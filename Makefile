# Makefile for agentic-data-engineer
# Build automation for Python project with pyenv, poetry, and ruff

# POSIX compatibility
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Variables
PYTHON_VERSION := $(shell cat .python-version 2>/dev/null || echo "3.12.12")
POETRY_VERSION := 2.2.1
POETRY_HOME := $(HOME)/.local/share/pypoetry
POETRY_BIN := $(HOME)/.local/bin/poetry
VENV_PATH := .venv

# Targets

# Declare all targets as phony to prevent conflicts with files
.PHONY: help activate-pyenv check-pyenv install-poetry install-deps setup-mcp setup validate lint format lint-fix test test-cov build clean

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: activate-pyenv
activate-pyenv: ## Activate pyenv and set Python version
	@echo "Activating pyenv..."
	@command -v pyenv >/dev/null 2>&1 || { \
		echo "ERROR: pyenv not found"; \
		echo ""; \
		echo "Install pyenv:"; \
		echo "  macOS: brew install pyenv"; \
		echo "  Linux: curl https://pyenv.run | bash"; \
		exit 1; \
	}
	@echo "✓ pyenv is available"
	@pyenv versions | grep -q "$(PYTHON_VERSION)" || { \
		echo "ERROR: Python $(PYTHON_VERSION) not installed"; \
		echo ""; \
		echo "Installing Python $(PYTHON_VERSION)..."; \
		pyenv install $(PYTHON_VERSION); \
	}
	@echo "Setting local Python version to $(PYTHON_VERSION)..."
	@pyenv local $(PYTHON_VERSION)
	@echo "✓ Python $(PYTHON_VERSION) activated"
	@echo ""
	@echo "Current Python version: $$(python --version)"
	@echo "Python path: $$(which python)"
	@echo ""
	@echo "Note: To activate pyenv in your shell, ensure these lines are in ~/.bashrc or ~/.zshrc:"
	@echo "  export PATH=\"\$$HOME/.pyenv/bin:\$$PATH\""
	@echo "  eval \"\$$(pyenv init --path)\""
	@echo "  eval \"\$$(pyenv init -)\""

.PHONY: check-pyenv
check-pyenv: ## Verify pyenv installation and Python version
	@echo "Checking pyenv installation..."
	@command -v pyenv >/dev/null 2>&1 || { \
		echo "ERROR: pyenv not found"; \
		echo ""; \
		echo "Install pyenv:"; \
		echo "  macOS: brew install pyenv"; \
		echo "  Linux: curl https://pyenv.run | bash"; \
		echo ""; \
		echo "Then add to your shell config (~/.bashrc or ~/.zshrc):"; \
		echo "  export PATH=\"\$$HOME/.pyenv/bin:\$$PATH\""; \
		echo "  eval \"\$$(pyenv init -)\""; \
		echo "  eval \"\$$(pyenv virtualenv-init -)\""; \
		exit 1; \
	}
	@echo "✓ pyenv found (version $$(pyenv --version | cut -d' ' -f2))"
	@pyenv versions | grep -q "$(PYTHON_VERSION)" || { \
		echo "ERROR: Python $(PYTHON_VERSION) not installed"; \
		echo ""; \
		echo "Install it with:"; \
		echo "  pyenv install $(PYTHON_VERSION)"; \
		echo "  pyenv local $(PYTHON_VERSION)"; \
		exit 1; \
	}
	@echo "✓ Python $(PYTHON_VERSION) is installed"
	@if [ "$$(python --version 2>&1 | awk '{print $$2}')" = "$(PYTHON_VERSION)" ]; then \
		echo "✓ Python $(PYTHON_VERSION) is active"; \
	else \
		echo "Warning: Active Python version ($$(python --version 2>&1)) doesn't match $(PYTHON_VERSION)"; \
		echo "Run: pyenv local $(PYTHON_VERSION)"; \
	fi

.PHONY: install-poetry
install-poetry: ## Install poetry if not present
	@if command -v poetry >/dev/null 2>&1; then \
		echo "✓ poetry already installed (version $$(poetry --version | awk '{print $$3}'))"; \
	else \
		echo "Installing poetry $(POETRY_VERSION)..."; \
		curl -sSL https://install.python-poetry.org | python3 - --version $(POETRY_VERSION); \
		echo "✓ poetry installed to $(POETRY_BIN)"; \
		echo ""; \
		echo "Note: Add poetry to your PATH if needed:"; \
		echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""; \
	fi

.PHONY: install-deps
install-deps: install-poetry ## Install project dependencies
	@echo "Configuring poetry..."
	@poetry config virtualenvs.in-project true
	@echo "✓ virtualenvs.in-project = true"
	@echo "Installing dependencies..."
	@poetry install --no-root
	@echo "✓ Dependencies installed"

.PHONY: setup-mcp
setup-mcp: ## Install MCP dependencies for databricks-utils submodule
	@echo "Installing MCP dependencies for databricks-utils..."
	@test -d databricks-utils || { echo "ERROR: databricks-utils submodule not found. Run 'git submodule update --init' first."; exit 1; }
	@poetry -C databricks-utils install --with mcp
	@echo "✓ MCP dependencies installed for databricks-utils"
	@echo ""
	@echo "MCP server is now ready. Configure it in Claude Code with:"
	@echo "  Path: $(shell pwd)/databricks-utils"
	@echo "  Command: poetry run python -m src.mcp"

.PHONY: setup
setup: check-pyenv install-poetry install-deps ## Set up development environment
	@echo ""
	@echo "✓ Development environment ready"
	@echo ""
	@echo "Run 'make help' to see available commands."

.PHONY: validate
validate: ## Validate environment configuration
	@echo "Validating environment..."
	@echo "Checking .python-version file..."
	@test -f .python-version && echo "✓ .python-version file exists" || { echo "✗ .python-version missing"; exit 1; }
	@echo "Checking pyproject.toml..."
	@test -f pyproject.toml && echo "✓ pyproject.toml exists" || { echo "✗ pyproject.toml missing"; exit 1; }
	@echo "Checking poetry.lock..."
	@test -f poetry.lock && echo "✓ poetry.lock exists" || { echo "✗ poetry.lock missing"; exit 1; }
	@echo "Checking pyenv..."
	@command -v pyenv >/dev/null 2>&1 && echo "✓ pyenv available" || { echo "✗ pyenv not found"; exit 1; }
	@echo "Checking Python version..."
	@pyenv versions | grep -q "$(PYTHON_VERSION)" && echo "✓ Python $(PYTHON_VERSION) installed" || { echo "✗ Python $(PYTHON_VERSION) not installed"; exit 1; }
	@echo "Checking poetry..."
	@command -v poetry >/dev/null 2>&1 && echo "✓ poetry available" || { echo "✗ poetry not found"; exit 1; }
	@echo "Checking virtual environment..."
	@test -d $(VENV_PATH) && echo "✓ $(VENV_PATH) exists" || { echo "✗ $(VENV_PATH) not found - run 'make setup'"; exit 1; }
	@echo ""
	@echo "✓ All validations passed"

.PHONY: lint
lint: ## Check code with ruff
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found. Run 'make setup' first."; exit 1; }
	@echo "Checking code with ruff..."
	@poetry run ruff check .

.PHONY: format
format: ## Format code with ruff
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found. Run 'make setup' first."; exit 1; }
	@echo "Formatting code with ruff..."
	@poetry run ruff format .

.PHONY: lint-fix
lint-fix: ## Fix linting issues and format code
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found. Run 'make setup' first."; exit 1; }
	@echo "Fixing linting issues..."
	@poetry run ruff check --fix .
	@echo "Formatting code..."
	@poetry run ruff format .
	@echo "✓ Code quality fixes applied"

.PHONY: test
test: ## Run test suite
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found. Run 'make setup' first."; exit 1; }
	@echo "Running tests..."
	@poetry run pytest -v

.PHONY: test-cov
test-cov: ## Run tests with coverage report
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found. Run 'make setup' first."; exit 1; }
	@echo "Running tests with coverage..."
	@poetry run pytest --cov=src --cov-report=html --cov-report=term

.PHONY: build
build: ## Build the project
	@test -d $(VENV_PATH) || { echo "ERROR: Virtual environment not found. Run 'make setup' first."; exit 1; }
	@echo "Building project..."
	@poetry build
	@echo "✓ Build complete"

.PHONY: clean
clean: ## Remove build artifacts and caches
	@echo "Cleaning build artifacts and caches..."
	@rm -rf dist/ build/ *.egg-info
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name '*.pyc' -delete
	@rm -rf .pytest_cache .ruff_cache htmlcov/ .coverage
	@echo "✓ Clean complete"

# End of Makefile
