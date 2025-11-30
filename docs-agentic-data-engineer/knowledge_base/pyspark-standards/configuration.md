# PySpark Configuration Standards

> **Note**: This document extends the [Python Project Structure Standards](../python-standards/coding.md).
> Follow the general Python standards for project structure, Poetry, and **Google-style docstrings**.
> Only PySpark-specific configurations are covered here.

## Overview

PySpark projects require additional configuration beyond standard Python applications:

- **Spark Configuration**: SparkSession settings, executor/driver configs
- **Databricks Integration**: Cluster configs, job parameters, widgets
- **Data Access**: Catalog/schema/table paths, storage credentials
- **Environment-Specific**: Different configs for dev/staging/prod Databricks workspaces

## PySpark Project Structure

```
project/
├── pyproject.toml              # Poetry configuration
├── poetry.lock
├── .env.example                # Example environment variables
├── .env                        # Local environment variables (not committed)
├── databricks.yml              # Databricks Asset Bundle config
├── config/
│   ├── spark/
│   │   ├── dev.yaml           # Dev Spark configs
│   │   ├── staging.yaml       # Staging Spark configs
│   │   └── prod.yaml          # Production Spark configs
│   ├── catalog/
│   │   ├── dev.yaml           # Dev catalog/schema/table configs
│   │   ├── staging.yaml
│   │   └── prod.yaml
│   └── job/                    # Job-specific configs
│       ├── bronze_ingestion.yaml
│       ├── silver_transform.yaml
│       └── gold_aggregation.yaml
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── config.py           # Configuration classes
│       ├── spark_utils.py      # Spark session utilities
│       ├── jobs/               # ETL job scripts
│       │   ├── __init__.py
│       │   ├── bronze/
│       │   ├── silver/
│       │   └── gold/
│       └── transforms/         # Reusable transformations
│           ├── __init__.py
│           └── common.py
├── notebooks/                  # Databricks notebooks
│   ├── dev/
│   ├── staging/
│   └── prod/
└── tests/
    ├── unit/
    └── integration/
```

## Configuration Management with Pydantic

### Installation

```bash
poetry add pydantic pydantic-settings python-dotenv pyyaml pyspark
```

### Configuration Classes

**src/myproject/config.py:**

```python
from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class SparkConfig(BaseSettings):
    """Spark-specific configuration."""

    # Spark Application
    app_name: str = "myproject"

    # Driver Configuration
    driver_memory: str = "4g"
    driver_cores: int = Field(default=2, ge=1, le=16)

    # Executor Configuration
    executor_memory: str = "8g"
    executor_cores: int = Field(default=4, ge=1, le=16)
    num_executors: int = Field(default=2, ge=1, le=100)

    # Shuffle and IO
    shuffle_partitions: int = Field(default=200, ge=1)
    default_parallelism: int = Field(default=200, ge=1)

    # Delta Lake
    enable_delta: bool = True
    delta_merge_max_file_size: str = "128MB"

    # Adaptive Query Execution
    adaptive_enabled: bool = True
    adaptive_coalesce_partitions: bool = True

    # Logging
    log_level: Literal["ALL", "DEBUG", "ERROR", "FATAL", "INFO", "OFF", "TRACE", "WARN"] = "INFO"

    def to_spark_config(self) -> dict[str, str]:
        """Convert to Spark configuration dictionary."""
        return {
            "spark.app.name": self.app_name,
            "spark.driver.memory": self.driver_memory,
            "spark.driver.cores": str(self.driver_cores),
            "spark.executor.memory": self.executor_memory,
            "spark.executor.cores": str(self.executor_cores),
            "spark.executor.instances": str(self.num_executors),
            "spark.sql.shuffle.partitions": str(self.shuffle_partitions),
            "spark.default.parallelism": str(self.default_parallelism),
            "spark.sql.extensions": "io.delta.sql.DeltaSparkSessionExtension" if self.enable_delta else "",
            "spark.sql.catalog.spark_catalog": "org.apache.spark.sql.delta.catalog.DeltaCatalog" if self.enable_delta else "",
            "spark.databricks.delta.merge.maxFileSize": self.delta_merge_max_file_size,
            "spark.sql.adaptive.enabled": str(self.adaptive_enabled).lower(),
            "spark.sql.adaptive.coalescePartitions.enabled": str(self.adaptive_coalesce_partitions).lower(),
        }


class CatalogConfig(BaseSettings):
    """Unity Catalog configuration."""

    # Catalog/Schema/Table
    catalog_name: str = Field(..., description="Unity Catalog name")
    bronze_schema: str = "bronze"
    silver_schema: str = "silver"
    gold_schema: str = "gold"

    # Storage
    checkpoint_location: str = Field(..., description="Checkpoint location for streaming")
    external_location: str | None = None

    @property
    def bronze_path(self) -> str:
        """Get full bronze schema path."""
        return f"{self.catalog_name}.{self.bronze_schema}"

    @property
    def silver_path(self) -> str:
        """Get full silver schema path."""
        return f"{self.catalog_name}.{self.silver_schema}"

    @property
    def gold_path(self) -> str:
        """Get full gold schema path."""
        return f"{self.catalog_name}.{self.gold_schema}"

    def get_table_path(self, layer: Literal["bronze", "silver", "gold"], table_name: str) -> str:
        """Get full table path."""
        schema_map = {
            "bronze": self.bronze_schema,
            "silver": self.silver_schema,
            "gold": self.gold_schema,
        }
        return f"{self.catalog_name}.{schema_map[layer]}.{table_name}"


class DatabricksConfig(BaseSettings):
    """Databricks-specific configuration."""

    # Workspace
    workspace_url: str | None = None
    workspace_id: str | None = None

    # Authentication
    token: SecretStr | None = None

    # Job Configuration
    job_id: str | None = None
    run_id: str | None = None

    # Cluster
    cluster_id: str | None = None
    cluster_name: str | None = None

    # DBR Version
    databricks_runtime_version: str = "13.3"


class Settings(BaseSettings):
    """Application settings for PySpark projects."""

    # Environment
    environment: Literal["dev", "staging", "prod"] = "dev"
    debug: bool = False

    # Application
    app_name: str = "myproject"
    app_version: str = "0.1.0"

    # Spark Configuration
    spark: SparkConfig = Field(default_factory=SparkConfig)

    # Catalog Configuration
    catalog: CatalogConfig

    # Databricks Configuration
    databricks: DatabricksConfig = Field(default_factory=DatabricksConfig)

    # Paths
    data_dir: Path = Field(default=Path("/dbfs/mnt/data"))
    log_dir: Path = Field(default=Path("/dbfs/mnt/logs"))

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        env_prefix="MYPROJECT_",
        env_nested_delimiter="__",  # Allows MYPROJECT_SPARK__DRIVER_MEMORY
        extra="ignore",
    )

    @classmethod
    def from_yaml(cls, env: str = "dev") -> "Settings":
        """Load settings from YAML files and environment variables."""
        import yaml
        from pathlib import Path

        config_dir = Path("config")

        # Load Spark config
        spark_config = {}
        spark_file = config_dir / "spark" / f"{env}.yaml"
        if spark_file.exists():
            with open(spark_file) as f:
                spark_config = yaml.safe_load(f) or {}

        # Load Catalog config
        catalog_config = {}
        catalog_file = config_dir / "catalog" / f"{env}.yaml"
        if catalog_file.exists():
            with open(catalog_file) as f:
                catalog_config = yaml.safe_load(f) or {}

        # Merge configs
        merged_config = {
            "environment": env,
            "spark": spark_config.get("spark", {}),
            "catalog": catalog_config.get("catalog", {}),
            "databricks": catalog_config.get("databricks", {}),
        }

        return cls(**merged_config)


@lru_cache
def get_settings(env: str | None = None) -> Settings:
    """Get cached settings instance.

    Args:
        env: Environment name (dev/staging/prod).
             If None, reads from MYPROJECT_ENVIRONMENT env var.
    """
    import os
    if env is None:
        env = os.getenv("MYPROJECT_ENVIRONMENT", "dev")
    return Settings.from_yaml(env)
```

## Environment Variable Files

**.env.example:**
```bash
# Environment
MYPROJECT_ENVIRONMENT=dev
MYPROJECT_DEBUG=true

# Spark Configuration (nested with __)
MYPROJECT_SPARK__APP_NAME=myproject_dev
MYPROJECT_SPARK__DRIVER_MEMORY=4g
MYPROJECT_SPARK__EXECUTOR_MEMORY=8g
MYPROJECT_SPARK__NUM_EXECUTORS=2
MYPROJECT_SPARK__LOG_LEVEL=INFO

# Catalog Configuration
MYPROJECT_CATALOG__CATALOG_NAME=dev_catalog
MYPROJECT_CATALOG__BRONZE_SCHEMA=bronze
MYPROJECT_CATALOG__SILVER_SCHEMA=silver
MYPROJECT_CATALOG__GOLD_SCHEMA=gold
MYPROJECT_CATALOG__CHECKPOINT_LOCATION=/dbfs/mnt/checkpoints/dev

# Databricks Configuration
MYPROJECT_DATABRICKS__WORKSPACE_URL=https://your-workspace.cloud.databricks.com
MYPROJECT_DATABRICKS__TOKEN=dapi_your_token_here
```

## YAML Configuration Files

> **Configuration Files Location**: All configuration templates referenced in this section are committed to the repository in the `config/` directory. You can use these as-is for local development or as templates for customization. See [Configuration File Location](#configuration-file-location) section below for details.

### Spark Configuration

**config/spark/dev.yaml:**
> **Status**: Version-controlled in repository at `./config/spark/dev.yaml`
```yaml
spark:
  app_name: myproject_dev
  driver_memory: 4g
  driver_cores: 2
  executor_memory: 8g
  executor_cores: 4
  num_executors: 2
  shuffle_partitions: 50
  default_parallelism: 50
  log_level: DEBUG
  adaptive_enabled: true
```

**config/spark/prod.yaml:**
> **Status**: Version-controlled in repository at `./config/spark/prod.yaml`
```yaml
spark:
  app_name: myproject_prod
  driver_memory: 8g
  driver_cores: 4
  executor_memory: 16g
  executor_cores: 8
  num_executors: 10
  shuffle_partitions: 200
  default_parallelism: 200
  log_level: WARN
  adaptive_enabled: true
  adaptive_coalesce_partitions: true
```

### Catalog Configuration

**config/catalog/dev.yaml:**
```yaml
catalog:
  catalog_name: dev_catalog
  bronze_schema: bronze
  silver_schema: silver
  gold_schema: gold
  checkpoint_location: /dbfs/mnt/checkpoints/dev
  external_location: s3://my-bucket/dev

databricks:
  workspace_url: https://dev-workspace.cloud.databricks.com
  databricks_runtime_version: "13.3"
```

**config/catalog/prod.yaml:**
```yaml
catalog:
  catalog_name: prod_catalog
  bronze_schema: bronze
  silver_schema: silver
  gold_schema: gold
  checkpoint_location: /dbfs/mnt/checkpoints/prod
  external_location: s3://my-bucket/prod

databricks:
  workspace_url: https://prod-workspace.cloud.databricks.com
  databricks_runtime_version: "14.3"
  cluster_name: prod-etl-cluster
```

## Spark Session Utilities

**src/myproject/spark_utils.py:**

```python
import logging
from typing import Any

from pyspark.sql import SparkSession

from myproject.config import Settings, get_settings

logger = logging.getLogger(__name__)


def create_spark_session(
    settings: Settings | None = None,
    additional_configs: dict[str, str] | None = None,
) -> SparkSession:
    """Create or get Spark session with configuration.

    Args:
        settings: Settings instance. If None, loads from get_settings()
        additional_configs: Additional Spark configs to apply

    Returns:
        Configured SparkSession
    """
    if settings is None:
        settings = get_settings()

    # Get base Spark configuration
    spark_configs = settings.spark.to_spark_config()

    # Merge additional configs
    if additional_configs:
        spark_configs.update(additional_configs)

    # Create SparkSession builder
    builder = SparkSession.builder

    # Apply all configurations
    for key, value in spark_configs.items():
        if value:  # Skip empty values
            builder = builder.config(key, value)

    # Get or create session
    spark = builder.getOrCreate()

    # Set log level
    spark.sparkContext.setLogLevel(settings.spark.log_level)

    logger.info(
        f"SparkSession created for {settings.environment} environment",
        extra={
            "app_name": settings.spark.app_name,
            "executor_memory": settings.spark.executor_memory,
            "num_executors": settings.spark.num_executors,
        },
    )

    return spark


def get_spark_session() -> SparkSession:
    """Get existing SparkSession or create new one with default settings."""
    try:
        return SparkSession.getActiveSession()
    except Exception:
        return create_spark_session()


def configure_spark_for_testing() -> SparkSession:
    """Create minimal Spark session for testing."""
    test_settings = Settings(
        environment="test",
        catalog={"catalog_name": "test_catalog", "checkpoint_location": "/tmp/checkpoints"},
        spark={
            "app_name": "test",
            "driver_memory": "2g",
            "executor_memory": "2g",
            "num_executors": 1,
            "shuffle_partitions": 4,
        },
    )

    return create_spark_session(
        settings=test_settings,
        additional_configs={
            "spark.sql.warehouse.dir": "/tmp/spark-warehouse",
            "spark.driver.host": "localhost",
        },
    )
```

## Usage in PySpark Jobs

### ETL Job Example

**src/myproject/jobs/bronze/ingest_data.py:**

```python
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F

from myproject.config import get_settings
from myproject.spark_utils import create_spark_session


def ingest_source_data(spark: SparkSession, source_path: str, target_table: str) -> None:
    """Ingest data from source to bronze layer.

    Args:
        spark: SparkSession
        source_path: Source data path
        target_table: Target bronze table name
    """
    settings = get_settings()

    # Read source data
    df = spark.read.format("json").load(source_path)

    # Add metadata columns
    df = df.withColumn("_ingestion_timestamp", F.current_timestamp()) \
           .withColumn("_source_file", F.input_file_name())

    # Get full table path
    table_path = settings.catalog.get_table_path("bronze", target_table)

    # Write to bronze layer
    df.write \
        .format("delta") \
        .mode("append") \
        .option("mergeSchema", "true") \
        .saveAsTable(table_path)

    print(f"Ingested {df.count()} records to {table_path}")


def main():
    """Main entry point."""
    settings = get_settings()
    spark = create_spark_session(settings)

    try:
        # Example: Ingest customer data
        source_path = f"{settings.data_dir}/raw/customers/*.json"
        target_table = "customers"

        ingest_source_data(spark, source_path, target_table)

    finally:
        spark.stop()


if __name__ == "__main__":
    main()
```

## Databricks Notebooks Integration

### Notebook Configuration with Widgets

**notebooks/bronze_ingest.py:**

```python
# Databricks notebook source

# COMMAND ----------
# Import required modules
from myproject.config import get_settings
from myproject.spark_utils import get_spark_session
from myproject.jobs.bronze.ingest_data import ingest_source_data

# COMMAND ----------
# Create widgets for parameters
dbutils.widgets.text("environment", "dev", "Environment")
dbutils.widgets.text("source_path", "", "Source Path")
dbutils.widgets.text("target_table", "", "Target Table")

# COMMAND ----------
# Get parameters
environment = dbutils.widgets.get("environment")
source_path = dbutils.widgets.get("source_path")
target_table = dbutils.widgets.get("target_table")

# COMMAND ----------
# Load configuration for environment
import os
os.environ["MYPROJECT_ENVIRONMENT"] = environment
settings = get_settings(env=environment)

# COMMAND ----------
# Get Spark session (Databricks provides this)
spark = get_spark_session()

# COMMAND ----------
# Run ingestion
ingest_source_data(spark, source_path, target_table)
```

## Databricks Asset Bundles

### databricks.yml

```yaml
bundle:
  name: myproject

variables:
  catalog:
    description: Unity Catalog name
    default: dev_catalog

  warehouse_id:
    description: SQL Warehouse ID

include:
  - resources/*.yml

targets:
  dev:
    mode: development
    default: true
    workspace:
      host: https://dev-workspace.cloud.databricks.com
    variables:
      catalog: dev_catalog

  staging:
    mode: production
    workspace:
      host: https://staging-workspace.cloud.databricks.com
    variables:
      catalog: staging_catalog

  prod:
    mode: production
    workspace:
      host: https://prod-workspace.cloud.databricks.com
      root_path: /Workspace/Production/myproject
    variables:
      catalog: prod_catalog
    run_as:
      service_principal_name: myproject-prod-sp
```

### resources/jobs.yml

```yaml
resources:
  jobs:
    bronze_ingestion:
      name: Bronze Data Ingestion - ${bundle.target}

      job_clusters:
        - job_cluster_key: main_cluster
          new_cluster:
            spark_version: 13.3.x-scala2.12
            node_type_id: i3.xlarge
            num_workers: 2
            spark_conf:
              spark.databricks.delta.preview.enabled: true

      tasks:
        - task_key: ingest_customers
          job_cluster_key: main_cluster
          python_wheel_task:
            package_name: myproject
            entry_point: ingest_customers
            parameters:
              - "--environment"
              - "${bundle.target}"
              - "--source"
              - "customers"
          libraries:
            - whl: ../dist/*.whl
```

## Testing Configuration

**tests/conftest.py:**

```python
import pytest
from pyspark.sql import SparkSession

from myproject.config import Settings
from myproject.spark_utils import configure_spark_for_testing


@pytest.fixture(scope="session")
def spark() -> SparkSession:
    """Provide Spark session for tests."""
    spark = configure_spark_for_testing()
    yield spark
    spark.stop()


@pytest.fixture(scope="session")
def test_settings() -> Settings:
    """Provide test settings."""
    return Settings(
        environment="test",
        catalog={
            "catalog_name": "test_catalog",
            "checkpoint_location": "/tmp/checkpoints",
        },
        spark={
            "app_name": "test",
            "shuffle_partitions": 4,
        },
    )
```

**tests/unit/test_transforms.py:**

```python
import pytest
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

from myproject.transforms.common import add_metadata_columns


def test_add_metadata_columns(spark: SparkSession):
    """Test adding metadata columns to DataFrame.

    Verifies that metadata columns are correctly added to the DataFrame
    and that the row count remains unchanged.

    Args:
        spark: SparkSession fixture from conftest.
    """
    # Create test data
    schema = StructType([
        StructField("id", IntegerType(), True),
        StructField("name", StringType(), True),
    ])
    data = [(1, "Alice"), (2, "Bob")]
    df = spark.createDataFrame(data, schema)

    # Apply transformation
    result_df = add_metadata_columns(df)

    # Assertions
    assert "_ingestion_timestamp" in result_df.columns
    assert "_source_file" in result_df.columns
    assert result_df.count() == 2
```

## Best Practices for PySpark Configuration

### 1. Environment-Specific Spark Configs
```yaml
# dev.yaml - smaller resources for development
spark:
  executor_memory: 4g
  num_executors: 2
  shuffle_partitions: 50

# prod.yaml - scaled for production workloads
spark:
  executor_memory: 16g
  num_executors: 20
  shuffle_partitions: 200
```

### 2. Catalog Path Management
```python
# Always use helper methods to build table paths
table_path = settings.catalog.get_table_path("silver", "customers")

# Avoid hardcoding
# BAD: table_path = "prod_catalog.silver.customers"
```

### 3. Secrets Management
```python
# Use Databricks Secrets for sensitive data
token = dbutils.secrets.get(scope="myproject", key="api_token")

# Or Azure Key Vault / AWS Secrets Manager
from azure.keyvault.secrets import SecretClient
secret = secret_client.get_secret("database-password")
```

### 4. Configuration Precedence
```
1. Databricks Job Parameters (highest)
2. Environment Variables
3. .env file
4. YAML config files
5. Default values (lowest)
```

### 5. Checkpoint Management
```python
# Always use environment-specific checkpoint locations
checkpoint_path = f"{settings.catalog.checkpoint_location}/{job_name}"

df.writeStream \
    .format("delta") \
    .option("checkpointLocation", checkpoint_path) \
    .start()
```

### 6. Schema Evolution
```python
# Enable schema evolution for bronze layer
df.write \
    .format("delta") \
    .mode("append") \
    .option("mergeSchema", "true") \
    .saveAsTable(table_path)
```

### 7. Adaptive Query Execution
```python
# Enable AQE for better performance
spark_configs = {
    "spark.sql.adaptive.enabled": "true",
    "spark.sql.adaptive.coalescePartitions.enabled": "true",
    "spark.sql.adaptive.skewJoin.enabled": "true",
}
```

## Security Checklist

- [ ] Databricks tokens stored in secret management system
- [ ] Service principals used for production jobs
- [ ] Unity Catalog permissions properly configured
- [ ] Checkpoint locations secured with appropriate ACLs
- [ ] No hardcoded credentials in code or configs
- [ ] Environment-specific workspaces isolated
- [ ] Cluster policies enforced for cost control

## Configuration Validation

Add validation to catch configuration errors early:

```python
class CatalogConfig(BaseSettings):
    catalog_name: str = Field(..., description="Unity Catalog name")

    @field_validator("catalog_name")
    @classmethod
    def validate_catalog_name(cls, v: str) -> str:
        """Validate catalog name format."""
        if not v.replace("_", "").isalnum():
            raise ValueError("Catalog name must be alphanumeric with underscores")
        return v

    @model_validator(mode="after")
    def validate_checkpoint_location(self) -> "CatalogConfig":
        """Validate checkpoint location exists."""
        if self.checkpoint_location and not self.checkpoint_location.startswith("/dbfs"):
            raise ValueError("Checkpoint location must start with /dbfs")
        return self
```

## Configuration File Location

### Accessing Configuration Files

All configuration files referenced in this document are committed to the repository and available at the repository root under the `config/` directory:

```
./config/spark/
├── dev.yaml        # Development environment Spark configuration
├── prod.yaml       # Production environment Spark configuration
├── lab.yaml        # Lab/testing environment Spark configuration
└── local.yaml      # Local development Spark configuration
```

### Using Configuration Files

**In Python code:**
```python
from myproject.config import get_settings

# Automatically loads from config/spark/{ENVIRONMENT}.yaml
settings = get_settings(env="dev")  # Loads config/spark/dev.yaml
```

**At runtime:**
```bash
# Load configuration for different environments
MYPROJECT_ENVIRONMENT=dev python -m myproject.jobs.bronze.ingest

MYPROJECT_ENVIRONMENT=prod python -m myproject.jobs.bronze.ingest
```

### Configuration File Strategy

- **Version-controlled**: All config files are committed to the repository
- **Environment-specific**: Separate files for dev, prod, lab, and local environments
- **Customizable**: Can be customized per developer for local development needs
- **Template-based**: Use as-is or modify for your specific needs

---

## References

### PySpark Project Structure
- [Structuring PySpark Projects: A Comprehensive Guide](https://www.sparkcodehub.com/pyspark/best-practices/structuring-pyspark-projects)
- [PySpark Example Project - Best Practices](https://github.com/AlexIoannides/pyspark-example-project)
- [Best Practices for Running PySpark - Databricks](https://www.databricks.com/session/best-practices-for-running-pyspark)

### Configuration Management
- [Spark Configuration Documentation](https://spark.apache.org/docs/latest/configuration.html)
- [SparkConf and Configuration Options Guide](https://www.sparkcodehub.com/pyspark/fundamentals/configurations)
- [How to Manage Environment Variables with Pydantic in 2025](https://maicongodinho.com/how-to-manage-environment-variables-with-pydantic-in-2025/)

### Databricks Best Practices
- [Best Practices for Performance Efficiency - Databricks](https://docs.databricks.com/aws/en/lakehouse-architecture/performance-efficiency/best-practices)
- [Best Practices for Operational Excellence - Azure Databricks](https://learn.microsoft.com/en-us/azure/databricks/lakehouse-architecture/operational-excellence/best-practices)
