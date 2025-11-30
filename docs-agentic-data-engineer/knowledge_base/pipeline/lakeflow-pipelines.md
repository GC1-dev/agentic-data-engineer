# Lakeflow Declarative Pipelines (DLT) Best Practices Guide

**Framework**: Databricks Delta Live Tables (Lakeflow Declarative Pipelines)
**Official Docs**: https://docs.databricks.com/en/delta-live-tables/index.html
**Last Updated**: 2025-11-19
**Purpose**: Knowledge base for implementing production-grade DLT pipelines

---

## 📚 Documentation Structure

This document provides a high-level overview of Lakeflow Declarative Pipelines. For detailed best practices on specific table types, refer to the specialized documents:

- **[Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md)** - Comprehensive guide for real-time, incremental processing with streaming tables
- **[Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md)** - Comprehensive guide for batch processing with materialized views

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Pipeline Architecture Patterns](#pipeline-architecture-patterns)
3. [Table Types & When to Use](#table-types--when-to-use)
4. [Data Quality Expectations](#data-quality-expectations)
5. [CDC & Incremental Processing](#cdc--incremental-processing)
6. [Performance Optimization](#performance-optimization)
7. [Configuration Best Practices](#configuration-best-practices)
8. [Monitoring & Observability](#monitoring--observability)
9. [Testing Strategy](#testing-strategy)
10. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

---

## Core Concepts

### What is Lakeflow Declarative Pipelines?

**Lakeflow Declarative Pipelines (DLT)** is Databricks' framework for building reliable, maintainable, and testable data pipelines using **declarative syntax** rather than imperative code.

**Key Principles**:
- **Declarative**: Define *what* you want, not *how* to do it
- **Dependency Management**: Automatic DAG construction from table references
- **Data Quality**: Built-in expectations for validation
- **Observability**: Automatic event logging and metrics

### Core Components

```
Pipeline
├── Streaming Tables (incremental, always appending)
├── Materialized Views (batch, full refresh or incremental)
├── Views (ephemeral, not persisted)
└── Flows (deprecated in newer versions, use streaming tables)
```

**Medallion Architecture** (Bronze → Silver → Gold):
- **Bronze**: Raw ingestion (landing zone)
- **Silver**: Cleaned, validated, deduplicated
- **Gold**: Aggregated, business-level metrics

---

## Pipeline Architecture Patterns

### 1. Batch vs. Streaming

> 📖 **For detailed guidance**, see:
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md)
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md)

#### Use **Streaming Tables** when:
- ✅ Data arrives continuously (Kafka, Kinesis, cloud storage)
- ✅ Need low latency (minutes, not hours)
- ✅ Incremental processing required
- ✅ CDC (Change Data Capture) needed

```python
import dlt

@dlt.table(
    name="events_bronze",
    comment="Raw events streamed from Kafka"
)
def events_bronze():
    return (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", "broker:9092")
        .option("subscribe", "events_topic")
        .load()
    )
```

#### Use **Materialized Views** (Batch) when:
- ✅ Daily/hourly batch processing sufficient
- ✅ Full table refresh acceptable
- ✅ Complex aggregations needed
- ✅ Data volumes are manageable

```python
@dlt.table(
    name="daily_metrics",
    comment="Daily aggregated metrics"
)
def daily_metrics():
    return (
        dlt.read("events_silver")
        .groupBy("date", "user_id")
        .agg(count("*").alias("event_count"))
    )
```

### 2. Medallion Architecture Implementation

**Input Sources** (External Tables as Views):

**Best Practice**: Always wrap external input sources with `@dlt.view` for clear documentation and testability.

```python
@dlt.view(comment="Bronze: Android Mini Search")
def bronze_android_mini_search():
    """Input source: prod_trusted_bronze.internal.android_mini_search"""
    return spark.table("prod_trusted_bronze.internal.android_mini_search")

@dlt.view(comment="Bronze: iOS Mini Search")
def bronze_ios_mini_search():
    """Input source: prod_trusted_bronze.internal.ios_mini_search"""
    return spark.table("prod_trusted_bronze.internal.ios_mini_search")
```

**Bronze Layer** (Raw Ingestion from Files):
```python
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
```

**Silver Layer** (Cleaned & Validated):
```python
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
            upper(col("country_code")).alias("country_code")
        )
    )
```

**Gold Layer** (Business Aggregates):
```python
@dlt.table(
    name="daily_user_metrics",
    comment="Daily user engagement metrics for reporting"
)
def daily_user_metrics():
    return (
        dlt.read("events_silver")
        .groupBy("date", "user_id", "country_code")
        .agg(
            count("*").alias("event_count"),
            countDistinct("session_id").alias("session_count")
        )
    )
```

---

## Table Types & When to Use

> 📖 **For detailed guidance**, see:
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md) - Real-time processing patterns
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md) - Batch processing patterns

### Comparison Table

| Feature | Streaming Table | Materialized View | View |
|---------|----------------|-------------------|------|
| **Persistence** | ✅ Persisted to storage | ✅ Persisted to storage | ❌ Ephemeral |
| **Incremental** | ✅ Always incremental | ⚠️ Can be incremental | ❌ Always full scan |
| **Expectations** | ✅ Supported | ✅ Supported | ❌ Not supported |
| **CDC Support** | ✅ Yes | ✅ Yes | ❌ No |
| **Use Case** | Real-time ingestion | Batch aggregations | Intermediate transforms |
| **Cost** | Medium (streaming) | Low (batch) | Minimal (no storage) |

### Decision Tree

```
Need to persist data?
├─ No → Use VIEW (ephemeral transformation)
└─ Yes → Need real-time processing?
    ├─ Yes → Use STREAMING TABLE
    └─ No → Use MATERIALIZED VIEW
```

### Views (Ephemeral)

**Use for**: Intermediate transformations that don't need persistence

```python
@dlt.view(name="events_cleaned")
def events_cleaned():
    return (
        dlt.read("events_bronze")
        .filter(col("event_timestamp").isNotNull())
    )

# Then reference in another table
@dlt.table(name="events_silver")
def events_silver():
    return dlt.read("events_cleaned").select("*")
```

**⚠️ Warning**: Views are recomputed on every read. For frequently accessed data, use tables instead.

### Input Source Pattern: External Tables as Views

**Best Practice**: When reading from external tables (outside the pipeline), always create a `@dlt.view` to wrap the source table reference.

**Why**:
- ✅ Clear documentation of pipeline inputs
- ✅ Centralized source table references
- ✅ Easy to mock during testing
- ✅ Consistent naming pattern across pipelines
- ✅ Simplified dependency tracking

**Pattern**:
```python
@dlt.view(comment="Bronze: Android Mini Search")
def bronze_android_mini_search():
    """Input source: prod_trusted_bronze.internal.android_mini_search"""
    return spark.table("prod_trusted_bronze.internal.android_mini_search")

@dlt.view(comment="Bronze: iOS Mini Search")
def bronze_ios_mini_search():
    """Input source: prod_trusted_bronze.internal.ios_mini_search"""
    return spark.table("prod_trusted_bronze.internal.ios_mini_search")

# Then transform in downstream tables
@dlt.table(
    name="silver_mini_search_events",
    comment="Cleaned and validated mini search events from all platforms"
)
@dlt.expect_or_drop("valid_timestamp", "event_timestamp IS NOT NULL")
def silver_mini_search_events():
    android_df = dlt.read("bronze_android_mini_search")
    ios_df = dlt.read("bronze_ios_mini_search")

    return android_df.unionByName(ios_df, allowMissingColumns=True)
```

**Naming Convention for Input Views**:
- Format: `bronze_<source_name>`
- Example: `bronze_android_mini_search`, `bronze_flight_search_requests`
- Comment: `"Bronze: <Human-Readable Source Name>"`

**Environment-Specific Sources**:
```python
@dlt.view(comment="Bronze: Android Mini Search")
def bronze_android_mini_search():
    """Input source from environment-specific bronze catalog"""
    env = spark.conf.get("pipeline.env", "prod")
    source_table = f"{env}_trusted_bronze.internal.android_mini_search"
    return spark.table(source_table)
```

---

## Data Quality Expectations

### Three Expectation Types

| Type | Decorator | SQL | Behavior | Use Case |
|------|-----------|-----|----------|----------|
| **TRACK** | `@dlt.expect()` | `CONSTRAINT name EXPECT (condition)` | Pass through, log violations | Monitor data quality |
| **DROP** | `@dlt.expect_or_drop()` | `CONSTRAINT ... ON VIOLATION DROP ROW` | Drop invalid records | Remove bad data |
| **FAIL** | `@dlt.expect_or_fail()` | `CONSTRAINT ... ON VIOLATION FAIL UPDATE` | Stop pipeline | Critical validation |

### Expectation Severity Guidelines

#### CRITICAL (expect_or_fail)
Use for violations that **must stop the pipeline**:
- Missing partition keys
- Schema violations
- Critical business rules

```python
@dlt.expect_or_fail("valid_partition", "dt IS NOT NULL")
@dlt.expect_or_fail("valid_schema", "event_id IS NOT NULL")
```

#### HIGH (expect_or_drop)
Use for violations where **records should be rejected**:
- Invalid data types
- Referential integrity violations
- Business rule violations

```python
@dlt.expect_or_drop("valid_email", "email LIKE '%@%'")
@dlt.expect_or_drop("valid_age", "age >= 0 AND age <= 120")
@dlt.expect_or_drop("valid_country", "LENGTH(country_code) = 2")
```

#### MEDIUM (expect - track only)
Use for violations that **should be monitored but not block data**:
- Optional field completeness
- Data quality metrics
- SLA tracking

```python
@dlt.expect("has_session_id", "session_id IS NOT NULL")
@dlt.expect("has_user_agent", "user_agent IS NOT NULL")
@dlt.expect("within_sla", "processing_time_ms < 60000")
```

### Grouping Expectations

**Python** - Use `expect_all*` for multiple expectations:
```python
@dlt.table(name="events_silver")
@dlt.expect_all({
    "valid_timestamp": "event_timestamp IS NOT NULL",
    "valid_user": "user_id IS NOT NULL",
    "within_range": "event_date >= '2023-01-01'"
})
def events_silver():
    return dlt.read("events_bronze")
```

**SQL**:
```sql
CREATE OR REFRESH STREAMING TABLE events_silver (
  CONSTRAINT valid_timestamp EXPECT (event_timestamp IS NOT NULL),
  CONSTRAINT valid_user EXPECT (user_id IS NOT NULL),
  CONSTRAINT within_range EXPECT (event_date >= '2023-01-01')
)
AS SELECT * FROM STREAM(LIVE.events_bronze)
```

### Expectation Best Practices

✅ **DO**:
- Name expectations clearly (`valid_email`, not `check_1`)
- Start with tracking expectations, then escalate to drop/fail
- Document business rules in expectation comments
- Use SQL functions for complex validation
- Group related expectations together

❌ **DON'T**:
- Use Python UDFs in expectations (not supported)
- Create expectations with side effects
- Use subqueries (not supported)
- Over-use `expect_or_fail` (can make pipeline brittle)

### Quarantine Pattern

Capture dropped records for investigation:

```python
# Main table with expectations
@dlt.table(name="events_silver")
@dlt.expect_or_drop("valid_user", "user_id IS NOT NULL")
@dlt.expect_or_drop("valid_email", "email LIKE '%@%'")
def events_silver():
    return dlt.read("events_bronze")

# Quarantine table for rejected records
@dlt.table(name="events_quarantine")
def events_quarantine():
    bronze = dlt.read("events_bronze")
    return bronze.filter(
        col("user_id").isNull() |
        ~col("email").rlike(".*@.*")
    ).withColumn("quarantine_reason", lit("failed_expectations"))
```

---

## CDC & Incremental Processing

> 📖 **For detailed CDC patterns**, see:
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md) - CDC with streaming, APPLY CHANGES API
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md) - Incremental batch processing

### Enable CDC (Change Data Capture)

**Table Property**:
```python
@dlt.table(
    name="users_silver",
    table_properties={"delta.enableChangeDataFeed": "true"}
)
def users_silver():
    return dlt.read("users_bronze")
```

**Spark Configuration** (Global):
```python
spark.conf.set("spark.databricks.delta.properties.defaults.enableChangeDataFeed", "true")
```

**Why Enable CDC**:
- ✅ Downstream consumers can read only changes
- ✅ Efficient incremental processing
- ✅ Support for SCD patterns (Slowly Changing Dimensions)
- ✅ Audit trail of all changes

### Basic CDC Consumption Pattern

```python
# Downstream consumer reading changes
changes_df = (
    spark.read
    .format("delta")
    .option("readChangeFeed", "true")
    .option("startingVersion", last_checkpoint)
    .table("silver_table")
)

# Filter for specific change types
inserts = changes_df.filter(col("_change_type") == "insert")
updates = changes_df.filter(col("_change_type").isin("update_preimage", "update_postimage"))
deletes = changes_df.filter(col("_change_type") == "delete")
```

**For Advanced Patterns**: See specialized documentation for APPLY CHANGES API, SCD implementations, and streaming CDC patterns.

---

## Performance Optimization

> 📖 **For detailed optimization patterns**, see:
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md) - Auto Loader, trigger tuning, state management
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md) - Batch optimization, joins, caching

### Core Optimization Principles

#### 1. Partitioning Strategy

```python
@dlt.table(
    name="events_silver",
    partition_cols=["date"],  # Partition by date
    table_properties={
        "pipelines.autoOptimize.zOrderCols": "date,user_id"  # Z-order
    }
)
def events_silver():
    return dlt.read("events_bronze")
```

**Partitioning Guidelines**:
- ✅ Partition by query filter columns (date, country, product_id)
- ✅ Target 100MB-1GB per partition
- ❌ Don't over-partition (<10MB per partition)
- ❌ Don't partition on high-cardinality columns

#### 2. Auto-Optimization

```python
table_properties={
    "delta.autoOptimize.optimizeWrite": "true",  # Bin-packing
    "delta.autoOptimize.autoCompact": "true",    # Auto-compaction
    "pipelines.autoOptimize.zOrderCols": "dt"    # Z-ordering
}
```

**When to Use**:
- `optimizeWrite`: Always enable for better write performance
- `autoCompact`: Enable if many small files (< 1MB)
- `zOrderCols`: Enable for frequently filtered columns

#### 3. Cluster Sizing

```yaml
# DLT Pipeline Configuration
clusters:
  - label: "default"
    autoscale:
      min_workers: 2     # Start small
      max_workers: 8     # Scale based on data volume
    node_type_id: "i3.xlarge"  # Memory-optimized for Delta
    spark_conf:
      "spark.sql.adaptive.enabled": "true"
      "spark.sql.adaptive.coalescePartitions.enabled": "true"
```

**Sizing Guidelines**:
- **Small datasets (<1GB/day)**: 2-4 workers
- **Medium datasets (1-100GB/day)**: 4-8 workers
- **Large datasets (>100GB/day)**: 8-16+ workers

---

## Configuration Best Practices

### Pipeline Configuration YAML

```yaml
# databricks-workflows/pipeline_name.yml
name: "ios_mini_search_daily_pipeline"

# Catalog & Schema (Unity Catalog)
catalog: "prod_trusted"
target: "${catalog}.meta_search"

# Configuration
configuration:
  pipeline.env: "prod"
  pipeline.owner: "data_team"

# Libraries
libraries:
  - notebook:
      path: "/pipelines/ios_mini_search"
  - maven:
      coordinates: "com.example:library:1.0.0"

# Cluster Configuration
clusters:
  - label: "default"
    autoscale:
      min_workers: 2
      max_workers: 8
    node_type_id: "i3.xlarge"
    spark_conf:
      "spark.databricks.delta.properties.defaults.enableChangeDataFeed": "true"
      "spark.databricks.delta.autoOptimize.optimizeWrite": "true"
      "spark.sql.adaptive.enabled": "true"

# Schedule
trigger:
  cron:
    quartz_cron_schedule: "0 0 7 * * ?"  # Daily at 07:00 UTC
    timezone_id: "UTC"

# Channel (Development or Production)
channel: "CURRENT"  # or "PREVIEW" for latest features

# Job-level notifications
notifications:
  - email_recipients:
      - "team@company.com"
    on_failure: true
    on_success: false
    on_duration_warning_threshold_exceeded: true
```

### Environment-Specific Configuration

```python
# Use configuration in pipeline code
env = spark.conf.get("pipeline.env", "dev")

bronze_table = f"{env}_trusted_bronze.internal.events"
silver_table = f"{env}_trusted_silver.meta_search.events"
```

### Secrets Management

```python
# Don't hardcode credentials
webhook_url = dbutils.secrets.get(scope="slack", key="webhook_url")
api_key = dbutils.secrets.get(scope="external_api", key="api_key")
```

---

## Monitoring & Observability

> 📖 **For detailed monitoring patterns**, see:
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md) - Streaming lag, backlog monitoring
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md) - Batch execution metrics

### Core Monitoring Principles

#### 1. Event Logs

**Query Pipeline Events**:
```sql
SELECT
    timestamp,
    details:flow_definition.output_dataset as table_name,
    details:flow_progress.status as status,
    details:flow_progress.metrics.num_output_rows as rows_written
FROM event_log(TABLE(LIVE.table_name))
WHERE event_type = 'flow_progress'
ORDER BY timestamp DESC
```

**Key Event Types**:
- `flow_progress`: Pipeline execution status
- `user_action`: Manual operations
- `update_progress`: Overall pipeline progress
- `flow_definition`: Table/view definitions

#### 2. Data Quality Metrics

```sql
-- Query expectation violations
SELECT
    timestamp,
    details:flow_definition.output_dataset as table,
    details:flow_progress.data_quality.expectations as expectations,
    details:flow_progress.data_quality.dropped_records as dropped
FROM event_log(TABLE(LIVE.table_name))
WHERE event_type = 'flow_progress'
  AND details:flow_progress.data_quality.dropped_records > 0
```

#### 3. Key Metrics to Track

- ✅ Success rate (target: >= 99.9%)
- ✅ Processing time per table
- ✅ Row counts (input vs. output)
- ✅ Data quality violations
- ✅ Cost per run

#### 4. Alerting

**Use Databricks Job Notifications** - Configure alerts at the job/task level, not in pipeline code.

**Documentation**: https://docs.databricks.com/aws/en/jobs/notifications

#### Job-Level Notifications (YAML)

```yaml
# databricks-workflows/pipeline_name.yml
name: "ios_mini_search_daily_pipeline"

# ... pipeline configuration ...

# Job-level notifications
notifications:
  # Email notifications
  - email_recipients:
      - "team@company.com"
      - "oncall@company.com"
    on_failure: true
    on_success: false
    on_duration_warning_threshold_exceeded: true

  # Slack notifications (requires admin-configured webhook)
  - slack:
      webhook_url: "{{secrets/slack/pipeline_alerts_webhook}}"
    on_failure: true
    on_start: false

  # Webhook for external systems (PagerDuty, custom alerting)
  - webhook:
      url: "{{secrets/pagerduty/webhook_url}}"
    on_failure: true

# Duration warning threshold (optional)
timeout_seconds: 3600
max_retries: 3
```

#### Task-Level Notifications

**⚠️ Important**: Use task-level notifications for better retry handling. Job-level notifications don't trigger during task retries.

```yaml
tasks:
  - task_key: process_data
    python_wheel_task:
      package_name: my_package
      entry_point: loader

    # Task-level notifications
    notification_settings:
      no_alert_for_skipped_runs: true  # Reduce noise
      no_alert_for_canceled_runs: true
      alert_on_last_attempt: true      # Only alert after all retries exhausted

    # Email notification for this task
    email_notifications:
      on_failure:
        - "team@company.com"
      on_duration_warning_threshold_exceeded:
        - "oncall@company.com"

    # Retry configuration
    max_retries: 3
    timeout_seconds: 3600
```

#### Notification Best Practices

✅ **DO**:
- Use **task-level notifications** instead of job-level for failure scenarios (better retry handling)
- Configure "Mute notifications until the last retry" to avoid alert fatigue
- Filter out skipped/canceled run notifications (`no_alert_for_skipped_runs: true`)
- Set duration warning thresholds for SLA monitoring
- Use Databricks Secrets for webhook URLs
- Limit to 3 system destinations per event type

❌ **DON'T**:
- Add alerting logic in pipeline code (use job configuration instead)
- Depend on specific Slack/Teams message formats (content may change)
- Alert on every retry attempt (use `alert_on_last_attempt: true`)
- Hardcode webhook URLs in YAML (use secrets)

#### Notification Event Types

| Event Type | When Triggered | Use Case |
|------------|----------------|----------|
| `on_start` | Job/task begins | High-priority pipeline start tracking |
| `on_success` | Successful completion | Daily success confirmations, SLA compliance |
| `on_failure` | Failed execution | Immediate incident response |
| `on_duration_warning_threshold_exceeded` | Exceeds timeout | SLA monitoring, performance degradation |

#### Example: Production Pipeline with Alerts

```yaml
name: "production_pipeline"

tasks:
  - task_key: ingest_bronze
    pipeline_task:
      pipeline_id: "bronze_pipeline_id"

    # Only alert on final failure (after retries)
    notification_settings:
      alert_on_last_attempt: true
      no_alert_for_skipped_runs: true

    email_notifications:
      on_failure:
        - "data-platform-oncall@company.com"
      on_duration_warning_threshold_exceeded:
        - "data-platform-team@company.com"

    timeout_seconds: 3600  # 1 hour SLA
    max_retries: 3
    min_retry_interval_millis: 300000  # 5 minutes

# Job-level notifications for overall pipeline
notifications:
  - email_recipients:
      - "data-platform-team@company.com"
    on_success: false  # Don't spam on success
    on_failure: true   # Alert if entire job fails
```

#### Webhook Payload Example

When a task fails, Databricks sends this JSON payload:

```json
{
  "event_type": "jobs.on_failure",
  "workspace_id": "12345",
  "task": {
    "task_key": "process_data"
  },
  "run": {
    "run_id": "67890",
    "parent_run_id": "54321"
  },
  "job": {
    "job_id": "11111",
    "name": "production_pipeline"
  }
}
```

Use this payload to integrate with external alerting systems (PagerDuty, Opsgenie, custom dashboards).

---

## Testing Strategy

> 📖 **For detailed testing patterns**, see:
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md) - Streaming-specific tests
> - [Materialized Views Best Practices](./LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md) - Batch processing tests

### Core Testing Principles

#### 1. Local Development Setup

```python
# Use Databricks Connect for local testing
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("test_pipeline")
    .master("local[2]")
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    .getOrCreate()
)
```

#### 2. Basic Unit Test Pattern

```python
import pytest
from pyspark.sql import SparkSession

@pytest.fixture
def spark():
    return SparkSession.builder.master("local[2]").getOrCreate()

def test_filter_logic(spark):
    # Create test data
    test_data = [{"id": 1, "value": 100}, {"id": 2, "value": -50}]
    input_df = spark.createDataFrame(test_data)

    # Apply transformation
    output_df = input_df.filter(col("value") >= 0)

    # Assert
    assert output_df.count() == 1
    assert output_df.first()["id"] == 1
```

#### 3. Data Quality Test Pattern

```python
def test_expectations_enforce_quality(spark):
    # Create data with violations
    bad_data = [{"user_id": None, "email": "invalid"}]
    df = spark.createDataFrame(bad_data)

    # Apply expectations (simulating DLT behavior)
    result_df = df.filter(col("user_id").isNotNull() & col("email").rlike(".*@.*"))

    # Verify bad records dropped
    assert result_df.count() == 0
```

---

## Common Pitfalls & Solutions

### Pitfall 1: Mixing Batch and Streaming

❌ **Problem**:
```python
@dlt.table(name="mixed")
def mixed():
    # Streaming read
    stream_df = dlt.read_stream("streaming_source")
    # Batch read
    batch_df = dlt.read("batch_source")
    return stream_df.union(batch_df)  # ERROR: Can't mix!
```

✅ **Solution**: Keep streaming and batch pipelines separate
```python
@dlt.table(name="streaming_output")
def streaming_output():
    return dlt.read_stream("streaming_source")

@dlt.table(name="batch_output")
def batch_output():
    return dlt.read("batch_source")
```

### Pitfall 2: Using `.write()` in DLT

❌ **Problem**:
```python
@dlt.table(name="output")
def output():
    df = dlt.read("input")
    df.write.format("delta").save("/path")  # DON'T DO THIS!
    return df
```

✅ **Solution**: Return DataFrame, let DLT handle writing
```python
@dlt.table(name="output")
def output():
    return dlt.read("input").select("*")
```

### Pitfall 3: Forgetting CDC Enablement

❌ **Problem**: Downstream consumers can't use CDC
```python
@dlt.table(name="silver_table")
def silver_table():
    return dlt.read("bronze_table")  # CDC not enabled!
```

✅ **Solution**: Enable CDC in table properties
```python
@dlt.table(
    name="silver_table",
    table_properties={"delta.enableChangeDataFeed": "true"}
)
def silver_table():
    return dlt.read("bronze_table")
```

### Pitfall 4: Over-using expect_or_fail

❌ **Problem**: Pipeline too brittle
```python
@dlt.expect_or_fail("has_everything", "column1 IS NOT NULL AND column2 IS NOT NULL AND ...")
# One null value stops entire pipeline!
```

✅ **Solution**: Use appropriate severity levels
```python
@dlt.expect_or_fail("has_partition_key", "dt IS NOT NULL")  # Critical only
@dlt.expect_or_drop("has_user_id", "user_id IS NOT NULL")  # Drop bad records
@dlt.expect("has_optional_field", "optional_field IS NOT NULL")  # Track only
```

### Pitfall 5: Hardcoded Table Names

❌ **Problem**: Can't deploy to different environments
```python
@dlt.table(name="output")
def output():
    return spark.table("prod_catalog.prod_schema.input")  # Hardcoded!
```

✅ **Solution**: Use configuration
```python
@dlt.table(name="output")
def output():
    env = spark.conf.get("pipeline.env", "dev")
    input_table = f"{env}_catalog.{env}_schema.input"
    return dlt.read(input_table)
```

### Pitfall 6: Ignoring Small Files

❌ **Problem**: Performance degrades over time
```python
# Many small files accumulate
# Query performance gets slower and slower
```

✅ **Solution**: Enable auto-compaction
```python
table_properties={
    "delta.autoOptimize.autoCompact": "true",
    "delta.autoOptimize.optimizeWrite": "true"
}
```

### Pitfall 7: Missing Partitioning

❌ **Problem**: Full table scans on every query
```python
@dlt.table(name="events")
def events():
    return dlt.read("bronze_events")  # No partitioning!
```

✅ **Solution**: Partition by query filter columns
```python
@dlt.table(
    name="events",
    partition_cols=["date"]
)
def events():
    return dlt.read("bronze_events")
```

---

## Quick Reference

### Cheat Sheet

| Task | Python | SQL |
|------|--------|-----|
| **Streaming Table** | `@dlt.table` + `read_stream` | `CREATE STREAMING TABLE` |
| **Materialized View** | `@dlt.table` + `read` | `CREATE LIVE TABLE` |
| **View** | `@dlt.view` | `CREATE TEMPORARY LIVE VIEW` |
| **Input Source View** | `@dlt.view` + `spark.table()` | N/A |
| **Track Violations** | `@dlt.expect()` | `CONSTRAINT ... EXPECT` |
| **Drop Violations** | `@dlt.expect_or_drop()` | `ON VIOLATION DROP ROW` |
| **Fail on Violations** | `@dlt.expect_or_fail()` | `ON VIOLATION FAIL UPDATE` |
| **Read Streaming** | `dlt.read_stream("table")` | `STREAM(LIVE.table)` |
| **Read Batch** | `dlt.read("table")` | `LIVE.table` |

### Input Source Pattern

**Always wrap external table references with `@dlt.view`**:

```python
# Pattern for input sources
@dlt.view(comment="Bronze: <Source Name>")
def bronze_<source_name>():
    """Input source: catalog.schema.table_name"""
    return spark.table("catalog.schema.table_name")

# Then use in transformations
@dlt.table(name="silver_output")
def silver_output():
    return dlt.read("bronze_<source_name>").select("*")
```

**Benefits**:
- ✅ Centralized source references
- ✅ Easy to identify pipeline inputs
- ✅ Simplified testing (mock views)
- ✅ Environment-specific configuration support

### Decision Matrix

```
┌─ Need real-time processing?
│  ├─ Yes → Streaming Table
│  └─ No  → Materialized View
│
├─ Need data quality checks?
│  ├─ Yes → Add expectations
│  └─ No  → Basic table
│
├─ Need CDC for downstream?
│  ├─ Yes → Enable changeDataFeed
│  └─ No  → Default settings
│
└─ Need to persist results?
   ├─ Yes → Table/Materialized View
   └─ No  → View
```

---

## Additional Resources

**Official Documentation**:
- Main: https://docs.databricks.com/en/delta-live-tables/index.html
- Expectations: https://docs.databricks.com/en/delta-live-tables/expectations.html
- CDC: https://docs.databricks.com/en/delta/delta-change-data-feed.html
- Best Practices: https://docs.databricks.com/en/delta-live-tables/best-practices.html

**DLT-Specific Documentation**:
- **Streaming Tables**: `.agents/knowledge_base/LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md`
- **Materialized Views**: `.agents/knowledge_base/LAKEFLOW_MATERIALIZED_VIEWS_BEST_PRACTICES.md`

**Related Knowledge Base Documentation**:
- Project Structure: `.agents/knowledge_base/PROJECT_STRUCTURE.md`
- Catalog Structure: `.agents/knowledge_base/CATALOG_STRUCTURE.md`
- Medallion Architecture: `.agents/knowledge_base/MEDALLION_ARCHITECTURE.md`
- Naming Conventions: `.agents/knowledge_base/MEDALLION_NAMING_CONVENTIONS.md`
- Dataset Health Framework: `.agents/knowledge_base/DATASET_HEALTH_FRAMEWORK.md`

**Community**:
- Databricks Community Forum
- Stack Overflow: `[databricks] [delta-live-tables]`
- GitHub: https://github.com/databricks

---

**Version**: 1.0.0
**Maintained by**: Data Platform Team
**Last Review**: 2025-10-29
**Next Review**: 2025-11-29
