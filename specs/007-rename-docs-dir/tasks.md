# Tasks: Rename Documentation Directory

**Input**: Design documents from `/specs/007-rename-docs-dir/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, quickstart.md

**Tests**: No test tasks generated - this is a pure refactoring/structural change that will be verified through grep/find commands and git history inspection.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story. However, note that User Story 1 (directory rename) is a blocking prerequisite for all other stories.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

This is a documentation refactoring task affecting:
- Repository root: `docs/` directory (to be renamed)
- Agent configurations: `.claude/agents/*.md`
- Specification files: `specs/**/*.md`
- Configuration files: `pyproject.toml`, `Makefile`, etc.

---

## Phase 1: Setup (Pre-Flight Checks)

**Purpose**: Verify prerequisites and create safety backups before making any changes

- [X] T001 Verify working tree is clean: `git status` should show no uncommitted changes
- [X] T002 Verify current branch is 007-rename-docs-dir: `git branch --show-current`
- [X] T003 Verify docs/ directory exists: `ls -ld docs/`
- [X] T004 Verify docs-agentic-data-engineer/ does not exist: `ls docs-agentic-data-engineer/ 2>&1` (should fail)
- [X] T005 Create safety tag for rollback: `git tag pre-docs-rename-007`

**Checkpoint**: All prerequisites verified - safe to proceed with rename

---

## Phase 2: User Story 1 - Directory Renaming (Priority: P1) 🎯 MVP BLOCKER

**Goal**: Rename the `docs` directory to `docs-agentic-data-engineer` using git to preserve history

**Independent Test**: Verify the directory exists at `docs-agentic-data-engineer/` with all original content and no `docs/` directory remains

**⚠️ CRITICAL**: This phase BLOCKS all other user stories - must complete successfully before proceeding

### Implementation for User Story 1

- [X] T006 [US1] Rename directory using git: `git mv docs docs-agentic-data-engineer`
- [X] T007 [US1] Verify git recognized rename: `git status` should show "renamed: docs -> docs-agentic-data-engineer"
- [X] T008 [US1] Verify new directory exists with content: `ls -la docs-agentic-data-engineer/ | head -10`
- [X] T009 [US1] Verify old directory is gone: `ls docs/ 2>&1 | grep "No such file or directory"`
- [X] T010 [US1] Verify directory content preserved: Check key files like `docs-agentic-data-engineer/knowledge_base/` exist

**Checkpoint**: Directory successfully renamed and git tracked the change. All other user stories can now proceed in parallel.

---

## Phase 3: User Story 2 - Agent Configuration Updates (Priority: P2)

**Goal**: Update all references to `docs/` in `.claude/agents` directory to `docs-agentic-data-engineer/`

**Independent Test**: Search all files in `.claude/agents` for "docs/" and verify zero matches (excluding "docs-agentic-data-engineer")

**Dependencies**: MUST complete User Story 1 (T006-T010) before starting

### Implementation for User Story 2

- [X] T011 [US2] Identify agent files with docs/ references: `grep -l "docs/" .claude/agents/*.md`
- [X] T012 [US2] Update architecture-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/architecture-agent.md`
- [X] T013 [US2] Update coding-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/coding-agent.md`
- [X] T014 [US2] Update data-project-generator-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/data-project-generator-agent.md`
- [X] T015 [US2] Update decision-documenter-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/decision-documenter-agent.md`
- [X] T016 [US2] Update dimensional-modeling-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/dimensional-modeling-agent.md`
- [X] T017 [US2] Update documentation-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/documentation-agent.md`
- [X] T018 [US2] Update testing-agent.md references: `sed -i '' 's|docs/|docs-agentic-data-engineer/|g' .claude/agents/testing-agent.md`
- [X] T019 [US2] Verify zero docs/ references remain in .claude/agents: `grep -r "docs/" .claude/agents/ | grep -v "docs-agentic-data-engineer" | wc -l` should return 0

**Checkpoint**: All agent configurations updated and verified. Agents can now access documentation at correct paths.

---

## Phase 4: User Story 3 - Markdown Documentation Updates (Priority: P2)

**Goal**: Update all references to `docs/` in markdown files throughout the project

**Independent Test**: Scan all `.md` files for "docs/" references and verify only external URLs remain

**Dependencies**: MUST complete User Story 1 (T006-T010) before starting

### Implementation for User Story 3

- [X] T020 [P] [US3] Update specs/001-ai-native-data-eng-process/tasks.md internal references: Replace docs/ with docs-agentic-data-engineer/ (preserve external URLs)
- [X] T021 [P] [US3] Update specs/001-ai-native-data-eng-process/plan.md project structure references: Replace docs/ with docs-agentic-data-engineer/ in structure diagrams
- [X] T022 [P] [US3] Update IMPLEMENTATION_SUMMARY.md project structure references: Replace docs/ with docs-agentic-data-engineer/
- [X] T023 [P] [US3] Scan for additional markdown files with internal docs/ references: `grep -r "docs/" --include="*.md" . | grep -v "https://" | grep -v "http://" | grep -v "docs-agentic-data-engineer"`
- [X] T024 [US3] Update any additional markdown files found in T023 (manual review required for context)
- [X] T025 [US3] Verify zero internal docs/ references in markdown files: Run verification grep excluding external URLs

**Checkpoint**: All markdown documentation updated. Internal links should resolve correctly.

---

## Phase 5: User Story 4 - Project-Wide Reference Updates (Priority: P3)

**Goal**: Update references in configuration files, scripts, and any other project files

**Independent Test**: Perform project-wide search for "docs/" and verify only acceptable exclusions remain

**Dependencies**: MUST complete User Story 1 (T006-T010) before starting

### Implementation for User Story 4

- [X] T026 [P] [US4] Search for docs/ references in configuration files: `grep -r "docs/" pyproject.toml Makefile *.json *.yml *.yaml 2>/dev/null`
- [X] T027 [P] [US4] Search for docs/ references in Python files: `grep -r "docs/" --include="*.py" . | grep -v ".git" | grep -v "__pycache__"`
- [X] T028 [P] [US4] Search for docs/ references in shell scripts: `grep -r "docs/" --include="*.sh" . | grep -v ".git"`
- [X] T029 [US4] Update any configuration files found with internal docs/ references (manual review for context)
- [X] T030 [US4] Update any Python files found with internal docs/ references (manual review for context)
- [X] T031 [US4] Update any shell scripts found with internal docs/ references (manual review for context)
- [X] T032 [US4] Perform comprehensive project-wide verification: `grep -r "docs/" --exclude-dir=.git --exclude-dir=node_modules . | grep -v "https://" | grep -v "http://" | grep -v "docs-agentic-data-engineer"`

**Checkpoint**: All project-wide references updated. Only acceptable exclusions remain in search results.

---

## Phase 6: Validation & Commit

**Purpose**: Comprehensive verification and committing all changes

### Validation Tasks

- [X] T033 Validate SC-001: Verify docs-agentic-data-engineer/ exists with all content: `ls -la docs-agentic-data-engineer/`
- [X] T034 Validate SC-002: Verify zero docs/ in .claude/agents: `grep -r "docs/" .claude/agents/ | grep -v "docs-agentic-data-engineer" | wc -l` = 0
- [X] T035 Validate SC-003: Verify zero docs/ in markdown files (excluding external): `grep -r "docs/" --include="*.md" . | grep -v "https://" | grep -v "http://" | grep -v "docs-agentic-data-engineer" | wc -l` = 0
- [X] T036 Validate SC-004: Manual spot-check 5-10 internal documentation links resolve correctly
- [X] T037 Validate SC-005: Verify git history preserved: `git log --follow --oneline docs-agentic-data-engineer/ | head -5`
- [X] T038 Validate SC-006: Review remaining grep matches are only acceptable exclusions (external URLs, submodules)

### Commit Tasks

- [X] T039 Stage all changes: `git add -A`
- [X] T040 Review staged changes: `git status` and `git diff --cached --name-status | head -30`
- [X] T041 Create commit with descriptive message: `git commit -m "Rename docs/ to docs-agentic-data-engineer/..."`
- [X] T042 Verify commit looks correct: `git show --name-status HEAD | head -30`
- [X] T043 Final verification: `git status` should show clean working tree

**Checkpoint**: All changes committed successfully. Feature complete and ready for PR.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **User Story 1 (Phase 2)**: Depends on Setup - BLOCKS all other user stories ⚠️
- **User Story 2 (Phase 3)**: Depends on User Story 1 completion - Can proceed in parallel with US3 and US4
- **User Story 3 (Phase 4)**: Depends on User Story 1 completion - Can proceed in parallel with US2 and US4
- **User Story 4 (Phase 5)**: Depends on User Story 1 completion - Can proceed in parallel with US2 and US3
- **Validation & Commit (Phase 6)**: Depends on all user stories (US1, US2, US3, US4) being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Setup (Phase 1) - **BLOCKS all other stories**
- **User Story 2 (P2)**: Can start after US1 completes - Independent of US3 and US4
- **User Story 3 (P2)**: Can start after US1 completes - Independent of US2 and US4
- **User Story 4 (P3)**: Can start after US1 completes - Independent of US2 and US3

### Critical Path

```
Setup (T001-T005)
  ↓
User Story 1 (T006-T010) ← BLOCKING CRITICAL PATH
  ↓
┌─────────────────┬─────────────────┬─────────────────┐
│  User Story 2   │  User Story 3   │  User Story 4   │
│  (T011-T019)    │  (T020-T025)    │  (T026-T032)    │
│  Agent Configs  │  Markdown Docs  │  Other Files    │
└─────────────────┴─────────────────┴─────────────────┘
  ↓
Validation & Commit (T033-T043)
```

### Parallel Opportunities

**Within User Story 2** (after US1):
- T012-T018 can be done in parallel (different agent files)

**Within User Story 3** (after US1):
- T020-T022 can be done in parallel (different spec/doc files)

**Within User Story 4** (after US1):
- T026-T028 can be done in parallel (different file type searches)
- T029-T031 can be done in parallel (different file type updates)

**Across User Stories** (after US1):
- User Stories 2, 3, and 4 can ALL proceed in parallel once US1 is complete

---

## Parallel Example: After User Story 1 Complete

```bash
# All three user stories can execute in parallel:

# Developer A or Agent A:
Task: "Update architecture-agent.md references"
Task: "Update coding-agent.md references"
Task: "Update data-project-generator-agent.md references"
# ... (all US2 tasks)

# Developer B or Agent B (simultaneously):
Task: "Update specs/001-ai-native-data-eng-process/tasks.md internal references"
Task: "Update specs/001-ai-native-data-eng-process/plan.md project structure references"
Task: "Update IMPLEMENTATION_SUMMARY.md project structure references"
# ... (all US3 tasks)

# Developer C or Agent C (simultaneously):
Task: "Search for docs/ references in configuration files"
Task: "Search for docs/ references in Python files"
Task: "Search for docs/ references in shell scripts"
# ... (all US4 tasks)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T005)
2. Complete Phase 2: User Story 1 (T006-T010) - **CRITICAL**
3. **STOP and VALIDATE**: Verify directory renamed correctly
4. Optionally commit just US1 if desired

### Incremental Delivery

1. Complete Setup → Pre-flight checks passed
2. Complete User Story 1 → Directory renamed (BLOCKING complete)
3. Complete User Story 2 → Agent configs updated → Test agents work
4. Complete User Story 3 → Markdown docs updated → Test links work
5. Complete User Story 4 → All references updated → Full project consistency
6. Complete Validation & Commit → Feature complete

### Parallel Team Strategy

With multiple developers or agents:

1. One person completes Setup + User Story 1 (critical path)
2. Once User Story 1 is done, split work:
   - Developer/Agent A: User Story 2 (Agent configs)
   - Developer/Agent B: User Story 3 (Markdown docs)
   - Developer/Agent C: User Story 4 (Other files)
3. Regroup for Validation & Commit together

### Sequential Safe Strategy (Recommended for First Time)

Follow the quickstart.md guide step-by-step:
1. Setup checks (T001-T005)
2. US1: Directory rename with verification (T006-T010)
3. US2: Agent configs with verification (T011-T019)
4. US3: Markdown docs with verification (T020-T025)
5. US4: Other files with verification (T026-T032)
6. Full validation and commit (T033-T043)

---

## Rollback Procedures

### Before Committing (T001-T040)

If any issues discovered:
```bash
# Reset to clean state
git reset --hard HEAD

# Or use safety tag
git reset --hard pre-docs-rename-007
```

### After Committing (T041+)

If issues discovered after commit:
```bash
# Revert the commit
git revert HEAD

# Or hard reset to tag (WARNING: loses commit)
git reset --hard pre-docs-rename-007
```

---

## Success Criteria Validation

Each task in Phase 6 (T033-T038) maps to a success criterion from spec.md:

- ✅ **T033 → SC-001**: Directory `docs-agentic-data-engineer` exists with all files
- ✅ **T034 → SC-002**: Zero `docs/` references in `.claude/agents`
- ✅ **T035 → SC-003**: Zero `docs/` references in markdown files (internal)
- ✅ **T036 → SC-004**: All internal documentation links resolve
- ✅ **T037 → SC-005**: Git tracked rename and preserved history
- ✅ **T038 → SC-006**: Only acceptable exclusions remain in searches

All criteria must pass before considering feature complete.

---

## Notes

- **[P]** tasks = different files, no dependencies, can run in parallel
- **[Story]** label maps task to specific user story for traceability
- User Story 1 is a **BLOCKER** - must complete before any other story
- User Stories 2, 3, 4 are **independent** once US1 is done
- Manual review required for some tasks to preserve context (external URLs)
- Commit after validation phase completes successfully
- Use quickstart.md as detailed execution guide for each task
- Estimated total time: 15-30 minutes for sequential execution
- Risk level: Low (git history preserved, changes reversible)

---

## Quick Reference: Task Counts

- **Total Tasks**: 43
- **Setup (Phase 1)**: 5 tasks
- **User Story 1 (Phase 2)**: 5 tasks (BLOCKER)
- **User Story 2 (Phase 3)**: 9 tasks
- **User Story 3 (Phase 4)**: 6 tasks
- **User Story 4 (Phase 5)**: 7 tasks
- **Validation & Commit (Phase 6)**: 11 tasks

**Parallelizable Tasks**: 15 tasks marked with [P]
**Critical Path Tasks**: 5 tasks in User Story 1 (blocking all others)
