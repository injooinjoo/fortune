import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/celebrity_saju.dart';
import '../../services/celebrity_saju_service.dart';

// 서비스 프로바이더
final celebritySajuServiceProvider = Provider<CelebritySajuService>((ref) {
  return CelebritySajuService();
});

// 유명인사 검색 프로바이더
final celebritySearchProvider = FutureProvider.family<List<CelebritySaju>, String>((ref, query) async {
  final service = ref.read(celebritySajuServiceProvider);
  return await service.searchCelebrities(query);
});

// 카테고리별 인기 유명인사 프로바이더
final popularCelebritiesProvider = FutureProvider.family<List<CelebritySaju>, String?>((ref, category) async {
  final service = ref.read(celebritySajuServiceProvider);
  return await service.getPopularCelebrities(category);
});

// 특정 유명인사 사주 정보 프로바이더
final celebritySajuDetailProvider = FutureProvider.family<CelebritySaju?, String>((ref, name) async {
  final service = ref.read(celebritySajuServiceProvider);
  return await service.getCelebritySaju(name);
});

// 카테고리 목록 프로바이더
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(celebritySajuServiceProvider);
  return await service.getCategories();
});

// 오행별 유명인사 프로바이더
final elementCelebritiesProvider = FutureProvider.family<List<CelebritySaju>, String>((ref, element) async {
  final service = ref.read(celebritySajuServiceProvider);
  return await service.getCelebritiesByElement(element);
});

// 랜덤 유명인사 추천 프로바이더
final randomCelebritiesProvider = FutureProvider<List<CelebritySaju>>((ref) async {
  final service = ref.read(celebritySajuServiceProvider);
  return await service.getRandomCelebrities(5);
});

/// 오늘 일주 기반 궁합도가 포함된 연예인 리스트 프로바이더
///
/// 매일 새로운 궁합도 계산, 궁합도 높은 순으로 정렬
final celebritiesWithCompatibilityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final celebrities = await ref.watch(randomCelebritiesProvider.future);
  final today = DateTime.now();

  final result = celebrities.map((celeb) {
    final compatibility = CelebritySajuService.calculateDailyCompatibility(
      today,
      celeb.birthDate,
    );
    return {
      'celebrity': celeb,
      'compatibility': compatibility,
    };
  }).toList();

  // 궁합도 높은 순으로 정렬
  result.sort((a, b) => (b['compatibility'] as int).compareTo(a['compatibility'] as int));

  return result;
});

// 검색어 상태 관리 프로바이더
final searchQueryProvider = StateProvider<String>((ref) => '');

// 선택된 카테고리 상태 관리 프로바이더
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 선택된 유명인사 상태 관리 프로바이더
final selectedCelebrityProvider = StateProvider<CelebritySaju?>((ref) => null);