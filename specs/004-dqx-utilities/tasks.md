# Tasks: Data Quality Framework Integration Utilities

**Feature**: `004-dqx-utilities`
**Input**: Design documents from `/specs/004-dqx-utilities/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/dqx-api.md, quickstart.md

**Tests**: Tests are NOT explicitly requested in the feature specification. This task list focuses on implementation only. Unit tests can be added in the Polish phase if needed.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

Based on plan.md, this feature integrates into the existing `databricks-shared-utilities` package:
- **Module root**: `databricks-shared-utilities/src/databricks_utils/data_quality/`
- **Tests**: `databricks-shared-utilities/tests/unit/data_quality/` and `databricks-shared-utilities/tests/integration/data_quality/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and module structure creation

- [X] T001 Create data_quality module structure in databricks-shared-utilities/src/databricks_utils/data_quality/
- [X] T002 Create __init__.py with public API exports in databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py
- [X] T003 [P] Create templates submodule structure in databricks-shared-utilities/src/databricks_utils/data_quality/templates/
- [X] T004 [P] Create test directory structure in databricks-shared-utilities/tests/unit/data_quality/ and databricks-shared-utilities/tests/integration/data_quality/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data models and enums that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 [P] Implement RuleType and Severity enums in databricks-shared-utilities/src/databricks_utils/data_quality/rules.py
- [X] T006 [P] Implement ValidationRule dataclass with factory methods in databricks-shared-utilities/src/databricks_utils/data_quality/rules.py
- [X] T007 [P] Implement Status enum and RuleViolation dataclass in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [X] T008 [P] Implement ColumnProfile base class and type-specific variants (NumericColumnProfile, StringColumnProfile, TimestampColumnProfile) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [X] T009 Update databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py to export foundational types (RuleType, Severity, ValidationRule, Status, RuleViolation, ColumnProfile)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Data Quality Rule Definition and Validation (Priority: P1) 🎯 MVP

**Goal**: Enable data engineers to define data quality rules declaratively and validate DataFrames against these rules, detecting completeness, uniqueness, freshness, and schema violations.

**Independent Test**: Create a DataFrame with known quality issues (nulls, duplicates, schema mismatches), define quality rules via data quality utilities, run validation, and verify that violations are detected and reported with clear error messages.

### Implementation for User Story 1

- [ ] T010 [P] [US1] Implement ValidationRuleset class with add_rule(), remove_rule(), and rule management in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T011 [P] [US1] Implement ValidationResult dataclass with properties (pass_rate, has_critical_failures, has_warnings) and to_dataframe() method in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T012 [US1] Implement validation execution engine in ValidationRuleset.validate() method with single-pass optimization for completeness rules in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T013 [US1] Implement uniqueness rule validation logic using Spark countDistinct() in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T014 [US1] Implement freshness rule validation logic using timestamp comparison in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T015 [US1] Implement schema rule validation logic (required columns, data types) in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T016 [US1] Implement pattern rule validation logic using Spark rlike() for regex matching in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T017 [US1] Implement range rule validation logic for numeric and date bounds checking in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T018 [US1] Implement custom rule validation logic with user-defined functions in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T019 [US1] Add violation collection logic with sampling (sample_violations parameter) in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T020 [US1] Implement ruleset serialization (to_json(), from_json()) in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T021 [US1] Implement validation result serialization (to_json()) in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T022 [US1] Add logging integration with databricks-shared-utilities logger for validation events in databricks-shared-utilities/src/databricks_utils/data_quality/validator.py
- [ ] T023 [US1] Update databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py to export ValidationRuleset and ValidationResult

**Checkpoint**: At this point, User Story 1 should be fully functional - users can define rules and validate DataFrames with comprehensive violation reporting

---

## Phase 4: User Story 2 - Data Profiling and Quality Metrics (Priority: P2)

**Goal**: Enable data analysts to automatically generate data quality profiles (null rates, distinct counts, value distributions, correlations) for DataFrames for quick data exploration and quality assessment.

**Independent Test**: Profile a DataFrame with diverse data types (numeric, string, timestamp, boolean), verify that profile includes summary statistics, null rates, distinct counts, value distributions, and data type analysis, and confirm results match expected values.

### Implementation for User Story 2

- [ ] T024 [P] [US2] Implement DataProfile dataclass with get_column_profile(), compare(), to_json(), and from_json() methods in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T025 [P] [US2] Implement DataProfiler class initialization with sampling configuration in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T026 [US2] Implement reservoir sampling algorithm for large DataFrame profiling in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T027 [US2] Implement stratified sampling logic (stratify_by parameter) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T028 [US2] Implement numeric column profiling (min, max, mean, median, stddev, quartiles, histogram) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T029 [US2] Implement string column profiling (min/max/avg length, most_common_values, unique_values_sample) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T030 [US2] Implement timestamp column profiling (min_date, max_date, date_range_days, freshness_hours) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T031 [US2] Implement base column statistics (null_count, null_percentage, distinct_count, distinct_percentage) for all column types in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T032 [US2] Implement schema digest generation (hash of DataFrame schema) for drift detection in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T033 [US2] Implement correlation computation (optional, compute_correlations parameter) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T034 [US2] Implement DataProfiler.profile() main method with column filtering and profiling orchestration in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T035 [US2] Add logging integration for profiling operations (sample size, columns profiled, execution time) in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T036 [US2] Update databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py to export DataProfiler and DataProfile

**Checkpoint**: At this point, User Story 2 should be fully functional - users can profile DataFrames and get comprehensive statistical summaries

---

## Phase 5: User Story 3 - Quality Gates and Pipeline Integration (Priority: P3)

**Goal**: Enable data platform engineers to define quality gates that block pipeline execution when critical data quality thresholds are violated, ensuring only high-quality data reaches production.

**Independent Test**: Create a pipeline with defined quality gates (e.g., "null rate < 5%", "row count > 1000"), execute the pipeline with both passing and failing data, and verify that execution succeeds for passing data and fails with clear error messages for failing data.

### Implementation for User Story 3

- [ ] T037 [P] [US3] Implement GateAction enum in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T038 [P] [US3] Implement QualityGateException class with gate_name, violations, and result attributes in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T039 [US3] Implement QualityGate class initialization with ruleset, actions mapping, and metadata in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T040 [US3] Implement QualityGate.check() method with validation execution and action handling (RAISE) in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T041 [US3] Implement COLLECT_THEN_RAISE action logic (collect all violations before raising) in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T042 [US3] Implement LOG action logic (log violations without raising) using databricks-shared-utilities logger in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T043 [US3] Implement IGNORE action logic (skip rule evaluation) in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T044 [US3] Implement QualityGate.get_last_result() method for result caching in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T045 [US3] Add severity-based action dispatch logic in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T046 [US3] Add logging integration for gate checks (gate name, status, violations) in databricks-shared-utilities/src/databricks_utils/data_quality/gates.py
- [ ] T047 [US3] Update databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py to export QualityGate, GateAction, and QualityGateException

**Checkpoint**: At this point, User Story 3 should be fully functional - quality gates can block pipeline execution on critical failures

---

## Phase 6: User Story 4 - Anomaly Detection and Drift Monitoring (Priority: P4)

**Goal**: Enable data operations engineers to detect anomalies and data drift by comparing current data quality metrics against historical baselines, identifying unusual patterns proactively.

**Independent Test**: Establish a baseline profile from historical data, process new data with significant changes (volume spike, distribution shift, new values), run anomaly detection, and verify that anomalies are detected and reported with baseline comparisons.

### Implementation for User Story 4

- [ ] T048 [P] [US4] Implement AnomalyType enum (VOLUME, DISTRIBUTION, SCHEMA, STATISTICAL) in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T049 [P] [US4] Implement DetectedAnomaly dataclass with anomaly details and remediation suggestions in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T050 [P] [US4] Implement AnomalyReport dataclass with get_critical_anomalies() and get_anomalies_by_type() methods in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T051 [P] [US4] Implement Baseline dataclass in databricks-shared-utilities/src/databricks_utils/data_quality/baseline.py
- [ ] T052 [P] [US4] Implement BaselineStore class initialization with Delta Lake storage path in databricks-shared-utilities/src/databricks_utils/data_quality/baseline.py
- [ ] T053 [US4] Implement BaselineStore.save() method with profile serialization and Delta write in databricks-shared-utilities/src/databricks_utils/data_quality/baseline.py
- [ ] T054 [US4] Implement BaselineStore.load() method with baseline retrieval (latest active or specific version) in databricks-shared-utilities/src/databricks_utils/data_quality/baseline.py
- [ ] T055 [US4] Implement BaselineStore.list_baselines() method with optional table_name filtering in databricks-shared-utilities/src/databricks_utils/data_quality/baseline.py
- [ ] T056 [US4] Implement baseline activation logic (is_active flag, only one active per table) in databricks-shared-utilities/src/databricks_utils/data_quality/baseline.py
- [ ] T057 [US4] Implement AnomalyDetector class initialization with threshold configuration in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T058 [US4] Implement volume anomaly detection (row count change threshold) in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T059 [US4] Implement distribution drift detection using Kolmogorov-Smirnov test for numeric columns in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T060 [US4] Implement distribution drift detection using Chi-square test for categorical columns in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T061 [US4] Implement schema drift detection (new/removed columns, type changes) in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T062 [US4] Implement statistical drift detection (mean/median/stddev shifts beyond threshold) in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T063 [US4] Implement AnomalyDetector.detect() main method with baseline comparison orchestration in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T064 [US4] Implement DataProfile.compare() method for profile-to-profile comparison in databricks-shared-utilities/src/databricks_utils/data_quality/profiler.py
- [ ] T065 [US4] Add logging integration for anomaly detection (anomalies found, severity levels) in databricks-shared-utilities/src/databricks_utils/data_quality/anomaly.py
- [ ] T066 [US4] Update databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py to export BaselineStore, Baseline, AnomalyDetector, AnomalyReport, and DetectedAnomaly

**Checkpoint**: At this point, User Story 4 should be fully functional - anomaly detection and drift monitoring work against historical baselines

---

## Phase 7: Pre-built Rule Templates (Enhancement)

**Purpose**: Provide pre-built rule templates for common data quality patterns to accelerate rule definition

- [ ] T067 [P] Implement EmailRule template with email regex validation in databricks-shared-utilities/src/databricks_utils/data_quality/templates/common.py
- [ ] T068 [P] Implement DateRangeRule template with configurable min/max dates in databricks-shared-utilities/src/databricks_utils/data_quality/templates/common.py
- [ ] T069 [P] Implement NumericBoundsRule template with min/max value constraints in databricks-shared-utilities/src/databricks_utils/data_quality/templates/common.py
- [ ] T070 [P] Implement PhoneNumberRule template with country code validation in databricks-shared-utilities/src/databricks_utils/data_quality/templates/common.py
- [ ] T071 Create templates/__init__.py with template exports in databricks-shared-utilities/src/databricks_utils/data_quality/templates/__init__.py
- [ ] T072 Update main __init__.py to include templates submodule in public API in databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py

---

## Phase 8: Reporting and Utilities (Enhancement)

**Purpose**: Add report generation and utilities for validation result persistence

- [ ] T073 [P] Implement ReportFormat enum (DATAFRAME, JSON) in databricks-shared-utilities/src/databricks_utils/data_quality/reports.py
- [ ] T074 [P] Implement ReportGenerator class in databricks-shared-utilities/src/databricks_utils/data_quality/reports.py
- [ ] T075 Implement ReportGenerator.generate() method with format conversion (ValidationResult → DataFrame/JSON) in databricks-shared-utilities/src/databricks_utils/data_quality/reports.py
- [ ] T076 Implement report schema for Delta table persistence (partitioned by date, table_name) in databricks-shared-utilities/src/databricks_utils/data_quality/reports.py
- [ ] T077 Add helper methods for report querying and historical analysis in databricks-shared-utilities/src/databricks_utils/data_quality/reports.py
- [ ] T078 Update databricks-shared-utilities/src/databricks_utils/data_quality/__init__.py to export ReportGenerator and ReportFormat

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, testing, and documentation

- [ ] T079 [P] Add comprehensive docstrings to all public classes and methods following NumPy docstring format
- [ ] T080 [P] Create unit tests for ValidationRule factory methods in databricks-shared-utilities/tests/unit/data_quality/test_rules.py
- [ ] T081 [P] Create unit tests for ValidationRuleset and validation execution in databricks-shared-utilities/tests/unit/data_quality/test_validator.py
- [ ] T082 [P] Create unit tests for DataProfiler and profiling logic in databricks-shared-utilities/tests/unit/data_quality/test_profiler.py
- [ ] T083 [P] Create unit tests for QualityGate and gate actions in databricks-shared-utilities/tests/unit/data_quality/test_gates.py
- [ ] T084 [P] Create unit tests for AnomalyDetector and drift detection in databricks-shared-utilities/tests/unit/data_quality/test_anomaly.py
- [ ] T085 [P] Create unit tests for BaselineStore and baseline persistence in databricks-shared-utilities/tests/unit/data_quality/test_baseline.py
- [ ] T086 [P] Create integration test for end-to-end validation workflow in databricks-shared-utilities/tests/integration/data_quality/test_validation_e2e.py
- [ ] T087 [P] Create integration test for profiling and drift detection workflow in databricks-shared-utilities/tests/integration/data_quality/test_profiling_e2e.py
- [ ] T088 [P] Create integration test for quality gates in pipeline context in databricks-shared-utilities/tests/integration/data_quality/test_quality_gates_e2e.py
- [ ] T089 [P] Update databricks-shared-utilities README.md with data quality utilities section and usage examples
- [ ] T090 [P] Add type hints to all functions and verify with mypy
- [ ] T091 Run validation tests from quickstart.md to verify all documented examples work correctly
- [ ] T092 Performance optimization: Benchmark validation speed against SC-002 target (10M rows in <60s)
- [ ] T093 Performance optimization: Benchmark profiling speed against SC-003 target (100M rows in <30s with sampling)
- [ ] T094 Add error handling and validation for edge cases (empty DataFrames, missing columns, invalid parameters)
- [ ] T095 Security review: Ensure validation reports don't expose sensitive data values
- [ ] T096 Add configuration options for PII column exclusion in profiling

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-6)**: All depend on Foundational phase completion
  - User stories can proceed in parallel (if staffed) after Phase 2
  - Or sequentially in priority order (US1 → US2 → US3 → US4)
- **Templates (Phase 7)**: Depends on User Story 1 completion (ValidationRule API)
- **Reporting (Phase 8)**: Depends on User Story 1 completion (ValidationResult API)
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Independent of US1 (different module: profiler.py vs validator.py)
- **User Story 3 (P3)**: Depends on User Story 1 completion - Quality gates use ValidationRuleset and ValidationResult
- **User Story 4 (P4)**: Depends on User Story 2 completion - Anomaly detection uses DataProfile from profiler

### Within Each User Story

**User Story 1 (Validation)**:
1. ValidationRuleset and ValidationResult classes (T010, T011) - can be parallel
2. Validation execution engine (T012) - depends on T010
3. Rule-specific validation logic (T013-T018) - can be parallel after T012
4. Violation collection (T019) - depends on rule validation logic
5. Serialization and logging (T020-T022) - can be parallel after core validation works

**User Story 2 (Profiling)**:
1. DataProfile dataclass (T024) and DataProfiler class (T025) - can be parallel
2. Sampling algorithms (T026-T027) - can be parallel
3. Column-specific profiling (T028-T030) - can be parallel
4. Base statistics and schema digest (T031-T032) - can be parallel with column profiling
5. Main profile() method (T034) - depends on all profiling logic
6. Serialization and logging (T035) - after core profiling works

**User Story 3 (Quality Gates)**:
1. GateAction enum and QualityGateException (T037-T038) - can be parallel
2. QualityGate class (T039) - after enums/exceptions
3. check() method with action handling (T040-T043) - sequential, building on check() logic
4. Result caching and logging (T044-T046) - after check() method

**User Story 4 (Anomaly Detection)**:
1. Data models (T048-T051, Baseline and Anomaly entities) - can all be parallel
2. BaselineStore methods (T053-T055) - sequential after Baseline model
3. AnomalyDetector methods (T058-T062) - can be parallel after AnomalyDetector init (T057)
4. Main detect() method (T063) - depends on all anomaly detection logic
5. Profile comparison (T064) - can happen in parallel with anomaly detector implementation

### Parallel Opportunities

- All Setup tasks (T001-T004) can run in parallel
- Most Foundational tasks (T005-T008) can run in parallel
- Within User Story 1: T010-T011 parallel, T013-T018 parallel after T012
- Within User Story 2: T024-T025 parallel, T026-T027 parallel, T028-T032 parallel
- Within User Story 3: T037-T038 parallel
- Within User Story 4: T048-T051 parallel, T058-T062 parallel
- User Story 1 and User Story 2 can run completely in parallel (different modules)
- All template tasks (T067-T070) can run in parallel
- All reporting tasks (T073-T074) can run in parallel
- All unit test tasks (T080-T085) can run in parallel
- All integration test tasks (T086-T088) can run in parallel

---

## Parallel Example: User Story 1 (Validation)

```bash
# Launch foundational models in parallel:
Task T010: "Implement ValidationRuleset class with add_rule(), remove_rule(), and rule management"
Task T011: "Implement ValidationResult dataclass with properties and to_dataframe() method"

# After T012 (validation engine), launch rule validation logic in parallel:
Task T013: "Implement uniqueness rule validation logic using Spark countDistinct()"
Task T014: "Implement freshness rule validation logic using timestamp comparison"
Task T015: "Implement schema rule validation logic"
Task T016: "Implement pattern rule validation logic using Spark rlike()"
Task T017: "Implement range rule validation logic"
Task T018: "Implement custom rule validation logic"

# After rule logic completes, launch serialization and logging in parallel:
Task T020: "Implement ruleset serialization (to_json(), from_json())"
Task T021: "Implement validation result serialization"
Task T022: "Add logging integration with databricks-shared-utilities logger"
```

---

## Parallel Example: User Story 2 (Profiling)

```bash
# Launch profiling data models in parallel:
Task T024: "Implement DataProfile dataclass with methods"
Task T025: "Implement DataProfiler class initialization"

# Launch sampling algorithms in parallel:
Task T026: "Implement reservoir sampling algorithm"
Task T027: "Implement stratified sampling logic"

# Launch column-specific profiling in parallel:
Task T028: "Implement numeric column profiling"
Task T029: "Implement string column profiling"
Task T030: "Implement timestamp column profiling"
Task T031: "Implement base column statistics"
Task T032: "Implement schema digest generation"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T009) - CRITICAL
3. Complete Phase 3: User Story 1 (T010-T023)
4. **STOP and VALIDATE**: Test validation with quickstart.md examples
5. Deploy/demo validation capabilities

**Why US1 as MVP**: Validation is the core capability that enables data engineers to catch data quality issues early. It's independently useful without profiling or gates.

### Incremental Delivery

1. **MVP** (Setup + Foundational + US1): Basic validation → Deploy
2. **v2** (+ US2): Add profiling for data exploration → Deploy
3. **v3** (+ US3): Add quality gates for pipeline integration → Deploy
4. **v4** (+ US4): Add anomaly detection for drift monitoring → Deploy
5. **v5** (+ Templates + Reporting + Polish): Production-ready with all enhancements

Each increment adds value without breaking previous capabilities.

### Parallel Team Strategy

With multiple developers:

1. **Setup + Foundational** (1-2 days): Team works together on T001-T009
2. **Once Foundational completes**:
   - Developer A: User Story 1 (Validation) - T010-T023
   - Developer B: User Story 2 (Profiling) - T024-T036 (parallel with A)
   - Developer C: Tests and Polish setup - T079-T090 (as US1/US2 complete)
3. **After US1 completes**:
   - Developer A: User Story 3 (Gates) - T037-T047
   - Developer B: Continue User Story 2 if not done
   - Developer C: Templates and Reporting - T067-T078
4. **After US2 completes**:
   - Developer B: User Story 4 (Anomaly Detection) - T048-T066
5. **Final Phase**: All developers on Polish & Testing - T079-T096

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Performance targets: 10M rows validation in <60s, 100M rows profiling in <30s
- Follow existing databricks-shared-utilities patterns for logging and configuration
- Use Pydantic for all data models to ensure type safety and serialization support

---

## Task Summary

- **Total tasks**: 96
- **Setup tasks**: 4 (T001-T004)
- **Foundational tasks**: 5 (T005-T009)
- **User Story 1 tasks**: 14 (T010-T023) - Validation
- **User Story 2 tasks**: 13 (T024-T036) - Profiling
- **User Story 3 tasks**: 11 (T037-T047) - Quality Gates
- **User Story 4 tasks**: 19 (T048-T066) - Anomaly Detection
- **Template tasks**: 6 (T067-T072)
- **Reporting tasks**: 6 (T073-T078)
- **Polish tasks**: 18 (T079-T096)

**Parallel opportunities**: 45+ tasks marked [P] can run in parallel within constraints
**MVP scope**: Phases 1-3 (T001-T023) = 23 tasks for basic validation capability
**Independent stories**: US1 and US2 are fully independent and can run in parallel
