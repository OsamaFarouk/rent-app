/// Data model representing a public business profile from public.business_profiles table.
class BusinessProfileModel {
  final String id;
  final String userId;
  final String businessName;
  final String? businessAddress;
  final String? businessDescription;
  final String? logoUrl;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String city;
  final String? area;
  final String? websiteUrl;
  final String? workingHours;
  final String approvalStatus;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BusinessProfileModel({
    required this.id,
    required this.userId,
    required this.businessName,
    this.businessAddress,
    this.businessDescription,
    this.logoUrl,
    this.phone,
    this.whatsapp,
    this.email,
    this.city = 'Cairo',
    this.area,
    this.websiteUrl,
    this.workingHours,
    this.approvalStatus = 'approved',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isApproved => approvalStatus == 'approved';

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String? ?? 'Business',
      businessAddress: json['business_address'] as String?,
      businessDescription: json['business_description'] as String?,
      logoUrl: json['logo_url'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String? ?? 'Cairo',
      area: json['area'] as String?,
      websiteUrl: json['website_url'] as String?,
      workingHours: json['working_hours'] as String?,
      approvalStatus: json['approval_status'] as String? ?? 'approved',
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
      'user_id': userId,
      'business_name': businessName,
      'business_address': businessAddress,
      'business_description': businessDescription,
      'logo_url': logoUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'city': city,
      'area': area,
      'website_url': websiteUrl,
      'working_hours': workingHours,
      'approval_status': approvalStatus,
      'is_active': isActive,
    };
  }
}
