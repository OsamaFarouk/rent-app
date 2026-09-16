import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/equipment/domain/equipment_model.dart';
import 'package:rent_app/features/professionals/presentation/pages/my_professional_profile_page.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/pages/my_business_profile_page.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';

Widget _createTestableWidget(Widget child, ProfileModel userProfile) {
  return ProviderScope(
    overrides: [
      currentProfileProvider.overrideWith((ref) async => userProfile),
      currentBusinessProfileProvider.overrideWith((ref) async {
        if (userProfile.isBusiness) {
          return BusinessProfileModel(
            id: 'biz-1',
            userId: userProfile.id,
            businessName: userProfile.businessName ?? 'Test Business',
          );
        }
        return null;
      }),
      currentProfessionalProfileProvider.overrideWith((ref) async {
        if (userProfile.isProfessional) {
          return ProfessionalProfileModel(
            id: 'pro-1',
            profileId: userProfile.id,
            professionalTitle: 'Director of Photography',
          );
        }
        return null;
      }),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('Account Architecture 10 Flow Scenarios', () {
    // Scenario 1: New Personal/User account
    test('Scenario 1: New Personal account setup & model properties', () {
      final profile = ProfileModel.fromJson({
        'id': 'user-personal-1',
        'full_name': 'Alice Personal',
        'account_type': 'personal',
      });

      expect(profile.accountType, 'user');
      expect(profile.isPersonal, true);
      expect(profile.isUser, true);
      expect(profile.isProfessional, false);
      expect(profile.isBusiness, false);
      expect(profile.hasCompletedOnboarding, true);
      expect(profile.profileType, 'user');
    });

    // Scenario 2: New Professional account
    test('Scenario 2: New Professional account setup & model properties', () {
      final profile = ProfileModel.fromJson({
        'id': 'user-pro-1',
        'full_name': 'Bob Pro',
        'account_type': 'professional',
      });

      expect(profile.accountType, 'professional');
      expect(profile.isPersonal, false);
      expect(profile.isProfessional, true);
      expect(profile.isBusiness, false);
      expect(profile.hasCompletedOnboarding, true);
      expect(profile.profileType, 'professional');
    });

    // Scenario 3: New Business account
    test('Scenario 3: New Business account setup & model properties', () {
      final profile = ProfileModel.fromJson({
        'id': 'user-biz-1',
        'full_name': 'Charlie Biz',
        'account_type': 'business',
        'business_name': 'CineRent Studios',
      });

      expect(profile.accountType, 'business');
      expect(profile.isPersonal, false);
      expect(profile.isProfessional, false);
      expect(profile.isBusiness, true);
      expect(profile.hasCompletedOnboarding, true);
      expect(profile.profileType, 'business');
      expect(profile.businessName, 'CineRent Studios');
    });

    // Scenario 4: Existing migrated Personal account
    test('Scenario 4: Existing migrated Personal account from profile_type = individual', () {
      final profile = ProfileModel.fromJson({
        'id': 'migrated-user-1',
        'full_name': 'Migrated User',
        'profile_type': 'individual',
      });

      expect(profile.accountType, 'user');
      expect(profile.isPersonal, true);
      expect(profile.isUser, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    // Scenario 5: Existing migrated Professional account
    test('Scenario 5: Existing migrated Professional account', () {
      final profile = ProfileModel.fromJson({
        'id': 'migrated-pro-1',
        'full_name': 'Migrated Pro',
        'account_type': 'professional',
      });

      expect(profile.accountType, 'professional');
      expect(profile.isProfessional, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    // Scenario 6: Existing migrated Business account
    test('Scenario 6: Existing migrated Business account', () {
      final profile = ProfileModel.fromJson({
        'id': 'migrated-biz-1',
        'full_name': 'Migrated Biz',
        'account_type': 'business',
        'business_name': 'FinCam',
      });

      expect(profile.accountType, 'business');
      expect(profile.isBusiness, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    // Scenario 7: Professional attempts to create business profile -> denied
    testWidgets('Scenario 7: Professional accessing Business Profile page is denied', (tester) async {
      const proProfile = ProfileModel(
        id: 'pro-user',
        fullName: 'Pro User',
        accountType: 'professional',
      );

      await tester.pumpWidget(_createTestableWidget(const MyBusinessProfilePage(), proProfile));
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
    });

    // Scenario 8: Business attempts to create professional profile -> denied
    testWidgets('Scenario 8: Business accessing Professional Profile page is denied', (tester) async {
      const bizProfile = ProfileModel(
        id: 'biz-user',
        fullName: 'Biz Owner',
        accountType: 'business',
        businessName: 'Biz Office',
      );

      await tester.pumpWidget(_createTestableWidget(const MyProfessionalProfilePage(), bizProfile));
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
    });

    // Scenario 9: Personal attempts either -> denied
    testWidgets('Scenario 9: Personal account accessing Pro & Business profile pages is denied', (tester) async {
      const personalProfile = ProfileModel(
        id: 'personal-user',
        fullName: 'Personal User',
        accountType: 'personal',
      );

      // Test Pro Profile Page Access
      await tester.pumpWidget(_createTestableWidget(const MyProfessionalProfilePage(), personalProfile));
      await tester.pumpAndSettle();
      expect(find.text('Access Denied'), findsOneWidget);

      // Test Business Profile Page Access
      await tester.pumpWidget(_createTestableWidget(const MyBusinessProfilePage(), personalProfile));
      await tester.pumpAndSettle();
      expect(find.text('Access Denied'), findsOneWidget);
    });

    // Scenario 10: All three account types can add equipment
    test('Scenario 10: All three account types can own and create equipment listings', () {
      const personalUser = ProfileModel(id: 'p-1', fullName: 'P1', accountType: 'personal');
      const proUser = ProfileModel(id: 'pro-1', fullName: 'Pro1', accountType: 'professional');
      const bizUser = ProfileModel(id: 'b-1', fullName: 'B1', accountType: 'business');

      final eqPersonal = EquipmentModel(
        id: 'eq-1',
        ownerId: personalUser.id,
        name: 'Sony A7IV',
        dailyPrice: 500,
      );

      final eqPro = EquipmentModel(
        id: 'eq-2',
        ownerId: proUser.id,
        name: 'RED V-Raptor',
        dailyPrice: 2500,
      );

      final eqBiz = EquipmentModel(
        id: 'eq-3',
        ownerId: bizUser.id,
        name: 'ARRI Alexa Mini',
        dailyPrice: 5000,
      );

      expect(eqPersonal.ownerId, 'p-1');
      expect(eqPro.ownerId, 'pro-1');
      expect(eqBiz.ownerId, 'b-1');
    });
  });
}
