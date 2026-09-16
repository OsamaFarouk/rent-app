import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';

void main() {
  group('ProfileModel Tests', () {
    test('ProfileModel fromJson and toJson works correctly with profileType as single source of truth', () {
      final json = {
        'id': 'test-uuid-123',
        'full_name': 'Ahmed Nabil',
        'email': 'ahmed@example.com',
        'phone': '+201000000000',
        'whatsapp': '+201000000000',
        'city': 'Cairo',
        'area': 'Maadi',
        'profile_type': 'business',
        'is_active': true,
      };

      final profile = ProfileModel.fromJson(json);

      expect(profile.id, 'test-uuid-123');
      expect(profile.fullName, 'Ahmed Nabil');
      expect(profile.email, 'ahmed@example.com');
      expect(profile.city, 'Cairo');
      expect(profile.phone, '+201000000000');
      expect(profile.whatsapp, '+201000000000');
      expect(profile.profileType, 'business');
      expect(profile.hasCompletedOnboarding, true);

      final serialized = profile.toJson();
      expect(serialized['id'], 'test-uuid-123');
      expect(serialized['full_name'], 'Ahmed Nabil');
      expect(serialized['phone'], '+201000000000');
      expect(serialized['whatsapp'], '+201000000000');
      expect(serialized['profile_type'], 'business');
    });

    test('ProfileModel handles null/empty and custom whatsapp number correctly', () {
      final jsonCustom = {
        'id': 'test-uuid-999',
        'full_name': 'Custom WhatsApp User',
        'phone': '+201000000000',
        'whatsapp': '+201222222222',
        'city': 'Cairo',
      };

      final profileCustom = ProfileModel.fromJson(jsonCustom);
      expect(profileCustom.phone, '+201000000000');
      expect(profileCustom.whatsapp, '+201222222222');
      expect(profileCustom.phone == profileCustom.whatsapp, false);

      final jsonNullWhatsapp = {
        'id': 'test-uuid-888',
        'full_name': 'Null WhatsApp User',
        'phone': '+201000000000',
        'whatsapp': null,
        'city': 'Cairo',
      };

      final profileNull = ProfileModel.fromJson(jsonNullWhatsapp);
      expect(profileNull.phone, '+201000000000');
      expect(profileNull.whatsapp, null);
      expect(profileNull.toJson()['whatsapp'], null);
    });

    test('ProfileModel detects uncompleted onboarding when profile_type is NULL', () {
      final json = {
        'id': 'new-user-456',
        'full_name': 'New User',
        'email': 'new@example.com',
        'profile_type': null,
        'is_active': true,
      };

      final profile = ProfileModel.fromJson(json);

      expect(profile.profileType, null);
      expect(profile.hasCompletedOnboarding, false);
    });

    test('ProfileModel copyWith updates profileType cleanly', () {
      const profile = ProfileModel(
        id: 'user-1',
        fullName: 'Original Name',
        city: 'Cairo',
      );

      final updated = profile.copyWith(
        fullName: 'New Name',
        area: 'Zamalek',
        accountType: 'personal',
      );

      expect(updated.id, 'user-1');
      expect(updated.fullName, 'New Name');
      expect(updated.city, 'Cairo');
      expect(updated.area, 'Zamalek');
      expect(updated.profileType, 'user');
      expect(updated.hasCompletedOnboarding, true);
    });
  });
}
