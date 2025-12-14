# Spark Configuration Guide

This guide covers the Spark job configurations located in `config/spark/` directory. All configurations are validated against the JSON schema defined in `spark_config_schema.yaml`.

## Configuration Schema

Each Spark configuration file must contain:

```yaml
environment_type: <string>  # Required: local, lab, dev, or prod
spark:                       # Required
  app_name: <string>        # Required: Application name
  master: <string>          # Optional: Spark master endpoint
  config:                   # Required: Key-value configuration pairs
    <key>: <string>         # All values must be strings
```

## Environment Examples

### Local Environment

**File:** `config/spark/local.yaml`

```yaml
environment_type: local

spark:
  app_name: "my-domain-silver-job-local"
  master: "local[*]"
  config:
    spark.sql.session.timeZone: "UTC"
    spark.sql.shuffle.partitions: "4"
    spark.sql.adaptive.enabled: "false"
    spark.sql.warehouse.dir: "spark-warehouse"
```

**Use Case:** Local development on a single machine using all available cores.

**Key Settings:**
- `master: "local[*]"` - Uses all available CPU cores
- `spark.sql.shuffle.partitions: "4"` - Reduced partitions for faster local testing
- `spark.sql.adaptive.enabled: "false"` - Disable adaptive execution for consistent behavior
- Custom warehouse directory for local file storage

---

### Lab Environment

**File:** `config/spark/lab.yaml`

```yaml
environment_type: lab

spark:
  app_name: "my-domain-silver-job-lab"
  config:
    spark.sql.session.timeZone: "UTC"
```

**Use Case:** Testing and validation on a shared cluster.

**Key Settings:**
- No `master` specified (cluster-managed)
- Minimal configuration to use cluster defaults
- Only timezone explicitly configured for consistency

---

### Dev Environment

**File:** `config/spark/dev.yaml`

```yaml
environment_type: dev

spark:
  app_name: "my-domain-silver-job-dev"
  config:
    spark.sql.session.timeZone: "UTC"
```

**Use Case:** Development work on shared Databricks cluster.

**Key Settings:**
- No `master` specified (managed by Databricks)
- Relies on cluster-level configuration
- Timezone set to ensure consistent timestamp handling across all environments

---

### Production Environment

**File:** `config/spark/prod.yaml`

```yaml
environment_type: prod

spark:
  app_name: "my-domain-silver-job-prod"
  config:
    spark.sql.session.timeZone: "UTC"
```

**Use Case:** Production workloads on managed Databricks cluster.

**Key Settings:**
- Minimal explicit configuration
- All tuning managed at cluster level
- Only essential timezone setting to match other environments

---

## Common Spark Configuration Options

| Configuration Key | Example Values | Purpose |
|---|---|---|
| `spark.sql.session.timeZone` | `"UTC"` | Session timezone for timestamp operations |
| `spark.sql.shuffle.partitions` | `"4"` (local), `"200"` (cluster) | Number of partitions to use for shuffles |
| `spark.sql.adaptive.enabled` | `"true"` or `"false"` | Enable adaptive query execution |
| `spark.sql.warehouse.dir` | `"spark-warehouse"` | Location of Spark warehouse |
| `spark.driver.memory` | `"4g"`, `"8g"` | Driver memory allocation |
| `spark.executor.memory` | `"4g"`, `"8g"` | Executor memory allocation |
| `spark.executor.cores` | `"4"`, `"8"` | CPU cores per executor |
| `spark.default.parallelism` | `"200"`, `"400"` | Default parallelism for RDDs |

## Validation

All configuration files are validated against `spark_config_schema.yaml`. To manually validate:

```bash
python3 << 'EOF'
import yaml
from jsonschema import validate, ValidationError

config_file = 'config/spark/dev.yaml'  # Change as needed
schema_file = 'config/spark/spark_config_schema.yaml'

with open(config_file, 'r') as f:
    config = yaml.safe_load(f)

with open(schema_file, 'r') as f:
    schema = yaml.safe_load(f)

try:
    validate(instance=config, schema=schema)
    print(f"✓ {config_file} is valid!")
except ValidationError as e:
    print(f"✗ Validation failed: {e.message}")
EOF
```

## Loading Configuration in Code

```python
import yaml
from typing import Dict, Any

def load_spark_config(environment: str) -> Dict[str, Any]:
    """Load Spark configuration for the specified environment.

    Args:
        environment: One of 'local', 'lab', 'dev', or 'prod'

    Returns:
        Configuration dictionary with 'environment_type' and 'spark' keys
    """
    config_path = f'config/spark/{environment}.yaml'
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)


# Usage
config = load_spark_config('dev')
app_name = config['spark']['app_name']
spark_settings = config['spark']['config']

# Apply to SparkSession
from pyspark.sql import SparkSession

session = SparkSession.builder \
    .appName(app_name) \
    .config('spark.sql.session.timeZone', spark_settings['spark.sql.session.timeZone'])
    # ... add other configs as needed
    .getOrCreate()
```

## Best Practices

1. **Always set `spark.sql.session.timeZone`** - Ensures consistent timestamp handling across all environments
2. **Local development** - Use `master: "local[*]"` and reduced partition counts for faster feedback
3. **Cluster environments** - Omit `master` and rely on cluster defaults for better resource management
4. **String values** - All configuration values must be strings, even numeric values
5. **Validation** - Validate configurations after changes using the validation script above
6. **Secrets** - Never commit sensitive information (passwords, API keys) in config files

## Schema Reference

See `spark_config_schema.yaml` for the complete JSON Schema definition used for validation.
