# Naming Conventions Reference

Comprehensive naming patterns for Medallion Architecture.

## General Rules

1. **Singular words**: `redirect` not `redirects`, `booking` not `bookings`
2. **snake_case**: `user_journey` not `userJourney` or `user-journey`
3. **Business terminology**: `redirect` not `click`, `booking` not `order`
4. **Avoid squad/team names**: `internal` not `ziggy`, `session` not `data_tribe`
5. **Descriptive**: Names should convey business meaning at a glance

## Catalog Names

Production catalogs:
- `prod_trusted_bronze`
- `prod_trusted_silver`
- `prod_trusted_gold`
- `prod_trusted_silicon`

Development catalogs:
- `dev_trusted_bronze`
- `dev_trusted_silver`
- `dev_trusted_gold`
- `dev_trusted_silicon`

## Schema Names (Data Domains)

Data domains are the schema level, containing related datasets. Use consistent naming by layer.

### Bronze Layer Domains

Bronze domains follow source system conventions. Each source has dedicated domain.

#### 1st Party Events: `internal`

**Pattern**: `internal`

**Characteristics**:
- All first-party events centralized in single domain
- Multiple datasets within `internal` for different event types
- Multiple squads can own datasets within `internal`
- Example: `prod_trusted_bronze.internal.web_events`, `prod_trusted_bronze.internal.app_events`

**Dataset Examples**:
- `skippy_redirect_events`
- `app_funnel_events`
- `search_events`
- `payment_events`

#### 1st Party Batch: Named by data source

**Pattern**: `<system_name>`

**Examples**:
- `casc` (internal batch)
- `human_curated_data` (reference data)
- `revenue_forecasts` (financial batch)

**Characteristics**:
- Named after source system
- Internal Skyscanner data sources
- Batch processing cadence

**Dataset Examples**:
- `prod_trusted_bronze.casc.accomodation_rates`
- `prod_trusted_bronze.human_curated_data.partner_metadata`

#### 3rd Party Batch (Custom Integration)

**Pattern**: `<system_name>` or `<system>_<function>`

**Examples**:
- `amadeus` (API integration)
- `similarweb` (market data)
- `revenue_scrapers` (web scraping)
- `ql2` (airline data)
- `google_ads_paid_marketing` (multi-function)

**Characteristics**:
- Named after external data source
- Custom ETL jobs (AWS Batch, custom code)
- May be owned by multiple squads

**Dataset Examples**:
- `prod_trusted_bronze.amadeus.availability`
- `prod_trusted_bronze.revenue_scrapers.hotel_rates`
- `prod_trusted_bronze.google_ads_paid_marketing.campaign_metrics`

#### 3rd Party (Fivetran): Prefix with `fivetran_`

**Pattern**: `fivetran_<system_name>`

**Examples**:
- `fivetran_zendesk`
- `fivetran_qualtrics`
- `fivetran_salesforce`
- `fivetran_amadeus`
- `fivetran_similerweb_api`

**Characteristics**:
- Managed by Fivetran connectors
- Standardized naming for easy identification
- Often multiple tables within domain

**Dataset Examples**:
- `prod_trusted_bronze.fivetran_zendesk.tickets`
- `prod_trusted_bronze.fivetran_zendesk.articles`
- `prod_trusted_bronze.fivetran_qualtrics.survey_responses`

#### 3rd Party (Lakeflow Connect): Prefix with `lfc_`

**Pattern**: `lfc_<system_name>`

**Examples**:
- `lfc_content_platform`
- `lfc_marketing_platform`

**Characteristics**:
- Managed by Lakeflow Connect
- Standardized naming convention
- External data platform integration

**Dataset Examples**:
- `prod_trusted_bronze.lfc_content_platform.articles`
- `prod_trusted_bronze.lfc_content_platform.recommendations`

#### Multiple Squad Ingestion (Exception)

**Pattern**: `<system>_<use_case>` or `<system>_<team>`

**Examples**:
- `google_ads_paid_marketing` (paid marketing ingestion)
- `funnel_paid_marketing` (funnel team also ingests)
- `funnel_campaign` (campaign data for funnel)

**Use When**:
- Multiple squads need to ingest same source
- Segregation required for different use cases
- Exception to single-ownership rule

**Characteristics**:
- Suffix with use case or team context
- Clear ownership/governance needed
- Document ingestion coordination

**Dataset Examples**:
- `prod_trusted_bronze.google_ads_paid_marketing.campaign_metrics`
- `prod_trusted_bronze.funnel_paid_marketing.campaign_metrics`

### Silver Layer Domains

Silver domains represent business concepts and logical entities.

#### Business Concepts

**Pattern**: `<business_concept>`

**Characteristics**:
- Named after core Skyscanner business concepts
- Long-lived domains
- Joinable by design
- Owned by business/product team or UDM team

**Examples**:
- `redirect` (user searches and redirects)
- `booking` (completed transactions)
- `user_complaint` (customer complaints/feedback)
- `session` (user session context)
- `payment` (payment transactions)
- `accommodation` (property information)
- `user_journey` (user behavior path)
- `search_query` (normalized search requests)

**Dataset Naming** (within domain):
- `prod_trusted_silver.redirect.events` (cleaned redirect entity)
- `prod_trusted_silver.booking.transactions` (cleaned booking entity)
- `prod_trusted_silver.user_complaint.tickets` (cleaned complaint entity)

#### Reference Data

**Pattern**: `<reference_type>` (noun, singular, classification data)

**Characteristics**:
- Static or slowly changing dimensions
- Lookup/reference data for enrichment
- Used across multiple domains
- Lower update frequency

**Examples**:
- `partner` (partner/vendor information)
- `carrier` (airline companies)
- `geo_entity` (geographic locations)
- `currency` (currency definitions)
- `payment_method` (payment types)
- `hotel_chain` (hotel chain information)
- `airport` (airport information)

**Dataset Naming** (within domain):
- `prod_trusted_silver.partner.properties` (partner reference data)
- `prod_trusted_silver.geo_entity.countries` (country reference)
- `prod_trusted_silver.carrier.airlines` (carrier reference)

### Gold Layer Domains

Gold domains serve analytics, reporting, and specific use cases.

#### Business Concept Domains

**Pattern**: `<business_concept>`

**Characteristics**:
- Named after business concept
- Contains fact and dimension tables
- Organized for BI/reporting
- May include wide pre-joined tables

**Examples**:
- `revenue` (revenue facts and dimensions)
- `conversion` (conversion funnel facts)
- `user_engagement` (engagement metrics)
- `marketplace_health` (market health facts)

**Dataset Naming** (within domain):
- `prod_trusted_gold.revenue.f_booking` (fact table)
- `prod_trusted_gold.revenue.d_partner` (dimension table)
- `prod_trusted_gold.revenue.d_currency` (dimension table)
- `prod_trusted_gold.revenue.wide_revenue_summary` (wide table)

#### BAR Reporting Domains

**Pattern**: `bar_<reporting_area>`

**Characteristics**:
- Prefix with `bar_` (Business Analytics & Reporting)
- Pre-joined, pre-aggregated wide tables
- Optimized for BI tool consumption
- Specific to reporting use case

**Examples**:
- `bar_understand` (user understanding/segmentation)
- `bar_audience` (audience/traffic analysis)
- `bar_roi` (ROI and performance metrics)
- `bar_marketplace` (marketplace health reporting)

**Dataset Naming** (within domain):
- `prod_trusted_gold.bar_understand.user_wide_table`
- `prod_trusted_gold.bar_audience.traffic_summary`
- `prod_trusted_gold.bar_roi.campaign_performance`

#### Performance Metrics Domains

**Pattern**: `<metric_area>_metrics`

**Characteristics**:
- Suffix with `_metrics`
- Performance and KPI focused
- Time-series oriented
- May include aggregations at multiple grains

**Examples**:
- `session_metrics` (session-level metrics)
- `conversion_funnel_metrics` (funnel progression)
- `search_metrics` (search performance)
- `booking_metrics` (booking performance)

**Dataset Naming** (within domain):
- `prod_trusted_gold.session_metrics.hourly_summary`
- `prod_trusted_gold.session_metrics.daily_summary`
- `prod_trusted_gold.conversion_funnel_metrics.funnel_steps`

### Silicon Layer Domains

Silicon domains organize ML datasets by use case.

#### ML Use Cases

**Pattern**: `<ml_purpose>` or `<model_name>`

**Characteristics**:
- Named after ML use case or model
- Feature engineering contained here
- Not for business reporting
- 6-month retention

**Examples**:
- `ranking_model` (hotel ranking model features)
- `recommendation_features` (recommendation engine features)
- `churn_prediction` (customer churn model)
- `price_optimization` (pricing model)
- `search_quality` (search ranking features)

**Dataset Naming** (within domain):
- `prod_trusted_silicon.ranking_model.features_training_v2`
- `prod_trusted_silicon.ranking_model.model_predictions`
- `prod_trusted_silicon.recommendation_features.user_history`

---

## Table Naming Conventions

### Fact Table Naming

**Prefix**: `f_`

**Pattern**: `f_<business_concept>` or `f_<grain>`

**Examples**:
- `f_redirect` (one row per redirect)
- `f_booking` (one row per booking)
- `f_search` (one row per search)
- `f_user_session` (one row per user session)
- `f_daily_revenue` (one row per day)

**Guideline**: Name should clearly indicate the grain/subject of the table

### Dimension Table Naming

**Prefix**: `d_`

**Pattern**: `d_<dimension_entity>`

**Examples**:
- `d_user` (user dimension)
- `d_partner` (partner dimension)
- `d_hotel` (hotel dimension)
- `d_airport` (airport dimension)
- `d_carrier` (airline carrier dimension)
- `d_currency` (currency dimension)
- `d_date` (date dimension)

**Guideline**: Singular entity name, clearly identifies what the dimension represents

### Bridge Table Naming

**Pattern**: `bridge_<fact_a>_<fact_b>` or `bridge_<grain>`

**Characteristics**:
- Used to join facts at appropriate grain
- Clarifies joining logic
- Replaces fact-to-fact reads

**Examples**:
- `bridge_booking_daily` (joins booking-level to daily-level facts)
- `bridge_search_session` (joins search events to session-level facts)

### Reference Table Naming (Silver)

**Pattern**: `<entity_type>` (no prefix)

**Examples**:
- `partner` (partner reference)
- `carrier` (carrier reference)
- `geo_entity` (geography reference)
- `currency` (currency reference)

**Guideline**: Simple entity name in singular form

### Reverse ETL Table Naming

**Pattern**: `<purpose>` or `<tool>_export`

**Characteristics**:
- May be wide or denormalized
- Optimized for tool consumption
- Document tool requirements

**Examples**:
- `amplitude_events` (events exported to Amplitude)
- `druid_facts` (facts for Druid consumption)
- `user_segments` (segments for external tool)

### Temporary/Staging Table Naming

**Pattern**: `tmp_<purpose>` or `stg_<purpose>`

**Characteristics**:
- Prefix with `tmp_` or `stg_`
- Clearly indicates temporary nature
- Document expected lifetime

**Examples**:
- `tmp_dedup_intermediate`
- `stg_enrichment_staging`
- `tmp_data_quality_check`

---

## Column Naming Conventions

### General Column Rules

1. **snake_case**: `user_id` not `userId` or `user-id`
2. **Descriptive**: `booking_date` not `date`
3. **Include type hints**: `is_completed` for boolean, `count_` for counts
4. **Qualify foreign keys**: `partner_id`, `user_id`, `hotel_id`
5. **Date columns**: Suffix with `_date` or `_timestamp`

### Fact Table Columns

**Foreign Keys**:
- `partner_id`, `user_id`, `hotel_id`, `date_id`
- Reference matching dimension names

**Facts/Measures**:
- `total_revenue`, `booking_count`, `session_duration_minutes`
- Clear, quantitative names

**Attributes**:
- Move to dimensions unless critical to grain
- Example: `is_completed`, `booking_status`

### Dimension Table Columns

**Primary Key**:
- `partner_id`, `user_id`, `date_id`
- Singular, clear identifier

**Attributes**:
- `partner_name`, `partner_country`, `partner_type`
- Descriptive classification attributes

**Dates**:
- `created_date`, `effective_date`, `expiration_date`
- Clear date purpose

### Source System Columns (Bronze)

**Source metadata**:
- `_ingestion_timestamp` (when loaded)
- `_source_system` (origin system)
- `_raw_data` (original raw payload)
- Prefix with `_` to distinguish metadata

---

## Naming in Different Scenarios

### Scenario: Multiple Datasets in One Domain

**Setup**: Multiple data teams ingest to `internal` Bronze domain

```
prod_trusted_bronze.internal.web_events        (Ziggy squad)
prod_trusted_bronze.internal.app_events        (Mobile squad)
prod_trusted_bronze.internal.api_events        (API squad)
```

**Rule**: Domain owned collectively, dataset owners manage their tables

### Scenario: Renamed Business Concept

**Old concept**: `competitor_pricing`
**New concept**: `market_rates` (renamed in Silver)

```
prod_trusted_bronze.revenue_scrapers.competitor_pricing    (Bronze - keep source)
prod_trusted_silver.market_rates.daily_rates              (Silver - business term)
prod_trusted_gold.revenue.d_market_rate                   (Gold - fact/dimension)
```

**Rule**: Keep Bronze name matching source, rename at Silver

### Scenario: Multiple Representations of Same Data

**Use case**: Different de-dup rules needed

```
prod_trusted_silver.search_query.all_queries          (no dedup)
prod_trusted_silver.search_query.distinct_queries     (unique only)
prod_trusted_silver.search_query.canonical_queries    (normalized)
```

**Rule**: Suffix with representation type if multiple versions needed

### Scenario: Slowly Changing Dimension

**Setup**: Historical tracking for slowly changing reference data

```
prod_trusted_silver.partner.current              (latest)
prod_trusted_silver.partner.history              (all versions)
prod_trusted_gold.d_partner                      (slowly changing type 2)
```

**Rule**: Include version/history info if tracking changes

---

## Anti-Patterns to Avoid

❌ **Technical names**: `tbl_001`, `x_data`, `temp_dump`
→ Use descriptive business terms

❌ **Squad names**: `ziggy_events`, `mobile_data`, `data_tribe_table`
→ Use business concepts, not team names

❌ **Inconsistent casing**: `User_ID`, `userId`, `user-id` mixed
→ Standardize on snake_case

❌ **Abbreviations**: `usr`, `ptn`, `bk`, `accom`
→ Use full words (user, partner, booking, accommodation)

❌ **Plural domain names**: `redirects`, `bookings`, `partners`
→ Use singular form

❌ **DBFS paths**: Schema names like `/mnt/data/bronze/events`
→ Use catalog.schema.table naming, not paths

❌ **Version numbers in domains**: `bronze_v1`, `silver_v2`
→ Version at table level if needed, not domain level

---

## Naming Validation Checklist

When naming a new table/domain:

- [ ] **Singular form**: No plurals
- [ ] **snake_case**: All lowercase, underscores only
- [ ] **Business terminology**: Clear business meaning
- [ ] **No squad names**: Not named after teams
- [ ] **No technical terms**: Not technical/system-specific
- [ ] **Descriptive**: 2-5 words, clear purpose
- [ ] **Follows layer pattern**: Bronze/Silver/Gold/Silicon conventions
- [ ] **No ambiguity**: Unambiguous to all users
- [ ] **Documented**: Owner and purpose clear
- [ ] **Consistent**: Matches existing naming in domain

---

## Migration and Renaming

If renaming existing tables:

1. **Document mapping**: Old name → New name
2. **Update lineage**: Adjust data flow documentation
3. **Communicate change**: Notify consumers
4. **Create alias** (if tool supports): Old name → New name redirect
5. **Deprecate old name**: Set retention date for old table
6. **Update contracts**: Reflect new names in data contracts
