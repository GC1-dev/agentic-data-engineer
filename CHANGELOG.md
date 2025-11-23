# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-11-22

### Added - New Packages

#### data-quality-utilities 1.0.0
- **INITIAL RELEASE**: Standalone data quality validation and profiling package
- Validation rules: completeness, uniqueness, freshness, schema, pattern, range
- Data profiling with sampling support (reservoir, systematic, random)
- Statistical profiles for numeric, string, and timestamp columns
- Quality gates and anomaly detection (future features)
- Zero dependencies on databricks-shared-utilities or observability packages
- Full API documentation and migration guides

#### data-observability-utilities 1.0.0
- **INITIAL RELEASE**: Standalone Monte Carlo observability integration package
- Monte Carlo client wrapper for SDK operations
- High-level integration helpers for monitoring setup
- Configuration management with credential handling
- Zero dependencies on databricks-shared-utilities or data-quality packages
- Full API documentation and migration guides

#### spark-session-utilities 1.0.0
- **UPDATED RELEASE**: Spark session management, configuration, and logging
- Added logging module with structured logging support
- Added SparkSessionManager for high-level session lifecycle management
- Spark configuration presets (Databricks, local, cluster)
- Delta Lake integration support
- Full API documentation

### Changed - databricks-shared-utilities 0.3.0

#### Breaking Changes
- **REMOVED**: `databricks_utils.data_quality.*` - migrated to data-quality-utilities
- **REMOVED**: `databricks_utils.observability.*` - migrated to data-observability-utilities
- **REMOVED**: `databricks_utils.logging.*` - migrated to spark-session-utilities
- **REMOVED**: `databricks_utils.config.spark_session` - migrated to spark-session-utilities

#### Remaining Features
- Unity Catalog integration (via databricks-uc-utilities)
- Testing utilities and fixtures
- Error handling (retry logic, exponential backoff)
- Updated to depend on spark-session-utilities 1.0.0

#### Migration
- See [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for step-by-step instructions
- Only import paths change - no API breaking changes
- Package size reduced by ~50%

## [0.2.0] - 2025-11-22 (Previous Release)

### Added
- Data quality validation framework
- Data profiling capabilities
- Spark session management
- Unity Catalog integration
- Logging utilities

---

## Migration Summary

| Package | Old Version | New Version | Status |
|---------|-------------|-------------|--------|
| data-quality-utilities | N/A | 1.0.0 | ✅ New |
| data-observability-utilities | N/A | 1.0.0 | ✅ New |
| spark-session-utilities | 0.2.0 | 1.0.0 | ✅ Updated |
| databricks-shared-utilities | 0.2.0 | 0.3.0 | ⚠️ Breaking |

## Installation

### New Packages (1.0.0)
```bash
pip install data-quality-utilities==1.0.0
pip install data-observability-utilities==1.0.0
pip install spark-session-utilities==1.0.0
```

### Updated Package (0.3.0)
```bash
pip install databricks-shared-utilities==0.3.0
```

## Support

- Documentation: See each package's README.md
- Migration Guide: [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
- API Contracts: See `specs/005-separate-utilities/contracts/`
- Issues: GitHub issues with `migration` tag
