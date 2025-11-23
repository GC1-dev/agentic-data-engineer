# Research: Claude Agent Template System

**Date**: 2025-11-23
**Feature**: 006-claude-agent-templates

## Overview

This document resolves the "NEEDS CLARIFICATION" items from the Technical Context section of plan.md through research into best practices, technology choices, and architectural patterns for conversational AI agents that generate code projects.

---

## Research Item 1: Agent Orchestration Framework

### Decision: Custom orchestration with Claude SDK (no framework)

### Rationale:
1. **Simplicity**: The conversational flow is linear (requirements gathering → clarification → generation), not requiring complex multi-agent orchestration or memory management that LangChain/LlamaIndex provide
2. **Control**: Direct Claude API usage gives full control over prompts, context management, and response parsing without framework abstractions
3. **Dependencies**: Avoiding heavy frameworks (LangChain with 50+ dependencies) reduces installation complexity and potential conflicts
4. **Performance**: Direct API calls have lower latency than framework middleware layers
5. **Maintenance**: Fewer dependencies = less version conflict risk and easier long-term maintenance

### Alternatives Considered:
- **LangChain**: Rejected - Overkill for linear conversation flow; adds complexity with agents, chains, memory systems we don't need
- **LlamaIndex**: Rejected - Optimized for RAG (retrieval-augmented generation) over documents; our "documents" are structured templates, not unstructured knowledge
- **Custom with Claude SDK**: **SELECTED** - Sufficient for stateful conversation within a single session, simple prompt engineering, and structured output parsing

### Implementation Approach:
```python
# Lightweight conversation manager
class ConversationManager:
    def __init__(self, claude_client):
        self.client = claude_client
        self.history = []  # Session-scoped only (security requirement)

    def ask_question(self, question, context):
        # Direct Claude API call with conversation history
        pass

    def parse_requirements(self, natural_language):
        # Claude API with structured output parsing
        pass
```

---

## Research Item 2: Storage Mechanism for Pattern Analysis

### Decision: Local JSON files with optional SQLite for analytics

### Rationale:
1. **Simplicity**: JSON files are human-readable, easy to debug, and require no external dependencies
2. **Privacy**: Local storage aligns with security requirement "must not persist conversation logs beyond session" - pattern data is anonymized metadata, not full conversations
3. **Scale**: For 10-100 projects (the expected scale), file-based storage is performant enough
4. **Portability**: JSON files can be easily backed up, version controlled, or migrated to cloud storage later
5. **Analytics Evolution**: SQLite can be added later if complex queries needed (without changing data collection code)

### Alternatives Considered:
- **PostgreSQL/MySQL**: Rejected - Overkill for metadata storage; requires external database setup
- **Cloud Storage (S3, GCS)**: Rejected - Adds network dependency, auth complexity, and cost for what should be local-first tool
- **SQLite**: **CONSIDERED for Phase 2** - Good middle ground if analytics queries become complex
- **Local JSON files**: **SELECTED** - Start simple, migrate to SQLite if query complexity demands it

### Implementation Approach:
```
project_root/
└── .generation_analytics/
    ├── sessions/
    │   ├── 2025-11-23_project_a.json  # Individual session records
    │   └── 2025-11-23_project_b.json
    └── analysis_cache.json             # Aggregated patterns
```

**Session Record Schema**:
```json
{
  "session_id": "uuid",
  "timestamp": "2025-11-23T10:30:00Z",
  "project_type_hash": "hash",  # Anonymized project identifier
  "features_requested": ["streaming", "monte_carlo"],
  "questions_asked": 3,
  "generation_time_seconds": 180,
  "python_version": "3.11",
  "dbr_version": "14.3"
}
```

---

## Research Item 3: Testing Strategy for Conversational Flows

### Decision: Fixture-based testing with Claude response mocks

### Rationale:
1. **Determinism**: Tests must be reproducible - mocking Claude responses ensures consistent behavior
2. **Cost**: Real Claude API calls in CI/CD would be expensive and slow
3. **Offline Testing**: Developers should be able to run tests without network/API access
4. **Coverage**: Fixture-based approach allows testing edge cases (ambiguous input, conflicting requirements) that would be hard to trigger consistently with real API
5. **Integration Tests**: Real Claude API used in manual/nightly integration tests to validate prompt quality

### Alternatives Considered:
- **Real Claude API in tests**: Rejected - Non-deterministic, slow, expensive, requires API keys in CI/CD
- **Record/Replay (VCR.py)**: Rejected - Good for initial fixture creation, but still ties tests to specific API responses
- **Fixture-based mocking**: **SELECTED** - Fast, deterministic, offline-capable, covers edge cases
- **Hybrid approach**: **SELECTED** - Unit tests use fixtures, nightly integration tests use real API

### Implementation Approach:

**Unit Tests** (pytest with fixtures):
```python
# tests/fixtures/claude_responses.py
FIXTURE_CLARIFICATION_RESPONSE = {
    "content": "What CI/CD platform will you use?",
    "type": "clarification"
}

# tests/unit/test_conversation.py
def test_ci_cd_clarification(conversation_manager, monkeypatch):
    monkeypatch.setattr(
        "claude.Client.send_message",
        lambda *args: FIXTURE_CLARIFICATION_RESPONSE
    )
    response = conversation_manager.ask_clarifying_question(requirements)
    assert "CI/CD platform" in response.content
```

**Integration Tests** (nightly, real API):
```python
# tests/integration/test_end_to_end_with_real_claude.py
@pytest.mark.slow
@pytest.mark.requires_claude_api
def test_full_generation_workflow():
    # Uses real Claude API with pytest.ini configuration
    # Validates actual prompt quality and response parsing
    pass
```

---

## Research Item 4: Concurrent Users and Session Persistence

### Decision: Single-user, session-scoped only (no persistence)

### Rationale:
1. **Security Requirement**: Spec explicitly states "agent must not persist conversation logs beyond session"
2. **Use Case**: This is a developer CLI tool used interactively, not a multi-tenant web service
3. **Simplicity**: No need for session management, user authentication, or concurrent access control
4. **In-Memory State**: Conversation state lives only in memory during active generation session

### Alternatives Considered:
- **Multi-user with session database**: Rejected - Not a web service, adds unnecessary complexity
- **Session persistence to disk**: Rejected - Violates security requirement about conversation logs
- **In-memory session-scoped state**: **SELECTED** - Aligns with security requirements and use case

### Implementation Constraints:
- Conversation history cleared after project generation completes or session ends
- Generation session metadata (anonymized) is saved for analytics, but NOT full conversation transcripts
- If user wants to resume/modify a project later, it's a NEW session (agent doesn't remember previous conversations)

---

## Technology Stack Summary

Based on research decisions above:

### Core Dependencies:
```toml
[project.dependencies]
anthropic = ">=0.40.0"          # Claude SDK
jinja2 = ">=3.1.0"              # Template rendering
pyyaml = ">=6.0.0"              # YAML config generation
pydantic = ">=2.0.0"            # Data validation and models
click = ">=8.1.0"               # CLI interface (if standalone CLI)
```

### Development Dependencies:
```toml
[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-mock>=3.10.0",      # For mocking Claude responses
    "black>=23.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
]
```

### Storage Architecture:
- **Generated Projects**: Local filesystem
- **Session Analytics**: Local JSON files in `.generation_analytics/`
- **Templates**: Bundled Jinja2 templates in `templates/` directory
- **Knowledge Base**: YAML configuration files in `knowledge/` directory

### Testing Architecture:
- **Unit Tests**: Fixture-based mocks for Claude responses
- **Contract Tests**: Generated project structure validation
- **Integration Tests**: End-to-end with fixture responses
- **Manual/Nightly**: Real Claude API validation (optional)

---

## Architectural Patterns

### Pattern 1: Conversation State Machine

```
[Start]
  → Parse Requirements (natural language → structured)
  → Identify Ambiguities
  → Ask Clarifying Questions (loop until resolved)
  → Validate Requirements (detect conflicts)
  → Generate Project
  → Validate Output
  → Record Session Analytics
[End]
```

### Pattern 2: Feature Module System

Each optional feature (streaming, Monte Carlo, data validation) implements a common interface:

```python
class FeatureModule(ABC):
    @abstractmethod
    def applies_to(self, requirements: ProjectRequirements) -> bool:
        """Detect if this feature is needed based on requirements"""
        pass

    @abstractmethod
    def generate_files(self, project_path: Path) -> List[Path]:
        """Generate feature-specific files"""
        pass

    @abstractmethod
    def update_dependencies(self, requirements_txt: Path) -> None:
        """Add feature-specific Python packages"""
        pass
```

### Pattern 3: Validation Pipeline

```
Generated Project
  → Structure Validator (9-directory layout)
  → Config Validator (YAML syntax)
  → Compatibility Checker (Python/DBR versions)
  → Bundle Validator (Asset Bundle spec)
  → [All Pass] → Success
  → [Any Fail] → Error with details
```

---

## Best Practices Applied

### Databricks Best Practices:
1. **Medallion Architecture**: Default templates include bronze/silver/gold pipeline structure
2. **Unity Catalog**: Generated configs include catalog/schema patterns
3. **Asset Bundles**: All projects generate valid bundle.yml for deployment
4. **Environment Separation**: Distinct configs for local/lab/dev/prod

### AI Agent Best Practices:
1. **Prompt Engineering**: Use system prompts with clear instructions and examples
2. **Structured Outputs**: Request JSON/YAML responses where possible for parsing
3. **Error Recovery**: Handle API failures gracefully, allow retry
4. **Token Management**: Keep conversation history concise to avoid context limits

### Security Best Practices:
1. **No Credential Persistence**: Conversation logs not saved
2. **Anonymization**: Session analytics strip project-specific identifiers
3. **Secret Detection**: Warn if user mentions credentials in conversation
4. **Secure Defaults**: Generated .gitignore excludes common secret files

---

## Risk Mitigation

| Risk | Mitigation Strategy |
|------|-------------------|
| Claude API rate limits | Implement exponential backoff, respect rate limit headers |
| API downtime | Graceful error messages, suggest fallback to cookiecutter |
| Prompt quality degradation | Version prompts in code, maintain integration tests with real API |
| Generated code quality | Validation pipeline, contract tests, linting in generated projects |
| Security incidents | No conversation persistence, anonymized analytics, security scanning defaults |

---

## Open Questions for Implementation Phase

These items don't block planning but should be decided during implementation:

1. **CLI vs Pure Agent**: Should there be a standalone CLI entry point, or only invoked as Claude agent slash command?
2. **Cookiecutter Migration**: How to migrate existing cookiecutter templates to Jinja2 templates used by agent?
3. **Prompt Versioning**: How to version and test prompts as they evolve?
4. **Error Messages**: Specific wording for error messages (user-facing copy)
5. **Progress Indicators**: How to show progress during generation (streaming output, progress bar, etc.)?

These will be addressed during task breakdown in `/speckit.tasks`.

---

**Research Complete**: All NEEDS CLARIFICATION items resolved with justified decisions.
