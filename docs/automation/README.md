# Rent App automation reference

Status: initial documentation baseline; automation implementation has not started.
Prepared: 2026-10-07. Repository: OsamaFarouk/rent-app.
Inspected application commit: `d8fe9049c737ff8ef725f14fa86a5b667220bcbf` (2026-10-07).

## Start here

Read these files in order:
1. [HANDOVER.md](HANDOVER.md) — current checkpoint and next action.
2. [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) — product scope and code evidence.
3. [DECISIONS.md](DECISIONS.md) — agreed direction and open choices.
4. [AGENT_ROLES.md](AGENT_ROLES.md) — ownership and boundaries.
5. [WORKFLOW_PLAN.md](WORKFLOW_PLAN.md) — staged implementation and documentation updates.
6. [Workflow exports](../../automation/n8n/workflows/README.md) — future export convention.

## Evidence and continuity

- **Observed in code** means source was inspected at the commit above; it does not mean the app was run or the deployed backend was verified.
- **Agreed direction** records Osama's instructions and the development cycle discussed on 2026-10-07.
- **Proposed** means an implementation detail still to be finalized.
- **Unverified** means evidence or access is missing.
- Approved product requirements describe intended behavior. Code and tests describe implementation; discrepancies must be recorded, not silently treated as new business decisions.
- The August 19 concept brief is historical context. Current navigation and account models have evolved.
- Read the latest approved documentation from the base branch and overlay the approved feature specification. Do not assume AI conversations or API sessions share memory.
- Documentation on a feature branch remains a proposal until reviewed and merged.
- At each checkpoint record the inspected source SHA, checks actually performed, changed files, unresolved issues, and next action.
- Preserve decision history; supersede old entries explicitly.
- Never include credentials, personal data, raw production logs, or confidential conversation history in these public repository documents.

## New-chat handover

> Read docs/automation/README.md and its linked documents, especially HANDOVER.md. Confirm the branch and source revision, summarize the verified state and unresolved items, then continue only within the authorized stage.

This documentation change does not enable n8n, alter app code, apply migrations, or authorize a production release.
