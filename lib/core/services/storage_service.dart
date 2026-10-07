import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Storage service handling uploads to Supabase Storage.
class StorageService {
  final SupabaseClient _client;

  StorageService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  static const String avatarBucket = 'avatars';

  /// Uploads a rental-house cover using the existing profile-media bucket.
  Future<String> uploadBusinessCover({
    required String userId,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = file.name.split('.').last.toLowerCase();
    final validExtension = ['png', 'jpg', 'jpeg', 'webp'].contains(extension)
        ? extension
        : 'jpg';
    final path =
        '$userId/business_cover_${DateTime.now().microsecondsSinceEpoch}.$validExtension';
    await _client.storage
        .from(avatarBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType:
                'image/${validExtension == 'jpg' ? 'jpeg' : validExtension}',
          ),
        );
    return _client.storage.from(avatarBucket).getPublicUrl(path);
  }

  static const String equipmentBucket = 'equipment';
  static const String portfolioBucket = 'portfolio';

  /// Uploads user profile photo to Supabase Storage avatars bucket.
  /// Path: `{userId}/avatar_{timestamp}.jpg`
  Future<String> uploadProfilePhoto({
    required String userId,
    required XFile file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();
      final validExt =
          (extension == 'png' || extension == 'jpeg' || extension == 'jpg')
          ? extension
          : 'jpg';
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$validExt';

      await _client.storage
          .from(avatarBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$validExt',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage
          .from(avatarBucket)
          .getPublicUrl(fileName);
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint(
        '[StorageService] StorageException during avatar upload: message="${e.message}", statusCode="${e.statusCode}", error="${e.error}"',
      );
      if (e.statusCode == '404' ||
          e.message.toLowerCase().contains('not found')) {
        throw const StorageException(
          'Storage bucket "avatars" was not found in Supabase. Please create a public bucket named "avatars" in Supabase Dashboard -> Storage.',
          statusCode: '404',
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      debugPrint(
        '[StorageService] Unexpected uploadProfilePhoto error: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  /// Uploads an equipment photo to Supabase Storage equipment bucket.
  /// Path: `{userId}/{equipmentId}_{index}_{timestamp}.jpg`
  Future<String> uploadEquipmentPhoto({
    required String userId,
    required String equipmentId,
    required XFile file,
    int index = 0,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();
      final validExt =
          (extension == 'png' || extension == 'jpeg' || extension == 'jpg')
          ? extension
          : 'jpg';
      final fileName =
          '$userId/${equipmentId}_${index}_${DateTime.now().millisecondsSinceEpoch}.$validExt';

      // Try equipment bucket first, fallback to avatars bucket if equipment bucket not created yet
      String targetBucket = equipmentBucket;
      try {
        await _client.storage
            .from(targetBucket)
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$validExt',
                upsert: true,
              ),
            );
      } catch (err) {
        debugPrint(
          '[StorageService] equipment bucket upload failed ($err). Falling back to $avatarBucket...',
        );
        targetBucket = avatarBucket;
        await _client.storage
            .from(targetBucket)
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$validExt',
                upsert: true,
              ),
            );
      }

      final publicUrl = _client.storage
          .from(targetBucket)
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint(
        '[StorageService] uploadEquipmentPhoto error: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  /// Uploads a portfolio photo to Supabase Storage portfolio bucket (falls back to avatars bucket).
  /// Path: `{userId}/portfolio_{timestamp}_{index}.$validExt`
  Future<String> uploadPortfolioPhoto({
    required String userId,
    required XFile file,
    int index = 0,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();
      final validExt =
          (extension == 'png' ||
              extension == 'jpeg' ||
              extension == 'jpg' ||
              extension == 'webp')
          ? extension
          : 'jpg';
      final fileName =
          '$userId/portfolio_${DateTime.now().millisecondsSinceEpoch}_$index.$validExt';

      String targetBucket = portfolioBucket;
      try {
        await _client.storage
            .from(targetBucket)
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$validExt',
                upsert: true,
              ),
            );
      } catch (err) {
        debugPrint(
          '[StorageService] portfolio bucket upload failed ($err). Falling back to $avatarBucket...',
        );
        targetBucket = avatarBucket;
        await _client.storage
            .from(targetBucket)
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$validExt',
                upsert: true,
              ),
            );
      }

      final publicUrl = _client.storage
          .from(targetBucket)
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint(
        '[StorageService] uploadPortfolioPhoto error: $e\n$stackTrace',
      );
      rethrow;
    }
  }
}
