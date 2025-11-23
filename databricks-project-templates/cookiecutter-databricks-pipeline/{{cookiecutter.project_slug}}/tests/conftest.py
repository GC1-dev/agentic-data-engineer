"""
Pytest configuration for {{ cookiecutter.project_name }}.

Registers Spark session fixtures for all tests.
"""

# Register Spark session fixtures from spark-session-utilities
# These fixtures are available via databricks-shared-utilities or directly from spark-session-utilities
pytest_plugins = ["spark_session_utilities.testing.conftest"]

# Add any project-specific fixtures below
