"""
Example unit tests for {{ cookiecutter.project_name }}.

Demonstrates testing patterns using pytest fixtures from databricks-utils.
"""

import pytest
from pyspark.sql import SparkSession
from pyspark.sql.functions import col


def test_example_transformation(spark_session: SparkSession):
    """
    Example test showing how to test a transformation.

    The spark_session fixture provides an isolated Spark session
    that is automatically cleaned up after the test.
    """
    # Arrange: Create test input data
    input_data = [
        (1, "customer_a", "2024-01-01"),
        (2, "customer_b", "2024-01-02"),
        (3, "customer_c", "2024-01-03")
    ]
    input_df = spark_session.createDataFrame(
        input_data,
        ["id", "customer_name", "date"]
    )

    # Act: Apply transformation (replace with actual transformation function)
    result_df = input_df.filter(col("id") > 1)

    # Assert: Verify results
    assert result_df.count() == 2
    result_list = [row.customer_name for row in result_df.collect()]
    assert "customer_b" in result_list
    assert "customer_c" in result_list


def test_config_usage(test_config):
    """
    Example test showing how to use test configuration.

    The test_config fixture provides a test environment configuration.
    """
    # Verify test configuration
    assert test_config.environment_type == "local"

    # Get table name using config
    table_name = test_config.catalog.get_table_name("bronze", "test_table")
    assert "test_catalog" in table_name
    assert "test_bronze" in table_name


@pytest.mark.parametrize("input_count,filter_value,expected_count", [
    (10, 5, 5),
    (20, 10, 10),
    (5, 3, 2)
])
def test_parametrized_transformation(
    spark_session: SparkSession,
    input_count,
    filter_value,
    expected_count
):
    """
    Example of parametrized test with Spark fixture.

    Each parameter combination gets a fresh Spark session.
    """
    df = spark_session.range(input_count)
    result = df.filter(col("id") >= filter_value)
    assert result.count() == expected_count
