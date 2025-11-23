"""
Model Context Protocol (MCP) server for IDE integration.

This module implements an MCP server that allows IDEs like Claude Code
and Cursor to interact with Databricks AI agents.
"""

import json
import sys
from typing import Any, Dict, List


class MCPServer:
    """
    MCP server for agent integration.

    Implements the Model Context Protocol to expose agents as tools
    that can be called from IDEs and other MCP clients.
    """

    def __init__(self):
        """Initialize MCP server."""
        self.tools = self._register_tools()

    def _register_tools(self) -> List[Dict[str, Any]]:
        """
        Register available tools (agents) with MCP.

        Returns:
            List of tool definitions
        """
        return [
            {
                "name": "init_project",
                "description": "Initialize a new Databricks pipeline project",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "name": {
                            "type": "string",
                            "description": "Project name"
                        },
                        "description": {
                            "type": "string",
                            "description": "Project description"
                        },
                        "owner_team": {
                            "type": "string",
                            "description": "Owning team name"
                        }
                    },
                    "required": ["name", "owner_team"]
                }
            },
            {
                "name": "generate_code",
                "description": "Generate PySpark transformation code",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "layer": {
                            "type": "string",
                            "enum": ["bronze", "silver", "gold"],
                            "description": "Medallion architecture layer"
                        },
                        "source": {
                            "type": "string",
                            "description": "Source path or table"
                        },
                        "target": {
                            "type": "string",
                            "description": "Target table"
                        },
                        "description": {
                            "type": "string",
                            "description": "Transformation description"
                        }
                    },
                    "required": ["layer", "source", "target", "description"]
                }
            },
            {
                "name": "generate_tests",
                "description": "Generate unit tests for transformation code",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "target_file": {
                            "type": "string",
                            "description": "File containing code to test"
                        },
                        "function_name": {
                            "type": "string",
                            "description": "Specific function to test (optional)"
                        }
                    },
                    "required": ["target_file"]
                }
            },
            {
                "name": "profile_data",
                "description": "Profile data and generate quality rules",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "table": {
                            "type": "string",
                            "description": "Table to profile"
                        }
                    },
                    "required": ["table"]
                }
            },
            {
                "name": "review_quality",
                "description": "Review code quality and best practices",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "file": {
                            "type": "string",
                            "description": "File to review"
                        }
                    },
                    "required": ["file"]
                }
            }
        ]

    def handle_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """
        Handle MCP request.

        Args:
            request: MCP request object

        Returns:
            MCP response object
        """
        method = request.get("method")

        if method == "tools/list":
            return {
                "tools": self.tools
            }
        elif method == "tools/call":
            tool_name = request.get("params", {}).get("name")
            tool_args = request.get("params", {}).get("arguments", {})
            return self._call_tool(tool_name, tool_args)
        else:
            return {
                "error": {
                    "code": -32601,
                    "message": f"Method not found: {method}"
                }
            }

    def _call_tool(self, tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """
        Call a tool (agent).

        Args:
            tool_name: Name of tool to call
            arguments: Tool arguments

        Returns:
            Tool result
        """
        # Placeholder - actual agent invocation will be implemented
        # when agents are completed in Phase 3 & 4
        return {
            "content": [
                {
                    "type": "text",
                    "text": f"Tool {tool_name} would be executed with args: {arguments}\n"
                            f"Note: Agent implementation pending in Phase 3/4"
                }
            ]
        }

    def serve(self) -> None:
        """
        Start serving MCP requests on stdin/stdout.

        This follows the MCP specification for stdio-based communication.
        """
        print("MCP Server started. Waiting for requests...", file=sys.stderr)

        for line in sys.stdin:
            try:
                request = json.loads(line)
                response = self.handle_request(request)
                print(json.dumps(response))
                sys.stdout.flush()
            except json.JSONDecodeError as e:
                error_response = {
                    "error": {
                        "code": -32700,
                        "message": f"Parse error: {str(e)}"
                    }
                }
                print(json.dumps(error_response))
                sys.stdout.flush()
            except Exception as e:
                error_response = {
                    "error": {
                        "code": -32603,
                        "message": f"Internal error: {str(e)}"
                    }
                }
                print(json.dumps(error_response))
                sys.stdout.flush()


def main():
    """Main entry point for MCP server."""
    server = MCPServer()
    server.serve()


if __name__ == "__main__":
    main()
