import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_profile.dart';
import 'resilient_service.dart';

/// ResilientService를 활용한 PetService 리팩토링 예시
///
/// 기존 PetService의 반복적인 try-catch 패턴을
/// ResilientService의 표준화된 메서드로 대체한 예시입니다.
class PetServiceResillient extends ResilientService {
  static final _client = Supabase.instance.client;
  static const String _tableName = 'pets';

  @override
  String get serviceName => 'PetService';

  /// 사용자의 반려동물 목록 조회 - 기존 방식
  ///
  /// 기존 코드:
  /// ```dart
  /// try {
  ///   final response = await _client.from(_tableName)...;
  ///   return response.map((json) => PetProfile.fromJson(json)).toList();
  /// } catch (e) {
  ///   Logger.warning('[PetService] 사용자 반려동물 목록 조회 실패 (선택적 기능, 빈 목록 반환): $e');
  ///   return [];
  /// }
  /// ```
  Future<List<PetProfile>> getUserPets(String userId) async {
    return await safeExecuteWithFallback(
      () async {
        final response = await _client
            .from(_tableName)
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .timeout(Duration(seconds: 10));

        if (response == null) return <PetProfile>[];

        return (response as List)
            .map((json) => PetProfile.fromJson(json))
            .toList();
      },
      <PetProfile>[], // fallback value
      '사용자 반려동물 목록 조회',
      '빈 목록 반환'
    );
  }

  /// 특정 반려동물 조회 - 기존 방식
  ///
  /// 기존 코드:
  /// ```dart
  /// try {
  ///   final response = await _client.from(_tableName)...;
  ///   if (response == null) return null;
  ///   return PetProfile.fromJson(response);
  /// } catch (e) {
  ///   Logger.warning('[PetService] 반려동물 조회 실패 (선택적 기능, null 반환): $e');
  ///   return null;
  /// }
  /// ```
  Future<PetProfile?> getPet(String petId) async {
    return await safeExecuteWithNull(
      () async {
        final response = await _client
            .from(_tableName)
            .select()
            .eq('id', petId)
            .maybeSingle();

        if (response == null) return null;
        return PetProfile.fromJson(response);
      },
      '반려동물 조회',
      'null 반환'
    );
  }

  /// 반려동물 등록 - 성공/실패 bool 반환
  Future<bool> createPet(PetProfile pet) async {
    return await safeExecuteWithBool(
      () async {
        await _client.from(_tableName).insert(pet.toJson());
      },
      '반려동물 등록',
      'false 반환'
    );
  }

  /// 반려동물 정보 수정 - 권한 확인 포함
  Future<PetProfile?> updatePet(String petId, Map<String, dynamic> updates, String userId) async {
    return await safeExecuteWithPermission(
      () async {
        // 권한 확인: 해당 반려동물이 사용자의 것인지 확인
        final pet = await _client
            .from(_tableName)
            .select('user_id')
            .eq('id', petId)
            .eq('user_id', userId)
            .maybeSingle();
        return pet != null;
      },
      () async {
        final response = await _client
            .from(_tableName)
            .update(updates)
            .eq('id', petId)
            .select()
            .single();
        return PetProfile.fromJson(response);
      },
      null, // fallback value
      '반려동물 정보 수정',
      '권한 없음',
      'null 반환'
    );
  }

  /// 반려동물 삭제 - 여러 시도를 통한 안전한 삭제
  Future<bool> deletePet(String petId) async {
    return await safeExecuteWithRetry(
      [
        // 첫 번째 시도: 소프트 삭제
        () async {
          await _client
              .from(_tableName)
              .update({'deleted_at': DateTime.now().toIso8601String()})
              .eq('id', petId);
          return true;
        },
        // 두 번째 시도: 하드 삭제
        () async {
          await _client.from(_tableName).delete().eq('id', petId);
          return true;
        },
      ],
      false, // fallback value
      '반려동물 삭제',
      'false 반환'
    );
  }

  /// 조건부 반려동물 통계 조회
  Future<Map<String, int>> getPetStatistics(String userId, {bool includeDeleted = false}) async {
    return await safeExecuteWithCondition(
      userId.isNotEmpty, // 조건: 유효한 사용자 ID
      () async {
        var query = _client.from(_tableName).select('*').eq('user_id', userId);

        if (!includeDeleted) {
          query = query.isFilter('deleted_at', null);
        }

        final response = await query;
        final pets = response as List;

        return {
          'total': pets.length,
          'dogs': pets.where((p) => p['species'] == 'dog').length,
          'cats': pets.where((p) => p['species'] == 'cat').length,
          'others': pets.where((p) => !['dog', 'cat'].contains(p['species'])).length,
        };
      },
      <String, int>{
        'total': 0,
        'dogs': 0,
        'cats': 0,
        'others': 0,
      }, // fallback value
      '반려동물 통계 조회',
      '유효하지 않은 사용자 ID',
      '기본 통계 반환'
    );
  }
}

/// SupabaseStorageService를 ResilientService로 리팩토링한 예시
class StorageServiceResilient extends ResilientService {
  final SupabaseClient _supabase;
  static const String _profileImagesBucket = 'profile-images';

  StorageServiceResilient(this._supabase);

  @override
  String get serviceName => 'SupabaseStorageService';

  /// 버킷 존재 여부 및 권한 확인 - 기존의 복잡한 로직을 단순화
  Future<bool> ensureBucketExists() async {
    return await safeExecuteWithPermission(
      () async {
        // 사용자 인증 확인
        final user = _supabase.auth.currentUser;
        return user != null;
      },
      () async {
        // 버킷 존재 및 접근 권한 확인
        final buckets = await _supabase.storage.listBuckets();
        final bucketExists = buckets.any((b) => b.name == _profileImagesBucket);

        if (!bucketExists) return false;

        // 접근 권한 테스트
        final user = _supabase.auth.currentUser!;
        await _supabase.storage
            .from(_profileImagesBucket)
            .list(path: user.id, const SearchOptions(limit: 1));
        return true;
      },
      false, // fallback value
      '스토리지 버킷 권한 확인',
      '사용자 인증 필요',
      '버킷 접근 불가'
    );
  }

  /// 프로필 이미지 업로드 - 조건부 실행
  Future<String?> uploadProfileImage({
    required String userId,
    required dynamic imageFile,
  }) async {
    return await safeExecuteWithCondition(
      await ensureBucketExists(), // 조건: 버킷 접근 권한 있음
      () async {
        // 실제 업로드 로직
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'profile_${userId}_$timestamp.jpg';
        final filePath = '$userId/$fileName';

        final bytes = await imageFile.readAsBytes();

        await _supabase.storage
            .from(_profileImagesBucket)
            .uploadBinary(filePath, bytes);

        return _supabase.storage
            .from(_profileImagesBucket)
            .getPublicUrl(filePath);
      },
      null, // fallback value
      '프로필 이미지 업로드',
      '버킷 접근 권한 없음',
      'null 반환'
    );
  }
}