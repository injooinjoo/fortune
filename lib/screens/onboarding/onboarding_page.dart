import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/fortune_constants.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/fortune_haptic_service.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../models/unified_onboarding_progress.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/user_profile_notifier.dart';
import '../../services/storage_service.dart';
import '../../utils/date_utils.dart';
import '../auth/signup_screen.dart';
import 'steps/birth_input_step.dart';
import 'widgets/interest_selection_step.dart';
import 'widgets/personalized_handoff_step.dart';
import '../../features/character/presentation/utils/onboarding_interest_catalog.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool isPartialCompletion;
  final VoidCallback? onCompleted;
  final bool showGuestBrowseAction;

  const OnboardingPage({
    super.key,
    this.isPartialCompletion = false,
    this.onCompleted,
    this.showGuestBrowseAction = true,
  });

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();

  int _currentStep = 0;
  User? _currentUser;
  UserProfile? _existingProfile;

  String _name = '';
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  List<String> _selectedInterestIds = const [];

  bool _requireDisplayName = false;
  bool _isLoadingProfile = true;
  bool _isCompletingHandoff = false;
  bool _didScheduleAutoHandoff = false;

  UnifiedOnboardingProgress _progress = UnifiedOnboardingProgress.empty;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
        _didScheduleAutoHandoff = false;
        _isCompletingHandoff = false;
      });
    }

    final session = Supabase.instance.client.auth.currentSession;
    _currentUser = session?.user;
    _progress = await _storageService.getUnifiedOnboardingProgress();

    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    Map<String, dynamic>? existingProfileJson;

    try {
      try {
        existingProfileJson = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', _currentUser!.id)
            .maybeSingle();
      } catch (error) {
        debugPrint('Error loading onboarding profile from database: $error');
      }

      existingProfileJson ??= await _storageService.getUserProfile();
      if (existingProfileJson != null) {
        _existingProfile = UserProfile.fromJson(existingProfileJson);
      }

      final resolvedName = _resolveInitialName(existingProfileJson);
      final resolvedBirthDate = _parseBirthDate(existingProfileJson);
      final resolvedBirthTime = _parseBirthTime(existingProfileJson);
      final resolvedInterestIds = _parseSelectedInterests(existingProfileJson);

      final birthCompleted = resolvedBirthDate != null;
      final interestCompleted = resolvedInterestIds.isNotEmpty;
      final legacyCompleted =
          (existingProfileJson?['onboarding_completed'] == true) ||
              await _storageService.isCharacterOnboardingCompleted();

      var targetStep = 0;
      var nextProgress = _progress.copyWith(
        authCompleted: true,
        birthCompleted: birthCompleted,
        interestCompleted: interestCompleted,
      );

      if (legacyCompleted) {
        nextProgress = nextProgress.copyWith(
          softGateCompleted: true,
          authCompleted: true,
          birthCompleted: true,
          interestCompleted: true,
          firstRunHandoffSeen: true,
        );
      } else if (birthCompleted && interestCompleted) {
        targetStep = nextProgress.firstRunHandoffSeen ? 1 : 2;
      } else if (birthCompleted) {
        targetStep = 1;
      }

      await _storageService.saveUnifiedOnboardingProgress(nextProgress);

      if (legacyCompleted) {
        if (!mounted) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          if (widget.onCompleted != null) {
            widget.onCompleted!();
            return;
          }

          context.go('/chat');
        });
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _name = resolvedName;
        _birthDate = resolvedBirthDate;
        _birthTime = resolvedBirthTime;
        _selectedInterestIds = resolvedInterestIds;
        _requireDisplayName = !_hasRealName(resolvedName);
        _currentStep = targetStep;
        _progress = nextProgress;
        _isLoadingProfile = false;
      });

      if (targetStep > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _pageController.jumpToPage(targetStep);
          if (targetStep == 2) {
            _scheduleHandoffCompletion();
          }
        });
      }
    } catch (error) {
      debugPrint('Error initializing onboarding: $error');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  String _resolveInitialName(Map<String, dynamic>? existingProfileJson) {
    final existingName = existingProfileJson?['name']?.toString().trim() ?? '';
    if (_hasRealName(existingName)) {
      return existingName;
    }

    final metadataName =
        (_currentUser?.userMetadata?['full_name'] as String?)?.trim() ??
            (_currentUser?.userMetadata?['name'] as String?)?.trim() ??
            '';
    if (_hasRealName(metadataName)) {
      return metadataName;
    }

    final email = _currentUser?.email ?? '';
    if (email.isNotEmpty && !email.contains('kakao_')) {
      return email.split('@').first.trim();
    }

    return '';
  }

  DateTime? _parseBirthDate(Map<String, dynamic>? existingProfileJson) {
    final raw = existingProfileJson?['birth_date'];
    if (raw == null) {
      return null;
    }
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseBirthTime(Map<String, dynamic>? existingProfileJson) {
    final raw = existingProfileJson?['birth_time']?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final parts = raw.split(':');
    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<String> _parseSelectedInterests(
      Map<String, dynamic>? existingProfileJson) {
    final preferences = _asMap(existingProfileJson?['fortune_preferences']);
    final categoryWeights = _asMap(preferences?['category_weights']);
    if (categoryWeights == null) {
      return const [];
    }

    final parsed = <String, double>{};
    for (final entry in categoryWeights.entries) {
      final numeric = entry.value;
      if (numeric is num) {
        parsed[entry.key] = numeric.toDouble();
      }
    }
    return selectedOnboardingInterestIds(parsed);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  bool _hasRealName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return false;
    }

    const placeholders = {
      '사용자',
      'Apple 사용자',
      'Google 사용자',
      'user',
    };

    return !placeholders.contains(normalized) &&
        !normalized.startsWith('kakao_');
  }

  String _resolvedDisplayName() {
    if (_name.trim().isNotEmpty) {
      return _name.trim();
    }

    final metadataName =
        (_currentUser?.userMetadata?['full_name'] as String?)?.trim() ??
            (_currentUser?.userMetadata?['name'] as String?)?.trim() ??
            '';
    if (_hasRealName(metadataName)) {
      return metadataName;
    }

    final email = _currentUser?.email ?? '';
    if (email.isNotEmpty && !email.contains('kakao_')) {
      return email.split('@').first.trim();
    }

    return '';
  }

  Future<void> _nextFromBirth() async {
    if (_birthDate == null) {
      return;
    }

    _birthTime ??= const TimeOfDay(hour: 12, minute: 0);
    ref.read(fortuneHapticServiceProvider).pageSnap();
    await _storageService.updateUnifiedOnboardingProgress(
      authCompleted: _currentUser != null,
      birthCompleted: true,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentStep = 1;
    });
    await _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _goBackToBirth() async {
    setState(() {
      _currentStep = 0;
    });
    await _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleGuestBrowse() async {
    await _storageService.setGuestMode(true);
    await _storageService.updateUnifiedOnboardingProgress(
      softGateCompleted: true,
    );

    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }

    if (mounted) {
      context.go('/chat');
    }
  }

  void _scheduleHandoffCompletion() {
    if (_didScheduleAutoHandoff) {
      return;
    }

    _didScheduleAutoHandoff = true;
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) {
        return;
      }
      _completeHandoff();
    });
  }

  Future<void> _moveToHandoff() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentStep = 2;
    });

    await _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    _scheduleHandoffCompletion();
  }

  /// 프로필 완성 보너스 청구 (백그라운드)
  void _claimProfileCompletionBonus() {
    Future(() async {
      try {
        final result = await ref
            .read(tokenProvider.notifier)
            .claimProfileCompletionBonus();

        if (result['bonusGranted'] == true) {
          debugPrint('🎁 프로필 완성 보너스 ${result['bonusAmount']}토큰 지급 완료!');
        }
      } catch (error) {
        debugPrint('❌ 프로필 완성 보너스 청구 오류: $error');
      }
    });
  }

  /// 백그라운드에서 사주 계산 (UI 블로킹 없음)
  void _calculateSajuInBackground({
    required String userId,
    required String birthDate,
    required String birthTime,
  }) {
    Future(() async {
      try {
        final sajuResponse = await Supabase.instance.client.functions.invoke(
          'calculate-saju',
          body: {
            'birthDate': birthDate,
            'birthTime': birthTime,
            'isLunar': false,
            'timezone': 'Asia/Seoul',
          },
        ).timeout(
          const Duration(seconds: 45),
          onTimeout: () {
            throw Exception('사주 계산 시간 초과 (45초)');
          },
        );

        if (sajuResponse.status == 200 &&
            sajuResponse.data['success'] == true) {
          await Supabase.instance.client.from('user_profiles').update({
            'saju_calculated': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', userId);
        }
      } catch (error) {
        debugPrint('⚠️ [백그라운드] 사주 계산 오류: $error');
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_birthDate == null || _selectedInterestIds.length < 3) {
      return;
    }

    try {
      final resolvedName = _resolvedDisplayName();
      if (resolvedName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('대화에서 부를 이름을 입력해주세요.'),
              backgroundColor: context.colors.error,
            ),
          );
        }
        return;
      }

      final birthTimeString =
          '${(_birthTime ?? const TimeOfDay(hour: 12, minute: 0)).hour.toString().padLeft(2, '0')}:${(_birthTime ?? const TimeOfDay(hour: 12, minute: 0)).minute.toString().padLeft(2, '0')}';

      final existingPreferences =
          _existingProfile?.fortunePreferences ?? const FortunePreferences();
      final profile = (_existingProfile ??
              UserProfile(
                id: _currentUser?.id ?? '',
                name: resolvedName,
                email: _currentUser?.email ?? '',
                onboardingCompleted: false,
                subscriptionStatus: SubscriptionStatus.free,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .copyWith(
        name: resolvedName,
        email: _currentUser?.email ?? _existingProfile?.email ?? '',
        birthDate: _birthDate,
        birthTime: birthTimeString,
        gender: _existingProfile?.gender ?? Gender.other,
        zodiacSign: FortuneDateUtils.getZodiacSign(
          _birthDate!.toIso8601String(),
        ),
        chineseZodiac: FortuneDateUtils.getChineseZodiac(
          _birthDate!.toIso8601String(),
        ),
        onboardingCompleted: true,
        subscriptionStatus:
            _existingProfile?.subscriptionStatus ?? SubscriptionStatus.free,
        createdAt: _existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        primaryProvider: (_currentUser?.appMetadata['provider'] as String?) ??
            _existingProfile?.primaryProvider,
        linkedProviders: _existingProfile?.linkedProviders,
        fortunePreferences: existingPreferences.copyWith(
          categoryWeights: buildOnboardingInterestWeights(_selectedInterestIds),
          showPersonalized: true,
        ),
      );

      await _storageService.setRequiredPoliciesAccepted();
      await _storageService.saveUserProfile(profile.toJson());
      ref.read(userProfileNotifierProvider.notifier).applyProfile(profile);

      if (_currentUser != null) {
        await Supabase.instance.client.from('user_profiles').upsert({
          'id': _currentUser!.id,
          'email': _currentUser!.email,
          'name': profile.name,
          'birth_date': _birthDate!.toIso8601String(),
          'birth_time': birthTimeString,
          'gender': profile.gender.value,
          'onboarding_completed': true,
          'zodiac_sign': profile.zodiacSign,
          'chinese_zodiac': profile.chineseZodiac,
          'fortune_preferences': profile.fortunePreferences?.toJson(),
          'primary_provider': profile.primaryProvider,
          'linked_providers': profile.linkedProviders,
          'updated_at': DateTime.now().toIso8601String(),
        });

        _claimProfileCompletionBonus();
        _calculateSajuInBackground(
          userId: _currentUser!.id,
          birthDate: _birthDate!.toIso8601String().split('T')[0],
          birthTime: birthTimeString,
        );
      }

      _existingProfile = profile;
      await _storageService.updateUnifiedOnboardingProgress(
        authCompleted: _currentUser != null,
        birthCompleted: true,
        interestCompleted: true,
      );

      ref.read(fortuneHapticServiceProvider).sectionComplete();
      await _moveToHandoff();
    } catch (error) {
      debugPrint('프로필 저장 오류: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _completeHandoff() async {
    if (_isCompletingHandoff) {
      return;
    }

    _isCompletingHandoff = true;
    await _storageService.updateUnifiedOnboardingProgress(
      softGateCompleted: true,
      authCompleted: _currentUser != null,
      birthCompleted: _birthDate != null,
      interestCompleted: _selectedInterestIds.isNotEmpty,
      firstRunHandoffSeen: true,
    );
    await _storageService.setCharacterOnboardingCompleted();

    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }

    if (mounted) {
      context.go('/chat?firstTime=true');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const PaperRuntimeBackground(
          ringAlignment: Alignment.center,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return SignupScreen(
        eyebrow: widget.isPartialCompletion ? '빠르게 이어가기' : '개인화 시작',
        title: widget.isPartialCompletion
            ? '흐름을 이어가기 전에\n계정을 연결해주세요'
            : '대화를 바로 시작해볼까요?',
        description: widget.isPartialCompletion
            ? '로그인만 끝내면 생년월일과 관심사를 기준으로 화면을 더 자연스럽게 맞춰드릴게요.'
            : '계정을 연결하면 저장과 개인화가 바로 이어지고, 원할 때는 둘러보기로 가볍게 시작할 수도 있어요.',
        showBrowseAction: widget.showGuestBrowseAction,
        onAuthenticated: _initializeUser,
        onBrowseAsGuest:
            widget.showGuestBrowseAction ? _handleGuestBrowse : null,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          if (_currentStep < 2)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: DSSpacing.md),
                child: _OnboardingProgress(
                  currentStep: _currentStep.clamp(0, 1),
                  totalSteps: 2,
                ),
              ),
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BirthInputStep(
                  initialDate: _birthDate,
                  initialTime: _birthTime,
                  showBackButton: widget.onCompleted == null,
                  title: '언제 태어나셨어요?',
                  description:
                      '사주와 인사이트 정확도를 높이기 위해 생년월일을 먼저 받아요. 시간을 모르면 낮 12시 기준으로 이어집니다.',
                  ctaLabel: '관심사 고르기',
                  requireDisplayName: _requireDisplayName,
                  initialDisplayName: _name,
                  onDisplayNameChanged: (name) {
                    setState(() {
                      _name = name;
                    });
                  },
                  onBirthDateChanged: (date) {
                    setState(() {
                      _birthDate = date;
                    });
                  },
                  onBirthTimeChanged: (time) {
                    setState(() {
                      _birthTime = time;
                    });
                  },
                  onNext: _nextFromBirth,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/chat');
                    }
                  },
                ),
                InterestSelectionStep(
                  initialSelectedIds: _selectedInterestIds,
                  onSelectionChanged: (ids) {
                    setState(() {
                      _selectedInterestIds = ids;
                    });
                  },
                  onNext: _handleSubmit,
                  onBack: _goBackToBirth,
                ),
                PersonalizedHandoffStep(
                  selectedInterestIds: _selectedInterestIds,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _OnboardingProgress({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
          width: isActive ? 28 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? colors.textPrimary
                : colors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
