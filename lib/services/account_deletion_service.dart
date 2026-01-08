import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/cache/cache_service.dart';
import '../core/services/debug_premium_service.dart';
import '../core/services/performance_cache_service.dart';
import '../core/utils/logger.dart';
import '../core/utils/secure_storage.dart';
import '../services/storage_service.dart';

class AccountDeletionService {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  AccountDeletionService({
    SupabaseClient? supabase,
    StorageService? storageService,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _storageService = storageService ?? StorageService();

  Future<void> deleteAccount({String? reason, String? feedback}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('로그인 상태가 아닙니다.');
    }

    Logger.info('[AccountDeletion] 요청 시작', {
      'userId': user.id,
      'reason': reason,
    });

    final response = await _supabase.functions.invoke(
      'delete-account',
      body: {
        'reason': reason,
        'feedback': feedback,
      },
    );

    if (response.status != 200) {
      Logger.warning(
        '[AccountDeletion] Edge Function 실패',
        {'status': response.status, 'data': response.data},
      );
      throw Exception('계정 삭제 요청 실패');
    }

    await _supabase.auth.signOut();
    await _cleanupLocalData();
    Logger.info('[AccountDeletion] 완료');
  }

  Future<void> _cleanupLocalData() async {
    try {
      await SecureStorage.deleteAll();
      await _storageService.clearAll();

      final cacheService = CacheService();
      await cacheService.clearAllCache();

      final performanceCacheService = PerformanceCacheService();
      await performanceCacheService.clearAll();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('unified_fortune_widget_data');

      await DebugPremiumService.setOverride(null);
    } catch (e) {
      Logger.warning('[AccountDeletion] 로컬 정리 실패 (무시): $e');
    }
  }
}
