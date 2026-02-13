import '../utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 행운 아이템 에셋 서비스
/// 에셋 존재 여부를 확인하고, 누락 시 동적 생성 및 캐싱을 관리합니다.
class FortuneAssetService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _assetPrefix = 'assets/images/fortune/icons/lucky/';
  static const String _storageBucket = 'lucky-items';

  static const Map<String, String> _typeMapping = {
    'color': 'lucky_color_',
    'direction': 'lucky_direction_',
    'time': 'lucky_time_',
    'number': 'lucky_number_',
    'zodiac': 'zodiac_',
    'element': 'element_',
    'food': 'food_',
    'fashion': 'fashion_',
    'place': 'place_',
    'jewelry': 'jewelry_',
  };

  /// 특정 아이템의 최종 이미지 경로(또는 URL)를 반환합니다.
  /// 1. 정적 에셋 경로 생성
  /// 2. (미래 구현) 로컬 파일 시스템 캐시 확인
  /// 3. (미래 구현) Supabase Storage URL 생성
  static String getLuckyItemPath(String type, String value) {
    final normalizedType = type.toLowerCase();

    // 기본 매스 매핑 (이미 정의된 정적 에셋들용)
    final prefix = _typeMapping[normalizedType] ?? '';
    final fileName = value.toLowerCase().replaceAll(' ', '_');

    // 우선 로컬 에셋 경로 반환 (LuckyItemsRow의 errorBuilder에서 원격 전환 처리)
    return '$_assetPrefix$prefix$fileName.webp';
  }

  /// 에셋이 로컬에 없을 경우 호출되어 원격 저장소 URL을 반환하거나 생성을 트리거합니다.
  static String getRemoteFallbackUrl(String type, String value) {
    final typeKey = type.toLowerCase();
    final valueKey = value.toLowerCase().replaceAll(' ', '_');

    // Supabase Storage 경로 규칙: bucket/lucky-items/{type}/{value}.webp
    return _supabase.storage
        .from(_storageBucket)
        .getPublicUrl('$typeKey/$valueKey.webp');
  }

  /// AI 이미지 생성을 요청합니다.
  /// Edge Function: 'generate-lucky-image' 호출 (미구현 시 로그 기록)
  static Future<void> requestImageGeneration(String type, String value) async {
    try {
      Logger.info('[FortuneAssetService] 이미지 생성 요청: $type - $value');

      // Edge Function 호출 예시
      // await _supabase.functions.invoke('generate-lucky-image', body: {
      //   'type': type,
      //   'value': value,
      // });
    } catch (e) {
      Logger.error('[FortuneAssetService] 이미지 생성 요청 실패: $e');
    }
  }

  /// 누락된 에셋을 기록합니다.
  static void logMissingAsset(String type, String value) {
    Logger.warning(
        '[FortuneAssetService] Missing Asset: Type=$type, Value=$value');
    // 비동기로 생성 트리거
    requestImageGeneration(type, value);
  }
}
