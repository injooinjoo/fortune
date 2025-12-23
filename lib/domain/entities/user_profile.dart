import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String name;
  final DateTime? birthdate;
  final String? birthTime;
  final bool isLunar;
  final String? gender;
  final String? mbti;
  final String? bloodType;
  final String? zodiacSign;
  final String? zodiacAnimal;
  final bool onboardingCompleted;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final int tokenBalance;
  final Map<String, dynamic>? preferences;
  final bool sajuCalculated;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.birthdate,
    this.birthTime,
    this.isLunar = false,
    this.gender,
    this.mbti,
    this.bloodType,
    this.zodiacSign,
    this.zodiacAnimal,
    required this.onboardingCompleted,
    this.isPremium = false,
    this.premiumExpiry,
    this.tokenBalance = 0,
    this.preferences,
    this.sajuCalculated = false,
    required this.createdAt,
    required this.updatedAt});

  // 프로필 완성도 계산
  double get completionPercentage {
    int completedFields = 0;
    const totalFields = 8; // 필수 입력 필드 수

    if (birthdate != null) completedFields++;
    if (birthTime != null) completedFields++;
    if (gender != null) completedFields++;
    if (mbti != null) completedFields++;
    if (bloodType != null) completedFields++;
    if (zodiacSign != null) completedFields++;
    if (zodiacAnimal != null) completedFields++;
    if (name.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  // 프로필이 완성되었는지 확인
  bool get isProfileComplete => completionPercentage >= 80;

  // 프리미엄 활성 상태 확인
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiry == null) return true;
    return premiumExpiry!.isAfter(DateTime.now());
  }

  // 생년월일로부터 나이 계산
  int? get age {
    if (birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      age--;
    }
    return age;
  }

  // 띠 계산 (12간지)
  String? calculateZodiacAnimal() {
    if (birthdate == null) return null;
    
    const animals = [
      '쥐', '소', '호랑이', '토끼', '용', '뱀',
      '말', '양', '원숭이', '닭', '개', '돼지'
    ];
    
    // 음력 변환이 필요한 경우 처리 (간단한 근사치)
    final int year = birthdate!.year;
    if (isLunar) {
      // 음력->양력 변환 로직 필요
      // 여기서는 간단히 처리
    }
    
    // 1900년이 쥐띠 시작
    final index = (year - 1900) % 12;
    return '${animals[index]}띠';
  }

  // 별자리 계산
  String? calculateZodiacSign() {
    if (birthdate == null) return null;
    
    final month = birthdate!.month;
    final day = birthdate!.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '쌍둥이자리';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '게자리';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '천칭자리';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '전갈자리';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '사수자리';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
    return '물고기자리';
  }

  // 사용자 메타데이터 getter (호환성을 위해 추가)
  Map<String, dynamic> get userMetadata {
    return {
      'birthdate': birthdate?.toIso8601String(),
      'birthTime': birthTime,
      'isLunar': isLunar,
      'gender': gender,
      'mbti': mbti,
      'bloodType': bloodType,
      'zodiacSign': zodiacSign,
      'zodiacAnimal': null,
      ...?preferences};
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? birthdate,
    String? birthTime,
    bool? isLunar,
    String? gender,
    String? mbti,
    String? bloodType,
    String? zodiacSign,
    String? zodiacAnimal,
    bool? onboardingCompleted,
    bool? isPremium,
    DateTime? premiumExpiry,
    int? tokenBalance,
    Map<String, dynamic>? preferences,
    bool? sajuCalculated,
    DateTime? createdAt,
    DateTime? updatedAt}) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      birthTime: birthTime ?? this.birthTime,
      isLunar: isLunar ?? this.isLunar,
      gender: gender ?? this.gender,
      mbti: mbti ?? this.mbti,
      bloodType: bloodType ?? this.bloodType,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      zodiacAnimal: zodiacAnimal ?? this.zodiacAnimal,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      preferences: preferences ?? this.preferences,
      sajuCalculated: sajuCalculated ?? this.sajuCalculated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }

  @override
  List<Object?> get props => [
    id, email, name, birthdate, birthTime, isLunar, gender,
    mbti, bloodType, zodiacSign, zodiacAnimal, onboardingCompleted,
    isPremium, premiumExpiry, tokenBalance, preferences, sajuCalculated, 
    createdAt, updatedAt
  ];
}