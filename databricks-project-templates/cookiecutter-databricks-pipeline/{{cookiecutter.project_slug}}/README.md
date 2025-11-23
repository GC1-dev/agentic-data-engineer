# {{ cookiecutter.project_name }}

{{ cookiecutter.description }}

**Owner Team**: {{ cookiecutter.owner_team }}
**Python Version**: {{ cookiecutter.python_version }}
**Databricks Runtime**: {{ cookiecutter.databricks_runtime }}

## Project Structure

```
{{ cookiecutter.project_slug }}/
├── src/                    # Reusable utility functions
├── pipelines/              # Data transformation workflows
│   ├── bronze/             # Raw data ingestion
│   ├── silver/             # Cleaned and validated data
│   └── gold/               # Business-level aggregations
├── dashboards/             # Dashboard definitions
├── databricks_apps/        # Databricks applications
├── monte_carlo/            # Observability configuration
├── data_validation/        # Data quality rules
├── tests/                  # Unit and integration tests
├── config/                 # Environment configurations
├── docs/                   # Project documentation
└── databricks/             # Asset Bundle configuration
```

## Quick Start

### 1. Install Dependencies

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### 2. Configure Environments

Update configuration files in `config/` directory:
- `local.yaml` - Local development
- `lab.yaml` - Experimentation
- `dev.yaml` - Development environment
- `prod.yaml` - Production environment

### 3. Run Locally

```bash
# Set environment
export ENV=local

# Run a transformation
python pipelines/bronze/example_ingest.py
```

### 4. Deploy to Databricks

```bash
# Validate Asset Bundle
databricks bundle validate

# Deploy to dev
databricks bundle deploy -t dev

# Run pipeline
databricks bundle run <pipeline-name> -t dev
```

## Development Workflow

### Generate Code with AI Agents

```bash
# Generate bronze layer code
databricks-agent code \
  --layer bronze \
  --source "s3://raw-data/source/" \
  --target "{{ cookiecutter.catalog_name_dev }}.{{ cookiecutter.schema_prefix }}_bronze.table" \
  --description "Ingest data with validation" \
  --output pipelines/bronze/ingest_source.py

# Generate tests
databricks-agent test \
  --target-file pipelines/bronze/ingest_source.py \
  --output tests/unit/test_ingest_source.py

# Profile data
databricks-agent profile \
  --table "{{ cookiecutter.catalog_name_dev }}.{{ cookiecutter.schema_prefix }}_bronze.table" \
  --output data_profiles/bronze_table.json
```

### Run Tests

```bash
# Unit tests
pytest tests/unit/ -v

# Integration tests
pytest tests/integration/ -v

# With coverage
pytest tests/ --cov=pipelines --cov-report=html
```

### Code Quality

```bash
# Format code
black pipelines/ src/ tests/

# Lint
ruff check pipelines/ src/ tests/

# Type check
mypy pipelines/ src/
```

## Configuration

### Environment Variables

```bash
export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
export DATABRICKS_TOKEN="your-token"
export ENV="dev"  # or local, lab, prod
```

### Unity Catalog Schema Names

| Environment | Catalog | Bronze Schema | Silver Schema | Gold Schema |
|-------------|---------|---------------|---------------|-------------|
| Local | `local_catalog` | `{{ cookiecutter.schema_prefix }}_bronze` | `{{ cookiecutter.schema_prefix }}_silver` | `{{ cookiecutter.schema_prefix }}_gold` |
| Lab | `lab_analytics` | `{{ cookiecutter.schema_prefix }}_bronze` | `{{ cookiecutter.schema_prefix }}_silver` | `{{ cookiecutter.schema_prefix }}_gold` |
| Dev | `{{ cookiecutter.catalog_name_dev }}` | `{{ cookiecutter.schema_prefix }}_bronze` | `{{ cookiecutter.schema_prefix }}_silver` | `{{ cookiecutter.schema_prefix }}_gold` |
| Prod | `{{ cookiecutter.catalog_name_prod }}` | `{{ cookiecutter.schema_prefix }}_bronze` | `{{ cookiecutter.schema_prefix }}_silver` | `{{ cookiecutter.schema_prefix }}_gold` |

## Observability

### Monte Carlo Integration

Data quality monitoring is configured in `monte_carlo/` directory.

To register monitors:

```bash
databricks-agent observe \
  --pipeline-name "{{ cookiecutter.project_slug }}" \
  --config monte_carlo/monitors.yaml
```

### Data Quality Rules

Validation rules are defined in `data_validation/` directory.

## CI/CD

GitHub Actions workflows are configured in `.github/workflows/`:
- `ci.yml` - Run tests on pull requests
- `deploy.yml` - Deploy to environments on merge

## Documentation

- [Architecture](docs/architecture.md)
- [Development Guide](docs/development.md)
- [Deployment Guide](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)

## Support

- **Team**: {{ cookiecutter.owner_team }}
- **Slack**: #data-engineering-support
- **Documentation**: [Internal Wiki]

## License

[Your License]
