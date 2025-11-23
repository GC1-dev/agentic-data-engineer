# API Contract: DQX Data Quality Framework

**Feature**: `004-dqx-utilities`
**Date**: 2025-11-22
**Package**: `databricks_utils.data_quality`
**Purpose**: Define public API contracts for DQX utilities

---

## Module Structure

```
databricks_utils.data_quality/
├── __init__.py                 # Public API exports
├── rules.py                    # ValidationRule, RuleType, Severity
├── validator.py                # ValidationRuleset, ValidationResult
├── profiler.py                 # DataProfiler, DataProfile
├── gates.py                    # QualityGate, GateAction
├── anomaly.py                  # AnomalyDetector, AnomalyReport
├── baseline.py                 # BaselineStore, Baseline
├── reports.py                  # ReportGenerator, ReportFormat
└── templates/                  # Pre-built rule templates
    ├── __init__.py
    ├── common.py               # EmailRule, DateRangeRule, etc.
    └── industry.py             # Industry-specific templates
```

---

## Public API (`__init__.py`)

### Exports

```python
from databricks_utils.data_quality.rules import (
    ValidationRule,
    RuleType,
    Severity,
)
from databricks_utils.data_quality.validator import (
    ValidationRuleset,
    ValidationResult,
    RuleViolation,
)
from databricks_utils.data_quality.profiler import (
    DataProfiler,
    DataProfile,
    ColumnProfile,
)
from databricks_utils.data_quality.gates import (
    QualityGate,
    GateAction,
    QualityGateException,
)
from databricks_utils.data_quality.anomaly import (
    AnomalyDetector,
    AnomalyReport,
    DetectedAnomaly,
)
from databricks_utils.data_quality.baseline import (
    BaselineStore,
    Baseline,
)
from databricks_utils.data_quality.reports import (
    ReportGenerator,
    ReportFormat,
)

__all__ = [
    # Rules
    "ValidationRule",
    "RuleType",
    "Severity",
    # Validation
    "ValidationRuleset",
    "ValidationResult",
    "RuleViolation",
    # Profiling
    "DataProfiler",
    "DataProfile",
    "ColumnProfile",
    # Quality Gates
    "QualityGate",
    "GateAction",
    "QualityGateException",
    # Anomaly Detection
    "AnomalyDetector",
    "AnomalyReport",
    "DetectedAnomaly",
    # Baselines
    "BaselineStore",
    "Baseline",
    # Reporting
    "ReportGenerator",
    "ReportFormat",
]
```

---

## 1. ValidationRule API (`rules.py`)

### Enums

```python
class RuleType(str, Enum):
    """Types of validation rules."""
    COMPLETENESS = "completeness"      # Null/missing value checks
    UNIQUENESS = "uniqueness"          # Duplicate detection
    FRESHNESS = "freshness"            # Data age/staleness checks
    SCHEMA = "schema"                  # Column presence and data type checks
    PATTERN = "pattern"                # Regex pattern matching
    RANGE = "range"                    # Numeric/date range checks
    CUSTOM = "custom"                  # User-defined validation functions


class Severity(str, Enum):
    """Severity levels for validation rules."""
    CRITICAL = "critical"              # Pipeline-blocking failures
    WARNING = "warning"                # Non-blocking issues
    INFO = "info"                      # Informational findings
```

### ValidationRule Class

```python
@dataclass
class ValidationRule:
    """
    Represents a single data quality validation rule.

    Attributes:
        rule_id: Unique identifier for the rule
        rule_type: Type of validation (from RuleType enum)
        name: Human-readable rule name
        description: Detailed rule description
        target_column: Column name being validated (None for multi-column rules)
        parameters: Rule-specific configuration parameters
        severity: Severity level (from Severity enum)
        enabled: Whether rule is active (default: True)
    """
    rule_id: str
    rule_type: RuleType
    name: str
    description: str
    target_column: Optional[str]
    parameters: Dict[str, Any]
    severity: Severity
    enabled: bool = True

    # Factory methods for common rules
    @classmethod
    def completeness(
        cls,
        column: str,
        allow_null: bool = False,
        severity: Severity = Severity.CRITICAL,
        name: Optional[str] = None,
    ) -> "ValidationRule":
        """
        Create a completeness rule (null/missing value check).

        Args:
            column: Column name to validate
            allow_null: Whether null values are allowed
            severity: Severity level
            name: Custom rule name (default: auto-generated)

        Returns:
            ValidationRule configured for completeness check

        Example:
            rule = ValidationRule.completeness(
                column="user_id",
                allow_null=False,
                severity=Severity.CRITICAL
            )
        """
        ...

    @classmethod
    def uniqueness(
        cls,
        column: str,
        severity: Severity = Severity.CRITICAL,
        name: Optional[str] = None,
    ) -> "ValidationRule":
        """
        Create a uniqueness rule (duplicate detection).

        Args:
            column: Column name to validate
            severity: Severity level
            name: Custom rule name

        Returns:
            ValidationRule configured for uniqueness check
        """
        ...

    @classmethod
    def freshness(
        cls,
        column: str,
        max_age_hours: int,
        severity: Severity = Severity.WARNING,
        name: Optional[str] = None,
    ) -> "ValidationRule":
        """
        Create a freshness rule (data age check).

        Args:
            column: Timestamp column name
            max_age_hours: Maximum allowed age in hours
            severity: Severity level
            name: Custom rule name

        Returns:
            ValidationRule configured for freshness check
        """
        ...

    @classmethod
    def pattern(
        cls,
        column: str,
        regex: str,
        severity: Severity = Severity.WARNING,
        name: Optional[str] = None,
    ) -> "ValidationRule":
        """
        Create a pattern rule (regex matching).

        Args:
            column: Column name to validate
            regex: Regular expression pattern
            severity: Severity level
            name: Custom rule name

        Returns:
            ValidationRule configured for pattern matching
        """
        ...

    @classmethod
    def range(
        cls,
        column: str,
        min_value: Optional[Union[int, float, datetime]] = None,
        max_value: Optional[Union[int, float, datetime]] = None,
        severity: Severity = Severity.WARNING,
        name: Optional[str] = None,
    ) -> "ValidationRule":
        """
        Create a range rule (numeric/date bounds check).

        Args:
            column: Column name to validate
            min_value: Minimum allowed value (inclusive)
            max_value: Maximum allowed value (inclusive)
            severity: Severity level
            name: Custom rule name

        Returns:
            ValidationRule configured for range validation
        """
        ...

    @classmethod
    def schema(
        cls,
        required_columns: List[str],
        optional_columns: Optional[List[str]] = None,
        severity: Severity = Severity.CRITICAL,
        name: Optional[str] = None,
    ) -> "ValidationRule":
        """
        Create a schema rule (column presence check).

        Args:
            required_columns: Columns that must be present
            optional_columns: Columns that may be present
            severity: Severity level
            name: Custom rule name

        Returns:
            ValidationRule configured for schema validation
        """
        ...

    @classmethod
    def custom(
        cls,
        validation_func: Callable[[DataFrame], bool],
        name: str,
        description: str,
        severity: Severity = Severity.WARNING,
    ) -> "ValidationRule":
        """
        Create a custom rule with user-defined validation function.

        Args:
            validation_func: Function taking DataFrame, returning True if valid
            name: Rule name
            description: Rule description
            severity: Severity level

        Returns:
            ValidationRule with custom validation logic

        Example:
            def check_positive_age(df):
                return df.filter(col("age") < 0).count() == 0

            rule = ValidationRule.custom(
                validation_func=check_positive_age,
                name="positive_age",
                description="Age must be positive"
            )
        """
        ...
```

---

## 2. ValidationRuleset API (`validator.py`)

```python
class ValidationRuleset:
    """
    Collection of validation rules applied together to a DataFrame.

    Attributes:
        ruleset_id: Unique identifier
        name: Descriptive ruleset name
        description: Ruleset purpose
        rules: List of ValidationRule objects
        metadata: Additional context
    """

    def __init__(
        self,
        name: str,
        rules: Optional[List[ValidationRule]] = None,
        description: str = "",
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """
        Initialize a validation ruleset.

        Args:
            name: Ruleset name
            rules: Initial list of rules (default: empty)
            description: Ruleset description
            metadata: Additional context (pipeline name, owner, etc.)
        """
        ...

    def add_rule(self, rule: ValidationRule) -> "ValidationRuleset":
        """
        Add a rule to the ruleset.

        Args:
            rule: ValidationRule to add

        Returns:
            Self (for method chaining)

        Raises:
            ValueError: If rule with same ID already exists
        """
        ...

    def remove_rule(self, rule_id: str) -> "ValidationRuleset":
        """
        Remove a rule from the ruleset.

        Args:
            rule_id: ID of rule to remove

        Returns:
            Self (for method chaining)

        Raises:
            KeyError: If rule_id not found
        """
        ...

    def validate(
        self,
        df: DataFrame,
        fail_fast: bool = False,
        sample_violations: int = 10,
    ) -> ValidationResult:
        """
        Execute all enabled rules against a DataFrame.

        Args:
            df: Spark DataFrame to validate
            fail_fast: Stop on first failure (default: False, collect all)
            sample_violations: Number of example violations to collect per rule

        Returns:
            ValidationResult with pass/fail status and violation details

        Raises:
            ValueError: If DataFrame is empty or no rules are enabled

        Example:
            ruleset = ValidationRuleset(name="user_validation")
            ruleset.add_rule(ValidationRule.completeness("user_id"))
            result = ruleset.validate(df)

            if result.overall_status == Status.FAILED:
                print(f"Validation failed: {result.failed_rules} failures")
                for violation in result.violations:
                    print(f"- {violation.message}")
        """
        ...

    def to_json(self) -> str:
        """
        Serialize ruleset to JSON string.

        Returns:
            JSON representation of ruleset
        """
        ...

    @classmethod
    def from_json(cls, json_str: str) -> "ValidationRuleset":
        """
        Deserialize ruleset from JSON string.

        Args:
            json_str: JSON representation of ruleset

        Returns:
            ValidationRuleset instance

        Raises:
            ValueError: If JSON is malformed or validation fails
        """
        ...


@dataclass
class ValidationResult:
    """
    Result of executing a ValidationRuleset against a DataFrame.

    Attributes:
        validation_id: Unique execution ID
        ruleset_id: Reference to ruleset used
        table_name: Fully qualified table name
        timestamp: Validation execution time
        overall_status: Status enum (PASSED, FAILED, WARNING, ERROR)
        total_rules: Total number of rules evaluated
        passed_rules: Number of rules that passed
        failed_rules: Number of rules that failed
        violations: List of RuleViolation objects
        execution_time_seconds: Total validation runtime
        dataframe_row_count: Total rows in validated DataFrame
        metadata: Additional execution context
    """
    validation_id: str
    ruleset_id: str
    table_name: str
    timestamp: datetime
    overall_status: Status
    total_rules: int
    passed_rules: int
    failed_rules: int
    violations: List[RuleViolation]
    execution_time_seconds: float
    dataframe_row_count: int
    metadata: Dict[str, Any]

    @property
    def pass_rate(self) -> float:
        """Calculate pass rate as decimal (0.0 to 1.0)."""
        return self.passed_rules / self.total_rules if self.total_rules > 0 else 0.0

    @property
    def has_critical_failures(self) -> bool:
        """Check if any violations have severity=CRITICAL."""
        return any(v.severity == Severity.CRITICAL for v in self.violations)

    @property
    def has_warnings(self) -> bool:
        """Check if any violations have severity=WARNING."""
        return any(v.severity == Severity.WARNING for v in self.violations)

    def to_dataframe(self, spark: SparkSession) -> DataFrame:
        """
        Convert validation result to Spark DataFrame.

        Args:
            spark: Active SparkSession

        Returns:
            DataFrame with validation result details
        """
        ...

    def to_json(self) -> str:
        """Serialize result to JSON string."""
        ...


@dataclass
class RuleViolation:
    """
    Details about a single rule violation.

    Attributes:
        rule_id: Reference to violated rule
        rule_name: Human-readable rule name
        severity: Severity level
        violation_count: Number of rows violating rule
        violation_percentage: Percentage of total rows (0-100)
        sample_violations: Example violating values
        affected_columns: Columns involved in violation
        message: Human-readable violation description
        remediation_suggestion: Actionable guidance
    """
    rule_id: str
    rule_name: str
    severity: Severity
    violation_count: int
    violation_percentage: float
    sample_violations: List[Any]
    affected_columns: List[str]
    message: str
    remediation_suggestion: str
```

---

## 3. DataProfiler API (`profiler.py`)

```python
class DataProfiler:
    """
    Generates statistical profiles for Spark DataFrames.

    Attributes:
        sample_size: Maximum rows to sample for profiling
        sampling_method: Sampling strategy ("reservoir", "systematic", "random")
        stratify_by: Optional column for stratified sampling
    """

    def __init__(
        self,
        sample_size: int = 100000,
        sampling_method: str = "reservoir",
        stratify_by: Optional[str] = None,
    ):
        """
        Initialize data profiler.

        Args:
            sample_size: Maximum rows to sample (default: 100,000)
            sampling_method: Sampling strategy (default: "reservoir")
            stratify_by: Column for stratification (default: None)
        """
        ...

    def profile(
        self,
        df: DataFrame,
        columns: Optional[List[str]] = None,
        compute_correlations: bool = False,
    ) -> DataProfile:
        """
        Generate comprehensive data profile for DataFrame.

        Args:
            df: Spark DataFrame to profile
            columns: Specific columns to profile (default: all columns)
            compute_correlations: Calculate column correlations (default: False)

        Returns:
            DataProfile with statistical summaries

        Raises:
            ValueError: If DataFrame is empty or columns don't exist

        Example:
            profiler = DataProfiler(sample_size=50000)
            profile = profiler.profile(df)

            print(f"Row count: {profile.row_count}")
            print(f"Column count: {profile.column_count}")

            user_id_profile = profile.get_column_profile("user_id")
            print(f"Null rate: {user_id_profile.null_percentage}%")
        """
        ...


@dataclass
class DataProfile:
    """
    Statistical profile for a DataFrame.

    Attributes:
        profile_id: Unique identifier
        table_name: Fully qualified table name
        timestamp: Profile generation time
        row_count: Total rows
        column_count: Total columns
        column_profiles: Dict mapping column name to ColumnProfile
        schema_digest: Hash of DataFrame schema
        sampling_method: Sampling method used
        sample_size: Actual sample size
        profile_metadata: Additional context
    """
    profile_id: str
    table_name: str
    timestamp: datetime
    row_count: int
    column_count: int
    column_profiles: Dict[str, ColumnProfile]
    schema_digest: str
    sampling_method: str
    sample_size: int
    profile_metadata: Dict[str, Any]

    def get_column_profile(self, column: str) -> ColumnProfile:
        """
        Retrieve profile for specific column.

        Args:
            column: Column name

        Returns:
            ColumnProfile instance

        Raises:
            KeyError: If column not found
        """
        ...

    def compare(self, other: "DataProfile") -> "ProfileComparison":
        """
        Compare this profile with another (drift detection).

        Args:
            other: Another DataProfile to compare against

        Returns:
            ProfileComparison with differences and drift metrics
        """
        ...

    def to_json(self) -> str:
        """Serialize profile to JSON string."""
        ...

    @classmethod
    def from_json(cls, json_str: str) -> "DataProfile":
        """Deserialize profile from JSON string."""
        ...
```

---

## 4. QualityGate API (`gates.py`)

```python
class QualityGateException(Exception):
    """
    Exception raised when a quality gate fails.

    Attributes:
        gate_name: Name of failed gate
        violations: List of RuleViolation objects
        result: Full ValidationResult
    """
    def __init__(
        self,
        gate_name: str,
        violations: List[RuleViolation],
        result: ValidationResult,
    ):
        ...


class GateAction(str, Enum):
    """Actions to take when validation fails."""
    RAISE = "raise"                      # Raise exception immediately
    COLLECT_THEN_RAISE = "collect_raise" # Collect all violations, then raise
    LOG = "log"                          # Log violations, continue execution
    IGNORE = "ignore"                    # Skip rule evaluation


class QualityGate:
    """
    Decision point in pipeline that enforces data quality thresholds.

    Attributes:
        gate_id: Unique identifier
        name: Gate name
        ruleset: ValidationRuleset to evaluate
        actions: Dict mapping Severity to GateAction
        enabled: Whether gate is active
    """

    def __init__(
        self,
        name: str,
        ruleset: ValidationRuleset,
        actions: Dict[Severity, GateAction],
        enabled: bool = True,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """
        Initialize quality gate.

        Args:
            name: Gate name
            ruleset: ValidationRuleset to execute
            actions: Severity → GateAction mapping
            enabled: Whether gate is active (default: True)
            metadata: Additional context
        """
        ...

    def check(
        self,
        df: DataFrame,
        table_name: str = "unknown",
    ) -> ValidationResult:
        """
        Execute quality gate validation.

        Args:
            df: DataFrame to validate
            table_name: Fully qualified table name for logging

        Returns:
            ValidationResult (if gate passes or warnings only)

        Raises:
            QualityGateException: If critical violations found and action=RAISE

        Example:
            gate = QualityGate(
                name="bronze_gate",
                ruleset=my_ruleset,
                actions={
                    Severity.CRITICAL: GateAction.RAISE,
                    Severity.WARNING: GateAction.LOG,
                    Severity.INFO: GateAction.IGNORE
                }
            )

            try:
                result = gate.check(df, table_name="bronze.users")
                # Gate passed, continue pipeline
                df.write.saveAsTable("bronze.users")
            except QualityGateException as e:
                logger.error(f"Gate failed: {e}")
                # Handle failure (alert, rollback, etc.)
        """
        ...

    def get_last_result(self) -> Optional[ValidationResult]:
        """
        Retrieve result from last check() call.

        Returns:
            ValidationResult or None if check() not yet called
        """
        ...
```

---

## 5. AnomalyDetector API (`anomaly.py`)

```python
class AnomalyDetector:
    """
    Detects data drift and anomalies by comparing current data against baseline.

    Attributes:
        thresholds: Dict of anomaly detection thresholds
    """

    def __init__(
        self,
        volume_change_threshold: float = 0.5,
        distribution_pvalue_threshold: float = 0.01,
        statistical_deviation_threshold: float = 2.0,
    ):
        """
        Initialize anomaly detector.

        Args:
            volume_change_threshold: Row count change % to trigger alert (default: 0.5 = 50%)
            distribution_pvalue_threshold: P-value for distribution drift (default: 0.01 = 99% confidence)
            statistical_deviation_threshold: Standard deviation multiplier for mean/median shifts (default: 2.0)
        """
        ...

    def detect(
        self,
        baseline: Baseline,
        current_profile: DataProfile,
    ) -> AnomalyReport:
        """
        Detect anomalies by comparing current profile against baseline.

        Args:
            baseline: Historical baseline profile
            current_profile: Current data profile

        Returns:
            AnomalyReport with detected anomalies

        Example:
            detector = AnomalyDetector(volume_change_threshold=0.3)

            baseline = baseline_store.load("bronze.users")
            current_profile = profiler.profile(current_df)

            report = detector.detect(baseline, current_profile)

            if report.overall_severity == Severity.CRITICAL:
                logger.critical(f"Critical anomalies detected: {len(report.anomalies)}")
                for anomaly in report.get_critical_anomalies():
                    logger.critical(f"- {anomaly.message}")
        """
        ...


@dataclass
class AnomalyReport:
    """
    Collection of detected anomalies.

    Attributes:
        report_id: Unique identifier
        table_name: Fully qualified table name
        baseline_id: Reference to baseline used
        current_profile_id: Reference to current profile
        timestamp: Detection timestamp
        anomalies: List of DetectedAnomaly objects
        overall_severity: Highest severity among anomalies
        metadata: Additional context
    """
    report_id: str
    table_name: str
    baseline_id: str
    current_profile_id: str
    timestamp: datetime
    anomalies: List[DetectedAnomaly]
    overall_severity: Severity
    metadata: Dict[str, Any]

    def get_critical_anomalies(self) -> List[DetectedAnomaly]:
        """Filter anomalies by severity=CRITICAL."""
        ...

    def get_anomalies_by_type(self, anomaly_type: AnomalyType) -> List[DetectedAnomaly]:
        """Filter anomalies by type."""
        ...
```

---

## 6. BaselineStore API (`baseline.py`)

```python
class BaselineStore:
    """
    Manages persistence and retrieval of baseline profiles.

    Attributes:
        storage_path: Delta Lake table path for baselines
    """

    def __init__(
        self,
        storage_path: str,
        spark: Optional[SparkSession] = None,
    ):
        """
        Initialize baseline store.

        Args:
            storage_path: Delta Lake table path (e.g., "baselines.data_quality")
            spark: SparkSession (default: use SparkSessionFactory)
        """
        ...

    def save(
        self,
        profile: DataProfile,
        table_name: str,
        version: str = "1.0.0",
        set_as_active: bool = True,
    ) -> Baseline:
        """
        Save a baseline profile.

        Args:
            profile: DataProfile to save as baseline
            table_name: Fully qualified table name
            version: Semantic version (default: "1.0.0")
            set_as_active: Mark as active baseline (default: True)

        Returns:
            Baseline object with assigned baseline_id

        Example:
            store = BaselineStore("baselines.data_quality")
            profile = profiler.profile(df)
            baseline = store.save(profile, table_name="bronze.users")
        """
        ...

    def load(
        self,
        table_name: str,
        version: Optional[str] = None,
    ) -> Baseline:
        """
        Load baseline profile.

        Args:
            table_name: Fully qualified table name
            version: Specific version to load (default: latest active)

        Returns:
            Baseline object

        Raises:
            ValueError: If no baseline found for table_name
        """
        ...

    def list_baselines(
        self,
        table_name: Optional[str] = None,
    ) -> List[Baseline]:
        """
        List all baselines, optionally filtered by table.

        Args:
            table_name: Optional table name filter

        Returns:
            List of Baseline objects
        """
        ...
```

---

## Usage Examples

### Example 1: Basic Validation

```python
from databricks_utils.data_quality import ValidationRule, ValidationRuleset, Severity

# Define rules
ruleset = ValidationRuleset(name="user_validation")
ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=False, severity=Severity.CRITICAL))
ruleset.add_rule(ValidationRule.uniqueness("email", severity=Severity.CRITICAL))
ruleset.add_rule(ValidationRule.freshness("created_at", max_age_hours=24, severity=Severity.WARNING))

# Validate DataFrame
result = ruleset.validate(df)

# Check results
if result.overall_status == Status.FAILED:
    print(f"Validation failed: {result.failed_rules}/{result.total_rules} rules failed")
    for violation in result.violations:
        print(f"  - {violation.message}")
else:
    print("Validation passed!")
```

### Example 2: Quality Gate in Pipeline

```python
from databricks_utils.data_quality import QualityGate, GateAction, QualityGateException

# Create gate
gate = QualityGate(
    name="bronze_ingestion_gate",
    ruleset=ruleset,
    actions={
        Severity.CRITICAL: GateAction.RAISE,
        Severity.WARNING: GateAction.LOG,
        Severity.INFO: GateAction.IGNORE
    }
)

# Execute pipeline with gate
try:
    result = gate.check(df, table_name="bronze.users")
    df.write.saveAsTable("bronze.users")
    print("Data written successfully")
except QualityGateException as e:
    logger.error(f"Quality gate failed: {e}")
    # Handle failure (alert, rollback, etc.)
```

### Example 3: Data Profiling and Drift Detection

```python
from databricks_utils.data_quality import DataProfiler, BaselineStore, AnomalyDetector

# Profile current data
profiler = DataProfiler(sample_size=100000)
current_profile = profiler.profile(df, compute_correlations=True)

# Save as baseline (first run)
baseline_store = BaselineStore("baselines.data_quality")
baseline = baseline_store.save(current_profile, table_name="bronze.users")

# Detect drift (subsequent runs)
baseline = baseline_store.load("bronze.users")
detector = AnomalyDetector(volume_change_threshold=0.3)
report = detector.detect(baseline, current_profile)

if report.anomalies:
    for anomaly in report.get_critical_anomalies():
        logger.critical(f"Anomaly: {anomaly.message}")
```

---

## Backward Compatibility

- All public APIs use semantic versioning
- Deprecated methods will include `@deprecated` decorator with migration guide
- Major version bumps indicate breaking changes
- Pydantic models use `allow_extra_fields=True` for forward compatibility

---

## Error Handling

All methods raise specific exceptions:
- `ValueError`: Invalid arguments or configuration
- `KeyError`: Entity not found (rule_id, column name, etc.)
- `QualityGateException`: Quality gate failures
- `RuntimeError`: Unexpected Spark or system errors

Error messages include actionable guidance for resolution.
