# Unity Catalog Structure

## Catalog Naming Convention

Our Unity Catalog follows a layer-based approach where each data layer (Bronze, Silver, Gold, Silicon) has its own dedicated catalog.

### Production Environment

```
prod_trusted_bronze          # Raw data layer
  ├── raw_ad_clicks
  ├── raw_creative
  └── raw_campaigns

prod_trusted_silver          # Cleaned & validated data layer
  ├── curated_ad_clicks
  ├── curated_creative
  └── curated_campaigns

prod_trusted_gold            # Business aggregates layer
  ├── analytics_metrics
  ├── analytics_kpis
  └── analytics_reports

prod_trusted_silicon         # ML features & models layer
  ├── ml_features
  ├── ml_models
  └── ml_predictions
```

### Development Environment

```
dev_trusted_bronze           # Raw data layer (dev)
  ├── raw_ad_clicks
  ├── raw_creative
  └── raw_campaigns

dev_trusted_silver           # Cleaned & validated data layer (dev)
  ├── curated_ad_clicks
  ├── curated_creative
  └── curated_campaigns

dev_trusted_gold             # Business aggregates layer (dev)
  ├── analytics_metrics
  ├── analytics_kpis
  └── analytics_reports

dev_trusted_silicon          # ML features & models layer (dev)
  ├── ml_features
  ├── ml_models
  └── ml_predictions
```

## Layer Descriptions

### Bronze Layer Catalogs (prod_trusted_bronze / dev_trusted_bronze)
- **Purpose**: Raw data ingestion with minimal transformation
- **Data Format**: Delta Lake with schema enforcement
- **Key Features**:
  - Auto Loader for incremental ingestion
  - Schema evolution enabled
  - Audit columns (ingestion_timestamp, source_system, file_name)
  - Complete raw data history for reprocessing

### Silver Layer Catalogs (prod_trusted_silver / dev_trusted_silver)
- **Purpose**: Cleaned, validated, and conformed data
- **Data Quality**: Comprehensive quality checks with quarantine tables
- **Key Features**:
  - Data validation and standardization
  - Deduplication
  - SCD Type 2 for historical tracking
  - Business key enforcement

### Gold Layer Catalogs (prod_trusted_gold / dev_trusted_gold)
- **Purpose**: Business-ready datasets optimized for analytics
- **Access**: Primary layer for business users and BI tools
- **Key Features**:
  - Dimensional modeling (star/snowflake schemas)
  - Pre-aggregated metrics and KPIs
  - Optimized with Z-ORDER and partition pruning
  - Business-friendly naming conventions

### Silicon Layer Catalogs (prod_trusted_silicon / dev_trusted_silicon)
- **Purpose**: Machine learning features, models, and predictions
- **ML Integration**: Full MLflow integration
- **Key Features**:
  - Feature engineering and feature stores
  - ML model registry and versioning
  - Model predictions and inference results
  - Model monitoring and drift detection
  - Integration with Databricks ML features

## Access Control by Layer

```sql
-- Bronze: Data Engineers only
GRANT SELECT ON CATALOG prod_trusted_bronze TO `data_engineers`;
GRANT MODIFY ON CATALOG prod_trusted_bronze TO `data_engineers`;

-- Silver: Data Engineers (write), Data Analysts (read)
GRANT SELECT ON CATALOG prod_trusted_silver TO `data_analysts`;
GRANT MODIFY ON CATALOG prod_trusted_silver TO `data_engineers`;

-- Gold: Data Analysts and BI Users
GRANT SELECT ON CATALOG prod_trusted_gold TO `data_analysts`;
GRANT SELECT ON CATALOG prod_trusted_gold TO `bi_users`;
GRANT MODIFY ON CATALOG prod_trusted_gold TO `data_engineers`;

-- Silicon: ML Engineers and Data Scientists
GRANT SELECT ON CATALOG prod_trusted_silicon TO `ml_engineers`;
GRANT SELECT ON CATALOG prod_trusted_silicon TO `data_scientists`;
GRANT MODIFY ON CATALOG prod_trusted_silicon TO `ml_engineers`;
```

## Schema Naming Conventions

### Bronze Layer Schemas
- Prefix: `raw_`
- Example: `raw_ad_clicks`, `raw_creative`
- Contains raw, unprocessed data

### Silver Layer Schemas
- Prefix: `curated_`
- Example: `curated_ad_clicks`, `curated_creative`
- Contains cleaned and validated data

### Gold Layer Schemas
- Prefix: `analytics_`
- Example: `analytics_metrics`, `analytics_kpis`, `analytics_reports`
- Contains business-ready aggregates

### Silicon Layer Schemas
- Prefix: `ml_`
- Example: `ml_features`, `ml_models`, `ml_predictions`
- Contains ML artifacts and predictions

## Table Naming Examples

### Bronze Layer
- `prod_trusted_bronze.raw_ad_clicks.ad_clicks`
- `prod_trusted_bronze.raw_creative.creative_assets`

### Silver Layer
- `prod_trusted_silver.curated_ad_clicks.ad_clicks`
- `prod_trusted_silver.curated_creative.creative_assets`

### Gold Layer
- `prod_trusted_gold.analytics_metrics.daily_ad_performance`
- `prod_trusted_gold.analytics_kpis.customer_lifetime_value`

### Silicon Layer
- `prod_trusted_silicon.ml_features.ad_click_features`
- `prod_trusted_silicon.ml_models.click_prediction_model`
- `prod_trusted_silicon.ml_predictions.ad_click_predictions`

## Data Flow

```
[Source Systems]
       ↓
prod_trusted_bronze (Raw ingestion)
       ↓
prod_trusted_silver (Cleaning & validation)
       ↓
       ├─→ prod_trusted_gold (Business aggregates)
       │
       └─→ prod_trusted_silicon (ML features & models)
              ↓
         [Predictions back to Gold]
```

## Setup Script

To create this catalog structure, run:

```bash
./scripts/setup/create_unity_catalog.py --env prod
./scripts/setup/create_unity_catalog.py --env dev
```

## Configuration Files

Environment-specific catalog configurations are stored in:
- `config/environments/prod.yaml`
- `config/environments/dev.yaml`

Example configuration:
```yaml
catalogs:
  bronze: prod_trusted_bronze
  silver: prod_trusted_silver
  gold: prod_trusted_gold
  silicon: prod_trusted_silicon

schemas:
  bronze: ["raw_ad_clicks", "raw_creative", "raw_campaigns"]
  silver: ["curated_ad_clicks", "curated_creative", "curated_campaigns"]
  gold: ["analytics_metrics", "analytics_kpis", "analytics_reports"]
  silicon: ["ml_features", "ml_models", "ml_predictions"]
```

## Best Practices

1. **Layer Isolation**: Keep data transformations isolated within their respective catalogs
2. **Progressive Quality**: Data quality improves as it moves through layers
3. **Immutable Bronze**: Never modify bronze layer data; always reprocess from source
4. **Versioned Models**: Use MLflow model registry for all silicon layer models
5. **Access Control**: Implement least-privilege access by layer
6. **Naming Consistency**: Follow naming conventions strictly for discoverability
7. **Documentation**: Maintain table and column descriptions in Unity Catalog

## Migration from Old Structure

If you have an existing catalog structure, migrate as follows:

### Old Structure
```
prod_catalog
  ├── raw_data      → Move to prod_trusted_bronze.*
  ├── curated_data  → Move to prod_trusted_silver.*
  └── analytics     → Move to prod_trusted_gold.*
```

### Migration Steps
1. Create new layer-based catalogs
2. Use DEEP CLONE to copy tables to new catalogs
3. Update pipeline configurations
4. Switch over applications incrementally
5. Deprecate old catalogs after validation

## References

- [AGENTS.md](./AGENTS.md) - Section 3.1: Unity Catalog Governance
- [Unity Catalog Documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
- [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
