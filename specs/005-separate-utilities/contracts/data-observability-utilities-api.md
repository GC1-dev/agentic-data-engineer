# API Contract: data-observability-utilities v1.0.0

**Package**: `data-observability-utilities`
**Version**: 1.0.0
**Status**: Stable
**Purpose**: Standalone Monte Carlo observability integration and monitoring for PySpark DataFrames

---

## Installation

```bash
pip install data-observability-utilities==1.0.0
```

**Dependencies**:
- Monte Carlo Data SDK >= 0.50.0
- PySpark >= 3.0.0

---

## Public API

### Top-Level Imports

All primary classes are exported from the top-level package:

```python
from data_observability_utilities import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig,
)
```

---

## Core Classes

### MonteCarloClient

**Purpose**: Wrapper around Monte Carlo SDK for observability operations

#### Constructor
```python
def __init__(
    self,
    api_key_id: str,
    api_key_secret: str,
    domain: str = "api.getmontecarlo.com"
)
```

**Parameters**:
- `api_key_id` (str): Monte Carlo API key ID
- `api_key_secret` (str): Monte Carlo API key secret
- `domain` (str): Monte Carlo API domain (default: "api.getmontecarlo.com")

**Example**:
```python
client = MonteCarloClient(
    api_key_id="YOUR_API_KEY_ID",
    api_key_secret="YOUR_API_KEY_SECRET"
)
```

---

#### create_monitor()
```python
def create_monitor(
    self,
    table_name: str,
    monitor_type: str,
    **monitor_params
) -> Dict[str, Any]
```

**Parameters**:
- `table_name` (str): Fully qualified table name
- `monitor_type` (str): Monitor type (e.g., "freshness", "volume", "schema")
- `**monitor_params`: Additional monitor-specific parameters

**Returns**: Dict with monitor creation response

**Example**:
```python
response = client.create_monitor(
    table_name="catalog.schema.users",
    monitor_type="freshness",
    max_age_hours=24
)
```

---

#### get_incident()
```python
def get_incident(self, incident_id: str) -> Dict[str, Any]
```

**Parameters**:
- `incident_id` (str): Monte Carlo incident ID

**Returns**: Dict with incident details

---

#### list_monitors()
```python
def list_monitors(self, table_name: Optional[str] = None) -> List[Dict[str, Any]]
```

**Parameters**:
- `table_name` (Optional[str]): Filter by table name (default: None for all)

**Returns**: List of monitor configurations

---

### MonteCarloIntegration

**Purpose**: High-level integration helpers for common Monte Carlo operations

#### Constructor
```python
def __init__(
    self,
    client: MonteCarloClient,
    default_warehouse: str,
    default_schema: str
)
```

**Parameters**:
- `client` (MonteCarloClient): Initialized Monte Carlo client
- `default_warehouse` (str): Default data warehouse name
- `default_schema` (str): Default schema name

**Example**:
```python
client = MonteCarloClient(api_key_id="...", api_key_secret="...")
integration = MonteCarloIntegration(
    client=client,
    default_warehouse="databricks",
    default_schema="production"
)
```

---

#### setup_table_monitoring()
```python
def setup_table_monitoring(
    self,
    table_name: str,
    enable_freshness: bool = True,
    enable_volume: bool = True,
    enable_schema: bool = True,
    freshness_max_age_hours: float = 24.0
) -> Dict[str, Any]
```

**Parameters**:
- `table_name` (str): Table name (schema inferred from default_schema)
- `enable_freshness` (bool): Enable freshness monitoring (default: True)
- `enable_volume` (bool): Enable volume monitoring (default: True)
- `enable_schema` (bool): Enable schema change monitoring (default: True)
- `freshness_max_age_hours` (float): Max data age in hours (default: 24.0)

**Returns**: Dict with created monitor IDs

**Example**:
```python
monitors = integration.setup_table_monitoring(
    table_name="users",
    enable_freshness=True,
    enable_volume=True,
    freshness_max_age_hours=24
)
```

---

#### check_table_health()
```python
def check_table_health(self, table_name: str) -> Dict[str, Any]
```

**Parameters**:
- `table_name` (str): Table name to check

**Returns**: Dict with health status and active incidents

**Example**:
```python
health = integration.check_table_health("users")
if health["status"] == "unhealthy":
    print(f"Active incidents: {health['incident_count']}")
```

---

### ObservabilityConfig

**Purpose**: Configuration for observability features

#### Constructor
```python
def __init__(
    self,
    monte_carlo_api_key_id: str,
    monte_carlo_api_key_secret: str,
    monte_carlo_domain: str = "api.getmontecarlo.com",
    default_warehouse: str = "databricks",
    default_schema: str = "production",
    enable_auto_monitoring: bool = True
)
```

**Parameters**:
- `monte_carlo_api_key_id` (str): Monte Carlo API key ID
- `monte_carlo_api_key_secret` (str): Monte Carlo API key secret
- `monte_carlo_domain` (str): Monte Carlo API domain (default: "api.getmontecarlo.com")
- `default_warehouse` (str): Default data warehouse name (default: "databricks")
- `default_schema` (str): Default schema name (default: "production")
- `enable_auto_monitoring` (bool): Auto-create monitors for new tables (default: True)

---

#### to_dict()
```python
def to_dict(self) -> Dict[str, Any]
```

**Returns**: Dict representation of configuration (secrets masked)

---

#### from_dict()
```python
@classmethod
def from_dict(cls, config: Dict[str, Any]) -> ObservabilityConfig
```

**Parameters**:
- `config` (Dict[str, Any]): Configuration dictionary

**Returns**: ObservabilityConfig instance

---

## Compatibility Guarantees

### API Stability
- **MAJOR version**: Breaking changes to public API
- **MINOR version**: New features, backward compatible
- **PATCH version**: Bug fixes, backward compatible

### Deprecation Policy
- Deprecated features marked 1 MINOR version before removal
- Deprecation warnings raised at runtime
- Migration guide provided in release notes

---

## Migration from databricks-shared-utilities

### Import Changes

**Before** (databricks-shared-utilities 0.2.0):
```python
from databricks_utils.observability import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig
)
```

**After** (data-observability-utilities 1.0.0):
```python
from data_observability_utilities import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig
)
```

### Breaking Changes
- **None**: All APIs preserved exactly
- **Only change**: Import paths (module names)

---

## Examples

### Complete Observability Setup

```python
from data_observability_utilities import (
    MonteCarloClient,
    MonteCarloIntegration,
    ObservabilityConfig,
)

# Configure observability
config = ObservabilityConfig(
    monte_carlo_api_key_id="YOUR_API_KEY_ID",
    monte_carlo_api_key_secret="YOUR_API_KEY_SECRET",
    default_warehouse="databricks",
    default_schema="production",
    enable_auto_monitoring=True
)

# Initialize client
client = MonteCarloClient(
    api_key_id=config.monte_carlo_api_key_id,
    api_key_secret=config.monte_carlo_api_key_secret,
    domain=config.monte_carlo_domain
)

# Create integration helper
integration = MonteCarloIntegration(
    client=client,
    default_warehouse=config.default_warehouse,
    default_schema=config.default_schema
)

# Set up table monitoring
monitors = integration.setup_table_monitoring(
    table_name="users",
    enable_freshness=True,
    enable_volume=True,
    enable_schema=True,
    freshness_max_age_hours=24
)

print(f"✅ Created {len(monitors)} monitors for users table")

# Check table health
health = integration.check_table_health("users")
if health["status"] == "healthy":
    print("✅ Table health: OK")
else:
    print(f"⚠️  Table health: {health['status']}")
    print(f"   Active incidents: {health['incident_count']}")
```

---

### Monitor-Specific Operations

```python
from data_observability_utilities import MonteCarloClient

client = MonteCarloClient(
    api_key_id="YOUR_API_KEY_ID",
    api_key_secret="YOUR_API_KEY_SECRET"
)

# Create freshness monitor
freshness_monitor = client.create_monitor(
    table_name="catalog.schema.orders",
    monitor_type="freshness",
    max_age_hours=6,
    alert_on_failure=True
)

# Create volume monitor
volume_monitor = client.create_monitor(
    table_name="catalog.schema.orders",
    monitor_type="volume",
    min_threshold=1000,
    max_threshold=1000000
)

# List all monitors for a table
monitors = client.list_monitors(table_name="catalog.schema.orders")
print(f"Found {len(monitors)} monitors")

# Get incident details
incident = client.get_incident(incident_id="INC-12345")
print(f"Incident: {incident['title']}")
print(f"Status: {incident['status']}")
print(f"Severity: {incident['severity']}")
```

---

## Security Considerations

### Credential Management
- **Never hardcode credentials** in source code
- Use environment variables or secret management systems
- Credentials are masked in `ObservabilityConfig.to_dict()`

**Example with environment variables**:
```python
import os
from data_observability_utilities import MonteCarloClient

client = MonteCarloClient(
    api_key_id=os.getenv("MONTE_CARLO_API_KEY_ID"),
    api_key_secret=os.getenv("MONTE_CARLO_API_KEY_SECRET")
)
```

---

## Support & Issues

- **Documentation**: [Package README](../../data-observability-utilities/README.md)
- **Monte Carlo Docs**: https://docs.getmontecarlo.com/
- **Issues**: Report bugs via GitHub Issues
- **Breaking Changes**: Follow semantic versioning (MAJOR.MINOR.PATCH)

---

**Contract Version**: 1.0.0
**Last Updated**: 2025-11-22
**Note**: API surface may expand in future minor versions as observability features are added. Current API represents initial stable interface migrated from databricks-shared-utilities.
