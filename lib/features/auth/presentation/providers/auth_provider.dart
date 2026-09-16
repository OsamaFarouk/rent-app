import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/account_guard_provider.dart';
import '../../../profile/domain/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider).asData?.value;
  if (authState != null) {
    return authState.session?.user;
  }
  return ref.read(authRepositoryProvider).currentUser;
});

class AuthStateData {
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  const AuthStateData({
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  AuthStateData copyWith({
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthStateData(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthStateData> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthStateData());

  void clearMessages() {
    if (state.errorMessage != null || state.infoMessage != null) {
      state = state.copyWith(errorMessage: null, infoMessage: null);
    }
  }

  /// Performs authentication AND validates account status synchronously
  /// BEFORE considering the user logged in.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.signIn(
        email: email.trim(),
        password: password,
      );

      final user = response.session?.user;
      if (user == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'invalidCredentialsError');
        return false;
      }

      // LOGIN VALIDATION GATE:
      // Fetch public.profiles BEFORE considering login successful!
      final profileRepo = _ref.read(profileRepositoryProvider);
      ProfileModel? profile;
      try {
        profile = await profileRepo.getProfile(user.id);
      } catch (e) {
        debugPrint('[AuthNotifier] Error fetching profile during login validation: $e');
      }

      if (profile == null) {
        debugPrint('[AuthNotifier] Login validation failed: Profile record missing for ${user.id}.');
        await _ref.read(accountGuardProvider.notifier).notifyDeleted();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'accountDeletedMessage',
        );
        return false;
      }

      if (!profile.isActive) {
        debugPrint('[AuthNotifier] Login validation failed: Account suspended (is_active = false) for ${user.id}.');
        await _ref.read(accountGuardProvider.notifier).notifySuspended();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'accountSuspendedMessage',
        );
        return false;
      }

      // Active valid account -> Validate session with AccountGuard and complete login
      await _ref.read(accountGuardProvider.notifier).validateSession();
      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } on AuthException catch (e) {
      debugPrint('[AuthNotifier] SignIn AuthException: message="${e.message}", code="${e.code}", status="${e.statusCode}"');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e),
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('[AuthNotifier] SignIn unexpected error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'user',
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.signUp(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        accountType: accountType,
      );
      state = state.copyWith(isLoading: false);

      if (response.session == null) {
        state = state.copyWith(
          infoMessage: 'checkEmailVerification',
        );
      }
      return true;
    } on AuthException catch (e) {
      debugPrint('[AuthNotifier] SignUp AuthException: message="${e.message}", code="${e.code}", status="${e.statusCode}"');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e),
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('[AuthNotifier] SignUp unexpected error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.resetPassword(email: email.trim());
      state = state.copyWith(
        isLoading: false,
        infoMessage: 'checkEmailVerification',
      );
      return true;
    } on AuthException catch (e) {
      debugPrint('[AuthNotifier] ResetPassword AuthException: message="${e.message}", code="${e.code}", status="${e.statusCode}"');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthError(e),
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('[AuthNotifier] ResetPassword unexpected error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(accountGuardProvider.notifier).signOut();
      await _repository.signOut();
    } catch (e, stackTrace) {
      debugPrint('[AuthNotifier] SignOut error: $e\n$stackTrace');
    } finally {
      state = const AuthStateData();
    }
  }

  String _mapAuthError(AuthException exception) {
    final lower = exception.message.toLowerCase();
    final code = exception.code?.toLowerCase() ?? '';

    if (code == 'user_already_exists' || lower.contains('already registered') || lower.contains('already exists')) {
      return 'userAlreadyExistsError';
    }
    if (code == 'signup_disabled' || lower.contains('signups not allowed')) {
      return 'signupDisabledError';
    }
    if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
      return 'invalidCredentialsError';
    }
    if (lower.contains('email not confirmed')) {
      return 'checkEmailVerification';
    }
    if (lower.contains('rate limit exceeded') || lower.contains('too many requests')) {
      return 'rateLimitError';
    }
    return exception.message;
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});
