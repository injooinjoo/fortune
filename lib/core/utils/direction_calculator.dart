import 'dart:math' as math;

/// 두 좌표 간 8방위 및 거리 계산 유틸리티
class DirectionCalculator {
  DirectionCalculator._();

  /// 8방위 상수
  static const List<String> directions = [
    '북',
    '동북',
    '동',
    '동남',
    '남',
    '서남',
    '서',
    '서북',
  ];

  /// 8방위 영문 (Edge Function 전송용)
  static const List<String> directionsEnglish = [
    'north',
    'northeast',
    'east',
    'southeast',
    'south',
    'southwest',
    'west',
    'northwest',
  ];

  /// 두 좌표 간 8방위 계산
  ///
  /// [fromLat], [fromLng]: 출발지 좌표
  /// [toLat], [toLng]: 도착지 좌표
  ///
  /// 반환: 8방위 문자열 (한글)
  static String calculate({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    // 각도 계산 (북쪽 0도, 시계방향)
    final dLng = toLng - fromLng;
    final dLat = toLat - fromLat;

    // atan2는 y, x 순서이며 -π ~ π 범위 반환
    // 북쪽을 0도로 하려면 x, y를 바꾸고 동쪽 방향으로 변환
    var angle = math.atan2(dLng, dLat) * (180 / math.pi);

    // 음수 각도를 양수로 변환 (0~360도)
    if (angle < 0) {
      angle += 360;
    }

    // 8방위로 변환 (각 방위는 45도씩)
    // 북 = 337.5~22.5, 동북 = 22.5~67.5, ...
    final index = ((angle + 22.5) / 45).floor() % 8;

    return directions[index];
  }

  /// 두 좌표 간 8방위 계산 (영문)
  static String calculateEnglish({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final koreanDirection = calculate(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
    final index = directions.indexOf(koreanDirection);
    return directionsEnglish[index];
  }

  /// 두 좌표 간 거리 계산 (km)
  /// Haversine 공식 사용
  static double calculateDistance({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    const double earthRadius = 6371; // 지구 반지름 (km)

    final dLat = _toRadians(toLat - fromLat);
    final dLng = _toRadians(toLng - fromLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(fromLat)) *
            math.cos(_toRadians(toLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// 라디안 변환
  static double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  /// 방위와 거리를 포함한 상세 정보 반환
  static Map<String, dynamic> getDirectionInfo({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final direction = calculate(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );

    final directionEnglish = calculateEnglish(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );

    final distance = calculateDistance(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );

    return {
      'direction': direction,
      'directionEnglish': directionEnglish,
      'distanceKm': distance,
      'distanceFormatted': _formatDistance(distance),
    };
  }

  /// 거리 포맷팅
  static String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)}km';
    } else {
      return '${km.round()}km';
    }
  }

  /// 지역명으로 방향 추론 (좌표 없을 때 폴백)
  /// 대략적인 지역별 위치 기반
  static String? inferFromRegionNames(String fromRegion, String toRegion) {
    // 대략적인 지역 좌표 매핑
    const regionCoords = <String, List<double>>{
      '서울': [37.5665, 126.9780],
      '부산': [35.1796, 129.0756],
      '대구': [35.8714, 128.6014],
      '인천': [37.4563, 126.7052],
      '광주': [35.1595, 126.8526],
      '대전': [36.3504, 127.3845],
      '울산': [35.5384, 129.3114],
      '세종': [36.4800, 127.2890],
      '경기': [37.4138, 127.5183],
      '강원': [37.8228, 128.1555],
      '충북': [36.6357, 127.4912],
      '충남': [36.5184, 126.8000],
      '전북': [35.8203, 127.1089],
      '전남': [34.8679, 126.9910],
      '경북': [36.4919, 128.8889],
      '경남': [35.4606, 128.2132],
      '제주': [33.4996, 126.5312],
    };

    // 지역명에서 키 추출
    String? fromKey;
    String? toKey;

    for (final key in regionCoords.keys) {
      if (fromRegion.contains(key)) fromKey = key;
      if (toRegion.contains(key)) toKey = key;
    }

    if (fromKey == null || toKey == null || fromKey == toKey) {
      return null;
    }

    final from = regionCoords[fromKey]!;
    final to = regionCoords[toKey]!;

    return calculate(
      fromLat: from[0],
      fromLng: from[1],
      toLat: to[0],
      toLng: to[1],
    );
  }
}
