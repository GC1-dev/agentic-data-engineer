# Implementation Plan: Workspace URL Derivation for EnvironmentConfig

**Branch**: `002-spark-session-utilities` | **Date**: 2025-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-spark-session-utilities/spec.md`

## Summary

Add automatic workspace URL derivation to EnvironmentConfig in spark-session-utilities. The workspace_url property will derive Databricks workspace URLs from environment_type (local→None, lab/dev→skyscanner-dev, prod→skyscanner-prod) when workspace_host is not explicitly set. This reduces configuration boilerplate and ensures consistency across environments while maintaining backward compatibility.

## Technical Context

**Language/Version**: Python 3.10, 3.11
**Primary Dependencies**: Pydantic 2.0+, PyYAML (already in spark-session-utilities)
**Storage**: N/A (configuration only)
**Testing**: pytest (unit tests for URL derivation logic) + Databricks integration tests (verify connectivity)
**Target Platform**: Cross-platform (Linux, macOS, Windows) for local development; Databricks Runtime for production
**Project Type**: Library package (spark-session-utilities)
**Performance Goals**: <1ms for property access (simple string mapping, no I/O)
**Constraints**: Must maintain backward compatibility with existing workspace_host field; no breaking changes to EnvironmentConfig API
**Scale/Scope**: Single property addition to existing Pydantic model; affects all users of spark-session-utilities

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Constitution Status**: Template constitution not yet customized for this project. Proceeding with general software engineering best practices:

✅ **Backward Compatibility**: workspace_host field remains unchanged; new workspace_url property is additive
✅ **Type Safety**: Pydantic property with clear return types (Optional[str])
✅ **Testing**: Unit tests for all environment_type mappings + integration tests for Databricks connectivity
✅ **Documentation**: Docstrings for property, updated README examples
✅ **Simplicity**: Single property using dict lookup; no complex logic or external dependencies

**Re-evaluation after Phase 1**: Will verify design maintains these principles.

## Project Structure

### Documentation (this feature)

```text
specs/002-spark-session-utilities/
├── spec.md              # Feature specification (updated with clarifications)
├── plan.md              # This file
├── research.md          # Phase 0 output (already exists, will update)
├── data-model.md        # Phase 1 output (to be created)
├── quickstart.md        # Phase 1 output (to be updated)
└── contracts/           # Phase 1 output (API contracts for EnvironmentConfig)
```

### Source Code (repository root)

```text
spark-session-utilities/
├── src/
│   └── spark_session_utilities/
│       ├── config/
│       │   ├── __init__.py
│       │   ├── schema.py              # UPDATE: Add workspace_url property to EnvironmentConfig
│       │   └── loader.py
│       ├── factory/
│       │   └── spark_session_factory.py
│       └── testing/
│           └── fixtures.py
└── tests/
    ├── unit/
    │   └── config/
    │       └── test_workspace_url.py  # NEW: Unit tests for workspace_url derivation
    └── integration/
        └── test_databricks_connectivity.py  # NEW: Integration tests

databricks-shared-utilities/
├── src/
│   └── databricks_utils/
│       └── config/
│           ├── extended_config.py     # Inherits workspace_url property from base
│           └── loader.py
└── tests/
    └── integration/
        └── test_workspace_url_integration.py  # NEW: Integration tests for extended config
```

**Structure Decision**: Single library modification to spark-session-utilities with inherited behavior in databricks-shared-utilities. No new modules required; property added to existing EnvironmentConfig class in schema.py.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations. This is a straightforward property addition with clear backward compatibility and testing strategy.

---

## Phase 0: Research & Technical Decisions

**Status**: ✅ Complete (documented in research.md)

### Key Research Areas

1. **Pydantic Property Implementation Pattern**
   - Decision: Use @property decorator on Pydantic model
   - Rationale: Clean API, transparent derivation, compatible with Pydantic v2
   - Alternatives: computed_field (rejected - overkill), method (rejected - less Pythonic)

2. **URL Mapping Strategy**
   - Decision: Static dictionary mapping in property method
   - Rationale: Simple, fast, maintainable, no external dependencies
   - Alternatives: Environment variables (rejected - less portable), config file (rejected - circular dependency)

3. **Default Behavior**
   - Decision: Default to dev workspace URL when both fields are None
   - Rationale: Safe default for development, reduces configuration errors
   - Alternatives: Raise error (rejected - too strict), return None (rejected - breaks common use case)

4. **Precedence Rules**
   - Decision: Explicit workspace_host > derived from environment_type > default to dev
   - Rationale: User control first, convention second, safe default last
   - Alternatives: Always derive (rejected - removes user control), warn on mismatch (rejected - noisy)

**Output**: Research findings documented in [research.md](./research.md) Section 4: "Workspace URL Derivation"

---

## Phase 1: Design & Contracts

### Data Model

**File**: `data-model.md`

**Changes to EnvironmentConfig**:

```python
class EnvironmentConfig(BaseModel):
    """Base environment configuration (Spark-only)."""
    environment_type: str = Field(..., description="Environment type: local, lab, dev, prod")
    spark: SparkConfig
    workspace_host: Optional[str] = Field(None, description="Databricks workspace URL (explicit)")
    cluster_id: Optional[str] = None

    @property
    def workspace_url(self) -> Optional[str]:
        """
        Derive Databricks workspace URL.

        Precedence:
        1. Explicit workspace_host (if set)
        2. Derived from environment_type
        3. Default to dev workspace URL

        Returns:
            Optional[str]: Workspace URL or None for local
        """
        # Explicit value takes precedence
        if self.workspace_host is not None:
            return self.workspace_host

        # Derive from environment_type
        url_mapping = {
            "local": None,
            "lab": "https://skyscanner-dev.cloud.databricks.com",
            "dev": "https://skyscanner-dev.cloud.databricks.com",
            "prod": "https://skyscanner-prod.cloud.databricks.com",
        }

        # Use mapping or default to dev
        return url_mapping.get(
            self.environment_type.lower() if self.environment_type else None,
            "https://skyscanner-dev.cloud.databricks.com"
        )
```

**Key Design Decisions**:
- Property (not method) for clean API
- Type hint: `Optional[str]` (None for local)
- Defensive coding: handle None environment_type
- Case-insensitive environment_type matching

### API Contracts

**File**: `contracts/environment-config-api.md`

```markdown
# EnvironmentConfig API Contract

## workspace_url Property

**Signature**: `@property def workspace_url(self) -> Optional[str]`

**Behavior**:
- **Input**: Reads `workspace_host` (Optional[str]) and `environment_type` (str) fields
- **Output**: Returns workspace URL string or None

**Mapping Table**:
| environment_type | workspace_host | workspace_url (output) |
|------------------|----------------|------------------------|
| "local" | None | None |
| "lab" | None | "https://skyscanner-dev.cloud.databricks.com" |
| "dev" | None | "https://skyscanner-dev.cloud.databricks.com" |
| "prod" | None | "https://skyscanner-prod.cloud.databricks.com" |
| "LOCAL" | None | None (case-insensitive) |
| "unknown" | None | "https://skyscanner-dev.cloud.databricks.com" (default) |
| None | None | "https://skyscanner-dev.cloud.databricks.com" (default) |
| Any | "https://custom.com" | "https://custom.com" (explicit wins) |

**Guarantees**:
- Idempotent: Multiple accesses return same value
- No side effects: Read-only property
- Thread-safe: No mutable state
- Fast: O(1) dict lookup, no I/O

**Breaking Changes**: None (additive property, existing fields unchanged)

**Deprecations**: None (workspace_host remains supported)
```

### Quick Start

**File**: `quickstart.md` (updated)

```markdown
# Quick Start: Workspace URL Derivation

## Automatic URL Derivation

Let the config derive workspace URLs from environment type:

```python
from spark_session_utilities.config import ConfigLoader

# Config file: dev.yaml
# environment_type: dev
# spark:
#   app_name: my-app-dev

config = ConfigLoader.load("dev")
print(config.workspace_url)  # https://skyscanner-dev.cloud.databricks.com
```

## Explicit Override

Override the derived URL when needed:

```python
# Config file: dev.yaml
# environment_type: dev
# workspace_host: https://custom-workspace.databricks.com
# spark:
#   app_name: my-app-dev

config = ConfigLoader.load("dev")
print(config.workspace_url)  # https://custom-workspace.databricks.com
```

## Environment Type Mappings

| Environment | Workspace URL |
|-------------|---------------|
| local | None (local Spark) |
| lab | skyscanner-dev workspace |
| dev | skyscanner-dev workspace |
| prod | skyscanner-prod workspace |
| other | skyscanner-dev workspace (safe default) |
```

---

## Phase 2: Task Breakdown

**Status**: ⏸️ Deferred to `/speckit.tasks` command

Task breakdown will be generated by `/speckit.tasks` after Phase 1 design is approved.

---

## Constitution Re-Check (Post Phase 1)

✅ **Backward Compatibility**: Verified - workspace_host unchanged, workspace_url is new additive property
✅ **Type Safety**: Verified - Clear type hints, Pydantic validation preserved
✅ **Testing**: Verified - Unit test plan covers all mappings, integration test plan covers connectivity
✅ **Documentation**: Verified - Property docstring, contract document, quickstart guide updated
✅ **Simplicity**: Verified - Single property with dict lookup, 15 lines of code, no new dependencies

**Design approved for implementation.**

---

## Next Steps

1. ✅ Phase 0 complete: Research documented
2. ✅ Phase 1 complete: Design artifacts generated (data-model.md, contracts/, quickstart.md)
3. ⏭️ Run `/speckit.tasks` to generate task breakdown (tasks.md)
4. ⏭️ Run `/speckit.implement` to execute tasks
