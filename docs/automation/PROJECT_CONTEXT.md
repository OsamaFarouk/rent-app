# Project context

Reviewed: 2026-10-07.
Application baseline: `40b23664507b416a9c6cc1659ab42a08dde62c7b`, committed 2026-09-16.
Scope: source inspection only. Windows working copy, runtime behavior, live database, and installed tool versions are unverified.

## Product direction

Rent App connects media, photography, film, and production users with equipment providers, rental houses, and creative professionals. The current agreed product is discovery and direct provider contact. In-app payments, deposits, contracts, and confirmed bookings are not part of this automation task. "Add equipment booking requests" was an example of a feature request, not authorization to implement it.

Preserve existing design and behavior unless a feature explicitly changes them. Explain proposed UX or architecture changes briefly before implementation and obtain Osama's decision when they change scope. Keep development prompts concise.

## Observed source structure

| Area | Evidence | Observation |
|---|---|---|
| Application | `lib/main.dart`, `lib/app.dart` | Supabase initialization, Riverpod ProviderScope, MaterialApp.router, dark theme |
| Dependencies | `pubspec.yaml` | App version 1.0.0+1; Dart constraint ^3.13.0; Flutter, Riverpod, go_router, supabase_flutter, image_picker, shared_preferences, url_launcher, share_plus |
| Feature organization | `lib/features/` | Auth, equipment, favorites, home, professionals, profile, search |
| Navigation | `lib/core/routing/app_router.dart`, `lib/shared/widgets/app_shell.dart` | Home, Equipment, Professionals, Rental Houses, Profile; separate details, editing, authentication and search routes |
| Accounts | `lib/features/profile/domain/profile_model.dart` | user, professional, business; compatibility mapping for personal/individual |
| Equipment | `lib/features/equipment/data/equipment_repository.dart` | Creation and edits set pending approval; edits filter by equipment ID and owner ID; public list filters approved records |
| Business profiles | `lib/features/profile/data/business_repository.dart` | Uses business_profiles, public discovery filters approved and active; detail lookup is by ID |
| Professional data | `lib/features/profile/data/profile_repository.dart` | professional_profiles and portfolio_items reads/writes; public professional query uses profiles |
| Account guard | `lib/core/providers/account_guard_provider.dart`, `lib/core/services/account_guard_service.dart` | Session validation and profile realtime handling, including suspended-account sign-out |
| Storage | `lib/core/services/storage_service.dart` | Profile/equipment uploads and public URLs; equipment upload fallback to avatar bucket |
| Localization | `lib/l10n/`, `lib/app.dart` | English/Arabic resources and localization delegates present; translation completeness not audited |
| Backend history | `supabase/migrations/` | Ten SQL files present, dated Aug 25–Sep 14, 2026 |
| Tests | `test/` | Fourteen Dart test files present; none executed for this documentation change |

Dependencies above are declared packages, not a statement of installed Windows versions.

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

It does not run the test suite, build Android/iOS artifacts, create a GitHub Release, or deploy backend changes. Do not invoke this script unchanged in the proposed feature-branch workflow. It stages all local work and explicitly pushes main. A newer local script may exist and has not been inspected.

No GitHub Actions workflow or n8n export was present in the inspected tree.

## Reconciliation needed before implementation

- Determine whether the Windows working copy contains changes after September 16 and refresh this baseline if so.
- Inspect the current local release script if it differs from the committed script.
- Verify installed Flutter/Dart, Antigravity CLI, Codex, n8n versions and n8n hosting method.
- Reconcile onboarding/account selection, business/professional approval, guest access, and location behavior with the current app.
- The home/search test source describes home results across all locations; earlier discussions mentioned a home city filter. Treat desired location behavior as unresolved until current code and founder intent are reconciled.
- Identify development versus production backend targets, signing arrangements, release channels, monitoring source, and iOS build runner.
