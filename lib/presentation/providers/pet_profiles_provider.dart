import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../data/models/pet_profile.dart';

/// 반려동물 프로필 목록 Provider
final petProfilesProvider =
    StateNotifierProvider<PetProfilesNotifier, AsyncValue<List<PetProfile>>>(
  (ref) => PetProfilesNotifier(),
);

class PetProfilesNotifier extends StateNotifier<AsyncValue<List<PetProfile>>> {
  PetProfilesNotifier({
    bool loadOnInit = true,
    AsyncValue<List<PetProfile>>? initialState,
  }) : super(initialState ?? const AsyncValue.loading()) {
    if (loadOnInit) {
      _loadProfiles();
    }
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadProfiles() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      Logger.info('[PetProfiles] 반려동물 로드 시작 - $userId');

      final response = await _supabase
          .from('pets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final profiles = (response as List)
          .map((json) => PetProfile.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);

      state = AsyncValue.data(profiles);
      Logger.info('[PetProfiles] ${profiles.length}개 반려동물 로드 완료');
    } catch (e, st) {
      Logger.error('[PetProfiles] 로드 실패: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      Logger.info('[PetProfiles] 반려동물 삭제 - $profileId');

      await _supabase.from('pets').delete().eq('id', profileId);

      state = state.whenData(
        (profiles) =>
            profiles.where((profile) => profile.id != profileId).toList(),
      );

      Logger.info('[PetProfiles] 반려동물 삭제 완료');
    } catch (e) {
      Logger.error('[PetProfiles] 삭제 실패: $e');
      rethrow;
    }
  }

  Future<PetProfile> addProfile({
    required String name,
    required String species,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      Logger.info('[PetProfiles] 반려동물 추가 - $name');

      final response = await _supabase
          .from('pets')
          .insert({
            'user_id': userId,
            'name': name,
            'species': species,
          })
          .select()
          .single();

      final newProfile = PetProfile.fromJson(response);
      final currentProfiles = state.valueOrNull ?? const <PetProfile>[];
      state = AsyncValue.data([...currentProfiles, newProfile]);

      Logger.info('[PetProfiles] 반려동물 추가 완료 - ${newProfile.id}');
      return newProfile;
    } catch (e) {
      Logger.error('[PetProfiles] 추가 실패: $e');
      rethrow;
    }
  }

  Future<void> refresh() => _loadProfiles();
}
