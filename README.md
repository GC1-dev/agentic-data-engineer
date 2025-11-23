# AI-Native Data Engineering Process

A multi-package monorepo for data engineering utilities with independent packages for data quality, observability, Spark session management, and Databricks integration.

## Packages

This repository contains 4 independent Python packages:

### 1. data-quality-utilities (v1.0.0)
Standalone data quality validation and profiling for PySpark DataFrames.

**Features**:
- Declarative validation rules (completeness, uniqueness, freshness, schema, pattern, range)
- Statistical data profiling with sampling support
- Quality gates and anomaly detection

**Installation**:
```bash
pip install data-quality-utilities==1.0.0
```

[→ Documentation](./data-quality-utilities/README.md)

### 2. data-observability-utilities (v1.0.0)
Standalone Monte Carlo observability integration for data monitoring.

**Features**:
- Monte Carlo SDK wrapper
- High-level integration helpers
- Configuration management with credential handling

**Installation**:
```bash
pip install data-observability-utilities==1.0.0
```

[→ Documentation](./data-observability-utilities/README.md)

### 3. spark-session-utilities (v1.0.0)
Spark session management, configuration, and logging utilities.

**Features**:
- Spark session lifecycle management
- Configuration presets (Databricks, local, cluster)
- Structured logging with context support
- Delta Lake integration

**Installation**:
```bash
pip install spark-session-utilities==1.0.0
```

[→ Documentation](./spark-session-utilities/README.md)

### 4. databricks-shared-utilities (v0.3.0)
Core utilities for Databricks with Unity Catalog integration and testing support.

**Features**:
- Unity Catalog operations (via databricks-uc-utilities)
- Testing utilities and fixtures
- Error handling (retry logic, exponential backoff)

**Installation**:
```bash
pip install databricks-shared-utilities==0.3.0
```

[→ Documentation](./databricks-shared-utilities/README.md)

## Quick Start

### Data Quality Validation
```python
from data_quality_utilities import ValidationRule, ValidationRuleset

ruleset = ValidationRuleset(name="user_validation")
ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=False))
ruleset.add_rule(ValidationRule.uniqueness("email"))

result = ruleset.validate(df)
if result.overall_status == Status.FAILED:
    print(f"Validation failed: {result.failed_rules} failures")
```

### Data Profiling
```python
from data_quality_utilities import DataProfiler

profiler = DataProfiler(sample_size=100000)
profile = profiler.profile(df)

print(f"Rows: {profile.row_count:,}")
print(f"Null rate: {profile.get_column_profile('user_id').null_percentage}%")
```

### Spark Session Management
```python
from spark_session_utilities import SparkConfig

config = SparkConfig.for_databricks().enable_delta()
spark = config.create_session(app_name="ETL Pipeline")
```

## Migration from databricks-shared-utilities 0.2.0

If you're migrating from the monolithic `databricks-shared-utilities` 0.2.0:

**Only import paths change** - all class names, method signatures, and parameters remain identical.

See [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for step-by-step instructions.

## Documentation

- [Migration Guide](./MIGRATION_GUIDE.md) - Step-by-step migration from databricks-shared-utilities 0.2.0
- [Changelog](./CHANGELOG.md) - Version history and breaking changes
- [Feature Specifications](./specs/) - Detailed feature specs and design documents

### API Contracts
- [data-quality-utilities API](./specs/005-separate-utilities/contracts/data-quality-utilities-api.md)
- [data-observability-utilities API](./specs/005-separate-utilities/contracts/data-observability-utilities-api.md)
- [spark-session-utilities API](./specs/005-separate-utilities/contracts/spark-session-utilities-api.md)

## Repository Structure

```
.
├── data-quality-utilities/          # Data quality validation package
├── data-observability-utilities/    # Monte Carlo observability package
├── spark-session-utilities/         # Spark session management package
├── databricks-shared-utilities/     # Core Databricks utilities
├── databricks-uc-utilities/         # Unity Catalog utilities
├── specs/                           # Feature specifications
├── MIGRATION_GUIDE.md              # Migration instructions
└── CHANGELOG.md                    # Version history
```

## Development

Each package is independently developed and versioned:

```bash
# Install package in development mode
cd data-quality-utilities/
pip install -e ".[dev]"

# Run tests
pytest tests/

# Run linting
black src/ tests/
ruff src/ tests/
mypy src/
```

### MCP Server Setup (Claude Code Integration)

This repository includes a Model Context Protocol (MCP) server via the `databricks-utils` submodule for integration with Claude Code. The main project now includes MCP dependencies for enhanced AI integration capabilities.

**Setup:**

```bash
# Install main project dependencies (includes mcp and pydantic)
make setup

# Install MCP dependencies for databricks-utils submodule
make setup-mcp

# Or manually:
poetry install --no-root
poetry -C databricks-utils install --with mcp
```

**Configuration:**

The MCP server is configured in `.mcp.json`. Ensure the following environment variables are set:

```bash
export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
export DATABRICKS_TOKEN="your-personal-access-token"
export DATABRICKS_WAREHOUSE_ID="your-warehouse-id"
```

Once configured, Claude Code will have access to Unity Catalog operations and SQL query execution capabilities through the MCP server.

## License

MIT License - see LICENSE file for details.
