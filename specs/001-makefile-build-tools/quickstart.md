# Quickstart Guide: Makefile Build Tools

**Feature**: 001-makefile-build-tools
**Last Updated**: 2025-11-23

## Overview

This guide helps you get started with the Makefile build automation system for this project. Follow these steps to set up your development environment and learn the essential commands.

## Prerequisites

Before you begin, ensure you have:

1. **pyenv** installed (for Python version management)
2. **Git** installed (for cloning the repository)
3. **macOS**, **Linux**, or **Windows WSL** environment

### Installing pyenv

If you don't have pyenv installed:

**macOS**:
```bash
brew install pyenv

# Add to ~/.zshrc or ~/.bashrc
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

**Linux**:
```bash
curl https://pyenv.run | bash

# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
source ~/.bashrc
```

**Windows**:
- Install WSL2 (Windows Subsystem for Linux)
- Follow Linux instructions above in WSL terminal

## Quick Setup (5 minutes)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-name>
```

### 2. Install Required Python Version

```bash
# Check required version
cat .python-version

# Install it (if not already installed)
pyenv install $(cat .python-version)

# Set as local version for this project
pyenv local $(cat .python-version)

# Verify
python --version
```

### 3. Run Setup

```bash
make setup
```

This single command will:
- ✅ Verify pyenv is installed
- ✅ Check Python version is available
- ✅ Install poetry (if needed)
- ✅ Configure poetry settings
- ✅ Install all project dependencies
- ✅ Create virtual environment (`.venv/`)

**Expected output**:
```
Checking pyenv installation...
✓ pyenv found (version 2.6.11)
✓ Python 3.12.12 is installed
Checking poetry installation...
✓ poetry found (version 2.2.1)
Configuring poetry...
✓ virtualenvs.in-project = true
Installing dependencies...
Installing dependencies from lock file
...
✓ Dependencies installed
✓ Development environment ready

Run 'make help' to see available commands.
```

### 4. Verify Setup

```bash
make validate
```

This checks that everything is configured correctly.

## Essential Commands

### View All Available Commands

```bash
make help
```

or just:

```bash
make
```

### Code Quality

**Check code for issues** (no changes):
```bash
make lint
```

**Format code** (modifies files):
```bash
make format
```

**Fix issues and format** (one command):
```bash
make lint-fix
```

### Testing

**Run tests**:
```bash
make test
```

**Run tests with coverage**:
```bash
make test-cov
```

Coverage report will be generated at `htmlcov/index.html`

### Building

**Build the project**:
```bash
make build
```

**Clean build artifacts**:
```bash
make clean
```

## Daily Workflow

### Starting Work

```bash
# Pull latest changes
git pull

# Update dependencies if needed
make install-deps

# Verify environment
make validate
```

### Before Committing

```bash
# Fix code quality issues
make lint-fix

# Run tests
make test

# Review changes
git status
git diff
```

### Making Changes

1. **Write code**
2. **Run lint-fix**: `make lint-fix`
3. **Run tests**: `make test`
4. **Commit changes**: `git commit`

## Common Scenarios

### Scenario 1: Fresh Clone Setup

```bash
git clone <repo-url>
cd <repo-name>
make setup
# Start coding!
```

### Scenario 2: After Pulling Changes

```bash
git pull
make install-deps  # Updates dependencies
make test          # Verify everything works
```

### Scenario 3: Adding New Dependencies

```bash
poetry add <package-name>        # For runtime dependency
poetry add --group dev <package>  # For dev dependency
make test                         # Verify tests pass
git add pyproject.toml poetry.lock
git commit -m "Add <package-name> dependency"
```

### Scenario 4: Dependency Issues

```bash
# If poetry.lock is out of sync
poetry lock --no-update

# If virtual env is corrupted
rm -rf .venv
make setup
```

### Scenario 5: Code Formatting Conflicts

```bash
# Before committing
make lint-fix

# If conflicts after merge
git merge <branch>
make lint-fix
git add .
git commit
```

## Troubleshooting

### Problem: "pyenv not found"

**Solution**:
```bash
# macOS
brew install pyenv

# Linux
curl https://pyenv.run | bash

# Add to shell config and restart terminal
```

### Problem: "Python version not installed"

**Solution**:
```bash
# Check required version
cat .python-version

# Install it
pyenv install $(cat .python-version)
```

### Problem: "poetry not found"

**Solution**:
```bash
# poetry should auto-install, but if not:
curl -sSL https://install.python-poetry.org | python3 -

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

### Problem: Dependencies won't install

**Check**:
1. Python version matches `.python-version`: `python --version`
2. Poetry is working: `poetry --version`
3. Lock file is valid: `poetry lock --check`

**Solutions**:
```bash
# Update lock file
poetry lock --no-update

# Clear poetry cache
poetry cache clear pypi --all

# Reinstall
rm -rf .venv
make setup
```

### Problem: Tests failing after setup

**Check**:
```bash
# Verify environment
make validate

# Check Python version
python --version

# List installed packages
poetry show
```

### Problem: "Command not found" errors

**Solution**:
```bash
# Ensure you're using poetry to run commands
poetry run python script.py
poetry run pytest

# Or activate the virtual environment
source .venv/bin/activate
python script.py
pytest
```

## Understanding the Virtual Environment

### What is `.venv/`?

- Isolated Python environment for this project
- Contains all dependencies listed in `pyproject.toml`
- Managed by poetry
- Created during `make setup`

### Do I need to activate it?

**No, if using make targets**:
```bash
make test      # Automatically uses .venv
make lint      # Automatically uses .venv
```

**Yes, if running commands directly**:
```bash
source .venv/bin/activate
python script.py
pytest
deactivate  # When done
```

**Alternative - use poetry run**:
```bash
poetry run python script.py
poetry run pytest
```

## Configuration Files

### `.python-version`
- Specifies required Python version
- Used by pyenv to auto-activate correct version
- Committed to git

### `pyproject.toml`
- Project metadata and dependencies
- Poetry configuration
- Ruff linting/formatting rules
- Pytest configuration
- Committed to git

### `poetry.lock`
- Locked dependency versions
- Ensures reproducible installs
- **Always commit this file**

### `Makefile`
- Build automation commands
- Entry point for all development tasks
- Self-documenting (run `make help`)

## Tips and Best Practices

### 1. Always Use Make Targets

✅ **Do**:
```bash
make test
make lint
make format
```

❌ **Don't**:
```bash
pytest
ruff check .
ruff format .
```

**Why**: Make targets ensure correct environment and consistent behavior

### 2. Run lint-fix Before Committing

```bash
make lint-fix  # Before git commit
```

### 3. Keep Dependencies Up to Date

```bash
# Update specific package
poetry update <package-name>

# Update all packages
poetry update

# Always test after updates
make test
```

### 4. Clean When Things Get Weird

```bash
make clean
```

Removes caches, build artifacts, and temporary files.

### 5. Validate After Major Changes

```bash
make validate
```

Checks all tool configurations and environment state.

## Next Steps

1. **Read the full docs**: Check `specs/001-makefile-build-tools/` directory
2. **Explore the codebase**: Look at `src/` and `tests/` directories
3. **Run tests**: `make test` to see the test suite
4. **Make changes**: Edit files, run `make lint-fix`, commit
5. **Ask for help**: Check team documentation or ask a teammate

## Quick Reference Card

```bash
# Setup
make setup              # One-time environment setup
make validate           # Verify configuration

# Code Quality
make lint               # Check code (no changes)
make format             # Format code (modifies files)
make lint-fix           # Fix + format (one command)

# Testing
make test               # Run tests
make test-cov           # Run with coverage

# Maintenance
make install-deps       # Update dependencies
make clean              # Remove artifacts
make help               # Show all commands

# Direct Commands (if needed)
poetry add <package>    # Add dependency
poetry show             # List dependencies
poetry run <command>    # Run in venv
```

## Getting Help

- **View all commands**: `make help`
- **Check configuration**: `make validate`
- **Verify setup**: `make check-pyenv`
- **See installed packages**: `poetry show`
- **Check Python version**: `python --version`

## Summary

You're now ready to develop! The key commands are:

1. **Setup once**: `make setup`
2. **Before committing**: `make lint-fix && make test`
3. **View commands**: `make help`

Happy coding! 🚀
