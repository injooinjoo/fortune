import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../../data/models/secondary_profile.dart';

/// 서브 프로필(가족/친구) 목록 Provider
///
/// 현재 로그인된 사용자가 등록한 다른 사람 프로필 목록을 관리
final secondaryProfilesProvider = StateNotifierProvider<
    SecondaryProfilesNotifier, AsyncValue<List<SecondaryProfile>>>((ref) {
  return SecondaryProfilesNotifier();
});

/// 서브 프로필 목록 상태 관리 클래스
class SecondaryProfilesNotifier
    extends StateNotifier<AsyncValue<List<SecondaryProfile>>> {
  SecondaryProfilesNotifier() : super(const AsyncValue.loading()) {
    _loadProfiles();
  }

  final _supabase = Supabase.instance.client;

  /// 프로필 목록 로드
  Future<void> _loadProfiles() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('⚠️ SecondaryProfilesProvider: 로그인 필요');
        state = const AsyncValue.data([]);
        return;
      }

      developer.log('🔄 SecondaryProfilesProvider: 프로필 로드 시작');

      final response = await _supabase
          .from('secondary_profiles')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: true);

      final profiles = (response as List)
          .map(
              (json) => SecondaryProfile.fromJson(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(profiles);
      developer
          .log('✅ SecondaryProfilesProvider: ${profiles.length}개 프로필 로드 완료');
    } catch (e, st) {
      developer.log('❌ SecondaryProfilesProvider 로드 실패: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// 프로필 추가
  ///
  /// [name] 이름 (필수)
  /// [birthDate] 생년월일 YYYY-MM-DD (필수)
  /// [birthTime] 태어난 시간 HH:MM (선택)
  /// [gender] 성별 male/female (필수)
  /// [isLunar] 음력 여부
  /// [relationship] 관계 family/friend/lover/other
  /// [familyRelation] 가족 세부 관계 parents/spouse/children/siblings
  /// [mbti] MBTI 성격유형 (선택)
  /// [bloodType] 혈액형 A/B/O/AB (선택)
  Future<SecondaryProfile?> addProfile({
    required String name,
    required String birthDate,
    String? birthTime,
    required String gender,
    bool isLunar = false,
    String? relationship,
    String? familyRelation,
    String? mbti,
    String? bloodType,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      developer.log('➕ SecondaryProfilesProvider: 프로필 추가 - $name');

      final response = await _supabase
          .from('secondary_profiles')
          .insert({
            'owner_id': userId,
            'name': name,
            'birth_date': birthDate,
            'birth_time': birthTime,
            'gender': gender,
            'is_lunar': isLunar,
            'relationship': relationship,
            'family_relation': familyRelation,
            'mbti': mbti,
            'blood_type': bloodType,
          })
          .select()
          .single();

      final newProfile = SecondaryProfile.fromJson(response);

      // 목록에 추가
      state = state.whenData((profiles) => [...profiles, newProfile]);

      developer
          .log('✅ SecondaryProfilesProvider: 프로필 추가 완료 - ${newProfile.id}');
      return newProfile;
    } catch (e) {
      developer.log('❌ SecondaryProfilesProvider 추가 실패: $e');
      rethrow;
    }
  }

  /// 프로필 수정
  Future<void> updateProfile(SecondaryProfile profile) async {
    try {
      developer.log('✏️ SecondaryProfilesProvider: 프로필 수정 - ${profile.name}');

      await _supabase.from('secondary_profiles').update({
        'name': profile.name,
        'birth_date': profile.birthDate,
        'birth_time': profile.birthTime,
        'gender': profile.gender,
        'is_lunar': profile.isLunar,
        'relationship': profile.relationship,
        'family_relation': profile.familyRelation,
        'mbti': profile.mbti,
        'blood_type': profile.bloodType,
        'avatar_index': profile.avatarIndex,
      }).eq('id', profile.id);

      // 목록 업데이트
      state = state.whenData((profiles) =>
          profiles.map((p) => p.id == profile.id ? profile : p).toList());

      developer.log('✅ SecondaryProfilesProvider: 프로필 수정 완료');
    } catch (e) {
      developer.log('❌ SecondaryProfilesProvider 수정 실패: $e');
      rethrow;
    }
  }

  /// 프로필 삭제
  Future<void> deleteProfile(String profileId) async {
    try {
      developer.log('🗑️ SecondaryProfilesProvider: 프로필 삭제 - $profileId');

      await _supabase.from('secondary_profiles').delete().eq('id', profileId);

      // 목록에서 제거
      state = state.whenData(
          (profiles) => profiles.where((p) => p.id != profileId).toList());

      developer.log('✅ SecondaryProfilesProvider: 프로필 삭제 완료');
    } catch (e) {
      developer.log('❌ SecondaryProfilesProvider 삭제 실패: $e');
      rethrow;
    }
  }

  /// 목록 새로고침
  Future<void> refresh() => _loadProfiles();

  /// 프로필 ID로 단일 프로필 조회
  SecondaryProfile? getProfileById(String id) {
    return state.whenOrNull(
      data: (profiles) {
        try {
          return profiles.firstWhere((p) => p.id == id);
        } catch (_) {
          return null;
        }
      },
    );
  }

  /// 가족 관계별 프로필 목록 조회
  ///
  /// [familyRelation] 가족 세부 관계 (parents/spouse/children/siblings)
  /// relationship이 'family'이고 familyRelation이 일치하는 프로필만 반환
  List<SecondaryProfile> getFamilyProfiles(String familyRelation) {
    return state.whenOrNull(
          data: (profiles) => profiles
              .where((p) =>
                  p.relationship == 'family' &&
                  p.familyRelation == familyRelation)
              .toList(),
        ) ??
        [];
  }

  /// 모든 가족 프로필 조회 (relationship이 'family'인 모든 프로필)
  List<SecondaryProfile> getAllFamilyProfiles() {
    return state.whenOrNull(
          data: (profiles) =>
              profiles.where((p) => p.relationship == 'family').toList(),
        ) ??
        [];
  }
}

/// 서브 프로필 개수 Provider (편의용)
final secondaryProfileCountProvider = Provider<int>((ref) {
  final profiles = ref.watch(secondaryProfilesProvider);
  return profiles.whenOrNull(data: (list) => list.length) ?? 0;
});

/// 최대 프로필 개수
const int maxSecondaryProfiles = 5;

/// 프로필 추가 가능 여부 Provider
final canAddSecondaryProfileProvider = Provider<bool>((ref) {
  final count = ref.watch(secondaryProfileCountProvider);
  return count < maxSecondaryProfiles;
});
