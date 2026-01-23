
## Troubleshooting

### Issue: `copier: command not found`

**Solution**: Install Copier:
```bash
pip install copier
```

### Issue: Python version not found

**Solution**: Install the required Python version via pyenv:
```bash
pyenv install 3.12
```

### Issue: `make: command not found` (Windows)

**Solution**:
- Install Make for Windows via Chocolatey: `choco install make`
- Or use WSL2 (Windows Subsystem for Linux)
- Or use Git Bash

### Issue: Databricks authentication fails

**Solution**:
1. Verify your Databricks workspace URL
2. Check your OAuth token or credentials
3. Re-run the authentication setup:
   ```bash
   source shared_scripts/databricks-auth-setup.sh
   ```
4. Verify your `~/.databrickscfg` file has the correct profile

### Issue: Poetry installation fails

**Solution**:
```bash
# Clear poetry cache
poetry cache clear . --all

# Reinstall
poetry install
```

### Issue: Template version conflicts

**Solution**:
```bash
# Force update to specific version
copier update --trust --vcs-ref v1.0.32 --force

# Review and resolve conflicts manually
```
