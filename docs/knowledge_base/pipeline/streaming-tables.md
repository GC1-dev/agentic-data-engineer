# Lakeflow Streaming Tables Best Practices Guide

**Framework**: Databricks Delta Live Tables (Lakeflow Declarative Pipelines)
**Official Docs**: https://docs.databricks.com/en/delta-live-tables/index.html
**Last Updated**: 2025-11-19
**Purpose**: Comprehensive guide for implementing real-time, incremental processing with streaming tables in DLT pipelines

> 📖 **Related Documentation**:
> - [DLT Best Practices Overview](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md) - Core concepts, expectations, configuration
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md) - Batch processing patterns

---

## Table of Contents

1. [What are Streaming Tables?](#what-are-streaming-tables)
2. [When to Use Streaming Tables](#when-to-use-streaming-tables)
3. [Streaming Table Patterns](#streaming-table-patterns)
4. [Data Quality for Streaming](#data-quality-for-streaming)
5. [CDC & Incremental Processing](#cdc--incremental-processing)
6. [Performance Optimization](#performance-optimization)
7. [Configuration Best Practices](#configuration-best-practices)
8. [Monitoring Streaming Pipelines](#monitoring-streaming-pipelines)
9. [Testing Strategy](#testing-strategy)
10. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

---

## What are Streaming Tables?

**Streaming Tables** are DLT's approach to incremental, continuous data processing. They process data as it arrives, maintaining state and checkpoints automatically.

**Key Characteristics**:
- ✅ **Incremental Processing**: Only new data is processed
- ✅ **Automatic Checkpointing**: DLT manages streaming state
- ✅ **Always Appending**: Designed for append-only workloads
- ✅ **Low Latency**: Minutes, not hours
- ✅ **Fault Tolerant**: Automatic recovery from failures

**Core Syntax**:
```python
import dlt

@dlt.table(name="events_bronze")
def events_bronze():
    return (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", "broker:9092")
        .option("subscribe", "events_topic")
        .load()
    )
```

---

## When to Use Streaming Tables

### Use Streaming Tables When:

- ✅ **Data arrives continuously** (Kafka, Kinesis, cloud storage with Auto Loader)
- ✅ **Low latency required** (minutes, not hours)
- ✅ **Incremental processing needed** (only process new data)
- ✅ **CDC (Change Data Capture) required**
- ✅ **Event-driven architecture**

### Real-World Use Cases:

1. **Real-Time Event Processing**
   - Clickstream analytics
   - IoT sensor data
   - Application logs
   - User behavior tracking

2. **CDC Pipelines**
   - Database replication
   - Slowly Changing Dimensions (SCD Type 1 & 2)
   - Maintaining current state tables

3. **Streaming Aggregations**
   - Real-time dashboards
   - Live metrics computation
   - Anomaly detection

---

## Streaming Table Patterns

### Pattern 1: Auto Loader for Cloud Storage

**Best for**: Ingesting files from S3/ADLS/GCS

```python
@dlt.table(
    name="events_bronze",
    comment="Raw events streamed from cloud storage",
    table_properties={
        "quality": "bronze",
        "delta.enableChangeDataFeed": "true"
    }
)
def events_bronze():
    return (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", "/schema/events")
        .option("cloudFiles.inferColumnTypes", "true")
        .option("cloudFiles.schemaEvolutionMode", "addNewColumns")
        .option("cloudFiles.maxFilesPerTrigger", "1000")
        .load("/data/raw/events/")
    )
```

**Auto Loader Benefits**:
- ✅ Automatic schema inference and evolution
- ✅ Efficient incremental processing (tracks processed files)
- ✅ Handles millions of files
- ✅ Supports JSON, CSV, Avro, Parquet, ORC

### Pattern 2: Kafka/Event Hubs Integration

**Best for**: Real-time message streams

```python
@dlt.table(
    name="kafka_events_bronze",
    comment="Real-time events from Kafka",
    table_properties={
        "quality": "bronze",
        "delta.enableChangeDataFeed": "true"
    }
)
def kafka_events_bronze():
    return (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", "broker1:9092,broker2:9092")
        .option("subscribe", "events_topic")
        .option("startingOffsets", "latest")
        .option("maxOffsetsPerTrigger", "10000")
        .load()
        .selectExpr(
            "CAST(key AS STRING) as event_key",
            "CAST(value AS STRING) as event_json",
            "topic",
            "partition",
            "offset",
            "timestamp as kafka_timestamp"
        )
    )
```

### Pattern 3: Streaming Transformation Chain

**Bronze → Silver → Gold** with streaming tables:

```python
# Bronze: Raw ingestion
@dlt.table(
    name="events_bronze",
    comment="Raw events - no transformations",
    table_properties={
        "quality": "bronze",
        "delta.enableChangeDataFeed": "true"
    }
)
def events_bronze():
    return (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", "/schema_path")
        .load("/bronze/events/")
    )

# Silver: Cleaned & validated
@dlt.table(
    name="events_silver",
    comment="Cleaned and validated events",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true"
    }
)
@dlt.expect_or_fail("valid_timestamp", "event_timestamp IS NOT NULL")
@dlt.expect_or_drop("valid_user_id", "user_id IS NOT NULL")
@dlt.expect("valid_country", "LENGTH(country_code) = 2")
def events_silver():
    return (
        dlt.read_stream("events_bronze")
        .select(
            col("event_id"),
            col("event_timestamp").cast("timestamp"),
            col("user_id"),
            upper(col("country_code")).alias("country_code"),
            col("event_type"),
            col("session_id")
        )
    )

# Gold: Real-time aggregations (using streaming)
@dlt.table(
    name="events_gold_realtime",
    comment="Real-time session metrics"
)
def events_gold_realtime():
    return (
        dlt.read_stream("events_silver")
        .withWatermark("event_timestamp", "10 minutes")
        .groupBy(
            window("event_timestamp", "5 minutes"),
            "user_id",
            "session_id"
        )
        .agg(
            count("*").alias("event_count"),
            countDistinct("event_type").alias("unique_event_types")
        )
    )
```

### Pattern 4: Input Source Views for Streaming

**Best Practice**: Wrap external streaming sources with `@dlt.view`

```python
@dlt.view(comment="Bronze: Android Events Stream")
def bronze_android_events():
    """Input source: Streaming from external bronze table"""
    return spark.readStream.table("prod_trusted_bronze.internal.android_events")

@dlt.view(comment="Bronze: iOS Events Stream")
def bronze_ios_events():
    """Input source: Streaming from external bronze table"""
    return spark.readStream.table("prod_trusted_bronze.internal.ios_events")

# Then combine in downstream streaming table
@dlt.table(
    name="silver_mobile_events",
    comment="Unified mobile events from all platforms"
)
@dlt.expect_or_drop("valid_timestamp", "event_timestamp IS NOT NULL")
def silver_mobile_events():
    android_stream = dlt.read_stream("bronze_android_events")
    ios_stream = dlt.read_stream("bronze_ios_events")

    return android_stream.unionByName(ios_stream, allowMissingColumns=True)
```

---

## Data Quality for Streaming

> 📖 **Core DLT Expectations**: See [DLT Best Practices - Data Quality Expectations](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#data-quality-expectations) for:
> - Expectation types (TRACK, DROP, FAIL)
> - Severity guidelines
> - Grouping expectations
> - Quarantine pattern basics

### Streaming-Specific Quality Patterns

#### Pattern 1: Critical Field Validation

```python
@dlt.table(name="events_silver")
@dlt.expect_or_fail("has_partition_key", "event_date IS NOT NULL")
@dlt.expect_or_fail("has_event_id", "event_id IS NOT NULL")
@dlt.expect_or_drop("valid_timestamp", "event_timestamp IS NOT NULL")
@dlt.expect_or_drop("valid_user", "user_id IS NOT NULL AND LENGTH(user_id) > 0")
def events_silver():
    return dlt.read_stream("events_bronze")
```

#### Pattern 2: Quarantine Pattern for Streaming

Capture dropped records for investigation:

```python
# Main streaming table with expectations
@dlt.table(name="events_silver")
@dlt.expect_or_drop("valid_user", "user_id IS NOT NULL")
@dlt.expect_or_drop("valid_email", "email LIKE '%@%'")
def events_silver():
    return dlt.read_stream("events_bronze")

# Quarantine streaming table for rejected records
@dlt.table(name="events_quarantine")
def events_quarantine():
    return (
        dlt.read_stream("events_bronze")
        .filter(
            col("user_id").isNull() |
            ~col("email").rlike(".*@.*")
        )
        .withColumn("quarantine_reason", lit("failed_expectations"))
        .withColumn("quarantine_timestamp", current_timestamp())
    )
```

#### Pattern 3: Watermarking for Late Data

```python
@dlt.table(name="events_with_watermark")
def events_with_watermark():
    return (
        dlt.read_stream("events_bronze")
        .withWatermark("event_timestamp", "1 hour")  # Allow 1 hour of late data
        .filter(col("event_timestamp").isNotNull())
    )
```

---

## CDC & Incremental Processing

> 📖 **CDC Basics**: See [DLT Best Practices - CDC & Incremental Processing](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#cdc--incremental-processing) for:
> - Enabling CDC (Change Data Capture)
> - Basic CDC consumption patterns
> - Why to use CDC

### Streaming-Specific CDC Patterns

#### Enable CDC for Streaming Tables

**Table Property** (Recommended):
```python
@dlt.table(
    name="users_silver",
    table_properties={"delta.enableChangeDataFeed": "true"}
)
def users_silver():
    return dlt.read_stream("users_bronze")
```

### APPLY CHANGES API (SCD Type 1 & 2)

#### SCD Type 1 (Current State Only)

```python
# Create target streaming table
dlt.create_streaming_table("users_current")

# Apply changes (keeps only latest state)
dlt.apply_changes(
    target="users_current",
    source="users_cdc",
    keys=["user_id"],
    sequence_by="updated_timestamp",
    stored_as_scd_type=1
)
```

#### SCD Type 2 (Full History)

```python
# Create target streaming table
dlt.create_streaming_table("users_history")

# Apply changes (maintains full history)
dlt.apply_changes(
    target="users_history",
    source="users_cdc",
    keys=["user_id"],
    sequence_by="updated_timestamp",
    stored_as_scd_type=2
)
```

#### Advanced APPLY CHANGES with Column Filtering

```python
dlt.create_streaming_table("customers")

dlt.apply_changes(
    target="customers",
    source="customers_cdc",
    keys=["customer_id"],
    sequence_by="update_timestamp",
    stored_as_scd_type=2,
    except_column_list=["_metadata", "_ingestion_timestamp"],  # Exclude columns
    ignore_null_updates=True,  # Ignore updates where all non-key columns are NULL
    apply_as_deletes="operation = 'DELETE'"  # Handle deletes
)
```

### CDC Consumption Pattern

```python
# Read changes from CDC-enabled table
@dlt.table(name="users_changes_consumer")
def users_changes_consumer():
    changes_df = (
        spark.readStream
        .format("delta")
        .option("readChangeFeed", "true")
        .option("startingVersion", 0)
        .table("LIVE.users_silver")
    )

    # Process only inserts and updates
    return changes_df.filter(
        col("_change_type").isin("insert", "update_postimage")
    )
```

---

## Performance Optimization

> 📖 **Core Optimization Principles**: See [DLT Best Practices - Performance Optimization](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#performance-optimization) for:
> - Partitioning guidelines
> - Auto-optimization settings
> - Cluster sizing

### Streaming-Specific Optimization

#### 1. Trigger Configuration

Control micro-batch frequency:

```python
@dlt.table(
    name="events_bronze",
    spark_conf={
        "spark.databricks.delta.streaming.trigger.processingTime": "10 seconds"
    }
)
def events_bronze():
    return spark.readStream.format("cloudFiles").load("/data/")
```

**Trigger Guidelines**:
- **Low latency (seconds)**: `"1 second"` to `"10 seconds"`
- **Balanced (minutes)**: `"5 minutes"` to `"15 minutes"`
- **Cost-optimized (once)**: Use `availableNow` trigger

#### 2. Auto Loader Optimization

```python
@dlt.table(name="events_bronze")
def events_bronze():
    return (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", "/schema/events")
        .option("cloudFiles.maxFilesPerTrigger", "1000")  # Limit files per batch
        .option("cloudFiles.maxBytesPerTrigger", "10g")    # Limit data per batch
        .option("cloudFiles.useNotifications", "true")     # Use cloud notifications
        .load("/data/events/")
    )
```

**Tuning Parameters**:
- `maxFilesPerTrigger`: Control batch size (default: 1000)
- `maxBytesPerTrigger`: Limit data volume per trigger
- `useNotifications`: Enable for S3/ADLS notifications (faster discovery)

#### 3. State Management for Streaming Aggregations

```python
# Configure state store location
spark.conf.set(
    "spark.sql.streaming.stateStore.providerClass",
    "com.databricks.sql.streaming.state.RocksDBStateStoreProvider"
)

# For aggregations with state
@dlt.table(name="session_aggregates")
def session_aggregates():
    return (
        dlt.read_stream("events_silver")
        .withWatermark("event_timestamp", "10 minutes")
        .groupBy(
            window("event_timestamp", "5 minutes", "1 minute"),
            "session_id"
        )
        .agg(count("*").alias("event_count"))
    )
```

---

## Configuration Best Practices

> 📖 **Core Configuration**: See [DLT Best Practices - Configuration](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#configuration-best-practices) for:
> - Pipeline YAML structure
> - Environment-specific configuration
> - Secrets management
> - Notification setup

### Streaming-Specific Configuration

#### Pipeline Configuration for Streaming

```yaml
# databricks-workflows/streaming_pipeline.yml
name: "realtime_events_pipeline"

catalog: "prod_trusted"
target: "${catalog}.meta_search"

configuration:
  pipeline.env: "prod"
  pipeline.mode: "streaming"

# Cluster Configuration
clusters:
  - label: "default"
    autoscale:
      min_workers: 2
      max_workers: 8
    node_type_id: "i3.xlarge"
    spark_conf:
      # Streaming-specific configuration
      "spark.databricks.delta.streaming.trigger.processingTime": "5 minutes"
      "spark.sql.streaming.stateStore.providerClass": "com.databricks.sql.streaming.state.RocksDBStateStoreProvider"

      # Delta optimization
      "spark.databricks.delta.properties.defaults.enableChangeDataFeed": "true"
      "spark.databricks.delta.autoOptimize.optimizeWrite": "true"
      "spark.sql.adaptive.enabled": "true"

# Continuous mode (always running)
trigger:
  continuous: true

# Channel
channel: "CURRENT"
```

---

## Monitoring Streaming Pipelines

> 📖 **Core Monitoring**: See [DLT Best Practices - Monitoring & Observability](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#monitoring--observability) for:
> - Event logs overview
> - Data quality metrics queries
> - Key metrics to track
> - Alerting setup

### Streaming-Specific Monitoring

#### 1. Streaming Lag and Backlog Metrics

**Query Pipeline Events for Streaming**:
```sql
SELECT
    timestamp,
    details:flow_definition.output_dataset as table_name,
    details:flow_progress.status as status,
    details:flow_progress.metrics.num_output_rows as rows_written,
    details:flow_progress.metrics.backlog_bytes as backlog_bytes
FROM event_log(TABLE(LIVE.events_bronze))
WHERE event_type = 'flow_progress'
  AND details:flow_definition.schema.stream = true
ORDER BY timestamp DESC
```

**Key Streaming Metrics**:
- ✅ **Backlog**: `backlog_bytes` (how much data is pending)
- ✅ **Throughput**: `num_output_rows` per trigger
- ✅ **Processing Time**: Duration per micro-batch
- ✅ **Trigger Frequency**: Time between triggers

#### 2. Streaming Lag Monitoring

```sql
-- Monitor streaming lag
SELECT
    timestamp,
    details:flow_definition.output_dataset as table_name,
    details:flow_progress.metrics.backlog_bytes / (1024 * 1024 * 1024) as backlog_gb,
    details:flow_progress.metrics.num_input_rows as input_rows,
    details:flow_progress.metrics.num_output_rows as output_rows
FROM event_log(TABLE(LIVE.events_bronze))
WHERE event_type = 'flow_progress'
  AND details:flow_definition.schema.stream = true
ORDER BY timestamp DESC
LIMIT 100
```

---

## Testing Strategy

> 📖 **Core Testing Principles**: See [DLT Best Practices - Testing Strategy](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#testing-strategy) for:
> - Local development setup
> - Basic unit test patterns
> - Data quality test patterns

### Streaming-Specific Testing

#### 1. Local Streaming Tests

```python
import pytest
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

@pytest.fixture
def spark():
    return (
        SparkSession.builder
        .master("local[2]")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .getOrCreate()
    )

def test_streaming_transformation(spark, tmp_path):
    # Create test data
    test_data = [
        {"event_id": 1, "user_id": "user1", "event_timestamp": "2023-01-01T10:00:00"},
        {"event_id": 2, "user_id": "user2", "event_timestamp": "2023-01-01T10:05:00"}
    ]

    # Write test data
    input_path = str(tmp_path / "input")
    spark.createDataFrame(test_data).write.format("json").save(input_path)

    # Read as stream
    stream_df = (
        spark.readStream
        .format("json")
        .schema("event_id INT, user_id STRING, event_timestamp STRING")
        .load(input_path)
    )

    # Apply transformation
    transformed_df = stream_df.filter(col("user_id").isNotNull())

    # Write to memory sink for testing
    output_path = str(tmp_path / "output")
    query = (
        transformed_df.writeStream
        .format("delta")
        .option("checkpointLocation", str(tmp_path / "checkpoint"))
        .start(output_path)
    )

    query.processAllAvailable()
    query.stop()

    # Verify results
    result_df = spark.read.format("delta").load(output_path)
    assert result_df.count() == 2
```

#### 2. Testing Watermark and Late Data Handling

```python
def test_watermark_behavior(spark, tmp_path):
    # Create test data with various timestamps
    test_data = [
        {"event_id": 1, "event_timestamp": "2023-01-01T10:00:00", "value": 100},
        {"event_id": 2, "event_timestamp": "2023-01-01T09:00:00", "value": 50},  # Late data
        {"event_id": 3, "event_timestamp": "2023-01-01T10:30:00", "value": 75}
    ]

    input_path = str(tmp_path / "input")
    spark.createDataFrame(test_data).write.format("json").save(input_path)

    # Read as stream with watermark
    stream_df = (
        spark.readStream
        .format("json")
        .schema("event_id INT, event_timestamp STRING, value INT")
        .load(input_path)
        .withColumn("event_timestamp", col("event_timestamp").cast("timestamp"))
        .withWatermark("event_timestamp", "30 minutes")
    )

    # Process and verify watermark behavior
    output_path = str(tmp_path / "output")
    query = (
        stream_df.writeStream
        .format("delta")
        .option("checkpointLocation", str(tmp_path / "checkpoint"))
        .start(output_path)
    )

    query.processAllAvailable()
    query.stop()

    # Verify results
    result_df = spark.read.format("delta").load(output_path)
    assert result_df.count() >= 2  # Should include events within watermark
```

---

## Common Pitfalls & Solutions

### Pitfall 1: Mixing Batch and Streaming

❌ **Problem**:
```python
@dlt.table(name="mixed")
def mixed():
    stream_df = dlt.read_stream("streaming_source")  # Streaming
    batch_df = dlt.read("batch_source")              # Batch
    return stream_df.union(batch_df)  # ERROR: Can't mix!
```

✅ **Solution**: Keep streaming and batch separate
```python
@dlt.table(name="streaming_output")
def streaming_output():
    return dlt.read_stream("streaming_source")

@dlt.table(name="batch_output")
def batch_output():
    return dlt.read("batch_source")
```

### Pitfall 2: Forgetting Watermarks for Aggregations

❌ **Problem**: State grows indefinitely
```python
@dlt.table(name="aggregates")
def aggregates():
    return (
        dlt.read_stream("events")
        .groupBy(window("timestamp", "5 minutes"))  # No watermark!
        .count()
    )
```

✅ **Solution**: Add watermark
```python
@dlt.table(name="aggregates")
def aggregates():
    return (
        dlt.read_stream("events")
        .withWatermark("timestamp", "10 minutes")  # Clean up old state
        .groupBy(window("timestamp", "5 minutes"))
        .count()
    )
```

### Pitfall 3: Using `.write()` in Streaming DLT

❌ **Problem**:
```python
@dlt.table(name="output")
def output():
    df = dlt.read_stream("input")
    df.writeStream.format("delta").start("/path")  # DON'T DO THIS!
    return df
```

✅ **Solution**: Return DataFrame, let DLT handle streaming writes
```python
@dlt.table(name="output")
def output():
    return dlt.read_stream("input").select("*")
```

### Pitfall 4: Not Enabling CDC

❌ **Problem**: Downstream can't consume changes
```python
@dlt.table(name="silver_table")
def silver_table():
    return dlt.read_stream("bronze_table")  # CDC not enabled!
```

✅ **Solution**: Enable CDC
```python
@dlt.table(
    name="silver_table",
    table_properties={"delta.enableChangeDataFeed": "true"}
)
def silver_table():
    return dlt.read_stream("bronze_table")
```

### Pitfall 5: Over-Aggressive Triggers

❌ **Problem**: Too frequent processing increases cost
```python
spark_conf={
    "spark.databricks.delta.streaming.trigger.processingTime": "1 second"
}
# Wastes resources if data arrives every 5 minutes
```

✅ **Solution**: Match trigger to data arrival pattern
```python
spark_conf={
    "spark.databricks.delta.streaming.trigger.processingTime": "5 minutes"
}
# Process every 5 minutes if data arrives every 5 minutes
```

---

## Quick Reference

### Streaming Table Syntax

```python
# Basic streaming table
@dlt.table(name="table_name")
def table_name():
    return spark.readStream.format("source").load()

# With expectations
@dlt.table(name="table_name")
@dlt.expect_or_drop("valid_field", "field IS NOT NULL")
def table_name():
    return dlt.read_stream("source_table")

# With CDC enabled
@dlt.table(
    name="table_name",
    table_properties={"delta.enableChangeDataFeed": "true"}
)
def table_name():
    return dlt.read_stream("source_table")
```

### Common Streaming Operations

| Operation | Code |
|-----------|------|
| **Read streaming** | `dlt.read_stream("table")` |
| **Auto Loader** | `spark.readStream.format("cloudFiles")` |
| **Kafka** | `spark.readStream.format("kafka")` |
| **Watermark** | `.withWatermark("timestamp", "10 minutes")` |
| **Window** | `window("timestamp", "5 minutes")` |
| **CDC** | `table_properties={"delta.enableChangeDataFeed": "true"}` |

---

## Additional Resources

**Official Documentation**:
- Streaming Tables: https://docs.databricks.com/en/delta-live-tables/streaming.html
- Auto Loader: https://docs.databricks.com/en/ingestion/auto-loader/index.html
- CDC: https://docs.databricks.com/en/delta/delta-change-data-feed.html
- Structured Streaming: https://docs.databricks.com/en/structured-streaming/index.html

**Related Knowledge Base Documentation**:
- Materialized Views: `.agents/knowledge_base/LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md`
- Project Structure: `.agents/knowledge_base/PROJECT_STRUCTURE.md`
- Medallion Architecture: `.agents/knowledge_base/MEDALLION_ARCHITECTURE.md`

---

**Version**: 1.0.0
**Maintained by**: Data Platform Team
**Last Review**: 2025-11-19
**Next Review**: 2025-12-19
