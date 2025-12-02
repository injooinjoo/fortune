import '../fortune_conditions.dart';

/// 집 풍수 진단 조건
///
/// 특징:
/// - 현재 살고 있는 집의 풍수를 진단
/// - 주소, 집 유형, 층수, 대문 방향으로 조건 구분
///
/// 예시:
/// ```dart
/// final conditions = HomeFengshuiFortuneConditions(
///   address: '서울 강남구',
///   homeType: '아파트',
///   floor: 10,
///   doorDirection: '남',
/// );
/// ```
class HomeFengshuiFortuneConditions extends FortuneConditions {
  final String address;
  final String homeType;
  final int floor;
  final String doorDirection;

  HomeFengshuiFortuneConditions({
    required this.address,
    required this.homeType,
    required this.floor,
    required this.doorDirection,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'address:${address.hashCode}',
      'homeType:${homeType.hashCode}',
      'floor:$floor',
      'doorDirection:${doorDirection.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'homeType': homeType,
      'floor': floor,
      'doorDirection': doorDirection,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      // 개인정보 보호를 위해 해시만 저장
      'address_hash': address.hashCode.toString(),
      'home_type': homeType,
      'floor': floor,
      'door_direction': doorDirection,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'home-fengshui',
      'address': address,
      'home_type': homeType,
      'floor': floor,
      'door_direction': doorDirection,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeFengshuiFortuneConditions &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          homeType == other.homeType &&
          floor == other.floor &&
          doorDirection == other.doorDirection;

  @override
  int get hashCode =>
      address.hashCode ^
      homeType.hashCode ^
      floor.hashCode ^
      doorDirection.hashCode;

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
