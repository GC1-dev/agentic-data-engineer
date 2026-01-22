---
skill_name: pyproject-formatter-skill
description: |
  Standardize pyproject.toml files according to Skyscanner data engineering conventions
  with proper structure, documentation, and dependency organization.
version: 1.0.0
author: Skyscanner Data Engineering
tags:
  - pyproject
  - poetry
  - formatting
  - dependencies
  - python
---

# pyproject.toml Formatter Skill

## What This Skill Does

This skill standardizes `pyproject.toml` files to match Skyscanner data engineering team conventions. It ensures consistent structure, comprehensive documentation, proper dependency organization, and Poetry best practices.

## When to Use This Skill

Use this skill when you need to:

- ✅ Format a new `pyproject.toml` file
- ✅ Standardize an existing `pyproject.toml` to match team conventions
- ✅ Add documentation to undocumented dependencies
- ✅ Reorganize dependencies into proper groups (cli, mcp, dev, test)
- ✅ Update metadata fields for consistency
- ✅ Ensure compatibility with Poetry best practices
- ✅ Prepare `pyproject.toml` for project templates or cookiecutters

## Capabilities

- Standardize `pyproject.toml` structure with clear sections
- Add comprehensive inline documentation for all dependencies
- Organize dependencies into logical groups (cli, mcp, dev, test)
- Normalize version constraints for consistency
- Add missing metadata fields (license, repository, homepage)
- Preserve project-specific configurations and tooling
- Ensure proper optional group declarations
- Add usage documentation in header comments

## How to Invoke

You can invoke this skill directly or Claude will automatically suggest it when working with `pyproject.toml` files.

### Direct Invocation

```
/pyproject-formatter-skill
```

### Automatic Detection

Claude will suggest this skill when you:
- Create or modify a `pyproject.toml` file
- Ask to format or organize dependencies
- Request standardization of project configuration

## Examples

### Example 1: Format New Project

**User**: "Format my pyproject.toml to match the team standards"

**Assistant**: "I'll use the pyproject-formatter-skill to standardize your pyproject.toml file."

**Result**: File formatted with proper sections, documented dependencies, and team conventions.

---

### Example 2: Add Dependency Documentation

**User**: "Add comments to all my dependencies explaining what they're for"

**Assistant**: "I'll use the pyproject-formatter-skill to add comprehensive documentation."

**Result**: Every dependency gets an inline comment explaining its purpose.

---

### Example 3: Organize Optional Groups

**User**: "Organize my dependencies into cli, mcp, dev, and test groups"

**Assistant**: "I'll use the pyproject-formatter-skill to properly organize your dependencies."

**Result**: Dependencies reorganized into standard groups with proper optional declarations.

---

## Standard Template Structure

The skill applies this standardized structure:

```toml
[tool.poetry]
name = "project-name"
version = "0.1.0"
description = "Project description"
authors = ["Author Name <email@example.com>"]
readme = "README.md"
license = "MIT"
repository = "https://github.com/org/repo"
homepage = "https://github.com/org/repo"
packages = [{ include = "package_name", from = "src" }]

# Optional dependency groups available:
# - cli: Command-line interface tools (install with: poetry install --with cli)
# - mcp: Model Context Protocol support (install with: poetry install --with mcp)
# - dev: Development tools (install with: poetry install --with dev)
# - test: Testing tools (install with: poetry install --with test)

# ============================================================================
# Package Sources
# ============================================================================

[[tool.poetry.source]]
name = "skyscanner-artifactory"
url = "https://artifactory.skyscannertools.net/artifactory/api/pypi/pypi/simple/"
priority = "primary"

# ============================================================================
# Dependencies
# ============================================================================

[tool.poetry.dependencies]
python = ">=3.10,<4.0"  # Databricks Runtime 12.2 LTS compatible
# Core dependencies here with inline comments

# ============================================================================
# CLI Dependencies
# ============================================================================

[tool.poetry.group.cli]
optional = true

[tool.poetry.group.cli.dependencies]
# CLI-specific dependencies

# ============================================================================
# MCP Dependencies
# ============================================================================

[tool.poetry.group.mcp]
optional = true

[tool.poetry.group.mcp.dependencies]
# MCP-specific dependencies

# ============================================================================
# Dev Dependencies
# ============================================================================

[tool.poetry.group.dev]
optional = false

[tool.poetry.group.dev.dependencies]
# Development tools

# ============================================================================
# Test Dependencies
# ============================================================================

[tool.poetry.group.test]
optional = false

[tool.poetry.group.test.dependencies]
# Testing tools and frameworks

# ============================================================================
# Build System
# ============================================================================

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

# ============================================================================
# Tool Configuration
# ============================================================================

# Tool configs preserved here
```

## Dependency Documentation Standards

Every dependency must have an inline comment explaining its purpose:

### Pattern
```toml
package-name = ">=X.Y.Z"  # Brief description of what it does
```

### Examples

**Core Dependencies:**
```toml
pyspark = ">=3.4.0"  # Apache Spark for distributed data processing
pydantic = ">=2.0.0"  # JSON Schema generation from type hints
pyyaml = ">=6.0.0"  # YAML parser for configuration files
```

**Internal Dependencies:**
```toml
# Skyscanner data engineering utilities
skyscanner-databricks-utils = ">=0.2.2"  # Databricks utilities and helpers
skyscanner-data-shared-utils = ">=1.0.2"  # Shared data engineering utilities
```

**CLI Tools:**
```toml
databricks-sdk = ">=0.18.0"  # Databricks SDK for Python
click = ">=8.1.0"  # CLI framework
rich = ">=13.0.0"  # Rich terminal formatting
```

## Version Constraint Guidelines

### Recommended Patterns

```toml
# Minimum version (recommended for most packages)
package = ">=1.0.0"

# Exact version (use for critical compatibility)
delta-spark = "3.2.0"  # Pinned for Databricks compatibility

# Version range (use when specific max version needed)
pytest-asyncio = ">=0.21.0,<0.23.0"  # 0.23.x has compatibility issues

# Python version constraint
python = ">=3.10,<4.0"  # Databricks Runtime 12.2 LTS compatible
```

### Avoid

```toml
package = "^1.0.0"  # Don't use caret notation, use >= instead
package = "*"       # Don't use wildcards
```

## Dependency Group Organization

### [tool.poetry.dependencies]
**Core runtime dependencies** - required for the package to function:
- Python version
- Data processing libraries (PySpark, pandas)
- Data models (Pydantic)
- Configuration (PyYAML)
- Logging (python-json-logger)
- Internal package dependencies

### [tool.poetry.group.cli] (optional = true)
**Command-line interface tools** - for running CLI applications:
- databricks-sdk, databricks-cli, databricks-sql-connector
- click (CLI framework)
- rich (terminal formatting)
- pandas (for CLI data display)

### [tool.poetry.group.mcp] (optional = true)
**Model Context Protocol** - for MCP server/client functionality:
- mcp (official SDK)
- pydantic (if not in core dependencies)
- httpx (async HTTP client)
- anyio (async compatibility)

### [tool.poetry.group.dev] (optional = false)
**Development tools** - for code quality and development:
- ruff (linter and formatter)
- pre-commit (git hooks)
- black (formatter, if needed)
- flake8 (linter, if needed)

### [tool.poetry.group.test] (optional = false)
**Testing tools** - for running tests:
- pytest (test framework)
- pytest-cov (coverage)
- pytest-asyncio (async testing)
- pyyaml (config testing)
- jsonschema (schema validation)
- delta-spark (for integration tests)

## Common Dependencies Reference

### Data Engineering Stack
```toml
pyspark = ">=3.4.0"  # Apache Spark for distributed data processing
delta-spark = "3.2.0"  # Delta Lake support - pinned for Databricks compatibility
pandas = ">=2.0.0"  # Data manipulation and analysis
numpy = ">=1.24.0"  # Numerical computing library
scipy = ">=1.11.0"  # Scientific computing library for statistical operations
```

### Databricks Tools
```toml
databricks-sdk = ">=0.18.0"  # Databricks SDK for Python
databricks-cli = ">=0.18.0"  # Databricks CLI tool
databricks-sql-connector = ">=4.2.2"  # SQL connector for Databricks
```

### Data Validation
```toml
pydantic = ">=2.0.0"  # JSON Schema generation from type hints
jsonschema = ">=4.20.0"  # JSON Schema validation for contract tests
```

### Configuration & Serialization
```toml
pyyaml = ">=6.0.0"  # YAML parser for configuration files
python-json-logger = ">=4.0.0"  # Structured JSON logging
```

### CLI Tools
```toml
click = ">=8.1.0"  # CLI framework
rich = ">=13.0.0"  # Rich terminal formatting
```

### Testing Tools
```toml
pytest = ">=7.0.0"  # Testing framework
pytest-cov = ">=4.0.0"  # Coverage plugin for pytest
pytest-asyncio = ">=0.21.0,<0.23.0"  # Async test support (0.23.x has compatibility issues)
```

## Formatting Checklist

Before completing, the skill verifies:

- ✅ All section separators in place
- ✅ Header comment with optional groups documented
- ✅ Metadata fields complete (name, version, description, authors, license, repository, homepage)
- ✅ Python version constraint uses `>=3.10,<4.0` format
- ✅ All dependencies have inline comments
- ✅ Internal dependencies grouped and labeled
- ✅ CLI group marked as `optional = true`
- ✅ MCP group marked as `optional = true`
- ✅ Dev group marked as `optional = false`
- ✅ Test group marked as `optional = false`
- ✅ Version constraints use `>=` notation
- ✅ Build system specifies `poetry-core>=1.0.0`
- ✅ Tool configurations preserved
- ✅ File ends with newline

## What Gets Preserved

**Always preserved:**
- Existing tool configurations ([tool.ruff], [tool.pytest.ini_options], etc.)
- Project-specific packages list
- Actual project name, version, authors
- Any custom dependency groups beyond cli/mcp/dev/test
- Existing version pins with rationale

**Updated/Standardized:**
- Section structure and separators
- Version constraint format (^ to >=)
- Inline documentation
- Metadata fields (add missing ones)
- Group optional declarations

## Output Summary

After formatting, the skill provides a summary of changes:
- ✅ Added metadata fields
- ✅ Restructured sections
- ✅ Updated version constraints
- ✅ Added inline documentation
- ✅ Organized dependency groups

## Success Criteria

A well-formatted pyproject.toml has:

- ✅ Clear section separators with visual hierarchy
- ✅ Complete metadata (name, version, description, authors, license, repository, homepage)
- ✅ Header comment documenting optional groups
- ✅ All dependencies documented with inline comments
- ✅ Consistent version constraint format (>=)
- ✅ Proper optional group declarations
- ✅ Internal dependencies grouped and labeled
- ✅ Standard dependency groups (cli, mcp, dev, test)
- ✅ Tool configurations preserved
- ✅ Newline at end of file

---

**Remember**: A well-formatted pyproject.toml enables developers to quickly understand dependencies, install optional features, and maintain the project with minimal confusion.
