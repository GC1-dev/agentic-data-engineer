# Implementation Plan: Separate Data Quality and Observability Utilities

**Branch**: `005-separate-utilities` | **Date**: 2025-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-separate-utilities/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature separates data quality and observability utilities from the monolithic `databricks-shared-utilities` package into three independent, standalone packages: `data-quality-utilities`, `data-observability-utilities`, and `spark-session-utilities`. This is a clean break migration (no backward compatibility) that enables:

- Independent package installation and versioning
- Reduced dependency footprint for specialized use cases
- Clearer separation of concerns (validation vs monitoring vs Spark management)
- Simplified maintenance and development workflows

**Technical Approach**: Create three new top-level directories at repository root, migrate code modules with updated import paths, create independent package configurations (pyproject.toml), rewrite test suites from scratch for each package, and remove migrated modules from databricks-shared-utilities.

## Technical Context

**Language/Version**: Python 3.10+ (existing codebase standard)
**Primary Dependencies**:
- **data-quality-utilities**: PySpark 3.x, Pydantic 2.x, scipy/numpy (for anomaly detection)
- **data-observability-utilities**: Monte Carlo Data SDK, PySpark 3.x
- **spark-session-utilities**: PySpark 3.x, Delta Lake
- **databricks-shared-utilities** (remaining): databricks-uc-utilities==0.2.0, spark-session-utilities==0.2.0

**Storage**: N/A (utilities library packages - no persistent storage)
**Testing**: pytest 7.0+, pytest-cov 4.0+ (existing test infrastructure)
**Target Platform**: Databricks Runtime 13.0+ (DBR), local PySpark environments
**Project Type**: Multi-package library monorepo (4 independent packages sharing repository)
**Performance Goals**:
- Package installation < 30 seconds
- Validation rule execution < 5 seconds per 1M rows (sampling-based)
- Profile generation < 30 seconds per 100k sample rows
- Zero performance degradation from package separation

**Constraints**:
- No circular dependencies between packages
- Each package independently installable via pip
- API compatibility preserved (same class names, method signatures)
- Zero runtime overhead from import path changes

**Scale/Scope**:
- 3 new packages to create (data-quality, observability, spark-session)
- ~2000 LOC to migrate from databricks-shared-utilities
- 4-6 modules per new package
- Complete test suite rewrite (~20-30 test files across all packages)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ PASS (No constitution defined - using default architectural best practices)

**Notes**: The repository does not have a project-specific constitution defined (`.specify/memory/constitution.md` contains only template placeholders). This feature follows standard Python package architecture best practices:

- **Modularity**: Clear separation of concerns across independent packages
- **Testability**: Each package has independent test suites
- **Simplicity**: Clean break migration avoids complex backward compatibility layers
- **Independence**: No circular dependencies, each package standalone

**Post-Design Re-check**: ✅ PASS

After completing Phase 1 design (research.md, data-model.md, contracts/), verified:

- ✅ **Modularity**: 3 independent packages with clear boundaries (data-quality, observability, spark-session)
- ✅ **No circular dependencies**: Strict dependency hierarchy enforced (Layer 2 packages have zero internal dependencies)
- ✅ **Testability**: Each package has independent test suites (unit, integration, contract)
- ✅ **API stability**: Public APIs preserved exactly (zero breaking changes beyond import paths)
- ✅ **Simplicity**: Clean break migration avoids complex backward compatibility layers
- ✅ **Independence**: Each package independently installable, versioned, and testable

No architectural violations detected. Design adheres to best practices for Python package separation.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Repository Root - Multi-package Monorepo Structure
.
├── data-quality-utilities/              # NEW: Data quality validation package
│   ├── src/
│   │   └── data_quality_utilities/
│   │       ├── __init__.py
│   │       ├── rules.py                # ValidationRule, RuleType, Severity
│   │       ├── validator.py             # ValidationRuleset, ValidationResult
│   │       ├── profiler.py              # DataProfiler, ColumnProfile variants
│   │       ├── gates.py                 # QualityGate (future)
│   │       ├── anomaly.py               # AnomalyDetector (future)
│   │       ├── baseline.py              # BaselineManager (future)
│   │       └── templates/               # Report templates (future)
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── contract/
│   ├── pyproject.toml                   # Independent package config
│   └── README.md
│
├── data-observability-utilities/        # NEW: Monte Carlo observability package
│   ├── src/
│   │   └── data_observability_utilities/
│   │       ├── __init__.py
│   │       ├── monte_carlo_client.py    # Monte Carlo SDK wrapper
│   │       ├── monte_carlo_integration.py
│   │       └── config.py                # Observability configuration
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── contract/
│   ├── pyproject.toml
│   └── README.md
│
├── spark-session-utilities/             # NEW: Spark session + logging package
│   ├── src/
│   │   └── spark_session_utilities/
│   │       ├── __init__.py
│   │       ├── session.py               # Spark session management
│   │       ├── config/
│   │       │   └── spark_session.py     # Spark configuration
│   │       └── logging/                 # Spark logging utilities
│   │           └── spark_logger.py
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── contract/
│   ├── pyproject.toml
│   └── README.md
│
├── databricks-shared-utilities/         # EXISTING: Reduced to core utilities
│   ├── src/
│   │   └── databricks_utils/
│   │       ├── __init__.py
│   │       ├── data_quality/            # REMOVE: Migrate to data-quality-utilities
│   │       ├── observability/           # REMOVE: Migrate to data-observability-utilities
│   │       ├── config/
│   │       │   └── spark_session.py     # REMOVE: Migrate to spark-session-utilities
│   │       ├── logging/                 # REMOVE: Migrate to spark-session-utilities
│   │       ├── testing/                 # KEEP: Shared test fixtures
│   │       └── errors/                  # KEEP: Common error types
│   ├── tests/
│   ├── pyproject.toml                   # UPDATE: Remove migrated modules
│   └── README.md                        # UPDATE: Reference new packages
│
├── databricks-uc-utilities/             # EXISTING: No changes
└── specs/                               # Feature specifications
    └── 005-separate-utilities/
        ├── spec.md
        ├── plan.md                      # This file
        ├── research.md                  # Generated in Phase 0
        ├── data-model.md                # Generated in Phase 1
        ├── quickstart.md                # Generated in Phase 1
        └── contracts/                   # Generated in Phase 1
```

**Structure Decision**: Multi-package monorepo with 3 new top-level directories for independent packages. This structure:
- Enables independent package installation and versioning
- Maintains clear package boundaries (no shared src/)
- Allows each package to have independent pyproject.toml, dependencies, tests
- Reduces databricks-shared-utilities to core utilities only (testing, errors, UC integration)

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations** - Constitution check passed. No complexity justifications needed.
