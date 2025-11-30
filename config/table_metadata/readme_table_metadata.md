# Table Metadata Configuration Guide

This document covers table metadata configuration files used in the agentic data engineer project. All configurations are validated against the JSON schema defined in `table_metadata_schema.yaml`.

## Configuration Schema

Table metadata files define business and technical properties of data tables, including descriptions, SLOs, ownership, and data governance.

### Directory Structure

```
config/table_metadata/
├── table_metadata_schema.yaml     # Schema definition
└── {data_product}/
    └── {table_name}.yaml          # Individual table metadata
```

## Example: Search Intent Table

**File:** `config/table_metadata/sexample_data_product/example_flight_search_intent.yaml`

```yaml
table:
  # Table Identification
  name: "flight_search_intent"

  # Description and Documentation
  desription_detail:
    description: >
      A search result consists of a group of itineraries generated from a users search.
      This table captures search metadata, user intent signals, and pricing information.

    # Data Granularity
    granularity: >
      One row per search_request_id, utid, pricing_option_id combination.
      Deduplication applied on [guid, utid, dt].

    # Data Technical Specification
    data_spec: "https://github.com/Skyscanner/databricks-meta-search-silver-domain/blob/main/data_specs/user_interaction_events/search_intent/flight_search_intent_data_spec.md"

    # Compliance and Contracts
    data_contract: "https://skyscanner.atlassian.net/wiki/x/AYCYSQ"

    # Pipeline Links
    dev_data_pipeline: "https://skyscanner-dev.cloud.databricks.com/pipelines/fc41d815-a696-4a34-9886-f3bbcf7ea394"
    prod_data_pipeline: "https://skyscanner-prod.cloud.databricks.com/pipelines/fc41d815-a696-4a34-9886-f3bbcf7ea394"

    # GitHub Repository
    data_product_github: "https://github.com/Skyscanner/databricks-meta-search-silver-domain"

    # Service Level Objectives (SLO)
    slo:
      type: "every_n_hours"
      timezone: "UTC"
      start: "09:00"
      interval_hours: 2

  # Metadata Tags - Business Metadata
  metadata_tags:
    data_owner: "Viserion"
    data_category: "business_analytical_data"
    data_classification: "internal"
    business_criticality: "p2"
    sox_scope: false
    ooh_support: false
    retention_period:
      unit: "years"
      value: 7

  # Data Model Tags - Technical Metadata
  data_model_tags:
    nk: "guid+utid+dt"
```

## Schema Details

### Description Details Block

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | ✓ | Detailed description of table purpose and content |
| `data_spec` | URL | ✓ | Data technical specification |
| `granularity` | string | ✓ | What constitutes a single row; level of detail |
| `data_contract` | URL | ✓ | Link to data contract documentation |
| `dev_data_pipeline` | URL | ✓ | Link to development Databricks pipeline |
| `prod_data_pipeline` | URL | ✓ | Link to production Databricks pipeline (or "TBD") |
| `data_product_github` | URL | ✓ | Link to GitHub repository |

### SLO Configuration

The SLO (Service Level Objective) block defines how frequently the table is updated:

```yaml
slo:
  type: "every_n_hours"      # Schedule type
  timezone: "UTC"             # Timezone for scheduling
  start: "09:00"              # Start time (HH:MM)
  interval_hours: 2           # Repeat every N hours
```

| Type | Required Fields | Purpose |
|------|-----------------|---------|
| `every_n_hours` | `start`, `interval_hours`, `timezone` | Run at regular intervals (e.g., every 2 hours starting at 09:00) |
| `daily` | `times`, `timezone` | Run at specific times daily |
| `custom` | `times`, `timezone` | Run at custom specified times |

### Metadata Tags

**Business Metadata:**

| Tag | Type | Values | Description |
|-----|------|--------|-------------|
| `data_owner` | string | Any team name | Team responsible for this table |
| `data_category` | string | `business_analytical_data`, `operational_data`, `pii`, `other` | Data type classification |
| `data_classification` | string | `internal`, `confidential` | Sensitivity/security level |
| `business_criticality` | string | `p0`, `p1`, `p2`, `p3` | Priority: p0=critical, p3=low |
| `sox_scope` | boolean | `true` / `false` | Is this in SOX compliance scope? |
| `ooh_support` | boolean | `true` / `false` | Does this require out-of-hours support? |

**Retention Period:**

```yaml
retention_period:
  unit: "years"    # Options: "days", "months", "years"
  value: 7         # Numeric value
```

### Data Model Tags

| Tag | Type | Example | Description |
|-----|------|---------|-------------|
| `nk` | string | `guid+utid+dt` | Natural key (columns that uniquely identify a row) |
| `scd_type` | string | `type2` | Slowly Changing Dimension type (type1, type2, type3, hybrid) |
| `bk` | string | `search_request_id` | Business key |

## Validation

### Validate YAML Syntax

```bash
python3 << 'EOF'
import yaml

with open('config/table_metadata/search_intent.yaml', 'r') as f:
    data = yaml.safe_load(f)
    print("✓ YAML syntax is valid!")
EOF
```

### Validate Against Schema

```bash
python3 << 'EOF'
import yaml
from jsonschema import validate, ValidationError

with open('config/table_metadata/table_metadata_schema.yaml', 'r') as f:
    schema = yaml.safe_load(f)

with open('config/table_metadata/search_intent.yaml', 'r') as f:
    data = yaml.safe_load(f)

try:
    validate(instance=data, schema=schema)
    print("✓ Configuration is valid against schema!")
except ValidationError as e:
    print(f"✗ Validation failed: {e.message}")
EOF
```

## Best Practices

1. **Granularity:** Be specific about what constitutes a row in your table
2. **Natural Key:** Clearly identify which columns form the unique identifier
3. **Retention Period:** Balance storage costs with business requirements
4. **Data Contracts:** Always link to authoritative documentation
5. **SLO Configuration:** Choose the schedule type that matches your update frequency
6. **Criticality:** Set p-level based on business impact and dependencies
7. **Ownership:** Clearly assign data ownership for accountability

## Common Issues

### Issue: Missing Required SLO Fields

**Solution:** Ensure all required fields are present based on SLO type:

```yaml
# For every_n_hours, include:
slo:
  type: "every_n_hours"
  start: "09:00"
  interval_hours: 2
  timezone: "UTC"

# For daily, include:
slo:
  type: "daily"
  times:
    - "06:00"
    - "18:00"
  timezone: "UTC"

# For custom, include:
slo:
  type: "custom"
  times:
    - "09:00"
    - "12:00"
    - "15:00"
  timezone: "UTC"
```

### Issue: Invalid Retention Period

**Solution:** Use valid combinations:

```yaml
# ✅ Valid examples
retention_period:
  unit: "years"
  value: 7

retention_period:
  unit: "months"
  value: 12

retention_period:
  unit: "days"
  value: 90
```
