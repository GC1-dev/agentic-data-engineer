# Feature Specification: Monte Carlo Observability Integration Utilities

**Feature Branch**: `003-monte-carlo-utilities`
**Created**: 2025-11-22
**Status**: Draft
**Input**: User description: "i want to create 2 more utilieis: one more monte carlo and other for dqx"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Data Quality Monitoring Integration (Priority: P1)

As a data engineer running Databricks pipelines, I want to automatically send data quality metrics and lineage information to Monte Carlo so that I can monitor data health, detect anomalies, and receive alerts without manually instrumenting observability code.

**Why this priority**: Core value proposition - enables automated data observability for Databricks pipelines with minimal code changes, allowing teams to detect data quality issues proactively.

**Independent Test**: Can be fully tested by running a Databricks pipeline with the Monte Carlo utilities installed, executing data transformations, and verifying that metrics (row counts, null percentages, schema changes) are automatically sent to Monte Carlo and visible in the Monte Carlo dashboard.

**Acceptance Scenarios**:

1. **Given** a Databricks pipeline using databricks-shared-utilities, **When** I import and enable Monte Carlo integration, **Then** table operations automatically send lineage and quality metrics to Monte Carlo
2. **Given** a DataFrame transformation in my pipeline, **When** the transformation completes, **Then** row count, column statistics, and data freshness metrics are logged to Monte Carlo
3. **Given** a pipeline failure or data quality issue, **When** the issue is detected, **Then** Monte Carlo receives the error context and can trigger configured alerts

---

### User Story 2 - Custom Metrics and Annotations (Priority: P2)

As a data engineer implementing business-specific data quality checks, I want to send custom metrics and annotations to Monte Carlo so that I can track domain-specific KPIs and add context to data observability events.

**Why this priority**: Extends basic monitoring with business-specific metrics, allowing teams to track metrics beyond standard data quality dimensions (completeness, freshness, schema).

**Independent Test**: Can be fully tested by creating a pipeline that computes custom metrics (e.g., "daily_revenue_total", "customer_count"), sending them to Monte Carlo via the utilities, and verifying they appear in Monte Carlo's custom metrics dashboard.

**Acceptance Scenarios**:

1. **Given** a custom business metric calculated in my pipeline, **When** I use the Monte Carlo utilities to log the metric, **Then** the metric appears in Monte Carlo with timestamp, value, and context
2. **Given** a data quality incident, **When** I add annotations via the utilities, **Then** the annotations appear in Monte Carlo's incident timeline with relevant context
3. **Given** multiple custom metrics across different tables, **When** metrics are sent to Monte Carlo, **Then** they are correctly associated with their respective tables and time periods

---

### User Story 3 - Incident Management Integration (Priority: P3)

As a data platform team lead, I want to query and manage Monte Carlo incidents programmatically from Databricks notebooks so that I can create automated incident response workflows and embed data quality status checks into operational dashboards.

**Why this priority**: Enables advanced workflows like automated incident resolution, quality gates in CI/CD pipelines, and custom alerting logic beyond Monte Carlo's built-in rules.

**Independent Test**: Can be fully tested by creating a notebook that queries Monte Carlo for open incidents, filters by severity and table, and programmatically updates incident status (e.g., marking as resolved, adding comments).

**Acceptance Scenarios**:

1. **Given** open data quality incidents in Monte Carlo, **When** I query incidents via the utilities, **Then** I receive a list of incidents with severity, affected tables, and timestamps
2. **Given** an incident that has been manually resolved, **When** I update the incident status via the utilities, **Then** the incident status changes in Monte Carlo and triggers configured workflows
3. **Given** a data quality gate in my CI/CD pipeline, **When** I check for critical incidents before deploying, **Then** the deployment blocks if critical incidents exist for affected tables

---

### Edge Cases

- **Monte Carlo API unavailable**: System continues pipeline execution but logs warning; metrics are queued for retry
- **Authentication failures**: Clear error messages guide users to check API credentials; sensitive credentials are not logged
- **Large metric volumes**: Utilities batch metrics efficiently to avoid rate limiting; configurable batch size and flush intervals
- **Network timeouts**: Automatic retry with exponential backoff; configurable timeout thresholds
- **Missing table metadata**: Utilities gracefully handle tables not yet registered in Monte Carlo; auto-register if permissions allow
- **Schema evolution**: Utilities detect and report schema changes to Monte Carlo; handle backward-compatible and breaking changes differently

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a MonteCarlo client class that authenticates using Monte Carlo API credentials (API key ID and token)
- **FR-002**: System MUST automatically send table lineage information (source tables, target tables, transformation type) to Monte Carlo when DataFrame operations complete
- **FR-003**: System MUST collect and send standard data quality metrics (row count, null count per column, distinct count, min/max/mean for numeric columns) after DataFrame operations
- **FR-004**: Users MUST be able to send custom metrics to Monte Carlo with table name, metric name, value, and timestamp
- **FR-005**: Users MUST be able to add annotations to Monte Carlo incidents programmatically with incident ID, annotation text, and metadata
- **FR-006**: System MUST provide methods to query Monte Carlo incidents by table name, severity level, status, and time range
- **FR-007**: System MUST provide methods to update Monte Carlo incident status (resolve, reopen, acknowledge) with optional comments
- **FR-008**: System MUST batch metric submissions to avoid rate limiting, with configurable batch size and flush interval
- **FR-009**: System MUST handle Monte Carlo API errors gracefully with automatic retry logic (exponential backoff, max retry attempts)
- **FR-010**: System MUST log all Monte Carlo API interactions (requests, responses, errors) using structured logging compatible with databricks-shared-utilities
- **FR-011**: Users MUST be able to configure Monte Carlo integration via EnvironmentConfig or separate MonteCarlo configuration object
- **FR-012**: System MUST support both synchronous (blocking) and asynchronous (non-blocking) metric submission modes
- **FR-013**: System MUST provide utility functions to convert Spark DataFrame schemas to Monte Carlo schema format
- **FR-014**: System MUST respect Monte Carlo API rate limits and automatically throttle requests when limits are approached

### Key Entities

- **MonteCarloClient**: Handles authentication and API communication with Monte Carlo; manages API credentials, retry logic, and rate limiting
- **DataQualityMetrics**: Represents standard metrics (row count, nulls, distinct values, statistics); associated with specific table and timestamp
- **CustomMetric**: User-defined business metric with name, value, unit, and table association
- **Incident**: Represents Monte Carlo data quality incident with ID, severity, status, affected tables, timestamps, and annotations
- **LineageEvent**: Represents data lineage information (source → target relationships) tracked by Monte Carlo
- **Configuration**: Monte Carlo-specific settings including API credentials, batch settings, retry policies, and logging preferences

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Data engineers can enable Monte Carlo integration in existing Databricks pipelines with fewer than 10 lines of code
- **SC-002**: Standard data quality metrics (row count, null percentage, schema) are automatically sent to Monte Carlo for all monitored tables within 5 minutes of pipeline execution
- **SC-003**: Custom metrics submitted via the utilities appear in Monte Carlo dashboard within 2 minutes
- **SC-004**: 95% of metric submissions succeed on first attempt; remaining 5% succeed after retry
- **SC-005**: Monte Carlo utilities handle at least 1000 metric submissions per minute without rate limit errors
- **SC-006**: Data engineers can query and filter Monte Carlo incidents in under 5 seconds for typical datasets (< 100 incidents)
- **SC-007**: Integration has minimal performance impact - adds less than 5% overhead to pipeline execution time
- **SC-008**: Zero sensitive data (API credentials, PII) is logged in plaintext by Monte Carlo utilities

## Assumptions & Dependencies *(mandatory)*

### Assumptions

- Users have active Monte Carlo subscription with API access enabled
- Monte Carlo API credentials (API key ID and token) are available via environment variables or configuration files
- Databricks pipelines use databricks-shared-utilities for Spark session management and configuration
- Tables being monitored are registered in Monte Carlo or utilities have permissions to auto-register
- Network connectivity from Databricks clusters to Monte Carlo API endpoints is available
- Python 3.10+ runtime environment (standard for Databricks)

### Dependencies

- **Monte Carlo API**: RESTful API for data observability (lineage, metrics, incidents)
- **databricks-shared-utilities**: Required for EnvironmentConfig integration and structured logging
- **requests library**: HTTP client for Monte Carlo API communication
- **pydantic**: Configuration validation and data modeling
- **Databricks SDK**: Optional, for enhanced Databricks-specific integrations

### External Integrations

- Monte Carlo Data Observability Platform (SaaS)
- Monte Carlo REST API v1 (assuming current API version)

## Out of Scope *(optional)*

- Real-time streaming data quality monitoring (focus on batch pipelines)
- Custom anomaly detection algorithms (use Monte Carlo's built-in ML capabilities)
- Direct integration with Monte Carlo's UI/dashboard customization
- On-premise Monte Carlo deployment support (SaaS only)
- Monte Carlo billing and subscription management
- Advanced lineage visualization (use Monte Carlo's native lineage viewer)
- Monte Carlo alerting configuration (use Monte Carlo UI for alert setup)

## Technical Constraints *(optional)*

- Must respect Monte Carlo API rate limits (typically 100 requests per minute, configurable)
- API responses must be processed within 30-second timeout to avoid blocking pipelines
- Metric payloads limited to 1MB per request (Monte Carlo API constraint)
- Must work in both interactive notebooks and scheduled job contexts
- Must handle transient network failures gracefully without data loss

## Security & Privacy Considerations *(optional)*

- API credentials must never be logged or displayed in error messages
- Credentials should be loaded from secure storage (Databricks secrets, environment variables)
- All API communication must use HTTPS
- Sensitive data in DataFrames should not be sent to Monte Carlo (only metadata and statistics)
- Users must have appropriate permissions to write metrics for specific tables
- Audit logging for all Monte Carlo API write operations
