# skyspark-cookiecutter

## Purpose
A Cookiecutter template for generating opinionated SkySpark projects with built-in testing, deployment configurations, and best practices.

## Repository Location
https://github.com/skyscanner/skyspark-cookiecutter

## Template Variables

Configured via `cookiecutter.json`:

| Variable | Description | Example |
|----------|-------------|---------|
| `gitlab_group_name` | GitHub/GitLab group | "Skyscanner" |
| `squad_name` | Team name | "Data Platform" |
| `contact_email` | Team email | "team@skyscanner.net" |
| `contact_slack_channel` | Slack channel | "#data-platform" |
| `type_of_task` | Deployment type | "docker" or "dab" |
| `service_principal_application_id_dev` | Azure SP for dev (DABs only) | UUID |
| `service_principal_application_id_prod` | Azure SP for prod (DABs only) | UUID |
| `repo_name` | Repository name | "my-data-pipeline" |
| `repo_description` | Description | "ETL pipeline for..." |
| `aws_project_name` | AWS cost allocation tag | "data-platform" |

## Generated Project Structure

```
{{cookiecutter.repo_name}}/
├── src/
│   ├── __init__.py
│   ├── apps/                  # Spark application entry points
│   ├── common/                # Shared utilities
│   ├── resources/             # Configuration files (YAML, JSON)
│   ├── schema/                # Data schemas and contracts
│   └── transformations/       # Business logic transformations
├── tests/                     # Test suite with Delta Lake emulation
├── Dockerfile                 # Container definition (if type_of_task=docker)
├── databricks.yaml            # DABs configuration (if type_of_task=dab)
├── databricks-workflows/      # Workflow definitions
├── Makefile                   # Build automation
├── pyproject.toml             # Python project metadata
├── requirements.txt           # Runtime dependencies
├── requirements-dev.txt       # Development dependencies
└── README.md                  # Project documentation
```

## Usage via MShell

```bash
# Interactive project generation
mshell-cut cut
# Select option [7] - skyspark
# Choose deployment type: [0] docker or [1] dab
# Provide configuration values
```

## Deployment Type Comparison

### Docker-based (type_of_task="docker")
- **Default choice** for data engineering pipelines
- Generates `Dockerfile` for containerization
- Images pushed to AWS ECR
- SkySparkOperator references Docker image
- Better for standard ETL workloads

### Databricks Asset Bundles (type_of_task="dab")
- **Required** for Machine Learning workloads
- Generates `databricks.yaml` configuration
- Direct code deployment to Databricks workspace
- No Docker image required
- Uses Databricks ML Runtime
- Requires service principal IDs

## Testing Approach

- Delta Lake-based test suite emulates production
- Test structure mirrors `src/` organization
- Pytest fixtures for Spark session management
- Local execution with Delta Lake

## Example Configuration

### Docker-based Project
```json
{
  "gitlab_group_name": "Skyscanner",
  "squad_name": "My Squad",
  "contact_email": "MySquad@skyscanner.net",
  "contact_slack_channel": "#my-squad-channel",
  "type_of_task": "docker",
  "service_principal_application_id_dev": "",
  "service_principal_application_id_prod": "",
  "repo_name": "test-skyspark-repo",
  "repo_description": "A test SkySpark repository using Docker",
  "aws_project_name": "untagged"
}
```

### DABs-based Project
```json
{
  "gitlab_group_name": "Skyscanner",
  "squad_name": "skyspark",
  "contact_email": "MySquad@skyscanner.net",
  "contact_slack_channel": "#my-squad-channel",
  "type_of_task": "dab",
  "service_principal_application_id_dev": "12jh2j3-ca31-45e1-9939-2n342n234n2",
  "service_principal_application_id_prod": "54m2n3n2-ca31-45e1-9939-234n234mm23",
  "repo_name": "test-skyspark-repo",
  "repo_description": "A test SkySpark repository using DABs",
  "aws_project_name": "untagged"
}
```

## Integration Points

### With SkySpark Framework
- Generated projects have SkySpark as a dependency in `requirements.txt`
- Apps import SkySpark utilities for Spark session and Delta operations
- Projects follow SkySpark conventions and patterns

### With Databricks
- Docker images deployed to ECR for Databricks clusters
- DABs configurations for direct workspace deployment
- Workflow definitions for job scheduling

### With Airflow
- Generated DAGs can use SkySparkOperator
- Projects structured for orchestration via Airflow

## Developer Guide

1. Ensure Docker daemon is running, then upgrade `mshell-cut`:
   ```bash
   brew update && brew upgrade mshell-cut
   ```

2. Cut a sample project:
   ```bash
   make cut-test-project
   ```

3. Switch to project directory:
   ```bash
   cd test-skyspark-repo
   ```

4. Run tests:
   ```bash
   make test
   ruff check .
   ```

## Related Components

- [SkySpark Framework](SKYSPARK_FRAMEWORK.md) - Core PySpark framework used by generated projects
- [alchemy-airflow-operators](ALCHEMY_AIRFLOW_OPERATORS.md) - Orchestration operators for SkySpark jobs
- [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md) - Complete deployment patterns
- [Architecture Overview](SKYSCANNER_DATA_PLATFORM_ARCHITECTURE.md) - Complete system architecture
