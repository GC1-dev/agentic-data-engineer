# Data Model

**Feature**: AI-Native Data Engineering Process for Databricks
**Date**: 2025-11-21
**Status**: Complete

## Overview

This document defines the data structures, entities, and their relationships for the AI-Native data engineering process. The model covers configuration schemas, metadata structures, and runtime objects.

---

## 1. Project Configuration

### ProjectConfig

Represents the root configuration for a pipeline project.

**Schema**:
```python
class ProjectConfig(BaseModel):
    """Root project configuration"""
    name: str = Field(..., description="Project identifier", pattern=r"^[a-z0-9-]+$")
    version: str = Field(..., description="Project version", pattern=r"^\d+\.\d+\.\d+$")
    description: str
    owner_team: str

    environments: Dict[str, EnvironmentConfig]
    dependencies: DependencyConfig
    metadata: Optional[ProjectMetadata] = None

    class Config:
        json_schema_extra = {
            "example": {
                "name": "customer-360-pipeline",
                "version": "1.0.0",
                "description": "Customer 360 data pipeline",
                "owner_team": "data-analytics",
                "environments": {"dev": {...}, "prod": {...}},
                "dependencies": {...}
            }
        }
```

**Validation Rules**:
- `name` must be lowercase with hyphens only
- `version` must follow semantic versioning (MAJOR.MINOR.PATCH)
- At least one environment must be defined
- `owner_team` must be non-empty

**Relationships**:
- Contains multiple `EnvironmentConfig` instances
- References `DependencyConfig` for package dependencies
- Optional `ProjectMetadata` for additional context

---

## 2. Environment Configuration

### EnvironmentConfig

Environment-specific settings for Spark, Unity Catalog, and services.

**Schema**:
```python
class SparkConfig(BaseModel):
    """Spark session configuration"""
    app_name: str
    master: Optional[str] = None  # None for Databricks managed
    config: Dict[str, str] = Field(default_factory=dict)

    # Common config keys
    # spark.sql.shuffle.partitions
    # spark.sql.adaptive.enabled
    # spark.databricks.delta.optimizeWrite.enabled

class CatalogConfig(BaseModel):
    """Unity Catalog configuration"""
    name: str = Field(..., description="Catalog name")
    schema_prefix: str = Field(..., description="Schema prefix for medallion layers")

    # Computed properties
    @property
    def bronze_schema(self) -> str:
        return f"{self.schema_prefix}_bronze"

    @property
    def silver_schema(self) -> str:
        return f"{self.schema_prefix}_silver"

    @property
    def gold_schema(self) -> str:
        return f"{self.schema_prefix}_gold"

class ObservabilityConfig(BaseModel):
    """Monte Carlo configuration"""
    api_key_secret: str  # Reference to Databricks secret
    api_endpoint: str = "https://getmontecarlo.com/api/v1"
    enabled: bool = True

class EnvironmentConfig(BaseModel):
    """Complete environment configuration"""
    environment_type: Literal["local", "lab", "dev", "prod"]
    spark: SparkConfig
    catalog: CatalogConfig
    observability: Optional[ObservabilityConfig] = None

    # Databricks-specific
    workspace_host: Optional[str] = None
    cluster_id: Optional[str] = None
```

**Validation Rules**:
- `environment_type` must be one of: local, lab, dev, prod
- `workspace_host` required for non-local environments
- `master` required for local environment
- Catalog names must follow Unity Catalog naming conventions

**File Representation** (YAML):
```yaml
# config/prod.yaml
environment_type: prod

spark:
  app_name: "customer-360-prod"
  config:
    spark.sql.shuffle.partitions: "200"
    spark.sql.adaptive.enabled: "true"

catalog:
  name: "prod_analytics"
  schema_prefix: "customer_360"
  # Generates: prod_analytics.customer_360_bronze, etc.

observability:
  api_key_secret: "monte-carlo/api-key"
  enabled: true

workspace_host: "https://prod.cloud.databricks.com"
```

---

## 3. Dependency Configuration

### DependencyConfig

Manages shared utility and external package dependencies.

**Schema**:
```python
class SharedUtilityDependency(BaseModel):
    """Shared utility library reference"""
    name: str = Field(..., pattern=r"^databricks-[a-z-]+$")
    version: str = Field(..., description="Semantic version or range")
    source: Literal["pypi", "git"] = "pypi"
    git_url: Optional[str] = None
    git_ref: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "name": "databricks-utils",
                "version": "1.2.3",
                "source": "pypi"
            }
        }

class DependencyConfig(BaseModel):
    """Project dependencies"""
    shared_utilities: List[SharedUtilityDependency]
    external_packages: List[str] = Field(default_factory=list)
    python_version: str = Field(default="3.10", pattern=r"^\d+\.\d+$")

    def to_requirements_txt(self) -> str:
        """Generate requirements.txt content"""
        lines = []
        for util in self.shared_utilities:
            if util.source == "pypi":
                lines.append(f"{util.name}=={util.version}")
            elif util.source == "git":
                lines.append(f"git+{util.git_url}@{util.git_ref}#egg={util.name}")
        lines.extend(self.external_packages)
        return "\n".join(lines)
```

**Validation Rules**:
- Shared utility names must start with `databricks-`
- Versions must be valid semver or ranges (e.g., `>=1.0.0,<2.0.0`)
- Git dependencies must provide both `git_url` and `git_ref`

---

## 4. AI Agent Metadata

### AgentDefinition

Describes an AI agent's capabilities and interface.

**Schema**:
```python
class AgentInput(BaseModel):
    """Agent input specification"""
    name: str
    type: str  # e.g., "string", "file_path", "json"
    description: str
    required: bool = True
    default: Optional[Any] = None

class AgentOutput(BaseModel):
    """Agent output specification"""
    type: Literal["code", "test", "config", "documentation"]
    format: str  # e.g., "python", "yaml", "markdown"
    validation_schema: Optional[Dict] = None

class AgentDefinition(BaseModel):
    """AI agent metadata"""
    agent_id: str = Field(..., pattern=r"^[a-z-]+$")
    name: str
    description: str
    agent_type: Literal["coding", "testing", "profiling", "quality", "optimization"]
    version: str

    inputs: List[AgentInput]
    outputs: AgentOutput

    prompt_template_path: str
    examples_path: Optional[str] = None

    # LLM settings
    model: str = "claude-sonnet-4"
    temperature: float = Field(default=0.2, ge=0.0, le=1.0)
    max_tokens: int = Field(default=4000, gt=0)

    # Execution
    timeout_seconds: int = 300
    retry_attempts: int = 3

    class Config:
        json_schema_extra = {
            "example": {
                "agent_id": "bronze-coding-agent",
                "name": "Bronze Layer Coding Agent",
                "agent_type": "coding",
                "version": "1.0.0",
                "inputs": [...],
                "outputs": {...},
                "prompt_template_path": "prompts/bronze_layer.md"
            }
        }
```

**Validation Rules**:
- `agent_id` must be kebab-case
- `temperature` between 0.0 and 1.0
- `timeout_seconds` must be positive
- `prompt_template_path` must exist

**Relationships**:
- Referenced by `PipelineProject` for agent usage tracking
- Outputs validated against `AgentOutput` schema

---

## 5. Pipeline Execution Context

### PipelineExecution

Runtime context for pipeline execution.

**Schema**:
```python
class TableReference(BaseModel):
    """Unity Catalog table reference"""
    catalog: str
    schema_: str = Field(alias="schema")
    table: str

    @property
    def fully_qualified_name(self) -> str:
        return f"{self.catalog}.{self.schema_}.{self.table}"

class TransformationStep(BaseModel):
    """Single transformation in pipeline"""
    step_id: str
    name: str
    layer: Literal["bronze", "silver", "gold"]

    source_tables: List[TableReference]
    target_table: TableReference

    transformation_file: str  # Path to Python file
    dependencies: List[str] = Field(default_factory=list)  # Other step_ids

    # Execution metadata
    estimated_runtime_seconds: Optional[int] = None
    max_retry_attempts: int = 3

class PipelineExecution(BaseModel):
    """Pipeline execution context"""
    execution_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    pipeline_name: str
    environment: str

    steps: List[TransformationStep]

    # Runtime state
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    status: Literal["pending", "running", "completed", "failed"] = "pending"

    # Metrics
    rows_processed: int = 0
    bytes_processed: int = 0

    # Observability
    spark_job_ids: List[str] = Field(default_factory=list)
    monte_carlo_run_id: Optional[str] = None

    def duration_seconds(self) -> Optional[float]:
        if self.started_at and self.completed_at:
            return (self.completed_at - self.started_at).total_seconds()
        return None
```

**State Transitions**:
```
pending → running → completed
                 → failed
```

**Validation Rules**:
- `execution_id` must be unique UUID
- `status` transitions must be valid (no completed → pending)
- `steps` must form a valid DAG (no circular dependencies)
- All `source_tables` in step must exist or be outputs of prior steps

---

## 6. Asset Bundle Manifest

### AssetBundleManifest

Databricks Asset Bundle deployment metadata.

**Schema**:
```python
class JobResource(BaseModel):
    """Databricks job definition"""
    name: str
    tasks: List[Dict[str, Any]]  # Task definitions
    schedule: Optional[Dict[str, str]] = None
    libraries: List[Dict[str, Any]] = Field(default_factory=list)
    max_concurrent_runs: int = 1
    timeout_seconds: int = 0  # 0 = no timeout

class AssetBundleManifest(BaseModel):
    """Asset Bundle deployment manifest"""
    bundle_name: str
    version: str

    target_environment: str
    workspace_host: str

    resources: Dict[str, Any]  # Jobs, pipelines, etc.

    # Dependencies
    shared_utilities: List[SharedUtilityDependency]

    # Deployment metadata
    deployed_by: str
    deployed_at: datetime
    git_commit_sha: str
    git_branch: str

    # Validation
    validation_passed: bool = True
    validation_errors: List[str] = Field(default_factory=list)
```

**File Representation** (YAML):
```yaml
# databricks/bundle.yml
bundle:
  name: customer-360-pipeline

targets:
  prod:
    mode: production
    workspace:
      host: https://prod.cloud.databricks.com

    resources:
      jobs:
        customer_360_job:
          name: "Customer 360 Pipeline"
          tasks:
            - task_key: bronze_ingest
              python_file: src/transformations/bronze/ingest.py
              libraries:
                - pypi:
                    package: "databricks-utils==1.2.3"
```

---

## 7. Data Quality Rules

### DataQualityRule

Data quality rule registered with Monte Carlo.

**Schema**:
```python
class DataQualityRule(BaseModel):
    """Data quality monitoring rule"""
    rule_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    description: str

    rule_type: Literal[
        "freshness",    # Data recency
        "volume",       # Row count change
        "schema",       # Schema drift
        "custom_sql",   # Custom validation query
        "null_rate",    # Null percentage
        "uniqueness"    # Duplicate detection
    ]

    # Target
    table: TableReference

    # Rule parameters (type-specific)
    threshold: Optional[Union[int, float, str]] = None
    threshold_hours: Optional[int] = None  # For freshness
    threshold_change_percent: Optional[float] = None  # For volume
    custom_sql: Optional[str] = None  # For custom_sql

    severity: Literal["low", "medium", "high", "critical"] = "medium"

    # Monte Carlo integration
    monte_carlo_monitor_id: Optional[str] = None
    last_checked_at: Optional[datetime] = None
    last_status: Optional[Literal["passed", "failed", "warning"]] = None

    # Alerting
    alert_channels: List[str] = Field(default_factory=list)  # Slack, email, etc.

    class Config:
        json_schema_extra = {
            "example": {
                "name": "Customer data freshness",
                "rule_type": "freshness",
                "table": {
                    "catalog": "prod_analytics",
                    "schema": "customer_360_silver",
                    "table": "customers"
                },
                "threshold_hours": 24,
                "severity": "high",
                "alert_channels": ["#data-alerts"]
            }
        }
```

**Validation Rules**:
- `threshold_hours` required when `rule_type` is "freshness"
- `threshold_change_percent` required when `rule_type` is "volume"
- `custom_sql` required when `rule_type` is "custom_sql"
- `severity` determines alerting urgency

---

## 8. Project Metadata

### ProjectMetadata

Additional project context and tracking.

**Schema**:
```python
class AgentUsage(BaseModel):
    """Track agent usage in project"""
    agent_id: str
    invocations_count: int = 0
    total_tokens: int = 0
    successful_generations: int = 0
    failed_generations: int = 0
    last_used_at: Optional[datetime] = None

class ProjectMetadata(BaseModel):
    """Project metadata and tracking"""
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_modified_at: datetime = Field(default_factory=datetime.utcnow)

    # Repository info
    git_repository: Optional[str] = None
    git_branch: str = "main"

    # Usage tracking
    agent_usage: List[AgentUsage] = Field(default_factory=list)

    # Statistics
    total_pipelines: int = 0
    total_tables_created: int = 0
    total_rows_processed: int = 0

    # Team
    contributors: List[str] = Field(default_factory=list)

    # Tags
    tags: List[str] = Field(default_factory=list)

    # Documentation
    documentation_url: Optional[str] = None
    runbook_url: Optional[str] = None
```

---

## Entity Relationships

```
ProjectConfig
  ├── 1:N EnvironmentConfig
  ├── 1:1 DependencyConfig
  │     └── N:M SharedUtilityDependency
  └── 1:1 ProjectMetadata
        └── 1:N AgentUsage

PipelineExecution
  ├── 1:N TransformationStep
  │     ├── N:M TableReference (sources)
  │     └── 1:1 TableReference (target)
  └── 1:N DataQualityRule
        └── 1:1 TableReference

AssetBundleManifest
  ├── 1:N JobResource
  └── N:M SharedUtilityDependency

AgentDefinition
  ├── 1:N AgentInput
  └── 1:1 AgentOutput
```

---

## File Storage Locations

| Entity | Storage Location | Format |
|--------|------------------|--------|
| ProjectConfig | `{project}/config/project.yaml` | YAML |
| EnvironmentConfig | `{project}/config/{env}.yaml` | YAML |
| AgentDefinition | `databricks-ai-agents/agents/{agent}/definition.yaml` | YAML |
| AssetBundleManifest | `{project}/databricks/bundle.yml` | YAML |
| PipelineExecution | Runtime (Databricks job run metadata) | JSON (API) |
| DataQualityRule | Monte Carlo + `{project}/quality_rules.yaml` | YAML |

---

## Schema Validation Examples

### Valid ProjectConfig

```yaml
name: customer-360-pipeline
version: 1.0.0
description: "Customer 360 degree view pipeline"
owner_team: data-analytics

environments:
  dev:
    environment_type: dev
    spark:
      app_name: "customer-360-dev"
      config:
        spark.sql.shuffle.partitions: "10"
    catalog:
      name: "dev_analytics"
      schema_prefix: "customer_360"
    workspace_host: "https://dev.databricks.com"

  prod:
    environment_type: prod
    spark:
      app_name: "customer-360-prod"
      config:
        spark.sql.shuffle.partitions: "200"
    catalog:
      name: "prod_analytics"
      schema_prefix: "customer_360"
    workspace_host: "https://prod.databricks.com"
    observability:
      api_key_secret: "monte-carlo/api-key"
      enabled: true

dependencies:
  python_version: "3.10"
  shared_utilities:
    - name: "databricks-utils"
      version: "1.2.3"
      source: "pypi"
  external_packages:
    - "pandas>=2.0.0"
    - "pyarrow>=10.0.0"
```

### Valid AgentDefinition

```yaml
agent_id: bronze-coding-agent
name: "Bronze Layer Coding Agent"
description: "Generates PySpark code for bronze layer ingestion"
agent_type: coding
version: 1.0.0

inputs:
  - name: source_path
    type: string
    description: "Path to source data"
    required: true

  - name: target_table
    type: string
    description: "Target Unity Catalog table"
    required: true

  - name: description
    type: string
    description: "Natural language transformation description"
    required: true

outputs:
  type: code
  format: python
  validation_schema:
    check_syntax: true
    check_imports: true
    required_functions: ["main"]

prompt_template_path: "prompts/bronze_layer.md"
examples_path: "examples/bronze_examples.json"

model: "claude-sonnet-4"
temperature: 0.2
max_tokens: 4000
timeout_seconds: 300
retry_attempts: 3
```

---

## Summary

This data model provides:
- **Type-safe configuration** via Pydantic models
- **Clear validation rules** for all entities
- **Relationship mapping** between components
- **File format specifications** for persistence
- **Extensibility** for future enhancements

All schemas support JSON Schema export for documentation and tooling integration.
