import 'professional_profile_model.dart';
import 'profile_model.dart';

class MandatoryCheckItem {
  final String key;
  final String label;
  final bool isCompleted;
  final String route; // '/edit-profile' or '/my-professional-profile'
  final String category; // 'Personal' or 'Professional'

  const MandatoryCheckItem({
    required this.key,
    required this.label,
    required this.isCompleted,
    required this.route,
    required this.category,
  });
}

class ProfessionalCompletionStatus {
  final int totalCount;
  final int completedCount;
  final int percentage;
  final List<MandatoryCheckItem> items;

  const ProfessionalCompletionStatus({
    required this.totalCount,
    required this.completedCount,
    required this.percentage,
    required this.items,
  });

  bool get isFullyCompleted => percentage >= 100;

  List<MandatoryCheckItem> get missingItems => items.where((i) => !i.isCompleted).toList();
  List<MandatoryCheckItem> get completedItems => items.where((i) => i.isCompleted).toList();

  /// Grouped high-level summary items for card display (matching reference UI)
  List<String> get summaryMissingLabels {
    final list = <String>[];
    if (items.any((i) => i.key == 'phone' && !i.isCompleted)) {
      list.add('Add phone number');
    }
    if (items.any((i) => i.key == 'photo' && !i.isCompleted)) {
      list.add('Add profile photo');
    }
    if (items.any((i) => (i.category == 'Professional') && !i.isCompleted)) {
      list.add('Complete professional details');
    }
    if (items.any((i) => i.key == 'city' && !i.isCompleted)) {
      list.add('Select city');
    }
    return list;
  }

  static bool isLinkValid(String key, String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed.contains(' ')) return false;

    final lowerKey = key.toLowerCase();
    final lowerUrl = trimmed.toLowerCase();

    if (lowerKey.contains('instagram')) {
      return lowerUrl.contains('instagram.com') ||
          (trimmed.startsWith('@') && trimmed.length > 2) ||
          (!trimmed.contains('/') && !trimmed.contains('.') && trimmed.length >= 3);
    }
    if (lowerKey.contains('linkedin')) {
      return lowerUrl.contains('linkedin.com');
    }
    if (lowerKey.contains('behance')) {
      return lowerUrl.contains('behance.net') || lowerUrl.contains('behance.com');
    }
    if (lowerKey.contains('vimeo')) {
      return lowerUrl.contains('vimeo.com');
    }
    if (lowerKey.contains('youtube')) {
      return lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be');
    }
    if (lowerKey.contains('imdb')) {
      return lowerUrl.contains('imdb.com');
    }
    if (lowerKey.contains('artstation')) {
      return lowerUrl.contains('artstation.com');
    }
    if (lowerKey.contains('dribbble')) {
      return lowerUrl.contains('dribbble.com');
    }
    if (lowerKey.contains('tiktok')) {
      return lowerUrl.contains('tiktok.com');
    }
    if (lowerKey.contains('soundcloud')) {
      return lowerUrl.contains('soundcloud.com');
    }
    if (lowerKey.contains('spotify')) {
      return lowerUrl.contains('spotify.com');
    }

    // Generic Website / Other / Custom links validation
    if (lowerUrl.startsWith('http://') || lowerUrl.startsWith('https://')) {
      return lowerUrl.contains('.') && lowerUrl.split('.').last.isNotEmpty;
    }
    return lowerUrl.contains('.') && !lowerUrl.startsWith('.') && !lowerUrl.endsWith('.');
  }

  static bool hasValidPortfolioOrLink(ProfessionalProfileModel? proProfile) {
    if (proProfile == null) return false;
    if (proProfile.portfolioItems.isNotEmpty) return true;
    return proProfile.allSocialLinks.any((link) => isLinkValid(link.key, link.url));
  }

  factory ProfessionalCompletionStatus.calculate({
    required ProfileModel? profile,
    required ProfessionalProfileModel? proProfile,
  }) {
    final items = <MandatoryCheckItem>[
      MandatoryCheckItem(
        key: 'name',
        label: 'Full name',
        isCompleted: profile?.fullName.trim().isNotEmpty ?? false,
        route: '/edit-profile',
        category: 'Personal',
      ),
      MandatoryCheckItem(
        key: 'photo',
        label: 'Profile photo',
        isCompleted: profile?.profilePhoto?.trim().isNotEmpty ?? false,
        route: '/edit-profile',
        category: 'Personal',
      ),
      MandatoryCheckItem(
        key: 'email',
        label: 'Email address',
        isCompleted: profile?.email?.trim().isNotEmpty ?? false,
        route: '/edit-profile',
        category: 'Personal',
      ),
      MandatoryCheckItem(
        key: 'phone',
        label: 'Phone number',
        isCompleted: profile?.phone?.trim().isNotEmpty ?? false,
        route: '/edit-profile',
        category: 'Personal',
      ),
      MandatoryCheckItem(
        key: 'city',
        label: 'City',
        isCompleted: profile?.city.trim().isNotEmpty ?? false,
        route: '/edit-profile',
        category: 'Personal',
      ),
      MandatoryCheckItem(
        key: 'title',
        label: 'Professional title',
        isCompleted: proProfile != null &&
            proProfile.professionalTitle.trim().isNotEmpty &&
            proProfile.professionalTitle.trim() != 'Professional',
        route: '/my-professional-profile',
        category: 'Professional',
      ),
      MandatoryCheckItem(
        key: 'travel',
        label: 'Willing to travel preference',
        isCompleted: proProfile != null,
        route: '/my-professional-profile',
        category: 'Professional',
      ),
      MandatoryCheckItem(
        key: 'portfolio',
        label: 'At least one portfolio item or external work link',
        isCompleted: hasValidPortfolioOrLink(proProfile),
        route: '/my-professional-profile',
        category: 'Professional',
      ),
    ];

    final total = items.length;
    final completed = items.where((i) => i.isCompleted).length;
    final pct = ((completed / total) * 100).round();

    return ProfessionalCompletionStatus(
      totalCount: total,
      completedCount: completed,
      percentage: pct,
      items: items,
    );
  }
}
