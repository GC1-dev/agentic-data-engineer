# Skyscanner Data Platform Architecture

## Overview

This document describes the architecture and relationships between the key components of Skyscanner's data platform migration from Alchemy/Airflow to SkySpark/Databricks ecosystem.

## Component Repositories

The platform consists of four main repositories:

| Component | Repository | Description |
|-----------|------------|-------------|
| **SkySpark** | [github.com/skyscanner/skyspark](https://github.com/skyscanner/skyspark) | Core PySpark framework for Spark applications |
| **skyspark-cookiecutter** | [github.com/skyscanner/skyspark-cookiecutter](https://github.com/skyscanner/skyspark-cookiecutter) | Project template generator |
| **alchemy-airflow-operators** | [github.com/skyscanner/alchemy-airflow-operators](https://github.com/skyscanner/alchemy-airflow-operators) | Custom Airflow operators for orchestration |
| **astro-dag-deploy** | [github.com/skyscanner/astro-dag-deploy](https://github.com/skyscanner/astro-dag-deploy) | AWS Lambda for DAG deployment automation |

### Component Relationship Graph

```mermaid
graph TB
    COOKIE["<a href='https://github.com/skyscanner/skyspark-cookiecutter'>skyspark-cookiecutter</a><br/>Project Template Generator"]
    SKYSPARK["<a href='https://github.com/skyscanner/skyspark'>SkySpark</a><br/>PySpark Framework"]
    ALCHEMY["<a href='https://github.com/skyscanner/alchemy-airflow-operators'>alchemy-airflow-operators</a><br/>Airflow Operators"]
    ASTRO["<a href='https://github.com/skyscanner/astro-dag-deploy'>astro-dag-deploy</a><br/>DAG Deployment Lambda"]

    DATABRICKS["Databricks<br/>Compute Platform"]
    AIRFLOW["Apache Airflow<br/>Orchestration"]
    DELTA["Delta Lake<br/>Storage Layer"]
    PROJECTS["Generated<br/>SkySpark Projects"]

    COOKIE -->|"generates projects<br/>that depend on"| SKYSPARK
    COOKIE -->|generates| PROJECTS
    PROJECTS -->|uses| SKYSPARK
    ALCHEMY -->|"contains operators<br/>for submitting"| SKYSPARK
    ALCHEMY -->|"submits jobs to"| DATABRICKS
    ASTRO -->|"deploys DAGs to"| AIRFLOW
    AIRFLOW -->|uses| ALCHEMY
    DATABRICKS -->|executes| SKYSPARK
    SKYSPARK -->|"writes/reads"| DELTA

    classDef repo fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef platform fill:#f5f5f5,stroke:#666,stroke-width:1px

    class COOKIE,SKYSPARK,ALCHEMY,ASTRO repo
    class DATABRICKS,AIRFLOW,DELTA,PROJECTS platform
```

**Repository Interactions:**
- **skyspark-cookiecutter** → **SkySpark**: Generated projects import SkySpark as a dependency
- **alchemy-airflow-operators** → **SkySpark**: Contains SkySparkOperator for job submission
- **alchemy-airflow-operators** → **Databricks**: Submits jobs via Databricks API
- **astro-dag-deploy** → **Airflow**: Automates DAG deployment to Astronomer
- **SkySpark** → **Delta Lake**: Provides APIs for Delta table operations

## Architecture Diagram

```mermaid
graph TB
    subgraph "Development Tools"
        MSHELL["MShell Cut<br/>Project Generator"]
        COOKIE["skyspark-cookiecutter<br/>Project Template"]
    end

    subgraph "Core Framework"
        SKYSPARK["SkySpark Library<br/>PySpark Framework"]
        SKYSPARK_APP["Spark App Wrapper"]
        SKYSPARK_DELTA["Delta Table Operations"]
        SKYSPARK_CONFIG["Configuration Management"]
    end

    subgraph "Orchestration Layer"
        AIRFLOW["Apache Airflow"]
        ALCHEMY_OPS["alchemy-airflow-operators<br/>Custom Operators"]
        SKYSPARK_OP["SkySparkOperator"]
        DATABRICKS_OP["AlchemyDatabricksSubmitPySparkJobOperator"]
    end

    subgraph "Deployment Layer"
        ASTRO_LAMBDA["astro-dag-deploy<br/>AWS Lambda"]
        S3_BUCKET["S3 Bucket<br/>DAG Storage"]
        ASTRO_CLI["Astro CLI"]
    end

    subgraph "Compute Platform"
        DATABRICKS["Databricks Platform"]
        SPARK_CLUSTER["Spark Clusters"]
        DELTA_LAKE["Delta Lake Storage"]
    end

    subgraph "Generated Projects"
        PROJ["SkySpark Project"]
        PROJ_SRC["src/"]
        PROJ_APPS["apps/"]
        PROJ_TRANS["transformations/"]
        PROJ_SCHEMA["schema/"]
        PROJ_DOCKER["Dockerfile"]
        PROJ_DAB["databricks.yaml"]
    end

    %% Development Flow
    MSHELL -->|cuts project from| COOKIE
    COOKIE -->|generates| PROJ
    PROJ --> PROJ_SRC
    PROJ_SRC --> PROJ_APPS
    PROJ_SRC --> PROJ_TRANS
    PROJ_SRC --> PROJ_SCHEMA
    PROJ --> PROJ_DOCKER
    PROJ --> PROJ_DAB

    %% Dependency Relationships
    PROJ_APPS -->|imports| SKYSPARK
    SKYSPARK --> SKYSPARK_APP
    SKYSPARK --> SKYSPARK_DELTA
    SKYSPARK --> SKYSPARK_CONFIG

    %% Orchestration Flow
    AIRFLOW -->|uses| ALCHEMY_OPS
    ALCHEMY_OPS -->|includes| SKYSPARK_OP
    SKYSPARK_OP -->|extends| DATABRICKS_OP
    SKYSPARK_OP -->|submits jobs to| DATABRICKS

    %% Deployment Flow
    AIRFLOW -->|triggers| ASTRO_LAMBDA
    ASTRO_LAMBDA -->|uploads DAGs to| S3_BUCKET
    ASTRO_LAMBDA -->|deploys via| ASTRO_CLI
    S3_BUCKET -->|syncs to| AIRFLOW

    %% Execution Flow
    DATABRICKS -->|creates| SPARK_CLUSTER
    SPARK_CLUSTER -->|runs| PROJ_APPS
    SPARK_CLUSTER -->|writes to| DELTA_LAKE
    PROJ_APPS -->|uses| SKYSPARK_DELTA

    %% Docker Flow
    PROJ_DOCKER -->|builds image for| DATABRICKS

    %% DAB Flow
    PROJ_DAB -->|alternative deployment| DATABRICKS

    classDef framework fill:#e1f5ff,stroke:#0066cc
    classDef orchestration fill:#fff4e1,stroke:#cc6600
    classDef deployment fill:#e8f5e9,stroke:#2e7d32
    classDef platform fill:#fce4ec,stroke:#c2185b
    classDef development fill:#f3e5f5,stroke:#7b1fa2
    classDef project fill:#fff9c4,stroke:#f9a825

    class SKYSPARK,SKYSPARK_APP,SKYSPARK_DELTA,SKYSPARK_CONFIG framework
    class AIRFLOW,ALCHEMY_OPS,SKYSPARK_OP,DATABRICKS_OP orchestration
    class ASTRO_LAMBDA,S3_BUCKET,ASTRO_CLI deployment
    class DATABRICKS,SPARK_CLUSTER,DELTA_LAKE platform
    class MSHELL,COOKIE development
    class PROJ,PROJ_SRC,PROJ_APPS,PROJ_TRANS,PROJ_SCHEMA,PROJ_DOCKER,PROJ_DAB project
```

## Component Layers

### 1. Development Tools Layer
- **MShell Cut**: Command-line tool for generating new projects
- **skyspark-cookiecutter**: Template repository containing opinionated project structure

### 2. Core Framework Layer
- **SkySpark**: Python library providing PySpark utilities and patterns
- Handles Spark session management, configuration, and Delta Lake operations

### 3. Orchestration Layer
- **Apache Airflow**: Workflow orchestration platform
- **alchemy-airflow-operators**: Custom Airflow operators for data pipelines
- **SkySparkOperator**: Specialized operator for submitting SkySpark jobs to Databricks

### 4. Deployment Layer
- **astro-dag-deploy**: AWS Lambda function for deploying DAGs to Astronomer
- Handles DAG file management and deployment automation

### 5. Compute Platform Layer
- **Databricks**: Unified analytics platform running Spark workloads
- **Delta Lake**: Storage layer providing ACID transactions

### 6. Generated Projects Layer
- Projects created from the cookiecutter template
- Contains apps, transformations, schemas, and deployment configurations

## Deployment Patterns

### Pattern 1: Docker-based Deployment (Default)
1. Developer cuts project using `mshell-cut`
2. Project includes Dockerfile for containerization
3. Docker image pushed to ECR
4. SkySparkOperator references Docker image when submitting jobs
5. Databricks pulls Docker image and runs Spark job

### Pattern 2: Databricks Asset Bundles (DABs)
1. Developer cuts project with `type_of_task=dab`
2. Project includes `databricks.yaml` configuration
3. DABs CLI deploys code directly to Databricks workspace
4. No Docker image required (uses Databricks ML Runtime)

## Data Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as GitHub
    participant AF as Airflow
    participant Lambda as astro-dag-deploy
    participant S3 as S3 Bucket
    participant DB as Databricks
    participant DL as Delta Lake

    Dev->>Git: Push code changes
    Git->>AF: Trigger DAG deployment
    AF->>Lambda: Invoke with DAG metadata
    Lambda->>S3: Upload DAG files
    Lambda->>AF: Deploy to Astronomer
    AF->>DB: Submit SkySpark job via SkySparkOperator
    DB->>DB: Execute PySpark transformations
    DB->>DL: Write results to Delta tables
```

## Integration Points

### 1. **skyspark-cookiecutter → SkySpark**
- Generated projects have SkySpark as a dependency in `requirements.txt`
- Apps import SkySpark utilities for Spark session and Delta operations

### 2. **alchemy-airflow-operators → Databricks**
- SkySparkOperator configures Databricks cluster and job parameters
- Handles authentication, IAM roles, and Spark configuration

### 3. **astro-dag-deploy → Airflow**
- Lambda function manages DAG lifecycle in Astronomer
- Parses DAG definitions and uploads to S3
- Uses Astro CLI for deployment

### 4. **SkySpark → Delta Lake**
- Provides high-level APIs for Delta table operations
- Handles partitioning, clustering, and metadata management

## Key Technologies

- **Python 3.10+**: Primary programming language
- **PySpark 4.0+**: Distributed data processing
- **Delta Lake**: ACID-compliant storage layer
- **Databricks Runtime**: Managed Spark environment
- **Apache Airflow**: Workflow orchestration
- **AWS Lambda**: Serverless deployment automation
- **Docker**: Containerization for reproducible environments
- **Databricks Asset Bundles**: Alternative deployment mechanism for ML workloads

## Migration Context

This architecture represents Skyscanner's migration from:
- **Alchemy** (legacy data platform) → **SkySpark** (modern PySpark framework)
- **EMR/Glue** (AWS-native compute) → **Databricks** (unified analytics platform)
- **Manual deployment** → **Automated DAG deployment** (via Lambda)

The migration maintains Airflow as the orchestration layer while modernizing the compute and data storage infrastructure.
