import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:rent_app/features/equipment/domain/equipment_model.dart';
import 'package:rent_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:rent_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/professionals/presentation/widgets/professional_card.dart';
import 'package:rent_app/features/profile/presentation/widgets/rental_house_card.dart';
import 'package:rent_app/l10n/app_localizations.dart';

Widget _createTestableWidget(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
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
  group('Final Favorites & Moderation Flow Tests', () {
    const testUser = User(
      id: 'user-777',
      appMetadata: {},
      userMetadata: {'full_name': 'Test User'},
      aud: 'authenticated',
      createdAt: '2026-01-01',
    );

    const sampleEquipment = EquipmentModel(
      id: 'eq-777',
      ownerId: 'owner-1',
      name: 'RED V-Raptor 8K',
      dailyPrice: 4500,
      approvalStatus: 'approved',
    );

    const samplePro = ProfileModel(
      id: 'pro-777',
      fullName: 'Sami Director',
      accountType: 'professional',
      city: 'Cairo',
    );

    const sampleBusiness = BusinessProfileModel(
      id: 'biz-777',
      userId: 'owner-biz',
      businessName: 'Apex Cine Supplies',
      city: 'Cairo',
      area: 'Maadi',
      approvalStatus: 'approved',
    );

    testWidgets('Guest user on FavoritesPage sees empty state with Sign In action', (tester) async {
      await tester.pumpWidget(
        _createTestableWidget(
          const FavoritesPage(),
          overrides: [
            currentUserProvider.overrideWithValue(null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('Authenticated user on FavoritesPage sees 3 tabs and saved Equipment', (tester) async {
      await tester.pumpWidget(
        _createTestableWidget(
          const FavoritesPage(),
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            isEquipmentFavoriteProvider('eq-777').overrideWithValue(true),
            userFavoriteEquipmentListProvider.overrideWith((ref) async => [sampleEquipment]),
            userFavoriteProfessionalsListProvider.overrideWith((ref) async => [samplePro]),
            userFavoriteBusinessesListProvider.overrideWith((ref) async => [sampleBusiness]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Equipment'), findsWidgets);
      expect(find.text('Professionals'), findsWidgets);
      expect(find.text('Rental Houses'), findsWidgets);

      // Tab 1 (Equipment) active by default
      expect(find.text('RED V-Raptor 8K'), findsOneWidget);
    });

    testWidgets('ProfessionalCard renders correctly with favorite heart toggle active', (tester) async {
      await tester.pumpWidget(
        _createTestableWidget(
          ProfessionalCard(
            name: 'Sami Director',
            role: 'Director of Photography',
            rating: '5.0',
            isFavorite: true,
            onFavoriteTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sami Director'), findsOneWidget);
      expect(find.text('Director of Photography'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('RentalHouseCard renders correctly with favorite heart toggle active', (tester) async {
      await tester.pumpWidget(
        _createTestableWidget(
          RentalHouseCard(
            businessName: 'Apex Cine Supplies',
            city: 'Cairo',
            area: 'Maadi',
            isFavorite: true,
            onTap: () {},
            onFavoriteTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apex Cine Supplies'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    test('Moderation status default and active flag checks for discovery', () {
      expect(sampleBusiness.approvalStatus, 'approved');
      expect(sampleBusiness.isActive, true);
      expect(sampleEquipment.approvalStatus, 'approved');
    });
  });
}
