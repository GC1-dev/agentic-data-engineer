# Implementation Plan: Claude Agent Template System

**Branch**: `006-claude-agent-templates` | **Date**: 2025-11-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-claude-agent-templates/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Replace the existing cookiecutter-based databricks-project-templates system with an intelligent Claude agent that generates Databricks projects through conversational interaction. The agent will understand natural language requirements ("I need a streaming pipeline for customer events"), ask targeted clarifying questions, and generate complete project structures with the standard 9-directory layout, environment-specific configurations, Databricks Asset Bundles, and comprehensive documentation. This eliminates the need for users to memorize cookiecutter variable names and enables intelligent customization based on stated requirements rather than static template substitution.

## Technical Context

**Language/Version**: Python 3.10+ (aligns with Databricks Runtime 13.0+ requirement from spec)
**Primary Dependencies**:
- Claude SDK/API for conversational interface
- Jinja2 for template rendering (existing cookiecutter templates)
- PyYAML for configuration file generation
- Pydantic for data validation and schema management
- NEEDS CLARIFICATION: Agent orchestration framework (LangChain, LlamaIndex, or custom)

**Storage**:
- Local filesystem for generated projects
- JSON/YAML files for generation session records (FR-014: template improvement analysis)
- NEEDS CLARIFICATION: Storage mechanism for pattern analysis data (local files, SQLite, or cloud storage)

**Testing**:
- pytest for Python agent logic testing
- Contract tests for generated project structure validation
- Integration tests for end-to-end generation workflows
- NEEDS CLARIFICATION: Testing strategy for conversational flows (mock Claude responses, or fixture-based)

**Target Platform**:
- Developer workstations (macOS, Linux, Windows with WSL)
- Claude CLI environment with filesystem access
- CI/CD environments (GitHub Actions, GitLab CI, Azure DevOps) for automated validation

**Project Type**: Single CLI/agent application with template knowledge base

**Performance Goals**:
- Agent response time <30 seconds per interaction (from Technical Constraints)
- Complete project generation in <5 minutes including conversation (SC-001)
- Fewer than 5 clarifying questions for typical projects (SC-003)

**Constraints**:
- Generated projects must be under 50MB before adding data (from Technical Constraints)
- Agent must not persist conversation logs beyond session (Security requirement)
- Generated Asset Bundle YAML must validate against Databricks specification
- Project structure must follow fixed 9-directory standard (cannot be customized)
- Python 3.10+ compatibility for all generated code

**Scale/Scope**:
- Support 100+ project generations without performance degradation
- Template improvement analysis requires 10+ projects (SC-005)
- Handle 5+ optional feature modules (streaming, Monte Carlo, data validation, testing frameworks)
- Support 4 environment configurations (local, lab, dev, prod)
- NEEDS CLARIFICATION: Expected number of concurrent users, session persistence requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Check (Pre-Phase 0)

**Status**: ⚠️ Constitution file contains placeholder content only - no project-specific principles defined yet.

**Action**: Since the constitution file at `.specify/memory/constitution.md` contains only template placeholders with no actual principles ratified, this gate is **DEFERRED** until the project constitution is established via `/speckit.constitution`.

**Recommended Next Step**: Run `/speckit.constitution` to establish core architectural principles before proceeding with implementation, OR accept that this feature will proceed without constitutional constraints (higher risk of architectural inconsistency with future features).

### Post-Design Re-evaluation (After Phase 1)

**Status**: ⚠️ Constitution still not defined - proceeding with implementation without architectural constraints

**Design Decisions Made**:
1. ✅ **Single Project Structure**: Chose single CLI/agent application (not web/mobile split)
2. ✅ **Custom Orchestration**: Chose direct Claude SDK over frameworks (LangChain/LlamaIndex)
3. ✅ **Local Storage**: Chose JSON files over databases (SQLite/PostgreSQL)
4. ✅ **Fixture-Based Testing**: Chose mocked responses for unit tests, real API for integration
5. ✅ **Session-Scoped State**: Chose in-memory state, no persistence of conversations

**Potential Constitution Violations** (if constitution existed):
- **Complexity**: 7 subdirectories in src/ (agent, generators, features, validation, analytics, models, cli) - may violate simplicity principles if defined
- **Testing Strategy**: Mix of fixture-based and real API testing - may conflict with consistency principles
- **Storage Strategy**: JSON files + potential SQLite migration - may violate data persistence principles

**Risk Assessment**:
- **Medium Risk**: Without constitution, future features may make inconsistent architecture choices
- **Recommendation**: Establish constitution via `/speckit.constitution` before feature 007 to prevent architectural drift
- **Acceptable for Current Feature**: Design decisions are well-justified in research.md and align with requirements

**Proceeding**: ✅ Gate PASSED conditionally - proceeding with implementation, but constitution should be established before next feature

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
databricks-project-templates/
├── src/
│   ├── agent/
│   │   ├── __init__.py
│   │   ├── conversation.py          # Conversational flow orchestration
│   │   ├── question_builder.py      # Clarifying question generation
│   │   └── requirements_parser.py   # Natural language → structured requirements
│   ├── generators/
│   │   ├── __init__.py
│   │   ├── project_generator.py     # Main generation orchestrator
│   │   ├── directory_builder.py     # 9-directory structure creation
│   │   ├── config_generator.py      # Environment config (local/lab/dev/prod)
│   │   ├── bundle_generator.py      # Databricks Asset Bundle YAML
│   │   ├── readme_generator.py      # Comprehensive README with diagrams
│   │   └── cicd_generator.py        # CI/CD workflow generation
│   ├── features/
│   │   ├── __init__.py
│   │   ├── base.py                  # Feature module interface
│   │   ├── streaming.py             # Streaming pipeline feature
│   │   ├── monte_carlo.py           # Monte Carlo observability
│   │   ├── data_validation.py       # Data quality validation
│   │   └── testing.py               # Testing framework setup
│   ├── validation/
│   │   ├── __init__.py
│   │   ├── structure_validator.py   # 9-directory layout validation
│   │   ├── config_validator.py      # YAML syntax validation
│   │   └── compatibility_checker.py # Python/DBR version compatibility
│   ├── analytics/
│   │   ├── __init__.py
│   │   ├── session_recorder.py      # Generation session tracking (FR-014)
│   │   ├── pattern_analyzer.py      # Template improvement analysis (FR-015)
│   │   └── anonymizer.py            # Project detail anonymization
│   ├── models/
│   │   ├── __init__.py
│   │   ├── project_requirements.py  # Pydantic model for requirements
│   │   ├── configuration_profile.py # Environment config model
│   │   ├── feature_module.py        # Feature module metadata
│   │   └── generation_session.py    # Session record model
│   └── cli/
│       ├── __init__.py
│       └── main.py                  # CLI entry point (if separate from agent)
│
├── templates/
│   ├── project_structure/           # 9-directory templates (Jinja2)
│   ├── configs/                     # YAML config templates
│   ├── bundle/                      # Asset Bundle templates
│   ├── readme/                      # README section templates
│   └── cicd/                        # CI/CD workflow templates
│       ├── github_actions/
│       ├── gitlab_ci/
│       └── azure_devops/
│
├── knowledge/
│   ├── databricks_best_practices.yaml   # Databricks recommendations
│   ├── compatibility_matrix.yaml        # Python/DBR version compatibility
│   └── default_packages.yaml            # Standard dependencies by feature
│
├── tests/
│   ├── contract/
│   │   ├── test_generated_structure.py  # Validates 9-directory layout
│   │   ├── test_config_schema.py        # Validates YAML schemas
│   │   └── test_bundle_compatibility.py # Validates Asset Bundle format
│   ├── integration/
│   │   ├── test_end_to_end_generation.py
│   │   ├── test_feature_combinations.py
│   │   └── test_conflict_detection.py
│   └── unit/
│       ├── test_conversation.py
│       ├── test_requirements_parser.py
│       ├── test_generators.py
│       └── test_validators.py
│
└── pyproject.toml
```

**Structure Decision**: Single project structure selected because:
1. This is a Python CLI/agent application, not a web or mobile app
2. All components operate within the same process (agent → generators → validators)
3. No frontend/backend separation needed
4. Template files are static assets loaded by generators
5. Knowledge base is configuration data, not executable code

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
