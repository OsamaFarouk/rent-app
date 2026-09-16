import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/core/providers/account_guard_provider.dart';
import 'package:rent_app/features/profile/domain/profile_model.dart';

void main() {
  group('AccountGuardState Tests', () {
    test('AccountGuardState.bootstrap creates bootstrap status', () {
      final state = AccountGuardState.bootstrap();
      expect(state.status, AccountGuardStatus.bootstrap);
      expect(state.profile, null);
    });

    test('AccountGuardState.guest creates guest status', () {
      final state = AccountGuardState.guest();
      expect(state.status, AccountGuardStatus.guest);
    });

    test('AccountGuardState.active creates active status with profile', () {
      const profile = ProfileModel(
        id: 'user-123',
        fullName: 'Test User',
        accountType: 'personal',
      );
      final state = AccountGuardState.active(profile);
      expect(state.status, AccountGuardStatus.active);
      expect(state.profile?.id, 'user-123');
      expect(state.profile?.profileType, 'user');
    });

    test('AccountGuardState.suspended creates suspended status with notification message', () {
      final state = AccountGuardState.suspended('accountSuspendedMessage');
      expect(state.status, AccountGuardStatus.suspended);
      expect(state.notificationMessage, 'accountSuspendedMessage');
    });

    test('AccountGuardState.deleted creates deleted status with notification message', () {
      final state = AccountGuardState.deleted('accountDeletedMessage');
      expect(state.status, AccountGuardStatus.deleted);
      expect(state.notificationMessage, 'accountDeletedMessage');
    });
  });
}
