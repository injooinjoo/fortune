import 'dart:convert';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_info.dart';
import '../constants/location_mappings.dart';

/// 앱 전체 위치 정보 중앙 관리 서비스
///
/// Singleton 패턴으로 구현되며, 다음 우선순위로 위치를 제공합니다:
/// 1. 캐시된 위치 (24시간 이내)
/// 2. 실시간 GPS 위치 (권한 있을 때)
/// 3. 기본 위치 (서울 강남구)
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  static LocationManager get instance => _instance;

  LocationManager._internal();

  /// SharedPreferences 캐시 키
  static const String _cacheKey = 'last_location_cache';

  /// 현재 위치 캐시 (메모리)
  LocationInfo? _currentLocation;

  /// 현재 위치 가져오기
  ///
  /// 우선순위:
  /// 1. 메모리 캐시 (유효한 경우)
  /// 2. SharedPreferences 캐시 (유효한 경우)
  /// 3. 실시간 GPS (권한 있을 때)
  /// 4. 기본값 (서울 강남구)
  Future<LocationInfo> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // 1. 메모리 캐시 확인 (강제 새로고침 아닐 때)
      if (!forceRefresh &&
          _currentLocation != null &&
          _currentLocation!.isValid()) {
        // GPS 캐시인 경우, 권한이 여전히 있는지 확인
        if (_currentLocation!.isFromGPS) {
          final hasPermission = await hasLocationPermission();
          if (!hasPermission) {
            developer.log('⚠️ LocationManager: GPS 권한 취소됨, 메모리 캐시 무효화');
            _currentLocation = null;
            // SharedPreferences 캐시도 정리
            await clearCache();
          } else {
            developer.log(
                '🎯 LocationManager: 메모리 캐시 사용 - ${_currentLocation!.cityName}');
            return _currentLocation!;
          }
        } else {
          developer.log(
              '🎯 LocationManager: 메모리 캐시 사용 - ${_currentLocation!.cityName}');
          return _currentLocation!;
        }
      }

      // 2. SharedPreferences 캐시 확인
      if (!forceRefresh) {
        final cachedLocation = await getLastSavedLocation();
        if (cachedLocation != null && cachedLocation.isValid()) {
          // GPS 캐시인 경우, 권한이 여전히 있는지 확인
          if (cachedLocation.isFromGPS) {
            final hasPermission = await hasLocationPermission();
            if (!hasPermission) {
              // 권한이 취소됨 → 캐시 무효화하고 기본값 사용
              developer.log('⚠️ LocationManager: GPS 권한 취소됨, 캐시 무효화');
              await clearCache();
              final defaultLocation = LocationInfo.defaultSeoul();
              _currentLocation = defaultLocation;
              return defaultLocation;
            }
          }
          _currentLocation = cachedLocation;
          developer
              .log('💾 LocationManager: 캐시 사용 - ${cachedLocation.cityName}');
          return cachedLocation;
        }
      }

      // 3. 실시간 GPS 시도
      if (await hasLocationPermission()) {
        developer.log('📍 LocationManager: GPS 위치 가져오기 시도...');
        final gpsLocation = await _getGPSLocation();
        if (gpsLocation != null) {
          _currentLocation = gpsLocation;
          await saveLocation(gpsLocation);
          developer.log('✅ LocationManager: GPS 성공 - ${gpsLocation.cityName}');
          return gpsLocation;
        }
      }

      // 4. 기본값 반환 (서울 강남구)
      developer.log('⚠️ LocationManager: 기본값 사용 - 강남구');
      final defaultLocation = LocationInfo.defaultSeoul();
      _currentLocation = defaultLocation;
      await saveLocation(defaultLocation);
      return defaultLocation;
    } catch (e) {
      developer.log('❌ LocationManager 에러: $e');
      final defaultLocation = LocationInfo.defaultSeoul();
      _currentLocation = defaultLocation;
      return defaultLocation;
    }
  }

  /// GPS로부터 실시간 위치 가져오기
  Future<LocationInfo?> _getGPSLocation() async {
    try {
      // 위치 정확도 설정
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100,
      );

      // 현재 위치 가져오기 (타임아웃 10초)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('GPS timeout');
        },
      );

      // 역 지오코딩 (좌표 → 주소)
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Geocoding timeout');
        },
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;

      // 지역명 생성
      final cityName = _extractCityName(place);
      final fullName = _extractFullName(place);

      return LocationInfo(
        cityName: cityName,
        fullName: fullName,
        latitude: position.latitude,
        longitude: position.longitude,
        isFromGPS: true,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      developer.log('❌ GPS 위치 가져오기 실패: $e');
      return null;
    }
  }

  /// Placemark로부터 짧은 지역명 추출
  String _extractCityName(Placemark place) {
    // 한국 위치인 경우
    if (place.isoCountryCode == 'KR') {
      // 구/군 이름 우선
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        return place.subLocality!;
      }
      // 시/도 이름
      if (place.locality != null && place.locality!.isNotEmpty) {
        return place.locality!;
      }
      // administrativeArea (광역시/도)
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        return LocationMappings.extractDistrict(place.administrativeArea!);
      }
    } else {
      // 해외 위치인 경우
      final String cityName =
          place.locality ?? place.administrativeArea ?? 'Unknown';
      // 영문 → 한글 변환
      return LocationMappings.toKorean(cityName);
    }

    return '알 수 없음';
  }

  /// Placemark로부터 전체 지역명 추출
  String _extractFullName(Placemark place) {
    // 한국 위치인 경우
    if (place.isoCountryCode == 'KR') {
      final parts = <String>[];

      // 시/도
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }

      // 구/군
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        parts.add(place.subLocality!);
      } else if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }

      return parts.join(' ');
    } else {
      // 해외 위치인 경우
      final parts = <String>[];

      // 나라 이름
      if (place.country != null && place.country!.isNotEmpty) {
        parts.add(LocationMappings.toKorean(place.country!));
      }

      // 도시 이름
      final String cityName = place.locality ?? place.administrativeArea ?? '';
      if (cityName.isNotEmpty) {
        parts.add(LocationMappings.toKorean(cityName));
      }

      return parts.join(' ');
    }
  }

  /// 마지막 저장된 위치 불러오기
  Future<LocationInfo?> getLastSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);

      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final location = LocationInfo.fromJson(json);

      // 유효성 검사
      if (!location.isValid()) {
        developer.log('⏰ LocationManager: 캐시 만료 (24시간 초과)');
        return null;
      }

      return location;
    } catch (e) {
      developer.log('❌ 캐시 불러오기 실패: $e');
      return null;
    }
  }

  /// 위치 저장하기
  Future<void> saveLocation(LocationInfo location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(location.toJson());
      await prefs.setString(_cacheKey, jsonString);
      _currentLocation = location;
      developer.log('💾 LocationManager: 위치 저장 - ${location.cityName}');
    } catch (e) {
      developer.log('❌ 위치 저장 실패: $e');
    }
  }

  /// 위치 권한 확인
  Future<bool> hasLocationPermission() async {
    try {
      // 서비스 활성화 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('⚠️ 위치 서비스가 비활성화되어 있습니다');
        return false;
      }

      // 권한 확인
      final LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        developer.log('⚠️ 위치 권한이 거부되었습니다');
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('⚠️ 위치 권한이 영구적으로 거부되었습니다');
        return false;
      }

      return true;
    } catch (e) {
      developer.log('❌ 위치 권한 확인 실패: $e');
      return false;
    }
  }

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    try {
      // 서비스 활성화 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('⚠️ 위치 서비스가 비활성화되어 있습니다');
        return false;
      }

      // 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // 권한 요청
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('⚠️ 사용자가 위치 권한을 거부했습니다');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('⚠️ 위치 권한이 영구적으로 거부되었습니다');
        return false;
      }

      developer.log('✅ 위치 권한 승인됨');
      return true;
    } catch (e) {
      developer.log('❌ 위치 권한 요청 실패: $e');
      return false;
    }
  }

  /// 지역명 포맷팅 (짧은 형식)
  ///
  /// 예: "서울 강남구" → "강남구"
  String formatLocationName(String fullName) {
    return LocationMappings.extractDistrict(fullName);
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      _currentLocation = null;
      developer.log('🗑️ LocationManager: 캐시 초기화');
    } catch (e) {
      developer.log('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 강제 새로고침 (GPS 위치 다시 가져오기)
  Future<LocationInfo> refresh() async {
    return getCurrentLocation(forceRefresh: true);
  }
}
