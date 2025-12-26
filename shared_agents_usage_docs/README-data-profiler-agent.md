# Data Profiler Agent

## Overview

Generate comprehensive data profiling reports for Unity Catalog tables, including statistical analysis, quality assessment, and nested STRUCT column analysis.

## Agent Details

- **Name**: `data-profiler-agent`
- **Model**: Sonnet
- **Skills**: mermaid-diagrams-skill, pdf-creator-skill

## Capabilities

- Generate comprehensive data profiling reports
- Perform statistical analysis (row counts, null rates, cardinality, distributions)
- Analyze nested STRUCT columns with field-level profiling
- Identify data quality issues (nulls, duplicates, type mismatches, outliers)
- Assess partition distribution and completeness
- Provide platform-specific insights
- Generate actionable recommendations
- Create detailed reports saved to ./reports directory

## When to Use

- Understand characteristics of new datasets
- Investigate data quality issues
- Validate transformation output quality
- Profile tables with complex nested STRUCT columns
- Identify type mismatches in nested structures
- Assess data completeness and platform coverage
- Generate profiling reports for documentation

## Usage Examples

```
User: "Profile the prod_trusted_silver.user_activity table"
Agent: Generates comprehensive profiling report with statistics and quality assessment

User: "Analyze the session_data table for null rates and distributions"
Agent: Performs thorough analysis with actionable insights

User: "Profile ios_mini_search with nested STRUCT analysis"
Agent: Provides detailed nested field analysis and type validation
```

## Key Features

- Full dataset queries for accurate statistics (no sampling unless necessary)
- STRUCT column deep analysis (2-5+ levels deep)
- Platform coverage assessment
- Data quality scoring
- Actionable recommendations
- Visual distribution analysis
- Type mismatch detection

## Success Criteria

✅ Comprehensive statistical analysis
✅ Accurate quality assessment
✅ Nested STRUCT profiling complete
✅ Actionable recommendations provided
✅ Report saved to ./reports
✅ Platform coverage analyzed

## Related Agents

- **Data Contract Agent**: Define quality contracts
- **Testing Agent**: Generate quality tests
- **Bronze Table Finder**: Find source tables

---

**Last Updated**: 2025-12-26
