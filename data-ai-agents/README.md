# Databricks AI Agents

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

AI-powered agents for Databricks data engineering development, providing automated code generation, testing, quality checks, and project scaffolding.

## Features

- **Template Agent**: Generate and evolve cookiecutter project templates
- **Coding Agent**: Generate PySpark transformation code for bronze/silver/gold layers
- **Testing Agent**: Automatically create unit and integration tests
- **Profiling Agent**: Analyze data and generate quality rules
- **Quality Agent**: Review code against organizational standards
- **Observability Agent**: Generate Monte Carlo monitoring configurations
- **Dashboard Agent**: Create dashboard definitions from data models
- **Optimization Agent**: Suggest performance improvements

## Installation

```bash
pip install databricks-ai-agents
```

## Quick Start

### Initialize a New Project

```bash
databricks-agent init \
  --name "customer-360-pipeline" \
  --description "Customer 360 degree view pipeline" \
  --owner-team "data-analytics"
```

### Generate Transformation Code

```bash
databricks-agent code \
  --layer bronze \
  --source "s3://raw-data/customers/*.json" \
  --target "dev_analytics.customer_360_bronze.raw_customers" \
  --description "Ingest customer data with schema validation" \
  --output pipelines/bronze/ingest_customers.py
```

### Generate Tests

```bash
databricks-agent test \
  --target-file pipelines/bronze/ingest_customers.py \
  --function-name ingest_customers \
  --output tests/unit/test_ingest_customers.py
```

### Profile Data

```bash
databricks-agent profile \
  --table "dev_analytics.customer_360_bronze.raw_customers" \
  --output data_profiles/bronze_customers.json
```

### Review Code Quality

```bash
databricks-agent quality \
  --file pipelines/silver/clean_customers.py \
  --report quality_report.md
```

## Available Agents

### Template Agent (`init`)

Generates project structures from cookiecutter templates or creates new templates based on requirements.

```bash
databricks-agent init --help
```

### Coding Agent (`code`)

Generates PySpark transformation code for medallion architecture layers.

```bash
databricks-agent code --help
```

### Testing Agent (`test`)

Creates pytest test suites for transformations.

```bash
databricks-agent test --help
```

### Profiling Agent (`profile`)

Analyzes data and generates data quality rules.

```bash
databricks-agent profile --help
```

### Quality Agent (`quality`)

Reviews code for best practices and potential issues.

```bash
databricks-agent quality --help
```

### Observability Agent (`observe`)

Generates Monte Carlo monitoring configurations.

```bash
databricks-agent observe --help
```

## Configuration

Set your AI provider API key:

```bash
export ANTHROPIC_API_KEY="your-api-key"
```

Configure agent settings in `~/.databricks-agents/config.yaml`:

```yaml
default_model: claude-sonnet-4
default_temperature: 0.2
max_tokens: 4000
timeout_seconds: 300
```

## MCP Integration

The agents support Model Context Protocol (MCP) for IDE integration:

```json
{
  "servers": {
    "databricks-agents": {
      "command": "databricks-agent",
      "args": ["serve"],
      "env": {}
    }
  }
}
```

## Agent Composition

Chain multiple agents for complex workflows:

```bash
# Generate code, then tests, then quality check
databricks-agent code --layer silver --description "Clean customer data" --output pipelines/silver/clean.py && \
databricks-agent test --target-file pipelines/silver/clean.py --output tests/unit/test_clean.py && \
databricks-agent quality --file pipelines/silver/clean.py
```

## Development

```bash
# Clone repository
git clone https://github.com/company/databricks-ai-agents.git
cd databricks-ai-agents

# Install in development mode
pip install -e ".[dev]"

# Run tests
pytest tests/

# Run specific agent
python -m cli.main code --help
```

## Version History

- **0.1.0** (2025-11-22): Initial release
  - Base agent framework
  - CLI with Click
  - MCP server support

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

- Documentation: https://databricks-ai-agents.readthedocs.io
- Issues: https://github.com/company/databricks-ai-agents/issues
- Slack: #data-engineering-support
