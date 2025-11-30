# Layer Specifications Reference

Detailed technical specifications for each medallion layer.

## Bronze Layer

### Technical Specifications

| Property | Value |
|----------|-------|
| **Definition** | Raw data layer with minimal transformation |
| **Purpose** | Immutable source of truth for replay capabilities |
| **Primary Consumer** | Data engineering teams |
| **Data Mesh Equivalent** | Source-aligned domains |
| **File Format** | Databricks Delta |
| **Compression** | Databricks default: snappy |
| **Table Type** | Managed tables (external tables for trusted pipeline ingestion) |
| **Retention Period** | 7 years by default (configurable per table) |
| **Update Frequency** | 5-15 minutes |

### Characteristics

- **Raw Data**: Unprocessed data as received from sources
- **Immutability**: Data in this layer is immutable (exceptions for PII/GDPR deletions)
- **No Transformations**: No enrichment or transformations applied
- **Data Contracts**: Datasets must adhere to data contracts and data types
- **Metadata**: Attach metadata (date, owner, session details, etc.)
- **Data Modeling**: 1:1 table for each source folder

### Use Cases

- Enable end-to-end pipeline replay in case of Silver/Gold transformation errors
- Provide raw data for reprocessing
- Maintain audit trail of original data
- Source for Silver layer data entity creation

### Key Rules

- ✅ External tables for trusted pipeline ingestion (avoids large data movement)
- ✅ Managed tables for other data sources
- ✅ Attach comprehensive metadata
- ❌ No deduplication
- ❌ No enrichment (geo, device, session)
- ❌ No filtering or transformation
- ❌ Consumer access direct from Bronze (go through Silver)

### Domain Naming (Bronze)

- **1st Party Events**: `internal`
- **1st Party Batch**: `casc`, `human_curated_data`
- **3rd Party Custom**: `amadeus`, `revenue_scrapers`, `similarweb`
- **Fivetran Connectors**: `fivetran_zendesk`, `fivetran_qualtrics`
- **Lakeflow Connect**: `lfc_content_platform`
- **Multi-Squad Ingestion**: `google_ads_paid_marketing`, `funnel_campaign`

---

## Silver Layer

### Technical Specifications

| Property | Value |
|----------|-------|
| **Definition** | Cleaned, validated, and conformed data |
| **Purpose** | Source of truth for all business consumers |
| **Primary Consumer** | Business users understanding key business concepts |
| **Data Mesh Equivalent** | Business concepts/objects |
| **File Format** | Databricks Delta |
| **Compression** | Databricks default: snappy |
| **Table Type** | Managed tables |
| **Retention Period** | 7 years by default (configurable per table) |
| **Update Frequency** | 24 hours / Daily |

### Characteristics

- **Logical, Re-usable Entities**: Business objects that can be combined
- **Data Entity Tables**: Cleansed, deduped, enriched business concepts
- **Reference Tables**: Static/slowly changing data for classification
- **Joined/Enriched**: Multiple enrichment sources applied
- **Cleaned Source of Truth**: The definitive source for consumers
- **Data Quality**: Validated against contracts and health guidelines

### Data Enrichment Activities

- **Deduplication**: Apply de-dup rules from config (configurable per use case)
- **Geo Enrichment**: MaxMind to map IP addresses to geography
- **Device Enrichment**: DeviceAtlas to map user agent strings to device info
- **Session Enrichment**: Enable joining distinct events into sessions
- **Business Merging**: Merge related events where applicable

### Use Cases

- Business understanding of key concepts
- Integration with tools (Amplitude, Druid, Dr.Jekyll)
- Foundation for Gold layer aggregations
- Source for Silicon layer ML datasets
- Reverse ETL to business tools

### Key Rules

- ✅ Data Entity Tables: Cleansed business concepts (Redirect, User Complaint)
- ✅ Reference Tables: Static/slowly changing data (Partner, Carrier, Geo Entity)
- ✅ Apply enrichment and deduplication
- ✅ Source from Bronze only
- ❌ Do not create use-case-specific tables (move to Gold)
- ❌ Do not include Gold-level aggregations

### Deduplication Rules

- Configurable as columns differ by use case
- Different de-dup rules create different source of truth representations
- Document de-dup logic in table contracts
- Examples: Keep first event, keep most recent event, merge on session ID

### Domain Naming (Silver)

- **Business Concepts**: `redirect`, `booking`, `user_complaint`, `partner`, `carrier`
- **Reference Data**: `geo_entity`, `currency`, `payment_method`
- Named after business concepts, not technical terms or squads

---

## Gold Layer

### Technical Specifications

| Property | Value |
|----------|-------|
| **Definition** | Business-level aggregates and analytics-ready datasets |
| **Purpose** | Serving layer for BI, reporting, and reverse ETL use cases |
| **Primary Consumer** | BI tools, business reporting, analytics tools |
| **Data Mesh Equivalent** | Consumer/purpose-aligned domains |
| **File Format** | Databricks Delta |
| **Compression** | Databricks default: snappy |
| **Table Type** | Managed tables |
| **Retention Period** | 7 years by default (configurable per table) |
| **Update Frequency** | 24 hours / Daily |

### Characteristics

- **Fact Tables**: Data representing key business concepts with clear grain
- **Dimension Tables**: Categorizations of fact table attributes
- **Wide Tables**: Pre-joined/flattened/aggregated datasets for reporting
- **Kimball Data Modeling**: Follow dimensional modeling techniques (star/snowflake)

### Fact Tables

**Definition**: One row = one distinct entity/event with facts about that entity

**Components**:
- **Grain**: Clear definition (e.g., one row per redirect, one row per booking)
- **Facts**: One or more numeric/summative measures
- **Foreign Keys**: Links to dimension tables
- **Filters/Grouping**: Via dimension tables

**Naming**: Prefix with `f_` (e.g., `f_redirect`, `f_booking`, `f_user_complaint`)

**Data Source**: MUST read from Silver tables (and reference dimensions in Gold)

### Dimension Tables

**Definition**: Categorizations and attributes for filtering/grouping facts

**Characteristics**:
- One row per entity with multiple attributes
- Used to group and filter facts in analytics
- Static or slowly changing
- References for classification (Partner, Carrier, Airport, Hotel)

**Naming**: Prefix with `d_` (e.g., `d_partner`, `d_carrier`, `d_airport`, `d_hotel`)

**Data Source**: Read from Silver tables

### Wide Tables

**Purpose**: Pre-joined/flattened/aggregated datasets for reporting

**Use Case**: Fast query performance, easier BI tool integration

**Naming**: Context-specific (e.g., `bar_understand`, `bar_audience`, `session_metrics`)

### Valid Table Reads

| From | To | Allowed? | Reason |
|------|-----|----------|--------|
| Gold Fact | Gold Dimension | ✅ Yes | Dimensions are reference lookups |
| Gold Dimension | Silver | ✅ Yes | Source of truth lookup data |
| Gold Fact | Silver | ✅ Yes | Source of truth facts |
| Gold Fact | Gold Fact | ❌ No | Violates source of truth (use bridge tables) |
| Gold Dimension | Bronze | ⚠️ Caution | References only, validate necessity |

### Why No Fact-to-Fact Reads

Fact tables CANNOT read from other fact tables because:

1. **Violates source of truth principle**: Silver is the source of truth for facts
2. **Adds SLA time**: Fact tables are large; creates dependency delays
3. **Creates dependency management issues**: Hard to track which facts depend on which
4. **Risk of cyclic dependencies**: Can create impossible-to-resolve loops
5. **Different granularity levels cause duplication**: Aggregating different grains leads to double-counting

**Solution**: Use bridge tables to join facts at appropriate grain level.

### Domain Naming (Gold)

- **Business Concepts**: `revenue`
- **BAR Reporting**: `bar_understand`, `bar_audience`, `bar_roi`
- **Performance Metrics**: `session_metrics`, `conversion_funnel_metrics`

---

## Silicon Layer

### Technical Specifications

| Property | Value |
|----------|-------|
| **Definition** | ML model training datasets and predictions |
| **Purpose** | Data Science equivalent to Gold layer |
| **Primary Consumer** | ML model building tools |
| **Data Mesh Equivalent** | Consumer/purpose-aligned domains (DS) |
| **File Format** | Databricks Delta (exception: TensorFlow records in separate bucket) |
| **Compression** | Databricks default: snappy |
| **Table Type** | Managed tables |
| **Retention Period** | 6 months by default (configurable per table) |
| **Update Frequency** | 24 hours / Daily |

### Characteristics

- **Model Training Datasets**: Datasets prepared for ML model training
- **Model Predictions**: Results of ML model inference
- **Feature Engineering**: ML-specific transformations and derived features
- **Not a Trusted Layer**: Not open for business reports or non-ML use cases

### Use Cases

- ✅ ML model training
- ✅ Feature engineering
- ✅ Model predictions
- ✅ Model monitoring datasets
- ❌ Business reporting (recreate in Silver if needed)
- ❌ Non-ML applications

### Key Rules

- ✅ Source from Silver layer
- ✅ Feature engineering applied here
- ✅ Shorter retention (6mo) fits ML lifecycle
- ❌ Not for business BI/reporting
- ❌ If business needs cross-domain, recreate in Silver

### Domain Naming (Silicon)

- **ML Use Cases**: `ranking_model`, `recommendation_features`, `churn_prediction`
- Named after ML model purpose or feature set

### TensorFlow Records Exception

- TensorFlow records stored in separate bucket (not Delta format)
- S3 bucket policies and access managed separately
- Retention and access rules apply similarly

---

## Staging Layer (Optional)

### Technical Specifications

| Property | Value |
|----------|-------|
| **Definition** | Transient staging layer for file-based data ingestion |
| **Purpose** | Optional layer for raw file dumps from external systems |
| **File Formats** | json, csv, parquet, avro, orc, txt, BinaryFile, Databricks delta |
| **Compression** | none, uncompressed, bzip2, deflate, gzip, lz4, snappy |
| **Retention** | 30 days |
| **Update Frequency** | 5-15 minutes |

### Characteristics

- **Completely unprocessed**: Raw file dumps
- **Per-source folders**: Each source has its own folder
- **Flexibility**: Provides flexibility for future file additions
- **Staging-only**: Not a trusted layer

### Use Cases

- File drop locations before processing
- Temporary landing zone for data ingestion
- Flexibility for ad-hoc data additions

### Key Rules

- ✅ Store raw files as-is
- ✅ Each source in its own folder
- ✅ 30-day retention
- ❌ Not a data lake or trusted source
- ❌ No querying from Staging directly (move to Bronze first)

### Contact

- **Point of Contact**: Gemma Witham (for Staging layer support and retention policies)

---

## Layer Consumption Patterns

### Bronze → Silver

Bronze is consumed exclusively by data engineers:
- Rebuilding Silver datasets on transformation errors
- Replaying pipelines after failures
- Auditing source data changes

**Never**: Direct business tool consumption (go through Silver)

### Silver → Gold/Silicon

Silver is the main consumption layer for business:
- Tools: Amplitude, Druid, Dr.Jekyll, business dashboards
- Foundation for Gold aggregations and ML datasets
- Joined with references and enrichment

### Gold → BI/Analytics

Gold is consumed by BI tools and analytics:
- Tableau, Looker, other BI platforms
- Business dashboards and reports
- Analytics and insights

### Silicon → ML

Silicon consumed by ML tools:
- MLflow, model training pipelines
- Feature stores
- Model serving infrastructure

---

## Environment Isolation

Each environment (dev/prod) has separate catalogs:

- **Dev**: `dev_trusted_{bronze|silver|gold|silicon}`
- **Prod**: `prod_trusted_{bronze|silver|gold|silicon}`

**No trusted preview**: Different catalogs for each environment (not unified preview)

This prevents accidental production impacts and enables safe experimentation.
