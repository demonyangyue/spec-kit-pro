---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
handoffs: 
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot"). If FEATURE_SPEC is missing or unreadable, abort and suggest running `/speckit.specify` or `/speckit.parse-prd` first.

2. **Prepare / Load context**:
   - Read `.specify/memory/AGENTS.md` and load referenced docs (norms, tech stack, architecture) as needed.
   - Read FEATURE_SPEC in full: feature description, user stories, flows.
   - Read `/memory/constitution.md`. Load IMPL_PLAN template (already copied).
   - Optionally: explore codebase for existing APIs, entities, and reusable components; or delegate gap-analyst if the project uses `specs/` and gap analysis—if not applicable, skip.
   - **Checkpoint**: Spec read; norms/templates read; (if applicable) gap or reuse identified.

3. **Requirements / scope analysis**: From FEATURE_SPEC extract and list briefly:
   - Core requirements and user stories
   - Key entities and relationships
   - Main flows and constraints (and permissions if relevant)
   So the plan workflow is scope-aware.

4. **Technical decision clarification (if needed)**:
   - **Decision tree** (evaluate in order): (a) All technical decisions have clear best practice or template guidance → skip; use **[Suggested]** with rationale where needed. (b) Can be inferred from codebase or norms → skip; follow existing style. (c) At least one critical technical uncertainty → ask (max 2 questions).
   - **Clarification format**: Use a table: Option | Answer | Implications. Technical only (no requirement questions; those belong in specify/parse-prd). Max 2 questions; each option should state when it applies.
   - **When not asking**: Proceed with **[Suggested]** and brief rationale (e.g. "based on existing codebase style", "industry best practice").

5. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

6. **Quality verification** (before reporting): Check the plan and generated artifacts:
   - **Accuracy**: Every design element traceable to FEATURE_SPEC; no out-of-scope design; user stories and acceptance criteria covered.
   - **Operability**: Key logic described (pseudocode/flowcharts where helpful); exceptions and edge cases mentioned.
   - **Readability**: Follow template section order; prefer diagrams over long text; naming self-explanatory.
   - **Completeness**: Unambiguous; pre/post conditions and state transitions explicit where relevant.
   If checks fail: list issues, fix, then re-check (e.g. one round); then report.

7. **Report**: Command ends after planning. Produce a **minimal report**:
   - IMPL_PLAN path and branch
   - Short overview: main artifacts (e.g. research.md, data-model.md, contracts), and 1–2 line summary of scope
   - Readiness for next phase (e.g. `/speckit.tasks` or `/speckit.checklist`)
   Do not include a long checklist in the report; keep it minimal.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Define interface contracts** (if project has external interfaces) → `/contracts/`:
   - Identify what interfaces the project exposes to users or other systems
   - Document the contract format appropriate for the project type
   - Examples: public APIs for libraries, command schemas for CLI tools, endpoints for web services, grammars for parsers, UI contracts for applications
   - Skip if project is purely internal (build scripts, one-off tools, etc.)

3. **Agent context update**:
   - Run `{AGENT_SCRIPT}`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

**Output**: data-model.md, /contracts/*, quickstart.md, agent-specific file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications

## Important constraints and safety

- **Clarification**: Ask questions only in the Technical decision clarification step; max 2 questions; technical only. Requirement gaps or ambiguities → suggest revising the spec or running `/speckit.specify` or `/speckit.parse-prd`.
- **Safety**: If FEATURE_SPEC is missing or unreadable, abort and suggest running `/speckit.specify` or `/speckit.parse-prd` first.
