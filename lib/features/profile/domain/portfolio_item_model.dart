import 'dart:convert';

/// Data model representing a portfolio item from public.portfolio_items table.
class PortfolioItemModel {
  final String id;
  final String professionalProfileId;
  final String title;
  final String? description;
  final String? mediaUrl;
  final String mediaType; // 'image', 'video'
  final String? externalUrl;
  final int displayOrder;
  final DateTime? createdAt;

  const PortfolioItemModel({
    required this.id,
    required this.professionalProfileId,
    required this.title,
    this.description,
    this.mediaUrl,
    this.mediaType = 'image',
    this.externalUrl,
    this.displayOrder = 0,
    this.createdAt,
  });

  bool get isVideo => mediaType == 'video';
  bool get isImage => mediaType == 'image';

  Map<String, dynamic> get _parsedMetadata {
    if (description == null || description!.trim().isEmpty) return {};
    final trimmed = description!.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final map = jsonDecode(trimmed);
        if (map is Map<String, dynamic>) return map;
      } catch (_) {}
    }
    return {};
  }

  String get workType {
    final meta = _parsedMetadata;
    if (meta.containsKey('work_type') && meta['work_type'] != null) {
      final wt = meta['work_type'].toString().trim();
      if (wt.isNotEmpty) return wt;
    }
    return isVideo ? 'Video' : 'Project';
  }

  String? get userRole {
    final meta = _parsedMetadata;
    if (meta.containsKey('user_role') && meta['user_role'] != null) {
      final role = meta['user_role'].toString().trim();
      return role.isNotEmpty ? role : null;
    }
    return null;
  }

  String? get year {
    final meta = _parsedMetadata;
    if (meta.containsKey('year') && meta['year'] != null) {
      final y = meta['year'].toString().trim();
      return y.isNotEmpty ? y : null;
    }
    return null;
  }

  String get shortDescription {
    final meta = _parsedMetadata;
    if (meta.containsKey('summary') && meta['summary'] != null) {
      return meta['summary'].toString();
    }
    return description ?? '';
  }

  String? get client {
    final meta = _parsedMetadata;
    if (meta.containsKey('client') && meta['client'] != null) {
      final c = meta['client'].toString().trim();
      return c.isNotEmpty ? c : null;
    }
    return null;
  }

  String? get tools {
    final meta = _parsedMetadata;
    if (meta.containsKey('tools') && meta['tools'] != null) {
      final t = meta['tools'].toString().trim();
      return t.isNotEmpty ? t : null;
    }
    return null;
  }

  String? get externalProjectLink {
    final meta = _parsedMetadata;
    if (meta.containsKey('external_project_link') && meta['external_project_link'] != null) {
      final link = meta['external_project_link'].toString().trim();
      return link.isNotEmpty ? link : null;
    }
    return null;
  }

  List<String> get galleryImages {
    final meta = _parsedMetadata;
    if (meta.containsKey('gallery') && meta['gallery'] is List) {
      return (meta['gallery'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  static String encodeDescription({
    required String summary,
    required String workType,
    String? userRole,
    String? year,
    String? client,
    String? tools,
    String? externalProjectLink,
    List<String>? gallery,
  }) {
    final map = <String, dynamic>{
      'summary': summary,
      'work_type': workType,
    };
    if (userRole != null && userRole.trim().isNotEmpty) {
      map['user_role'] = userRole.trim();
    }
    if (year != null && year.trim().isNotEmpty) {
      map['year'] = year.trim();
    }
    if (client != null && client.trim().isNotEmpty) {
      map['client'] = client.trim();
    }
    if (tools != null && tools.trim().isNotEmpty) {
      map['tools'] = tools.trim();
    }
    if (externalProjectLink != null && externalProjectLink.trim().isNotEmpty) {
      map['external_project_link'] = externalProjectLink.trim();
    }
    if (gallery != null && gallery.isNotEmpty) {
      map['gallery'] = gallery;
    }
    return jsonEncode(map);
  }

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      id: json['id'] as String,
      professionalProfileId: json['professional_profile_id'] as String,
      title: json['title'] as String? ?? 'Untitled Project',
      description: json['description'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String? ?? 'image',
      externalUrl: json['external_url'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_profile_id': professionalProfileId,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'external_url': externalUrl,
      'display_order': displayOrder,
    };
  }

  PortfolioItemModel copyWith({
    String? id,
    String? professionalProfileId,
    String? title,
    String? description,
    String? mediaUrl,
    String? mediaType,
    String? externalUrl,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return PortfolioItemModel(
      id: id ?? this.id,
      professionalProfileId: professionalProfileId ?? this.professionalProfileId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      externalUrl: externalUrl ?? this.externalUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
