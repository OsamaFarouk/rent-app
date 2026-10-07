import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/profile/domain/portfolio_item_model.dart';
import 'package:rent_app/features/profile/domain/professional_completion_status.dart';
import 'package:rent_app/features/profile/domain/professional_profile_model.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';

void main() {
  group('ProfessionalCompletionStatus Tests', () {
    test('Calculates 0% completion for empty profile', () {
      final status = ProfessionalCompletionStatus.calculate(
        profile: null,
        proProfile: null,
      );

      expect(status.totalCount, equals(8));
      expect(status.completedCount, equals(0));
      expect(status.percentage, equals(0));
      expect(status.isFullyCompleted, isFalse);
      expect(status.missingItems.length, equals(8));
    });

    test('Calculates partial completion when only personal info is filled', () {
      const profile = ProfileModel(
        id: 'user1',
        fullName: 'John Director',
        profilePhoto: 'https://photo.jpg',
        email: 'john@example.com',
        phone: '+20100000000',
        city: 'Cairo',
        accountType: 'professional',
      );

      final status = ProfessionalCompletionStatus.calculate(
        profile: profile,
        proProfile: null,
      );

      // 5 personal fields completed out of 8 total = (5/8)*100 = 62.5% -> 63%
      expect(status.completedCount, equals(5));
      expect(status.percentage, equals(63));
      expect(status.isFullyCompleted, isFalse);
    });

    test('Calculates 100% completion when all 8 mandatory fields are present', () {
      const profile = ProfileModel(
        id: 'user1',
        fullName: 'Jane DOP',
        profilePhoto: 'https://photo.jpg',
        email: 'jane@example.com',
        phone: '+20111111111',
        city: 'Alexandria',
        accountType: 'professional',
      );

      const proProfile = ProfessionalProfileModel(
        id: 'pro1',
        profileId: 'user1',
        professionalTitle: 'Director of Photography',
        categoryId: 'cat_cinematography',
        bio: 'Over 10 years experience filming feature films and high-end commercials across Egypt.',
        willingToTravel: true,
        approvalStatus: 'draft',
        portfolioItems: [
          PortfolioItemModel(
            id: 'item1',
            professionalProfileId: 'pro1',
            title: 'Feature Film 2025',
          ),
        ],
      );

      final status = ProfessionalCompletionStatus.calculate(
        profile: profile,
        proProfile: proProfile,
      );

      expect(status.totalCount, equals(8));
      expect(status.completedCount, equals(8));
      expect(status.percentage, equals(100));
      expect(status.isFullyCompleted, isTrue);
      expect(status.missingItems, isEmpty);
    });
  });
}
