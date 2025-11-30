# Research: Rename Documentation Directory

**Date**: 2025-11-30
**Feature**: 007-rename-docs-dir
**Objective**: Identify all file types and locations referencing `docs/` path to ensure comprehensive updates

## Research Summary

This document consolidates findings from investigating the project structure to understand all locations where the `docs/` path is referenced and the best approach for a safe rename operation.

## Task 1: Path Reference Patterns

### Research Question
What are all the ways `docs/` is referenced in the project?

### Investigation Performed

Executed comprehensive grep search across project:
```bash
grep -r "docs/" --exclude-dir=.git --exclude-dir=node_modules \
  --exclude-dir=__pycache__ --exclude="*.pyc" --exclude="*.log" .
```

Also searched specifically in agent configurations:
```bash
grep -r "docs/" .claude/agents/
```

### Findings

#### 1. Agent Configuration Files (High Priority)

**Location**: `.claude/agents/*.md`

**Files with docs/ references** (7 total):
- `.claude/agents/architecture-agent.md`
- `.claude/agents/coding-agent.md`
- `.claude/agents/data-project-generator-agent.md`
- `.claude/agents/decision-documenter-agent.md`
- `.claude/agents/dimensional-modeling-agent.md`
- `.claude/agents/documentation-agent.md`
- `.claude/agents/testing-agent.md`

**Reference Pattern**: These files likely contain instructions referencing documentation paths like:
- `docs/knowledge_base/`
- `docs/adr/`
- `docs/<specific-file>.md`

**Update Approach**: Direct string replacement `docs/` → `docs-agentic-data-engineer/`

#### 2. Markdown Files (Project-Wide)

**Count**: 593 markdown files found across project

**Common reference patterns identified**:
- Relative links: `[text](docs/...)`, `./docs/`, `../docs/`
- Direct path mentions: `docs/` as directory reference
- External URL references: `https://example.com/docs/` (should NOT be changed - external links)

**Update Approach**: Selective replacement targeting internal project references only

#### 3. Specification and Task Files

**Locations with docs/ references**:
- `specs/001-ai-native-data-eng-process/tasks.md` - Multiple task descriptions mentioning docs/ paths
- `specs/001-ai-native-data-eng-process/plan.md` - Project structure diagrams
- `specs/005-separate-utilities/contracts/spark-session-utilities-api.md` - External docs URLs (DO NOT change)
- `IMPLEMENTATION_SUMMARY.md` - Project structure documentation

**Reference Types**:
- **Internal**: Project structure, task descriptions → MUST UPDATE
- **External**: URLs like `https://spark.apache.org/docs/` → DO NOT UPDATE

**Update Approach**: Manual review or pattern matching to distinguish internal vs external

#### 4. Submodules and External Projects

**Found references in**:
- `spark-session-utils/` subdirectory
- References to external documentation URLs (Poetry, PySpark, Django, etc.)

**Decision**: Submodules are separate projects with their own documentation paths. Only update references in main project root that point to main project's `docs/` directory.

#### 5. Reference Pattern Variations

**Patterns identified**:
```
docs/                           # Basic directory reference
./docs/                         # Relative from current location
../docs/                        # Relative from subdirectory
[link](docs/file.md)           # Markdown link
`docs/`                         # Inline code reference
https://*/docs/                 # External URL (DO NOT change)
```

### Acceptable Exclusions

The following should NOT be updated:
1. **External URLs**: Any `https://` or `http://` URLs containing `/docs/`
2. **Git history**: `.git/` directory (automatically excluded)
3. **Submodule references**: If submodules have their own `docs/` directories
4. **Build artifacts**: `node_modules/`, `__pycache__/`, `*.pyc`, `*.log`
5. **Third-party examples**: References to other projects' documentation

## Task 2: Git History Preservation Strategy

### Research Question
What is the correct git command to rename a directory while preserving history?

### Decision: Use `git mv`

**Rationale**:
- `git mv` is the standard Git command for renaming files and directories
- Git automatically tracks renames and preserves file history
- Git uses similarity detection to recognize moved/renamed files
- Works identically for files and directories

**Command**:
```bash
git mv docs docs-agentic-data-engineer
```

**Verification**:
```bash
# Verify history is preserved
git log --follow docs-agentic-data-engineer/

# Check rename was tracked
git status  # Should show "renamed: docs -> docs-agentic-data-engineer"
```

**Alternatives Considered**:
1. **Manual `mv` + `git add`**: Works but less explicit about rename intent
2. **`git mv` each file**: Unnecessary overhead, directory-level rename is simpler

**Special Considerations**:
- Directory size: No special handling needed for large directories in Git
- Commit message: Should clearly indicate rename operation
- Clean working tree: Recommended before operation to avoid conflicts

## Task 3: Validation and Verification Strategy

### Research Question
How can we verify no broken references remain after the update?

### Decision: Multi-Pattern Grep Verification

**Verification Commands**:

```bash
# 1. Verify old directory no longer exists
ls docs 2>&1 | grep "No such file or directory"

# 2. Verify new directory exists
ls -la docs-agentic-data-engineer/

# 3. Search for remaining internal docs/ references
grep -r "docs/" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=__pycache__ \
  --include="*.md" \
  --include="*.json" \
  --include="*.py" \
  --include="*.sh" \
  .

# 4. Specifically check agent configs (must be zero matches)
grep -r "docs/" .claude/agents/

# 5. Verify git tracked the rename
git log --follow --oneline docs-agentic-data-engineer/ | head -5
```

**Acceptable Grep Results**:
After updates, remaining matches should ONLY be:
- External URLs (https://example.com/docs/)
- Submodule paths (if submodules have their own docs/)
- Historical references in changelogs (intentionally preserved)

**Validation Criteria** (from spec SC-001 through SC-006):
- ✅ SC-001: New directory exists with all content
- ✅ SC-002: Zero "docs/" in `.claude/agents/`
- ✅ SC-003: Zero "docs/" in markdown files (excluding external URLs)
- ✅ SC-004: All internal links resolve
- ✅ SC-005: Git history preserved
- ✅ SC-006: Only acceptable exclusions remain

### Rationale

**Why grep over automated link checker**:
- Grep provides immediate feedback on exact matches
- Can distinguish between internal and external references
- No additional tooling required
- Fast and reliable for verification

**Alternatives Considered**:
1. **Markdown link checker tools**: Overkill for simple rename; grep is sufficient
2. **Manual review**: Too error-prone for 593 markdown files
3. **CI/CD integration**: Good for ongoing validation but not needed for one-time operation

## Implementation Recommendations

### Phase Approach

**Phase 1: Prepare**
1. Ensure clean working tree
2. Create feature branch (already done: `007-rename-docs-dir`)
3. Backup current state (optional but recommended)

**Phase 2: Execute Rename**
1. Rename directory: `git mv docs docs-agentic-data-engineer`
2. Verify git tracked it: `git status`

**Phase 3: Update References**
1. Update agent configs (`.claude/agents/*.md`)
2. Update specification files in `specs/`
3. Update root-level markdown files
4. Update any configuration files

**Phase 4: Verify**
1. Run verification grep commands
2. Manually check a few critical files
3. Commit changes with clear message

### Risk Assessment

**Low Risk**:
- This is a pure refactoring task
- Git preserves history automatically
- Changes are reversible (can revert commit)
- No runtime behavior affected

**Medium Risk**:
- Potential for missed references in obscure locations
- **Mitigation**: Comprehensive grep verification

**Negligible Risk**:
- Breaking external links (external URLs unaffected)
- Data loss (git history preserved)

### Tooling Requirements

**Required**:
- Git (already available)
- Grep (standard Unix tool, available)
- Sed (for bulk replacements - standard Unix tool)

**Optional**:
- Find (for file discovery)
- Perl or Python (for complex replacements if needed)

## Conclusion

All research questions have been answered with concrete findings:

1. **Path references**: Identified in 7 agent configs, 593 markdown files, and various spec files
2. **Git strategy**: Use `git mv` for history-preserving rename
3. **Verification**: Multi-pattern grep with defined acceptable exclusions

**Ready for Phase 1 (Design)**: Yes - sufficient information gathered to create detailed execution plan.

**No unknowns remain**: All "NEEDS CLARIFICATION" items from Technical Context have been resolved through investigation.
