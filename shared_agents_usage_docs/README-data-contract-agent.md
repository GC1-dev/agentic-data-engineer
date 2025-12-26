# Data Contract Agent

## Overview

The Data Contract Agent generates, validates, and enforces data contracts for tables, ensuring data quality and governance across the data platform. It creates formal agreements between data producers and consumers.

## Agent Details

- **Name**: `data-contract-agent`
- **Model**: Sonnet
- **Skills**: json-formatter-skill, mermaid-diagrams-skill

## Capabilities

- Generate data contract definitions from existing table schemas
- Validate table schemas against data contract specifications
- Enforce contract requirements (required fields, types, constraints)
- Version control contract changes with backward compatibility checks
- Document contract expectations for data consumers
- Validate SLA compliance and data freshness
- Generate contract validation tests
- Create contract documentation for stakeholders
- Monitor contract compliance over time

## When to Use

Use this agent when you need to:

- Generate data contracts for new or existing tables
- Validate that table schemas match contract specifications
- Enforce data quality requirements via contracts
- Document data expectations for consumers
- Version and manage contract evolution
- Validate SLA compliance
- Create contract-based quality tests
- Review contract changes for breaking impacts
- Set up contract monitoring and alerting

## Usage Examples

### Example 1: Generate Contract

```
User: "Generate a data contract for the prod_trusted_silver.session.user_session table"

Agent: "I'll generate a comprehensive data contract including schema, quality rules, and SLAs."
```

### Example 2: Validate Contract

```
User: "Validate that the enriched_sessions table meets its data contract requirements"

Agent: "I'll validate schema compliance, quality rules, and SLA adherence."
```

### Example 3: Check Breaking Changes

```
User: "I need to add a new column to the user_events contract. Check for breaking changes."

Agent: "I'll analyze the contract change and validate backward compatibility."
```

### Example 4: Document Contract

```
User: "Document the data contract expectations for the booking_metrics table"

Agent: "I'll generate comprehensive documentation for consumers."
```

## Data Contract Structure

A complete data contract includes:

```yaml
contract:
  id: "prod_trusted_silver.session.user_session"
  version: "1.2.0"
  status: "active"  # draft, active, deprecated

  metadata:
    name: "User Session Events"
    description: "Cleaned and validated user session data"
    owner: "data-platform-team"
    domain: "session"
    layer: "silver"
    tags: ["pii", "core", "session"]

  schema:
    table_name: "prod_trusted_silver.session.user_session"
    format: "delta"

    columns:
      - name: "session_id"
        type: "STRING"
        required: true
        unique: true
        description: "Unique session identifier"

      - name: "platform"
        type: "STRING"
        required: true
        constraints:
          - type: "enum"
            values: ["web", "ios", "android", "desktop"]

    partition_columns:
      - "dt"
      - "platform"

  quality:
    completeness:
      - column: "session_id"
        threshold: 100  # 100% non-null

    uniqueness:
      - columns: ["session_id"]
        threshold: 100

    validity:
      - rule: "session_duration_seconds >= 0"
        threshold: 100

    freshness:
      - column: "dt"
        max_age_hours: 24

  sla:
    availability: 99.9
    latency: "24 hours"
    retention: "7 years"
    update_frequency: "daily"

  consumers:
    - name: "gold_session_metrics"
      type: "pipeline"
      criticality: "high"
```

## Approach

### 1. Generate Contracts

**From Existing Table:**
1. Extract schema from Unity Catalog
2. Analyze data to infer requirements
3. Generate contract YAML

**From Requirements:**
1. Gather business requirements
2. Design schema
3. Define quality rules

### 2. Validate Contracts

**Schema Validation:**
- Check column existence
- Verify type compatibility
- Validate constraints (enums, ranges)

**Quality Validation:**
- Completeness checks
- Uniqueness checks
- Validity checks

**SLA Validation:**
- Freshness checks
- Availability monitoring

### 3. Version Control

**Semantic Versioning:**
- MAJOR: Breaking changes
- MINOR: Backward-compatible additions
- PATCH: Bug fixes, documentation

**Breaking Change Detection:**
- Removed columns
- Type changes
- New required columns

### 4. Generate Tests

```python
def test_schema_matches_contract(spark, contract):
    """Validate table schema matches contract."""
    table_name = contract['contract']['schema']['table_name']
    table_df = spark.table(table_name)

    contract_cols = [c['name'] for c in contract['contract']['schema']['columns']]
    actual_cols = table_df.columns

    assert set(contract_cols) == set(actual_cols)
```

### 5. Generate Documentation

Create consumer-facing documentation with:
- Schema details
- Quality guarantees
- SLA commitments
- Usage examples
- Changelog

## Decision Framework

### When to Create Contracts

✅ **Create for:**
- Silver tables consumed downstream
- All Gold layer tables
- Tables shared across teams
- Tables with SLA requirements
- Critical business data

⚠️ **Consider for:**
- Bronze tables with external consumers
- Intermediate processing tables

❌ **Skip for:**
- Temporary tables
- Internal processing artifacts
- Ad-hoc analysis tables

## Best Practices

1. **Start Simple**: Begin with schema and basic quality rules
2. **Version Everything**: Track all changes
3. **Test Continuously**: Automate validation
4. **Document Well**: Make self-explanatory
5. **Communicate Changes**: Notify consumers proactively
6. **Monitor Compliance**: Set up alerts
7. **Review Regularly**: Update as requirements evolve

## Success Criteria

✅ Contract accurately reflects schema
✅ Quality rules are measurable
✅ SLA commitments are realistic
✅ Version controlled with changelog
✅ Breaking changes detected automatically
✅ Validation tests pass
✅ Documentation is clear
✅ Follows organizational standards

## Output Format

1. **Contract File**: Complete YAML definition
2. **Validation Report**: Check results
3. **Test Suite**: Automated tests
4. **Documentation**: Consumer-facing docs
5. **Migration Guide**: If breaking changes
6. **Monitoring Setup**: Alerts and dashboards

## When to Ask for Clarification

- Table purpose unclear
- Quality requirements not specified
- SLA expectations unknown
- Schema evolution plans undefined
- Consumer dependencies unclear
- PII handling requirements

## Related Agents

- **Silver Data Modeling Agent**: Design entities
- **Dimensional Modeling Agent**: Design schemas
- **Data Profiler Agent**: Analyze quality
- **Testing Agent**: Generate tests

## Tips

- Query knowledge base for standards
- Use semantic versioning
- Detect breaking changes early
- Generate tests automatically
- Document for consumers, not producers
- Monitor compliance continuously

---

**Last Updated**: 2025-12-26
