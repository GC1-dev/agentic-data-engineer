# Agent Interface Contract

**Version**: 1.0.0
**Date**: 2025-11-23
**Feature**: Claude Agent Template System

## Overview

This contract defines the interface between the user (data engineer) and the Claude agent for conversational project generation. Since this is an AI agent system, the "API" is the conversational interface and the structure of prompts/responses.

---

## Conversation Flow Contract

### 1. Initiation

**User Action**: Invokes agent with initial project description

**Input Format**:
```text
Natural language description of project needs
Examples:
- "I need a streaming pipeline for customer events"
- "Create a bronze/silver/gold pipeline for sales data with Monte Carlo monitoring"
- "New project for batch processing with data validation"
```

**Agent Response Contract**:
```json
{
  "type": "acknowledgment",
  "message": "I understand you need a [project_type]. Let me ask a few questions to customize your project.",
  "next_action": "clarifying_questions"
}
```

---

### 2. Clarifying Questions Phase

**Agent Behavior**: Asks targeted questions based on ambiguities in requirements

**Question Format Contract**:
```json
{
  "type": "clarification",
  "question": "What CI/CD platform will you use?",
  "options": [
    {
      "value": "github_actions",
      "label": "GitHub Actions",
      "description": "GitHub's built-in CI/CD"
    },
    {
      "value": "gitlab_ci",
      "label": "GitLab CI",
      "description": "GitLab's CI/CD pipelines"
    },
    {
      "value": "azure_devops",
      "label": "Azure DevOps",
      "description": "Azure Pipelines"
    }
  ],
  "default": "github_actions",
  "required": true
}
```

**User Response Contract**:
```text
Short answer: "github_actions" OR "GitHub Actions" OR "1" (option number)
OR natural language: "We use GitHub"
```

**Constraints**:
- Maximum 5 clarifying questions per session (SC-003)
- Each question must have clear purpose
- Must provide default option
- Must support both structured (option selection) and natural language responses

---

### 3. Requirements Confirmation Phase

**Agent Behavior**: Summarizes gathered requirements for user approval

**Summary Format Contract**:
```yaml
# Confirmed Requirements
project_name: customer_events_pipeline
python_version: "3.11"
databricks_runtime: "14.3"
transformation_layers:
  - bronze
  - silver
  - gold
features:
  - streaming
  - monte_carlo
environments:
  - local
  - lab
  - dev
  - prod
ci_cd_platform: github_actions
```

**User Response Contract**:
```text
"yes" | "confirm" | "looks good" → Proceed to generation
"no" | "change [X]" | "modify [Y]" → Return to clarification phase
```

---

### 4. Conflict Detection Phase (if applicable)

**Agent Behavior**: Warns about conflicting or incompatible requirements

**Warning Format Contract**:
```json
{
  "type": "conflict_warning",
  "conflicts": [
    {
      "description": "Streaming pipelines require Databricks Runtime 13.3+, but you specified 13.0",
      "severity": "error",
      "resolution_required": true,
      "suggested_fix": "Upgrade to DBR 13.3 or remove streaming feature"
    }
  ],
  "can_proceed": false
}
```

**Severity Levels**:
- `error`: Blocks generation, must resolve
- `warning`: Can proceed but not recommended
- `info`: FYI, no action needed

---

### 5. Generation Phase

**Agent Behavior**: Creates project structure with progress updates

**Progress Update Contract**:
```json
{
  "type": "progress",
  "phase": "generating_structure",
  "steps": [
    {"name": "Creating directories", "status": "completed"},
    {"name": "Generating configurations", "status": "in_progress"},
    {"name": "Creating README", "status": "pending"},
    {"name": "Validating structure", "status": "pending"}
  ],
  "estimated_seconds_remaining": 45
}
```

**Completion Contract**:
```json
{
  "type": "generation_complete",
  "project_path": "/path/to/customer_events_pipeline",
  "files_created": 45,
  "directories_created": 9,
  "validation_results": {
    "structure_validation": "passed",
    "config_validation": "passed",
    "bundle_validation": "passed",
    "compatibility_check": "passed"
  },
  "next_steps": [
    "cd customer_events_pipeline",
    "Review README.md for project-specific documentation",
    "Configure secrets in .env file",
    "Deploy with: databricks bundle deploy"
  ]
}
```

---

### 6. Error Handling Phase

**Agent Behavior**: Reports errors with actionable recovery steps

**Error Format Contract**:
```json
{
  "type": "generation_error",
  "error_code": "DIRECTORY_EXISTS",
  "message": "Target directory 'customer_events_pipeline' already exists",
  "severity": "error",
  "recovery_options": [
    {
      "action": "overwrite",
      "description": "Delete existing directory and create new project",
      "warning": "This will permanently delete existing files"
    },
    {
      "action": "merge",
      "description": "Merge generated files with existing directory",
      "warning": "May overwrite some existing files"
    },
    {
      "action": "backup",
      "description": "Backup existing directory and create new project",
      "detail": "Existing directory will be renamed to 'customer_events_pipeline.backup.20251123'"
    },
    {
      "action": "cancel",
      "description": "Cancel generation and exit"
    }
  ]
}
```

**User Response Contract**:
```text
"overwrite" | "merge" | "backup" | "cancel"
```

---

## Validation Contract

### Structure Validation (FR-018)

**Input**: Generated project directory

**Output**:
```json
{
  "validator": "structure_validator",
  "passed": true,
  "checks": [
    {"name": "9-directory layout", "passed": true, "details": "All required directories present"},
    {"name": "Required files", "passed": true, "details": "README.md, requirements.txt, .gitignore present"},
    {"name": "No extra root directories", "passed": true}
  ]
}
```

**Failure Contract**:
```json
{
  "validator": "structure_validator",
  "passed": false,
  "checks": [
    {"name": "9-directory layout", "passed": false, "details": "Missing directory: 'databricks/'"},
    {"name": "Required files", "passed": true},
    {"name": "No extra root directories", "passed": false, "details": "Found unexpected directory: 'extra/'"}
  ],
  "recovery_action": "Regenerate project structure"
}
```

---

### Configuration Validation

**Input**: Generated YAML configuration files

**Output**:
```json
{
  "validator": "config_validator",
  "passed": true,
  "files_validated": [
    {"file": "config/local.yaml", "valid": true, "schema_version": "1.0"},
    {"file": "config/dev.yaml", "valid": true, "schema_version": "1.0"},
    {"file": "config/prod.yaml", "valid": true, "schema_version": "1.0"},
    {"file": "databricks/bundle.yml", "valid": true, "databricks_spec_version": "1.0"}
  ]
}
```

---

### Compatibility Validation (FR-011)

**Input**: Python version + Databricks Runtime version

**Output**:
```json
{
  "validator": "compatibility_checker",
  "passed": true,
  "checks": [
    {
      "type": "python_dbr_compatibility",
      "python_version": "3.11",
      "databricks_runtime": "14.3",
      "compatible": true,
      "min_dbr_required": "13.3"
    },
    {
      "type": "package_compatibility",
      "incompatible_packages": [],
      "warnings": []
    }
  ]
}
```

**Failure Example**:
```json
{
  "validator": "compatibility_checker",
  "passed": false,
  "checks": [
    {
      "type": "python_dbr_compatibility",
      "python_version": "3.12",
      "databricks_runtime": "13.0",
      "compatible": false,
      "min_dbr_required": "14.0",
      "error": "Python 3.12 requires Databricks Runtime 14.0+, but 13.0 was specified"
    }
  ],
  "recovery_action": "Update databricks_runtime to '14.3' or downgrade python_version to '3.11'"
}
```

---

## Session Recording Contract (FR-014)

**Purpose**: Capture anonymized session metadata for template improvement analysis

**Session Record Schema**:
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-11-23T10:30:00Z",
  "project_name_hash": "a3f7b2c1d4e5f6g7",
  "requirements_summary": {
    "transformation_layers": ["bronze", "silver", "gold"],
    "features_requested": ["streaming", "monte_carlo"],
    "python_version": "3.11",
    "databricks_runtime": "14.3",
    "ci_cd_platform": "github_actions"
  },
  "questions_asked": 3,
  "clarifications_count": 1,
  "generation_time_seconds": 127.5,
  "success": true,
  "validation_results": {
    "structure_validator": true,
    "config_validator": true,
    "bundle_validator": true,
    "compatibility_checker": true
  }
}
```

**Anonymization Rules**:
- ❌ **NEVER store**: Full conversation transcripts, project names, team ownership, workspace URLs, data source specifics
- ✅ **CAN store**: Feature choices, versions, question count, generation time, validation results

---

## Analytics Contract (FR-015)

**Input**: Aggregate of 10+ session records

**Output**: Template improvement suggestions

```json
{
  "suggestion_id": "660e8400-e29b-41d4-a716-446655440001",
  "created_at": "2025-11-23T11:00:00Z",
  "pattern_type": "commonly_requested_feature",
  "description": "Monte Carlo observability requested in 78% of projects (47 out of 60 sessions)",
  "supporting_sessions": 47,
  "frequency_percentage": 78.3,
  "recommended_action": "Consider making Monte Carlo a default feature (opt-out instead of opt-in)",
  "priority": "high",
  "status": "pending_review"
}
```

---

## Performance Contract

Based on Technical Constraints and Success Criteria:

| Metric | Target | Measured By |
|--------|--------|-------------|
| Agent response time | <30 seconds per interaction | `response_time_ms` in logs |
| Total generation time | <5 minutes including conversation | `generation_time_seconds` in session record |
| Clarifying questions | <5 questions for typical projects | `questions_asked` in session record |
| Zero manual changes | 90% of projects | Post-generation user survey |

---

## Security Contract

Based on Security & Privacy Considerations:

### Data Retention
- ❌ **NO persistence**: Conversation logs, user messages, agent responses
- ✅ **Session-scoped only**: Conversation state in memory during active session
- ✅ **CAN persist**: Anonymized session metadata for analytics

### Secret Detection
**Agent Behavior**: Warn if user mentions credentials in conversation

**Warning Format**:
```json
{
  "type": "security_warning",
  "detected_pattern": "API key or credential mentioned",
  "message": "I noticed you mentioned what appears to be a credential. Please do not include actual secrets in this conversation. The generated project will use environment variables for sensitive data.",
  "recommendation": "Use .env file with environment variables after generation"
}
```

### Generated Project Security
- All projects include `.gitignore` excluding common secret files
- Configuration templates use environment variable placeholders
- README includes security reminder about secrets management

---

## Fallback Contract (FR-013)

**Scenario**: Claude agent unavailable or user preference

**Fallback Behavior**:
```json
{
  "type": "fallback_option",
  "message": "I'm unable to process your request right now. Would you like to use the cookiecutter fallback?",
  "fallback_command": "cookiecutter gh:your-org/databricks-project-templates",
  "note": "Cookiecutter requires manual variable input but doesn't need AI agent"
}
```

---

## Contract Testing

All contracts validated by:

1. **Unit Tests**: Mock agent responses matching contract schemas
2. **Contract Tests**: Validate generated project structure against FR-003 (9-directory layout)
3. **Integration Tests**: End-to-end generation with contract validation
4. **Schema Validation**: Pydantic models enforce data contracts at runtime

---

**Contract Version**: 1.0.0
**Last Updated**: 2025-11-23
**Stability**: Draft (subject to change during implementation)
