# Agentic Data Engineer Constitution

## Core Principles

### I. Standards-First Development (NON-NEGOTIABLE)
All development must adhere to established standards before implementation begins.

- Documentation precedes implementation
- Standards are living documents, continuously improved
- Consistency enforced across all projects and components
- Standards cover: architecture, code style, naming, configuration, testing
- Code reviews enforce compliance; automated tooling validates adherence (ruff, mypy, pytest)
- Standards violations block merges

### II. AI-Native by Design
The framework must be optimized for AI-assisted development and operation.

- Clear, structured documentation for LLM consumption
- Modular, composable components with explicit type hints
- Google-style docstrings with complete context
- Type-safe configuration management (Pydantic)
- Declarative over imperative where possible
- Configuration-driven behavior with rich metadata and lineage tracking

### III. Medallion Architecture Adherence (NON-NEGOTIABLE)
Strict compliance with Medallion Architecture (Bronze/Silver/Gold) patterns.

- Bronze: Raw data ingestion, minimal transformation
- Silver: Cleaned, conformed, entity-centric (3NF)
- Gold: Business-ready, aggregated, dimensional models
- No layer skipping or shortcuts; clear separation of concerns
- Unity Catalog for all data access (Bronze onwards)
- Delta Lake format mandatory (Bronze onwards)
- Table-based access only (no direct S3/DBFS)
- Proper metadata and lineage tracking

### IV. Type Safety and Validation (NON-NEGOTIABLE)
Embrace strong typing and validation to catch errors early.

- Type hints on all functions, methods, and variables
- Pydantic for configuration and data validation
- Schema enforcement at ingestion
- Fail fast on validation errors
- Tools: mypy (static), Pydantic (runtime), PySpark schema validation
- Unit tests with type coverage

### V. Test-First Development (NON-NEGOTIABLE)
Every component must be testable and tested before deployment.

- Unit tests for all business logic (80% minimum coverage)
- Integration tests for data pipelines (critical paths)
- Test data fixtures and factories
- Tests run in CI/CD
- Testing stack: pytest, pytest-cov, local Spark for unit tests
- Test environments mirror production

### VI. Configuration Over Code
Behavior should be configurable without code changes.

- Environment-specific configs (dev/staging/prod) via YAML
- 12-factor app compliance
- Secrets in secret managers, never in code
- Configuration hierarchy: Environment variables (highest) → .env files → YAML → Code defaults (lowest)
- Pydantic Settings for type-safe configuration

### VII. Security and Governance (NON-NEGOTIABLE)
Security and governance are non-negotiable requirements.

- Principle of least privilege
- No hardcoded credentials
- Unity Catalog for access control
- Audit logging enabled
- Data classification respected
- Service principals for production jobs
- Secrets in Databricks Secrets/cloud KMS
- PII/sensitive data marked and protected

### VIII. Observability and Debugging
Systems must be observable and debuggable.

- Structured logging (JSON in production)
- Metrics collection and distributed tracing where applicable
- Clear error messages with context
- Log levels: DEBUG (dev), INFO (staging), WARN (prod)
- Correlation IDs for request tracking

### IX. Performance and Cost Efficiency
Optimize for both performance and cost.

- Adaptive Query Execution (AQE) enabled
- Appropriate partitioning, bucketing, and Z-ordering
- Delta Lake optimization (OPTIMIZE, VACUUM)
- Broadcast joins for small tables
- Autoscaling where appropriate
- Cost monitoring and alerts

### X. Documentation as Code
Documentation is a first-class deliverable.

- Google-style docstrings mandatory
- README in every module
- Architecture decision records (ADRs) for significant changes
- Inline code comments for complex logic only
- Knowledge base continuously updated
- Documentation types: API (auto-generated), architecture, runbooks, standards, examples

## Technology Stack Requirements

### Mandatory Technologies
- **Language**: Python 3.10+ (Databricks Runtime compatibility)
- **Framework**: PySpark 3.4+
- **Platform**: Databricks
- **Storage**: Delta Lake on AWS S3
- **Governance**: Unity Catalog
- **Package Management**: Poetry
- **Configuration**: Pydantic Settings
- **Documentation**: Google-style docstrings
- **Project Layout**: Src layout (mandatory)

### Prohibited Technologies
- R/SparkR (no team expertise)
- Scala (no team expertise)
- Direct DBFS access (must use Unity Catalog)
- XML, Excel, PDF formats (unsupported in Bronze layer)
- Flat layout (use src layout)
- setup.py (use pyproject.toml with Poetry)

## Code Quality Standards

### Python Standards
- Src layout structure (mandatory)
- Poetry for dependency management
- Type hints on all public APIs
- Google-style docstrings complete
- Ruff for linting and formatting
- Mypy for type checking
- pytest with 80%+ coverage
- Pydantic for configuration

### PySpark Standards
- Environment-specific Spark configurations
- SparkSession utilities with configuration injection
- DataFrame transformations as pure functions
- No hardcoded table paths
- Unity Catalog three-level namespace (catalog.schema.table)
- Configuration externalized to YAML/env vars

### Naming Conventions
**Python:**
- `snake_case`: functions, variables, modules
- `PascalCase`: classes
- `UPPER_CASE`: constants
- Prefix private: `_private_func`

**Data Assets:**
- Bronze: `bronze.<domain>_<entity>`
- Silver: `silver.<entity>` (3NF, entity-centric)
- Gold: `gold.<business_area>_<purpose>`
- Catalog names: `<env>_catalog` (dev_catalog, prod_catalog)

## Anti-Patterns (Prohibited)

### Code Anti-Patterns
- ❌ Hardcoded configuration values
- ❌ Missing type hints on public APIs
- ❌ No docstrings on public functions/classes
- ❌ Direct file system access (S3/DBFS)
- ❌ Mutable default arguments
- ❌ Bare except clauses
- ❌ Global state manipulation

### Data Anti-Patterns
- ❌ Skipping Bronze layer (direct to Silver/Gold)
- ❌ Non-Delta tables in Bronze/Silver/Gold
- ❌ SELECT * in production pipelines
- ❌ Missing partition columns on large tables
- ❌ No schema evolution strategy
- ❌ Undocumented table purposes
- ❌ Orphaned tables (no ownership)

### Configuration Anti-Patterns
- ❌ Credentials in code or configs
- ❌ Environment-specific code branches
- ❌ Hardcoded catalog/schema names
- ❌ Missing .env.example file
- ❌ Secrets in version control
- ❌ No validation on required configs

## Acceptance Criteria Checklist

All contributions must meet these criteria:

### Code Quality
- [ ] Follows src layout structure
- [ ] Type hints on all public APIs
- [ ] Google-style docstrings complete
- [ ] Passes ruff linting
- [ ] Passes mypy type checking
- [ ] Unit tests written (80%+ coverage)
- [ ] No hardcoded credentials or configs
- [ ] Uses Pydantic for configuration

### PySpark Compliance
- [ ] Uses SparkSession utilities
- [ ] Configuration externalized
- [ ] Unity Catalog for data access
- [ ] Delta Lake format
- [ ] Proper error handling
- [ ] Logging implemented
- [ ] Follows layer specifications

### Documentation
- [ ] README updated if needed
- [ ] Docstrings complete and accurate
- [ ] Configuration documented
- [ ] Examples provided
- [ ] Knowledge base updated if standards change

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass (if applicable)
- [ ] Test fixtures proper
- [ ] Coverage target met (80%+)
- [ ] Tests run in CI

### Data Quality
- [ ] Schema defined and enforced
- [ ] Data quality checks implemented
- [ ] Metadata columns present
- [ ] Table documented in catalog
- [ ] Owner assigned

## Reference Documentation

### Knowledge Base Structure
```
docs/
├── constitution.md                     # This file
├── knowledge_base/
│   ├── python-standards/
│   │   └── coding.md                  # Python/Poetry/Pydantic standards
│   ├── pyspark-standards/
│   │   ├── README.md                  # PySpark overview
│   │   └── configuration.md           # Spark/Databricks config
│   ├── medallion-architecture/
│   │   ├── layer-specifications.md    # Bronze/Silver/Gold specs
│   │   ├── naming-conventions.md      # Naming standards
│   │   ├── technical-standards.md     # Tech stack decisions
│   │   └── design-rationale.md        # Architectural rationale
│   ├── dimensional-modeling/
│   │   ├── dimensions.md              # Dimension design
│   │   └── facts.md                   # Fact table design
│   └── data-platform/
│       ├── catalog-structure.md       # Unity Catalog structure
│       └── databricks-system-tables.md
└── adr/                                # Architecture Decision Records
```

### Key Standards Documents
1. **[Python Project Structure Standards](./knowledge_base/python-standards/coding.md)** - Src layout, Poetry, Google docstrings, Pydantic Settings
2. **[PySpark Configuration Standards](./knowledge_base/pyspark-standards/configuration.md)** - Spark session, configs, Unity Catalog, Asset Bundles
3. **[Medallion Architecture](./knowledge_base/medallion-architecture/)** - Layer specs, naming, technical standards, design rationale
4. **[Dimensional Modeling](./knowledge_base/dimensional-modeling/)** - Dimension/fact table design, SCD patterns

## Governance

### Constitution Authority
- This constitution supersedes all other practices and guidelines
- All PRs and code reviews must verify compliance
- Complexity or deviations must be justified in writing
- Use knowledge base documents for detailed implementation guidance

### Amendment Process
1. Propose change via PR with rationale
2. Team review and discussion (requires consensus for core principles)
3. Update affected documentation and knowledge base
4. Communicate to all stakeholders
5. Grace period for adaptation (2 weeks minimum)

### Compliance Enforcement
**Automated:**
- CI/CD checks enforce standards (ruff, mypy, pytest coverage)
- Pre-commit hooks validate code style
- Type checkers validate type hints
- Test coverage gates block merges

**Manual:**
- Code review checklist verification
- Architecture review for new features
- Quarterly standards audit
- Documentation completeness review

### Exception Process
Standards violations require documented justification:

1. **Request**: Document why standard cannot be followed with technical rationale
2. **Review**: Technical lead evaluates impact and alternatives
3. **Decision**: Approve with time limit or deny with explanation
4. **Track**: Log exception in Architecture Decision Record (ADR)
5. **Remediate**: Create plan to resolve technical debt with timeline

## Onboarding Requirements

New contributors must complete:

1. **Read Core Documentation**
   - [ ] This constitution
   - [ ] Python standards (coding.md)
   - [ ] PySpark standards (configuration.md)
   - [ ] Medallion architecture overview

2. **Setup Development Environment**
   - [ ] Install Poetry and pyenv (Python 3.10+)
   - [ ] Install pre-commit hooks
   - [ ] Setup Databricks CLI
   - [ ] Configure local Spark for testing

3. **Complete Tutorial**
   - [ ] Create sample Bronze ingestion job
   - [ ] Implement Silver transformation with tests
   - [ ] Build Gold aggregation
   - [ ] Deploy via Databricks Asset Bundle

**Version**: 1.0 | **Ratified**: 2025-11-30 | **Last Amended**: 2025-11-30
