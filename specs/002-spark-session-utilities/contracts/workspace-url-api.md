# API Contract: workspace_url Property

**Feature**: Workspace URL Derivation
**Package**: spark-session-utilities
**Module**: `spark_session_utilities.config.schema`
**Class**: `EnvironmentConfig`
**Version**: 0.3.0 (new feature)

---

## Property Signature

```python
@property
def workspace_url(self) -> Optional[str]:
    """Derive Databricks workspace URL from environment_type."""
```

**Access**: Read-only property (no setter)
**Return Type**: `Optional[str]`
**Side Effects**: None (pure function, no state changes)
**Thread Safety**: Yes (no mutable state)
**Performance**: O(1) dictionary lookup, < 1ms

---

## Behavior Specification

### Input Dependencies

The property reads from two instance fields:
1. `workspace_host: Optional[str]` - Explicit workspace URL override
2. `environment_type: str` - Environment identifier

### Output Mapping

| environment_type | workspace_host | workspace_url (output) | Notes |
|------------------|----------------|------------------------|-------|
| `"local"` | `None` | `None` | Local Spark instance, no Databricks workspace |
| `"lab"` | `None` | `"https://skyscanner-dev.cloud.databricks.com"` | Lab environment shares dev workspace |
| `"dev"` | `None` | `"https://skyscanner-dev.cloud.databricks.com"` | Development workspace |
| `"prod"` | `None` | `"https://skyscanner-prod.cloud.databricks.com"` | Production workspace |
| `"LOCAL"` | `None` | `None` | Case-insensitive matching |
| `"DEV"` | `None` | `"https://skyscanner-dev.cloud.databricks.com"` | Case-insensitive matching |
| `"unknown"` | `None` | `"https://skyscanner-dev.cloud.databricks.com"` | Safe default to dev |
| `None` | `None` | `"https://skyscanner-dev.cloud.databricks.com"` | Safe default to dev |
| `""` (empty) | `None` | `"https://skyscanner-dev.cloud.databricks.com"` | Safe default to dev |
| Any value | `"https://custom.databricks.com"` | `"https://custom.databricks.com"` | Explicit workspace_host takes precedence |
| `"prod"` | `"https://custom.databricks.com"` | `"https://custom.databricks.com"` | Explicit workspace_host overrides derivation |

### Precedence Rules

**Priority order** (highest to lowest):
1. **Explicit `workspace_host`** - If set (not None), return this value unchanged
2. **Derived from `environment_type`** - Use mapping table
3. **Default value** - Return `"https://skyscanner-dev.cloud.databricks.com"`

---

## Guarantees

### Functional Guarantees

✅ **Idempotence**: Multiple accesses return the same value for same inputs
```python
config = EnvironmentConfig(environment_type="dev", spark=SparkConfig(app_name="test"))
assert config.workspace_url == config.workspace_url  # Always true
```

✅ **Determinism**: Same inputs always produce same output
```python
config1 = EnvironmentConfig(environment_type="dev", spark=SparkConfig(app_name="test1"))
config2 = EnvironmentConfig(environment_type="dev", spark=SparkConfig(app_name="test2"))
assert config1.workspace_url == config2.workspace_url  # Always true
```

✅ **No Side Effects**: Reading property does not modify any state
```python
config = EnvironmentConfig(environment_type="dev", spark=SparkConfig(app_name="test"))
url1 = config.workspace_url
url2 = config.workspace_url
assert config.environment_type == "dev"  # Unchanged
assert config.workspace_host is None  # Unchanged
```

✅ **Thread Safety**: Safe to access from multiple threads
- No mutable state
- No shared resources
- Pure computation

✅ **Fast Performance**: < 1ms per access
- O(1) dictionary lookup
- No I/O operations
- No network calls
- No database queries

### Non-Functional Guarantees

✅ **Backward Compatibility**:
- Additive change only
- No modifications to existing fields
- No breaking changes to API

✅ **Type Safety**:
- Return type clearly defined: `Optional[str]`
- Pydantic validation on input fields
- None is valid return value (for local environment)

---

## Usage Examples

### Example 1: Automatic Derivation (Recommended)

```python
from spark_session_utilities.config import EnvironmentConfig, SparkConfig

# Config file: dev.yaml
# environment_type: dev
# spark:
#   app_name: my-app-dev

config = EnvironmentConfig(
    environment_type="dev",
    spark=SparkConfig(app_name="my-app-dev")
)

print(config.workspace_url)
# Output: https://skyscanner-dev.cloud.databricks.com
```

### Example 2: Explicit Override

```python
config = EnvironmentConfig(
    environment_type="dev",
    workspace_host="https://custom-workspace.databricks.com",
    spark=SparkConfig(app_name="my-app-dev")
)

print(config.workspace_url)
# Output: https://custom-workspace.databricks.com
```

### Example 3: Local Environment

```python
config = EnvironmentConfig(
    environment_type="local",
    spark=SparkConfig(app_name="my-app-local", master="local[*]")
)

print(config.workspace_url)
# Output: None
```

### Example 4: Production Environment

```python
config = EnvironmentConfig(
    environment_type="prod",
    spark=SparkConfig(app_name="my-app-prod")
)

print(config.workspace_url)
# Output: https://skyscanner-prod.cloud.databricks.com
```

### Example 5: Unknown Environment (Safe Default)

```python
config = EnvironmentConfig(
    environment_type="staging",  # Not in mapping
    spark=SparkConfig(app_name="my-app-staging")
)

print(config.workspace_url)
# Output: https://skyscanner-dev.cloud.databricks.com (safe default)
```

### Example 6: Case-Insensitive Matching

```python
config1 = EnvironmentConfig(environment_type="dev", spark=SparkConfig(app_name="test"))
config2 = EnvironmentConfig(environment_type="DEV", spark=SparkConfig(app_name="test"))
config3 = EnvironmentConfig(environment_type="Dev", spark=SparkConfig(app_name="test"))

assert config1.workspace_url == config2.workspace_url == config3.workspace_url
# All return: https://skyscanner-dev.cloud.databricks.com
```

---

## Error Handling

### No Errors Raised

This property **never raises exceptions**. All edge cases return valid values:
- None environment_type → default to dev
- Empty environment_type → default to dev
- Unknown environment_type → default to dev
- None workspace_host → use derivation logic

### Rationale for No Exceptions

- Configuration should be forgiving (fail gracefully)
- Safe default (dev) is better than crashing
- Validation errors should occur earlier (during config load)
- Property access should be fast and safe

---

## Breaking Changes

**None**: This is an additive change
- New property added
- Existing fields unchanged
- No deprecations

---

## Deprecations

**None**: workspace_host field remains fully supported
- Both workspace_host and workspace_url coexist
- workspace_host is input, workspace_url is derived output
- No migration required

---

## Testing Requirements

### Unit Tests Required

**File**: `spark-session-utilities/tests/unit/config/test_workspace_url.py`

**Test Coverage**:
1. ✅ All environment_type mappings (local/lab/dev/prod)
2. ✅ Unknown environment_type defaults to dev
3. ✅ None environment_type defaults to dev
4. ✅ Empty environment_type defaults to dev
5. ✅ Case-insensitive matching (LOCAL, Dev, etc.)
6. ✅ Explicit workspace_host overrides derivation
7. ✅ Idempotence (multiple accesses return same value)
8. ✅ No side effects (instance fields unchanged after access)

### Integration Tests Required

**File**: `databricks-shared-utilities/tests/integration/test_workspace_url_integration.py`

**Test Coverage**:
1. ✅ Verify actual connectivity to skyscanner-dev workspace
2. ✅ Verify actual connectivity to skyscanner-prod workspace (if creds available)
3. ✅ Verify SparkSessionFactory uses workspace_url correctly
4. ✅ Verify extended EnvironmentConfig inherits property correctly

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.3.0 | 2025-11-22 | Added workspace_url property with automatic derivation |
| 0.2.0 | 2025-11-22 | Three-package architecture implemented |
| 0.1.0 | 2025-11-21 | Initial release |

---

## Related Documentation

- [Data Model](../data-model.md) - Complete schema definition
- [Research](../research.md#4-workspace-url-derivation) - Design decisions and alternatives
- [Quickstart](../quickstart.md) - Usage examples
- [Specification](../spec.md) - Feature requirements
