# Quick Start Guide: DQX Data Quality Framework

**Feature**: `004-dqx-utilities`
**Date**: 2025-11-22

## Overview

DQX provides comprehensive data quality validation, profiling, quality gates, and anomaly detection for Spark DataFrames in Databricks environments. This guide helps you get started with common use cases.

---

## Installation

DQX utilities are included in `databricks-shared-utilities`:

```bash
pip install databricks-shared-utilities>=0.3.0
```

---

## Quick Start Examples

### 1. Basic Data Validation

Validate a DataFrame against data quality rules:

```python
from pyspark.sql import SparkSession
from databricks_utils.data_quality import ValidationRule, ValidationRuleset, Severity

# Create Spark session (or use existing)
spark = SparkSession.builder.appName("dqx_example").getOrCreate()

# Load data
df = spark.table("bronze.users")

# Define validation rules
ruleset = ValidationRuleset(name="user_validation")
ruleset.add_rule(
    ValidationRule.completeness(
        column="user_id",
        allow_null=False,
        severity=Severity.CRITICAL
    )
)
ruleset.add_rule(
    ValidationRule.uniqueness(
        column="email",
        severity=Severity.CRITICAL
    )
)
ruleset.add_rule(
    ValidationRule.freshness(
        column="created_at",
        max_age_hours=24,
        severity=Severity.WARNING
    )
)

# Validate DataFrame
result = ruleset.validate(df)

# Check results
print(f"Overall status: {result.overall_status}")
print(f"Pass rate: {result.pass_rate:.1%}")

if result.violations:
    print("Violations:")
    for violation in result.violations:
        print(f"  - [{violation.severity}] {violation.message}")
        print(f"    Remediation: {violation.remediation_suggestion}")
```

**Output**:
```
Overall status: FAILED
Pass rate: 66.7%
Violations:
  - [CRITICAL] 1,523 rows (0.15%) have null user_id values
    Remediation: Check upstream data source for null user_ids
  - [WARNING] Data is 36 hours old (created_at max: 2025-11-20 22:00:00)
    Remediation: Verify upstream pipeline is running on schedule
```

---

### 2. Data Profiling

Generate comprehensive statistical profiles:

```python
from databricks_utils.data_quality import DataProfiler

# Create profiler with sampling
profiler = DataProfiler(
    sample_size=100000,
    sampling_method="reservoir"
)

# Profile DataFrame
profile = profiler.profile(df)

print(f"Table: {profile.table_name}")
print(f"Row count: {profile.row_count:,}")
print(f"Column count: {profile.column_count}")
print(f"Sample size: {profile.sample_size:,}")

# Inspect column profiles
for column_name, column_profile in profile.column_profiles.items():
    print(f"\nColumn: {column_name}")
    print(f"  Data type: {column_profile.data_type}")
    print(f"  Null rate: {column_profile.null_percentage:.2f}%")
    print(f"  Distinct count: {column_profile.distinct_count:,}")

    # Numeric columns
    if hasattr(column_profile, "mean"):
        print(f"  Mean: {column_profile.mean:.2f}")
        print(f"  Median: {column_profile.median:.2f}")
        print(f"  Range: [{column_profile.min_value}, {column_profile.max_value}]")

    # String columns
    if hasattr(column_profile, "avg_length"):
        print(f"  Avg length: {column_profile.avg_length:.1f}")
        print(f"  Top values: {column_profile.most_common_values[:3]}")
```

---

### 3. Quality Gates in Pipelines

Enforce data quality thresholds at pipeline stages:

```python
from databricks_utils.data_quality import QualityGate, GateAction, QualityGateException

# Create quality gate
gate = QualityGate(
    name="bronze_ingestion_gate",
    ruleset=ruleset,
    actions={
        Severity.CRITICAL: GateAction.RAISE,  # Stop pipeline
        Severity.WARNING: GateAction.LOG,     # Log only
        Severity.INFO: GateAction.IGNORE      # Skip
    }
)

# Execute gate in pipeline
def bronze_ingestion_pipeline():
    # Read source data
    df = spark.read.format("delta").load("/mnt/source/users")

    try:
        # Quality gate checkpoint
        result = gate.check(df, table_name="bronze.users")

        # Gate passed - continue pipeline
        df.write.mode("overwrite").saveAsTable("bronze.users")
        print(f"✓ Pipeline completed. Validation pass rate: {result.pass_rate:.1%}")

    except QualityGateException as e:
        # Gate failed - handle error
        print(f"✗ Quality gate failed: {e.gate_name}")
        print(f"  Critical violations: {len([v for v in e.violations if v.severity == Severity.CRITICAL])}")

        # Log violations for debugging
        for violation in e.violations:
            if violation.severity == Severity.CRITICAL:
                print(f"  - {violation.message}")

        # Optionally send alert, rollback, etc.
        raise

# Run pipeline
bronze_ingestion_pipeline()
```

---

### 4. Anomaly Detection and Drift Monitoring

Detect data drift by comparing against historical baselines:

```python
from databricks_utils.data_quality import BaselineStore, AnomalyDetector

# Initialize baseline store
baseline_store = BaselineStore(storage_path="baselines.data_quality")

# FIRST RUN: Create baseline
def create_baseline():
    df = spark.table("bronze.users")

    # Profile data
    profiler = DataProfiler(sample_size=100000)
    profile = profiler.profile(df)

    # Save as baseline
    baseline = baseline_store.save(
        profile,
        table_name="bronze.users",
        version="1.0.0",
        set_as_active=True
    )

    print(f"✓ Baseline created: {baseline.baseline_id}")

# SUBSEQUENT RUNS: Detect drift
def detect_drift():
    df = spark.table("bronze.users")

    # Profile current data
    profiler = DataProfiler(sample_size=100000)
    current_profile = profiler.profile(df)

    # Load baseline
    baseline = baseline_store.load("bronze.users")

    # Detect anomalies
    detector = AnomalyDetector(
        volume_change_threshold=0.5,      # 50% volume change
        distribution_pvalue_threshold=0.01,  # 99% confidence
        statistical_deviation_threshold=2.0  # 2 std deviations
    )

    report = detector.detect(baseline, current_profile)

    if report.anomalies:
        print(f"⚠ Anomalies detected: {len(report.anomalies)}")
        print(f"  Overall severity: {report.overall_severity}")

        for anomaly in report.anomalies:
            print(f"\n  [{anomaly.severity}] {anomaly.anomaly_type}")
            print(f"    {anomaly.message}")
            print(f"    Baseline: {anomaly.baseline_value}")
            print(f"    Current: {anomaly.current_value}")
            print(f"    Remediation: {anomaly.remediation_suggestion}")
    else:
        print("✓ No anomalies detected")

# Run drift detection
detect_drift()
```

**Example Output**:
```
⚠ Anomalies detected: 3
  Overall severity: CRITICAL

  [CRITICAL] VOLUME
    Row count decreased by 52% (10,000,000 → 4,800,000 rows)
    Baseline: 10000000
    Current: 4800000
    Remediation: Check for upstream data pipeline failures

  [WARNING] DISTRIBUTION
    Distribution shift detected in 'age' column (KS-test p<0.01)
    Baseline: KS statistic=0.15
    Current: KS statistic=0.45
    Remediation: Investigate changes in age distribution patterns

  [WARNING] STATISTICAL
    Mean shift in 'order_amount' exceeds 2 std deviations
    Baseline: mean=125.50, stddev=45.20
    Current: mean=220.75, stddev=52.30
    Remediation: Review pricing changes or fraud patterns
```

---

## Common Patterns

### Pattern 1: Pre-built Rule Templates

Use pre-built templates for common validation patterns:

```python
from databricks_utils.data_quality.templates import (
    EmailRule,
    DateRangeRule,
    NumericBoundsRule,
    PhoneNumberRule
)

ruleset = ValidationRuleset(name="user_validation")
ruleset.add_rule(EmailRule(column="email"))
ruleset.add_rule(DateRangeRule(column="birth_date", min_date="1900-01-01", max_date="today"))
ruleset.add_rule(NumericBoundsRule(column="age", min_value=0, max_value=120))
ruleset.add_rule(PhoneNumberRule(column="phone", country_code="US"))
```

### Pattern 2: Custom Validation Logic

Define custom validation functions:

```python
from pyspark.sql.functions import col

def validate_email_domain(df):
    """Ensure emails are from allowed domains."""
    allowed_domains = ["company.com", "partner.com"]
    invalid_count = df.filter(
        ~col("email").rlike(f"@({'|'.join(allowed_domains)})$")
    ).count()
    return invalid_count == 0

ruleset.add_rule(
    ValidationRule.custom(
        validation_func=validate_email_domain,
        name="email_domain_check",
        description="Email must be from allowed domains",
        severity=Severity.CRITICAL
    )
)
```

### Pattern 3: Conditional Validation

Apply different rules based on environment:

```python
import os

env = os.getenv("ENV", "dev")

if env == "prod":
    # Strict rules for production
    ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=False, severity=Severity.CRITICAL))
    ruleset.add_rule(ValidationRule.freshness("created_at", max_age_hours=1, severity=Severity.CRITICAL))
else:
    # Relaxed rules for dev
    ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=True, severity=Severity.WARNING))
    ruleset.add_rule(ValidationRule.freshness("created_at", max_age_hours=24, severity=Severity.INFO))
```

### Pattern 4: Incremental Validation

Validate only new/changed partitions:

```python
# Validate only today's partition
from datetime import date

today = date.today().strftime("%Y-%m-%d")
df_incremental = spark.table("bronze.users").filter(f"date_partition = '{today}'")

result = ruleset.validate(df_incremental)
```

### Pattern 5: Validation Report Persistence

Save validation results for historical analysis:

```python
from databricks_utils.data_quality import ReportGenerator, ReportFormat

# Generate report
generator = ReportGenerator()
report_df = generator.generate(
    result,
    format=ReportFormat.DATAFRAME
)

# Save to Delta table
report_df.write.mode("append").partitionBy("date", "table_name").saveAsTable("monitoring.dqx_validation_results")

# Query historical results
spark.sql("""
    SELECT
        date,
        table_name,
        overall_status,
        pass_rate,
        failed_rules
    FROM monitoring.dqx_validation_results
    WHERE table_name = 'bronze.users'
    ORDER BY date DESC
    LIMIT 30
""").show()
```

---

## Integration with Existing Utilities

### Integration with databricks-shared-utilities Logging

```python
from databricks_utils.logging import get_logger

logger = get_logger(__name__, context={"pipeline": "bronze_ingestion"})

# Validation results are automatically logged
result = ruleset.validate(df)

if result.has_critical_failures:
    logger.error(f"Critical validation failures: {result.failed_rules}")
    for violation in result.violations:
        if violation.severity == Severity.CRITICAL:
            logger.error(f"  {violation.message}", extra={"violation": violation})
else:
    logger.info(f"Validation passed: {result.pass_rate:.1%} pass rate")
```

### Integration with Monte Carlo Utilities (Optional)

```python
from databricks_utils.observability import MonteCarloClient

# Send validation results to Monte Carlo
mc_client = MonteCarloClient()

for violation in result.violations:
    mc_client.send_custom_metric(
        table_name="bronze.users",
        metric_name=f"dqx_violation_{violation.rule_name}",
        value=violation.violation_count,
        timestamp=result.timestamp
    )
```

---

## Performance Optimization

### Tip 1: Use Sampling for Large DataFrames

```python
# Profile with sampling (fast)
profiler = DataProfiler(sample_size=100000)
profile = profiler.profile(df)  # <30 seconds for 100M rows

# Full validation (slower but exact)
profiler_full = DataProfiler(sample_size=None)  # No sampling
profile_full = profiler_full.profile(df)  # May take minutes
```

### Tip 2: Combine Rules for Single-Pass Validation

```python
# DQX automatically combines compatible rules into single DataFrame pass
ruleset = ValidationRuleset(name="optimized")
ruleset.add_rule(ValidationRule.completeness("user_id"))
ruleset.add_rule(ValidationRule.uniqueness("email"))
ruleset.add_rule(ValidationRule.range("age", min_value=0, max_value=120))

# All three rules evaluated in one pass over DataFrame
result = ruleset.validate(df)
```

### Tip 3: Partition Pruning for Incremental Validation

```python
# Validate only changed partitions
latest_partition = spark.sql("SELECT MAX(date_partition) FROM bronze.users").collect()[0][0]
df_latest = spark.table("bronze.users").filter(f"date_partition = '{latest_partition}'")
result = ruleset.validate(df_latest)
```

---

## Troubleshooting

### Issue: Validation Takes Too Long

**Solution**: Enable sampling for profiling, reduce sample_violations parameter

```python
# Fast profiling with sampling
profiler = DataProfiler(sample_size=50000)

# Fast validation with limited violation sampling
result = ruleset.validate(df, sample_violations=5)
```

### Issue: Quality Gate Raises Exception for Warnings

**Solution**: Configure gate actions correctly

```python
gate = QualityGate(
    name="my_gate",
    ruleset=ruleset,
    actions={
        Severity.CRITICAL: GateAction.RAISE,      # Raise exception
        Severity.WARNING: GateAction.LOG,         # Log only (don't raise)
        Severity.INFO: GateAction.IGNORE
    }
)
```

### Issue: Baseline Not Found

**Solution**: Create baseline before running drift detection

```python
baseline_store = BaselineStore("baselines.data_quality")

# Check if baseline exists
try:
    baseline = baseline_store.load("bronze.users")
except ValueError:
    # Create baseline if not found
    profile = profiler.profile(df)
    baseline = baseline_store.save(profile, "bronze.users")
```

---

## Next Steps

- **Deep Dive**: See [data-model.md](./data-model.md) for entity relationships
- **API Reference**: See [contracts/dqx-api.md](./contracts/dqx-api.md) for complete API documentation
- **Examples**: See `tests/integration/data_quality/` for more examples
- **Extend**: Create custom validation rules and templates for your domain

---

## Support

- **Documentation**: Full API reference in `contracts/dqx-api.md`
- **Examples**: Integration tests in `tests/integration/data_quality/`
- **Issues**: GitHub issues in databricks-shared-utilities repository
