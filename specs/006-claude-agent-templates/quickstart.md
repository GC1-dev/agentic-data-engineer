# Quickstart Guide: Claude Agent Template System

**Feature**: 006-claude-agent-templates
**Date**: 2025-11-23
**Audience**: Developers implementing the Claude agent template system

## Overview

This quickstart provides a step-by-step guide to understanding and implementing the Claude Agent Template System. Follow these steps to go from specification to working implementation.

---

## Prerequisites

Before starting implementation, ensure you have:

- [ ] Read the [feature specification](./spec.md)
- [ ] Read the [implementation plan](./plan.md)
- [ ] Read the [research decisions](./research.md)
- [ ] Reviewed the [data model](./data-model.md)
- [ ] Understood the [contracts](./contracts/)
- [ ] Python 3.10+ installed
- [ ] Claude API access (Anthropic API key)
- [ ] Basic understanding of:
  - Databricks platform
  - Asset Bundles
  - Jinja2 templating
  - Pydantic models

---

## Step 1: Environment Setup (15 minutes)

### 1.1 Create Development Environment

```bash
# Clone the repository
cd databricks-project-templates

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install anthropic jinja2 pyyaml pydantic click pytest pytest-mock black ruff mypy
```

### 1.2 Configure Claude API Access

```bash
# Set API key as environment variable
export ANTHROPIC_API_KEY="your-api-key-here"

# Or create .env file (DO NOT commit this)
echo "ANTHROPIC_API_KEY=your-api-key-here" > .env
```

### 1.3 Verify Setup

```bash
# Test Claude API connection
python -c "from anthropic import Anthropic; client = Anthropic(); print('✅ Claude API connected')"
```

---

## Step 2: Understand the Architecture (30 minutes)

### 2.1 Review Project Structure

The implementation follows this structure (from plan.md):

```
src/
├── agent/              # Conversational flow orchestration
├── generators/         # Project generation logic
├── features/           # Feature module system
├── validation/         # Output validation
├── analytics/          # Session recording & pattern analysis
└── models/             # Pydantic data models
```

### 2.2 Key Components

| Component | Purpose | Key Classes |
|-----------|---------|-------------|
| `agent/conversation.py` | Manages conversation flow | `ConversationManager` |
| `agent/requirements_parser.py` | NL → structured requirements | `RequirementsParser` |
| `generators/project_generator.py` | Orchestrates generation | `ProjectGenerator` |
| `features/base.py` | Feature module interface | `FeatureModule` (ABC) |
| `validation/structure_validator.py` | Validates 9-directory layout | `StructureValidator` |
| `models/project_requirements.py` | Requirements data model | `ProjectRequirements` (Pydantic) |

### 2.3 Conversation Flow

```
User Input (natural language)
  ↓
RequirementsParser (Claude API) → Structured Requirements
  ↓
QuestionBuilder → Identify Ambiguities
  ↓
ConversationManager → Ask Clarifying Questions (loop)
  ↓
CompatibilityChecker → Detect Conflicts
  ↓
ProjectGenerator → Generate Project Files
  ↓
ValidationPipeline → Validate Output
  ↓
SessionRecorder → Save Anonymized Metadata
  ↓
Success! → Return project path
```

---

## Step 3: Implement Core Data Models (1 hour)

### 3.1 Create Pydantic Models

Start with the foundational models from [data-model.md](./data-model.md):

**File**: `src/models/project_requirements.py`

```python
from pydantic import BaseModel, Field, field_validator
from enum import Enum
from typing import List, Optional

class FeatureType(str, Enum):
    STREAMING = "streaming"
    MONTE_CARLO = "monte_carlo"
    DATA_VALIDATION = "data_validation"
    TESTING_FRAMEWORK = "testing"

class ProjectRequirements(BaseModel):
    project_name: str = Field(..., pattern=r'^[a-zA-Z0-9_-]+$')
    description: str = Field(..., min_length=10, max_length=500)
    python_version: str = Field("3.11", pattern=r'^3\.(10|11|12)$')
    databricks_runtime: str = Field("14.3", pattern=r'^\d+\.\d+$')
    transformation_layers: List[str] = ["bronze_silver_gold"]
    data_sources: List[str] = []
    optional_features: List[FeatureType] = []
    ci_cd_platform: str = Field("github_actions")
    team_ownership: Optional[str] = None
    environment_configs: List[str] = ["local", "lab", "dev", "prod"]
```

### 3.2 Test the Models

**File**: `tests/unit/test_project_requirements.py`

```python
import pytest
from src.models.project_requirements import ProjectRequirements, FeatureType

def test_valid_project_requirements():
    req = ProjectRequirements(
        project_name="test_pipeline",
        description="Test pipeline for customer data"
    )
    assert req.python_version == "3.11"  # Default
    assert req.databricks_runtime == "14.3"  # Default

def test_invalid_project_name():
    with pytest.raises(ValueError):
        ProjectRequirements(
            project_name="test pipeline with spaces",  # Invalid
            description="Test description"
        )
```

Run tests:
```bash
pytest tests/unit/test_project_requirements.py -v
```

---

## Step 4: Implement Requirements Parser (2 hours)

### 4.1 Create Requirements Parser

**File**: `src/agent/requirements_parser.py`

```python
from anthropic import Anthropic
from src.models.project_requirements import ProjectRequirements, FeatureType
import json

class RequirementsParser:
    def __init__(self, claude_client: Anthropic):
        self.client = claude_client

    def parse_natural_language(self, user_input: str) -> ProjectRequirements:
        """Parse natural language into structured requirements."""

        prompt = f"""Extract structured project requirements from this description:

        User Input: "{user_input}"

        Extract and return JSON with these fields:
        {{
            "project_name": "inferred name (alphanumeric, hyphens, underscores only)",
            "description": "clear 1-2 sentence description",
            "transformation_layers": ["bronze", "silver", "gold"],
            "optional_features": ["streaming", "monte_carlo", "data_validation", "testing"],
            "data_sources": ["list of mentioned data sources"]
        }}

        Infer values from context. For example:
        - "streaming pipeline" → optional_features includes "streaming"
        - "bronze/silver/gold" → transformation_layers includes all three
        - "Monte Carlo monitoring" → optional_features includes "monte_carlo"
        """

        response = self.client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=1024,
            messages=[{"role": "user", "content": prompt}]
        )

        # Parse JSON response
        parsed = json.loads(response.content[0].text)

        # Convert to Pydantic model (validates automatically)
        return ProjectRequirements(**parsed)
```

### 4.2 Test with Fixtures

**File**: `tests/unit/test_requirements_parser.py`

```python
import pytest
from unittest.mock import Mock
from src.agent.requirements_parser import RequirementsParser

@pytest.fixture
def mock_claude_client():
    """Mock Claude API responses."""
    client = Mock()

    # Mock streaming pipeline response
    client.messages.create.return_value = Mock(
        content=[Mock(text='{"project_name": "customer_events_pipeline", "description": "Streaming pipeline for customer events", "transformation_layers": ["bronze", "silver", "gold"], "optional_features": ["streaming"], "data_sources": ["Kafka"]}')]
    )

    return client

def test_parse_streaming_pipeline(mock_claude_client):
    parser = RequirementsParser(mock_claude_client)
    result = parser.parse_natural_language("I need a streaming pipeline for customer events")

    assert result.project_name == "customer_events_pipeline"
    assert "streaming" in result.optional_features
    assert "Kafka" in result.data_sources
```

---

## Step 5: Implement Project Generator (3 hours)

### 5.1 Create Directory Builder

**File**: `src/generators/directory_builder.py`

```python
from pathlib import Path
from typing import List

# From contracts/generated_project_structure.md
BASE_DIRECTORIES = [
    "src/",
    "pipelines/",
    "dashboards/",
    "databricks_apps/",
    "monte_carlo/",
    "data_validation/",
    "tests/",
    "config/",
    "docs/",
    "databricks/"
]

class DirectoryBuilder:
    def __init__(self, project_root: Path):
        self.project_root = project_root

    def create_standard_layout(self) -> List[Path]:
        """Create 9-directory standard layout."""
        created = []

        for dir_name in BASE_DIRECTORIES:
            dir_path = self.project_root / dir_name
            dir_path.mkdir(parents=True, exist_ok=True)
            created.append(dir_path)

            # Create __init__.py for Python packages
            if dir_name.endswith("/"):
                init_file = dir_path / "__init__.py"
                init_file.touch()

        return created
```

### 5.2 Create Config Generator

**File**: `src/generators/config_generator.py`

```python
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
import yaml

class ConfigGenerator:
    def __init__(self, templates_dir: Path):
        self.env = Environment(loader=FileSystemLoader(templates_dir))

    def generate_environment_config(
        self,
        output_path: Path,
        environment_name: str,
        config_values: dict
    ):
        """Generate environment-specific YAML config."""
        template = self.env.get_template("environment_config.yaml.j2")

        content = template.render(
            environment=environment_name,
            **config_values
        )

        output_path.write_text(content)
```

### 5.3 Test Generation

**File**: `tests/integration/test_project_generation.py`

```python
import pytest
from pathlib import Path
from src.generators.directory_builder import DirectoryBuilder, BASE_DIRECTORIES

def test_create_standard_layout(tmp_path):
    builder = DirectoryBuilder(tmp_path)
    created = builder.create_standard_layout()

    # Verify all 9 directories created
    assert len(created) == 9

    # Verify specific directories exist
    for dir_name in BASE_DIRECTORIES:
        assert (tmp_path / dir_name).exists()
```

---

## Step 6: Implement Validation (2 hours)

### 6.1 Create Structure Validator

**File**: `src/validation/structure_validator.py`

```python
from pathlib import Path
from typing import Dict, List
from src.generators.directory_builder import BASE_DIRECTORIES

class ValidationResult:
    def __init__(self, passed: bool, checks: List[Dict]):
        self.passed = passed
        self.checks = checks

class StructureValidator:
    def validate(self, project_path: Path) -> ValidationResult:
        """Validate 9-directory layout (FR-018)."""
        checks = []

        # Check all required directories exist
        missing = []
        for dir_name in BASE_DIRECTORIES:
            if not (project_path / dir_name).exists():
                missing.append(dir_name)

        checks.append({
            "name": "9-directory layout",
            "passed": len(missing) == 0,
            "details": f"Missing: {missing}" if missing else "All directories present"
        })

        # Check no extra root directories
        actual_dirs = [d.name for d in project_path.iterdir() if d.is_dir()]
        expected_dirs = [d.rstrip("/") for d in BASE_DIRECTORIES]
        extra = set(actual_dirs) - set(expected_dirs) - {".git", "venv"}

        checks.append({
            "name": "No extra root directories",
            "passed": len(extra) == 0,
            "details": f"Extra: {extra}" if extra else "No unexpected directories"
        })

        return ValidationResult(
            passed=all(c["passed"] for c in checks),
            checks=checks
        )
```

---

## Step 7: End-to-End Integration (2 hours)

### 7.1 Create Main Orchestrator

**File**: `src/generators/project_generator.py`

```python
from pathlib import Path
from src.agent.requirements_parser import RequirementsParser
from src.generators.directory_builder import DirectoryBuilder
from src.generators.config_generator import ConfigGenerator
from src.validation.structure_validator import StructureValidator

class ProjectGenerator:
    def __init__(self, requirements_parser, config_generator):
        self.requirements_parser = requirements_parser
        self.config_generator = config_generator

    def generate(self, requirements, output_dir: Path) -> dict:
        """Generate complete project from requirements."""

        # Step 1: Create directory structure
        builder = DirectoryBuilder(output_dir)
        builder.create_standard_layout()

        # Step 2: Generate configurations
        for env in requirements.environment_configs:
            config_path = output_dir / "config" / f"{env}.yaml"
            self.config_generator.generate_environment_config(
                config_path,
                env,
                {"project_name": requirements.project_name}
            )

        # Step 3: Validate structure
        validator = StructureValidator()
        validation_result = validator.validate(output_dir)

        return {
            "project_path": str(output_dir),
            "validation_passed": validation_result.passed,
            "validation_checks": validation_result.checks
        }
```

### 7.2 Create Integration Test

**File**: `tests/integration/test_end_to_end.py`

```python
import pytest
from pathlib import Path
from unittest.mock import Mock
from src.models.project_requirements import ProjectRequirements
from src.generators.project_generator import ProjectGenerator
from src.generators.config_generator import ConfigGenerator

def test_generate_simple_project(tmp_path):
    requirements = ProjectRequirements(
        project_name="test_pipeline",
        description="Test pipeline for customer data"
    )

    config_gen = ConfigGenerator(Path("templates"))
    generator = ProjectGenerator(None, config_gen)

    result = generator.generate(requirements, tmp_path / "test_pipeline")

    assert result["validation_passed"] == True
    assert (tmp_path / "test_pipeline" / "src").exists()
    assert (tmp_path / "test_pipeline" / "config" / "dev.yaml").exists()
```

---

## Step 8: Run Tests & Validate (30 minutes)

### 8.1 Run Full Test Suite

```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=src --cov-report=html

# View coverage report
open htmlcov/index.html
```

### 8.2 Manual Testing

```python
# Manual test script: test_manual.py
from anthropic import Anthropic
from src.agent.requirements_parser import RequirementsParser
from src.generators.project_generator import ProjectGenerator
from pathlib import Path

# Initialize
client = Anthropic()
parser = RequirementsParser(client)

# Parse requirements
requirements = parser.parse_natural_language(
    "I need a streaming pipeline for customer events with Monte Carlo monitoring"
)

# Generate project
generator = ProjectGenerator(parser, None)
result = generator.generate(requirements, Path("./output/customer_pipeline"))

print(f"✅ Project generated at: {result['project_path']}")
print(f"✅ Validation passed: {result['validation_passed']}")
```

Run:
```bash
python test_manual.py
```

---

## Step 9: Next Steps

After completing the quickstart:

1. **Implement Remaining Features**:
   - [ ] Feature module system (`src/features/`)
   - [ ] README generator with Mermaid diagrams
   - [ ] CI/CD workflow generation
   - [ ] Session analytics

2. **Run `/speckit.tasks`**:
   ```bash
   # Generate detailed task breakdown
   /speckit.tasks
   ```

3. **Implement tasks systematically** following the generated tasks.md

4. **Continuous Testing**:
   - Add tests for each new component
   - Maintain >80% code coverage
   - Use fixture-based mocks for Claude API

5. **Documentation**:
   - Keep README.md updated
   - Document API changes
   - Add inline code comments

---

## Common Issues & Solutions

### Issue: Claude API Rate Limits

**Solution**: Implement exponential backoff:
```python
import time
from anthropic import RateLimitError

def call_claude_with_retry(func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return func()
        except RateLimitError:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
            else:
                raise
```

### Issue: Pydantic Validation Errors

**Solution**: Add helpful error messages:
```python
try:
    requirements = ProjectRequirements(**data)
except ValidationError as e:
    print(f"❌ Validation failed: {e.json()}")
```

### Issue: Template Not Found Errors

**Solution**: Verify template paths:
```python
templates_dir = Path(__file__).parent.parent / "templates"
assert templates_dir.exists(), f"Templates directory not found: {templates_dir}"
```

---

## Resources

- **Specification**: [spec.md](./spec.md)
- **Implementation Plan**: [plan.md](./plan.md)
- **Research Decisions**: [research.md](./research.md)
- **Data Model**: [data-model.md](./data-model.md)
- **Contracts**: [contracts/](./contracts/)
- **Anthropic Docs**: https://docs.anthropic.com/claude/docs
- **Pydantic Docs**: https://docs.pydantic.dev/
- **Jinja2 Docs**: https://jinja.palletsprojects.com/
- **Databricks Asset Bundles**: https://docs.databricks.com/dev-tools/bundles/

---

## Success Criteria Checklist

Before considering implementation complete, verify all success criteria from spec.md:

- [ ] SC-001: Generate project in <5 minutes
- [ ] SC-002: 100% accuracy for requested features
- [ ] SC-003: <5 clarifying questions
- [ ] SC-004: 90% require zero manual changes
- [ ] SC-005: Analytics after 10+ projects
- [ ] SC-006: 4:1 user preference (post-launch)
- [ ] SC-007: All validation checks pass
- [ ] SC-008: 95% success rate for ambiguous requirements

---

**Quickstart Version**: 1.0.0
**Last Updated**: 2025-11-23
**Estimated Time**: 8-10 hours for core implementation
