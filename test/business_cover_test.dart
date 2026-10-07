import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/profile/data/business_repository.dart';
import 'package:rent_app/features/profile/domain/business_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';
import 'package:rent_app/features/profile/presentation/pages/my_business_profile_page.dart';
import 'package:rent_app/features/profile/presentation/providers/business_providers.dart';
import 'package:rent_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:rent_app/l10n/app_localizations.dart';

class CoverRepository extends BusinessRepository {
  BusinessProfileModel business = const BusinessProfileModel(
    id: 'business',
    userId: 'owner',
    businessName: 'Rental office',
    coverImageUrl: 'https://example.com/cover.jpg',
  );
  @override
  Future<BusinessProfileModel?> getBusinessProfileById(String id) async =>
      business;
  @override
  Future<BusinessProfileModel?> getBusinessProfileByUserId(String id) async =>
      business;
  @override
  Future<BusinessProfileModel> upsertBusinessProfile(
    BusinessProfileModel value,
  ) async {
    business = value;
    return value;
  }
}

void main() {
  test('Cover URL survives a business profile database round trip', () {
    const business = BusinessProfileModel(
      id: 'business',
      userId: 'owner',
      businessName: 'Rental office',
      coverImageUrl: 'https://example.com/cover.jpg',
    );
    final restored = BusinessProfileModel.fromJson(business.toJson());
    expect(restored.coverImageUrl, business.coverImageUrl);
    expect(
      BusinessProfileModel.fromJson({'id': 'business', 'user_id': 'owner'})
          .coverImageUrl,
      isNull,
    );
  });
  testWidgets('Saved cover can be previewed, removed, and persisted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = CoverRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          businessRepositoryProvider.overrideWithValue(repository),
          currentProfileProvider.overrideWith(
            (ref) async => const ProfileModel(
              id: 'owner',
              fullName: 'Owner',
              accountType: 'business',
            ),
          ),
          currentBusinessProfileProvider.overrideWith(
            (ref) async => repository.business,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyBusinessProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Replace cover'), findsOneWidget);
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .any(
            (image) =>
                image.image is NetworkImage &&
                (image.image as NetworkImage).url ==
                    repository.business.coverImageUrl,
          ),
      isTrue,
    );
    await tester.tap(find.text('Remove cover'));
    await tester.pump();
    expect(find.text('Add cover'), findsOneWidget);
    expect(find.text('Remove cover'), findsNothing);
    final save = find.widgetWithText(ElevatedButton, 'Save changes');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.business.coverImageUrl, isNull);
  });
}
