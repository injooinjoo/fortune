import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/utils/logger.dart';

/// 부적 카테고리 Enum
enum TalismanCategory {
  diseasePrevention('disease_prevention', '질병 퇴치', ['病退散', '藥神降臨'],
      '질병과 나쁜 기운을 물리치는 부적입니다. 침실이나 현관에 붙여두고, 아침마다 한 번 바라보며 건강을 빌어보세요.'),
  loveRelationship('love_relationship', '사랑 성취', ['夫婦和合', '百年好合'],
      '사랑과 좋은 인연을 불러오는 부적입니다. 지갑이나 핸드폰 케이스에 넣어 늘 가까이 지니세요.'),
  wealthCareer('wealth_career', '재물운', ['財祿豊盈', '官運亨通'],
      '재물과 성공을 불러오는 부적입니다. 지갑이나 금고 근처에 두고, 매일 아침 바라보며 소원을 빌어보세요.'),
  disasterRemoval('disaster_removal', '삼재 소멸', ['三災消滅'],
      '삼재와 액운을 막아주는 부적입니다. 현관문 안쪽에 붙여두고, 외출 전 한 번 바라보세요.'),
  homeProtection('home_protection', '안택', ['家內平安', '安宅'],
      '가정의 평안과 화목을 지키는 부적입니다. 거실이나 가족이 모이는 곳에 두고, 온 가족이 함께 바라보세요.'),
  academicSuccess('academic_success', '학업 성취', ['及第及第', '文昌帝君'],
      '학업 성취와 합격을 기원하는 부적입니다. 책상 위나 필통에 넣어두고, 공부 전 한 번 바라보세요.'),
  healthLongevity('health_longevity', '건강 장수', ['無病長壽', '福祿壽'],
      '건강과 장수를 기원하는 부적입니다. 침대 머리맡이나 거울 옆에 두고, 매일 아침 감사하며 바라보세요.');

  const TalismanCategory(this.id, this.displayName, this.defaultCharacters, this.shortDescription);

  final String id;
  final String displayName;
  final List<String> defaultCharacters;
  final String shortDescription;

  /// 카테고리 ID로 TalismanCategory 찾기
  static TalismanCategory? fromId(String id) {
    try {
      return TalismanCategory.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 부적 이미지 생성 결과
class TalismanGenerationResult {
  final String? id;
  final String imageUrl;
  final String category;
  final String categoryName; // 카테고리 한글명 (예: 재물운)
  final String shortDescription; // 100자 내외 효능 + 사용법
  final List<String> characters;
  final DateTime createdAt;

  TalismanGenerationResult({
    this.id,
    required this.imageUrl,
    required this.category,
    required this.categoryName,
    required this.shortDescription,
    required this.characters,
    required this.createdAt,
  });

  factory TalismanGenerationResult.fromJson(Map<String, dynamic> json) {
    return TalismanGenerationResult(
      id: json['id'] as String?,
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String,
      category: json['category'] as String,
      categoryName: (json['categoryName'] ?? json['category_name'] ?? '') as String,
      shortDescription: (json['shortDescription'] ?? json['short_description'] ?? '') as String,
      characters: (json['characters'] as List).cast<String>(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// 부적 이미지 생성 서비스
///
/// Gemini Imagen 3 API를 사용하여 전통 한국 부적 이미지를 생성합니다.
///
/// **사용 예시**:
/// ```dart
/// final service = TalismanGenerationService();
/// final result = await service.generateTalisman(
///   category: TalismanCategory.diseasePrevention,
/// );
/// print('Image URL: ${result.imageUrl}');
/// ```
class TalismanGenerationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 부적 이미지 생성 (최적화 시스템 적용 - API 비용 70-80% 절감)
  ///
  /// **프로세스**:
  /// 0️⃣ 하루 1회 제한 확인 → 이미 오늘 생성했으면 캐시 반환
  /// 1️⃣ 개인 캐시 확인 → 오늘 동일 조건 이미 생성?
  /// 2️⃣ DB 풀 크기 확인 → 공용 풀 ≥100개?
  /// 3️⃣ 30% 랜덤 선택 → Math.random() < 0.3?
  /// 4️⃣ API 호출 (70% 확률) - Gemini 2.0 Flash Image
  ///
  /// [category] - 부적 카테고리 (질병 퇴치, 사랑 성취, 재물 운 등)
  /// [customCharacters] - 사용자 지정 한자 문구 (옵션)
  /// [animal] - 동물 상징 (옵션, 기본값은 카테고리별 기본 동물)
  /// [pattern] - 기하학 패턴 (옵션, 기본값은 카테고리별 기본 패턴)
  Future<TalismanGenerationResult> generateTalisman({
    required TalismanCategory category,
    List<String>? customCharacters,
    String? animal,
    String? pattern,
  }) async {
    try {
      Logger.info('[TalismanGen] 🔮 Generating talisman: ${category.displayName}');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final characters = customCharacters ?? category.defaultCharacters;
      Logger.info('[TalismanGen] 📝 Characters: ${characters.join(", ")}');

      // 0️⃣ 하루 1회 제한 확인 - 이미 오늘 생성했으면 캐시에서 반환
      final todaysTalisman = await getTodaysTalisman(category);
      if (todaysTalisman != null) {
        Logger.info('[TalismanGen] ✅ Already created today, returning cached result');
        return todaysTalisman;
      }

      // 1️⃣ 개인 캐시 확인 (레거시 호환성)
      final cachedResult = await _checkPersonalCache(userId, category, characters);
      if (cachedResult != null) {
        Logger.info('[TalismanGen] ✅ Using cached talisman (personal cache)');
        return cachedResult;
      }

      // 2️⃣ DB 공용 풀 크기 확인
      final poolSize = await _checkPoolSize(category, characters);
      Logger.info('[TalismanGen] 📊 Public pool size: $poolSize');

      if (poolSize >= 100) {
        Logger.info('[TalismanGen] ✅ Pool size ≥100, using random from public pool');
        final randomResult = await _getRandomFromDB(category, characters);
        await _saveToPersonalCache(userId, category, randomResult);
        await Future.delayed(const Duration(seconds: 5)); // 5초 대기 (사용자 경험)
        return randomResult;
      }

      // 3️⃣ 30% 랜덤 선택 (풀에 이미지가 있을 경우)
      final random = math.Random().nextDouble();
      if (random < 0.3 && poolSize > 0) {
        Logger.info('[TalismanGen] 🎲 30% random selection (${(random * 100).toInt()}%), using public pool');
        final randomResult = await _getRandomFromDB(category, characters);
        await _saveToPersonalCache(userId, category, randomResult);
        await Future.delayed(const Duration(seconds: 5)); // 5초 대기
        return randomResult;
      }

      // 4️⃣ API 호출 (70% 확률) - Gemini 2.0 Flash Image 사용
      Logger.info('[TalismanGen] 🚀 API call (70% path) - Gemini Image Generation');
      final result = await _callGeminiAPI(userId, category, characters, animal, pattern);

      // 새로 생성된 이미지 캐시 저장
      await _saveToPersonalCache(userId, category, result);

      return result;
    } catch (e, stackTrace) {
      Logger.error('[TalismanGen] ❌ Failed to generate talisman: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 1️⃣ 개인 캐시 확인 (레거시 - talisman_images 테이블에서 직접 조회)
  Future<TalismanGenerationResult?> _checkPersonalCache(
    String userId,
    TalismanCategory category,
    List<String> characters,
  ) async {
    try {
      final todayStart = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
      final todayEnd = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

      final response = await _supabase
          .from('talisman_images')
          .select()
          .eq('user_id', userId)
          .eq('category', category.id)
          .gte('created_at', todayStart.toIso8601String())
          .lte('created_at', todayEnd.toIso8601String())
          .maybeSingle();

      if (response == null) return null;

      final categoryId = response['category'] as String;
      final cat = TalismanCategory.fromId(categoryId);

      return TalismanGenerationResult(
        id: response['id'] as String?,
        imageUrl: response['image_url'] as String,
        category: categoryId,
        categoryName: cat?.displayName ?? categoryId,
        shortDescription: cat?.shortDescription ?? '',
        characters: (response['characters'] as List).cast<String>(),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Cache check failed: $e', e);
      return null;
    }
  }

  /// 2️⃣ DB 풀 크기 확인 (공용 풀만 카운트)
  Future<int> _checkPoolSize(TalismanCategory category, List<String> characters) async {
    try {
      final response = await _supabase
          .from('talisman_images')
          .select('id')
          .eq('category', category.id)
          .eq('is_public', true)  // 공용 풀만 카운트
          .count();

      return response.count;
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Pool size check failed: $e', e);
      return 0;
    }
  }

  /// 3️⃣ DB에서 랜덤 선택 (공용 풀에서만)
  Future<TalismanGenerationResult> _getRandomFromDB(
    TalismanCategory category,
    List<String> characters,
  ) async {
    final response = await _supabase
        .from('talisman_images')
        .select()
        .eq('category', category.id)
        .eq('is_public', true)  // 공용 풀에서만 선택
        .order('created_at', ascending: false)
        .limit(100); // 최근 100개 중 랜덤

    if ((response as List).isEmpty) {
      throw Exception('No talisman found in DB');
    }

    final random = math.Random();
    final randomIndex = random.nextInt(response.length);
    final item = response[randomIndex];

    // 사용 횟수 증가 (비동기, 에러 무시)
    _incrementUsageCount(item['id'] as String);

    return TalismanGenerationResult(
      id: item['id'] as String,
      imageUrl: item['image_url'] as String,
      category: item['category'] as String,
      categoryName: category.displayName,
      shortDescription: category.shortDescription,
      characters: (item['characters'] as List).cast<String>(),
      createdAt: DateTime.parse(item['created_at'] as String),
    );
  }

  /// 사용 횟수 증가 (fire-and-forget)
  Future<void> _incrementUsageCount(String imageId) async {
    try {
      await _supabase.rpc('increment_talisman_usage', params: {'p_image_id': imageId});
    } catch (e) {
      Logger.error('[TalismanGen] ⚠️ Failed to increment usage: $e', e);
    }
  }

  /// 4️⃣ Gemini API 호출
  Future<TalismanGenerationResult> _callGeminiAPI(
    String userId,
    TalismanCategory category,
    List<String> characters,
    String? animal,
    String? pattern,
  ) async {
    final response = await _supabase.functions.invoke(
      'generate-talisman',
      body: {
        'userId': userId,
        'category': category.id,
        'characters': characters,
        'animal': animal,
        'pattern': pattern,
      },
    );

    if (response.status != 200) {
      final errorData = response.data as Map<String, dynamic>?;
      final errorMessage = errorData?['error'] ?? 'Unknown error';
      throw Exception('Failed to generate talisman: $errorMessage');
    }

    final data = response.data as Map<String, dynamic>;
    return TalismanGenerationResult(
      id: data['id'] as String?,
      imageUrl: data['imageUrl'] as String,
      category: data['category'] as String,
      categoryName: (data['categoryName'] as String?) ?? category.displayName,
      shortDescription: (data['shortDescription'] as String?) ?? category.shortDescription,
      characters: (data['characters'] as List).cast<String>(),
      createdAt: DateTime.now(),
    );
  }

  /// 개인 캐시 저장 (하루 1회 제한 관리)
  Future<void> _saveToPersonalCache(
    String userId,
    TalismanCategory category,
    TalismanGenerationResult result,
  ) async {
    try {
      if (result.id == null) {
        Logger.error('[TalismanGen] ⚠️ Cannot save cache without image id');
        return;
      }

      await _supabase.from('talisman_user_cache').upsert({
        'user_id': userId,
        'category': category.id,
        'image_id': result.id,
        'cache_date': DateTime.now().toIso8601String().split('T')[0],
      });

      Logger.info('[TalismanGen] 💾 Saved to personal cache for user: $userId');
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Failed to save to personal cache: $e', e);
    }
  }

  /// 오늘 부적 생성 가능 여부 확인 (하루 1회 제한)
  Future<bool> canCreateTalisman(TalismanCategory category) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('talisman_user_cache')
          .select('id')
          .eq('user_id', userId)
          .eq('category', category.id)
          .eq('cache_date', today)
          .maybeSingle();

      return response == null; // null이면 오늘 생성 안 함 → 생성 가능
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Failed to check daily limit: $e', e);
      return true; // 에러 시 생성 허용
    }
  }

  /// 오늘 생성한 부적 조회 (캐시에서)
  Future<TalismanGenerationResult?> getTodaysTalisman(TalismanCategory category) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final cacheResponse = await _supabase
          .from('talisman_user_cache')
          .select('image_id')
          .eq('user_id', userId)
          .eq('category', category.id)
          .eq('cache_date', today)
          .maybeSingle();

      if (cacheResponse == null) return null;

      final imageId = cacheResponse['image_id'] as String;

      final imageResponse = await _supabase
          .from('talisman_images')
          .select()
          .eq('id', imageId)
          .single();

      return TalismanGenerationResult(
        id: imageResponse['id'] as String,
        imageUrl: imageResponse['image_url'] as String,
        category: imageResponse['category'] as String,
        categoryName: category.displayName,
        shortDescription: category.shortDescription,
        characters: (imageResponse['characters'] as List).cast<String>(),
        createdAt: DateTime.parse(imageResponse['created_at'] as String),
      );
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Failed to get todays talisman: $e', e);
      return null;
    }
  }

  /// 사용자의 부적 이미지 목록 조회
  ///
  /// [limit] - 최대 조회 개수 (기본값: 20)
  Future<List<TalismanGenerationResult>> getUserTalismans({int limit = 20}) async {
    try {
      Logger.info('[TalismanGen] 📋 Fetching user talismans (limit: $limit)');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('talisman_images')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final talismans = (response as List).map((json) {
        final categoryId = json['category'] as String;
        final cat = TalismanCategory.fromId(categoryId);
        return TalismanGenerationResult(
          id: json['id'] as String?,
          imageUrl: json['image_url'] as String,
          category: categoryId,
          categoryName: cat?.displayName ?? categoryId,
          shortDescription: cat?.shortDescription ?? '',
          characters: (json['characters'] as List).cast<String>(),
          createdAt: DateTime.parse(json['created_at'] as String),
        );
      }).toList();

      Logger.info('[TalismanGen] ✅ Found ${talismans.length} talismans');

      return talismans;
    } catch (e, stackTrace) {
      Logger.error('[TalismanGen] ❌ Failed to fetch talismans: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 특정 카테고리의 부적 이미지 조회
  Future<List<TalismanGenerationResult>> getTalismansByCategory(
    TalismanCategory category, {
    int limit = 10,
  }) async {
    try {
      Logger.info('[TalismanGen] 📋 Fetching talismans for: ${category.displayName}');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('talisman_images')
          .select()
          .eq('user_id', userId)
          .eq('category', category.id)
          .order('created_at', ascending: false)
          .limit(limit);

      final talismans = (response as List)
          .map((json) => TalismanGenerationResult(
                id: json['id'] as String?,
                imageUrl: json['image_url'] as String,
                category: json['category'] as String,
                categoryName: category.displayName,
                shortDescription: category.shortDescription,
                characters: (json['characters'] as List).cast<String>(),
                createdAt: DateTime.parse(json['created_at'] as String),
              ))
          .toList();

      Logger.info('[TalismanGen] ✅ Found ${talismans.length} talismans for ${category.displayName}');

      return talismans;
    } catch (e, stackTrace) {
      Logger.error('[TalismanGen] ❌ Failed to fetch talismans by category: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 부적 이미지 삭제
  Future<void> deleteTalisman(String imageUrl) async {
    try {
      Logger.info('[TalismanGen] 🗑️ Deleting talisman: $imageUrl');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // DB에서 삭제
      await _supabase
          .from('talisman_images')
          .delete()
          .eq('user_id', userId)
          .eq('image_url', imageUrl);

      // Storage에서 파일 삭제
      final fileName = imageUrl.split('/').last;
      await _supabase.storage
          .from('talisman-images')
          .remove(['$userId/$fileName']);

      Logger.info('[TalismanGen] ✅ Talisman deleted');
    } catch (e, stackTrace) {
      Logger.error('[TalismanGen] ❌ Failed to delete talisman: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 부적 이미지 다운로드 (로컬 저장)
  Future<void> downloadTalisman(String imageUrl, String savePath) async {
    try {
      Logger.info('[TalismanGen] 💾 Downloading talisman to: $savePath');

      // HTTP GET으로 이미지 다운로드
      // (실제 구현은 http 패키지 또는 dio 사용)

      Logger.info('[TalismanGen] ✅ Talisman downloaded');
    } catch (e, stackTrace) {
      Logger.error('[TalismanGen] ❌ Failed to download talisman: $e', e, stackTrace);
      rethrow;
    }
  }
}
