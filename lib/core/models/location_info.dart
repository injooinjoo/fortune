/// 위치 정보 모델
///
/// 앱 전체에서 사용되는 위치 정보를 담는 데이터 클래스
class LocationInfo {
  /// 지역명 (짧은 형식, 예: "강남구", "도쿄")
  final String cityName;

  /// 전체 지역명 (예: "서울 강남구", "일본 도쿄")
  final String fullName;

  /// 위도
  final double? latitude;

  /// 경도
  final double? longitude;

  /// GPS로부터 가져온 실시간 위치인지 여부
  /// true: 실시간 GPS, false: 캐시 또는 기본값
  final bool isFromGPS;

  /// 위치 정보 타임스탬프
  final DateTime timestamp;

  const LocationInfo({
    required this.cityName,
    required this.fullName,
    this.latitude,
    this.longitude,
    required this.isFromGPS,
    required this.timestamp,
  });

  /// 서울 기본값 (위치 권한 없을 때 폴백)
  factory LocationInfo.defaultSeoul() {
    return LocationInfo(
      cityName: '강남구',
      fullName: '서울 강남구',
      latitude: 37.5665,
      longitude: 126.9780,
      isFromGPS: false,
      timestamp: DateTime.now(),
    );
  }

  /// JSON으로부터 생성
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      cityName: json['cityName'] as String,
      fullName: json['fullName'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isFromGPS: json['isFromGPS'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'fullName': fullName,
      'latitude': latitude,
      'longitude': longitude,
      'isFromGPS': isFromGPS,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 복사본 생성
  LocationInfo copyWith({
    String? cityName,
    String? fullName,
    double? latitude,
    double? longitude,
    bool? isFromGPS,
    DateTime? timestamp,
  }) {
    return LocationInfo(
      cityName: cityName ?? this.cityName,
      fullName: fullName ?? this.fullName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFromGPS: isFromGPS ?? this.isFromGPS,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 캐시 유효성 검사 (1시간)
  bool isValid() {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inHours < 1;
  }

  @override
  String toString() {
    return 'LocationInfo(cityName: $cityName, fullName: $fullName, '
        'isFromGPS: $isFromGPS, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationInfo &&
        other.cityName == cityName &&
        other.fullName == fullName &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isFromGPS == isFromGPS;
  }

  @override
  int get hashCode {
    return Object.hash(
      cityName,
      fullName,
      latitude,
      longitude,
      isFromGPS,
    );
  }
}
