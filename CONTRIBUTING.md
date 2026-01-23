# Contributing to Agentic Data Engineer

Thank you for your interest in contributing to the Agentic Data Engineer project! This document provides guidelines and information for contributors at all levels.

## Table of Contents

- [Roles and Responsibilities](#roles-and-responsibilities)
- [Who Can Contribute?](#who-can-contribute)
- [How to Contribute](#how-to-contribute)
- [Definition of Done](#definition-of-done)
- [Development Guidelines](#development-guidelines)
- [Testing Requirements](#testing-requirements)
- [Getting Help](#getting-help)
- [Maintainers](#core-team)

## Roles and Responsibilities

We have three primary roles in this project:

### Maintainer

**Owns the repository and its long-term health**

Responsibilities:
- Own and manage the [agentic-data-engineer repository](https://github.com/Skyscanner/agentic-data-engineer)
- Define and evolve the repo's vision, scope, and standards
- Review and approve pull requests; ensure code quality and consistency
- Manage releases, versioning, and deprecations
- Maintain documentation and contribution guidelines
- Triage [issues](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/issues) and prioritize work
- Ensure security, compliance, and operational readiness
- Act as the primary point of contact for the repository
- Make architecture and design decisions

**Note**: A small group of maintainers manages the repository.

### Contributor

**Actively improves the repository**

Responsibilities:
- Contribute knowledge base content, agents, skills, code, tests, documentation, or examples
- Follow established coding standards and contribution guidelines
- Raise pull requests with clear context and rationale
- Review pull requests (maintainers give final sign-off)
- Respond to review feedback and iterate on changes
- Raise issues or proposals for improvements in [Jira](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/boards/7118)
- Help keep the repo healthy by fixing bugs or tech debt when possible

**Note**: Maintainers also act as contributors. Anyone at Skyscanner is welcome to contribute.

### Consumer

**Uses the repository without directly maintaining it**

Responsibilities:
- Use the repository according to documented guidelines and supported templates or interfaces
- Stay aware of version changes, deprecations, and breaking changes
- Raise [issues](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/boards/7118) or feature requests when needed
- Provide feedback on usability and gaps
- Avoid relying on undocumented or unstable internals

## Who Can Contribute?

**For Maintainers and Contributors**: Currently, the Weathervane squad members are the primary maintainers. However, anyone at Skyscanner can contribute by following the process outlined below. If you're interested in becoming a regular contributor, please reach out to the core team on [#agentic-data-engineer](https://skyscanner.slack.com/archives/agentic-data-engineer).

**For Consumers**: All data engineering teams at Skyscanner are encouraged to use this package and provide feedback through the appropriate channels.

## How to Contribute

This project operates under a **branching model with protected main branch**. To contribute:

### 1. Set Up Your Development Environment

Before making changes, ensure you have your development environment configured:

See the [Development Setup](./docs/how_to_guides/contributor_onboarding.md) for detailed setup instructions.

### 2. Create a Feature Branch

```bash
# Create a new branch from main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/your-bug-fix
```

Branch naming conventions:
- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or improvements

### 3. Make Your Changes

When making changes:

#### For Agent/Skill Development:
See the [How to add/update a specialised sub-agent](./docs/how_to_guides/add_update_specialised_sub_agents.md) for detailed setup instructions.

#### For Python Utilities:
```bash
# Edit utilities in the src directory
vim src/agentic_data_engineer/your_utility/your_file.py

# Add tests
vim tests/your_utility/test_your_file.py
```

#### For Knowledge Base:
```bash
# Knowledge base is managed in the separate skyscanner-data-knowledge-base-mcp package
# Open an issue to request knowledge base updates
```

### 4. Test Your Changes

Run the test suite to ensure your changes don't break existing functionality:

```bash
# Run all tests
make test

# Run tests with coverage
make test-cov

# Run linting
make lint

# Auto-fix linting issues
make lint-fix

# Validate package structure
make validate
```

### 5. Document Your Changes

Ensure your changes are properly documented:

- **Code comments**: Add inline comments for complex logic
- **Agent/Skill documentation**: Update usage docs in `shared_agents_usage_docs/`
- **README updates**: Update README.md if adding new features

### 6. Submit a Pull Request

```bash
# Commit your changes
git add .
git commit -m "add new data modeling agent"

# Push to your branch
git push origin feature/your-feature-name
```

**Pull Request Guidelines**:
1. Create a PR from your feature branch to `main`
2. Fill out the PR template with:
   - Clear description of changes
   - Motivation and context
   - Testing performed
   - Screenshots (if applicable)
   - Related issues/tickets
3. Request review from at least one maintainer
4. Address review feedback promptly
5. Ensure CI/CD pipeline passes (build, tests, linting)

### 7. Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
   - Build verification
   - Test execution
   - Linting checks
   - Package validation

2. **Code Review**: At least one maintainer reviews your PR
   - Code quality and standards compliance
   - Test coverage
   - Documentation completeness
   - Architecture alignment

3. **Approval**: Maintainer approves and merges the PR

### 8. After Merge

Once your PR is merged:
- Your changes are included in the next release
- The main branch is automatically deployed to dev workspace
- For production release, maintainers will tag a new version

## Definition of Done

For a pull request to be accepted, it must meet these criteria:

### Code Quality
- [ ] Code follows Python coding standards (PEP 8)
- [ ] Code follows PySpark standards (see `docs/pyspark-standards/`)
- [ ] All linting checks pass (`make lint`)
- [ ] No security vulnerabilities introduced

### Testing
- [ ] Unit tests added for new functionality
- [ ] Integration tests added where applicable
- [ ] All tests pass (`make test`)
- [ ] Test coverage maintained or improved (`make test-cov`)
- [ ] Manual testing performed (document in PR)

### Documentation
- [ ] Inline code comments added for complex logic
- [ ] Agent/skill usage documentation updated
- [ ] README.md updated if feature is user-facing
- [ ] CHANGELOG.md entry added
- [ ] Architecture decision documented (if applicable)

### Review
- [ ] Code reviewed by at least one maintainer
- [ ] Review feedback addressed
- [ ] CI/CD pipeline passes
- [ ] No merge conflicts with main branch

### For Agent/Skill Contributions
- [ ] Agent follows template structure
- [ ] Examples provided in agent documentation
- [ ] Usage guide created in `shared_agents_usage_docs/`
- [ ] Agent tested with Claude Code CLI

### For Python Utility Contributions
- [ ] Type hints added for all public functions
- [ ] Docstrings follow Google style guide
- [ ] Backward compatibility maintained or deprecation plan documented
- [ ] Dependencies added to appropriate group in `pyproject.toml`

## Development Guidelines

### Python Code Style

Follow these standards:
- **Python version**: 3.10+ (3.12 recommended)
- **Style guide**: PEP 8
- **Formatter**: `ruff` (configured in `pyproject.toml`)
- **Type hints**: Required for all public APIs
- **Docstrings**: Google style

Example:
```python
from typing import Optional

def transform_data(
    df: DataFrame,
    column_name: str,
    default_value: Optional[str] = None
) -> DataFrame:
    """Transform data by applying default values.

    Args:
        df: Input DataFrame
        column_name: Column to transform
        default_value: Default value to apply when null

    Returns:
        Transformed DataFrame

    Raises:
        ValueError: If column doesn't exist
    """
    pass
```

### PySpark Standards

Follow standards in `src/agentic_data_engineer/.claude/skills/pyspark-standards-skill/`:
- Import organization
- Configuration patterns
- Column naming conventions
- Transformation patterns
- Testing approaches

### Agent Development

When creating agents:
1. Use the `claude-agent-template-generator` agent for scaffolding
2. Follow the template structure in `.claude/agents/shared/`
3. Include clear capability descriptions
4. Provide at least 3 examples wrapped in `<example>` tags
5. Document operating principles
6. Add usage guide to `shared_agents_usage_docs/`

### Skill Development

When creating skills:
1. Distinguish between **action skills** (perform tasks) and **reference skills** (provide documentation)
2. Place in `.claude/skills/your-skill-name/`
3. Include `skill.md` with instructions
4. Add examples and test cases
5. Document in README and usage docs

### Directory Structure

Maintain the standard structure:
```
src/agentic_data_engineer/
├── .claude/               # Claude AI assets
│   ├── agents/shared/     # Agents (consultants)
│   ├── commands/          # Speckit commands
│   └── skills/            # Skills (tools)
├── shared_schema/         # Schema definitions
├── shared_scripts/        # Utility scripts
└── shared_agents_usage_docs/  # Agent documentation
```

## Testing Requirements

### Unit Tests

Write unit tests for:
- All public functions
- Edge cases and error conditions
- Data transformations

Use `pytest` framework:
```python
import pytest
from your_module import your_function

def test_your_function():
    """Test basic functionality."""
    result = your_function(input_data)
    assert result == expected_output

def test_your_function_edge_case():
    """Test edge case handling."""
    with pytest.raises(ValueError):
        your_function(invalid_input)
```

### Integration Tests

Write integration tests for:
- End-to-end workflows
- Agent/skill interactions
- MCP server functionality

### Test Coverage

Maintain test coverage:
- **Minimum**: 80% coverage for new code
- **Target**: 90%+ coverage
- Run: `make test-cov` to check coverage

## Getting Help

### Support Channels

- **Slack**: [#agentic-data-engineer](https://skyscanner.slack.com/archives/agentic-data-engineer)
- **Jira**: [ADE Project](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/issues)
- **GitHub Issues**: For bug reports and feature requests

### Documentation

- [README.md](./README.md) - Setup and usage instructions
- [docs/](./docs/) - Additional documentation
- [specs/](./specs/) - Feature specifications
- [CLAUDE.md](./CLAUDE.md) - Project instructions for AI assistants

### Common Questions

**Q: How do I add a new agent?**
A: Use the `claude-agent-template-generator` agent, follow the template structure, and add documentation to `shared_agents_usage_docs/`.

**Q: How do I test MCP servers locally?**
A: Configure `.claude/settings.local.json` with MCP server settings and use `poetry run python -m module.server` to test.

**Q: How do I update the knowledge base?**
A: The knowledge base is managed in the separate `skyscanner-data-knowledge-base-mcp` package. Open an issue in that repository.

**Q: How do I release a new version?**
A: Maintainers create git tags which trigger the CI/CD pipeline to publish to Artifactory. See RELEASING.md for details.

## Core Team

This project is maintained by the **Weathervane squad** at Skyscanner.

### Current Maintainers
- Check the [MAINTAINERS](https://flightdeck.skyscannertools.net/squads/Agentic%20Data%20Engineer) file for current maintainers
- Reach out on [#agentic-data-engineer](https://skyscanner.slack.com/archives/agentic-data-engineer) for questions

### Contact
- **Slack**: [#agentic-data-engineer](https://skyscanner.slack.com/archives/agentic-data-engineer)
- **Contributors Jira**: [ADE Contributors Project](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/boards/7018)
- **Maintainers Jira**: [ADE Maintainers Project](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/boards/7118)

---

## References

- **Jira Project**: [ADE Issues](https://skyscanner.atlassian.net/jira/software/c/projects/ADE/issues?jql=project%20%3D%20%22ADE%22%20ORDER%20BY%20created%20DESC)
- **GitHub Repository**: [agentic-data-engineer](https://github.com/Skyscanner/agentic-data-engineer)
- **CI/CD Pipeline**: `.github/workflows/main.yaml`

---

Thank you for contributing to the Agentic Data Engineer project! Your contributions help improve data engineering practices at Skyscanner.
