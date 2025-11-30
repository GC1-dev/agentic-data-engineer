# Technical Standards Reference

Technical specifications and supported technologies for Medallion Architecture implementation.

## Supported Technologies

| Technology | Supported | Rationale | Constraints |
|------------|-----------|-----------|------------|
| **Python/PySpark** | ✅ Yes | Engineering resources available | None |
| **SQL** | ✅ Yes | Engineering resources available | None |
| **R/SparkR** | ❌ No | Limited/no engineering resources | Not supported |
| **Scala** | ❌ No | Limited/no engineering resources | Not supported |
| **DBFS Direct** | ❌ No | AWS S3 preferred; storage/compute separation | Must use Unity Catalog tables |

### Tooling & Platforms

| Tool | Purpose | Status |
|------|---------|--------|
| **Databricks** | Primary compute/storage platform | ✅ Required |
| **Apache Spark** | Distributed data processing | ✅ Required |
| **Delta Lake** | Table format and ACID transactions | ✅ Required |
| **Unity Catalog** | Data governance and access control | ✅ Required |
| **Fivetran** | Managed data integration | ✅ Supported |
| **Lakeflow Connect** | Data integration (alternative) | ✅ Supported |
| **AWS S3** | Object storage (cloud provider) | ✅ Required |

---

## File Formats

### Staging Layer

Supported input formats (readable by Apache Spark):

- ✅ `json` (JSON files)
- ✅ `csv` (Comma-separated values)
- ✅ `parquet` (Apache Parquet columnar format)
- ✅ `avro` (Apache Avro serialization)
- ✅ `orc` (Apache ORC columnar format)
- ✅ `txt` (Plain text)
- ✅ `BinaryFile` (Binary files)
- ✅ `Databricks delta` (Delta format)

**Unsupported Formats**:
- ❌ `xml` (XML files)
- ❌ `excel` (Excel: xls, xlsx, xlsm)
- ❌ `pdf` (PDF documents)
- ❌ `zip` (Compressed archives) - must unzip to Staging first

### Bronze Layer Onwards

**Required Format**: Databricks Delta

- ✅ `delta` (Databricks Delta table format - REQUIRED)

**Why Delta**:
1. **ACID Compliance**: Prevents data corruption from failed ETL
2. **Transaction Log**: Serves as manifest file (no expensive LIST operations)
3. **Data Freshness**: Auto-optimize during writes improves query performance
4. **Compliance**: GDPR/CCPA support via DELETE and UPDATE operations
5. **Unified**: Single format across Bronze/Silver/Gold/Silicon

### Silicon Layer Exception

**TensorFlow Records**: Stored in separate S3 bucket (not Delta format)

- Managed separately with own access controls
- Same retention and update frequency rules apply
- Not queryable via standard Databricks SQL

---

## Compression Formats

### Supported Compression

Supported compression algorithms for data files:

- ✅ `none` (Uncompressed)
- ✅ `uncompressed` (Uncompressed)
- ✅ `bzip2` (BZ2 compression)
- ✅ `deflate` (DEFLATE compression)
- ✅ `gzip` (GZIP compression)
- ✅ `lz4` (LZ4 compression)
- ✅ `snappy` (Snappy compression - DEFAULT for Parquet)

### Unsupported Compression

- ❌ `zip` (ZIP archives)

**Note**: If data arrives in ZIP format, must be unzipped to Staging layer first before processing.

### Default Compression

**Parquet default**: `snappy`

Databricks automatically applies snappy compression to Parquet files if no compression specified. This provides good balance of compression ratio and speed.

### Compression Selection Guide

| Use Case | Recommendation | Reason |
|----------|---------------|---------| 
| **Default** | snappy | Good balance of speed/compression |
| **Maximum compression** | gzip | Highest compression, slower |
| **Maximum speed** | lz4 | Fastest, less compression |
| **No compression** | none | Uncompressed (rare) |

---

## Data Types & Schema

### Supported Databricks Data Types

**Numeric Types**:
- `BYTE`, `SHORT`, `INT`, `LONG` (Integers)
- `FLOAT`, `DOUBLE` (Floating point)
- `DECIMAL(precision, scale)` (Fixed-point decimal)

**String Types**:
- `STRING` (UTF-8 encoded text)
- `VARCHAR(n)` (Variable length string)
- `CHAR(n)` (Fixed-length string)

**Boolean Type**:
- `BOOLEAN` (true/false)

**Date/Time Types**:
- `DATE` (YYYY-MM-DD)
- `TIMESTAMP` (Date + time with timezone)
- `TIMESTAMP_NTZ` (Timestamp without timezone)

**Complex Types**:
- `ARRAY<T>` (Ordered collection)
- `MAP<K, V>` (Key-value pairs)
- `STRUCT<field1: T1, field2: T2>` (Nested structure)

**Binary Types**:
- `BINARY` (Uninterpreted binary data)

### Schema Evolution

**Supported**: Delta Lake supports schema evolution

**Options**:
- **Additive**: Adding new columns (supported)
- **Reordering**: Changing column order (supported)
- **Type changes**: Narrowing types (limited support)
- **Removal**: Dropping columns (requires explicit setting)

---

## Retention Policies

### Default Retention Periods

| Layer | Retention | Notes | Configurable |
|-------|-----------|-------|-------------|
| **Staging** | 30 days | Transient staging only | Yes |
| **Bronze** | 7 years | Default for all datasets | Yes |
| **Silver** | 7 years | Default for all datasets | Yes |
| **Gold** | 7 years | Default for all datasets | Yes |
| **Silicon** | 6 months | Shorter ML lifecycle | Yes |

### Retention Policy Rules

1. **Default applies**: Unless explicitly configured otherwise
2. **Documented**: Retention reason documented in table
3. **Compliant**: Longer retention for compliance data if required
4. **Shorter allowed**: Can shorten retention if business allows
5. **Per-table**: Configured at table level, not domain

### Staging Layer Contact

- **Point of Contact**: Gemma Witham
- **Contact for**: Staging layer support, retention override requests, troubleshooting

---

## Update Frequencies

### Standard Update Frequencies

| Layer | Frequency | Notes |
|-------|-----------|-------|
| **Staging** | 5-15 minutes | External ingestion rate |
| **Bronze** | 5-15 minutes | Matches source ingestion |
| **Silver** | 24 hours / Daily | Once per day (usually overnight) |
| **Gold** | 24 hours / Daily | Once per day (after Silver completes) |
| **Silicon** | 24 hours / Daily | Once per day (after Silver completes) |

### Frequency Considerations

**Staging/Bronze (5-15 min)**:
- Real-time or near-real-time streaming
- Frequent batch ingestions
- Example: Event streams, API data

**Silver/Gold/Silver (Daily)**:
- End-of-day batch processing
- Sufficient for most analytics
- Cost-effective
- Typically runs 2am-6am

**Exceptions**:
- Reverse ETL may need higher frequency (real-time sync)
- Staging tables have 30-day TTL
- Can be configured per table if business need exists

---

## Table Type Classifications

### Managed Tables

**Definition**: Tables owned and managed by Databricks

**Storage**:
- Data stored in Databricks-managed location (S3 default)
- Path managed by Databricks
- Cannot be moved without data loss

**When to use**:
- ✅ Bronze (except trusted pipeline)
- ✅ Silver, Gold, Silicon (all)
- Standard choice for production tables

**Properties**:
```
TBLPROPERTIES (
  'external' = 'false',  # Managed table
  'location' = 's3://bucket/catalog/schema/table/'
)
```

### External Tables

**Definition**: Tables with data stored outside Databricks location

**Storage**:
- Data stored in specific S3 location
- Accessible by tools/systems outside Databricks
- Managed by external system

**When to use**:
- ✅ Bronze (trusted pipeline ingestion only)
- Avoids large data movement
- Enables Fivetran/Lakeflow to write directly

**Properties**:
```
TBLPROPERTIES (
  'external' = 'true',
  'location' = 's3://specific-bucket/specific-path/'
)
```

**Important**: External tables in UC require careful permission management (table-level + S3 bucket permissions)

---

## Storage Buckets

### S3 Bucket Structure

One bucket per layer (separate S3 policies, permissions, maintenance):

```
aws-account/
├── s3://prod-trusted-bronze/     (Bronze layer)
├── s3://prod-trusted-silver/     (Silver layer)
├── s3://prod-trusted-gold/       (Gold layer)
├── s3://prod-trusted-silicon/    (Silicon layer)
├── s3://prod-tensorflow-records/ (TensorFlow records - Silicon)
└── s3://dev-trusted-*/           (Development equivalents)
```

### Bucket Policy Limits

**S3 Bucket Policy Limit**: 20KB maximum size

**Why separate buckets per layer**:
- Policies isolated per layer
- Different security/retention settings
- Easier maintenance and lifecycle management
- Future migration flexibility

### Lifecycle Management

Each bucket configured with:
- **Expiration rules**: Auto-delete after retention period
- **Versioning**: Enable for data protection
- **Archival**: Move to Glacier after X days
- **Encryption**: At-rest encryption enabled

---

## Unity Catalog Mapping

### Catalog Structure

Production Catalogs:
```
prod_trusted_bronze     → s3://prod-trusted-bronze/
prod_trusted_silver     → s3://prod-trusted-silver/
prod_trusted_gold       → s3://prod-trusted-gold/
prod_trusted_silicon    → s3://prod-trusted-silicon/
```

Development Catalogs:
```
dev_trusted_bronze      → s3://dev-trusted-bronze/
dev_trusted_silver      → s3://dev-trusted-silver/
dev_trusted_gold        → s3://dev-trusted-gold/
dev_trusted_silicon     → s3://dev-trusted-silicon/
```

### Environment Isolation

**Dev/Prod Separation**:
- Different catalogs (not schemas)
- No cross-environment references
- Safe experimentation in dev

**No Trusted Preview**:
- All environments have full layer separation
- No unified preview across dev/prod
- Each environment is independent

---

## Access Control

### Access Model

**Table-Level Access**:
- ✅ Access controlled at table level via Unity Catalog
- ✅ Grants: SELECT, MODIFY, EXECUTE, MANAGE_METADATA
- ❌ No location-based access (no direct S3 path access)
- ❌ No DBFS path access

### Permission Grant Pattern

```sql
GRANT SELECT ON TABLE prod_trusted_silver.redirect.events
TO GROUP analytics_team;

GRANT MODIFY ON TABLE prod_trusted_gold.revenue.f_booking
TO GROUP revenue_team;
```

### Service Principal Access

For Fivetran/Lakeflow/external integrations:
- Create service principal with UC permissions
- Grant MODIFY on specific Bronze domains
- No S3 path access needed (UC handles it)

### Best Practices

1. **Principle of Least Privilege**: Grant minimum necessary permissions
2. **Group-based**: Grant to groups, not individuals
3. **Document access**: Document who has access and why
4. **Review quarterly**: Audit access periodically
5. **No DBFS**: Never grant DBFS/S3 path access (use UC only)

---

## Performance Considerations

### Delta Lake Optimization

Delta tables support optimization:

```sql
OPTIMIZE table_name
ZORDER BY (column1, column2);
```

**Benefits**:
- Clusters related rows together
- Improves query performance
- Reduces files and file count
- Run periodically on large tables

### Query Performance Patterns

| Pattern | Recommendation |
|---------|-----------------|
| **Large aggregations** | Use pre-aggregated Gold tables |
| **Frequent joins** | Use wide tables (bar_*) |
| **Real-time lookups** | Cache small dimensions |
| **Complex filters** | Use partitioned columns |

### Partitioning Strategy

**Recommended**: Partition by `date` or `date_id`

```
Bronze: Partition by ingestion_date
Silver: Partition by updated_date
Gold: Partition by date_id (or processing date)
```

**Benefits**:
- Faster queries (only scans relevant partitions)
- Easier incremental updates
- Better lifecycle management

---

## Data Quality Standards

### Mandatory Checks

Every pipeline should include:

1. **Schema validation**: Columns match contract
2. **Type validation**: Data types correct
3. **Null checks**: Required fields non-null
4. **Business rule checks**: Domain-specific validation
5. **Duplicate detection**: Identify duplicates (Bronze → Silver)
6. **Freshness checks**: Data is recent enough

### Quality Metrics to Track

```
Quality Table: dq_metrics
├── table_name
├── check_name
├── check_result (PASS/FAIL/WARN)
├── row_count
├── issue_count
├── check_timestamp
└── alert_if_failing
```

### Alert Thresholds

- **Critical**: Null checks, schema validation, duplicates > 5%
- **Warning**: Missing data, freshness SLA violations
- **Info**: Row count changes > 50%

---

## Metadata Standards

### Required Table Metadata

Every table must have:

```sql
COMMENT ON TABLE schema.table IS 'Business description of table purpose'

ALTER TABLE schema.table
SET TBLPROPERTIES (
  'owner' = 'team-name',
  'data_domain' = 'domain-name',
  'purpose' = 'Clear business purpose',
  'sla' = 'Update frequency and SLA',
  'retention' = '7 years',
  'source_system' = 'Source or DERIVED',
  'table_category' = 'raw|entity|fact|dimension|wide'
)
```

### Required Column Metadata

Key columns should have comments:

```sql
COMMENT ON COLUMN schema.table.column_name IS 'Description of column'
```

---

## Infrastructure & Operations

### Cluster Configuration

**Recommended for medallion pipelines**:
- **Driver node**: 16-32GB RAM
- **Worker nodes**: 8-16 workers, compute-optimized
- **Auto-scaling**: Enable for variable workloads
- **Spot instances**: Use for cost optimization

### Job Configuration

```
Job: medallion_bronze_to_silver
├── Cluster: All-purpose (shared)
├── Schedule: 2:00 AM UTC (after Bronze completes)
├── Timeout: 4 hours
├── Retries: 2 (exponential backoff)
├── Notifications: Slack on failure
└── Timeout action: Alert + escalate
```

### Monitoring & Alerting

Monitor:
- Job success/failure
- Data quality metrics
- Pipeline freshness
- Processing time trends
- Error rates

Alert on:
- Job failures
- Quality check failures
- SLA violations
- Unusual data patterns

---

## Governance & Compliance

### GDPR/CCPA Compliance

Delta Lake supports:
- **DELETE**: Remove PII on retention expiry
- **UPDATE**: Correct personal information
- **Column-level encryption**: For sensitive data
- **Audit logs**: Track deletions/updates

### Data Lineage

Unity Catalog tracks:
- Table dependencies (which tables depend on which)
- Column-level lineage (for selected columns)
- Accessible via UI and API

### Data Classification

Tag tables with sensitivity:

```
PII (Personally Identifiable Information)
├── User emails, phone numbers, IDs
├── Payment information
└── Browsing history

SENSITIVE
├── Revenue data
├── Partner contracts
└── Metrics

PUBLIC
├── Aggregated counts
├── Published reports
└── General reference data
```

---

## Version Control

### Code Management

- **Git**: Infrastructure-as-code for jobs
- **Workflows**: Databricks Workflows as code
- **Notebooks**: Version in Git, deploy via CI/CD
- **SQL**: Version SQL in Git repos

### Versioning Strategy

```
repository/
├── bronze/
│   ├── ingest_events.py
│   └── ingest_partners.py
├── silver/
│   ├── entities/
│   │   ├── redirect_events.py
│   │   └── user_sessions.py
│   └── reference/
│       └── partner_reference.py
└── gold/
    ├── facts/
    │   ├── f_booking.py
    │   └── f_redirect.py
    └── dimensions/
        ├── d_partner.py
        └── d_user.py
```

---

## Performance SLAs

### Update Frequency SLAs

| Layer | SLA | Buffer |
|-------|-----|--------|
| Staging | Within 5-15 min of source | 5 min |
| Bronze | Within 15 min of Staging | 5 min |
| Silver | Completes by 8am UTC | 2 hour buffer |
| Gold | Completes by 10am UTC | 1 hour buffer after Silver |
| Silicon | Completes by 12pm UTC | 1 hour buffer after Silver |

### Query Performance SLAs

| Query Type | Target | Notes |
|-----------|--------|-------|
| Fact table scan | < 5 sec | < 1B rows |
| Dimension lookup | < 1 sec | Join with fact |
| Wide table query | < 10 sec | Pre-aggregated |
| ML training | < 30 min | Full dataset |

---

## References

- Databricks Documentation: https://docs.databricks.com/
- Delta Lake: https://docs.databricks.com/delta/index.html
- Unity Catalog: https://docs.databricks.com/data-governance/unity-catalog/
- Layer specifications: See `layer-specifications.md`
