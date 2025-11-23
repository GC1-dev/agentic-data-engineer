# Databricks Project Templates

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Cookiecutter templates for Databricks data engineering projects, providing standardized project structures for batch pipelines, streaming pipelines, and ML feature engineering.

## Available Templates

### 1. Databricks Pipeline (`cookiecutter-databricks-pipeline`)

Standard batch data pipeline following medallion architecture.

**Features:**
- Bronze/Silver/Gold layer structure
- Environment configurations (local/lab/dev/prod)
- Databricks Asset Bundle integration
- Monte Carlo observability
- Data quality validation rules
- Dashboard definitions
- CI/CD workflows

**Usage:**

```bash
cookiecutter https://github.com/company/databricks-project-templates.git \
  --directory cookiecutter-databricks-pipeline
```

Or use the AI template agent:

```bash
databricks-agent init \
  --name "my-pipeline" \
  --description "My data pipeline" \
  --owner-team "data-team"
```

### Project Structure

All templates create a standardized 9-directory structure:

```
project-name/
├── src/                    # Reusable utility functions
├── pipelines/              # Data transformation workflows
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── dashboards/             # Visualization definitions
├── databricks_apps/        # Databricks applications
├── monte_carlo/            # Observability configuration
├── data_validation/        # Data quality rules
├── tests/                  # Unit and integration tests
│   ├── unit/
│   └── integration/
├── config/                 # Environment configurations
│   ├── local.yaml
│   ├── lab.yaml
│   ├── dev.yaml
│   ├── prod.yaml
│   └── project.yaml
├── docs/                   # Project documentation
└── databricks/             # Asset Bundle configuration
    └── bundle.yml
```

## Template Variables

Common variables across templates:

- `project_name`: Human-readable project name
- `project_slug`: URL-safe project identifier
- `description`: Project description
- `owner_team`: Owning team name
- `python_version`: Python version (default: 3.10)
- `include_streaming`: Include streaming components (yes/no)
- `databricks_runtime`: Target Databricks Runtime version

## Environment Configuration

Each template includes environment-specific configurations:

- **local**: Local development with Spark standalone
- **lab**: Experimentation environment
- **dev**: Development environment
- **prod**: Production environment

## Customization

Templates can be customized by:

1. Modifying `cookiecutter.json` variables
2. Editing template files in `{{cookiecutter.project_slug}}/`
3. Using post-generation hooks in `hooks/`

## Template Evolution

Templates are continuously improved by the AI template agent based on usage patterns:

```bash
# Analyze template usage
databricks-agent template analyze --template cookiecutter-databricks-pipeline

# Propose improvements
databricks-agent template propose --template cookiecutter-databricks-pipeline

# Update template (requires approval)
databricks-agent template update --template cookiecutter-databricks-pipeline --version 1.1.0
```

## Development

### Creating a New Template

```bash
# Create template directory
mkdir cookiecutter-new-template
cd cookiecutter-new-template

# Create cookiecutter.json
cat > cookiecutter.json << EOF
{
  "project_name": "My Project",
  "project_slug": "{{ cookiecutter.project_name.lower().replace(' ', '-') }}",
  "description": "Project description",
  "owner_team": "data-team"
}
EOF

# Create template structure
mkdir -p "{{cookiecutter.project_slug}}"
```

### Testing Templates

```bash
# Test template generation
cookiecutter . --no-input

# Validate generated project
cd my-project
pip install -r requirements.txt
pytest tests/
```

## Version History

- **1.0.0** (2025-11-22): Initial template release
  - Databricks pipeline template
  - 9-directory standard structure
  - Environment configurations
  - Asset Bundle integration

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for template development guidelines.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

- Documentation: https://databricks-templates.readthedocs.io
- Issues: https://github.com/company/databricks-project-templates/issues
- Slack: #data-engineering-support
