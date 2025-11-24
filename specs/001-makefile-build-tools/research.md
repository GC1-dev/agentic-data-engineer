# Research: Makefile Build Tools Configuration

**Feature**: 001-makefile-build-tools
**Date**: 2025-11-23
**Status**: Complete

## Overview

This document consolidates research on Makefile patterns, pyenv integration, poetry automation, and ruff configuration for creating a robust, cross-platform development tooling setup.

## 1. Makefile Best Practices for Python Projects

### Decision: Use POSIX-compatible Makefile with shell detection

**Rationale**:
- POSIX compatibility ensures cross-platform support (macOS, Linux, WSL)
- Shell detection allows graceful handling of bash vs zsh differences
- `.PHONY` targets prevent conflicts with files of the same name
- Variable declarations at top improve maintainability

**Key Patterns**:
```makefile
.PHONY: target-name    # Always declare targets as .PHONY
.DEFAULT_GOAL := help  # Set default target when running 'make' alone
SHELL := /bin/bash     # Explicit shell specification
.ONESHELL:             # Execute recipe in single shell session (preserves env vars)
```

**Alternatives Considered**:
- **Just**: Modern command runner but requires additional installation
- **Task**: Go-based task runner but adds Go dependency
- **npm scripts**: Limited to Node.js ecosystem
- **Rejected because**: Makefile is universally available on Unix systems

## 2. pyenv Integration in Makefiles

### Decision: Detect pyenv and provide installation guidance, not auto-install

**Rationale**:
- pyenv requires shell configuration changes (~/.bashrc, ~/.zshrc)
- Automatic modification of shell configs is risky and invasive
- Better UX to detect, validate, and guide user vs silent installation
- pyenv installation method varies by platform (curl script, homebrew, apt)

**Implementation Pattern**:
```makefile
check-pyenv:
	@command -v pyenv >/dev/null 2>&1 || \
		(echo "pyenv not found. Install: curl https://pyenv.run | bash" && exit 1)
	@pyenv versions | grep -q $(PYTHON_VERSION) || \
		(echo "Python $(PYTHON_VERSION) not installed. Run: pyenv install $(PYTHON_VERSION)" && exit 1)
```

**Alternatives Considered**:
- **Auto-install pyenv**: Too invasive, requires shell config modifications
- **Assume system Python**: Doesn't ensure version consistency
- **Docker containers**: Overkill for local development setup

## 3. Poetry Automation Patterns

### Decision: Auto-install poetry using official installer with version pinning

**Rationale**:
- Poetry's official installer is self-contained (no pip pollution)
- Installer supports specifying exact versions via POETRY_VERSION env var
- Poetry manages its own virtual environment, isolated from project
- Safe to auto-install as it doesn't modify system Python or shell configs

**Implementation Pattern**:
```makefile
POETRY_VERSION := 2.2.1
POETRY_HOME := $(HOME)/.local/share/pypoetry
POETRY_BIN := $(HOME)/.local/bin/poetry

install-poetry:
	@command -v poetry >/dev/null 2>&1 || \
		(curl -sSL https://install.python-poetry.org | python3 - --version $(POETRY_VERSION))
	@poetry --version | grep -q $(POETRY_VERSION) || \
		echo "Warning: Poetry version mismatch"

poetry-install: install-poetry
	poetry config virtualenvs.in-project true
	poetry install --no-root
```

**Best Practices**:
- Use `--no-root` flag if project is not a publishable package
- Set `virtualenvs.in-project` for predictable .venv location
- Lock file (`poetry.lock`) ensures reproducible installs

**Alternatives Considered**:
- **pipenv**: Less active development, slower dependency resolution
- **pip-tools**: Requires manual workflow, less integrated
- **conda**: Heavy, includes non-Python packages unnecessarily

## 4. Ruff Configuration and Automation

### Decision: Install ruff via poetry as dev dependency, configure in pyproject.toml

**Rationale**:
- Ruff is Python package - natural fit for poetry management
- Version pinning via pyproject.toml ensures team consistency
- Single configuration location (pyproject.toml) vs separate .ruff.toml
- Ruff can lint and format, replacing multiple tools (flake8, black, isort)

**Configuration Pattern**:
```toml
[tool.ruff]
line-length = 120
target-version = "py312"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP"]
ignore = ["E501"]  # Line length handled by formatter

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

**Makefile Integration**:
```makefile
lint:
	poetry run ruff check .

format:
	poetry run ruff format .

lint-fix:
	poetry run ruff check --fix .
	poetry run ruff format .
```

**Alternatives Considered**:
- **black + flake8 + isort**: Multiple tools vs single ruff (10-100x slower)
- **pylint**: More comprehensive but much slower, opinionated
- **Global ruff install**: Version inconsistency across developers

## 5. Idempotency Patterns for Makefile Targets

### Decision: Use conditional checks before installation commands

**Rationale**:
- Running setup multiple times should be safe and fast
- Check existence before expensive operations (downloads, installs)
- Provide helpful feedback on current state

**Pattern**:
```makefile
setup: check-pyenv install-poetry poetry-install
	@echo "✓ Development environment ready"

check-pyenv:
	@if command -v pyenv >/dev/null 2>&1; then \
		echo "✓ pyenv found"; \
	else \
		echo "✗ pyenv not found"; \
		exit 1; \
	fi

install-poetry:
	@if command -v poetry >/dev/null 2>&1; then \
		echo "✓ poetry already installed"; \
	else \
		echo "Installing poetry..."; \
		curl -sSL https://install.python-poetry.org | python3 -; \
	fi
```

## 6. Help Target Self-Documentation

### Decision: Use comment-based automatic help generation

**Rationale**:
- Inline documentation stays synchronized with targets
- Developers discover commands via `make help`
- No external documentation files to maintain

**Pattern**:
```makefile
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

setup: ## Set up development environment
	@echo "Setting up..."

test: ## Run test suite
	@poetry run pytest
```

## 7. Cross-Platform Compatibility

### Decision: Target macOS and Linux primarily, document WSL for Windows

**Rationale**:
- macOS and Linux share POSIX compatibility
- Windows developers commonly use WSL for Unix-like environment
- Native Windows Makefile support is limited (requires GNU Make for Windows)
- Most Python development tooling assumes Unix-like environment

**Considerations**:
- Use `command -v` instead of `which` (more portable)
- Avoid GNU-specific extensions where possible
- Test on both bash and zsh shells
- Document WSL setup for Windows users

**Windows Support**:
- Recommend WSL2 for Windows 10/11 users
- Alternative: Git Bash (includes GNU Make)
- Document in README with setup instructions

## 8. Error Handling and User Feedback

### Decision: Fail fast with clear, actionable error messages

**Rationale**:
- Developers should know immediately what went wrong
- Error messages should include remediation steps
- Exit codes should halt the build pipeline appropriately

**Pattern**:
```makefile
check-pyenv:
	@command -v pyenv >/dev/null 2>&1 || { \
		echo "ERROR: pyenv not found"; \
		echo ""; \
		echo "Install pyenv:"; \
		echo "  macOS: brew install pyenv"; \
		echo "  Linux: curl https://pyenv.run | bash"; \
		echo ""; \
		echo "Then add to your shell config:"; \
		echo "  export PATH=\"\$$HOME/.pyenv/bin:\$$PATH\""; \
		echo "  eval \"\$$(pyenv init -)\""; \
		exit 1; \
	}
```

## 9. Python Version Management Strategy

### Decision: Use .python-version file with pyenv integration

**Rationale**:
- `.python-version` file provides single source of truth
- pyenv automatically activates correct version when entering directory
- Poetry respects pyenv's active Python version
- Version is tracked in git, ensuring team consistency

**Implementation**:
```makefile
PYTHON_VERSION := $(shell cat .python-version 2>/dev/null || echo "3.12.12")

check-python-version:
	@if [ "$$(python --version 2>&1 | cut -d' ' -f2)" != "$(PYTHON_VERSION)" ]; then \
		echo "Warning: Active Python version doesn't match .python-version"; \
		echo "Expected: $(PYTHON_VERSION)"; \
		echo "Active: $$(python --version)"; \
		echo "Run: pyenv local $(PYTHON_VERSION)"; \
	fi
```

## 10. Testing and Build Targets

### Decision: Provide separate targets for test, build, and clean operations

**Rationale**:
- Clear separation of concerns
- Developers can run operations independently
- CI/CD pipelines can invoke specific stages

**Pattern**:
```makefile
test: ## Run test suite with pytest
	poetry run pytest -v

test-cov: ## Run tests with coverage report
	poetry run pytest --cov=src --cov-report=html --cov-report=term

build: ## Build the project (if applicable)
	poetry build

clean: ## Remove build artifacts and caches
	rm -rf dist/ build/ *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete
	rm -rf .pytest_cache .ruff_cache htmlcov/ .coverage
```

## Summary of Key Decisions

| Component | Decision | Rationale |
|-----------|----------|-----------|
| Build Tool | GNU Make (POSIX-compatible) | Universal availability, no extra dependencies |
| Python Version | pyenv with .python-version file | Team consistency, auto-activation |
| Package Manager | Poetry 2.2+ | Modern, fast, reliable dependency resolution |
| Code Quality | Ruff (lint + format) | 10-100x faster than alternatives, all-in-one |
| Installation | Detect pyenv, auto-install poetry | Balance safety vs convenience |
| Documentation | Self-documenting help target | Inline docs, always synchronized |
| Idempotency | Conditional checks before operations | Safe to run multiple times |
| Error Handling | Fail fast with actionable messages | Clear remediation steps |

## Implementation Checklist

- [ ] Create Makefile with help target (default)
- [ ] Add pyenv detection and validation
- [ ] Add poetry installation and configuration
- [ ] Add dependency installation targets
- [ ] Add ruff lint and format targets
- [ ] Add test execution targets
- [ ] Add build and clean targets
- [ ] Add cross-platform compatibility checks
- [ ] Document all targets with inline comments
- [ ] Test on macOS and Linux
- [ ] Document WSL setup for Windows users
