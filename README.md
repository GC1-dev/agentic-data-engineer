# Agentic Data Engineer

All-in-one data engineering platform with Claude AI integration.

## Overview

`skyscanner-agentic-data-engineer` is an all-in-one Python package that bundles:

- **21 Claude AI Agents** - Specialized agents for data engineering tasks
- **9 Speckit Commands** - AI-powered development workflow
- **5 Reusable Skills** - JSON, Mermaid diagrams, PDF generation, and more
- **Schema Definitions** - ODCS/ODPS data contract and product schemas
- **Shared Scripts** - Databricks authentication, environment setup utilities

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

✅ **Claude AI Assets** - 21 agents, 9 commands, 5 skills in `.claude/`
✅ **Schema Definitions** - ODCS/ODPS schemas in `schema/`
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

#### 2. Use Claude AI Agents

Agents are automatically available in Claude Code:

```bash
# Example: Use the bronze-table-finder agent
# In Claude Code, reference the agent
"Use bronze-table-finder-agent to find source tables for my Silver user_session"
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

### Core Dependencies (via Poetry)

| Package | Version | Description |
|---------|---------|-------------|
| `skyscanner-spark-session-utils` | >=1.0.1 | Spark session lifecycle, configuration presets, logging |
| `skyscanner-data-shared-utils` | >=1.0.2 | Core Databricks utilities, Unity Catalog ops, testing |
| `skyscanner-databricks-utils` | >=0.2.2 | MCP server for Claude Code + Databricks integration |
| `skyscanner-data-knowledge-base-mcp` | >=1.0.5 | Data knowledge base MCP integration |

### Bundled Assets (Automatically Included)

```
your-project/
├── .claude/
│   ├── agents/shared/           # 21 specialized agents
│   │   ├── bronze-table-finder-agent.md
│   │   ├── claude-agent-template-generator.md
│   │   ├── coding-agent.md
│   │   ├── data-contract-agent.md
│   │   ├── data-naming-agent.md
│   │   ├── data-profiler-agent.md
│   │   ├── data-project-generator-agent.md
│   │   ├── decision-documenter-agent.md
│   │   ├── dimensional-modeling-agent.md
│   │   ├── documentation-agent.md
│   │   ├── makefile-formatter-agent.md
│   │   ├── materialized-view-agent.md
│   │   ├── medallion-architecture-agent.md
│   │   ├── project-structure-agent.md
│   │   ├── pyproject-formatter-agent.md
│   │   ├── pyspark-standards-agent.md
│   │   ├── silver-data-modeling-agent.md
│   │   ├── streaming-tables-agent.md
│   │   ├── testing-agent.md
│   │   ├── transformation-validation-agent.md
│   │   └── unity-catalog-agent.md
│   ├── commands/                # 9 speckit workflow commands
│   │   ├── speckit.analyze.md
│   │   ├── speckit.checklist.md
│   │   ├── speckit.clarify.md
│   │   ├── speckit.constitution.md
│   │   ├── speckit.implement.md
│   │   ├── speckit.plan.md
│   │   ├── speckit.specify.md
│   │   ├── speckit.tasks.md
│   │   └── speckit.taskstoissues.md
│   └── skills/                  # 5 reusable skills
│       ├── dbdiagram-skill/
│       ├── json-formatter-skill/
│       ├── mermaid-diagrams-skill/
│       ├── pdf-creator-skill/
│       └── recommend_silver_data_model-skill/
├── schema/                      # Schema definitions
│   ├── data_contract/           # ODCS schemas
│   │   └── odcs/v3.1.0/
│   └── data_product/            # ODPS schemas
│       └── odps/v1.0.0/
├── shared_scripts/              # Utility scripts
│   ├── activate-pyenv.sh
│   ├── databricks-auth-setup.sh
│   ├── databricks-auth-setup-zsh.sh
│   └── fix-databricks-cache.sh
└── shared_agents_usage_docs/    # Agent documentation
    └── README-*.md              # Usage guides for each agent
```

## Makefile Integration

Add these targets to your project's Makefile:

```makefile
# Check installed version
platform-info:
	poetry show skyscanner-agentic-data-engineer
```

## Included Agents (21 Total)

| Agent | Purpose |
|-------|---------|
| `bronze-table-finder` | Discover and analyze Bronze layer tables |
| `claude-agent-template-generator` | Create new agent templates |
| `coding-agent` | General code implementation |
| `data-contract-agent` | Generate and validate ODCS data contracts |
| `data-naming-agent` | Naming conventions and consistency |
| `data-profiler` | Data analysis and statistical profiling |
| `data-project-generator` | Scaffold new data engineering projects |
| `decision-documenter` | Document architectural decisions |
| `dimensional-modeling` | Design fact and dimension tables |
| `documentation-agent` | Generate technical documentation |
| `makefile-formatter-agent` | Format and validate Makefiles |
| `materialized-view-agent` | Design materialized views for Databricks |
| `medallion-architecture` | Design Bronze/Silver/Gold layers |
| `project-structure-agent` | Scaffold and organize project structure |
| `pyproject-formatter-agent` | Format and validate pyproject.toml files |
| `pyspark-standards-agent` | Enforce PySpark coding standards |
| `silver-data-modeling` | Entity-Centric Modeling for Silver layer |
| `streaming-tables-agent` | Design streaming table pipelines |
| `testing-agent` | Test development and QA |
| `transformation-validation-agent` | Validate data transformations |
| `unity-catalog-agent` | Unity Catalog management and operations |

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

- Python 3.10+ (via pyenv, 3.12 recommended)
- Poetry 2.2+
- Make 3.81+

### Setup

```bash
# Clone repository
git clone git@github.com:Skyscanner/agentic-data-engineer.git
cd agentic-data-engineer

# Setup environment
make setup

# Or manually:
pyenv install 3.12.12
pyenv local 3.12.12
poetry install
```

### MCP Server Setup

For Claude Code integration with Databricks:

```bash
# Install MCP dependencies
make setup-mcp

# Configure environment
export DATABRICKS_HOST="https://skyscanner-dev.cloud.databricks.com"
export DATABRICKS_WAREHOUSE_ID="your-warehouse-id"

# Authenticate
databricks auth login --host $DATABRICKS_HOST
```

### Testing

```bash
make test          # Run tests
make test-cov      # Run with coverage
make lint          # Check code style
make lint-fix      # Fix code style
```

### Building & Packaging

```bash
make build         # Build distribution
make validate      # Validate package structure
```

## Repository Structure

```
agentic-data-engineer/
├── .claude/                     # Claude Code assets
│   ├── agents/shared/           # 21 AI agents
│   ├── commands/                # 9 Speckit commands
│   └── skills/                  # 5 reusable skills
├── .github/
│   └── workflows/
│       └── main.yaml            # CI/CD pipeline
├── .specify/                    # Speckit workflow templates
│   ├── templates/
│   ├── scripts/
│   └── memory/
├── docs/                        # Documentation
│   └── PACKAGING.md
├── schema/                      # Schema definitions
│   ├── data_contract/           # ODCS v3.1.0
│   └── data_product/            # ODPS v1.0.0
├── scripts/                     # Build scripts
│   └── verify-packaging.sh
├── shared_agents_usage_docs/    # Agent documentation (21 READMEs)
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
