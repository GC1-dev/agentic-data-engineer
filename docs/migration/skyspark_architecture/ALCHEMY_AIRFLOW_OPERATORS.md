# alchemy-airflow-operators

## Purpose
A library of custom Airflow operators for orchestrating Alchemy data pipelines, including specialized operators for Databricks/SkySpark job submission.

## Repository Location
https://github.com/skyscanner/alchemy-airflow-operators

## Key Components

### 1. SkySparkOperator

The primary operator for submitting SkySpark jobs to Databricks.

- **Location**: `alchemy/operators/skyspark_operator.py`
- **Base Class**: `AlchemyDatabricksSubmitPySparkJobOperator`
- **Purpose**: Simplifies Databricks job submission for SkySpark applications

#### Key Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `spark_app` | str | Application name (must match SkySpark app name) |
| `docker_image` | str | ECR image path (e.g., "databricks-alchemy/group/job:tag") |
| `databricks_runtime` | str | Databricks runtime version |
| `py_files` | List[str] | Python files/zips (e.g., ["/pipeline.zip", "/src/apps/app.py"]) |
| `jars` | List[str] | Additional JAR dependencies |
| `cmd_params` | List[str] | Command-line arguments for Spark app |
| `spark_s3_iam_role` | str | IAM role for S3 access (prefixed with `alc-db-`) |
| `max_workers` | int | Maximum autoscaling workers (default: 8) |
| `project` | str | AWS project tag for cost allocation |
| `enable_glue_access` | bool | Enable Glue Catalog access (default: False) |
| `instance_pool_name` | str | Databricks instance pool name |

#### Default Spark Configuration

```python
spark_conf = [
    ("spark.hadoop.fs.s3a.acl.default", "BucketOwnerFullControl"),
    ("spark.hadoop.fs.s3a.canned.acl", "BucketOwnerFullControl"),
    ("spark.hadoop.fs.s3a.credentialsType", "AssumeRole"),
    ("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension"),
    ("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog"),
    ("spark.sql.catalogImplementation", "hive"),
]
```

#### Example Usage in Airflow DAG

```python
from alchemy.operators.skyspark_operator import SkySparkOperator

task = SkySparkOperator(
    spark_app="my_etl_pipeline",
    docker_image="databricks-alchemy/data-platform/my-pipeline:latest",
    databricks_runtime="13.3.x-scala2.12",
    py_files=[
        "/my-pipeline.zip",
        "/my-pipeline/src/apps/my_etl_pipeline.py"
    ],
    spark_s3_iam_role="arn:aws:iam::123456789:role/alc-db-data-access",
    project="data-platform",
    max_workers=8,
    enable_glue_access=True,
)
```

### 2. Other Operators

Located in `alchemy/operators/`:

- **alchemy_databricks_pyspark_operator.py**: Base Databricks PySpark operator
- **alchemy_glue_operator.py**: AWS Glue job operator
- **alchemy_batch_operator.py**: AWS Batch job operator
- **create_databricks_connection_operator.py**: Databricks connection setup

### 3. Sensors

Located in `alchemy/sensors/`:

- **glue_catalog_table_sensor.py**: Wait for Glue table availability
- **redshift_query_sensor.py**: Wait for Redshift query results
- **alchemy_field_validation_sensor.py**: Data validation checks

## Dependencies

- Apache Airflow
- Databricks Python SDK
- AWS SDK (boto3)

## Job Configuration

The SkySparkOperator automatically configures:

### Cluster Configuration
- Autoscaling (min 1, max configurable workers)
- AWS instance profile for IAM access
- Docker image from ECR
- Spark environment variables
- Databricks runtime version

### Job Configuration
- Run name matching spark_app parameter
- Spark submit task with:
  - JAR dependencies
  - Spark configuration
  - Python files
  - Command-line parameters

## Spark Configuration Options

### S3 Access
- Automatic S3 ACL configuration
- Assume Role credentials
- Optional custom IAM role

### Delta Lake
- Delta Spark session extensions
- Delta catalog configuration
- Hive catalog implementation

### Glue Catalog (Optional)
When `enable_glue_access=True`:
- Glue catalog ID configuration
- Databricks Glue catalog enablement

## Integration Points

### With SkySpark Framework
- Submits SkySpark applications to Databricks
- Configures Spark environment for SkySpark apps
- Handles SkySpark-specific requirements

### With Databricks
- Uses Databricks REST API for job submission
- Manages cluster lifecycle
- Configures Docker image pulling from ECR

### With Airflow
- Extends Airflow BaseOperator
- Integrates with Airflow scheduler
- Supports Airflow task dependencies

## Development

### Installing Dependencies
```bash
make install-dev
```

### Running Tests
```bash
make unit
```

### Code Formatting
```bash
make black
```

### Linting
```bash
make lint
```

## Advanced Features

### Instance Pools
Use Databricks instance pools for faster cluster startup:
```python
SkySparkOperator(
    instance_pool_name="my-pool",
    driver_instance_pool_name="driver-pool",  # Optional separate driver pool
    ...
)
```

### Data Processing Types
Tag costs in CloudZero:
```python
SkySparkOperator(
    data_processing_type="batch",  # or "streaming", "ml", etc.
    ...
)
```

### Custom Spark Configuration
Add additional Spark configuration:
```python
SkySparkOperator(
    additional_spark_conf=[
        ("spark.sql.shuffle.partitions", "200"),
        ("spark.executor.memory", "8g"),
    ],
    ...
)
```

## Related Components

- [SkySpark Framework](SKYSPARK_FRAMEWORK.md) - Framework executed by this operator
- [astro-dag-cookiecutter](ASTRO_DAG_COOKIECUTTER.md) - Template for generating DAGs using this operator
- [skyspark-cookiecutter](SKYSPARK_COOKIECUTTER.md) - Projects that use this operator
- [astro-dag-deploy](ASTRO_DAG_DEPLOY.md) - Deployment automation for DAGs using this operator
- [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md) - Complete deployment patterns
- [Architecture Overview](SKYSCANNER_DATA_PLATFORM_ARCHITECTURE.md) - Complete system architecture
