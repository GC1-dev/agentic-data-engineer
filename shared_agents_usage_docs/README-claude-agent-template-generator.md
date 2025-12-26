# Claude Agent Template Generator

## Overview

The Claude Agent Template Generator creates fully valid Claude agent templates following the required YAML-frontmatter format. It scaffolds new agent files with proper structure, capabilities, examples, and documentation.

## Agent Details

- **Name**: `claude-agent-template-generator`
- **Model**: Haiku
- **Skills**: None

## Capabilities

- Generate Claude-compatible agent templates
- Validate YAML-frontmatter structure
- Produce correct example blocks wrapped in `<example>` tags
- Create specialized agent templates (Data Engineering, QA, Documentation, Analytics, Infrastructure, Orchestrator, etc.)
- Customize capabilities, examples, and behaviors
- Add optional sections (Usage, Inputs, Outputs, Architecture)

## When to Use

Use this agent whenever you need to:

- Create a new Claude agent file
- Generate a template for a specialized agent
- Ensure agent formatting correctness
- Scaffold new multi-agent system components
- Build custom agents for specific domains

## Usage Examples

### Example 1: Generate Blank Template

```
User: "Generate a blank Claude agent template"

Agent: Creates a minimal agent template with required YAML frontmatter and basic structure
```

### Example 2: Create Domain-Specific Agent

```
User: "Create a code review agent"

Agent: Generates a complete code review agent with capabilities, usage examples, and best practices
```

### Example 3: Create Orchestrator Agent

```
User: "Make an orchestrator agent that coordinates DE and documentation agents"

Agent: Creates an orchestrator agent that can invoke multiple specialized agents
```

### Example 4: Create Quality Agent

```
User: "Create a data-quality agent with examples for profiling, schema checks, and anomaly detection"

Agent: Generates a comprehensive data quality agent with specific capabilities and examples
```

## Output Format

The generated agent template includes:

```yaml
---
name: agent-name
description: |
  Multi-line description of the agent's purpose and capabilities.
  Use this agent when...
model: sonnet|haiku|opus
skills: skill1, skill2  # Optional
---
```

Followed by:

- **Capabilities** section listing what the agent can do
- **Usage** section with when to use guidance
- **Examples** section with `<example>` blocks
- **Approach** section with methodology
- **Best Practices** section
- **Success Criteria** section

## Template Structure

### Required Sections

1. **YAML Frontmatter**
   - `name`: Agent identifier (kebab-case)
   - `description`: Multi-line purpose description
   - `model`: sonnet, haiku, or opus

2. **Capabilities**
   - Bulleted list of what the agent can do
   - Specific, actionable capabilities

3. **Usage**
   - When to use this agent
   - Clear trigger scenarios

4. **Examples**
   - Wrapped in `<example>` tags
   - Include context, user input, and agent response
   - Show typical usage patterns

### Optional Sections

- **Approach**: Step-by-step methodology
- **Best Practices**: Guidelines and tips
- **Success Criteria**: What success looks like
- **Common Pitfalls**: What to avoid
- **Related Agents**: Links to other agents

## Agent Types

The generator can create various specialized agents:

### Data Engineering Agents
- Bronze/Silver/Gold layer agents
- ETL pipeline agents
- Data quality agents
- Schema design agents

### Quality Assurance Agents
- Test generation agents
- Validation agents
- Code review agents

### Documentation Agents
- Technical documentation generators
- API documentation agents
- Diagram generation agents

### Analytics Agents
- Dashboard builders
- SQL query generators
- Report automation agents

### Infrastructure Agents
- Deployment agents
- Configuration agents
- Monitoring setup agents

### Orchestrator Agents
- Multi-agent coordinators
- Workflow managers
- Task delegation agents

## Best Practices

### Naming
- Use kebab-case for agent names
- Be specific and descriptive
- Suffix with `-agent` for clarity

### Description
- Start with "Use this agent for..."
- Explain purpose clearly
- List key use cases

### Capabilities
- Be specific, not vague
- Use action verbs
- Focus on outcomes

### Examples
- Include realistic scenarios
- Show context before usage
- Demonstrate typical patterns
- Add commentary explaining why

### Model Selection
- **Haiku**: Fast, simple tasks (formatting, naming, templates)
- **Sonnet**: Complex reasoning (architecture, design, implementation)
- **Opus**: Most complex tasks (rare, specific use cases)

## Example Output

```yaml
---
name: data-validation-agent
description: |
  Use this agent for validating data quality, schema compliance, and business rules
  in data pipelines. Generates validation tests and quality checks.
model: sonnet
skills: json-formatter-skill
---

## Capabilities
- Validate schema compliance
- Generate data quality checks
- Create validation tests
- Profile data quality metrics
- Detect anomalies and outliers

## Usage
Use this agent when you need to:

- Validate data against schemas
- Check data quality metrics
- Generate validation test suites
- Profile data distributions
- Detect data anomalies

## Examples

<example>
Context: User needs to validate table schema
user: "Validate the user_session table schema"
assistant: "I'll use the data-validation-agent to check schema compliance."
<Task tool call>
</example>
```

## Integration

Generated agents can be:

1. **Saved** to `.claude/agents/shared/`
2. **Invoked** via Task tool
3. **Referenced** in other agents
4. **Customized** after generation

## Success Criteria

✅ Valid YAML frontmatter
✅ Required sections present
✅ Examples use correct `<example>` tags
✅ Capabilities are specific
✅ Description is clear
✅ Model selection is appropriate
✅ File is Claude-compatible
✅ Ready to drop into `.claude/agents/shared/`

## Tips

- Keep descriptions focused and clear
- Use real-world examples
- Specify capabilities precisely
- Choose the right model for the task
- Include usage guidance
- Add commentary in examples
- Test generated agents before deployment

## Related Agents

- All agents can benefit from this generator for consistency
- Use for extending the agent ecosystem
- Create project-specific agents

---

**Last Updated**: 2025-12-26
