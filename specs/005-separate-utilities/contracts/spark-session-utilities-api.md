# API Contract: spark-session-utilities v1.0.0

**Package**: `spark-session-utilities`
**Version**: 1.0.0
**Status**: Stable
**Purpose**: Standalone Spark session management, configuration, and Spark-specific logging utilities

---

## Installation

```bash
pip install spark-session-utilities==1.0.0
```

**Dependencies**:
- PySpark >= 3.0.0
- Delta Lake >= 2.0.0

---

## Public API

### Top-Level Imports

All primary classes are exported from the top-level package:

```python
from spark_session_utilities import (
    SparkSessionManager,
    SparkConfig,
    SparkLogger,
)
```

---

## Core Classes

### SparkSessionManager

**Purpose**: Spark session lifecycle management with configuration and cleanup

#### Constructor
```python
def __init__(
    self,
    config: Optional[SparkConfig] = None,
    app_name: str = "SparkApp",
    enable_hive: bool = False
)
```

**Parameters**:
- `config` (Optional[SparkConfig]): Spark configuration (default: None for defaults)
- `app_name` (str): Spark application name (default: "SparkApp")
- `enable_hive` (bool): Enable Hive support (default: False)

**Example**:
```python
manager = SparkSessionManager(
    app_name="DataQualityPipeline",
    enable_hive=True
)
```

---

#### get_or_create()
```python
def get_or_create(self) -> SparkSession
```

**Returns**: Active SparkSession (creates if not exists)

**Example**:
```python
spark = manager.get_or_create()
```

---

#### stop()
```python
def stop(self) -> None
```

**Purpose**: Gracefully stop the Spark session

**Returns**: None

---

### SparkConfig

**Purpose**: Spark configuration builder with presets for common environments

#### Constructor
```python
def __init__(self, configs: Optional[Dict[str, str]] = None)
```

**Parameters**:
- `configs` (Optional[Dict[str, str]]): Initial Spark configuration key-value pairs

**Example**:
```python
config = SparkConfig(configs={
    "spark.sql.adaptive.enabled": "true",
    "spark.sql.adaptive.coalescePartitions.enabled": "true"
})
```

---

#### set()
```python
def set(self, key: str, value: str) -> SparkConfig
```

**Parameters**:
- `key` (str): Configuration key
- `value` (str): Configuration value

**Returns**: Self (for method chaining)

**Example**:
```python
config = SparkConfig().set("spark.executor.memory", "4g")
```

---

#### for_databricks()
```python
@classmethod
def for_databricks(cls) -> SparkConfig
```

**Returns**: SparkConfig with Databricks-optimized settings

**Example**:
```python
config = SparkConfig.for_databricks()
spark = config.create_session()
```

---

#### for_local()
```python
@classmethod
def for_local(cls, cores: int = 4, memory: str = "4g") -> SparkConfig
```

**Parameters**:
- `cores` (int): Number of local cores (default: 4)
- `memory` (str): Executor memory (default: "4g")

**Returns**: SparkConfig with local mode settings

**Example**:
```python
config = SparkConfig.for_local(cores=8, memory="8g")
spark = config.create_session()
```

---

#### for_cluster()
```python
@classmethod
def for_cluster(
    cls,
    executor_memory: str = "4g",
    executor_cores: int = 4,
    num_executors: int = 10,
    driver_memory: str = "4g"
) -> SparkConfig
```

**Parameters**:
- `executor_memory` (str): Memory per executor (default: "4g")
- `executor_cores` (int): Cores per executor (default: 4)
- `num_executors` (int): Number of executors (default: 10)
- `driver_memory` (str): Driver memory (default: "4g")

**Returns**: SparkConfig with cluster mode settings

**Example**:
```python
config = SparkConfig.for_cluster(
    executor_memory="8g",
    executor_cores=8,
    num_executors=20
)
```

---

#### enable_delta()
```python
def enable_delta(self) -> SparkConfig
```

**Returns**: Self with Delta Lake extensions enabled

**Example**:
```python
config = SparkConfig().enable_delta()
```

---

#### enable_adaptive_execution()
```python
def enable_adaptive_execution(self) -> SparkConfig
```

**Returns**: Self with Adaptive Query Execution enabled

**Example**:
```python
config = SparkConfig().enable_adaptive_execution()
```

---

#### create_session()
```python
def create_session(self, app_name: str = "SparkApp") -> SparkSession
```

**Parameters**:
- `app_name` (str): Application name (default: "SparkApp")

**Returns**: Configured SparkSession

**Example**:
```python
config = SparkConfig.for_databricks().enable_delta()
spark = config.create_session(app_name="ETL Pipeline")
```

---

#### to_dict()
```python
def to_dict(self) -> Dict[str, str]
```

**Returns**: Dict of all configuration key-value pairs

---

### SparkLogger

**Purpose**: Spark-specific logging utilities with structured logging support

#### Constructor
```python
def __init__(
    self,
    spark: SparkSession,
    log_level: str = "INFO",
    enable_structured_logging: bool = False
)
```

**Parameters**:
- `spark` (SparkSession): Active Spark session
- `log_level` (str): Log level (DEBUG, INFO, WARN, ERROR) (default: "INFO")
- `enable_structured_logging` (bool): Enable JSON structured logs (default: False)

**Example**:
```python
logger = SparkLogger(
    spark=spark,
    log_level="INFO",
    enable_structured_logging=True
)
```

---

#### log_dataframe_info()
```python
def log_dataframe_info(
    self,
    df: DataFrame,
    name: str,
    include_schema: bool = True,
    include_sample: bool = False,
    sample_rows: int = 5
) -> None
```

**Parameters**:
- `df` (DataFrame): DataFrame to log
- `name` (str): Descriptive name for DataFrame
- `include_schema` (bool): Log schema (default: True)
- `include_sample` (bool): Log sample rows (default: False)
- `sample_rows` (int): Number of sample rows (default: 5)

**Returns**: None

**Example**:
```python
logger.log_dataframe_info(
    df=users_df,
    name="users",
    include_schema=True,
    include_sample=True,
    sample_rows=3
)
```

**Output**:
```
[INFO] DataFrame 'users': 1,234,567 rows, 12 columns
[INFO] Schema:
  - user_id (bigint)
  - email (string)
  - created_at (timestamp)
[INFO] Sample (3 rows):
  +-------+-------------------+-------------------+
  |user_id|email              |created_at         |
  +-------+-------------------+-------------------+
  |1      |user1@example.com  |2025-01-15 10:23:45|
  ...
```

---

#### log_job_start()
```python
def log_job_start(self, job_name: str, parameters: Optional[Dict[str, Any]] = None) -> None
```

**Parameters**:
- `job_name` (str): Job identifier
- `parameters` (Optional[Dict[str, Any]]): Job parameters to log

**Returns**: None

**Example**:
```python
logger.log_job_start(
    job_name="user_etl",
    parameters={"date": "2025-11-22", "mode": "full"}
)
```

---

#### log_job_end()
```python
def log_job_end(
    self,
    job_name: str,
    status: str = "SUCCESS",
    duration_seconds: Optional[float] = None,
    metrics: Optional[Dict[str, Any]] = None
) -> None
```

**Parameters**:
- `job_name` (str): Job identifier
- `status` (str): Job status (SUCCESS, FAILED, etc.) (default: "SUCCESS")
- `duration_seconds` (Optional[float]): Job duration
- `metrics` (Optional[Dict[str, Any]]): Job metrics to log

**Returns**: None

**Example**:
```python
logger.log_job_end(
    job_name="user_etl",
    status="SUCCESS",
    duration_seconds=125.5,
    metrics={"rows_processed": 1234567, "rows_inserted": 5432}
)
```

---

#### set_log_level()
```python
def set_log_level(self, level: str) -> None
```

**Parameters**:
- `level` (str): Log level (DEBUG, INFO, WARN, ERROR)

**Returns**: None

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
from databricks_utils.config.spark_session import SparkConfig
from databricks_utils.logging import SparkLogger
```

**After** (spark-session-utilities 1.0.0):
```python
from spark_session_utilities import SparkConfig, SparkLogger
```

### Breaking Changes
- **None**: All APIs preserved exactly
- **Only change**: Import paths (module names)

---

## Examples

### Complete Spark Setup (Databricks)

```python
from spark_session_utilities import SparkConfig, SparkLogger

# Configure for Databricks with Delta Lake
config = SparkConfig.for_databricks().enable_delta().enable_adaptive_execution()

# Create session
spark = config.create_session(app_name="Production ETL")

# Initialize logger
logger = SparkLogger(
    spark=spark,
    log_level="INFO",
    enable_structured_logging=True
)

# Log job start
logger.log_job_start(
    job_name="daily_user_pipeline",
    parameters={"date": "2025-11-22", "mode": "incremental"}
)

# Process data
users_df = spark.table("catalog.schema.users")
logger.log_dataframe_info(users_df, name="users", include_schema=True)

# Transform
processed_df = users_df.filter("created_at >= '2025-11-01'")
logger.log_dataframe_info(processed_df, name="filtered_users")

# Log job end
logger.log_job_end(
    job_name="daily_user_pipeline",
    status="SUCCESS",
    duration_seconds=45.2,
    metrics={"rows_processed": 12345}
)
```

---

### Complete Spark Setup (Local Development)

```python
from spark_session_utilities import SparkConfig, SparkSessionManager, SparkLogger

# Configure for local development
config = SparkConfig.for_local(cores=8, memory="8g").enable_delta()

# Create session manager
manager = SparkSessionManager(
    config=config,
    app_name="Local Development",
    enable_hive=False
)

# Get session
spark = manager.get_or_create()

# Initialize logger
logger = SparkLogger(spark, log_level="DEBUG")

# Use Spark
df = spark.read.parquet("/path/to/data")
logger.log_dataframe_info(df, name="input_data", include_sample=True, sample_rows=5)

# Clean up
manager.stop()
```

---

### Complete Spark Setup (Cluster)

```python
from spark_session_utilities import SparkConfig

# Configure for cluster deployment
config = SparkConfig.for_cluster(
    executor_memory="16g",
    executor_cores=8,
    num_executors=50,
    driver_memory="8g"
).enable_delta().enable_adaptive_execution()

# Add custom configurations
config.set("spark.sql.shuffle.partitions", "400")
config.set("spark.default.parallelism", "400")

# Create session
spark = config.create_session(app_name="Large Scale ETL")

print(f"Spark version: {spark.version}")
print(f"Configurations: {config.to_dict()}")
```

---

### Structured Logging Example

```python
from spark_session_utilities import SparkLogger

logger = SparkLogger(
    spark=spark,
    log_level="INFO",
    enable_structured_logging=True
)

# Structured logs are output as JSON
logger.log_job_start(
    job_name="user_aggregation",
    parameters={
        "start_date": "2025-11-01",
        "end_date": "2025-11-22",
        "aggregation_level": "daily"
    }
)

# Output (JSON):
# {
#   "timestamp": "2025-11-22T14:35:12Z",
#   "level": "INFO",
#   "event": "job_start",
#   "job_name": "user_aggregation",
#   "parameters": {
#     "start_date": "2025-11-01",
#     "end_date": "2025-11-22",
#     "aggregation_level": "daily"
#   }
# }
```

---

## Support & Issues

- **Documentation**: [Package README](../../spark-session-utilities/README.md)
- **PySpark Docs**: https://spark.apache.org/docs/latest/api/python/
- **Delta Lake Docs**: https://docs.delta.io/
- **Issues**: Report bugs via GitHub Issues
- **Breaking Changes**: Follow semantic versioning (MAJOR.MINOR.PATCH)

---

**Contract Version**: 1.0.0
**Last Updated**: 2025-11-22
