# Data Model: Claude Agent Template System

**Date**: 2025-11-23
**Feature**: 006-claude-agent-templates

## Overview

This document defines the core data entities, their fields, relationships, validation rules, and state transitions for the Claude Agent Template System. All entities are implemented as Pydantic models for validation and serialization.

---

## Entity 1: ProjectRequirements

**Purpose**: Natural language description of project needs, captured through conversation. Includes project purpose, data sources, transformation layers, monitoring needs, and team ownership.

### Fields

| Field | Type | Required | Validation | Default |
|-------|------|----------|-----------|---------|
| `project_name` | `str` | Yes | Filesystem-safe (alphanumeric, hyphens, underscores only) | - |
| `description` | `str` | Yes | 10-500 characters | - |
| `python_version` | `str` | Yes | Must be "3.10", "3.11", or "3.12" | "3.11" |
| `databricks_runtime` | `str` | Yes | Must match compatibility matrix (DBR 13.0+) | "14.3" |
| `transformation_layers` | `List[str]` | No | Valid values: ["bronze", "silver", "gold", "bronze_silver", "bronze_silver_gold"] | ["bronze_silver_gold"] |
| `data_sources` | `List[str]` | No | Free text list (e.g., ["S3 buckets", "Delta tables", "streaming events"]) | [] |
| `optional_features` | `List[FeatureType]` | No | Enum: STREAMING, MONTE_CARLO, DATA_VALIDATION, TESTING_FRAMEWORK | [] |
| `ci_cd_platform` | `str` | Yes | Enum: "github_actions", "gitlab_ci", "azure_devops" | "github_actions" |
| `team_ownership` | `str` | No | Team/email identifier | None |
| `environment_configs` | `List[str]` | Yes | Must include at least ["local", "dev", "prod"] | ["local", "lab", "dev", "prod"] |

### Validation Rules

1. **Python/DBR Compatibility**: `python_version` must be compatible with `databricks_runtime` according to compatibility matrix
   - Python 3.10 → DBR 13.0+
   - Python 3.11 → DBR 13.3+
   - Python 3.12 → DBR 14.0+

2. **Project Name**: Must be filesystem-safe (no spaces, special characters except hyphen/underscore)

3. **Feature Conflicts**: Cannot combine incompatible features (validated by CompatibilityChecker)

### Relationships

- **Contains multiple** → `ConfigurationProfile` (one per environment)
- **Requests multiple** → `FeatureModule` (zero or more optional features)
- **Produces** → `GenerationSession` (one per generation attempt)

### Pydantic Model

```python
from pydantic import BaseModel, Field, field_validator
from enum import Enum
from typing import List, Optional

class FeatureType(str, Enum):
    STREAMING = "streaming"
    MONTE_CARLO = "monte_carlo"
    DATA_VALIDATION = "data_validation"
    TESTING_FRAMEWORK = "testing"

class ProjectRequirements(BaseModel):
    project_name: str = Field(..., pattern=r'^[a-zA-Z0-9_-]+$')
    description: str = Field(..., min_length=10, max_length=500)
    python_version: str = Field("3.11", pattern=r'^3\.(10|11|12)$')
    databricks_runtime: str = Field("14.3", pattern=r'^\d+\.\d+$')
    transformation_layers: List[str] = ["bronze_silver_gold"]
    data_sources: List[str] = []
    optional_features: List[FeatureType] = []
    ci_cd_platform: str = Field("github_actions", pattern=r'^(github_actions|gitlab_ci|azure_devops)$')
    team_ownership: Optional[str] = None
    environment_configs: List[str] = ["local", "lab", "dev", "prod"]

    @field_validator('databricks_runtime')
    def validate_dbr_compatibility(cls, v, values):
        # Check Python/DBR compatibility against matrix
        pass
```

---

## Entity 2: ConfigurationProfile

**Purpose**: Environment-specific settings (local/lab/dev/prod) with infrastructure details, connection strings, and compute specifications.

### Fields

| Field | Type | Required | Validation | Default |
|-------|------|----------|-----------|---------|
| `environment_name` | `str` | Yes | One of: "local", "lab", "dev", "prod" | - |
| `workspace_url` | `str` | No | Valid URL format | None |
| `catalog_name` | `str` | No | Unity Catalog naming rules | None |
| `schema_name` | `str` | No | Unity Catalog naming rules | None |
| `compute_size` | `str` | No | Enum: "small", "medium", "large" | "small" |
| `autoscaling_enabled` | `bool` | No | - | True |
| `min_workers` | `int` | No | 1-100 | 1 |
| `max_workers` | `int` | No | 1-100, must be >= min_workers | 4 |
| `spot_instances` | `bool` | No | - | False (True for dev/lab, False for prod) |

### Validation Rules

1. **Worker Constraints**: `max_workers` >= `min_workers`
2. **Environment-Specific Defaults**:
   - local: No workspace URL required
   - lab/dev: Can use spot instances
   - prod: No spot instances by default (Databricks best practice)
3. **Catalog/Schema**: If one is set, both must be set (Unity Catalog requirement)

### Relationships

- **Belongs to** → `ProjectRequirements` (many-to-one)
- **Used in** → `ProjectTemplate` generation (one per environment)

### Pydantic Model

```python
class ConfigurationProfile(BaseModel):
    environment_name: str = Field(..., pattern=r'^(local|lab|dev|prod)$')
    workspace_url: Optional[str] = Field(None, pattern=r'^https://.*')
    catalog_name: Optional[str] = None
    schema_name: Optional[str] = None
    compute_size: str = Field("small", pattern=r'^(small|medium|large)$')
    autoscaling_enabled: bool = True
    min_workers: int = Field(1, ge=1, le=100)
    max_workers: int = Field(4, ge=1, le=100)
    spot_instances: bool = False

    @field_validator('max_workers')
    def validate_worker_range(cls, v, values):
        if 'min_workers' in values and v < values['min_workers']:
            raise ValueError('max_workers must be >= min_workers')
        return v

    @field_validator('schema_name')
    def validate_catalog_schema_pair(cls, v, values):
        if v and not values.get('catalog_name'):
            raise ValueError('schema_name requires catalog_name to be set')
        return v
```

---

## Entity 3: FeatureModule

**Purpose**: Optional project component (streaming, Monte Carlo, data validation) that adds specific files and configurations when requested.

### Fields

| Field | Type | Required | Validation | Default |
|-------|------|----------|-----------|---------|
| `feature_type` | `FeatureType` | Yes | Enum: STREAMING, MONTE_CARLO, DATA_VALIDATION, TESTING_FRAMEWORK | - |
| `enabled` | `bool` | Yes | - | True |
| `dependencies` | `List[str]` | Yes | Python package specifications | [] |
| `generated_files` | `List[str]` | Yes | Relative paths from project root | [] |
| `configuration_overrides` | `Dict[str, Any]` | No | Feature-specific config values | {} |
| `incompatible_with` | `List[FeatureType]` | No | Features that conflict | [] |

### Feature-Specific Metadata

#### Streaming Feature
```python
{
    "feature_type": "streaming",
    "dependencies": [
        "pyspark[sql]>=3.5.0",
        "delta-spark>=3.0.0"
    ],
    "generated_files": [
        "pipelines/streaming/stream_processor.py",
        "pipelines/streaming/__init__.py",
        "config/streaming_checkpoints.yaml"
    ],
    "configuration_overrides": {
        "spark.streaming.stopGracefullyOnShutdown": "true",
        "spark.sql.streaming.checkpointLocation": "/dbfs/checkpoints"
    },
    "incompatible_with": []
}
```

#### Monte Carlo Feature
```python
{
    "feature_type": "monte_carlo",
    "dependencies": [
        "pycarlo>=0.50.0"
    ],
    "generated_files": [
        "monte_carlo/monitors.py",
        "monte_carlo/__init__.py",
        "config/monte_carlo.yaml"
    ],
    "configuration_overrides": {},
    "incompatible_with": []
}
```

#### Data Validation Feature
```python
{
    "feature_type": "data_validation",
    "dependencies": [
        "great-expectations>=0.18.0",
        "pydantic>=2.0.0"
    ],
    "generated_files": [
        "data_validation/expectations/",
        "data_validation/rules.py",
        "data_validation/__init__.py"
    ],
    "configuration_overrides": {},
    "incompatible_with": []
}
```

#### Testing Framework Feature
```python
{
    "feature_type": "testing",
    "dependencies": [
        "pytest>=7.0.0",
        "pytest-cov>=4.0.0",
        "chispa>=0.9.0"  # PySpark testing utilities
    ],
    "generated_files": [
        "tests/unit/test_sample.py",
        "tests/integration/test_pipeline.py",
        "tests/conftest.py",
        "pytest.ini"
    ],
    "configuration_overrides": {},
    "incompatible_with": []
}
```

### Validation Rules

1. **Dependency Format**: Must be valid pip package specifications (name>=version)
2. **File Paths**: Must be relative paths, no absolute paths or parent directory references
3. **Compatibility**: Cannot enable features that are in `incompatible_with` list

### Relationships

- **Requested by** → `ProjectRequirements` (many-to-one)
- **Modifies** → `ProjectTemplate` (adds files/configs)

### Pydantic Model

```python
class FeatureModule(BaseModel):
    feature_type: FeatureType
    enabled: bool = True
    dependencies: List[str]
    generated_files: List[str]
    configuration_overrides: Dict[str, Any] = {}
    incompatible_with: List[FeatureType] = []

    @field_validator('generated_files')
    def validate_relative_paths(cls, v):
        for path in v:
            if path.startswith('/') or '..' in path:
                raise ValueError(f'File paths must be relative: {path}')
        return v
```

---

## Entity 4: ProjectTemplate

**Purpose**: Structured representation of project layout with configurable components (directories, files, configurations), can be dynamically customized based on requirements.

### Fields

| Field | Type | Required | Validation | Default |
|-------|------|----------|-----------|---------|
| `template_version` | `str` | Yes | Semantic version format | "1.0.0" |
| `base_directories` | `List[str]` | Yes | Must include 9-directory standard | Fixed list |
| `jinja_templates` | `Dict[str, str]` | Yes | Template name → file path mapping | {} |
| `required_files` | `List[str]` | Yes | Files that must exist in every project | [] |
| `optional_file_groups` | `Dict[FeatureType, List[str]]` | Yes | Feature → files mapping | {} |

### Constants

**9-Directory Standard** (from FR-003):
```python
BASE_DIRECTORIES = [
    "src/",
    "pipelines/",
    "dashboards/",
    "databricks_apps/",
    "monte_carlo/",
    "data_validation/",
    "tests/",
    "config/",
    "docs/",
    "databricks/"
]
```

**Required Files**:
```python
REQUIRED_FILES = [
    "README.md",
    "requirements.txt",
    ".gitignore",
    "databricks/bundle.yml",
    "config/project.yaml",
    "pyproject.toml"
]
```

### Validation Rules

1. **Directory Standard**: `base_directories` must exactly match the 9-directory standard
2. **Template Existence**: All Jinja template paths must exist in templates/ directory
3. **File Paths**: All generated files must fall within the 9-directory structure

### Relationships

- **Generated from** → `ProjectRequirements` (one-to-one per generation)
- **Includes** → `FeatureModule` files (many optional features)
- **Validated by** → `StructureValidator` (post-generation)

### Pydantic Model

```python
class ProjectTemplate(BaseModel):
    template_version: str = Field("1.0.0", pattern=r'^\d+\.\d+\.\d+$')
    base_directories: List[str] = BASE_DIRECTORIES
    jinja_templates: Dict[str, str]
    required_files: List[str] = REQUIRED_FILES
    optional_file_groups: Dict[FeatureType, List[str]]

    @field_validator('base_directories')
    def validate_standard_layout(cls, v):
        if v != BASE_DIRECTORIES:
            raise ValueError('base_directories must match 9-directory standard')
        return v
```

---

## Entity 5: GenerationSession

**Purpose**: Record of conversation, requirements gathered, choices made, and resulting project structure - used for template improvement analysis (FR-014).

### Fields

| Field | Type | Required | Validation | Default |
|-------|------|----------|-----------|---------|
| `session_id` | `str` | Yes | UUID format | Generated |
| `timestamp` | `datetime` | Yes | ISO 8601 format | Now |
| `project_name_hash` | `str` | Yes | SHA256 hash (anonymized) | Computed |
| `requirements_summary` | `Dict[str, Any]` | Yes | Anonymized requirements | {} |
| `questions_asked` | `int` | Yes | 0-10 | 0 |
| `clarifications_count` | `int` | Yes | 0-10 | 0 |
| `features_requested` | `List[FeatureType]` | Yes | - | [] |
| `generation_time_seconds` | `float` | Yes | > 0 | 0.0 |
| `python_version` | `str` | Yes | - | - |
| `databricks_runtime` | `str` | Yes | - | - |
| `ci_cd_platform` | `str` | Yes | - | - |
| `success` | `bool` | Yes | - | False |
| `error_message` | `Optional[str]` | No | - | None |
| `validation_results` | `Dict[str, bool]` | Yes | Validator name → passed | {} |

### Anonymization Rules (Security Requirement)

**MUST anonymize**:
- Project names → SHA256 hash
- Team ownership → Remove completely
- Data source descriptions → Remove specifics, keep categories only
- Workspace URLs → Remove completely

**CAN keep**:
- Feature choices (public information)
- Python/DBR versions (public information)
- Question count, generation time (aggregate metrics)
- Validation results (success/failure patterns)

### Validation Rules

1. **Timestamp**: Must be UTC timezone
2. **Duration**: `generation_time_seconds` must be positive
3. **Session ID**: Must be valid UUID v4
4. **Success/Error**: If `success` is False, `error_message` must be set

### Relationships

- **Records** → `ProjectRequirements` (one-to-one, anonymized)
- **Aggregated into** → `TemplateImprovementSuggestion` (many-to-one)

### Pydantic Model

```python
from datetime import datetime
from uuid import UUID, uuid4
import hashlib

class GenerationSession(BaseModel):
    session_id: str = Field(default_factory=lambda: str(uuid4()))
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    project_name_hash: str
    requirements_summary: Dict[str, Any]
    questions_asked: int = Field(0, ge=0, le=10)
    clarifications_count: int = Field(0, ge=0, le=10)
    features_requested: List[FeatureType] = []
    generation_time_seconds: float = Field(0.0, gt=0.0)
    python_version: str
    databricks_runtime: str
    ci_cd_platform: str
    success: bool = False
    error_message: Optional[str] = None
    validation_results: Dict[str, bool] = {}

    @classmethod
    def anonymize_project_name(cls, project_name: str) -> str:
        """Anonymize project name using SHA256 hash"""
        return hashlib.sha256(project_name.encode()).hexdigest()[:16]

    @field_validator('error_message')
    def validate_error_message(cls, v, values):
        if not values.get('success') and not v:
            raise ValueError('error_message required when success=False')
        return v
```

---

## Entity 6: TemplateImprovementSuggestion

**Purpose**: Data-driven recommendation for template changes based on analysis of multiple generation sessions (FR-015).

### Fields

| Field | Type | Required | Validation | Default |
|-------|------|----------|-----------|---------|
| `suggestion_id` | `str` | Yes | UUID format | Generated |
| `created_at` | `datetime` | Yes | ISO 8601 format | Now |
| `pattern_type` | `str` | Yes | Enum: "commonly_requested_feature", "commonly_skipped_feature", "common_conflict", "performance_bottleneck" | - |
| `description` | `str` | Yes | Human-readable description | - |
| `supporting_sessions` | `int` | Yes | >= 10 (minimum for statistical significance per SC-005) | 0 |
| `frequency_percentage` | `float` | Yes | 0.0-100.0 | 0.0 |
| `recommended_action` | `str` | Yes | Actionable change description | - |
| `priority` | `str` | Yes | Enum: "high", "medium", "low" | "medium" |
| `status` | `str` | Yes | Enum: "pending_review", "approved", "rejected", "implemented" | "pending_review" |

### Pattern Types

1. **commonly_requested_feature**: Feature requested in >50% of projects (consider making default)
2. **commonly_skipped_feature**: Feature offered but declined in >70% of projects (consider removing from prompts)
3. **common_conflict**: Feature combination that frequently triggers conflict warnings
4. **performance_bottleneck**: Generation step that consistently takes >30s (optimize)

### Validation Rules

1. **Statistical Significance**: `supporting_sessions` >= 10 (per SC-005)
2. **Frequency Range**: 0.0 <= `frequency_percentage` <= 100.0
3. **Status Transitions**: pending_review → approved/rejected → implemented (one-way)

### Relationships

- **Derived from** → `GenerationSession` (many-to-one)
- **Informs** → Future `ProjectTemplate` updates

### Pydantic Model

```python
class PatternType(str, Enum):
    COMMONLY_REQUESTED = "commonly_requested_feature"
    COMMONLY_SKIPPED = "commonly_skipped_feature"
    COMMON_CONFLICT = "common_conflict"
    PERFORMANCE_BOTTLENECK = "performance_bottleneck"

class Priority(str, Enum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class SuggestionStatus(str, Enum):
    PENDING_REVIEW = "pending_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    IMPLEMENTED = "implemented"

class TemplateImprovementSuggestion(BaseModel):
    suggestion_id: str = Field(default_factory=lambda: str(uuid4()))
    created_at: datetime = Field(default_factory=datetime.utcnow)
    pattern_type: PatternType
    description: str = Field(..., min_length=10, max_length=500)
    supporting_sessions: int = Field(..., ge=10)
    frequency_percentage: float = Field(..., ge=0.0, le=100.0)
    recommended_action: str = Field(..., min_length=10)
    priority: Priority = Priority.MEDIUM
    status: SuggestionStatus = SuggestionStatus.PENDING_REVIEW

    @field_validator('supporting_sessions')
    def validate_statistical_significance(cls, v):
        if v < 10:
            raise ValueError('Minimum 10 sessions required for statistical significance (SC-005)')
        return v
```

---

## State Transitions

### GenerationSession State Machine

```
[Created]
  → requirements_gathering (questions_asked increments)
  → validation (validation_results populated)
  → generation (generation_time_seconds measured)
  → [Success] (success=True) OR [Failed] (success=False, error_message set)
  → saved_to_analytics
[End]
```

### TemplateImprovementSuggestion State Machine

```
[Created] (status=pending_review)
  → [Reviewed]
    → [Approved] (status=approved)
      → [Implemented] (status=implemented) [Terminal State]
    → [Rejected] (status=rejected) [Terminal State]
```

---

## Relationships Diagram

```
ProjectRequirements (1) ─── contains ───> (4) ConfigurationProfile
       │
       │ requests
       ↓
FeatureModule (0..n)
       │
       │ modifies
       ↓
ProjectTemplate (1) ─── generates ───> (1..n) Generated Files
       │
       │ validated_by
       ↓
StructureValidator
       │
       │ records
       ↓
GenerationSession (1)
       │
       │ aggregated_into (10+)
       ↓
TemplateImprovementSuggestion (0..n)
```

---

## Validation Summary

All validation rules are enforced by Pydantic models at runtime:

1. **Type Safety**: All fields have explicit types
2. **Range Constraints**: Numeric fields have min/max bounds (ge, le)
3. **Pattern Matching**: String fields use regex patterns where applicable
4. **Cross-Field Validation**: `@field_validator` decorators enforce relationships
5. **Enum Constraints**: Categorical fields use Enum types
6. **Custom Validation**: Complex rules implemented in validator methods

---

**Data Model Complete**: All entities defined with fields, relationships, and validation rules ready for implementation.
