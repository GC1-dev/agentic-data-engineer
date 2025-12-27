# Package Structure - Resource Management

This project uses a specific directory structure to properly package resources while keeping them accessible during development.

## Directory Structure

```
project-root/
├── src/
│   └── agentic_data_engineer/
│       ├── __init__.py
│       ├── .claude/              (actual directory - Claude AI agents)
│       ├── .specify/             (actual directory - Specification templates)
│       ├── schema/               (actual directory - JSON schemas)
│       ├── shared_scripts/       (actual directory - Shared shell scripts)
│       └── shared_agents_usage_docs/  (actual directory - Agent documentation)
└── (symlinks at root for convenience)
    ├── .claude -> src/agentic_data_engineer/.claude
    ├── .specify -> src/agentic_data_engineer/.specify
    ├── schema -> src/agentic_data_engineer/schema
    ├── shared_scripts -> src/agentic_data_engineer/shared_scripts
    └── shared_agents_usage_docs -> src/agentic_data_engineer/shared_agents_usage_docs
```

## Why This Structure?

1. **Actual directories in package**: Resources live inside `src/agentic_data_engineer/` so they're properly packaged by Poetry
2. **Symlinks at root**: Convenience symlinks at the project root make it easy to access resources during development
3. **No duplication**: Single source of truth for all resources
4. **Clean packaging**: Poetry automatically includes everything under the package directory

## For Contributors

### Automatic Setup

Symlinks are automatically set up when you:
- Run `make setup` (recommended for new contributors)
- Run `make project-init` (full initialization)
- Run `make setup-symlinks` (just the symlinks)

### Manual Setup

If symlinks are missing or broken:

```bash
bash scripts/setup-symlinks.sh
```

Or use the Makefile:

```bash
make setup-symlinks
```

### Verification

Check if symlinks are correct:

```bash
ls -la | grep -E "(claude|specify|schema|shared)"
```

You should see symlinks (indicated by `->`) pointing to `src/agentic_data_engineer/<directory>`.

### Git Tracking

- **Actual directories**: Tracked in `src/agentic_data_engineer/`
- **Symlinks at root**: Tracked as symlinks (not as directories)

When you clone the repo on:
- **Linux/macOS**: Symlinks work natively
- **Windows**: Requires Git with symlink support (Git Bash, WSL, or `git config --global core.symlinks true`)

### Editing Resources

Edit resources directly through the symlinks at the root or navigate to `src/agentic_data_engineer/`. Both point to the same files.

Example:
```bash
# These are equivalent:
vim .claude/agents/shared/data-contract-agent.md
vim src/agentic_data_engineer/.claude/agents/shared/data-contract-agent.md
```

## For Package Consumers

When users install the package:

```bash
pip install skyscanner-agentic-data-engineer
```

They can access resources using the package API:

```python
from agentic_data_engineer import get_resource_path, list_resources

# Access any resource
schema = get_resource_path('schema/data_contract/odcs/v3.1.0/odcs-json-schema-v3.1.0.skyscanner.schema.json')
agent_doc = get_resource_path('shared_agents_usage_docs/README-data-contract-agent.md')
script = get_resource_path('shared_scripts/activate-pyenv.sh')

# List resources
schemas = list_resources('schema')
```

## Troubleshooting

**Symlinks appear as regular files or directories:**
- Delete them: `rm -rf .claude .specify schema shared_scripts shared_agents_usage_docs`
- Run setup: `bash scripts/setup-symlinks.sh`

**Symlinks are broken:**
- Run: `bash scripts/setup-symlinks.sh`
- The script automatically fixes broken symlinks

**Windows users:**
Enable symlink support in Git:
```bash
git config --global core.symlinks true
```

Then re-clone the repository.

**Resources not found when running code:**
- Ensure you've installed the package: `poetry install`
- Check resources exist: `ls src/agentic_data_engineer/`

## Build Process

When building the package (`make build` or `poetry build`):
- Poetry packages everything in `src/agentic_data_engineer/`
- Resources are included automatically (no special configuration needed)
- Symlinks at root are NOT included in the distribution (consumers don't need them)
