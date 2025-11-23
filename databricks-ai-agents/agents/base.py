"""
Base agent class with MCP (Model Context Protocol) support.

This module provides the foundational agent class that all specialized
agents inherit from.
"""

import os
from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Union
from pydantic import BaseModel, Field
from anthropic import Anthropic


class AgentError(Exception):
    """Raised when agent execution fails."""
    pass


class AgentInput(BaseModel):
    """Base model for agent inputs."""
    pass


class AgentOutput(BaseModel):
    """Base model for agent outputs."""
    status: str = Field(default="success", description="Execution status")
    warnings: List[str] = Field(default_factory=list, description="Non-fatal warnings")
    errors: List[str] = Field(default_factory=list, description="Error messages")


class AgentMetadata(BaseModel):
    """Agent execution metadata."""
    duration_ms: int
    tokens_used: int
    model_version: str
    validation_passed: bool = True


class BaseAgent(ABC):
    """
    Base class for all AI agents.

    Provides common functionality for:
    - API client management
    - Prompt loading and rendering
    - Response validation
    - Error handling
    - MCP (Model Context Protocol) support
    """

    def __init__(
        self,
        model: str = "claude-sonnet-4",
        temperature: float = 0.2,
        max_tokens: int = 4000,
        timeout_seconds: int = 300,
        api_key: Optional[str] = None
    ):
        """
        Initialize base agent.

        Args:
            model: AI model to use
            temperature: Sampling temperature (0.0-1.0)
            max_tokens: Maximum tokens in response
            timeout_seconds: Timeout for API calls
            api_key: Optional API key (defaults to ANTHROPIC_API_KEY env var)
        """
        self.model = model
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.timeout_seconds = timeout_seconds

        # Initialize Anthropic client
        api_key = api_key or os.getenv("ANTHROPIC_API_KEY")
        if not api_key:
            raise AgentError(
                "ANTHROPIC_API_KEY environment variable not set. "
                "Set it or pass api_key parameter."
            )

        self.client = Anthropic(api_key=api_key)

    @abstractmethod
    def invoke(self, inputs: Dict[str, Any]) -> Dict[str, Any]:
        """
        Invoke the agent with given inputs.

        Args:
            inputs: Agent-specific inputs

        Returns:
            Agent-generated outputs

        Raises:
            AgentError: If agent execution fails
        """
        pass

    @abstractmethod
    def validate_inputs(self, inputs: Dict[str, Any]) -> None:
        """
        Validate agent inputs.

        Args:
            inputs: Inputs to validate

        Raises:
            AgentError: If validation fails
        """
        pass

    @abstractmethod
    def get_prompt(self, inputs: Dict[str, Any]) -> str:
        """
        Generate prompt for the AI model.

        Args:
            inputs: Agent inputs

        Returns:
            Formatted prompt string
        """
        pass

    def call_model(
        self,
        prompt: str,
        system_message: Optional[str] = None
    ) -> str:
        """
        Call the AI model with given prompt.

        Args:
            prompt: User prompt
            system_message: Optional system message

        Returns:
            Model response text

        Raises:
            AgentError: If API call fails
        """
        try:
            messages = [{"role": "user", "content": prompt}]

            kwargs = {
                "model": self.model,
                "messages": messages,
                "temperature": self.temperature,
                "max_tokens": self.max_tokens,
            }

            if system_message:
                kwargs["system"] = system_message

            response = self.client.messages.create(**kwargs)

            # Extract text from response
            if response.content and len(response.content) > 0:
                return response.content[0].text

            raise AgentError("Empty response from model")

        except Exception as e:
            raise AgentError(f"Model API call failed: {str(e)}")

    def load_prompt_template(self, template_path: str) -> str:
        """
        Load prompt template from file.

        Args:
            template_path: Path to template file

        Returns:
            Template content

        Raises:
            AgentError: If template cannot be loaded
        """
        try:
            with open(template_path, 'r') as f:
                return f.read()
        except IOError as e:
            raise AgentError(f"Failed to load prompt template {template_path}: {e}")

    def render_prompt(self, template: str, **kwargs: Any) -> str:
        """
        Render prompt template with variables.

        Args:
            template: Prompt template string
            **kwargs: Variables to substitute

        Returns:
            Rendered prompt
        """
        try:
            return template.format(**kwargs)
        except KeyError as e:
            raise AgentError(f"Missing template variable: {e}")

    def validate_output(self, output: str) -> bool:
        """
        Validate agent output.

        Args:
            output: Output to validate

        Returns:
            True if valid, False otherwise

        Default implementation always returns True.
        Override in subclasses for specific validation.
        """
        return True

    def __str__(self) -> str:
        """String representation of agent."""
        return f"{self.__class__.__name__}(model={self.model})"

    def __repr__(self) -> str:
        """Detailed string representation."""
        return (
            f"{self.__class__.__name__}("
            f"model={self.model}, "
            f"temperature={self.temperature}, "
            f"max_tokens={self.max_tokens})"
        )
