# Databricks System Tables

## Overview

System tables are a Databricks-hosted analytical repository of operational account data located in the `system` catalog. They enable historical observability across your entire account infrastructure, providing insights into billing, security, data lineage, compute resources, and operational metrics.

**Source:** [Databricks System Tables Documentation](https://docs.databricks.com/aws/en/admin/system-tables/)

## Key Requirements

- Workspace must be enabled for Unity Catalog to access system tables
- Metastore must operate on Unity Catalog Privilege Model Version 1.0
- In AWS GovCloud, only `system.billing` schema and `system.access.audit` table are available

## Access and Permissions

- All system tables are read-only and immutable
- No default user permissions - a metastore admin and account admin must grant `USE` and `SELECT` permissions
- Access is governed by Unity Catalog permissions
- Data originates from all regional workspaces but is only queryable through Unity Catalog-enabled workspaces

## Data Storage Architecture

System table data is stored in a Databricks-hosted storage account located in the same region as your metastore. Data is securely shared via the Delta Sharing protocol.

**Note:** Customer-managed VPCs may require updated S3 bucket policies for access.

## Entity Relationship Diagram (ERD)

The following diagram outlines how system tables relate to one another, showing primary and foreign keys for each table. Understanding these relationships is crucial for building comprehensive queries that span multiple system tables.

### Key Relationship Patterns

#### 1. Compute Resources Hub
The compute-related tables form a central hub connecting to usage, billing, and job execution:

- **system.compute.clusters** (PK: `account_id`, `workspace_id`, `cluster_id`, `change_time`)
  - Links to `system.compute.node_timeline` via `cluster_id`
  - Links to `system.lakeflow.job_run_timeline` via `cluster_id`
  - Links to `system.query.history` via `compute_id`

- **system.compute.warehouses** (PK: `account_id`, `workspace_id`, `warehouse_id`, `change_time`)
  - Links to `system.compute.warehouse_events` via `workspace_id`, `warehouse_id`
  - Links to `system.billing.usage` via `workspace_id`
  - Links to `system.query.history` via `compute_id`

- **system.compute.node_timeline** (PK: `account_id`, `workspace_id`, `cluster_id`, `node_id`, `status_id`, `start_time`)
  - References `system.compute.clusters` via `cluster_id`
  - Links to `system.compute.node_types` via `node_type`

#### 2. Job Execution Hierarchy
Job-related tables maintain a hierarchical structure from jobs to tasks to runs:

- **system.lakeflow.jobs** (PK: `account_id`, `workspace_id`, `job_id`, `change_time`)
  - Parent to `system.lakeflow.job_tasks`
  - Links to `system.lakeflow.job_run_timeline` via `job_id`

- **system.lakeflow.job_tasks** (PK: `account_id`, `workspace_id`, `job_id`, `task_key`, `load_snapshot_slot_id`)
  - Child of `system.lakeflow.jobs`
  - Links to `system.lakeflow.job_task_run_timeline` via `job_id`, `task_key`

- **system.lakeflow.job_run_timeline** (PK: `account_id`, `workspace_id`, `job_id`, `run_id`, `period_end_time`)
  - References `system.lakeflow.jobs` via `job_id`
  - Links to `system.compute.clusters` via `cluster_id`
  - Contains `compute_ids` linking to compute resources

- **system.lakeflow.job_task_run_timeline** (PK: `account_id`, `workspace_id`, `job_id`, `run_id`, `task_key`, `period_end_time`)
  - References `system.lakeflow.job_tasks` via `job_id`, `task_key`
  - Contains execution-level details

- **system.lakeflow.pipelines** (PK: `account_id`, `workspace_id`, `pipeline_id`, `change_time`)
  - Links to `system.lakeflow.pipeline_update_timeline` via `pipeline_id`

- **system.lakeflow.pipeline_update_timeline** (PK: `account_id`, `workspace_id`, `pipeline_id`, `update_id`, `period_end_time`)
  - References `system.lakeflow.pipelines`

#### 3. Query and Billing Integration
Query execution connects to compute resources and billing:

- **system.query.history** (PK: `account_id`, `workspace_id`, `statement_id`, `compute_id`)
  - Links to `system.compute.clusters` or `system.compute.warehouses` via `compute_id`
  - Related to `system.billing.usage` for cost attribution

- **system.billing.usage** (PK: `account_id`, `workspace_id`, `sku_name`, `usage_date`, ...)
  - Links to `system.billing.list_prices` via `sku_name`
  - References `system.compute.warehouses` via `workspace_id`

- **system.billing.list_prices** (PK: `account_id`, `sku_name`, `price_start_time`)
  - Referenced by `system.billing.usage` for pricing calculations

#### 4. Access and Security Monitoring
Access tables track various security and audit events:

- **system.access.audit** (PK: `account_id`, `workspace_id`, `version`, `event_time`, `event_id`)
  - Central audit log for all workspace activities
  - Contains `workspace_id` linking to `system.access.workspaces_latest`

- **system.access.table_lineage** (PK: `account_id`, `workspace_id`, `entity_id`, `source_table_full_name`, `event_time`)
  - Tracks data flow between tables
  - Links to `system.access.column_lineage` for detailed lineage

- **system.access.column_lineage** (PK: `account_id`, `workspace_id`, `entity_id`, `entity_type`, `create_time`)
  - Column-level lineage details
  - References `system.access.table_lineage`

- **system.access.workspaces_latest** (PK: `account_id`, `workspace_id`, `create_time`)
  - Master workspace metadata table
  - Referenced by most other system tables via `workspace_id`

- **system.access.assistant_events** (PK: `account_id`, `workspace_id`, `session_id`)
  - Tracks AI Assistant usage

- **system.access.clean_room_events** (PK: `metastore_id`, `session_id`, `event_type`, `clean_room_name`)
  - Monitors clean room activities

- **system.access.inbound_network** (PK: `account_id`, `users_id`)
  - Tracks denied inbound connections

- **system.access.outbound_network** (PK: `account_id`, `workspace_id`)
  - Monitors denied outbound connections

#### 5. MLflow Integration
MLflow tables track machine learning experiments and runs:

- **system.mlflow.experiments_latest** (PK: `account_id`, `experiment_id`, `update_time`)
  - Parent to `system.mlflow.runs_latest`

- **system.mlflow.runs_latest** (PK: `account_id`, `experiment_id`, `name`, `update_time`)
  - Child of `system.mlflow.experiments_latest`
  - Links to `system.mlflow.run_metrics_history` via `run_id`

- **system.mlflow.run_metrics_history** (PK: `account_id`, `query_time`, `experiment_id`, `run_id`)
  - Contains timeseries metrics for ML runs

#### 6. Model Serving
Serving tables track model endpoint usage:

- **system.serving.served_entities** (PK: `account_id`, `workspace_id`, `endpoint_id`)
  - Links to `system.serving.endpoint_usage` via `endpoint_id`

- **system.serving.endpoint_usage** (PK: `account_id`, `workspace_id`, `endpoint_id`, `served_entity_id`, `request_time`)
  - Tracks token usage and request details

#### 7. Marketplace Activity
Marketplace tables track listing engagement:

- **system.marketplace.listing_funnel_events** (PK: `account_id`, `milestone_id`, `event_type`, `event_time`, `event_date`)
  - Tracks listing impressions and interactions

- **system.marketplace.listing_access_events** (PK: `account_id`, `metastore_id`, `listing_id`, `consumer_data_sharing_recipient_type`)
  - Monitors data access requests

### Common Join Patterns

#### Pattern 1: Job Performance Analysis with Compute Costs
```sql
SELECT
    j.job_id,
    j.job_name,
    jrt.run_id,
    c.cluster_name,
    c.node_type_id,
    bu.usage_quantity,
    bu.list_amount as cost
FROM system.lakeflow.jobs j
INNER JOIN system.lakeflow.job_run_timeline jrt
    ON j.account_id = jrt.account_id
    AND j.workspace_id = jrt.workspace_id
    AND j.job_id = jrt.job_id
INNER JOIN system.compute.clusters c
    ON jrt.account_id = c.account_id
    AND jrt.workspace_id = c.workspace_id
    AND jrt.cluster_id = c.cluster_id
LEFT JOIN system.billing.usage bu
    ON c.workspace_id = bu.workspace_id
    AND bu.usage_date = DATE(jrt.period_start_time)
WHERE j.change_time >= current_timestamp() - INTERVAL 30 DAYS
```

#### Pattern 2: Query Performance with Warehouse Configuration
```sql
SELECT
    qh.statement_id,
    qh.statement_text,
    qh.execution_duration_ms,
    w.warehouse_name,
    w.warehouse_size,
    w.min_num_clusters,
    w.max_num_clusters
FROM system.query.history qh
INNER JOIN system.compute.warehouses w
    ON qh.account_id = w.account_id
    AND qh.workspace_id = w.workspace_id
    AND qh.compute_id = w.warehouse_id
WHERE qh.start_time >= current_timestamp() - INTERVAL 7 DAYS
    AND qh.execution_duration_ms > 60000
```

#### Pattern 3: Table Lineage with Audit Context
```sql
SELECT
    tl.source_table_full_name,
    tl.target_table_full_name,
    tl.event_time,
    a.action_name,
    a.user_identity.email as user_email,
    a.request_id
FROM system.access.table_lineage tl
INNER JOIN system.access.audit a
    ON tl.account_id = a.account_id
    AND tl.workspace_id = a.workspace_id
    AND tl.event_time = a.event_time
WHERE tl.event_date >= current_date() - INTERVAL 7 DAYS
    AND tl.source_table_full_name LIKE 'prod_trusted_bronze%'
```

#### Pattern 4: Cluster Utilization with Node Details
```sql
SELECT
    c.cluster_id,
    c.cluster_name,
    nt.node_type,
    nt.instance_type_id,
    ntl.node_id,
    ntl.status,
    ntl.uptime_in_ms
FROM system.compute.clusters c
INNER JOIN system.compute.node_timeline ntl
    ON c.account_id = ntl.account_id
    AND c.workspace_id = ntl.workspace_id
    AND c.cluster_id = ntl.cluster_id
INNER JOIN system.compute.node_types nt
    ON ntl.node_type = nt.node_type
WHERE c.change_time >= current_timestamp() - INTERVAL 24 HOURS
```

#### Pattern 5: MLflow Experiment Metrics Over Time
```sql
SELECT
    e.experiment_name,
    r.run_name,
    r.status,
    m.metric_name,
    m.metric_value,
    m.timestamp
FROM system.mlflow.experiments_latest e
INNER JOIN system.mlflow.runs_latest r
    ON e.account_id = r.account_id
    AND e.experiment_id = r.experiment_id
INNER JOIN system.mlflow.run_metrics_history m
    ON r.account_id = m.account_id
    AND r.experiment_id = m.experiment_id
    AND r.run_id = m.run_id
WHERE e.update_time >= current_timestamp() - INTERVAL 30 DAYS
```

### Key Foreign Key Columns

| Column | Description | Used In |
|--------|-------------|---------|
| `account_id` | Unique identifier for Databricks account | All tables (PK component) |
| `workspace_id` | Workspace identifier within account | Most tables (PK component) |
| `cluster_id` | Compute cluster identifier | compute.clusters, compute.node_timeline, lakeflow.job_run_timeline |
| `warehouse_id` | SQL warehouse identifier | compute.warehouses, compute.warehouse_events, query.history (as compute_id) |
| `job_id` | Job identifier | lakeflow.jobs, lakeflow.job_tasks, lakeflow.job_run_timeline |
| `task_key` | Job task identifier | lakeflow.job_tasks, lakeflow.job_task_run_timeline |
| `run_id` | Job or pipeline run identifier | lakeflow.job_run_timeline, lakeflow.job_task_run_timeline, mlflow.runs_latest |
| `pipeline_id` | Pipeline identifier | lakeflow.pipelines, lakeflow.pipeline_update_timeline |
| `experiment_id` | MLflow experiment identifier | mlflow.experiments_latest, mlflow.runs_latest, mlflow.run_metrics_history |
| `endpoint_id` | Model serving endpoint identifier | serving.served_entities, serving.endpoint_usage |
| `node_type` | Compute node type | compute.node_types, compute.node_timeline |
| `sku_name` | Billing SKU identifier | billing.usage, billing.list_prices |

### ERD Best Practices

1. **Always Filter on Account and Workspace**: Most queries should filter on `account_id` and `workspace_id` for performance
2. **Use Date Partitions**: Tables with date columns are partitioned - always include date filters
3. **Join on Complete Keys**: Use all components of composite keys when joining tables
4. **Consider Temporal Joins**: Many tables have time-based keys (`change_time`, `event_time`) - ensure temporal alignment
5. **Handle Schema Evolution**: Primary keys may expand over time as new columns are added to composite keys

## Available System Tables

### system.access - Security and Governance

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.access.audit` | Records all audit events from workspaces | 365 days |
| `system.access.table_lineage` | Documents read/write operations on tables and paths | 365 days |
| `system.access.column_lineage` | Tracks read/write events on Unity Catalog columns | 365 days |
| `system.access.workspaces_latest` | Metadata for all account workspaces | Indefinite |
| `system.access.clean_room_events` | Captures clean room-related activity | 365 days |
| `system.access.assistant_events` | Logs Databricks Assistant user interactions | 365 days |
| `system.access.inbound_network` | Denied inbound access attempts | 30 days |
| `system.access.outbound_network` | Denied outbound internet access | 365 days |

**Use Cases:**
- Security auditing and compliance reporting
- Data lineage tracking for governance
- Access pattern analysis
- Network security monitoring

### system.billing - Cost Management

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.billing.usage` | Records for all billable usage across your account | 365 days |
| `system.billing.list_prices` | Historical SKU pricing changes | Indefinite |

**Use Cases:**
- Cost analysis and optimization
- Chargeback and showback reporting
- Budget forecasting
- Usage trend analysis

**Note:** Billing schema tables are global and free to use.

### system.compute - Cluster and Warehouse Management

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.compute.clusters` | Full history of compute configurations over time | 365 days |
| `system.compute.node_timeline` | Utilization metrics for compute resources | 90 days |
| `system.compute.node_types` | Available node hardware specifications | Indefinite |
| `system.compute.warehouses` | Configuration history for SQL warehouses | 365 days |
| `system.compute.warehouse_events` | SQL warehouse lifecycle events | 365 days |

**Use Cases:**
- Compute resource utilization tracking
- Cluster configuration analysis
- SQL warehouse performance monitoring
- Capacity planning

### system.lakeflow - Jobs and Pipelines

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.lakeflow.jobs` | All created jobs | 365 days |
| `system.lakeflow.job_tasks` | Individual job task records | 365 days |
| `system.lakeflow.job_run_timeline` | Job start/end times | 365 days |
| `system.lakeflow.job_task_run_timeline` | Task-level timing and resource usage | 365 days |
| `system.lakeflow.pipelines` | All created pipelines | 365 days |
| `system.lakeflow.pipeline_update_timeline` | Pipeline execution metrics | 365 days |

**Use Cases:**
- Job performance analytics
- Pipeline monitoring and optimization
- SLA tracking
- Resource consumption analysis

### system.query - Query Performance

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.query.history` | SQL warehouse and serverless compute queries | 365 days |

**Use Cases:**
- Query performance optimization
- Usage pattern analysis
- Identifying slow queries
- Query cost analysis

### system.mlflow - Machine Learning Operations

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.mlflow.experiments_latest` | MLflow experiment metadata | 180 days |
| `system.mlflow.runs_latest` | MLflow run records | 180 days |
| `system.mlflow.run_metrics_history` | Timeseries training metrics | 180 days |

**Use Cases:**
- ML experiment tracking
- Model training monitoring
- Experiment comparison
- Training metrics analysis

### system.serving - Model Serving

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.serving.served_entities` | Foundation model metadata | 365 days |
| `system.serving.endpoint_usage` | Token counts per request | 90 days |

**Use Cases:**
- Model serving monitoring
- Token usage tracking
- Endpoint performance analysis
- Cost attribution for serving

### system.marketplace - Marketplace Analytics

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.marketplace.listing_funnel_events` | Consumer impression data | 365 days |
| `system.marketplace.listing_access_events` | Consumer information for data requests | 365 days |

**Use Cases:**
- Marketplace listing analytics
- Consumer behavior tracking
- Access request monitoring

### system.data_classification - Sensitive Data Detection

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.data_classification.results` | Sensitive data detections by column | 365 days |

**Use Cases:**
- PII/sensitive data identification
- Data classification compliance
- Privacy risk assessment

### system.data_quality_monitoring - Data Quality

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.data_quality_monitoring.table_results` | Quality checks and incident analysis | Indefinite |

**Use Cases:**
- Data quality monitoring
- Incident tracking
- Quality trend analysis

### system.sharing - Delta Sharing

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.sharing.materialization_history` | Data materialization events from shared objects | 365 days |

**Use Cases:**
- Delta Sharing monitoring
- Materialization tracking
- Sharing usage analysis

### system.storage - Storage Optimization

| Table | Purpose | Retention |
|-------|---------|-----------|
| `system.storage.predictive_optimization_operations_history` | Feature operation history | 180 days |

**Use Cases:**
- Predictive optimization monitoring
- Storage operation tracking
- Optimization performance analysis

## Common Usage Patterns

### Query System Tables

```python
# Example: Query audit logs
audit_logs = spark.sql("""
    SELECT
        event_time,
        user_identity.email as user_email,
        action_name,
        request_params
    FROM system.access.audit
    WHERE event_date >= current_date() - INTERVAL 7 DAYS
    ORDER BY event_time DESC
""")

# Example: Analyze billable usage
usage_by_sku = spark.sql("""
    SELECT
        usage_date,
        sku_name,
        SUM(usage_quantity) as total_usage,
        SUM(list_amount) as total_cost
    FROM system.billing.usage
    WHERE usage_date >= current_date() - INTERVAL 30 DAYS
    GROUP BY usage_date, sku_name
    ORDER BY usage_date DESC, total_cost DESC
""")

# Example: Track table lineage
table_lineage = spark.sql("""
    SELECT
        event_time,
        source_table_full_name,
        target_table_full_name,
        read_row_count,
        write_row_count
    FROM system.access.table_lineage
    WHERE event_date >= current_date() - INTERVAL 7 DAYS
""")
```

### Streaming System Tables

When streaming system tables, set `skipChangeCommits` option to `true` to prevent job disruption from deletes:

```python
# Stream audit logs
audit_stream = (spark.readStream
    .format("delta")
    .option("skipChangeCommits", "true")
    .table("system.access.audit")
)

# Process stream
(audit_stream
    .writeStream
    .format("delta")
    .outputMode("append")
    .trigger(once=True)  # Note: Trigger.AvailableNow converts to Trigger.Once with Delta Sharing
    .start("/path/to/checkpoint")
)
```

## Important Limitations

1. **Schema Evolution**: New columns may be added to existing schemas without notice; queries with fixed schemas could break
2. **Real-time Monitoring**: Not available for real-time use cases; data updates throughout the day
3. **Streaming Limitations**:
   - No support for `Trigger.AvailableNow` - it converts to `Trigger.Once` with Delta Sharing
   - Must set `skipChangeCommits=true` when streaming
4. **Deprecated Schemas**:
   - `system.operational_data` (use `system.compute` instead)
   - `system.lineage` (use `system.access.table_lineage` and `system.access.column_lineage` instead)

## Data Retention Policies

| Retention Period | Tables |
|-----------------|--------|
| 30 days | `system.access.inbound_network` |
| 90 days | `system.compute.node_timeline`, `system.serving.endpoint_usage` |
| 180 days | `system.mlflow.*`, `system.storage.predictive_optimization_operations_history` |
| 365 days | Most access, billing, compute, lakeflow, query, marketplace, and data_classification tables |
| Indefinite | `system.billing.list_prices`, `system.compute.node_types`, `system.access.workspaces_latest`, `system.data_quality_monitoring.table_results` |

## Best Practices

1. **Permissions Management**:
   - Grant minimal necessary permissions to users
   - Use groups for permission management
   - Regularly audit access to system tables

2. **Query Optimization**:
   - Always filter on date partitions (e.g., `event_date`, `usage_date`)
   - Use appropriate retention windows for your use case
   - Consider materializing frequently-used queries

3. **Schema Handling**:
   - Use `SELECT *` sparingly due to potential schema changes
   - Explicitly list required columns in production queries
   - Implement schema validation in critical pipelines

4. **Cost Management**:
   - Billing tables are free to query, but other tables consume DBUs
   - Cache frequently-accessed data
   - Schedule queries during off-peak hours when possible

5. **Streaming Considerations**:
   - Always set `skipChangeCommits=true` for streaming workloads
   - Use checkpointing for fault tolerance
   - Monitor stream processing lag

## Integration with Data Platform

System tables can be integrated into the medallion architecture:

```
system.* (Source) � Bronze (Raw audit/billing data) � Silver (Cleaned/enriched) � Gold (Business metrics)
```

**Example Pipeline:**
- Bronze: Direct reads from `system.billing.usage` with minimal transformation
- Silver: Join billing with cluster metadata, clean data, add business dimensions
- Gold: Aggregate by department/project, calculate cost trends, produce executive dashboards

## Troubleshooting

### Common Issues

1. **Access Denied Errors**:
   - Verify Unity Catalog is enabled
   - Check `USE` and `SELECT` permissions on system schema
   - Confirm metastore privilege model version

2. **Missing Data**:
   - Check data retention policies
   - Verify regional workspace configuration
   - Confirm table is not deprecated

3. **Schema Changes Breaking Queries**:
   - Review release notes for schema updates
   - Use explicit column selection instead of `SELECT *`
   - Implement error handling for schema evolution

4. **S3 Access Issues (Customer-managed VPCs)**:
   - Update S3 bucket policies to allow Databricks system table access
   - Contact Databricks support for specific bucket ARNs

## Additional Resources

- [Databricks System Tables Documentation](https://docs.databricks.com/aws/en/admin/system-tables/)
- [Unity Catalog Documentation](https://docs.databricks.com/en/data-governance/unity-catalog/index.html)
- [Delta Sharing Documentation](https://docs.databricks.com/en/delta-sharing/index.html)

---

**Last Updated:** 2025-11-20
**Documentation Source:** [Databricks AWS System Tables](https://docs.databricks.com/aws/en/admin/system-tables/)
