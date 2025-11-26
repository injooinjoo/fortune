import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import '../core/utils/logger.dart';

/// App Tracking Transparency (ATT) 서비스
/// iOS 14.5+ 필수 요구사항
class AttService {
  static final AttService _instance = AttService._internal();
  factory AttService() => _instance;
  AttService._internal();

  static AttService get instance => _instance;

  bool _isRequested = false;
  TrackingStatus _status = TrackingStatus.notDetermined;

  bool get isRequested => _isRequested;
  TrackingStatus get status => _status;

  /// 추적이 허용되었는지 확인
  bool get isTrackingAuthorized => _status == TrackingStatus.authorized;

  /// 추적이 거부되었는지 확인
  bool get isTrackingDenied =>
      _status == TrackingStatus.denied ||
      _status == TrackingStatus.restricted;

  /// ATT 권한 요청
  /// iOS에서만 작동하며, Android에서는 즉시 반환
  Future<TrackingStatus> requestTrackingAuthorization() async {
    // iOS가 아니면 스킵
    if (!Platform.isIOS) {
      Logger.info('🔒 [ATT] Not iOS platform, skipping ATT request');
      _status = TrackingStatus.authorized;
      _isRequested = true;
      return _status;
    }

    try {
      Logger.info('🔒 [ATT] Checking current tracking status...');

      // 현재 상태 확인
      _status = await AppTrackingTransparency.trackingAuthorizationStatus;
      Logger.info('🔒 [ATT] Current status: $_status');

      // 아직 결정되지 않은 경우에만 요청
      if (_status == TrackingStatus.notDetermined) {
        Logger.info('🔒 [ATT] Requesting tracking authorization...');

        // iOS 요구사항: 앱이 활성화된 후 약간의 지연 필요
        await Future.delayed(const Duration(milliseconds: 500));

        _status = await AppTrackingTransparency.requestTrackingAuthorization();
        Logger.info('🔒 [ATT] User response: $_status');
      }

      _isRequested = true;
      _logTrackingStatus();

      return _status;
    } catch (e, stackTrace) {
      Logger.error('❌ [ATT] Failed to request tracking authorization', e, stackTrace);
      _isRequested = true;
      return TrackingStatus.notDetermined;
    }
  }

  /// 현재 추적 상태만 확인 (권한 요청 없이)
  Future<TrackingStatus> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return TrackingStatus.authorized;
    }

    try {
      _status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return _status;
    } catch (e) {
      Logger.error('❌ [ATT] Failed to get tracking status', e);
      return TrackingStatus.notDetermined;
    }
  }

  /// IDFA (Identifier for Advertisers) 가져오기
  /// ATT가 허용된 경우에만 유효한 값 반환
  Future<String?> getAdvertisingIdentifier() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      if (_status == TrackingStatus.authorized) {
        final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
        // 0으로 채워진 UUID는 추적이 거부된 것
        if (uuid == '00000000-0000-0000-0000-000000000000') {
          return null;
        }
        return uuid;
      }
      return null;
    } catch (e) {
      Logger.error('❌ [ATT] Failed to get advertising identifier', e);
      return null;
    }
  }

  void _logTrackingStatus() {
    switch (_status) {
      case TrackingStatus.notDetermined:
        Logger.info('🔒 [ATT] Status: Not determined (user has not been asked)');
        break;
      case TrackingStatus.restricted:
        Logger.info('🔒 [ATT] Status: Restricted (device/parental controls)');
        break;
      case TrackingStatus.denied:
        Logger.info('🔒 [ATT] Status: Denied (user declined tracking)');
        break;
      case TrackingStatus.authorized:
        Logger.info('✅ [ATT] Status: Authorized (user allowed tracking)');
        break;
      case TrackingStatus.notSupported:
        Logger.info('🔒 [ATT] Status: Not supported (iOS < 14)');
        break;
    }
  }
}
