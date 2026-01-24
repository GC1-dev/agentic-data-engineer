---
name: claude-agent-template-generator
description: Generate fully valid Claude agent templates that follow the required YAML-frontmatter format. This skill creates new agent files in the correct structure with name, description, model, capabilities, examples, operating principles, and usage instructions. Use when generating new agents for projects, ensuring formatting correctness, or scaffolding multi-agent system components.
---

# Claude Agent Template Generator Skill

Generate fully valid Claude agent templates following the required YAML-frontmatter format.

## Overview

This skill creates Claude-compatible agent template files in the correct structure, ready to drop into `.claude/agents/shared/`. It ensures every output is minimal, clean, and properly formatted with all required sections.

## When to Use This Skill

Use this skill when you need to:

- ✅ Generate a new Claude agent template from scratch
- ✅ Create specialized agents (data engineering, QA, documentation, analytics, infrastructure, orchestrator)
- ✅ Ensure YAML-frontmatter structure is correct
- ✅ Scaffold multi-agent system components
- ✅ Standardize agent definitions across projects
- ✅ Create agents with proper examples and capabilities
- ✅ Add optional sections (Usage, Inputs, Outputs, Architecture)

## Capabilities

- Generate Claude-compatible agent templates
- Validate YAML-frontmatter structure
- Produce correct `<example>` blocks
- Create specialized agent templates:
  - Data Engineering agents
  - QA and testing agents
  - Documentation agents
  - Analytics agents
  - Infrastructure agents
  - Orchestrator agents
  - Custom domain-specific agents
- Customize capabilities, examples, and behaviors
- Add optional sections (Usage, Inputs, Outputs, Architecture, etc.)

## How to Invoke

You can invoke this skill directly or Claude will automatically suggest it when working with agent templates.

### Direct Invocation

```
/claude-agent-template-generator
```

### Automatic Detection

Claude will suggest this skill when you:
- Ask to create a new agent
- Request agent template generation
- Need to scaffold multi-agent systems
- Want to standardize agent definitions

## Examples

### Example 1: Generate Blank Template

**User**: "Generate a blank Claude agent template"

**Assistant**: "I'll use the claude-agent-template-generator skill to create a minimal agent template."

**Result**: Complete agent template with all required sections ready for customization.

---

### Example 2: Create Specialized Agent

**User**: "Create a code review agent"

**Assistant**: "I'll use the claude-agent-template-generator skill to create a code review agent."

**Result**: Agent template with code review-specific capabilities, examples, and usage instructions.

---

### Example 3: Data Engineering Agent

**User**: "Create a data-quality agent with examples for profiling, schema checks, and anomaly detection"

**Assistant**: "I'll use the claude-agent-template-generator skill to create a data quality agent."

**Result**: Agent template with data quality capabilities, profiling examples, schema validation, and anomaly detection patterns.

---

### Example 4: Orchestrator Agent

**User**: "Make an orchestrator agent that coordinates DE and documentation agents"

**Assistant**: "I'll use the claude-agent-template-generator skill to create an orchestrator agent."

**Result**: Agent template with orchestration capabilities, multi-agent coordination patterns, and workflow examples.

---

## Standard Template Structure

The skill generates agents following this structure:

```markdown
---
name: agent-name
description: |
  Brief description of what this agent does.

  Use this agent when you need to [specific use cases].

model: sonnet
---

## Capabilities
- List of what the agent can do
- Specific features and functions
- Domain expertise areas

## Usage
Use this agent whenever you want to [use case].

Ask it things like:

- "Example request 1"
- "Example request 2"
- "Example request 3"

<example>
Example 1: [Scenario Name]

User: [User request]
Agent: [Agent response with specific actions/recommendations]

[Optional explanation of approach or reasoning]
</example>

<example>
Example 2: [Another Scenario]

User: [Different request]
Agent: [Agent response]
</example>

## Operating Principles
- Principle 1: [Key operating principle]
- Principle 2: [Another principle]
- Principle 3: [Another principle]
```

## Required Sections

### 1. YAML Frontmatter
```yaml
---
name: agent-name
description: |
  Multi-line description of the agent.

  Include use cases and when to use this agent.

model: sonnet  # or opus, haiku
---
```

**Fields**:
- `name`: Kebab-case identifier (e.g., `data-quality-agent`)
- `description`: Multi-line description with use cases
- `model`: `sonnet` (default), `opus` (complex tasks), or `haiku` (simple tasks)

### 2. Capabilities Section
List what the agent can do:

```markdown
## Capabilities
- Specific capability 1
- Specific capability 2
- Domain expertise area 1
- Tool or technique the agent uses
```

### 3. Usage Section
Explain when and how to use the agent:

```markdown
## Usage
Use this agent whenever you want to [use case].

Ask it things like:

- "Example request 1"
- "Example request 2"
- "Example request 3"
```

### 4. Examples
Show concrete usage scenarios wrapped in `<example>` tags:

```markdown
<example>
Example 1: Scenario Name

User: [User request]
Agent: [Agent response]

[Optional: Explanation of approach]
</example>
```

### 5. Operating Principles (Optional)
List key principles the agent follows:

```markdown
## Operating Principles
- Principle 1: [Description]
- Principle 2: [Description]
- Principle 3: [Description]
```

## Agent Types and Templates

### Data Engineering Agent

```markdown
---
name: data-engineering-agent
description: |
  Process and transform data following best practices for data engineering.

  Use this agent for data pipeline development, ETL processes, and data modeling.

model: sonnet
---

## Capabilities
- Design data pipelines
- Write PySpark transformations
- Implement data quality checks
- Create data models
- Optimize query performance

## Usage
Use this agent for data engineering tasks like:

- "Design a Bronze to Silver transformation"
- "Create a data quality validation framework"
- "Optimize this Spark query"
```

### QA and Testing Agent

```markdown
---
name: qa-testing-agent
description: |
  Design and implement comprehensive test strategies and test cases.

  Use this agent for unit testing, integration testing, and test automation.

model: sonnet
---

## Capabilities
- Design test strategies
- Write unit tests
- Create integration tests
- Implement test fixtures
- Generate test data

## Usage
Use this agent for testing tasks like:

- "Write unit tests for this transformation"
- "Create integration test suite"
- "Generate test data for scenario X"
```

### Documentation Agent

```markdown
---
name: documentation-agent
description: |
  Create comprehensive documentation for code, APIs, and systems.

  Use this agent for technical writing, API docs, and user guides.

model: sonnet
---

## Capabilities
- Write technical documentation
- Generate API documentation
- Create architecture diagrams
- Write user guides
- Document code and functions

## Usage
Use this agent for documentation tasks like:

- "Document this API endpoint"
- "Create architecture diagram"
- "Write user guide for feature X"
```

### Orchestrator Agent

```markdown
---
name: orchestrator-agent
description: |
  Coordinate multiple specialized agents to complete complex workflows.

  Use this agent to manage multi-step processes involving different agents.

model: sonnet
---

## Capabilities
- Coordinate multiple agents
- Manage complex workflows
- Route tasks to specialized agents
- Aggregate results from multiple agents
- Handle dependencies between tasks

## Usage
Use this agent for complex tasks like:

- "Build a complete data pipeline from Bronze to Gold"
- "Create feature with code, tests, and documentation"
- "Implement end-to-end data quality framework"
```

## Example Patterns

### Simple Example
```markdown
<example>
Example 1: Basic Task

User: Write a function to calculate sum
Agent: I'll create a simple sum function:

```python
def calculate_sum(numbers):
    """Calculate sum of numbers."""
    return sum(numbers)
```

The function uses Python's built-in sum() for simplicity.
</example>
```

### Complex Example with Multiple Steps
```markdown
<example>
Example 2: Multi-Step Process

User: Create a data validation pipeline
Agent: I'll design a comprehensive validation pipeline:

1. **Schema Validation**
   - Check column names and types
   - Validate required fields

2. **Data Quality Checks**
   - Null value validation
   - Range checks for numeric fields
   - Pattern validation for strings

3. **Business Rule Validation**
   - Custom business logic checks
   - Cross-field validations

Implementation:
```python
def validate_pipeline(df):
    # Schema validation
    validate_schema(df)

    # Quality checks
    check_data_quality(df)

    # Business rules
    validate_business_rules(df)

    return validation_results
```

This approach ensures comprehensive validation at multiple levels.
</example>
```

### Example with Reasoning
```markdown
<example>
Example 3: Design Decision

User: Should I use a materialized view or a streaming table?
Agent: For your use case, I recommend a **materialized view**:

**Reasoning**:
- Your data updates hourly (not real-time requirement)
- Query patterns are read-heavy
- Aggregations are expensive to compute on-demand
- Historical data doesn't change

**Alternative**: Use streaming table if:
- You need real-time updates (< 1 minute latency)
- Source data arrives continuously
- Downstream consumers need immediate access

**Implementation**:
```sql
CREATE MATERIALIZED VIEW mv_hourly_metrics AS
SELECT
  date_trunc('hour', timestamp) as hour,
  COUNT(*) as event_count,
  AVG(value) as avg_value
FROM events
GROUP BY 1
```

Refresh schedule: `REFRESH EVERY 1 HOUR`
</example>
```

## Formatting Guidelines

### YAML Frontmatter
- **Required**: name, description, model
- **Optional**: version, author, tags
- Use `|` for multi-line descriptions
- Indent continuation lines by 2 spaces

### Markdown Structure
- Use `##` for main sections
- Use `###` for subsections
- Use `-` for bullet lists
- Use numbered lists `1.` for sequences
- Use ` ``` ` for code blocks with language identifier

### Example Blocks
- Always wrap in `<example>` tags
- Use `Example N: [Descriptive Name]` as title
- Show both User request and Agent response
- Include explanations when helpful
- Use code blocks for implementations

### Code Blocks
- Always specify language: ` ```python `, ` ```sql `, ` ```bash `
- Include comments for complex logic
- Show complete, runnable examples
- Use realistic variable names

### Naming Conventions
- Agent names: `kebab-case-agent`
- Section titles: `Title Case`
- Code identifiers: `snake_case` (Python) or `camelCase` (JS)

## Common Patterns

### Multi-Tool Agent
Agent that uses multiple tools or techniques:

```markdown
## Capabilities
- Use Tool A for task type 1
- Use Tool B for task type 2
- Combine Tools A and B for complex scenarios
- Fallback strategies when tools unavailable
```

### Specialized Domain Agent
Agent with deep expertise in specific domain:

```markdown
## Capabilities
- Domain-specific knowledge area 1
- Domain-specific technique 1
- Industry best practices
- Common patterns and anti-patterns
- Optimization strategies
```

### Workflow Coordination Agent
Agent that manages multi-step processes:

```markdown
## Capabilities
- Break complex tasks into steps
- Coordinate sub-tasks
- Handle dependencies
- Aggregate results
- Error handling and retries
```

## Quality Checklist

Before finalizing an agent template, verify:

- ✅ YAML frontmatter is valid
- ✅ Name uses kebab-case
- ✅ Description includes use cases
- ✅ Model is specified (sonnet/opus/haiku)
- ✅ Capabilities section lists specific capabilities
- ✅ Usage section shows example requests
- ✅ At least 2 examples wrapped in `<example>` tags
- ✅ Examples show realistic scenarios
- ✅ Code blocks have language identifiers
- ✅ Formatting is consistent
- ✅ No placeholder text (e.g., "TODO", "[fill this in]")
- ✅ File ends with closing marker (if applicable)

## Model Selection Guidelines

### Use `sonnet` (default) when:
- General-purpose tasks
- Balanced performance and cost
- Most common use case

### Use `opus` when:
- Highly complex reasoning required
- Critical decisions with high stakes
- Need for maximum capability
- Complex multi-step planning

### Use `haiku` when:
- Simple, straightforward tasks
- Fast response time needed
- Cost optimization important
- Task is well-defined and routine

## Best Practices

### Do's ✅
- Keep descriptions concise but informative
- Show realistic, practical examples
- Include code that actually works
- Explain design decisions when helpful
- Use consistent formatting throughout
- Add operating principles for complex agents
- Include edge cases in examples

### Don'ts ❌
- Don't use placeholder text
- Don't leave sections incomplete
- Don't use overly complex language
- Don't include broken code examples
- Don't skip the YAML frontmatter
- Don't forget `<example>` tags
- Don't use non-standard section names

## Success Criteria

A well-formatted agent template has:

- ✅ Valid YAML frontmatter with required fields
- ✅ Clear, specific capabilities
- ✅ Realistic usage examples
- ✅ At least 2 concrete examples in `<example>` tags
- ✅ Consistent formatting throughout
- ✅ Working code examples
- ✅ Appropriate model selection
- ✅ Complete sections (no TODOs)
- ✅ Ready to use without modification

## Output Location

Generated agents should be saved to:

```
.claude/agents/shared/[agent-name].md
```

Example:
```
.claude/agents/shared/data-quality-agent.md
.claude/agents/shared/code-review-agent.md
.claude/agents/shared/orchestrator-agent.md
```

---

**Remember**: A well-crafted agent template enables Claude to provide specialized, contextual assistance for specific domains and tasks. The template should be clear, complete, and immediately usable.