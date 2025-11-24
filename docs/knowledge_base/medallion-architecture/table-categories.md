# Table Categories Reference

Classification and specifications for different table types in the Medallion Architecture.

## Table Categories Overview

| Category | Layer | Purpose | Naming |
|----------|-------|---------|--------|
| **Raw Tables** | Bronze | Unedited source data | `<source_name>` |
| **Data Entity Tables** | Silver | Cleansed business concepts | `<entity_name>` |
| **Reference Tables** | Silver | Static/slowly changing | `<entity_name>` |
| **Fact Tables** | Gold | Business metrics/events | `f_<concept>` |
| **Dimension Tables** | Gold | Analytics attributes | `d_<entity>` |
| **Wide Tables** | Gold | Pre-joined reporting | `bar_<area>` |
| **Reverse ETL Tables** | Gold/Silver | Export to tools | `<tool>_export` |
| **App Logs** | Any | System/app logs | `<app>_logs` |
| **Temporary Tables** | Any | Short-lived ETL | `tmp_<purpose>` |
| **Data Quality Metrics** | Any | Quality validation | `dq_<check_name>` |
| **Config Tables** | Any | ETL configuration | `config_<system>` |
| **Audit Tables** | Any | Audit trails | `audit_<domain>` |

---

## Bronze Layer Tables

### Raw Tables

**Definition**: Unedited data from source systems with system-specific concepts

**Purpose**:
- Preserve original data structure
- Enable replay and audit capability
- Maintain immutable source of truth

**Characteristics**:
- 1:1 mapping to source system tables/exports
- No transformations, deduplication, or enrichment
- System-specific column names and data types
- Preserves original data semantics

**Naming**:
- Match source system table names where possible
- Example: `skippy_redirect_events`, `zendesk_tickets`

**Examples**:
- Bronze: `internal.skippy_redirect_events` (raw Skippy redirect events)
- Bronze: `fivetran_zendesk.tickets` (raw Zendesk tickets)
- Bronze: `amadeus.availability` (raw Amadeus API response)

**Use Cases**:
- End-to-end replay on transformation errors
- Auditing source data changes
- Debugging data quality issues
- Reprocessing historical data

**Key Rules**:
- ✅ No deduplication
- ✅ No filtering
- ✅ No transformation
- ✅ Metadata attached (ingestion time, source, session)
- ❌ No enrichment
- ❌ No consumer access (go through Silver)

---

## Silver Layer Tables

### Data Entity Tables

**Definition**: Cleansed, deduped, enriched business concepts

**Purpose**:
- Source of truth for business entities
- Enable consistent enrichment across organization
- Support multiple downstream representations

**Characteristics**:
- Logical, reusable business entities
- Deduplication applied
- Enrichment applied (geo, device, session)
- Validation against contracts
- Supports complex business joins

**Naming**:
- Business concept name in singular form
- Example: `redirect`, `booking`, `user_complaint`
- Within domain: `silver.booking.transactions`

**Examples**:
- Silver: `redirect.events` (cleaned user redirect events)
- Silver: `booking.transactions` (cleaned bookings with enrichment)
- Silver: `user_complaint.tickets` (customer complaints with enrichment)
- Silver: `session.context` (user sessions with session attributes)

**Columns Included**:
- Source keys: `source_id`, `external_id`
- Business keys: `user_id`, `partner_id`, `booking_id`
- Attributes: `created_date`, `updated_date`, `status`
- Enriched data: `geo_country`, `device_type`, `session_id`
- Flags: `is_valid`, `is_duplicate`, `is_cancelled`

**Deduplication Strategies**:
- Keep first occurrence: `ROW_NUMBER() OVER (PARTITION BY source_id ORDER BY ingestion_time)`
- Keep most recent: `ROW_NUMBER() OVER (PARTITION BY source_id ORDER BY ingestion_time DESC)`
- Custom logic: Configurable per entity

**Quality Checks**:
- Null checks on required fields
- Data type validation
- Business rule validation (e.g., prices >= 0)
- Referential integrity checks
- Duplicate detection

**Use Cases**:
- Business analytics and reporting
- BI tool consumption
- Foundation for Gold facts/dimensions
- ML feature engineering
- Reverse ETL to business tools

**Key Rules**:
- ✅ Cleansed and validated data
- ✅ Enrichment applied
- ✅ Deduplication applied
- ✅ Source from Bronze layer
- ❌ No use-case-specific modifications (move to Gold)
- ❌ No aggregations (move to Gold)

### Reference Tables

**Definition**: Static or slowly changing data for classification and lookup

**Purpose**:
- Provide lookup data for enrichment and joins
- Standardize classifications across organization
- Enable consistent filtering/grouping in analytics

**Characteristics**:
- 1 row per unique entity
- Multiple descriptive attributes
- Static or very slowly changing
- Shared across multiple domains/fact tables
- Simple join keys

**Naming**:
- Classification entity name in singular form
- Example: `partner`, `carrier`, `geo_entity`, `currency`

**Examples**:
- Silver: `partner.properties` (partner reference with attributes)
- Silver: `carrier.airlines` (airline/carrier reference)
- Silver: `geo_entity.countries` (country/geography reference)
- Silver: `currency.definitions` (currency reference)
- Silver: `payment_method.types` (payment type reference)

**Columns Included**:
- Primary key: `partner_id`, `carrier_id`, `country_code`, `currency_id`
- Descriptive attributes: `name`, `type`, `category`, `status`
- Validity: `is_active`, `effective_date`, `expiration_date`
- Metadata: `created_date`, `modified_date`

**Change Management**:
- SCD Type 1: Overwrite (simple overwrite of current values)
- SCD Type 2: Track history (maintain multiple rows with dates)
- Documentation: Clear versioning strategy

**Use Cases**:
- Dimension table lookups
- Fact table enrichment
- Filtering/grouping in reports
- Validation reference (valid values)
- Reverse ETL lookups

**Key Rules**:
- ✅ One row per entity
- ✅ Slowly changing (or static)
- ✅ Shared across multiple consumers
- ✅ Primary key clearly defined
- ❌ Not use-case-specific (generic reference)
- ❌ Not derived data (source or minimal transformation)

---

## Gold Layer Tables

### Fact Tables

**Definition**: Key business concepts with clear grain and numeric facts

**Purpose**:
- Central tables for analytics and reporting
- Foundation for BI dashboards
- Quantify business events/metrics

**Characteristics**:
- Clear grain: 1 row = 1 something (event, transaction, user-day)
- Foreign keys to dimensions
- Numeric facts: counts, amounts, durations
- Event-based or aggregate structure
- Optimized for joins with dimensions

**Naming**:
- Prefix with `f_` for fact table
- Example: `f_booking`, `f_redirect`, `f_search`

**Examples**:
- Gold: `revenue.f_booking` (one row per booking transaction)
- Gold: `revenue.f_redirect` (one row per redirect event)
- Gold: `conversion.f_funnel_event` (one row per funnel step)
- Gold: `session.f_daily_summary` (one row per day-user-session)

**Grain Examples**:
- Event-level: 1 row per user action
- Transaction-level: 1 row per booking/payment
- Daily-level: 1 row per day-user-product combo
- User-day-level: 1 row per user per calendar day

**Column Structure**:

```
Fact Table: f_booking
├── Grain Keys
│   ├── booking_id (PK)
│   ├── date_id (FK to d_date)
│   └── session_id (PK for session grain)
├── Foreign Keys (to dimensions)
│   ├── partner_id (FK to d_partner)
│   ├── user_id (FK to d_user)
│   ├── hotel_id (FK to d_hotel)
│   └── currency_id (FK to d_currency)
├── Facts/Measures (numeric)
│   ├── booking_amount
│   ├── commission_amount
│   ├── discount_amount
│   └── total_revenue
├── Flags
│   ├── is_completed
│   ├── is_cancelled
│   └── is_paid
└── Metadata
    ├── booking_date
    ├── ingestion_timestamp
    └── source_system
```

**Data Source**:
- ✅ Read from Silver tables
- ✅ Read from Gold dimensions (allowed)
- ✅ Join dimensions on fact_key
- ❌ Never read from other Gold facts
- ❌ Use bridge tables if different grains needed

**Use Cases**:
- BI reporting and dashboards
- Business analytics and insights
- KPI tracking
- Operational monitoring
- Compliance reporting

**Key Rules**:
- ✅ Clear, well-defined grain
- ✅ Foreign keys to dimensions
- ✅ Numeric measures/facts
- ✅ Source from Silver (or reference Gold dimension)
- ❌ No other fact table reads (use bridge table)
- ❌ No wide/denormalized data (move to wide tables)

### Dimension Tables

**Definition**: Categorizations and attributes for filtering/grouping facts

**Purpose**:
- Provide context for fact analysis
- Enable consistent filtering in reports
- Standardize business attributes

**Characteristics**:
- One row per unique entity
- Multiple descriptive attributes
- Used to slice and dice facts
- Join to facts on foreign key
- Often smaller than facts

**Naming**:
- Prefix with `d_` for dimension
- Example: `d_partner`, `d_user`, `d_hotel`

**Examples**:
- Gold: `revenue.d_partner` (partner attributes for filtering)
- Gold: `revenue.d_currency` (currency attributes)
- Gold: `revenue.d_date` (date dimension for time analysis)
- Gold: `revenue.d_hotel` (hotel attributes for filtering)

**Column Structure**:

```
Dimension Table: d_partner
├── Primary Key
│   └── partner_id
├── Descriptive Attributes
│   ├── partner_name
│   ├── partner_type
│   ├── country
│   ├── status
│   └── rating
├── Slowly Changing (if tracked)
│   ├── effective_date
│   ├── expiration_date
│   └── is_current
└── Metadata
    ├── created_date
    ├── modified_date
    └── source_system
```

**Sourcing**:
- Read from Silver reference tables
- May include cross-domain joins
- Apply business logic/transformations
- Document any complex derivations

**Slowly Changing Dimension (SCD) Strategy**:

- **SCD Type 1** (Overwrite): Current values only
  - Good for: Attributes that shouldn't change historically
  - Example: Partner name corrections

- **SCD Type 2** (Track history): Multiple rows per entity with dates
  - Good for: Attributes that need historical context
  - Example: Partner status changes over time
  - Includes: `effective_date`, `expiration_date`, `is_current` flags

**Use Cases**:
- Filtering data in reports (select all hotels in country X)
- Grouping/aggregating data (revenue by partner type)
- Labeling facts (categorize bookings as urgent/normal)
- Adding context (show partner rating with each booking)

**Key Rules**:
- ✅ One row per unique entity
- ✅ Multiple descriptive attributes
- ✅ Source from Silver
- ✅ Join to facts on foreign key
- ❌ Not for numeric aggregates (use facts)
- ❌ Not for events/transactions (use facts)

### Wide Tables

**Definition**: Pre-joined, pre-aggregated datasets for fast BI consumption

**Purpose**:
- Optimize query performance for BI tools
- Pre-aggregate common calculations
- Simplify BI tool configurations
- Flatten denormalized data for reporting

**Characteristics**:
- Pre-joined fact + dimensions
- Pre-aggregated calculations
- Denormalized structure
- Optimized for specific reporting use case
- May contain derived metrics

**Naming**:
- Prefix with `bar_` for BAR (Business Analytics & Reporting) tables
- Example: `bar_understand`, `bar_audience`
- Or suffix with use case: `session_metrics`, `revenue_summary`

**Examples**:
- Gold: `bar_understand.user_cohorts` (user cohort analysis wide table)
- Gold: `bar_audience.traffic_summary` (traffic analysis with pre-aggregates)
- Gold: `session_metrics.daily_summary` (daily session metrics pre-aggregated)
- Gold: `revenue_summary.monthly_facts` (monthly revenue with all dimensions)

**Column Structure Example**:

```
Wide Table: bar_understand.user_cohorts
├── Dimension Attributes (flattened)
│   ├── user_id
│   ├── user_segment
│   ├── signup_date
│   ├── country
│   ├── device_type
│   └── traffic_source
├── Pre-Calculated Metrics
│   ├── total_bookings (SUM)
│   ├── total_revenue (SUM)
│   ├── avg_booking_value (AVG)
│   ├── conversion_rate (CALCULATED)
│   ├── days_since_last_booking (CALCULATED)
│   └── lifetime_value (CALCULATED)
├── Time Attributes
│   ├── cohort_date
│   ├── analysis_date
│   └── days_in_cohort
└── Metadata
    ├── row_count
    └── last_updated
```

**When to Use**:
- ✅ Complex joins difficult in BI tool
- ✅ Heavy aggregations needed
- ✅ Consistent metric calculations
- ✅ BI tool performance issues
- ❌ Simple fact/dimension design sufficient
- ❌ Changing business logic (use facts/dims instead)

**Maintenance Considerations**:
- Document exactly what's pre-aggregated
- Maintain clear lineage to source fact/dimensions
- Update frequency may differ from facts/dimensions
- Versioning strategy for metric changes

**Use Cases**:
- Executive dashboards (pre-aggregated metrics)
- Marketing analytics (pre-joined dimensions)
- Operations monitoring (complex calculations)
- User segmentation (denormalized user attributes + metrics)

---

## Cross-Layer Tables

### Reverse ETL Tables

**Definition**: Data copied from Databricks to external consumption tools

**Purpose**:
- Export analytics data to business tools
- Feed marketing platforms, data warehouses
- Synchronize business data across tools

**Characteristics**:
- Typically wide/denormalized format
- Optimized for tool consumption
- May be Intermediate (in Databricks) or Final (exported)
- Clear schema matching tool requirements

**Naming**:
- `<tool>_export`: `amplitude_export`, `druid_export`
- Or use descriptive name: `user_segments_amplitude`

**Examples**:
- Gold/Silver: `amplitude_export` (user events exported to Amplitude)
- Gold/Silver: `druid_export` (facts exported to Druid analytics)
- Gold/Silver: `dr_jekyll_export` (customer data exported to Dr.Jekyll)

**Column Mapping**:
- Document how Databricks columns map to tool fields
- Include any transformations applied
- Note any tool-specific formatting

**Update Frequency**:
- Often real-time or very frequent (5-15 min)
- Must meet tool's sync cadence
- Document SLA for sync

**Use Cases**:
- Event analytics (Amplitude, Druid)
- Customer data platforms (Dr.Jekyll)
- Marketing automation tools
- BI tool syncs

### App Logs

**Definition**: Logs from applications, systems, or pipelines

**Purpose**:
- Debugging and troubleshooting
- System monitoring
- Performance analysis
- Audit trails

**Characteristics**:
- Unstructured or semi-structured
- High volume, time-series
- Typically stored as-is (minimal processing)
- May be compressed or archived

**Naming**:
- `<app>_logs`: `pipeline_logs`, `ingestion_logs`
- Or `<component>_events`: `api_events`, `etl_events`

**Examples**:
- Bronze/Silver: `internal.pipeline_logs` (ETL pipeline logs)
- Bronze: `api_events` (API access logs)
- Bronze: `system_errors` (system error logs)

**Retention**:
- Often shorter (30-90 days) than business data
- Archived to cold storage after period
- Configurable per log type

**Use Cases**:
- Troubleshooting pipeline failures
- Monitoring system health
- Security auditing
- Performance analysis

### Temporary Tables

**Definition**: Short-lived tables for ETL, PoC, or analysis

**Purpose**:
- Intermediate processing steps
- Experimentation and prototyping
- Staging for transformations
- Ad-hoc analysis

**Characteristics**:
- Expected to be short-lived
- May use less rigorous naming conventions
- Often recreated daily or per-run
- Lower priority for maintenance

**Naming**:
- Prefix with `tmp_` or `stg_`
- Include purpose: `tmp_dedup_intermediate`, `stg_enrichment`

**Examples**:
- `tmp_dedup_intermediate` (intermediate table during dedup)
- `stg_enrichment_staging` (staging table for enrichment)
- `tmp_data_quality_check` (QA verification table)
- `tmp_poc_ranking_model` (proof of concept table)

**Lifecycle**:
- Created: At job start
- Dropped: At job end or after TTL expires
- Or recreated: Daily/weekly as needed

**Use Cases**:
- ETL intermediate tables
- Proof of concepts
- Ad-hoc analysis
- Debugging

### Data Quality Metrics

**Definition**: Quality validation metrics captured during ETL

**Purpose**:
- Monitor data quality
- Track quality improvements
- Alert on quality degradation
- Root cause analysis

**Characteristics**:
- One row per check per run
- Includes check name, result, count
- Timestamped with run info
- Often aggregated/monitored

**Naming**:
- Prefix with `dq_` for data quality
- Include check type: `dq_null_check`, `dq_duplicate_count`

**Examples**:
- `dq_redirect_null_check` (null value checks)
- `dq_booking_range_validation` (value range checks)
- `dq_duplicate_count_by_key` (duplicate detection counts)

**Columns**:
- `check_name`: What was checked
- `check_result`: PASS/FAIL/WARNING
- `row_count`: Rows checked
- `issue_count`: Issues found
- `check_timestamp`: When check ran
- `table_name`: Table checked

**Use Cases**:
- Data quality dashboards
- Alerting on issues
- SLA tracking
- Trend analysis

### Config Tables

**Definition**: Configuration for jobs and processes

**Purpose**:
- Externalize configuration
- Enable job parameterization
- Reduce hardcoding

**Characteristics**:
- Key-value pairs or structured config
- Rarely changes
- Sourced from system of record
- Often small tables

**Naming**:
- Prefix with `config_`
- Example: `config_dedup_rules`, `config_enrichment`

**Examples**:
- `config_dedup_rules` (deduplication rules per entity)
- `config_enrichment_sources` (which enrichments to apply)
- `config_retention_policies` (retention by table)

**Use Cases**:
- Parameterizing ETL jobs
- Managing dedup rules
- Controlling enrichment behavior
- Retention policy management

### Audit Tables

**Definition**: Audit trail information for compliance/debugging

**Purpose**:
- Track data changes
- Maintain compliance audit trail
- Enable data lineage
- Support investigations

**Characteristics**:
- Records changes over time
- Includes who/what/when
- Often immutable
- May be subject to compliance holds

**Naming**:
- Prefix with `audit_`
- Example: `audit_redirect_changes`

**Examples**:
- `audit_redirect_changes` (tracking redirect data changes)
- `audit_schema_modifications` (schema change tracking)
- `audit_access_logs` (who accessed what data)

**Columns**:
- `audit_timestamp`: When change occurred
- `operation`: INSERT/UPDATE/DELETE
- `user_id`: Who made change
- `old_value` / `new_value`: Before/after
- `reason`: Why change made

**Retention**:
- Often very long (match data retention or regulatory requirement)
- May require write-once storage
- Subject to data governance policies

---

## Table Design Patterns

### Pattern 1: Conformed Dimension

Single dimension referenced by multiple facts

```
Dimension: d_partner
├── f_booking (references d_partner)
├── f_redirect (references d_partner)
└── f_revenue (references d_partner)
```

**Benefits**: Consistent business logic, single source of partner attributes

### Pattern 2: Junk Dimension

Multiple low-cardinality attributes combined into single dimension

```
Instead of:
├── d_is_completed
├── d_is_cancelled
├── d_is_paid

Use:
└── d_flags (composite: is_completed, is_cancelled, is_paid)
```

**Benefits**: Reduces dimension table count, simplifies joins

### Pattern 3: Bridge Table

Join facts at different grains

```
Silver: click_event, booking_event (different grain)
  ↓
Bridge: bridge_booking_daily (matches booking grain)
  ↓
Facts: f_booking, f_daily_summary (read from bridge)
```

**Benefits**: Avoids fact-to-fact reads, maintains single source of truth

### Pattern 4: Slowly Changing Dimension

Track changes to dimension attributes over time

```
d_partner (SCD Type 2)
├── partner_id | partner_name | status | effective_date | expiration_date
├── 100 | Skyscanner | ACTIVE | 2020-01-01 | NULL
├── 100 | Skyscanner Inc | ACTIVE | 2021-06-01 | NULL
└── (previous rows have expiration_date)
```

**Benefits**: Historical context, accurate historical reporting

---

## Table Category Checklist

When creating a new table, determine:

- [ ] **Layer**: Bronze/Silver/Gold/Silicon
- [ ] **Category**: Raw, Entity, Reference, Fact, Dimension, etc.
- [ ] **Grain**: For facts, what's 1 row?
- [ ] **Primary Key**: What uniquely identifies rows?
- [ ] **Foreign Keys**: What dimensions does this reference?
- [ ] **Data Source**: Where does data come from?
- [ ] **Update Frequency**: How often refreshed?
- [ ] **Retention**: How long kept?
- [ ] **Naming**: Follows category conventions?
- [ ] **Documentation**: Purpose, grain, keys documented?

---

## References

- Layer specifications: See `layer-specifications.md`
- Naming conventions: See `naming-conventions.md`
- Data flows: See `data-flows.md`
- Kimball modeling: See `kimball-modeling.md`
