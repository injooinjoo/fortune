import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 운세 조건 추상 클래스
///
/// 각 운세마다 "동일 조건"을 다르게 정의하기 위한 베이스 클래스
///
/// 사용 예시:
/// ```dart
/// class LoveFortuneConditions extends FortuneConditions {
///   final SajuData saju;
///   final DateTime date;
///
///   @override
///   String generateHash() => 'saju:${_sha256Hash(saju)}_date:$date';
/// }
/// ```
abstract class FortuneConditions {
  /// 조건 해시 생성 (동일 조건 판단용)
  ///
  /// 같은 해시 = 같은 조건 = DB에서 재사용 가능
  ///
  /// 예시:
  /// - 연애운: 'saju:abc123_date:2025-01-10'
  /// - 타로: 'spread:basic_cards:1,5,10'
  /// - 궁합: 'user:abc123_partner:def456'
  String generateHash();

  /// DB 저장용 JSON
  ///
  /// conditions_data 컬럼에 저장될 전체 조건 데이터
  Map<String, dynamic> toJson();

  /// 인덱싱용 필드 추출
  ///
  /// DB 쿼리 성능을 위해 자주 사용되는 필드를 별도 컬럼으로 저장
  /// 예: saju_data, date, period, selected_cards 등
  Map<String, dynamic> toIndexableFields();

  /// API 호출 페이로드 생성
  ///
  /// OpenAI API에 전달할 프롬프트 생성용 데이터
  Map<String, dynamic> buildAPIPayload();

  /// SHA256 해시 생성 헬퍼 (16자리)
  String _sha256Hash(Object data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16);
  }

  /// 날짜를 YYYY-MM-DD 형식으로 변환
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 사주 데이터 모델
///
/// 운세 조건에서 공통적으로 사용되는 사주 정보
class SajuData {
  final int birthYear;
  final int birthMonth;
  final int birthDay;
  final int birthHour;
  final bool isLunar; // 음력 여부

  const SajuData({
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    required this.birthHour,
    this.isLunar = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'birth_year': birthYear,
      'birth_month': birthMonth,
      'birth_day': birthDay,
      'birth_hour': birthHour,
      'is_lunar': isLunar,
    };
  }

  factory SajuData.fromJson(Map<String, dynamic> json) {
    return SajuData(
      birthYear: json['birth_year'] as int,
      birthMonth: json['birth_month'] as int,
      birthDay: json['birth_day'] as int,
      birthHour: json['birth_hour'] as int,
      isLunar: json['is_lunar'] as bool? ?? false,
    );
  }

  /// 사주 해시 생성 (조건 비교용)
  String toHash() {
    final jsonString = jsonEncode(toJson());
    final bytes = utf8.encode(jsonString);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SajuData &&
          runtimeType == other.runtimeType &&
          birthYear == other.birthYear &&
          birthMonth == other.birthMonth &&
          birthDay == other.birthDay &&
          birthHour == other.birthHour &&
          isLunar == other.isLunar;

  @override
  int get hashCode =>
      birthYear.hashCode ^
      birthMonth.hashCode ^
      birthDay.hashCode ^
      birthHour.hashCode ^
      isLunar.hashCode;
}
