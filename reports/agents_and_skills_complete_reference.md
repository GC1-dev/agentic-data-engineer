# Agents and Skills - Complete Reference

**Last Updated**: 2026-01-24
**Total Components**: 28 (17 agents + 11 skills)
**Status**: ✅ 100% Correctly Categorized

---

## Executive Summary

This project contains 17 agents and 11 skills that work together to provide AI-native data engineering capabilities. Each component is precisely categorized based on its functional nature: agents provide advisory guidance and context-dependent recommendations, while skills perform deterministic actions or provide reference documentation.

**Component Breakdown**:
- **17 Agents**: Advisory guidance, analysis, context-dependent decisions
- **11 Skills**: Deterministic actions, fixed rules, reference documentation
- **9 Opus Agents**: Complex reasoning and deep analysis tasks
- **8 Sonnet Agents**: Standard advisory and guidance tasks
- **0 Haiku Agents**: No agents use Haiku (reserved for skills)

---

## Decision Framework

### What Makes Something an Agent?

An **Agent** provides:
- ✅ **Advisory guidance** - Recommends approaches based on context
- ✅ **Context-dependent decisions** - Different advice for different situations
- ✅ **Analysis and evaluation** - Examines existing code/data before suggesting changes
- ✅ **Custom recommendations** - Tailored suggestions specific to the project
- ✅ **Expert judgment** - Makes decisions requiring domain expertise
- ✅ **Multi-step reasoning** - Analyzes, considers alternatives, recommends best approach

**Example**: "Should I use SCD Type 1 or Type 2 for this dimension?" → Requires context, analysis, and expert judgment → **Agent**

### What Makes Something a Skill?

A **Skill** provides:
- ✅ **Deterministic actions** - Same input → same output, always
- ✅ **Fixed rules/procedures** - Follows established standards without judgment
- ✅ **Reference documentation** - Provides information without customization
- ✅ **Tool execution** - Runs tools (linters, formatters) with fixed configuration
- ✅ **Template generation** - Produces output with predetermined structure
- ✅ **User-invocable** - Direct commands users can run on demand

**Example**: "Lint my Python code with Ruff" → Deterministic, fixed rules, no judgment → **Skill**

### Decision Criteria

| Question | Agent | Skill |
|----------|-------|-------|
| **Requires expert judgment?** | ✅ Yes | ❌ No |
| **Context-dependent decisions?** | ✅ Yes | ❌ No |
| **Analysis before recommendation?** | ✅ Yes | ❌ No |
| **Multiple valid approaches?** | ✅ Yes | ❌ No |
| **Same input → same output?** | ❌ No | ✅ Yes |
| **Fixed rules to apply?** | ❌ No | ✅ Yes |
| **User-invocable with slash command?** | ❌ No | ✅ Yes |

---

## All 17 Agents

### Complete Agent List

| # | Agent Name | Model | Purpose | Use For |
|---|------------|-------|---------|---------|
| 1 | **medallion-architecture-agent** | Sonnet | Comprehensive medallion architecture guidance | Pipeline design, layer placement, naming conventions, data flow validation |
| 2 | **dimensional-modeling-agent** | Opus | Kimball dimensional modeling for Gold layer | Star schemas, fact/dimension design, SCD patterns |
| 3 | **silver-data-modeling-agent** | Opus | Entity-centric modeling for Silver layer | 3NF design, entity relationships, normalization, business key design |
| 4 | **data-transformation-coding-agent** | Opus | Write PySpark transformation code | Transformations, aggregations, joins, window functions, feature implementation |
| 5 | **data-transformation-testing-agent** | Opus | Write comprehensive tests for transformations | Unit tests, integration tests, 4 core testing patterns, 80%+ coverage |
| 6 | **data-contract-agent** | Sonnet | Generate and validate data contracts | Contract generation, schema validation, SLA monitoring |
| 7 | **transformation-validation-agent** | Opus | Validate transformations against standards | Quality checks, medallion rules, error handling validation |
| 8 | **pyspark-standards-agent** | Opus | Enforce PySpark coding standards | Import organization, configuration patterns, performance review |
| 9 | **project-structure-agent** | Opus | Validate project structure standards | Directory organization, required files, documentation completeness |
| 10 | **streaming-tables-agent** | Sonnet | Design streaming tables for real-time ingestion | Streaming pipelines, continuous processing, low-latency analytics |
| 11 | **materialized-view-agent** | Sonnet | Design materialized views for query acceleration | Pre-computed aggregations, BI optimization, refresh strategies |
| 12 | **documentation-agent** | Sonnet | Create documentation and diagrams | Architecture docs, API references, Mermaid diagrams |
| 13 | **data-naming-agent** | Sonnet | Name tables, columns, schemas following conventions | Medallion naming, Unity Catalog naming |
| 14 | **decision-documenter-agent** | Sonnet | Document architectural decisions (ADRs) | Architecture decisions, technical choices, tradeoff analysis |
| 15 | **bronze-table-finder-agent** | Opus | Identify candidate Bronze tables for Silver | Source table recommendations, schema analysis, catalog navigation |
| 16 | **data-profiler-agent** | Opus | Generate data profiling reports | Statistical analysis, quality assessment, nested column analysis |
| 17 | **unity-catalog-agent** | Sonnet | Navigate Unity Catalog, query system tables | Metadata queries, lineage analysis, table discovery |

### Agents by Category

#### 🏗️ Architecture & Design (5 agents)
- **medallion-architecture-agent** (Sonnet) - Medallion architecture guidance
- **dimensional-modeling-agent** (Opus) - Kimball dimensional modeling
- **silver-data-modeling-agent** (Opus) - Entity-centric Silver modeling
- **materialized-view-agent** (Sonnet) - Materialized view design
- **project-structure-agent** (Opus) - Project structure validation

#### 💻 Code Development (3 agents)
- **data-transformation-coding-agent** (Opus) - PySpark code generation
- **pyspark-standards-agent** (Opus) - PySpark best practices
- **streaming-tables-agent** (Sonnet) - Streaming pipeline design

#### 🔍 Data Discovery & Analysis (3 agents)
- **bronze-table-finder-agent** (Opus) - Find Bronze source tables
- **data-profiler-agent** (Opus) - Data profiling and quality analysis
- **unity-catalog-agent** (Sonnet) - Unity Catalog navigation

#### ✅ Quality & Validation (3 agents)
- **data-transformation-testing-agent** (Opus) - Test generation
- **transformation-validation-agent** (Opus) - Transformation validation
- **data-contract-agent** (Sonnet) - Data contract generation

#### 📋 Standards & Conventions (2 agents)
- **data-naming-agent** (Sonnet) - Naming conventions
- **decision-documenter-agent** (Sonnet) - Decision documentation

#### 📝 Documentation (1 agent)
- **documentation-agent** (Sonnet) - Technical documentation creation

### Agents by Model

#### Opus Agents (9 total)

Complex tasks requiring deep reasoning, comprehensive analysis, and sophisticated decision-making:

| Agent | Purpose |
|-------|---------|
| bronze-table-finder-agent | Identify candidate Bronze tables for Silver |
| data-profiler-agent | Generate comprehensive data profiling reports |
| data-transformation-coding-agent | Write PySpark transformation code |
| data-transformation-testing-agent | Write comprehensive tests for transformations |
| dimensional-modeling-agent | Kimball dimensional modeling for Gold layer |
| project-structure-agent | Validate project structure standards |
| pyspark-standards-agent | Enforce PySpark coding standards |
| silver-data-modeling-agent | Entity-centric modeling for Silver layer |
| transformation-validation-agent | Validate transformations against standards |

**Why Opus?**
- **Deep code analysis**: Understanding complex transformations, patterns, anti-patterns
- **Comprehensive testing**: Generating multiple test scenarios with edge cases
- **Complex modeling**: Dimensional modeling, entity modeling, normalization
- **Detailed validation**: Multi-layer validation with context-aware recommendations
- **Data profiling**: Statistical analysis, quality assessment, nested structures
- **Standards enforcement**: Deep understanding of coding patterns and best practices

#### Sonnet Agents (8 total)

Standard advisory and guidance tasks:

| Agent | Purpose |
|-------|---------|
| data-contract-agent | Generate and validate data contracts |
| data-naming-agent | Name tables, columns, schemas following conventions |
| decision-documenter-agent | Document architectural decisions (ADRs) |
| documentation-agent | Create documentation and diagrams |
| materialized-view-agent | Design materialized views for query acceleration |
| medallion-architecture-agent | Comprehensive medallion architecture guidance |
| streaming-tables-agent | Design streaming tables for real-time ingestion |
| unity-catalog-agent | Navigate Unity Catalog, query system tables |

**Why Sonnet?**
- **Standard guidance**: Architectural recommendations, naming conventions
- **Documentation**: Creating docs, diagrams, decision records
- **Contract management**: Schema validation, SLA monitoring
- **Catalog navigation**: Metadata queries, table discovery
- **Straightforward design**: Materialized views, streaming patterns

---

## All 11 Skills

### Complete Skill List

#### Action Skills (6 total)

Skills that perform formatting, linting, validation, and generation.

| # | Skill Name | Invocation | Purpose | Type |
|---|------------|------------|---------|------|
| 1 | **makefile-formatter-skill** | `/makefile-formatter-skill` | Standardize Makefiles to Skyscanner conventions | Formatter |
| 2 | **pyproject-formatter-skill** | `/pyproject-formatter-skill` | Standardize pyproject.toml files | Formatter |
| 3 | **json-formatter-skill** | `/json-formatter-skill` | Format, validate, and manipulate JSON data | Formatter |
| 4 | **data-contract-formatter-skill** | `/data-contract-formatter-skill` | Format and validate ODCS v3.1.0 data contracts | Validator |
| 5 | **project-code-linter-skill** | `/project-code-linter-skill` or `/lint` | Enforce code quality with Ruff, pytest, YAML/JSON linters | Linter |
| 6 | **claude-agent-template-generator-skill** | `/generate-agent` | Generate Claude agent templates | Generator |

#### Reference Documentation Skills (5 total)

Skills that provide comprehensive reference documentation for libraries and tools.

| # | Skill Name | Invocation | Purpose | Type |
|---|------------|------------|---------|------|
| 7 | **skyscanner-data-shared-utils-skill** | Auto-detected | Reference for data-shared-utils library | Reference |
| 8 | **skyscanner-spark-session-utils-skill** | Auto-detected | Reference for spark-session-utils library | Reference |
| 9 | **mermaid-diagrams-skill** | Auto-detected | Mermaid diagram syntax reference | Reference |
| 10 | **dbdiagram-skill** | Auto-detected | DBML database diagram syntax reference | Reference |
| 11 | **pdf-creator-skill** | Auto-detected | ReportLab PDF generation reference | Reference |

### Skills by Category

#### 🔧 Formatting & Linting (5 skills)
- **makefile-formatter-skill** - Makefile standardization
- **pyproject-formatter-skill** - pyproject.toml formatting
- **json-formatter-skill** - JSON formatting and validation
- **data-contract-formatter-skill** - ODCS v3.1.0 contract validation
- **project-code-linter-skill** - Code quality enforcement (Ruff, pytest, YAML, JSON)

#### 🎨 Generation & Templates (1 skill)
- **claude-agent-template-generator-skill** - Agent template generation

#### 📚 Reference Documentation (5 skills)
- **skyscanner-data-shared-utils-skill** - PySpark utilities reference
- **skyscanner-spark-session-utils-skill** - Spark session management reference
- **mermaid-diagrams-skill** - Mermaid syntax reference
- **dbdiagram-skill** - DBML syntax reference
- **pdf-creator-skill** - ReportLab API reference

---

## Invocation Methods

### How to Use Agents

Agents are invoked via natural language or the Task tool. Claude automatically selects the appropriate agent based on your request.

```
# Natural language (automatic)
"Design a Silver layer entity model for user sessions"
→ Claude invokes silver-data-modeling-agent

"Find Bronze tables for my Silver bookings table"
→ Claude invokes bronze-table-finder-agent

# Explicit Task tool
"Use the dimensional-modeling-agent to design a star schema for bookings analytics"
```

### How to Use Skills

Skills can be invoked directly via slash commands or automatically detected.

```
# Direct slash command
/project-code-linter-skill
/data-contract-formatter-skill
/generate-agent

# Natural language (automatic)
"Lint my code"
→ Claude invokes /project-code-linter-skill

"Format this data contract"
→ Claude invokes /data-contract-formatter-skill
```

---

## Common Workflows

### 1. Starting a New Data Product

1. **medallion-architecture-agent** - Understand architecture patterns
2. **project-structure-agent** - Set up compliant project structure
3. **data-naming-agent** - Name your assets correctly
4. **bronze-table-finder-agent** - Find source tables
5. **silver-data-modeling-agent** - Design Silver entities
6. **dimensional-modeling-agent** - Design Gold star schemas
7. **data-contract-agent** - Define and enforce contracts

### 2. Writing Transformation Code

1. **bronze-table-finder-agent** - Identify source tables
2. **data-transformation-coding-agent** - Write transformation code
3. **pyspark-standards-agent** - Apply best practices
4. **data-transformation-testing-agent** - Generate tests
5. **transformation-validation-agent** - Validate outputs
6. **/project-code-linter-skill** - Lint and format code

### 3. Ensuring Code Quality

1. **/project-code-linter-skill** - Run Ruff, pytest, YAML/JSON linters
2. **pyspark-standards-agent** - Review PySpark patterns
3. **transformation-validation-agent** - Validate transformation logic
4. **data-transformation-testing-agent** - Ensure test coverage
5. **/data-contract-formatter-skill** - Validate data contracts

### 4. Creating Documentation

1. **documentation-agent** - Generate architecture docs
2. **decision-documenter-agent** - Document key decisions
3. **/mermaid-diagrams-skill** - Create diagrams
4. **/dbdiagram-skill** - Generate database schemas
5. **data-contract-agent** - Document data contracts

---

## Detailed Rationale by Component

### Agent Rationale Summary

Each agent was categorized as an agent (not a skill) because it:

**Requires Expert Judgment**: Makes decisions that require domain expertise and understanding of context
- Example: dimensional-modeling-agent decides between fact and dimension based on business requirements

**Context-Dependent**: Different situations require different recommendations
- Example: data-transformation-coding-agent generates different code based on specific transformation requirements

**Performs Analysis**: Examines existing code, data, or patterns before making recommendations
- Example: bronze-table-finder-agent analyzes Unity Catalog schemas to recommend appropriate source tables

**Multiple Valid Approaches**: Same problem can have different solutions based on context
- Example: pyspark-standards-agent recommends different optimization strategies based on data volume and patterns

**Custom Recommendations**: Tailored advice specific to the project and situation
- Example: project-structure-agent provides structure recommendations based on project complexity and team needs

### Skill Rationale Summary

Each skill was categorized as a skill (not an agent) because it:

**Deterministic**: Same input always produces same output
- Example: json-formatter-skill always formats JSON with same indentation rules

**Fixed Rules**: Follows established standards without judgment
- Example: project-code-linter-skill runs Ruff with fixed configuration from ruff.toml

**No Analysis Required**: Executes without examining context or making decisions
- Example: makefile-formatter-skill applies predetermined structure to all Makefiles

**Reference Documentation**: Provides fixed information without customization
- Example: skyscanner-data-shared-utils-skill documents library API without variation

**User-Invocable**: Can be directly called via slash command
- Example: /data-contract-formatter-skill validates contracts on demand

---

## Why No Haiku Agents?

All advisory tasks require capabilities beyond Haiku's intended use:
- **Context-dependent decision making**
- **Multi-factor analysis**
- **Trade-off evaluation**
- **Comprehensive recommendations**

Haiku is reserved for **skills** when they need to perform quick, deterministic operations. However, currently all skills either use inherited model settings or don't require model specification (for reference documentation).

---

## File Locations

### Agents
```
src/agentic_data_engineer/.claude/agents/shared/
├── bronze-table-finder-agent.md
├── data-contract-agent.md
├── data-naming-agent.md
├── data-profiler-agent.md
├── data-transformation-coding-agent.md
├── data-transformation-testing-agent.md
├── decision-documenter-agent.md
├── dimensional-modeling-agent.md
├── documentation-agent.md
├── materialized-view-agent.md
├── medallion-architecture-agent.md
├── project-structure-agent.md
├── pyspark-standards-agent.md
├── silver-data-modeling-agent.md
├── streaming-tables-agent.md
├── transformation-validation-agent.md
└── unity-catalog-agent.md
```

### Skills
```
src/agentic_data_engineer/.claude/skills/
├── claude-agent-template-generator-skill/SKILL.md
├── data-contract-formatter-skill/SKILL.md
├── dbdiagram-skill/SKILL.md
├── json-formatter-skill/SKILL.md
├── makefile-formatter-skill/SKILL.md
├── mermaid-diagrams-skill/SKILL.md
├── pdf-creator-skill/SKILL.md
├── project-code-linter-skill/SKILL.md
├── pyproject-formatter-skill/SKILL.md
├── skyscanner-data-shared-utils-skill/SKILL.md
└── skyscanner-spark-session-utils-skill/SKILL.md
```

---

## Verification Commands

### Count agents by model
```bash
cd src/agentic_data_engineer/.claude/agents/shared
for file in *.md; do
  grep "^model:" "$file" | head -1 | awk '{print $2}'
done | sort | uniq -c | sort -rn

# Expected output:
# 9 opus
# 8 sonnet
```

### List all components
```bash
# Agents
ls src/agentic_data_engineer/.claude/agents/shared/*.md | wc -l
# Expected: 17

# Skills
ls src/agentic_data_engineer/.claude/skills/*/SKILL.md | wc -l
# Expected: 11
```

---

## Status

✅ **100% Complete** - All 28 components correctly categorized
✅ **17 Agents** - All providing advisory/guidance roles
✅ **11 Skills** - All performing actions or providing reference docs
✅ **9 Opus / 8 Sonnet** - All agents properly assigned to correct models
✅ **Documentation** - All documentation updated and accurate

**Last Verified**: 2026-01-24
