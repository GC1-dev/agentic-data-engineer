# Migration Guide: Package Separation

**From**: `databricks-shared-utilities` 0.2.0 (monolithic)
**To**: Separated packages (1.0.0)

## Overview

The `databricks-shared-utilities` package has been separated into independent packages:

| Old Package | New Package | Version |
|-------------|-------------|---------|
| databricks-shared-utilities 0.2.0 | data-quality-utilities | 1.0.0 |
| | data-observability-utilities | 1.0.0 |
| | spark-session-utilities | 1.0.0 |
| | databricks-shared-utilities | 0.3.0 |

## Quick Migration Steps

### 1. Update requirements.txt

**Before**:
```txt
databricks-shared-utilities==0.2.0
```

**After** (install only what you need):
```txt
# For data quality validation/profiling
data-quality-utilities==1.0.0

# For Monte Carlo observability
data-observability-utilities==1.0.0

# For Spark session management
spark-session-utilities==1.0.0

# For Unity Catalog integration
databricks-shared-utilities==0.3.0
```

### 2. Update Import Statements

**Data Quality**:
```python
# Before
from databricks_utils.data_quality import ValidationRule, ValidationRuleset
from databricks_utils.data_quality.profiler import DataProfiler

# After
from data_quality_utilities import ValidationRule, ValidationRuleset, DataProfiler
```

**Observability**:
```python
# Before
from databricks_utils.observability import MonteCarloClient

# After
from data_observability_utilities import MonteCarloClient
```

**Spark Session/Logging**:
```python
# Before
from databricks_utils.config.spark_session import SparkConfig
from databricks_utils.logging import get_logger

# After
from spark_session_utilities import SparkConfig, get_logger
```

### 3. Run Tests

```bash
# Update imports first, then test
pytest tests/

# Verify no old imports remain
grep -r "from databricks_utils.data_quality" . --exclude-dir=venv
grep -r "from databricks_utils.observability" . --exclude-dir=venv
```

## Detailed Migration Examples

### Example 1: Data Quality Pipeline

**Before** (databricks-shared-utilities 0.2.0):
```python
from databricks_utils.data_quality import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    Status
)

ruleset = ValidationRuleset(name="users")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)
```

**After** (data-quality-utilities 1.0.0):
```python
from data_quality_utilities import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    Status
)

ruleset = ValidationRuleset(name="users")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)
```

**Changes**: Only import path changed (1 line)

### Example 2: Complete ETL with Spark + Validation

**Before**:
```python
from databricks_utils.config.spark_session import SparkConfig
from databricks_utils.data_quality import ValidationRule, ValidationRuleset

config = SparkConfig.for_databricks()
spark = config.create_session()

df = spark.table("users")
ruleset = ValidationRuleset(name="users")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)
```

**After**:
```python
from spark_session_utilities import SparkConfig
from data_quality_utilities import ValidationRule, ValidationRuleset

config = SparkConfig.for_databricks()
spark = config.create_session()

df = spark.table("users")
ruleset = ValidationRuleset(name="users")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)
```

**Changes**: Only import paths changed (2 lines)

## Breaking Changes

### databricks-shared-utilities 0.3.0

**Removed Modules**:
- ❌ `databricks_utils.data_quality.*` → Use `data-quality-utilities`
- ❌ `databricks_utils.observability.*` → Use `data-observability-utilities`
- ❌ `databricks_utils.logging.*` → Use `spark-session-utilities`
- ❌ `databricks_utils.config.spark_session` → Use `spark-session-utilities`

**Remaining Modules**:
- ✅ `databricks_utils.errors` (retry logic, error handling)
- ✅ `databricks_utils.testing` (test fixtures)
- ✅ Unity Catalog integration (via databricks-uc-utilities)

## Troubleshooting

### ImportError: No module named 'databricks_utils.data_quality'

**Solution**: Install `data-quality-utilities` and update imports:
```bash
pip install data-quality-utilities==1.0.0
```

```python
# Update imports
from data_quality_utilities import ValidationRule
```

### ImportError: No module named 'data_quality_utilities'

**Solution**: Install the package:
```bash
pip install data-quality-utilities==1.0.0
```

### Dependency conflicts

If you see conflicts between databricks-shared-utilities 0.2.0 and 0.3.0:

```bash
# Uninstall old version
pip uninstall databricks-shared-utilities

# Install new version (only if you need Unity Catalog integration)
pip install databricks-shared-utilities==0.3.0
```

## Benefits of Migration

✅ **Smaller installations**: Install only what you need (40-60% smaller packages)
✅ **Faster installs**: Fewer dependencies to resolve
✅ **Independent versioning**: Each package evolves separately
✅ **Clearer boundaries**: Data quality ≠ observability ≠ Spark management
✅ **No API changes**: Only import paths change

## Support

- **Documentation**: See README.md files in each package
- **API Contracts**: See `specs/005-separate-utilities/contracts/`
- **Questions**: Open GitHub issue with `migration` tag

## Timeline

- **databricks-shared-utilities 0.2.0**: Deprecated (no bug fixes)
- **New packages 1.0.0**: Production ready
- **Migration deadline**: None (migrate at your own pace)
