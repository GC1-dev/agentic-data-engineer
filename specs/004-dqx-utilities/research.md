# Research: DQX Data Quality Framework Integration Utilities

**Feature**: `004-dqx-utilities`
**Date**: 2025-11-22
**Purpose**: Research technical approaches, patterns, and best practices for implementing data quality validation, profiling, and anomaly detection for Spark DataFrames

---

## 1. Data Quality Validation Patterns for Spark DataFrames

### Decision
Use declarative rule-based validation with lazy evaluation and built-in Spark aggregation functions for distributed validation.

### Rationale
- **Performance**: Spark's native aggregations (count, countDistinct, etc.) are optimized for distributed execution
- **Composability**: Rules can be combined and evaluated in a single DataFrame pass using multiple aggregations
- **Error Reporting**: Violations can be collected as DataFrames, enabling filtering, sampling, and storage of violation details
- **Extensibility**: Custom validation functions can be registered as UDFs for domain-specific rules

### Implementation Pattern
```python
# Rule definition (declarative)
ruleset = ValidationRuleset([
    CompletenessRule(column="user_id", allow_null=False, severity="critical"),
    UniquenessRule(column="email", severity="critical"),
    FreshnessRule(column="created_at", max_age_hours=24, severity="warning"),
    SchemaRule(required_columns=["user_id", "email", "created_at"])
])

# Validation execution (single pass when possible)
result = ruleset.validate(dataframe)
# Result contains: pass/fail, violation DataFrame, summary statistics
```

### Alternatives Considered
- **Row-by-row validation**: Rejected due to poor performance on large datasets; doesn't leverage Spark's distributed aggregations
- **External tools integration (Great Expectations, Deequ)**: Rejected to maintain standalone utility without heavy dependencies; DQX provides focused, lightweight alternative
- **SQL-based validation**: Rejected because Pydantic models provide better type safety and IDE support than string-based SQL

### Key Patterns
1. **Single-pass validation**: Combine multiple aggregations into one DataFrame operation
2. **Violation sampling**: For large violation sets, sample representative examples
3. **Lazy rule evaluation**: Rules return validation expressions, not immediate results
4. **Result accumulation**: All rule results collected into unified ValidationResult object

---

## 2. Statistical Sampling Strategies for Large-Scale Profiling

### Decision
Use reservoir sampling with configurable sample size and stratified sampling for skewed distributions.

### Rationale
- **Scalability**: Reservoir sampling maintains fixed memory footprint regardless of DataFrame size
- **Accuracy**: Stratified sampling ensures representation from all partition groups
- **Performance**: Sampling converts O(n) full scans to O(sample_size) for profile generation
- **Statistical validity**: Sample size of 10,000-100,000 rows provides <5% margin of error for most statistics

### Implementation Approach
```python
# Profiler with adaptive sampling
profiler = DataProfiler(
    sample_size=100000,  # Configurable
    stratify_by="date",  # Optional column for stratification
    sampling_method="reservoir"  # or "systematic", "random"
)

profile = profiler.profile(dataframe)
# Profile includes: summary stats, distributions, correlations, quality scores
```

### Sampling Methods
1. **Reservoir sampling**: For uniform random samples from streaming data
2. **Systematic sampling**: Every nth row; faster but may introduce bias with ordered data
3. **Stratified sampling**: Ensure representation across partition key values
4. **Adaptive sampling**: Increase sample size for high-variance columns

### Accuracy Guarantees
- Numeric statistics (mean, stddev): ±5% with 95% confidence at sample_size=10,000
- Distinct counts: HyperLogLog approximation for large cardinalities
- Percentiles: T-Digest algorithm for accurate quantile estimation from samples

### Alternatives Considered
- **Full DataFrame scans**: Rejected due to prohibitive cost on billion-row datasets
- **Fixed percentage sampling**: Rejected because small datasets over-sample, large datasets under-sample
- **Approximate aggregations only**: Rejected because some rules require exact counts (uniqueness, completeness)

---

## 3. Anomaly Detection and Data Drift Methods

### Decision
Use Kolmogorov-Smirnov test for continuous distributions, Chi-square test for categorical distributions, and threshold-based checks for volume/schema anomalies.

### Rationale
- **Statistical rigor**: KS-test and Chi-square are standard methods with well-understood properties
- **Non-parametric**: No assumptions about data distributions (unlike t-test, z-test)
- **Interpretability**: P-values provide clear significance thresholds
- **Lightweight**: scipy provides efficient implementations without ML training overhead

### Implementation Approach
```python
# Baseline persistence
baseline = profiler.profile(historical_dataframe)
baseline_store.save(baseline, table_name="users", timestamp=datetime.now())

# Drift detection
current_profile = profiler.profile(current_dataframe)
anomalies = detect_drift(baseline, current_profile, thresholds={
    "volume_change": 0.5,  # 50% change triggers alert
    "distribution_pvalue": 0.01,  # p<0.01 indicates significant drift
    "schema_change": "any"  # Any column addition/removal
})
```

### Detection Methods

**1. Volume Anomalies** (threshold-based)
- Row count change > 50%: Critical alert
- Row count change > 20%: Warning alert

**2. Distribution Drift** (statistical tests)
- **Numeric columns**: Kolmogorov-Smirnov two-sample test
  - Null hypothesis: Current and baseline distributions are same
  - Reject if p-value < 0.01 (99% confidence)
- **Categorical columns**: Chi-square test for category proportions
- **Timestamp columns**: Compare min/max dates and freshness metrics

**3. Schema Drift** (structural comparison)
- New columns added
- Columns removed
- Data type changes
- Nullability changes

**4. Statistical Drift** (summary statistics)
- Mean/median shift > 2 standard deviations
- Null rate change > 10 percentage points
- Distinct count change > 50%

### Alternatives Considered
- **ML-based anomaly detection**: Rejected due to training overhead, cold-start problem, and complexity for simple drift detection
- **Z-score anomalies**: Rejected because assumes normal distribution; KS-test is distribution-agnostic
- **Time-series models (ARIMA, Prophet)**: Out of scope; focused on batch DataFrame comparison, not time-series forecasting

---

## 4. Rule Definition DSL and API Design

### Decision
Use Pydantic models for type-safe rule definitions with builder pattern for fluent API.

### Rationale
- **Type safety**: Pydantic provides runtime validation and IDE autocomplete
- **Serialization**: Rules can be saved/loaded as JSON for configuration management
- **Extensibility**: Easy to add custom rule types by subclassing BaseRule
- **Validation**: Pydantic ensures rule parameters are valid before execution

### API Design Pattern
```python
# Declarative style (Pydantic models)
from databricks_utils.data_quality import ValidationRule, Severity

rules = [
    ValidationRule.completeness(
        column="user_id",
        allow_null=False,
        severity=Severity.CRITICAL
    ),
    ValidationRule.uniqueness(
        column="email",
        severity=Severity.CRITICAL
    ),
    ValidationRule.range(
        column="age",
        min_value=0,
        max_value=120,
        severity=Severity.WARNING
    ),
    ValidationRule.pattern(
        column="email",
        regex=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        severity=Severity.WARNING
    )
]

# Builder/fluent API (alternative for complex rules)
ruleset = (
    ValidationRuleset()
    .add_completeness("user_id", severity="critical")
    .add_uniqueness("email", severity="critical")
    .add_custom(lambda df: df.filter(col("age") < 0).count() == 0, "age_positive")
)
```

### Rule Template Library
Pre-built templates for common patterns:
```python
from databricks_utils.data_quality.templates import EmailRule, DateRangeRule, NumericBoundsRule

# Use pre-built templates
rules = [
    EmailRule(column="email"),
    DateRangeRule(column="birth_date", min_date="1900-01-01", max_date="today"),
    NumericBoundsRule(column="salary", min_value=0, max_value=1000000)
]
```

### Alternatives Considered
- **SQL string-based rules**: Rejected due to lack of type safety and error-prone string manipulation
- **YAML configuration only**: Rejected because programmatic API provides more flexibility and testability
- **Function-based API only**: Rejected because declarative rules are easier to serialize and audit

---

## 5. Quality Gate Implementation Strategies

### Decision
Implement quality gates as exception-raising checkpoints with configurable behavior (fail-fast vs. collect-all).

### Rationale
- **Pipeline integration**: Exceptions naturally halt pipeline execution for critical failures
- **Flexibility**: Warning-level violations can be logged without stopping execution
- **Visibility**: Violations are logged to databricks-shared-utilities logger for observability
- **Composability**: Multiple gates can be chained at different pipeline stages

### Implementation Pattern
```python
from databricks_utils.data_quality import QualityGate, GateAction

# Define gate with thresholds
gate = QualityGate(
    name="bronze_ingestion_gate",
    rules=ruleset,
    actions={
        Severity.CRITICAL: GateAction.RAISE,  # Stop pipeline
        Severity.WARNING: GateAction.LOG,     # Log only
        Severity.INFO: GateAction.IGNORE
    }
)

# Execute gate (raises exception on critical failures)
try:
    gate.check(dataframe)
    # Continue pipeline if gate passes
    dataframe.write.saveAsTable("bronze.users")
except QualityGateException as e:
    logger.error(f"Quality gate failed: {e.violations}")
    # Handle failure (alert, rollback, etc.)
```

### Gate Behaviors
1. **Fail-fast (RAISE)**: Immediately raises exception on first critical violation
2. **Collect-all (COLLECT_THEN_RAISE)**: Executes all rules, then raises with all violations
3. **Log-only (LOG)**: Logs violations but continues execution
4. **Ignore (IGNORE)**: Skips rule evaluation entirely

### Integration Strategies
- **Databricks Jobs**: Gate failures fail the job with violation details in logs
- **Notebooks**: Interactive mode shows violation report in notebook output
- **CI/CD**: Gate failures prevent deployment to production
- **Orchestration (Airflow/DLT)**: Gate status determines downstream task execution

### Alternatives Considered
- **Return boolean flags**: Rejected because exceptions provide better error propagation in Python pipelines
- **Decorator-based gates**: Considered but rejected; explicit gate.check() calls provide clearer control flow
- **Async validation**: Out of scope for v1; synchronous validation sufficient for batch processing

---

## 6. Baseline Persistence and Versioning

### Decision
Store baselines as Delta Lake tables with partitioning by table name and timestamp.

### Rationale
- **Native integration**: Delta Lake is standard in Databricks environment
- **Time travel**: Delta's version history enables baseline comparison across time
- **Schema evolution**: Delta handles schema changes gracefully
- **Performance**: Partitioning by table_name enables fast baseline retrieval

### Storage Schema
```python
# Baseline storage table schema
baselines/
  table_name=users/
    timestamp=2025-11-20/
      profile.parquet  # Serialized DataProfile
```

### Baseline Versioning Strategy
- **Semantic versioning**: Major (breaking schema changes), Minor (new columns), Patch (data updates)
- **Timestamp-based**: Each baseline snapshot includes creation timestamp
- **Retention policy**: Keep last N baselines per table (configurable, default 30 days)

### Alternatives Considered
- **JSON files in cloud storage**: Rejected due to lack of schema evolution and time travel
- **External database**: Rejected to avoid additional infrastructure dependencies
- **In-memory only**: Rejected because baselines must persist across pipeline runs

---

## 7. Validation Report Generation and Storage

### Decision
Generate reports as both structured DataFrames (for programmatic access) and JSON (for storage/dashboards).

### Rationale
- **Dual format**: DataFrames for pipeline integration, JSON for persistence and visualization
- **Queryable**: Stored as Delta tables, enabling SQL-based analysis and dashboards
- **Structured**: Consistent schema across all report types
- **Actionable**: Include violation examples, affected row counts, and remediation suggestions

### Report Schema
```python
{
    "validation_id": "uuid",
    "table_name": "bronze.users",
    "timestamp": "2025-11-22T10:30:00Z",
    "overall_status": "FAILED",
    "rules_evaluated": 10,
    "rules_passed": 8,
    "rules_failed": 2,
    "violations": [
        {
            "rule_name": "user_id_completeness",
            "severity": "CRITICAL",
            "violation_count": 1523,
            "violation_percentage": 0.15,
            "sample_violations": [...],  # First 10 examples
            "remediation": "Check upstream data source for null user_ids"
        }
    ],
    "execution_time_seconds": 45.2,
    "dataframe_row_count": 10000000
}
```

### Alternatives Considered
- **HTML reports**: Out of scope; focus on structured data, not visualization
- **Slack/email notifications**: Out of scope; integrate with existing alerting via databricks-shared-utilities logging
- **Real-time streaming**: Out of scope for batch validation use case

---

## 8. Performance Optimization Strategies

### Key Optimizations
1. **Single-pass validation**: Combine multiple aggregations into one Spark action
2. **Lazy evaluation**: Build execution plan before running (avoid multiple DataFrame passes)
3. **Predicate pushdown**: Schema and pattern rules evaluated before expensive aggregations
4. **Partition pruning**: For incremental validation, only process changed partitions
5. **Broadcast joins**: For reference data validation (e.g., foreign key checks)

### Benchmarking Targets
- 10M rows, 10 rules: <60 seconds (target from SC-002)
- 100M rows, profiling with sampling: <30 seconds (target from SC-003)
- Pipeline overhead: <10% (target from SC-007)

---

## Summary

This research establishes the technical foundation for DQX utilities implementation:

1. **Validation**: Declarative, rule-based, leveraging Spark's distributed aggregations
2. **Profiling**: Reservoir sampling with stratified support for billion-row datasets
3. **Anomaly Detection**: Statistical tests (KS, Chi-square) for distribution drift
4. **API Design**: Pydantic-based type-safe rules with fluent builder pattern
5. **Quality Gates**: Exception-based checkpoints with configurable actions
6. **Persistence**: Delta Lake for baselines and reports
7. **Performance**: Single-pass validation, lazy evaluation, sampling for scale

All technical uncertainties from the plan have been resolved. Proceeding to Phase 1 (Design & Contracts).
