---
skill_name: makefile-formatter-skill
description: |
  Standardize Makefiles according to Skyscanner data engineering conventions with proper
  structure, documentation, POSIX compatibility, and target organization.
version: 1.0.0
author: Skyscanner Data Engineering
tags:
  - makefile
  - build
  - automation
  - formatting
  - posix
---

# Makefile Formatter Skill

## What This Skill Does

This skill standardizes Makefiles to match Skyscanner data engineering team conventions. It ensures consistent structure, comprehensive documentation, POSIX compatibility, proper target organization, and best practices for build automation.

## When to Use This Skill

Use this skill when you need to:

- ✅ Format a new Makefile for a project
- ✅ Standardize an existing Makefile to match team conventions
- ✅ Add documentation to undocumented targets
- ✅ Reorganize targets into proper sections
- ✅ Add helper targets (check-venv, check-pyenv, etc.)
- ✅ Ensure POSIX compatibility
- ✅ Prepare Makefiles for project templates or cookiecutters

## Capabilities

- Standardize Makefile structure with clear sections
- Add comprehensive inline documentation for all targets
- Organize targets into logical groups (initialization, dependencies, code quality, testing)
- Ensure POSIX compatibility and proper shell configuration
- Add help target with automatic documentation generation
- Implement helper targets for validation (check-venv, check-pyenv)
- Format variables and error messages consistently
- Add .PHONY declarations for all non-file targets
- Standardize indentation (tabs, not spaces)

## How to Invoke

You can invoke this skill directly or Claude will automatically suggest it when working with Makefiles.

### Direct Invocation

```
/makefile-formatter-skill
```

### Automatic Detection

Claude will suggest this skill when you:
- Create or modify a Makefile
- Ask to format or organize build targets
- Request standardization of build automation

## Examples

### Example 1: Format New Project

**User**: "Format my Makefile to match the team standards"

**Assistant**: "I'll use the makefile-formatter-skill to standardize your Makefile."

**Result**: Makefile formatted with proper sections, documented targets, and team conventions.

---

### Example 2: Add Proper Structure

**User**: "Organize my Makefile targets into logical sections"

**Assistant**: "I'll use the makefile-formatter-skill to add proper section organization."

**Result**: Targets organized into Configuration, Initialization, Dependencies, Code Quality, Testing, and Build sections.

---

### Example 3: Add Help Target

**User**: "Add a help target that auto-generates documentation from comments"

**Assistant**: "I'll use the makefile-formatter-skill to add the help target."

**Result**: Help target added that automatically generates documentation from `##` comments.

---

## Standard Template Structure

The skill applies this standardized structure:

```makefile
# Makefile for <project-name>
# <Brief description>

# ==============================================================================
# Configuration
# ==============================================================================

# POSIX compatibility
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Pyenv initialization
export PATH := $(HOME)/.pyenv/bin:$(PATH)
export PYENV_ROOT := $(HOME)/.pyenv
SHELL_INIT := export PATH="$$HOME/.pyenv/bin:$$PATH"; eval "$$(pyenv init --path)"; eval "$$(pyenv init -)"

# Variables
PYTHON_VERSION := $(shell cat .python-version 2>/dev/null || echo "3.12")
POETRY_VERSION := 2.2.1
POETRY_BIN := $(HOME)/.local/bin/poetry
VENV_PATH := .venv

# Error messages
ERROR_VENV_NOT_FOUND := ERROR: Virtual environment not found. Run 'make setup' first.
ERROR_PYENV_NOT_FOUND := ERROR: pyenv not found
PYENV_INSTALL_INSTRUCTIONS := \n\nInstall pyenv:\n  macOS: brew install pyenv\n  Linux: curl https://pyenv.run | bash

# Declare all targets as phony
.PHONY: help <list-all-targets>

# ==============================================================================
# Internal Helper Targets
# ==============================================================================

check-venv:
	@test -d $(VENV_PATH) || { echo "$(ERROR_VENV_NOT_FOUND)"; exit 1; }

# ==============================================================================
# Help
# ==============================================================================

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# ==============================================================================
# Project Initialization
# ==============================================================================

project-init: install-deps install-hooks ## Initialize project end-to-end

# ==============================================================================
# Dependency Installation
# ==============================================================================

install-poetry: ## Install Poetry if not present
install-deps: ## Install project dependencies
install-hooks: ## Install pre-commit hooks

# ==============================================================================
# Code Quality
# ==============================================================================

lint: ## Check code with ruff
format: ## Format code with ruff
lint-fix: ## Fix linting issues and format code

# ==============================================================================
# Testing
# ==============================================================================

test: ## Run test suite
test-cov: ## Run tests with coverage report

# ==============================================================================
# Build and Clean
# ==============================================================================

build: ## Build the project
clean: ## Remove build artifacts and caches

# End of Makefile
```

## Standard Section Organization

Targets are organized into these sections in order:

### 1. Configuration
- Shell settings (SHELL, .ONESHELL, .DEFAULT_GOAL)
- Variables (PYTHON_VERSION, POETRY_VERSION, VENV_PATH)
- Error messages (reusable error text)
- .PHONY declarations

### 2. Internal Helper Targets
- `check-venv` - Verify virtual environment exists
- `check-pyenv` - Verify pyenv installation
- Other validation helpers

### 3. Help
- `help` - Auto-generates documentation from `##` comments

### 4. Project Initialization
- `project-init` - Full project setup
- `init` - Initialize project

### 5. Pyenv Management (for Python projects)
- `build-pyenv` - Install Python version via pyenv
- `activate-pyenv` - Activate pyenv and set Python version
- `check-python` - Check which Python version is active

### 6. Dependency Installation
- `install-poetry` - Install Poetry if not present
- `install-deps` - Install project dependencies
- `install-hooks` - Install pre-commit hooks

### 7. Environment Setup
- `setup` - Set up development environment
- `setup-mcp` - Install MCP dependencies
- `validate` - Validate environment configuration

### 8. Code Quality
- `lint` - Check code with ruff
- `format` - Format code with ruff
- `lint-fix` - Fix linting issues and format code

### 9. Testing
- `test` - Run test suite
- `test-cov` - Run tests with coverage report
- `test-integration` - Run integration tests

### 10. Build and Clean
- `build` - Build the project
- `clean` - Remove build artifacts and caches

## Target Documentation Standards

Every public target must have inline documentation using `##`:

### Pattern
```makefile
target-name: ## Brief description of what this does
	@echo "Doing something..."
	@command
```

### Examples

```makefile
setup: ## Set up development environment
	@echo "Setting up..."
	@poetry install

test: check-venv ## Run test suite
	@echo "Running tests..."
	@poetry run pytest -v

clean: ## Remove build artifacts and caches
	@echo "Cleaning..."
	@rm -rf dist/ build/
```

## Common Patterns

### Setup Target Chain
```makefile
setup: check-pyenv install-poetry install-deps install-hooks ## Set up development environment
	@echo "✓ Development environment ready"
```

### Check Helper Targets
```makefile
check-venv:
	@test -d $(VENV_PATH) || { echo "$(ERROR_VENV_NOT_FOUND)"; exit 1; }

check-pyenv:
	@$(SHELL_INIT); \
	command -v pyenv >/dev/null 2>&1 || { \
		echo "$(ERROR_PYENV_NOT_FOUND)$(PYENV_INSTALL_INSTRUCTIONS)"; \
		exit 1; \
	}
```

### Install Targets
```makefile
install-poetry: ## Install Poetry if not present
	@if command -v poetry >/dev/null 2>&1; then \
		echo "✓ Poetry already installed"; \
	else \
		echo "Installing Poetry..."; \
		curl -sSL https://install.python-poetry.org | python3 -; \
		echo "✓ Poetry installed"; \
	fi
```

### Quality Targets
```makefile
lint: check-venv ## Check code with ruff
	@echo "Checking code..."
	@poetry run ruff check .

format: check-venv ## Format code with ruff
	@echo "Formatting code..."
	@poetry run ruff format .

lint-fix: check-venv ## Fix linting issues and format code
	@echo "Fixing linting issues..."
	@poetry run ruff check --fix .
	@echo "Formatting code..."
	@poetry run ruff format .
	@echo "✓ Code quality fixes applied"
```

### Test Targets
```makefile
test: check-venv ## Run test suite
	@echo "Running tests..."
	@poetry run pytest -v

test-cov: check-venv ## Run tests with coverage report
	@echo "Running tests with coverage..."
	@poetry run pytest --cov=src --cov-report=html --cov-report=term
```

### Clean Target
```makefile
clean: ## Remove build artifacts and caches
	@echo "Cleaning build artifacts..."
	@rm -rf dist/ build/ *.egg-info
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name '*.pyc' -delete
	@rm -rf .pytest_cache .ruff_cache htmlcov/ .coverage
	@echo "✓ Clean complete"
```

## Indentation Rules

**CRITICAL**: Makefiles require TAB characters, not spaces!

```makefile
target:
	@command          # TAB character (required)
    @command          # SPACES - WILL NOT WORK!
```

**How to ensure tabs**:
- Use actual TAB character (ASCII 9)
- Configure editor to insert tabs in Makefiles
- Never convert tabs to spaces in Makefiles

## Status Messages

Use consistent formatting for output messages:

```makefile
@echo "Starting task..."       # Action starting
@echo "✓ Task complete"        # Success
@echo "✗ Task failed"          # Failure
@echo "Warning: Something"     # Warning
@echo "ERROR: Problem"         # Error
```

## Formatting Checklist

Before completing, the skill verifies:

- ✅ File starts with header comment
- ✅ Configuration section at top
- ✅ All sections have separator comments
- ✅ All public targets have `## description`
- ✅ All non-file targets in .PHONY
- ✅ TAB characters used for indentation (not spaces)
- ✅ Variables use `:=` not `=`
- ✅ Shell commands use `@` prefix
- ✅ Error messages defined as variables
- ✅ Help target generates from `##` comments
- ✅ File ends with `# End of Makefile`
- ✅ Consistent target naming (kebab-case)
- ✅ Success messages use ✓ symbol
- ✅ Target dependencies listed before ##

## Common Target Names

Use these standard names:

**Initialization**:
- `help` - Show help message
- `setup` - Set up development environment
- `init` - Initialize project
- `project-init` - Full project initialization

**Installation**:
- `install-deps` - Install dependencies
- `install-hooks` - Install git hooks
- `install-poetry` - Install Poetry

**Code Quality**:
- `lint` - Check code
- `format` - Format code
- `lint-fix` - Fix and format code

**Testing**:
- `test` - Run tests
- `test-cov` - Run tests with coverage
- `test-integration` - Run integration tests
- `test-unit` - Run unit tests

**Build**:
- `build` - Build project
- `clean` - Clean build artifacts

**Validation**:
- `validate` - Validate configuration
- `check-<thing>` - Check specific thing

## Python Project Specifics

For Python projects with pyenv and poetry:

### Required Variables
```makefile
PYTHON_VERSION := $(shell cat .python-version 2>/dev/null || echo "3.12")
POETRY_VERSION := 2.2.1
POETRY_BIN := $(HOME)/.local/bin/poetry
VENV_PATH := .venv
SHELL_INIT := export PATH="$$HOME/.pyenv/bin:$$PATH"; eval "$$(pyenv init --path)"; eval "$$(pyenv init -)"
```

### Required Targets
- `check-pyenv` - Verify pyenv installed
- `check-python` - Check Python version
- `check-venv` - Verify virtual environment
- `install-poetry` - Install Poetry
- `install-deps` - Install dependencies

## Success Criteria

A well-formatted Makefile has:

- ✅ Clear section separators
- ✅ POSIX compatibility settings
- ✅ All targets documented with ##
- ✅ .PHONY declaration for all non-file targets
- ✅ TAB indentation (not spaces)
- ✅ Help target with auto-generation
- ✅ Helper targets (check-venv, etc.)
- ✅ Consistent variable naming
- ✅ Error messages as variables
- ✅ Status messages with ✓/✗ symbols
- ✅ Logical section organization
- ✅ End-of-file marker comment

---

**Remember**: A well-formatted Makefile enables developers to quickly understand available targets, run common tasks, and maintain the build system with minimal confusion.
