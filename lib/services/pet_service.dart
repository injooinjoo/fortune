import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/pet_profile.dart';
import '../core/utils/logger.dart';

class PetService {
  static final _client = Supabase.instance.client;
  static const String _tableName = 'pets';

  /// 사용자의 반려동물 목록 조회
  static Future<List<PetProfile>> getUserPets(String userId) async {
    try {
      Logger.info('Loading pets for user: $userId');
      
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(Duration(seconds: 10)); // 10초 타임아웃 추가

      Logger.info('Pet query response received: ${response.length} pets');
      
      return (response as List)
          .map((json) => PetProfile.fromJson(json))
          .toList();
    } catch (e) {
      Logger.warning('[PetService] 사용자 반려동물 목록 조회 실패 (선택적 기능, 빈 목록 반환): $e');
      return []; // 항상 빈 리스트 반환으로 UI 블로킹 방지
    }
  }

  /// 특정 반려동물 조회
  static Future<PetProfile?> getPet(String petId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', petId)
          .maybeSingle();

      if (response == null) return null;
      return PetProfile.fromJson(response);
    } catch (e) {
      Logger.warning('[PetService] 반려동물 조회 실패 (선택적 기능, null 반환): $e');
      return null;
    }
  }

  /// 새 반려동물 등록
  static Future<PetProfile?> createPet({
    required String userId,
    required String species,
    required String name,
    required int age,
  }) async {
    try {
      Logger.info('Creating pet: name=$name, species=$species, age=$age, userId=$userId');
      
      final petData = {
        'user_id': userId,
        'species': species,
        'name': name,
        'age': age,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(_tableName)
          .insert(petData)
          .select()
          .single()
          .timeout(Duration(seconds: 10));

      Logger.info('✅ Pet created successfully: ${response['name']} (ID: ${response['id']})');
      return PetProfile.fromJson(response);
    } catch (e) {
      Logger.warning('[PetService] 반려동물 등록 실패 (선택적 기능, null 반환): $e');
      return null;
    }
  }

  /// 반려동물 정보 수정
  static Future<PetProfile?> updatePet({
    required String petId,
    String? species,
    String? name,
    int? age,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (species != null) updateData['species'] = species;
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;

      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('id', petId)
          .select()
          .single();

      Logger.info('Pet updated successfully');
      return PetProfile.fromJson(response);
    } catch (e) {
      Logger.warning('[PetService] 반려동물 정보 수정 실패 (선택적 기능, null 반환): $e');
      return null;
    }
  }

  /// 반려동물 삭제
  static Future<bool> deletePet(String petId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', petId);

      Logger.info('Pet deleted successfully');
      return true;
    } catch (e) {
      Logger.warning('[PetService] 반려동물 삭제 실패 (선택적 기능, false 반환): $e');
      return false;
    }
  }

  /// 사용자의 반려동물 수 조회
  static Future<int> getUserPetCount(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      Logger.warning('[PetService] 반려동물 수 조회 실패 (선택적 기능, 0 반환): $e');
      return 0;
    }
  }

  /// 반려동물 이름 중복 확인 (같은 사용자 내에서)
  static Future<bool> isPetNameExists(String userId, String name, {String? excludePetId}) async {
    try {
      var query = _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('name', name);

      if (excludePetId != null) {
        query = query.neq('id', excludePetId);
      }

      final response = await query.maybeSingle();
      return response != null;
    } catch (e) {
      Logger.warning('[PetService] 반려동물 이름 중복 확인 실패 (선택적 기능, false 반환): $e');
      return false;
    }
  }

  /// 반려동물과 사용자의 궁합 점수 계산 (간단한 로직)
  static int calculateCompatibilityScore({
    required PetProfile pet,
    required String userZodiacSign,
    required String userMbtiType,
  }) {
    int baseScore = 70;
    
    // 동물별 기본 점수 조정
    switch (PetSpecies.fromString(pet.species)) {
      case PetSpecies.dog:
        baseScore += 10;
        break;
      case PetSpecies.cat:
        baseScore += 8;
        break;
      case PetSpecies.rabbit:
        baseScore += 6;
        break;
      case PetSpecies.bird:
        baseScore += 4;
        break;
      default:
        baseScore += 2;
    }

    // 나이에 따른 조정
    if (pet.age >= 1 && pet.age <= 3) {
      baseScore += 5; // 어린 반려동물
    } else if (pet.age >= 4 && pet.age <= 10) {
      baseScore += 8; // 성숙한 반려동물
    } else {
      baseScore += 3; // 고령 반려동물
    }

    // MBTI에 따른 조정 (간단한 로직)
    if (userMbtiType.contains('E')) {
      if (pet.species == '강아지') baseScore += 5;
    } else {
      if (pet.species == '고양이') baseScore += 5;
    }

    // 띠에 따른 조정 (간단한 로직)
    final compatibleZodiacs = {
      '강아지': ['개', '토끼', '말'],
      '고양이': ['호랑이', '토끼', '용'],
      '토끼': ['개', '돼지', '양'],
    };

    if (compatibleZodiacs[pet.species]?.contains(userZodiacSign) == true) {
      baseScore += 10;
    }

    // 점수를 0-100 범위로 제한
    return (baseScore).clamp(0, 100);
  }
}