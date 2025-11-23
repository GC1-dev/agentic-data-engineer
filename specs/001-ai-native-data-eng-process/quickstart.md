# Quick Start Guide

**Feature**: AI-Native Data Engineering Process for Databricks
**Version**: 1.0.0
**Last Updated**: 2025-11-21

## Overview

This guide will walk you through setting up your development environment and creating your first AI-assisted data pipeline on Databricks using the AI-Native process.

**Time to Complete**: 30-45 minutes

**Prerequisites**:
- Python 3.10+ installed
- Access to Databricks workspace
- Git installed
- Basic familiarity with PySpark and data engineering concepts

---

## Step 1: Environment Setup (10 minutes)

### 1.1 Install Core Tools

```bash
# Install Python dependencies
pip install --upgrade pip
pip install cookiecutter databricks-cli pytest

# Install Databricks CLI and configure
databricks configure --token

# Follow prompts to enter:
# - Databricks Host: https://your-workspace.cloud.databricks.com
# - Token: (generate from User Settings > Access Tokens)
```

### 1.2 Clone Shared Utilities Repository

```bash
# Clone the shared utilities library
git clone https://github.com/your-org/databricks-shared-utilities.git
cd databricks-shared-utilities

# Install in development mode
pip install -e ".[dev]"

# Run tests to verify installation
pytest tests/
```

### 1.3 Install AI Agents

```bash
# Clone AI agents repository
git clone https://github.com/your-org/databricks-ai-agents.git
cd databricks-ai-agents

# Install agents CLI
pip install -e .

# Verify installation
databricks-agent --version

# List available agents
databricks-agent list
```

**Expected Output**:
```
Available AI Agents:
  - coding: Generate PySpark transformation code
  - testing: Generate unit tests
  - profiling: Analyze data and generate profiles
  - quality: Review code quality
  - optimization: Suggest performance improvements
```

---

## Step 2: Create Your First Pipeline Project (5 minutes)

### 2.1 Use Cookiecutter Template

```bash
# Navigate to your projects directory
cd ~/projects

# Create new pipeline from template
cookiecutter https://github.com/your-org/databricks-project-templates.git \
  --directory cookiecutter-databricks-pipeline
```

### 2.2 Answer Template Questions

```
project_name [My Pipeline]: Customer 360
project_slug [customer-360-pipeline]: customer-360-pipeline
description [My data pipeline]: Customer 360 degree view pipeline
owner_team [data-team]: customer-analytics
python_version [3.10]: 3.10
include_streaming [no]: no
```

### 2.3 Explore Generated Structure

```bash
cd customer-360-pipeline
tree -L 2

# Output:
# customer-360-pipeline/
# ├── src/
# │   ├── transformations/
# │   │   ├── bronze/
# │   │   ├── silver/
# │   │   └── gold/
# │   └── orchestration/
# ├── tests/
# ├── config/
# │   ├── local.yaml
# │   ├── dev.yaml
# │   └── prod.yaml
# ├── databricks/
# │   └── bundle.yml
# ├── requirements.txt
# └── README.md
```

### 2.4 Install Project Dependencies

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

---

## Step 3: Configure Environments (5 minutes)

### 3.1 Update Local Configuration

Edit `config/local.yaml`:

```yaml
environment_type: local

spark:
  app_name: "customer-360-local"
  master: "local[*]"
  config:
    spark.sql.shuffle.partitions: "4"
    spark.sql.adaptive.enabled: "true"

catalog:
  name: "local_catalog"
  schema_prefix: "customer_360"
```

### 3.2 Update Dev Configuration

Edit `config/dev.yaml`:

```yaml
environment_type: dev

spark:
  app_name: "customer-360-dev"
  config:
    spark.sql.shuffle.partitions: "50"
    spark.sql.adaptive.enabled: "true"

catalog:
  name: "dev_analytics"
  schema_prefix: "customer_360"

workspace_host: "https://your-dev-workspace.cloud.databricks.com"
```

### 3.3 Test Configuration Loading

```python
# test_config.py
from databricks_utils.config import ConfigLoader

# Test local config
local_config = ConfigLoader.load("local")
print(f"Local catalog: {local_config.catalog.name}")
print(f"Bronze schema: {local_config.catalog.bronze_schema}")

# Test dev config
dev_config = ConfigLoader.load("dev")
print(f"Dev catalog: {dev_config.catalog.name}")
```

Run test:
```bash
python test_config.py
```

---

## Step 4: Generate Your First Transformation with AI (10 minutes)

### 4.1 Use Coding Agent for Bronze Layer

```bash
# Generate bronze layer ingestion code
databricks-agent code \
  --layer bronze \
  --source "s3://raw-data/customers/*.json" \
  --target "dev_analytics.customer_360_bronze.raw_customers" \
  --description "Ingest customer data from JSON files with schema validation" \
  --output src/transformations/bronze/ingest_customers.py
```

**Agent will generate code like**:

```python
# src/transformations/bronze/ingest_customers.py
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from databricks_utils.logging import get_logger
from databricks_utils.catalog import register_table
from databricks_utils.data_quality import validate_schema

logger = get_logger(__name__)

def ingest_customers(spark: SparkSession, config, source_path: str):
    """
    Ingest customer data from JSON files to Bronze layer.

    Args:
        spark: SparkSession instance
        config: Environment configuration
        source_path: Path to source JSON files
    """
    logger.info(f"Starting customer ingestion from {source_path}")

    # Define expected schema
    schema = StructType([
        StructField("customer_id", LongType(), False),
        StructField("name", StringType(), False),
        StructField("email", StringType(), False),
        StructField("created_at", TimestampType(), True),
    ])

    # Read data
    try:
        df = spark.read.schema(schema).json(source_path)
        logger.info(f"Read {df.count()} records")
    except Exception as e:
        logger.error(f"Failed to read data: {str(e)}")
        raise

    # Validate schema
    validation_result = validate_schema(df, schema)
    if not validation_result.is_valid:
        logger.error(f"Schema validation failed: {validation_result.errors}")
        raise ValueError("Schema validation failed")

    # Write to Bronze table
    target_table = f"{config.catalog.name}.{config.catalog.bronze_schema}.raw_customers"
    register_table(spark, df, target_table, mode="overwrite")

    logger.info(f"Successfully wrote {df.count()} records to {target_table}")
    return df

if __name__ == "__main__":
    from databricks_utils.config import ConfigLoader, SparkSessionFactory
    import sys

    env = sys.argv[1] if len(sys.argv) > 1 else "local"
    config = ConfigLoader.load(env)
    spark = SparkSessionFactory.create(env)

    ingest_customers(spark, config, "s3://raw-data/customers/")
```

### 4.2 Generate Tests with Testing Agent

```bash
# Generate tests for the transformation
databricks-agent test \
  --target-file src/transformations/bronze/ingest_customers.py \
  --function-name ingest_customers \
  --output tests/unit/test_ingest_customers.py
```

**Agent generates test file**:

```python
# tests/unit/test_ingest_customers.py
import pytest
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from chispa import assert_df_equality
from src.transformations.bronze.ingest_customers import ingest_customers

@pytest.fixture(scope="module")
def spark():
    return SparkSession.builder \
        .master("local[1]") \
        .appName("test") \
        .getOrCreate()

def test_ingest_customers_basic(spark, tmp_path):
    """Test basic ingestion functionality"""
    # Create test data
    test_data = [
        {"customer_id": 1, "name": "Alice", "email": "alice@example.com"},
        {"customer_id": 2, "name": "Bob", "email": "bob@example.com"},
    ]

    # Write to temp JSON file
    import json
    test_file = tmp_path / "customers.json"
    with open(test_file, 'w') as f:
        for record in test_data:
            f.write(json.dumps(record) + '\n')

    # Run ingestion
    result_df = ingest_customers(spark, mock_config, str(tmp_path))

    # Verify
    assert result_df.count() == 2
    assert set(result_df.columns) == {"customer_id", "name", "email", "created_at"}

def test_ingest_customers_empty_source(spark, tmp_path):
    """Test handling of empty source"""
    # Test implementation...
    pass
```

### 4.3 Run Tests Locally

```bash
# Run unit tests
pytest tests/unit/ -v

# Run with coverage
pytest tests/unit/ --cov=src --cov-report=html
```

---

## Step 5: Run Pipeline Locally (5 minutes)

### 5.1 Prepare Local Test Data

```bash
# Create local test data directory
mkdir -p data/raw/customers

# Create sample JSON file
cat > data/raw/customers/sample.json << EOF
{"customer_id": 1, "name": "Alice Smith", "email": "alice@example.com", "created_at": "2025-01-01T10:00:00"}
{"customer_id": 2, "name": "Bob Jones", "email": "bob@example.com", "created_at": "2025-01-02T11:30:00"}
{"customer_id": 3, "name": "Carol White", "email": "carol@example.com", "created_at": "2025-01-03T09:15:00"}
EOF
```

### 5.2 Execute Transformation

```bash
# Run bronze layer ingestion locally
python src/transformations/bronze/ingest_customers.py local
```

**Expected Output**:
```
INFO - Starting customer ingestion from data/raw/customers/
INFO - Read 3 records
INFO - Successfully wrote 3 records to local_catalog.customer_360_bronze.raw_customers
```

### 5.3 Verify Results

```python
# verify_results.py
from databricks_utils.config import ConfigLoader, SparkSessionFactory

config = ConfigLoader.load("local")
spark = SparkSessionFactory.create("local")

# Read from bronze table
df = spark.table("local_catalog.customer_360_bronze.raw_customers")
df.show()

# Output:
# +-----------+------------+--------------------+-------------------+
# |customer_id|        name|               email|         created_at|
# +-----------+------------+--------------------+-------------------+
# |          1| Alice Smith|  alice@example.com|2025-01-01 10:00:00|
# |          2|   Bob Jones|    bob@example.com|2025-01-02 11:30:00|
# |          3| Carol White|  carol@example.com|2025-01-03 09:15:00|
# +-----------+------------+--------------------+-------------------+
```

---

## Step 6: Deploy to Databricks (5 minutes)

### 6.1 Update Asset Bundle Configuration

Edit `databricks/bundle.yml`:

```yaml
bundle:
  name: customer-360-pipeline

targets:
  dev:
    mode: development
    workspace:
      host: https://your-dev-workspace.cloud.databricks.com

    resources:
      jobs:
        customer_360_bronze:
          name: "Customer 360 - Bronze Ingestion"
          tasks:
            - task_key: ingest_customers
              python_file: src/transformations/bronze/ingest_customers.py
              arguments: ["dev"]
              libraries:
                - pypi:
                    package: "databricks-utils==1.2.3"
          schedule:
            quartz_cron_expression: "0 0 2 * * ?"  # Daily at 2 AM
            timezone_id: "America/New_York"
```

### 6.2 Validate and Deploy Bundle

```bash
# Validate bundle configuration
databricks bundle validate

# Deploy to dev environment
databricks bundle deploy -t dev

# Run job manually to test
databricks bundle run customer_360_bronze -t dev
```

### 6.3 Monitor Execution

```bash
# Check job run status
databricks jobs list-runs --job-id <job-id> --limit 1

# View logs
databricks jobs get-run-output --run-id <run-id>
```

---

## Step 7: Set Up Monitoring (Optional, 5 minutes)

### 7.1 Register Data Quality Rules

```python
# register_monitoring.py
from databricks_utils.observability import register_rule
from databricks_utils.data_quality import Rule
from databricks_utils.config import ConfigLoader

config = ConfigLoader.load("dev")

# Freshness rule
freshness_rule = Rule.freshness_check(
    table=f"{config.catalog.name}.{config.catalog.bronze_schema}.raw_customers",
    threshold_hours=24,
    severity="high"
)
monitor_id = register_rule(freshness_rule)
print(f"Registered freshness monitor: {monitor_id}")

# Volume rule
volume_rule = Rule.volume_check(
    table=f"{config.catalog.name}.{config.catalog.bronze_schema}.raw_customers",
    threshold_change_percent=20,
    severity="medium"
)
monitor_id = register_rule(volume_rule)
print(f"Registered volume monitor: {monitor_id}")
```

Run monitoring setup:
```bash
python register_monitoring.py
```

---

## Next Steps

### Expand Your Pipeline

1. **Add Silver Layer Transformation**:
   ```bash
   databricks-agent code \
     --layer silver \
     --source "dev_analytics.customer_360_bronze.raw_customers" \
     --target "dev_analytics.customer_360_silver.cleaned_customers" \
     --description "Clean and deduplicate customer data, validate email formats"
   ```

2. **Add Gold Layer Aggregation**:
   ```bash
   databricks-agent code \
     --layer gold \
     --source "dev_analytics.customer_360_silver.cleaned_customers" \
     --target "dev_analytics.customer_360_gold.customer_summary" \
     --description "Create customer summary with lifetime metrics"
   ```

3. **Profile Your Data**:
   ```bash
   databricks-agent profile \
     --table "dev_analytics.customer_360_bronze.raw_customers" \
     --output data_profiles/bronze_customers.json
   ```

### CI/CD Setup

Add GitHub Actions workflow (`.github/workflows/deploy.yml`):

```yaml
name: Deploy Pipeline

on:
  push:
    branches: [main, dev]

jobs:
  test-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Run tests
        run: pytest tests/unit/ --cov

      - name: Deploy to dev
        if: github.ref == 'refs/heads/dev'
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_DEV_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_DEV_HOST }}
        run: |
          databricks bundle deploy -t dev
```

### Learn More

- **Shared Utilities Documentation**: [Link to docs]
- **Agent Usage Guide**: [Link to docs]
- **Best Practices**: [Link to docs]
- **Troubleshooting**: [Link to docs]

---

## Common Issues & Troubleshooting

### Issue: Agent not generating code

**Solution**:
```bash
# Check agent installation
databricks-agent --version

# Verify API credentials
echo $ANTHROPIC_API_KEY  # or your LLM provider key

# Try with verbose logging
databricks-agent code --layer bronze --verbose
```

### Issue: Cannot connect to Databricks

**Solution**:
```bash
# Reconfigure Databricks CLI
databricks configure --token

# Test connection
databricks workspace list /
```

### Issue: Local Spark session fails

**Solution**:
```bash
# Verify Java installation
java -version  # Should be Java 8 or 11

# Set JAVA_HOME if needed
export JAVA_HOME=/path/to/java

# Try with explicit Spark configuration
python -c "from pyspark.sql import SparkSession; SparkSession.builder.master('local[1]').getOrCreate()"
```

### Issue: Tests failing

**Solution**:
```bash
# Run tests with verbose output
pytest tests/unit/ -v -s

# Run specific test
pytest tests/unit/test_ingest_customers.py::test_ingest_customers_basic -v

# Check test dependencies
pip list | grep -E "pytest|chispa|pyspark"
```

---

## Summary

Congratulations! You've successfully:
- ✅ Set up your AI-Native data engineering environment
- ✅ Created a pipeline project from a template
- ✅ Used AI agents to generate transformation code and tests
- ✅ Ran the pipeline locally with test data
- ✅ Deployed to Databricks using Asset Bundles
- ✅ (Optional) Set up data quality monitoring

You're now ready to build production-grade data pipelines with AI assistance!

**Estimated Time Saved**: 4-6 hours compared to manual setup and coding.

---

## Feedback & Support

- **Questions**: Reach out on #data-engineering-support Slack channel
- **Bug Reports**: [GitHub Issues]
- **Feature Requests**: [GitHub Discussions]
- **Documentation**: [Internal Wiki]
