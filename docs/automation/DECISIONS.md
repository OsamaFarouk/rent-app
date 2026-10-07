# Decisions

Recorded: 2026-10-07. Status distinguishes agreed direction from proposed technical choices.

| ID | Status | Decision | Reason |
|---|---|---|---|
| D001 | Agreed | Use OsamaFarouk/rent-app as the repository | Confirmed by Osama |
| D002 | Agreed | Prepare documentation before automation implementation | Establish a reusable reference first |
| D003 | Agreed | Founder: Osama; planner: ChatGPT; designer: Stitch; developer: Antigravity; reviewer: Codex | User-selected development team |
| D004 | Agreed | Keep design and final acceptance/release approvals | Founder controls UX and release |
| D005 | Agreed direction | Keep reference documents and workflow exports versioned in GitHub | Continuity must not depend on chat memory |
| D006 | Agreed direction | Documentation updates belong in the automated cycle | Keep the reference aligned with reviewed work |
| D007 | Proposed working method | One master planning chat and one chat per stage, with a handover | Keep stage context manageable |
| D008 | Proposed architecture | Modular n8n workflows with a Windows execution runner | Separate coordination from local tool execution |
| D009 | Proposed release process | Feature branches and reviewed pull requests; code and docs merge together | Traceable changes and approvals |
| D010 | Proposed pilot | One small feature before full design/release automation | Validate the core path incrementally |
| D011 | Proposed reliability limit | Maximum three repair attempts, then founder escalation | Avoid endless loops and uncontrolled usage |

## Open choices

- Trigger and approval channel: GitHub issue, form, or another authenticated channel.
- n8n hosting method and Windows runner transport.
- Model choices, authentication, quotas and usage budget.
- Stitch access and output format; Antigravity CLI/MCP configuration.
- Durable execution-state store and artifact/log storage.
- Required checks, severity threshold for blocking findings, and final retry/time limits.
- Android test distribution, production deployment order, iOS runner and signing.
- Monitoring/crash reporting integration and recovery procedure.
- Whether a newer Windows source revision should replace the September 16 baseline.

## History rule

Append decisions with date, owner/approval evidence, and rationale. To change an agreed decision, record which decision it supersedes. Code changes alone do not establish approval for a business-rule change.
