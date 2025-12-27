# Package Structure - Symlinks

This project uses symlinks to avoid duplicating resource directories in the package structure.

## Directory Structure

```
project-root/
├── .claude/              (actual directory - Claude AI agents)
├── .specify/             (actual directory - Specification templates)
├── schema/               (actual directory - JSON schemas)
├── shared_scripts/       (actual directory - Shared shell scripts)
├── shared_agents_usage_docs/  (actual directory - Agent documentation)
└── src/
    └── agentic_data_engineer/
        ├── __init__.py
        ├── .claude -> ../../.claude  (symlink)
        ├── .specify -> ../../.specify  (symlink)
        ├── schema -> ../../schema  (symlink)
        ├── shared_scripts -> ../../shared_scripts  (symlink)
        └── shared_agents_usage_docs -> ../../shared_agents_usage_docs  (symlink)
```

## For Contributors

### Automatic Setup

The symlinks are automatically set up when you:
- Run `make setup` (recommended for new contributors)
- Run `make setup-symlinks` (just the symlinks)
- Check out a branch (via git post-checkout hook)
- Pull changes (via git post-merge hook with pre-commit)

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
ls -la src/agentic_data_engineer/
```

You should see symlinks (indicated by `->`) pointing to `../../<directory>`.

### Git Tracking

Git tracks these as symlinks (not as directories). When you clone the repo on:
- **Linux/macOS**: Symlinks work natively
- **Windows**: Requires Git with symlink support enabled (Git Bash or WSL recommended)

### Troubleshooting

**Symlinks appear as regular files or directories:**
- Delete them: `rm -rf src/agentic_data_engineer/{.claude,.specify,schema,shared_scripts,shared_agents_usage_docs}`
- Run setup: `bash scripts/setup-symlinks.sh`

**Symlinks are broken:**
- Run the setup script: `bash scripts/setup-symlinks.sh`
- It will automatically fix broken symlinks

**Windows users:**
Enable symlink support in Git:
```bash
git config --global core.symlinks true
```

Then re-clone the repository.

## Why Symlinks?

1. **No duplication**: Resource directories exist once at the root
2. **Easier development**: Edit resources in their natural location
3. **Package compatibility**: Poetry/pip can find and package the resources
4. **Version control**: Single source of truth for all resources
