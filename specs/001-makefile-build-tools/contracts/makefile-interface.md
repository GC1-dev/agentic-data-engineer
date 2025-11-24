# Makefile Interface Contract

**Feature**: 001-makefile-build-tools
**Version**: 1.0.0
**Date**: 2025-11-23

## Overview

This document defines the command-line interface contract for the Makefile build automation system. It specifies all available targets, their inputs, outputs, exit codes, and behavior guarantees.

## Target Interface Specification

### help (Default Target)

**Purpose**: Display all available make targets with descriptions

**Invocation**:
```bash
make
# or
make help
```

**Inputs**: None

**Outputs** (stdout):
```
Usage: make [target]

Available targets:
  help                 Show this help message
  setup                Set up development environment
  check-pyenv          Verify pyenv installation and Python version
  install-poetry       Install poetry if not present
  install-deps         Install project dependencies
  lint                 Check code with ruff
  format               Format code with ruff
  lint-fix             Fix linting issues and format code
  test                 Run test suite
  test-cov             Run tests with coverage report
  build                Build the project
  clean                Remove build artifacts and caches
  validate             Validate all tool configurations
```

**Exit Codes**:
- `0`: Success

**Guarantees**:
- Always succeeds
- Output is human-readable
- Lists all public targets (those with ## documentation)

---

### setup

**Purpose**: Complete development environment setup (one-command onboarding)

**Invocation**:
```bash
make setup
```

**Inputs**:
- `.python-version` file must exist
- User must have pyenv installed (checked, not installed)

**Outputs** (stdout):
```
Checking pyenv installation...
✓ pyenv found (version 2.6.11)
✓ Python 3.12.12 is installed
Checking poetry installation...
✓ poetry found (version 2.2.1)
Configuring poetry...
✓ virtualenvs.in-project = true
Installing dependencies...
[poetry install output]
✓ Dependencies installed
✓ Development environment ready

Run 'make help' to see available commands.
```

**Exit Codes**:
- `0`: Setup completed successfully
- `1`: pyenv not found (ERROR with installation instructions)
- `1`: Required Python version not installed (ERROR with pyenv install command)
- `1`: Poetry installation failed
- `1`: Dependency installation failed

**Side Effects**:
- Installs poetry (if missing) to `~/.local/bin/poetry`
- Sets poetry config: `virtualenvs.in-project = true`
- Creates `.venv/` directory in project root
- Installs all dependencies from `poetry.lock`

**Guarantees**:
- Idempotent: safe to run multiple times
- If successful, environment is ready for development
- All dev tools (pytest, ruff) available in `.venv`

**Error Handling**:
- Clear error messages with resolution steps
- Fails fast at first error (doesn't continue)
- Preserves any partial state (doesn't rollback)

---

### check-pyenv

**Purpose**: Verify pyenv installation and required Python version

**Invocation**:
```bash
make check-pyenv
```

**Inputs**:
- `.python-version` file

**Outputs** (stdout):
```
✓ pyenv found (version 2.6.11)
✓ Python 3.12.12 is installed
✓ Python 3.12.12 is active
```

**Exit Codes**:
- `0`: pyenv installed and Python version available
- `1`: pyenv not found
- `1`: Required Python version not installed

**Error Output Example**:
```
ERROR: pyenv not found

Resolution:
  Install pyenv using your system package manager

macOS:
  brew install pyenv

Linux:
  curl https://pyenv.run | bash

After installation, add to your shell config (~/.bashrc or ~/.zshrc):
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

Then restart your shell or run: source ~/.bashrc
```

**Guarantees**:
- Read-only operation (no modifications)
- Checks complete in <1 second

---

### install-poetry

**Purpose**: Install poetry package manager if not present

**Invocation**:
```bash
make install-poetry
```

**Inputs**: None (uses system Python)

**Outputs** (stdout):
```
✓ poetry already installed (version 2.2.1)
# or
Installing poetry 2.2.1...
[official installer output]
✓ poetry installed to ~/.local/bin/poetry
```

**Exit Codes**:
- `0`: Poetry installed or already present
- `1`: Installation failed (network, permissions, etc.)

**Side Effects**:
- Installs poetry to `~/.local/bin/poetry` (if missing)
- Creates `~/.local/share/pypoetry/` directory
- Does NOT modify shell configuration files

**Guarantees**:
- Idempotent: checks existence before installing
- Uses official poetry installer
- Installs specific version (POETRY_VERSION variable)

---

### install-deps

**Purpose**: Install project dependencies using poetry

**Invocation**:
```bash
make install-deps
```

**Inputs**:
- `pyproject.toml`
- `poetry.lock`
- Poetry must be installed

**Outputs** (stdout):
```
Installing dependencies...
[poetry install output - package list]
✓ Dependencies installed
```

**Exit Codes**:
- `0`: Dependencies installed successfully
- `1`: Poetry not found
- `1`: pyproject.toml or poetry.lock missing
- `1`: Installation failed (network, version conflicts, etc.)

**Side Effects**:
- Creates `.venv/` directory
- Installs all dependencies into `.venv/`
- Updates virtual environment if already exists

**Guarantees**:
- Idempotent: safe to run multiple times
- Uses locked versions from poetry.lock
- Configures poetry with virtualenvs.in-project = true

---

### lint

**Purpose**: Check code quality with ruff (no modifications)

**Invocation**:
```bash
make lint
```

**Inputs**:
- Source files in `src/` and `tests/`
- `.venv/` must exist with ruff installed

**Outputs** (stdout):
```
Checking code with ruff...
[ruff check output - violations or "All checks passed!"]
```

**Exit Codes**:
- `0`: No linting issues found
- `1`: Linting issues found (violations reported)
- `1`: Ruff not available

**Guarantees**:
- Read-only operation
- Reports all violations
- Consistent with ruff configuration in pyproject.toml

---

### format

**Purpose**: Format code with ruff (modifies files)

**Invocation**:
```bash
make format
```

**Inputs**:
- Source files in `src/` and `tests/`
- `.venv/` must exist with ruff installed

**Outputs** (stdout):
```
Formatting code with ruff...
[ruff format output - files modified]
N files reformatted, M files left unchanged
```

**Exit Codes**:
- `0`: Formatting completed
- `1`: Ruff not available
- `1`: Formatting failed (syntax errors)

**Side Effects**:
- Modifies Python files in place
- Applies formatting rules from pyproject.toml

**Guarantees**:
- Idempotent: running twice produces same result
- Preserves functionality (only changes formatting)

---

### lint-fix

**Purpose**: Fix linting issues and format code (combined operation)

**Invocation**:
```bash
make lint-fix
```

**Inputs**:
- Source files in `src/` and `tests/`
- `.venv/` must exist with ruff installed

**Outputs** (stdout):
```
Fixing linting issues...
[ruff check --fix output]
Formatting code...
[ruff format output]
✓ Code quality fixes applied
```

**Exit Codes**:
- `0`: All fixes applied successfully
- `1`: Some issues remain (manual fixes needed)
- `1`: Ruff not available

**Side Effects**:
- Auto-fixes linting violations where possible
- Formats all Python files
- Modifies files in place

**Guarantees**:
- Idempotent: safe to run multiple times
- Combines lint + format in correct order

---

### test

**Purpose**: Run test suite with pytest

**Invocation**:
```bash
make test
```

**Inputs**:
- Test files in `tests/` directory
- `.venv/` must exist with pytest installed

**Outputs** (stdout):
```
Running tests...
[pytest output]
======================== test session starts =========================
collected N items

tests/test_file.py ...                                         [100%]

======================== N passed in 0.50s ==========================
```

**Exit Codes**:
- `0`: All tests passed
- `1`: One or more tests failed
- `1`: Pytest not available

**Guarantees**:
- Runs all tests in `tests/` directory
- Verbose output (-v flag)
- Preserves test database/fixtures state

---

### test-cov

**Purpose**: Run tests with coverage report

**Invocation**:
```bash
make test-cov
```

**Inputs**:
- Test files in `tests/` directory
- Source files in `src/` directory
- `.venv/` must exist with pytest and pytest-cov installed

**Outputs** (stdout):
```
Running tests with coverage...
[pytest output with coverage]

---------- coverage: platform linux, python 3.12.12 -----------
Name                      Stmts   Miss  Cover
---------------------------------------------
src/module.py                50      5    90%
---------------------------------------------
TOTAL                       150     15    90%

Coverage HTML report: htmlcov/index.html
```

**Exit Codes**:
- `0`: Tests passed (regardless of coverage %)
- `1`: Tests failed
- `1`: Pytest/coverage not available

**Side Effects**:
- Creates `htmlcov/` directory
- Creates `.coverage` file

**Guarantees**:
- Generates both terminal and HTML coverage reports
- Measures coverage for `src/` directory only

---

### build

**Purpose**: Build the project (if applicable)

**Invocation**:
```bash
make build
```

**Inputs**:
- `pyproject.toml` with build configuration
- `.venv/` must exist

**Outputs** (stdout):
```
Building project...
[poetry build output]
Built dist/package-name-0.1.0.tar.gz
Built dist/package_name-0.1.0-py3-none-any.whl
✓ Build complete
```

**Exit Codes**:
- `0`: Build successful
- `1`: Build failed
- `1`: Poetry not available

**Side Effects**:
- Creates `dist/` directory
- Generates wheel and sdist files

**Guarantees**:
- Uses poetry build system
- Cleans previous build artifacts first

---

### clean

**Purpose**: Remove build artifacts, caches, and temporary files

**Invocation**:
```bash
make clean
```

**Inputs**: None

**Outputs** (stdout):
```
Cleaning build artifacts and caches...
✓ Removed dist/
✓ Removed build/
✓ Removed __pycache__ directories
✓ Removed .pytest_cache
✓ Removed .ruff_cache
✓ Removed coverage reports
✓ Clean complete
```

**Exit Codes**:
- `0`: Always succeeds (even if files don't exist)

**Side Effects**:
- Removes `dist/`, `build/`, `*.egg-info` directories
- Removes all `__pycache__` directories recursively
- Removes `*.pyc` files
- Removes `.pytest_cache`, `.ruff_cache`, `htmlcov/`, `.coverage`
- Does NOT remove `.venv/` (use manual removal if needed)

**Guarantees**:
- Safe to run anytime
- Idempotent
- Preserves source code and configuration

---

### validate

**Purpose**: Validate all tool configurations and state

**Invocation**:
```bash
make validate
```

**Inputs**:
- All configuration files
- Installed tools

**Outputs** (stdout):
```
Validating environment...
✓ .python-version file exists
✓ Python version matches (3.12.12)
✓ pyproject.toml valid
✓ poetry.lock in sync
✓ .venv exists
✓ All tools available
✓ All validations passed
```

**Exit Codes**:
- `0`: All validations passed
- `1`: One or more validations failed

**Guarantees**:
- Read-only operation
- Checks all configuration consistency
- Reports specific validation failures

---

## Environment Variables

### User-Configurable

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `PYTHON_VERSION` | Override Python version | From `.python-version` | `PYTHON_VERSION=3.11.0 make setup` |
| `POETRY_VERSION` | Poetry version to install | `2.2.1` | `POETRY_VERSION=2.2.0 make install-poetry` |
| `POETRY_HOME` | Poetry installation directory | `~/.local/share/pypoetry` | - |

### Internal Variables (read-only)

| Variable | Purpose | Value |
|----------|---------|-------|
| `POETRY_BIN` | Poetry executable path | `~/.local/bin/poetry` |
| `VENV_PATH` | Virtual environment path | `./.venv` |

---

## Dependency Graph

```
help (no dependencies)

setup
├── check-pyenv
├── install-poetry
└── install-deps
    └── install-poetry

lint
└── install-deps

format
└── install-deps

lint-fix
├── install-deps
├── lint
└── format

test
└── install-deps

test-cov
└── install-deps

build
└── install-deps

clean (no dependencies)

validate
├── check-pyenv
└── install-deps
```

---

## Error Message Format Specification

All error messages follow this pattern:

```
ERROR: [Short problem description]

[Optional: current state vs expected state]

Resolution:
  [Step 1]
  [Step 2]

Example:
  $ [concrete command to run]

[Optional: Additional context or documentation link]
```

**Example**:
```
ERROR: Required Python version not installed

Expected: 3.12.12 (from .python-version)
Available: 3.11.0, 3.12.0

Resolution:
  Install Python 3.12.12 using pyenv:

Example:
  $ pyenv install 3.12.12
  $ pyenv local 3.12.12

This may take 2-5 minutes to download and compile.
```

---

## Performance Guarantees

| Operation | Target Time | Measured Against |
|-----------|-------------|------------------|
| `make help` | <100ms | Makefile parsing |
| `make check-pyenv` | <500ms | Tool detection |
| `make install-poetry` (cached) | <500ms | Already installed |
| `make install-poetry` (fresh) | <30s | Network download + install |
| `make install-deps` (cached) | <5s | No changes to poetry.lock |
| `make install-deps` (fresh) | <5min | Full dependency download |
| `make lint` | <30s | Per 10k LOC |
| `make format` | <30s | Per 10k LOC |
| `make test` | Variable | Depends on test suite |
| `make clean` | <2s | Filesystem operations |

---

## Compatibility Matrix

| Target | macOS | Linux (Ubuntu/Debian) | Windows WSL |
|--------|-------|-----------------------|-------------|
| help | ✅ | ✅ | ✅ |
| setup | ✅ | ✅ | ✅ |
| check-pyenv | ✅ | ✅ | ✅ |
| install-poetry | ✅ | ✅ | ✅ |
| install-deps | ✅ | ✅ | ✅ |
| lint | ✅ | ✅ | ✅ |
| format | ✅ | ✅ | ✅ |
| lint-fix | ✅ | ✅ | ✅ |
| test | ✅ | ✅ | ✅ |
| test-cov | ✅ | ✅ | ✅ |
| build | ✅ | ✅ | ✅ |
| clean | ✅ | ✅ | ✅ |
| validate | ✅ | ✅ | ✅ |

**Requirements**:
- GNU Make 3.81+ or compatible
- bash or zsh shell
- Network connectivity (for initial setup)

---

## Contract Versioning

**Version**: 1.0.0
**Schema**: SemVer

**Breaking Changes** (major version bump):
- Removing a public target
- Changing target exit codes
- Removing output fields
- Changing side effects without backward compatibility

**Non-Breaking Changes** (minor version bump):
- Adding new targets
- Adding new optional environment variables
- Enhancing error messages
- Adding new output fields

**Patches** (patch version bump):
- Bug fixes
- Performance improvements
- Documentation updates

---

## Testing the Contract

All targets should be tested for contract compliance:

```bash
# Test help target
make help && echo "✓ help passed"

# Test setup (requires pyenv)
make setup && echo "✓ setup passed"

# Test idempotency
make setup && make setup && echo "✓ setup idempotent"

# Test lint
make lint; [ $? -eq 0 ] && echo "✓ lint passed"

# Test clean
make clean && echo "✓ clean passed"

# Test error handling (pyenv not found)
# Should fail with clear error message
PATH="/bin:/usr/bin" make check-pyenv 2>&1 | grep "ERROR: pyenv"
```

---

## Summary

This contract defines:

1. **12 Public Targets**: help, setup, check-pyenv, install-poetry, install-deps, lint, format, lint-fix, test, test-cov, build, clean, validate
2. **Exit Codes**: 0 for success, 1 for errors
3. **Error Format**: Structured with problem, resolution, example
4. **Idempotency**: All targets safe to run multiple times
5. **Performance**: Specific timing guarantees per operation
6. **Platform Support**: macOS, Linux, Windows WSL

The contract ensures consistent, predictable behavior across all developer environments.
