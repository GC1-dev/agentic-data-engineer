# Feature Specification: Separate Data Quality and Observability Utilities

**Feature Branch**: `005-separate-utilities`
**Created**: 2025-11-22
**Status**: Draft
**Input**: User description: "i want data_quality_utilites and data_observabilit into 2 different directories. Not part of databricks utilities"

## Clarifications

### Session 2025-11-22

- Q: Where should Spark logging functionality reside after package separation? → A: Spark logging goes to spark-session-utilities
- Q: After separating data quality, observability, and Spark logging, what should happen to the databricks-shared-utilities package itself? → A: Keep databricks-shared-utilities with remaining core utilities (Unity Catalog, testing, general config)
- Q: What should be the directory structure for the separated packages in the repository? → A: Create 3 new top-level directories (data-quality-utilities/, data-observability-utilities/, spark-session-utilities/)
- Q: How should existing tests be migrated to the new package structures? → A: Rewrite tests from scratch using new package structure
- Q: How should version numbers be managed for the new packages? → A: Each package uses its own versioning starting at 1.0.0 (independent versioning)
- Q: Where should Spark session management functionality reside? → A: Move Spark session management to spark-session-utilities (co-locate with Spark logging)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Independent Data Quality Package Structure (Priority: P1)

As a data engineer working on data quality validation, I want the data quality utilities to exist as a standalone package separate from databricks utilities, so that I can install and use only the data quality functionality without pulling in unnecessary dependencies from other observability or databricks-specific packages.

**Why this priority**: Core restructuring that enables independent development, testing, and deployment of data quality capabilities. This is the foundation for modular architecture and allows teams to adopt only the functionality they need.

**Independent Test**: Can be fully tested by creating a new Python project, installing only the data-quality-utilities package, importing validation rules and profiling classes, and verifying that no databricks-specific or observability dependencies are required or imported.

**Acceptance Scenarios**:

1. **Given** a fresh Python environment, **When** I install the data-quality-utilities package, **Then** only data quality dependencies are installed (no observability or databricks-specific packages)
2. **Given** the data-quality-utilities package is installed, **When** I import validation and profiling classes, **Then** imports succeed without requiring databricks-shared-utilities
3. **Given** existing data quality code in databricks-shared-utilities, **When** I migrate to the new structure, **Then** all validation rules, profiling, quality gates, and anomaly detection functionality is preserved
4. **Given** the new package structure, **When** I run existing data quality tests, **Then** all tests pass without modification
5. **Given** the separated packages, **When** I create a requirements.txt with only data-quality-utilities, **Then** the package dependency tree excludes observability and databricks utilities

---

### User Story 2 - Independent Data Observability Package Structure (Priority: P2)

As a data operations engineer working on observability and monitoring, I want the data observability utilities to exist as a standalone package separate from databricks utilities, so that I can integrate Monte Carlo observability features without depending on data quality validation or other databricks-specific functionality.

**Why this priority**: Enables independent observability adoption and development. Teams focused on monitoring and alerting can use observability utilities without data quality features, reducing cognitive load and dependency footprint.

**Independent Test**: Can be fully tested by creating a new Python project, installing only the data-observability-utilities package, importing Monte Carlo integration classes, and verifying that no data quality or databricks-specific dependencies are required.

**Acceptance Scenarios**:

1. **Given** a fresh Python environment, **When** I install the data-observability-utilities package, **Then** only observability dependencies (Monte Carlo SDK, etc.) are installed
2. **Given** the data-observability-utilities package is installed, **When** I import Monte Carlo integration classes, **Then** imports succeed without requiring databricks-shared-utilities or data-quality-utilities
3. **Given** existing observability code in databricks-shared-utilities, **When** I migrate to the new structure, **Then** all Monte Carlo integration functionality is preserved
4. **Given** the new package structure, **When** I run existing observability tests, **Then** all tests pass without modification
5. **Given** the separated packages, **When** I examine the dependency graph, **Then** data-observability-utilities does not depend on data-quality-utilities

---

### Edge Cases

- How does the system handle users who have pinned specific versions of databricks-shared-utilities that include the old structure? Users will need to update their dependencies to use the new standalone packages.
- What if users have customized or extended the data quality/observability classes in their forks? Documentation should explain how to migrate custom extensions to the new package structure.
- How are shared dependencies (like Spark, Pydantic) managed across the three packages? Each package should declare its own dependencies explicitly to avoid version conflicts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create three new top-level directories (data-quality-utilities/, data-observability-utilities/, spark-session-utilities/) at repository root
- **FR-002**: System MUST create a new standalone package named `data-quality-utilities` containing all data quality validation, profiling, quality gates, and anomaly detection functionality
- **FR-003**: System MUST create a new standalone package named `data-observability-utilities` containing all Monte Carlo integration and observability functionality
- **FR-004**: System MUST preserve all existing functionality when migrating code from databricks-shared-utilities to the new packages (no feature loss)
- **FR-005**: System MUST maintain identical public APIs in the new packages (same class names, method signatures, parameters, and return types)
- **FR-006**: System MUST ensure data-quality-utilities has no dependencies on databricks-shared-utilities or data-observability-utilities
- **FR-007**: System MUST ensure data-observability-utilities has no dependencies on databricks-shared-utilities or data-quality-utilities
- **FR-008**: System MUST provide separate pyproject.toml/setup.py configuration for each package (data-quality-utilities, data-observability-utilities, spark-session-utilities)
- **FR-009**: System MUST provide separate test suites for each package that can run independently (tests rewritten from scratch for new package structure)
- **FR-010**: System MUST update all internal imports within data quality code to reference data_quality_utilities package
- **FR-011**: System MUST update all internal imports within observability code to reference data_observability_utilities package
- **FR-012**: System MUST maintain separate README.md files for each package explaining installation and usage
- **FR-013**: System MUST remove data quality and observability modules from databricks-shared-utilities after code is migrated to new packages
- **FR-014**: System MUST move Spark logging functionality to spark-session-utilities package (not to data-quality-utilities or data-observability-utilities)
- **FR-015**: System MUST update databricks-shared-utilities documentation to reference the new standalone packages for data quality and observability functionality
- **FR-016**: Users MUST be able to install data-quality-utilities independently without installing data-observability-utilities or databricks-shared-utilities
- **FR-017**: Users MUST be able to install data-observability-utilities independently without installing data-quality-utilities or databricks-shared-utilities

### Key Entities

- **data-quality-utilities Package**: Standalone Python package containing validation rules, data profiling, quality gates, anomaly detection, and baseline management. Key modules: rules, validator, profiler, gates, anomaly, baseline, reports, templates.
- **data-observability-utilities Package**: Standalone Python package containing Monte Carlo integration, observability configuration, and monitoring utilities. Key modules: monte_carlo client/integration, configuration management, observability helpers.
- **spark-session-utilities Package**: Standalone Python package containing Spark session management, Spark configuration, and Spark-related logging functionality. All Spark-specific utilities consolidated in this package.
- **databricks-shared-utilities Package**: Remaining shared utilities (Unity Catalog operations, general configuration, testing utilities). Data quality, observability, Spark session management, and Spark logging modules will be removed from this package.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Data engineers can install and use data-quality-utilities package independently, with installation completing in under 30 seconds and requiring fewer than 10 dependencies
- **SC-002**: Data operations engineers can install and use data-observability-utilities package independently, with no transitive dependencies on data quality or databricks utilities
- **SC-003**: All rewritten unit tests for data quality utilities achieve equivalent or better code coverage compared to original tests in databricks-shared-utilities
- **SC-004**: All rewritten unit tests for observability utilities achieve equivalent or better code coverage compared to original tests in databricks-shared-utilities
- **SC-005**: Package size for data-quality-utilities is at least 40% smaller than databricks-shared-utilities (due to removal of observability and other utilities)
- **SC-006**: Package size for data-observability-utilities is at least 60% smaller than databricks-shared-utilities (due to removal of data quality and other utilities)
- **SC-007**: Migration documentation allows users to update imports in existing codebases in under 15 minutes for a typical project
- **SC-008**: New users can get started with either data-quality-utilities or data-observability-utilities without learning about the other package, reducing onboarding time by 50%
- **SC-009**: Databricks-shared-utilities package size decreases by at least 50% after removing data quality and observability modules

## Assumptions & Dependencies *(mandatory)*

### Assumptions

- Existing databricks-shared-utilities users will need to explicitly switch to the new standalone packages and update their imports
- Data quality utilities do not have hard dependencies on Databricks-specific features (Unity Catalog, DBFS) and can operate with standard PySpark
- Observability utilities primarily integrate with Monte Carlo and do not require data quality validation functionality
- Users are willing to update import statements as part of the migration to new packages
- This is a clean break migration - no backward compatibility support will be provided

### Dependencies

- **PySpark**: Required by data-quality-utilities for DataFrame operations (existing dependency)
- **Pydantic**: Required by data-quality-utilities for rule validation and configuration (existing dependency)
- **scipy/numpy**: Required by data-quality-utilities for statistical anomaly detection (existing dependency)
- **Monte Carlo SDK**: Required by data-observability-utilities for Monte Carlo integration (existing dependency)
- **Python packaging tools**: Required for creating and publishing separate packages (setuptools, build, twine)

### External Integrations

- None required - packages operate independently within Databricks or local PySpark environments

## Out of Scope *(optional)*

- Renaming classes or changing public APIs (maintain exact compatibility with existing databricks-shared-utilities implementations)
- Merging data quality and observability functionality (goal is separation, not integration)
- Creating new data quality or observability features beyond what exists in databricks-shared-utilities
- Migrating existing user codebases automatically (users are responsible for updating imports)
- Publishing packages to PyPI (focus on structure; publishing is a separate deployment concern)
- Breaking changes to existing databricks-shared-utilities core functionality (Spark session, Unity Catalog, logging)
- Providing backward compatibility for old import paths (clean break approach - no import redirection)

## Technical Constraints *(optional)*

- Package names must follow Python naming conventions (underscores, lowercase)
- Each package must have independent versioning starting at 1.0.0 and independent release cycles
- Data quality and observability packages must not create circular dependencies
- Shared test fixtures and utilities may need to be duplicated or extracted into a separate test-helpers package
- This is a breaking change for existing users - they must update their imports to use the new packages

## Security & Privacy Considerations *(optional)*

- Data quality validation reports must not expose sensitive data in logs or error messages (existing behavior preserved)
- Observability utilities must not log or transmit sensitive credentials or API keys (existing behavior preserved)
- Package dependencies should be regularly audited for security vulnerabilities (existing practice continues)
