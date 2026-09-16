import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// Repository managing Supabase Authentication routines.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Active currentUser getter.
  User? get currentUser => _client.auth.currentUser;

  /// Active session getter.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Registers a new user with Email + Password.
  /// Passes [fullName] and [accountType] in user metadata so trigger populates public.profiles.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'user',
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'account_type': accountType,
      },
    );
  }

  /// Signs in existing user with Email + Password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out current authenticated session.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Triggers password reset email via Supabase Auth.
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
