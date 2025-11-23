# Research & Architectural Decisions: Package Separation

**Feature**: Separate Data Quality and Observability Utilities
**Date**: 2025-11-22
**Status**: Complete

## Overview

This document captures architectural decisions, research findings, and best practices for separating data quality and observability utilities from the monolithic `databricks-shared-utilities` package into three independent packages.

## Architectural Decisions

### AD-001: Package Naming Convention

**Decision**: Use hyphenated names for package directories, underscored names for Python modules

**Rationale**:
- **Directory names**: `data-quality-utilities/`, `data-observability-utilities/`, `spark-session-utilities/`
  - Follows Python packaging best practices (PEP 423)
  - Improves readability in file system and GitHub
  - Prevents module naming conflicts
- **Python module names**: `data_quality_utilities`, `data_observability_utilities`, `spark_session_utilities`
  - Python convention requires underscores (hyphens invalid in import statements)
  - Consistent with existing `databricks_utils` naming

**Alternatives Considered**:
- **All underscores**: Less readable in file system, harder to distinguish from module names
- **All hyphens**: Would require setuptools package name mapping, adds complexity
- **Short names** (dqu, dobu): Poor discoverability, unclear purpose

**References**: PEP 423 (Naming conventions for packages)

---

### AD-002: Import Path Migration Strategy

**Decision**: Complete import path replacement (clean break, no import redirection)

**Rationale**:
- User explicitly requested no backward compatibility
- Clean break simplifies codebase (no aliasing, no deprecation warnings)
- Forces users to consciously update dependencies and imports
- Prevents ambiguity about which package is being used
- Reduces long-term maintenance burden

**Migration Pattern**:
```python
# OLD (databricks-shared-utilities)
from databricks_utils.data_quality import ValidationRule, ValidationRuleset
from databricks_utils.data_quality.profiler import DataProfiler

# NEW (data-quality-utilities)
from data_quality_utilities import ValidationRule, ValidationRuleset
from data_quality_utilities.profiler import DataProfiler
```

**Alternatives Considered**:
- **Import redirection in databricks-shared-utilities**: Rejected per user request
- **Symlinks**: Would create package installation conflicts
- **Namespace packages**: Adds complexity, not needed for clean break

---

### AD-003: Dependency Management Across Packages

**Decision**: Each package declares own dependencies explicitly, no shared dependency management

**Rationale**:
- Independent versioning requires independent dependency declarations
- Prevents transitive dependency conflicts
- Users install only what they need
- Clear dependency boundaries per package

**Package Dependencies**:

| Package | Core Dependencies | Optional Dependencies |
|---------|-------------------|----------------------|
| data-quality-utilities | PySpark 3.x, Pydantic 2.x, scipy, numpy | pytest (dev) |
| data-observability-utilities | Monte Carlo SDK, PySpark 3.x | pytest (dev) |
| spark-session-utilities | PySpark 3.x, Delta Lake | pytest (dev) |
| databricks-shared-utilities | spark-session-utilities, databricks-uc-utilities | pytest (dev) |

**Alternatives Considered**:
- **Shared requirements.txt**: Would force users to install all dependencies
- **Optional dependency groups**: Adds complexity, doesn't solve isolation issue

---

### AD-004: Test Suite Strategy

**Decision**: Rewrite tests from scratch for new package structure (per user request)

**Rationale**:
- User explicitly chose option C (rewrite tests) in clarification workflow
- Fresh test suite ensures tests use new import paths correctly
- Opportunity to improve test organization and coverage
- Eliminates technical debt from old test structure

**Test Structure per Package**:
```
tests/
├── unit/                    # Fast, isolated unit tests
│   ├── test_rules.py
│   ├── test_validator.py
│   └── test_profiler.py
├── integration/             # Multi-component integration tests
│   └── test_validation_pipeline.py
└── contract/                # API contract tests
    └── test_public_api.py
```

**Test Coverage Goals**:
- Unit tests: ≥90% code coverage
- Integration tests: Cover primary user workflows
- Contract tests: Verify public API stability

**Alternatives Considered**:
- **Copy existing tests**: Rejected by user
- **Adapt existing tests**: Rejected by user
- **No tests**: Not acceptable for production utilities

---

### AD-005: Versioning Strategy

**Decision**: Independent semantic versioning starting at 1.0.0 for each new package

**Rationale**:
- Each package evolves independently (per user request)
- Starting at 1.0.0 signals production-ready, stable API
- Follows semantic versioning (MAJOR.MINOR.PATCH)
- Allows different release cadences per package

**Initial Versions**:
- `data-quality-utilities==1.0.0` (migrated stable code)
- `data-observability-utilities==1.0.0` (migrated stable code)
- `spark-session-utilities==1.0.0` (migrated stable code)
- `databricks-shared-utilities==0.3.0` (breaking change - modules removed)

**Alternatives Considered**:
- **Shared versioning**: Would couple release cycles, rejected by user
- **Starting at 0.1.0**: Implies unstable API, but code is already stable

---

### AD-006: Package Configuration (pyproject.toml)

**Decision**: Use modern pyproject.toml (PEP 621) for all packages

**Rationale**:
- Modern Python packaging standard (PEP 621, PEP 517)
- Single source of truth for package metadata
- Better tool integration (pip, build, twine)
- Consistent with existing databricks-shared-utilities configuration

**Standard Structure**:
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "package-name"
version = "1.0.0"
description = "Package description"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
dependencies = [...]

[project.optional-dependencies]
dev = ["pytest>=7.0.0", ...]

[tool.setuptools.packages.find]
where = ["src"]
```

**Alternatives Considered**:
- **setup.py**: Deprecated approach, less declarative
- **setup.cfg + setup.py**: Legacy hybrid approach

---

### AD-007: Spark Logging Consolidation

**Decision**: Move ALL Spark-related utilities to spark-session-utilities

**Rationale**:
- User clarification: "spark logging goes to spark-session-utilities"
- Co-locate Spark session management with Spark logging (related concerns)
- Single package for all Spark configuration and utilities
- Clear package purpose: "Everything Spark"

**Modules to Move**:
- `databricks_utils.config.spark_session` → `spark_session_utilities.config.spark_session`
- `databricks_utils.logging` → `spark_session_utilities.logging`

**Alternatives Considered**:
- **Keep logging in databricks-shared-utilities**: Would create unnecessary dependency
- **Separate spark-logging-utilities package**: Over-engineering, rejected

---

### AD-008: Directory Structure (Top-Level vs Nested)

**Decision**: Create 3 new top-level directories at repository root (per user request)

**Rationale**:
- User clarification: "Create 3 new top-level directories"
- Clear physical separation in repository
- Independent package boundaries visible in file system
- Simplifies CI/CD pipelines (each package can be built independently)

**Structure**:
```
/
├── data-quality-utilities/
├── data-observability-utilities/
├── spark-session-utilities/
├── databricks-shared-utilities/    # Existing
└── databricks-uc-utilities/         # Existing
```

**Alternatives Considered**:
- **Nested under packages/ directory**: Rejected by user
- **Flat src/ with namespace packages**: Would not provide clean separation

---

### AD-009: Documentation Strategy

**Decision**: Each package has independent README with installation, usage, API reference

**Rationale**:
- Independent packages need independent documentation
- Users should be able to understand each package without reading others
- Reduces cognitive load for specialized use cases
- Supports independent package discovery (PyPI, GitHub)

**README Structure**:
1. Package overview (1-2 sentences)
2. Installation (`pip install package-name`)
3. Quick start example (5-10 lines of code)
4. Core concepts (what problems it solves)
5. API reference (link to detailed docs or inline)
6. Migration guide (for databricks-shared-utilities users)

**Alternatives Considered**:
- **Single monorepo README**: Would not support independent package usage
- **External docs site**: Over-engineering for initial release

---

### AD-010: Circular Dependency Prevention

**Decision**: Strict dependency hierarchy with no circular references

**Rationale**:
- Prevents package installation conflicts
- Ensures each package can be installed independently
- Maintains clear architectural boundaries

**Dependency Hierarchy** (can depend on packages below, never above):
```
Layer 3: databricks-shared-utilities
         ├─ depends on: spark-session-utilities, databricks-uc-utilities
         └─ NOT allowed: data-quality-utilities, data-observability-utilities

Layer 2: data-quality-utilities, data-observability-utilities
         ├─ depends on: PySpark, Pydantic, Monte Carlo SDK (external only)
         └─ NOT allowed: databricks-shared-utilities, spark-session-utilities

Layer 1: spark-session-utilities
         ├─ depends on: PySpark, Delta Lake (external only)
         └─ NOT allowed: All internal packages
```

**Enforcement**:
- Contract tests verify no unexpected imports
- CI pipeline checks dependency graph
- Code review checklist includes dependency validation

**Alternatives Considered**:
- **Allow data-quality to depend on spark-session-utilities**: Would couple packages unnecessarily
- **No hierarchy**: Would risk circular dependencies

---

## Best Practices Applied

### Python Package Structure
- **Source layout** (`src/package_name/`): Prevents accidental imports from working directory
- **Test isolation**: Tests in separate `tests/` directory
- **Explicit `__init__.py`**: Clear public API definition

### Migration Safety
- **Incremental migration**: Move one module at a time, test after each move
- **Import validation**: Run tests to catch missing imports
- **Dependency validation**: Verify no circular dependencies introduced

### Code Quality
- **Type hints**: Preserve existing type annotations
- **Docstrings**: Maintain existing documentation
- **Code formatting**: Use black, ruff (existing tools)

---

## Technology Stack Validation

### Python 3.10+
- **Status**: ✅ Validated
- **Rationale**: Existing codebase standard, compatible with Databricks Runtime 13.0+
- **Risk**: None - well-established baseline

### PySpark 3.x
- **Status**: ✅ Validated
- **Rationale**: Core dependency for all data utilities
- **Risk**: None - already in use across all packages

### Pydantic 2.x
- **Status**: ✅ Validated
- **Rationale**: Existing validation framework in data_quality module
- **Risk**: None - already in production use

### pytest
- **Status**: ✅ Validated
- **Rationale**: Existing test framework
- **Risk**: None - well-established tooling

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Import path errors in user code | High | Medium | Comprehensive migration guide, clear error messages |
| Circular dependencies introduced | Low | High | Strict dependency hierarchy, contract tests |
| Test coverage regression | Medium | Medium | Rewrite tests with ≥90% coverage target |
| Package size bloat | Low | Low | Independent dependencies, no bundling |
| Version conflicts | Low | Medium | Independent versioning, clear dependency ranges |

---

## Open Questions

**None** - All technical unknowns resolved through user clarification workflow.

---

## References

- PEP 420: Implicit Namespace Packages
- PEP 423: Naming conventions and recipes related to packaging
- PEP 517: A build-system independent format for source trees
- PEP 621: Storing project metadata in pyproject.toml
- Python Packaging User Guide: https://packaging.python.org/
- Semantic Versioning 2.0.0: https://semver.org/

---

**Review Status**: ✅ Complete
**Approved By**: Workflow (user clarifications integrated)
**Next Phase**: Phase 1 - Data Model & Contracts
