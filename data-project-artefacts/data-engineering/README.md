# Data Project Artefacts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Reusable project artefacts and templates for Databricks data engineering projects following Skyscanner's medallion architecture and best practices.

## Overview

This directory contains standardized project artefacts that can be used as templates or references for new Databricks data engineering projects. These artefacts embody organizational best practices and are designed to work with the AI agents in `.claude/agents/` and `.github/agents/`.

## Contents

### Configuration Files

#### `pyproject.toml`
Python project configuration using Poetry package manager:
- **Python version**: 3.10+ (Databricks Runtime 12.2 LTS compatible)
- **Package management**: Poetry-based with Skyscanner Artifactory
- **Dependencies**:
  - `sqlglot>=27.0.0` - SQL parsing and query rewriting
  - `databricks-cli>=0.18.0` - Databricks CLI integration
  - `pycarlo>=0.12.28` - Monte Carlo data observability
- **Linting**: ruff, mypy, black, isort
- **Testing**: pytest with coverage

**Template variables** (replace when using):
- `{{git-repo-name}}` - Repository name
- `{{git repo description}}` - Project description
- `{{squad name}}` - Owning team name
- `{{aws project tag}}` - AWS project tag
- `{{squad name}}` - Owning team name
- `{{slackChannel}}` - Slack channel

#### `databricks.yaml`
Databricks Asset Bundle (DAB) configuration:
- **Bundle definition**: Project packaging and deployment
- **Artifact building**: Poetry wheel build with dependencies
- **Variables**:
  - `env` - Environment (dev/staging/prod)
  - `squad` - Owning team name
  - `project` - AWS project name
  - `service_principal_application_id` - Deployment credentials

**Template variables**:
- `{{repo_name}}` - Repository name
- `{{owner_team}}` - Squad name
- `{{dev_sp}}` - Service principal for dev environment
- `{{prod_sp}}` - Service principal for prod environment

#### `Makefile`
Build automation with comprehensive targets:
- **Environment setup**: pyenv, poetry, python version management
- **Development tools**: MCP server setup, pre-commit hooks
- **Quality checks**: linting (ruff), formatting, type checking (mypy)
- **Testing**: pytest with coverage reporting
- **Build**: wheel packaging, dependency management
- **Deployment**: Databricks CLI integration

**Key targets**:
```bash
make help                    # Show all available targets
make project_pyenv_init      # Initialize pyenv and Python version
make setup                   # Full project setup (pyenv + poetry + deps + hooks)
make install-deps            # Install project dependencies
make install-hooks           # Install pre-commit hooks
make lint                    # Run ruff linter
make format                  # Format code with ruff
make test                    # Run pytest suite
make test-cov                # Run tests with coverage
make build                   # Build wheel package
make clean                   # Clean build artifacts
```

#### `pytest.ini`
Pytest configuration:
- Test discovery patterns
- Coverage settings
- Output formatting
- Markers for test categorization

#### `.gitignore`
Comprehensive ignore patterns:
- Python artifacts (`__pycache__`, `*.pyc`, `*.pyo`)
- Virtual environments (`.venv/`, `venv/`)
- Build artifacts (`dist/`, `build/`, `*.egg-info/`)
- IDE files (`.vscode/`, `.idea/`)
- Testing artifacts (`.pytest_cache/`, `.coverage`, `htmlcov/`)
- Databricks artifacts (`dependency_wheels/`, `requirements-dabs.txt`)

#### `.pre-commit-config.yaml`
Pre-commit hooks for code quality:
- Trailing whitespace removal
- End-of-file fixing
- YAML validation
- Large file prevention
- ruff linting and formatting

#### `.yamllint`
YAML linting configuration for consistent YAML formatting

#### `.jsonlintrc`
JSON linting configuration

#### `.mcp.json`
Model Context Protocol (MCP) server configuration:
- Data knowledge base MCP server integration
- Knowledge base path configuration

#### `CLAUDE.md`
AI-generated development guidelines tracking:
- Active technologies across features
- Project structure
- Common commands
- Code style guidelines
- Recent changes log

### GitHub Integration

#### `.github/agents/`
Speckit agents for AI-assisted development workflow:
- `speckit.specify.agent.md` - Feature specification generation
- `speckit.clarify.agent.md` - Requirement clarification
- `speckit.constitution.agent.md` - Project principles management
- `speckit.plan.agent.md` - Implementation planning
- `speckit.checklist.agent.md` - Quality checklist generation
- `speckit.tasks.agent.md` - Task breakdown
- `speckit.implement.agent.md` - Task implementation
- `speckit.taskstoissues.agent.md` - GitHub issue creation
- `speckit.analyze.agent.md` - Cross-artifact consistency checks

#### `.github/prompts/`
Prompt templates for each Speckit agent (corresponding `.prompt.md` files)

#### `.github/workflows/`
GitHub Actions CI/CD workflows (to be added based on project needs)

#### `.github/pull_request_template.md`
Standardized pull request template

## Recommended Project Structure

When using these artefacts, your complete project should follow this structure:

```
project-name/
├── .github/                    # GitHub integration (from artefacts)
│   ├── agents/                 # Speckit agents
│   ├── prompts/                # Agent prompts
│   ├── workflows/              # CI/CD workflows
│   └── pull_request_template.md
├── .claude/                    # Claude AI configuration (create this)
│   ├── agents/                 # Custom Claude agents for your project
│   ├── commands/               # Custom slash commands
│   └── skills/                 # Custom skills
├── .specify/                   # Speckit state management (create this)
│   ├── memory/                 # Feature specifications and plans
│   │   ├── constitution.md     # Project principles
│   │   └── features/           # Feature-specific artifacts
│   ├── templates/              # Custom templates
│   └── scripts/                # Speckit automation scripts
│       └── bash/
│           ├── check-prerequisites.sh   # Validate environment setup
│           ├── common.sh                # Shared utility functions
│           ├── create-new-feature.sh    # Initialize new feature
│           ├── setup-plan.sh            # Set up planning artifacts
│           └── update-agent-context.sh  # Update agent context
├── config/                     # Environment configurations (create this)
│   ├── local.yaml              # Local development
│   ├── dev.yaml                # Development environment
│   ├── staging.yaml            # Staging environment
│   ├── prod.yaml               # Production environment
│   └── project.yaml            # Project-wide settings
├── scripts_shared/             # Shared utility scripts (create this)
│   ├── activate-pyenv.sh              # Activate pyenv environment
│   ├── databricks-auth-setup.sh       # Configure Databricks authentication
│   ├── databricks-auth-setup-zsh.sh   # Databricks auth for Zsh shell
│   └── fix-databricks-cache.sh        # Fix Databricks cache issues
├── src/                        # Source code (create this)
│   ├── bronze/                 # Bronze layer transformations
│   ├── silver/                 # Silver layer transformations
│   ├── gold/                   # Gold layer transformations
│   └── utils/                  # Shared utilities
├── tests/                      # Test suite (create this)
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── conftest.py             # Pytest fixtures
├── docs/                       # Documentation (create this)
│   ├── architecture.md         # Architecture overview
│   ├── data-model.md          # Data model documentation
│   └── runbook.md             # Operational runbook
├── pyproject.toml             # From artefacts
├── databricks.yaml            # From artefacts
├── Makefile                   # From artefacts
├── pytest.ini                 # From artefacts
├── .catalog.yml               # Service catalog metadata (create this)
├── .gitignore                 # From artefacts
├── .pre-commit-config.yaml    # From artefacts
├── .mcp.json                  # From artefacts
├── CLAUDE.md                  # From artefacts (auto-updated)
└── README.md                  # Create project-specific README
```

### Directory Purposes

**`.claude/`** - Claude AI integration
- Store custom agents specific to your project
- Define project-specific slash commands
- Add custom skills for repeated tasks

**`.specify/`** - Speckit state and artifacts
- `memory/` - Stores feature specifications, plans, and constitution
- `templates/` - Custom templates for your workflow
- `scripts/` - Automation scripts for feature management

**`config/`** - Environment-specific configurations
- YAML files for each environment (local, dev, staging, prod)
- Database connections, API endpoints, compute resources
- Feature flags and environment variables

**`scripts_shared/`** - Automation and utility scripts
- `activate-pyenv.sh` - Activate pyenv environment
- `databricks-auth-setup.sh` - Configure Databricks authentication (Bash)
- `databricks-auth-setup-zsh.sh` - Configure Databricks authentication (Zsh)
- `fix-databricks-cache.sh` - Fix Databricks cache issues

**`.catalog.yml`** - Service catalog metadata
- Component name, owner, and description
- Personal data handling classification
- SOX scope and payment processing flags
- AWS project tags and service class
- Support channels (Slack)
- Security checklist ID

**`src/`** - Source code organized by medallion layer
- `bronze/` - Raw data ingestion
- `silver/` - Cleaned and validated data
- `gold/` - Business aggregations and metrics
- `utils/` - Shared utility functions

## Usage

### As a Reference

Use these files as a reference when creating new projects:

1. Copy relevant configuration files to your new project
2. Replace template variables with your project values
3. Run `make setup` to initialize the project
4. Customize based on your specific requirements

### Template Variables to Replace

When using these artefacts, replace the following template variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{git-repo-name}}` | Repository name | `databricks-session-pipeline` |
| `{{git repo description}}` | Project description | `Session data processing pipeline` |
| `{{squad name}}` | Owning team name | `data-platform-team` |
| `{{repo_name}}` | Repository name (snake_case) | `databricks_session_pipeline` |
| `{{owner_team}}` | Squad name | `data-platform` |
| `{{dev_sp}}` | Dev service principal | `app-id-12345` |
| `{{prod_sp}}` | Dev service principal | `app-id-23353` |

### Quick Start

1. **Copy artefacts to new project**:
   ```bash
   cp data-project-artefacts/{pyproject.toml,Makefile,databricks.yaml,pytest.ini} my-new-project/
   cp -r data-project-artefacts/.github my-new-project/
   ```

2. **Replace template variables**:
   ```bash
   cd my-new-project
   # Use sed or your editor to replace {{variables}}
   ```

3. **Initialize project**:
   ```bash
   make setup
   ```

4. **Verify setup**:
   ```bash
   make validate
   make test
   ```

## Integration with AI Agents

These artefacts are designed to work seamlessly with:

### Claude Agents (`.claude/agents/shared/`)
- `data-project-generator-agent` - Generates projects using these templates
- `project-structure-agent` - Validates project structure against these standards
- `pyspark-standards-agent` - Enforces code standards defined in configurations
- `transformation-validation-agent` - Validates transformations follow patterns

### Speckit Agents (`.github/agents/`)
- Full feature development lifecycle support
- Automated specification, planning, and implementation
- Quality checks and GitHub integration

## Project Standards

### Python Version
- **Minimum**: Python 3.10 (Databricks Runtime 12.2 LTS)
- **Managed by**: pyenv (see `.python-version`)

### Package Management
- **Tool**: Poetry 2.2+
- **Repository**: Skyscanner Artifactory
- **Lock file**: `poetry.lock` (not included in artefacts, generated per project)

### Code Quality
- **Linter**: ruff 0.11+
- **Formatter**: ruff format
- **Type checker**: mypy
- **Import sorting**: isort (via ruff)

### Testing
- **Framework**: pytest
- **Coverage**: pytest-cov with minimum thresholds
- **Structure**: `tests/unit/` and `tests/integration/`

### CI/CD
- **Deployment**: Databricks Asset Bundles (DAB)
- **Build**: Poetry wheel packaging
- **Environments**: dev, staging, prod

## Best Practices

1. **Always run `make setup`** after cloning or copying these artefacts
2. **Use `make validate`** to check project health
3. **Run `make lint` and `make test`** before committing
4. **Update `CLAUDE.md`** when adding new features (auto-generated by Speckit)
5. **Keep dependencies up to date** with `poetry update`
6. **Use pre-commit hooks** to maintain code quality

## Customization

### Adding New Dependencies

```bash
poetry add package-name
poetry add --group dev dev-package-name
```

### Adding New Make Targets

Edit `Makefile` and add your target following the existing pattern:
```makefile
.PHONY: my-target
my-target: ## Description of my target
	@echo "Running my target"
	# Your commands here
```

### Modifying Build Process

1. Update `databricks.yaml` for bundle configuration
2. Update `Makefile` for build automation
3. Update `.github/workflows/` for CI/CD (when added)

## Version History

- **v1.0.0** (2024-12-24): Initial artefacts
  - Poetry-based pyproject.toml
  - Databricks Asset Bundle configuration
  - Comprehensive Makefile with build automation
  - Speckit agent integration
  - MCP server configuration

## Contributing

When updating these artefacts:

1. Test changes with a real project
2. Update this README with new features
3. Ensure backward compatibility with existing projects
4. Document any breaking changes

## Related Documentation

- [Databricks Asset Bundles](https://docs.databricks.com/dev-tools/bundles/index.html)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [Ruff Linter](https://docs.astral.sh/ruff/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Speckit Framework](../.github/agents/README.md)
- [Claude Agents](../.claude/agents/README.md)

## Support

For questions or issues:
- Check existing projects using these artefacts for examples
- Consult the AI agents for guidance: `data-project-generator-agent`, `project-structure-agent`
- Review Skyscanner data engineering documentation
- Contact: #data-engineering-support (Slack)

## License

MIT License - see [LICENSE](../LICENSE) file for details.
