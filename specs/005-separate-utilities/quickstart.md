# Quick Start Guide: Package Separation Migration

**Feature**: Separate Data Quality and Observability Utilities
**Date**: 2025-11-22
**Target Audience**: Users of databricks-shared-utilities 0.2.0

---

## Overview

This guide helps you migrate from the monolithic `databricks-shared-utilities` package to the new separated packages:

- **data-quality-utilities** - Data validation and profiling
- **data-observability-utilities** - Monte Carlo integration
- **spark-session-utilities** - Spark session and logging

**Migration Type**: Clean break (no backward compatibility)
**Estimated Migration Time**: 10-15 minutes for typical project

---

## What Changed?

### Package Structure

**Before** (databricks-shared-utilities 0.2.0):
```
databricks-shared-utilities
├── data_quality/        # Validation, profiling
├── observability/       # Monte Carlo integration
├── config/             # Spark configuration
├── logging/            # Spark logging
├── testing/            # Test fixtures
└── errors/             # Common errors
```

**After** (New separated packages):
```
data-quality-utilities       # Independent package
data-observability-utilities # Independent package
spark-session-utilities      # Independent package
databricks-shared-utilities  # Reduced to core utilities only
```

### Why This Change?

✅ **Independent installation** - Install only what you need
✅ **Reduced dependencies** - Smaller package footprint
✅ **Clear separation** - Data quality ≠ observability ≠ Spark management
✅ **Independent versioning** - Each package evolves separately

---

## Installation

### Old Way (databricks-shared-utilities 0.2.0)

```bash
pip install databricks-shared-utilities==0.2.0
```

**Result**: Installs everything (data quality + observability + Spark + Unity Catalog)

### New Way (Separated packages)

Install only what you need:

```bash
# Data quality validation and profiling
pip install data-quality-utilities==1.0.0

# Monte Carlo observability
pip install data-observability-utilities==1.0.0

# Spark session and logging
pip install spark-session-utilities==1.0.0

# Core utilities (testing, errors, Unity Catalog integration)
pip install databricks-shared-utilities==0.3.0
```

**Result**: Smaller installation, faster installs, fewer dependencies

---

## Migration Guide

### Step 1: Identify Your Usage

Determine which packages you actually use:

```python
# If you use data quality validation/profiling → data-quality-utilities
from databricks_utils.data_quality import ValidationRule, ValidationRuleset
from databricks_utils.data_quality.profiler import DataProfiler

# If you use Monte Carlo observability → data-observability-utilities
from databricks_utils.observability import MonteCarloClient, MonteCarloIntegration

# If you use Spark session/logging → spark-session-utilities
from databricks_utils.config.spark_session import SparkConfig
from databricks_utils.logging import SparkLogger

# If you use testing/errors → databricks-shared-utilities (unchanged)
from databricks_utils.testing import spark_fixture
from databricks_utils.errors import ConfigurationError
```

### Step 2: Update requirements.txt / pyproject.toml

**Before**:
```txt
databricks-shared-utilities==0.2.0
```

**After** (example for project using data quality + Spark):
```txt
data-quality-utilities==1.0.0
spark-session-utilities==1.0.0
```

### Step 3: Update Import Statements

Use find-and-replace in your codebase:

#### Data Quality Utilities

**Find**:
```python
from databricks_utils.data_quality import
from databricks_utils.data_quality.
```

**Replace**:
```python
from data_quality_utilities import
from data_quality_utilities.
```

**Examples**:

| Before | After |
|--------|-------|
| `from databricks_utils.data_quality import ValidationRule` | `from data_quality_utilities import ValidationRule` |
| `from databricks_utils.data_quality import ValidationRuleset` | `from data_quality_utilities import ValidationRuleset` |
| `from databricks_utils.data_quality.profiler import DataProfiler` | `from data_quality_utilities import DataProfiler` |
| `from databricks_utils.data_quality.profiler import DataProfile` | `from data_quality_utilities import DataProfile` |

---

#### Data Observability Utilities

**Find**:
```python
from databricks_utils.observability import
```

**Replace**:
```python
from data_observability_utilities import
```

**Examples**:

| Before | After |
|--------|-------|
| `from databricks_utils.observability import MonteCarloClient` | `from data_observability_utilities import MonteCarloClient` |
| `from databricks_utils.observability import MonteCarloIntegration` | `from data_observability_utilities import MonteCarloIntegration` |
| `from databricks_utils.observability import ObservabilityConfig` | `from data_observability_utilities import ObservabilityConfig` |

---

#### Spark Session Utilities

**Find**:
```python
from databricks_utils.config.spark_session import
from databricks_utils.logging import
```

**Replace**:
```python
from spark_session_utilities import
from spark_session_utilities import
```

**Examples**:

| Before | After |
|--------|-------|
| `from databricks_utils.config.spark_session import SparkConfig` | `from spark_session_utilities import SparkConfig` |
| `from databricks_utils.logging import SparkLogger` | `from spark_session_utilities import SparkLogger` |

**Note**: Spark utilities are now consolidated under a single package with top-level imports (no nested submodules).

---

### Step 4: Verify No Code Changes Needed

**Good news**: Only import paths change. All class names, method signatures, and parameters remain identical.

**Example**:

```python
# Before (databricks-shared-utilities 0.2.0)
from databricks_utils.data_quality import ValidationRule, ValidationRuleset, Severity

ruleset = ValidationRuleset(name="my_rules")
ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=False))
result = ruleset.validate(df)

# After (data-quality-utilities 1.0.0)
from data_quality_utilities import ValidationRule, ValidationRuleset, Severity

ruleset = ValidationRuleset(name="my_rules")
ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=False))
result = ruleset.validate(df)
# ^^^^^^^^^^^^^^^ IDENTICAL CODE (only import changed)
```

### Step 5: Update Tests

If your tests import from databricks-shared-utilities, update them using the same find-and-replace patterns from Step 3.

### Step 6: Test Your Application

```bash
# Run your test suite
pytest tests/

# Verify imports work
python -c "from data_quality_utilities import ValidationRule; print('✅ Import successful')"

# Check no old imports remain
grep -r "from databricks_utils.data_quality" . --exclude-dir=venv
grep -r "from databricks_utils.observability" . --exclude-dir=venv
grep -r "from databricks_utils.config.spark_session" . --exclude-dir=venv
grep -r "from databricks_utils.logging" . --exclude-dir=venv
```

---

## Complete Migration Examples

### Example 1: Data Quality Validation Project

**Before** (requirements.txt):
```txt
databricks-shared-utilities==0.2.0
pyspark==3.5.0
```

**After** (requirements.txt):
```txt
data-quality-utilities==1.0.0
pyspark==3.5.0
```

**Before** (validation.py):
```python
from databricks_utils.data_quality import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    Status
)
from databricks_utils.data_quality.profiler import DataProfiler

def validate_users(df):
    ruleset = ValidationRuleset(name="user_validation")
    ruleset.add_rule(ValidationRule.completeness("user_id"))
    ruleset.add_rule(ValidationRule.uniqueness("email"))
    return ruleset.validate(df)
```

**After** (validation.py):
```python
from data_quality_utilities import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    Status,
    DataProfiler
)

def validate_users(df):
    ruleset = ValidationRuleset(name="user_validation")
    ruleset.add_rule(ValidationRule.completeness("user_id"))
    ruleset.add_rule(ValidationRule.uniqueness("email"))
    return ruleset.validate(df)
```

**Changes**: Only import statements (4 lines changed)

---

### Example 2: ETL Pipeline with Spark + Data Quality

**Before** (requirements.txt):
```txt
databricks-shared-utilities==0.2.0
```

**After** (requirements.txt):
```txt
data-quality-utilities==1.0.0
spark-session-utilities==1.0.0
```

**Before** (pipeline.py):
```python
from databricks_utils.config.spark_session import SparkConfig
from databricks_utils.logging import SparkLogger
from databricks_utils.data_quality import ValidationRule, ValidationRuleset

config = SparkConfig.for_databricks()
spark = config.create_session()
logger = SparkLogger(spark)

logger.log_job_start("etl_pipeline")
df = spark.table("users")

ruleset = ValidationRuleset(name="users")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)

logger.log_job_end("etl_pipeline", status="SUCCESS")
```

**After** (pipeline.py):
```python
from spark_session_utilities import SparkConfig, SparkLogger
from data_quality_utilities import ValidationRule, ValidationRuleset

config = SparkConfig.for_databricks()
spark = config.create_session()
logger = SparkLogger(spark)

logger.log_job_start("etl_pipeline")
df = spark.table("users")

ruleset = ValidationRuleset(name="users")
ruleset.add_rule(ValidationRule.completeness("user_id"))
result = ruleset.validate(df)

logger.log_job_end("etl_pipeline", status="SUCCESS")
```

**Changes**: Only import statements (2 lines changed)

---

### Example 3: Monte Carlo Observability Integration

**Before** (requirements.txt):
```txt
databricks-shared-utilities==0.2.0
```

**After** (requirements.txt):
```txt
data-observability-utilities==1.0.0
```

**Before** (monitoring.py):
```python
from databricks_utils.observability import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig
)

config = ObservabilityConfig(
    monte_carlo_api_key_id="YOUR_KEY_ID",
    monte_carlo_api_key_secret="YOUR_KEY_SECRET"
)

client = MonteCarloClient(
    api_key_id=config.monte_carlo_api_key_id,
    api_key_secret=config.monte_carlo_api_key_secret
)

integration = MonteCarloIntegration(client, "databricks", "production")
integration.setup_table_monitoring("users")
```

**After** (monitoring.py):
```python
from data_observability_utilities import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig
)

config = ObservabilityConfig(
    monte_carlo_api_key_id="YOUR_KEY_ID",
    monte_carlo_api_key_secret="YOUR_KEY_SECRET"
)

client = MonteCarloClient(
    api_key_id=config.monte_carlo_api_key_id,
    api_key_secret=config.monte_carlo_api_key_secret
)

integration = MonteCarloIntegration(client, "databricks", "production")
integration.setup_table_monitoring("users")
```

**Changes**: Only import statement (1 line changed)

---

## Troubleshooting

### Issue: Import Error - Module not found

**Error**:
```
ModuleNotFoundError: No module named 'data_quality_utilities'
```

**Solution**:
```bash
# Ensure package is installed
pip install data-quality-utilities==1.0.0

# Verify installation
pip show data-quality-utilities
```

---

### Issue: Old imports still in code

**Error**:
```
ModuleNotFoundError: No module named 'databricks_utils.data_quality'
```

**Solution**:
```bash
# Find all old imports
grep -r "from databricks_utils.data_quality" . --exclude-dir=venv

# Replace using find-and-replace in your IDE or:
find . -name "*.py" -exec sed -i '' 's/from databricks_utils.data_quality/from data_quality_utilities/g' {} +
```

---

### Issue: Dependency conflicts

**Error**:
```
ERROR: Cannot install data-quality-utilities==1.0.0 and databricks-shared-utilities==0.2.0
```

**Solution**:
Either upgrade databricks-shared-utilities to 0.3.0 or remove it entirely if you don't use core utilities:

```bash
# Option 1: Upgrade databricks-shared-utilities
pip install databricks-shared-utilities==0.3.0

# Option 2: Remove if not needed
pip uninstall databricks-shared-utilities
```

---

### Issue: Tests failing after migration

**Symptoms**: Tests import from old paths

**Solution**:
```bash
# Update test imports
find tests/ -name "*.py" -exec sed -i '' 's/from databricks_utils.data_quality/from data_quality_utilities/g' {} +
find tests/ -name "*.py" -exec sed -i '' 's/from databricks_utils.observability/from data_observability_utilities/g' {} +
find tests/ -name "*.py" -exec sed -i '' 's/from databricks_utils.config.spark_session/from spark_session_utilities/g' {} +
```

---

## Verification Checklist

Use this checklist to verify successful migration:

- [ ] Uninstalled or upgraded `databricks-shared-utilities` to 0.3.0
- [ ] Installed new packages (`data-quality-utilities`, `data-observability-utilities`, `spark-session-utilities`)
- [ ] Updated all imports in source code
- [ ] Updated all imports in test code
- [ ] No references to old import paths remain (grep verification)
- [ ] All tests pass (`pytest tests/`)
- [ ] Application runs successfully
- [ ] No deprecation warnings in logs

---

## FAQ

### Q: Can I use both old and new packages simultaneously?

**A**: No. This is a clean break migration. You must choose either:
- `databricks-shared-utilities==0.2.0` (old monolithic package), OR
- New separated packages (`data-quality-utilities`, etc.)

Mixing versions will cause import conflicts.

---

### Q: What if I only use data quality utilities?

**A**: Perfect! Install only `data-quality-utilities==1.0.0`. You don't need the other packages.

```bash
pip install data-quality-utilities==1.0.0
```

---

### Q: What happened to databricks-shared-utilities?

**A**: It still exists (version 0.3.0) but now contains only core utilities:
- Testing fixtures
- Common error types
- Unity Catalog integration (via databricks-uc-utilities)

Data quality, observability, and Spark utilities moved to separate packages.

---

### Q: Are there any breaking changes besides import paths?

**A**: No. All class names, method signatures, parameters, and return types are identical. Only import paths changed.

---

### Q: What if I need to support both old and new versions?

**A**: Not recommended due to clean break approach. If absolutely necessary, use conditional imports:

```python
try:
    from data_quality_utilities import ValidationRule
except ImportError:
    from databricks_utils.data_quality import ValidationRule
```

**Warning**: This adds complexity. Migrate fully instead.

---

### Q: How long will databricks-shared-utilities 0.2.0 be supported?

**A**: Version 0.2.0 is deprecated. Migrate to separated packages as soon as possible. No bug fixes or updates will be provided for 0.2.0.

---

## Getting Help

- **API Documentation**: See [contracts/](./contracts/) directory for detailed API specifications
- **Architecture**: See [data-model.md](./data-model.md) for package structure details
- **Issues**: Report migration issues via GitHub Issues
- **Questions**: Tag issues with `migration` label

---

## Next Steps

After successful migration:

1. **Review API contracts**: [contracts/data-quality-utilities-api.md](./contracts/data-quality-utilities-api.md)
2. **Explore new features**: Check package READMEs for new capabilities
3. **Optimize dependencies**: Remove unused packages from requirements.txt
4. **Update CI/CD**: Ensure pipelines install correct packages

---

**Migration Guide Version**: 1.0.0
**Last Updated**: 2025-11-22
**Estimated Migration Time**: 10-15 minutes for typical project
