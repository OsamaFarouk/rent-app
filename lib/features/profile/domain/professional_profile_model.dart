import 'dart:convert';
import 'package:flutter/material.dart';
import 'portfolio_item_model.dart';

/// Representation of a custom user-added social or portfolio link.
class CustomSocialLink {
  final String id;
  final String title;
  final String url;

  const CustomSocialLink({
    required this.id,
    required this.title,
    required this.url,
  });

  factory CustomSocialLink.fromJson(Map<String, dynamic> json) {
    return CustomSocialLink(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? json['name'] as String? ?? 'Link',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
    };
  }

  CustomSocialLink copyWith({
    String? id,
    String? title,
    String? url,
  }) {
    return CustomSocialLink(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }
}

/// Helper data holder for rendering active social links on public profiles.
class SocialLinkItem {
  final String key;
  final String label;
  final String url;
  final IconData icon;

  const SocialLinkItem({
    required this.key,
    required this.label,
    required this.url,
    required this.icon,
  });
}

/// Data model representing a public professional profile from public.professional_profiles table.
class ProfessionalProfileModel {
  final String id;
  final String profileId;
  final String? categoryId;
  final String professionalTitle;
  final String? bio;
  final int yearsOfExperience;
  final String? experienceLevel;
  final double? startingPrice;
  final String pricingType; // 'per_day', 'per_project', 'contact_for_price'
  final bool willingToTravel;
  final String? linkedinUrl;
  final String? instagramUrl;
  final String? behanceUrl;
  final String? vimeoUrl;
  final String? youtubeUrl;
  final String? websiteUrl;
  final String approvalStatus; // 'pending', 'approved', 'rejected', 'suspended'
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PortfolioItemModel> portfolioItems;

  const ProfessionalProfileModel({
    required this.id,
    required this.profileId,
    this.categoryId,
    required this.professionalTitle,
    this.bio,
    this.yearsOfExperience = 0,
    this.experienceLevel,
    this.startingPrice,
    this.pricingType = 'per_day',
    this.willingToTravel = false,
    this.linkedinUrl,
    this.instagramUrl,
    this.behanceUrl,
    this.vimeoUrl,
    this.youtubeUrl,
    this.websiteUrl,
    this.approvalStatus = 'approved',
    this.lastUpdated,
    this.createdAt,
    this.updatedAt,
    this.portfolioItems = const [],
  });

  bool get isApproved => approvalStatus == 'approved';

  bool get isContactForPrice => pricingType == 'contact_for_price';

  String get formattedPrice {
    if (isContactForPrice || startingPrice == null || startingPrice == 0) {
      return 'Contact for Price';
    }
    final priceInt = startingPrice!.round();
    final priceStr = priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    if (pricingType == 'per_project') {
      return '$priceStr EGP / Project';
    }
    return '$priceStr EGP / Day';
  }

  Map<String, dynamic> get _parsedWebsiteData {
    if (websiteUrl == null || websiteUrl!.trim().isEmpty) return {};
    final trimmed = websiteUrl!.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  String? get actualWebsiteUrl {
    final meta = _parsedWebsiteData;
    if (meta.containsKey('website') && meta['website'] != null) {
      final val = meta['website'].toString().trim();
      return val.isNotEmpty ? val : null;
    }
    if (_parsedWebsiteData.isEmpty && websiteUrl != null && websiteUrl!.trim().isNotEmpty) {
      return websiteUrl!.trim();
    }
    return null;
  }

  String? get imdbUrl => _getSocialField('imdb');
  String? get artstationUrl => _getSocialField('artstation');
  String? get dribbbleUrl => _getSocialField('dribbble');
  String? get tiktokUrl => _getSocialField('tiktok');
  String? get soundcloudUrl => _getSocialField('soundcloud');
  String? get spotifyUrl => _getSocialField('spotify');
  String? get otherPortfolioUrl => _getSocialField('other_portfolio');

  List<CustomSocialLink> get customSocialLinks {
    final meta = _parsedWebsiteData;
    if (meta.containsKey('custom_links') && meta['custom_links'] is List) {
      return (meta['custom_links'] as List)
          .map((e) => CustomSocialLink.fromJson(e as Map<String, dynamic>))
          .where((l) => l.url.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  String? _getSocialField(String key) {
    final meta = _parsedWebsiteData;
    if (meta.containsKey(key) && meta[key] != null) {
      final val = meta[key].toString().trim();
      return val.isNotEmpty ? val : null;
    }
    return null;
  }

  static String encodeWebsiteData({
    String? website,
    String? imdb,
    String? artstation,
    String? dribbble,
    String? tiktok,
    String? soundcloud,
    String? spotify,
    String? otherPortfolio,
    List<CustomSocialLink>? customLinks,
  }) {
    final map = <String, dynamic>{};
    if (website != null && website.trim().isNotEmpty) map['website'] = website.trim();
    if (imdb != null && imdb.trim().isNotEmpty) map['imdb'] = imdb.trim();
    if (artstation != null && artstation.trim().isNotEmpty) map['artstation'] = artstation.trim();
    if (dribbble != null && dribbble.trim().isNotEmpty) map['dribbble'] = dribbble.trim();
    if (tiktok != null && tiktok.trim().isNotEmpty) map['tiktok'] = tiktok.trim();
    if (soundcloud != null && soundcloud.trim().isNotEmpty) map['soundcloud'] = soundcloud.trim();
    if (spotify != null && spotify.trim().isNotEmpty) map['spotify'] = spotify.trim();
    if (otherPortfolio != null && otherPortfolio.trim().isNotEmpty) map['other_portfolio'] = otherPortfolio.trim();

    if (customLinks != null && customLinks.isNotEmpty) {
      map['custom_links'] = customLinks.map((l) => l.toJson()).toList();
    }

    if (map.isEmpty) return '';
    if (map.length == 1 && map.containsKey('website')) {
      return map['website'].toString();
    }
    return jsonEncode(map);
  }

  List<SocialLinkItem> get allSocialLinks {
    final links = <SocialLinkItem>[];

    void addIfValid(String key, String label, String? url, IconData icon) {
      if (url != null && url.trim().isNotEmpty) {
        links.add(SocialLinkItem(
          key: key,
          label: label,
          url: url.trim(),
          icon: icon,
        ));
      }
    }

    addIfValid('linkedin', 'LinkedIn', linkedinUrl, Icons.link_rounded);
    addIfValid('instagram', 'Instagram', instagramUrl, Icons.camera_alt_outlined);
    addIfValid('behance', 'Behance', behanceUrl, Icons.palette_outlined);
    addIfValid('vimeo', 'Vimeo Profile', vimeoUrl, Icons.movie_outlined);
    addIfValid('youtube', 'YouTube Channel', youtubeUrl, Icons.video_library_outlined);
    addIfValid('imdb', 'IMDb Profile', imdbUrl, Icons.movie_creation_outlined);
    addIfValid('artstation', 'ArtStation', artstationUrl, Icons.brush_outlined);
    addIfValid('dribbble', 'Dribbble', dribbbleUrl, Icons.sports_basketball_outlined);
    addIfValid('tiktok', 'TikTok', tiktokUrl, Icons.music_note_outlined);
    addIfValid('soundcloud', 'SoundCloud', soundcloudUrl, Icons.cloud_outlined);
    addIfValid('spotify', 'Spotify', spotifyUrl, Icons.library_music_outlined);
    addIfValid('website', 'Personal Website', actualWebsiteUrl, Icons.language_rounded);
    addIfValid('other_portfolio', 'Other Portfolio', otherPortfolioUrl, Icons.folder_open_rounded);

    for (final custom in customSocialLinks) {
      if (custom.url.trim().isNotEmpty) {
        links.add(SocialLinkItem(
          key: 'custom_${custom.id}',
          label: custom.title,
          url: custom.url.trim(),
          icon: Icons.link_rounded,
        ));
      }
    }

    return links;
  }

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) {
    List<PortfolioItemModel> items = [];
    if (json['portfolio_items'] != null && json['portfolio_items'] is List) {
      items = (json['portfolio_items'] as List)
          .map((e) => PortfolioItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ProfessionalProfileModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      categoryId: json['category_id'] as String?,
      professionalTitle: json['professional_title'] as String? ?? 'Professional',
      bio: json['bio'] as String?,
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
      experienceLevel: json['experience_level'] as String?,
      startingPrice: (json['starting_price'] as num?)?.toDouble(),
      pricingType: json['pricing_type'] as String? ?? 'per_day',
      willingToTravel: json['willing_to_travel'] as bool? ?? false,
      linkedinUrl: json['linkedin_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      behanceUrl: json['behance_url'] as String?,
      vimeoUrl: json['vimeo_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      approvalStatus: json['approval_status'] as String? ?? 'approved',
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      portfolioItems: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'category_id': categoryId,
      'professional_title': professionalTitle,
      'bio': bio,
      'years_of_experience': yearsOfExperience,
      'experience_level': experienceLevel,
      'starting_price': startingPrice,
      'pricing_type': pricingType,
      'willing_to_travel': willingToTravel,
      'linkedin_url': linkedinUrl,
      'instagram_url': instagramUrl,
      'behance_url': behanceUrl,
      'vimeo_url': vimeoUrl,
      'youtube_url': youtubeUrl,
      'website_url': websiteUrl,
      'approval_status': approvalStatus,
    };
  }

  ProfessionalProfileModel copyWith({
    String? id,
    String? profileId,
    String? categoryId,
    String? professionalTitle,
    String? bio,
    int? yearsOfExperience,
    String? experienceLevel,
    double? startingPrice,
    String? pricingType,
    bool? willingToTravel,
    String? linkedinUrl,
    String? instagramUrl,
    String? behanceUrl,
    String? vimeoUrl,
    String? youtubeUrl,
    String? websiteUrl,
    String? approvalStatus,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PortfolioItemModel>? portfolioItems,
  }) {
    return ProfessionalProfileModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      categoryId: categoryId ?? this.categoryId,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      bio: bio ?? this.bio,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      startingPrice: startingPrice ?? this.startingPrice,
      pricingType: pricingType ?? this.pricingType,
      willingToTravel: willingToTravel ?? this.willingToTravel,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      behanceUrl: behanceUrl ?? this.behanceUrl,
      vimeoUrl: vimeoUrl ?? this.vimeoUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      portfolioItems: portfolioItems ?? this.portfolioItems,
    );
  }
}

