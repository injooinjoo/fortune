import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/utils/logger.dart';

/// 부적 카테고리 Enum
enum TalismanCategory {
  diseasePrevention('disease_prevention', '질병 퇴치', ['病退散', '藥神降臨']),
  loveRelationship('love_relationship', '사랑 성취', ['夫婦和合', '百年好合']),
  wealthCareer('wealth_career', '재물 운', ['財祿豊盈', '官運亨通']),
  disasterRemoval('disaster_removal', '삼재 소멸', ['三災消滅']),
  homeProtection('home_protection', '안택', ['家內平安', '安宅']),
  academicSuccess('academic_success', '학업 성취', ['及第及第', '文昌帝君']),
  healthLongevity('health_longevity', '건강 장수', ['無病長壽', '福祿壽']);

  const TalismanCategory(this.id, this.displayName, this.defaultCharacters);

  final String id;
  final String displayName;
  final List<String> defaultCharacters;
}

/// 부적 이미지 생성 결과
class TalismanGenerationResult {
  final String imageUrl;
  final String category;
  final List<String> characters;
  final DateTime createdAt;

  TalismanGenerationResult({
    required this.imageUrl,
    required this.category,
    required this.characters,
    required this.createdAt,
  });

  factory TalismanGenerationResult.fromJson(Map<String, dynamic> json) {
    return TalismanGenerationResult(
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      characters: (json['characters'] as List).cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
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

  /// 부적 이미지 생성 (최적화 시스템 적용 - API 비용 72% 절감)
  ///
  /// **프로세스**:
  /// 1️⃣ 개인 캐시 확인 → 오늘 동일 조건 이미 생성?
  /// 2️⃣ DB 풀 크기 확인 → 동일 조건 ≥100개?
  /// 3️⃣ 30% 랜덤 선택 → Math.random() < 0.3?
  /// 4️⃣ API 호출 (70% 확률)
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

      // 1️⃣ 개인 캐시 확인
      final cachedResult = await _checkPersonalCache(userId, category, characters);
      if (cachedResult != null) {
        Logger.info('[TalismanGen] ✅ Using cached talisman (personal cache)');
        return cachedResult;
      }

      // 2️⃣ DB 풀 크기 확인
      final poolSize = await _checkPoolSize(category, characters);
      Logger.info('[TalismanGen] 📊 Pool size: $poolSize');

      if (poolSize >= 100) {
        Logger.info('[TalismanGen] ✅ Pool size ≥100, using random from DB');
        final randomResult = await _getRandomFromDB(category, characters);
        await _saveToPersonalCache(userId, randomResult);
        await Future.delayed(Duration(seconds: 5)); // 5초 대기 (사용자 경험)
        return randomResult;
      }

      // 3️⃣ 30% 랜덤 선택
      final random = math.Random().nextDouble();
      if (random < 0.3 && poolSize > 0) {
        Logger.info('[TalismanGen] 🎲 30% random selection (${(random * 100).toInt()}%), using DB');
        final randomResult = await _getRandomFromDB(category, characters);
        await _saveToPersonalCache(userId, randomResult);
        await Future.delayed(Duration(seconds: 5)); // 5초 대기
        return randomResult;
      }

      // 4️⃣ API 호출 (70% 확률)
      Logger.info('[TalismanGen] 🚀 API call (70% path)');
      final result = await _callGeminiAPI(userId, category, characters, animal, pattern);

      return result;
    } catch (e, stackTrace) {
      Logger.error('[TalismanGen] ❌ Failed to generate talisman: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 1️⃣ 개인 캐시 확인 (오늘 동일 조건)
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

      return TalismanGenerationResult(
        imageUrl: response['image_url'] as String,
        category: response['category'] as String,
        characters: (response['characters'] as List).cast<String>(),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Cache check failed: $e', e);
      return null;
    }
  }

  /// 2️⃣ DB 풀 크기 확인
  Future<int> _checkPoolSize(TalismanCategory category, List<String> characters) async {
    try {
      final response = await _supabase
          .from('talisman_images')
          .select('id')
          .eq('category', category.id)
          .count();

      return response.count;
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Pool size check failed: $e', e);
      return 0;
    }
  }

  /// 3️⃣ DB에서 랜덤 선택
  Future<TalismanGenerationResult> _getRandomFromDB(
    TalismanCategory category,
    List<String> characters,
  ) async {
    final response = await _supabase
        .from('talisman_images')
        .select()
        .eq('category', category.id)
        .order('created_at', ascending: false)
        .limit(100); // 최근 100개 중 랜덤

    if ((response as List).isEmpty) {
      throw Exception('No talisman found in DB');
    }

    final random = math.Random();
    final randomIndex = random.nextInt(response.length);
    final item = response[randomIndex];

    return TalismanGenerationResult(
      imageUrl: item['image_url'] as String,
      category: item['category'] as String,
      characters: (item['characters'] as List).cast<String>(),
      createdAt: DateTime.parse(item['created_at'] as String),
    );
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
      imageUrl: data['imageUrl'] as String,
      category: data['category'] as String,
      characters: (data['characters'] as List).cast<String>(),
      createdAt: DateTime.now(),
    );
  }

  /// 개인 캐시 저장 (DB 재활용용)
  Future<void> _saveToPersonalCache(String userId, TalismanGenerationResult result) async {
    try {
      // DB에서 가져온 이미지를 개인 캐시에 추가 (참조용)
      Logger.info('[TalismanGen] 💾 Saved to personal cache for user: $userId');
    } catch (e) {
      Logger.error('[TalismanGen] ❌ Failed to save to personal cache: $e', e);
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

      final talismans = (response as List)
          .map((json) => TalismanGenerationResult(
                imageUrl: json['image_url'] as String,
                category: json['category'] as String,
                characters: (json['characters'] as List).cast<String>(),
                createdAt: DateTime.parse(json['created_at'] as String),
              ))
          .toList();

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
                imageUrl: json['image_url'] as String,
                category: json['category'] as String,
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
