# API Contract: data-quality-utilities v1.0.0

**Package**: `data-quality-utilities`
**Version**: 1.0.0
**Status**: Stable
**Purpose**: Standalone data quality validation, profiling, quality gates, and anomaly detection for PySpark DataFrames

---

## Installation

```bash
pip install data-quality-utilities==1.0.0
```

**Dependencies**:
- PySpark >= 3.0.0
- Pydantic >= 2.0.0
- scipy >= 1.9.0
- numpy >= 1.20.0

---

## Public API

### Top-Level Imports

All primary classes and enums are exported from the top-level package:

```python
from data_quality_utilities import (
    # Validation rules
    ValidationRule,
    RuleType,
    Severity,

    # Validation execution
    ValidationRuleset,
    ValidationResult,
    RuleViolation,
    Status,

    # Data profiling
    DataProfiler,
    DataProfile,
    ColumnProfile,
    NumericColumnProfile,
    StringColumnProfile,
    TimestampColumnProfile,
)
```

---

## Core Classes

### ValidationRule

**Purpose**: Defines a data validation rule with type, severity, and parameters

**Factory Methods** (Primary Interface):

#### completeness()
```python
@classmethod
def completeness(
    cls,
    column: str,
    allow_null: bool = False,
    threshold: float = 1.0,
    severity: Severity = Severity.CRITICAL
) -> ValidationRule
```

**Parameters**:
- `column` (str): Column name to validate
- `allow_null` (bool): Whether nulls are permitted (default: False)
- `threshold` (float): Minimum completeness rate 0.0-1.0 (default: 1.0)
- `severity` (Severity): Rule severity (default: CRITICAL)

**Returns**: ValidationRule instance

**Example**:
```python
rule = ValidationRule.completeness("user_id", allow_null=False, threshold=0.95)
```

---

#### uniqueness()
```python
@classmethod
def uniqueness(
    cls,
    column: str,
    threshold: float = 1.0,
    severity: Severity = Severity.CRITICAL
) -> ValidationRule
```

**Parameters**:
- `column` (str): Column name to validate
- `threshold` (float): Minimum uniqueness rate 0.0-1.0 (default: 1.0)
- `severity` (Severity): Rule severity (default: CRITICAL)

**Returns**: ValidationRule instance

**Example**:
```python
rule = ValidationRule.uniqueness("email", threshold=1.0)
```

---

#### freshness()
```python
@classmethod
def freshness(
    cls,
    column: str,
    max_age_hours: float,
    severity: Severity = Severity.WARNING
) -> ValidationRule
```

**Parameters**:
- `column` (str): Timestamp column name
- `max_age_hours` (float): Maximum allowed data age in hours
- `severity` (Severity): Rule severity (default: WARNING)

**Returns**: ValidationRule instance

**Example**:
```python
rule = ValidationRule.freshness("updated_at", max_age_hours=24)
```

---

#### schema_match()
```python
@classmethod
def schema_match(
    cls,
    expected_schema: Dict[str, str],
    severity: Severity = Severity.CRITICAL
) -> ValidationRule
```

**Parameters**:
- `expected_schema` (Dict[str, str]): Expected column names and types
- `severity` (Severity): Rule severity (default: CRITICAL)

**Returns**: ValidationRule instance

**Example**:
```python
rule = ValidationRule.schema_match({
    "user_id": "long",
    "email": "string",
    "created_at": "timestamp"
})
```

---

#### pattern_match()
```python
@classmethod
def pattern_match(
    cls,
    column: str,
    pattern: str,
    threshold: float = 1.0,
    severity: Severity = Severity.WARNING
) -> ValidationRule
```

**Parameters**:
- `column` (str): Column name to validate
- `pattern` (str): Regular expression pattern
- `threshold` (float): Minimum match rate 0.0-1.0 (default: 1.0)
- `severity` (Severity): Rule severity (default: WARNING)

**Returns**: ValidationRule instance

**Example**:
```python
rule = ValidationRule.pattern_match("email", r"^[\w\.-]+@[\w\.-]+\.\w+$")
```

---

#### range_check()
```python
@classmethod
def range_check(
    cls,
    column: str,
    min_value: Optional[Union[int, float]] = None,
    max_value: Optional[Union[int, float]] = None,
    severity: Severity = Severity.WARNING
) -> ValidationRule
```

**Parameters**:
- `column` (str): Numeric column name
- `min_value` (Optional[Union[int, float]]): Minimum allowed value (default: None)
- `max_value` (Optional[Union[int, float]]): Maximum allowed value (default: None)
- `severity` (Severity): Rule severity (default: WARNING)

**Returns**: ValidationRule instance

**Example**:
```python
rule = ValidationRule.range_check("age", min_value=0, max_value=120)
```

---

### ValidationRuleset

**Purpose**: Collection of validation rules for a dataset, with execution logic

#### Constructor
```python
def __init__(self, name: str, rules: Optional[List[ValidationRule]] = None)
```

**Parameters**:
- `name` (str): Ruleset identifier
- `rules` (Optional[List[ValidationRule]]): Initial rules (default: [])

---

#### add_rule()
```python
def add_rule(self, rule: ValidationRule) -> None
```

**Parameters**:
- `rule` (ValidationRule): Validation rule to add

**Returns**: None

**Example**:
```python
ruleset = ValidationRuleset(name="user_validation")
ruleset.add_rule(ValidationRule.completeness("user_id"))
ruleset.add_rule(ValidationRule.uniqueness("email"))
```

---

#### validate()
```python
def validate(self, df: DataFrame) -> ValidationResult
```

**Parameters**:
- `df` (DataFrame): PySpark DataFrame to validate

**Returns**: ValidationResult with overall status and violations

**Example**:
```python
result = ruleset.validate(df)
if result.overall_status == Status.FAILED:
    print(f"Validation failed: {result.failed_rules} failures")
    for violation in result.violations:
        print(f"  - {violation.rule_name}: {violation.message}")
```

---

### ValidationResult

**Purpose**: Results of validation execution with violations and status

**Attributes**:
- `overall_status` (Status): Overall validation status (PASSED, FAILED, WARNING)
- `passed_rules` (int): Count of passed rules
- `failed_rules` (int): Count of failed rules
- `warning_rules` (int): Count of warning rules
- `violations` (List[RuleViolation]): List of rule violations
- `execution_time_seconds` (float): Validation execution time

**Methods**:
- `to_dict() -> Dict[str, Any]`: Serialize to dictionary
- `to_json() -> str`: Serialize to JSON string

---

### RuleViolation

**Purpose**: Details of a single rule failure

**Attributes**:
- `rule_name` (str): Name of failed rule
- `rule_type` (RuleType): Type of rule
- `severity` (Severity): Rule severity
- `column` (str): Affected column name
- `message` (str): Human-readable violation message
- `metric_value` (Optional[float]): Measured metric value
- `threshold_value` (Optional[float]): Expected threshold value

---

### DataProfiler

**Purpose**: Generates statistical profiles for Spark DataFrames

#### Constructor
```python
def __init__(
    self,
    sample_size: int = 100000,
    sampling_method: str = "reservoir",
    stratify_by: Optional[str] = None
)
```

**Parameters**:
- `sample_size` (int): Maximum rows to sample (default: 100,000)
- `sampling_method` (str): Sampling strategy ("reservoir", "systematic", "random") (default: "reservoir")
- `stratify_by` (Optional[str]): Column for stratified sampling (default: None)

---

#### profile()
```python
def profile(
    self,
    df: DataFrame,
    columns: Optional[List[str]] = None,
    compute_correlations: bool = False
) -> DataProfile
```

**Parameters**:
- `df` (DataFrame): PySpark DataFrame to profile
- `columns` (Optional[List[str]]): Specific columns to profile (default: all)
- `compute_correlations` (bool): Calculate column correlations (default: False)

**Returns**: DataProfile with comprehensive statistics

**Example**:
```python
profiler = DataProfiler(sample_size=50000)
profile = profiler.profile(df)

print(f"Row count: {profile.row_count}")
print(f"Column count: {profile.column_count}")

user_id_profile = profile.get_column_profile("user_id")
print(f"Null rate: {user_id_profile.null_percentage}%")
```

---

### DataProfile

**Purpose**: Complete statistical profile of a DataFrame

**Attributes**:
- `profile_id` (str): Unique identifier
- `table_name` (str): Fully qualified table name
- `timestamp` (datetime): Profile generation time
- `row_count` (int): Total rows
- `column_count` (int): Total columns
- `column_profiles` (Dict[str, ColumnProfile]): Per-column profiles
- `schema_digest` (str): Hash of DataFrame schema
- `sampling_method` (str): Sampling method used
- `sample_size` (int): Actual sample size
- `profile_metadata` (Dict[str, Any]): Additional context

**Methods**:

#### get_column_profile()
```python
def get_column_profile(self, column: str) -> ColumnProfile
```

**Parameters**:
- `column` (str): Column name

**Returns**: ColumnProfile instance

**Raises**: KeyError if column not found

---

#### to_json()
```python
def to_json(self) -> str
```

**Returns**: JSON representation of profile

---

#### from_json()
```python
@classmethod
def from_json(cls, json_str: str) -> DataProfile
```

**Parameters**:
- `json_str` (str): JSON representation

**Returns**: DataProfile instance

**Raises**: ValueError if JSON is malformed

---

### ColumnProfile

**Purpose**: Base statistical profile for any column type

**Attributes**:
- `column_name` (str): Column name
- `data_type` (str): Spark data type
- `null_count` (int): Number of null values
- `null_percentage` (float): Percentage null (0-100)
- `distinct_count` (int): Number of distinct values
- `distinct_percentage` (float): Percentage distinct (0-100)

---

### NumericColumnProfile

**Purpose**: Statistical profile for numeric columns

**Extends**: ColumnProfile

**Additional Attributes**:
- `min_value` (Optional[Union[int, float]]): Minimum value
- `max_value` (Optional[Union[int, float]]): Maximum value
- `mean` (Optional[float]): Arithmetic mean
- `median` (Optional[float]): 50th percentile
- `stddev` (Optional[float]): Standard deviation
- `quartiles` (Optional[List[float]]): [Q1, Q2/median, Q3]
- `histogram` (Optional[Dict[str, Any]]): Value distribution

---

### StringColumnProfile

**Purpose**: Statistical profile for string columns

**Extends**: ColumnProfile

**Additional Attributes**:
- `min_length` (Optional[int]): Shortest string length
- `max_length` (Optional[int]): Longest string length
- `avg_length` (Optional[float]): Average string length
- `most_common_values` (Optional[List[Dict[str, Any]]]): Top 10 values with counts
- `unique_values_sample` (Optional[List[str]]): Sample of unique values

---

### TimestampColumnProfile

**Purpose**: Statistical profile for timestamp/date columns

**Extends**: ColumnProfile

**Additional Attributes**:
- `min_date` (Optional[datetime]): Earliest timestamp
- `max_date` (Optional[datetime]): Latest timestamp
- `date_range_days` (Optional[float]): Days between min and max
- `freshness_hours` (Optional[float]): Hours since max_date

---

## Enums

### RuleType

```python
class RuleType(str, Enum):
    COMPLETENESS = "completeness"
    UNIQUENESS = "uniqueness"
    FRESHNESS = "freshness"
    SCHEMA = "schema"
    PATTERN = "pattern"
    RANGE = "range"
```

---

### Severity

```python
class Severity(str, Enum):
    CRITICAL = "critical"    # Must pass, else pipeline fails
    WARNING = "warning"      # Should pass, but pipeline continues
    INFO = "info"            # Informational only
```

---

### Status

```python
class Status(str, Enum):
    PASSED = "passed"        # All rules passed
    FAILED = "failed"        # At least one CRITICAL rule failed
    WARNING = "warning"      # At least one WARNING rule failed, no CRITICAL failures
```

---

## Compatibility Guarantees

### API Stability
- **MAJOR version**: Breaking changes to public API
- **MINOR version**: New features, backward compatible
- **PATCH version**: Bug fixes, backward compatible

### Deprecation Policy
- Deprecated features marked 1 MINOR version before removal
- Deprecation warnings raised at runtime
- Migration guide provided in release notes

---

## Migration from databricks-shared-utilities

### Import Changes

**Before** (databricks-shared-utilities 0.2.0):
```python
from databricks_utils.data_quality import ValidationRule, ValidationRuleset, Severity
from databricks_utils.data_quality.profiler import DataProfiler
```

**After** (data-quality-utilities 1.0.0):
```python
from data_quality_utilities import ValidationRule, ValidationRuleset, Severity, DataProfiler
```

### Breaking Changes
- **None**: All APIs preserved exactly
- **Only change**: Import paths (module names)

---

## Examples

### Complete Validation Workflow

```python
from data_quality_utilities import (
    ValidationRule,
    ValidationRuleset,
    Severity,
    Status,
)

# Define validation ruleset
ruleset = ValidationRuleset(name="user_data_quality")

ruleset.add_rule(
    ValidationRule.completeness("user_id", allow_null=False, severity=Severity.CRITICAL)
)
ruleset.add_rule(
    ValidationRule.uniqueness("email", threshold=1.0, severity=Severity.CRITICAL)
)
ruleset.add_rule(
    ValidationRule.freshness("updated_at", max_age_hours=24, severity=Severity.WARNING)
)
ruleset.add_rule(
    ValidationRule.pattern_match("email", r"^[\w\.-]+@[\w\.-]+\.\w+$", severity=Severity.WARNING)
)
ruleset.add_rule(
    ValidationRule.range_check("age", min_value=0, max_value=120, severity=Severity.WARNING)
)

# Validate DataFrame
result = ruleset.validate(df)

# Check results
if result.overall_status == Status.FAILED:
    print(f"❌ Validation FAILED: {result.failed_rules} critical failures")
    for violation in result.violations:
        if violation.severity == Severity.CRITICAL:
            print(f"  - {violation.rule_name}: {violation.message}")
    raise ValueError("Data quality validation failed")

elif result.overall_status == Status.WARNING:
    print(f"⚠️  Validation WARNING: {result.warning_rules} warnings")
    for violation in result.violations:
        print(f"  - {violation.rule_name}: {violation.message}")

else:
    print(f"✅ Validation PASSED: All {result.passed_rules} rules passed")
```

---

### Complete Profiling Workflow

```python
from data_quality_utilities import DataProfiler

# Create profiler with sampling
profiler = DataProfiler(sample_size=100000, sampling_method="reservoir")

# Generate profile
profile = profiler.profile(df)

print(f"Profile ID: {profile.profile_id}")
print(f"Table: {profile.table_name}")
print(f"Rows: {profile.row_count:,}")
print(f"Columns: {profile.column_count}")
print(f"Sample size: {profile.sample_size:,}")

# Analyze specific column
user_id_profile = profile.get_column_profile("user_id")
print(f"\nuser_id column:")
print(f"  Data type: {user_id_profile.data_type}")
print(f"  Null rate: {user_id_profile.null_percentage:.2f}%")
print(f"  Distinct rate: {user_id_profile.distinct_percentage:.2f}%")
print(f"  Distinct count: {user_id_profile.distinct_count:,}")

# Serialize profile for storage
profile_json = profile.to_json()

# Later: Deserialize
from data_quality_utilities import DataProfile
loaded_profile = DataProfile.from_json(profile_json)
```

---

## Support & Issues

- **Documentation**: [Package README](../../data-quality-utilities/README.md)
- **Issues**: Report bugs via GitHub Issues
- **Breaking Changes**: Follow semantic versioning (MAJOR.MINOR.PATCH)

---

**Contract Version**: 1.0.0
**Last Updated**: 2025-11-22
