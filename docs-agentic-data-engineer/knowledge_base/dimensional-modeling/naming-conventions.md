# Naming Conventions for Gold Layer

Gold layer naming conventions following Skyscanner's Medallion Architecture standards.

## General Rules

1. **Singular words**: `redirect` not `redirects`, `booking` not `bookings`
2. **snake_case**: `user_journey` not `userJourney` or `user-journey`
3. **Business terminology**: Use domain language, not technical jargon
4. **Avoid squad/team names**: `internal` not `ziggy`, `session` not `data_tribe`
5. **Descriptive**: Names should convey business meaning at a glance

## Catalog Names

**Production:**
- `prod_trusted_gold`

**Development:**
- `dev_trusted_gold`

## Schema Names (Data Domains)

Gold domains organize data for analytics, reporting, and specific use cases.

### Business Concept Domains

**Pattern**: `<business_concept>`

**Characteristics:**
- Named after business concept
- Contains fact and dimension tables
- Organized for BI/reporting
- May include wide pre-joined tables

**Examples:**
- `revenue` (revenue facts and dimensions)
- `conversion` (conversion funnel facts)
- `user_engagement` (engagement metrics)
- `marketplace_health` (market health facts)
- `booking` (booking-related facts and dimensions)
- `redirect` (redirect-related facts and dimensions)
- `session` (session-related facts and dimensions)

**Table Naming within Domain:**
```sql
-- Fact tables
prod_trusted_gold.revenue.f_booking
prod_trusted_gold.revenue.f_daily_revenue
prod_trusted_gold.conversion.f_user_journey

-- Dimension tables
prod_trusted_gold.revenue.d_partner
prod_trusted_gold.revenue.d_currency
prod_trusted_gold.booking.d_hotel

-- Wide tables (optional)
prod_trusted_gold.revenue.wide_revenue_summary
```

### BAR Reporting Domains

**Pattern**: `bar_<reporting_area>`

**Characteristics:**
- Prefix with `bar_` (Business Analytics & Reporting)
- Pre-joined, pre-aggregated wide tables
- Optimized for BI tool consumption
- Specific to reporting use case

**Examples:**
- `bar_understand` (user understanding/segmentation)
- `bar_audience` (audience/traffic analysis)
- `bar_roi` (ROI and performance metrics)
- `bar_marketplace` (marketplace health reporting)

**Table Naming within Domain:**
```sql
prod_trusted_gold.bar_understand.user_wide_table
prod_trusted_gold.bar_audience.traffic_summary
prod_trusted_gold.bar_roi.campaign_performance
prod_trusted_gold.bar_marketplace.daily_metrics
```

### Performance Metrics Domains

**Pattern**: `<metric_area>_metrics`

**Characteristics:**
- Suffix with `_metrics`
- Performance and KPI focused
- Time-series oriented
- May include aggregations at multiple grains

**Examples:**
- `session_metrics` (session-level metrics)
- `conversion_funnel_metrics` (funnel progression)
- `search_metrics` (search performance)
- `booking_metrics` (booking performance)

**Table Naming within Domain:**
```sql
prod_trusted_gold.session_metrics.hourly_summary
prod_trusted_gold.session_metrics.daily_summary
prod_trusted_gold.conversion_funnel_metrics.funnel_steps
prod_trusted_gold.booking_metrics.daily_aggregates
```

## Table Naming Conventions

### Fact Table Naming

**Prefix**: `f_`

**Pattern**: `f_<business_concept>` or `f_<grain>`

**Examples:**
```sql
-- Transaction facts
CREATE TABLE prod_trusted_gold.revenue.f_booking (...)
CREATE TABLE prod_trusted_gold.redirect.f_redirect (...)
CREATE TABLE prod_trusted_gold.search.f_search (...)

-- Aggregated facts
CREATE TABLE prod_trusted_gold.revenue.f_daily_revenue (...)
CREATE TABLE prod_trusted_gold.session.f_user_session (...)

-- Event facts
CREATE TABLE prod_trusted_gold.engagement.f_page_view (...)
```

**Guidelines:**
- Name clearly indicates the grain/subject
- Use singular form
- Descriptive of business process

### Dimension Table Naming

**Prefix**: `d_`

**Pattern**: `d_<dimension_entity>`

**Examples:**
```sql
CREATE TABLE prod_trusted_gold.revenue.d_partner (...)
CREATE TABLE prod_trusted_gold.revenue.d_hotel (...)
CREATE TABLE prod_trusted_gold.booking.d_airport (...)
CREATE TABLE prod_trusted_gold.revenue.d_carrier (...)
CREATE TABLE prod_trusted_gold.revenue.d_currency (...)
CREATE TABLE prod_trusted_gold.revenue.d_date (...)
CREATE TABLE prod_trusted_gold.user.d_user (...)
```

**Guidelines:**
- Singular entity name
- Clearly identifies what dimension represents
- Use business terminology

### Bridge Table Naming

**Pattern**: `bridge_<entity_a>_<entity_b>` or `bridge_<grain>`

**Characteristics:**
- Used to join facts at appropriate grain
- Clarifies joining logic
- Replaces fact-to-fact reads

**Examples:**
```sql
CREATE TABLE prod_trusted_gold.revenue.bridge_booking_daily (...)
CREATE TABLE prod_trusted_gold.search.bridge_search_session (...)
CREATE TABLE prod_trusted_gold.conversion.bridge_redirect_booking (...)
```

### Wide Table Naming

**Pattern**: `wide_<purpose>` or `<entity>_wide_table`

**Characteristics:**
- Pre-joined denormalized tables
- Optimized for BI consumption
- Clear indication it's a wide table

**Examples:**
```sql
CREATE TABLE prod_trusted_gold.revenue.wide_revenue_summary (...)
CREATE TABLE prod_trusted_gold.bar_understand.user_wide_table (...)
CREATE TABLE prod_trusted_gold.conversion.wide_funnel_analysis (...)
```

### Reverse ETL Table Naming

**Pattern**: `<tool>_export` or `<purpose>`

**Characteristics:**
- May be wide or denormalized
- Optimized for tool consumption
- Document tool requirements

**Examples:**
```sql
CREATE TABLE prod_trusted_gold.exports.amplitude_events (...)
CREATE TABLE prod_trusted_gold.exports.druid_facts (...)
CREATE TABLE prod_trusted_gold.segments.user_segments (...)
```

### Temporary/Staging Table Naming

**Pattern**: `tmp_<purpose>` or `stg_<purpose>`

**Characteristics:**
- Prefix with `tmp_` or `stg_`
- Clearly indicates temporary nature
- Document expected lifetime

**Examples:**
```sql
CREATE TABLE prod_trusted_gold.revenue.tmp_dedup_intermediate (...)
CREATE TABLE prod_trusted_gold.booking.stg_enrichment_staging (...)
CREATE TABLE prod_trusted_gold.revenue.tmp_data_quality_check (...)
```

## Column Naming Conventions

### General Column Rules

1. **snake_case**: `user_id` not `userId` or `user-id`
2. **Descriptive**: `booking_date` not `date`
3. **Type hints**: `is_completed` (boolean), `count_bookings` (count)
4. **Qualify foreign keys**: `partner_id`, `user_id`, `hotel_id`
5. **Date columns**: Suffix with `_date`, `_timestamp`, or `_key`

### Fact Table Columns

**Surrogate Keys:**
```sql
booking_key BIGINT NOT NULL,
sales_key BIGINT NOT NULL,
transaction_key BIGINT NOT NULL
```

**Foreign Keys (to dimensions):**
```sql
partner_id BIGINT NOT NULL,
user_id BIGINT NOT NULL,
hotel_id BIGINT NOT NULL,
date_key BIGINT NOT NULL,
currency_id BIGINT NOT NULL
```

**Degenerate Dimensions:**
```sql
order_number STRING NOT NULL,
invoice_id STRING NOT NULL,
transaction_id STRING NOT NULL
```

**Measures/Facts:**
```sql
-- Amounts
total_revenue DECIMAL(18,2) NOT NULL,
booking_amount DECIMAL(18,2) NOT NULL,
commission_amount DECIMAL(18,2) NOT NULL,

-- Counts
booking_count INT NOT NULL,
session_count INT NOT NULL,
click_count BIGINT NOT NULL,

-- Durations
session_duration_seconds INT NOT NULL,
response_time_milliseconds BIGINT NOT NULL,

-- Flags/Attributes
is_completed BOOLEAN NOT NULL,
booking_status STRING NOT NULL
```

**Audit Columns:**
```sql
created_timestamp TIMESTAMP NOT NULL,
updated_timestamp TIMESTAMP NOT NULL,
source_system STRING NOT NULL,
batch_id BIGINT NOT NULL
```

### Dimension Table Columns

**Primary Key:**
```sql
partner_id BIGINT NOT NULL,
user_id BIGINT NOT NULL,
date_key BIGINT NOT NULL,
hotel_id BIGINT NOT NULL
```

**Natural/Business Keys:**
```sql
partner_code STRING NOT NULL,
user_uuid STRING NOT NULL,
hotel_code STRING NOT NULL
```

**Descriptive Attributes:**
```sql
partner_name STRING NOT NULL,
partner_country STRING NOT NULL,
partner_type STRING NOT NULL,
partner_status STRING NOT NULL
```

**SCD Type 2 Columns:**
```sql
effective_date DATE NOT NULL,
expiration_date DATE NOT NULL,
is_current BOOLEAN NOT NULL
```

**Audit Columns:**
```sql
created_timestamp TIMESTAMP NOT NULL,
updated_timestamp TIMESTAMP NOT NULL,
source_system STRING NOT NULL
```

## Complete Examples

### Business Concept Domain with Facts and Dimensions

```sql
-- Domain: revenue
-- Purpose: Revenue analytics and reporting

-- Fact table
CREATE TABLE prod_trusted_gold.revenue.f_booking (
    booking_key BIGINT NOT NULL,
    booking_id STRING NOT NULL,          -- Degenerate dimension
    partner_id BIGINT NOT NULL,           -- FK to d_partner
    hotel_id BIGINT NOT NULL,             -- FK to d_hotel
    user_id BIGINT NOT NULL,              -- FK to d_user
    booking_date_key BIGINT NOT NULL,     -- FK to d_date
    currency_id BIGINT NOT NULL,          -- FK to d_currency
    room_count INT NOT NULL,
    night_count INT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    commission_amount DECIMAL(18,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (booking_date_key);

-- Dimension tables
CREATE TABLE prod_trusted_gold.revenue.d_partner (
    partner_id BIGINT NOT NULL,
    partner_code STRING NOT NULL,
    partner_name STRING NOT NULL,
    partner_country STRING NOT NULL,
    partner_type STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA;

CREATE TABLE prod_trusted_gold.revenue.d_currency (
    currency_id BIGINT NOT NULL,
    currency_code STRING NOT NULL,
    currency_name STRING NOT NULL,
    currency_symbol STRING NOT NULL,
    is_active BOOLEAN NOT NULL
)
USING DELTA;
```

### BAR Domain with Wide Tables

```sql
-- Domain: bar_audience
-- Purpose: Pre-aggregated audience reporting

CREATE TABLE prod_trusted_gold.bar_audience.traffic_summary (
    date_key BIGINT NOT NULL,
    traffic_source STRING NOT NULL,
    device_type STRING NOT NULL,
    country STRING NOT NULL,
    session_count BIGINT NOT NULL,
    user_count BIGINT NOT NULL,
    page_view_count BIGINT NOT NULL,
    avg_session_duration_seconds INT NOT NULL,
    bounce_rate DECIMAL(5,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (date_key);
```

### Metrics Domain with Time-Series Aggregations

```sql
-- Domain: session_metrics
-- Purpose: Session-level performance metrics

CREATE TABLE prod_trusted_gold.session_metrics.hourly_summary (
    hour_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    hour_of_day INT NOT NULL,
    session_count BIGINT NOT NULL,
    unique_user_count BIGINT NOT NULL,
    avg_session_duration_seconds INT NOT NULL,
    total_page_views BIGINT NOT NULL,
    conversion_count INT NOT NULL,
    conversion_rate DECIMAL(5,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (date_key);
```

## Anti-Patterns to Avoid

❌ **Technical names**: `tbl_001`, `x_data`, `temp_dump`
→ Use descriptive business terms

❌ **Squad names**: `ziggy_revenue`, `mobile_booking`, `data_tribe_facts`
→ Use business concepts, not team names

❌ **Inconsistent casing**: `User_ID`, `userId`, `user-id` mixed
→ Standardize on snake_case

❌ **Abbreviations**: `usr`, `ptn`, `bk`, `accom`
→ Use full words: `user`, `partner`, `booking`, `accommodation`

❌ **Plural table names**: `f_bookings`, `d_partners`
→ Use singular: `f_booking`, `d_partner`

❌ **Plural domain names**: `bookings`, `revenues`, `sessions`
→ Use singular: `booking`, `revenue`, `session`

❌ **Missing prefixes**: `booking` (ambiguous - fact or dimension?)
→ Use `f_booking` or `d_booking`

❌ **Version numbers in names**: `revenue_v1`, `booking_v2`
→ Version through metadata/comments, not names

## Naming Validation Checklist

When creating a new gold layer table:

- [ ] **Singular form**: No plurals in table or domain names
- [ ] **snake_case**: All lowercase, underscores only
- [ ] **Business terminology**: Clear business meaning
- [ ] **No squad names**: Not named after teams
- [ ] **Appropriate prefix**: `f_` for facts, `d_` for dimensions
- [ ] **Descriptive name**: 2-5 words, clear purpose
- [ ] **Correct domain**: Placed in appropriate business/BAR/metrics domain
- [ ] **Consistent with domain**: Matches naming pattern in domain
- [ ] **No ambiguity**: Clear to all users what table contains
- [ ] **Documented**: Owner, grain, and purpose documented

## Migration and Renaming

If renaming existing gold tables:

1. **Document mapping**: Old name → New name
2. **Update lineage**: Adjust downstream dependencies
3. **Communicate change**: Notify all consumers (BI, ML, apps)
4. **Create view alias**: `CREATE VIEW old_name AS SELECT * FROM new_name`
5. **Deprecation period**: Set timeline for removing old name
6. **Update contracts**: Reflect new names in data contracts
7. **Update documentation**: Update Confluence, README files
