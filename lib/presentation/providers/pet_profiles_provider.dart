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
  PetProfilesNotifier() : super(const AsyncValue.loading()) {
    _loadProfiles();
  }

  final _supabase = Supabase.instance.client;

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

  Future<void> refresh() => _loadProfiles();
}
