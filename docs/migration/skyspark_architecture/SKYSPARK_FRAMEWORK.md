# SkySpark Framework

## Purpose
SkySpark is a PySpark framework that provides a structured approach to building Spark applications with built-in support for Delta Lake operations, configuration management, and Databricks integration.

## Repository Location
https://github.com/skyscanner/skyspark

## Key Features

### 1. Spark App Wrapper
- **Location**: `src/skyspark/spark_app.py`
- **Function**: Provides a structured entry point for Spark applications
- **Capabilities**:
  - Argument parsing via `utils/arg_parser.py`
  - Spark session lifecycle management via `utils/spark_session.py`
  - Application settings management via `settings/`

### 2. Delta Table Operations
- **Location**: `src/skyspark/load/`
- **Modules**:
  - `write.py`: Core Delta table write operations
  - `metadata.py`: Table metadata management
- **Functions**:
  - `save_delta_table()`: Standard partitioned Delta writes
  - `save_delta_table_clustered()`: Delta writes with clustering
  - `save_table_metadata()`: Schema and metadata persistence

### 3. Configuration Management
- **Location**: `src/skyspark/settings/` and `src/skyspark/conf/`
- **Modules**:
  - `base_settings.py`: Base configuration classes
  - `env.py`: Environment-specific settings
  - `delta_lake_properties.py`: Delta Lake configuration
  - `base_test_properties.py`: Test environment configuration

## Directory Structure

```
src/
├── skyspark/
│   ├── spark_app.py          # Main application wrapper
│   ├── settings/              # Application settings
│   │   ├── base_settings.py
│   │   └── env.py
│   ├── utils/                 # Utility modules
│   │   ├── spark_session.py
│   │   └── arg_parser.py
│   ├── load/                  # Delta Lake operations
│   │   ├── write.py
│   │   └── metadata.py
│   └── conf/                  # Configuration
│       ├── delta_lake_properties.py
│       └── base_test_properties.py
tests/                         # Test suite
```

## Dependencies

- PySpark 4.0.0+
- Delta Lake
- Python 3.12

## Usage Pattern

```python
from skyspark.load import save_delta_table, save_table_metadata
from pyspark.sql import SparkSession, DataFrame

# Initialize Spark session
spark: SparkSession = ...
df: DataFrame = ...

# Save data with partitioning
save_delta_table(
    df=df,
    table_name="my_table",
    partitions=["dt"],
    mode="overwrite",
    replaceWhere='dt="2025-01-22"'
)

# Save metadata
save_table_metadata(
    spark,
    table_name="my_table",
    table_schema=df.schema,
    metadata_dict={"version": "1.0"}
)
```

## Integration Points

### With Projects
- Imported as a dependency in `requirements.txt`
- Applications use SkySpark utilities for Spark session management
- Provides abstractions for Delta Lake operations

### With Databricks
- Executes on Databricks Spark clusters
- Supports Databricks Runtime configurations
- Handles Delta Lake table operations

### With Delta Lake
- Provides high-level APIs for table operations
- Handles partitioning and clustering
- Manages table metadata

## Development

### Building
```bash
make build-dev
```

### Testing
```bash
make test
```

### Linting
```bash
make lint
```

## Related Components

- [skyspark-cookiecutter](SKYSPARK_COOKIECUTTER.md) - Project template that depends on SkySpark
- [astro-dag-cookiecutter](ASTRO_DAG_COOKIECUTTER.md) - DAG template for orchestrating SkySpark jobs
- [alchemy-airflow-operators](ALCHEMY_AIRFLOW_OPERATORS.md) - Contains SkySparkOperator for job submission
- [Architecture Overview](SKYSCANNER_DATA_PLATFORM_ARCHITECTURE.md) - Complete system architecture
