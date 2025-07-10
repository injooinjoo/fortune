import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? mbtiType;
  final String? zodiacSign;
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
    this.gender,
    this.mbtiType,
    this.zodiacSign,
    this.profileImageUrl,
    this.preferences,
    this.tokenBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      gender: json['gender'],
      mbtiType: json['mbti_type'],
      zodiacSign: json['zodiac_sign'],
      profileImageUrl: json['profile_image_url'],
      preferences: json['preferences'],
      tokenBalance: json['token_balance'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'gender': gender,
      'mbti_type': mbtiType,
      'zodiac_sign': zodiacSign,
      'profile_image_url': profileImageUrl,
      'preferences': preferences,
      'token_balance': tokenBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? mbtiType,
    String? zodiacSign,
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
      gender: gender ?? this.gender,
      mbtiType: mbtiType ?? this.mbtiType,
      zodiacSign: zodiacSign ?? this.zodiacSign,
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
    gender,
    mbtiType,
    zodiacSign,
    profileImageUrl,
    preferences,
    tokenBalance,
    createdAt,
    updatedAt,
  ];
}