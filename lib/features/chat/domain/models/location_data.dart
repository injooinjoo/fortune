// 이사 운세용 위치 데이터 모델
//
// GPS, 텍스트 검색, 드롭다운, 지도 탭 등 다양한 방식으로
// 수집된 위치 정보를 담는 모델
class LocationData {
  /// 표시용 이름 (예: "서울 강남구")
  final String displayName;

  /// 시/도 (예: "서울특별시")
  final String? sido;

  /// 시/군/구 (예: "강남구")
  final String? sigungu;

  /// 위도
  final double? latitude;

  /// 경도
  final double? longitude;

  /// 입력 방식
  final LocationInputMethod inputMethod;

  const LocationData({
    required this.displayName,
    this.sido,
    this.sigungu,
    this.latitude,
    this.longitude,
    this.inputMethod = LocationInputMethod.manual,
  });

  /// GPS로 현재 위치 생성
  factory LocationData.fromGPS({
    required String displayName,
    String? sido,
    String? sigungu,
    required double latitude,
    required double longitude,
  }) {
    return LocationData(
      displayName: displayName,
      sido: sido,
      sigungu: sigungu,
      latitude: latitude,
      longitude: longitude,
      inputMethod: LocationInputMethod.gps,
    );
  }

  /// 지도 탭으로 위치 생성
  factory LocationData.fromMap({
    required String displayName,
    String? sido,
    String? sigungu,
    required double latitude,
    required double longitude,
  }) {
    return LocationData(
      displayName: displayName,
      sido: sido,
      sigungu: sigungu,
      latitude: latitude,
      longitude: longitude,
      inputMethod: LocationInputMethod.mapTap,
    );
  }

  /// 텍스트 검색으로 위치 생성
  factory LocationData.fromSearch({
    required String displayName,
    String? sido,
    String? sigungu,
    double? latitude,
    double? longitude,
  }) {
    return LocationData(
      displayName: displayName,
      sido: sido,
      sigungu: sigungu,
      latitude: latitude,
      longitude: longitude,
      inputMethod: LocationInputMethod.search,
    );
  }

  /// 드롭다운 선택으로 위치 생성
  factory LocationData.fromDropdown({
    required String sido,
    required String sigungu,
    double? latitude,
    double? longitude,
  }) {
    return LocationData(
      displayName: '$sido $sigungu',
      sido: sido,
      sigungu: sigungu,
      latitude: latitude,
      longitude: longitude,
      inputMethod: LocationInputMethod.dropdown,
    );
  }

  /// 좌표가 있는지 확인
  bool get hasCoordinates => latitude != null && longitude != null;

  /// 짧은 표시명 (시군구만)
  String get shortName => sigungu ?? displayName;

  /// JSON 변환 (API 전송용)
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'sido': sido,
      'sigungu': sigungu,
      'latitude': latitude,
      'longitude': longitude,
      'inputMethod': inputMethod.name,
    };
  }

  /// 좌표 JSON (Edge Function 전송용)
  Map<String, double>? get coordsJson {
    if (!hasCoordinates) return null;
    return {
      'lat': latitude!,
      'lng': longitude!,
    };
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.displayName == displayName &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(displayName, latitude, longitude);

  LocationData copyWith({
    String? displayName,
    String? sido,
    String? sigungu,
    double? latitude,
    double? longitude,
    LocationInputMethod? inputMethod,
  }) {
    return LocationData(
      displayName: displayName ?? this.displayName,
      sido: sido ?? this.sido,
      sigungu: sigungu ?? this.sigungu,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      inputMethod: inputMethod ?? this.inputMethod,
    );
  }
}

/// 위치 입력 방식
enum LocationInputMethod {
  /// GPS 자동 감지
  gps,

  /// 텍스트 검색
  search,

  /// 시/도 드롭다운 선택
  dropdown,

  /// 지도 탭 선택
  mapTap,

  /// 직접 입력
  manual,

  /// 인기 지역 칩 선택
  quickSelect,
}
