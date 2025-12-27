# Data Naming Agent

## Overview

The Data Naming Agent provides naming recommendations for tables, columns, schemas, and catalogs following medallion architecture and Unity Catalog naming conventions with British English standards.

## Agent Details

- **Name**: `data-naming-agent`
- **Model**: Haiku
- **Skills**: None

## Capabilities

- Provide naming recommendations for catalogs, schemas, tables, and columns
- Apply medallion architecture naming patterns (Bronze/Silver/Gold/Silicon)
- Follow British English and snake_case conventions
- Generate Unity Catalog qualified names (environment_trusted_layer.schema.table)
- Apply table type prefixes (d_, f_, w_, v_, log_, tmp_, intermediate_, map_)
- Name columns appropriately (IDs, FKs, dates, booleans, measurements)
- Ensure singular naming (except for arrays/complex types)
- Validate naming consistency across layers

## When to Use

Use this agent when you need to:

- Name new tables, columns, schemas, or catalogs
- Ensure compliance with organizational naming conventions
- Determine appropriate prefixes for fact, dimension, or wide tables
- Name foreign key columns in gold layer facts
- Structure date/time columns with correct suffixes
- Apply proper naming for boolean flags, enumerations, and measurements
- Validate existing names against conventions

## Usage Examples

### Example 1: Name a Silver Table

```
User: "What should I name a table that stores cleaned session data in the silver layer?"

Agent: "For cleaned session data in Silver, use: `session`
- Pattern: <business_entity> (singular)
- Full path: prod_trusted_silver.session.session"
```

### Example 2: Name Columns

```
User: "How should I name the timestamp and user ID columns in my event table?"

Agent: "Use these column names:
- User ID: `user_id` (pattern: <entity>_id)
- Timestamp: `event_utc_timestamp` (pattern: <context>_utc_timestamp)"
```

### Example 3: Name Gold Dimension

```
User: "I'm creating a dimension table for markets. What's the correct name?"

Agent: "For a Gold dimension: `d_market`
- Pattern: d_<name>
- Full path: prod_trusted_gold.reference.d_market"
```

### Example 4: Name Catalog

```
User: "What naming pattern should I use for the production gold layer catalog?"

Agent: "`prod_trusted_gold`
- Pattern: <environment>_trusted_<layer>"
```

## Naming Conventions

### Universal Rules

1. **British English**: "utilisation" not "utilization"
2. **snake_case**: All lowercase with underscores
3. **Meaningful**: Self-sufficient names
4. **Singular**: Not plural (except arrays)

### Catalogs

**Pattern**: `<environment>_trusted_<layer>` or `<environment>_silicon`

| Layer | Dev | QA | Prod |
|-------|-----|-----|------|
| Bronze | dev_trusted_bronze | qa_trusted_bronze | prod_trusted_bronze |
| Silver | dev_trusted_silver | qa_trusted_silver | prod_trusted_silver |
| Gold | dev_trusted_gold | qa_trusted_gold | prod_trusted_gold |
| Silicon | dev_silicon | qa_silicon | prod_silicon |

### Schemas

**Pattern**: `<data_domain_name>` (singular)

Examples:
- ✅ `booking` (singular)
- ✅ `advertising`
- ✅ `fivetran_salesforce`
- ❌ `bookings` (plural)

**Bronze Layer Patterns:**
- 1st Party Single: `<source>`
- 1st Party Multiple: `<source>_<use_case>`
- 3rd Party Custom: `<source_name>`
- Fivetran: `fivetran_<connector>`
- Lakeflow Connect: `lfc_<connector>`

### Tables

**General Rules:**
1. Singular names: `session` not `sessions`
2. No redundant words (details, info, information)
3. Vertical-specific: `<vertical>_<name>`

**Table Type Prefixes:**

| Type | Pattern | Layer | Example |
|------|---------|-------|---------|
| Dimension | `d_<name>` | Gold | `d_market` |
| Fact | `f_<name>` | Gold | `f_daily_revenue` |
| Wide | `w_<name>` | Gold | `w_booking_funnel` |
| View | `v_<name>` | Any | `v_customer` |
| Log | `log_<name>` | Any | `log_storage` |
| Temporary | `tmp_<name>` | Any | `tmp_redirects` |
| Intermediate | `intermediate_<name>` | Silver/Gold | `intermediate_redirect` |
| Mapping | `map_<table1>_<table2>` | Any | `map_view_session` |

**By Layer:**
- Bronze: `<source_entity>`
- Silver: `<business_entity>`
- Gold: `<prefix>_<business_aggregate>`

### Columns

**Primary Key / ID:**
```
<entity>_id
```
Examples: `session_id`, `booking_id`

**Foreign Key:**
- Bronze/Silver/Silicon: `<entity>_id`
- Gold Facts: `fk_<dimension>`

**Date/Time:**

| Type | Pattern | Data Type | Example |
|------|---------|-----------|---------|
| Date (partition) | `dt` or `<context>_dt` | DateType | `dt`, `billing_dt` |
| UTC Timestamp | `<context>_utc_timestamp` | TimestampType | `server_utc_timestamp` |
| Local Timestamp | `<context>_timestamp_local` | TimestampType | `client_timestamp_local` |
| Timezone | `<context>_timestamp_timezone` | StringType | `client_timestamp_timezone` |

**Boolean Flags:**
```
is_<state>
```
Examples: `is_received`, `is_current`, `is_active`

**Enumerations:**
```
UPPER_CASE_WITH_UNDERSCORES
```
Example: `vertical`: `[FLIGHT, HOTEL, CAR_HIRE]`

For Gold reporting, add readable version:
```
<field>_reporting_name
```

**Numeric/Measurement:**
```
<measurement>_<unit>
```
Examples: `duration_min`, `price_usd`, `distance_km`

**Count Columns:**
```
<entity>_count
```
Examples: `session_count`, `booking_count`

**Aggregation:**
```
<aggregation>_<measure>
```
Examples: `total_revenue`, `avg_session_duration`

### Metadata Columns

Standard columns for all tables:
```python
dt: DateType                        # Partition - date
platform: StringType                # Partition - platform
ingestion_timestamp: TimestampType  # When ingested
processing_timestamp: TimestampType # When transformed
```

## Complete Examples

### Gold Fact Table

```
Catalog: prod_trusted_gold
Schema: booking
Table: f_daily_booking_revenue

Full Name: prod_trusted_gold.booking.f_daily_booking_revenue

Columns:
- booking_id: StringType
- fk_market: StringType
- fk_vertical: StringType
- dt: DateType
- platform: StringType
- total_revenue_usd: DoubleType
- booking_count: IntegerType
- is_cancelled: BooleanType
- status: StringType  # CONFIRMED, CANCELLED
- ingestion_timestamp: TimestampType
```

### Silver Table

```
Catalog: prod_trusted_silver
Schema: session
Table: user_session

Full Name: prod_trusted_silver.session.user_session

Columns:
- session_id: StringType
- user_id: StringType
- dt: DateType
- platform: StringType
- start_timestamp_utc: TimestampType
- end_timestamp_utc: TimestampType
- duration_min: IntegerType
- is_timeout: BooleanType
- event_ids: ArrayType(StringType)  # Plural for array
- ingestion_timestamp: TimestampType
```

## Quick Reference

| Element | Pattern | Example |
|---------|---------|---------|
| Catalog | `<env>_trusted_<layer>` | `prod_trusted_silver` |
| Schema | `<domain>` (singular) | `booking` |
| Table (Silver) | `<entity>` (singular) | `session` |
| Table (Gold Fact) | `f_<name>` | `f_daily_revenue` |
| Table (Gold Dim) | `d_<name>` | `d_market` |
| ID Column | `<entity>_id` | `session_id` |
| FK Column | `fk_<dimension>` | `fk_market` |
| Date | `dt` | `dt` |
| Boolean | `is_<state>` | `is_active` |
| Array | `<entity>_plural` | `event_ids` |

## Success Criteria

✅ British English spelling
✅ snake_case format
✅ Singular names (except arrays)
✅ Appropriate prefix for type
✅ Layer-appropriate pattern
✅ Environment prefix correct
✅ Self-documenting
✅ Follows conventions
✅ No redundant words
✅ Meaningful abbreviations only

## Output Format

1. **Recommended Name**: Exact name to use
2. **Pattern Used**: Convention applied
3. **Rationale**: Why chosen
4. **Full Path**: Complete Unity Catalog path
5. **Alternative Names**: Other valid options
6. **Column Examples**: Sample columns if table

## When to Ask for Clarification

- Layer placement unclear
- Purpose/entity type ambiguous
- Data type not specified
- Multiple naming options exist
- Business context missing
- Source system naming unclear

## Related Agents

- **Medallion Architecture Agent**: Understand layers
- **Data Contract Agent**: Define contracts
- **Silver Data Modeling Agent**: Design entities
- **Dimensional Modeling Agent**: Design schemas

## Tips

- Always use singular names
- Follow British English
- Be specific and descriptive
- Use recognized abbreviations only
- Avoid redundant words
- Prefix by table type in Gold
- Use `dt` for date partitions
- Prefix FKs with `fk_` in Gold

---

**Last Updated**: 2025-12-26
