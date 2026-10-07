# n8n workflow exports

Status: no exported workflows yet. This folder contains instructions only.

When automation is implemented:
- Save actual exported workflows as stable descriptive JSON filenames, for example feature-planning.json or code-review.json. These names are examples, not existing workflows.
- Record the compatible n8n version, required node/package versions, credential types, callback requirements and import/reconnection instructions with each workflow.
- Export after a reviewed workflow change. Keep Git history instead of numbered "final" copies.
- Never export credentials. Inspect JSON for embedded authorization headers, tokens, webhook secrets, pinned/sample execution data and private payloads; remove those before committing.
- Keep logical structure intact and verify import into a non-production instance with credentials reconnected.
- Keep imported workflows inactive until their setup, tests and activation are approved.
- A committed export is a versioned definition, not proof that the running n8n instance matches it. Record the deployed workflow revision and verify drift during updates.
- Update docs/automation/HANDOVER.md with actual export/import verification results.

The proposed update/review process is described in [WORKFLOW_PLAN.md](../../../docs/automation/WORKFLOW_PLAN.md).
