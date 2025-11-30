# Python Project Structure Standards

## Standards Overview

This document defines the standard Python project structure and tooling:

- **Project Layout**: Src layout
- **Package Management**: Poetry
- **Build Configuration**: pyproject.toml (PEP 518/621 compliant)
- **Environment Configuration**: Pydantic Settings + .env files (12-factor app)
- **Documentation Style**: Google-style docstrings
- **Python Version**: 3.10+ (Databricks Runtime compatibility)

### Quick Start

```bash
# Create new project with Poetry and src layout
poetry new myproject --src
cd myproject

# Configure Poetry to use in-project virtualenvs
poetry config virtualenvs.in-project true

# Install dependencies
poetry install

# Add core dependencies (including configuration management)
poetry add pydantic pydantic-settings python-dotenv pyyaml
poetry add --group dev pytest ruff mypy

# Set up configuration
mkdir config
cp .env.example .env  # Create from example and customize

# Run commands
poetry run pytest
poetry run ruff check .
poetry run mypy src

# Activate virtual environment
poetry shell
```

## Standard Project Structure

```
project/
├── pyproject.toml          # Poetry configuration (PEP 518/621)
├── poetry.lock             # Poetry lock file
├── README.md
├── .gitignore
├── Makefile                # Build automation
├── .env.example            # Example environment variables (committed)
├── .env                    # Local environment variables (not committed)
├── config/                 # Environment-specific configs
│   ├── dev.yaml
│   ├── staging.yaml
│   └── prod.yaml
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── config.py       # Configuration management
│       └── module.py
└── tests/
    └── test_module.py
```

## Why This Standard?

### Src Layout Benefits
- Prevents import shadowing issues (local packages overriding installed versions)
- Enforces strict separation between source code and configuration
- Ensures consistency between development and production environments
- Only intended files are importable during editable installations
- Prevents configuration files from being exposed on the import path

### Poetry Benefits
1. **Dependency Resolution**: Deterministic dependency resolution with poetry.lock
2. **Simplified Workflow**: Single tool for dependency management, packaging, and publishing
3. **Virtual Environment Management**: Automatic creation and management of isolated environments
4. **Modern Standards**: Uses pyproject.toml (PEP 518/621) as single source of truth
5. **Dependency Groups**: Organize dependencies by purpose (dev, test, docs, etc.)
6. **Better Dependency Specifications**: Semantic versioning with clear constraints
7. **Publishing**: Built-in support for publishing to PyPI or private repositories

## Documentation Standards: Google-Style Docstrings

### Overview

Use **Google-style docstrings** for all Python code. This style is clean, readable, and well-supported by documentation tools like Sphinx.

### Basic Structure

```python
def function_name(param1: str, param2: int) -> bool:
    """Brief one-line summary.

    Optional detailed description that can span multiple lines.
    Provide context, behavior, and any important notes.

    Args:
        param1: Description of param1.
        param2: Description of param2.

    Returns:
        Description of return value.

    Raises:
        ValueError: When param2 is negative.
        TypeError: When param1 is not a string.

    Examples:
        >>> function_name("test", 42)
        True
    """
    pass
```

### Module Docstrings

```python
"""Module for data transformation utilities.

This module provides functions and classes for transforming raw data
into structured formats suitable for analysis.

Typical usage example:

    from mypackage import transforms
    result = transforms.clean_data(raw_df)
"""
```

### Class Docstrings

```python
class DataProcessor:
    """Processes and validates input data.

    This class handles data validation, cleaning, and transformation
    operations for incoming datasets.

    Attributes:
        config: Configuration settings for the processor.
        validator: Data validation instance.
        errors: List of validation errors encountered.

    Examples:
        >>> processor = DataProcessor(config)
        >>> result = processor.process(data)
    """

    def __init__(self, config: dict):
        """Initialize the DataProcessor.

        Args:
            config: Dictionary containing processor configuration.
                Must include 'validation_rules' key.

        Raises:
            ValueError: If config is missing required keys.
        """
        self.config = config
        self.errors = []
```

### Method Docstrings

```python
class Calculator:
    """Simple calculator class."""

    def add(self, a: float, b: float) -> float:
        """Add two numbers.

        Args:
            a: First number.
            b: Second number.

        Returns:
            Sum of a and b.
        """
        return a + b

    def divide(self, dividend: float, divisor: float) -> float:
        """Divide two numbers.

        Args:
            dividend: Number to be divided.
            divisor: Number to divide by.

        Returns:
            Result of division.

        Raises:
            ZeroDivisionError: If divisor is zero.

        Examples:
            >>> calc = Calculator()
            >>> calc.divide(10, 2)
            5.0
        """
        if divisor == 0:
            raise ZeroDivisionError("Cannot divide by zero")
        return dividend / divisor
```

### Property Docstrings

```python
class User:
    """User model class."""

    @property
    def full_name(self) -> str:
        """Get user's full name.

        Returns:
            Full name in "FirstName LastName" format.
        """
        return f"{self.first_name} {self.last_name}"

    @full_name.setter
    def full_name(self, value: str) -> None:
        """Set user's full name.

        Args:
            value: Full name in "FirstName LastName" format.

        Raises:
            ValueError: If value doesn't contain exactly two parts.
        """
        parts = value.split()
        if len(parts) != 2:
            raise ValueError("Full name must be 'FirstName LastName'")
        self.first_name, self.last_name = parts
```

### Type Hints and Docstrings

Type hints reduce the need for type documentation in docstrings:

```python
# Good: Type hints provide type information
def process_data(df: pd.DataFrame, threshold: float = 0.5) -> pd.DataFrame:
    """Process DataFrame by filtering based on threshold.

    Args:
        df: Input DataFrame to process.
        threshold: Minimum value for filtering (default: 0.5).

    Returns:
        Filtered DataFrame.
    """
    return df[df["value"] > threshold]

# Avoid: Redundant type information in docstring
def process_data(df: pd.DataFrame, threshold: float = 0.5) -> pd.DataFrame:
    """Process DataFrame by filtering based on threshold.

    Args:
        df (pd.DataFrame): Input DataFrame to process.  # Type already in hint
        threshold (float): Minimum value (default 0.5).  # Redundant
    """
    pass
```

### Generator and Iterator Docstrings

```python
def generate_batches(data: list[int], batch_size: int) -> Iterator[list[int]]:
    """Generate batches from data.

    Args:
        data: List of items to batch.
        batch_size: Size of each batch.

    Yields:
        List containing batch_size items (or fewer for last batch).

    Examples:
        >>> data = [1, 2, 3, 4, 5]
        >>> list(generate_batches(data, 2))
        [[1, 2], [3, 4], [5]]
    """
    for i in range(0, len(data), batch_size):
        yield data[i:i + batch_size]
```

### Context Manager Docstrings

```python
class DatabaseConnection:
    """Context manager for database connections.

    Examples:
        >>> with DatabaseConnection("localhost") as conn:
        ...     conn.execute("SELECT * FROM users")
    """

    def __enter__(self) -> "DatabaseConnection":
        """Enter the context manager.

        Returns:
            The database connection instance.
        """
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> bool:
        """Exit the context manager.

        Args:
            exc_type: Exception type if an error occurred.
            exc_val: Exception value if an error occurred.
            exc_tb: Exception traceback if an error occurred.

        Returns:
            False to propagate exceptions, True to suppress them.
        """
        self.disconnect()
        return False
```

### Pydantic Model Docstrings

```python
from pydantic import BaseModel, Field

class UserConfig(BaseModel):
    """User configuration model.

    Validates and stores user configuration settings with
    automatic type checking and validation.

    Attributes:
        username: User's unique identifier.
        email: User's email address.
        age: User's age (must be positive).
    """

    username: str = Field(..., min_length=3, description="User's unique identifier")
    email: str = Field(..., description="User's email address")
    age: int = Field(..., gt=0, description="User's age")

    def validate_email(self) -> bool:
        """Validate email format.

        Returns:
            True if email is valid, False otherwise.
        """
        return "@" in self.email
```

### Async Function Docstrings

```python
async def fetch_data(url: str, timeout: int = 30) -> dict:
    """Fetch data from a URL asynchronously.

    Args:
        url: URL to fetch data from.
        timeout: Request timeout in seconds (default: 30).

    Returns:
        Parsed JSON response as dictionary.

    Raises:
        asyncio.TimeoutError: If request exceeds timeout.
        aiohttp.ClientError: If request fails.

    Examples:
        >>> data = await fetch_data("https://api.example.com/data")
    """
    async with aiohttp.ClientSession() as session:
        async with session.get(url, timeout=timeout) as response:
            return await response.json()
```

### Docstring Best Practices

1. **Start with a brief summary**: One line describing what the function does
2. **Use imperative mood**: "Return the result" not "Returns the result"
3. **Be concise but complete**: Provide enough context without verbosity
4. **Document all parameters**: Even if they seem obvious
5. **Include examples**: Especially for complex functions
6. **Document exceptions**: List all exceptions that can be raised
7. **Keep type info in hints**: Don't duplicate type information in docstrings
8. **Update with code changes**: Keep docstrings in sync with implementation
9. **Use consistent terminology**: Maintain vocabulary across the codebase
10. **Add notes for side effects**: Document mutations, I/O, or state changes

### Tools Integration

Configure tools to work with Google-style docstrings:

**pyproject.toml:**
```toml
[tool.pydocstyle]
convention = "google"
add-ignore = ["D100", "D104"]  # Ignore missing docstrings in __init__.py

[tool.mypy]
# Require docstrings for public functions
disallow_untyped_defs = true
warn_return_any = true

[tool.ruff.lint.pydocstyle]
convention = "google"
```

## Environment-Specific Configuration Management

### Standard Approach: Pydantic Settings + .env Files

Following [12-factor app principles](https://12factor.net/config), use **pydantic-settings** for type-safe configuration management with environment variables.

#### Installation

```bash
poetry add pydantic-settings python-dotenv pyyaml
```

#### Configuration Structure

**File Organization:**
```
project/
├── .env.example            # Template (committed to git)
├── .env                    # Local overrides (NOT committed)
├── config/
│   ├── dev.yaml           # Development defaults
│   ├── staging.yaml       # Staging defaults
│   └── prod.yaml          # Production defaults
└── src/
    └── mypackage/
        └── config.py      # Settings classes
```

#### Implementation Pattern

**src/mypackage/config.py:**

```python
from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings with environment variable support.

    Environment variables take precedence over .env file values.
    """

    # Environment
    environment: Literal["dev", "staging", "prod"] = "dev"
    debug: bool = False

    # Application
    app_name: str = "mypackage"
    app_version: str = "0.1.0"

    # Database
    database_url: SecretStr = Field(
        ...,  # Required field
        description="Database connection string"
    )
    database_pool_size: int = Field(default=10, ge=1, le=100)

    # API Keys (use SecretStr for sensitive data)
    api_key: SecretStr | None = None
    openai_api_key: SecretStr | None = None

    # Paths
    data_dir: Path = Field(default=Path("data"))
    log_dir: Path = Field(default=Path("logs"))

    # Feature Flags
    enable_feature_x: bool = False

    @field_validator("data_dir", "log_dir")
    @classmethod
    def ensure_path_exists(cls, v: Path) -> Path:
        """Ensure directory exists.

        Args:
            v: Path to validate and create.

        Returns:
            The validated path.
        """
        v.mkdir(parents=True, exist_ok=True)
        return v

    model_config = SettingsConfigDict(
        # Load from .env file
        env_file=".env",
        env_file_encoding="utf-8",

        # Case-insensitive environment variables
        case_sensitive=False,

        # Prefix for environment variables
        env_prefix="MYAPP_",

        # Allow extra fields
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance.

    Uses lru_cache to ensure settings are loaded only once.
    """
    return Settings()


# Usage in application
settings = get_settings()
```

#### Environment Variable Files

**.env.example (committed to git):**
```bash
# Environment
MYAPP_ENVIRONMENT=dev
MYAPP_DEBUG=true

# Database
MYAPP_DATABASE_URL=postgresql://user:pass@localhost:5432/mydb

# API Keys (example values - replace with real keys)
MYAPP_API_KEY=your-api-key-here
MYAPP_OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxx

# Paths
MYAPP_DATA_DIR=./data
MYAPP_LOG_DIR=./logs

# Feature Flags
MYAPP_ENABLE_FEATURE_X=false
```

**.env (local, NOT committed):**
```bash
# Local development overrides
MYAPP_DATABASE_URL=postgresql://dev:devpass@localhost:5432/dev_db
MYAPP_DEBUG=true
MYAPP_OPENAI_API_KEY=sk-real-key-here
```

**.gitignore:**
```
# Environment variables
.env
.env.local
.env.*.local

# Keep example file
!.env.example
```

#### YAML Configuration Files (Optional)

For complex configurations, use YAML files with environment-specific overrides:

**config/base.yaml:**
```yaml
app:
  name: mypackage
  version: 0.1.0

logging:
  level: INFO
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

database:
  pool_size: 10
  timeout: 30
```

**config/dev.yaml:**
```yaml
app:
  debug: true

logging:
  level: DEBUG

database:
  pool_size: 5
```

**config/prod.yaml:**
```yaml
app:
  debug: false

logging:
  level: WARNING

database:
  pool_size: 20
  connection_lifetime: 3600
```

**Loading YAML configs with Pydantic:**

```python
import yaml
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    environment: str = "dev"
    # ... other fields ...

    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="MYAPP_",
    )

    @classmethod
    def from_yaml(cls, env: str = "dev") -> "Settings":
        """Load settings from YAML file and environment variables.

        Args:
            env: Environment name (dev/staging/prod).

        Returns:
            Settings instance with merged configuration.
        """
        config_dir = Path("config")

        # Load base config
        base_config = {}
        base_file = config_dir / "base.yaml"
        if base_file.exists():
            with open(base_file) as f:
                base_config = yaml.safe_load(f) or {}

        # Load environment-specific config
        env_file = config_dir / f"{env}.yaml"
        env_config = {}
        if env_file.exists():
            with open(env_file) as f:
                env_config = yaml.safe_load(f) or {}

        # Merge configs (env_config overrides base_config)
        merged_config = {**base_config, **env_config}

        # Flatten nested dicts for Pydantic
        flat_config = cls._flatten_dict(merged_config)

        # Create settings (env vars still take precedence)
        return cls(**flat_config)

    @staticmethod
    def _flatten_dict(d: dict, parent_key: str = "", sep: str = "_") -> dict:
        """Flatten nested dictionary.

        Args:
            d: Dictionary to flatten.
            parent_key: Parent key prefix for nested keys.
            sep: Separator for joining keys.

        Returns:
            Flattened dictionary with joined keys.
        """
        items = []
        for k, v in d.items():
            new_key = f"{parent_key}{sep}{k}" if parent_key else k
            if isinstance(v, dict):
                items.extend(
                    Settings._flatten_dict(v, new_key, sep=sep).items()
                )
            else:
                items.append((new_key, v))
        return dict(items)


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance.

    Loads settings from YAML files and environment variables.
    Uses lru_cache to ensure settings are loaded only once.

    Returns:
        Cached Settings instance.
    """
    import os
    env = os.getenv("MYAPP_ENVIRONMENT", "dev")
    return Settings.from_yaml(env)
```

#### Usage in Application

```python
from mypackage.config import get_settings

# Get settings (cached after first call)
settings = get_settings()

# Access configuration
print(f"Running in {settings.environment} mode")

# Sensitive data (use .get_secret_value() to access)
db_url = settings.database_url.get_secret_value()

# Use in FastAPI
from fastapi import FastAPI, Depends

app = FastAPI()

@app.get("/health")
def health_check(settings: Settings = Depends(get_settings)):
    return {
        "status": "healthy",
        "environment": settings.environment,
        "debug": settings.debug,
    }
```

#### Testing with Different Configs

```python
import pytest
from mypackage.config import Settings


def test_with_custom_settings():
    """Test Settings initialization with custom configuration.

    Verifies that Settings can be instantiated with test values
    and that all fields are properly set.
    """
    settings = Settings(
        environment="test",
        database_url="postgresql://test:test@localhost/test_db",
        debug=True,
    )

    assert settings.environment == "test"
    assert settings.debug is True


@pytest.fixture
def test_settings():
    """Provide test settings fixture.

    Returns:
        Settings instance configured for testing.
    """
    return Settings(
        environment="test",
        database_url="postgresql://test:test@localhost/test_db",
        api_key="test-key",
    )


def test_feature(test_settings):
    """Test feature using settings fixture.

    Args:
        test_settings: Settings fixture from conftest.
    """
    assert test_settings.environment == "test"
```

### Best Practices for Configuration

1. **Use Environment Variables for Secrets**: Never commit sensitive data
2. **Provide .env.example**: Document all required environment variables
3. **Use SecretStr for Sensitive Data**: Prevents accidental logging
4. **Validate Configuration**: Use Pydantic validators for business rules
5. **Cache Settings**: Use `@lru_cache` to load settings once
6. **Hierarchical Precedence**:
   - Environment variables (highest priority)
   - .env file
   - YAML config files
   - Default values (lowest priority)
7. **Use Type Hints**: Enable IDE autocomplete and type checking
8. **Document Defaults**: Clear documentation for all settings
9. **Fail Fast**: Required fields should raise errors at startup
10. **Environment-Specific Configs**: Use separate files for dev/staging/prod

### Configuration Precedence Example

```bash
# Priority (highest to lowest):
1. Environment variables:     MYAPP_DEBUG=true
2. .env file:                 MYAPP_DEBUG=false
3. YAML config file:          debug: false
4. Default in code:           debug: bool = False

# Result: debug = True (environment variable wins)
```

### Security Checklist

- [ ] .env files are in .gitignore
- [ ] .env.example contains no real secrets
- [ ] Sensitive values use SecretStr
- [ ] Secrets are never logged
- [ ] Production secrets use secret management (AWS Secrets Manager, Azure Key Vault, etc.)
- [ ] Database credentials are rotated regularly
- [ ] API keys have appropriate scopes/permissions

## Poetry Standard Configuration

### Complete pyproject.toml Example

```toml
[tool.poetry]
name = "mypackage"
version = "0.1.0"
description = "A brief description of the package"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
packages = [{include = "mypackage", from = "src"}]

[tool.poetry.dependencies]
python = "^3.10"
pydantic = "^2.0"
pyyaml = "^6.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4"
pytest-cov = "^4.1"
ruff = "^0.11"
mypy = "^1.7"

[tool.poetry.group.test.dependencies]
pytest = "^7.4"
pytest-mock = "^3.12"

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

# Tool configurations in the same file
[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
addopts = "-v --cov=src --cov-report=term-missing"

[tool.mypy]
python_version = "3.10"
mypy_path = "src"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.ruff]
src = ["src"]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
ignore = []

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
]
```

## Poetry Workflow Commands

### Initial Setup
```bash
# Install Poetry (if not already installed)
curl -sSL https://install.python-poetry.org | python3 -

# Initialize a new project with Poetry
poetry new mypackage --src

# Or configure Poetry in existing project
poetry init

# Configure Poetry to create virtual environments in project directory
poetry config virtualenvs.in-project true
```

### Development Workflow
```bash
# Install dependencies (creates/updates poetry.lock)
poetry install

# Add a new dependency
poetry add pydantic

# Add a development dependency
poetry add --group dev pytest ruff mypy

# Update dependencies
poetry update

# Activate virtual environment
poetry shell

# Run commands in the virtual environment
poetry run python -m mypackage
poetry run pytest
poetry run ruff check .

# Build package
poetry build

# Publish to PyPI (or private repository)
poetry publish
```

### Dependency Management
```bash
# Show dependency tree
poetry show --tree

# Show outdated packages
poetry show --outdated

# Export requirements.txt (for compatibility)
poetry export -f requirements.txt --output requirements.txt

# Lock dependencies without installing
poetry lock --no-update
```

## Common Patterns

### Adding Console Scripts

```toml
[tool.poetry.scripts]
myapp = "mypackage.cli:main"
myapp-admin = "mypackage.admin:main"
```

### Working with Local Dependencies

```toml
[tool.poetry.dependencies]
python = "^3.10"
my-shared-lib = {path = "../shared-lib", develop = true}
```

### Using Environment Markers

```toml
[tool.poetry.dependencies]
python = "^3.10"
# Only install on specific platforms
pywin32 = {version = "^305", markers = "sys_platform == 'win32'"}
```

### Multiple Python Versions

```toml
[tool.poetry.dependencies]
python = ">=3.10,<3.13"
```

Test with different versions:
```bash
poetry env use 3.10
poetry install
poetry run pytest

poetry env use 3.11
poetry install
poetry run pytest
```

## Migration from requirements.txt to Poetry

### Step 1: Initialize Poetry
```bash
poetry init
# Answer interactive prompts or use --no-interaction
```

### Step 2: Add Dependencies from requirements.txt
```bash
# Add runtime dependencies
cat requirements.txt | xargs -n 1 poetry add

# Add dev dependencies
cat requirements-dev.txt | xargs -n 1 poetry add --group dev
```

### Step 3: Configure Source Layout
```toml
[tool.poetry]
packages = [{include = "mypackage", from = "src"}]
```

### Step 4: Test and Verify
```bash
poetry install
poetry run pytest
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v5
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install Poetry
      uses: snok/install-poetry@v1
      with:
        version: 2.2.0
        virtualenvs-create: true
        virtualenvs-in-project: true

    - name: Load cached venv
      id: cached-poetry-dependencies
      uses: actions/cache@v4
      with:
        path: .venv
        key: venv-${{ runner.os }}-${{ matrix.python-version }}-${{ hashFiles('**/poetry.lock') }}

    - name: Install dependencies
      if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      run: poetry install --no-interaction --no-root

    - name: Install project
      run: poetry install --no-interaction

    - name: Run tests
      run: poetry run pytest --cov

    - name: Run linting
      run: poetry run ruff check .

    - name: Run type checking
      run: poetry run mypy src
```

## Makefile Integration

```makefile
.PHONY: help install test lint format clean

help:
	@echo "Available targets:"
	@echo "  install  - Install dependencies with Poetry"
	@echo "  test     - Run tests with coverage"
	@echo "  lint     - Run linting checks"
	@echo "  format   - Format code with ruff"
	@echo "  clean    - Remove build artifacts"

install:
	poetry install

test:
	poetry run pytest --cov --cov-report=html

lint:
	poetry run ruff check .
	poetry run mypy src

format:
	poetry run ruff format .
	poetry run ruff check --fix .

clean:
	rm -rf dist/ build/ *.egg-info .coverage htmlcov/ .pytest_cache/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
```

## Best Practices

1. **Always use src layout** for new projects
2. **Use Poetry** for dependency management and packaging
3. **Use pyproject.toml** for all tool configuration (single source of truth)
4. **Install in editable mode** during development: `poetry install`
5. **Configure tools** (pytest, mypy, ruff) in pyproject.toml
6. **Test imports** work correctly after installation
7. **Document** the installation requirement for contributors
8. **Use virtual environments** managed by Poetry
9. **Commit poetry.lock** to ensure reproducible builds
10. **Use dependency groups** to organize dependencies by purpose

## Summary

**Standard Stack:**
- **Layout**: Src layout for safety and reliability
- **Package Manager**: Poetry for dependency management and packaging
- **Configuration**: pyproject.toml as single source of truth (PEP 518/621)
- **Python Version**: 3.10+ (Databricks Runtime compatibility)

**Key Benefits:**
- Import shadowing protection via src layout
- Deterministic dependency resolution with Poetry
- Reproducible builds via poetry.lock
- Simplified development workflow
- Modern Python packaging standards

The combination of src layout and Poetry provides a robust, professional foundation for Python projects with excellent developer experience and production reliability.

## References

### Project Structure
- [Src Layout vs Flat Layout - Python Packaging Guide](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/)

### Documentation
- [Google Python Style Guide - Docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
- [PEP 257 - Docstring Conventions](https://peps.python.org/pep-0257/)
- [Sphinx Napoleon - Google Style](https://www.sphinx-doc.org/en/master/usage/extensions/napoleon.html)

### Configuration Management
- [Pydantic Settings Documentation](https://docs.pydantic.dev/latest/concepts/pydantic_settings/)
- [Settings Management - FastAPI](https://fastapi.tiangolo.com/advanced/settings/)
- [The Twelve-Factor App - Config](https://12factor.net/config)
- [All You Need to Know About Python Configuration with pydantic-settings 2.0+ (2025 Guide)](https://medium.com/@yuxuzi/all-you-need-to-know-about-python-configuration-with-pydantic-settings-2-0-2025-guide-4c55d2346b31)
- [Mastering Pydantic Settings: Clean and Reliable Environment Config](https://pvsravanth.medium.com/mastering-pydantic-settings-clean-and-reliable-environment-config-for-llm-systems-c89d52c602b0)
