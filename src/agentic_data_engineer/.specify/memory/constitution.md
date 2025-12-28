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

#### 4 Core Testing Patterns for PySpark Transformations

All tests must follow one or more of these proven patterns:

**Pattern 1: Parametrized Scenario Testing**
- Use for testing multiple distinct input scenarios systematically
- Test happy path, edge cases, and boundary conditions
- Use `Scenarios` helper from `tests.parametrize_helpers`
- Example: Empty input, single record, multiple records, boundary values

**Pattern 2: Data Quality Validation**
- Use for validating transformation output quality
- Validate: row counts, nulls, duplicates, schema, value ranges
- Use assertion helpers: `assert_row_count`, `assert_no_nulls`, `assert_no_duplicates`, `assert_columns_equal`, `assert_values_in_range`
- Each assertion can include `test_id` for debugging
- Example: Ensure enriched table has no null PKs, correct column set, no duplicates

**Pattern 3: Scale Testing**
- Use for testing at different data volumes (0, 1, 10, 100, 1000+ rows)
- Parametrize with `@pytest.mark.parametrize("row_count", [...])`
- Validate behavior and performance at each scale
- Example: Aggregation works correctly with empty, small, and large datasets

**Pattern 4: Error Condition Testing**
- Use for testing error handling and validation logic
- Test business rule violations, schema mismatches, invalid inputs
- Use `pytest.raises(expected_error)` to verify exceptions
- Example: Null keys should raise ValueError, duplicates should raise error

**Combining Patterns**: Mix patterns as needed (e.g., scenarios with quality checks, scale with quality validation)

#### Test Structure Requirements

- **Test Organization**: Mirror `src/` structure exactly in `tests/` directory
- **Test Naming**: Use `test_<function>_<scenario>` or `test_<function>_quality`, `test_<function>_scenarios`, `test_<function>_scale`, `test_<function>_errors`
- **Test Classes**: Group related tests with `class Test<FunctionName>`
- **Arrange-Act-Assert**: Clear structure: setup (Arrange) → execute (Act) → validate (Assert)
- **One Concept per Test**: Each test validates one thing
- **Independent Tests**: Tests must not depend on each other
- **Use Fixtures**: Share common setup via pytest fixtures in `tests/conftest.py`

#### Test Coverage Checklist

For each transformation, ensure coverage of the 10 data coverage dimensions:

**1. Schema Coverage**
- ✅ Column presence, data types, nullability constraints
- ✅ Primary/unique key constraints
- ✅ Partition columns, nested structures
- ✅ Schema evolution cases

**2. Distribution Coverage**
- ✅ Min/max values, normal ranges
- ✅ Long-tail values, outliers
- ✅ Zero-variance columns, value drift scenarios

**3. Logical/Domain Rule Coverage**
- ✅ Business logic rules (eligibility, mappings, conversions)
- ✅ Derived fields, conditional logic
- ✅ Rule-based quality checks

**4. Edge Case Coverage**
- ✅ Empty datasets, single-row datasets
- ✅ Very large datasets, high-null columns
- ✅ Duplicate rows, invalid types, unexpected categories

**5. Temporal Coverage**
- ✅ Old/recent/future timestamps
- ✅ Daylight savings transitions
- ✅ End-of-month/quarter boundaries, skewed time distributions

**6. Cross-Field Relationship Coverage**
- ✅ Referential integrity, derived correctness
- ✅ Multi-column uniqueness, consistency checks

**7. Negative Coverage (Invalid Data)**
- ✅ Wrong types, malformed records
- ✅ Missing required fields, constraint violations
- ✅ Corrupted payloads, impossible/illogical values

**8. Volume Coverage**
- ✅ Very small datasets, medium datasets
- ✅ Large datasets (millions of rows)
- ✅ Highly skewed partitions, shuffle-heavy operations

**9. Environment Coverage**
- ✅ Local execution, test cluster, production-like cluster
- ✅ Configuration variations, dependency version variations

**10. Pipeline Coverage (End-to-End)**
- ✅ Input ingestion, transformations, aggregations
- ✅ Output schema validation, data quality rules
- ✅ Metadata propagation, data contract enforcement

#### Test Dimensions Taxonomy

For systematic test case design, use these dimension categories when generating test data and scenarios:

**Volume/Scale Dimensions**
- **CARDINALITY**: `empty` | `single` | `few` | `many` (0, 1, 2-10, 100+ rows)
- **SCALE**: `small` | `medium` | `large` | `very_large` (100-1K, 1K-100K, 100K-1M, 1M+ rows)

**Data Quality Dimensions**
- **NULL_HANDLING**: `no_nulls` | `some_nulls` | `all_nulls` | `mixed_nulls`
- **DATA_TYPES**: `string` | `numeric` | `date` | `boolean` | `nested` | `decimal` | `timestamp`
- **STRING_VARIANTS**: `empty_string` | `whitespace` | `special_chars` | `unicode` | `long_strings`

**Business Logic Dimensions**
- **GROUPING**: `no_groups` | `single_group` | `multiple_groups` | `skewed_groups`
- **AGGREGATION**: `sum` | `count` | `avg` | `min` | `max` | `distinct` | `concat`
- **TIME_PARTITIONING**: `single_date` | `multiple_dates` | `date_range` | `overlapping_ranges` | `gaps`

**Edge Cases Dimensions**
- **EDGE_CASES**: `duplicates` | `outliers` | `extreme_values` | `boundary_values` | `contradictions`
- **SCHEMA_VARIANTS**: `all_required` | `missing_fields` | `extra_fields` | `nested_structures` | `schema_mismatch`

When generating tests, apply relevant dimensions to create comprehensive test datasets covering all aspects of the data pipeline.

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
- NO Broadcast joins for small tables
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

### Standardized Tool Configuration (NON-NEGOTIABLE)
All projects must use centralized configuration files for tooling consistency and maintainability.

**Required Configuration Files:**
- **pytest.ini**: Centralized pytest configuration (test discovery, markers, coverage settings, output formatting)
- **ruff.toml**: Ruff linting and formatting rules (line length, indent style, enabled rules, exclusions)
- **.jsonlintrc**: JSON validation rules (schema validation, formatting standards)
- **.yamllint**: YAML linting configuration (indentation, key ordering, line length, document standards)

**Configuration File Requirements:**
- All configuration files must be in the project root directory
- Configuration must be version-controlled (committed to git)
- Tool-specific settings must NOT be in `pyproject.toml` if a dedicated config file exists
- No local overrides that contradict project standards
- Configuration changes require team review and approval
- All developers must respect these configurations (no `--ignore-config` flags)

**Benefits:**
- Consistent code quality across all environments
- Reduced cognitive load (one source of truth)
- Easier onboarding (standard tooling setup)
- CI/CD alignment (same rules locally and in pipelines)
- Better IDE integration with standardized configurations

### Python Standards
- Src layout structure (mandatory)
- Poetry for dependency management
- Type hints on all public APIs
- Google-style docstrings complete
- Ruff for linting and formatting (configured via ruff.toml)
- Mypy for type checking
- pytest with 80%+ coverage (configured via pytest.ini)
- Pydantic for configuration

#### Test Directory Structure (Mandatory)
The `tests/` directory must mirror the `src/` directory structure exactly:

**Directory Mirroring Rules:**
- Every Python module under `src/` must have a corresponding test module under `tests/`
- Subpackage hierarchies in `src/` must be replicated exactly in `tests/`
- Test files must be named `test_<module>.py` for each `<module>.py` in `src/`

**Example:**
```
src/
  package_a/
    module_x.py
    module_y.py
  package_b/
    utils/
      transform.py

tests/
  package_a/
    test_module_x.py
    test_module_y.py
  package_b/
    utils/
      test_transform.py
```

**Enforcement:**
- Tests must **never** be stored inside `src/`
- New modules in `src/` automatically generate test scaffolds in `tests/`
- When source files are updated or renamed, test files must be updated/renamed accordingly
- When source files are removed, corresponding test files must be removed
- If inconsistency exists between `src/` and `tests/`, `src/` is the source of truth and `tests/` must be aligned

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
- [ ] Passes ruff linting (using ruff.toml configuration)
- [ ] Passes mypy type checking
- [ ] Unit tests written (80%+ coverage, using pytest.ini configuration)
- [ ] No hardcoded credentials or configs
- [ ] Uses Pydantic for configuration
- [ ] Required config files present: pytest.ini, ruff.toml, .jsonlintrc, .yamllint
- [ ] All JSON files pass .jsonlintrc validation
- [ ] All YAML files pass .yamllint validation

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

### Knowledge Base (MCP Server)

Access knowledge base documents via the `kb://` URI scheme:

**Data Platform**
- `kb://document/data-platform/catalog-structure` - Unity Catalog structure
- `kb://document/data-platform/databricks-system-tables` - System tables reference

**Data Product Standards**
- `kb://document/data-product-standards/data-contracts` - Data contracts
- `kb://document/data-product-standards/data-quality` - Data quality rules
- `kb://document/data-product-standards/documentation` - Documentation standards
- `kb://document/data-product-standards/project-structure` - Project structure
- `kb://document/data-product-standards/testing-standards` - Testing standards
- `kb://document/data-product-standards/transformation-requirements` - Transformation requirements

**Dimensional Modeling**
- `kb://document/dimensional-modeling/dimensions` - Dimension design
- `kb://document/dimensional-modeling/facts` - Fact table design
- `kb://document/dimensional-modeling/naming-conventions` - Naming conventions

**Medallion Architecture**
- `kb://document/medallion-architecture/data-domains` - Data domains
- `kb://document/medallion-architecture/data-flows` - Data flows
- `kb://document/medallion-architecture/design-rationale` - Architectural rationale
- `kb://document/medallion-architecture/kimball-modeling` - Kimball modeling
- `kb://document/medallion-architecture/layer-specifications` - Bronze/Silver/Gold specs
- `kb://document/medallion-architecture/naming-conventions` - Naming standards
- `kb://document/medallion-architecture/table-categories` - Table categories
- `kb://document/medallion-architecture/technical-standards` - Tech stack decisions

**Pipeline**
- `kb://document/pipeline/lakeflow-pipelines` - Lakeflow pipelines
- `kb://document/pipeline/materialized-views` - Materialized views
- `kb://document/pipeline/streaming-tables` - Streaming tables

**PySpark Standards**
- `kb://document/pyspark-standards/README` - PySpark overview
- `kb://document/pyspark-standards/configuration` - Spark/Databricks config
- `kb://document/pyspark-standards/data_coverage_instructions` - Data coverage dimensions
- `kb://document/pyspark-standards/import-organization-rule` - Import organization

**Python Standards**
- `kb://document/python-standards/coding` - Python/Poetry/Pydantic standards
- `kb://document/python-standards/testing_structure` - Test directory structure

### Key Standards Documents
1. **Python Project Structure Standards** (`kb://document/python-standards/coding`) - Src layout, Poetry, Google docstrings, Pydantic Settings
2. **Test Directory Structure** (`kb://document/python-standards/testing_structure`) - Mandatory tests/ mirroring of src/ structure, test file naming, enforcement rules
3. **Testing Patterns & Best Practices** (Section V above) - 4 core patterns for PySpark tests, structure requirements, coverage checklist
4. **Data Coverage Dimensions** (`kb://document/pyspark-standards/data_coverage_instructions`) - 10 dimensions for comprehensive test data coverage (schema, distribution, logic, edges, temporal, cross-field, negative, volume, environment, pipeline)
5. **PySpark Configuration Standards** (`kb://document/pyspark-standards/configuration`) - Spark session, configs, Unity Catalog, Asset Bundles
6. **Medallion Architecture** (`kb://document/medallion-architecture/layer-specifications`) - Layer specs, naming, technical standards, design rationale
7. **Dimensional Modeling** (`kb://document/dimensional-modeling/dimensions`, `kb://document/dimensional-modeling/facts`) - Dimension/fact table design, SCD patterns

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

## AI-Assisted Development with Agents

The project provides specialized AI agents to assist with development tasks while maintaining standards compliance.

### Available Agents

**testing-agent** (Model: Claude 3.5 Sonnet)
- Use for writing comprehensive unit and end-to-end tests for PySpark transformations
- Applies 4 core testing patterns: parametrized scenarios, data quality, scale, error conditions
- Handles test file organization, fixture creation, and assertion helpers
- When to use: Writing tests for data transformations, adding quality validation tests, creating parametrized test suites, testing error handling
- Output: Well-structured test code following Skyscanner testing patterns with 80%+ coverage

### Agent Compliance

All agent-generated code must:
- Follow this constitution and all standards
- Respect test directory structure requirements (tests/ mirrors src/)
- Use appropriate testing patterns (Pattern 1-4)
- Include proper docstrings and type hints
- Pass ruff linting and mypy type checking
- Achieve 80%+ test coverage on new code
- Be reviewed by humans before merging

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

**Version**: 1.1 | **Ratified**: 2025-11-30 | **Last Amended**: 2025-11-30
