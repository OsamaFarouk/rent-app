// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/domain/profile_model.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../services/account_guard_service.dart';
import '../services/supabase_service.dart';

enum AccountGuardStatus {
  bootstrap,
  guest,
  authenticating,
  validatingAccount,
  active,
  needsOnboarding,
  suspended,
  deleted,
  missingProfile,
  sessionExpired,
  offline,
}

class AccountGuardState {
  final AccountGuardStatus status;
  final ProfileModel? profile;
  final String? notificationMessage;

  const AccountGuardState({
    required this.status,
    this.profile,
    this.notificationMessage,
  });

  factory AccountGuardState.bootstrap() =>
      const AccountGuardState(status: AccountGuardStatus.bootstrap);

  factory AccountGuardState.guest() =>
      const AccountGuardState(status: AccountGuardStatus.guest);

  factory AccountGuardState.validatingAccount() =>
      const AccountGuardState(status: AccountGuardStatus.validatingAccount);

  factory AccountGuardState.active(ProfileModel profile) =>
      AccountGuardState(status: AccountGuardStatus.active, profile: profile);

  factory AccountGuardState.needsOnboarding(ProfileModel profile) =>
      AccountGuardState(status: AccountGuardStatus.needsOnboarding, profile: profile);

  factory AccountGuardState.suspended(String message) => AccountGuardState(
        status: AccountGuardStatus.suspended,
        notificationMessage: message,
      );

  factory AccountGuardState.deleted(String message) => AccountGuardState(
        status: AccountGuardStatus.deleted,
        notificationMessage: message,
      );

  factory AccountGuardState.missingProfile(String message) => AccountGuardState(
        status: AccountGuardStatus.missingProfile,
        notificationMessage: message,
      );

  factory AccountGuardState.sessionExpired(String message) => AccountGuardState(
        status: AccountGuardStatus.sessionExpired,
        notificationMessage: message,
      );

  factory AccountGuardState.offline(String message) => AccountGuardState(
        status: AccountGuardStatus.offline,
        notificationMessage: message,
      );
}

final accountGuardServiceProvider = Provider<AccountGuardService>((ref) {
  return AccountGuardService();
});

class AccountGuardNotifier extends StateNotifier<AccountGuardState>
    with WidgetsBindingObserver {
  final SupabaseClient _client;
  final ProfileRepository _profileRepo;
  final AccountGuardService _guardService;
  final Ref _ref;

  StreamSubscription<AuthState>? _authSubscription;
  bool _isValidating = false;

  AccountGuardNotifier({
    required ProfileRepository profileRepo,
    required AccountGuardService guardService,
    required Ref ref,
    SupabaseClient? client,
  })  : _profileRepo = profileRepo,
        _guardService = guardService,
        _ref = ref,
        _client = client ?? SupabaseService.client,
        super(AccountGuardState.bootstrap()) {
    WidgetsBinding.instance.addObserver(this);
    _initAuthListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _guardService.unsubscribe();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[AccountGuard] App resumed from background. Maintaining active UI state.');
      final user = _client.auth.currentUser;
      if (user != null && !_guardService.isSubscribed(user.id)) {
        debugPrint('[AccountGuard] Re-subscribing Realtime channel on resume for user ${user.id}.');
        _setupRealtimeSubscription(user.id);
      }
    }
  }

  void _initAuthListener() {
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      debugPrint('[AccountGuard] Auth state event: $event');

      if (event == AuthChangeEvent.signedOut) {
        _handleLocalSignOut(status: AccountGuardStatus.guest);
      } else if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession) {
        // Only run validation if not already in active state
        if (state.status == AccountGuardStatus.bootstrap ||
            state.status == AccountGuardStatus.guest) {
          validateSession();
        }
      }
    });

    // Perform initial validation for current session
    validateSession();
  }

  /// Central session and profile validation method.
  Future<void> validateSession() async {
    if (_isValidating) return;
    _isValidating = true;

    try {
      final session = _client.auth.currentSession;
      final user = session?.user;

      if (session == null || user == null) {
        _guardService.unsubscribe();
        state = AccountGuardState.guest();
        _isValidating = false;
        return;
      }

      // Enter validatingAccount state ONLY during initial application bootstrap launch
      if (state.status == AccountGuardStatus.bootstrap) {
        state = AccountGuardState.validatingAccount();
      }

      // Fetch profile from Supabase with safety timeout
      ProfileModel? profile;
      try {
        profile = await _profileRepo
            .getProfile(user.id)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('[AccountGuard] Network or query error fetching profile: $e');
        if (state.profile != null) {
          _setupRealtimeSubscription(user.id);
          _isValidating = false;
          return;
        }
        // Fallback profile from session metadata if offline/timeout during app startup
        profile = ProfileModel(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name']?.toString() ?? 'User',
          accountType: user.userMetadata?['account_type']?.toString(),
          isActive: true,
        );
      }

      // Missing Profile Handling
      if (profile == null) {
        debugPrint('[AccountGuard] Profile null on first fetch. Retrying safe fetch...');
        await Future.delayed(const Duration(milliseconds: 600));
        try {
          profile = await _profileRepo.getProfile(user.id);
        } catch (_) {}

        if (profile == null) {
          debugPrint('[AccountGuard] Profile deleted or missing in DB for user ${user.id}. Signing out.');
          await notifyDeleted();
          _isValidating = false;
          return;
        }
      }

      // Check Suspended State (is_active == false)
      if (!profile.isActive) {
        debugPrint('[AccountGuard] Account suspended for user ${user.id} (is_active = false). Signing out.');
        await notifySuspended();
        _isValidating = false;
        return;
      }

      // Check Onboarding State
      if (!profile.hasCompletedOnboarding) {
        state = AccountGuardState.needsOnboarding(profile);
      } else {
        state = AccountGuardState.active(profile);
      }

      // Subscribe to Realtime Postgres Changes
      _setupRealtimeSubscription(user.id);
    } finally {
      _isValidating = false;
    }
  }

  void _setupRealtimeSubscription(String userId) {
    _guardService.subscribeToProfile(
      userId: userId,
      onUpdate: (newRecord) async {
        final updatedProfile = ProfileModel.fromJson(newRecord);

        // Check if admin set is_active = false
        if (!updatedProfile.isActive) {
          debugPrint('[AccountGuard] Realtime update: Account suspended (is_active = false).');
          await notifySuspended();
          return;
        }

        // Refresh profile state
        _ref.invalidate(currentProfileProvider);
        if (!updatedProfile.hasCompletedOnboarding) {
          state = AccountGuardState.needsOnboarding(updatedProfile);
        } else {
          state = AccountGuardState.active(updatedProfile);
        }
      },
      onDelete: () async {
        debugPrint('[AccountGuard] Realtime delete: Profile deleted from DB.');
        await notifyDeleted();
      },
    );
  }

  Future<void> notifySuspended() async {
    _guardService.unsubscribe();
    _ref.invalidate(currentProfileProvider);
    try {
      await _client.auth.signOut();
    } catch (_) {}
    state = AccountGuardState.suspended('accountSuspendedMessage');
  }

  Future<void> notifyDeleted() async {
    _guardService.unsubscribe();
    _ref.invalidate(currentProfileProvider);
    try {
      await _client.auth.signOut();
    } catch (_) {}
    state = AccountGuardState.deleted('accountDeletedMessage');
  }

  Future<void> _handleLocalSignOut({required AccountGuardStatus status}) async {
    _guardService.unsubscribe();
    _ref.invalidate(currentProfileProvider);
    state = AccountGuardState(status: status);
  }

  /// Triggers manual sign out from app controls.
  Future<void> signOut() async {
    await _handleLocalSignOut(status: AccountGuardStatus.guest);
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  /// Clears any pending notification message once shown in UI.
  void clearNotificationMessage() {
    if (state.notificationMessage != null) {
      state = AccountGuardState(
        status: state.status,
        profile: state.profile,
        notificationMessage: null,
      );
    }
  }
}

final accountGuardProvider =
    StateNotifierProvider<AccountGuardNotifier, AccountGuardState>((ref) {
  return AccountGuardNotifier(
    profileRepo: ref.watch(profileRepositoryProvider),
    guardService: ref.watch(accountGuardServiceProvider),
    ref: ref,
  );
});
