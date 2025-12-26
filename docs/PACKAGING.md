# Package Build Configuration

## Overview

This document explains how the `agentic-data-engineer` package includes Claude Code configurations, shared scripts, and documentation in the distribution.

## Included Files and Directories

The following files and directories are packaged with the distribution:

### 1. Claude Code Configuration (`.claude/`)

**Location**: `.claude/`

**Contents**:
- **Agents**: `.claude/agents/shared/*.md` - All custom agents
- **Skills**: `.claude/skills/*/SKILL.md` - All skills and their documentation
- **Commands**: `.claude/commands/*.md` - Custom slash commands
- **Settings**: `.claude/settings.local.json` - Local configuration

**Purpose**: Provides Claude Code integration including agents, skills, and commands that users can leverage when working with the package.

### 2. Project Constitution (`.specify/memory/constitution.md`)

**Location**: `.specify/memory/constitution.md`

**Contents**: Project principles, guidelines, and decision-making framework

**Purpose**: Ensures consistent decision-making and adherence to project standards across all development activities.

### 3. Shared Scripts (`scripts_shared/`)

**Location**: `scripts_shared/`

**Contents**:
- Shell scripts for common operations
- Utility scripts for project setup
- Helper scripts for development workflows

**Purpose**: Provides reusable scripts that can be used across multiple projects or by package consumers.

### 4. Shared Agent Usage Documentation (`shared_agents_usage_docs/`)

**Location**: `shared_agents_usage_docs/`

**Contents**:
- Usage guides for custom agents
- Examples and best practices
- Troubleshooting documentation

**Purpose**: Helps users understand how to use the custom agents effectively.

## Configuration Files

### pyproject.toml

The `pyproject.toml` file specifies what gets included in the package:

```toml
[tool.poetry]
packages = [
    { include = "agentic_data_engineer", from = "src" },
    { include = ".claude" },
    { include = "scripts_shared" },
    { include = "shared_agents_usage_docs" }
]

include = [
    ".specify/memory/constitution.md",
    ".claude/**/*.md",
    ".claude/**/*.json",
    "scripts_shared/**/*",
    "shared_agents_usage_docs/**/*.md"
]
```

**Explanation**:
- `packages`: Specifies directories to include as package modules
- `include`: Glob patterns for additional data files to include

### MANIFEST.in

The `MANIFEST.in` file provides additional control over included files:

```
# Include Claude Code configurations
recursive-include .claude *.md *.json

# Include Specify constitution
include .specify/memory/constitution.md

# Include shared scripts
recursive-include scripts_shared *

# Include shared agent usage documentation
recursive-include shared_agents_usage_docs *.md

# Exclude unwanted files
global-exclude *.py[cod]
global-exclude __pycache__
global-exclude .DS_Store
```

## Building the Package

### Basic Build

Build the package with:

```bash
make build
```

This will:
1. Verify virtual environment exists
2. Run `poetry build`
3. Create distribution files in `dist/`
4. Show a sample of included files

### Build with Verification

To build and verify all included files:

```bash
make build-verify
```

This will:
1. Build the package
2. Verify `.claude` files are included
3. Verify `scripts_shared` files are included
4. Verify `shared_agents_usage_docs` files are included
5. Verify `constitution.md` is included
6. Display counts and verification status

**Example Output**:
```
Building project...
✓ Build complete

Verifying package contents...

=== Package Contents Verification ===

Claude Code files:
  Files included: 42

Scripts shared:
  Files included: 8

Agent usage docs:
  Files included: 15

Constitution:
  ✓ Included

✓ Verification complete
```

## Verifying Package Contents Manually

### List All Files in Package

```bash
tar -tzf dist/agentic_data_engineer-*.tar.gz
```

### List Specific Files

**Claude Code files**:
```bash
tar -tzf dist/agentic_data_engineer-*.tar.gz | grep ".claude"
```

**Shared scripts**:
```bash
tar -tzf dist/agentic_data_engineer-*.tar.gz | grep "scripts_shared"
```

**Agent docs**:
```bash
tar -tzf dist/agentic_data_engineer-*.tar.gz | grep "shared_agents_usage_docs"
```

**Constitution**:
```bash
tar -tzf dist/agentic_data_engineer-*.tar.gz | grep "constitution.md"
```

### Extract and Inspect

```bash
# Extract to temporary directory
mkdir -p /tmp/package-inspect
cd /tmp/package-inspect
tar -xzf /path/to/agentic_data_engineer-*.tar.gz

# Inspect contents
tree agentic_data_engineer-*/
```

## Package Structure

After installation, the package structure will be:

```
site-packages/
├── agentic_data_engineer/          # Main package (from src/)
│   ├── __init__.py
│   └── ...
├── .claude/                         # Claude Code configuration
│   ├── agents/
│   │   └── shared/
│   │       ├── data-naming-agent.md
│   │       ├── pyproject-formatter-agent.md
│   │       ├── makefile-formatter-agent.md
│   │       └── ...
│   ├── skills/
│   │   ├── json-formatter-skill/
│   │   ├── mermaid-diagrams-skill/
│   │   └── ...
│   ├── commands/
│   │   └── ...
│   └── settings.local.json
├── scripts_shared/                  # Shared utility scripts
│   └── ...
├── shared_agents_usage_docs/        # Agent documentation
│   ├── README-pyproject-formatter.md
│   ├── README-makefile-formatter.md
│   └── ...
└── .specify/
    └── memory/
        └── constitution.md          # Project constitution
```

## Accessing Packaged Files at Runtime

### Python Code

```python
import importlib.resources
from pathlib import Path

# Access Claude agents
agents_path = importlib.resources.files('.claude') / 'agents' / 'shared'

# Access constitution
constitution_path = importlib.resources.files('.specify') / 'memory' / 'constitution.md'

# Read constitution content
with importlib.resources.files('.specify').joinpath('memory', 'constitution.md').open() as f:
    constitution = f.read()
```

### Python 3.9+ Alternative

```python
from importlib.resources import files

# Access packaged files
claude_agents = files('.claude').joinpath('agents', 'shared')
scripts = files('scripts_shared')
docs = files('shared_agents_usage_docs')
```

## Best Practices

### 1. Version Control

**Do track**:
- Source files in `.claude/`, `scripts_shared/`, `shared_agents_usage_docs/`
- `pyproject.toml` with package configuration
- `MANIFEST.in`

**Don't track**:
- `dist/` directory
- `build/` directory
- `*.egg-info` directories

Add to `.gitignore`:
```
dist/
build/
*.egg-info
```

### 2. Testing Packaging

Before releasing, always test the package locally:

```bash
# Build package
make build-verify

# Install in a test environment
python -m venv test-env
source test-env/bin/activate
pip install dist/agentic_data_engineer-*.whl

# Verify files are accessible
python -c "from importlib.resources import files; print(files('.claude'))"
```

### 3. Documentation

Update documentation when adding new packaged resources:
- Update this file
- Update README.md
- Update CHANGELOG.md

### 4. Size Considerations

Monitor package size:

```bash
ls -lh dist/
```

If package becomes too large:
- Consider moving large files to separate data packages
- Use Poetry's `exclude` to remove unnecessary files
- Compress large static resources

## Troubleshooting

### Files Not Included

**Problem**: Files aren't appearing in the built package

**Solutions**:
1. Check `pyproject.toml` `include` patterns
2. Verify `MANIFEST.in` patterns
3. Ensure files aren't in `.gitignore` (Poetry respects gitignore)
4. Run `make build-verify` to see what's included

### Permission Errors

**Problem**: Permission denied when installing package

**Solution**: Some files may have restrictive permissions. Ensure files have appropriate read permissions:

```bash
find .claude scripts_shared shared_agents_usage_docs -type f -exec chmod 644 {} \;
find .claude scripts_shared shared_agents_usage_docs -type d -exec chmod 755 {} \;
```

### Import Errors

**Problem**: Cannot import packaged resources

**Solution**: Use `importlib.resources` (Python 3.9+) instead of `__file__` or relative paths.

### Large Package Size

**Problem**: Package is too large

**Solution**:
1. Review included files: `tar -tzf dist/*.tar.gz | wc -l`
2. Add exclusions to `MANIFEST.in`
3. Consider splitting into multiple packages

## Related Documentation

- [Poetry Packaging Guide](https://python-poetry.org/docs/pyproject/#packages)
- [Python Packaging User Guide](https://packaging.python.org/)
- [importlib.resources Documentation](https://docs.python.org/3/library/importlib.resources.html)
- [MANIFEST.in Guide](https://packaging.python.org/guides/using-manifest-in/)

## Maintenance

When updating packaged resources:

1. Add new files to appropriate directories
2. Update `pyproject.toml` `include` patterns if needed
3. Update `MANIFEST.in` if needed
4. Run `make build-verify` to test
5. Update this documentation
6. Bump version in `pyproject.toml`
7. Update CHANGELOG.md
