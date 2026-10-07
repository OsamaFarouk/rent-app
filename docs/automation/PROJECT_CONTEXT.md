# Project context

Reviewed: 2026-10-07.
Application baseline: `d8fe9049c737ff8ef725f14fa86a5b667220bcbf`, committed 2026-10-07.
Scope: source inspection only. Osama confirmed pushing the latest Windows project on 2026-10-07; this revision is the refreshed repository baseline. Runtime behavior, live database, installed tool versions and any subsequent local edits remain unverified.

## Product direction

Rent App connects media, photography, film, and production users with equipment providers, rental houses, and creative professionals. The current agreed product is discovery and direct provider contact. In-app payments, deposits, contracts, and confirmed bookings are not part of this automation task. "Add equipment booking requests" was an example of a feature request, not authorization to implement it.

Preserve existing design and behavior unless a feature explicitly changes them. Explain proposed UX or architecture changes briefly before implementation and obtain Osama's decision when they change scope. Keep development prompts concise.

## Observed source structure

| Area | Evidence | Observation |
|---|---|---|
| Application | `lib/main.dart`, `lib/app.dart` | Supabase initialization, Riverpod ProviderScope, MaterialApp.router, dark theme |
| Dependencies | `pubspec.yaml` | App version 1.0.0+1; Dart constraint ^3.13.0; Flutter, Riverpod, go_router, supabase_flutter, image_picker, url_launcher, share_plus |
| Feature organization | `lib/features/` | Auth, equipment, favorites, home, professionals, profile, search |
| Navigation | `lib/core/routing/app_router.dart`, `lib/shared/widgets/app_shell.dart` | Home, Equipment, Professionals, Rental Houses, Profile; separate details, editing, authentication and search routes |
| Accounts | `lib/features/profile/domain/profile_model.dart` | user, professional, business; compatibility mapping for personal/individual |
| Equipment | `lib/features/equipment/data/equipment_repository.dart` | Creation and edits set pending approval; edits filter by equipment ID and owner ID; public list filters approved records |
| Business profiles | `lib/features/profile/data/business_repository.dart` | Uses business_profiles, public discovery filters approved and active; detail lookup is by ID |
| Professional data | `lib/features/profile/data/profile_repository.dart` | professional_profiles and portfolio_items reads/writes; onboarding creates a draft professional profile; public discovery first selects approved professional profile IDs, then active profiles |
| Account guard | `lib/core/providers/account_guard_provider.dart`, `lib/core/services/account_guard_service.dart` | Session validation and profile realtime handling, including suspended-account sign-out |
| Storage | `lib/core/services/storage_service.dart` | Profile, equipment, portfolio and business-cover uploads; equipment/portfolio can fall back to avatars; business covers use avatars |
| Localization | `lib/l10n/`, `lib/app.dart` | English/Arabic resources and localization delegates present; translation completeness not audited |
| Backend history | `supabase/migrations/` | Twelve SQL files present, dated Aug 25–Oct 6, 2026; latest additions allow professional draft status and business cover_image_url |
| Tests | `test/` | Sixteen Dart test files present; none executed for this documentation change |

Dependencies above are declared packages, not a statement of installed Windows versions.

## October 7 source updates

- Professional completion: `lib/features/profile/domain/professional_completion_status.dart` calculates eight checks: name, photo, email, phone, city, professional title, travel preference and a portfolio item or external work link. Travel completion currently checks that a professional profile exists; it does not prove the user explicitly selected a preference.
- Professional editing: `lib/features/professionals/presentation/pages/my_professional_profile_page.dart` includes Save Draft, submission to pending review, a pending-state message and an approved-state Update & Resubmit action. Submission validates the form and completion status. The approved-state action differs from an earlier request to remove submission buttons after approval; clarify desired UX before changing it.
- Portfolio work: the same page provides required title/work type/role/description fields, cover selection and multiple gallery images from the phone, a cover-or-valid-link requirement, optional client/tools/year/project-link fields, and explicit invalid-URL messages.
- Portfolio metadata: `lib/features/profile/domain/portfolio_item_model.dart` stores supplementary work metadata, including gallery URLs, as JSON inside the existing description field. Do not invent new database columns for these values in documentation.
- Profile overview: `lib/features/profile/presentation/pages/profile_page.dart` shows completion guidance; `profile_provider.dart` supplies the completion status.
- Rental-house covers: the business model/repository persist cover_image_url, and the editor supports add/replace/remove separately from the logo. Cover-related presentation changes are present in rental-house cards and details.
- New migration files: `20260923_allow_draft_approval_status.sql` permits draft/pending/approved/rejected/suspended professional statuses; `20261006123350_add_business_cover_image.sql` adds cover_image_url to business_profiles. Application to any live database is unverified.
- Test sources added: `test/professional_onboarding_and_completion_test.dart` checks completion calculations; `test/business_cover_test.dart` checks model serialization and an editor flow using a fake repository. These are not evidence of live database round trips or successful execution.
- Cleanup: shared_preferences and cupertino_icons were removed from declared dependencies; fonts/icons asset-directory declarations and two sample images were removed. No measured build-size reduction was supplied.

These are source observations, not a runtime acceptance report. URL validators use heuristics and have not been certified robust by this documentation review.

## Backend boundaries

The inspected client uses profiles, business_profiles, professional_profiles, portfolio_items, equipment, equipment_images, and categories. Historical references to rental_offices should not override the current business_profiles client code.

Migration files describe intended database changes, not proof they were applied. RLS, grants, ownership enforcement, moderation permissions, storage policies, triggers, and deployed schema need separate verification against a development environment before backend automation.

Do not infer backend protection from Flutter query filters. For example, the business list query filters approval status while its detail lookup relies on backend access controls. The inspected account-architecture migration defaults business profiles to approved. Approval behavior must be reconciled with current product requirements and actual deployed policies before documenting it as guaranteed.

## Existing repository update script

`update_repo.ps1`:
1. Changes directory to `D:\\rent_app`.
2. Checks for a Git repository and runs `flutter analyze`.
3. If changes exist, stages all changes and creates a dated commit.
4. Runs `git push origin main`.

It does not run the test suite, build Android/iOS artifacts, create a GitHub Release, or deploy backend changes. Do not invoke this script unchanged in the proposed feature-branch workflow. It stages all local work and explicitly pushes main. The script is unchanged in the October 7 push. No separate release-publishing script is present in the inspected tree.

No GitHub Actions workflow or n8n export was present in the inspected tree.

## Reconciliation needed before implementation

- Baseline refresh is complete for Osama's October 7 push. Read the latest approved revision at the start of each future task.
- Clarify whether the reported release automation refers to update_repo.ps1 or a separate local-only script; the committed script only analyzes, commits and pushes.
- Verify installed Flutter/Dart, Antigravity CLI, Codex, n8n versions and n8n hosting method.
- Reconcile onboarding/account selection, business/professional approval, guest access, and location behavior with the current app.
- The home/search test source describes home results across all locations; earlier discussions mentioned a home city filter. Treat desired location behavior as unresolved until current code and founder intent are reconciled.
- Identify development versus production backend targets, signing arrangements, release channels, monitoring source, and iOS build runner.
