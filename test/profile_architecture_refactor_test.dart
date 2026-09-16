import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:rent_app/features/professionals/presentation/pages/my_professional_profile_page.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:rent_app/features/profile/presentation/pages/my_business_profile_page.dart';
import 'package:rent_app/features/profile/presentation/pages/profile_page.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget _createTestApp(Widget child, ProfileModel profile) {
  final user = User(
    id: profile.id,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => user),
      currentProfileProvider.overrideWith((ref) async => profile),
      currentBusinessProfileProvider.overrideWith((ref) async {
        if (profile.isBusiness) {
          return BusinessProfileModel(
            id: 'biz-123',
            userId: profile.id,
            businessName: profile.businessName ?? 'Cairo Camera Rentals',
            businessAddress: '14 Road 9, Maadi',
            businessDescription: 'High quality film gear',
            phone: profile.phone,
            whatsapp: profile.whatsapp,
            email: profile.email,
            city: profile.city,
            area: profile.area,
            workingHours: 'Sun – Thu, 10:00 AM – 8:00 PM',
          );
        }
        return null;
      }),
      currentProfessionalProfileProvider.overrideWith((ref) async {
        if (profile.isProfessional) {
          return ProfessionalProfileModel(
            id: 'pro-123',
            profileId: profile.id,
            professionalTitle: 'Director of Photography',
            bio: 'Experienced cinematographer',
            yearsOfExperience: 7,
            approvalStatus: 'approved',
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
  group('Profile Architecture Refactor Requirements Tests', () {
    testWidgets('1. EditProfilePage contains ONLY common account fields for Personal User', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const userProfile = ProfileModel(
        id: 'user-1',
        fullName: 'Ahmed Hassan',
        accountType: 'user',
        email: 'ahmed@example.com',
        phone: '+201000000000',
        city: 'Cairo',
        area: 'Maadi',
      );

      await tester.pumpWidget(_createTestApp(const EditProfilePage(), userProfile));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Ahmed Hassan'), findsOneWidget);
      expect(find.text('Account Type'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);

      // Business fields MUST NOT be present
      expect(find.text('Business Name'), findsNothing);
      expect(find.text('Full Address'), findsNothing);
      expect(find.text('Business Description'), findsNothing);
      expect(find.text('Website URL'), findsNothing);
    });

    testWidgets('2. EditProfilePage contains EXACT SAME common fields for Business Account', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const bizProfile = ProfileModel(
        id: 'biz-owner-1',
        fullName: 'Ahmed Hassan Owner',
        accountType: 'business',
        businessName: 'Cairo Cine Rentals',
        email: 'cairo@example.com',
        city: 'Cairo',
      );

      await tester.pumpWidget(_createTestApp(const EditProfilePage(), bizProfile));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Ahmed Hassan Owner'), findsOneWidget);
      expect(find.text('Business / Rental House'), findsOneWidget);

      // Business fields MUST NOT be present on common Edit Profile
      expect(find.text('Business Name'), findsNothing);
      expect(find.text('Full Address'), findsNothing);
      expect(find.text('Business Description'), findsNothing);
      expect(find.text('Website URL'), findsNothing);
    });

    testWidgets('3. Personal Account ProfilePage shows Personal menu options only', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const userProfile = ProfileModel(
        id: 'user-1',
        fullName: 'Personal User',
        accountType: 'user',
      );

      await tester.pumpWidget(_createTestApp(const ProfilePage(), userProfile));
      await tester.pumpAndSettle();

      expect(find.text('Personal User'), findsOneWidget);
      expect(find.text('My Equipment'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);

      expect(find.text('My Professional Profile'), findsNothing);
      expect(find.text('My Rental House / Business Profile'), findsNothing);
    });

    testWidgets('4. Professional Account ProfilePage shows Professional Profile menu option', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const proProfile = ProfileModel(
        id: 'pro-1',
        fullName: 'Pro User',
        accountType: 'professional',
      );

      await tester.pumpWidget(_createTestApp(const ProfilePage(), proProfile));
      await tester.pumpAndSettle();

      expect(find.text('Pro User'), findsOneWidget);
      expect(find.text('Professional Profile'), findsOneWidget);
      expect(find.text('My Equipment'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('My Business / Rental House'), findsNothing);
    });

    testWidgets('5. Business Account ProfilePage shows My Business / Rental House menu option', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const bizProfile = ProfileModel(
        id: 'biz-1',
        fullName: 'Business Owner',
        accountType: 'business',
        businessName: 'Cairo Rentals',
      );

      await tester.pumpWidget(_createTestApp(const ProfilePage(), bizProfile));
      await tester.pumpAndSettle();

      expect(find.text('Business Owner'), findsOneWidget);
      expect(find.text('My Business / Rental House'), findsOneWidget);
      expect(find.text('My Equipment'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Professional Profile'), findsNothing);
    });

    testWidgets('6. MyProfessionalProfilePage renders professional information and portfolio tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const proProfile = ProfileModel(
        id: 'pro-1',
        fullName: 'Pro Filmmaker',
        accountType: 'professional',
      );

      await tester.pumpWidget(_createTestApp(const MyProfessionalProfilePage(), proProfile));
      await tester.pumpAndSettle();

      expect(find.text('Professional Profile'), findsOneWidget);
      expect(find.text('Professional Info'), findsOneWidget);
      expect(find.text('Portfolio & Work'), findsOneWidget);
      expect(find.text('Social Links'), findsOneWidget);
    });

    testWidgets('7. MyBusinessProfilePage renders dedicated business fields and logo section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const bizProfile = ProfileModel(
        id: 'biz-1',
        fullName: 'Business Owner',
        accountType: 'business',
      );

      await tester.pumpWidget(_createTestApp(const MyBusinessProfilePage(), bizProfile));
      await tester.pumpAndSettle();

      expect(find.text('My Business / Rental House'), findsOneWidget);
      expect(find.text('Business Logo'), findsOneWidget);
      expect(find.text('Business / Office Name'), findsOneWidget);
      expect(find.text('Short Business Description'), findsOneWidget);
      expect(find.text('Full Business Address'), findsOneWidget);
    });
  });
}
