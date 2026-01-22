---
name: skyscanner-spark-session-utils
description: Manage PySpark sessions with environment-based YAML configuration, structured logging, and testing fixtures. Use when users need to configure Spark sessions, manage Spark application lifecycles, load environment-specific configurations, implement structured logging for Spark applications, or set up isolated Spark test environments.
---

# Skyscanner Spark Session Utils Skill

Comprehensive utilities for PySpark session management, YAML-based configuration, structured logging, and testing.

## Overview

The spark-session-utils library provides production-ready utilities for managing Spark sessions across different environments (local, dev, prod) with type-safe configuration, structured logging, and isolated testing support. It follows enterprise patterns for configuration management and session lifecycle control.

## When to Use This Skill

Trigger when users request:
- "create Spark session", "configure Spark", "Spark session management"
- "load Spark config from YAML", "environment-specific Spark config"
- "Spark structured logging", "log Spark metrics", "Spark logging"
- "Spark test fixtures", "isolated Spark testing"
- "SparkSessionFactory", "SparkSessionManager"
- Any Spark session configuration or lifecycle management task

## Available Imports

```python
# Main components
from spark_session_utils import (
    SparkSessionFactory,     # Singleton session factory
    SparkSessionManager,     # Context manager for sessions
    SparkConfig,             # Spark configuration schema
    EnvironmentConfig,       # Environment configuration schema
    get_logger,              # Structured logger
    log_metrics,             # Metrics logging
    SparkLogger,             # Alias for get_logger
)

# Configuration utilities
from spark_session_utils.config import (
    ConfigLoader,            # YAML config loader
    SparkSessionFactory,     # Also available here
    SparkConfig,             # Also available here
    EnvironmentConfig,       # Also available here
    ConfigurationError,      # Base exception
    ConfigFileNotFoundError, # File not found
    ConfigFileReadError,     # Read error
    ConfigParseError,        # YAML parse error
    ConfigValidationError,   # Schema validation error
)

# Logging utilities
from spark_session_utils.logging import (
    get_logger,              # Get structured logger
    log_metrics,             # Log metrics
    info,                    # Quick info log
    warning,                 # Quick warning log
    error,                   # Quick error log
    debug,                   # Quick debug log
    StructuredFormatter,     # JSON formatter
    ContextLogger,           # Logger with context
)
```

## Core Components

### 1. SparkSessionFactory (Singleton Pattern)

The primary way to get Spark sessions in production code.

```python
from spark_session_utils import SparkSessionFactory

# Get Spark session (singleton pattern)
spark = SparkSessionFactory.get_spark()

# Use the session
df = spark.read.parquet("path/to/data")
df.show()

# Stop the session (cleanup)
SparkSessionFactory.stop_spark()
```

**Key Features:**
- Singleton pattern ensures one session per application
- Thread-safe session access
- Automatic configuration from environment
- Clean session lifecycle management

### 2. SparkSessionManager (Context Manager)

High-level session management with automatic cleanup.

```python
from spark_session_utils import SparkSessionManager

# Use as context manager (auto cleanup)
with SparkSessionManager(
    app_name="my-etl-pipeline",
    master="local[*]",
    config={
        "spark.sql.shuffle.partitions": "50",
        "spark.sql.adaptive.enabled": "true"
    }
) as spark:
    df = spark.read.csv("data.csv", header=True)
    df.write.parquet("output.parquet")
# Session automatically stopped after context

# Or manage lifecycle manually
manager = SparkSessionManager(app_name="my-pipeline")
spark = manager.get_or_create()
# ... do work ...
manager.stop()
```

**When to Use:**
- Context manager pattern for automatic cleanup
- Custom session configuration per script
- Local development and testing
- Scripts with clear start/end boundaries

## Configuration Management

### YAML Configuration Files

```yaml
# config/env_config/dev.yaml
environment_type: dev
spark:
  app_name: customer-pipeline-dev
  config:
    spark.sql.shuffle.partitions: "50"
    spark.sql.adaptive.enabled: "true"
    spark.sql.adaptive.coalescePartitions.enabled: "true"
cluster_id: "0123-456789-abc123"
```

```yaml
# config/env_config/local.yaml
environment_type: local
spark:
  app_name: customer-pipeline-local
  master: "local[*]"  # Required for local environment
  config:
    spark.sql.shuffle.partitions: "2"  # Lower for local
    spark.driver.memory: "4g"
```

```yaml
# config/env_config/prod.yaml
environment_type: prod
spark:
  app_name: customer-pipeline-prod
  config:
    spark.sql.shuffle.partitions: "200"
    spark.sql.adaptive.enabled: "true"
    spark.dynamicAllocation.enabled: "true"
cluster_id: "prod-0123-456789-abc123"
```

### Loading Configuration

```python
from spark_session_utils.config import ConfigLoader
from spark_session_utils import EnvironmentConfig

# Load dev configuration
config = ConfigLoader.load("dev")
print(config.environment_type)  # "dev"
print(config.spark.app_name)    # "customer-pipeline-dev"
print(config.cluster_id)         # "0123-456789-abc123"

# Load from custom directory
config = ConfigLoader.load("prod", config_path="./my-configs")

# Load local configuration
local_config = ConfigLoader.load("local")
print(local_config.spark.master)  # "local[*]"

# Access workspace URL (automatically derived)
print(config.workspace_url)
# dev/lab: https://skyscanner-dev.cloud.databricks.com
# prod: https://skyscanner-prod.cloud.databricks.com
# local: None
```

### Configuration Schema

```python
from spark_session_utils import SparkConfig, EnvironmentConfig
from pydantic import ValidationError

# Define Spark configuration
spark_config = SparkConfig(
    app_name="my-pipeline-dev",
    master="local[*]",  # Optional, only for local
    config={
        "spark.sql.shuffle.partitions": "50",
        "spark.sql.adaptive.enabled": "true"
    }
)

# Define environment configuration
env_config = EnvironmentConfig(
    environment_type="dev",
    spark=spark_config,
    cluster_id="optional-cluster-id"
)

# Validate environment-specific requirements
try:
    env_config.validate_environment()
except ValidationError as e:
    print(f"Configuration error: {e}")
```

**Configuration Rules:**
- Local environment MUST specify `spark.master`
- Dev/prod environments should NOT specify `spark.master` (uses cluster)
- All Spark config values must be strings
- Environment types: `local`, `lab`, `dev`, `prod`

### Error Handling

```python
from spark_session_utils.config import (
    ConfigLoader,
    ConfigurationError,
    ConfigFileNotFoundError,
    ConfigFileReadError,
    ConfigParseError,
    ConfigValidationError
)

try:
    config = ConfigLoader.load("dev")
except ConfigFileNotFoundError as e:
    print(f"Config file missing: {e.file_path}")
    print(f"Environment: {e.env}")
except ConfigFileReadError as e:
    print(f"Cannot read file: {e.file_path}")
    print(f"Original error: {e.original_error}")
except ConfigParseError as e:
    print(f"Invalid YAML syntax: {e.yaml_error}")
except ConfigValidationError as e:
    print(f"Schema validation failed: {e.validation_errors}")
except ConfigurationError as e:
    # Catch all config errors
    print(f"Configuration error: {e}")
```

## Structured Logging

### Basic Logging

```python
from spark_session_utils import get_logger

# Create logger with context
logger = get_logger(
    __name__,
    context={"pipeline": "customer-360", "layer": "bronze"}
)

# Log messages (automatically includes context)
logger.info("Starting data processing")
logger.warning("High memory usage detected")
logger.error("Failed to read table", extra_fields={"table": "customers"})

# Log with additional fields
logger.info(
    "Transformation complete",
    extra_fields={
        "rows_processed": 10000,
        "duration_seconds": 45.3
    }
)
```

**Output (JSON structured):**
```json
{
  "timestamp": "2024-11-24T10:30:45.123456",
  "level": "INFO",
  "logger": "my_module",
  "message": "Transformation complete",
  "module": "my_module",
  "function": "process_data",
  "line": 42,
  "context": {
    "pipeline": "customer-360",
    "layer": "bronze"
  },
  "rows_processed": 10000,
  "duration_seconds": 45.3
}
```

### Metrics Logging

```python
from spark_session_utils import log_metrics

# Log structured metrics
log_metrics(
    metrics={
        "rows_processed": 10000,
        "duration_seconds": 45.3,
        "partitions_written": 10,
        "data_size_mb": 512.5
    },
    tags={
        "layer": "bronze",
        "table": "customers",
        "environment": "prod"
    }
)
```

### Logging Configuration

```python
from spark_session_utils import get_logger

# Structured JSON logging (default)
logger = get_logger(__name__, structured=True)

# Plain text logging
logger = get_logger(__name__, structured=False)

# No context
logger = get_logger(__name__)
logger.info("Simple message")

# With context
logger = get_logger(
    __name__,
    context={"job_id": "j-12345", "user": "data-eng-team"}
)
```

### Module-Level Convenience Functions

```python
from spark_session_utils.logging import info, warning, error, debug

# Quick logging without creating logger instance
info("Pipeline started")
warning("Configuration missing, using defaults")
error("Database connection failed")
debug("Cache hit for key: customers")
```

## Testing Support

### Unit Test Fixtures (tests/unit/conftest.py)

```python
"""Unit test fixtures for all unit tests.

This module provides pytest fixtures for unit testing, including Spark session setup
with configuration loaded from config/env_config/test-unit.yaml via SparkSessionFactory.
"""

from collections.abc import Generator
from pathlib import Path

import pytest
from pyspark.sql import SparkSession

from spark_session_utils.config import SparkSessionFactory


@pytest.fixture(scope="session")
def repo_root() -> Path:
    """Get repository root directory.

    Returns:
        Path: Repository root path
    """
    # Navigate up from tests/unit/conftest.py to repo root
    return Path(__file__).parents[2]


@pytest.fixture(scope="session")
def spark(repo_root: Path) -> Generator[SparkSession, None, None]:
    """Create Spark session for unit tests using SparkSessionFactory.

    This fixture creates a Spark session with configuration loaded from
    config/env_config/test-unit.yaml via SparkSessionFactory.

    Args:
        repo_root: Repository root path

    Yields:
        SparkSession: Configured Spark session for local testing

    Note:
        - Configuration is loaded from config/env_config/test-unit.yaml
        - Session is managed by SparkSessionFactory singleton
        - Properly cleaned up via SparkSessionFactory.stop()
    """
    config_path = repo_root / "config" / "env_config"
    spark = SparkSessionFactory.create(env="test-unit", config_path=config_path)
    spark.sparkContext.setLogLevel("WARN")

    yield spark

    SparkSessionFactory.stop()
```

**Test Configuration (config/env_config/test-unit.yaml):**
```yaml
environment_type: test_unit

spark:
  app_name: "test-unit-transformations"
  master: local[2]  # 2 threads for complex transformations
  config:
    # Session timezone
    spark.sql.session.timeZone: UTC

    # Performance Tuning (minimize resources)
    spark.sql.shuffle.partitions: "2"  # Reduce shuffle overhead
    spark.default.parallelism: "2"     # Match local[2] thread count

    # Storage
    spark.sql.warehouse.dir: spark-warehouse-unit

    # Optimization (disable expensive features for deterministic tests)
    spark.sql.adaptive.enabled: "false"  # Disable AQE for deterministic behavior
    spark.sql.autoBroadcastJoinThreshold: "-1"  # Disable auto broadcast joins


logging:
  level: "info"
```

**Using the fixture:**
```python
def test_data_transformation(spark):
    """Test with isolated Spark session."""
    # Create test DataFrame
    data = [("Alice", 25), ("Bob", 30)]
    df = spark.createDataFrame(data, ["name", "age"])

    # Test transformation
    result = df.filter(df.age > 25)

    # Assertions
    assert result.count() == 1
    assert result.first().name == "Bob"
```

### Integration Test Fixtures (tests/integration/conftest.py)

```python
"""Integration test fixtures for integration testing.

This module provides pytest fixtures for integration testing, including Spark session
with integration-specific configuration and larger-scale test data generation.
"""

from collections.abc import Generator
from pathlib import Path

import pytest
from pyspark.sql import SparkSession

from spark_session_utils.config import SparkSessionFactory


@pytest.fixture(scope="session")
def repo_root() -> Path:
    """Get repository root directory.

    Returns:
        Path: Repository root path
    """
    # Navigate up from tests/integration/conftest.py to repo root
    return Path(__file__).parents[2]


@pytest.fixture(scope="session")
def spark(repo_root: Path) -> Generator[SparkSession, None, None]:
    """Create Spark session for integration tests using SparkSessionFactory.

    This fixture creates a Spark session with configuration loaded from
    config/env_config/test-integration.yaml via SparkSessionFactory.

    Args:
        repo_root: Repository root path

    Yields:
        SparkSession: Configured Spark session for integration testing

    Note:
        - Configuration is loaded from config/env_config/test-integration.yaml
        - Session is managed by SparkSessionFactory singleton
        - Properly cleaned up via SparkSessionFactory.stop()
    """
    config_path = repo_root / "config" / "env_config"
    spark = SparkSessionFactory.create(env="test-integration", config_path=config_path)
    spark.sparkContext.setLogLevel("WARN")

    yield spark

    SparkSessionFactory.stop()
```

**Test Configuration (config/env_config/test-integration.yaml):**
```yaml
environment_type: test_integration

spark:
  app_name: "test-integration-transformations"
  master: local[2]  # 2 threads for complex transformations
  config:
    # Session timezone
    spark.sql.session.timeZone: "UTC"

    # Memory Configuration (increased for integration tests)
    # Driver memory: Memory allocated to the Spark driver process
    spark.driver.memory: "4g"  # Increased from default 1g
    # Executor memory: Memory for executor processes (for local mode, driver handles this)
    spark.executor.memory: "4g"
    # Overhead memory: Additional memory for off-heap allocations
    spark.driver.memoryOverhead: "1g"
    spark.executor.memoryOverhead: "1g"
    # Maximum result size: Limit data returned to driver
    spark.driver.maxResultSize: "2g"

    # Performance Tuning (moderate resources)
    spark.sql.shuffle.partitions: "2"
    spark.default.parallelism: "2"

    # Storage
    spark.sql.warehouse.dir: "spark-warehouse-integration"

    # Delta Lake Support (required for Delta operations)
    spark.sql.extensions: "io.delta.sql.DeltaSparkSessionExtension"
    spark.sql.catalog.spark_catalog: "org.apache.spark.sql.delta.catalog.DeltaCatalog"

    # Optimization (enable realistic production-like behavior)
    spark.sql.adaptive.enabled: "true"  # Enable AQE like production
    spark.databricks.delta.optimizeWrite.enabled: "true"
    spark.databricks.delta.retentionDurationCheck.enabled: "false"
    spark.databricks.delta.schema.autoMerge.enabled: "true"
    spark.databricks.delta.optimize.zorder.checkStatsCollection.enabled: "false"

    # Memory Management
    # Storage memory fraction: Reduce to allow more execution memory
    spark.memory.storageFraction: "0.3"  # Default: 0.5, lower = more execution memory
    # Off-heap memory: Enable to reduce heap pressure
    spark.memory.offHeap.enabled: "true"
    spark.memory.offHeap.size: "1g"
    # Broadcast timeout: Increase for large broadcasts
    spark.sql.broadcastTimeout: "600"

# Database/Catalog Configuration
data_catalog:
  catalog: "test_catalog"
  schema: "test_schema"

logging:
  level: "info"
```

### Key Testing Patterns

**Pattern 1: Session-Scoped Fixtures**
- Use `scope="session"` to share Spark session across all tests
- Faster test execution (no session creation overhead per test)
- Clean up once after all tests complete

**Pattern 2: Config-Based Testing**
- Separate config files for unit vs integration tests
- `test-unit.yaml`: Minimal config, 2 partitions, fast
- `test-integration.yaml`: More realistic config, more partitions

**Pattern 3: SparkSessionFactory.create()**
- Use `SparkSessionFactory.create(env, config_path)` for tests
- Loads configuration from YAML files
- Singleton pattern ensures one session per test suite
- Clean up with `SparkSessionFactory.stop()`

**Pattern 4: Repo Root Navigation**
- Use `Path(__file__).parents[2]` to navigate to repo root
- Makes fixtures work regardless of where pytest is run from
- Ensures config files are found reliably

## Common Usage Patterns

### Pattern 1: Production Pipeline with Config

```python
from spark_session_utils import SparkSessionFactory
from spark_session_utils.config import ConfigLoader
from spark_session_utils import get_logger

# Load environment configuration
config = ConfigLoader.load("prod")

# Setup logger with context
logger = get_logger(
    __name__,
    context={
        "pipeline": "customer-360",
        "environment": config.environment_type
    }
)

# Get Spark session
spark = SparkSessionFactory.get_spark()

try:
    logger.info("Starting ETL pipeline")

    # Read data
    df = spark.read.parquet("s3://bucket/raw-data")
    logger.info("Data loaded", extra_fields={"rows": df.count()})

    # Transform
    transformed = df.filter(df.status == "active")

    # Write
    transformed.write.parquet("s3://bucket/processed-data")
    logger.info("Pipeline complete")

except Exception as e:
    logger.error(f"Pipeline failed: {e}")
    raise
finally:
    SparkSessionFactory.stop_spark()
```

### Pattern 2: Local Development Script

```python
from spark_session_utils import SparkSessionManager

# Quick local development
with SparkSessionManager(
    app_name="local-dev",
    master="local[*]"
) as spark:
    df = spark.read.csv("local-data.csv", header=True)
    df.show()
    df.write.parquet("output.parquet")
```

### Pattern 3: Multi-Environment Pipeline

```python
import os
from spark_session_utils.config import ConfigLoader
from spark_session_utils import SparkSessionFactory, get_logger

# Get environment from env var
env = os.getenv("ENVIRONMENT", "dev")
config = ConfigLoader.load(env)

# Setup logger
logger = get_logger(__name__, context={"environment": env})

# Get session
spark = SparkSessionFactory.get_spark()

logger.info(
    f"Running in {env} environment",
    extra_fields={
        "app_name": config.spark.app_name,
        "cluster_id": config.cluster_id
    }
)

# Run pipeline...
```

### Pattern 4: Databricks Notebook

```python
# In Databricks notebook
from spark_session_utils.config import ConfigLoader
from spark_session_utils import get_logger, log_metrics
import time

# Load config for current environment
config = ConfigLoader.load("prod")

# Setup logging
logger = get_logger(
    "notebook_job",
    context={
        "notebook": "customer_processing",
        "cluster": config.cluster_id
    }
)

# Use existing Databricks Spark session
# (Databricks provides 'spark' variable)

start_time = time.time()

logger.info("Starting notebook execution")

df = spark.table("bronze.customers")
processed = df.filter(df.active == True)
processed.write.mode("overwrite").saveAsTable("silver.active_customers")

duration = time.time() - start_time

# Log metrics
log_metrics(
    metrics={
        "rows_processed": df.count(),
        "duration_seconds": duration
    },
    tags={
        "layer": "silver",
        "table": "active_customers"
    }
)

logger.info("Notebook execution complete")
```

### Pattern 5: Testing with Config-Based Fixtures

```python
# tests/unit/conftest.py
from collections.abc import Generator
from pathlib import Path

import pytest
from pyspark.sql import SparkSession
from spark_session_utils.config import SparkSessionFactory


@pytest.fixture(scope="session")
def repo_root() -> Path:
    """Get repository root directory."""
    return Path(__file__).parents[2]


@pytest.fixture(scope="session")
def spark(repo_root: Path) -> Generator[SparkSession, None, None]:
    """Create Spark session for unit tests."""
    config_path = repo_root / "config" / "env_config"
    spark = SparkSessionFactory.create(env="test-unit", config_path=config_path)
    spark.sparkContext.setLogLevel("WARN")
    yield spark
    SparkSessionFactory.stop()


# tests/unit/test_pipeline.py
def test_transformation(spark):
    """Test data transformation with config-based fixture."""
    df = spark.createDataFrame(
        [(1, "Alice"), (2, "Bob")],
        ["id", "name"]
    )

    result = df.filter(df.id > 1)
    assert result.count() == 1
    assert result.first().name == "Bob"


# config/env_config/test-unit.yaml
# environment_type: test_unit
# spark:
#   app_name: "test-unit-transformations"
#   master: "local[2]"
#   config:
#     spark.sql.session.timeZone: UTC
#     spark.sql.shuffle.partitions: "2"
#     spark.sql.adaptive.enabled: "false"
```

## Configuration Directory Structure

```
project/
├── config/
│   └── env_config/
│       ├── local.yaml           # Local development
│       ├── dev.yaml             # Development environment
│       ├── prod.yaml            # Production environment
│       ├── lab.yaml             # Lab/sandbox environment
│       ├── test-unit.yaml       # Unit test configuration
│       └── test-integration.yaml # Integration test configuration
├── src/
│   └── pipeline.py
└── tests/
    ├── unit/
    │   ├── conftest.py          # Unit test fixtures
    │   └── test_pipeline.py
    └── integration/
        ├── conftest.py          # Integration test fixtures
        └── test_integration.py
```

## Best Practices

### Configuration

1. **Separate Configs per Environment**
   - Keep environment-specific settings in separate YAML files
   - Never hardcode environment-specific values in code

2. **Validate Configuration Early**
   ```python
   config = ConfigLoader.load(env)
   config.validate_environment()  # Catch config errors early
   ```

3. **Use Type-Safe Access**
   ```python
   # Good: Type-safe access
   app_name = config.spark.app_name

   # Bad: Dictionary access (no type checking)
   app_name = config["spark"]["app_name"]
   ```

### Session Management

1. **Use SparkSessionFactory in Production**
   ```python
   # Good: Singleton pattern
   spark = SparkSessionFactory.get_spark()

   # Bad: Creating multiple sessions
   spark1 = SparkSession.builder.getOrCreate()
   spark2 = SparkSession.builder.getOrCreate()
   ```

2. **Clean Up Sessions**
   ```python
   try:
       spark = SparkSessionFactory.get_spark()
       # ... work ...
   finally:
       SparkSessionFactory.stop_spark()
   ```

3. **Use Context Manager for Scripts**
   ```python
   with SparkSessionManager(...) as spark:
       # Auto cleanup
       pass
   ```

### Logging

1. **Always Use Structured Logging**
   ```python
   # Good: Structured with context
   logger = get_logger(__name__, context={"pipeline": "etl"})
   logger.info("Processing", extra_fields={"rows": 1000})

   # Bad: Unstructured
   print(f"Processing 1000 rows")
   ```

2. **Include Relevant Context**
   ```python
   logger = get_logger(
       __name__,
       context={
           "environment": env,
           "pipeline": "customer-360",
           "layer": "bronze"
       }
   )
   ```

3. **Log Metrics for Observability**
   ```python
   log_metrics(
       metrics={"rows": count, "duration_seconds": duration},
       tags={"layer": "bronze", "table": "customers"}
   )
   ```

### Testing

1. **Use Config-Based Fixtures with SparkSessionFactory**
   ```python
   @pytest.fixture(scope="session")
   def spark(repo_root: Path):
       config_path = repo_root / "config" / "env_config"
       spark = SparkSessionFactory.create(env="test-unit", config_path=config_path)
       spark.sparkContext.setLogLevel("WARN")
       yield spark
       SparkSessionFactory.stop()
   ```

2. **Use Session Scope for Faster Tests**
   ```python
   # Good: Session scope (faster, shared session)
   @pytest.fixture(scope="session")
   def spark(repo_root: Path):
       ...

   # Only use function scope if tests need isolation
   @pytest.fixture(scope="function")
   def spark_isolated():
       ...
   ```

3. **Separate Test Configs**
   ```yaml
   # config/env_config/test-unit.yaml
   environment_type: test_unit
   spark:
     app_name: "test-unit-transformations"
     master: "local[2]"
     config:
       spark.sql.shuffle.partitions: "2"  # Fast tests
       spark.sql.adaptive.enabled: "false"  # Deterministic behavior
       spark.sql.session.timeZone: "UTC"

   # config/env_config/test-integration.yaml
   environment_type: test_integration
   spark:
     app_name: "test-integration-transformations"
     master: "local[2]"
     config:
       spark.driver.memory: "4g"  # More memory
       spark.sql.shuffle.partitions: "2"
       spark.sql.adaptive.enabled: "true"  # Enable optimizations
       spark.sql.session.timeZone: "UTC"
       # Delta Lake support
       spark.sql.extensions: "io.delta.sql.DeltaSparkSessionExtension"
       spark.sql.catalog.spark_catalog: "org.apache.spark.sql.delta.catalog.DeltaCatalog"
   ```

4. **Navigate to Repo Root Reliably**
   ```python
   @pytest.fixture(scope="session")
   def repo_root() -> Path:
       # Works from any pytest invocation location
       return Path(__file__).parents[2]
   ```

5. **Clean Up Test Data with tmp_path**
   ```python
   def test_write(spark, tmp_path):
       df.write.parquet(str(tmp_path / "output"))
       # tmp_path auto-cleaned by pytest
   ```

## Environment Variables

```bash
# Set environment for pipeline
export ENVIRONMENT=prod

# Optional: Custom config path
export SPARK_CONFIG_PATH=/path/to/configs
```

```python
import os
from spark_session_utils.config import ConfigLoader

env = os.getenv("ENVIRONMENT", "dev")
config_path = os.getenv("SPARK_CONFIG_PATH")

config = ConfigLoader.load(env, config_path=config_path)
```

## Quick Reference

| Component | Use Case | Import |
|-----------|----------|--------|
| SparkSessionFactory | Production singleton session | `from spark_session_utils import SparkSessionFactory` |
| SparkSessionManager | Context manager with auto cleanup | `from spark_session_utils import SparkSessionManager` |
| ConfigLoader | Load YAML configuration | `from spark_session_utils.config import ConfigLoader` |
| SparkConfig | Type-safe Spark config | `from spark_session_utils import SparkConfig` |
| EnvironmentConfig | Type-safe environment config | `from spark_session_utils import EnvironmentConfig` |
| get_logger | Structured logging | `from spark_session_utils import get_logger` |
| log_metrics | Metric logging | `from spark_session_utils import log_metrics` |
| Test fixtures | Testing support | `from spark_session_utils.testing import fixtures` |

## Common Spark Configurations

```yaml
# Performance tuning
spark:
  config:
    # Adaptive Query Execution
    spark.sql.adaptive.enabled: "true"
    spark.sql.adaptive.coalescePartitions.enabled: "true"

    # Shuffle configuration
    spark.sql.shuffle.partitions: "200"
    spark.shuffle.service.enabled: "true"

    # Memory management
    spark.driver.memory: "8g"
    spark.executor.memory: "16g"
    spark.executor.memoryOverhead: "2g"

    # Dynamic allocation
    spark.dynamicAllocation.enabled: "true"
    spark.dynamicAllocation.minExecutors: "2"
    spark.dynamicAllocation.maxExecutors: "20"

    # Delta Lake
    spark.sql.extensions: "io.delta.sql.DeltaSparkSessionExtension"
    spark.sql.catalog.spark_catalog: "org.apache.spark.sql.delta.catalog.DeltaCatalog"
```

## Troubleshooting

### Config File Not Found
```python
# Error: ConfigFileNotFoundError
# Solution: Check file path and name
config = ConfigLoader.load("dev")  # Looks for config/env_config/dev.yaml
```

### Invalid YAML Syntax
```python
# Error: ConfigParseError
# Solution: Validate YAML syntax
# - Use 2-space indentation
# - Quote string values with special characters
# - No tabs, only spaces
```

### Schema Validation Failed
```python
# Error: ConfigValidationError
# Solution: Ensure all required fields present
# Required: environment_type, spark.app_name
# Optional: spark.master (required only for local)
```

### Local Environment Missing Master
```python
# Error: ValueError: Local environment must specify spark.master
# Solution: Add master to local config
spark:
  master: "local[*]"
```

## Success Criteria

A successful Spark session setup should:
1. **Load config correctly** - YAML parsed and validated
2. **Create session** - Spark session initialized with correct config
3. **Enable logging** - Structured logs with context
4. **Clean up properly** - Session stopped after use
5. **Environment-aware** - Correct config per environment

## Tips

- Always use YAML configuration instead of hardcoded values
- Load config early to catch errors before processing
- Use structured logging for better observability
- Keep test sessions lightweight (low partitions, no UI)
- Clean up sessions to avoid resource leaks
- Use context managers for automatic cleanup
- Separate configs per environment (local, dev, prod)
- Include relevant context in all log messages
