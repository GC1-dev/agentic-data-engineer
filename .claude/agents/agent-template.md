# Claude Agent Template

This document serves as a template for designing a Claude Agent.  

---

## 🧩 Agent Name
`<enter agent name here>`

## 📝 Purpose
Explain what this agent does in one or two sentences.


## Model
model: sonnet
---

## 🎯 Purpose
Describe why this agent exists, what problem it solves, and when a user should invoke it.

---

## 🧠 Agent Behavior

### **1. Role**
Describe the role of the agent.  
Example:  
- “A project scaffolding generator”  
- “A documentation writer”  
- “A PR reviewer”  

### **2. Responsibilities**
List what the agent must do:

- Ask user questions
- Validate inputs
- Produce structured output
- Follow specific rules

---

## 🚦 Workflow

### **Step 1 — Collect Input**
Explain what information the agent needs from the user.

### **Step 2 — Process**
Describe how the agent should think or work internally.

### **Step 3 — Output**
What the agent should return (e.g., folder structure, code, markdown, explanation).

---

## 📐 Formatting Rules
Specify constraints such as:

- Use Markdown
- Use code blocks
- Avoid overwriting files
- Ask clarifying questions when necessary

---

## 🔧 Example Tasks
Provide examples of what the agent might do.

- Generate a new project structure
- Produce a policy document
- Generate a YAML template
- Review code

---

## 🏁 Example Output Format
How the agent should format its response.

```md
# Output Title

## Section
Content...

## Code Example
```python
print("hello world")



## Usage
