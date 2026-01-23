# How to add/update principles to Speckit Constitution

---

## 1. What Constitution Means in Spec-Driven Development

In Spec-Driven Development, a **Constitution** is a **project-wide governance document** that defines **project's core principles, rules and standards** which guide the rest of the development workflow. It lives alongside and *above* individual feature specifications, and it constrains how AI agents and developers make decisions throughout the project life cycle.

A Constitution typically includes:

- **Core principles** for development (e.g., "natural language first", "test-first and field validated")
- **Architecture & tech stack choices**
- **Code quality standards and rules**
- **Testing requirements and policies**
- **Performance, security, and compliance constraints**
- **Governance and amendment process**

The **Project Constitution** is established *before any feature work begins*. To create it, you run the Spec Kit command ([https://deepwiki.com/github/spec-kit/4.2-speckit.constitution-command#purpose-and-overview](https://deepwiki.com/github/spec-kit/4.2-speckit.constitution-command#purpose-and-overview)):

```bash
/speckit.constitution <principles-description>
```

This command takes your description of core project values and guidelines (e.g., quality standards, testing requirement, architectural constraints) and generates a persistent Constitution file.

The Constitution is stored persistently in the project's memory (e.g., `.specify/memory/constitution.md`). This file becomes **institutional memory** — AI agents and tooling reference it at every stage (specification, planning, task breakdown, implementation) to ensure consistent decision-making aligned with your project's values and constraints.

---

## 2. Prerequisites for updating the Constitution

Updating the Constitution is a **governance change**, not routine documentation. Before making a change, the following prerequisites should be met.

| Requirements                                      | Details                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A Constitution Already Exists                     | The Constitution **MUST** exist at `.specify/memory/constitution.md`. If it does not exist, the correct action is to create one, not update it.                                                                                                                                                                                                                                                                                |
| Change is cross-cutting                           | A Constitution update is appropriate **only if the change affects multiple features** or future work.                                                                                                                                                                                                                                                                                                                          |
| Governance-level rules                            | The change belongs in the Constitution if it defines:<br/>- Architectural constraints<br/>- Testing philosophy or quality bars<br/>- Language / platform standards<br/>- Security, performance, or compliance rules<br/>- Spec-writing or acceptance-criteria conventions<br/><br/>The change does not belong to constitution if the change applies to:<br/>- a single feature<br/>- a one-off exception<br/>- a temporary experiment |
| Defines *how*, not *what*                         | The Constitution defines **how** work is done and decisions are made — **not** what features should be built or prioritized.                                                                                                                                                                                                                                                                                                   |
| Rule is stable and intentional                    | The rule should not be:<br/>- Not speculative<br/>- Not exploratory<br/>- Unlikely to be reverted soon                                                                                                                                                                                                                                                                                                                        |
| Proven over time                                  | Before updating, the principle should have demonstrated stability, for example:<br/>- Applied successfully across **2–3 implemented features**, or<br/>- Reached **explicit team consensus** and remained unchanged for a defined period (e.g. multiple iterations or releases).                                                                                                                                              |
| Alignment With Existing Constitution Principles   | Before updating, you should verify that the change:<br/>- Does not contradict existing principles<br/>- Does not silently weaken stronger rules<br/>- Explicitly resolves conflicts if they exist                                                                                                                                                                                                                             |
| Change Can Be Expressed Normatively               | Constitution rules must be written in **normative, enforceable language** (e.g. MUST / SHOULD / MAY).                                                                                                                                                                                                                                                                                                                          |
| Updated Amendment history                         | Track constitutional changes as Amendment History ([https://deepwiki.com/github/spec-kit/4.2-speckit.constitution-command#amendment-tracking-best-practices](https://deepwiki.com/github/spec-kit/4.2-speckit.constitution-command#amendment-tracking-best-practices))                                                                                                                                                          |
| Deliberate and explicit review                    | Constitution updates SHOULD require:<br/>- Deliberate review<br/>  - Explicit acknowledgement of impact<br/>  - Clear documentation of what changed and why<br/><br/>Even small wording changes can have **large downstream effects** on AI-generated work.                                                                                                                                                                   |
| Version bumps reviewed manually                   | Version changes should always be reviewed manually, as Constitution changes can have wide downstream impact.<br/>- Adding a new principle → **MINOR** version bump<br/>- Removing or redefining an existing principle → **MAJOR** version bump<br/>- Clarifying language without changing intent → **PATCH** version bump                                                                                                      |
| Use the right artefact                            | If the change does not meet the above criteria, document it elsewhere:<br/>1. **ADRs** – One-time architectural decisions<br/>2. **Feature specs** – Feature-specific behavior and constraints<br/>3. **README / docs** – Usage patterns and non-normative guidance                                                                                                                                                           |

---

## 3. How to update the Constitution

To update the Constitution, run the command:

```bash
/speckit.constitution <description of the change>

Example to update the constitution:
/speckit.constitution Add a new principle about lakeflow declarative pipeline
```

You should explicitly describe the principle or rule you want to add, modify, or clarify. Constitution updates are intentional governance changes and should not rely on implicit inference.

**What happens when you run the command:**

1. The agent loads the existing Constitution from `.specify/memory/constitution.md`.
2. It applies targeted updates based on:
   - your input
   - the existing Constitution content
   - limited supporting context from the repository (e.g., README, docs).
3. The agent updates or adds principles using normative language.
4. If versioning metadata exists, it may be updated and should be reviewed.
5. The updated Constitution is written back to `.specify/memory/constitution.md`.

**Important:**
Changes to the Constitution influence all future specification, planning, tasking, and implementation steps, but they do not automatically modify existing specs, plans, or templates.

---

## 4. How to Test That a Changed Constitution Works

Testing a Constitution is about verifying **governance effects**, not code correctness alone. A Constitution works if it **changes how specs, plans, tasks, and implementations are produced** in predictable, intended ways.

---

### a. Constitution Diff Review (Baseline Test)

**Goal:** Verify the change is intentional, scoped, and unambiguous.

Before running any downstream workflows:

- Review the diff of `.specify/memory/constitution.md`
- Confirm:
  - Only the intended principles changed
  - Language is normative (MUST / SHOULD / MAY)
  - No unintended weakening of existing rules

**Failure signal:**
Reviewers cannot agree what the new rule requires.

---

### b. Spec Generation Test (Primary Test)

**Goal:** Verify that new specs reflect the updated Constitution.

#### How to run

Generate a new feature spec **after** the Constitution update (real or hypothetical):

- Pick a feature that **should be affected** by the change
- Run your normal spec-generation workflow

#### What to check

- The spec **explicitly reflects the new principle**
- Constraints introduced by the Constitution are:
  - present
  - correctly scoped
  - not overridden or ignored

**Failure signal:**
The generated spec violates or omits a Constitution MUST-level rule.

---

### c. Negative Spec Test (Guardrail Test)

**Goal:** Ensure the Constitution actively rejects invalid specs.

#### How to run

Intentionally propose or generate a spec that:

- Violates the new Constitution rule
- Uses old assumptions the rule was meant to eliminate

#### What to check

- The agent flags the violation
- The spec is rewritten, rejected, or annotated with required changes

**Failure signal:**
Invalid specs pass through unchanged.

---

### d. Planning & Tasking Propagation Test

**Goal:** Ensure the rule propagates beyond specs.

#### How to run

From a compliant spec:

- Generate a plan
- Generate tasks

#### What to check

- Planning decisions respect the new principle
- Tasks reflect new constraints (e.g. tests, checks, steps)
- No downstream artifact contradicts the Constitution

**Failure signal:**
Specs comply, but plans or tasks quietly violate the rule.

---

### e. Implementation Guidance Test (Behavioral Test)

**Goal:** Confirm the Constitution influences implementation decisions.

#### How to run

Ask the agent to implement or modify code under the new Constitution.

#### What to check

- The agent references the Constitution (explicitly or implicitly)
- Decisions align with the new principle
- Trade-offs are resolved *using the Constitution*

**Failure signal:**
The agent ignores the rule when implementation pressure appears.

---

### f. Regression Test (Backwards Compatibility Check)

**Goal:** Ensure existing valid behavior is not accidentally broken.

#### How to run

- Re-run spec or planning generation for a feature that:
  - should NOT be affected by the change

#### What to check

- No unnecessary constraints appear
- Existing behavior remains valid

**Failure signal:**
The Constitution change overreaches and constrains unrelated work.

---

### g. Durability Test (Time-Based Validation)

**Goal:** Ensure the rule remains useful over time.

#### How to run

- Apply the Constitution across:
  - 2–3 real features
  - multiple iterations or releases

#### What to check

- The rule continues to:
  - clarify decisions
  - reduce ambiguity
  - prevent regressions

**Failure signal:**
The rule is repeatedly worked around or ignored.

---

### h. Human Comprehension Test (Often Missed, Very Important)

**Goal:** Ensure humans can apply the rule without interpretation gaps.

#### How to run

- Ask a teammate unfamiliar with the change to:
  - explain the rule
  - apply it to a hypothetical feature

#### What to check

- Consistent interpretation
- Clear enforcement boundaries

**Failure signal:**
Different readers reach different conclusions.

---

## 5. Troubleshooting

<To be added later>

---

## 6. Additional Resource

- DeepWiki: [https://deepwiki.com/github/spec-kit/4-spec-driven-development-workflow](https://deepwiki.com/github/spec-kit/4-spec-driven-development-workflow)