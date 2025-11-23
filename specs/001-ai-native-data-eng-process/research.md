# Research & Technical Decisions

**Feature**: AI-Native Data Engineering Process for Databricks
**Date**: 2025-11-21
**Status**: Complete

## Overview

This document captures research findings and technical decisions for implementing an AI-Native data engineering process on Databricks. Each section addresses a specific technical question identified during planning, provides the selected approach, rationale, and alternatives considered.

---

## 1. Spark Session Management

### Decision

Implement a **Factory Pattern with Environment-Aware Configuration** using a centralized `SparkSessionFactory` class in the shared utilities library.

### Approach

```python
# databricks_utils/config/spark_session.py
class SparkSessionFactory:
    @staticmethod
    def create(env: str, config_path: Optional[str] = None) -> SparkSession:
        """
        Creates SparkSession based on environment type.

        Args:
            env: Environment type (local, lab, dev, prod)
            config_path: Optional path to config file (auto-detected if None)

        Returns:
            Configured SparkSession instance
        """
        config = ConfigLoader.load(env, config_path)

        if env == "local":
            return SparkSessionFactory._create_local(config)
        else:
            return SparkSessionFactory._create_databricks(config)
```

**Configuration Structure** (YAML):
```yaml
# config/local.yaml
spark:
  app_name: "pipeline-local"
  master: "local[*]"
  config:
    spark.sql.shuffle.partitions: "4"
    spark.sql.adaptive.enabled: "true"

catalog:
  name: "local_catalog"
  schema: "dev_schema"

# config/prod.yaml
spark:
  app_name: "pipeline-prod"
  # master is omitted - Databricks provides cluster
  config:
    spark.sql.shuffle.partitions: "200"
    spark.sql.adaptive.enabled: "true"
    spark.databricks.delta.optimizeWrite.enabled: "true"

catalog:
  name: "prod_catalog"
  schema: "prod_schema"
```

### Rationale

- **Single Entry Point**: All projects use same factory, ensuring consistency
- **Environment Isolation**: Configuration files prevent cross-environment data access
- **Local Development**: Full Spark functionality available locally without Databricks
- **Runtime Detection**: Can detect Databricks environment automatically via environment variables
- **Testability**: Easy to mock SparkSession in tests

### Alternatives Considered

1. **Environment Variables Only**: Rejected - too verbose, hard to version control, error-prone
2. **Databricks Secrets**: Rejected for base config - secrets are for credentials, not structural config
3. **Code-based Configuration**: Rejected - violates environment parity principle, requires code changes per environment
4. **Separate Entry Points per Environment**: Rejected - increases maintenance burden, code duplication

---

## 2. Shared Utility Distribution

### Decision

Use **PyPI Private Repository** (e.g., Artifactory, Nexus, or AWS CodeArtifact) for distributing shared utilities, with Databricks Libraries for cluster installation.

### Approach

**Publishing Workflow**:
1. Version shared utilities library with semantic versioning
2. Build wheel package: `python -m build`
3. Publish to private PyPI: `twine upload --repository-url https://pypi.company.com dist/*`
4. Specify version in project's `requirements.txt` or `pyproject.toml`

**Consumption in Pipeline Projects**:
```toml
# pyproject.toml
[project]
dependencies = [
    "databricks-utils==1.2.3",  # Pin to specific version
    "pyspark>=3.4.0",
]
```

**Databricks Asset Bundle Integration**:
```yaml
# databricks/bundle.yml
resources:
  jobs:
    pipeline_job:
      libraries:
        - pypi:
            package: "databricks-utils==1.2.3"
```

### Rationale

- **Standard Python Workflow**: Familiar to all Python developers
- **Version Control**: Explicit version pinning prevents breaking changes
- **Dependency Resolution**: pip/poetry handle transitive dependencies
- **CI/CD Integration**: Easy to integrate into build pipelines
- **Rollback Support**: Can revert to previous versions instantly

### Alternatives Considered

1. **Git Submodules**: Rejected - creates tight coupling, difficult version management, merge conflicts
2. **Databricks Repos**: Rejected - limited to Databricks environment, no local development support
3. **Copy-Paste**: Rejected - defeats entire purpose of shared utilities, no version control
4. **Monorepo**: Rejected - conflicts with multi-repository architecture requirement

---

## 3. Agent Integration Architecture

### Decision

Implement agents as **CLI Tools with MCP (Model Context Protocol) Support**, enabling both standalone usage and IDE integration.

### Approach

**Agent as CLI Tool**:
```bash
# Coding agent usage
databricks-agent code \
  --type bronze \
  --source "s3://raw-data/customers" \
  --target "catalog.schema.bronze_customers" \
  --description "Ingest customer data with schema validation"

# Testing agent usage
databricks-agent test \
  --target-file src/transformations/bronze/customers.py \
  --output tests/unit/test_customers.py
```

**Agent Architecture**:
```
databricks-ai-agents/
├── cli/
│   └── main.py              # Click CLI entrypoint
├── agents/
│   ├── base.py              # Abstract base class
│   ├── coding_agent.py      # Concrete implementation
│   ├── testing_agent.py
│   └── profiling_agent.py
├── prompts/
│   └── [medallion layer templates]
└── mcp/
    └── server.py            # MCP server for IDE integration
```

**MCP Integration** (for Claude Code, Cursor, etc.):
```json
// .mcp.json
{
  "servers": {
    "databricks-agents": {
      "command": "databricks-agent",
      "args": ["serve"],
      "env": {}
    }
  }
}
```

### Rationale

- **Flexibility**: Works standalone, in CI/CD, and in IDEs
- **Standardization**: MCP is emerging standard for AI tool integration
- **Composability**: Agents can be chained in scripts
- **Auditability**: CLI produces logs of all agent interactions
- **Developer Choice**: Developers choose their preferred interface

### Alternatives Considered

1. **Jupyter Notebook Widgets**: Rejected - limited to notebook environment, not portable
2. **VS Code Extension Only**: Rejected - locks into specific IDE
3. **Web Service**: Rejected - adds infrastructure complexity, latency, authentication overhead
4. **Direct LLM API Calls**: Rejected - inconsistent prompting, no shared context, cost tracking difficult

---

## 4. Configuration Management

### Decision

Use **Pydantic for Schema Validation** with **YAML for Configuration Files**, implementing hierarchical config merging (defaults → environment → overrides).

### Approach

**Configuration Schema** (Pydantic):
```python
from pydantic import BaseModel, Field
from typing import Dict, Optional

class SparkConfig(BaseModel):
    app_name: str
    master: Optional[str] = None
    config: Dict[str, str] = Field(default_factory=dict)

class CatalogConfig(BaseModel):
    name: str
    schema_: str = Field(alias="schema")

class EnvironmentConfig(BaseModel):
    environment: str
    spark: SparkConfig
    catalog: CatalogConfig
    monte_carlo: Optional[Dict[str, str]] = None
```

**Configuration Loader**:
```python
class ConfigLoader:
    @staticmethod
    def load(env: str, path: Optional[str] = None) -> EnvironmentConfig:
        # 1. Load defaults
        base = yaml.safe_load(open("config/defaults.yaml"))

        # 2. Load environment-specific
        env_config = yaml.safe_load(open(f"config/{env}.yaml"))

        # 3. Merge (env overrides base)
        merged = {**base, **env_config}

        # 4. Validate with Pydantic
        return EnvironmentConfig(**merged)
```

### Rationale

- **Type Safety**: Pydantic catches config errors at load time, not runtime
- **IDE Support**: Autocomplete and type hints for configuration objects
- **Validation**: Built-in validation rules (required fields, format checks)
- **Environment Variables**: Pydantic supports env var substitution
- **Human Readable**: YAML is easy to read and edit

### Alternatives Considered

1. **JSON**: Rejected - no comments, less readable for complex configs
2. **Python Config Files**: Rejected - security risk, harder to parse/validate
3. **TOML**: Considered - good option, but YAML more familiar to data engineers
4. **Environment Variables Only**: Rejected - too many variables, hard to track

---

## 5. Unity Catalog Patterns

### Decision

Implement **Environment-Prefixed Naming Convention** with **Catalog-per-Environment** strategy.

### Approach

**Naming Convention**:
```
{environment}_{catalog}.{project}_{layer}.{table}

Examples:
- dev_analytics.customer_360_bronze.raw_customers
- prod_analytics.customer_360_silver.cleaned_customers
- lab_analytics.customer_360_gold.customer_lifetime_value
```

**Catalog Structure**:
```
Catalogs:
├── dev_analytics       (dev environment)
├── prod_analytics      (prod environment)
├── lab_analytics       (lab/staging)
└── local_catalog       (local development - optional)

Each Catalog Contains:
├── {project}_bronze/   (raw data)
├── {project}_silver/   (cleaned/conformed)
└── {project}_gold/     (aggregated/business)
```

**Permission Model**:
- **Bronze**: Read by all, write by ingestion service accounts
- **Silver**: Read by all, write by transformation jobs
- **Gold**: Read by all, write by aggregation jobs, BI tools have SELECT only

**Implementation Helper**:
```python
class CatalogHelper:
    def __init__(self, config: EnvironmentConfig):
        self.catalog = config.catalog.name
        self.schema_prefix = config.catalog.schema_

    def table_name(self, layer: str, table: str) -> str:
        """Generate fully-qualified table name"""
        return f"{self.catalog}.{self.schema_prefix}_{layer}.{table}"
```

### Rationale

- **Environment Isolation**: Impossible to accidentally query prod from dev
- **Clear Lineage**: Naming convention shows data flow (bronze → silver → gold)
- **Permission Simplicity**: Catalog-level permissions prevent cross-environment access
- **Scale**: Supports multiple projects in same catalog with schema separation

### Alternatives Considered

1. **Single Catalog with Schema per Environment**: Rejected - harder permission management, more error-prone
2. **Table Name Suffixes** (e.g., `customers_dev`): Rejected - clutters namespace, hard to query
3. **Workspace per Environment**: Rejected - too much infrastructure overhead
4. **Unity Catalog Tags for Environment**: Rejected - tags are metadata, not access control

---

## 6. Asset Bundle Strategy

### Decision

Use **Template-Based Bundle Configuration** with **Environment-Specific Variable Files** and **Shared Utility Bundling via PyPI Dependencies**.

### Approach

**Bundle Structure**:
```yaml
# databricks/bundle.yml
bundle:
  name: customer-360-pipeline

variables:
  environment:
    description: "Deployment environment"
    default: "dev"

targets:
  dev:
    mode: development
    workspace:
      host: https://dev.cloud.databricks.com
    variables:
      catalog: "dev_analytics"

  prod:
    mode: production
    workspace:
      host: https://prod.cloud.databricks.com
    variables:
      catalog: "prod_analytics"

resources:
  jobs:
    customer_360:
      name: "customer-360-${var.environment}"
      tasks:
        - task_key: bronze_ingest
          libraries:
            - pypi:
                package: "databricks-utils==1.2.3"
          python_file: src/transformations/bronze/ingest.py
```

**Deployment Workflow**:
```bash
# Validate bundle
databricks bundle validate

# Deploy to dev
databricks bundle deploy -t dev

# Deploy to prod
databricks bundle deploy -t prod
```

### Rationale

- **Infrastructure as Code**: Bundle config is versioned with pipeline code
- **Environment Consistency**: Same bundle structure across all environments
- **Dependency Management**: Libraries automatically installed on cluster
- **Rollback Support**: Git revert + redeploy restores previous version
- **CI/CD Ready**: Easy to integrate into GitHub Actions/GitLab CI

### Alternatives Considered

1. **Manual Deployment Scripts**: Rejected - error-prone, no validation, hard to maintain
2. **Terraform**: Rejected - Asset Bundles are Databricks-native, better integration
3. **Databricks CLI without Bundles**: Rejected - requires custom scripts, less standardized
4. **Wheel File Bundling**: Rejected for utilities - PyPI provides better versioning

---

## 7. Monte Carlo Integration

### Decision

Implement **Decorator-Based Rule Registration** with **Async Background Sync** to Monte Carlo API.

### Approach

**Rule Definition in Code**:
```python
from databricks_utils.observability import monte_carlo_rule

@monte_carlo_rule(
    rule_type="freshness",
    threshold_hours=24,
    severity="high"
)
def create_silver_customers(spark: SparkSession):
    """Transform bronze to silver customers"""
    # Transformation logic
    pass

@monte_carlo_rule(
    rule_type="volume",
    threshold_change_percent=20,
    severity="medium"
)
def create_gold_customer_360(spark: SparkSession):
    """Aggregate to gold layer"""
    pass
```

**Registration During Deployment**:
```python
# Executed during bundle deployment
from databricks_utils.observability import MonteCarloSync

sync = MonteCarloSync(api_key=os.getenv("MC_API_KEY"))
sync.register_rules_from_module("src.transformations")
```

**Monitoring Dashboard**:
- Monte Carlo automatically monitors registered tables
- Alerts sent to configured channels (Slack, PagerDuty, email)
- Lineage integrated with Unity Catalog metadata

### Rationale

- **Developer-Friendly**: Rules defined next to transformation code
- **Version Control**: Rules evolve with code in same commit
- **Automated Sync**: No manual Monte Carlo UI configuration
- **Type Safety**: Decorators validated at deployment time

### Alternatives Considered

1. **Manual Monte Carlo UI Configuration**: Rejected - error-prone, out of sync with code, no version control
2. **Separate YAML Rule Files**: Rejected - disconnected from code, duplicate maintenance
3. **Monte Carlo Auto-Discovery Only**: Rejected - insufficient customization, generic rules
4. **DBT Integration**: Rejected - requires adopting DBT, adds complexity

---

## 8. Testing Strategy

### Decision

Implement **Layered Testing Approach** with **pytest + chispa + Databricks Connect** for local testing and **Databricks Workflows** for integration testing.

### Approach

**Test Pyramid**:

1. **Unit Tests** (70% of tests) - Run locally with pytest
```python
# tests/unit/test_transformations.py
from chispa import assert_df_equality
from src.transformations.silver import clean_customers

def test_clean_customers_removes_nulls(spark_session):
    # Given
    input_df = spark_session.createDataFrame([
        (1, "John", "john@email.com"),
        (2, None, "jane@email.com"),  # Should be filtered
        (3, "Bob", None),              # Should be filtered
    ], ["id", "name", "email"])

    # When
    result_df = clean_customers(input_df)

    # Then
    expected_df = spark_session.createDataFrame([
        (1, "John", "john@email.com"),
    ], ["id", "name", "email"])

    assert_df_equality(result_df, expected_df, ignore_row_order=True)
```

2. **Integration Tests** (20%) - Run on Databricks with sample data
```python
# tests/integration/test_pipeline.py
@pytest.mark.integration
def test_end_to_end_pipeline(databricks_session):
    # Run full bronze → silver → gold pipeline
    # Verify data in each layer
    pass
```

3. **Contract Tests** (10%) - Validate schemas and APIs
```python
# tests/contract/test_schemas.py
def test_bronze_customer_schema():
    expected_schema = StructType([
        StructField("id", LongType(), False),
        StructField("name", StringType(), False),
        StructField("email", StringType(), False),
    ])
    assert bronze_customers_schema == expected_schema
```

**Test Configuration**:
```toml
# pyproject.toml
[tool.pytest.ini_options]
markers = [
    "unit: Unit tests (run locally)",
    "integration: Integration tests (run on Databricks)",
    "slow: Slow tests",
]
```

**CI/CD Pipeline**:
```yaml
# .github/workflows/ci.yml
- name: Run unit tests
  run: pytest -m "unit" --cov

- name: Run integration tests
  if: github.ref == 'refs/heads/main'
  run: |
    databricks bundle deploy -t dev
    databricks bundle run test_job -t dev
```

### Rationale

- **Fast Feedback**: Unit tests run in seconds locally
- **High Coverage**: chispa provides DataFrame-specific assertions
- **Databricks Parity**: Integration tests use actual Databricks runtime
- **CI/CD Integration**: Automated testing on every commit
- **Cost Effective**: Most tests run locally, only integration tests use Databricks compute

### Alternatives Considered

1. **Only Local Tests**: Rejected - misses Databricks-specific behavior
2. **Only Databricks Tests**: Rejected - slow, expensive, poor developer experience
3. **DBT Test Framework**: Rejected - requires DBT adoption, Python-first approach preferred
4. **Manual Testing**: Rejected - not scalable, error-prone

---

## 9. CI/CD Pipeline

### Decision

Implement **GitHub Actions Workflow** with **Databricks Asset Bundle CLI** for automated deployment across environments.

### Approach

**Workflow Structure**:

```yaml
# .github/workflows/deploy.yml
name: Deploy Pipeline

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
      - name: Run unit tests
        run: pytest -m "unit" --cov
      - name: Lint code
        run: ruff check src/

  deploy-dev:
    needs: test
    if: github.ref == 'refs/heads/dev'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Databricks CLI
        run: |
          curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
      - name: Deploy to dev
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_DEV_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_DEV_HOST }}
        run: |
          databricks bundle validate
          databricks bundle deploy -t dev

  deploy-prod:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production  # Requires approval
    steps:
      - uses: actions/checkout@v3
      - name: Setup Databricks CLI
        run: |
          curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
      - name: Deploy to prod
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_PROD_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_PROD_HOST }}
        run: |
          databricks bundle validate
          databricks bundle deploy -t prod
```

**Branching Strategy**:
- `main` branch → deploys to production (with approval)
- `dev` branch → auto-deploys to dev environment
- Feature branches → run tests only (no deployment)

### Rationale

- **Automation**: Push to branch triggers deployment automatically
- **Safety**: Production deployments require manual approval
- **Validation**: Bundle validation catches errors before deployment
- **Secrets Management**: GitHub Secrets for credentials
- **Audit Trail**: All deployments logged in GitHub Actions

### Alternatives Considered

1. **Manual Deployment**: Rejected - error-prone, not scalable
2. **Jenkins**: Rejected - more infrastructure to maintain
3. **GitLab CI**: Alternative option if using GitLab
4. **Databricks Repos + Manual Trigger**: Rejected - less automation, no validation

---

## 10. Agent Prompt Engineering

### Decision

Implement **Layered Prompt Templates** with **Few-Shot Examples** and **RAG (Retrieval-Augmented Generation)** for organizational code patterns.

### Approach

**Prompt Template Structure**:

```markdown
# agents/coding_agent/prompts/bronze_layer.md

## Role
You are a data engineering expert specializing in Databricks medallion architecture.

## Task
Generate PySpark code to ingest raw data into a Bronze layer table in Unity Catalog.

## Requirements
- Use Spark DataFrame API (not SQL)
- Include error handling and logging
- Add schema validation
- Use provided shared utilities
- Follow organizational coding standards

## Context
- Source: {source_path}
- Target: {target_table}
- Description: {user_description}

## Organizational Patterns
{rag_retrieved_patterns}

## Examples

### Example 1: CSV Ingestion
[Few-shot example with complete code]

### Example 2: JSON Ingestion
[Few-shot example with complete code]

## Output Format
Provide complete Python code with:
1. Imports
2. Function definition
3. Schema definition
4. Read logic with error handling
5. Write logic to Unity Catalog
6. Logging statements
```

**RAG Integration**:
```python
# Retrieve similar code patterns from vector store
from databricks_agents.rag import CodePatternRetriever

retriever = CodePatternRetriever(
    vector_store="pinecone",
    index_name="org-code-patterns"
)

similar_patterns = retriever.retrieve(
    query=user_description,
    layer="bronze",
    top_k=3
)
```

**Agent Execution**:
```python
# Format prompt with context
prompt = bronze_template.format(
    source_path=args.source,
    target_table=args.target,
    user_description=args.description,
    rag_retrieved_patterns=similar_patterns
)

# Call LLM
response = llm.generate(
    prompt=prompt,
    temperature=0.2,  # Low temp for code generation
    max_tokens=2000
)

# Validate generated code
validator = CodeValidator()
validation_result = validator.validate_syntax(response.code)

if validation_result.is_valid:
    save_code(response.code, output_path)
else:
    print(f"Validation errors: {validation_result.errors}")
```

### Rationale

- **Consistency**: Templates ensure all generated code follows same structure
- **Context-Aware**: RAG provides organization-specific patterns
- **Quality**: Few-shot examples guide LLM to production-quality code
- **Validation**: Syntax and style checks before code is saved
- **Iterative**: Failed validations can trigger regeneration

### Alternatives Considered

1. **Zero-Shot Prompting**: Rejected - inconsistent output quality
2. **Fine-Tuned Model**: Rejected - expensive to maintain, requires retraining
3. **Rule-Based Code Generation**: Rejected - inflexible, can't handle novel requirements
4. **Template Filling Only**: Rejected - too rigid, can't adapt to variations

---

## Technology Stack Summary

| Component | Technology Choice | Version/Details |
|-----------|------------------|-----------------|
| **Language** | Python | 3.10+ |
| **Compute** | Databricks | Runtime 11.3+ |
| **Storage** | Unity Catalog | Delta Lake format |
| **Orchestration** | Lakeflow | Declarative pipelines |
| **Deployment** | Asset Bundles | Databricks CLI |
| **Observability** | Monte Carlo | API integration |
| **Configuration** | Pydantic + YAML | Type-safe validation |
| **Testing** | pytest + chispa | Local + Databricks |
| **CI/CD** | GitHub Actions | Automated deployment |
| **Package Management** | PyPI (private) | Semantic versioning |
| **Agent Framework** | MCP + CLI | Model Context Protocol |
| **Prompt Engineering** | RAG + Few-Shot | Vector store for patterns |
| **Version Control** | Git | Multi-repo strategy |

---

## Open Questions & Future Research

1. **Cost Optimization**: How to optimize Databricks compute costs for development workflows?
2. **Agent Fine-Tuning**: Should we eventually fine-tune models on organizational code?
3. **Real-Time Streaming**: How to extend this process to Delta Live Tables for streaming?
4. **Multi-Cloud**: How to adapt for cross-cloud deployments (AWS + Azure)?
5. **Governance**: What additional governance controls are needed for AI-generated code?

These questions can be addressed in future iterations as the system matures.

---

**Research Complete**: All technical decisions documented and ready for Phase 1 design.
