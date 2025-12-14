# Import Organization Rule for Test Files

## Rule: Module-Under-Test Imports at Top

All imports for the **module being tested** MUST be placed at the top of the test file, immediately after the module docstring and before any test classes.

## Rationale

1. **Code Clarity**: Makes it immediately obvious what module is being tested
2. **Import Organization**: Follows standard Python import practices
3. **Maintainability**: Easier to identify and update imports when functions move
4. **Performance**: Imports are resolved once at module load time, not repeated in every test
5. **Consistency**: Aligns with Python PEP 8 import guidelines

## Import Organization Order

```python
"""Module docstring."""

# Standard library imports
import pytest
from typing import List, Dict

# Third-party imports
from pyspark.sql import SparkSession
from pyspark.sql.types import (
    IntegerType,
    StringType,
    StructField,
    StructType,
)

# Imports of module(s) under test (MUST be at top)
from data_shared_utils.transformation_utils.currency_utils import (
    convert_price_to_decimals,
    find_currency_conversion_latest_date,
)
from data_shared_utils.transformation_utils.time_utils import (
    duration_second_to_human_readable,
    duration_second_to_minutes,
)


class TestFunctionName:
    """Test class for specific function."""

    def test_something(self, spark: SparkSession):
        """Test description."""
        # Test code here - functions already imported at top
        result = convert_price_to_decimals(...)
        assert result == expected
```

## Examples

### ✅ CORRECT

```python
"""Unit tests for transformation_utils.currency_utils module."""

import pytest
from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, StringType, StructField, StructType

from data_shared_utils.transformation_utils.currency_utils import (
    convert_price_to_decimals,
    find_currency_conversion_latest_date,
)


class TestConvertPriceToDecimals:
    """Tests for convert_price_to_decimals function."""

    def test_all_units(self, spark: SparkSession):
        """Test conversion for all unit types."""
        data = [(100, "WHOLE"), (10000, "CENTI")]
        schema = StructType([...])
        df = spark.createDataFrame(data, schema)

        result_df = convert_price_to_decimals(df, "price", "unit", "price_decimal")
        assert result_df.count() > 0
```

### ❌ INCORRECT (Late Imports in Test Methods)

```python
"""Unit tests for transformation_utils.currency_utils module."""

import pytest
from pyspark.sql import SparkSession


class TestConvertPriceToDecimals:
    """Tests for convert_price_to_decimals function."""

    def test_all_units(self, spark: SparkSession):
        """Test conversion for all unit types."""
        # BAD: Import inside test method
        from data_shared_utils.transformation_utils.currency_utils import (
            convert_price_to_decimals,
        )

        result_df = convert_price_to_decimals(...)
```

## Exceptions

Late imports (inside test methods) are acceptable ONLY for:

1. **Testing import errors**: Verifying that importing a non-existent module raises ImportError
2. **Mocking/patching**: When imports need to be mocked or patched for testing
3. **Conditional imports**: When imports depend on runtime conditions

```python
def test_missing_module_import_error(self):
    """Test that missing module raises ImportError."""
    with pytest.raises(ImportError):
        from nonexistent_module import function  # OK: Testing import failure
```

## Implementation

When updating or creating test files:

1. Move all module-under-test imports to the top
2. Group imports: standard library → third-party → modules under test
3. Use parentheses for multi-line imports
4. Remove duplicate/late imports from test methods
5. Verify all tests still pass

## Files to Update

- [x] `tests/unit/transformation_utils/test_currency_utils.py`
- [x] `tests/unit/transformation_utils/test_data_utils.py`
- [x] `tests/unit/transformation_utils/test_id_utils.py`
- [x] `tests/unit/transformation_utils/test_time_utils.py`
- [x] `tests/unit/dataframe_utils/test_*.py` (3 files)
- [x] `tests/unit/general_utils/test_byte_conversion.py`
- [x] `tests/contract/transformation_utils/test_transformation_utils_contract.py`
- [x] `tests/contract/dataframe_utils/test_dataframe_utils_contract.py`
- [x] `tests/contract/general_utils/test_general_utils_contract.py`
- [x] `tests/integration/test_transformation_integration.py`

## Validation

Run this command to verify imports are at top:

```bash
# Check for late imports (imports inside functions/methods)
grep -rn "^[[:space:]]*from data_shared_utils" tests/unit/ tests/contract/ | grep -v "^.*\.py:[0-9]*:from" | head -20

# Better: Check using AST analysis
python3 << 'EOF'
import ast
import pathlib

for test_file in pathlib.Path("tests").glob("**/test_*.py"):
    with open(test_file) as f:
        tree = ast.parse(f.read())

    # Check for imports inside functions/classes
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            for child in ast.walk(node):
                if isinstance(child, (ast.Import, ast.ImportFrom)):
                    print(f"Late import in {test_file}:{child.lineno} inside {node.name}")
EOF
```

---

**Status**: Rule established and implemented
**Last Updated**: 2025-11-30
**Maintainer**: Data Platform Team
