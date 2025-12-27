# Documentation Agent

## Overview

Create documentation, diagrams, and visual representations for data engineering projects.

## Agent Details

- **Name**: `documentation-agent`
- **Model**: Sonnet
- **Skills**: mermaid-diagrams-skill, pdf-creator-skill

## Capabilities

- Create technical documentation (architecture, API, runbooks)
- Generate mermaid diagrams (flow, sequence, ER, class diagrams)
- Document data flows through medallion layers
- Create architecture documentation with diagrams
- Write API documentation
- Generate runbooks for operational procedures
- Ensure light/dark mode compatibility (no colors)

## When to Use

- Create data flow diagrams (bronze → silver → gold)
- Document system architecture
- Write API documentation
- Create runbooks
- Generate Unity Catalog structure diagrams
- Document transformation dependencies
- Create visual representations

## Usage Examples

```
User: "Create diagram showing data flow from bronze to gold"
Agent: Creates mermaid diagram with layer flow

User: "Document the session processing pipeline architecture"
Agent: Creates comprehensive architecture docs with diagrams

User: "Draw Unity Catalog structure diagram"
Agent: Creates catalog organization diagram
```

## Key Features

- No hallucination - only documents actual code
- Light/dark mode compatible diagrams
- Multiple diagram types (flow, sequence, ER, class)
- Comprehensive API documentation
- Operational runbooks
- Architecture decision records

## Diagram Types

- **Flow diagrams**: Process flows, pipelines
- **Sequence diagrams**: API interactions, message flows
- **ER diagrams**: Database schemas, data models
- **Class diagrams**: Object models, code structure

## Best Practices

- Verify all information from actual code
- Use light/dark compatible diagrams
- Clear, concise documentation
- Include examples where appropriate
- Document decisions with rationale
- Save to appropriate locations

## Success Criteria

✅ Documentation is accurate
✅ Diagrams render correctly
✅ Light/dark mode compatible
✅ Saved to appropriate location
✅ Comprehensive and clear
✅ No hallucinated information

## Related Agents

- **Decision Documenter Agent**: Record decisions
- **Medallion Architecture Agent**: Understand patterns

---

**Last Updated**: 2025-12-26
