# Feature Specification: Separate Spark Session Utilities Package

**Feature Branch**: `002-spark-session-utilities`
**Created**: 2025-11-22
**Status**: Draft
**Input**: User description: "i want spark session to be in a folder called spark-session-utilities and everything else in databricks-shared-utilities"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Minimal Dependency Installation (Priority: P1)

As a data engineer working on a simple Python utility that needs Spark session management but not other Databricks utilities, I want to install only the Spark session package so that my project has minimal dependencies and faster installation times.

**Why this priority**: This is the core value proposition - allowing users to install only what they need, reducing dependency bloat and potential conflicts.

**Independent Test**: Can be fully tested by creating a new Python project, installing only `spark-session-utilities`, creating a Spark session using the singleton factory, and verifying no other databricks-utils dependencies are required.

**Acceptance Scenarios**:

1. **Given** a new Python project with no dependencies, **When** I run `pip install spark-session-utilities`, **Then** only Spark session related dependencies (PySpark, PyYAML, Pydantic) are installed, not logging/observability/quality packages
2. **Given** a project with spark-session-utilities installed, **When** I import and use `SparkSessionFactory.get_spark()`, **Then** I can create and access Spark sessions without errors
3. **Given** a project needing only Spark utilities, **When** I run security scans or dependency audits, **Then** the dependency tree contains only Spark-related packages

---

### User Story 2 - Full Platform Installation (Priority: P2)

As a data engineer building a complete Databricks pipeline, I want to install databricks-shared-utilities and have it automatically include spark-session-utilities as a dependency, so that I get all utilities without managing multiple packages.

**Why this priority**: This maintains backward compatibility and convenience for users who need the full suite of utilities.

**Independent Test**: Can be fully tested by installing only `databricks-shared-utilities` and verifying that Spark session functionality is available without separate installation.

**Acceptance Scenarios**:

1. **Given** a new Python project, **When** I run `pip install databricks-shared-utilities`, **Then** both databricks-shared-utilities and spark-session-utilities are installed automatically
2. **Given** databricks-shared-utilities is installed, **When** I import `from databricks_utils.config import SparkSessionFactory`, **Then** the import works seamlessly (re-exported from spark-session-utilities)
3. **Given** existing code using the original combined package, **When** I upgrade to the separated version, **Then** all imports continue to work without code changes

---

### User Story 3 - Testing Framework Isolation (Priority: P3)

As a data engineer writing unit tests for transformations, I want to use pytest fixtures for Spark sessions in tests while production code uses the singleton pattern, and I want test fixtures to be in spark-session-utilities so test dependencies are minimal.

**Why this priority**: Keeps testing utilities close to the Spark session code, ensuring test isolation patterns are available wherever Spark sessions are used.

**Independent Test**: Can be fully tested by installing spark-session-utilities, importing pytest fixtures, and running tests that create isolated Spark sessions.

**Acceptance Scenarios**:

1. **Given** a test file using `spark_session` fixture, **When** tests are executed, **Then** each test receives an isolated Spark session that is cleaned up afterward
2. **Given** production pipeline code using `SparkSessionFactory.get_spark()`, **When** the pipeline runs, **Then** it uses the singleton pattern for performance
3. **Given** a project with spark-session-utilities installed, **When** I import testing fixtures, **Then** no additional dependencies beyond pytest are required

---

### User Story 4 - Unity Catalog Operations Only (Priority: P2)

As a data engineer working on Unity Catalog metadata management and governance, I want to install only databricks-uc-utilities without Spark dependencies, so that I can manage catalogs, schemas, and tables in lightweight scripts and tools.

**Why this priority**: Enables UC operations independently of Spark, supporting governance workflows, metadata tools, and administrative scripts that don't need Spark session overhead.

**Independent Test**: Can be fully tested by installing databricks-uc-utilities, creating catalog/schema/table operations, and verifying no Spark dependencies are pulled in.

**Acceptance Scenarios**:

1. **Given** a Python project with only databricks-uc-utilities installed, **When** I import UC operations, **Then** only UC-related dependencies (Databricks SDK, Pydantic) are installed
2. **Given** databricks-uc-utilities installed, **When** I perform catalog/schema/table operations, **Then** operations complete without requiring Spark session
3. **Given** a governance tool using UC utilities, **When** managing metadata and permissions, **Then** operations succeed with minimal dependency footprint

---

### User Story 5 - Automatic Workspace URL Derivation (Priority: P3)

As a data engineer configuring pipelines across multiple environments, I want workspace URLs to be automatically derived from environment_type so that I don't need to duplicate this information in config files and reduce configuration errors.

**Why this priority**: Convenience feature that reduces configuration boilerplate and ensures consistency between environment_type and workspace URLs.

**Independent Test**: Can be fully tested by creating EnvironmentConfig instances with only environment_type set (no workspace_host) and verifying workspace_url property returns correct URL.

**Acceptance Scenarios**:

1. **Given** a config with environment_type="local" and workspace_host=None, **When** I access config.workspace_url, **Then** it returns None (local Spark instance)
2. **Given** a config with environment_type="lab" and workspace_host=None, **When** I access config.workspace_url, **Then** it returns "https://skyscanner-dev.cloud.databricks.com"
3. **Given** a config with environment_type="dev" and workspace_host=None, **When** I access config.workspace_url, **Then** it returns "https://skyscanner-dev.cloud.databricks.com"
4. **Given** a config with environment_type="prod" and workspace_host=None, **When** I access config.workspace_url, **Then** it returns "https://skyscanner-prod.cloud.databricks.com"
5. **Given** a config with explicit workspace_host="https://custom.databricks.com", **When** I access config.workspace_url, **Then** it returns the explicit value regardless of environment_type
6. **Given** a config with environment_type=None and workspace_host=None, **When** I access config.workspace_url, **Then** it defaults to "https://skyscanner-dev.cloud.databricks.com"

---

### Edge Cases

- **Version conflicts**: Prevented via exact version pinning (==X.Y.Z) where databricks-shared-utilities depends on specific spark-session-utilities and databricks-uc-utilities versions
- **Backward compatibility**: Existing projects importing from databricks_utils.config continue working via re-exports from databricks-shared-utilities
- **Pinned old versions**: Projects with pinned combined package version remain functional; migration guide provides upgrade path
- **Simultaneous imports**: SparkSessionFactory imported from both packages resolves to same singleton instance due to re-export mechanism
- **Direct version mismatch**: pip/package manager resolves exact version constraint, preventing installation of incompatible combinations
- **Workspace URL precedence**: Explicit workspace_host always takes precedence over derived URL; derivation only occurs when workspace_host is None
- **Unknown environment types**: Any environment_type not in (local, lab, dev, prod) defaults to dev workspace URL

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create a new standalone package with PyPI name `spark-session-utilities` (hyphenated) and Python import name `spark_session_utilities` (underscored) containing only Spark session management code
- **FR-002**: spark-session-utilities MUST include SparkSessionFactory singleton implementation with get_spark() method
- **FR-003**: spark-session-utilities MUST include base configuration system with SparkConfig and EnvironmentConfig (without catalog field) and base ConfigLoader for loading Spark/environment configuration only
- **FR-004**: spark-session-utilities MUST include pytest fixtures for testing (spark_session, test_config, temp_tables, spark_session_long_running)
- **FR-005**: databricks-shared-utilities MUST declare spark-session-utilities as a required dependency in its package configuration
- **FR-006**: databricks-shared-utilities MUST re-export SparkSessionFactory and related classes to maintain backward compatibility
- **FR-007**: databricks-shared-utilities MUST re-export testing fixtures to maintain backward compatibility for existing test code
- **FR-008**: spark-session-utilities MUST have minimal dependencies (PySpark, Pydantic, PyYAML only)
- **FR-009**: databricks-shared-utilities MUST use exact version pinning (==X.Y.Z) for spark-session-utilities dependency to prevent version conflicts
- **FR-010**: Both packages MUST support Python 3.10 and 3.11
- **FR-011**: Documentation MUST clearly explain when to use each package independently vs together and MUST include Mermaid diagram in README visualizing three-package architecture and dependency relationships
- **FR-012**: Migration guide MUST be provided for users transitioning from the combined package; old combined package will not be published after separation (immediate cutover)
- **FR-013**: Package metadata MUST indicate spark-session-utilities as the source of truth for Spark session management
- **FR-014**: CI/CD workflows MUST be updated to build and test both packages independently
- **FR-015**: System MUST create databricks-uc-utilities package with PyPI name `databricks-uc-utilities` (hyphenated) and Python import name `databricks_uc_utilities` (underscored)
- **FR-016**: databricks-uc-utilities MUST include CatalogConfig for Unity Catalog configuration
- **FR-017**: databricks-uc-utilities MUST include catalog operations (create, read, update, delete, list catalogs)
- **FR-018**: databricks-uc-utilities MUST include schema operations (create, read, update, delete, list schemas within catalogs)
- **FR-019**: databricks-uc-utilities MUST include table operations (create, read, update, delete, list tables within schemas, table metadata management)
- **FR-020**: databricks-uc-utilities MUST include Unity Catalog helper utilities (permissions management, lineage tracking, metadata queries)
- **FR-021**: databricks-shared-utilities MUST depend on both spark-session-utilities AND databricks-uc-utilities with exact version pinning (==X.Y.Z)
- **FR-022**: databricks-shared-utilities MUST re-export classes from both spark-session-utilities and databricks-uc-utilities for backward compatibility
- **FR-023**: All three packages MUST support Python 3.10 and 3.11
- **FR-024**: CI/CD workflows MUST build packages in order: spark-session-utilities first, databricks-uc-utilities second, databricks-shared-utilities third
- **FR-025**: Package publishing MUST follow immediate cutover strategy with no deprecation period; existing users upgrade to new three-package structure
- **FR-026**: EnvironmentConfig in spark-session-utilities MUST provide a workspace_url property that derives workspace URL based on environment_type when workspace_host is None: local returns None, lab/dev return "https://skyscanner-dev.cloud.databricks.com", prod returns "https://skyscanner-prod.cloud.databricks.com"
- **FR-027**: Workspace URL derivation MUST honor explicit workspace_host values in config (precedence: explicit workspace_host > derived from environment_type > default to dev URL)
- **FR-028**: The workspace_url property MUST be implemented on EnvironmentConfig base class in spark-session-utilities and accessible via config.workspace_url

### Key Entities

- **spark-session-utilities package**: Standalone Python package containing Spark session management, configuration loading, and testing fixtures. Minimal dependencies (PySpark, Pydantic, PyYAML). Independent versioning and release cycle.

- **databricks-uc-utilities package**: Standalone Python package containing Unity Catalog operations (catalog/schema/table management), CatalogConfig, UC helper utilities (permissions, lineage, metadata). Minimal dependencies (Databricks SDK, Pydantic). Independent from Spark session utilities.

- **databricks-shared-utilities package**: Convenience aggregator package containing logging, data quality, observability, and error handling utilities. Depends on both spark-session-utilities AND databricks-uc-utilities with exact version pinning. Re-exports classes from both packages for backward compatibility and convenience.

- **SparkSessionFactory**: Singleton factory class managing Spark session lifecycle. Resides in spark-session-utilities. Thread-safe with get_spark() method.

- **Configuration Schemas**: Pydantic models for environment configuration. SparkConfig and base EnvironmentConfig (Spark-only) reside in spark-session-utilities. CatalogConfig resides in databricks-uc-utilities. Extended EnvironmentConfig combining both resides in databricks-shared-utilities. EnvironmentConfig includes workspace_url property that derives Databricks workspace URL from environment_type when workspace_host is not explicitly set.

- **ConfigLoader**: Configuration loading system split between packages. Base ConfigLoader in spark-session-utilities loads Spark/environment config only. CatalogConfig loader in databricks-uc-utilities handles UC configuration. Extended ConfigLoader in databricks-shared-utilities combines both.

- **Unity Catalog Operations**: Catalog, schema, and table management utilities reside in databricks-uc-utilities. Includes CRUD operations, permissions management, lineage tracking, and metadata queries for Unity Catalog three-level namespace.

- **Testing Fixtures**: Pytest fixtures for isolated testing (spark_session, test_config, temp_tables, spark_session_long_running). Reside in spark-session-utilities to stay with Spark session code.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can install spark-session-utilities independently with dependency tree size less than 50% of full databricks-shared-utilities package
- **SC-002**: Installation time for spark-session-utilities is under 30 seconds on standard development machines
- **SC-003**: All existing projects using databricks-shared-utilities continue to work without code changes after upgrade (100% backward compatibility)
- **SC-004**: Projects using only Spark session functionality reduce their dependency count by at least 5 packages compared to full installation
- **SC-005**: All three packages (spark-session-utilities, databricks-uc-utilities, databricks-shared-utilities) can be built, tested, and released independently with separate CI/CD pipelines
- **SC-006**: Documentation includes clear decision tree helping users choose which package(s) to install
- **SC-007**: Zero import errors when using re-exported classes from databricks-shared-utilities
- **SC-008**: Test execution time for Spark session tests is under 2 minutes when using function-scoped fixtures
- **SC-009**: Package separation reduces security vulnerability surface by at least 30% for minimal installations
- **SC-010**: README documentation includes Mermaid diagram clearly visualizing three-package architecture, dependencies, and typical usage patterns
- **SC-011**: Workspace URL derivation correctly maps all environment types (local/lab/dev/prod) with 100% accuracy in unit tests and successfully connects to Databricks workspaces in integration tests

## Assumptions

1. **Assumption 1**: Users will install packages based on needs: spark-session-utilities for Spark-only, databricks-uc-utilities for UC-only, or databricks-shared-utilities for full platform (includes both as dependencies).

2. **Assumption 2**: The configuration system is split: SparkConfig/base EnvironmentConfig in spark-session-utilities, CatalogConfig in databricks-uc-utilities, extended EnvironmentConfig in databricks-shared-utilities combining both.

3. **Assumption 3**: Package versioning will follow semantic versioning with exact version pinning (databricks-shared-utilities depends on spark-session-utilities==X.Y.Z and databricks-uc-utilities==X.Y.Z) to ensure compatibility.

4. **Assumption 4**: Existing projects have import statements like `from databricks_utils.config import SparkSessionFactory` which must continue working via re-exports.

5. **Assumption 5**: PyPI or internal package repository supports publishing multiple related packages with dependency relationships.

6. **Assumption 6**: The TESTING.md documentation should remain in spark-session-utilities since it primarily documents Spark session testing patterns.

7. **Assumption 7**: CI/CD workflows can be structured to build spark-session-utilities first, databricks-uc-utilities second, then databricks-shared-utilities third (depends on both).

8. **Assumption 8**: Local development will use relative/editable installs during development, production uses published packages.

## Clarifications

*Session 2025-11-22*:

- Initial specification created based on user request to separate Spark session utilities into dedicated package
- Assumed configuration system stays with Spark utilities since it's primarily Spark-focused
- Assumed backward compatibility is critical requirement based on existing implementation
- Q: CatalogConfig placement - should it stay in spark-session-utilities or move to databricks-shared-utilities with Unity Catalog operations? → A: Move CatalogConfig to databricks-shared-utilities (with Unity Catalog operations)
- Q: Version conflict resolution strategy - how should version conflicts between packages be handled? → A: Use version pinning: databricks-shared-utilities depends on exact spark-session-utilities version (e.g., ==0.2.0)
- Q: Package name convention - should it follow Python naming standards? → A: PyPI name uses hyphens (spark-session-utilities), import name uses underscores (spark_session_utilities)
- Q: Deprecation strategy - should there be a transition period or immediate cutover? → A: Immediate cutover: stop publishing old combined package, only publish separated packages
- Q: ConfigLoader dependency on CatalogConfig - how should ConfigLoader handle CatalogConfig moving to databricks-shared-utilities? → A: Split ConfigLoader: base in spark-session-utilities (Spark/Environment config only), extended in databricks-shared-utilities (adds Catalog support)
- Q: Three-package architecture - should Unity Catalog utilities be in a separate package? → A: 3 packages: spark-session-utilities + databricks-uc-utilities + databricks-shared-utilities (shared-utilities depends on both others for convenience)
- Q: Unity Catalog package contents - what should go into databricks-uc-utilities? → A: CatalogConfig, catalog operations, schema operations, table operations, UC helper utilities
- Q: Documentation requirement - should package architecture be visualized? → A: Include Mermaid diagram in README showing package relationships and dependencies

*Clarification Session 2025-11-22 (Workspace URL Derivation)*:

- Q: Where should the workspace URL derivation method be implemented? → A: As a method on EnvironmentConfig (in spark-session-utilities base class) that derives URL when workspace_host is None
- Q: If workspace_host is explicitly set in the config file but differs from the derived value for that environment_type, which should take precedence? → A: Explicit workspace_host wins (only derive when workspace_host is None/missing); default to dev workspace URL when both workspace_host and environment_type are None/invalid
- Q: Should the workspace URL derivation be exposed as a property or as a method? → A: Property (config.workspace_url) for cleaner API and transparent derivation
- Q: What level of testing is required for the workspace URL derivation feature? → A: Unit tests in spark-session-utilities (test all environment_type mappings) + integration tests verifying actual Databricks connectivity
- Q: Should the existing workspace_host field be deprecated in favor of the new workspace_url property, or should both coexist? → A: Keep both - workspace_host as config input field, workspace_url as derived property for public API