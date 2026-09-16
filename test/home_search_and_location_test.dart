import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rent_app/features/equipment/data/equipment_repository.dart';
import 'package:rent_app/features/equipment/domain/equipment_model.dart';
import 'package:rent_app/features/equipment/presentation/providers/equipment_providers.dart';
import 'package:rent_app/features/home/presentation/pages/home_page.dart';
import 'package:rent_app/features/profile/data/business_repository.dart';
import 'package:rent_app/features/profile/data/profile_repository.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/providers/business_providers.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/features/search/data/search_repository.dart';
import 'package:rent_app/features/search/presentation/pages/search_results_page.dart';
import 'package:rent_app/shared/widgets/category_chip.dart';
import 'package:rent_app/l10n/app_localizations.dart';

class FakeEquipmentRepository extends EquipmentRepository {
  final List<EquipmentModel> items;
  FakeEquipmentRepository(this.items);

  @override
  Future<List<EquipmentModel>> getPublicApprovedEquipment({
    String? categoryId,
    String? categoryName,
    String? searchQuery,
    String? city,
  }) async {
    if (city == null || city.isEmpty || city == 'All Locations') return items;
    return items.where((e) => e.city.toLowerCase() == city.toLowerCase()).toList();
  }
}

class FakeProfileRepository extends ProfileRepository {
  final List<ProfileModel> pros;
  FakeProfileRepository(this.pros);

  @override
  Future<List<ProfileModel>> getPublicApprovedProfessionals({
    String? city,
    String? category,
    String? searchQuery,
  }) async {
    if (city == null || city.isEmpty || city == 'All Locations') return pros;
    return pros.where((p) => p.city.toLowerCase() == city.toLowerCase()).toList();
  }
}

class FakeBusinessRepository extends BusinessRepository {
  final List<BusinessProfileModel> businesses;
  FakeBusinessRepository(this.businesses);

  @override
  Future<List<BusinessProfileModel>> getApprovedBusinessProfiles({String? city}) async {
    if (city == null || city.isEmpty || city == 'All Locations') return businesses;
    return businesses.where((b) => b.city.toLowerCase() == city.toLowerCase()).toList();
  }
}

class FakeSearchRepository implements SearchRepository {
  final ({
    List<EquipmentModel> equipment,
    List<ProfileModel> professionals,
    List<BusinessProfileModel> rentalHouses,
  }) results;

  FakeSearchRepository(this.results);

  @override
  Future<
      ({
        List<EquipmentModel> equipment,
        List<ProfileModel> professionals,
        List<BusinessProfileModel> rentalHouses,
      })> searchPublic({
    required String query,
    String? city,
  }) async {
    return results;
  }
}

void main() {
  Widget buildTestableWidget(Widget child, List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => child,
        ),
      ),
    );
  }

  final sampleCairoEquipment = EquipmentModel(
    id: 'eq-1',
    ownerId: 'user-1',
    name: 'Sony FX3 Camera',
    dailyPrice: 1500,
    city: 'Cairo',
    approvalStatus: 'approved',
    availabilityStatus: 'available_now',
    createdAt: DateTime.now(),
  );

  final sampleAlexEquipment = EquipmentModel(
    id: 'eq-2',
    ownerId: 'user-2',
    name: 'RED V-Raptor',
    dailyPrice: 3500,
    city: 'Alexandria',
    approvalStatus: 'approved',
    availabilityStatus: 'available_now',
    createdAt: DateTime.now(),
  );

  const sampleCairoPro = ProfileModel(
    id: 'pro-1',
    fullName: 'Omar Editor',
    email: 'omar@example.com',
    city: 'Cairo',
    accountType: 'professional',
    isActive: true,
  );

  const sampleAlexPro = ProfileModel(
    id: 'pro-2',
    fullName: 'Sara DOP',
    email: 'sara@example.com',
    city: 'Alexandria',
    accountType: 'professional',
    isActive: true,
  );

  final sampleCairoBusiness = BusinessProfileModel(
    id: 'biz-1',
    userId: 'user-3',
    businessName: 'Cairo Cine Rentals',
    city: 'Cairo',
    approvalStatus: 'approved',
    isActive: true,
    createdAt: DateTime.now(),
  );

  final sampleAlexBusiness = BusinessProfileModel(
    id: 'biz-2',
    userId: 'user-4',
    businessName: 'Alex Film House',
    city: 'Alexandria',
    approvalStatus: 'approved',
    isActive: true,
    createdAt: DateTime.now(),
  );

  group('Home Location & Search Behavior Tests', () {
    testWidgets('1. Home Page renders featured items across all locations without location filter chip',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final overrides = [
        equipmentRepositoryProvider.overrideWithValue(
          FakeEquipmentRepository([sampleCairoEquipment, sampleAlexEquipment]),
        ),
        profileRepositoryProvider.overrideWithValue(
          FakeProfileRepository([sampleCairoPro, sampleAlexPro]),
        ),
        businessRepositoryProvider.overrideWithValue(
          FakeBusinessRepository([sampleCairoBusiness, sampleAlexBusiness]),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(const HomePage(), overrides));
      await tester.pumpAndSettle();

      // Verify equipment from both locations are loaded without location filter chip
      expect(find.text('Sony FX3 Camera'), findsOneWidget);
      expect(find.text('RED V-Raptor'), findsOneWidget);
    });

    testWidgets('2. SearchResultsPage renders results for guest users across all locations by default',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeRepo = FakeSearchRepository((
        equipment: [sampleCairoEquipment],
        professionals: <ProfileModel>[],
        rentalHouses: <BusinessProfileModel>[],
      ));

      final overrides = [
        searchRepositoryProvider.overrideWithValue(fakeRepo),
      ];

      await tester.pumpWidget(buildTestableWidget(
        const SearchResultsPage(initialQuery: 'Camera'),
        overrides,
      ));
      await tester.pumpAndSettle();

      // Verify search results page title and equipment card
      expect(find.text('Search Results'), findsOneWidget);
      expect(find.text('All Locations'), findsOneWidget);
      expect(find.text('Sony FX3 Camera'), findsOneWidget);
    });

    testWidgets('3. SearchResultsPage allows filtering by result type chips',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeRepo = FakeSearchRepository((
        equipment: [sampleCairoEquipment],
        professionals: [sampleCairoPro],
        rentalHouses: [sampleCairoBusiness],
      ));

      final overrides = [
        searchRepositoryProvider.overrideWithValue(fakeRepo),
      ];

      await tester.pumpWidget(buildTestableWidget(
        const SearchResultsPage(initialQuery: ''),
        overrides,
      ));
      await tester.pumpAndSettle();

      // Verify category chips exist
      expect(find.byType(CategoryChip), findsNWidgets(4));

      // Tap Equipment filter chip (index 1)
      await tester.tap(find.byType(CategoryChip).at(1));
      await tester.pumpAndSettle();

      expect(find.text('Sony FX3 Camera'), findsOneWidget);

      // Tap Professionals filter chip (index 2)
      await tester.tap(find.byType(CategoryChip).at(2));
      await tester.pumpAndSettle();

      expect(find.text('Omar Editor'), findsOneWidget);

      // Tap Rental Houses filter chip (index 3)
      await tester.tap(find.byType(CategoryChip).at(3));
      await tester.pumpAndSettle();

      expect(find.text('Cairo Cine Rentals'), findsOneWidget);
    });
  });
}
