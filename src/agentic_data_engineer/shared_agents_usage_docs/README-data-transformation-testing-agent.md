# Data Transformation Testing Agent

## Overview

Write comprehensive unit and e2e tests for PySpark transformations following testing patterns and best practices.

## Agent Details

- **Name**: `data-transformation-testing-agent`
- **Model**: Sonnet
- **Skills**: None

## Capabilities

- Write comprehensive unit and e2e tests
- Apply 5 core testing patterns (parametrized scenarios, data quality, scale, error conditions, granularity)
- Use testing helpers (assertion_helpers, parametrize_helpers)
- Test happy path, edge cases, and error conditions
- Validate data quality (row counts, nulls, duplicates, schema)
- Create scale tests for different data volumes
- Test error handling and validation logic
- **Write granularity tests for integration tests (session, user, daily grains)**
- **Validate cross-grain consistency and aggregation rollups**
- Follow pytest best practices

## When to Use

- Write tests for new transformations
- Add data quality validation tests
- Create parametrized tests for multiple scenarios
- Test at different data scales
- Write error handling tests
- **Create granularity tests for integration tests with aggregations**
- **Validate aggregation consistency across different grain levels**
- Ensure comprehensive test coverage
- Follow organizational testing patterns

## Testing Patterns

### 1. Parametrized Scenario Testing
Test multiple distinct input scenarios systematically.

```python
from tests.parametrize_helpers import Scenarios

def test_session_timeout_scenarios():
    scenarios = Scenarios()
    scenarios.add("no_timeout", input_df, expected_df)
    scenarios.add("timeout_exceeded", input_df2, expected_df2)
    scenarios.run(transformation_func)
```

### 2. Data Quality Testing
Validate data quality metrics.

```python
from tests.assertion_helpers import assert_quality

def test_data_quality():
    result_df = transform(input_df)
    assert_quality(result_df, min_rows=100, max_null_rate=0.05)
```

### 3. Scale Testing
Test with different data volumes.

```python
@pytest.mark.parametrize("size", ["empty", "small", "large"])
def test_at_scale(size):
    input_df = generate_data(size)
    result_df = transform(input_df)
    assert_valid(result_df)
```

### 4. Error Condition Testing
Test error handling and validation.

```python
def test_invalid_input_handling():
    with pytest.raises(ValidationError):
        transform(invalid_df)
```

### 5. Granularity Testing (Integration Tests - REQUIRED)
Test aggregations at different data grain levels.

**IMPORTANT**: This pattern is **REQUIRED** for all integration tests involving aggregations.

**Granularity Levels to Test**:
- **Finest grain**: Session, event, transaction level
- **User grain**: User-level aggregations
- **Temporal grains**: Hourly, daily, weekly, monthly
- **Composite grains**: User+Day, Session+Platform

```python
@pytest.mark.integration
def test_session_level_granularity(spark):
    """Test aggregation at session grain (finest level)."""
    input_data = [
        Row(session_id="s1", user_id="u1", value=10, dt="2024-01-01"),
        Row(session_id="s1", user_id="u1", value=5, dt="2024-01-01"),
        Row(session_id="s2", user_id="u1", value=15, dt="2024-01-01"),
    ]
    input_df = spark.createDataFrame(input_data)

    # Aggregate at session level
    result = input_df.groupBy("session_id", "user_id", "dt").agg(
        spark_sum("value").alias("total_value")
    )

    # Validate session-level aggregates
    assert_row_count(result, 2, test_id="session_grain")
    s1_result = result.filter("session_id = 's1'").collect()[0]
    assert s1_result["total_value"] == 15, "Session s1 should sum to 15"

@pytest.mark.integration
def test_user_level_granularity(spark):
    """Test aggregation at user grain (rolled up from sessions)."""
    # Same input data...

    # Aggregate at user level
    result = input_df.groupBy("user_id", "dt").agg(
        spark_sum("value").alias("total_value")
    )

    assert_row_count(result, 1, test_id="user_grain")

@pytest.mark.integration
def test_cross_grain_consistency(spark):
    """Test that aggregates roll up consistently across grains."""
    # Arrange
    input_data = [
        Row(session_id="s1", user_id="u1", value=10, dt="2024-01-01"),
        Row(session_id="s2", user_id="u1", value=15, dt="2024-01-01"),
    ]
    input_df = spark.createDataFrame(input_data)

    # Calculate at different grains
    session_total = input_df.agg(spark_sum("value")).collect()[0][0]
    user_total = input_df.groupBy("user_id").agg(
        spark_sum("value")
    ).agg(spark_sum("sum(value)")).collect()[0][0]

    # Assert - All grains should sum to same total
    assert session_total == user_total == 25, "Cross-grain consistency failed"

@pytest.mark.integration
@pytest.mark.parametrize("grain,group_cols,expected_count", [
    ("session", ["session_id"], 3),
    ("user", ["user_id"], 2),
    ("day", ["dt"], 1),
])
def test_multiple_granularities(spark, grain, group_cols, expected_count):
    """Test multiple granularity levels with parametrization."""
    input_df = create_test_data(spark)
    result = input_df.groupBy(*group_cols).agg(spark_sum("value").alias("total"))
    assert_row_count(result, expected_count, test_id=f"{grain}_grain")
```

**Granularity Testing Checklist**:
- ✅ Test at finest grain level (session, event, transaction)
- ✅ Test at user/entity grain
- ✅ Test at temporal grains (hourly, daily, weekly)
- ✅ Test at composite grains (user+day, session+platform)
- ✅ Validate cross-grain consistency (aggregates roll up correctly)
- ✅ Verify no data loss during aggregation
- ✅ Check for duplicate records at each grain

## Best Practices

- Test happy path + edge cases + error conditions
- Use parametrized tests for multiple scenarios
- Validate data quality metrics
- Test at different scales
- **Integration tests MUST include granularity testing (Pattern 5)**
- **Validate cross-grain consistency for all aggregations**
- Use assertion helpers
- Follow pytest naming conventions
- Mock external dependencies

## Success Criteria

✅ Comprehensive test coverage
✅ All 5 patterns applied appropriately
✅ Tests are maintainable
✅ Clear test names and documentation
✅ Quality metrics validated
✅ Error conditions handled
✅ **Integration tests include granularity testing**
✅ **Cross-grain consistency validated**
✅ All tests pass

## Related Agents

- **Coding Agent**: Implement features to test
- **Data Contract Agent**: Define quality contracts
- **Transformation Validation Agent**: Validate outputs

---

**Last Updated**: 2026-01-18
**Version**: 2.0 (Added Pattern 5: Granularity Testing for Integration Tests)
