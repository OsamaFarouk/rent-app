import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:rent_app/features/professionals/presentation/pages/my_professional_profile_page.dart';
import 'package:rent_app/features/professionals/presentation/pages/professional_detail_page.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rent_app/features/favorites/presentation/providers/favorites_provider.dart';

Widget _createTestApp({
  required Widget child,
  required ProfileModel profile,
  ProfessionalProfileModel? proProfile,
}) {
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
      currentProfessionalProfileProvider.overrideWith((ref) async => proProfile),
      professionalDetailProvider.overrideWith((ref, id) async => profile),
      professionalProfileByIdProvider.overrideWith((ref, id) async => proProfile),
      isProfessionalFavoriteProvider.overrideWith((ref, id) => false),
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
  group('Professional Profile Pricing Model Tests', () {
    test('1. formattedPrice returns "Contact for Price" when pricingType is contact_for_price', () {
      const model = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Cinematographer',
        startingPrice: 2500,
        pricingType: 'contact_for_price',
      );

      expect(model.isContactForPrice, isTrue);
      expect(model.formattedPrice, equals('Contact for Price'));
    });

    test('2. formattedPrice returns "Contact for Price" when startingPrice is null', () {
      const model = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Cinematographer',
        startingPrice: null,
        pricingType: 'per_day',
      );

      expect(model.formattedPrice, equals('Contact for Price'));
    });

    test('3. formattedPrice formats per_day rates correctly', () {
      const model = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Cinematographer',
        startingPrice: 2500,
        pricingType: 'per_day',
      );

      expect(model.isContactForPrice, isFalse);
      expect(model.formattedPrice, equals('2,500 EGP / Day'));
    });

    test('4. formattedPrice formats per_project rates correctly', () {
      const model = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Director',
        startingPrice: 5000,
        pricingType: 'per_project',
      );

      expect(model.isContactForPrice, isFalse);
      expect(model.formattedPrice, equals('5,000 EGP / Project'));
    });
  });

  group('MyProfessionalProfilePage Pricing Section Widget Tests', () {
    testWidgets('5. Renders Starting Rate and Pricing Basis when Contact for Price is OFF', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const profile = ProfileModel(
        id: 'user-1',
        fullName: 'Omar Radwan',
        accountType: 'professional',
      );

      const proProfile = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Director of Photography',
        startingPrice: 2500,
        pricingType: 'per_day',
      );

      await tester.pumpWidget(_createTestApp(
        child: const MyProfessionalProfilePage(),
        profile: profile,
        proProfile: proProfile,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Starting Rate (EGP)'), findsOneWidget);
      expect(find.text('Pricing Basis'), findsOneWidget);
      expect(find.text('2500'), findsOneWidget);
      expect(find.text('Contact for Price'), findsOneWidget);
      expect(find.text('Hide your rate and let clients contact you for pricing.'), findsOneWidget);
      expect(find.text('Willing to Travel / Work Abroad'), findsOneWidget);
    });

    testWidgets('6. Toggling Contact for Price to ON hides Starting Rate & Pricing Basis fields immediately', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const profile = ProfileModel(
        id: 'user-1',
        fullName: 'Omar Radwan',
        accountType: 'professional',
      );

      const proProfile = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Director of Photography',
        startingPrice: 2500,
        pricingType: 'per_day',
      );

      await tester.pumpWidget(_createTestApp(
        child: const MyProfessionalProfilePage(),
        profile: profile,
        proProfile: proProfile,
      ));
      await tester.pumpAndSettle();

      // Fields exist initially
      expect(find.text('Starting Rate (EGP)'), findsOneWidget);
      expect(find.text('Pricing Basis'), findsOneWidget);

      // Tap Contact for Price switch
      final switchFinder = find.widgetWithText(SwitchListTile, 'Contact for Price');
      expect(switchFinder, findsOneWidget);
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Fields MUST be hidden completely
      expect(find.text('Starting Rate (EGP)'), findsNothing);
      expect(find.text('Pricing Basis'), findsNothing);
      expect(find.text('Willing to Travel / Work Abroad'), findsOneWidget);

      // Tap Contact for Price switch back to OFF
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Fields MUST reappear
      expect(find.text('Starting Rate (EGP)'), findsOneWidget);
      expect(find.text('Pricing Basis'), findsOneWidget);
      expect(find.text('Per Day'), findsOneWidget);
    });

    testWidgets('7. Initializing with pricingType = contact_for_price pre-selects switch ON and hides rate fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const profile = ProfileModel(
        id: 'user-1',
        fullName: 'Omar Radwan',
        accountType: 'professional',
      );

      const proProfile = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'user-1',
        professionalTitle: 'Director of Photography',
        startingPrice: 3000,
        pricingType: 'contact_for_price',
      );

      await tester.pumpWidget(_createTestApp(
        child: const MyProfessionalProfilePage(),
        profile: profile,
        proProfile: proProfile,
      ));
      await tester.pumpAndSettle();

      // Starting Rate & Pricing Basis MUST NOT be shown initially
      expect(find.text('Starting Rate (EGP)'), findsNothing);
      expect(find.text('Pricing Basis'), findsNothing);

      // Switch MUST be ON
      final switchWidget = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Contact for Price'));
      expect(switchWidget.value, isTrue);

      // Toggling switch OFF restores fields
      final switchFinder = find.widgetWithText(SwitchListTile, 'Contact for Price');
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Starting Rate (EGP)'), findsOneWidget);
      expect(find.text('Per Day'), findsOneWidget);
    });
  });

  group('ProfessionalDetailPage Public Pricing Display Tests', () {
    testWidgets('8. ProfessionalDetailPage displays Contact for Price when contact_for_price is true', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const profile = ProfileModel(
        id: 'pro-1',
        fullName: 'Tarek Cinematographer',
        accountType: 'professional',
        city: 'Cairo',
      );

      const proProfile = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'pro-1',
        professionalTitle: 'Cinematographer',
        pricingType: 'contact_for_price',
        startingPrice: 2500,
      );

      await tester.pumpWidget(_createTestApp(
        child: const ProfessionalDetailPage(professionalId: 'pro-1'),
        profile: profile,
        proProfile: proProfile,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Starting Rate'), findsOneWidget);
      expect(find.text('Contact for Price'), findsOneWidget);
      expect(find.text('2,500 EGP / Day'), findsNothing);
    });

    testWidgets('9. ProfessionalDetailPage displays formatted rate when Contact for Price is OFF', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const profile = ProfileModel(
        id: 'pro-1',
        fullName: 'Tarek Cinematographer',
        accountType: 'professional',
        city: 'Cairo',
      );

      const proProfile = ProfessionalProfileModel(
        id: 'pro-1',
        profileId: 'pro-1',
        professionalTitle: 'Cinematographer',
        pricingType: 'per_day',
        startingPrice: 2500,
      );

      await tester.pumpWidget(_createTestApp(
        child: const ProfessionalDetailPage(professionalId: 'pro-1'),
        profile: profile,
        proProfile: proProfile,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Starting Rate'), findsOneWidget);
      expect(find.text('2,500 EGP / Day'), findsOneWidget);
    });
  });
}
