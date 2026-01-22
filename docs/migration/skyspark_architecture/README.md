# Skyscanner Data Platform Documentation

This directory contains comprehensive documentation for Skyscanner's data platform migration from Alchemy/Airflow to SkySpark/Databricks ecosystem.

## Documentation Index

### Architecture Overview
- **[Architecture Overview](SKYSCANNER_DATA_PLATFORM_ARCHITECTURE.md)** - High-level system architecture with diagrams showing all components and their relationships

### Component Documentation

#### 1. [SkySpark Framework](SKYSPARK_FRAMEWORK.md)
Core PySpark framework providing structured approach to building Spark applications with Delta Lake support.

**Repository**: https://github.com/skyscanner/skyspark

**Key Features**:
- Spark App Wrapper
- Delta Table Operations
- Configuration Management

#### 2. [skyspark-cookiecutter](SKYSPARK_COOKIECUTTER.md)
Cookiecutter template for generating opinionated SkySpark projects with testing and deployment configurations.

**Repository**: https://github.com/skyscanner/skyspark-cookiecutter

**Key Features**:
- Project generation via MShell
- Docker and DABs deployment options
- Built-in testing framework

#### 3. [alchemy-airflow-operators](ALCHEMY_AIRFLOW_OPERATORS.md)
Custom Airflow operators library for orchestrating data pipelines, including specialized operators for Databricks/SkySpark job submission.

**Repository**: https://github.com/skyscanner/alchemy-airflow-operators

**Key Features**:
- SkySparkOperator for job submission
- Databricks integration
- Sensors for data validation

#### 4. [astro-dag-deploy](ASTRO_DAG_DEPLOY.md)
AWS Lambda function automating deployment of Airflow DAGs to Astronomer platform.

**Repository**: https://github.com/skyscanner/astro-dag-deploy

**Key Features**:
- Automated DAG deployment
- S3 DAG management
- Deployment metrics and monitoring

### Deployment Patterns

- **[Deployment Workflows](DEPLOYMENT_WORKFLOWS.md)** - Detailed workflows for both Docker-based and DABs-based deployments, including step-by-step breakdowns

### Original Reference Documents

- **[Component Breakdown](SKYSCANNER_COMPONENT_BREAKDOWN.md)** - Complete consolidated breakdown of all components (source document for individual component docs)

## Quick Navigation

### By Role

#### Data Engineers
Start here:
1. [skyspark-cookiecutter](SKYSPARK_COOKIECUTTER.md) - Learn how to generate projects
2. [SkySpark Framework](SKYSPARK_FRAMEWORK.md) - Understand the framework you'll use
3. [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md) - Learn deployment patterns

#### Platform Engineers
Start here:
1. [Architecture Overview](SKYSCANNER_DATA_PLATFORM_ARCHITECTURE.md) - Understand system architecture
2. [alchemy-airflow-operators](ALCHEMY_AIRFLOW_OPERATORS.md) - Configure orchestration
3. [astro-dag-deploy](ASTRO_DAG_DEPLOY.md) - Manage DAG deployment

#### DevOps/SRE
Start here:
1. [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md) - Understand CI/CD pipelines
2. [astro-dag-deploy](ASTRO_DAG_DEPLOY.md) - Lambda deployment automation
3. [Architecture Overview](SKYSCANNER_DATA_PLATFORM_ARCHITECTURE.md) - System integration points

### By Task

#### Creating a New Data Pipeline
1. [skyspark-cookiecutter](SKYSPARK_COOKIECUTTER.md#usage-via-mshell) - Generate project
2. [SkySpark Framework](SKYSPARK_FRAMEWORK.md#usage-pattern) - Use SkySpark APIs
3. [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md#docker-based-deployment-workflow) - Deploy to production

#### Submitting Jobs to Databricks
1. [alchemy-airflow-operators](ALCHEMY_AIRFLOW_OPERATORS.md#1-skysparkoperator) - Configure SkySparkOperator
2. [SkySpark Framework](SKYSPARK_FRAMEWORK.md) - Understand SkySpark apps
3. [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md#job-execution) - Execution flow

#### Deploying DAGs to Airflow
1. [astro-dag-deploy](ASTRO_DAG_DEPLOY.md#deployment-process) - Understand deployment
2. [alchemy-airflow-operators](ALCHEMY_AIRFLOW_OPERATORS.md) - Write DAGs with operators
3. [Deployment Workflows](DEPLOYMENT_WORKFLOWS.md#dag-deployment) - Deployment steps

## Component Relationships

```
┌─────────────────────────┐
│  skyspark-cookiecutter  │
│  (Project Generator)    │
└───────────┬─────────────┘
            │ generates
            ▼
┌─────────────────────────┐      ┌──────────────────────┐
│   SkySpark Framework    │◄─────│ Databricks Platform  │
│   (PySpark Library)     │      │  (Compute Engine)    │
└───────────┬─────────────┘      └──────────┬───────────┘
            │                               │
            │ imported by                   │ executes
            │                               │
┌───────────▼─────────────┐      ┌─────────▼────────────┐
│ alchemy-airflow-ops     │      │   Delta Lake         │
│ (Orchestration)         │──────│   (Storage)          │
└───────────┬─────────────┘      └──────────────────────┘
            │                               ▲
            │ used by                       │ writes to
            │                               │
┌───────────▼─────────────┐                │
│   Apache Airflow        │                │
│   (Scheduler)           │────────────────┘
└───────────▲─────────────┘
            │
            │ deploys to
            │
┌───────────┴─────────────┐
│  astro-dag-deploy       │
│  (Deployment Automation)│
└─────────────────────────┘
```

## Deployment Patterns Summary

| Pattern | Artifact | Use Case | Runtime |
|---------|----------|----------|---------|
| **Docker** | Docker image in ECR | Standard ETL pipelines | Databricks Runtime |
| **DABs** | Wheel packages in workspace | ML workloads | Databricks ML Runtime |

## Technologies

- **Python 3.10+**: Primary programming language
- **PySpark 4.0+**: Distributed data processing
- **Delta Lake**: ACID-compliant storage layer
- **Databricks Runtime**: Managed Spark environment
- **Apache Airflow**: Workflow orchestration
- **AWS Lambda**: Serverless deployment automation
- **Docker**: Containerization for reproducible environments
- **Databricks Asset Bundles**: Alternative deployment for ML workloads

## Migration Context

This architecture represents Skyscanner's migration from:
- **Alchemy** (legacy data platform) → **SkySpark** (modern PySpark framework)
- **EMR/Glue** (AWS-native compute) → **Databricks** (unified analytics platform)
- **Manual deployment** → **Automated DAG deployment** (via Lambda)

The migration maintains Airflow as the orchestration layer while modernizing the compute and data storage infrastructure.

## Contributing

When updating this documentation:
1. Keep component docs focused and self-contained
2. Update cross-references when changing document structure
3. Maintain consistency in examples and code snippets
4. Update diagrams when architecture changes
5. Keep the index (this file) synchronized with actual content

## Additional Resources

- [Skyscanner SkySpark Slack Channel](https://skyscanner.slack.com/archives/C02LEV2CSBF) - #skyspark
- [Official SkySpark Documentation](https://skyscanner.atlassian.net/l/cp/CS1R9AHg)
- [Databricks Documentation](https://docs.databricks.com/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
