# Bronze Table Finder Agent

## Overview

The Bronze Table Finder Agent helps identify candidate Bronze layer input tables for Silver table definitions. It specializes in analyzing Silver table requirements and searching Unity Catalog for compatible Bronze tables.

## Agent Details

- **Name**: `bronze-table-finder-agent`
- **Model**: Sonnet
- **Skills**: mermaid-diagrams-skill, pdf-creator-skill

## Capabilities

- Analyze Silver table requirements (schemas, columns, data types, business logic)
- Search Unity Catalog for Bronze tables using multiple keyword patterns
- Navigate Unity Catalog's information schema to discover tables
- Examine table schemas and assess suitability as data sources
- Validate data freshness and coverage
- Provide ranked recommendations with schema mappings
- Identify platform coverage gaps (Android, iOS, Web, Desktop)
- Detect type mismatches and data quality issues

## When to Use

Use this agent when you need to:

- Identify source Bronze tables for a new Silver table definition
- Find relevant Bronze tables based on Silver schema requirements
- Verify Bronze table availability when refactoring pipelines
- Understand which Bronze tables can feed into a Silver table
- Map columns from Bronze to Silver layer
- Assess data completeness and platform coverage

## Usage Examples

### Example 1: Finding Source Tables for New Silver Table

```
User: "I'm creating a silver table for user session events. Can you help me find the right bronze tables?"

Agent: "I'll search prod_trusted_bronze.internal for candidate tables matching your session events requirements using multiple keyword patterns."
```

### Example 2: Schema-Based Search

```
User: "Here's my Silver table schema with columns for user_id, session_id, event_timestamp, platform, and event_type. What Bronze tables should I use?"

Agent: "I'll analyze your schema and search for Bronze tables with compatible columns, then provide ranked recommendations with schema mappings."
```

### Example 3: Pipeline Refactoring

```
User: "I need to rebuild the user activity aggregation pipeline. Can you check what Bronze tables are available for user events?"

Agent: "I'll query prod_trusted_bronze.internal and find all relevant user activity tables with their schemas and freshness."
```

## Search Strategy

The agent uses a systematic multi-step approach:

### Step 1: Understand Requirements
- Analyze Silver table definition
- Identify key columns, data types, and business entities
- Determine temporal requirements
- Note platform filters
- Extract keywords and domain concepts

### Step 2: Execute Parallel Keyword Searches
- Search using multiple keyword patterns simultaneously
- Use related terms and synonyms
- Examples: "search", "query", "session", "event", "activity"

### Step 3: Examine Candidate Tables
- Retrieve full schema details
- Compare columns against requirements
- Check partitioning and data freshness
- Assess platform coverage

### Step 4: Validate and Profile
- Check partition coverage
- Sample recent data
- Analyze record counts by partition

### Step 5: Rank and Recommend
- Provide primary recommendation with justification
- Show schema comparison
- Note coverage gaps
- List alternative options
- Highlight red flags

### Step 6: Validate Completeness
- Check all relevant platforms
- Examine tables with similar descriptions
- Verify metadata and ownership

## Output Format

The agent provides structured findings:

```markdown
## Bronze Table Candidates for [Silver Table Name]

### Primary Recommendation
**Table**: `prod_trusted_bronze.internal.[table_name]`
**Confidence**: High/Medium/Low
**Rationale**: [Why this table is the best fit]

**Schema Mapping**:
| Silver Column | Bronze Column | Data Type Match | Notes |
|---------------|---------------|-----------------|-------|
| ... | ... | ✅/⚠️ | ... |

**Partitioning**: [Partition columns and coverage]
**Data Freshness**: [Latest partition date]
**Sample Record Count**: [Approximate volume]

### Alternative Candidates
1. **`prod_trusted_bronze.internal.[table_name_2]`**
   - Pros: [Advantages]
   - Cons: [Limitations]

### Coverage Analysis
✅ **Available**: [List columns/requirements met]
⚠️ **Gaps**: [List missing columns or data]
❌ **Blockers**: [List critical issues]

### Recommended Next Steps
1. [Action item 1]
2. [Action item 2]
```

## Key Features

### Multi-Keyword Search
- Searches multiple related terms in parallel
- Reduces risk of missing relevant tables
- Handles terminology variations

### Schema Validation
- Compares Bronze schemas to Silver requirements
- Identifies type mismatches
- Validates column availability

### Platform Coverage Analysis
- Identifies which platforms are covered
- Detects coverage gaps
- Highlights multi-platform considerations

### Data Freshness Checks
- Validates recent data availability
- Checks partition completeness
- Assesses data quality

## Common Pitfalls Avoided

### 1. Keyword-Dependent Blindness
❌ Don't rely on single keyword searches
✅ Search multiple related terms

### 2. Assumed Redundancy
❌ Don't assume similar descriptions mean duplicate tables
✅ Always compare schemas

### 3. Single Platform Bias
❌ Don't stop after finding one match
✅ Ensure cross-platform coverage

### 4. Ignoring Metadata
❌ Don't focus only on schema
✅ Check ownership, criticality, freshness

## Best Practices

1. **Use Multiple Keywords**: Search 5-7 different keyword patterns
2. **Check All Platforms**: Ensure Android, iOS, Web, Desktop coverage
3. **Examine Schemas**: Don't assume based on descriptions
4. **Validate Freshness**: Check recent partition availability
5. **Profile Data**: Sample data to verify content
6. **Check Metadata**: Review ownership and criticality
7. **Ask Users**: Leverage existing knowledge of pipelines

## Limitations

- **Keyword-Dependent**: Only finds tables with keywords in names
- **No Lineage Trace**: Doesn't automatically check existing ETL references
- **Comment Quality**: Relies on accurate table descriptions
- **Nested Fields**: Harder to search within STRUCT/ARRAY columns

## Success Criteria

✅ Found all relevant Bronze tables across platforms
✅ Schema mappings are accurate and complete
✅ Data freshness validated
✅ Coverage gaps identified
✅ Recommendations are evidence-based
✅ Alternative options provided

## Tools Available

- `search_tables`: Find tables by keyword in Unity Catalog
- `get_table_schema`: Examine table structure
- `execute_query`: Run SQL for data profiling and validation

## Related Agents

- **Silver Data Modeling Agent**: Design Silver entities
- **Data Contract Agent**: Define table contracts
- **Medallion Architecture Agent**: Understand layer patterns

## Tips

- Start with broad searches using primary keywords
- Expand to synonyms and related terms
- Always examine schemas, don't rely on names alone
- Check for platform-specific tables
- Validate with data sampling
- Consider union strategies for multi-table coverage

---

**Last Updated**: 2025-12-26
