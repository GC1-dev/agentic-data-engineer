# Makefile Formatter Agent

## Overview

The `makefile-formatter-agent` is a specialized Claude agent that standardizes Makefiles according to Skyscanner data engineering conventions with proper structure, POSIX compatibility, and comprehensive documentation.

## Location

```
.claude/agents/shared/makefile-formatter-agent.md
```

## Usage

### From Claude Code CLI

You can invoke this agent in several ways:

#### 1. Direct Request

```
"Use the makefile-formatter-agent to format my Makefile"
```

#### 2. Via Description

```
"Format the Makefile according to team standards"
```

#### 3. For Specific Files

```
"Use makefile-formatter-agent to standardize /path/to/Makefile"
```

## What It Does

The agent will:

1. ✅ **Read** your existing Makefile
2. ✅ **Add** section separators with clear visual hierarchy
3. ✅ **Document** all targets with inline comments (`##`)
4. ✅ **Organize** targets into standard sections
5. ✅ **Add** POSIX compatibility settings
6. ✅ **Create** help target with auto-documentation
7. ✅ **Add** helper targets (check-venv, check-pyenv)
8. ✅ **Ensure** TAB indentation (not spaces)
9. ✅ **Add** .PHONY declarations
10. ✅ **Standardize** variable naming and error messages

## Standard Template Structure

The agent formats Makefiles according to this structure:

```makefile
# Makefile for project-name
# Brief description

# ==============================================================================
# Configuration
# ==============================================================================
# - POSIX compatibility
# - Variables
# - Error messages
# - .PHONY declarations

# ==============================================================================
# Internal Helper Targets
# ==============================================================================
# - check-venv
# - check-pyenv

# ==============================================================================
# Help
# ==============================================================================
# - help target with auto-generation

# ==============================================================================
# Project Initialization
# ==============================================================================
# - project-init
# - project-pyenv-init

# ==============================================================================
# Pyenv Management
# ==============================================================================
# - build-pyenv
# - activate-pyenv
# - check-pyenv
# - check-python

# ==============================================================================
# Dependency Installation
# ==============================================================================
# - install-poetry
# - install-deps
# - install-hooks

# ==============================================================================
# Environment Setup
# ==============================================================================
# - setup
# - setup-mcp
# - validate

# ==============================================================================
# Code Quality
# ==============================================================================
# - lint
# - format
# - lint-fix

# ==============================================================================
# Testing
# ==============================================================================
# - test
# - test-cov

# ==============================================================================
# Build and Clean
# ==============================================================================
# - build
# - clean

# End of Makefile
```

## Key Features

### 1. POSIX Compatibility

```makefile
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help
```

### 2. Auto-Generated Help

Running `make help` shows all documented targets:

```
Usage: make [target]

Available targets:
  setup                     Set up development environment
  test                      Run test suite
  clean                     Remove build artifacts and caches
```

### 3. Helper Targets

Reusable validation targets:

```makefile
check-venv:
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found"; exit 1; }
```

### 4. Consistent Error Messages

```makefile
ERROR_VENV_NOT_FOUND := ERROR: Virtual environment not found. Run 'make setup' first.
```

### 5. Status Indicators

```makefile
@echo "✓ Task complete"    # Success
@echo "✗ Task failed"      # Failure
```

## Critical Rules

### ⚠️ TAB vs SPACES

**Makefiles REQUIRE TAB characters for indentation, NOT spaces!**

```makefile
target:
→→→→@command          # CORRECT: TAB character
    @command          # WRONG: Will cause syntax error!
```

Always use actual TAB characters (ASCII 9) in recipe lines.

### Target Documentation Format

```makefile
target-name: dependencies ## Description shown in help
	@command
```

The `##` comment is what appears in `make help` output.

### .PHONY Declaration

List ALL non-file targets:

```makefile
.PHONY: help setup test clean lint format
```

This prevents conflicts with files of the same name.

## Examples

### Example 1: Basic Makefile

**Before**:
```makefile
test:
	pytest

clean:
	rm -rf build/
```

**After**:
```makefile
# Makefile for project-name
# Build automation

# ==============================================================================
# Configuration
# ==============================================================================

SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

.PHONY: help test clean

# ==============================================================================
# Help
# ==============================================================================

help: ## Show this help message
	@echo "Usage: make [target]"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# ==============================================================================
# Testing
# ==============================================================================

test: ## Run test suite
	@echo "Running tests..."
	@pytest -v
	@echo "✓ Tests complete"

# ==============================================================================
# Build and Clean
# ==============================================================================

clean: ## Remove build artifacts
	@echo "Cleaning..."
	@rm -rf build/
	@echo "✓ Clean complete"

# End of Makefile
```

### Example 2: Python Project

**Before**:
```makefile
install:
	poetry install

lint:
	ruff check .
```

**After**: Full Python project Makefile with:
- Pyenv management
- Poetry installation
- Virtual environment checks
- Code quality targets
- Testing targets
- Comprehensive documentation

## Standard Target Names

Use these conventional names:

**Initialization**:
- `help` - Show help
- `setup` - Set up environment
- `init` - Initialize project

**Installation**:
- `install-deps` - Install dependencies
- `install-hooks` - Install git hooks
- `install-<tool>` - Install specific tool

**Code Quality**:
- `lint` - Check code
- `format` - Format code
- `lint-fix` - Fix and format

**Testing**:
- `test` - Run tests
- `test-cov` - Test with coverage
- `test-integration` - Integration tests

**Build**:
- `build` - Build project
- `clean` - Clean artifacts

## Common Patterns

### Conditional Installation

```makefile
install-tool: ## Install tool if not present
	@if command -v tool >/dev/null 2>&1; then \
		echo "✓ Tool already installed"; \
	else \
		echo "Installing tool..."; \
		install-command; \
		echo "✓ Tool installed"; \
	fi
```

### Target Chaining

```makefile
setup: install-poetry install-deps install-hooks ## Set up development environment
	@echo "✓ Setup complete"
```

### Validation Before Action

```makefile
test: check-venv ## Run test suite
	@poetry run pytest -v
```

## Success Criteria

A properly formatted Makefile has:

- ✅ Header comment with project name
- ✅ Configuration section with POSIX settings
- ✅ All targets documented with `##`
- ✅ Sections separated with `# ===...===`
- ✅ .PHONY declaration present
- ✅ TAB indentation (not spaces!)
- ✅ Help target with auto-generation
- ✅ Error messages as variables
- ✅ Consistent status messages (✓/✗)
- ✅ End-of-file marker
- ✅ Helper targets for validation

## Troubleshooting

### "Missing separator" error

**Cause**: Using spaces instead of TAB
**Fix**: Replace spaces with TAB character in recipe lines

### "No rule to make target" error

**Cause**: Missing or misspelled target name
**Fix**: Check target spelling and dependencies

### Help not showing target

**Cause**: Missing or incorrectly formatted `##` comment
**Fix**: Ensure format is: `target: ## Description`

## Tips

1. **Always test after formatting**: Run `make help` to verify
2. **Use helper targets**: DRY principle - reuse validation logic
3. **Document everything**: Future you will thank present you
4. **Chain targets**: Compose complex operations from simple ones
5. **Check for tabs**: Configure editor to show whitespace
6. **Version control**: Commit Makefile separately from code changes

## Related Documentation

- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [Makefile Tutorial](https://makefiletutorial.com/)
- [Poetry Documentation](https://python-poetry.org/)
- [Pre-commit Documentation](https://pre-commit.com/)

## Maintenance

To update the agent's behavior:

1. Edit `.claude/agents/shared/makefile-formatter-agent.md`
2. Modify template or rules sections
3. Test with sample Makefiles
4. Update this README if conventions change
