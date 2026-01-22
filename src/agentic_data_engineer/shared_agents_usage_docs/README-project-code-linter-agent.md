# project-code-linter-agent - Usage Guide

## Quick Start

```bash
# In Claude Code CLI
Using @project-code-linter-agent lint the entire project and report all violations
```

## Overview

The `project-code-linter-agent` enforces code quality standards across your data engineering project by running:
- **Ruff** (Python linting and formatting)
- **Python Package Structure** (validate __init__.py files in src/ and tests/)
- **yamllint** (YAML validation)
- **jsonlint** (JSON validation)
- **pytest** (test structure validation)

## Common Use Cases

### Use Case 1: Lint Entire Project

**Prompt:**
```
Using @project-code-linter-agent lint the entire project and generate a comprehensive report
```

**What it does:**
1. Runs `ruff check .` on all Python files
2. Runs `ruff format --check .` to verify formatting
3. Lints all YAML files with `yamllint`
4. Validates JSON files against `.jsonlintrc`
5. Generates detailed report with:
   - File locations
   - Line numbers
   - Specific violations
   - Fix commands

**Expected Output:**
```
PYTHON LINTING REPORT
=====================
src/pipeline.py:15:1: F401 'os' imported but unused
src/pipeline.py:42:80: E501 Line too long (125 > 120)
tests/test_utils.py:10:1: I001 Import block is un-sorted

YAML LINTING REPORT
===================
.github/workflows/main.yaml:45: [warning] line too long (125 > 120)

JSON LINTING REPORT
===================
All JSON files valid

SUMMARY
=======
Python: 3 issues found
YAML: 1 warning
JSON: 0 issues

FIX COMMANDS
============
ruff check --fix .              # Auto-fix Python issues
ruff format .                   # Format Python code
```

### Use Case 2: Auto-Fix Linting Issues

**Prompt:**
```
Using @project-code-linter-agent fix all auto-fixable linting issues and report what was changed
```

**What it does:**
1. Runs `ruff check --fix .` to auto-fix violations
2. Runs `ruff format .` to format code
3. Reports all changes made
4. Lists remaining issues requiring manual fixes

**Expected Output:**
```
FIXED ISSUES
============
✓ Removed unused imports (3 files)
✓ Sorted imports (5 files)
✓ Fixed line length (2 files)
✓ Applied formatting (8 files)

FILES MODIFIED
==============
- src/pipeline.py
- src/transformations.py
- tests/test_pipeline.py
- tests/test_transformations.py

REMAINING ISSUES (MANUAL FIX REQUIRED)
======================================
src/pipeline.py:10:1: D103 Missing docstring in public function
tests/test_utils.py:25:1: N802 Function name should be lowercase
```

### Use Case 3: Lint Specific Files

**Prompt:**
```
Using @project-code-linter-agent lint src/data_pipeline.py and tests/test_pipeline.py
```

**What it does:**
1. Runs linter only on specified files
2. Provides targeted feedback
3. Suggests specific fixes

**Expected Output:**
```
LINTING: src/data_pipeline.py
==============================
Line 5: F401 'sys' imported but unused
Line 42: E501 Line too long (125 > 120)
Line 15: I001 Import 'pandas' should be before 'os'

LINTING: tests/test_pipeline.py
================================
Line 10: D103 Missing docstring in public function
Line 25: Naming convention violation

FIX COMMANDS
============
ruff check --fix src/data_pipeline.py tests/test_pipeline.py
```

### Use Case 4: Validate Test Structure

**Prompt:**
```
Using @project-code-linter-agent validate test naming conventions and structure in tests/ directory
```

**What it does:**
1. Scans all files in `tests/` directory
2. Validates against pytest conventions:
   - Files: `test_*.py` or `*_test.py`
   - Classes: `Test*`
   - Functions: `test_*`
3. Reports violations

**Expected Output:**
```
TEST STRUCTURE VALIDATION
=========================

✅ tests/test_pipeline.py
   - Class TestPipeline: Valid
   - Function test_transform_data: Valid
   - Function test_validate_schema: Valid

❌ tests/utils.py
   Issue: File should be named test_utils.py or utils_test.py
   Fix: Rename file to follow pytest conventions

❌ tests/test_data.py
   Line 15: Function 'validate_data' should be 'test_validate_data'
   Line 30: Class 'DataModel' should be 'TestDataModel'

✅ tests/integration/test_end_to_end.py
   - All tests follow conventions

SUMMARY
=======
Valid files: 2
Files with issues: 2
Total issues: 3
```

### Use Case 5: Check Import Order

**Prompt:**
```
Using @project-code-linter-agent validate import order in all Python files
```

**What it does:**
1. Runs `ruff check --select I .` (isort rules only)
2. Checks import order against configuration
3. Provides corrected import order

**Expected Output:**
```
IMPORT ORDER VIOLATIONS
=======================

File: src/pipeline.py (Lines 1-10)
----------------------------------
Current order:
import pandas as pd
import os
from pyspark.sql import SparkSession
from data_shared_utils import DataFrameUtils

Expected order:
import os  # Standard library

import pandas as pd  # Third-party
from pyspark.sql import SparkSession

from data_shared_utils import DataFrameUtils  # First-party

File: src/transformations.py (Lines 1-8)
-----------------------------------------
✅ Import order is correct

FIX COMMAND
===========
ruff check --select I --fix .
```

### Use Case 6: Validate Python Package Structure

**Prompt:**
```
Using @project-code-linter-agent validate Python package structure in src/ and tests/
```

**What it does:**
1. Scans all directories in `src/` and `tests/` recursively
2. Identifies directories containing Python files (`.py`)
3. Checks for `__init__.py` in each directory
4. Validates package naming conventions (lowercase, underscores)
5. Reports missing __init__.py files with fix commands

**Expected Output:**
```
PYTHON PACKAGE STRUCTURE VALIDATION
====================================

Checking src/
-------------
✅ src/__init__.py - Present
✅ src/my_package/__init__.py - Present
❌ src/my_package/utils/ - Missing __init__.py
   Contains: helper.py, validators.py
   Fix: touch src/my_package/utils/__init__.py

✅ src/my_package/transformations/__init__.py - Present
❌ src/my_package/InvalidName/ - Invalid package name (use lowercase)
   Fix: mv src/my_package/InvalidName src/my_package/invalid_name

Checking tests/
---------------
❌ tests/ - Missing __init__.py at root
   Fix: touch tests/__init__.py

✅ tests/unit/__init__.py - Present
❌ tests/integration/ - Missing __init__.py
   Contains: test_e2e.py
   Fix: touch tests/integration/__init__.py

SUMMARY
=======
Total directories scanned: 8
Valid packages: 5
Missing __init__.py: 3
Naming violations: 1

IMPACT
======
Missing __init__.py files will cause:
- ModuleNotFoundError when importing
- pytest discovery issues
- Package not recognized by Python

FIX COMMANDS
============
touch src/my_package/utils/__init__.py
touch tests/__init__.py
touch tests/integration/__init__.py
mv src/my_package/InvalidName src/my_package/invalid_name
```

**Why This Matters:**
- **Imports fail**: `from my_package.utils import helper` → ModuleNotFoundError
- **Tests not discovered**: pytest won't find tests in directories without __init__.py
- **Package not installable**: pip/poetry require proper package structure

### Use Case 7: Pre-Commit Validation

**Prompt:**
```
Using @project-code-linter-agent run pre-commit validation on staged files
```

**What it does:**
1. Gets list of staged files (git diff --staged)
2. Runs all linting checks on staged files only
3. Reports issues that would fail pre-commit hooks
4. Suggests fixes before committing

**Expected Output:**
```
PRE-COMMIT VALIDATION
=====================
Staged files: 5

PYTHON FILES (3)
================
✓ src/pipeline.py - No issues
✓ src/utils.py - No issues
❌ tests/test_new_feature.py - 2 issues
   Line 10: F401 'os' imported but unused
   Line 25: Missing docstring

YAML FILES (1)
==============
✓ .github/workflows/deploy.yaml - No issues

JSON FILES (1)
==============
✓ config/settings.json - No issues

STATUS
======
✅ Python formatting: PASSED
❌ Python linting: FAILED (2 issues)
✅ YAML linting: PASSED
✅ JSON linting: PASSED

RECOMMENDATION
==============
Fix issues before committing:
ruff check --fix tests/test_new_feature.py
```

### Use Case 8: Check Specific Linting Rules

**Prompt:**
```
Using @project-code-linter-agent check only for unused imports and undefined names
```

**What it does:**
1. Runs `ruff check --select F .` (pyflakes rules only)
2. Reports only F401 (unused imports) and F821 (undefined names)
3. Provides targeted fixes

**Expected Output:**
```
CHECKING: Unused Imports & Undefined Names
===========================================

Unused Imports (F401)
---------------------
src/pipeline.py:5: 'os' imported but unused
src/utils.py:10: 'sys' imported but unused
tests/test_data.py:3: 'pandas' imported but unused

Undefined Names (F821)
----------------------
src/transformations.py:42: Undefined name 'DataFrame'
(Hint: Did you forget to import from pyspark.sql?)

SUMMARY
=======
Unused imports: 3
Undefined names: 1

FIX COMMAND
===========
ruff check --select F --fix .  # Removes unused imports
# Manually add missing imports for undefined names
```

### Use Case 9: Validate Docstring Conventions

**Prompt:**
```
Using @project-code-linter-agent check docstring conventions (Google style) in src/
```

**What it does:**
1. Runs `ruff check --select D .` (pydocstyle rules)
2. Validates Google-style docstrings
3. Reports missing or malformed docstrings

**Expected Output:**
```
DOCSTRING VALIDATION (Google Style)
====================================

src/pipeline.py
---------------
✓ Module docstring: Present
✓ Class DataPipeline: Docstring follows Google style
❌ Function transform_data (line 45): Missing docstring
❌ Function validate_schema (line 60): Docstring missing Args section

src/utils.py
------------
❌ Missing module docstring
✓ Function parse_config: Docstring valid

SUMMARY
=======
Total functions/classes checked: 15
With valid docstrings: 12
Missing docstrings: 2
Malformed docstrings: 1

NOTE: Rules D100, D103, D104 are ignored in project config
(Module, function, and package docstrings are optional)
```

## Tips and Tricks

### Tip 1: Fix Issues Incrementally
For large codebases with many violations, fix one category at a time:
```bash
# Start with unused imports (easiest to fix)
ruff check --select F401 --fix .

# Then fix import order
ruff check --select I --fix .

# Then apply formatting
ruff format .

# Finally, address remaining issues
ruff check .
```

### Tip 2: Use Diff Before Applying Fixes
Always review what will change:
```bash
ruff check --fix --diff .  # Shows changes without applying
```

### Tip 3: Lint on Save
Configure your IDE to run Ruff on save:
- **VSCode**: Install Ruff extension
- **PyCharm**: Configure Ruff as external tool
- **Vim**: Use ALE or similar

### Tip 4: Use Pre-Commit Hooks
Install pre-commit hooks to catch issues before committing:
```bash
pre-commit install
pre-commit run --all-files  # Test all hooks
```

### Tip 5: Ignore Specific Lines
Use `# noqa` comments to ignore specific violations:
```python
import os  # noqa: F401 - Used in dynamic imports
```

### Tip 6: Test-Specific Linting
Run pytest collection to validate test discovery:
```bash
pytest --collect-only  # Lists all discovered tests
```

## Common Scenarios

### Scenario: New Feature Branch

```bash
# 1. Check current state
Using @project-code-linter-agent lint src/new_feature/ and tests/new_feature/

# 2. Fix auto-fixable issues
Using @project-code-linter-agent fix linting issues in src/new_feature/

# 3. Address remaining issues
# (Agent provides specific guidance)

# 4. Pre-commit check
Using @project-code-linter-agent run pre-commit validation

# 5. Commit clean code
git commit -m "Add new feature with clean linting"
```

### Scenario: Refactoring Existing Code

```bash
# 1. Establish baseline
Using @project-code-linter-agent check src/old_module.py and save current violations

# 2. Refactor code
# (Make your changes)

# 3. Verify improvements
Using @project-code-linter-agent check src/old_module.py and compare with baseline

# 4. Ensure no new violations
# Agent reports: "Reduced violations from 15 to 3"
```

### Scenario: Preparing for Pull Request

```bash
# 1. Full project lint
Using @project-code-linter-agent lint entire project

# 2. Fix all auto-fixable issues
Using @project-code-linter-agent fix all auto-fixable issues

# 3. Address remaining issues
# (Manual fixes for docstrings, naming, etc.)

# 4. Final validation
Using @project-code-linter-agent validate all code meets standards

# 5. Create PR with confidence
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Ruff not found" | Install: `poetry install --with dev` or `pip install ruff>=0.14.7` |
| "Config file not found" | Ensure you're in project root. Check: `ls ruff.toml .yamllint .jsonlintrc` |
| "Too many violations" | Fix incrementally: Start with `--select F` (imports), then `--select I` (sorting) |
| "Auto-fix breaks code" | Review first: `ruff check --fix --diff .` before applying |
| "YAML linter not installed" | Install: `pip install yamllint` |
| "JSON linter not installed" | Install: `npm install -g jsonlint` |
| "Tests not discovered" | Check `pytest.ini` exists and `pythonpath = src` is set |
| "Conflicts with Black" | Use Ruff formatter instead: `ruff format .` (Black compatibility mode) |
| "PySpark import errors" | N812 rule ignored for `import pyspark.sql.functions as F` |

## Configuration Files Reference

The agent uses these configuration files:

### ruff.toml
```toml
line-length = 120
target-version = "py310"
exclude = [".specify", "scripts", "pipelines"]

[lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "C4", "SIM", "D"]
ignore = ["E501", "E203", "D100", "D104", "D103", "N812"]
```

### .yamllint
```yaml
extends: default
rules:
  line-length:
    max: 120
  indentation:
    spaces: 2
```

### .jsonlintrc
```json
{
  "indent": 2,
  "max-line-length": 120,
  "trailing-commas": false
}
```

### pytest.ini
```ini
[pytest]
pythonpath = src
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
```

## Integration with CI/CD

Example GitHub Actions workflow:

```yaml
name: Lint

on: [pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install dependencies
        run: |
          pip install ruff yamllint
          npm install -g jsonlint

      - name: Run Ruff
        run: |
          ruff check .
          ruff format --check .

      - name: Run yamllint
        run: yamllint .

      - name: Run jsonlint
        run: find . -name "*.json" -exec jsonlint {} \;
```

## Related Documentation

- [Agent File](../../../.claude/agents/shared/project-code-linter-agent.md)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [yamllint Documentation](https://yamllint.readthedocs.io/)
- [pytest Documentation](https://docs.pytest.org/)
- [pyspark-standards-agent](./README-pyspark-standards-agent.md)
- [testing-agent](./README-data-transformation-testing-agent.md)

## Support

- **Questions**: #agentic-data-engineer on Slack
- **Ruff Issues**: https://github.com/astral-sh/ruff/issues
- **Project Standards**: See `docs/coding-standards/` in your project

---

**Agent Version**: 1.0
**Last Updated**: 2026-01-18
**Configuration Version**: Based on ruff.toml v1.0
