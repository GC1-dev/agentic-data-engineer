---
skill_name: data-contract-formatter-skill
description: |
  Format, validate, and ensure compliance of data contracts with ODCS v3.1.0 + Skyscanner Extensions.
  Performs deterministic validation checks, YAML formatting, and generates compliance reports.
version: 1.0.0
author: Skyscanner Data Engineering
tags:
  - data-contracts
  - validation
  - formatting
  - odcs
  - yaml
  - compliance
---

# Data Contract Formatter Skill

Validate and format data contracts to ensure compliance with ODCS v3.1.0 + Skyscanner Extensions standards.

## What This Skill Does

This skill performs automated validation and formatting operations on data contract YAML files:

- **Validates** data contract structure against ODCS v3.1.0 specification
- **Formats** YAML with consistent style and proper indentation
- **Checks** required fields, sections, and cross-references
- **Validates** transform logic and source object references
- **Verifies** foreign key relationships and key definitions
- **Ensures** proper semantic types and physical types alignment
- **Generates** detailed validation reports with actionable recommendations

## When to Use This Skill

Use this skill when you need to:

- Format and validate new data contracts before committing
- Ensure compliance with ODCS v3.1.0 + Skyscanner Extensions standards
- Standardize existing data contracts to match format requirements
- Validate transform logic references to source objects
- Check consistency between schema properties and their definitions
- Verify foreign key references are valid
- Ensure partition columns are properly defined
- Validate enum values and constraints
- Review data contract quality before release
- Integrate validation into CI/CD pipelines

## How to Invoke

### Direct Invocation

```bash
/data-contract-formatter-skill
```

You can also reference it as:
```bash
/format-data-contract
```

### Automatic Detection

Claude will suggest this skill when you:
- Say "validate the data contract"
- Request "format data contract YAML"
- Mention "check ODCS compliance"
- Ask to "validate transform logic"
- Need to "check contract structure"

## Capabilities

### Validation Operations

1. **Structure Validation**
   - Top-level required fields (kind, apiVersion, id, name, etc.)
   - Section completeness (team, support, schema)
   - Version format and status values
   - URN pattern compliance

2. **Schema Validation**
   - Required schema fields
   - Property completeness (name, title, type, physicalType, description)
   - Type consistency (logical type matches physical type)
   - Semantic type validity
   - Enum value validation

3. **Keys Validation**
   - Primary keys defined and valid
   - Primary key columns exist in properties
   - Surrogate keys have generation logic
   - Foreign key references exist
   - Foreign key columns valid

4. **Transform Logic Validation**
   - Source object references are valid
   - Transform logic has required fields
   - Library functions properly referenced
   - Derived field dependencies exist

5. **Partition Validation**
   - Partition columns exist in properties
   - Partition columns have appropriate tags
   - Partition type and granularity valid

### Formatting Operations

1. **YAML Formatting**
   - 2-space indentation
   - Block style for multi-line strings
   - Consistent section ordering
   - Proper property ordering
   - Comment formatting standards

2. **Naming Convention Enforcement**
   - Table names: snake_case
   - Column names: snake_case
   - URN pattern compliance
   - No leading/trailing underscores

## Examples

### Example 1: Validate New Data Contract

**User**: "Validate the data contract at contracts/session_events.yaml"

**Skill Action**:
1. Reads the YAML file
2. Runs all validation checks
3. Generates validation report

**Output**:
```
DATA CONTRACT VALIDATION REPORT
================================

Contract: session_events
Version: 1.0.0
Validation Date: 2026-01-24

SUMMARY
-------
✅ Passed: 45 checks
❌ Failed: 3 checks
⚠️ Warnings: 2 issues

CRITICAL ISSUES
---------------
1. Primary key 'session_id' missing primary=true flag (line 156)
2. Foreign key 'fk_user' references non-existent table 'user_dim' (line 203)
3. Property 'event_timestamp' missing required field 'physicalType' (line 178)

WARNINGS
--------
1. Transform description for 'session_duration' is too short (line 245)
2. Partition column 'event_date' missing 'partition' tag (line 189)

RECOMMENDATIONS
---------------
1. Add primary=true, required=true, nullable=false to session_id property
2. Add user_dim to transformSourceObjects or correct foreign key reference
3. Add physicalType: TimestampType to event_timestamp property
4. Expand transform description with source mapping and edge case handling
5. Add 'partition' tag to event_date property tags list

FIX COMMANDS
------------
# Fix primary key flags
Edit line 156 to add: primary=true, required=true, nullable=false

# Add missing source object
Edit line 127 to add user_dim to transformSourceObjects

# Add missing physicalType
Edit line 178 to add: physicalType: TimestampType
```

### Example 2: Format Existing Contract

**User**: "Format the data contract at contracts/booking_events.yaml"

**Skill Action**:
1. Reads the YAML file
2. Applies formatting rules
3. Writes formatted output

**Output**:
```
FORMATTING COMPLETE
===================

File: contracts/booking_events.yaml

Changes Applied:
- Standardized indentation (2 spaces)
- Converted multi-line strings to block style
- Reordered properties to follow standard sequence
- Added consistent comment headers
- Formatted property field ordering
- Applied snake_case naming conventions

Before: 423 lines
After: 438 lines (improved readability)

The contract is now consistently formatted and ready to commit.
```

### Example 3: Batch Validation

**User**: "Validate all data contracts in contracts/ directory"

**Skill Action**:
1. Finds all YAML files in contracts/
2. Validates each contract
3. Generates summary report

**Output**:
```
BATCH VALIDATION REPORT
=======================

Validated: 12 contracts
Passed: 9 contracts
Failed: 3 contracts

PASSED CONTRACTS
----------------
✅ session_events.yaml
✅ user_profiles.yaml
✅ booking_transactions.yaml
✅ flight_searches.yaml
✅ payment_methods.yaml
✅ user_sessions.yaml
✅ search_filters.yaml
✅ destination_info.yaml
✅ price_alerts.yaml

FAILED CONTRACTS
----------------
❌ booking_events.yaml (5 critical issues)
❌ user_journey.yaml (2 critical issues)
❌ session_analytics.yaml (3 critical issues)

See individual reports for details on each failure.
```

---

## ODCS v3.1.0 + Skyscanner Extensions Reference

### Core ODCS v3.1.0 Structure

```yaml
kind: DataContract
apiVersion: v3.1.0
id: urn:datacontract:organization:layer:domain:table_name

# Required top-level sections
name: table_name
dataProduct: Product Name
version: 1.0.0
status: active|draft|deprecated
description:
  purpose: |
    Business purpose and use case

team:
  members:
    - username: Team Name
      role: owner|steward|consumer
      description: Team responsibility
      dateIn: "YYYY-MM-DD"

support:
  - channel: '#team-channel'
    tool: slack|jira|confluence
    scope: data product|technical
    url: https://...

schema:
  - name: table_name
    businessName: Human Readable Name
    physicalName: table_name
    physicalType: table|view|materialized_view|streaming_table
    dataGranularityDescription: One row per...

    tags: [tag1, tag2]

    authoritativeDefinitions:
      - url: https://...
        type: Data Product Github|Data Pipeline|Unity Catalog link

    skyscannerCustomExtensions:
      contractLastUpdated: "YYYY-MM-DD"
      updateCadence: scheduled|real_time|ad_hoc
      category: business_analytical_data|operational_data|reference_data
      classification: internal|confidential|public
      businessCriticality: p0|p1|p2|p3
      retentionPeriod: P7Y|P3Y|P1Y
      soxScope: true|false
      oohSupport: true|false

      knownIssues:
        - id: ISSUE_ID
          description: Issue description
          impact: Business impact
          workaround: Recommended workaround

      businessNotes:
        - "Note about data interpretation or usage"

    transformSourceObjects:
      - name: source_table_name
        filter: "WHERE clause if applicable"

    keys:
      primary:
        - name: column_name
          description: Key description
      natural:
        - name: business_key_column
          description: Business key description
      surrogate:
        - name: surrogate_key_column
          logic: "generate_id(col1, col2) from library"
          description: Surrogate key generation logic

    foreignKeys:
      - name: fk_reference_name
        columns: [column_name]
        references:
          transformSourceObjects: target_table
          columns: [target_column]
        description: Relationship description

    partitions:
      - column: partition_column
        type: date|string|int
        granularity: day|month|year

    properties:
      - name: column_name
        title: Human Readable Title
        type: string|long|integer|timestamp|date|boolean|struct|array
        physicalType: StringType|LongType|IntegerType|TimestampType|DateType|BooleanType|StructType|ArrayType
        required: true|false
        unique: true|false
        primary: true|false
        nullable: true|false
        semanticType: identifier|surrogate_key|natural_key|event_time|processing_time|dimension|measure|attribute|currency|geo_country|geo_city
        classification: internal|confidential|public
        pii: true|false
        piiType: direct|indirect
        description: |
          Detailed column description including business meaning,
          usage notes, and special handling requirements.

        enum: [VALUE1, VALUE2, VALUE3]

        transform:
          logic: "Detailed transform logic with function references"
          description: |
            Human-readable explanation of transformation including:
            - Source field mappings
            - Library functions used with package references
            - Special handling for edge cases
            - Nullification rules

        transformSourceObjects:
          - source_table_1
          - source_table_2
          - derived_field_dependency

        tags:
          - tag1
          - PK
          - partition
```

## Validation Rules

### Section-Level Validation

**Top-Level Required Fields:**
- ✅ `kind: DataContract`
- ✅ `apiVersion: v3.1.0`
- ✅ `id:` must follow URN pattern `urn:datacontract:org:layer:domain:table`
- ✅ `name:` table name
- ✅ `dataProduct:` product name
- ✅ `version:` semantic version (X.Y.Z)
- ✅ `status:` one of [active, draft, deprecated]
- ✅ `description.purpose:` multi-line business description

**Team Section:**
- ✅ At least one team member with role 'owner'
- ✅ Valid `dateIn` format: "YYYY-MM-DD"
- ✅ Valid roles: [owner, steward, consumer]

**Support Section:**
- ✅ At least one support channel
- ✅ Valid tools: [slack, jira, confluence, email]
- ✅ Valid URLs

**Schema Section:**
- ✅ `name:` matches top-level name
- ✅ `physicalName:` matches table name
- ✅ `physicalType:` one of [table, view, materialized_view, streaming_table]
- ✅ `dataGranularityDescription:` present and descriptive

**Skyscanner Custom Extensions:**
- ✅ `contractLastUpdated:` valid date format
- ✅ `updateCadence:` one of [scheduled, real_time, ad_hoc]
- ✅ `category:` one of [business_analytical_data, operational_data, reference_data]
- ✅ `classification:` one of [internal, confidential, public]
- ✅ `businessCriticality:` one of [p0, p1, p2, p3]
- ✅ `retentionPeriod:` ISO 8601 duration (e.g., P7Y, P3Y)
- ✅ `soxScope:` boolean
- ✅ `oohSupport:` boolean

### Keys Validation

**Primary Keys:**
- At least one primary key defined
- Primary key columns exist in properties
- Primary key properties have `primary=true`
- Primary key properties have `required=true`
- Primary key properties have `nullable=false`

**Surrogate Keys:**
- Surrogate key must have logic defined
- Logic must reference library function

**Foreign Keys:**
- Referenced tables exist in transformSourceObjects
- Foreign key columns exist in properties
- Referenced columns are valid

### Properties Validation

**Required Fields per Property:**
- `name`, `title`, `type`, `physicalType`, `description`

**Type Consistency:**
| Logical Type | Physical Type |
|--------------|---------------|
| string | StringType |
| long | LongType |
| integer | IntegerType |
| timestamp | TimestampType |
| date | DateType |
| boolean | BooleanType |
| struct | StructType |
| array | ArrayType |
| decimal | DecimalType |
| double | DoubleType |
| float | FloatType |

**Valid Semantic Types:**
- identifier, surrogate_key, natural_key, foreign_key
- event_time, processing_time
- dimension, measure, attribute
- currency, geo_country, geo_city, geo_region

**Enum Validation:**
- Must be a list
- Cannot be empty
- No duplicates

### Transform Logic Validation

**Source Object References:**
- All referenced sources must exist in `transformSourceObjects`
- Derived field dependencies must exist in properties
- No dangling references

**Transform Logic Format:**
- Must have `logic` and `description` fields
- Logic cannot be empty
- Description must be descriptive (>20 chars)
- Library functions must reference package

### Partition Validation

- Partition columns must exist in properties
- Partition columns should have 'partition' tag
- Partition type and granularity must be valid

## Formatting Rules

### YAML Style Guidelines

1. **Indentation**: 2 spaces (not tabs)
2. **Multi-line strings**: Block style with `|`
3. **Comment formatting**:
   ```yaml
   # =============================================================================
   # SECTION HEADER
   # =============================================================================

   # -----------------------------------------------------------------------------
   # SUBSECTION
   # -----------------------------------------------------------------------------
   ```

4. **Property ordering**:
   ```yaml
   properties:
     - name:              # Always first
       title:             # Human-readable name
       type:              # Logical type
       physicalType:      # Physical type
       required:          # Nullability
       unique:            # Uniqueness constraint
       primary:           # Primary key flag
       nullable:          # Null allowance
       semanticType:      # Semantic category
       classification:    # Data classification
       pii:               # PII flag
       piiType:           # PII type
       description: |     # Business description
       enum:              # Valid values
       transform:         # Transform logic
       transformSourceObjects:  # Source dependencies
       tags:              # Classification tags
   ```

5. **Schema section ordering**:
   - name, businessName, physicalName, physicalType
   - dataGranularityDescription, tags
   - authoritativeDefinitions, skyscannerCustomExtensions
   - transformSourceObjects
   - keys, foreignKeys, partitions
   - properties

### Naming Conventions

**Table names**: snake_case, lowercase
**Column names**: snake_case, lowercase, no leading/trailing underscores
**ID field**: URN pattern `urn:datacontract:[org]:[layer]:[domain]:[table]`

## Validation Algorithms

### Structure Validation

```python
def validate_structure(contract):
    """Validate top-level structure and required fields."""
    errors = []

    required = ['kind', 'apiVersion', 'id', 'name', 'dataProduct',
                'version', 'status', 'description']
    for field in required:
        if field not in contract:
            errors.append(f"Missing required field: {field}")

    if contract.get('kind') != 'DataContract':
        errors.append(f"kind must be 'DataContract'")

    if contract.get('apiVersion') != 'v3.1.0':
        errors.append(f"apiVersion must be 'v3.1.0'")

    return errors
```

### Schema Validation

```python
def validate_schema(schema):
    """Validate schema section completeness and consistency."""
    errors = []

    required = ['name', 'physicalName', 'physicalType', 'properties']
    for field in required:
        if field not in schema:
            errors.append(f"Schema missing required field: {field}")

    if 'properties' in schema:
        for prop in schema['properties']:
            prop_errors = validate_property(prop)
            errors.extend(prop_errors)

    return errors
```

### Keys Validation

```python
def validate_keys_and_references(schema):
    """Validate keys, foreign keys, and cross-references."""
    errors = []

    property_names = {p['name'] for p in schema.get('properties', [])}
    source_objects = {obj['name'] for obj in schema.get('transformSourceObjects', [])}

    # Validate primary keys
    if 'keys' in schema and 'primary' in schema['keys']:
        for pk in schema['keys']['primary']:
            if pk['name'] not in property_names:
                errors.append(f"Primary key '{pk['name']}' not found in properties")

    # Validate foreign keys
    if 'foreignKeys' in schema:
        for fk in schema['foreignKeys']:
            for col in fk['columns']:
                if col not in property_names:
                    errors.append(f"FK '{fk['name']}' references non-existent column '{col}'")

            ref_table = fk['references']['transformSourceObjects']
            if ref_table not in source_objects:
                if not (ref_table.startswith('gold_') or ref_table.startswith('silver_')):
                    errors.append(f"FK '{fk['name']}' references unknown table '{ref_table}'")

    return errors
```

### YAML Formatting

```python
def format_yaml(contract):
    """Format YAML with consistent style."""
    import yaml
    from io import StringIO

    def str_representer(dumper, data):
        if '\n' in data:
            return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
        return dumper.represent_scalar('tag:yaml.org,2002:str', data)

    yaml.add_representer(str, str_representer)

    output = StringIO()
    yaml.dump(
        contract,
        output,
        default_flow_style=False,
        sort_keys=False,
        indent=2,
        width=120,
        allow_unicode=True
    )

    return output.getvalue()
```

## Best Practices

### ✅ DO

- Validate contracts before committing to version control
- Fix critical issues before addressing warnings
- Format consistently across all contracts
- Document transform logic with library references
- Validate cross-references and dependencies
- Use semantic types for all columns
- Tag primary keys, partitions, and classifications appropriately

### ❌ DON'T

- Skip validation for "small" changes
- Ignore warnings (address or document why they're acceptable)
- Commit malformed YAML
- Use inconsistent indentation or formatting
- Leave dangling references to non-existent sources
- Omit required fields
- Use incorrect type mappings

## Integration with CI/CD

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

for file in $(git diff --cached --name-only | grep 'contracts/.*\.yaml$'); do
    echo "Validating $file..."
    # Invoke skill via Claude Code CLI or validation script
    if ! validate_contract "$file"; then
        echo "❌ Validation failed for $file"
        exit 1
    fi
done

echo "✅ All contracts validated successfully"
```

### GitHub Actions

```yaml
name: Validate Data Contracts

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate contracts
        run: |
          for contract in contracts/*.yaml; do
            # Run validation
            python scripts/validate_contract.py "$contract"
          done
```

## Validation Report Format

```markdown
# Data Contract Validation Report

## Contract: {contract_name}
**Version**: {version}
**Validation Date**: {date}

## Summary
- ✅ Passed: {passed_count} checks
- ❌ Failed: {failed_count} checks
- ⚠️ Warnings: {warning_count} issues

## Critical Issues
{blocking issues that must be fixed}

## Warnings
{non-blocking issues that should be addressed}

## Recommendations
{best practice suggestions}

## Details

### Structure Validation
- [✅/❌] Top-level fields present
- [✅/❌] Required sections complete
- [✅/❌] Version format valid

### Schema Validation
- [✅/❌] All properties have required fields
- [✅/❌] Type mappings consistent
- [✅/❌] Semantic types valid

### Keys Validation
- [✅/❌] Primary keys defined and valid
- [✅/❌] Foreign key references valid
- [✅/❌] Surrogate keys have generation logic

### Transform Validation
- [✅/❌] All source objects exist
- [✅/❌] Transform logic documented
- [✅/❌] Library functions properly referenced

### Formatting
- [✅/❌] YAML syntax valid
- [✅/❌] Consistent indentation
- [✅/❌] Naming conventions followed
```

## Success Criteria

Validation is successful when:

- ✅ All critical structure checks pass
- ✅ YAML is well-formed and consistently formatted
- ✅ All keys are properly defined and referenced
- ✅ Transform logic references valid sources
- ✅ Foreign key relationships are valid
- ✅ Semantic types align with column usage
- ✅ Partition columns are properly tagged
- ✅ No dangling references to unknown sources
- ✅ Follows ODCS v3.1.0 + Skyscanner Extensions standards

## Related Skills

- `json-formatter-skill`: For formatting JSON data
- `pyproject-formatter-skill`: For formatting Python project configs
- `makefile-formatter-skill`: For formatting Makefiles

## Version History

- **1.0.0** (2026-01-24): Initial release
  - ODCS v3.1.0 validation
  - Skyscanner Extensions support
  - YAML formatting
  - Validation reporting
