# Research & Technical Decisions

**Feature**: Separate Spark Session Utilities Package
**Branch**: `002-spark-session-utilities`
**Created**: 2025-11-22
**Status**: Complete

## Overview

This document captures research findings and technical decisions for separating the Databricks utilities into three distinct packages: spark-session-utilities, databricks-uc-utilities, and databricks-shared-utilities.

---

## 1. Package Architecture Decision

### Decision

Implement a **Three-Package Architecture** with clear separation of concerns:
1. `spark-session-utilities` - Minimal Spark session management
2. `databricks-uc-utilities` - Unity Catalog operations (no Spark dependency)
3. `databricks-shared-utilities` - Full platform utilities (depends on both)

### Approach

**Package Dependencies**:
```
spark-session-utilities (standalone)
    └── PySpark, Pydantic, PyYAML

databricks-uc-utilities (standalone)
    └── Databricks SDK, Pydantic

databricks-shared-utilities (convenience package)
    ├── spark-session-utilities==0.2.0
    ├── databricks-uc-utilities==0.2.0
    └── Additional: logging, error handling, observability
```

**Import Pattern**:
```python
# Option 1: Minimal dependencies (Spark only)
from spark_session_utilities.config import SparkSessionFactory

# Option 2: UC operations only (no Spark)
from databricks_uc_utilities.catalog import CatalogOperations

# Option 3: Full platform
from databricks_utils.config import SparkSessionFactory, ConfigLoader
from databricks_utils.logging import get_logger
```

### Rationale

- **Dependency Minimization**: Projects install only what they need
- **Independent Evolution**: Each package can be versioned and released independently
- **Clear Responsibilities**: Spark, UC, and platform utilities are logically separated
- **Backward Compatibility**: databricks-shared-utilities re-exports everything for existing users
- **Security**: Smaller dependency trees reduce vulnerability surface

### Alternatives Considered

1. **Two-Package Architecture** (Spark + everything else): Rejected - still couples UC operations with Spark
2. **Monolithic Package**: Rejected - original architecture, forces unnecessary dependencies
3. **Four+ Packages** (separate logging, testing, etc.): Rejected - too granular, increases complexity
4. **Monorepo with Shared Code**: Rejected - doesn't solve the dependency problem

---

## 2. Configuration System Split

### Decision

Split configuration system across packages with **inheritance and composition**:
- Base `EnvironmentConfig` (Spark-only) in spark-session-utilities
- `CatalogConfig` in databricks-uc-utilities
- Extended `EnvironmentConfig` in databricks-shared-utilities (combines both)

### Approach

**spark-session-utilities/config/schema.py**:
```python
from pydantic import BaseModel

class SparkConfig(BaseModel):
    app_name: str
    master: Optional[str] = None
    config: Dict[str, str] = {}

class EnvironmentConfig(BaseModel):
    environment_type: str
    spark: SparkConfig
    workspace_host: Optional[str] = None
    cluster_id: Optional[str] = None
```

**databricks-uc-utilities/config/catalog_config.py**:
```python
from pydantic import BaseModel

class CatalogConfig(BaseModel):
    name: str
    schema_prefix: str

    @property
    def bronze_schema(self) -> str:
        return f"{self.schema_prefix}_bronze"
```

**databricks-shared-utilities/config/extended_config.py**:
```python
from spark_session_utilities.config.schema import EnvironmentConfig as BaseEnvironmentConfig
from databricks_uc_utilities.config import CatalogConfig

class EnvironmentConfig(BaseEnvironmentConfig):
    catalog: Optional[CatalogConfig] = None
```

### Rationale

- **Minimal Dependencies**: Each package only depends on what it needs
- **Type Safety**: Pydantic validation at all levels
- **Composition**: Extended config combines both without duplication
- **Backward Compatible**: Extended config supports all previous use cases

### Alternatives Considered

1. **Duplicate Config Schemas**: Rejected - violates DRY principle
2. **Single Config in Base Package**: Rejected - creates circular dependencies
3. **JSON Schema Instead of Pydantic**: Rejected - loses type safety and IDE support

---

## 3. Documentation Standardization

### Decision

Implement **Skyscanner-Specific Examples** across all documentation and docstrings to reflect real-world usage patterns.

### Approach

**Naming Conventions Applied**:
- **Catalogs**: `dev_trusted_silver` (development/silver layer), `dev_trusted_gold` (gold layer)
- **Schemas**: `meta_search` with medallion suffixes (`meta_search_bronze`, `meta_search_silver`, `meta_search_gold`)
- **Tables**: `flight_search_request` (primary example table)
- **Workspace**: `https://skyscanner-dev.cloud.databricks.com`

**Documentation Update Scope**:
- 14 Python files (all docstrings, examples in docstrings, type hints examples)
- 4 README.md files (quick start guides, usage examples, API references)
- 231+ individual replacements across:
  - Generic catalog names → `dev_trusted_silver`
  - Generic schema names → `meta_search`
  - Generic table names → `flight_search_request`
  - Generic workspace URLs → Skyscanner workspace URL

**Example Transformation**:
```python
# Before (generic)
ops = CatalogOperations(workspace_url="https://your-workspace.databricks.com")
ops.create("dev_analytics", comment="Development catalog")
table = ops.get("dev_analytics.customer_360_bronze.customers")

# After (Skyscanner-specific)
ops = CatalogOperations(workspace_url="https://skyscanner-dev.cloud.databricks.com")
ops.create("dev_trusted_silver", comment="Development trusted silver catalog")
table = ops.get("dev_trusted_silver.meta_search_bronze.flight_search_request")
```

### Rationale

- **Immediate Usability**: New developers can copy-paste examples that work with actual infrastructure
- **Consistency**: All documentation uses same naming conventions
- **Onboarding**: Reduces cognitive load by using familiar real-world names
- **Documentation as Code**: Examples reflect actual production patterns

### Impact

Successfully updated across all three packages:
- **spark-session-utilities**: Workspace URL examples
- **databricks-uc-utilities**: All catalog, schema, and table examples
- **databricks-shared-utilities**: Combined examples showing full stack

---

## 4. File Naming Convention: schema.py

### Decision

Use `schema.py` as the filename for Pydantic model definitions that define data structure schemas.

### Rationale

**Why "schema.py"?**
1. **Standard Python Convention**: In Python ecosystem, "schema" refers to data structure definitions
2. **Pydantic Models are Schemas**: Pydantic models define:
   - Data structure (fields and types)
   - Validation rules (constraints)
   - Serialization/deserialization logic
3. **Separation of Concerns**:
   - `schema.py` - Data structure definitions (what the data looks like)
   - `loader.py` - Data loading logic (how to create instances)
   - `operations.py` - Business logic (what to do with the data)
4. **Industry Pattern**: Common in projects using:
   - FastAPI (uses `schemas.py` for Pydantic models)
   - Django REST Framework (uses `serializers.py` for similar purpose)
   - SQLAlchemy projects (distinguish `models.py` for ORM vs `schemas.py` for API)

**File Contents**:
```python
# spark-session-utilities/src/spark_session_utilities/config/schema.py
class SparkConfig(BaseModel):      # Schema for Spark configuration
class EnvironmentConfig(BaseModel): # Schema for environment configuration
```

### Alternatives Considered

1. **models.py**: Rejected - typically reserved for database ORM models
2. **config.py**: Rejected - used for configuration loading logic
3. **types.py**: Rejected - typically for type aliases and TypedDict
4. **schemas.py** (plural): Alternative naming, equally valid

---

## Technology Stack Summary

| Component | Technology Choice | Version |
|-----------|------------------|---------|
| **Package Management** | PyPI | Private repository |
| **Dependency Management** | pip + requirements.txt | Exact pinning (==X.Y.Z) |
| **Type Safety** | Pydantic | 2.0+ |
| **Configuration** | YAML + Pydantic | Type-safe validation |
| **Spark** | PySpark | 3.4+ |
| **Unity Catalog** | Databricks SDK | 0.12+ |
| **Testing** | pytest + chispa | Function-scoped fixtures |
| **Documentation** | Python docstrings + Markdown | Skyscanner conventions |
| **CI/CD** | GitHub Actions | Multi-package workflow |

---

## Open Questions & Future Research

1. **Version Synchronization**: Should all three packages always have the same version number?
   - Current: Independent versioning (spark-session-utilities v0.2.0, databricks-shared-utilities v0.2.0)
   - Alternative: Synchronized versions to simplify dependency management

2. **Testing Strategy**: How to test the re-export mechanism comprehensively?
   - Current: Manual import testing
   - Future: Automated compatibility testing between packages

3. **Documentation Site**: Should we create a unified documentation site for all three packages?
   - Current: Individual README files
   - Future: Sphinx or MkDocs site with cross-package navigation

4. **UC Operations Without SDK**: Can we provide lightweight UC operations using REST API directly?
   - Current: Full Databricks SDK dependency
   - Future: Optional lightweight implementation for CI/CD scripts

---

## 4. Workspace URL Derivation

### Decision

Implement **workspace_url Property on EnvironmentConfig** with automatic derivation from environment_type when workspace_host is not explicitly set.

### Approach

**Implementation Pattern**:
```python
class EnvironmentConfig(BaseModel):
    environment_type: str
    workspace_host: Optional[str] = None

    @property
    def workspace_url(self) -> Optional[str]:
        """Derive workspace URL with precedence: explicit > derived > default"""
        if self.workspace_host is not None:
            return self.workspace_host

        url_mapping = {
            "local": None,
            "lab": "https://skyscanner-dev.cloud.databricks.com",
            "dev": "https://skyscanner-dev.cloud.databricks.com",
            "prod": "https://skyscanner-prod.cloud.databricks.com",
        }

        return url_mapping.get(
            self.environment_type.lower() if self.environment_type else None,
            "https://skyscanner-dev.cloud.databricks.com"  # Safe default
        )
```

**URL Mapping**:
- `local` → `None` (local Spark instance, no Databricks workspace)
- `lab` → `https://skyscanner-dev.cloud.databricks.com` (shared dev workspace)
- `dev` → `https://skyscanner-dev.cloud.databricks.com` (shared dev workspace)
- `prod` → `https://skyscanner-prod.cloud.databricks.com` (production workspace)
- Unknown → `https://skyscanner-dev.cloud.databricks.com` (safe default)

**Precedence Rules**:
1. **Explicit workspace_host** (if set in config file) - highest priority
2. **Derived from environment_type** (using mapping table)
3. **Default to dev workspace** (when both are None/unknown)

### Rationale

- **Reduces Configuration Boilerplate**: No need to specify workspace_host in every config file
- **Consistency**: Ensures environment_type and workspace URL stay in sync
- **Flexibility**: Explicit workspace_host can override derivation for edge cases
- **Backward Compatible**: workspace_host field unchanged; workspace_url is new property
- **Safe Default**: Defaulting to dev prevents accidental prod access
- **Simple Implementation**: Dict lookup, no I/O, <1ms performance
- **Pythonic API**: Property access (`config.workspace_url`) more natural than method call

### Alternatives Considered

1. **Method Instead of Property** (`config.get_workspace_url()`):
   - Rejected: Less Pythonic, makes simple data access look like complex operation
   - Property better conveys that this is derived data, not a side-effectful operation

2. **Pydantic computed_field**:
   - Rejected: Overkill for simple derivation, adds complexity
   - Standard @property sufficient and more familiar

3. **Always Derive (Ignore workspace_host)**:
   - Rejected: Removes user control for edge cases
   - Some users may need non-standard workspace URLs

4. **Raise Error on Mismatch**:
   - Rejected: Too strict, breaks valid use cases
   - Users should be able to override derivation

5. **Environment Variables for URLs**:
   - Rejected: Less portable, harder to version control
   - Config files are canonical source of configuration

6. **Return None for Unknown Environments**:
   - Rejected: Breaks common development workflow
   - Dev is safest default (non-destructive, available to all developers)

### Testing Strategy

**Unit Tests** (spark-session-utilities):
- Test all environment_type mappings (local/lab/dev/prod/unknown)
- Test precedence: explicit workspace_host overrides derivation
- Test default behavior: None environment_type → dev URL
- Test case-insensitivity: "LOCAL" / "Local" / "local" all work
- Test None handling: workspace_host=None, environment_type=None

**Integration Tests** (databricks-shared-utilities):
- Verify actual connectivity to skyscanner-dev workspace
- Verify actual connectivity to skyscanner-prod workspace (if credentials available)
- Verify SparkSessionFactory uses workspace_url correctly
- Verify extended EnvironmentConfig inherits property correctly

---

**Research Complete**: All technical decisions documented including workspace URL derivation.
