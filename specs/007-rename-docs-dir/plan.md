# Implementation Plan: Rename Documentation Directory

**Branch**: `007-rename-docs-dir` | **Date**: 2025-11-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/007-rename-docs-dir/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Rename the `docs` directory to `docs-agentic-data-engineer` and update all references throughout the project to maintain documentation integrity and prevent broken links. This is a pure refactoring task with no new functionality - only structural reorganization and path updates.

**Technical Approach**: Use git mv for directory rename to preserve history, then systematically update all path references in `.claude/agents`, markdown files, and other project files using find-and-replace operations with verification.

## Technical Context

**Language/Version**: N/A (refactoring task - no code execution)
**Primary Dependencies**: Git (for tracking rename), bash/shell utilities (find, sed, grep)
**Storage**: Filesystem only (local directory structure)
**Testing**: Manual verification via grep/find to confirm zero broken references
**Target Platform**: Repository filesystem (macOS/Linux/Windows compatible)
**Project Type**: Documentation refactoring (no source code changes)
**Performance Goals**: N/A (one-time operation)
**Constraints**: Must preserve git history, must not break any documentation links
**Scale/Scope**: ~1 directory, estimated 10-50 file references across project

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Evaluation Against Constitution Principles

#### ✅ I. Standards-First Development (NON-NEGOTIABLE)
**Status**: PASS - This task updates documentation structure to align with project identity standards.
**Justification**: The rename improves clarity and follows the principle of continuous standards improvement. Documentation precedes implementation (this is pure documentation restructuring).

#### ✅ II. AI-Native by Design
**Status**: PASS - Ensuring correct documentation paths improves AI agent access to context.
**Justification**: Agent configurations in `.claude/agents` must reference correct paths for AI-assisted development to function properly.

#### N/A III. Medallion Architecture Adherence (NON-NEGOTIABLE)
**Status**: NOT APPLICABLE - No data pipeline or architecture changes.

#### N/A IV. Type Safety and Validation (NON-NEGOTIABLE)
**Status**: NOT APPLICABLE - No code changes requiring type safety.

#### N/A V. Test-First Development (NON-NEGOTIABLE)
**Status**: NOT APPLICABLE - Refactoring task with manual verification sufficient.
**Justification**: This is a filesystem and path reference update with no executable code. Verification via grep/find for broken references is appropriate.

#### N/A VI. Configuration Over Code
**Status**: NOT APPLICABLE - No runtime behavior changes.

#### ✅ VII. Security and Governance (NON-NEGOTIABLE)
**Status**: PASS - No security implications.
**Justification**: Documentation path changes do not affect access control, credentials, or governance.

#### N/A VIII. Observability and Debugging
**Status**: NOT APPLICABLE - No runtime systems affected.

#### N/A IX. Performance and Cost Efficiency
**Status**: NOT APPLICABLE - No performance impact.

#### ✅ X. Documentation as Code
**Status**: PASS - This task improves documentation organization.
**Justification**: Renaming to `docs-agentic-data-engineer` makes documentation structure more explicit and maintainable.

### Technology Stack Compliance

**Mandatory Technologies**: N/A for this refactoring task.
**Prohibited Technologies**: N/A - no prohibited technologies used.

### Gate Result: ✅ PASS

All applicable constitution principles are satisfied. This is a low-risk refactoring task that improves documentation structure without violating any standards.

## Project Structure

### Documentation (this feature)

```text
specs/007-rename-docs-dir/
├── spec.md              # Feature specification
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (minimal for this refactoring task)
├── quickstart.md        # Phase 1 output (execution guide)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

**Note**: No `data-model.md` or `contracts/` needed - this is a pure refactoring task with no data models or API contracts.

### Source Code (repository root)

```text
# Current structure
docs/                           # TO BE RENAMED
├── knowledge_base/
├── adr/
└── ...

.claude/
├── agents/                     # Files referencing docs/ paths TO BE UPDATED
└── ...

# Many .md files throughout project    # TO BE UPDATED

# After refactoring
docs-agentic-data-engineer/     # RENAMED FROM docs/
├── knowledge_base/
├── adr/
└── ...
```

**Structure Decision**: Single-directory rename operation. No new directories or source code added. All existing documentation content preserved in place.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations - table not needed.

## Phase 0: Research & Discovery

**Objective**: Identify all file types and locations that reference the `docs/` path to ensure comprehensive updates.

### Research Tasks

#### Task 1: Identify All Path Reference Patterns

**Research Question**: What are all the ways `docs/` is referenced in the project?

**Investigation Plan**:
1. Search for literal string "docs/" in all files
2. Search for markdown links: `[text](docs/...)`
3. Search for relative paths: `./docs/`, `../docs/`
4. Search for absolute paths containing "docs"
5. Identify file types containing references (.md, .json, .yml, .py, .sh, etc.)

**Expected Findings**: List of file types and reference patterns to update.

#### Task 2: Git History Preservation Strategy

**Research Question**: What is the correct git command to rename a directory while preserving history?

**Investigation Plan**:
1. Verify `git mv` is the correct approach for directory rename
2. Confirm git tracks the rename automatically
3. Document any special considerations for large directories

**Expected Findings**: Confirmed approach: `git mv docs docs-agentic-data-engineer`

#### Task 3: Validation and Verification Strategy

**Research Question**: How can we verify no broken references remain after the update?

**Investigation Plan**:
1. Identify patterns to search for old path (`docs/`)
2. Define acceptable exclusions (git history, changelogs)
3. Plan link verification approach for markdown files

**Expected Findings**: Grep-based verification commands and exclusion patterns.

### Research Deliverable

`research.md` will document:
- All file locations with path references
- Reference pattern variations found
- Git commands for history-preserving rename
- Verification approach and commands
- List of intentional exclusions from path updates

## Phase 1: Design & Implementation Approach

**Objective**: Define the step-by-step approach for safe execution of the rename and update operations.

### Design Artifacts

#### 1. Execution Plan (quickstart.md)

**Content**:
- Pre-execution checklist (clean working tree, branch creation)
- Step-by-step commands with verification after each step
- Rollback procedure if issues arise
- Final verification checklist

#### 2. Path Update Strategy

**Scope**:
1. `.claude/agents/*.json` - Agent configuration files
2. `**/*.md` - All markdown files
3. `pyproject.toml`, `Makefile`, scripts - Configuration and build files
4. Any JSON/YAML configuration files

**Update Approach**:
- Use sed or programmatic find-and-replace for each file type
- Test on sample file first before bulk operations
- Verify each file type category before proceeding to next

#### 3. Validation Criteria

**Success Metrics** (from spec.md):
- SC-001: Directory `docs-agentic-data-engineer` exists and contains all files
- SC-002: Zero references to `docs/` in `.claude/agents`
- SC-003: Zero references to `docs/` in markdown files
- SC-004: All documentation links resolve successfully
- SC-005: Git tracks rename correctly
- SC-006: Only acceptable exclusions remain in search results

### Phase 1 Deliverables

1. **quickstart.md** - Step-by-step execution guide with:
   - Prerequisites and safety checks
   - Directory rename command
   - Path update commands by file type
   - Verification commands
   - Rollback instructions

2. **Agent context update** - Run `.specify/scripts/bash/update-agent-context.sh claude` to update CLAUDE.md with any new tooling/approaches from this plan.

**Note**: No `data-model.md` or `contracts/` for this refactoring task.

## Phase 2: Task Generation (NOT executed by /speckit.plan)

Phase 2 is executed separately via the `/speckit.tasks` command, which will:
1. Break down the implementation into atomic, dependency-ordered tasks
2. Generate `tasks.md` with specific file paths and commands
3. Prepare for implementation tracking

## Implementation Notes

### Assumptions

1. The current `docs/` directory exists and contains documentation files
2. No other directory named `docs-agentic-data-engineer` currently exists
3. Git is initialized and working tree is clean before starting
4. All team members are aware of the path change to update local references

### Risk Mitigation

**Risk**: Accidentally breaking external documentation links
**Mitigation**: This only affects internal project structure; external links unaffected

**Risk**: Missing references in obscure file locations
**Mitigation**: Comprehensive grep verification with multiple search patterns

**Risk**: Git history lost
**Mitigation**: Using `git mv` ensures git tracks the rename correctly

### Dependencies

**Blockers**: None - this task is self-contained.

**Related Work**: After this rename, any in-flight branches referencing `docs/` will need to be rebased/updated.

## Success Validation

After implementation, verify all success criteria from spec.md:

```bash
# Verify new directory exists
ls -la docs-agentic-data-engineer/

# Verify old directory gone
ls docs 2>&1 | grep "No such file or directory"

# Search for remaining references (excluding acceptable locations)
grep -r "docs/" --exclude-dir=.git --exclude-dir=node_modules --exclude="*.log"

# Verify git tracked the rename
git log --follow docs-agentic-data-engineer/
```

All checks must pass before considering the task complete.
