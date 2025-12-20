import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/celebrity_saju.dart';
import '../../services/celebrity_saju_service.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';

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

/// F04: 사용자 사주 기반 유사 유명인 프로바이더
///
/// 사용자 사주 데이터를 기반으로 실제 유사한 사주를 가진 유명인 1~3명 반환
/// - 유사도 50점 이상만 표시
/// - 유사도 높은 순 정렬
/// - 사용자 사주 데이터가 없으면 기존 궁합도 방식으로 폴백
final similarCelebritiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(celebritySajuServiceProvider);
  final sajuState = ref.watch(sajuProvider);
  final sajuData = sajuState.sajuData;

  // 사용자 사주 데이터가 있는 경우 - 실제 유사도 계산
  if (sajuData != null) {
    // 오행 데이터 추출
    final elementsRaw = sajuData['elements'] as Map<String, dynamic>?;
    final userElements = <String, int>{};
    if (elementsRaw != null) {
      for (final entry in elementsRaw.entries) {
        userElements[entry.key] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    // 일주 데이터 추출 (day.cheongan.char + day.jiji.char)
    String userDayPillar = '';
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    if (dayData != null) {
      final cheongan = dayData['cheongan'] as Map<String, dynamic>?;
      final jiji = dayData['jiji'] as Map<String, dynamic>?;
      final ganChar = cheongan?['char'] as String? ?? '';
      final zhiChar = jiji?['char'] as String? ?? '';
      userDayPillar = '$ganChar$zhiChar';
    }

    // 유사 유명인 검색 (유사도 50점 이상, 최대 3명)
    if (userElements.isNotEmpty || userDayPillar.isNotEmpty) {
      final similarCelebs = await service.findSimilarCelebrities(
        userElements: userElements,
        userDayPillar: userDayPillar,
        minSimilarity: 50,
        maxResults: 3,
      );

      if (similarCelebs.isNotEmpty) {
        return similarCelebs;
      }
    }
  }

  // 폴백: 기존 궁합도 방식 (사주 데이터 없거나 유사 유명인 없을 때)
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

  result.sort((a, b) => (b['compatibility'] as int).compareTo(a['compatibility'] as int));

  // 폴백에서는 상위 3명만 반환
  return result.take(3).toList();
});

// 검색어 상태 관리 프로바이더
final searchQueryProvider = StateProvider<String>((ref) => '');

// 선택된 카테고리 상태 관리 프로바이더
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 선택된 유명인사 상태 관리 프로바이더
final selectedCelebrityProvider = StateProvider<CelebritySaju?>((ref) => null);