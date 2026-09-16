import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Reusable Supabase Service for Rent App.
class SupabaseService {
  static bool _isInitialized = false;

  /// Initializes Supabase SDK with configuration settings.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabasePublishableKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Supabase client initialized successfully.');
    } catch (e) {
      debugPrint('[SupabaseService] Notice: Supabase initialized with placeholders or offline: $e');
    }
  }

  static SupabaseClient? _dummyClient;

  /// Returns the global active [SupabaseClient] instance.
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return _dummyClient ??= SupabaseClient(
        'https://dummy.supabase.co',
        'dummy-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
    }
  }

  /// Helper getter checking if Supabase has completed initialization.
  static bool get isInitialized => _isInitialized;
}
