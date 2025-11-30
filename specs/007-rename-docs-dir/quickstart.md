# Quickstart: Rename Documentation Directory

**Feature**: 007-rename-docs-dir
**Objective**: Safely rename `docs/` to `docs-agentic-data-engineer/` and update all references

## Prerequisites

Before starting, verify:

```bash
# 1. You're on the correct feature branch
git branch --show-current  # Should show: 007-rename-docs-dir

# 2. Working tree is clean (or only has expected changes)
git status

# 3. Current docs directory exists
ls -ld docs/

# 4. New directory name doesn't already exist
ls docs-agentic-data-engineer/ 2>&1  # Should show "No such file or directory"
```

**If prerequisites fail**, resolve issues before proceeding.

## Safety: Create Backup Point

While not strictly necessary (git history provides safety), you can create a backup:

```bash
# Tag current state for easy rollback
git tag pre-docs-rename-007

# Or create a backup branch
git branch backup-pre-docs-rename
```

## Step 1: Rename Directory

Execute the git rename operation:

```bash
# Rename the directory (git tracks this automatically)
git mv docs docs-agentic-data-engineer

# Verify git recognized the rename
git status
```

**Expected output**:
```
renamed: docs/ -> docs-agentic-data-engineer/
```

**Verification**:
```bash
# New directory should exist
ls -ld docs-agentic-data-engineer/

# Old directory should be gone
ls docs/ 2>&1 | grep "No such file or directory"
```

✅ **Checkpoint**: Directory renamed successfully

## Step 2: Update Agent Configurations

Update all references in `.claude/agents/` directory.

### Files to Update

From research, these 7 files contain `docs/` references:
- `.claude/agents/architecture-agent.md`
- `.claude/agents/coding-agent.md`
- `.claude/agents/data-project-generator-agent.md`
- `.claude/agents/decision-documenter-agent.md`
- `.claude/agents/dimensional-modeling-agent.md`
- `.claude/agents/documentation-agent.md`
- `.claude/agents/testing-agent.md`

### Update Command

```bash
# Use sed to replace docs/ with docs-agentic-data-engineer/ in agent files
# (macOS version - use 'sed -i' without '' on Linux)
find .claude/agents -type f -name "*.md" -exec sed -i '' 's|docs/|docs-agentic-data-engineer/|g' {} +
```

**Linux alternative**:
```bash
find .claude/agents -type f -name "*.md" -exec sed -i 's|docs/|docs-agentic-data-engineer/|g' {} +
```

### Verification

```bash
# Should return ZERO matches
grep -r "docs/" .claude/agents/ | grep -v "docs-agentic-data-engineer"
```

✅ **Checkpoint**: Agent configs updated (zero matches expected)

## Step 3: Update Specification Files

Update references in `specs/` directory.

### Target Files

Based on research:
- `specs/001-ai-native-data-eng-process/tasks.md`
- `specs/001-ai-native-data-eng-process/plan.md`
- Any other spec files with internal `docs/` references

### Update Command

```bash
# Update all .md files in specs/ (excluding external URLs)
# This targets internal project references only
find specs -type f -name "*.md" -exec sed -i '' 's|\([^:]/\)docs/|\1docs-agentic-data-engineer/|g' {} +
```

**Explanation**: The pattern `\([^:]/\)docs/` matches `docs/` not preceded by `:` (to avoid changing `https://example.com/docs/`)

### Verification

```bash
# Check for remaining internal references (manual review may be needed)
grep -r "docs/" specs/ | grep -v "https://" | grep -v "http://"
```

**Expected**: Only external URLs or intentional references should remain

✅ **Checkpoint**: Spec files updated

## Step 4: Update Root-Level Documentation

Update markdown files in project root and other locations.

### Files to Check

- `IMPLEMENTATION_SUMMARY.md`
- `README.md` (if exists)
- `CLAUDE.md`
- Any other root-level `.md` files

### Update Command

```bash
# Update root-level markdown files (careful to preserve external URLs)
find . -maxdepth 1 -type f -name "*.md" -exec sed -i '' 's|\([^:]/\)docs/|\1docs-agentic-data-engineer/|g' {} +
```

### Manual Review Required

Some files may need manual review to ensure context is correct:

```bash
# List files that were potentially updated
find . -maxdepth 1 -type f -name "*.md" -exec grep -l "docs-agentic-data-engineer" {} +
```

Open each file and verify changes make sense.

✅ **Checkpoint**: Root documentation updated

## Step 5: Update Configuration Files (If Any)

Check for references in configuration files:

```bash
# Search in common config files
grep -r "docs/" pyproject.toml Makefile *.json *.yml *.yaml 2>/dev/null || echo "No matches in config files"
```

**If matches found**: Update manually, as these are often context-sensitive.

✅ **Checkpoint**: Configuration files checked

## Step 6: Comprehensive Verification

Run full verification suite:

### 6.1 Directory Structure

```bash
# Verify new directory exists with content
ls -la docs-agentic-data-engineer/ | head -10

# Verify old directory is gone
ls docs/ 2>&1
```

**Expected**: New directory shows files, old directory shows "No such file or directory"

### 6.2 Agent Configurations (Critical)

```bash
# MUST return zero matches (excluding "docs-agentic-data-engineer")
grep -r "docs/" .claude/agents/ | grep -v "docs-agentic-data-engineer" | wc -l
```

**Expected**: `0`

### 6.3 Markdown Files (Project-Wide)

```bash
# Search all markdown files (excluding external URLs and submodules)
grep -r "docs/" --include="*.md" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  . | grep -v "https://" | grep -v "http://" | grep -v "docs-agentic-data-engineer"
```

**Expected**: Zero matches OR only acceptable exclusions (changelogs, historical references)

### 6.4 Git History Verification

```bash
# Verify git preserved history
git log --follow --oneline docs-agentic-data-engineer/ | head -5
```

**Expected**: Shows commit history from before the rename

### 6.5 Success Criteria Verification

Review against spec.md success criteria:

- ✅ **SC-001**: Directory `docs-agentic-data-engineer` exists: `ls -ld docs-agentic-data-engineer/`
- ✅ **SC-002**: Zero `docs/` in `.claude/agents`: (verified above)
- ✅ **SC-003**: Zero `docs/` in markdown files: (verified above)
- ✅ **SC-004**: All links resolve: (manual spot-check recommended)
- ✅ **SC-005**: Git tracks rename: `git status` shows rename
- ✅ **SC-006**: Only acceptable exclusions: (verified above)

## Step 7: Commit Changes

If all verifications pass, commit the changes:

```bash
# Stage all changes (directory rename + file updates)
git add -A

# Verify what will be committed
git status

# Create commit with clear message
git commit -m "Rename docs/ to docs-agentic-data-engineer/

- Rename directory using git mv to preserve history
- Update all references in .claude/agents/ configurations
- Update references in specs/ documentation
- Update root-level markdown files
- Verified zero broken references remain

Closes #007-rename-docs-dir"
```

**Commit checklist**:
- [ ] Directory rename tracked by git
- [ ] All agent config updates included
- [ ] All markdown file updates included
- [ ] No unintended changes included

## Step 8: Final Validation

After committing:

```bash
# Verify commit looks correct
git show --name-status HEAD | head -30

# Verify branch is clean
git status

# Check git log shows rename
git log --follow --oneline docs-agentic-data-engineer/ | head -3
```

✅ **Complete**: All changes committed successfully

## Rollback Procedure

If issues are discovered **before committing**:

```bash
# Discard all changes
git reset --hard HEAD

# Verify rollback
git status  # Should show "nothing to commit, working tree clean"
ls docs/    # Should exist again
```

If issues discovered **after committing**:

```bash
# Revert the commit
git revert HEAD

# Or reset to before rename (using tag from safety step)
git reset --hard pre-docs-rename-007
```

## Next Steps

After successful completion:

1. **Push to remote** (if ready):
   ```bash
   git push origin 007-rename-docs-dir
   ```

2. **Inform team**: Notify other developers of the path change so they can update their branches

3. **Update dependent branches**: Any in-flight branches referencing `docs/` will need:
   ```bash
   # On other branch
   git rebase 007-rename-docs-dir
   # Or merge
   git merge 007-rename-docs-dir
   ```

4. **Consider PR**: Create pull request to merge into main branch

## Troubleshooting

### Issue: Sed command not working on macOS

**Symptom**: `sed: 1: "...": command c expects \ followed by text`

**Solution**: Use `-i ''` (with space and empty quotes):
```bash
sed -i '' 's|docs/|docs-agentic-data-engineer/|g' file.md
```

### Issue: Found unexpected docs/ references

**Symptom**: Verification grep finds unintended matches

**Solution**:
1. Review each match manually
2. Determine if it's:
   - External URL → leave unchanged
   - Submodule path → leave unchanged
   - Internal reference → update manually
3. Re-run verification

### Issue: Git shows rename as delete + add

**Symptom**: `git status` shows deleted and untracked instead of rename

**Solution**: Git similarity detection should handle this automatically when you commit. If concerned:
```bash
git add -A
git status  # Should now show rename
```

## Summary

This quickstart provides:
- ✅ Pre-execution safety checks
- ✅ Step-by-step rename and update commands
- ✅ Comprehensive verification at each step
- ✅ Rollback procedures if needed
- ✅ Troubleshooting for common issues

**Estimated time**: 15-30 minutes (including verification)

**Risk level**: Low (git history preserved, changes reversible)
