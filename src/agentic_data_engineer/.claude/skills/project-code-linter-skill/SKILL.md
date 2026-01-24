---
skill_name: project-code-linter-skill
description: |
  Enforce code quality standards across data engineering projects using Ruff, pytest,
  YAML, and JSON linters. Validates Python code formatting, test structure, configuration files, and ensures
  compliance with project linting rules.
version: 1.0.0
author: Skyscanner Data Engineering
tags:
  - linting
  - code-quality
  - ruff
  - pytest
  - yaml
  - json
  - formatting
---

# Project Code Linter Skill

## What This Skill Does

This skill enforces code quality standards using automated linters and validators for Python (Ruff), YAML (yamllint), JSON (jsonlint), and test structure (pytest). It helps maintain consistent, high-quality code across data engineering projects through comprehensive linting and validation.

## When to Use This Skill

Use this skill when you need to:

- ✅ Lint Python code for style and quality issues
- ✅ Fix linting issues automatically
- ✅ Validate YAML and JSON configuration files
- ✅ Check test structure and naming conventions
- ✅ Validate Python package structure (__init__.py files)
- ✅ Run pre-commit checks
- ✅ Format code to match team standards
- ✅ Ensure import order and code organization

## Capabilities

- Check Python code with Ruff (replaces flake8, isort, black)
- Auto-fix Python linting issues
- Format Python code with proper indentation and style
- Validate YAML files with yamllint
- Validate JSON files with jsonlint
- Check pytest test structure and naming
- Validate Python package structure (__init__.py presence)
- Generate comprehensive linting reports
- Provide actionable fix suggestions

## How to Invoke

You can invoke this skill directly or Claude will automatically suggest it when working with code quality tasks.

### Direct Invocation

```
/project-code-linter-skill
```

### Automatic Detection

Claude will suggest this skill when you:
- Create or modify Python code that needs linting
- Ask to check code quality or fix formatting
- Request validation of configuration files
- Need to run pre-commit checks

## Examples

### Example 1: Lint Entire Project

**User**: "Check my code for linting issues"

**Assistant**: "I'll use the project-code-linter-skill to check your code."

**Result**: Comprehensive linting report showing all Python, YAML, and JSON issues with locations and fixes.

---

### Example 2: Auto-Fix Issues

**User**: "Fix all linting issues in my code"

**Assistant**: "I'll use the project-code-linter-skill to auto-fix the issues."

**Result**: Auto-fixable issues resolved, manual fixes identified with instructions.

---

### Example 3: Validate Package Structure

**User**: "Check if my Python packages have all required __init__.py files"

**Assistant**: "I'll use the project-code-linter-skill to validate package structure."

**Result**: Report showing missing __init__.py files with commands to create them.

---

## Linting Standards

### Python (Ruff)

**Configuration**: `ruff.toml` and `pyproject.toml`

**Key Rules:**
- **Line length**: 120 characters maximum
- **Target version**: Python 3.10+
- **Enabled checks**:
  - `E`: pycodestyle errors
  - `W`: pycodestyle warnings
  - `F`: pyflakes (unused imports, undefined names)
  - `I`: isort (import sorting)
  - `N`: pep8-naming conventions
  - `UP`: pyupgrade (modernize Python syntax)
  - `B`: flake8-bugbear (common bugs)
  - `C4`: flake8-comprehensions
  - `SIM`: flake8-simplify
  - `D`: pydocstyle (Google-style docstrings)

**Ignored Rules:**
- `E501`: Line too long (handled by formatter)
- `E203`: Whitespace before ':'
- `D100`: Missing module docstrings
- `D104`: Missing package docstrings
- `D103`: Missing function docstrings
- `N812`: Lowercase imported as non-lowercase (PySpark: `import pyspark.sql.functions as F`)
- `B008`: Function calls in argument defaults
- `C901`: Too complex

**Import Order (isort via Ruff):**
1. Future imports
2. Standard library imports
3. Third-party imports (pytest, pyspark, pandas)
4. First-party imports (spark_session_utils, data_shared_utils)
5. Local folder imports

**Formatting:**
- Quote style: Double quotes
- Indent: Spaces
- Preserve trailing commas

**Excluded**: `.specify/`, `scripts/`, `pipelines/`

### Python Package Structure

**Key Requirements:**
- **Every Python directory must contain `__init__.py`**
- **src/ structure**: All source code under `src/` with `__init__.py`
- **tests/ structure**: All tests under `tests/` with `__init__.py`
- **Package hierarchy**: Each subdirectory with `.py` files must be a package

**Valid Structure:**
```
src/
├── __init__.py                    # Root package
├── my_package/
│   ├── __init__.py                # Package marker
│   ├── module.py
│   └── subpackage/
│       ├── __init__.py            # Subpackage marker
│       └── another_module.py

tests/
├── __init__.py                    # Test package root
├── unit/
│   ├── __init__.py                # Unit tests package
│   └── test_module.py
└── integration/
    ├── __init__.py                # Integration tests package
    └── test_integration.py
```

### YAML (yamllint)

**Configuration**: `.yamllint`

**Key Rules:**
- **Line length**: 120 characters (warning)
- **Indentation**: 2 spaces
- **Comments**: Minimum 1 space from content
- **Document start**: Disabled (no `---` required)
- **Truthy values**: `true`, `false`, `on`, `off` allowed

### JSON (jsonlintrc)

**Configuration**: `.jsonlintrc`

**Key Rules:**
- **Indent**: 2 spaces
- **Line length**: 120 characters
- **Trailing commas**: Not allowed
- **Duplicate keys**: Not allowed
- **Comments**: Not allowed (strict JSON)
- **Ignored paths**: `node_modules/**`, `.venv/**`, `*.min.json`

### pytest

**Configuration**: `pytest.ini`

**Key Rules:**
- **Test paths**: `tests/` directory
- **Python path**: `src/` directory
- **Test files**: `test_*.py` or `*_test.py`
- **Test classes**: Prefix with `Test*`
- **Test functions**: Prefix with `test_*`
- **Markers**:
  - `slow`: Slow-running tests
  - `integration`: Integration tests
  - `llm`: Tests that mock LLM API calls

## Command Reference

### Python (Ruff)

```bash
# Check all Python files
ruff check .

# Auto-fix issues
ruff check --fix .

# Format code
ruff format .

# Check specific files
ruff check src/module.py

# Check specific rules
ruff check --select F,E .

# Show fixes without applying
ruff check --fix --diff .
```

### YAML (yamllint)

```bash
# Lint all YAML files
yamllint .

# Lint specific file
yamllint .github/workflows/main.yaml

# Lint with custom config
yamllint -c .yamllint .
```

### JSON (jsonlintrc)

```bash
# Lint JSON file
jsonlint file.json

# Lint with config
jsonlint -c .jsonlintrc file.json
```

### pytest

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific markers
pytest -m "not slow"
pytest -m integration

# Collect tests without running
pytest --collect-only
```

## Common Violations and Fixes

### 1. Unused Imports

```python
# ❌ Bad
import os
import sys
from pathlib import Path

def process_data():
    return Path("/data")
```

**Fix**: Remove unused imports
```python
# ✅ Good
from pathlib import Path

def process_data():
    return Path("/data")
```

**Command**: `ruff check --fix .` (auto-fixes)

### 2. Import Order

```python
# ❌ Bad
import pandas as pd
import os
from data_shared_utils import Utils
import sys
```

**Fix**: Sort imports correctly
```python
# ✅ Good
import os
import sys

import pandas as pd

from data_shared_utils import Utils
```

**Command**: `ruff check --select I --fix .`

### 3. Line Too Long

```python
# ❌ Bad
result = spark.sql("SELECT user_id, session_id, event_timestamp, event_type, event_properties FROM prod_trusted_bronze.analytics.user_events WHERE event_date >= '2024-01-01'")
```

**Fix**: Break into multiple lines
```python
# ✅ Good
result = spark.sql("""
    SELECT user_id, session_id, event_timestamp, event_type, event_properties
    FROM prod_trusted_bronze.analytics.user_events
    WHERE event_date >= '2024-01-01'
""")
```

**Command**: `ruff format .` (auto-fixes)

### 4. Missing Docstring

```python
# ❌ Bad
def transform_data(df):
    return df.filter(df.status == "active")
```

**Fix**: Add Google-style docstring
```python
# ✅ Good
def transform_data(df):
    """Filter DataFrame to include only active records.

    Args:
        df: PySpark DataFrame with status column

    Returns:
        DataFrame: Filtered DataFrame containing only active records
    """
    return df.filter(df.status == "active")
```

**Note**: Must be fixed manually (not auto-fixable)

### 5. Test Naming

```python
# ❌ Bad
def validate_pipeline():
    assert True

class PipelineTest:
    def check_output(self):
        assert True
```

**Fix**: Follow pytest naming conventions
```python
# ✅ Good
def test_validate_pipeline():
    assert True

class TestPipeline:
    def test_check_output(self):
        assert True
```

### 6. Missing __init__.py

```
# ❌ Bad - Directory structure without __init__.py
src/
├── my_package/
│   ├── utils/
│   │   ├── helper.py          # Missing __init__.py in utils/
│   │   └── validators.py
│   └── transformations/
│       └── clean.py            # Missing __init__.py in transformations/

tests/
└── unit/
    └── test_utils.py           # Missing __init__.py in tests/ and unit/
```

**Fix**: Add __init__.py to all directories
```
# ✅ Good - Proper package structure
src/
├── __init__.py                 # Root package marker
├── my_package/
│   ├── __init__.py             # Package marker
│   ├── utils/
│   │   ├── __init__.py         # Makes utils importable
│   │   ├── helper.py
│   │   └── validators.py
│   └── transformations/
│       ├── __init__.py         # Makes transformations importable
│       └── clean.py

tests/
├── __init__.py                 # Test package root
└── unit/
    ├── __init__.py             # Makes unit tests discoverable
    └── test_utils.py
```

**Commands**:
```bash
touch src/__init__.py
touch src/my_package/__init__.py
touch src/my_package/utils/__init__.py
touch src/my_package/transformations/__init__.py
touch tests/__init__.py
touch tests/unit/__init__.py
```

## Usage Workflow

### Complete Linting Workflow

```bash
# 1. Check current state
ruff check src/new_feature/

# 2. Auto-fix what's possible
ruff check --fix src/new_feature/
ruff format src/new_feature/

# 3. Validate package structure
find src/new_feature -type d -exec test -f {}/__init__.py \; -or -print

# 4. Validate tests
pytest --collect-only tests/new_feature/

# 5. Final check
ruff check .
yamllint .

# 6. Commit
git add .
git commit -m "Add new feature with clean linting"
```

## Best Practices

### ✅ DO

- **Run linter before commits**: Use pre-commit hooks or manual checks
- **Fix in batches**: Address one category at a time
- **Review auto-fixes**: Always review changes before committing
- **Lint new files immediately**: Catch issues early
- **Create __init__.py files**: Always add to new directories in src/ and tests/
- **Validate package structure**: Check imports work before committing
- **Use lowercase package names**: Follow PEP 8 conventions

### ❌ DON'T

- **Don't skip linting**: Never commit without running linters
- **Don't ignore warnings**: Address or explicitly suppress with reason
- **Don't auto-fix blindly**: Always review changes
- **Don't commit formatting with logic changes**: Separate commits
- **Don't forget __init__.py**: Missing files cause import errors
- **Don't use CamelCase for packages**: Use snake_case

## Configuration Files

This skill uses these configuration files from project root:

1. **ruff.toml**: Primary Ruff configuration
2. **pyproject.toml**: `[tool.ruff]` and `[tool.pytest.ini_options]`
3. **.yamllint**: YAML linting rules
4. **.jsonlintrc**: JSON linting rules
5. **pytest.ini**: pytest configuration

## Quick Reference

### Most Common Commands

| Task | Command |
|------|---------|
| Check Python code | `ruff check .` |
| Auto-fix Python | `ruff check --fix .` |
| Format Python | `ruff format .` |
| Check imports only | `ruff check --select I .` |
| Check YAML | `yamllint .` |
| Validate tests | `pytest --collect-only` |
| Show fixes preview | `ruff check --fix --diff .` |

### Rule Categories

| Code | Category | Example |
|------|----------|---------|
| F | Pyflakes | F401 (unused import) |
| E | Pycodestyle errors | E501 (line too long) |
| W | Pycodestyle warnings | W503 (line break before binary) |
| I | Import sorting | I001 (unsorted imports) |
| N | Naming | N806 (non-lowercase variable) |
| D | Docstrings | D103 (missing docstring) |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Ruff not found | `poetry install --with dev` or `pip install ruff` |
| Config file not found | Run from project root |
| Too many violations | Fix incrementally: `ruff check --select F .` |
| Auto-fix breaks code | Review first: `ruff check --fix --diff .` |
| YAML linter not found | `pip install yamllint` |
| JSON linter not found | `npm install -g jsonlint` |
| Tests not discovered | Check `pythonpath = src` in pytest.ini |
| ModuleNotFoundError | Check __init__.py files in all packages |

## Success Criteria

A successful linting operation:
1. **All checks pass** - No linting errors or warnings
2. **Proper formatting** - Code follows team style guidelines
3. **Valid imports** - No unused imports, proper order
4. **Package structure** - All __init__.py files present
5. **Test validity** - Tests follow naming conventions
6. **Clean configs** - YAML and JSON files are valid

---

**Remember**: Consistent code quality through automated linting ensures maintainable, readable code across the team. Run linters frequently, fix issues incrementally, and validate before committing.
