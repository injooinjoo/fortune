import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import '../../core/models/location_info.dart';
import '../../core/services/location_manager.dart';

/// 위치 정보 상태 관리 Provider
///
/// LocationManager를 Riverpod으로 래핑하여 UI에서 사용 가능하게 함
final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LocationInfo>>((ref) {
  return LocationNotifier();
});

/// 위치 정보 상태 관리 클래스
class LocationNotifier extends StateNotifier<AsyncValue<LocationInfo>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    // 초기화 시 위치 정보 가져오기
    _init();
  }

  /// 초기화: 캐시 또는 GPS 위치 가져오기
  Future<void> _init() async {
    try {
      state = const AsyncValue.loading();
      developer.log('🎯 LocationProvider: 초기화 시작');

      // LocationManager로부터 위치 가져오기
      final location = await LocationManager.instance.getCurrentLocation();
      state = AsyncValue.data(location);

      developer.log('✅ LocationProvider: ${location.cityName} 로드 완료');
    } catch (error, stackTrace) {
      developer.log('❌ LocationProvider 초기화 실패: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 위치 정보 새로고침 (GPS 강제 업데이트)
  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      developer.log('🔄 LocationProvider: GPS 강제 새로고침');

      // 강제 새로고침
      final location = await LocationManager.instance.refresh();
      state = AsyncValue.data(location);

      developer.log('✅ LocationProvider: ${location.cityName} 업데이트 완료');
    } catch (error, stackTrace) {
      developer.log('❌ LocationProvider 새로고침 실패: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 권한 요청 후 위치 업데이트
  Future<void> requestPermissionAndUpdate() async {
    try {
      developer.log('🔐 LocationProvider: 권한 요청');

      final hasPermission =
          await LocationManager.instance.requestLocationPermission();

      if (hasPermission) {
        developer.log('✅ 권한 승인 → GPS 업데이트');
        await refresh();
      } else {
        developer.log('⚠️ 권한 거부 → 캐시 사용');
        // 권한 거부 시에도 캐시된 위치 또는 기본값 사용
        final location = await LocationManager.instance.getCurrentLocation();
        state = AsyncValue.data(location);
      }
    } catch (error, stackTrace) {
      developer.log('❌ 권한 요청 실패: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      developer.log('🗑️ LocationProvider: 캐시 초기화');
      await LocationManager.instance.clearCache();
      await _init(); // 재초기화
    } catch (error, stackTrace) {
      developer.log('❌ 캐시 초기화 실패: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 현재 위치 정보 접근 Helper (읽기 전용)
extension LocationProviderExtension on WidgetRef {
  /// 현재 위치 정보 가져오기 (로딩 상태 무시)
  LocationInfo? get currentLocation {
    final asyncValue = watch(locationProvider);
    return asyncValue.when(
      data: (location) => location,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// 현재 지역명 가져오기 (짧은 형식)
  String get currentCityName {
    return currentLocation?.cityName ?? '위치 확인 중';
  }

  /// 전체 지역명 가져오기
  String get currentFullName {
    return currentLocation?.fullName ?? '위치 확인 중';
  }

  /// GPS 위치인지 확인
  bool get isFromGPS {
    return currentLocation?.isFromGPS ?? false;
  }

  /// 표시 가능한 위치 여부 (실제 GPS 위치일 때만 true)
  ///
  /// 위치 권한 거부 시 기본값(강남구)이 반환되는데,
  /// 이 경우 UI에 표시하면 사용자 혼란을 줄 수 있으므로
  /// 실제 GPS 위치일 때만 true 반환
  bool get hasDisplayableLocation {
    final location = currentLocation;
    return location != null && location.isFromGPS;
  }

  /// 표시용 위치명 (권한 거부 시 null)
  ///
  /// 권한 승인 → 실제 지역명 반환
  /// 권한 거부 → null 반환 (UI에서 숨김 처리)
  String? get displayableCityName {
    final location = currentLocation;
    if (location != null && location.isFromGPS) {
      return location.cityName;
    }
    return null;
  }
}
