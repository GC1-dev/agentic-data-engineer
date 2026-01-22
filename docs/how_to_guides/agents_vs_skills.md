# Agents vs Skills: When to Use Which

## Overview

This guide helps you decide whether to create an **agent** or a **skill** for your data engineering automation needs. Understanding the distinction is critical for building an effective AI-native data engineering toolkit.

## Quick Decision Tree

```
Is this providing advice, guidance, or recommendations?
├─ YES → Create an AGENT
│   └─ Examples: naming advice, modeling guidance, architecture decisions
│
└─ NO → Is this performing actions or providing reference documentation?
    ├─ Performing actions (formatting, linting, generating code)
    │   └─ Create a SKILL
    │
    └─ Reference documentation (library usage, patterns, examples)
        └─ Create a SKILL
```

## Agents

### What Are Agents?

Agents are **specialized consultants** that Claude invokes via the Task tool when it needs expert guidance or recommendations. They provide contextual advice, make decisions, and help with complex analysis.

### Characteristics

- **Claude-invocable**: Claude calls them using the Task tool with `subagent_type`
- **Advisory**: Provide guidance, recommendations, and decisions
- **Consultative**: Help analyze situations and choose approaches
- **Context-aware**: Consider multiple factors before recommending
- **Research-focused**: May explore codebase, gather context, analyze options

### When to Create an Agent

Create an agent when you need to:

- ✅ Provide naming recommendations based on conventions
- ✅ Give architectural guidance and trade-off analysis
- ✅ Recommend data modeling approaches
- ✅ Analyze code and suggest improvements
- ✅ Find and recommend source tables or data assets
- ✅ Make context-dependent decisions
- ✅ Answer "what should I do?" questions
- ✅ Provide expert consultation on complex topics

### Typical Agent Workflow

```
1. User asks: "What should I name this Silver table for sessions?"
2. Claude: "I'll use the data-naming-agent to determine the appropriate name"
3. Agent: Analyzes context, applies conventions, provides recommendation
4. Claude: Presents recommendation to user with rationale
```

### Agent Examples in This Codebase

| Agent | Purpose |
|-------|---------|
| `data-naming-agent` | Provides naming recommendations for tables, columns, schemas |
| `dimensional-modeling-agent` | Guides gold layer dimensional modeling design |
| `medallion-architecture-agent` | Architectural guidance for medallion layers |
| `bronze-table-finder-agent` | Recommends source tables for Silver definitions |
| `silver-data-modeling-agent` | Entity-centric modeling guidance for Silver layer |
| `unity-catalog-agent` | Unity Catalog navigation and metadata analysis |
| `transformation-validation-agent` | Validates transformations against standards |
| `project-structure-agent` | Validates project structure compliance |

### Agent File Structure

```markdown
---
name: data-naming-agent
description: |
  Use this agent for naming tables, columns, schemas, or catalogs following medallion architecture
  and Unity Catalog naming conventions.
model: sonnet
---

## Capabilities
- List what the agent can do

## Usage
Use this agent when you need to:
- Specific use cases

## Examples
<example>
Context: Description of scenario
user: "User question"
assistant: "I'll use the naming-agent to determine..."
<Task tool call to naming-agent>
</example>

---

[Detailed instructions for the agent...]
```

## Skills

### What Are Skills?

Skills are **executable tools** that users can directly invoke or that Claude automatically uses to perform specific actions or provide reference documentation.

### Characteristics

- **User-invocable**: Users can run them directly with `/skill-name`
- **Action-oriented**: Perform specific tasks (format, lint, generate)
- **Reference-focused**: Provide documentation and examples for libraries
- **Deterministic**: Execute clear, defined operations
- **Self-contained**: Have specific inputs and outputs

### When to Create a Skill

Create a skill when you need to:

- ✅ Format files according to standards (Makefile, pyproject.toml)
- ✅ Lint and validate code against rules
- ✅ Generate code, tests, or documentation
- ✅ Provide library reference documentation
- ✅ Show usage patterns and examples for utilities
- ✅ Perform automated transformations
- ✅ Execute standardization procedures
- ✅ Answer "how do I use X?" questions

### Skill Categories

#### 1. Action Skills (Perform Tasks)

These skills execute specific operations:

| Skill | Action Performed |
|-------|------------------|
| `makefile-formatter-skill` | Standardizes Makefiles to team conventions |
| `pyproject-formatter-skill` | Formats pyproject.toml files |
| `project-linter-skill` | Validates code quality with ruff, pytest, YAML linters |
| `data-transformation-testing-skill` | Generates comprehensive PySpark test suites |
| `json-formatter-skill` | Formats, validates, and manipulates JSON data |

#### 2. Reference Skills (Provide Documentation)

These skills document how to use libraries and tools:

| Skill | Documentation Provided |
|-------|------------------------|
| `skyscanner-data-shared-utils-skill` | PySpark data transformation utilities documentation |
| `skyscanner-spark-session-utils-skill` | Spark session management utilities reference |
| `mermaid-diagrams-skill` | Diagram creation syntax and examples |
| `dbdiagram-skill` | Database diagram DBML syntax reference |

### Typical Skill Workflow

#### Direct Invocation
```
1. User: "Run /makefile-formatter-skill"
2. Skill: Executes, formats Makefile
3. Claude: Reports results to user
```

#### Automatic Detection
```
1. User: "How do I use read_table from data-shared-utils?"
2. Claude: Automatically invokes skyscanner-data-shared-utils-skill
3. Skill: Provides documentation and examples
4. Claude: Presents formatted documentation
```

### Skill File Structure

```markdown
---
skill_name: makefile-formatter-skill
description: |
  Standardize Makefiles according to conventions with proper
  structure, documentation, and POSIX compatibility.
version: 1.0.0
author: Skyscanner Data Engineering
tags:
  - makefile
  - build
  - formatting
---

# Skill Name

## What This Skill Does
Clear description of functionality

## When to Use This Skill
Use this skill when you need to:
- Specific use cases

## Capabilities
- List of capabilities

## How to Invoke

### Direct Invocation
```
/skill-name
```

### Automatic Detection
Claude will suggest this skill when you:
- Trigger conditions

## Examples

### Example 1: Description
**User**: "User request"
**Assistant**: "I'll use the skill..."
**Result**: What happens

---

[Detailed documentation, patterns, examples...]
```

## Key Differences Summary

| Aspect | Agents | Skills |
|--------|--------|--------|
| **Invocation** | Claude via Task tool | User via `/skill-name` or auto-detect |
| **Purpose** | Advisory & guidance | Action or reference |
| **Output** | Recommendations, analysis | Formatted files, code, documentation |
| **Decision-making** | Yes - contextual decisions | No - deterministic execution |
| **Interaction** | "What should I do?" | "Do this" or "How do I use X?" |
| **Location** | `.claude/agents/shared/` | `.claude/skills/` |
| **Model** | Usually `haiku` for cost efficiency | Inherits from parent |

## Common Mistakes

### ❌ Wrong: Creating a Skill for Advice

```markdown
# DON'T DO THIS
skill_name: naming-advisor-skill
description: Recommends names for tables and columns
```

**Why wrong**: This provides advice, not actions. Should be an agent.

**Correct approach**: Create `data-naming-agent` that Claude invokes when naming guidance is needed.

---

### ❌ Wrong: Creating an Agent for Formatting

```markdown
# DON'T DO THIS
name: makefile-formatter-agent
description: Use this agent to format Makefiles
```

**Why wrong**: Formatting is a deterministic action, not advisory. Should be a skill.

**Correct approach**: Create `makefile-formatter-skill` that users invoke directly.

---

### ❌ Wrong: Creating an Agent for Library Documentation

```markdown
# DON'T DO THIS
name: spark-utils-documentation-agent
description: Use this agent to learn about spark-session-utils
```

**Why wrong**: This is reference documentation, not advice. Should be a skill.

**Correct approach**: Create `skyscanner-spark-session-utils-skill` with usage examples.

## Decision Framework

### Questions to Ask

1. **Is this providing recommendations or making decisions?**
   - YES → Agent
   - NO → Continue

2. **Is this performing a deterministic action (format, lint, generate)?**
   - YES → Action Skill
   - NO → Continue

3. **Is this providing reference documentation for a library or tool?**
   - YES → Reference Skill
   - NO → Consider if this belongs in the toolkit

### Gray Areas

#### "How should I structure my tests?"

This could be either:
- **Agent**: If it requires analyzing existing code and recommending test architecture
- **Skill**: If it generates standard test patterns based on templates

**Rule of thumb**: If multiple valid approaches exist and context matters → Agent

#### "Generate a data contract"

This could be either:
- **Agent**: If it requires analyzing tables, inferring schemas, making quality decisions
- **Skill**: If it follows a template with user-provided specifications

**Rule of thumb**: If it generates standard output from clear inputs → Skill

## Best Practices

### For Agents

1. **Focus on expertise**: Agents should be subject matter experts
2. **Provide rationale**: Always explain why a recommendation was made
3. **Consider context**: Use available tools to gather information
4. **Offer alternatives**: Present multiple options when applicable
5. **Use haiku model**: Cost-effective for most advisory tasks

### For Skills

1. **Clear scope**: Skills should do one thing well
2. **Complete documentation**: Reference skills need comprehensive examples
3. **Self-contained**: All necessary information in the skill file
4. **Version tracking**: Include version numbers for action skills
5. **User-friendly**: Write for developers who will invoke directly

## Testing Your Decision

### Test 1: The Invocation Test

How would this be used?

```
User: "/format-makefile"           → Skill (direct invocation)
User: "What should I name this?"   → Agent (advisory request)
User: "How do I use read_table()?" → Skill (reference documentation)
```

### Test 2: The Output Test

What does it produce?

```
Formatted file                     → Skill
Recommendation with rationale      → Agent
Code examples and usage patterns   → Skill
Architectural guidance             → Agent
```

### Test 3: The Dependency Test

Does it depend on context?

```
High context dependency            → Likely Agent
Low context dependency             → Likely Skill
Deterministic transformation       → Definitely Skill
```

## Migration Guide

### Converting Agent to Skill

If you discover an agent that should be a skill:

1. Move from `.claude/agents/shared/` to `.claude/skills/<skill-name>/`
2. Rename file from `agent-name.md` to `SKILL.md`
3. Update frontmatter:
   ```yaml
   # Change from:
   name: example-agent
   description: ...
   model: haiku

   # To:
   skill_name: example-skill
   description: ...
   version: 1.0.0
   author: ...
   tags: [...]
   ```
4. Add "How to Invoke" section with `/skill-name` invocation
5. Restructure as action or reference documentation

### Converting Skill to Agent

If you discover a skill that should be an agent:

1. Move from `.claude/skills/` to `.claude/agents/shared/`
2. Rename file to `agent-name.md`
3. Update frontmatter:
   ```yaml
   # Change from:
   skill_name: example-skill
   version: 1.0.0
   ...

   # To:
   name: example-agent
   description: ...
   model: haiku
   ```
4. Add agent examples showing Task tool invocation
5. Focus content on guidance rather than execution

## Examples from This Codebase

### Correctly Categorized Agents

```markdown
✅ data-naming-agent
   → Provides naming advice based on conventions and context

✅ dimensional-modeling-agent
   → Guides dimensional modeling decisions for gold layer

✅ medallion-architecture-agent
   → Architectural guidance across medallion layers
```

### Correctly Categorized Skills

```markdown
✅ makefile-formatter-skill
   → Formats Makefiles according to standards

✅ skyscanner-data-shared-utils-skill
   → Documents how to use the data-shared-utils library

✅ project-linter-skill
   → Validates code quality with automated linters
```

## Summary

| When You Need... | Create... | Example |
|-----------------|-----------|---------|
| Advice on what to do | Agent | "What should I name this table?" |
| Automated file formatting | Action Skill | "Format this Makefile" |
| Library usage documentation | Reference Skill | "How do I use read_table()?" |
| Architectural guidance | Agent | "Should this be Silver or Gold?" |
| Code generation | Action Skill | "Generate tests for this transform" |
| Contextual recommendations | Agent | "Which Bronze table should I use?" |
| Standards validation | Action Skill | "Lint my code" |

---

**Remember**: Agents provide **guidance**, skills provide **execution** or **reference**. When in doubt, ask: "Am I helping decide what to do (agent) or helping do it (skill)?"