# Agentic Data Engineer

[![Main](https://github.com/Skyscanner/agentic-data-engineer/actions/workflows/main.yaml/badge.svg)](https://github.com/Skyscanner/agentic-data-engineer/actions/workflows/main.yaml)

All-in-one data engineering framework with Claude AI integration.

## Overview

`skyscanner-agentic-data-engineer` is an all-in-one Python package that bundles:

- **18 Claude AI Agents** - Specialized consultants for advisory tasks (naming, modeling, architecture)
- **11 Reusable Skills** - Executable tools for actions and reference documentation
- **9 Speckit Commands** - AI-powered development workflow
- **Schema Definitions** - ODCS/ODPS data contract and product schemas
- **Shared Scripts** - Databricks authentication, environment setup utilities

### Understanding Agents vs Skills

**Agents** are consultants that Claude invokes for expert guidance and recommendations. They help with decision-making and provide contextual advice.

**Skills** are executable tools that users invoke directly or Claude uses automatically. They perform actions (formatting, linting) or provide reference documentation (library usage guides).

For detailed guidance on when to use agents vs skills, see [docs/how_to_guides/agents_vs_skills.md](docs/how_to_guides/agents_vs_skills.md).

## Setup Instructions

### Prerequisites

Before installing, ensure you have:

- **Python 3.10+** (3.12 recommended for best compatibility)
- **Poetry 2.2+** for dependency management
- **Claude Code CLI** (optional, for AI agents)
- **Databricks CLI** (optional, for MCP integration)

### Quick Start (Consumer Repos)

#### Step 1: Add Dependency

Add to your `pyproject.toml`:

```toml
[tool.poetry.dependencies]
skyscanner-agentic-data-engineer = "1.0.0"
```

#### Step 2: Install Package

```bash
# Install with Poetry
poetry install

# Or update existing installation
poetry update skyscanner-agentic-data-engineer
```

#### Step 3: Verify Installation

```bash
# Check installed version
poetry show skyscanner-agentic-data-engineer

# Expected output:
# name         : skyscanner-agentic-data-engineer
# version      : 1.0.0
# description  : All-in-one data engineering platform with Claude AI integration
```

#### What Gets Installed

After installation, all assets are automatically available:

✅ **Claude AI Assets** - 18 agents, 11 skills, 9 commands in `.claude/`
✅ **Schema Definitions** - ODCS/ODPS schemas in `shared_schema/`
✅ **Utility Scripts** - Databricks auth and environment setup in `shared_scripts/`
✅ **Documentation** - Agent usage guides in `shared_agents_usage_docs/`
✅ **Constitution Template** - Speckit workflow configuration in `.specify/`
✅ **Python Utilities** - Spark session, data utils, MCP servers

### Using the Package

#### 1. Import Python Utilities

```python
# Spark session management
from spark_session_utils import SparkSessionManager

# Core data utilities
from data_shared_utils.dataframe_utils import DataFrameUtils
```

#### 2. Use Claude AI Agents & Skills

**Agents** (Claude invokes them for advice):
```bash
# Claude automatically uses agents when you ask questions
"What should I name this Silver table for user sessions?"  # → data-naming-agent
"Help me design a star schema for bookings"                # → dimensional-modeling-agent
"Find Bronze tables for my Silver pipeline"                # → bronze-table-finder-agent
```

**Skills** (You invoke them directly):
```bash
# Format files
/makefile-formatter-skill
/pyproject-formatter-skill

# Generate code/documentation
/data-transformation-testing-skill
/mermaid-diagrams-skill

# Reference documentation
/skyscanner-data-shared-utils-skill     # Shows how to use data-shared-utils
/skyscanner-spark-session-utils-skill   # Shows how to use spark-session-utils
```

#### 3. Run Speckit Commands

```bash
# Create feature specification
/speckit.specify "Add user authentication"

# Generate implementation plan
/speckit.plan

# Generate tasks
/speckit.tasks

# Execute implementation
/speckit.implement
```

#### 4. Use Shared Scripts

```bash
# Setup Databricks authentication
source shared_scripts/databricks-auth-setup.sh

# Activate pyenv environment
source shared_scripts/activate-pyenv.sh

# Fix Databricks cache issues
./shared_scripts/fix-databricks-cache.sh

# Deploy to Databricks with retry logic (handles deployment locks)
./scripts/databricks-deploy-with-retry.sh
```

### MCP Server Setup (Optional)

For Claude Code + Databricks integration:

#### Step 1: Install MCP Dependencies

```bash
# In your consumer repo
poetry install --with mcp
```

#### Step 2: Configure Databricks

```bash
# Set environment variables
export DATABRICKS_HOST="https://skyscanner-dev.cloud.databricks.com"
export DATABRICKS_CONFIG_PROFILE="skyscanner-dev"
export DATABRICKS_WAREHOUSE_ID="your-warehouse-id"

# Authenticate with Databricks
databricks auth login --host $DATABRICKS_HOST
```

#### Step 3: Configure Claude Code MCP

Add to your `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "databricks": {
      "command": "poetry",
      "args": ["run", "python", "-m", "databricks_utils.mcp.server"],
      "env": {
        "DATABRICKS_HOST": "https://skyscanner-dev.cloud.databricks.com",
        "DATABRICKS_CONFIG_PROFILE": "skyscanner-dev",
        "DATABRICKS_WAREHOUSE_ID": "your-warehouse-id"
      }
    },
    "data-knowledge-base": {
      "command": "poetry",
      "args": ["run", "python", "-m", "data_knowledge_base_mcp.server"]
    }
  }
}
```

#### Step 4: Test MCP Connection

```bash
# In Claude Code, test MCP tools
# Use databricks__execute_query to run a simple query
```

### Troubleshooting

#### Issue: Package Not Found

```bash
# Clear Poetry cache and reinstall
poetry cache clear pypi --all
poetry install
```

#### Issue: MCP Server Not Starting

```bash
# Check Poetry environment
poetry env info

# Verify MCP dependencies installed
poetry show mcp httpx anyio

# Check logs
tail -f ~/.local/state/claude/logs/mcp*.log
```

#### Issue: Databricks Authentication Failing

```bash
# Re-authenticate
databricks auth login --host $DATABRICKS_HOST

# Verify credentials
databricks auth profiles

# Test connection
databricks warehouses list
```

#### Issue: Agents Not Available in Claude Code

1. Check `.claude/` directory exists in your project
2. Restart Claude Code
3. Verify package installed: `poetry show skyscanner-agentic-data-engineer`
4. Check Claude Code logs for errors

### Updating to New Versions

```bash
# Update to latest version
poetry update skyscanner-agentic-data-engineer

# Or specify version
poetry add skyscanner-agentic-data-engineer@1.1.0

# Verify update
poetry show skyscanner-agentic-data-engineer
```

## Package Contents

### Project Structure

This repository uses a specific structure to properly package resources while keeping them accessible during development:

```
agentic-data-engineer/
├── src/
│   └── agentic_data_engineer/           # Main Python package
│       ├── __init__.py                  # Package API for accessing resources
│       ├── .claude/                     # Claude AI assets (actual directory)
│       │   ├── agents/shared/           # 18 specialized agents
│       │   │   ├── bronze-table-finder-agent.md
│       │   │   ├── data-contract-agent.md
│       │   │   ├── data-naming-agent.md
│       │   │   ├── dimensional-modeling-agent.md
│       │   │   ├── medallion-architecture-agent.md
│       │   │   ├── project-structure-agent.md
│       │   │   ├── silver-data-modeling-agent.md
│       │   │   ├── transformation-validation-agent.md
│       │   │   ├── unity-catalog-agent.md
│       │   │   └── ... (9 more agents)
│       │   ├── commands/                # 9 speckit workflow commands
│       │   │   ├── speckit.analyze.md
│       │   │   ├── speckit.plan.md
│       │   │   ├── speckit.specify.md
│       │   │   ├── speckit.tasks.md
│       │   │   └── ... (5 more commands)
│       │   └── skills/                  # 11 reusable skills
│       │       ├── data-transformation-coding-skill/
│       │       ├── data-transformation-testing-skill/
│       │       ├── dbdiagram-skill/
│       │       ├── json-formatter-skill/
│       │       ├── makefile-formatter-skill/
│       │       ├── mermaid-diagrams-skill/
│       │       ├── pdf-creator-skill/
│       │       ├── project-linter-skill/
│       │       ├── pyproject-formatter-skill/
│       │       ├── pyspark-standards-skill/
│       │       ├── skyscanner-data-shared-utils-skill/
│       │       └── skyscanner-spark-session-utils-skill/
│       ├── .specify/                    # Speckit templates (actual directory)
│       │   └── templates/
│       ├── shared_schema/               # Schema definitions (actual directory)
│       │   ├── data_contract/           # ODCS schemas
│       │   │   └── odcs/v3.1.0/
│       │   └── data_product/            # ODPS schemas
│       │       └── odps/v1.0.0/
│       ├── shared_scripts/              # Utility scripts (actual directory)
│       │   ├── activate-pyenv.sh
│       │   ├── databricks-auth-setup.sh
│       │   ├── databricks-auth-setup-zsh.sh
│       │   └── fix-databricks-cache.sh
│       └── shared_agents_usage_docs/    # Agent documentation (actual directory)
│           └── README-*.md              # Usage guides for 21 agents
├── .claude -> src/agentic_data_engineer/.claude  # Symlink for convenience
├── .specify -> src/agentic_data_engineer/.specify
├── shared_schema -> src/agentic_data_engineer/shared_schema
├── shared_scripts -> src/agentic_data_engineer/shared_scripts
├── shared_agents_usage_docs -> src/agentic_data_engineer/shared_agents_usage_docs
├── pyproject.toml                       # Package configuration
├── Makefile                             # Build automation
└── README.md
```

**Key Points:**
- **Actual resources** live in `src/agentic_data_engineer/` (properly packaged)
- **Symlinks at root** provide convenient access during development
- **Git tracks** both the actual directories and symlinks
- **Poetry packages** everything in `src/agentic_data_engineer/` automatically

### Accessing Resources

#### In Development (This Repo)

Use symlinks at the root for convenience:
```bash
# Edit agents
vim .claude/agents/shared/data-contract-agent.md

# Use scripts
source shared_scripts/activate-pyenv.sh

# View schemas
cat shared_schema/data_contract/odcs/v3.1.0/odcs-json-schema-v3.1.0.skyscanner.schema.json
```

Or access directly:
```bash
vim src/agentic_data_engineer/.claude/agents/shared/data-contract-agent.md
```

#### In Consumer Projects (via Package)

Use the Python API to access resources:
```python
from agentic_data_engineer import get_resource_path, list_resources

# Access schema files
schema_path = get_resource_path('shared_schema/data_contract/odcs/v3.1.0/odcs-json-schema-v3.1.0.skyscanner.schema.json')

# Access agent documentation
agent_doc = get_resource_path('shared_agents_usage_docs/README-data-contract-agent.md')

# Access scripts
script_path = get_resource_path('shared_scripts/activate-pyenv.sh')

# List available resources
all_schemas = list_resources('shared_schema')
all_agents = list_resources('.claude/agents/shared')
```

### Core Dependencies (via Poetry)

| Package | Version | Description |
|---------|---------|-------------|
| `skyscanner-spark-session-utils` | >=1.0.1 | Spark session lifecycle, configuration presets, logging |
| `skyscanner-data-shared-utils` | >=1.0.2 | Core Databricks utilities, Unity Catalog ops, testing |
| `skyscanner-databricks-utils` | >=0.2.2 | MCP server for Claude Code + Databricks integration |
| `skyscanner-data-knowledge-base-mcp` | >=1.0.5 | Data knowledge base MCP integration |

### For Contributors

If you're contributing to this repository:

1. **Clone the repo:**
   ```bash
   git clone https://github.com/Skyscanner/agentic-data-engineer.git
   cd agentic-data-engineer
   ```

2. **Setup development environment:**
   ```bash
   make setup
   ```
   This automatically:
   - Installs Python dependencies via Poetry
   - Sets up convenience symlinks at project root
   - Configures pre-commit hooks

3. **Verify symlinks:**
   ```bash
   ls -la | grep -E "(claude|specify|shared)"
   ```
   You should see symlinks pointing to `src/agentic_data_engineer/`

4. **Edit resources:**
   - Edit via symlinks at root OR directly in `src/agentic_data_engineer/`
   - Both point to the same files

For more details, see [docs/RESOURCES.md](docs/RESOURCES.md).

## Makefile Integration

Add these targets to your project's Makefile:

```makefile
# Check installed version
platform-info:
	poetry show skyscanner-agentic-data-engineer
```

## Included Agents (18 Total)

Agents are **consultants** that Claude invokes for expert guidance and recommendations. They analyze context, provide advice, and help with decision-making.

| Agent | Purpose |
|-------|---------|
| `bronze-table-finder-agent` | Find and recommend Bronze tables for Silver development |
| `claude-agent-template-generator` | Create new agent templates following standards |
| `data-contract-agent` | Generate and validate ODCS data contracts |
| `data-naming-agent` | Provide naming recommendations following conventions |
| `data-profiler-agent` | Generate comprehensive data profiling reports |
| `decision-documenter-agent` | Document architectural decisions (ADRs) |
| `dimensional-modeling-agent` | Guide gold layer dimensional modeling design |
| `documentation-agent` | Create documentation, diagrams, and visual representations |
| `materialized-view-agent` | Design materialized views for query acceleration |
| `medallion-architecture-agent` | Provide architectural guidance for medallion layers |
| `project-structure-agent` | Validate project structure compliance |
| `silver-data-modeling-agent` | Entity-Centric Modeling guidance for Silver layer |
| `streaming-tables-agent` | Design streaming tables for real-time data |
| `transformation-validation-agent` | Validate transformations against standards |
| `unity-catalog-agent` | Navigate Unity Catalog and analyze metadata |
| `data-contract-formatter-agent` | Validate and format data contracts (ODCS v3.1.0) |
| `data-project-generator-agent` | Scaffold new data engineering projects |
| `claude-code-guide-agent` | Answer questions about Claude Code, SDK, and API |

## Included Skills (11 Total)

Skills are **executable tools** that users invoke directly or Claude uses automatically. They perform actions or provide reference documentation.

### Action Skills (Perform Tasks)

| Skill | Purpose |
|-------|---------|
| `data-transformation-coding-skill` | Generate PySpark transformation code |
| `data-transformation-testing-skill` | Generate comprehensive PySpark test suites |
| `json-formatter-skill` | Format, validate, and manipulate JSON data |
| `makefile-formatter-skill` | Standardize Makefiles to team conventions |
| `project-linter-skill` | Validate code quality with ruff, pytest, YAML linters |
| `pyproject-formatter-skill` | Format and validate pyproject.toml files |
| `pyspark-standards-skill` | Enforce PySpark coding standards |

### Reference Skills (Provide Documentation)

| Skill | Purpose |
|-------|---------|
| `dbdiagram-skill` | Generate database diagrams using DBML |
| `mermaid-diagrams-skill` | Create Mermaid diagrams for visualization |
| `pdf-creator-skill` | Create professional PDF documents |
| `skyscanner-data-shared-utils-skill` | PySpark data transformation utilities reference |
| `skyscanner-spark-session-utils-skill` | Spark session management utilities reference |

## Knowledge Base

The knowledge base is accessible via the `skyscanner-data-knowledge-base-mcp` package. Agents and commands reference these documents for context via the MCP server.

### Access Pattern
```
kb://document/<domain>/<document>
```

This knowledge base is managed separately and installed as a dependency.

## Speckit Workflow

Speckit provides an AI-powered development workflow:

```bash
# Create feature specification
/speckit.specify "Add user authentication feature"

# Generate implementation plan
/speckit.plan

# Clarify requirements
/speckit.clarify

# Generate tasks
/speckit.tasks

# Create checklist
/speckit.checklist

# Execute implementation
/speckit.implement

# Analyze consistency
/speckit.analyze

# Convert to GitHub issues
/speckit.taskstoissues
```

## Development Setup (Contributors)

For developing on `agentic-data-engineer` itself:

### Prerequisites

- **Python 3.10+** (3.12 recommended, managed via pyenv)
- **Poetry 2.2+** for dependency management
- **Make 3.81+** for build automation
- **Databricks CLI** for Databricks integration
- **Git** with symlink support (required for resource access)

### Setup Steps

Follow these steps in order:

#### Step 1: Clone Repository

```bash
git clone git@github.com:Skyscanner/agentic-data-engineer.git
cd agentic-data-engineer
```

**Windows Users**: Ensure Git has symlink support enabled:
```bash
git config --global core.symlinks true
# Then re-clone the repository
```
```

#### Step 2: Install pyenv and Python

```bash
# Install pyenv and configure Python version
make project-pyenv-init
```

This will:
- Install Python version from `.python-version` file
- Configure pyenv for the project
- Set up local Python environment

#### Step 3: Activate pyenv

```bash
# Activate pyenv in your current shell
source shared_scripts/activate-pyenv.sh
```

**Important**: You need to run this in every new terminal session, or add it to your shell profile.

#### Step 4: Initialize Project

```bash
# Install all dependencies and set up project
make project-init
```

This command will:
- Install Databricks CLI
- Install Poetry
- Install all Python dependencies (including MCP servers)
- Set up pre-commit hooks
- **Create convenience symlinks** at project root (`.claude`, `.specify`, `shared_schema`, `shared_scripts`, `shared_agents_usage_docs`)

#### Step 5: Verify Symlinks

After initialization, verify that symlinks were created:

```bash
# Check symlinks
ls -la | grep -E "(claude|specify|shared)"

# Expected output:
# lrwxr-xr-x .claude -> src/agentic_data_engineer/.claude
# lrwxr-xr-x .specify -> src/agentic_data_engineer/.specify
# lrwxr-xr-x shared_schema -> src/agentic_data_engineer/shared_schema
# lrwxr-xr-x shared_scripts -> src/agentic_data_engineer/shared_scripts
# lrwxr-xr-x shared_agents_usage_docs -> src/agentic_data_engineer/shared_agents_usage_docs
```

If symlinks are missing or broken, run:

```bash
make setup-symlinks
```

#### Step 6: Configure Databricks Authentication

```bash
# Set up Databricks authentication
source shared_scripts/databricks-auth-setup.sh
```

This will:
- Prompt for your Databricks host and warehouse ID
- Configure authentication via OAuth or token
- Set up environment variables

### Validation

After setup, validate your installation:

#### Check `/agents` Command

```bash
# In Claude Code, run:
/agents

# Expected output: List of 18 available agents
# - bronze-table-finder-agent
# - claude-agent-template-generator
# - data-contract-agent
# - data-naming-agent
# ... (18 total)
```

#### Check `/skills` Command

```bash
# In Claude Code, run:
/skills

# Expected output: List of 11 available skills
# - data-transformation-coding-skill
# - data-transformation-testing-skill
# - json-formatter-skill
# - makefile-formatter-skill
# ... (11 total)
```

#### Check `/mcp` Command

```bash
# In Claude Code, run:
/mcp

# Expected output: List of MCP servers
# - databricks (skyscanner-databricks-utils)
# - data-knowledge-base (skyscanner-data-knowledge-base-mcp)
```

#### Verify MCP Server Status

```bash
# Check MCP server health
poetry run python -m databricks_utils.mcp.server --help
poetry run python -m data_knowledge_base_mcp.server --help

# Both should show help output without errors
```

#### Test Databricks Connection

```bash
# List Databricks warehouses (should succeed if auth is correct)
databricks warehouses list

# Test query via MCP (in Claude Code)
# Use: databricks__execute_query("SELECT 1 as test")
```

### Common Issues

#### pyenv not activated
**Symptom**: Command not found, wrong Python version
**Fix**:
```bash
source shared_scripts/activate-pyenv.sh
```

#### MCP servers not starting
**Symptom**: `/mcp` shows errors or no servers
**Fix**:
```bash
# Reinstall MCP dependencies
poetry install --with mcp

# Check environment
poetry env info
```

#### Databricks auth failing
**Symptom**: Authentication errors when running queries
**Fix**:
```bash
# Re-run auth setup
source shared_scripts/databricks-auth-setup.sh

# Or manually authenticate
databricks auth login --host $DATABRICKS_HOST
```

### Testing & Validation

```bash
# Run all tests
make test

# Run tests with coverage
make test-cov

# Check code style
make lint

# Auto-fix code style issues
make lint-fix

# Validate package structure
make validate
```

### Building & Packaging

```bash
# Build distribution package
make build

# Build fat distribution (includes all dependencies)
make build-fat

# Build and verify contents
make build-verify

# Clean build artifacts
make clean
```

### CI/CD Pipeline

The project uses GitHub Actions for automated builds and deployments:

#### Build Jobs

On every push and pull request, the workflow runs:

1. **`build`** - Creates standard distribution package
   - Runs `make build`
   - Uploads artifacts as `dist-{run_number}`
   - Retention: 30 days

2. **`build-fat`** - Creates fat distribution with all dependencies bundled
   - Runs `make build-fat`
   - Uploads artifacts as `fatdist-{run_number}`
   - Retention: 30 days

#### Deployment Jobs

1. **`dabs-publish-dev`** - Deploys to Databricks dev workspace (on main branch)
2. **`create-deployment-version`** - Creates deployment version tracking files
3. **`publish`** - Publishes to Artifactory (on git tags only)

#### Workflow Configuration

Location: `.github/workflows/main.yaml`

Required permissions:
```yaml
permissions:
  actions: read          # Required for reusable workflows
  contents: write        # Required for creating releases
  pull-requests: write   # Required for PR operations
  id-token: write        # Required for OIDC authentication
```

#### Triggering Builds

```bash
# Trigger build on PR
git checkout -b feature/my-change
git push origin feature/my-change

# Trigger deployment to dev (main branch)
git checkout main
git push origin main

# Trigger publish to Artifactory (tag)
git tag v1.0.5
git push origin v1.0.5
```

### Daily Development Workflow

```bash
# 1. Activate pyenv (once per terminal session)
source shared_scripts/activate-pyenv.sh

# 2. Pull latest changes
git pull

# 3. Update dependencies if needed
poetry install

# 4. Make your changes
# ... edit files ...

# 5. Run tests
make test

# 6. Fix linting
make lint-fix

# 7. Commit changes
git add .
git commit -m "Your change description"

# 8. Push changes
git push
```

## Repository Structure

```
agentic-data-engineer/
├── .claude/                     # Claude Code assets
│   ├── agents/shared/           # 18 AI agents (consultants)
│   ├── commands/                # 9 Speckit commands
│   └── skills/                  # 11 reusable skills (action + reference)
├── .github/
│   └── workflows/
│       └── main.yaml            # CI/CD pipeline
├── .specify/                    # Speckit workflow templates
│   ├── templates/
│   ├── scripts/
│   └── memory/
├── docs/                        # Documentation
│   ├── how_to_guides/
│   │   └── agents_vs_skills.md  # Guide for agents vs skills
│   └── PACKAGING.md
├── shared_schema/               # Schema definitions
│   ├── data_contract/           # ODCS v3.1.0
│   └── data_product/            # ODPS v1.0.0
├── scripts/                     # Build scripts
│   └── verify-packaging.sh
├── shared_agents_usage_docs/    # Agent documentation (18 READMEs)
├── shared_scripts/              # Environment utilities (4 scripts)
├── specs/                       # Feature specifications
│   ├── 001-ai-native-data-eng-process/
│   ├── 001-makefile-build-tools/
│   └── .../
├── Makefile                     # Build automation
├── pyproject.toml               # Package configuration
├── MANIFEST.in                  # Package manifest
└── README.md                    # This file
```

## Architecture

```mermaid
flowchart TD
    subgraph Package["agentic-data-engineer Package"]
        ASSETS[Bundled Assets]
        subgraph Deps["Dependencies"]
            SSU[spark-session-utils]
            DSU[data-shared-utils]
            DBU[databricks-utils MCP]
            KBU[knowledge-base MCP]
        end
    end

    subgraph Consumer["Consumer Repo"]
        PYPROJECT[pyproject.toml]
        CLAUDE[.claude/]
        SCHEMA[schema/]
        SCRIPTS[shared_scripts/]
        CODE[Your Code]
    end

    PYPROJECT -->|poetry install| Package
    Package -->|includes| CLAUDE
    Package -->|includes| SCHEMA
    Package -->|includes| SCRIPTS
    Deps -->|import| CODE
    KBU -->|kb://| CLAUDE
```

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## License

MIT License - see LICENSE file for details.
