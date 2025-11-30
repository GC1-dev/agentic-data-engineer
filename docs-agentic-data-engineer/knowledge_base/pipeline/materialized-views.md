# Lakeflow Materialized Views Best Practices Guide

**Framework**: Databricks Delta Live Tables (Lakeflow Declarative Pipelines)
**Official Docs**: https://docs.databricks.com/en/delta-live-tables/index.html
**Last Updated**: 2025-11-19
**Purpose**: Comprehensive guide for implementing batch processing with materialized views in DLT pipelines

> 📖 **Related Documentation**:
> - [DLT Best Practices Overview](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md) - Core concepts, expectations, configuration
> - [Streaming Tables Best Practices](./LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md) - Real-time processing patterns

---

## Table of Contents

1. [What are Materialized Views?](#what-are-materialized-views)
2. [When to Use Materialized Views](#when-to-use-materialized-views)
3. [Materialized View Patterns](#materialized-view-patterns)
4. [Data Quality for Materialized Views](#data-quality-for-materialized-views)
5. [Incremental Materialized Views](#incremental-materialized-views)
6. [Performance Optimization](#performance-optimization)
7. [Configuration Best Practices](#configuration-best-practices)
8. [Monitoring Batch Pipelines](#monitoring-batch-pipelines)
9. [Testing Strategy](#testing-strategy)
10. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

---

## What are Materialized Views?

**Materialized Views** are DLT's approach to batch data processing. They compute results once per pipeline run and persist the results to storage.

**Key Characteristics**:
- ✅ **Batch Processing**: Full or incremental refresh on schedule
- ✅ **Persisted Storage**: Results saved to Delta tables
- ✅ **Deterministic**: Same input produces same output
- ✅ **Cost-Effective**: Run on schedule (hourly, daily)
- ✅ **Flexible Refresh**: Full or incremental modes

**Core Syntax**:
```python
import dlt

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

---

## When to Use Materialized Views

### Use Materialized Views When:

- ✅ **Daily/hourly batch processing sufficient**
- ✅ **Full table refresh acceptable**
- ✅ **Complex aggregations needed**
- ✅ **Data volumes are manageable**
- ✅ **Historical snapshots required**
- ✅ **Cost optimization is priority**

### Real-World Use Cases:

1. **Daily Aggregations**
   - Daily/weekly/monthly metrics
   - Business intelligence reports
   - Executive dashboards
   - Historical trend analysis

2. **Complex Transformations**
   - Multi-table joins
   - Complex business logic
   - Data enrichment
   - Denormalization

3. **Gold Layer Tables**
   - Reporting tables
   - Analytics-ready datasets
   - Business KPIs
   - Data marts

---

## Materialized View Patterns

### Pattern 1: Simple Aggregation

**Best for**: Daily/periodic metrics

```python
@dlt.table(
    name="daily_user_metrics",
    comment="Daily user engagement metrics for reporting",
    table_properties={
        "quality": "gold",
        "pipelines.autoOptimize.zOrderCols": "date,user_id"
    }
)
def daily_user_metrics():
    return (
        dlt.read("events_silver")
        .groupBy("date", "user_id", "country_code")
        .agg(
            count("*").alias("event_count"),
            countDistinct("session_id").alias("session_count"),
            countDistinct("event_type").alias("unique_event_types")
        )
    )
```

### Pattern 2: Complex Multi-Table Joins

**Best for**: Denormalized reporting tables

```python
@dlt.table(
    name="user_activity_enriched",
    comment="User activity enriched with user and product dimensions"
)
def user_activity_enriched():
    events = dlt.read("events_silver")
    users = dlt.read("users_dim")
    products = dlt.read("products_dim")

    return (
        events
        .join(users, "user_id", "left")
        .join(products, "product_id", "left")
        .select(
            events["*"],
            users["user_name"],
            users["user_segment"],
            products["product_name"],
            products["product_category"]
        )
    )
```

### Pattern 3: Incremental Aggregation

**Best for**: Large fact tables with append-only data

```python
@dlt.table(
    name="daily_sales_aggregates",
    comment="Daily sales metrics computed incrementally",
    table_properties={
        "pipelines.autoOptimize.zOrderCols": "date"
    }
)
def daily_sales_aggregates():
    # Only process new dates
    return (
        dlt.read("sales_silver")
        .filter(col("date") >= date_sub(current_date(), 7))  # Last 7 days
        .groupBy("date", "region", "product_category")
        .agg(
            sum("amount").alias("total_sales"),
            count("*").alias("transaction_count"),
            avg("amount").alias("avg_transaction_value")
        )
    )
```

### Pattern 4: Historical Snapshot Tables

**Best for**: Point-in-time analysis

```python
@dlt.table(
    name="users_snapshot_daily",
    comment="Daily snapshot of user dimension for historical analysis",
    table_properties={
        "quality": "gold"
    }
)
def users_snapshot_daily():
    return (
        dlt.read("users_current")
        .withColumn("snapshot_date", current_date())
        .withColumn("snapshot_timestamp", current_timestamp())
    )
```

### Pattern 5: Input Source Views for Batch

**Best Practice**: Wrap external batch sources with `@dlt.view`

```python
@dlt.view(comment="Bronze: User Master Data")
def bronze_user_master():
    """Input source: prod_trusted_bronze.internal.user_master"""
    return spark.table("prod_trusted_bronze.internal.user_master")

@dlt.view(comment="Bronze: Product Catalog")
def bronze_product_catalog():
    """Input source: prod_trusted_bronze.internal.product_catalog"""
    return spark.table("prod_trusted_bronze.internal.product_catalog")

# Then transform in downstream materialized view
@dlt.table(
    name="silver_enriched_transactions",
    comment="Transactions enriched with user and product data"
)
def silver_enriched_transactions():
    transactions = dlt.read("bronze_transactions")
    users = dlt.read("bronze_user_master")
    products = dlt.read("bronze_product_catalog")

    return (
        transactions
        .join(users, "user_id", "left")
        .join(products, "product_id", "left")
    )
```

---

## Data Quality for Materialized Views

> 📖 **Core DLT Expectations**: See [DLT Best Practices - Data Quality Expectations](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#data-quality-expectations) for:
> - Expectation types (TRACK, DROP, FAIL)
> - Severity guidelines
> - Grouping expectations
> - Best practices

### Batch-Specific Quality Patterns

#### Pattern 1: Critical Business Rule Validation

```python
@dlt.table(name="daily_sales_summary")
@dlt.expect_or_fail("has_date", "date IS NOT NULL")
@dlt.expect_or_fail("valid_totals", "total_sales >= 0")
@dlt.expect_or_drop("valid_region", "region IN ('US', 'EU', 'APAC')")
def daily_sales_summary():
    return (
        dlt.read("sales_silver")
        .groupBy("date", "region")
        .agg(sum("amount").alias("total_sales"))
    )
```

#### Pattern 2: Data Completeness Checks

```python
@dlt.table(name="user_metrics")
@dlt.expect_all({
    "has_user_id": "user_id IS NOT NULL",
    "has_metrics": "event_count > 0",
    "within_range": "event_count BETWEEN 1 AND 10000"
})
def user_metrics():
    return (
        dlt.read("events_silver")
        .groupBy("user_id")
        .agg(count("*").alias("event_count"))
    )
```

#### Pattern 3: Referential Integrity Checks

```python
@dlt.table(name="orders_with_customers")
@dlt.expect_or_drop("customer_exists", "customer_id IN (SELECT customer_id FROM LIVE.customers)")
def orders_with_customers():
    return dlt.read("orders_raw")
```

**⚠️ Note**: The above subquery pattern may not be supported in all DLT versions. Alternative approach:

```python
@dlt.table(name="orders_with_customers")
def orders_with_customers():
    orders = dlt.read("orders_raw")
    customers = dlt.read("customers")

    # Use join to enforce referential integrity
    return orders.join(customers.select("customer_id"), "customer_id", "inner")
```

---

## Incremental Materialized Views

### When to Use Incremental Refresh

Incremental refresh is useful when:
- ✅ Data is append-only or has clear incremental markers
- ✅ Full refresh is too expensive
- ✅ You need to process only new/changed data

### Pattern 1: Date-Based Incremental Processing

```python
@dlt.table(
    name="events_daily_aggregates",
    comment="Daily aggregates, processed incrementally by date"
)
def events_daily_aggregates():
    # Process only recent dates (e.g., last 7 days)
    cutoff_date = date_sub(current_date(), 7)

    return (
        dlt.read("events_silver")
        .filter(col("event_date") >= cutoff_date)
        .groupBy("event_date", "event_type")
        .agg(count("*").alias("event_count"))
    )
```

### Pattern 2: Incremental with MERGE

For upsert scenarios (not native DLT, but common pattern):

```python
@dlt.table(name="customer_summary")
def customer_summary():
    # Compute metrics for all customers
    return (
        dlt.read("transactions")
        .groupBy("customer_id")
        .agg(
            sum("amount").alias("total_spent"),
            count("*").alias("transaction_count"),
            max("transaction_date").alias("last_transaction_date")
        )
    )
```

**Note**: DLT handles incremental updates automatically. For more complex upsert logic, use `dlt.apply_changes()` with streaming tables or custom MERGE logic outside DLT.

### Pattern 3: Partition Overwrite

For partition-level incremental updates:

```python
@dlt.table(
    name="events_by_date",
    partition_cols=["date"],
    comment="Events partitioned by date for efficient incremental updates"
)
def events_by_date():
    # Process specific partition(s)
    target_date = spark.conf.get("pipeline.target_date", current_date())

    return (
        dlt.read("events_silver")
        .filter(col("date") == target_date)
    )
```

---

## Performance Optimization

> 📖 **Core Optimization Principles**: See [DLT Best Practices - Performance Optimization](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#performance-optimization) for:
> - Partitioning guidelines
> - Auto-optimization settings
> - Cluster sizing

### Batch-Specific Optimization Patterns

#### 1. Z-Ordering for Better Query Performance

```python
@dlt.table(
    name="transactions",
    table_properties={
        "pipelines.autoOptimize.zOrderCols": "customer_id,product_id"
    }
)
def transactions():
    return dlt.read("transactions_raw")
```

**Z-Ordering Best Practices**:
- ✅ Use for frequently filtered columns
- ✅ Combine 2-4 columns maximum
- ✅ Put most selective columns first
- ❌ Don't z-order on partition columns

#### 2. Broadcast Joins

For small dimension tables:

```python
@dlt.table(name="enriched_facts")
def enriched_facts():
    facts = dlt.read("large_fact_table")
    dim = dlt.read("small_dimension_table")

    # Broadcast small dimension
    return facts.join(broadcast(dim), "dimension_key")
```

**When to Broadcast**:
- ✅ Dimension table < 100MB
- ✅ Avoid shuffle of large fact table
- ❌ Don't broadcast large tables (> 8GB)

#### 3. Caching Intermediate Results

For multi-step transformations:

```python
@dlt.view(name="cleaned_events")
def cleaned_events():
    return (
        dlt.read("events_raw")
        .filter(col("event_timestamp").isNotNull())
        .withColumn("event_date", col("event_timestamp").cast("date"))
    )

# Use view in multiple downstream tables
@dlt.table(name="daily_counts")
def daily_counts():
    return dlt.read("cleaned_events").groupBy("event_date").count()

@dlt.table(name="hourly_counts")
def hourly_counts():
    return (
        dlt.read("cleaned_events")
        .withColumn("hour", hour("event_timestamp"))
        .groupBy("event_date", "hour")
        .count()
    )
```

**⚠️ Note**: Views are recomputed for each downstream table. For expensive transformations used multiple times, consider creating a materialized intermediate table instead.

---

## Configuration Best Practices

> 📖 **Core Configuration**: See [DLT Best Practices - Configuration](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#configuration-best-practices) for:
> - Pipeline YAML structure
> - Environment-specific configuration
> - Secrets management
> - Notification setup

### Batch-Specific Configuration

#### Pipeline Configuration for Batch Processing

```yaml
# databricks-workflows/batch_pipeline.yml
name: "daily_aggregations_pipeline"

catalog: "prod_trusted"
target: "${catalog}.meta_search"

configuration:
  pipeline.env: "prod"
  pipeline.mode: "batch"

# Cluster Configuration
clusters:
  - label: "default"
    autoscale:
      min_workers: 2
      max_workers: 8
    node_type_id: "i3.xlarge"
    spark_conf:
      # Batch-specific configuration
      "spark.sql.adaptive.enabled": "true"
      "spark.sql.adaptive.coalescePartitions.enabled": "true"
      "spark.sql.shuffle.partitions": "200"

      # Delta optimization
      "spark.databricks.delta.autoOptimize.optimizeWrite": "true"
      "spark.databricks.delta.autoOptimize.autoCompact": "true"

# Schedule (daily at 7 AM UTC)
trigger:
  cron:
    quartz_cron_schedule: "0 0 7 * * ?"
    timezone_id: "UTC"

# Channel
channel: "CURRENT"

# Notifications
notifications:
  - email_recipients:
      - "data-team@company.com"
    on_failure: true
    on_success: false
```

#### Cluster Sizing for Batch Pipelines

**Small Batch Jobs** (< 1GB/day):
```yaml
clusters:
  - label: "default"
    autoscale:
      min_workers: 2
      max_workers: 4
    node_type_id: "m5.large"
```

**Medium Batch Jobs** (1-100GB/day):
```yaml
clusters:
  - label: "default"
    autoscale:
      min_workers: 4
      max_workers: 8
    node_type_id: "i3.xlarge"
```

**Large Batch Jobs** (> 100GB/day):
```yaml
clusters:
  - label: "default"
    autoscale:
      min_workers: 8
      max_workers: 16
    node_type_id: "i3.2xlarge"
```

---

## Monitoring Batch Pipelines

> 📖 **Core Monitoring**: See [DLT Best Practices - Monitoring & Observability](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#monitoring--observability) for:
> - Event logs overview
> - Data quality metrics queries
> - Key metrics to track
> - Alerting setup

### Batch-Specific Monitoring

#### 1. Pipeline Execution Metrics

**Query Pipeline Events**:
```sql
SELECT
    timestamp,
    details:flow_definition.output_dataset as table_name,
    details:flow_progress.status as status,
    details:flow_progress.metrics.num_output_rows as rows_written,
    details:flow_progress.data_quality.expectations as expectations
FROM event_log(TABLE(LIVE.daily_metrics))
WHERE event_type = 'flow_progress'
ORDER BY timestamp DESC
```

**Key Batch Metrics**:
- ✅ **Success Rate**: Percentage of successful runs
- ✅ **Processing Time**: Duration per table
- ✅ **Row Counts**: Input vs. output row counts
- ✅ **Data Quality**: Expectation violations
- ✅ **Cost**: Compute cost per run

#### 2. Success Rate Dashboard

```sql
-- Daily success rate
SELECT
    DATE(timestamp) as date,
    COUNT(*) as total_runs,
    SUM(CASE WHEN details:flow_progress.status = 'COMPLETED' THEN 1 ELSE 0 END) as successful,
    ROUND(100.0 * successful / total_runs, 2) as success_rate_pct
FROM event_log(TABLE(LIVE.daily_metrics))
WHERE event_type = 'flow_progress'
GROUP BY DATE(timestamp)
ORDER BY date DESC
```

---

## Testing Strategy

> 📖 **Core Testing Principles**: See [DLT Best Practices - Testing Strategy](./LAKEFLOW_DECLARATIVE_PIPELINES_BEST_PRACTICES.md#testing-strategy) for:
> - Local development setup
> - Basic unit test patterns
> - Data quality test patterns

### Batch-Specific Testing

#### 1. Local Development Tests

```python
import pytest
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count

@pytest.fixture
def spark():
    return (
        SparkSession.builder
        .master("local[2]")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .getOrCreate()
    )

def test_aggregation_logic(spark):
    # Create test data
    test_data = [
        {"date": "2023-01-01", "user_id": "user1", "event_type": "click"},
        {"date": "2023-01-01", "user_id": "user1", "event_type": "view"},
        {"date": "2023-01-01", "user_id": "user2", "event_type": "click"}
    ]
    input_df = spark.createDataFrame(test_data)

    # Apply aggregation
    output_df = (
        input_df
        .groupBy("date", "user_id")
        .agg(count("*").alias("event_count"))
    )

    # Assert results
    assert output_df.count() == 2
    user1_count = output_df.filter(col("user_id") == "user1").first()["event_count"]
    assert user1_count == 2
```

#### 2. Aggregation Tests with Complex Logic

```python
def test_multi_table_join_aggregation(spark, tmp_path):
    # Create test data for multiple tables
    users_data = [{"user_id": "user1", "country": "US"}, {"user_id": "user2", "country": "UK"}]
    events_data = [
        {"user_id": "user1", "event_type": "click", "date": "2023-01-01"},
        {"user_id": "user1", "event_type": "view", "date": "2023-01-01"},
        {"user_id": "user2", "event_type": "click", "date": "2023-01-01"}
    ]

    users_df = spark.createDataFrame(users_data)
    events_df = spark.createDataFrame(events_data)

    # Apply join and aggregation
    result_df = (
        events_df
        .join(users_df, "user_id")
        .groupBy("country", "date")
        .agg(count("*").alias("event_count"))
    )

    # Verify
    assert result_df.count() == 2
    us_count = result_df.filter(col("country") == "US").first()["event_count"]
    assert us_count == 2
```

---

## Common Pitfalls & Solutions

### Pitfall 1: Full Table Scan on Large Tables

❌ **Problem**: No partitioning on large table
```python
@dlt.table(name="events")
def events():
    return dlt.read("events_raw")  # No partitioning!
```

✅ **Solution**: Add partitioning
```python
@dlt.table(
    name="events",
    partition_cols=["date"]
)
def events():
    return dlt.read("events_raw")
```

### Pitfall 2: Over-Using expect_or_fail

❌ **Problem**: Pipeline too brittle
```python
@dlt.table(name="metrics")
@dlt.expect_or_fail("has_everything", "col1 IS NOT NULL AND col2 IS NOT NULL AND ...")
# One violation stops entire pipeline!
```

✅ **Solution**: Use appropriate severity
```python
@dlt.table(name="metrics")
@dlt.expect_or_fail("has_partition_key", "date IS NOT NULL")  # Critical
@dlt.expect_or_drop("has_user_id", "user_id IS NOT NULL")    # Drop bad rows
@dlt.expect("has_optional", "optional_field IS NOT NULL")     # Track only
```

### Pitfall 3: Hardcoded Table Names

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
    return spark.table(input_table)
```

### Pitfall 4: Ignoring Small Files

❌ **Problem**: Small files accumulate, performance degrades
```python
# No optimization configured
```

✅ **Solution**: Enable auto-optimization
```python
@dlt.table(
    name="fact_table",
    table_properties={
        "delta.autoOptimize.autoCompact": "true",
        "delta.autoOptimize.optimizeWrite": "true"
    }
)
def fact_table():
    return dlt.read("source")
```

### Pitfall 5: Inefficient Joins

❌ **Problem**: Joining large tables without optimization
```python
@dlt.table(name="joined")
def joined():
    large1 = dlt.read("large_table_1")
    large2 = dlt.read("large_table_2")
    return large1.join(large2, "key")  # Expensive shuffle!
```

✅ **Solution**: Broadcast small tables, partition large tables
```python
@dlt.table(name="joined")
def joined():
    large = dlt.read("large_table")
    small = dlt.read("small_dimension")
    return large.join(broadcast(small), "key")
```

### Pitfall 6: Not Reusing Intermediate Results

❌ **Problem**: Expensive transformation recomputed multiple times
```python
@dlt.view(name="expensive_view")
def expensive_view():
    return dlt.read("raw").filter(...).join(...).agg(...)  # Expensive!

# Used in 3 downstream tables - computed 3 times!
@dlt.table(name="output1")
def output1():
    return dlt.read("expensive_view").select("*")

@dlt.table(name="output2")
def output2():
    return dlt.read("expensive_view").select("*")

@dlt.table(name="output3")
def output3():
    return dlt.read("expensive_view").select("*")
```

✅ **Solution**: Materialize intermediate result
```python
@dlt.table(name="expensive_intermediate")
def expensive_intermediate():
    return dlt.read("raw").filter(...).join(...).agg(...)

# Use materialized table (computed once)
@dlt.table(name="output1")
def output1():
    return dlt.read("expensive_intermediate").select("*")

@dlt.table(name="output2")
def output2():
    return dlt.read("expensive_intermediate").select("*")

@dlt.table(name="output3")
def output3():
    return dlt.read("expensive_intermediate").select("*")
```

---

## Quick Reference

### Materialized View Syntax

```python
# Basic materialized view
@dlt.table(name="table_name")
def table_name():
    return dlt.read("source_table").select("*")

# With expectations
@dlt.table(name="table_name")
@dlt.expect_or_drop("valid_field", "field IS NOT NULL")
def table_name():
    return dlt.read("source_table")

# With partitioning and optimization
@dlt.table(
    name="table_name",
    partition_cols=["date"],
    table_properties={
        "delta.autoOptimize.optimizeWrite": "true",
        "pipelines.autoOptimize.zOrderCols": "user_id"
    }
)
def table_name():
    return dlt.read("source_table")
```

### Common Batch Operations

| Operation | Code |
|-----------|------|
| **Read batch** | `dlt.read("table")` |
| **Aggregate** | `.groupBy(...).agg(...)` |
| **Join** | `.join(other_df, "key")` |
| **Broadcast join** | `.join(broadcast(small_df), "key")` |
| **Filter** | `.filter(col("field") > 0)` |
| **Window functions** | `.withColumn("rank", rank().over(window))` |

### Decision Matrix

```
┌─ Need real-time processing?
│  ├─ Yes → Use Streaming Tables
│  └─ No  → Use Materialized Views ✓
│
├─ Full refresh acceptable?
│  ├─ Yes → Standard Materialized View ✓
│  └─ No  → Incremental Materialized View or Streaming
│
├─ Complex aggregations?
│  ├─ Yes → Materialized Views (better for complex SQL) ✓
│  └─ No  → Either works
│
└─ Cost optimization priority?
   ├─ Yes → Scheduled Materialized Views (hourly/daily) ✓
   └─ No  → Streaming Tables for low latency
```

---

## Additional Resources

**Official Documentation**:
- Materialized Views: https://docs.databricks.com/en/delta-live-tables/index.html
- Delta Optimization: https://docs.databricks.com/en/delta/optimize.html
- Z-Ordering: https://docs.databricks.com/en/delta/data-skipping.html

**Related Knowledge Base Documentation**:
- Streaming Tables: `.agents/knowledge_base/LAKEFLOW_STREAMING_TABLES_BEST_PRACTICES.md`
- Project Structure: `.agents/knowledge_base/PROJECT_STRUCTURE.md`
- Medallion Architecture: `.agents/knowledge_base/MEDALLION_ARCHITECTURE.md`

---

**Version**: 1.0.0
**Maintained by**: Data Platform Team
**Last Review**: 2025-11-19
**Next Review**: 2025-12-19
