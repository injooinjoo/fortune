import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? birthTime;
  final String? gender;
  final String? mbtiType;
  final String? zodiacSign;
  final String? chineseZodiac;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;
  final int tokenBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.birthDate,
    this.birthTime,
    this.gender,
    this.mbtiType,
    this.zodiacSign,
    this.chineseZodiac,
    this.profileImageUrl,
    this.preferences,
    this.tokenBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      birthTime: json['birth_time'] as String?,
      gender: json['gender'] as String?,
      mbtiType: json['mbti_type'] as String?,
      zodiacSign: json['zodiac_sign'] as String?,
      chineseZodiac: json['chinese_zodiac'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      tokenBalance: json['token_balance'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'birth_date': birthDate?.toIso8601String(),
      'birth_time': birthTime,
      'gender': gender,
      'mbti_type': mbtiType,
      'zodiac_sign': zodiacSign,
      'chinese_zodiac': chineseZodiac,
      'profile_image_url': profileImageUrl,
      'preferences': preferences,
      'token_balance': tokenBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Check if user has premium access (temporary compatibility method)
  bool get isPremiumActive => false;

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? birthTime,
    String? gender,
    String? mbtiType,
    String? zodiacSign,
    String? chineseZodiac,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    int? tokenBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: gender ?? this.gender,
      mbtiType: mbtiType ?? this.mbtiType,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      chineseZodiac: chineseZodiac ?? this.chineseZodiac,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    phoneNumber,
    birthDate,
    birthTime,
    gender,
    mbtiType,
    zodiacSign,
    chineseZodiac,
    profileImageUrl,
    preferences,
    tokenBalance,
    createdAt,
    updatedAt,
  ];
}