---
description: Create or update the project constitution from interactive or provided principle inputs, ensuring all dependent templates stay in sync.
handoffs: 
  - label: Build Specification
    agent: speckit.specify
    prompt: Implement the feature specification based on the updated constitution. I want to build...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Phase 0 (optional): Project knowledge base bootstrap

If the project has no or minimal knowledge-base docs under `.specify/memory/` (e.g. `.specify/memory/product/product-overview.md` and `.specify/memory/architecture/tech-stack.md` are missing), run this **before** the constitution update so the project has a baseline. Skip if those files already exist and are populated.

**Output structure** under `.specify/memory/`:
- `product/` — product-overview.md, domain-model-and-terms.md, storage-model-index.md
- `architecture/` — tech-stack.md, system-pattern.md, external-integration.md, business-services.md, middleware-and-base.md
- `norms/` — architecture-specific norm docs (e.g. database-norms.md, persistence-norms.md, service-layer-norms.md)

**Principle**: Execute batches in strict order (batch 0 → 1 → 2 → 3); within a batch, tasks may run in parallel. Use TODO tracking. When delegating an agent, read and follow the steps defined in the referenced agent file; paths and reference docs are given below.

### Step 0: Read shared rules (required)

- `.specify/settings/rules/doc-responsibility.md` — document boundaries and which docs to generate
- `.specify/settings/rules/doc-quality-criteria.md` — accuracy and readability (code refs, MUST/SHOULD)
- `.specify/settings/rules/tech-stack-catalog.md` — tech stack categories

### Step 1: Generate foundation docs (batch 0)

**Check**: Use Glob to see if `.specify/memory/product/product-overview.md` and `.specify/memory/architecture/tech-stack.md` exist. If both exist, skip batch 0. Otherwise continue.

**Delegate** (parallel):

| Agent | Output path |
|-------|-------------|
| Execute steps from `.specify/agents/docs/product-context-writer.md` | `.specify/memory/product/product-overview.md` |
| Execute steps from `.specify/agents/docs/tech-stack-analyzer.md` | `.specify/memory/architecture/tech-stack.md` |

When invoking each agent, pass the output path above and any user input about product or tech stack. After completion, read both docs to plan later batches.

### Step 2: Determine document list

Using batch 0 outputs and `.specify/settings/rules/doc-responsibility.md`:

**Skip rules** (do not generate if condition holds):
- No business Web/HTTP APIs (or only non-business e.g. health checks) → skip Web-interface norms
- No business RPC APIs → skip RPC-interface norms
- No database → skip database-norms.md, persistence-norms.md
- No external system integration → skip external-integration.md
- No persistence layer → skip storage-model-index.md
- No shared internal tools → skip common-internal-tools (if applicable)
- No business service encapsulation → skip business-services.md
- No middleware/base-product wrappers → skip middleware-and-base.md

**Architecture norms**: Read the "norms" table in doc-responsibility.md; from tech-stack.md and system-pattern.md identify architecture (e.g. traditional layered, DDD, COLA, CQRS, hexagonal) and derive the list of norm docs to generate under `.specify/memory/norms/`.

Optionally output a short **document generation plan** (batch 0 done, batch 1–3 planned with conditions).

### Step 3: Delegate agents by batch

**Batch 1** (after batch 0): One doc.

| Agent | Output | Reference docs |
|-------|--------|----------------|
| `.specify/agents/docs/system-pattern-analyzer.md` | `.specify/memory/architecture/system-pattern.md` | product-overview.md, tech-stack.md |

Wait for batch 1 to complete before batch 2.

**Batch 2** (conditional; depends on batch 0 + 1):

| Agent | Output | Condition |
|-------|--------|-----------|
| `.specify/agents/docs/domain-model-extractor.md` | `.specify/memory/product/domain-model-and-terms.md` | Always |
| `.specify/agents/docs/storage-model-extractor.md` | `.specify/memory/product/storage-model-index.md` | Has persistence layer |
| `.specify/agents/docs/capability-indexer.md` | `.specify/memory/architecture/external-integration.md` | Has external system integration |
| `.specify/agents/docs/capability-indexer.md` | `.specify/memory/architecture/common-internal-tools.md` | Has shared internal tools |
| `.specify/agents/docs/business-service-indexer.md` | `.specify/memory/architecture/business-services.md` | Has business service encapsulation |
| `.specify/agents/docs/middleware-wrapper-indexer.md` | `.specify/memory/architecture/middleware-and-base.md` | Has middleware/base-product wrappers |
| `.specify/agents/docs/constitution-writer.md` | `.specify/memory/norms/database-norms.md` | Has database |

For each, pass the output path and reference docs (e.g. tech-stack.md, system-pattern.md, product-overview.md as needed). Wait for batch 2 before batch 3.

**Batch 3** (architecture-specific norms): From Step 2, for each norm doc in the list (e.g. Web-interface norms, RPC-interface norms, service-layer-norms.md, domain-model-norms.md, persistence-norms.md), delegate `.specify/agents/docs/constitution-writer.md` with output path `.specify/memory/norms/<norm-name>.md` and reference docs (tech-stack.md, system-pattern.md, domain-model-and-terms.md). Follow doc-responsibility.md and system-pattern for which norms apply.

**Execution**: Strict batch order; within a batch run in parallel if supported. On success continue; on failure record reason and skip or stop critical batches as appropriate.

### Step 4: Update index

Refresh `.specify/memory/AGENTS.md`: scan `.specify/memory/product/`, `.specify/memory/architecture/`, `.specify/memory/norms/` and update the application-knowledge table inside `<project_rules>` (columns: technology, scenarios, keywords, file path with `.specify/memory/` prefix). Either invoke the index-refresher agent or execute the steps defined in `.specify/agents/index-refresher.md` (same outcome).

### Step 5: Summary report

Summarize generated docs by category (product, architecture, norms): list created files and, for any skipped or failed, brief reason. Optionally total counts per category.

**Quality rules**: Every claim must have a code reference (path:line). Use MUST/SHOULD/MAY. Prefer less content over wrong content. Single doc ≤500 lines. Then proceed to the constitution update below.

## Outline

You are updating the project constitution at `.specify/memory/constitution.md`. This file is a TEMPLATE containing placeholder tokens in square brackets (e.g. `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`). Your job is to (a) collect/derive concrete values, (b) fill the template precisely, and (c) propagate any amendments across dependent artifacts.

**Note**: If `.specify/memory/constitution.md` does not exist yet, it should have been initialized from `.specify/templates/constitution-template.md` during project setup. If it's missing, copy the template first.

Follow this execution flow:

1. Load the existing constitution at `.specify/memory/constitution.md`.
   - Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`.
   **IMPORTANT**: The user might require less or more principles than the ones used in the template. If a number is specified, respect that - follow the general template. You will update the doc accordingly.

2. Collect/derive values for placeholders:
   - If user input (conversation) supplies a value, use it.
   - Otherwise infer from existing repo context (README, docs, prior constitution versions if embedded).
   - For governance dates: `RATIFICATION_DATE` is the original adoption date (if unknown ask or mark TODO), `LAST_AMENDED_DATE` is today if changes are made, otherwise keep previous.
   - `CONSTITUTION_VERSION` must increment according to semantic versioning rules:
     - MAJOR: Backward incompatible governance/principle removals or redefinitions.
     - MINOR: New principle/section added or materially expanded guidance.
     - PATCH: Clarifications, wording, typo fixes, non-semantic refinements.
   - If version bump type ambiguous, propose reasoning before finalizing.

3. Draft the updated constitution content:
   - Replace every placeholder with concrete text (no bracketed tokens left except intentionally retained template slots that the project has chosen not to define yet—explicitly justify any left).
   - Preserve heading hierarchy and comments can be removed once replaced unless they still add clarifying guidance.
   - Ensure each Principle section: succinct name line, paragraph (or bullet list) capturing non‑negotiable rules, explicit rationale if not obvious.
   - Ensure Governance section lists amendment procedure, versioning policy, and compliance review expectations.

4. Consistency propagation checklist (convert prior checklist into active validations):
   - Read `.specify/templates/plan-template.md` and ensure any "Constitution Check" or rules align with updated principles.
   - Read `.specify/templates/spec-template.md` for scope/requirements alignment—update if constitution adds/removes mandatory sections or constraints.
   - Read `.specify/templates/tasks-template.md` and ensure task categorization reflects new or removed principle-driven task types (e.g., observability, versioning, testing discipline).
   - Read each command file in `.specify/templates/commands/*.md` (including this one) to verify no outdated references (agent-specific names like CLAUDE only) remain when generic guidance is required.
   - Read any runtime guidance docs (e.g., `README.md`, `docs/quickstart.md`, or agent-specific guidance files if present). Update references to principles changed.

5. Produce a Sync Impact Report (prepend as an HTML comment at top of the constitution file after update):
   - Version change: old → new
   - List of modified principles (old title → new title if renamed)
   - Added sections
   - Removed sections
   - Templates requiring updates (✅ updated / ⚠ pending) with file paths
   - Follow-up TODOs if any placeholders intentionally deferred.

6. Validation before final output:
   - No remaining unexplained bracket tokens.
   - Version line matches report.
   - Dates ISO format YYYY-MM-DD.
   - Principles are declarative, testable, and free of vague language ("should" → replace with MUST/SHOULD rationale where appropriate).

7. Write the completed constitution back to `.specify/memory/constitution.md` (overwrite).

8. Output a final summary to the user with:
   - New version and bump rationale.
   - Any files flagged for manual follow-up.
   - Suggested commit message (e.g., `docs: amend constitution to vX.Y.Z (principle additions + governance update)`).

Formatting & Style Requirements:

- Use Markdown headings exactly as in the template (do not demote/promote levels).
- Wrap long rationale lines to keep readability (<100 chars ideally) but do not hard enforce with awkward breaks.
- Keep a single blank line between sections.
- Avoid trailing whitespace.

If the user supplies partial updates (e.g., only one principle revision), still perform validation and version decision steps.

If critical info missing (e.g., ratification date truly unknown), insert `TODO(<FIELD_NAME>): explanation` and include in the Sync Impact Report under deferred items.

Do not create a new template; always operate on the existing `.specify/memory/constitution.md` file.
