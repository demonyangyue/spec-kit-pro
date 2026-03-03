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

1. **Read shared rules** (required for quality):
   - `.specify/settings/rules/doc-responsibility.md` — document boundaries and which docs to generate
   - `.specify/settings/rules/doc-quality-criteria.md` — accuracy and readability rules (code references, MUST/SHOULD)
   - `.specify/settings/rules/tech-stack-catalog.md` — tech stack categories

2. **Phase 1 — Foundation**: Explore the repo, then create:
   - `.specify/memory/product/product-overview.md` — product positioning, main modules, key flows (with code refs)
   - `.specify/memory/architecture/tech-stack.md` — language, framework, middleware, base products, core libs (with versions and file:line refs). Prefer `mvn dependency:tree` (or equivalent) for real dependencies.

3. **Phase 2 — Plan**: Decide which docs to generate using doc-responsibility.md:
   - No business Web/RPC → skip Web/RPC interface norms; no DB → skip database-norms.md, persistence-norms.md; no external systems → skip external-integration.md.
   - Architecture: traditional layered → service-layer-norms.md; DDD → domain-model-norms.md; etc.

4. **Phase 3 — Generate in batches** (strict order, batch-internal serial):
   - **Batch 1**: `.specify/memory/architecture/system-pattern.md` — layering, module deps, directory tree, mermaid diagrams.
   - **Batch 2** (conditional): external-integration.md, business-services.md, middleware-and-base.md under `.specify/memory/architecture/` when applicable.
   - **Batch 3** (conditional): database-norms.md, service-layer-norms.md or domain-model-norms.md under `.specify/memory/norms/` when applicable.

5. **Phase 4**: Update `.specify/memory/AGENTS.md`: scan `.specify/memory/product/`, `.specify/memory/architecture/`, `.specify/memory/norms/` and refresh the **应用知识** table inside `<project_rules>` (technology, scenarios, keywords, file path with `.specify/memory/` prefix).

Rules: every claim must have a code reference (path:line). Use MUST/SHOULD/MAY. Prefer less content over wrong content. Single doc ≤500 lines. Then proceed to the constitution update below.

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
