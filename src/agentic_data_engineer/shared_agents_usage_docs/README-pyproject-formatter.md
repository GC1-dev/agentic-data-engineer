# PyProject Formatter Agent

## Overview

The `pyproject-formatter-agent` is a specialized Claude agent that standardizes `pyproject.toml` files according to Skyscanner data engineering conventions.

## Location

```
.claude/agents/shared/pyproject-formatter-agent.md
```

## Usage

### From Claude Code CLI

You can invoke this agent in several ways:

#### 1. Direct Task Tool Call

```python
# In your conversation with Claude
"Use the pyproject-formatter-agent to format my pyproject.toml"
```

#### 2. Via Agent Name Reference

```
"Format the pyproject.toml using the formatting agent"
```

#### 3. For Specific Files

```
"Use pyproject-formatter-agent to standardize /path/to/pyproject.toml"
```

## What It Does

The agent will:

1. ✅ **Read** your existing `pyproject.toml`
2. ✅ **Add** section separators with clear visual hierarchy
3. ✅ **Document** all dependencies with inline comments
4. ✅ **Organize** dependencies into standard groups (cli, mcp, dev, test)
5. ✅ **Normalize** version constraints (converts `^X.Y.Z` to `>=X.Y.Z`)
6. ✅ **Add** missing metadata (license, repository, homepage)
7. ✅ **Preserve** tool configurations (ruff, pytest, etc.)
8. ✅ **Mark** optional groups correctly
9. ✅ **Group** internal Skyscanner dependencies

## Standard Template Structure

The agent formats files according to this structure:

```toml
[tool.poetry]
# Metadata fields

# Optional dependency groups documentation comment

# ============================================================================
# Package Sources
# ============================================================================

# ============================================================================
# Dependencies
# ============================================================================

# ============================================================================
# CLI Dependencies
# ============================================================================

# ============================================================================
# MCP Dependencies
# ============================================================================

# ============================================================================
# Dev Dependencies
# ============================================================================

# ============================================================================
# Test Dependencies
# ============================================================================

# ============================================================================
# Build System
# ============================================================================

# ============================================================================
# Tool Configuration
# ============================================================================
```

## Examples

### Example 1: Format New Project

**Input**:
```toml
[tool.poetry]
name = "my-project"
version = "0.1.0"
description = "My data project"

[tool.poetry.dependencies]
python = "^3.10"
pyspark = "^3.4.0"
```

**Output**: Fully structured file with:
- Added metadata (license, repository, homepage)
- Section separators
- Inline documentation for all dependencies
- Standardized version constraints
- Optional group headers

### Example 2: Add Documentation

**Before**:
```toml
[tool.poetry.dependencies]
pyspark = ">=3.4.0"
pandas = ">=2.0.0"
```

**After**:
```toml
[tool.poetry.dependencies]
pyspark = ">=3.4.0"  # Apache Spark for distributed data processing
pandas = ">=2.0.0"  # Data manipulation and analysis
```

### Example 3: Organize Groups

**Before**:
```toml
[tool.poetry.dependencies]
python = "^3.10"
databricks-sdk = ">=0.18.0"
pytest = ">=7.0.0"
ruff = ">=0.14.7"
```

**After**: Dependencies properly organized into:
- Core dependencies
- CLI group (databricks-sdk)
- Dev group (ruff)
- Test group (pytest)

## Success Criteria

A properly formatted file will have:

- ✅ Clear section separators
- ✅ Complete metadata fields
- ✅ Header comment with optional groups
- ✅ All dependencies documented
- ✅ Consistent version constraints
- ✅ Proper optional group declarations
- ✅ Internal dependencies grouped
- ✅ Tool configurations preserved

## Common Use Cases

1. **New Project Setup**: Format initial pyproject.toml
2. **Team Standardization**: Ensure all projects follow same format
3. **Documentation**: Add missing inline comments
4. **Refactoring**: Reorganize messy dependency lists
5. **Template Creation**: Prepare cookiecutter templates
6. **Code Review**: Verify formatting standards

## Agent Configuration

- **Model**: Haiku (fast, cost-effective)
- **Type**: Shared agent (available to all projects)
- **Context**: Full pyproject.toml formatting knowledge

## Tips

- The agent preserves all tool configurations ([tool.ruff], etc.)
- Version pins with rationale are maintained
- Custom dependency groups are kept
- Internal Skyscanner packages are automatically grouped
- The agent uses `>=` version constraints by default

## Related Documentation

- [Poetry Documentation](https://python-poetry.org/docs/)
- [Skyscanner Data Engineering Standards](...)
- [Dependency Management Best Practices](...)

## Maintenance

To update the agent's behavior:

1. Edit `.claude/agents/shared/pyproject-formatter-agent.md`
2. Modify the template or rules sections
3. Test with sample pyproject.toml files
4. Update this README if needed
