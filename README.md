# Agentic Data Engineer

A multi-package monorepo for data engineering utilities with independent packages for data quality, observability, Spark session management, and Databricks integration.

## Submodule Initialization

This repository uses git submodules for package management. After cloning, initialize all submodules:

```bash
# Clone the repository with submodules
git clone --recurse-submodules https://github.com/your-org/agentic-data-engineer.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

## Packages

This repository contains 6 independent Python packages and 1 project template:

### 1. spark-session-utils (v1.0.0)
Spark session management, configuration, and logging utilities.

**Repository**: https://github.com/Skyscanner/spark-session-utils

**Features**:
- Spark session lifecycle management
- Configuration presets (Databricks, local, cluster)
- Structured logging with context support
- Delta Lake integration

**Installation**:
```bash
pip install spark-session-utils==1.0.0
```

[→ Documentation](./spark-session-utils/README.md)

### 2. data-shared-utils (v0.3.0)
Core utilities for Databricks with Unity Catalog integration and testing support.

**Repository**: https://github.com/Skyscanner/data-shared-utils

**Features**:
- Unity Catalog operations (via data-catalog-utils)
- Testing utilities and fixtures
- Error handling (retry logic, exponential backoff)

**Installation**:
```bash
pip install data-shared-utils==0.3.0
```

[→ Documentation](./data-shared-utils/README.md)

### 3. data-catalog-utils
Unity Catalog utilities for data catalog management and metadata operations.

**Repository**: https://github.com/Skyscanner/data-catalog-utils

**Features**:
- Unity Catalog table and schema operations
- Metadata management
- Catalog integration helpers

**Installation**:
```bash
pip install data-catalog-utils
```

[→ Documentation](./data-catalog-utils/README.md)

### 4. data-quality-utils (v1.0.0)
Standalone data quality validation and profiling for PySpark DataFrames.

**Repository**: https://github.com/Skyscanner/data-quality-utils

**Features**:
- Declarative validation rules (completeness, uniqueness, freshness, schema, pattern, range)
- Statistical data profiling with sampling support
- Quality gates and anomaly detection

**Installation**:
```bash
pip install data-quality-utils==1.0.0
```

[→ Documentation](./data-quality-utils/README.md)

### 5. data-observability-utils (v1.0.0)
Standalone Monte Carlo observability integration for data monitoring.

**Repository**: https://github.com/Skyscanner/data-observability-utils

**Features**:
- Monte Carlo SDK wrapper
- High-level integration helpers
- Configuration management with credential handling

**Installation**:
```bash
pip install data-observability-utils==1.0.0
```

[→ Documentation](./data-observability-utils/README.md)

### 6. databricks-utils
Databricks integration utilities with MCP server support for Claude Code integration.

**Repository**: https://github.com/Skyscanner/databricks-utils

**Features**:
- Model Context Protocol (MCP) server for Claude Code
- Unity Catalog SQL query execution
- Databricks workspace integration

**Installation**:
```bash
pip install databricks-utils
```

[→ Documentation](./databricks-utils/README.md)

## Project Templates

### blue-data-nova-cookiecutter
Cookiecutter template for creating new data projects following best practices.

**Repository**: https://github.com/Skyscanner/blue-data-nova-cookiecutter

**Features**:
- Pre-configured project structure
- Standard data engineering patterns
- Testing and CI/CD setup
- Configuration management templates

**Usage**:
```bash
# Generate a new project from template
cookiecutter data-project-templates/blue-data-nova-cookiecutter
```

[→ Documentation](./data-project-templates/blue-data-nova-cookiecutter/README.md)

## Quick Start

### Data Quality Validation
```python
from data_quality_utilities import ValidationRule, ValidationRuleset

ruleset = ValidationRuleset(name="user_validation")
ruleset.add_rule(ValidationRule.completeness("user_id", allow_null=False))
ruleset.add_rule(ValidationRule.uniqueness("email"))

result = ruleset.validate(df)
if result.overall_status == Status.FAILED:
    print(f"Validation failed: {result.failed_rules} failures")
```

### Data Profiling
```python
from data_quality_utilities import DataProfiler

profiler = DataProfiler(sample_size=100000)
profile = profiler.profile(df)

print(f"Rows: {profile.row_count:,}")
print(f"Null rate: {profile.get_column_profile('user_id').null_percentage}%")
```

### Spark Session Management
```python
from spark_session_utilities import SparkConfig

config = SparkConfig.for_databricks().enable_delta()
spark = config.create_session(app_name="ETL Pipeline")
```

## Migration from data-shared-utils 0.2.0

If you're migrating from the monolithic `data-shared-utils` 0.2.0:

**Only import paths change** - all class names, method signatures, and parameters remain identical.

See [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for step-by-step instructions.

## Documentation

- [Migration Guide](./MIGRATION_GUIDE.md) - Step-by-step migration from data-shared-utils 0.2.0
- [Changelog](./CHANGELOG.md) - Version history and breaking changes
- [Feature Specifications](./specs/) - Detailed feature specs and design documents

### API Contracts
- [data-quality-utils API](./specs/005-separate-utilities/contracts/data-quality-utils-api.md)
- [data-observability-utils API](./specs/005-separate-utilities/contracts/data-observability-utils-api.md)
- [spark-session-utils API](./specs/005-separate-utilities/contracts/spark-session-utils-api.md)

## Repository Structure

```
.
├── data-quality-utils/                           # Data quality validation package (submodule)
├── data-observability-utils/                     # Monte Carlo observability package (submodule)
├── spark-session-utils/                          # Spark session management package (submodule)
├── data-shared-utils/                            # Core Databricks utilities (submodule)
├── data-catalog-utils/                           # Unity Catalog utilities (submodule)
├── databricks-utils/                             # Databricks integration with MCP server (submodule)
├── data-project-templates/
│   └── blue-data-nova-cookiecutter/              # Cookiecutter project template (submodule)
├── .claude/                                      # Claude Code agents and configuration
├── specs/                                        # Feature specifications
├── MIGRATION_GUIDE.md                            # Migration instructions
├── CHANGELOG.md                                  # Version history
└── .gitmodules                                   # Submodule configuration
```

## Architecture & Diagrams

### Repository Structure Overview

```mermaid
flowchart TD
    subgraph Main["Agentic Data Engineer (Main Repo)"]
        SPECS[specs/]
        CLAUDE[.claude/]
        DOCS[Documentation]
    end

    subgraph Core["Core Utilities (Submodules)"]
        DSU[data-shared-utils]
        DCU[data-catalog-utils]
        DBU[databricks-utils]
    end

    subgraph Specialized["Specialized Utilities (Submodules)"]
        DQU[data-quality-utils]
        DOU[data-observability-utils]
        SSU[spark-session-utils]
    end

    subgraph Templates["Project Templates (Submodules)"]
        COOK[blue-data-nova-cookiecutter]
    end

    Main --> Core
    Main --> Specialized
    Main --> Templates

    DBU -.->|MCP Server| CLAUDE
    DCU -.->|Used by| DSU
```

### Package Dependencies

```mermaid
flowchart LR
    subgraph Applications["Data Applications"]
        ETL[ETL Pipeline]
        ANALYTICS[Analytics Jobs]
        MONITORING[Data Monitoring]
    end

    subgraph Layer1["Foundation Layer"]
        SSU[spark-session-utils<br/>Session Management]
        DSU[data-shared-utils<br/>Core Utilities]
    end

    subgraph Layer2["Specialized Layer"]
        DQU[data-quality-utils<br/>Validation & Profiling]
        DOU[data-observability-utils<br/>Monte Carlo Integration]
        DCU[data-catalog-utils<br/>Unity Catalog Ops]
    end

    subgraph Layer3["Integration Layer"]
        DBU[databricks-utils<br/>MCP Server]
    end

    ETL --> DQU
    ETL --> SSU
    ETL --> DSU

    ANALYTICS --> SSU
    ANALYTICS --> DCU
    ANALYTICS --> DSU

    MONITORING --> DOU
    MONITORING --> DQU

    DQU --> SSU
    DQU --> DSU

    DOU --> DSU

    DCU --> DSU

    DBU --> DCU
    DBU --> DSU
```

### Medallion Architecture with Entities

```mermaid
flowchart LR
    subgraph Bronze["Bronze Layer<br/>(Raw Data)"]
        B1[(Source Systems)]
        B2[(Event Streams)]
        B3[(Files)]
    end

    subgraph Silver["Silver Layer<br/>(Entity-Centric)"]
        S1[User Entity]
        S2[Partner Entity]
        S3[Booking Entity]
        S4[Itinerary Entity]
        S5[SearchIntent Entity]
        S6[SearchResult Entity]
        S7[FlightSegment Entity]
    end

    subgraph Gold["Gold Layer<br/>(Analytics)"]
        G1[Booking Facts]
        G2[Search Analytics]
        G3[Revenue Reports]
        G4[User Insights]
    end

    B1 --> S1
    B1 --> S2
    B2 --> S3
    B2 --> S5
    B3 --> S4

    S1 --> G1
    S1 --> G4
    S2 --> G1
    S3 --> G1
    S4 --> G1
    S5 --> G2
    S6 --> G2
    S7 --> G2

    S3 --> G3
    S4 --> G3
```

### Silver Layer Entity Relationships

```mermaid
erDiagram
    USER ||--o{ BOOKING : makes
    USER ||--o{ SEARCH_INTENT : performs

    BOOKING ||--|{ ITINERARY : contains

    PARTNER ||--o{ ITINERARY : provides
    PARTNER ||--o{ SEARCH_RESULT : offers
    PARTNER ||--o{ FLIGHT_SEGMENT : operates

    SEARCH_INTENT ||--o{ SEARCH_INTENT_RESULT : generates
    SEARCH_RESULT ||--o{ SEARCH_INTENT_RESULT : "shown in"
    SEARCH_RESULT ||--|{ FLIGHT_SEGMENT : "consists of"

    USER {
        bigint user_sk PK
        string user_id UK
        string email
        string loyalty_tier
        timestamp valid_from
        timestamp valid_to
        boolean is_current
    }

    PARTNER {
        bigint partner_sk PK
        string partner_id UK
        string partner_name
        string partner_type
        string iata_code
        boolean is_active
    }

    BOOKING {
        bigint booking_sk PK
        string booking_id UK
        bigint user_sk FK
        timestamp booking_date
        string booking_status
        decimal total_amount
    }

    ITINERARY {
        bigint itinerary_sk PK
        bigint booking_sk FK
        bigint partner_sk FK
        string itinerary_type
        timestamp departure_date
        timestamp return_date
    }

    SEARCH_INTENT {
        bigint search_intent_sk PK
        string search_intent_id UK
        bigint user_sk FK
        timestamp search_timestamp
        string origin_code
        string destination_code
    }

    SEARCH_RESULT {
        bigint search_result_sk PK
        string search_result_id UK
        bigint partner_sk FK
        string flight_number
        timestamp departure_time
        decimal price
    }

    FLIGHT_SEGMENT {
        bigint flight_segment_sk PK
        bigint search_result_sk FK
        int segment_number
        string origin_airport_code
        string destination_airport_code
    }

    SEARCH_INTENT_RESULT {
        bigint search_intent_result_sk PK
        bigint search_intent_sk FK
        bigint search_result_sk FK
        int result_rank
        boolean was_clicked
        boolean was_booked
    }
```

### Data Engineering Workflow

```mermaid
flowchart TD
    subgraph Ingestion["Data Ingestion"]
        A[Raw Data Sources] --> B[Bronze Tables]
    end

    subgraph EntityModeling["Entity Modeling"]
        B --> C{silver-data-modeling-agent}
        C -->|Design| D[Entity Schemas]
        C -->|Apply SCD| E[History Tracking]
        C -->|Define Rules| F[Quality Rules]
    end

    subgraph Transformation["Transformation Pipeline"]
        D --> G[Entity Extraction]
        E --> G
        F --> G
        G --> H[data-quality-utils<br/>Validate]
        H --> I{Quality Pass?}
        I -->|Yes| J[Silver Tables]
        I -->|No| K[Quality Report]
        K --> L[Fix Issues]
        L --> G
    end

    subgraph Analytics["Analytics Layer"]
        J --> M[dimensional-modeling-agent]
        M --> N[Gold Tables]
        N --> O[BI Reports]
    end

    subgraph Monitoring["Observability"]
        H --> P[data-observability-utils]
        P --> Q[Monte Carlo]
        Q --> R[Alerts]
    end
```

### Claude Code Agent Ecosystem

```mermaid
flowchart TD
    subgraph Agents["Claude Code Agents"]
        A1[silver-data-modeling-agent]
        A2[dimensional-modeling-agent]
        A3[bronze-table-finder]
        A4[data-profiler]
        A5[testing-agent]
        A6[documentation-agent]
    end

    subgraph Tools["Data Engineering Tools"]
        T1[data-quality-utils]
        T2[spark-session-utils]
        T3[data-catalog-utils]
    end

    subgraph MCP["MCP Integration"]
        M1[databricks-utils<br/>MCP Server]
        M2[Unity Catalog API]
        M3[SQL Execution]
    end

    A1 -.->|Uses| T1
    A1 -.->|Uses| T2
    A1 -.->|References| A2
    A1 -.->|References| A3
    A1 -.->|References| A4

    A4 -.->|Uses| T1
    A3 -.->|Uses| T3

    A1 -.->|Queries| M1
    A3 -.->|Queries| M1

    M1 --> M2
    M1 --> M3
```

### Submodule Development Workflow

```mermaid
flowchart LR
    subgraph Local["Local Development"]
        A[Clone Main Repo] --> B[Initialize Submodules]
        B --> C{Work on Submodule?}
        C -->|Yes| D[cd into submodule]
        C -->|No| E[Work on Main]
        D --> F[Make Changes]
        F --> G[Commit in Submodule]
        G --> H[Push to Submodule Remote]
        H --> I[Update Main Repo Reference]
        I --> J[Commit Main Repo]
    end

    subgraph Remote["Remote Updates"]
        K[Pull Main Repo] --> L[Update Submodules]
        L --> M[git submodule update<br/>--remote --merge]
    end

    J --> K
```

## Development

### Working with Submodules

```bash
# Update all submodules to latest commits
git submodule update --remote --merge

# Update a specific submodule
git submodule update --remote --merge data-quality-utils

# Pull latest changes for all submodules
git pull --recurse-submodules

# Check submodule status
git submodule status
```

### Package Development

Each package is independently developed and versioned:

```bash
# Install package in development mode
cd data-quality-utils/
pip install -e ".[dev]"

# Run tests
pytest tests/

# Run linting
black src/ tests/
ruff src/ tests/
mypy src/
```

### MCP Server Setup (Claude Code Integration)

This repository includes a Model Context Protocol (MCP) server via the `databricks-utils` submodule for integration with Claude Code. The main project now includes MCP dependencies for enhanced AI integration capabilities.

**Setup:**

```bash
# Install main project dependencies (includes mcp and pydantic)
make setup

# Install MCP dependencies for databricks-utils submodule
make setup-mcp

# Or manually:
poetry install --no-root
poetry -C databricks-utils install --with mcp
```

**Configuration:**

The MCP server is configured in `.mcp.json`. Ensure the following environment variables are set:

```bash
export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
export DATABRICKS_TOKEN="your-personal-access-token"
export DATABRICKS_WAREHOUSE_ID="your-warehouse-id"
```

Once configured, Claude Code will have access to Unity Catalog operations and SQL query execution capabilities through the MCP server.

## License

MIT License - see LICENSE file for details.
