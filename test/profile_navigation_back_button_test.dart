import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rent_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:rent_app/features/professionals/presentation/pages/my_professional_profile_page.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/pages/my_business_profile_page.dart';
import 'package:rent_app/features/profile/presentation/pages/profile_page.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget _createTestRouterWidget({
  required ProfileModel userProfile,
  required String initialLocation,
}) {
  final user = User(
    id: userProfile.id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/my-professional-profile',
        builder: (context, state) => const MyProfessionalProfilePage(),
      ),
      GoRoute(
        path: '/my-business-profile',
        builder: (context, state) => const MyBusinessProfilePage(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(user),
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
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  group('Profile Navigation & Back Arrow Tests', () {
    const proProfile = ProfileModel(
      id: 'pro-user-1',
      fullName: 'Jane Pro',
      accountType: 'professional',
    );

    const bizProfile = ProfileModel(
      id: 'biz-user-1',
      fullName: 'Cine Rentals Owner',
      accountType: 'business',
      businessName: 'Cine Rentals',
    );

    testWidgets('1. MyProfessionalProfilePage renders top back arrow icon button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestRouterWidget(
        userProfile: proProfile,
        initialLocation: '/my-professional-profile',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Professional Profile'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('2. MyBusinessProfilePage renders top back arrow icon button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestRouterWidget(
        userProfile: bizProfile,
        initialLocation: '/my-business-profile',
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Business / Rental House'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('3. Navigating Profile -> Professional Profile -> Top Back returns to Profile page', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestRouterWidget(
        userProfile: proProfile,
        initialLocation: '/profile',
      ));
      await tester.pumpAndSettle();

      // Tap Professional Profile tile on Profile page
      await tester.tap(find.text('Professional Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Professional Info'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Tap top back arrow
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Returned to Profile page
      expect(find.text('Jane Pro'), findsOneWidget);
      expect(find.text('MY ACTIVITY'), findsOneWidget);
    });

    testWidgets('4. Navigating Profile -> Business Profile -> Top Back returns to Profile page', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestRouterWidget(
        userProfile: bizProfile,
        initialLocation: '/profile',
      ));
      await tester.pumpAndSettle();

      // Tap Business Profile tile on Profile page
      await tester.tap(find.text('My Business / Rental House'));
      await tester.pumpAndSettle();

      expect(find.text('Cine Rentals'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Tap top back arrow
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Returned to Profile page
      expect(find.text('MY ACTIVITY'), findsOneWidget);
    });

    testWidgets('5. Opening and popping pages multiple times does not trap or duplicate stack', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestRouterWidget(
        userProfile: proProfile,
        initialLocation: '/profile',
      ));
      await tester.pumpAndSettle();

      // Loop 3 times open -> back
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Professional Profile'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.text('MY ACTIVITY'), findsOneWidget);
      }
    });
  });
}
