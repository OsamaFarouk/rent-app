import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/equipment/domain/equipment_model.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/presentation/pages/rental_house_detail_page.dart';
import 'package:rent_app/features/profile/presentation/pages/rental_houses_page.dart';
import 'package:rent_app/features/profile/presentation/providers/business_providers.dart';
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
  group('Rental Houses Discovery & Flow Tests', () {
    const sampleBusiness = BusinessProfileModel(
      id: 'biz-101',
      userId: 'owner-user-1',
      businessName: 'Cairo Cine Rental',
      city: 'Cairo',
      area: 'Zamalek',
      businessDescription: 'Premium cinema camera and lens rental office in Zamalek.',
      phone: '+201001234567',
      whatsapp: '+201001234567',
    );

    testWidgets('RentalHouseCard renders business name, location, and verified badge', (tester) async {
      await tester.pumpWidget(
        _createTestableWidget(
          RentalHouseCard(
            businessName: 'Cairo Cine Rental',
            city: 'Cairo',
            area: 'Zamalek',
            description: 'Top gear rental house',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cairo Cine Rental'), findsOneWidget);
      expect(find.text('Cairo, Zamalek'), findsOneWidget);
      expect(find.text('Top gear rental house'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('RentalHousesPage renders public approved rental houses for guest browsing', (tester) async {
      await tester.pumpWidget(
        _createTestableWidget(
          const RentalHousesPage(),
          overrides: [
            publicApprovedBusinessProfilesProvider(null).overrideWith((ref) async => [sampleBusiness]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rental Houses'), findsWidgets);
      expect(find.text('Cairo Cine Rental'), findsOneWidget);
    });

    testWidgets('RentalHouseDetailPage renders details and Equipment section', (tester) async {
      final sampleEquipment = [
        const EquipmentModel(
          id: 'eq-10',
          ownerId: 'owner-user-1',
          name: 'ARRI Alexa 35',
          dailyPrice: 8000,
        ),
      ];

      await tester.pumpWidget(
        _createTestableWidget(
          const RentalHouseDetailPage(businessProfileId: 'biz-101'),
          overrides: [
            businessProfileDetailProvider('biz-101').overrideWith((ref) async => sampleBusiness),
            businessOwnerEquipmentProvider('owner-user-1').overrideWith((ref) async => sampleEquipment),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cairo Cine Rental'), findsOneWidget);
      expect(find.text('Equipment from this Rental House'), findsOneWidget);
      expect(find.text('ARRI Alexa 35'), findsOneWidget);
    });
  });
}
