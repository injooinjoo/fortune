import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import '../../data/models/secondary_profile.dart';
import 'providers.dart';
import 'secondary_profiles_provider.dart';

/// 활성 프로필 타입
enum ActiveProfileType {
  /// 본인 프로필 (user_profiles)
  primary,

  /// 다른 사람 프로필 (secondary_profiles)
  secondary,
}

/// 활성 프로필 상태
///
/// 현재 운세 조회에 사용되는 프로필 정보
class ActiveProfileState {
  /// 프로필 타입 (본인 또는 서브)
  final ActiveProfileType type;

  /// 서브 프로필 ID (type이 secondary일 때만 유효)
  final String? secondaryProfileId;

  const ActiveProfileState({
    this.type = ActiveProfileType.primary,
    this.secondaryProfileId,
  });

  /// 본인 프로필인지 확인
  bool get isPrimary => type == ActiveProfileType.primary;

  /// 서브 프로필인지 확인
  bool get isSecondary => type == ActiveProfileType.secondary;

  ActiveProfileState copyWith({
    ActiveProfileType? type,
    String? secondaryProfileId,
  }) {
    return ActiveProfileState(
      type: type ?? this.type,
      secondaryProfileId: secondaryProfileId ?? this.secondaryProfileId,
    );
  }

  @override
  String toString() =>
      'ActiveProfileState(type: $type, secondaryProfileId: $secondaryProfileId)';
}

/// 활성 프로필 Provider
///
/// 어떤 프로필로 운세를 조회할지 결정
final activeProfileProvider =
    StateNotifierProvider<ActiveProfileNotifier, ActiveProfileState>((ref) {
  return ActiveProfileNotifier(ref);
});

/// 활성 프로필 상태 관리 클래스
class ActiveProfileNotifier extends StateNotifier<ActiveProfileState> {
  final Ref _ref;

  ActiveProfileNotifier(this._ref) : super(const ActiveProfileState()) {
    _restoreSelection();
  }

  /// 본인 프로필로 전환
  void switchToPrimary() {
    activatePrimary();
  }

  /// 서브 프로필로 전환
  void switchToSecondary(String profileId) {
    final profiles = _ref.read(secondaryProfilesProvider).valueOrNull ?? [];
    if (profiles.isEmpty) return;
    final profile = profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => profiles.first,
    );
    activateSecondary(profile);
  }

  Future<void> activatePrimary() async {
    developer.log('🔄 ActiveProfile: 본인 프로필로 전환');
    state = const ActiveProfileState(type: ActiveProfileType.primary);
    await _ref.read(storageServiceProvider).saveActiveProfileSelection(
          type: 'primary',
        );
    _ref.read(userProfileNotifierProvider.notifier).clearOverride();
  }

  /// 서브 프로필로 전환
  Future<void> activateSecondary(SecondaryProfile profile) async {
    developer.log('🔄 ActiveProfile: 서브 프로필로 전환 - ${profile.id}');
    state = ActiveProfileState(
      type: ActiveProfileType.secondary,
      secondaryProfileId: profile.id,
    );
    await _ref.read(storageServiceProvider).saveActiveProfileSelection(
          type: 'secondary',
          secondaryProfileId: profile.id,
        );
    _ref
        .read(userProfileNotifierProvider.notifier)
        .applySecondaryProfile(profile);
  }

  /// 초기화 (로그아웃 시 등)
  void reset() {
    developer.log('🔄 ActiveProfile: 초기화');
    state = const ActiveProfileState();
    _ref.read(userProfileNotifierProvider.notifier).clearOverride();
  }

  Future<void> _restoreSelection() async {
    final storage = _ref.read(storageServiceProvider);
    final selection = await storage.getActiveProfileSelection();
    final type = selection['type'];
    final secondaryId = selection['secondaryProfileId'];

    if (type == 'secondary' && secondaryId != null) {
      state = ActiveProfileState(
        type: ActiveProfileType.secondary,
        secondaryProfileId: secondaryId,
      );

      await _ref.read(userProfileNotifierProvider.notifier).ensureLoaded(
            trigger: 'activeProfile.restore',
          );
      await _ref.read(secondaryProfilesProvider.notifier).refresh();
      final profiles = _ref.read(secondaryProfilesProvider).valueOrNull ?? [];
      if (profiles.isEmpty) {
        await activatePrimary();
        return;
      }

      final profile = profiles.firstWhere(
        (p) => p.id == secondaryId,
        orElse: () => profiles.first,
      );

      _ref.read(userProfileNotifierProvider.notifier).applySecondaryProfile(
            profile,
          );
    }
  }
}

/// 현재 활성 프로필의 운세 파라미터 Provider
///
/// 운세 조회 시 사용할 생년월일, 성별 등의 파라미터 반환
final activeFortuneParamsProvider = Provider<Map<String, dynamic>?>((ref) {
  final activeState = ref.watch(activeProfileProvider);

  if (activeState.isPrimary) {
    // 본인 프로필
    final profileAsync = ref.watch(userProfileProvider);
    return profileAsync.whenOrNull(
      data: (profile) {
        if (profile == null) return null;
        return {
          'birthDate': profile.birthDate?.toIso8601String().split('T').first,
          'birthTime': profile.birthTime,
          'gender': profile.gender,
          'isLunar': false, // UserProfile에 isLunar 필드가 없으므로 기본값
        };
      },
    );
  } else {
    // 서브 프로필
    final secondaryProfiles = ref.watch(secondaryProfilesProvider);
    return secondaryProfiles.whenOrNull(
      data: (profiles) {
        if (profiles.isEmpty) return null;

        final profile = profiles.firstWhere(
          (p) => p.id == activeState.secondaryProfileId,
          orElse: () => profiles.first,
        );
        return profile.toFortuneParams();
      },
    );
  }
});

/// 현재 활성 프로필 이름 Provider
final activeProfileNameProvider = Provider<String>((ref) {
  final activeState = ref.watch(activeProfileProvider);

  if (activeState.isPrimary) {
    final profileAsync = ref.watch(userProfileProvider);
    return profileAsync.whenOrNull(
          data: (profile) => profile?.name,
        ) ??
        '나';
  } else {
    final secondaryProfiles = ref.watch(secondaryProfilesProvider);
    return secondaryProfiles.whenOrNull(
          data: (profiles) {
            if (profiles.isEmpty) return '프로필';

            final profile = profiles.firstWhere(
              (p) => p.id == activeState.secondaryProfileId,
              orElse: () => profiles.first,
            );
            return profile.name;
          },
        ) ??
        '프로필';
  }
});

/// 현재 활성 서브 프로필 Provider (서브 프로필일 때만 값 반환)
final activeSecondaryProfileProvider = Provider<SecondaryProfile?>((ref) {
  final activeState = ref.watch(activeProfileProvider);

  if (activeState.isPrimary) return null;

  final secondaryProfiles = ref.watch(secondaryProfilesProvider);
  return secondaryProfiles.whenOrNull(
    data: (profiles) {
      if (profiles.isEmpty) return null;

      try {
        return profiles.firstWhere(
          (p) => p.id == activeState.secondaryProfileId,
        );
      } catch (_) {
        return profiles.isNotEmpty ? profiles.first : null;
      }
    },
  );
});

/// WidgetRef Extension - 활성 프로필 관련 헬퍼
extension ActiveProfileExtension on WidgetRef {
  /// 현재 활성 프로필이 본인인지 확인
  bool get isActivePrimary => watch(activeProfileProvider).isPrimary;

  /// 현재 활성 프로필이 서브 프로필인지 확인
  bool get isActiveSecondary => watch(activeProfileProvider).isSecondary;

  /// 활성 프로필 이름
  String get activeProfileName => watch(activeProfileNameProvider);

  /// 활성 프로필의 운세 파라미터
  Map<String, dynamic>? get activeFortuneParams =>
      watch(activeFortuneParamsProvider);

  /// 본인 프로필로 전환
  void switchToPrimaryProfile() {
    read(activeProfileProvider.notifier).switchToPrimary();
  }

  /// 서브 프로필로 전환
  void switchToSecondaryProfile(String profileId) {
    read(activeProfileProvider.notifier).switchToSecondary(profileId);
  }
}

/// 총 프로필 개수 Provider (본인 1개 + 서브 프로필 N개)
final totalProfileCountProvider = Provider<int>((ref) {
  final secondaryCount = ref.watch(secondaryProfileCountProvider);
  return 1 + secondaryCount; // 본인 + 서브 프로필
});
