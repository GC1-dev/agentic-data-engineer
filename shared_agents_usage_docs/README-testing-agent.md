# Testing Agent

## Overview

Write comprehensive unit and e2e tests for PySpark transformations following testing patterns and best practices.

## Agent Details

- **Name**: `testing-agent`
- **Model**: Sonnet
- **Skills**: None

## Capabilities

- Write comprehensive unit and e2e tests
- Apply 4 core testing patterns (parametrized scenarios, data quality, scale, error conditions)
- Use testing helpers (assertion_helpers, parametrize_helpers)
- Test happy path, edge cases, and error conditions
- Validate data quality (row counts, nulls, duplicates, schema)
- Create scale tests for different data volumes
- Test error handling and validation logic
- Follow pytest best practices

## When to Use

- Write tests for new transformations
- Add data quality validation tests
- Create parametrized tests for multiple scenarios
- Test at different data scales
- Write error handling tests
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

## Best Practices

- Test happy path + edge cases + error conditions
- Use parametrized tests for multiple scenarios
- Validate data quality metrics
- Test at different scales
- Use assertion helpers
- Follow pytest naming conventions
- Mock external dependencies

## Success Criteria

✅ Comprehensive test coverage
✅ All patterns applied appropriately
✅ Tests are maintainable
✅ Clear test names and documentation
✅ Quality metrics validated
✅ Error conditions handled
✅ All tests pass

## Related Agents

- **Coding Agent**: Implement features to test
- **Data Contract Agent**: Define quality contracts
- **Transformation Validation Agent**: Validate outputs

---

**Last Updated**: 2025-12-26
