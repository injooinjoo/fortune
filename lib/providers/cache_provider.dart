import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final cacheStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final cacheService = ref.watch(cacheServiceProvider);
  return await cacheService.getCacheStats();
});

final cachedFortuneProvider =
    FutureProvider.family<dynamic, CachedFortuneParams>((ref, params) async {
  final cacheService = ref.watch(cacheServiceProvider);
  return await cacheService.getCachedFortune(
    params.fortuneType,
    params.parameters,
  );
});

class CachedFortuneParams {
  final String fortuneType;
  final Map<String, dynamic> parameters;

  CachedFortuneParams({
    required this.fortuneType,
    required this.parameters,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CachedFortuneParams &&
        other.fortuneType == fortuneType &&
        _mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode => fortuneType.hashCode ^ parameters.hashCode;

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
