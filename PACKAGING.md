# Package Build and Distribution Guide

This guide explains how to package your Skyscanner internal dependencies separately as part of the build process.

## Overview

Your project includes these internal Skyscanner dependencies:
- `skyscanner-databricks-utils` (>=0.2.2) - Databricks utilities and helpers MCP integration
- `skyscanner-data-knowledge-base-mcp` (>=1.0.7) - Data knowledge base MCP integration
- `skyscanner-spark-session-utils` (>=1.0.1) - Spark session management utilities
- `skyscanner-data-shared-utils` (>=1.0.2) - Shared data engineering utilities

## Build Commands

### 1. Build Fat Distribution (All Dependencies Together)

```bash
make build-fat
```

This creates a `fatdist/` directory with ALL dependencies as separate wheel files (~100 wheels):
- ✅ Simple to build and deploy
- ✅ All dependencies included
- ❌ No organization by package type

**Output:** `fatdist/*.whl` (all packages in one directory)

### 2. Build Organized Distribution (Separated by Type)

```bash
make build-organized
```

This builds everything AND organizes packages into categories:

```
fatdist/
├── internal/          # Skyscanner internal packages (5 wheels)
│   ├── skyscanner_databricks_utils-*.whl
│   ├── skyscanner_data_knowledge_base_mcp-*.whl
│   ├── skyscanner_spark_session_utils-*.whl
│   ├── skyscanner_data_shared_utils-*.whl
│   └── skyscanner_ip_ranges-*.whl
├── external/          # External dependencies (94 wheels)
│   ├── pyspark-*.whl
│   ├── pydantic-*.whl
│   └── ... (all other packages)
└── project/           # Your main project (1 wheel)
    └── skyscanner_agentic_data_engineer-*.whl
```

**Use this when:** You need fine-grained control over deployment

### 3. Organize Existing Build

If you already ran `make build-fat`, organize packages afterwards:

```bash
make organize-packages
```

This reorganizes an existing `fatdist/` into the structure above.

## Deployment Options

### Option 1: Upload All at Once (Simplest)

```bash
# Build
make build-fat

# Upload to Databricks
databricks fs cp fatdist/*.whl dbfs:/libs/agentic-data-engineer/ --recursive

# Install in Databricks
%pip install /dbfs/libs/agentic-data-engineer/*.whl
```

### Option 2: Staged Upload (Organized)

```bash
# Build organized
make build-organized

# Upload separately
databricks fs cp fatdist/internal/*.whl dbfs:/libs/internal/ --recursive
databricks fs cp fatdist/external/*.whl dbfs:/libs/external/ --recursive
databricks fs cp fatdist/project/*.whl dbfs:/libs/projects/ --recursive

# Install in order (if needed)
%pip install /dbfs/libs/internal/*.whl
%pip install /dbfs/libs/external/*.whl
%pip install /dbfs/libs/projects/*.whl
```

### Option 3: Selective Deployment

Deploy only what changed:

```bash
# Build organized
make build-organized

# Upload only internal dependencies (if they changed)
databricks fs cp fatdist/internal/*.whl dbfs:/libs/internal/ --recursive --overwrite

# Or upload only your project
databricks fs cp fatdist/project/*.whl dbfs:/libs/projects/ --recursive --overwrite
```

## Package Counts

After running `make build-organized`:
- **Internal dependencies:** 5 packages (~285 KB)
- **External dependencies:** 94 packages (~380 MB)
- **Project package:** 1 package (~296 KB)
- **Total:** 100 wheel files

## How It Works

### `build-fat-dist.sh`

1. Exports all dependencies from Poetry to `requirements.txt`
2. Uses `pip wheel` to download all dependencies as wheels
3. Builds your project wheel with `poetry build`
4. Copies everything to `fatdist/`

**Fixed Issues:**
- ✅ No longer requires `poetry-plugin-export`
- ✅ Falls back to `pip freeze` if export plugin missing
- ✅ Handles authentication via Poetry's configured credentials

### `organize-packages.sh`

1. Separates Skyscanner packages (prefix: `skyscanner_*`)
2. Moves your project package to `project/`
3. Moves all other dependencies to `external/`
4. Provides deployment examples

## Makefile Targets Reference

| Target | Description |
|--------|-------------|
| `make build-fat` | Build all dependencies as wheels in one directory |
| `make organize-packages` | Organize existing fatdist/ into categories |
| `make build-organized` | Build + organize in one command |
| `make clean` | Remove all build artifacts including fatdist/ |
| `make build` | Build only your project (no dependencies) |
| `make build-verify` | Build + verify package contents |

## Common Workflows

### Development Iteration

```bash
# Make code changes...
make clean
make build-organized
databricks fs cp fatdist/project/*.whl dbfs:/libs/projects/ --overwrite
```

### Full Release

```bash
make clean
make build-organized
databricks fs cp fatdist/ dbfs:/libs/v1.0.0/ --recursive
```

### Update Internal Dependencies Only

```bash
# Update versions in pyproject.toml...
poetry lock --no-update  # Update lock file
make clean
make build-organized
databricks fs cp fatdist/internal/*.whl dbfs:/libs/internal/ --overwrite
```

## Troubleshooting

### "poetry export: command not found"

**Fixed!** The build script automatically falls back to `pip freeze` if the export plugin isn't installed.

### Authentication Issues

The build uses Poetry's configured authentication. Ensure you're authenticated:

```bash
poetry config http-basic.skyscanner-artifactory USERNAME PASSWORD
```

### Missing Packages

If packages are missing from `fatdist/`, check:
1. `requirements.txt` - generated during build
2. Poetry lock file is up to date: `poetry lock`
3. All dependency groups are installed: `poetry install --with cli,mcp,dev,test`

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
- name: Build organized distribution
  run: make build-organized

- name: Upload to Databricks
  run: |
    databricks fs cp fatdist/internal/*.whl dbfs:/libs/internal/ --recursive
    databricks fs cp fatdist/external/*.whl dbfs:/libs/external/ --recursive
    databricks fs cp fatdist/project/*.whl dbfs:/libs/projects/ --recursive
```

---

**Last Updated:** 2026-01-02
