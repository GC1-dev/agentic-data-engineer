"""
Skyscanner Agentic Data Engineer

All-in-one data engineering platform with Claude AI integration.
Provides access to Claude agents, schemas, and shared scripts for data engineering workflows.
"""

__version__ = "1.0.0"

from importlib import resources
from pathlib import Path


def get_resource_path(resource_path: str) -> Path:
    """
    Get the absolute path to a resource file included in the package.

    Args:
        resource_path: Relative path to the resource (e.g., 'schema/data_contract/example.json')

    Returns:
        Path object pointing to the resource file

    Examples:
        >>> schema_path = get_resource_path('shared_schema/data_contract/odcs/v3.1.0/odcs-json-schema-v3.1.0.skyscanner.schema.json')
        >>> agent_doc = get_resource_path('shared_agents_usage_docs/README-data-contract-agent.md')
        >>> script = get_resource_path('shared_scripts/activate-pyenv.sh')
    """
    return resources.files(__package__).joinpath(resource_path)


def list_resources(directory: str) -> list[Path]:
    """
    List all resources in a directory.

    Args:
        directory: Directory path relative to package root (e.g., 'shared_schema', 'shared_scripts')

    Returns:
        List of Path objects for files in the directory
    """
    resource_dir = resources.files(__package__).joinpath(directory)
    if resource_dir.is_dir():
        return sorted(resource_dir.iterdir())
    return []


__all__ = ["get_resource_path", "list_resources", "__version__"]
