# Project Context

## Purpose

The **Agentic Data Engineer** project is an AI-native data engineering framework designed for building enterprise-grade data pipelines on Databricks. The project provides a comprehensive suite of utilities, standards, and AI agents to accelerate data product development while ensuring quality, governance, and architectural consistency.

### Core Objectives
- Enable AI-assisted data engineering through specialized Claude agents
- Enforce medallion architecture (Bronze/Silver/Gold) patterns
- Provide reusable utilities for PySpark transformations, data quality, and Spark session management
- Standardize data contracts using ODCS (Open Data Contract Standard) v3.1.0
- Automate testing, validation, and quality assurance
- Maintain comprehensive documentation and knowledge base

## Tech Stack

### Primary Technologies
- **Language**: Python 3.10+ (Databricks Runtime 13.0+ compatibility)
- **Framework**: PySpark 3.4+
- **Platform**: Databricks on AWS
- **Storage**: Delta Lake on AWS S3
- **Governance**: Unity Catalog (three-level namespace)
- **Package Management**: Poetry
- **Configuration**: Pydantic Settings with YAML files
- **Testing**: pytest with 80%+ coverage requirement
- **Linting**: Ruff for code formatting and linting
- **Type Checking**: mypy for static type analysis
- **Documentation**: Google-style docstrings

### Prohibited Technologies
- R/SparkR (no team expertise)
- Scala (no team expertise)
- Direct DBFS/S3 access (must use Unity Catalog)
- XML, Excel, PDF formats in Bronze layer
- Flat project layout (must use src layout)
- setup.py (must use pyproject.toml with Poetry)

## Project Conventions

### Code Style

#### Python Standards
- **Project Structure**: Mandatory src layout
  ```
  project/
    src/
      package_name/
        __init__.py
        module.py
    tests/
      test_module.py
    pyproject.toml
    pytest.ini
    ruff.toml
  ```
- **Naming Conventions**:
  - Functions, variables, modules: `snake_case`
  - Classes: `PascalCase`
  - Constants: `UPPER_CASE`
  - Private members: `_private_func`
- **Type Hints**: Required on all public APIs
- **Docstrings**: Google-style docstrings mandatory for all public functions and classes
- **Import Organization**: Follow PySpark standards (stdlib → third-party → local)

#### Data Asset Naming
- **Bronze Layer**: `bronze.<domain>_<entity>` (e.g., `bronze.bookings_raw_events`)
- **Silver Layer**: `silver.<entity>` (3NF, entity-centric, e.g., `silver.user_session`)
- **Gold Layer**: `gold.<business_area>_<purpose>` (e.g., `gold.finance_daily_bookings`)
- **Catalog Names**: `<env>_catalog` (e.g., `dev_catalog`, `prod_catalog`)

### Architecture Patterns

#### Medallion Architecture (Non-Negotiable)
Strict three-layer data architecture with clear separation of concerns:

1. **Bronze Layer**: Raw data ingestion
   - Minimal transformation (schema enforcement only)
   - Append-only, immutable
   - Full audit trail with metadata columns
   - Delta Lake format with Unity Catalog

2. **Silver Layer**: Cleaned, conformed data
   - Entity-centric modeling (3NF)
   - Data quality rules enforced
   - Deduplication and standardization
   - Business keys and surrogate keys

3. **Gold Layer**: Business-ready analytics
   - Dimensional modeling (Kimball methodology)
   - Aggregated, denormalized for performance
   - Star schemas with facts and dimensions
   - Optimized for BI and reporting

**Rules**:
- No layer skipping or shortcuts
- Unity Catalog for all data access
- Delta Lake format mandatory
- Table-based access only (no direct file access)
- Proper metadata and lineage tracking

#### Data Contracts as Source of Truth (Non-Negotiable)
- All data products must have data contracts before implementation
- Contracts written in ODCS v3.1.0 format
- Schema changes require contract versioning and approval
- Code must conform exactly to contract specifications
- Contract violations block deployment in CI/CD

#### Configuration-Driven Architecture
- Environment-specific configs via YAML (dev/staging/prod)
- 12-factor app compliance
- Secrets in Databricks Secrets/AWS KMS only
- Configuration hierarchy: Env vars → .env → YAML → Code defaults
- Pydantic Settings for type-safe configuration

### Testing Strategy

#### 4 Core Testing Patterns (Mandatory)

mcp__data-knowledge-base__get_document("python-standards", "testing_structure")

### Git Workflow

- **Main Branch**: `main` (protected, production-ready code)
- **Development Branch**: `dev` (integration branch)
- **Feature Branches**: `feature/<feature-name>` or `<username>/<feature-name>`
- **Commit Messages**: Clear, descriptive with AI co-author attribution
  ```
  Add dark mode toggle to user settings

  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```
- **Pull Requests**: Required for all changes to main/dev
- **Code Review**: Mandatory before merge
- **CI/CD**: Automated checks enforce standards (ruff, mypy, pytest)

## Domain Context

### Data Engineering Domain
This project operates in the enterprise data engineering domain with focus on:
- **Batch Data Pipelines**: Scheduled transformations on Databricks
- **Medallion Architecture**: Bronze → Silver → Gold data flow
- **Dimensional Modeling**: Kimball methodology for analytics
- **Data Quality**: Automated validation and monitoring
- **Data Governance**: Unity Catalog, data contracts, lineage tracking

### Business Context
- **Target Users**: Data engineers, analytics engineers, data scientists
- **Use Cases**:
  - Building production data pipelines
  - Creating analytics-ready datasets
  - Implementing data quality checks
  - Managing data contracts and schemas
  - Generating dimensional models
- **Scale**: Enterprise-scale data processing (billions of rows)

### Key Concepts
- **Entity-Centric Modeling**: Silver layer focuses on business entities (users, bookings, flights)
- **Data Contracts**: ODCS-compliant specifications defining schemas, SLAs, ownership
- **Unity Catalog**: Three-level namespace (catalog.schema.table)
- **Delta Lake**: ACID transactions, time travel, schema evolution
- **Data Quality Dimensions**: 10 dimensions for comprehensive testing (schema, distribution, logic, edges, temporal, cross-field, negative, volume, environment, pipeline)

## Important Constraints

### Technical Constraints
- **Python Version**: 3.10+ only (Databricks Runtime compatibility)
- **PySpark Version**: 3.4+ required
- **Delta Lake**: Mandatory for all layers
- **Unity Catalog**: Required for all data access
- **No Direct File Access**: Must use Unity Catalog tables
- **Type Safety**: Type hints required on all public APIs
- **Test Coverage**: 80% minimum, enforced in CI/CD

### Business Constraints
- **Data Governance**: All data must have ownership and classification
- **Security**: Principle of least privilege, no hardcoded credentials
- **Compliance**: Data classification and PII handling required
- **SLA Requirements**: Data freshness and quality defined in contracts

### Regulatory Constraints
- **PII/Sensitive Data**: Must be marked and protected
- **Audit Logging**: Required for all data access
- **Data Retention**: Policies enforced per data classification
- **Access Control**: Unity Catalog RBAC enforced

## External Dependencies

### Databricks Platform
- **Databricks Runtime**: 13.0+ (includes Spark 3.4+)
- **Unity Catalog**: For data governance and access control
- **Databricks Secrets**: For credential management
- **Databricks Workflows**: For pipeline orchestration

### Data Storage
- **AWS S3**: Primary data lake storage
- **Delta Lake**: Table format for ACID transactions

### Third-Party Libraries
- **data-shared-utils**: Skyscanner internal utilities for PySpark
- **Pydantic**: Data validation and settings management
- **pytest**: Testing framework with coverage plugin
- **ruff**: Linting and formatting
- **mypy**: Static type checking

### Knowledge Base (MCP Server)
Access comprehensive documentation via `kb://` URI scheme:
- **Medallion Architecture**: `kb://document/medallion-architecture/*`
- **Data Contracts**: `kb://document/data-product-standards/data-contracts`
- **Testing Standards**: `kb://document/data-product-standards/testing-standards`
- **PySpark Standards**: `kb://document/pyspark-standards/*`

## AI Agents

This project includes 20+ specialized Claude agents for AI-assisted development. All agents must follow the constitution and enforce project standards.

### Core Development Agents

#### data-transformation-coding-agent
- **Purpose**: Write PySpark transformation code
- **Use For**: Transformations, aggregations, joins, window functions
- **Model**: Claude 3.5 Sonnet
- **Key Features**: Medallion architecture patterns, PySpark best practices

#### data-transformation-testing-agent
- **Purpose**: Write comprehensive tests for PySpark transformations
- **Use For**: Unit tests, integration tests, quality validation
- **Model**: Claude 3.5 Sonnet
- **Key Features**: 4 core testing patterns, assertion helpers, 80%+ coverage

#### data-contract-agent
- **Purpose**: Generate and validate data contracts
- **Use For**: Contract generation, schema validation, SLA monitoring
- **Model**: Claude 3.5 Sonnet
- **Skills**: json-formatter-skill, mermaid-diagrams-skill

#### data-contract-formatter-agent
- **Purpose**: Format and validate ODCS v3.1.0 contracts
- **Use For**: Contract formatting, YAML validation, compliance checks
- **Model**: Claude 3.5 Sonnet

### Architecture & Design Agents

#### medallion-architecture-agent
- **Purpose**: Comprehensive medallion architecture guidance
- **Use For**: Pipeline design, layer placement, naming conventions
- **Model**: Claude 3.5 Sonnet
- **Skills**: mermaid-diagrams-skill, pdf-creator-skill

#### dimensional-modeling-agent
- **Purpose**: Kimball dimensional modeling for Gold layer
- **Use For**: Star schemas, fact/dimension design, SCD patterns
- **Model**: Claude 3.5 Sonnet

#### silver-data-modeling-agent
- **Purpose**: Entity-centric modeling for Silver layer
- **Use For**: 3NF design, entity relationships, normalization
- **Model**: Claude 3.5 Sonnet

#### decision-documenter-agent
- **Purpose**: Document architectural decisions (ADRs)
- **Use For**: Architecture decisions, technical choices, tradeoff analysis
- **Model**: Claude 3.5 Sonnet

### Data Discovery & Analysis Agents

#### unity-catalog-agent
- **Purpose**: Navigate Unity Catalog, query system tables
- **Use For**: Metadata queries, lineage analysis, table discovery
- **Model**: Claude 3.5 Sonnet

#### bronze-table-finder-agent
- **Purpose**: Identify candidate Bronze tables for Silver transformations
- **Use For**: Source table recommendations, schema analysis
- **Model**: Claude 3.5 Sonnet

#### data-profiler-agent
- **Purpose**: Generate data profiling reports
- **Use For**: Statistical analysis, quality assessment, nested column analysis
- **Model**: Claude 3.5 Sonnet

### Quality & Validation Agents

#### transformation-validation-agent
- **Purpose**: Validate transformations against standards
- **Use For**: Quality checks, medallion rules, error handling validation
- **Model**: Claude 3.5 Sonnet

#### pyspark-standards-agent
- **Purpose**: Enforce PySpark coding standards
- **Use For**: Import organization, configuration patterns, performance review
- **Model**: Claude 3.5 Sonnet

#### project-code-linter-skill
- **Purpose**: Enforce code quality with Ruff, pytest, YAML/JSON linters
- **Use For**: Code formatting, test structure, configuration validation
- **Type**: Skill (invoked via `/project-code-linter-skill`)

#### project-structure-agent
- **Purpose**: Validate project structure standards
- **Use For**: Directory organization, required files, documentation completeness
- **Model**: Claude 3.5 Sonnet

### Specialized Agents

#### data-naming-agent
- **Purpose**: Name tables, columns, schemas following conventions
- **Use For**: Medallion naming, Unity Catalog naming
- **Model**: Claude 3.5 Sonnet

#### streaming-tables-agent
- **Purpose**: Design streaming tables for real-time ingestion
- **Use For**: Streaming pipelines, continuous processing
- **Model**: Claude 3.5 Sonnet

#### materialized-view-agent
- **Purpose**: Design materialized views for query acceleration
- **Use For**: Pre-computed aggregations, BI optimization
- **Model**: Claude 3.5 Sonnet

#### documentation-agent
- **Purpose**: Create documentation and diagrams
- **Use For**: Architecture docs, API references, Mermaid diagrams
- **Model**: Claude 3.5 Sonnet

#### claude-agent-template-generator
- **Purpose**: Generate new Claude agent templates
- **Use For**: Creating new agents with correct YAML structure
- **Model**: Claude 3.5 Sonnet

### Agent Compliance Requirements

All agent-generated code must:
- Follow the project constitution and all standards
- Respect test directory structure (tests/ mirrors src/)
- Use appropriate testing patterns (Pattern 1-4)
- Include proper docstrings and type hints
- Pass ruff linting and mypy type checking
- Achieve 80%+ test coverage on new code
- Be reviewed by humans before merging

## Configuration Files (Mandatory)

All projects must include these standardized configuration files in the project root:

- **pytest.ini**: Centralized pytest configuration
- **ruff.toml**: Ruff linting and formatting rules
- **.jsonlintrc**: JSON validation rules
- **.yamllint**: YAML linting configuration
- **pyproject.toml**: Poetry dependencies and project metadata
- **.env.example**: Example environment variables (no secrets)

Configuration changes require team review and approval. No local overrides that contradict project standards are permitted.

## Standards Enforcement

### Automated Enforcement
- **CI/CD Checks**: Ruff, mypy, pytest coverage gates
- **Pre-commit Hooks**: Validate code style before commit
- **Type Checkers**: mypy validates type hints
- **Test Coverage**: 80% minimum blocks merge

### Manual Enforcement
- **Code Review Checklist**: Standards verification required
- **Architecture Review**: Required for new features
- **Quarterly Standards Audit**: Team-wide review
- **Documentation Completeness**: Review before merge

### Exception Process
Standards violations require documented justification:
1. **Request**: Document why standard cannot be followed
2. **Review**: Technical lead evaluates impact
3. **Decision**: Approve with time limit or deny
4. **Track**: Log exception in ADR
5. **Remediate**: Create plan to resolve technical debt

## SpecKit Workflow

This project uses SpecKit for feature development:

1. **/speckit.specify**: Create feature specification from natural language
2. **/speckit.plan**: Generate implementation plan and data models
3. **/speckit.tasks**: Break plan into actionable tasks
4. **/speckit.implement**: Execute tasks to produce code
5. **/speckit.analyze**: Validate consistency across artifacts

## Onboarding Checklist

New contributors must complete:

### Read Core Documentation
- [ ] Python standards (`kb://document/python-standards/coding`)
- [ ] PySpark standards (`kb://document/pyspark-standards/configuration`)
- [ ] Medallion architecture (`kb://document/medallion-architecture/layer-specifications`)
- [ ] Unity Catalog Structure (`kb://document/data-platform/catalog-structure`)
- [ ] Databricks System Tables (`kb://document/data-platform/databricks-system-tables`)
- [ ] Data Contracts (`kb://document/data-product-standards/data-contracts`)
- [ ] Data Quality Standards (`kb://document/data-product-standards/data-quality`)
- [ ] Documentation Standards (`kb://document/data-product-standards/documentation`)
- [ ] Project Structure Standards (`kb://document/data-product-standards/project-structure`)
- [ ] Testing Standards (`kb://document/data-product-standards/testing-standards`)
- [ ] Transformation Requirements (`kb://document/data-product-standards/transformation-requirements`)
- [ ] Dimension Design (`kb://document/dimensional-modeling/dimensions`)
- [ ] Fact Table Design (`kb://document/dimensional-modeling/facts`)
- [ ] Dimensional Modeling Naming Conventions (`kb://document/dimensional-modeling/naming-conventions`)
- [ ] Data Domains (`kb://document/medallion-architecture/data-domains`)
- [ ] Data Flows (`kb://document/medallion-architecture/data-flows`)
- [ ] Architecture Design Rationale (`kb://document/medallion-architecture/design-rationale`)
- [ ] Kimball Modeling (`kb://document/medallion-architecture/kimball-modeling`)
- [ ] Layer Specifications (`kb://document/medallion-architecture/layer-specifications`)
- [ ] Medallion Naming Conventions (`kb://document/medallion-architecture/naming-conventions`)
- [ ] Table Categories (`kb://document/medallion-architecture/table-categories`)
- [ ] Technical Standards (`kb://document/medallion-architecture/technical-standards`)
- [ ] Lakeflow Pipelines (`kb://document/pipeline/lakeflow-pipelines`)
- [ ] Materialized Views (`kb://document/pipeline/materialized-views`)
- [ ] Streaming Tables (`kb://document/pipeline/streaming-tables`)
- [ ] PySpark Overview (`kb://document/pyspark-standards/README`)
- [ ] PySpark Configuration (`kb://document/pyspark-standards/configuration`)
- [ ] Data Coverage Instructions (`kb://document/pyspark-standards/data_coverage_instructions`)
- [ ] Import Organization Rules (`kb://document/pyspark-standards/import-organization-rule`)
- [ ] Python Coding Standards (`kb://document/python-standards/coding`)
- [ ] Test Directory Structure (`kb://document/python-standards/testing_structure`)


### Setup Development Environment
- [ ] Install Poetry and pyenv (Python 3.10+)
- [ ] Install pre-commit hooks
- [ ] Setup Databricks CLI
- [ ] Configure local Spark for testing

### Complete Tutorial
- [ ] Create sample Bronze ingestion job
- [ ] Implement Silver transformation with tests
- [ ] Build Gold aggregation
- [ ] Deploy via Databricks Asset Bundle

## Project Status

**Version**: 1.0
**Last Updated**: 2026-01-22
**Status**: Active Development
**License**: Proprietary (Skyscanner Internal)
