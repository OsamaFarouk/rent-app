# Workflow plan

Status: design proposal recorded before implementation. No executable workflows or deployment changes are included.

## Staged delivery

| Stage | Work | Exit evidence |
|---|---|---|
| 1 — Assessment | Reconcile Windows/GitHub source; inspect local tools, n8n hosting, release script, access and costs | Confirmed baseline and connection choices |
| 2 — Rules | Review product context, roles, task format and acceptance criteria | Approved shared reference |
| 3 — Foundation | Implement runner dispatch, durable job state, logs, timeouts, locking, retry/deduplication | Controlled task runs and recovery after interruption |
| 4 — Planning | Receive request; generate requirements, tasks, criteria and scope | Reviewable feature specification |
| 5 — Design | Conditionally invoke Stitch; collect artifacts and founder approval | Approved design version or explicit no-UI-change path |
| 6 — Development | Dedicated branch; backend changes in development; Flutter implementation | Diff and implementation report |
| 7 — Verification | Analyze, tests, builds, Codex review, bounded repair loop and doc review | Required checks pass on reviewed revision |
| 8 — Acceptance/release | Test build, founder acceptance, PR merge and verified release process | Approval plus release evidence |
| 9 — Monitoring | Capture deployment status and configured crash/error signals | Notifications and linked follow-up tickets |

Pilot proposal: one small feature through planning, implementation, checks, Codex review and founder acceptance. Full design automation and production release follow after the core path is reliable.

## Feature lifecycle

Request -> requirements/tasks -> conditional design -> founder design approval -> conditional backend work -> Flutter implementation -> developer checks -> documentation proposal -> Codex code/docs review -> bounded repair and recheck -> founder app test and release approval -> merge -> deploy/distribute -> observe release.

Skip design/backend stages only when the approved scope does not require them. Requirements needing clarification return to the founder. Rejected designs return to design; failed checks return to development. After the agreed repair limit, pause with evidence and remaining findings.

## Proposed durable task record

Record task ID, approved scope/version, base SHA, feature branch, current code SHA, design artifact/version, stage/status, attempt count, check results, review findings, approval actor/time/revision, artifact IDs, release target/status and documentation paths.

Possible states: requested, planning, awaiting_design_approval, developing, verifying, reviewing, needs_fixes, awaiting_acceptance, approved, releasing, released, failed, cancelled.

State must survive n8n and runner restarts. A repeated webhook or callback must not create another branch, repeat a merge, or replay a migration. Queue one writer per checkout; use stable task/attempt IDs. Pauses must be resumable; cancellation must stop further mutation. On failure, preserve evidence and notify rather than marking the stage complete.

## Automatically maintaining the reference

1. At task start, read docs from the approved base revision and include relevant source and the approved task specification. Record their versions.
2. Record requirements as planned until implementation and verification exist.
3. After implementation, generate a proposed docs diff from changed code, migrations, approved decisions and actual test output.
4. Update PROJECT_CONTEXT for changed behavior, DECISIONS only for authorized decisions, and HANDOVER for checkpoint/next action.
5. Codex checks source references, status labels and claims. Record missing evidence as unverified.
6. Include code and documentation in the same PR. Re-run relevant checks after fixes; approvals bind to the exact reviewed revision/artifact.
7. Following release, record the actual deployment result in a separate traceable status update. A merged PR is not proof of deployment.
8. Proposed PR checks detect missing expected documentation changes or require a justified "no documentation impact" result. Documentation-only/status updates must not recursively trigger a new feature or release.
9. Export actual n8n changes using the convention in automation/n8n/workflows/README.md. Validate JSON and remove secrets/sample user data before committing.

This cycle is planned, not active. Automated summaries cannot approve themselves or redefine scope.

## Verification and release boundaries

- Analyzer, meaningful tests, required platform build and human acceptance are distinct gates.
- Test code presence is not a passing run. A zero CLI exit code does not replace checking expected outputs and tool denials.
- Capture failures, timeouts and skipped checks explicitly.
- Backend changes require migration history, development validation, access-control checks and a reviewed production rollout/recovery plan.
- Production backend changes must remain compatible with app versions still installed by users. Do not assume database changes can always be safely reversed.
- Android and iOS have separate build/signing/distribution requirements; iOS needs a macOS/Xcode runner.
- Inspect and adapt the existing update_repo.ps1 before automation use; it currently pushes main directly and does not release builds.
- Do not expose a general unauthenticated shell endpoint. Choose a restricted authenticated runner connection during Stage 1.
- Monitoring requires an actual configured error/crash source. Polling GitHub release state alone does not detect runtime crashes.

## Integration references to verify during setup

- n8n execution environment: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executecommand/
- n8n OpenAI credentials: https://docs.n8n.io/integrations/builtin/credentials/openai/
- Antigravity headless mode: https://www.antigravity.google/docs/cli/headless/
- Codex scripted execution: https://developers.openai.com/codex/noninteractive
- Stitch MCP: https://stitch.withgoogle.com/docs/mcp/setup/
- Flutter iOS release: https://docs.flutter.dev/deployment/ios

Availability in documentation is not verification of the installed version, account access, cost, or working connection.
