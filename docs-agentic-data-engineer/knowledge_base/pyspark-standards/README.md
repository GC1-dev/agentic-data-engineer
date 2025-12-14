# PySpark Standards

This directory contains PySpark-specific standards and best practices that extend the general [Python Project Structure Standards](../python-standards/coding.md).

## Documents

### [Configuration Management](./configuration.md)
Comprehensive guide for managing PySpark and Databricks configurations:
- Pydantic-based configuration classes for Spark, Catalog, and Databricks settings
- Environment-specific configurations (dev/staging/prod)
- YAML and .env file patterns
- SparkSession utilities
- Databricks Asset Bundles integration
- Testing configuration patterns
- Security best practices

## Key Differences from Standard Python Projects

### Additional Dependencies
```bash
poetry add pyspark pydantic pydantic-settings python-dotenv pyyaml
```

### PySpark-Specific Configuration
1. **Spark Configuration**: Driver/executor memory, cores, shuffle partitions
2. **Catalog Configuration**: Unity Catalog paths, schemas, checkpoint locations
3. **Databricks Integration**: Workspace URLs, cluster configs, job parameters
4. **Environment Isolation**: Separate Databricks workspaces per environment

### Project Structure Extensions
- `config/env_config/` - Environment-specific configs (Spark, catalog, etc.)
- `config/catalog/` - Unity Catalog configurations
- `config/job/` - Job-specific configurations
- `notebooks/` - Databricks notebooks
- `databricks.yml` - Databricks Asset Bundle configuration

### Configuration Precedence
1. Databricks Job Parameters (highest priority)
2. Environment Variables
3. .env file
4. YAML config files
5. Default values (lowest priority)

## Quick Start

```bash
# Create PySpark project
poetry new myproject --src
cd myproject

# Add PySpark dependencies
poetry add pyspark pydantic-settings python-dotenv pyyaml

# Create configuration structure
mkdir -p config/{env_config,catalog,job}
mkdir -p src/myproject/{jobs,transforms}
mkdir -p notebooks/{dev,staging,prod}

# Create base config files
touch config/env_config/{dev,staging,prod}.yaml
touch config/catalog/{dev,staging,prod}.yaml
touch databricks.yml

# Set up environment
cp .env.example .env
```

## Common Patterns

### Loading Configuration
```python
from myproject.config import get_settings

# Load environment-specific settings
settings = get_settings(env="dev")

# Access configurations
spark_config = settings.spark.to_spark_config()
table_path = settings.catalog.get_table_path("silver", "customers")
```

### Creating Spark Session
```python
from myproject.spark_utils import create_spark_session

# Create with default settings
spark = create_spark_session()

# Create with custom settings
spark = create_spark_session(
    settings=settings,
    additional_configs={"spark.sql.shuffle.partitions": "100"}
)
```

### Databricks Notebooks
```python
# Get environment from widget
environment = dbutils.widgets.get("environment")

# Load configuration
import os
os.environ["MYPROJECT_ENVIRONMENT"] = environment
settings = get_settings(env=environment)

# Use configuration
table_path = settings.catalog.get_table_path("bronze", "events")
df = spark.read.table(table_path)
```

## Best Practices

1. **Always use environment-specific configs** - Never hardcode catalog names or paths
2. **Use Pydantic validation** - Catch configuration errors at startup
3. **Leverage Unity Catalog** - Use three-level namespace (catalog.schema.table)
4. **Separate compute and storage** - Use external locations for data
5. **Enable Delta Lake features** - Use merge schema, time travel, OPTIMIZE
6. **Use Databricks Asset Bundles** - For CI/CD and deployment
7. **Test with local Spark** - Use minimal configs for unit tests
8. **Secure secrets** - Use Databricks Secrets or cloud secret managers
9. **Monitor costs** - Use cluster policies and autoscaling
10. **Enable AQE** - Adaptive Query Execution for better performance

## See Also

- [Python Project Structure Standards](../python-standards/coding.md) - Base standards for all Python projects
- [Medallion Architecture](../medallion-architecture/) - Bronze/Silver/Gold layering patterns
- [Dimensional Modeling](../dimensional-modeling/) - Data modeling best practices
