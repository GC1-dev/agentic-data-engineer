# Data Model: Package Separation Architecture

**Feature**: Separate Data Quality and Observability Utilities
**Date**: 2025-11-22
**Status**: Complete

## Overview

This document defines the package structures, module organization, and entity relationships for the separated utility packages. Since this is an infrastructure/refactoring feature (not a new feature with domain entities), the "data model" focuses on package architecture, module boundaries, and API surfaces.

---

## Package Architecture

### Package Dependency Graph

```
┌─────────────────────────────────────┐
│  databricks-shared-utilities        │
│  (Unity Catalog, testing, errors)   │
└──────────────┬──────────────────────┘
               │ depends on
               ├──────────────────────────┐
               │                          │
               ▼                          ▼
┌──────────────────────────┐   ┌────────────────────────┐
│ spark-session-utilities  │   │ databricks-uc-utilities│
│ (Session, config, logs)  │   │ (Unity Catalog ops)    │
└──────────────────────────┘   └────────────────────────┘
               ▲
               │ PySpark dependency (external)
               │
┌──────────────┴──────────────────────────────────┐
│                                                  │
│  ┌────────────────────────┐  ┌──────────────────────────────┐
│  │ data-quality-utilities │  │ data-observability-utilities │
│  │ (Validation, profiling)│  │ (Monte Carlo integration)    │
│  └────────────────────────┘  └──────────────────────────────┘
│
└─ Layer 2: Independent utilities (no internal deps)
```

**Key Principles**:
- Layer 2 packages (data-quality, observability) have NO dependencies on internal packages
- Layer 1 packages (spark-session, uc) are leaf packages
- Layer 3 (databricks-shared-utilities) can depend on Layers 1-2 but not vice versa
- All packages can depend on external packages (PySpark, Pydantic, etc.)

---

## Package Structures

### 1. data-quality-utilities

**Purpose**: Standalone data quality validation, profiling, quality gates, and anomaly detection

**Module Structure**:

```python
data_quality_utilities/
├── __init__.py                 # Public API exports
├── rules.py                    # ValidationRule, RuleType, Severity
├── validator.py                # ValidationRuleset, ValidationResult, RuleViolation
├── profiler.py                 # DataProfiler, ColumnProfile variants, DataProfile
├── gates.py                    # QualityGate (future - User Story 2)
├── anomaly.py                  # AnomalyDetector (future - User Story 4)
├── baseline.py                 # BaselineManager (future - User Story 4)
├── reports.py                  # Report generators (future - User Story 5)
└── templates/                  # HTML/JSON report templates (future)
    └── __init__.py
```

**Key Entities** (from existing databricks_utils.data_quality):

| Entity | Type | Purpose | Source File |
|--------|------|---------|-------------|
| `ValidationRule` | Class | Defines data validation rule with type, severity, parameters | rules.py |
| `RuleType` | Enum | Rule types (COMPLETENESS, UNIQUENESS, FRESHNESS, etc.) | rules.py |
| `Severity` | Enum | Rule severity (CRITICAL, WARNING, INFO) | rules.py |
| `ValidationRuleset` | Class | Collection of validation rules for a dataset | validator.py |
| `ValidationResult` | Class | Results of validation with violations and status | validator.py |
| `RuleViolation` | Class | Details of single rule failure | validator.py |
| `Status` | Enum | Overall validation status (PASSED, FAILED, WARNING) | validator.py |
| `DataProfiler` | Class | Generates statistical profiles for DataFrames | profiler.py |
| `DataProfile` | Class | Complete statistical profile of DataFrame | profiler.py |
| `ColumnProfile` | Class | Base profile for column statistics | profiler.py |
| `NumericColumnProfile` | Class | Profile for numeric columns with stats | profiler.py |
| `StringColumnProfile` | Class | Profile for string columns with lengths | profiler.py |
| `TimestampColumnProfile` | Class | Profile for timestamp columns with freshness | profiler.py |

**Public API** (exported from `__init__.py`):
```python
from data_quality_utilities import (
    # Rules and severity
    ValidationRule,
    RuleType,
    Severity,
    # Validation execution
    ValidationRuleset,
    ValidationResult,
    RuleViolation,
    Status,
    # Profiling
    DataProfiler,
    DataProfile,
    ColumnProfile,
    NumericColumnProfile,
    StringColumnProfile,
    TimestampColumnProfile,
)
```

**Dependencies**:
- PySpark 3.x (DataFrame operations)
- Pydantic 2.x (rule validation, configuration)
- scipy, numpy (anomaly detection - future)

---

### 2. data-observability-utilities

**Purpose**: Standalone Monte Carlo observability integration and monitoring

**Module Structure**:

```python
data_observability_utilities/
├── __init__.py                      # Public API exports
├── monte_carlo_client.py            # Monte Carlo SDK wrapper
├── monte_carlo_integration.py       # High-level integration helpers
└── config.py                        # Observability configuration
```

**Key Entities** (from existing databricks_utils.observability):

| Entity | Type | Purpose | Source File |
|--------|------|---------|-------------|
| `MonteCarloClient` | Class | Wrapper around Monte Carlo SDK | monte_carlo_client.py |
| `MonteCarloIntegration` | Class | High-level Monte Carlo operations | monte_carlo_integration.py |
| `ObservabilityConfig` | Class | Configuration for observability features | config.py |

**Public API** (exported from `__init__.py`):
```python
from data_observability_utilities import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig,
)
```

**Dependencies**:
- Monte Carlo Data SDK (observability platform)
- PySpark 3.x (DataFrame operations)

**Note**: Detailed module structure may be sparse initially as observability module is minimal in current codebase. Will be expanded in future user stories.

---

### 3. spark-session-utilities

**Purpose**: Standalone Spark session management, configuration, and Spark-specific logging

**Module Structure**:

```python
spark_session_utilities/
├── __init__.py                      # Public API exports
├── session.py                       # SparkSession management
├── config/
│   ├── __init__.py
│   └── spark_session.py             # Spark configuration classes
└── logging/
    ├── __init__.py
    └── spark_logger.py               # Spark logging utilities
```

**Key Entities** (from existing databricks_utils.config + databricks_utils.logging):

| Entity | Type | Purpose | Source File |
|--------|------|---------|-------------|
| `SparkSessionManager` | Class | Spark session lifecycle management | session.py |
| `SparkConfig` | Class | Spark configuration builder | config/spark_session.py |
| `SparkLogger` | Class | Spark-specific logging utilities | logging/spark_logger.py |

**Public API** (exported from `__init__.py`):
```python
from spark_session_utilities import (
    SparkSessionManager,
    SparkConfig,
    SparkLogger,
)
```

**Dependencies**:
- PySpark 3.x (Spark session, configuration)
- Delta Lake (Spark extension for Delta tables)

**Note**: Consolidates ALL Spark-related utilities per user clarification.

---

### 4. databricks-shared-utilities (MODIFIED)

**Purpose**: Core utilities for Unity Catalog, testing fixtures, common errors

**Module Structure** (AFTER migration):

```python
databricks_utils/
├── __init__.py                      # Public API exports (reduced)
├── testing/                         # KEEP: Shared test fixtures
│   ├── __init__.py
│   └── fixtures.py
├── errors/                          # KEEP: Common error types
│   ├── __init__.py
│   └── exceptions.py
└── [REMOVED modules]
    ├── data_quality/                # REMOVED: → data-quality-utilities
    ├── observability/               # REMOVED: → data-observability-utilities
    ├── config/spark_session.py      # REMOVED: → spark-session-utilities
    └── logging/                     # REMOVED: → spark-session-utilities
```

**Remaining Public API**:
```python
from databricks_utils import (
    # Testing utilities
    spark_fixture,
    sample_dataframe,
    # Common errors
    ConfigurationError,
    ValidationError,
)
```

**Dependencies** (AFTER migration):
- spark-session-utilities==1.0.0+ (for Spark integration)
- databricks-uc-utilities==0.2.0 (for Unity Catalog)

**Breaking Change**: This is version 0.3.0 (breaking change from 0.2.0) due to removed modules.

---

## Module Migration Map

### Migration Matrix

| Source (databricks-shared-utilities) | Destination Package | New Module Path |
|--------------------------------------|---------------------|-----------------|
| `databricks_utils.data_quality.rules` | data-quality-utilities | `data_quality_utilities.rules` |
| `databricks_utils.data_quality.validator` | data-quality-utilities | `data_quality_utilities.validator` |
| `databricks_utils.data_quality.profiler` | data-quality-utilities | `data_quality_utilities.profiler` |
| `databricks_utils.data_quality.templates` | data-quality-utilities | `data_quality_utilities.templates` |
| `databricks_utils.observability.*` | data-observability-utilities | `data_observability_utilities.*` |
| `databricks_utils.config.spark_session` | spark-session-utilities | `spark_session_utilities.config.spark_session` |
| `databricks_utils.logging.*` | spark-session-utilities | `spark_session_utilities.logging.*` |
| `databricks_utils.testing.*` | databricks-shared-utilities | UNCHANGED |
| `databricks_utils.errors.*` | databricks-shared-utilities | UNCHANGED |

---

## Import Path Changes

### Example: Data Quality Validation

**Before** (databricks-shared-utilities 0.2.0):
```python
from databricks_utils.data_quality import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    RuleType,
)
from databricks_utils.data_quality.profiler import DataProfiler

ruleset = ValidationRuleset(name="my_rules")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)
```

**After** (data-quality-utilities 1.0.0):
```python
from data_quality_utilities import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    RuleType,
    DataProfiler,
)

ruleset = ValidationRuleset(name="my_rules")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)
```

**Changes**:
- Import path: `databricks_utils.data_quality` → `data_quality_utilities`
- Submodule imports: `databricks_utils.data_quality.profiler` → `data_quality_utilities.profiler` OR top-level import
- API unchanged: Class names, method signatures, parameters identical

---

### Example: Spark Session Management

**Before** (databricks-shared-utilities 0.2.0):
```python
from databricks_utils.config.spark_session import SparkConfig
from databricks_utils.logging import SparkLogger

config = SparkConfig.for_databricks()
spark = config.create_session()
logger = SparkLogger(spark)
```

**After** (spark-session-utilities 1.0.0):
```python
from spark_session_utilities import SparkConfig, SparkLogger

config = SparkConfig.for_databricks()
spark = config.create_session()
logger = SparkLogger(spark)
```

**Changes**:
- Import path: `databricks_utils.config.spark_session` → `spark_session_utilities`
- Import path: `databricks_utils.logging` → `spark_session_utilities`
- Simpler top-level imports (no nested submodules)
- API unchanged: Class names, method signatures identical

---

## API Compatibility Matrix

| Component | Class Name | Method Signatures | Parameters | Return Types | Breaking Changes |
|-----------|-----------|-------------------|------------|--------------|------------------|
| ValidationRule | UNCHANGED | UNCHANGED | UNCHANGED | UNCHANGED | None |
| ValidationRuleset | UNCHANGED | UNCHANGED | UNCHANGED | UNCHANGED | None |
| DataProfiler | UNCHANGED | UNCHANGED | UNCHANGED | UNCHANGED | None |
| MonteCarloClient | UNCHANGED | UNCHANGED | UNCHANGED | UNCHANGED | None |
| SparkConfig | UNCHANGED | UNCHANGED | UNCHANGED | UNCHANGED | None |

**Key Guarantee**: Zero breaking changes to public APIs (only import paths change)

---

## Validation Rules

### Package Isolation Rules

1. **No cross-package imports** (Layer 2):
   - `data_quality_utilities` MUST NOT import from `data_observability_utilities`
   - `data_observability_utilities` MUST NOT import from `data_quality_utilities`
   - Both MUST NOT import from `databricks_shared_utilities`

2. **Dependency hierarchy enforcement**:
   - `databricks_shared_utilities` MAY import from `spark_session_utilities`
   - `data_quality_utilities` MUST NOT import from ANY internal package
   - `spark_session_utilities` MUST NOT import from ANY internal package

3. **External dependency isolation**:
   - Each package declares own dependencies in `pyproject.toml`
   - No shared dependency file across packages

### API Stability Rules

1. **Public API preservation**:
   - All exported classes, methods, parameters MUST remain identical
   - Only import paths change
   - Type hints preserved
   - Docstrings preserved

2. **Version compatibility**:
   - New packages start at 1.0.0 (stable API)
   - databricks-shared-utilities bumps to 0.3.0 (breaking change - modules removed)

---

## Testing Strategy

### Test Coverage Requirements

| Test Type | Coverage Target | Purpose |
|-----------|----------------|---------|
| Unit Tests | ≥90% line coverage | Validate individual functions/classes |
| Integration Tests | Primary workflows | Validate multi-component interactions |
| Contract Tests | 100% public API | Verify API stability across versions |

### Contract Test Examples

**Test: data-quality-utilities public API**
```python
def test_public_api_exports():
    """Verify all expected classes are exported from top-level package."""
    from data_quality_utilities import (
        ValidationRule,
        ValidationRuleset,
        ValidationResult,
        RuleViolation,
        Status,
        Severity,
        RuleType,
        DataProfiler,
        DataProfile,
        ColumnProfile,
    )
    # If any import fails, contract is broken
    assert all([
        ValidationRule,
        ValidationRuleset,
        DataProfiler,
        # ... all exports present
    ])

def test_validation_rule_api_compatibility():
    """Verify ValidationRule has expected factory methods."""
    from data_quality_utilities import ValidationRule

    # These methods must exist (API contract)
    assert hasattr(ValidationRule, "completeness")
    assert hasattr(ValidationRule, "uniqueness")
    assert hasattr(ValidationRule, "freshness")

    # Factory methods must work
    rule = ValidationRule.completeness("col", allow_null=False)
    assert rule is not None
```

**Test: No circular dependencies**
```python
def test_no_internal_dependencies():
    """Verify data-quality-utilities doesn't import from other internal packages."""
    import sys
    import data_quality_utilities

    # Get all loaded modules after import
    loaded_modules = sys.modules.keys()

    # These internal packages MUST NOT be loaded
    forbidden = [
        "databricks_utils",
        "data_observability_utilities",
        "spark_session_utilities",
    ]

    for forbidden_module in forbidden:
        assert not any(
            forbidden_module in mod for mod in loaded_modules
        ), f"Forbidden dependency on {forbidden_module}"
```

---

## Rollout Plan

### Phase 1: Create New Packages (Parallel)
1. Create `data-quality-utilities/` directory structure
2. Create `data-observability-utilities/` directory structure
3. Create `spark-session-utilities/` directory structure
4. Generate pyproject.toml for each package

### Phase 2: Migrate Code (Sequential per package)
1. Copy modules to new packages
2. Update import paths within modules
3. Update `__init__.py` exports
4. Verify no internal cross-references

### Phase 3: Rewrite Tests (Parallel)
1. Write contract tests first (API verification)
2. Write unit tests for core functionality
3. Write integration tests for workflows

### Phase 4: Update databricks-shared-utilities
1. Remove migrated modules
2. Update pyproject.toml dependencies
3. Update README with migration guide
4. Bump version to 0.3.0

### Phase 5: Validation
1. Run all test suites
2. Verify dependency graph (no circular deps)
3. Test package installation independently
4. Run contract tests

---

## Success Criteria

✅ All 3 new packages installable independently via pip
✅ Zero circular dependencies (verified by contract tests)
✅ Public APIs unchanged (verified by contract tests)
✅ Test coverage ≥90% for all packages
✅ databricks-shared-utilities reduced by ≥50% LOC
✅ All migration documentation complete

---

**Review Status**: ✅ Complete
**Next Phase**: Contracts Generation
