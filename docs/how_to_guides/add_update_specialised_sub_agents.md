# How to add/update a specialised sub-agent

---

## 1. Prerequisites

The following should be sorted before starting.

| Prerequisite                                               | Details                                                                                                                                                                                                               |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Understanding of Claude agent                              | Specialised AI assistants with specific capabilities<br/>- [https://skyscanner.atlassian.net/wiki/x/voJ0ag](https://skyscanner.atlassian.net/wiki/x/voJ0ag)                                                           |
| Understanding the project structure                        | agentic-data-engineer-consumer repo is structured on Claude framework<br/>- Understanding of [Build with Claude Code](https://code.claude.com/docs/en/sub-agents)<br/>- Understanding of Spec Kit-driven architecture |
| Setup instructions followed                                | [https://skyscanner.atlassian.net/wiki/x/XAVsbQ](https://skyscanner.atlassian.net/wiki/x/XAVsbQ)                                                                                                                      |
| Understanding of context window                            | [https://platform.claude.com/docs/en/build-with-claude/context-windows?utm_source=chatgpt.com](https://platform.claude.com/docs/en/build-with-claude/context-windows?utm_source=chatgpt.com)                          |
| Discussed with the core group on the purpose of this agent | Skills required by this agent (includes MCP) and models this will use.<br/>[#agentic-data-engineer-maintainers-group](https://skyscanner.slack.com/archives/C0A4ZSD82B1)                                              |
| Agent structure requirements                               | name, description, tools, model, permission mode, skills                                                                                                                                                              |
| Agent template                                             | use claude-agent-template-generator.md for creating a sub-agent                                                                                                                                                       |
| Agent checklist                                            |                                                                                                                                                                                                                       |

---

## 2. Step-by-Step Creation Process

### Step 1: Define Agent Purpose

- Identify the specific problem domain or task category
- Define the scope and boundaries of the agent's responsibilities
- Ensure no overlap with existing agents

### Step 2: Choose Model Type

- **haiku**: Lightweight, fast tasks (template generation, simple formatting)
- **sonnet**: Most common - balanced performance (coding, validation, analysis)
- **opus**: Complex, reasoning-heavy tasks (architecture design, modeling decisions)

### Step 3: Create Agent File

- File location: `.claude/agents/shared/`
- Naming convention: `{purpose}-agent.md` (e.g., `data-naming-agent.md`)
- Use kebab-case for consistency

### Step 4: Understand Agent Folder Structure

Agents should be added to the correct location to ensure they are distributed to consumers and testable locally:

- **Distribution folder**: `src/agentic_data_engineer/.claude/agents/shared/`
  - This is the folder that gets distributed to consumers
  - All new agents must be created here
- **Testing symlink**: `agentic-data-engineer/.claude/`
  - The top-level `.claude` folder has a symlink to the `src` folder
  - This symlink allows us to test agents in the development environment
  - Testing is currently done manually (automated evaluation coming in the future)

**Important**: Always create agents in `src/agentic_data_engineer/.claude/agents/shared/`, not in the root `.claude` folder.

### Step 5: Write YAML Frontmatter

```yaml
name: {agent-name}
description: |
  Multi-line description of agent purpose
  Include what it creates/generates/validates
  Mention key capabilities
model: {haiku|sonnet|opus}
skills: {skill1}, {skill2}
```

### Step 6: Document Capabilities

- List 5-8 concrete capabilities
- Be specific about what the agent can do
- Use action verbs (Generate, Validate, Implement, Design, etc.)

### Step 7: Define Usage Patterns

- When to use this agent (bullet list)
- Trigger conditions
- Integration points with other agents

### Step 8: Add Examples

- Provide 3-5 realistic usage examples
- Use `<example>` tags wrapping:
  - Context description
  - User prompt
  - Assistant response with `<Task tool call to {agent-name}>`
- Cover different scenarios and edge cases

### Step 9: Write Full Agent Prompt

After the `---` delimiter, write comprehensive instructions:

- **Approach**: How the agent should work (numbered steps)
- **Guiding Principles**: Core values and standards to follow
- **Domain Knowledge**: Reference documentation paths (e.g., `kb://document/...`)
- **Success Criteria**: How to measure successful completion
- **Output Format**: Expected structure of results
- **When to Ask for Clarification**: Situations requiring user input

---

## 3. Integration & Testing

### Integration Points

- How to reference the agent in the main Task tool
- How the agent appears in the available agents list
- How other agents can invoke this agent

### Testing Approach

- Test the agent with realistic prompts
- Verify it follows instructions correctly
- Ensure it produces expected outputs
- Check that examples in the definition work

---

## 4. Best Practices

### Naming Conventions

- Agent name: `{purpose}-agent` (kebab-case)
- File name: matches agent name with `.md` extension
- Clear, descriptive names that indicate purpose

### Documentation Quality

- Be explicit and specific in instructions
- Include concrete examples, not abstract descriptions
- Reference knowledge base paths for domain context
- Use clear section headers and formatting

### Model Selection Guidelines

- Default to sonnet for most agents
- Use haiku only for simple, fast tasks
- Reserve opus for complex reasoning and architecture

### Skills Integration

- Only add skills the agent actually needs
- Available skills:
  - `mermaid-diagrams-skill`
  - `pdf-creator-skill`
  - `json-formatter-skill`
  - `dbdiagram-skill`
  - `recommend_silver_data_model-skill`

---

## 5. Troubleshooting

(Content to be added)

---

## 6. Additional Resources

(Content to be added)
