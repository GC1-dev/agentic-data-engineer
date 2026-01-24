# Shared Agents Usage Documentation

This directory contains comprehensive usage documentation for all shared Claude agents available in `.claude/agents/shared/`.

## Quick Start

Each agent has its own detailed README with:
- Overview and capabilities
- When to use guidance
- Usage examples
- Best practices
- Related agents

## All Agents by Category

### 🏗️ Architecture & Design

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Medallion Architecture** | Sonnet | Design and implement medallion architecture patterns (Bronze/Silver/Gold) | [README](./README-medallion-architecture-agent.md) |
| **Dimensional Modeling** | Sonnet | Design star/snowflake schemas for Gold layer analytics | [README](./README-dimensional-modeling-agent.md) |
| **Silver Data Modeling** | Sonnet | Design entity-centric Silver layer models with 3NF normalization | [README](./README-silver-data-modeling-agent.md) |
| **Materialized View** | Sonnet | Design materialized views with refresh strategies | [README](./README-materialized-view-agent.md) |
| **Project Structure** | Sonnet | Set up compliant project structures following standards | [README](./README-project-structure-agent.md) |

### 💻 Code Development

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Data Transformation Coding** | Sonnet | Implement features, fix bugs, refactor PySpark code | [README](./README-data-transformation-coding-agent.md) |
| **PySpark Standards** | Sonnet | Apply PySpark best practices and performance optimization | [README](./README-pyspark-standards-agent.md) |
| **Streaming Tables** | Sonnet | Implement Delta Live Tables streaming pipelines | [README](./README-streaming-tables-agent.md) |

### 🔍 Data Discovery & Analysis

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Bronze Table Finder** | Sonnet | Find source Bronze tables for Silver definitions using Unity Catalog | [README](./README-bronze-table-finder-agent.md) |
| **Data Profiler** | Sonnet | Generate comprehensive data profiling reports with quality assessment | [README](./README-data-profiler-agent.md) |

### ✅ Quality & Validation

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Data Transformation Testing** | Sonnet | Generate comprehensive unit and E2E tests for transformations | [README](./README-data-transformation-testing-agent.md) |
| **Transformation Validation** | Sonnet | Validate data transformation outputs and quality | [README](./README-transformation-validation-agent.md) |
| **Data Contract** | Sonnet | Generate and enforce data contracts for tables | [README](./README-data-contract-agent.md) |

### 📋 Standards & Conventions

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Data Naming** | Haiku | Apply naming conventions for tables, columns, schemas, catalogs | [README](./README-data-naming-agent.md) |
| **Decision Documenter** | Haiku | Document architectural decisions and key technical choices | [README](./README-decision-documenter-agent.md) |

### 📝 Documentation & Generation

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Documentation** | Sonnet | Generate technical documentation with mermaid diagrams | [README](./README-documentation-agent.md) |
| **Data Project Generator** | Sonnet | Scaffold new data projects with complete structure | [README](./README-data-project-generator-agent.md) |

### 🛠️ Configuration & Tooling

**Note**: The following components have been converted to skills for better user experience:
- **Data Contract Formatter** - Use `/data-contract-formatter-skill` to format and validate data contracts
- **Project Code Linter** - Use `/project-code-linter-skill` to lint and validate code quality across projects
- **Agent Template Generator** - Use `/claude-agent-template-generator-skill` or `/generate-agent` to create new agent templates

### 🔄 Databricks Platform

| Agent | Model | Description | Documentation |
|-------|-------|-------------|---------------|
| **Unity Catalog** | Sonnet | Work with Unity Catalog governance and organization | [README](./README-unity-catalog-agent.md) |

## Quick Reference - When to Use Which Agent

### Starting a New Project
1. **[Data Project Generator](./README-data-project-generator-agent.md)** - Scaffold initial structure
2. **[Project Structure Agent](./README-project-structure-agent.md)** - Ensure compliance with standards
3. **[Data Naming Agent](./README-data-naming-agent.md)** - Name your assets correctly

### Designing Data Models
1. **[Medallion Architecture Agent](./README-medallion-architecture-agent.md)** - Understand overall architecture
2. **[Bronze Table Finder Agent](./README-bronze-table-finder-agent.md)** - Find source tables
3. **[Silver Data Modeling Agent](./README-silver-data-modeling-agent.md)** - Design normalized Silver entities
4. **[Dimensional Modeling Agent](./README-dimensional-modeling-agent.md)** - Design Gold star schemas
5. **[Materialized View Agent](./README-materialized-view-agent.md)** - Optimize with materialized views

### Implementing Code
1. **[Data Transformation Coding Agent](./README-data-transformation-coding-agent.md)** - Write transformation code
2. **[PySpark Standards Agent](./README-pyspark-standards-agent.md)** - Apply best practices
3. **[Streaming Tables Agent](./README-streaming-tables-agent.md)** - Implement streaming if needed
4. **[Data Transformation Testing Agent](./README-data-transformation-testing-agent.md)** - Generate comprehensive tests
5. **[Transformation Validation Agent](./README-transformation-validation-agent.md)** - Validate outputs

### Quality & Governance
1. **[Data Profiler Agent](./README-data-profiler-agent.md)** - Profile data quality
2. **[Data Contract Agent](./README-data-contract-agent.md)** - Define and enforce contracts
3. **`/data-contract-formatter-skill`** - Format and validate contract YAML files
3. **[Data Transformation Testing Agent](./README-data-transformation-testing-agent.md)** - Ensure quality with tests

### Documentation
1. **[Documentation Agent](./README-documentation-agent.md)** - Generate technical docs and diagrams
2. **[Decision Documenter Agent](./README-decision-documenter-agent.md)** - Record key decisions

### Creating New Agents & Templates
Use the `/claude-agent-template-generator-skill` or `/generate-agent` skill to create new agent templates.

## How to Use These Agents

### Via Claude Code

```bash
# Invoke via Task tool with agent description
"Use the bronze-table-finder-agent to find source tables for my Silver user_session table"
```

### Via Direct Reference

Simply reference the agent's purpose in your prompt:
```
"I need to design a Silver layer data model following entity-centric modeling principles"
# Claude will automatically use the silver-data-modeling-agent
```

## Agent Capabilities Matrix

| Capability | Agents |
|-----------|---------|
| **Generate Code** | Data Transformation Coding, Data Project Generator, Data Transformation Testing, Streaming Tables |
| **Design Models** | Medallion Architecture, Dimensional Modeling, Silver Data Modeling, Materialized View |
| **Find/Discover** | Bronze Table Finder, Data Profiler |
| **Validate/Test** | Data Transformation Testing, Transformation Validation, Data Contract |
| **Document** | Documentation, Decision Documenter |
| **Generate Templates** | Data Project Generator |
| **Govern** | Unity Catalog, Data Contract |

**Note**: Formatting, linting, and agent template generation are now skills:
- Format/Standardize: Data Naming (agent), PySpark Standards (agent), `/data-contract-formatter-skill`, `/project-code-linter-skill`
- Generate Agent Templates: `/claude-agent-template-generator-skill`

## Model Selection Guide

### Sonnet (Most Agents)
Complex tasks requiring deep reasoning:
- Architecture design
- Code implementation
- Data modeling
- Quality validation
- Comprehensive analysis

### Haiku (Fast Tasks)
Simple, straightforward tasks:
- Naming conventions
- Decision documentation

**Note**: Template generation and formatting are now skills, not agents.

## All Agents Alphabetically

1. [Bronze Table Finder Agent](./README-bronze-table-finder-agent.md) - Find Bronze source tables
2. [Data Contract Agent](./README-data-contract-agent.md) - Generate/enforce contracts
3. [Data Naming Agent](./README-data-naming-agent.md) - Apply naming conventions
4. [Data Profiler Agent](./README-data-profiler-agent.md) - Profile data quality
5. [Data Transformation Coding Agent](./README-data-transformation-coding-agent.md) - Implement features and code
6. [Data Transformation Testing Agent](./README-data-transformation-testing-agent.md) - Generate tests
7. [Decision Documenter Agent](./README-decision-documenter-agent.md) - Document decisions
8. [Dimensional Modeling Agent](./README-dimensional-modeling-agent.md) - Design star schemas
9. [Documentation Agent](./README-documentation-agent.md) - Generate documentation
10. [Materialized View Agent](./README-materialized-view-agent.md) - Design materialized views
11. [Medallion Architecture Agent](./README-medallion-architecture-agent.md) - Implement medallion patterns
12. [Project Structure Agent](./README-project-structure-agent.md) - Set up project structure
13. [PySpark Standards Agent](./README-pyspark-standards-agent.md) - Apply PySpark standards
14. [Silver Data Modeling Agent](./README-silver-data-modeling-agent.md) - Design Silver entities
15. [Streaming Tables Agent](./README-streaming-tables-agent.md) - Implement streaming
16. [Transformation Validation Agent](./README-transformation-validation-agent.md) - Validate transformations
17. [Unity Catalog Agent](./README-unity-catalog-agent.md) - Work with Unity Catalog

**Converted to Skills** (no longer agents):
- Data Contract Formatter → `/data-contract-formatter-skill`
- Project Code Linter → `/project-code-linter-skill`
- Claude Agent Template Generator → `/claude-agent-template-generator-skill`

## Example Workflows

### Complete Data Pipeline Development

```
1. Use Data Project Generator to scaffold project
2. Use Bronze Table Finder to identify source tables
3. Use Silver Data Modeling Agent to design entities
4. Use Dimensional Modeling Agent to design Gold schemas
5. Use Data Transformation Coding Agent to implement transformations
6. Use PySpark Standards Agent to optimize code
7. Use Data Transformation Testing Agent to generate comprehensive tests
8. Use Data Contract Agent to define quality contracts
9. Use Documentation Agent to create technical docs
10. Use Decision Documenter to record key choices
```

### Data Quality Initiative

```
1. Use Data Profiler Agent to assess current quality
2. Use Data Contract Agent to define quality standards
3. Use Transformation Validation Agent to validate pipelines
4. Use Data Transformation Testing Agent to ensure quality gates
5. Use Documentation Agent to document quality metrics
```

### New Feature Development

```
1. Use Medallion Architecture Agent to understand layer patterns
2. Use Data Naming Agent to name new tables/columns
3. Use Data Transformation Coding Agent to implement feature
4. Use Data Transformation Testing Agent to write comprehensive tests
5. Use Documentation Agent to document the feature
6. Use Decision Documenter to record design decisions
```

## Tips for Success

- **Start with Architecture**: Use architecture agents before coding
- **Follow Standards**: Use naming and standards agents consistently
- **Test Thoroughly**: Always use testing agent for new code
- **Document Everything**: Use documentation agents proactively
- **Validate Quality**: Profile and contract agents ensure quality
- **Record Decisions**: Document important choices with decision documenter

## Contributing

To add a new agent:
1. Create the agent file in `.claude/agents/shared/`
2. Create documentation: `README-<agent-name>.md`
3. Update this master README with the new agent
4. Follow the documentation template from existing READMEs

## Support

For questions about agents:
1. Check the individual agent README
2. Review the agent's usage examples
3. Check the agent's capabilities section
4. Look at related agents for additional context

---

**Directory**: `/shared_agents_usage_docs`
**Total Agents**: 20
**Last Updated**: 2026-01-22
**Status**: ✅ All agents documented
