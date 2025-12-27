# Makefile for blue-data-nova-cookiecutter
# Build automation for Python project with pyenv, poetry, and ruff

# ==============================================================================
# Configuration
# ==============================================================================

# POSIX compatibility
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Pyenv initialization - execute these commands in your shell
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

# Declare all targets as phony to prevent conflicts with files
.PHONY: help project-pyenv-init project-init build-pyenv activate-pyenv check-pyenv check-python install-databricks-cli install-poetry install-deps install-hooks setup-mcp setup setup-symlinks validate lint format lint-fix test test-cov build build-verify clean check-venv

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

project-pyenv-init: build-pyenv activate-pyenv check-pyenv check-python ## Initialize pyenv and Python environment
	@echo ""
	@echo "✓ Project pyenv initialization complete"
	@echo ""
	@echo "========================================"
	@echo "IMPORTANT: To use pyenv in this terminal, run:"
	@echo "  source shared_scripts/activate-pyenv.sh"
	@echo "========================================"

project-init: install-databricks-cli install-poetry install-deps install-hooks setup-symlinks ## Initialize project end-to-end
	@echo ""
	@echo "✓ Project initialization complete"
	@echo ""

setup-symlinks: ## Set up convenience symlinks at project root
	@bash scripts/setup-symlinks.sh

# ==============================================================================
# Pyenv Management
# ==============================================================================

build-pyenv: ## Install Python version via pyenv
	@$(SHELL_INIT); pyenv install -s $(PYTHON_VERSION)

activate-pyenv: ## Activate pyenv and set Python version
	@echo "Activating pyenv..."
	@$(SHELL_INIT); \
	command -v pyenv >/dev/null 2>&1 || { \
		echo "$(ERROR_PYENV_NOT_FOUND)$(PYENV_INSTALL_INSTRUCTIONS)"; \
		exit 1; \
	}
	@echo "✓ pyenv is available"
	@$(SHELL_INIT); \
	pyenv versions | grep -q "$(PYTHON_VERSION)" || { \
		echo "ERROR: Python $(PYTHON_VERSION) not installed"; \
		echo ""; \
		echo "Installing Python $(PYTHON_VERSION)..."; \
		pyenv install $(PYTHON_VERSION); \
	}
	@echo "Setting local Python version to $(PYTHON_VERSION)..."
	@$(SHELL_INIT); pyenv local $(PYTHON_VERSION) >/dev/null 2>&1
	@echo "✓ Python $(PYTHON_VERSION) configured"
	@echo ""
	@echo "========================================"
	@echo "To activate pyenv NOW in your terminal:"
	@echo "  source shared_scripts/activate-pyenv.sh"
	@echo "========================================"

check-pyenv: ## Verify pyenv installation and Python version
	@echo "Checking pyenv installation..."
	@$(SHELL_INIT); \
	command -v pyenv >/dev/null 2>&1 || { \
		echo "$(ERROR_PYENV_NOT_FOUND)$(PYENV_INSTALL_INSTRUCTIONS)"; \
		echo ""; \
		echo "Then add to your shell config (~/.bashrc or ~/.zshrc):"; \
		echo "  export PATH=\"\$$HOME/.pyenv/bin:\$$PATH\""; \
		echo "  eval \"\$$(pyenv init -)\""; \
		echo "  eval \"\$$(pyenv virtualenv-init -)\""; \
		exit 1; \
	}
	@$(SHELL_INIT); echo "✓ pyenv found (version $$(pyenv --version | cut -d' ' -f2))"
	@$(SHELL_INIT); \
	pyenv versions | grep -q "$(PYTHON_VERSION)" || { \
		echo "ERROR: Python $(PYTHON_VERSION) not installed"; \
		echo ""; \
		echo "Install it with:"; \
		echo "  pyenv install $(PYTHON_VERSION)"; \
		echo "  pyenv local $(PYTHON_VERSION)"; \
		exit 1; \
	}
	@echo "✓ Python $(PYTHON_VERSION) is installed"
	@$(SHELL_INIT); \
	if [ "$$(python --version 2>&1 | awk '{print $$2}')" = "$(PYTHON_VERSION)" ]; then \
		echo "✓ Python $(PYTHON_VERSION) is active"; \
	else \
		echo "Warning: Active Python version ($$(python --version 2>&1)) doesn't match $(PYTHON_VERSION)"; \
		echo "Run: pyenv local $(PYTHON_VERSION)"; \
	fi

check-python: ## Check which Python version is active in terminal
	@echo "=== Python Environment Check ==="
	@echo ""
	@echo "Python version:"
	@python --version
	@echo ""
	@echo "Python path:"
	@which python
	@echo ""
	@echo "Pyenv version:"
	@$(SHELL_INIT); pyenv version 2>/dev/null || echo "pyenv not initialized in this shell"
	@echo ""
	@echo "Local .python-version file:"
	@cat .python-version 2>/dev/null || echo "No .python-version file found"
	@echo ""
	@echo "Environment variables:"
	@echo "  PYENV_VERSION: $$PYENV_VERSION"
	@echo "  VIRTUAL_ENV: $$VIRTUAL_ENV"
	@echo ""
	@if echo "$$(which python)" | grep -q "pyenv/shims"; then \
		echo "✓ Terminal is using pyenv Python"; \
	elif echo "$$(which python)" | grep -q ".venv"; then \
		echo "✓ Terminal is using virtual environment Python"; \
	else \
		echo "✗ Terminal is NOT using pyenv (using system Python)"; \
		echo "  Run: source shared_scripts/activate-pyenv.sh"; \
	fi

# ==============================================================================
# Dependency Installation
# ==============================================================================

install-databricks-cli: ## Install Databricks CLI if not present
	@if command -v databricks >/dev/null 2>&1; then \
		echo "✓ Databricks CLI already installed (version $$(databricks --version 2>&1))"; \
	else \
		echo "Installing Databricks CLI..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew tap databricks/tap; \
			brew install databricks; \
		else \
			echo "Installing via curl..."; \
			curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh; \
		fi; \
		echo "✓ Databricks CLI installed"; \
	fi

install-poetry: ## Install Poetry if not present
	@if command -v poetry >/dev/null 2>&1; then \
		echo "✓ Poetry already installed (version $$(poetry --version | awk '{print $$3}'))"; \
	else \
		echo "Installing Poetry $(POETRY_VERSION)..."; \
		curl -sSL https://install.python-poetry.org | python3 - --version $(POETRY_VERSION); \
		echo "✓ Poetry installed to $(POETRY_BIN)"; \
		echo ""; \
		echo "Note: Add Poetry to your PATH if needed:"; \
		echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""; \
	fi

install-deps: install-poetry ## Install project dependencies
	@echo "Configuring Poetry..."
	@poetry config virtualenvs.in-project true
	@echo "✓ virtualenvs.in-project = true"
	@echo "Installing dependencies..."
	@poetry install --no-root --with cli,mcp,dev,test
	@echo "✓ Dependencies installed (including cli, mcp, dev, and test groups)"

install-hooks: check-venv ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	@poetry run pre-commit install
	@echo "✓ Pre-commit hooks installed"

# ==============================================================================
# Environment Setup
# ==============================================================================

setup: check-pyenv install-poetry install-deps setup-symlinks ## Set up development environment
	@echo ""
	@echo "✓ Development environment ready"
	@echo ""
	@echo "Run 'make help' to see available commands."

setup-mcp: ## Install MCP dependencies from installed library
	@echo "Installing MCP dependencies..."
	@poetry install --no-root --with mcp --with cli
	@echo "✓ MCP dependencies installed (including CLI dependencies required by MCP server)"
	@echo ""
	@echo "MCP server is now ready. The databricks-utils package is available in the virtual environment."

validate: ## Validate environment configuration
	@echo "Validating environment..."
	@test -f .python-version && echo "✓ .python-version file exists" || { echo "✗ .python-version missing"; exit 1; }
	@test -f pyproject.toml && echo "✓ pyproject.toml exists" || { echo "✗ pyproject.toml missing"; exit 1; }
	@test -f poetry.lock && echo "✓ poetry.lock exists" || { echo "✗ poetry.lock missing"; exit 1; }
	@$(SHELL_INIT); command -v pyenv >/dev/null 2>&1 && echo "✓ pyenv available" || { echo "✗ pyenv not found"; exit 1; }
	@$(SHELL_INIT); pyenv versions | grep -q "$(PYTHON_VERSION)" && echo "✓ Python $(PYTHON_VERSION) installed" || { echo "✗ Python $(PYTHON_VERSION) not installed"; exit 1; }
	@command -v poetry >/dev/null 2>&1 && echo "✓ Poetry available" || { echo "✗ Poetry not found"; exit 1; }
	@test -d $(VENV_PATH) && echo "✓ $(VENV_PATH) exists" || { echo "✗ $(VENV_PATH) not found - run 'make setup'"; exit 1; }
	@echo ""
	@echo "✓ All validations passed"

# ==============================================================================
# Code Quality
# ==============================================================================

lint: check-venv ## Check code with ruff
	@echo "Checking code with ruff..."
	@poetry run ruff check .

format: check-venv ## Format code with ruff
	@echo "Formatting code with ruff..."
	@poetry run ruff format .

lint-fix: check-venv ## Fix linting issues and format code
	@echo "Fixing linting issues..."
	@poetry run ruff check --fix --unsafe-fixes .
	@echo "Formatting code..."
	@poetry run ruff format .
	@echo "✓ Code quality fixes applied"

# ==============================================================================
# Testing
# ==============================================================================

test: check-venv ## Run test suite
	@echo "Running tests..."
	@poetry run pytest -v

test-cov: check-venv ## Run tests with coverage report
	@echo "Running tests with coverage..."
	@poetry run pytest --cov=src --cov-report=html --cov-report=term

# ==============================================================================
# Build and Clean
# ==============================================================================

build: check-venv ## Build the project
	@echo "Building project..."
	@poetry build
	@echo "✓ Build complete"
	@echo ""
	@echo "Verifying package contents..."
	@tar -tzf dist/skyscanner_agentic_data_engineer-*.tar.gz | grep -E "(.claude|shared_scripts|shared_agents_usage_docs)" | head -20 || echo "Note: To see full package contents, use: tar -tzf dist/skyscanner_agentic_data_engineer-*.tar.gz"

build-verify: build ## Build and verify included files
	@echo ""
	@echo "=== Package Contents Verification ==="
	@echo ""
	@echo "Claude Code files:"
	@tar -tzf dist/skyscanner_agentic_data_engineer-*.tar.gz | grep ".claude" | wc -l | xargs echo "  Files included:"
	@echo ""
	@echo "Scripts shared:"
	@tar -tzf dist/skyscanner_agentic_data_engineer-*.tar.gz | grep "shared_scripts" | wc -l | xargs echo "  Files included:"
	@echo ""
	@echo "Agent usage docs:"
	@tar -tzf dist/skyscanner_agentic_data_engineer-*.tar.gz | grep "shared_agents_usage_docs" | wc -l | xargs echo "  Files included:"
	@echo ""
	@echo "✓ Verification complete"

clean: ## Remove build artifacts and caches
	@echo "Cleaning build artifacts and caches..."
	@rm -rf dist/ build/ *.egg-info spark-warehouse/ spark-warehouse-unit/ spark-warehouse-integration/ spark-warehouse-data-quality/
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name '*.pyc' -delete
	@rm -rf .pytest_cache .ruff_cache htmlcov/ .coverage
	@echo "✓ Clean complete"

# End of Makefile
