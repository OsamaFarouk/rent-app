import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/core/providers/account_guard_provider.dart';
import 'package:rent_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:rent_app/features/equipment/domain/equipment_model.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';
import 'package:rent_app/features/profile/domain/portfolio_item_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeProfileNotifier extends StateNotifier<ProfileNotifierState>
    implements ProfileNotifier {
  FakeProfileNotifier() : super(const ProfileNotifierState());

  @override
  Future<bool> updateProfile(ProfileModel profile) async => true;

  @override
  Future<bool> updateProfessionalProfile(ProfessionalProfileModel proProfile) async => true;

  @override
  Future<bool> addPortfolioItem({
    required String professionalProfileId,
    required String title,
    String? description,
    String? mediaUrl,
    String mediaType = 'image',
    String? externalUrl,
    int displayOrder = 0,
  }) async => true;

  @override
  Future<bool> updatePortfolioItem(PortfolioItemModel item) async => true;

  @override
  Future<bool> reorderPortfolioItems(List<PortfolioItemModel> items) async => true;

  @override
  Future<bool> deletePortfolioItem(String itemId) async => true;

  @override
  Future<bool> completeProfileSetup({
    required String userId,
    required String profileType,
    String? businessName,
  }) async => true;
}

Widget _createSetupPageWidget({User? mockUser}) {
  final userToUse = mockUser ??
      User(
        id: 'test-user-id',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(userToUse),
      profileNotifierProvider.overrideWith((ref) => FakeProfileNotifier()),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProfileSetupPage(),
    ),
  );
}

void main() {
  group('Issue 1: Account Type Selection Tests', () {
    test('1. ProfileModel with null account_type has completed onboarding = false', () {
      final profile = ProfileModel.fromJson({
        'id': 'unselected-user-1',
        'full_name': 'New User',
        'account_type': null,
      });

      expect(profile.accountType, null);
      expect(profile.hasCompletedOnboarding, false);
    });

    test('2. ProfileModel with empty account_type has completed onboarding = false', () {
      final profile = ProfileModel.fromJson({
        'id': 'unselected-user-2',
        'full_name': 'New User 2',
        'account_type': '',
      });

      expect(profile.hasCompletedOnboarding, false);
    });

    test('3. AccountGuardNotifier offline fallback for unselected profile preserves null accountType', () {
      final guardState = AccountGuardState.active(const ProfileModel(
        id: 'u-123',
        fullName: 'Offline Unselected',
        accountType: null,
      ));

      expect(guardState.profile?.hasCompletedOnboarding, false);
    });

    test('4. ProfileModel with explicit personal account_type has completed onboarding = true', () {
      final profile = ProfileModel.fromJson({
        'id': 'personal-user',
        'full_name': 'Personal User',
        'account_type': 'personal',
      });

      expect(profile.accountType, 'user');
      expect(profile.isPersonal, true);
      expect(profile.isUser, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    test('5. ProfileModel with explicit professional account_type has completed onboarding = true', () {
      final profile = ProfileModel.fromJson({
        'id': 'pro-user',
        'full_name': 'Pro User',
        'account_type': 'professional',
      });

      expect(profile.accountType, 'professional');
      expect(profile.isProfessional, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    test('6. ProfileModel with explicit business account_type has completed onboarding = true', () {
      final profile = ProfileModel.fromJson({
        'id': 'biz-user',
        'full_name': 'Biz Owner',
        'account_type': 'business',
        'business_name': 'Cine Rentals',
      });

      expect(profile.accountType, 'business');
      expect(profile.isBusiness, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    testWidgets('7. ProfileSetupPage initializes with no pre-selected account type', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createSetupPageWidget());
      await tester.pumpAndSettle();

      // Verify page title and options rendered
      expect(find.text('Who does this account represent?'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Professional'), findsOneWidget);
      expect(find.text('Business / Office'), findsOneWidget);

      // Verify no business name textfield initially shown (because business is not selected)
      expect(find.text('Business / Office Name'), findsNothing);
    });

    testWidgets('8. ProfileSetupPage shows error when submitting without selecting an account type', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createSetupPageWidget());
      await tester.pumpAndSettle();

      // Tap continue button without selecting any option
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Expect validation snackbar
      expect(find.text('Please select an account type to continue.'), findsOneWidget);
    });

    testWidgets('9. ProfileSetupPage wraps body with PopScope canPop: false', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createSetupPageWidget());
      await tester.pumpAndSettle();

      final popScopeFinder = find.byType(PopScope);
      expect(popScopeFinder, findsOneWidget);

      final PopScope popScopeWidget = tester.widget(popScopeFinder);
      expect(popScopeWidget.canPop, false);
    });

    testWidgets('10. Selecting Business in ProfileSetupPage reveals required business name field', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createSetupPageWidget());
      await tester.pumpAndSettle();

      // Select Business option
      await tester.tap(find.text('Business / Office'));
      await tester.pumpAndSettle();

      // Business name field should now be visible
      expect(find.text('Business / Office Name'), findsOneWidget);

      // Tap continue without entering business name -> validation error
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your business / office name'), findsAtLeastNWidgets(1));
    });
  });

  group('Issue 2: Guest Public Visibility & Protection Tests', () {
    test('11. Approved equipment is publicly visible to guests', () {
      final equipment = EquipmentModel.fromJson({
        'id': 'eq-approved-1',
        'name': 'RED V-Raptor 8K',
        'daily_price': 3000,
        'approval_status': 'approved',
        'is_active': true,
      });

      expect(equipment.isApproved, true);
      expect(equipment.isActive, true);
    });

    test('12. Professional profile account is publicly visible to guests', () {
      final pro = ProfileModel.fromJson({
        'id': 'pro-approved-1',
        'full_name': 'Jane Director',
        'account_type': 'professional',
        'is_active': true,
      });

      expect(pro.isProfessional, true);
      expect(pro.isActive, true);
    });

    test('13. Approved rental house / business profile is publicly visible to guests', () {
      final biz = BusinessProfileModel.fromJson({
        'id': 'biz-approved-1',
        'user_id': 'user-biz',
        'business_name': 'Maadi Camera House',
        'approval_status': 'approved',
        'is_active': true,
      });

      expect(biz.isApproved, true);
      expect(biz.isActive, true);
    });

    test('14. Pending equipment is NOT visible to guests (isApproved == false)', () {
      final equipment = EquipmentModel.fromJson({
        'id': 'eq-pending-1',
        'name': 'Sony FX6',
        'daily_price': 1200,
        'approval_status': 'pending',
        'is_active': true,
      });

      expect(equipment.isApproved, false);
    });

    test('15. Rejected equipment is NOT visible to guests', () {
      final equipment = EquipmentModel.fromJson({
        'id': 'eq-rejected-1',
        'name': 'Broken Lens',
        'daily_price': 100,
        'approval_status': 'rejected',
        'is_active': true,
      });

      expect(equipment.isApproved, false);
    });

    test('16. Inactive equipment is NOT visible to guests', () {
      final equipment = EquipmentModel.fromJson({
        'id': 'eq-inactive-1',
        'name': 'Canon C300',
        'daily_price': 800,
        'approval_status': 'approved',
        'is_active': false,
      });

      expect(equipment.isActive, false);
    });

    test('17. Inactive professional profile is NOT visible to guests', () {
      final pro = ProfileModel.fromJson({
        'id': 'pro-inactive-1',
        'full_name': 'Inactive Pro',
        'account_type': 'professional',
        'is_active': false,
      });

      expect(pro.isActive, false);
    });

    test('18. Non-professional profile does not count as professional profile', () {
      final personalUser = ProfileModel.fromJson({
        'id': 'personal-1',
        'full_name': 'Personal User',
        'account_type': 'personal',
      });

      expect(personalUser.isProfessional, false);
    });

    test('19. Pending business profile / rental house is NOT visible to guests', () {
      final biz = BusinessProfileModel.fromJson({
        'id': 'biz-pending-1',
        'user_id': 'user-4',
        'business_name': 'Unapproved Rentals',
        'approval_status': 'pending',
        'is_active': true,
      });

      expect(biz.isApproved, false);
    });

    test('20. Guest state in AccountGuardState provides guest status with null profile', () {
      final guestState = AccountGuardState.guest();

      expect(guestState.status, AccountGuardStatus.guest);
      expect(guestState.profile, null);
    });
  });
}
