import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Realtime service monitoring Postgres changes on `public.profiles` for the authenticated user.
class AccountGuardService {
  final SupabaseClient _client;
  RealtimeChannel? _channel;
  String? _subscribedUserId;

  AccountGuardService({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Returns whether a realtime channel is currently active for [userId].
  bool isSubscribed(String userId) =>
      _channel != null && _subscribedUserId == userId;

  /// Subscribes to Realtime Postgres changes for [userId]'s profile row.
  void subscribeToProfile({
    required String userId,
    required void Function(Map<String, dynamic> newRecord) onUpdate,
    required void Function() onDelete,
  }) {
    if (isSubscribed(userId)) {
      return; // Prevent duplicate subscriptions
    }

    unsubscribe();

    _subscribedUserId = userId;
    final channelName = 'public_profiles_$userId';

    try {
      _channel = _client
          .channel(channelName)
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: userId,
            ),
            callback: (payload) {
              debugPrint('[AccountGuardService] Profile UPDATE received: ${payload.newRecord}');
              if (payload.newRecord.isNotEmpty) {
                onUpdate(payload.newRecord);
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'profiles',
            callback: (payload) {
              debugPrint('[AccountGuardService] Profile DELETE received: ${payload.oldRecord}');
              final oldId = payload.oldRecord['id']?.toString();
              if (oldId == null || oldId == userId) {
                onDelete();
              }
            },
          );

      _channel?.subscribe((status, [error]) {
        debugPrint('[AccountGuardService] Subscription status for $userId: $status (error: $error)');
        if (status == RealtimeSubscribeStatus.channelError ||
            status == RealtimeSubscribeStatus.timedOut ||
            status == RealtimeSubscribeStatus.closed) {
          debugPrint('[AccountGuardService] Resetting channel reference after $status for user $userId.');
          _channel = null;
          _subscribedUserId = null;
        }
      });
    } catch (e, stack) {
      debugPrint('[AccountGuardService] Safe subscription catch: $e\n$stack');
    }
  }

  /// Cancels and removes the active Realtime channel.
  void unsubscribe() {
    if (_channel != null) {
      try {
        _client.removeChannel(_channel!);
      } catch (e) {
        debugPrint('[AccountGuardService] Error removing channel: $e');
      }
      _channel = null;
      _subscribedUserId = null;
    }
  }
}
