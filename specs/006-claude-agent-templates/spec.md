# Feature Specification: Claude Agent Template System

**Feature Branch**: `006-claude-agent-templates`
**Created**: 2025-11-23
**Status**: Draft
**Input**: User description: "instead of /Users/puneethabagivalumanj/Documents/repos/python-repos/ai_native_repos/ai-native-data-engineering-process/databricks-project-templates being a cookiecutter. Should this be a template claude agent?"

## Clarifications

### Session 2025-11-23

- Q: Which CI/CD platform configuration(s) should the agent generate by default? → A: Ask during generation which CI/CD platform to use
- Q: What defines a "sensible default" for configuration values? → A: Databricks documented best practices and recommendations
- Q: How should the agent handle existing target project directories? → A: Prompt user with options (overwrite, merge, backup existing, cancel)
- Q: What makes a requirements.txt file "appropriate" for generated projects? → A: Databricks Runtime compatible versions with pinned version numbers
- Q: What sections must be included in generated README.md documentation? → A: Extensive: setup, included features, directory structure, deployment steps, architecture diagrams, and API references

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Interactive Project Generation (Priority: P1)

As a data engineer starting a new Databricks project, I want to interactively generate a project structure through a conversational Claude agent interface, so that I can provide requirements in natural language and receive a fully configured project without memorizing cookiecutter variable names.

**Why this priority**: Core value proposition - replaces static templating with intelligent conversation. This is the foundation that makes all other features possible.

**Independent Test**: Can be fully tested by having a user describe a project ("I need a bronze/silver/gold pipeline for customer data") and verifying the agent generates a complete project structure with appropriate configuration.

**Acceptance Scenarios**:

1. **Given** a user wants to create a new project, **When** they invoke the Claude agent with a natural language description, **Then** the agent asks clarifying questions about requirements
2. **Given** the agent has gathered requirements, **When** the user confirms the setup, **Then** a complete project structure is generated with all standard directories
3. **Given** a generated project, **When** the user reviews the structure, **Then** all configuration files are populated with values derived from the conversation
4. **Given** an ambiguous requirement, **When** the agent needs more information, **Then** it asks targeted questions with suggested answers
5. **Given** the user wants to skip questions, **When** they request defaults, **Then** the agent generates a project using sensible defaults

---

### User Story 2 - Template Customization Through Conversation (Priority: P2)

As a data engineer with specific requirements, I want to customize the generated project by describing my needs conversationally (e.g., "add streaming support", "configure for Unity Catalog"), so that I can get exactly the project structure I need without manually editing template files.

**Why this priority**: Differentiates from cookiecutter by enabling intelligent customization based on requirements, not just variable substitution.

**Independent Test**: Can be tested by requesting specific customizations ("enable Monte Carlo monitoring", "add PySpark testing") and verifying the agent includes appropriate files, configurations, and dependencies.

**Acceptance Scenarios**:

1. **Given** a user wants streaming support, **When** they mention "streaming pipeline" in requirements, **Then** the agent includes streaming-specific directories and configuration
2. **Given** a user needs data quality validation, **When** they request validation rules, **Then** the agent generates data_validation/ directory with example rules
3. **Given** a user wants specific Python packages, **When** they list dependencies, **Then** requirements.txt includes all requested packages with compatible versions
4. **Given** a user has Unity Catalog requirements, **When** they specify catalogs/schemas, **Then** configuration files include UC-specific settings
5. **Given** conflicting requirements, **When** the agent detects incompatibility, **Then** it warns the user and suggests alternatives

---

### User Story 3 - Template Evolution and Learning (Priority: P3)

As a platform engineer, I want the Claude agent to learn from generated projects and improve templates over time, so that future projects benefit from best practices discovered in production usage.

**Why this priority**: Long-term value - enables continuous improvement without manual template maintenance.

**Independent Test**: Can be tested by generating multiple projects, analyzing common patterns, and verifying the agent suggests improvements to the template structure or default configurations.

**Acceptance Scenarios**:

1. **Given** multiple projects have been generated, **When** the agent analyzes usage patterns, **Then** it identifies commonly requested customizations
2. **Given** pattern analysis complete, **When** platform engineers review suggestions, **Then** the agent presents data-driven template improvements
3. **Given** approved improvements, **When** the template is updated, **Then** future projects automatically benefit from enhancements
4. **Given** a project with custom modifications, **When** those modifications prove valuable, **Then** they become template suggestions for similar projects
5. **Given** template analytics, **When** engineers query template usage, **Then** they see metrics on most/least used features

---

### Edge Cases

- What happens when the agent cannot understand the user's requirements description?
- How does the system handle requests for features not supported by Databricks (e.g., AWS-specific services)?
- What if the user requests conflicting configurations (e.g., both batch and streaming optimizations)?
- How does the agent handle version compatibility (e.g., Python 3.10 vs 3.11, DBR 13 vs 14)?
- **Existing directory handling**: If target project directory exists, agent MUST prompt user with options: overwrite all files, merge with existing (preserve user files), backup existing directory with timestamp, or cancel generation
- How does the system handle network failures during conversation or project generation?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a conversational interface for project generation via Claude agent
- **FR-002**: Agent MUST ask clarifying questions when requirements are ambiguous or incomplete (includes CI/CD platform choice: GitHub Actions, GitLab CI, or Azure DevOps)
- **FR-003**: Agent MUST generate the standard 9-directory structure (src/, pipelines/, dashboards/, databricks_apps/, monte_carlo/, data_validation/, tests/, config/, docs/, databricks/)
- **FR-004**: Agent MUST create environment-specific configuration files (local.yaml, lab.yaml, dev.yaml, prod.yaml, project.yaml)
- **FR-005**: Agent MUST populate configuration files with values derived from conversational requirements
- **FR-006**: Agent MUST support natural language requirements like "I need a streaming pipeline for customer events"
- **FR-007**: Agent MUST provide sensible defaults for unspecified configuration values (sensible = follows Databricks documented best practices and recommendations)
- **FR-008**: Agent MUST generate appropriate requirements.txt based on requested features (appropriate = Databricks Runtime compatible versions with pinned version numbers for reproducibility)
- **FR-009**: Agent MUST create Databricks Asset Bundle configuration (databricks/bundle.yml)
- **FR-010**: Agent MUST support optional features (streaming, Monte Carlo, data validation, testing frameworks)
- **FR-011**: Agent MUST validate that requested Python version is compatible with Databricks Runtime
- **FR-012**: Agent MUST detect and warn about conflicting requirements before generation
- **FR-013**: Agent MUST preserve cookiecutter compatibility as a fallback option
- **FR-014**: System MUST record generated projects for template improvement analysis
- **FR-015**: System MUST provide a command to analyze template usage patterns and suggest improvements
- **FR-016**: Agent MUST support interactive customization during generation ("add Monte Carlo monitoring")
- **FR-017**: Agent MUST generate README.md with comprehensive project-specific documentation including: setup instructions, included features list, directory structure explanation, deployment steps, architecture diagrams (Mermaid format), and API references for custom modules
- **FR-018**: System MUST validate generated project structure matches the standard 9-directory layout
- **FR-019**: Agent MUST handle existing target directories by prompting user with options (overwrite, merge, backup, cancel)

### Key Entities

- **Project Requirements**: Natural language description of project needs, captured through conversation (includes project purpose, data sources, transformation layers, monitoring needs, team ownership)
- **Project Template**: Structured representation of project layout with configurable components (directories, files, configurations), can be dynamically customized based on requirements
- **Configuration Profile**: Environment-specific settings (local/lab/dev/prod) with infrastructure details, connection strings, compute specifications
- **Feature Module**: Optional project component (streaming, Monte Carlo, data validation) that adds specific files and configurations when requested
- **Generation Session**: Record of conversation, requirements gathered, choices made, and resulting project structure - used for template improvement
- **Template Improvement Suggestion**: Data-driven recommendation for template changes based on analysis of multiple generation sessions

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can generate a complete project from natural language description in under 5 minutes (including conversation)
- **SC-002**: Generated projects include all requested features with 100% accuracy
- **SC-003**: Agent asks fewer than 5 clarifying questions for typical project requirements
- **SC-004**: 90% of generated projects require zero manual configuration changes to run
- **SC-005**: Template improvement analysis identifies actionable suggestions after analyzing 10+ projects
- **SC-006**: Users prefer conversational generation over cookiecutter 4:1 in usability surveys
- **SC-007**: Generated projects pass all validation checks (directory structure, configuration syntax, dependency compatibility)
- **SC-008**: Agent handles ambiguous requirements with 95% success rate (measured by successful project generation)

## Assumptions & Dependencies *(mandatory)*

### Assumptions

- Users have basic understanding of Databricks concepts (pipelines, Asset Bundles, environments)
- Users can describe project requirements in natural language (English)
- Claude agent has access to write files to local filesystem
- Generated projects target Databricks Runtime 13.0+ with Python 3.10+
- Users have Claude CLI or similar agent interface available
- Cookiecutter remains installed as fallback mechanism

### Dependencies

- **Claude Agent Infrastructure**: Requires Claude agent with file system access and conversational interface
- **Template Knowledge Base**: Agent must have knowledge of Databricks best practices, Asset Bundles, medallion architecture
- **Project Structure Standards**: Depends on the 9-directory layout being maintained as organizational standard
- **Databricks Asset Bundles**: Generated projects must be compatible with current Asset Bundle specification
- **Python Package Ecosystem**: Agent must understand Python package compatibility and Databricks-compatible versions

### External Integrations

- **Databricks Workspace**: Generated projects integrate with Databricks via Asset Bundles
- **Monte Carlo** (optional): If requested, projects include Monte Carlo observability configuration
- **Git**: Generated projects include .gitignore and assume version control
- **CI/CD Platforms**: Agent asks user which platform to target (GitHub Actions, GitLab CI, or Azure DevOps) and generates corresponding workflow configuration

## Out of Scope *(optional)*

- Modifying existing projects (focus is new project generation)
- Non-Databricks platforms (AWS Glue, Azure Data Factory)
- Real-time project generation without conversation (batch mode only)
- Automatic deployment of generated projects to Databricks workspaces
- Template versioning and rollback (future enhancement)
- Multi-language support (initially English only)
- Integration with project management tools (Jira, ServiceNow)
- Automatic dependency updates after project generation

## Technical Constraints *(optional)*

- Agent must generate valid Python 3.10+ code
- Generated Asset Bundle YAML must conform to Databricks specification
- Project structure must follow organizational 9-directory standard (cannot be customized)
- Configuration files must be valid YAML with no syntax errors
- Generated requirements.txt must specify compatible package versions
- Project names must be filesystem-safe (no special characters, spaces)
- Agent response time should be under 30 seconds per interaction
- Generated projects must be under 50MB before adding data

## Security & Privacy Considerations *(optional)*

- Project descriptions may contain sensitive information about data sources - agent must not persist conversation logs beyond session
- Generated configuration files must not include hardcoded credentials or API keys
- Agent should remind users to add secrets management before deployment
- Template improvement analysis must anonymize project-specific details
- Generated .gitignore must exclude common secret files (.env, *.key, credentials.json)
- Agent should warn if user mentions credentials in conversation and suggest environment variables
- Generated projects should include security scanning configuration (ruff, bandit) by default
