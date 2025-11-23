# API Contract: spark-session-utilities

**Package**: spark-session-utilities
**Version**: 0.2.0
**Python**: 3.10, 3.11

---

## Public API Surface

### spark_session_utilities.config

#### SparkSessionFactory

```python
class SparkSessionFactory:
    """
    Singleton factory for managing SparkSession lifecycle.

    Thread-safe singleton pattern ensures single SparkSession instance
    across application. Use get_spark() for production code, pytest
    fixtures for tests.
    """

    @classmethod
    def create(
        cls,
        env: str,
        config_path: Optional[Union[str, Path]] = None,
        force_recreate: bool = False
    ) -> SparkSession:
        """
        Create or retrieve SparkSession for specified environment.

        Args:
            env: Environment type (local, lab, dev, prod)
            config_path: Optional path to config file or directory
            force_recreate: Force recreation of existing session

        Returns:
            SparkSession: Singleton Spark session instance

        Raises:
            RuntimeError: If session creation fails
            ConfigurationError: If config invalid or not found

        Example:
            spark = SparkSessionFactory.create("dev")
        """

    @classmethod
    def get_spark(cls) -> SparkSession:
        """
        Get the singleton SparkSession instance.

        This is the preferred method for production pipeline code.
        Must call create() first to initialize.

        Returns:
            SparkSession: The singleton instance

        Raises:
            RuntimeError: If session not yet initialized via create()

        Example:
            spark = SparkSessionFactory.get_spark()
            df = spark.table("catalog.schema.table")
        """

    @classmethod
    def is_initialized(cls) -> bool:
        """Check if SparkSession has been initialized."""

    @classmethod
    def stop(cls) -> None:
        """Stop the singleton SparkSession and reset factory state."""
```

#### ConfigLoader

```python
class ConfigLoader:
    """
    Loads environment-specific configuration from YAML files.

    Searches for configuration files in standard locations:
    1. Specified config_path
    2. ./config/{env}.yaml
    3. ../config/{env}.yaml
    4. Environment variable CONFIG_PATH
    """

    @classmethod
    def load(
        cls,
        env: str,
        config_path: Optional[Union[str, Path]] = None
    ) -> EnvironmentConfig:
        """
        Load configuration for specified environment.

        Args:
            env: Environment type (local, lab, dev, prod)
            config_path: Optional path to config file or directory

        Returns:
            EnvironmentConfig: Validated configuration object (Spark-only)

        Raises:
            ConfigurationError: If configuration cannot be loaded or is invalid

        Example:
            config = ConfigLoader.load("dev")
            print(config.spark.app_name)
        """

    @classmethod
    def clear_cache(cls) -> None:
        """Clear configuration cache. Useful for testing."""
```

#### SparkConfig

```python
class SparkConfig(BaseModel):
    """Spark session configuration."""

    app_name: str
    master: Optional[str] = None
    config: Dict[str, str] = Field(default_factory=dict)

    # Pydantic validation ensures type safety
```

#### EnvironmentConfig

```python
class EnvironmentConfig(BaseModel):
    """Base environment configuration (Spark-only, no catalog field)."""

    environment_type: str
    spark: SparkConfig
    workspace_host: Optional[str] = None
    cluster_id: Optional[str] = None

    # Validation methods
    def validate_environment(self) -> None:
        """Validate environment-specific requirements."""
```

---

### spark_session_utilities.testing

#### Pytest Fixtures

```python
@pytest.fixture(scope="function")
def spark_session() -> Iterator[SparkSession]:
    """
    Pytest fixture providing isolated Spark session for each test function.

    Configuration:
    - master: local[2]
    - shuffle.partitions: 2 (fast for tests)
    - memory: 1g driver, 1g executor
    - UI disabled for speed
    - Adaptive SQL disabled for determinism

    Automatically cleaned up after test.

    Usage:
        def test_my_transformation(spark_session: SparkSession):
            df = spark_session.createDataFrame([(1, "a")], ["id", "val"])
            assert df.count() == 1
    """


@pytest.fixture(scope="function")
def test_config() -> EnvironmentConfig:
    """
    Pytest fixture providing test environment configuration.

    Returns EnvironmentConfig with:
    - environment_type: "local"
    - spark.master: "local[2]"
    - test catalog: "test_catalog"

    Usage:
        def test_with_config(test_config):
            assert test_config.environment_type == "local"
    """


@pytest.fixture(scope="function")
def temp_tables(spark_session: SparkSession) -> Iterator[Dict[str, str]]:
    """
    Pytest fixture for managing temporary tables/views with automatic cleanup.

    Returns dictionary to track created table names.
    Automatically drops all tracked tables after test.

    Usage:
        def test_with_tables(spark_session, temp_tables):
            df = spark_session.range(10)
            df.createOrReplaceTempView("test_view")
            temp_tables["mytest"] = "test_view"  # Tracks for cleanup
    """


@pytest.fixture(scope="session")
def spark_session_long_running() -> Iterator[SparkSession]:
    """
    Pytest fixture for long-running Spark session (session-scoped).

    WARNING: Tests using this fixture are NOT isolated.
    Use only for read-only integration tests.

    Configuration optimized for larger workloads:
    - master: local[*]
    - memory: 2g driver

    Usage:
        @pytest.mark.integration
        def test_expensive(spark_session_long_running: SparkSession):
            df = spark_session_long_running.range(1000)
            assert df.count() == 1000
    """
```

---

## Exception Hierarchy

```python
class ConfigurationError(Exception):
    """Raised when configuration loading or validation fails."""
    pass


# Raised by SparkSessionFactory
class RuntimeError:  # Built-in
    """Raised when SparkSession creation fails or not initialized."""
    pass
```

---

## Configuration File Format

### YAML Structure

```yaml
# config/{env}.yaml
environment_type: local | lab | dev | prod

spark:
  app_name: string
  master: string (optional, required for local)
  config:
    key: value

workspace_host: string (optional, required for non-local)
cluster_id: string (optional)
```

### Example: Local Development

```yaml
environment_type: local

spark:
  app_name: "my-app-local"
  master: "local[*]"
  config:
    spark.sql.shuffle.partitions: "2"
    spark.sql.adaptive.enabled: "false"
```

### Example: Databricks Dev

```yaml
environment_type: dev

spark:
  app_name: "my-app-dev"
  config:
    spark.sql.shuffle.partitions: "50"
    spark.sql.adaptive.enabled: "true"

workspace_host: "https://dev.cloud.databricks.com"
cluster_id: "0123-456789-abc123"
```

---

## Usage Examples

### Production Pipeline

```python
from spark_session_utilities.config import SparkSessionFactory

# Initialize once at application startup
SparkSessionFactory.create("dev")

# Access anywhere in pipeline
def bronze_ingestion():
    spark = SparkSessionFactory.get_spark()
    df = spark.read.format("delta").load("/path/to/source")
    return df

def silver_transformation():
    spark = SparkSessionFactory.get_spark()  # Same instance
    df = spark.table("catalog.bronze.table")
    return df.filter("status = 'active'")
```

### Testing

```python
def test_bronze_ingestion(spark_session):
    """Isolated test using fixture, not singleton."""
    df = spark_session.createDataFrame(
        [(1, "test")],
        ["id", "data"]
    )

    result = bronze_ingestion_logic(df)  # Pass df, don't call get_spark()
    assert result.count() == 1
```

---

## Performance Characteristics

| Operation | Latency | Notes |
|-----------|---------|-------|
| `create("local")` | < 10s | Local Spark session |
| `create("dev")` | < 30s | Databricks managed session |
| `get_spark()` | < 1ms | Singleton retrieval |
| `ConfigLoader.load()` | < 100ms | With caching |
| Fixture creation (`spark_session`) | < 5s | Per test function |
| Fixture cleanup | < 1s | Automatic after test |

---

## Thread Safety

- `SparkSessionFactory`: Thread-safe via locking mechanism
- `ConfigLoader`: Thread-safe, uses class-level cache
- Pytest fixtures: Function-scoped, no shared state between tests

---

## Breaking Changes from v0.1.0

None - this is a refactoring. All existing APIs from combined package still accessible via databricks-shared-utilities re-exports.

For direct usage of spark-session-utilities:
- Change imports from `databricks_utils.config` to `spark_session_utilities.config`
- No API signature changes
