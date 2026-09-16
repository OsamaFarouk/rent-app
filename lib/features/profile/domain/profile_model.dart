/// Data model representing a user profile from public.profiles table.
class ProfileModel {
  final String id;
  final String fullName;
  final String? profilePhoto;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String city;
  final String? area;
  final String? accountType; // 'personal', 'professional', 'business'
  final String? businessName;
  final String? businessAddress;
  final String? businessDescription;
  final String? websiteUrl;
  final String? workingHours;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    this.profilePhoto,
    this.phone,
    this.whatsapp,
    this.email,
    this.city = 'Cairo',
    this.area,
    this.accountType,
    this.businessName,
    this.businessAddress,
    this.businessDescription,
    this.websiteUrl,
    this.workingHours,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Alias getter for backward compatibility with UI code expecting profileType
  String? get profileType => isUser ? 'user' : accountType;

  /// Account type getters for convenience and permission logic
  bool get isUser => accountType == 'user' || accountType == 'personal';
  bool get isProfessional => accountType == 'professional';
  bool get isBusiness => accountType == 'business';

  /// Alias for backward compatibility
  bool get isPersonal => isUser;

  /// Display text helper for user-facing UI
  String get accountTypeDisplayName {
    if (isBusiness) return 'Business / Rental House';
    if (isProfessional) return 'Professional';
    return 'User';
  }

  /// Single source of truth for onboarding setup completion:
  /// True ONLY if accountType is set and non-empty.
  bool get hasCompletedOnboarding => accountType != null && accountType!.isNotEmpty;

  /// Alias for backward compatibility
  bool get profileSetupCompleted => hasCompletedOnboarding;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawAccountType = json['account_type'] as String?;
    final rawProfileType = json['profile_type'] as String?;

    String? resolvedAccountType;
    if (rawAccountType != null && rawAccountType.isNotEmpty) {
      resolvedAccountType = (rawAccountType == 'personal' || rawAccountType == 'individual')
          ? 'user'
          : rawAccountType;
    } else if (rawProfileType != null && rawProfileType.isNotEmpty) {
      resolvedAccountType = (rawProfileType == 'personal' || rawProfileType == 'individual')
          ? 'user'
          : rawProfileType;
    }

    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'User',
      profilePhoto: json['profile_photo'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String? ?? 'Cairo',
      area: json['area'] as String?,
      accountType: resolvedAccountType,
      businessName: json['business_name'] as String?,
      businessAddress: json['business_address'] as String?,
      businessDescription: json['business_description'] as String?,
      websiteUrl: json['website_url'] as String?,
      workingHours: json['working_hours'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'city': city,
      'area': area,
      'account_type': accountType,
      'profile_type': profileType,
      'business_name': businessName,
      'business_address': businessAddress,
      'business_description': businessDescription,
      'website_url': websiteUrl,
      'working_hours': workingHours,
      'is_active': isActive,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? profilePhoto,
    String? phone,
    String? whatsapp,
    String? email,
    String? city,
    String? area,
    String? accountType,
    String? businessName,
    String? businessAddress,
    String? businessDescription,
    String? websiteUrl,
    String? workingHours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      city: city ?? this.city,
      area: area ?? this.area,
      accountType: accountType ?? this.accountType,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessDescription: businessDescription ?? this.businessDescription,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
