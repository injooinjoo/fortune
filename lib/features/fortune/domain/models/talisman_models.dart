import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/ds_colors.dart';

/// 부적 타입 정의
enum TalismanType {
  wealth('재물부적', '재물운과 금전운을 상승시키는 부적', Icons.monetization_on_rounded,
      [DSColors.warning, DSColors.warning]),
  love('연애부적', '사랑과 인연을 불러오는 부적', Icons.favorite_rounded,
      [DSColors.accentSecondary, Color(0xFFDB2777)]),
  health('건강부적', '건강과 장수를 기원하는 부적', Icons.favorite_border_rounded,
      [DSColors.success, Color(0xFF059669)]),
  protection('액막이부적', '나쁜 기운과 액운을 막아주는 부적', Icons.shield_rounded,
      [Color(0xFF6B7280), Color(0xFF4B5563)]),
  success('성공부적', '목표 달성과 성공을 돕는 부적', Icons.star_rounded,
      [DSColors.warning, DSColors.accentSecondary]),
  study('학업부적', '학업 성취와 합격을 기원하는 부적', Icons.school_rounded,
      [DSColors.accentSecondary, DSColors.info]),
  business('사업부적', '사업 번창과 번영을 기원하는 부적', Icons.business_rounded,
      [DSColors.accentSecondary, Color(0xFF6D28D9)]),
  family('가정화목부적', '가족의 화목과 평안을 지키는 부적', Icons.home_rounded,
      [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
  custom('맞춤형부적', '개인의 소원을 담은 특별한 부적', Icons.auto_awesome_rounded,
      [DSColors.accentSecondary, Color(0xFF8B008B)]);

  final String displayName;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const TalismanType(
      this.displayName, this.description, this.icon, this.gradientColors);
}

/// 부적 디자인 요소
class TalismanDesign {
  final String baseSymbol; // 기본 부적 문양 (SVG path나 이미지 URL)
  final Color primaryColor; // 주 색상
  final Color secondaryColor; // 보조 색상
  final String personalText; // 개인화 문구
  final String protectionSymbol; // 보호 상징
  final DateTime createdDate; // 생성일
  final String? userBirthInfo; // 사용자 생년월일 정보
  final String? userName; // 사용자 이름
  final Map<String, dynamic>? customSymbols; // 추가 커스텀 심볼

  TalismanDesign(
      {required this.baseSymbol,
      required this.primaryColor,
      required this.secondaryColor,
      required this.personalText,
      required this.protectionSymbol,
      required this.createdDate,
      this.userBirthInfo,
      this.userName,
      this.customSymbols});

  // JSON 변환을 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'baseSymbol': baseSymbol,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'personalText': personalText,
      'protectionSymbol': protectionSymbol,
      'createdDate': createdDate.toIso8601String(),
      'userBirthInfo': userBirthInfo,
      'userName': userName,
      'customSymbols': null
    };
  }

  factory TalismanDesign.fromJson(Map<String, dynamic> json) {
    return TalismanDesign(
      baseSymbol: json['baseSymbol'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      personalText: json['personalText'],
      protectionSymbol: json['protectionSymbol'],
      createdDate: DateTime.parse(json['createdDate']),
      userBirthInfo: json['userBirthInfo'],
      userName: json['userName'],
      customSymbols: json['customSymbols'],
    );
  }
}

/// 부적 결과 모델
class TalismanResult {
  final TalismanType type;
  final TalismanDesign design;
  final String meaning; // 부적의 의미
  final String usage; // 사용법
  final String effectiveness; // 효과
  final List<String> precautions; // 주의사항
  final String? shareableImageUrl; // 공유용 이미지 URL
  final Map<String, dynamic>? additionalInfo; // 추가 정보

  TalismanResult(
      {required this.type,
      required this.design,
      required this.meaning,
      required this.usage,
      required this.effectiveness,
      required this.precautions,
      this.shareableImageUrl,
      this.additionalInfo});

  // JSON 변환을 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'design': design.toJson(),
      'meaning': meaning,
      'usage': usage,
      'effectiveness': effectiveness,
      'precautions': precautions,
      'shareableImageUrl': shareableImageUrl,
      'additionalInfo': null
    };
  }

  factory TalismanResult.fromJson(Map<String, dynamic> json) {
    return TalismanResult(
      type: TalismanType.values.firstWhere((t) => t.name == json['type']),
      design: TalismanDesign.fromJson(json['design']),
      meaning: json['meaning'],
      usage: json['usage'],
      effectiveness: json['effectiveness'],
      precautions: List<String>.from(json['precautions']),
      shareableImageUrl: json['shareableImageUrl'],
      additionalInfo: json['additionalInfo'],
    );
  }
}

/// 부적 생성 요청 모델
class TalismanRequest {
  final TalismanType type;
  final String? personalWish; // 개인 소원
  final String? birthDate; // 생년월일
  final String? userName; // 사용자 이름
  final Map<String, dynamic>? customization; // 커스터마이징 옵션

  TalismanRequest(
      {required this.type,
      this.personalWish,
      this.birthDate,
      this.userName,
      this.customization});

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'personalWish': personalWish,
      'birthDate': birthDate,
      'userName': userName,
      'customization': null
    };
  }
}

/// 부적 히스토리 모델
class TalismanHistory {
  final String id;
  final TalismanResult talisman;
  final DateTime createdAt;
  final bool isShared;
  final int shareCount;

  TalismanHistory(
      {required this.id,
      required this.talisman,
      required this.createdAt,
      this.isShared = false,
      this.shareCount = 0});
}
