# Tasks: Separate Data Quality and Observability Utilities

**Input**: Design documents from `/specs/005-separate-utilities/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are rewritten from scratch per user request. Each user story includes contract tests to verify API stability and package independence.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each package.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1 = Data Quality, US2 = Observability)
- Include exact file paths in descriptions

## Path Conventions

This is a multi-package monorepo with 3 new top-level directories:
- **data-quality-utilities/**: `src/data_quality_utilities/`, `tests/`
- **data-observability-utilities/**: `src/data_observability_utilities/`, `tests/`
- **spark-session-utilities/**: `src/spark_session_utilities/`, `tests/`
- **databricks-shared-utilities/**: Existing package (modules removed)

---

## Phase 1: Setup (Repository Structure)

**Purpose**: Create 3 new package directories and basic Python package infrastructure

- [ ] T001 Create data-quality-utilities/ directory structure (src/, tests/, tests/unit/, tests/integration/, tests/contract/)
- [ ] T002 Create data-observability-utilities/ directory structure (src/, tests/, tests/unit/, tests/integration/, tests/contract/)
- [ ] T003 Create spark-session-utilities/ directory structure (src/, tests/, tests/unit/, tests/integration/, tests/contract/)
- [ ] T004 [P] Create data-quality-utilities/pyproject.toml with package metadata, version 1.0.0, dependencies (PySpark, Pydantic, scipy, numpy)
- [ ] T005 [P] Create data-observability-utilities/pyproject.toml with package metadata, version 1.0.0, dependencies (Monte Carlo SDK, PySpark)
- [ ] T006 [P] Create spark-session-utilities/pyproject.toml with package metadata, version 1.0.0, dependencies (PySpark, Delta Lake)
- [ ] T007 [P] Create data-quality-utilities/README.md with installation, quick start, API overview
- [ ] T008 [P] Create data-observability-utilities/README.md with installation, quick start, API overview
- [ ] T009 [P] Create spark-session-utilities/README.md with installation, quick start, API overview
- [ ] T010 [P] Create data-quality-utilities/src/data_quality_utilities/ module directory with __init__.py
- [ ] T011 [P] Create data-observability-utilities/src/data_observability_utilities/ module directory with __init__.py
- [ ] T012 [P] Create spark-session-utilities/src/spark_session_utilities/ module directory with __init__.py

---

## Phase 2: Foundational (Spark Session Utilities - Blocking Dependency)

**Purpose**: Implement spark-session-utilities package FIRST because databricks-shared-utilities depends on it

**⚠️ CRITICAL**: This package must be complete before User Stories 1-2 can reference it in their dependency tests

### Spark Session Utilities Implementation

- [ ] T013 Copy databricks-shared-utilities/src/databricks_utils/config/spark_session.py to spark-session-utilities/src/spark_session_utilities/config/spark_session.py
- [ ] T014 Copy databricks-shared-utilities/src/databricks_utils/logging/ to spark-session-utilities/src/spark_session_utilities/logging/
- [ ] T015 Create spark-session-utilities/src/spark_session_utilities/session.py with SparkSessionManager class (new wrapper for session management)
- [ ] T016 Update all imports in spark-session-utilities/src/spark_session_utilities/config/spark_session.py from databricks_utils to spark_session_utilities
- [ ] T017 Update all imports in spark-session-utilities/src/spark_session_utilities/logging/ from databricks_utils to spark_session_utilities
- [ ] T018 Create spark-session-utilities/src/spark_session_utilities/__init__.py exporting SparkSessionManager, SparkConfig, SparkLogger
- [ ] T019 [P] Write contract test in spark-session-utilities/tests/contract/test_public_api.py verifying all expected classes export
- [ ] T020 [P] Write contract test in spark-session-utilities/tests/contract/test_no_internal_deps.py verifying no databricks_utils imports
- [ ] T021 [P] Write unit tests for SparkConfig in spark-session-utilities/tests/unit/test_spark_config.py
- [ ] T022 [P] Write unit tests for SparkSessionManager in spark-session-utilities/tests/unit/test_session_manager.py
- [ ] T023 [P] Write unit tests for SparkLogger in spark-session-utilities/tests/unit/test_spark_logger.py
- [ ] T024 Write integration test in spark-session-utilities/tests/integration/test_session_lifecycle.py verifying session creation and cleanup
- [ ] T025 Run all spark-session-utilities tests and verify ≥90% coverage
- [ ] T026 Verify spark-session-utilities package can be installed independently (pip install -e spark-session-utilities/)

**Checkpoint**: spark-session-utilities package complete and independently testable

---

## Phase 3: User Story 1 - Independent Data Quality Package (Priority: P1) 🎯 MVP

**Goal**: Create standalone data-quality-utilities package with validation, profiling, quality gates, and anomaly detection

**Independent Test**: Install only data-quality-utilities in fresh environment, import all classes, verify no databricks_utils or observability dependencies required

### Contract Tests for User Story 1 (Write First, Verify FAIL)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T027 [P] [US1] Write contract test in data-quality-utilities/tests/contract/test_public_api.py verifying all expected classes exported (ValidationRule, ValidationRuleset, ValidationResult, RuleViolation, Status, Severity, RuleType, DataProfiler, DataProfile, ColumnProfile variants)
- [ ] T028 [P] [US1] Write contract test in data-quality-utilities/tests/contract/test_no_internal_deps.py verifying no imports from databricks_utils, data_observability_utilities, or spark_session_utilities
- [ ] T029 [P] [US1] Write contract test in data-quality-utilities/tests/contract/test_validation_rule_api.py verifying ValidationRule factory methods (completeness, uniqueness, freshness, schema_match, pattern_match, range_check)
- [ ] T030 [P] [US1] Write contract test in data-quality-utilities/tests/contract/test_api_compatibility.py verifying class names, method signatures match old databricks_utils.data_quality API

### Data Quality Package Implementation

- [ ] T031 [P] [US1] Copy databricks-shared-utilities/src/databricks_utils/data_quality/rules.py to data-quality-utilities/src/data_quality_utilities/rules.py
- [ ] T032 [P] [US1] Copy databricks-shared-utilities/src/databricks_utils/data_quality/validator.py to data-quality-utilities/src/data_quality_utilities/validator.py
- [ ] T033 [P] [US1] Copy databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py to data-quality-utilities/src/data_quality_utilities/profiler.py
- [ ] T034 [P] [US1] Copy databricks-shared-utilities/src/databricks_utils/data_quality/templates/ to data-quality-utilities/src/data_quality_utilities/templates/
- [ ] T035 [US1] Update all imports in data-quality-utilities/src/data_quality_utilities/rules.py from databricks_utils to data_quality_utilities
- [ ] T036 [US1] Update all imports in data-quality-utilities/src/data_quality_utilities/validator.py from databricks_utils to data_quality_utilities
- [ ] T037 [US1] Update all imports in data-quality-utilities/src/data_quality_utilities/profiler.py from databricks_utils to data_quality_utilities
- [ ] T038 [US1] Update all imports in data-quality-utilities/src/data_quality_utilities/templates/__init__.py from databricks_utils to data_quality_utilities
- [ ] T039 [US1] Create data-quality-utilities/src/data_quality_utilities/__init__.py exporting all public API classes (ValidationRule, ValidationRuleset, ValidationResult, RuleViolation, Status, Severity, RuleType, DataProfiler, DataProfile, ColumnProfile variants)
- [ ] T040 [US1] Verify all internal cross-references within data_quality_utilities package use relative imports or data_quality_utilities prefix

### Unit Tests for User Story 1 (Rewrite from scratch)

- [ ] T041 [P] [US1] Write unit tests for ValidationRule in data-quality-utilities/tests/unit/test_rules.py covering all factory methods (completeness, uniqueness, freshness, schema_match, pattern_match, range_check)
- [ ] T042 [P] [US1] Write unit tests for RuleType and Severity enums in data-quality-utilities/tests/unit/test_enums.py
- [ ] T043 [P] [US1] Write unit tests for ValidationRuleset in data-quality-utilities/tests/unit/test_validator.py covering add_rule, validate, and validation execution logic
- [ ] T044 [P] [US1] Write unit tests for ValidationResult in data-quality-utilities/tests/unit/test_validation_result.py covering to_dict, to_json serialization
- [ ] T045 [P] [US1] Write unit tests for RuleViolation in data-quality-utilities/tests/unit/test_rule_violation.py
- [ ] T046 [P] [US1] Write unit tests for DataProfiler in data-quality-utilities/tests/unit/test_profiler.py covering sampling strategies and profile generation
- [ ] T047 [P] [US1] Write unit tests for DataProfile in data-quality-utilities/tests/unit/test_data_profile.py covering get_column_profile, to_json, from_json
- [ ] T048 [P] [US1] Write unit tests for ColumnProfile variants (NumericColumnProfile, StringColumnProfile, TimestampColumnProfile) in data-quality-utilities/tests/unit/test_column_profiles.py

### Integration Tests for User Story 1 (Rewrite from scratch)

- [ ] T049 [US1] Write integration test in data-quality-utilities/tests/integration/test_validation_pipeline.py covering end-to-end validation workflow (create ruleset → add rules → validate DataFrame → check results)
- [ ] T050 [US1] Write integration test in data-quality-utilities/tests/integration/test_profiling_pipeline.py covering end-to-end profiling workflow (create profiler → profile DataFrame → access column profiles → serialize)
- [ ] T051 [US1] Write integration test in data-quality-utilities/tests/integration/test_validation_with_profiling.py combining validation and profiling in single pipeline

### User Story 1 Validation

- [ ] T052 [US1] Run all data-quality-utilities tests (contract + unit + integration) and verify 100% pass rate
- [ ] T053 [US1] Verify test coverage ≥90% for data-quality-utilities package
- [ ] T054 [US1] Test package installation in fresh environment: pip install -e data-quality-utilities/ and verify no transitive dependencies on databricks-shared-utilities or data-observability-utilities
- [ ] T055 [US1] Test acceptance scenario 1: Install data-quality-utilities and verify only data quality dependencies installed (PySpark, Pydantic, scipy, numpy)
- [ ] T056 [US1] Test acceptance scenario 2: Import all public API classes and verify imports succeed without databricks-shared-utilities
- [ ] T057 [US1] Test acceptance scenario 5: Create requirements.txt with only data-quality-utilities and verify dependency tree excludes observability/databricks utilities

**Checkpoint**: data-quality-utilities package complete, independently installable, and fully tested

---

## Phase 4: User Story 2 - Independent Data Observability Package (Priority: P2)

**Goal**: Create standalone data-observability-utilities package with Monte Carlo integration and monitoring

**Independent Test**: Install only data-observability-utilities in fresh environment, import Monte Carlo classes, verify no data quality or databricks dependencies required

### Contract Tests for User Story 2 (Write First, Verify FAIL)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T058 [P] [US2] Write contract test in data-observability-utilities/tests/contract/test_public_api.py verifying all expected classes exported (MonteCarloClient, MonteCarloIntegration, ObservabilityConfig)
- [ ] T059 [P] [US2] Write contract test in data-observability-utilities/tests/contract/test_no_internal_deps.py verifying no imports from databricks_utils or data_quality_utilities
- [ ] T060 [P] [US2] Write contract test in data-observability-utilities/tests/contract/test_monte_carlo_api.py verifying MonteCarloClient methods (create_monitor, get_incident, list_monitors)
- [ ] T061 [P] [US2] Write contract test in data-observability-utilities/tests/contract/test_api_compatibility.py verifying class names, method signatures match old databricks_utils.observability API

### Data Observability Package Implementation

- [ ] T062 [P] [US2] Copy databricks-shared-utilities/src/databricks_utils/observability/monte_carlo_client.py to data-observability-utilities/src/data_observability_utilities/monte_carlo_client.py
- [ ] T063 [P] [US2] Copy databricks-shared-utilities/src/databricks_utils/observability/monte_carlo_integration.py to data-observability-utilities/src/data_observability_utilities/monte_carlo_integration.py
- [ ] T064 [P] [US2] Copy databricks-shared-utilities/src/databricks_utils/observability/config.py to data-observability-utilities/src/data_observability_utilities/config.py
- [ ] T065 [US2] Update all imports in data-observability-utilities/src/data_observability_utilities/monte_carlo_client.py from databricks_utils to data_observability_utilities
- [ ] T066 [US2] Update all imports in data-observability-utilities/src/data_observability_utilities/monte_carlo_integration.py from databricks_utils to data_observability_utilities
- [ ] T067 [US2] Update all imports in data-observability-utilities/src/data_observability_utilities/config.py from databricks_utils to data_observability_utilities
- [ ] T068 [US2] Create data-observability-utilities/src/data_observability_utilities/__init__.py exporting all public API classes (MonteCarloClient, MonteCarloIntegration, ObservabilityConfig)
- [ ] T069 [US2] Verify all internal cross-references within data_observability_utilities package use relative imports or data_observability_utilities prefix

### Unit Tests for User Story 2 (Rewrite from scratch)

- [ ] T070 [P] [US2] Write unit tests for MonteCarloClient in data-observability-utilities/tests/unit/test_monte_carlo_client.py covering create_monitor, get_incident, list_monitors methods
- [ ] T071 [P] [US2] Write unit tests for MonteCarloIntegration in data-observability-utilities/tests/unit/test_monte_carlo_integration.py covering setup_table_monitoring, check_table_health methods
- [ ] T072 [P] [US2] Write unit tests for ObservabilityConfig in data-observability-utilities/tests/unit/test_config.py covering to_dict, from_dict, credential masking

### Integration Tests for User Story 2 (Rewrite from scratch)

- [ ] T073 [US2] Write integration test in data-observability-utilities/tests/integration/test_observability_setup.py covering end-to-end observability workflow (create client → create integration → setup monitoring)
- [ ] T074 [US2] Write integration test in data-observability-utilities/tests/integration/test_monte_carlo_operations.py covering monitor creation, incident retrieval, health checks

### User Story 2 Validation

- [ ] T075 [US2] Run all data-observability-utilities tests (contract + unit + integration) and verify 100% pass rate
- [ ] T076 [US2] Verify test coverage ≥90% for data-observability-utilities package
- [ ] T077 [US2] Test package installation in fresh environment: pip install -e data-observability-utilities/ and verify no transitive dependencies on databricks-shared-utilities or data-quality-utilities
- [ ] T078 [US2] Test acceptance scenario 1: Install data-observability-utilities and verify only observability dependencies installed (Monte Carlo SDK, PySpark)
- [ ] T079 [US2] Test acceptance scenario 2: Import all public API classes and verify imports succeed without databricks-shared-utilities or data-quality-utilities
- [ ] T080 [US2] Test acceptance scenario 5: Verify dependency graph shows data-observability-utilities does not depend on data-quality-utilities

**Checkpoint**: data-observability-utilities package complete, independently installable, and fully tested

---

## Phase 5: Update databricks-shared-utilities (Breaking Change)

**Purpose**: Remove migrated modules from databricks-shared-utilities and update to version 0.3.0

- [ ] T081 Remove databricks-shared-utilities/src/databricks_utils/data_quality/ directory entirely
- [ ] T082 Remove databricks-shared-utilities/src/databricks_utils/observability/ directory entirely
- [ ] T083 Remove databricks-shared-utilities/src/databricks_utils/config/spark_session.py file
- [ ] T084 Remove databricks-shared-utilities/src/databricks_utils/logging/ directory entirely
- [ ] T085 Update databricks-shared-utilities/src/databricks_utils/__init__.py removing all data_quality, observability, config.spark_session, and logging exports
- [ ] T086 Update databricks-shared-utilities/pyproject.toml version from 0.2.0 to 0.3.0 (breaking change)
- [ ] T087 Update databricks-shared-utilities/pyproject.toml dependencies adding spark-session-utilities==1.0.0 (databricks-shared-utilities now depends on it)
- [ ] T088 Update databricks-shared-utilities/README.md documenting removed modules and referencing new standalone packages (data-quality-utilities, data-observability-utilities, spark-session-utilities)
- [ ] T089 Remove or update databricks-shared-utilities tests referencing removed modules (tests/contract/test_spark_session_contract.py and any data_quality/observability tests)
- [ ] T090 Run remaining databricks-shared-utilities tests and verify all pass (only testing and errors modules remain)
- [ ] T091 Verify databricks-shared-utilities package size reduced by ≥50% LOC after module removal

---

## Phase 6: Cross-Package Validation & Documentation

**Purpose**: Verify all packages work independently and together, complete migration documentation

### Package Independence Validation

- [ ] T092 [P] Test fresh install of data-quality-utilities alone and verify no errors
- [ ] T093 [P] Test fresh install of data-observability-utilities alone and verify no errors
- [ ] T094 [P] Test fresh install of spark-session-utilities alone and verify no errors
- [ ] T095 [P] Test fresh install of databricks-shared-utilities==0.3.0 and verify spark-session-utilities installed as dependency
- [ ] T096 Verify no circular dependencies exist by checking import graph (data-quality and observability cannot import each other or databricks-shared-utilities)
- [ ] T097 Test installing all packages together in same environment and verify no conflicts

### Migration Documentation & Guides

- [ ] T098 [P] Create MIGRATION_GUIDE.md at repository root documenting step-by-step migration from databricks-shared-utilities 0.2.0 to separated packages
- [ ] T099 [P] Add migration examples to MIGRATION_GUIDE.md showing before/after import statements for all 3 packages
- [ ] T100 [P] Document troubleshooting common migration errors in MIGRATION_GUIDE.md (import errors, dependency conflicts)
- [ ] T101 [P] Update repository root README.md explaining new multi-package structure and linking to individual package READMEs
- [ ] T102 [P] Create CHANGELOG.md documenting version 1.0.0 release for all 3 new packages and 0.3.0 breaking change for databricks-shared-utilities

### Success Criteria Verification

- [ ] T103 Verify SC-001: Data engineers can install data-quality-utilities independently (installation < 30 seconds, < 10 dependencies)
- [ ] T104 Verify SC-002: Data operations engineers can install data-observability-utilities independently (no transitive deps on data quality)
- [ ] T105 Verify SC-003: All unit tests for data-quality-utilities achieve ≥90% code coverage
- [ ] T106 Verify SC-004: All unit tests for data-observability-utilities achieve ≥90% code coverage
- [ ] T107 Verify SC-005: data-quality-utilities package size is ≥40% smaller than databricks-shared-utilities 0.2.0
- [ ] T108 Verify SC-006: data-observability-utilities package size is ≥60% smaller than databricks-shared-utilities 0.2.0
- [ ] T109 Verify SC-009: databricks-shared-utilities package size decreased by ≥50% after removing modules

---

## Phase 7: Polish & Final Testing

**Purpose**: Final quality improvements, performance validation, documentation polish

- [ ] T110 [P] Run code quality checks (black, ruff, mypy) on all 3 new packages and fix any issues
- [ ] T111 [P] Verify all public API classes have complete docstrings with examples
- [ ] T112 [P] Add type hints to any missing function signatures across all packages
- [ ] T113 [P] Review and update all README.md files for clarity and completeness
- [ ] T114 Perform end-to-end validation using quickstart.md examples for all 3 packages
- [ ] T115 Run performance tests verifying zero performance degradation from package separation
- [ ] T116 Validate all contract tests still pass after any polish changes
- [ ] T117 Create repository-level documentation index linking to all package docs
- [ ] T118 Final review: Ensure no [NEEDS CLARIFICATION] markers remain in any files
- [ ] T119 Final review: Verify all functional requirements (FR-001 through FR-017) implemented and tested

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS User Stories 1-2
  - Must complete spark-session-utilities FIRST because it's a dependency
- **User Story 1 (Phase 3)**: Depends on Foundational (Phase 2) completion
  - Can start after T026 (spark-session-utilities complete)
- **User Story 2 (Phase 4)**: Depends on Foundational (Phase 2) completion
  - Can start after T026 (spark-session-utilities complete)
  - Can run in PARALLEL with User Story 1 (independent packages)
- **Update databricks-shared-utilities (Phase 5)**: Depends on User Stories 1-2 completion
  - Must complete after T057 (US1 complete) and T080 (US2 complete)
- **Cross-Package Validation (Phase 6)**: Depends on Phase 5 completion
- **Polish (Phase 7)**: Depends on Phase 6 completion

### User Story Dependencies

- **User Story 1 (P1 - Data Quality)**: Depends on Phase 2 completion
  - No dependencies on User Story 2
  - Can be implemented and tested independently

- **User Story 2 (P2 - Observability)**: Depends on Phase 2 completion
  - No dependencies on User Story 1
  - Can be implemented and tested independently
  - Can run in PARALLEL with User Story 1 if team capacity allows

### Within Each User Story

**User Story 1 (Data Quality)**:
1. Contract tests first (T027-T030) → Verify FAIL
2. Copy modules (T031-T034) in parallel
3. Update imports (T035-T040) sequentially (depends on T031-T034)
4. Unit tests (T041-T048) in parallel after imports updated
5. Integration tests (T049-T051) after unit tests
6. Validation (T052-T057) after all tests written

**User Story 2 (Observability)**:
1. Contract tests first (T058-T061) → Verify FAIL
2. Copy modules (T062-T064) in parallel
3. Update imports (T065-T069) sequentially (depends on T062-T064)
4. Unit tests (T070-T072) in parallel after imports updated
5. Integration tests (T073-T074) after unit tests
6. Validation (T075-T080) after all tests written

### Parallel Opportunities

**Within Setup (Phase 1)**:
- T004-T006 (pyproject.toml files) can run in parallel
- T007-T009 (README files) can run in parallel
- T010-T012 (module directories) can run in parallel

**Within Foundational (Phase 2)**:
- T019-T020 (contract tests) can run in parallel
- T021-T023 (unit tests) can run in parallel

**User Stories (Phase 3-4)**:
- **ENTIRE Phase 3 and Phase 4 can run in PARALLEL** (independent packages, different directories)
- Within each user story:
  - All contract tests can run in parallel
  - All module copies can run in parallel
  - All unit tests can run in parallel

**Within Cross-Package Validation (Phase 6)**:
- T092-T095 (independent package installs) can run in parallel
- T098-T102 (documentation) can run in parallel

**Within Polish (Phase 7)**:
- T110-T113 (code quality) can run in parallel

---

## Parallel Example: User Story 1 (Data Quality)

```bash
# Phase 3, Step 1: Launch all contract tests together
Task T027: "Write contract test for public API"
Task T028: "Write contract test for no internal deps"
Task T029: "Write contract test for ValidationRule API"
Task T030: "Write contract test for API compatibility"

# Phase 3, Step 2: Copy all modules together (after contract tests FAIL)
Task T031: "Copy rules.py"
Task T032: "Copy validator.py"
Task T033: "Copy profiler.py"
Task T034: "Copy templates/"

# Phase 3, Step 3: Update imports sequentially (wait for T031-T034)
Task T035-T040: Sequential (each depends on previous copy)

# Phase 3, Step 4: Launch all unit tests together (after imports updated)
Task T041: "Unit tests for ValidationRule"
Task T042: "Unit tests for enums"
Task T043: "Unit tests for ValidationRuleset"
Task T044: "Unit tests for ValidationResult"
Task T045: "Unit tests for RuleViolation"
Task T046: "Unit tests for DataProfiler"
Task T047: "Unit tests for DataProfile"
Task T048: "Unit tests for ColumnProfile variants"
```

---

## Parallel Example: User Stories 1 & 2 Together

```bash
# After Phase 2 completes, BOTH user stories can start in parallel:

# Developer A works on User Story 1 (Data Quality):
cd data-quality-utilities/
# Execute T027-T057

# Developer B works on User Story 2 (Observability):
cd data-observability-utilities/
# Execute T058-T080

# NO conflicts - different directories, independent packages
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. **Phase 1**: Setup (T001-T012) - Create 3 package directories
2. **Phase 2**: Foundational (T013-T026) - Complete spark-session-utilities
3. **Phase 3**: User Story 1 (T027-T057) - Complete data-quality-utilities
4. **STOP and VALIDATE**:
   - Test data-quality-utilities independently
   - Verify can install alone without other packages
   - Demo validation and profiling capabilities
5. **Decision Point**: Deploy MVP or continue to User Story 2

### Incremental Delivery (Recommended)

1. **Foundation**: Complete Phase 1 + Phase 2 → All 3 package structures exist, spark-session-utilities working
2. **Increment 1**: Add User Story 1 → Test independently → data-quality-utilities working ✅
3. **Increment 2**: Add User Story 2 → Test independently → data-observability-utilities working ✅
4. **Increment 3**: Complete Phase 5-6 → Update databricks-shared-utilities, validate all packages
5. **Increment 4**: Complete Phase 7 → Polish and final testing
6. Each increment adds value, packages remain independently usable

### Parallel Team Strategy

With 2 developers:

1. **Together**: Complete Phase 1 (Setup) and Phase 2 (Foundational)
2. **Split after T026**:
   - **Developer A**: Phase 3 (User Story 1 - Data Quality) T027-T057
   - **Developer B**: Phase 4 (User Story 2 - Observability) T058-T080
3. **Together**: Phase 5 (Update databricks-shared-utilities) T081-T091
4. **Split Phase 6**: Developer A does package testing, Developer B does documentation
5. **Together**: Phase 7 (Polish)

**Estimated Timeline**:
- Phase 1: 2 hours
- Phase 2: 4 hours
- Phase 3 OR 4 (parallel): 6-8 hours each
- Phase 5: 2 hours
- Phase 6: 3 hours
- Phase 7: 2 hours
- **Total (sequential)**: ~27-29 hours
- **Total (2 developers parallel)**: ~19-21 hours

---

## Notes

- **[P] tasks**: Different files/directories, can run in parallel safely
- **[US1]/[US2] labels**: Map tasks to user stories for traceability
- **Contract tests**: MUST be written first and verified to FAIL before implementation
- **Test rewrite**: All tests rewritten from scratch per user requirement (not copied)
- **Package independence**: data-quality and observability packages have ZERO dependencies on each other
- **Dependency hierarchy**: Layer 2 packages (data-quality, observability) → no internal deps; Layer 1 (spark-session) → leaf package
- **Clean break**: No backward compatibility, users must update imports
- **Commit strategy**: Commit after completing each user story phase (checkpoints)
- **MVP scope**: Phase 1 + 2 + 3 = data-quality-utilities working independently
- **Success criteria**: Each package installable alone, ≥90% test coverage, API compatibility preserved

---

## Task Count Summary

- **Phase 1 (Setup)**: 12 tasks
- **Phase 2 (Foundational)**: 14 tasks
- **Phase 3 (User Story 1)**: 31 tasks
- **Phase 4 (User Story 2)**: 23 tasks
- **Phase 5 (Update databricks-shared-utilities)**: 11 tasks
- **Phase 6 (Cross-Package Validation)**: 18 tasks
- **Phase 7 (Polish)**: 10 tasks

**TOTAL**: 119 tasks

**Parallel Opportunities**:
- Setup: 9 tasks can run in parallel
- Foundational: 5 tasks can run in parallel
- User Story 1: 16 tasks can run in parallel
- User Story 2: 13 tasks can run in parallel
- User Stories 1 & 2: ALL 54 tasks (31+23) can run in parallel with 2 developers
- Cross-Package Validation: 7 tasks can run in parallel
- Polish: 4 tasks can run in parallel

**Independent Test Criteria**:
- **User Story 1**: Install data-quality-utilities alone, import all classes, run validation/profiling workflows, verify no external package dependencies
- **User Story 2**: Install data-observability-utilities alone, import all classes, run Monte Carlo integration workflows, verify no data-quality dependencies
