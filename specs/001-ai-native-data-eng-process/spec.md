# Feature Specification: AI-Native Data Engineering Process for Databricks

**Feature Branch**: `001-ai-native-data-eng-process`
**Created**: 2025-11-21
**Status**: Draft
**Input**: User description: "I want to design an AI-Native development process for data engineering in PySpark on Databricks/Unity Catalog. I have a repository called Claude Code – Data Engineer, which uses Databricks utilities (repo) and includes several agents (coding, testing, data-profiling, etc.). I want guidance on how to structure the overall project so that: The Spark session is created dynamically based on the environment type (local / lab / dev / prod). Shared utilities can be reused by multiple teams. Project structure supports modularity, versioning, and AI-assisted workflows."

## Clarifications

### Session 2025-11-21

- Q: Spark Session Lifecycle Ownership - Where does the Spark session instance sit during pipeline execution? → A: Shared utilities singleton - SparkSessionFactory creates and maintains a single global SparkSession instance that all pipeline code accesses via utility methods
- Q: Project Initialization Mechanism - Should the system use cookiecutter templates, or can an AI agent create templates? → A: AI agent creates and maintains templates - AI agent both uses AND automatically updates/creates cookiecutter templates based on learnings from usage patterns
- Q: Project Directory Structure - How should pipelines, dashboards, and other components be organized relative to src/? → A: All major components are in separate top-level directories parallel to src/ (project root contains: src/, pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, tests/, config/, docs-agentic-data-engineer/)

### Session 2025-11-22

- Q: Spark Session Pattern for Testing - Should Spark session use fixture pattern for tests or singleton everywhere? → A: Pytest fixture for testing only, singleton remains for production - Tests use pytest fixtures for isolation and cleanup, production pipelines use singleton for performance and consistency

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initialize New Data Pipeline Project (Priority: P1)

A data engineer starts a new data pipeline project and needs to quickly scaffold a standardized project structure with all necessary components configured for their environment.

**Why this priority**: This is the foundation for all other workflows. Without a consistent project initialization process, teams cannot benefit from standardized tooling, agents, or shared utilities. This delivers immediate value by reducing project setup time from days to minutes.

**Independent Test**: Can be fully tested by running a project initialization command and verifying that all directories, configuration files, and base utilities are created with correct structure. Delivers a working project skeleton ready for development.

**Acceptance Scenarios**:

1. **Given** a data engineer wants to start a new pipeline project, **When** they invoke the template agent with project requirements in natural language, **Then** the agent either selects an existing cookiecutter template or generates a new one, creating a complete project structure with top-level directories: src/ (utilities and helpers), pipelines/ (data transformations), dashboards/ (visualization), databricks_apps/ (Databricks applications), monte_carlo/ (observability config), data_validation/ (quality rules), tests/, config/, and docs-agentic-data-engineer/
2. **Given** a project is initialized for a specific environment (dev/prod), **When** the initialization completes, **Then** environment-specific configuration files are created with appropriate Spark session settings and Unity Catalog references
3. **Given** a team wants to use shared utilities, **When** they initialize a project, **Then** the system automatically includes references to organization-wide shared utility libraries and agent configurations
4. **Given** multiple projects have been initialized over time, **When** the template agent analyzes usage patterns, **Then** it automatically updates existing cookiecutter templates or creates new template variants to reflect emerging best practices

---

### User Story 2 - Develop Data Transformation with AI Assistance (Priority: P1)

A data engineer writes a new data transformation pipeline using AI agents that assist with code generation, testing, and quality checks, while ensuring the code follows organizational standards.

**Why this priority**: This is the core development workflow that delivers the "AI-Native" promise. It directly impacts developer productivity and code quality, representing the primary value proposition of the entire process.

**Independent Test**: Can be tested by having a developer describe a transformation requirement, using AI agents to generate code, and verifying that the generated code passes quality checks and executes successfully against sample data.

**Acceptance Scenarios**:

1. **Given** a data engineer needs to implement a bronze-to-silver transformation, **When** they describe the transformation logic to the coding agent, **Then** the agent generates PySpark code in the pipelines/ directory that follows medallion architecture patterns and includes proper error handling
2. **Given** generated transformation code exists in pipelines/, **When** the testing agent is invoked, **Then** it automatically creates unit tests in the tests/ directory that cover common scenarios and edge cases
3. **Given** a data pipeline is being developed, **When** the data profiling agent analyzes source data, **Then** it generates data quality rules in the data_validation/ directory appropriate for the data characteristics
4. **Given** transformation code is written, **When** the code quality agent reviews it, **Then** it validates adherence to organizational coding standards, identifies potential performance issues, and suggests optimizations

---

### User Story 3 - Execute Pipeline Across Environments (Priority: P2)

A data engineer runs their pipeline across different environments (local for testing, dev for integration, prod for deployment) with environment-specific configurations automatically applied.

**Why this priority**: Critical for testing and deployment workflows, but depends on having code to execute (P1 stories). Enables reliable promotion path from development to production.

**Independent Test**: Can be tested by executing a simple pipeline in each environment and verifying that correct Spark configurations, catalog paths, and resource settings are applied based on environment type.

**Acceptance Scenarios**:

1. **Given** a pipeline is developed locally, **When** the engineer runs it with environment flag set to "local", **Then** the shared utilities singleton Spark session is initialized with local mode settings and points to local test data
2. **Given** a pipeline needs to run in dev environment, **When** executed with "dev" flag, **Then** the shared utilities singleton Spark session is configured to connect to dev Unity Catalog with appropriate resource allocations and dev-specific table paths
3. **Given** a pipeline is ready for production, **When** deployed with "prod" flag, **Then** the shared utilities singleton Spark session is initialized with production-grade configuration including full cluster resources, production catalog references, and appropriate logging/monitoring
4. **Given** pipeline runs in any environment, **When** it accesses shared utilities, **Then** utilities automatically adapt to environment context (connection strings, resource limits, etc.) and provide the singleton Spark session

---

### User Story 4 - Leverage Shared Utilities Across Teams (Priority: P2)

Multiple data engineering teams use a common set of utilities for logging, data quality checks, schema management, and error handling without duplicating code.

**Why this priority**: Enables organization-wide standardization and reduces duplication, but requires foundation from P1 stories. Delivers ROI at organizational scale rather than individual project level.

**Independent Test**: Can be tested by multiple projects importing and using shared utilities, making updates to utilities in the shared repository, and verifying that all consuming projects can access updated versions without code changes.

**Acceptance Scenarios**:

1. **Given** a data engineer needs logging functionality, **When** they import the shared logging utility, **Then** they can use standardized logging that automatically integrates with organizational monitoring tools
2. **Given** multiple teams use shared utilities, **When** the utilities team publishes an update, **Then** all consuming projects can opt-in to the new version through version specification without breaking existing code
3. **Given** a team develops a reusable data quality function, **When** they publish it to shared utilities repository, **Then** other teams can discover and import it through the project's utility management system
4. **Given** shared utilities are used across environments, **When** a pipeline runs in different environments, **Then** utilities automatically adjust behavior based on environment configuration (logging verbosity, error handling strategies, etc.)

---

### User Story 5 - Deploy Pipeline Using Asset Bundles (Priority: P3)

A data engineer packages their completed pipeline as a Databricks Asset Bundle and deploys it to target environments with proper versioning and dependency management.

**Why this priority**: Important for production deployment but depends on having working pipelines from P1-P2 stories. Focuses on the deployment mechanism rather than core development workflow.

**Independent Test**: Can be tested by bundling a simple pipeline, deploying it through Asset Bundles to a test workspace, and verifying that all components (code, configurations, dependencies) are correctly deployed and executable.

**Acceptance Scenarios**:

1. **Given** a pipeline is ready for deployment, **When** the engineer runs the bundle creation command, **Then** system packages all pipeline code from pipelines/, shared utility references, dashboards/, databricks_apps/, monte_carlo/ configs, data_validation/ rules, and environment settings into a Databricks Asset Bundle
2. **Given** an Asset Bundle is created, **When** deployed to target environment, **Then** all dependencies including shared utilities are resolved and pipeline is registered in the target workspace with correct permissions
3. **Given** a pipeline is deployed via Asset Bundle, **When** viewing the deployment in Databricks, **Then** can see version information, deployment timestamp, and complete dependency tree including utility versions

---

### User Story 6 - Monitor Pipeline with Observability Integration (Priority: P3)

A data engineer monitors their deployed pipeline through Monte Carlo integration, receiving alerts on data quality issues, pipeline failures, and anomalies.

**Why this priority**: Valuable for production operations but only needed after pipelines are developed and deployed (P1-P2-P3 dependencies). Enhances operational excellence rather than enabling core development.

**Independent Test**: Can be tested by deploying a pipeline with Monte Carlo configuration, running it with intentional data quality issues, and verifying that appropriate alerts are triggered and visible in monitoring dashboards.

**Acceptance Scenarios**:

1. **Given** a pipeline includes data quality rules in data_validation/ directory, **When** deployed to production, **Then** these rules are automatically registered with Monte Carlo using configuration from monte_carlo/ directory
2. **Given** a pipeline is running in production, **When** a data quality issue occurs, **Then** Monte Carlo detects the anomaly and sends alerts to configured channels with context about the affected pipeline
3. **Given** multiple pipelines are deployed, **When** viewing observability dashboard, **Then** can see unified view of all pipeline health metrics, data quality scores, and lineage information integrated from Databricks and Monte Carlo

---

### User Story 7 - Template Evolution Through AI Learning (Priority: P3)

The template agent continuously learns from project initialization patterns and automatically improves templates over time.

**Why this priority**: Enhances long-term process maturity but only valuable after multiple projects have been created (P1 dependency). Represents the self-improving aspect of the AI-Native approach.

**Independent Test**: Can be tested by tracking template versions over time, analyzing change logs, and verifying that new templates incorporate patterns observed in successful projects.

**Acceptance Scenarios**:

1. **Given** 10+ projects have been initialized using templates, **When** the template agent analyzes common customizations made after initialization, **Then** it proposes template updates that incorporate these patterns
2. **Given** a template update is proposed, **When** reviewed and approved by platform team, **Then** the template agent commits the updated template to the template repository with detailed change log
3. **Given** templates have evolved over time, **When** viewing template history, **Then** can see version timeline with rationale for each change and usage statistics for each template version

---

### Edge Cases

- What happens when a pipeline tries to run in an environment type that hasn't been configured?
- How does the system handle version conflicts when a pipeline depends on a specific shared utility version that's deprecated?
- What happens when AI agent-generated code fails quality checks multiple times?
- How does the system handle network failures when trying to fetch shared utilities from remote repositories?
- What happens when a pipeline is deployed to production but references local test data paths?
- How does the system handle concurrent updates to shared utilities by multiple teams?
- What happens when Monte Carlo monitoring is unavailable but the pipeline needs to run?
- How does the system handle schema evolution in Unity Catalog that breaks existing pipeline transformations?
- What happens when Spark session creation fails due to insufficient cluster resources?
- What happens when permissions issues when accessing Unity Catalog tables across environments?
- What happens when multiple pipelines running concurrently try to access the singleton Spark session with different configuration requirements?
- How does the singleton Spark session handle thread safety when multiple transformation functions execute in parallel?
- What happens when the template agent proposes a breaking change to an existing template?
- How does the system handle conflicts when the template agent's proposed changes contradict organizational standards?
- What happens when a template needs to be rolled back due to issues discovered after deployment?
- What happens when dashboards reference data from pipelines that haven't been deployed yet?
- How does the system handle dashboard deployment separately from pipeline deployment?
- What happens when Monte Carlo configuration in monte_carlo/ directory conflicts with rules in data_validation/ directory?
- How does the system handle Databricks apps in databricks_apps/ that depend on pipelines that failed deployment?

## Requirements *(mandatory)*

### Functional Requirements

#### Project Structure & Organization

- **FR-001**: System MUST provide a standardized project structure with top-level directories: src/ (utilities and helper functions), pipelines/ (data transformation workflows), dashboards/ (visualization and reporting), databricks_apps/ (Databricks applications), monte_carlo/ (observability configuration), data_validation/ (data quality rules), tests/ (test suites), config/ (environment configurations), and docs-agentic-data-engineer/ (documentation)
- **FR-002**: System MUST support separation of concerns with pipelines/ containing only data transformation logic, src/ containing reusable utility code, dashboards/ containing visualization definitions, databricks_apps/ containing Databricks app definitions, monte_carlo/ containing observability configuration, and data_validation/ containing quality validation rules
- **FR-003**: System MUST enable project initialization through a template agent that either uses existing cookiecutter templates or generates new ones based on natural language project requirements, creating the complete directory structure (src/, pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, tests/, config/, docs-agentic-data-engineer/)
- **FR-004**: System MUST organize pipelines/ following medallion architecture principles with subdirectories or clear file naming for bronze, silver, and gold layer transformations
- **FR-005**: System MUST include a template agent that analyzes project initialization patterns and automatically creates or updates cookiecutter templates in the template repository
- **FR-006**: System MUST version control all cookiecutter templates with semantic versioning and maintain template change logs
- **FR-007**: System MUST organize dashboards/ directory to contain dashboard definitions, SQL queries, and visualization configurations that reference data produced by pipelines/
- **FR-008**: System MUST organize databricks_apps/ directory to contain Databricks application code, configurations, and deployment manifests
- **FR-009**: System MUST organize monte_carlo/ directory to contain Monte Carlo integration configuration, monitor definitions, and alert routing rules
- **FR-010**: System MUST organize data_validation/ directory to contain data quality rule definitions, validation schemas, and expectation suites

#### Environment Management

- **FR-011**: System MUST support dynamic Spark session creation that adapts configuration based on environment type (local, lab, dev, prod) via a singleton pattern where SparkSessionFactory in shared utilities maintains a single global instance
- **FR-012**: System MUST load environment-specific configurations from structured configuration files (YAML, JSON, or similar) in the config/ directory
- **FR-013**: System MUST validate environment configurations at runtime before executing pipeline code
- **FR-014**: System MUST support environment variable override mechanism for sensitive configuration values (tokens, credentials)
- **FR-015**: System MUST provide clear error messages when required environment configurations are missing or invalid
- **FR-016**: System MUST provide a thread-safe singleton Spark session accessible via utility method `get_spark()` that all pipeline code uses

#### Shared Utilities Management

- **FR-017**: System MUST provide a centralized shared utilities repository that can be versioned and imported by multiple projects
- **FR-018**: System MUST support semantic versioning for shared utility libraries to enable controlled updates
- **FR-019**: System MUST allow projects to specify utility version dependencies in their configuration
- **FR-020**: System MUST include shared utilities for common operations: logging, error handling, data quality checks, schema validation, configuration management, and Spark session access
- **FR-021**: System MUST support environment-aware utilities that adapt behavior based on runtime environment context
- **FR-022**: System MUST ensure the singleton Spark session is initialized on first access with environment-appropriate configuration

#### AI Agent Integration

- **FR-023**: System MUST include a template agent that manages cookiecutter template creation, updates, and selection based on project requirements
- **FR-024**: System MUST include a coding agent that generates PySpark transformation code in pipelines/ directory based on natural language requirements
- **FR-025**: System MUST include a testing agent that automatically creates unit and integration tests in tests/ directory for data transformations
- **FR-026**: System MUST include a data profiling agent that analyzes source data and generates data quality rules in data_validation/ directory
- **FR-027**: System MUST include a code quality agent that reviews generated code against organizational standards
- **FR-028**: System MUST provide agent definitions as reusable components that can be shared across projects
- **FR-029**: System MUST support agent composition where multiple agents can collaborate on complex tasks
- **FR-030**: System MUST maintain agent execution history for audit and debugging purposes
- **FR-031**: System MUST generate code that accesses Spark session via shared utilities singleton pattern (using `get_spark()` method)
- **FR-032**: System MUST enable template agent to analyze project customizations and propose template improvements
- **FR-033**: System MUST require human approval for template updates before committing to template repository
- **FR-034**: System MUST include a dashboard agent that generates dashboard definitions in dashboards/ directory based on data model and business requirements
- **FR-035**: System MUST include an observability agent that generates Monte Carlo configuration in monte_carlo/ directory based on pipeline requirements

#### Unity Catalog Integration

- **FR-036**: System MUST support Unity Catalog three-level namespace (catalog.schema.table) in all data operations
- **FR-037**: System MUST provide utilities for schema management including schema registration and evolution
- **FR-038**: System MUST validate table access permissions before executing transformations
- **FR-039**: System MUST support environment-specific catalog/schema naming conventions to prevent cross-environment data access

#### Pipeline Development & Execution

- **FR-040**: System MUST support Lakeflow declarative pipeline definitions with materialized views
- **FR-041**: System MUST enable incremental processing patterns for efficient data transformation
- **FR-042**: System MUST provide utilities for checkpoint management and restart logic
- **FR-043**: System MUST support both batch and streaming data processing patterns
- **FR-044**: System MUST include comprehensive error handling with retry logic and dead letter queue patterns
- **FR-045**: System MUST support pipeline definitions in pipelines/ directory that reference utility functions from src/ directory and validation rules from data_validation/ directory

#### Deployment & Asset Bundles

- **FR-046**: System MUST support packaging pipelines as Databricks Asset Bundles with all dependencies including code from pipelines/, dashboards/, databricks_apps/, monte_carlo/ configs, data_validation/ rules, and referenced shared utilities
- **FR-047**: System MUST include Asset Bundle configuration templates for different deployment scenarios
- **FR-048**: System MUST resolve and include shared utility dependencies in Asset Bundle packages
- **FR-049**: System MUST support environment-specific Asset Bundle configurations
- **FR-050**: System MUST enable CI/CD integration for automated Asset Bundle deployment
- **FR-051**: System MUST support independent deployment of pipelines/, dashboards/, and databricks_apps/ components when appropriate

#### Observability & Monitoring

- **FR-052**: System MUST integrate with Monte Carlo for data observability and quality monitoring using configuration from monte_carlo/ directory
- **FR-053**: System MUST automatically register data quality rules from data_validation/ directory with Monte Carlo when pipelines are deployed
- **FR-054**: System MUST provide structured logging that integrates with organizational monitoring tools
- **FR-055**: System MUST capture pipeline execution metrics (runtime, record counts, data volumes)
- **FR-056**: System MUST support lineage tracking showing data flow through medallion architecture layers

#### Documentation & Templates

- **FR-057**: System MUST include comprehensive documentation covering project structure, agent usage, utility functions, and deployment procedures
- **FR-058**: System MUST maintain a template repository with cookiecutter templates for different project types (batch pipelines, streaming pipelines, ML feature engineering) that include the standardized directory structure (src/, pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, tests/, config/, docs-agentic-data-engineer/)
- **FR-059**: System MUST include example projects demonstrating best practices for common use cases
- **FR-060**: System MUST provide architecture decision records (ADRs) explaining key design choices
- **FR-061**: System MUST track template usage metrics (how often each template is used, common customizations, success rates)
- **FR-062**: System MUST maintain template change logs documenting evolution rationale and version history

### Key Entities

- **Project**: A data engineering initiative containing pipeline code, configurations, tests, and documentation. Has attributes: name, version, environment configurations, dependency specifications, owner team, and template version used. Structured with top-level directories: src/, pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, tests/, config/, docs-agentic-data-engineer/
- **Environment Configuration**: Environment-specific settings defining Spark session parameters, Unity Catalog references, resource allocations, and service endpoints. Has attributes: environment type, cluster size, catalog/schema names, and feature flags. Stored in config/ directory
- **Shared Utility Library**: A versioned collection of reusable functions and classes for common data engineering operations. Has attributes: version number, exported functions, dependencies, and compatibility matrix. Includes singleton SparkSession management with `get_spark()` method. Referenced by code in src/ directory
- **AI Agent**: A specialized AI component that performs specific data engineering tasks like code generation, testing, or template management. Has attributes: agent type, input specification, output format, and configuration parameters. Related to Projects through usage tracking
- **Template Agent**: Specialized AI agent responsible for managing cookiecutter templates. Has attributes: learning algorithms, approval workflow, template generation logic, and usage pattern analysis capabilities
- **Cookiecutter Template**: A version-controlled project structure template. Has attributes: template name, version, creation date, last updated date, usage count, customization patterns, and change log. Defines directory structure including src/, pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, tests/, config/, docs-agentic-data-engineer/
- **Pipeline**: A data transformation workflow implementing medallion architecture layers. Has attributes: source tables, target tables, transformation logic, schedule, and quality rules. Related to Unity Catalog objects through table references. Accesses Spark session via singleton pattern. Located in pipelines/ directory
- **Dashboard**: A visualization or reporting artifact that presents data from pipelines. Has attributes: dashboard name, data sources (tables from pipelines), visualization type, refresh schedule. Located in dashboards/ directory
- **Databricks App**: An application deployed to Databricks. Has attributes: app name, entrypoint, dependencies, resource requirements. Located in databricks_apps/ directory
- **Monte Carlo Configuration**: Observability and monitoring configuration for Monte Carlo integration. Has attributes: monitor definitions, alert rules, integration settings. Located in monte_carlo/ directory
- **Data Validation Rule**: A data quality validation rule or expectation. Has attributes: rule name, validation logic, severity, applied layers. Located in data_validation/ directory
- **Asset Bundle**: A deployment package containing pipeline code, configurations, and dependencies for Databricks deployment. Has attributes: bundle version, included files from pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, src/, environment targets, and deployment metadata
- **Data Quality Rule**: A validation constraint applied to data at different pipeline stages. Has attributes: rule type, threshold values, severity level, and monitoring integration. Related to Monte Carlo through observability configuration
- **Unity Catalog Object**: A table, view, or function registered in Unity Catalog. Has attributes: three-level namespace, schema definition, access permissions, and lineage metadata. Related to Pipelines through read/write operations

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Data engineers can initialize a new pipeline project in under 5 minutes using AI-generated templates, compared to 2-4 hours with manual setup
- **SC-002**: AI agents reduce time to implement a standard transformation from 2-3 hours to 20-30 minutes for common patterns (70%+ time savings)
- **SC-003**: Teams can execute the same pipeline code across all four environments (local/lab/dev/prod) without code changes, only configuration differences
- **SC-004**: Shared utilities are reused by at least 3 different team projects within the first month of availability
- **SC-005**: 90% of generated code passes quality checks on first attempt, with clear feedback for remaining 10%
- **SC-006**: Pipeline deployment through Asset Bundles completes in under 10 minutes from commit to running in target environment
- **SC-007**: Data quality issues are detected and alerted within 15 minutes of occurrence through Monte Carlo integration
- **SC-008**: Developer satisfaction score of 4/5 or higher for AI agent assistance quality and usefulness
- **SC-009**: Reduction in duplicate utility code across projects by 80% through shared utility adoption
- **SC-010**: Zero production incidents caused by environment misconfiguration within first 3 months of adoption
- **SC-011**: Complete data lineage visible from raw sources through all medallion layers to final consumption layer
- **SC-012**: Pipeline execution time improves by 30% through incremental processing and optimization patterns in shared utilities
- **SC-013**: Singleton Spark session provides consistent access across all pipeline transformations with zero initialization overhead after first access
- **SC-014**: Template agent proposes at least one meaningful template improvement per quarter based on usage pattern analysis
- **SC-015**: Template quality improves over time with 20% reduction in post-initialization customizations after 6 months of template evolution
- **SC-016**: Clear separation of concerns in directory structure improves code organization scores by 40% compared to monolithic structures
- **SC-017**: Data validation rules in data_validation/ directory are automatically synced with Monte Carlo configuration with 100% consistency

### Assumptions

- Teams have access to Databricks workspaces for all required environments (local, lab, dev, prod)
- Unity Catalog is configured and accessible with appropriate permissions for data engineering teams
- Monte Carlo or equivalent observability platform is available and configured
- Teams have basic proficiency with PySpark and medallion architecture concepts
- CI/CD infrastructure is available for Asset Bundle deployments
- Network connectivity allows access to shared utility repositories from all environments
- Claude Code (or equivalent AI coding assistant) is available for agent implementation
- Organizations have established naming conventions for Unity Catalog objects
- Version control system (Git) is in place for code and configuration management
- Standard Python packaging tools (pip, poetry, conda) are available for dependency management
- Pipeline transformations within a single execution run do not require different Spark session configurations
- Platform team has established approval workflow for template agent's proposed changes
- Template repository supports version control and maintains audit trail of all template modifications
- Dashboards can reference tables created by pipelines using Unity Catalog three-level namespace
- Databricks Apps can access data from pipelines via Unity Catalog
- Monte Carlo configuration and data validation rules are kept in sync through automated processes
