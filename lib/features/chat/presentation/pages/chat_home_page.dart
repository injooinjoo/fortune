import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/personality_dna_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/asset_delivery_service.dart';
import '../../../../core/constants/asset_pack_config.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../shared/components/profile_header_icon.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../presentation/providers/secondary_profiles_provider.dart';
import '../../../../providers/pet_provider.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/models/secondary_profile.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../data/services/fortune_api/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart' hide FortuneElements;
import '../../../../core/cache/cache_service.dart';
import '../../domain/models/recommendation_chip.dart';
import '../../domain/models/fortune_survey_config.dart';
import '../../domain/configs/survey_configs.dart';
import '../../domain/services/intent_detector.dart';
import '../../data/services/fortune_recommend_service.dart';
import '../../data/services/free_chat_service.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../providers/chat_messages_provider.dart';
import '../providers/chat_survey_provider.dart';
import '../widgets/chat_welcome_view.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/survey/fortune_type_chips.dart';
import '../widgets/survey/chat_survey_chips.dart';
import '../widgets/survey/chat_image_input.dart';
import '../widgets/survey/ootd_photo_input.dart';
import '../widgets/survey/chat_profile_selector.dart';
import '../widgets/survey/chat_family_profile_selector.dart';
import '../widgets/survey/chat_pet_profile_selector.dart';
import '../widgets/survey/chat_date_picker.dart';
import '../widgets/survey/chat_inline_calendar.dart';
import '../widgets/survey/chat_survey_slider.dart';
import '../widgets/survey/chat_tarot_flow.dart';
import '../widgets/survey/chat_face_reading_flow.dart';
import '../widgets/survey/chat_birth_datetime_picker.dart';
import '../widgets/survey/chat_pet_registration_form.dart';
import '../widgets/survey/chat_investment_category_selector.dart';
import '../widgets/survey/chat_investment_ticker_selector.dart';
import '../widgets/survey/chat_celebrity_selector.dart';
import '../widgets/survey/chat_match_selector.dart';
import '../widgets/survey/chat_location_picker.dart';
import '../widgets/survey/chat_onboarding_inputs.dart';
import '../../domain/models/location_data.dart';
import '../../../../core/utils/direction_calculator.dart';
import '../../../../features/fortune/domain/models/sports_schedule.dart';
import '../../../../features/fortune/domain/models/match_insight.dart';
import '../../../../features/fortune/domain/models/past_life_result.dart';
import '../../../../features/fortune/domain/models/yearly_encounter_result.dart';
import '../widgets/guest_login_banner.dart';
import '../../../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../../../services/fortune_history_service.dart';
import '../../../../features/history/domain/models/fortune_history.dart';
import '../../../../services/social_auth_service.dart';
import '../../../../screens/profile/widgets/add_profile_sheet.dart';
import '../providers/onboarding_chat_provider.dart';
import '../../../fortune/presentation/providers/saju_provider.dart';
import '../../../../core/services/fortune_generators/fortune_cookie_generator.dart';
import '../../../fortune/domain/services/lotto_number_generator.dart';
import '../../../../core/services/unified_calendar_service.dart';
import '../../../fortune/presentation/widgets/floating_dream_topics_widget.dart';
import '../../../../data/dream_interpretations.dart';
import '../../../interactive/presentation/widgets/cookie_shard_break_widget.dart';
import '../../../../core/services/talisman_generation_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/deep_link_service.dart';
import '../widgets/profile_required_bottom_sheet.dart';
import '../../services/chat_scroll_service.dart';

/// Chat-First 메인 홈 페이지
class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({super.key});

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  List<DetectedIntent> _detectedIntents = [];

  /// 통합 스크롤 서비스 (1회 스크롤 원칙 적용)
  late final ChatScrollService _scrollService;

  /// AI 추천 서비스
  late final FortuneRecommendService _recommendService;

  /// 자유 채팅 서비스
  late final FreeChatService _freeChatService;

  /// AI 추천 로딩 상태
  bool _isLoadingRecommendations = false;

  /// 프로필 생성 완료 후 궁합 진행해야 할지 여부
  bool _pendingCompatibilityAfterProfileCreation = false;

  /// 온보딩 시작 여부 플래그
  bool _onboardingStarted = false;

  /// 캘린더 연동 서비스 (기간별 운세용)
  final UnifiedCalendarService _calendarService = UnifiedCalendarService();
  bool _isCalendarSynced = false;

  /// 꿈해몽 버블 표시 여부
  bool _showDreamBubbles = true;

  /// 펫 등록 폼 표시 여부
  bool _showPetRegistrationForm = false;

  /// 포춘쿠키 애니메이션 오버레이 표시 여부
  bool _showCookieAnimation = false;

  /// 오늘의 타로 덱 (다운로드 완료 시 설정)
  String? _todaysTarotDeck;

  /// 타로 덱 다운로드 중 여부
  bool _isDownloadingTarotDeck = false;

  static const Map<FortuneSurveyType, String> _fortuneBackgroundAssets = {
    FortuneSurveyType.daily: 'assets/images/chat/backgrounds/bg_daily.png',
    FortuneSurveyType.newYear: 'assets/images/chat/backgrounds/bg_daily.png',
    FortuneSurveyType.dailyCalendar:
        'assets/images/chat/backgrounds/bg_time.png',
    FortuneSurveyType.love: 'assets/images/chat/backgrounds/bg_love.png',
    FortuneSurveyType.yearlyEncounter:
        'assets/images/chat/backgrounds/bg_love.png',
    FortuneSurveyType.avoidPeople:
        'assets/images/chat/backgrounds/bg_avoid_people.png',
    FortuneSurveyType.exam: 'assets/images/chat/backgrounds/bg_exam.png',
    FortuneSurveyType.career: 'assets/images/chat/backgrounds/bg_career.png',
    FortuneSurveyType.money: 'assets/images/chat/backgrounds/bg_money.png',
    FortuneSurveyType.luckyItems:
        'assets/images/chat/backgrounds/bg_lucky_items.png',
    FortuneSurveyType.lotto: 'assets/images/chat/backgrounds/bg_lotto.png',
    FortuneSurveyType.tarot: 'assets/images/chat/backgrounds/bg_tarot.png',
    FortuneSurveyType.traditional:
        'assets/images/chat/backgrounds/bg_traditional.png',
    FortuneSurveyType.faceReading:
        'assets/images/chat/backgrounds/bg_face_reading.png',
    FortuneSurveyType.talisman:
        'assets/images/chat/backgrounds/bg_talisman.png',
    FortuneSurveyType.biorhythm:
        'assets/images/chat/backgrounds/bg_biorhythm.png',
    FortuneSurveyType.sportsGame:
        'assets/images/chat/backgrounds/bg_sports_game.png',
    FortuneSurveyType.dream: 'assets/images/chat/backgrounds/bg_dream.png',
    FortuneSurveyType.wish: 'assets/images/chat/backgrounds/bg_wish.png',
    FortuneSurveyType.fortuneCookie:
        'assets/images/chat/backgrounds/bg_fortune_cookie.png',
    FortuneSurveyType.compatibility:
        'assets/images/chat/backgrounds/bg_compatibility.png',
    FortuneSurveyType.pet: 'assets/images/chat/backgrounds/bg_pet.png',
    FortuneSurveyType.family: 'assets/images/chat/backgrounds/bg_family.png',
    FortuneSurveyType.health: 'assets/images/chat/backgrounds/bg_health.png',
    FortuneSurveyType.talent: 'assets/images/chat/backgrounds/bg_talent.png',
  };

  String? _chatBackgroundAsset;
  static const String _defaultChatBackgroundAsset =
      'assets/images/chat/backgrounds/bg_chat_default.png';

  @override
  void initState() {
    super.initState();
    _scrollService = ChatScrollService(
      scrollController: _scrollController,
      isMounted: () => mounted,
    );
    _recommendService = FortuneRecommendService();
    _freeChatService = FreeChatService();
    _textController.addListener(_onTextChanged);
    _initializeCalendarService();

    // 초기화 후 온보딩 체크 및 딥링크 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartOnboarding();
      _precacheChatBackgrounds();
      _checkPendingDeepLink();
    });
  }

  /// 딥링크로 전달된 fortuneType 확인 및 자동 칩 선택
  Future<void> _checkPendingDeepLink() async {
    try {
      final pendingFortuneType = await DeepLinkService.consumePendingFortuneType();
      if (pendingFortuneType == null) return;

      debugPrint('🔗 [DeepLink] Pending fortune type: $pendingFortuneType');

      // fortuneType에 매칭되는 칩 찾기
      final matchingChip = defaultChips.firstWhere(
        (chip) => chip.fortuneType == pendingFortuneType,
        orElse: () => defaultChips.first,
      );

      // 약간의 딜레이 후 칩 탭 (UI 준비 대기)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        debugPrint('🔗 [DeepLink] Auto-tapping chip: ${matchingChip.label}');
        await _handleChipTap(matchingChip);
      }
    } catch (e) {
      debugPrint('⚠️ [DeepLink] Error checking pending deep link: $e');
    }
  }

  void _precacheChatBackgrounds() {
    final assets = <String>{
      _defaultChatBackgroundAsset,
      ..._fortuneBackgroundAssets.values,
    };
    for (final asset in assets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  /// 온보딩 필요 여부 확인 및 시작
  void _checkAndStartOnboarding() {
    if (_onboardingStarted) return;

    final onboardingState = ref.read(onboardingChatProvider);
    final chatState = ref.read(chatMessagesProvider);

    // ✅ 핵심: isCheckingStatus가 true면 아직 비동기 체크 중 → 기다려야 함
    if (onboardingState.isCheckingStatus) {
      debugPrint(
          '🔍 [_checkAndStartOnboarding] Still checking status, will retry...');
      // 상태 체크 완료 후 다시 확인
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkAndStartOnboarding();
      });
      return;
    }

    // 온보딩이 필요하고 채팅이 비어있으면 시작
    if (onboardingState.needsOnboarding &&
        onboardingState.currentStep == OnboardingStep.welcome &&
        chatState.isEmpty) {
      _onboardingStarted = true;
      ref.read(onboardingChatProvider.notifier).startOnboarding();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _recommendService.dispose();
    _scrollService.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// 캘린더 서비스 초기화 (기간별 운세용)
  Future<void> _initializeCalendarService() async {
    try {
      await _calendarService.initialize();

      if (_calendarService.isGoogleConnected) {
        if (mounted) {
          setState(() => _isCalendarSynced = true);
        }
        return;
      }

      final hasDevicePermission =
          await _calendarService.requestDevicePermission();
      if (hasDevicePermission && mounted) {
        setState(() => _isCalendarSynced = true);
      }
    } catch (e) {
      debugPrint('[Calendar] 초기화 실패: $e');
    }
  }

  /// 캘린더 연동 시작 (설문 답변 'sync' 선택 시)
  Future<void> _handleCalendarSync() async {
    try {
      final hasPermission = await _calendarService.requestDevicePermission();
      if (hasPermission && mounted) {
        setState(() => _isCalendarSynced = true);
      }
    } catch (e) {
      debugPrint('[Calendar] 연동 실패: $e');
    }
  }

  /// 특정 날짜의 캘린더 이벤트 로드
  Future<List<CalendarEventSummary>> _loadEventsForDate(DateTime date) async {
    try {
      return await _calendarService.getEventsForDate(date);
    } catch (e) {
      debugPrint('[Calendar] 이벤트 로드 실패: $e');
      return [];
    }
  }

  /// 캘린더 바텀시트 열기 버튼 빌드
  Widget _buildCalendarOpenButton({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.accentSecondary,
              borderRadius: BorderRadius.circular(DSRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: colors.accentSecondary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '날짜 선택하기',
                  style: typography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 기간별 운세 캘린더 바텀시트 표시
  void _showDailyCalendarBottomSheet({required bool showEvents}) {
    DSBottomSheet.show(
      context: context,
      title: '날짜 선택',
      showHandle: true,
      isScrollable: true,
      maxHeightFactor: 0.85,
      child: ChatInlineCalendar(
        onDateSelected: (date) {
          // showEventsAfterSelection=true일 때는 즉시 호출되지 않음
        },
        onDateConfirmed: (date, events) {
          Navigator.of(context).pop(); // 바텀시트 닫기

          final displayText = DateFormat('yyyy년 M월 d일').format(date);
          final eventSummary =
              events.isEmpty ? '' : ' (${events.length}개 일정 포함)';

          // 날짜와 이벤트를 함께 저장 (단일 날짜만)
          _handleSurveyAnswerValue(
            {
              'date': date.toIso8601String(),
              'events': events
                  .map((e) => {
                        'title': e.title,
                        'description': e.description,
                        'start_time': e.startTime?.toIso8601String(),
                        'end_time': e.endTime?.toIso8601String(),
                        'location': e.location,
                        'is_all_day': e.isAllDay,
                      })
                  .toList(),
            },
            '$displayText$eventSummary',
          );
        },
        // 단일 날짜 선택만 허용
        allowMultipleDates: false,
        showQuickOptions: true,
        showEventsAfterSelection: showEvents,
        isCalendarSynced: showEvents,
        onLoadEvents: _loadEventsForDate,
      ),
    );
  }

  /// 소셜 로그인 바텀시트 표시
  void _showSocialLoginBottomSheet(BuildContext context) {
    SocialAuthService? socialAuthService;
    try {
      socialAuthService = SocialAuthService(Supabase.instance.client);
    } catch (e) {
      debugPrint('⚠️ [ChatHomePage] SocialAuthService init failed: $e');
      return;
    }

    SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () async {
        Navigator.pop(context);
        try {
          await socialAuthService!.signInWithGoogle();
          // 로그인 성공 시 온보딩 완료 처리
          ref.read(onboardingChatProvider.notifier).skipLoginPrompt();
        } catch (e) {
          debugPrint('❌ Google login failed: $e');
        }
      },
      onAppleLogin: () async {
        Navigator.pop(context);
        try {
          await socialAuthService!.signInWithApple();
          ref.read(onboardingChatProvider.notifier).skipLoginPrompt();
        } catch (e) {
          debugPrint('❌ Apple login failed: $e');
        }
      },
      onKakaoLogin: () async {
        Navigator.pop(context);
        try {
          await socialAuthService!.signInWithKakao();
          ref.read(onboardingChatProvider.notifier).skipLoginPrompt();
        } catch (e) {
          debugPrint('❌ Kakao login failed: $e');
        }
      },
      onNaverLogin: () async {
        Navigator.pop(context);
        try {
          await socialAuthService!.signInWithNaver();
          ref.read(onboardingChatProvider.notifier).skipLoginPrompt();
        } catch (e) {
          debugPrint('❌ Naver login failed: $e');
        }
      },
      isProcessing: false,
      ref: ref,
    );
  }

  void _onTextChanged() {
    // 온보딩 중일 때는 추천 서비스 호출하지 않음
    final onboardingState = ref.read(onboardingChatProvider);
    final isOnboarding = onboardingState.needsOnboarding ||
        onboardingState.currentStep != OnboardingStep.completed;
    if (isOnboarding) {
      debugPrint(
          '🔇 [ChatHomePage] Skipping recommendations - onboarding active');
      return;
    }

    final text = _textController.text;
    if (text.length >= 2) {
      // 1. 즉시 키워드 기반 결과 표시 (빠른 피드백)
      final keywordIntents = IntentDetector.detectIntents(text);
      if (mounted) {
        setState(() {
          _detectedIntents =
              keywordIntents.where((i) => i.isConfident).toList();
        });
      }

      // 2. AI 추천 비동기 호출 (디바운싱)
      if (mounted) {
        setState(() => _isLoadingRecommendations = true);
      }

      _recommendService.getRecommendationsDebounced(
        text,
        onSuccess: (response) {
          if (mounted && response.recommendations.isNotEmpty) {
            // AI 결과를 우선 표시 (키워드 결과 교체)
            setState(() {
              _detectedIntents = response.toDetectedIntents();
              _isLoadingRecommendations = false;
            });
          } else if (mounted) {
            setState(() => _isLoadingRecommendations = false);
          }
        },
        onError: () {
          // 에러 시 키워드 결과 유지
          if (mounted) {
            setState(() => _isLoadingRecommendations = false);
          }
        },
      );
    } else {
      if ((_detectedIntents.isNotEmpty || _isLoadingRecommendations) &&
          mounted) {
        _recommendService.cancelDebounce();
        setState(() {
          _detectedIntents = [];
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  /// 최하단으로 스크롤 (ChatScrollService 위임)
  void _scrollToBottom() {
    _scrollService.scrollToBottom();
  }

  /// 운세 결과 카드 헤더로 스크롤 (1회만, ChatScrollService 위임)
  void _handleFortuneResultRendered(String messageId, BuildContext cardContext) {
    _scrollService.scrollToFortuneResult(
      messageId: messageId,
      cardContext: cardContext,
    );
  }

  /// 포춘쿠키 애니메이션 표시 후 결과 표시
  void _showFortuneCookieWithAnimation() {
    setState(() {
      _showCookieAnimation = true;
    });
  }

  /// 포춘쿠키 애니메이션 완료 후 결과 표시
  Future<void> _onCookieAnimationComplete() async {
    setState(() {
      _showCookieAnimation = false;
    });

    final chatNotifier = ref.read(chatMessagesProvider.notifier);

    // 운세 데이터 가져오기
    try {
      final cookieResult = await FortuneCookieGenerator.getTodayFortuneCookie();
      final userId = Supabase.instance.client.auth.currentUser?.id ??
          await StorageService().getOrCreateGuestId();

      // 모든 쿠키 데이터 포함
      final fortune = Fortune(
        id: 'fortune-cookie-${DateTime.now().toIso8601String().split('T')[0]}',
        userId: userId,
        type: 'fortune-cookie',
        content: cookieResult.data['message'] as String? ?? '',
        createdAt: DateTime.now(),
        overallScore: cookieResult.score,
        luckyItems: {
          'cookie_type': cookieResult.data['cookie_type'],
          'lucky_number': cookieResult.data['lucky_number'],
          'lucky_color': cookieResult.data['lucky_color'],
          'lucky_color_hex': cookieResult.data['lucky_color_hex'],
          'lucky_time': cookieResult.data['lucky_time'],
          'lucky_direction': cookieResult.data['lucky_direction'],
          'action_mission': cookieResult.data['action_mission'],
          'emoji': cookieResult.data['emoji'],
        },
      );

      // 결과 메시지 추가 (포춘쿠키 전용 카드로 표시됨)
      // 스크롤은 FortuneResultScrollWrapper의 onRendered 콜백으로 자동 처리됨
      chatNotifier.addFortuneResultMessage(
        text: '오늘의 메시지',
        fortuneType: 'fortune-cookie',
        fortune: fortune,
        isBlurred: false,
        blurredSections: [],
      );

      // 추천 칩 표시
      Future.delayed(const Duration(milliseconds: 500), () {
        chatNotifier.addSystemMessage();
      });
    } catch (e) {
      Logger.error('Fortune Cookie 생성 실패', e);
      chatNotifier.addAiMessage(
        '죄송해요, 쿠키를 여는 중 문제가 발생했어요. 😢\n'
        '잠시 후 다시 시도해주세요.',
      );
      _scrollToBottom();
    }
  }

  /// 더보기 버튼 탭 - 전체 운세 칩 표시
  void _handleViewAllTap() {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    chatNotifier.addAiMessage(
      '다양한 인사이트를 확인해보세요! 🌟\n'
      '아래에서 원하는 서비스를 선택해주세요.',
    );
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 200), () {
      chatNotifier.addSystemMessage(showAllChips: true);
      _scrollToBottom();
    });
  }

  /// birthDate가 필요한 fortune type 목록
  /// (사주 기반 운세는 생년월일 필수)
  static const _birthDateRequiredTypes = {
    'daily', // 오늘의 나
    'newYear', // 새해 운세
    'daily_calendar', // 기간별 인사이트
    'dailyCalendar', // 기간별 인사이트 (다른 표기)
    'compatibility', // 궁합
    'blindDate', // 소개팅 운세
    'love', // 연애운
    'yearlyEncounter', // 올해의 인연
    'traditional', // 사주 분석
    'biorhythm', // 바이오리듬
    'health', // 건강운
    'money', // 재물운
    'luckyItems', // 럭키 아이템
    'family', // 가족운
  };

  /// 프로필(birthDate) 체크 후 없으면 로그인/게스트 선택 바텀시트 표시
  /// 점신, 포스텔러 등 다른 앱처럼 로컬 저장 정보도 인정
  ///
  /// Returns: true면 진행 가능, false면 중단 (로그인 이동 또는 온보딩 시작)
  Future<bool> _checkProfileOrShowLoginPrompt(RecommendationChip chip) async {
    // 1. Supabase 프로필 확인
    final userProfileAsync = ref.read(userProfileNotifierProvider);
    final userProfile = userProfileAsync.valueOrNull;

    if (userProfile != null && userProfile.birthDate != null) {
      return true;
    }

    // 2. 로컬 저장소 프로필 확인 (게스트 사용자도 이용 가능하게)
    final storageService = StorageService();
    final localProfile = await storageService.getUserProfile();

    if (localProfile != null &&
        localProfile['birth_date'] != null &&
        localProfile['birth_date'].toString().isNotEmpty) {
      Logger.info('🎯 [ChatHomePage] 로컬 프로필로 진행 허용');
      return true;
    }

    // 3. 온보딩 완료 상태 확인
    final onboardingState = ref.read(onboardingChatProvider);
    if (onboardingState.currentStep == OnboardingStep.completed) {
      return true;
    }

    // 4. 프로필 없음 → 선택 모달 표시
    final action = await ProfileRequiredBottomSheet.show(context);

    if (action == ProfileRequiredAction.login) {
      // 로그인 페이지로 이동
      if (mounted) {
        context.go('/');
      }
      return false;
    } else if (action == ProfileRequiredAction.continueAsGuest) {
      // 온보딩 시작 (생년월일 등 입력)
      final chatNotifier = ref.read(chatMessagesProvider.notifier);
      chatNotifier.addUserMessage(chip.label);
      _scrollToBottom();

      // 온보딩 시작
      ref.read(onboardingChatProvider.notifier).startOnboarding();
      return false;
    }

    // 사용자가 모달을 닫음
    return false;
  }

  Future<void> _handleChipTap(RecommendationChip chip) async {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // birthDate 필요한 운세 타입: 프로필 체크 필요
    // (점신, 포스텔러 등 다른 앱처럼 로컬 저장 정보도 인정)
    if (_birthDateRequiredTypes.contains(chip.fortuneType)) {
      final canProceed = await _checkProfileOrShowLoginPrompt(chip);
      if (!canProceed) return;
    }

    // 전체운세보기: 모든 운세 칩 표시
    if (chip.fortuneType == 'viewAll') {
      chatNotifier.addUserMessage(chip.label);
      _scrollToBottom();
      Future.delayed(const Duration(milliseconds: 300), () {
        chatNotifier.addAiMessage(
          '다양한 인사이트를 확인해보세요! 🌟\n'
          '아래에서 원하는 서비스를 선택해주세요.',
        );
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 200), () {
          chatNotifier.addSystemMessage(showAllChips: true);
          _scrollToBottom();
        });
      });
      return;
    }

    // 숨쉬기: 웰니스 페이지로 직접 이동
    if (chip.fortuneType == 'breathing') {
      _setChatBackgroundAsset(
        'assets/images/chat/backgrounds/bg_breathing.png',
      );
      context.push('/wellness/meditation');
      return;
    }

    // 포춘쿠키: 인라인 애니메이션 후 결과 표시
    if (chip.fortuneType == 'fortuneCookie') {
      _updateChatBackgroundForType(FortuneSurveyType.fortuneCookie);
      chatNotifier.addUserMessage(chip.label);
      _scrollToBottom();
      _showFortuneCookieWithAnimation();
      return;
    }

    // 꿈해몽: 채팅 초기화 후 새로 시작
    if (chip.fortuneType == 'dream') {
      chatNotifier.clearConversation();
      surveyNotifier.cancelSurvey();
      _updateChatBackgroundForType(FortuneSurveyType.dream);
      setState(() => _showDreamBubbles = true);

      // 약간의 딜레이 후 사용자 메시지 추가 (초기화 후 렌더링 위해)
      await Future.delayed(const Duration(milliseconds: 100));
      chatNotifier.addUserMessage(chip.label);
      _scrollController.jumpTo(0);

      // 인사 메시지 생성 및 표시
      final userProfileAsync = ref.read(userProfileNotifierProvider);
      final userProfile = userProfileAsync.valueOrNull;
      final greeting = _buildGreetingMessage(userProfile, FortuneSurveyType.dream);

      Future.delayed(const Duration(milliseconds: 300), () {
        chatNotifier.addAiMessage(greeting);
        surveyNotifier.startSurvey(FortuneSurveyType.dream);
      });
      return;
    }

    // chip.fortuneType을 FortuneSurveyType으로 매핑
    final surveyType = _mapChipToSurveyType(chip.fortuneType);

    if (surveyType != null) {
      _updateChatBackgroundForType(surveyType);
      // 사주 분석 특별 처리 (ChatSajuResultCard 사용 - 설문 건너뛰기)
      if (surveyType == FortuneSurveyType.traditional) {
        chatNotifier.addUserMessage(chip.label);
        _scrollToBottom();
        _handleSajuRequest();
        return;
      }

      // 타로 특별 처리: 오늘의 덱 다운로드 후 진행
      if (surveyType == FortuneSurveyType.tarot) {
        chatNotifier.addUserMessage(chip.label);
        _scrollToBottom();
        _prepareTarotDeckAndStart(surveyNotifier, chatNotifier);
        return;
      }

      // 설문 설정 가져오기
      final config = surveyConfigs[surveyType];

      // 설문 단계가 없으면 바로 API 호출 (daily 등)
      if (config == null || config.steps.isEmpty) {
        chatNotifier.addUserMessage(chip.label);
        _scrollToBottom();

        // 사용자 프로필 가져오기
        final userProfileAsync = ref.read(userProfileNotifierProvider);
        final userProfile = userProfileAsync.valueOrNull;

        // 인사 메시지 생성 및 표시
        final greeting = _buildGreetingMessage(userProfile, surveyType);
        Future.delayed(const Duration(milliseconds: 300), () {
          chatNotifier.addAiMessage(greeting);
          _scrollToBottom();

          // 바로 운세 API 호출 및 결과 표시
          final typeName = _getTypeDisplayName(surveyType);
          final fortuneTypeStr = _mapSurveyTypeToString(surveyType);

          _callFortuneApiWithCache(type: surveyType, answers: {})
              .then((fortune) {
            // Fortune 객체와 함께 리치 카드 표시
            // 스크롤은 FortuneResultScrollWrapper의 onRendered 콜백으로 자동 처리됨
            chatNotifier.addFortuneResultMessage(
              text: typeName,
              fortuneType: fortuneTypeStr,
              fortune: fortune,
              isBlurred: fortune.isBlurred,
              blurredSections: fortune.blurredSections,
            );

            // 운세 결과 후 추천 칩 표시 (스크롤 없이 - 결과 카드가 보이게 유지)
            Future.delayed(const Duration(milliseconds: 500), () {
              chatNotifier.addSystemMessage();
            });
          }).catchError((error) {
            Logger.error('Fortune API 호출 실패', error);
            chatNotifier.addAiMessage(
              '죄송해요, 분석 중 문제가 발생했어요. 😢\n'
              '잠시 후 다시 시도해주세요.\n\n'
              '다른 인사이트를 확인해볼까요?',
            );
            _scrollToBottom();
          });
        });
        return;
      }

      // 기간별 인사이트: 하루 1회 제한 - 캐시 확인
      if (surveyType == FortuneSurveyType.dailyCalendar) {
        final userId = Supabase.instance.client.auth.currentUser?.id ??
            await StorageService().getOrCreateGuestId();
        final cacheService = CacheService();

        if (cacheService.hasTodayDailyCalendarFortune(userId)) {
          // 오늘 이미 조회했으면 바로 결과 표시 (설문 스킵)
          chatNotifier.addUserMessage(chip.label);
          chatNotifier.showTypingIndicator();
          _scrollToBottom();

          cacheService
              .getTodayDailyCalendarFortune(userId)
              .then((cachedFortune) {
            if (cachedFortune != null) {
              chatNotifier.addAiMessage('오늘 이미 조회하셨네요! 결과를 다시 보여드릴게요. 📅');
              _scrollToBottom();

              Future.delayed(const Duration(milliseconds: 300), () {
                // 스크롤은 FortuneResultScrollWrapper의 onRendered 콜백으로 자동 처리됨
                chatNotifier.addFortuneResultMessage(
                  text: '기간별 인사이트',
                  fortuneType: 'daily_calendar',
                  fortune: cachedFortune,
                  isBlurred: cachedFortune.isBlurred,
                  blurredSections: cachedFortune.blurredSections,
                  selectedDate: DateTime.now(), // 캐시된 결과는 오늘 날짜
                );

                // 추천 칩 표시 (스크롤 없이 - 결과 카드가 보이게 유지)
                Future.delayed(const Duration(milliseconds: 500), () {
                  chatNotifier.addSystemMessage();
                });
              });
            }
          });
          return;
        }
      }

      // 설문 지원 타입 → 설문 시작
      chatNotifier.addUserMessage(chip.label);
      _scrollToBottom();

      // 사용자 프로필 가져오기
      final userProfileAsync = ref.read(userProfileNotifierProvider);
      final userProfile = userProfileAsync.valueOrNull;

      // 인사 메시지 생성 및 표시
      final greeting = _buildGreetingMessage(userProfile, surveyType);
      Future.delayed(const Duration(milliseconds: 300), () {
        chatNotifier.addAiMessage(greeting);
        _scrollToBottom();

        // 설문 시작 (연애운은 프로필 성별 자동 적용)
        Map<String, dynamic>? initialAnswers;
        if (surveyType == FortuneSurveyType.love &&
            userProfile?.gender != null) {
          initialAnswers = {'gender': userProfile!.gender};
        }
        surveyNotifier.startSurvey(surveyType, initialAnswers: initialAnswers);

        // dailyCalendar이고 이미 캘린더 연동되어 있으면 첫 단계 건너뛰기
        if (surveyType == FortuneSurveyType.dailyCalendar &&
            _isCalendarSynced) {
          // 자동으로 'sync' 답변 처리 후 다음 단계로
          surveyNotifier.answerCurrentStep('sync');
          chatNotifier.addAiMessage('캘린더가 이미 연동되어 있어요! 📅');
        }

        // 궁합: 첫 단계(inputMethod) 건너뛰고 바로 프로필 선택 또는 새로 입력
        if (surveyType == FortuneSurveyType.compatibility) {
          _handleCompatibilityAutoSkip(surveyNotifier);
        }

        // AI 첫 질문 메시지
        Future.delayed(const Duration(milliseconds: 500), () {
          final surveyState = ref.read(chatSurveyProvider);
          if (surveyState.activeProgress != null &&
              surveyState.activeProgress!.config.steps.isNotEmpty) {
            final question = _buildDynamicQuestion(surveyState.activeProgress!);
            chatNotifier.addAiMessage(question);
            _scrollToBottom();
          }
        });
      });
    } else {
      // 미지원 타입 → 준비 중 메시지
      chatNotifier.addUserMessage(chip.label);
      chatNotifier.showTypingIndicator();
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 800), () {
        chatNotifier.addAiMessage(
          '${chip.label} 기능은 곧 준비될 예정이에요! 🔮\n다른 인사이트를 먼저 확인해보시겠어요?',
        );
        _scrollToBottom();
      });
    }
  }

  void _updateChatBackgroundForType(FortuneSurveyType? type) {
    if (type == null) return;
    final asset = _fortuneBackgroundAssets[type];
    if (asset == null) return;
    _setChatBackgroundAsset(asset);
  }

  void _setChatBackgroundAsset(String asset) {
    if (_chatBackgroundAsset == asset) return;
    setState(() {
      _chatBackgroundAsset = asset;
    });
  }

  DateTime _getCsatDate(DateTime now) {
    int year = now.year;
    DateTime csatDate = _thirdThursdayOfNovember(year);
    final today = DateTime(now.year, now.month, now.day);
    if (today.isAfter(csatDate)) {
      year += 1;
      csatDate = _thirdThursdayOfNovember(year);
    }
    return csatDate;
  }

  DateTime _thirdThursdayOfNovember(int year) {
    int count = 0;
    for (int day = 1; day <= 30; day += 1) {
      final date = DateTime(year, 11, day);
      if (date.weekday == DateTime.thursday) {
        count += 1;
        if (count == 3) {
          return date;
        }
      }
    }
    return DateTime(year, 11, 1);
  }

  String _normalizeDateValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is DateTime) {
      return value.toIso8601String().split('T')[0];
    }
    if (value is String) {
      return value.split('T')[0];
    }
    return value.toString();
  }

  /// RecommendationChip의 fortuneType을 FortuneSurveyType으로 매핑 (30개 전체)
  FortuneSurveyType? _mapChipToSurveyType(String fortuneType) {
    switch (fortuneType) {
      // 기존 6개
      case 'career':
        return FortuneSurveyType.career;
      case 'love':
        return FortuneSurveyType.love;
      case 'daily':
        return FortuneSurveyType.daily;
      case 'talent':
        return FortuneSurveyType.talent;
      case 'tarot':
        return FortuneSurveyType.tarot;
      case 'mbti':
        return FortuneSurveyType.mbti;
      // 시간 기반
      case 'newYear':
        return FortuneSurveyType.newYear;
      case 'daily_calendar':
        return FortuneSurveyType.dailyCalendar;
      // 전통 분석
      case 'traditional':
        return FortuneSurveyType.traditional;
      case 'faceReading':
        return FortuneSurveyType.faceReading;
      // 성격/개성
      case 'personalityDna':
        return FortuneSurveyType.personalityDna;
      case 'biorhythm':
        return FortuneSurveyType.biorhythm;
      // 연애/관계
      case 'compatibility':
        return FortuneSurveyType.compatibility;
      case 'avoidPeople':
        return FortuneSurveyType.avoidPeople;
      case 'exLover':
        return FortuneSurveyType.exLover;
      case 'blindDate':
        return FortuneSurveyType.blindDate;
      case 'yearlyEncounter':
        return FortuneSurveyType.yearlyEncounter;
      // 재물
      case 'money':
        return FortuneSurveyType.money;
      // 라이프스타일
      case 'luckyItems':
        return FortuneSurveyType.luckyItems;
      case 'lotto':
        return FortuneSurveyType.lotto;
      case 'wish':
        return FortuneSurveyType.wish;
      case 'fortuneCookie':
        return FortuneSurveyType.fortuneCookie;
      // 건강/스포츠
      case 'health':
        return FortuneSurveyType.health;
      case 'exercise':
        return FortuneSurveyType.exercise;
      case 'sportsGame':
        return FortuneSurveyType.sportsGame;
      // 인터랙티브
      case 'dream':
        return FortuneSurveyType.dream;
      case 'celebrity':
        return FortuneSurveyType.celebrity;
      case 'pastLife':
        return FortuneSurveyType.pastLife;
      case 'gameEnhance':
        return FortuneSurveyType.gameEnhance;
      // 가족/반려동물
      case 'pet':
        return FortuneSurveyType.pet;
      case 'family':
        return FortuneSurveyType.family;
      case 'naming':
        return FortuneSurveyType.naming;
      // 스타일/패션
      case 'ootdEvaluation':
        return FortuneSurveyType.ootdEvaluation;
      // 전통/신비 (추가)
      case 'talisman':
        return FortuneSurveyType.talisman;
      // 실용/결정
      case 'exam':
        return FortuneSurveyType.exam;
      case 'moving':
        return FortuneSurveyType.moving;
      // 웰니스
      case 'gratitude':
        return FortuneSurveyType.gratitude;
      default:
        return null;
    }
  }

  /// 온보딩 이름 입력 제출
  void _handleOnboardingNameSubmit(String text) {
    if (text.trim().isEmpty) return;

    // 이름 파싱: "김인주입니다", "김인주 입니다", "제 이름은 김인주예요" 등에서 이름 추출
    final name = _parseNameFromText(text.trim());
    debugPrint(
        '🔍 [_handleOnboardingNameSubmit] Original: $text, Parsed: $name');

    ref.read(onboardingChatProvider.notifier).submitName(name);
    _textController.clear();
    _scrollToBottom();
  }

  /// 텍스트에서 이름 추출 (한국어 문장 패턴 처리)
  String _parseNameFromText(String text) {
    // 공백 정리
    final cleaned = text.trim();

    // 패턴 1: "OOO입니다", "OOO 입니다", "OOO이에요", "OOO예요", "OOO요"
    final suffixPatterns = [
      RegExp(r'^(.+?)\s*입니다\.?$'),
      RegExp(r'^(.+?)\s*이에요\.?$'),
      RegExp(r'^(.+?)\s*예요\.?$'),
      RegExp(r'^(.+?)\s*이요\.?$'),
      RegExp(r'^(.+?)\s*요\.?$'),
      RegExp(r'^(.+?)\s*이야\.?$'),
      RegExp(r'^(.+?)\s*야\.?$'),
    ];

    for (final pattern in suffixPatterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        final extracted = match.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          // "제 이름은", "저는", "나는" 등 접두사 제거
          return _removePrefixes(extracted);
        }
      }
    }

    // 패턴 2: "제 이름은 OOO", "저는 OOO", "나는 OOO"
    final prefixPatterns = [
      RegExp(r'^제?\s*이름은\s*(.+)$'),
      RegExp(r'^저는\s*(.+)$'),
      RegExp(r'^나는\s*(.+)$'),
      RegExp(r'^전\s*(.+)$'),
      RegExp(r'^난\s*(.+)$'),
    ];

    for (final pattern in prefixPatterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        final extracted = match.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    // 패턴 매칭 실패 시 원본 반환
    return cleaned;
  }

  /// 이름 앞의 접두사 제거
  String _removePrefixes(String text) {
    final prefixes = ['제 이름은', '이름은', '저는', '나는', '전', '난'];
    var result = text;
    for (final prefix in prefixes) {
      if (result.startsWith(prefix)) {
        result = result.substring(prefix.length).trim();
      }
    }
    return result;
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 온보딩 중이면 온보딩 핸들러로 위임 (빌드 시점 레이스 컨디션 방지)
    final onboardingState = ref.read(onboardingChatProvider);
    debugPrint(
        '🔍 [_handleSendMessage] needsOnboarding: ${onboardingState.needsOnboarding}, currentStep: ${onboardingState.currentStep}');

    // 온보딩 진행 중이면 모든 입력을 온보딩으로 처리
    // ✅ currentStep 기준으로 판단 (needsOnboarding이 stale data로 false일 수 있음)
    final isOnboardingActive =
        onboardingState.currentStep != OnboardingStep.completed;
    debugPrint(
        '🔍 [_handleSendMessage] isOnboardingActive: $isOnboardingActive');

    if (isOnboardingActive) {
      if (onboardingState.currentStep == OnboardingStep.name ||
          onboardingState.currentStep == OnboardingStep.welcome) {
        // 이름 입력 또는 웰컴 단계에서 텍스트 입력 시 이름으로 처리
        debugPrint('🔍 [_handleSendMessage] Delegating to onboarding: $text');
        _handleOnboardingNameSubmit(text);
        return;
      }
      // birthDate/birthTime 단계에서는 텍스트 입력 무시 (picker 사용)
      debugPrint('🔍 [_handleSendMessage] Ignoring text during picker step');
      return;
    }

    // 의도 감지 (인사이트 추천용)
    final intents = IntentDetector.detectIntents(text);
    final hasConfidentIntent = intents.isNotEmpty && intents.first.isConfident;

    // 의도가 감지되면 기존 플로우 (인사이트 추천)
    if (hasConfidentIntent) {
      final notifier = ref.read(chatMessagesProvider.notifier);
      notifier.addUserMessage(text);
      _textController.clear();
      setState(() {
        _detectedIntents = [];
      });
      _scrollToBottom();

      final primaryIntent = intents.first;
      Future.delayed(const Duration(milliseconds: 500), () {
        notifier.addAiMessage(
          IntentDetector.getSuggestionMessage(primaryIntent.type),
        );
        _scrollToBottom();
      });
      return;
    }

    // 의도가 없으면 자유 채팅 (토큰 소비 + AI 응답)
    final tokenState = ref.read(tokenProvider);
    final hasUnlimitedAccess = tokenState.balance?.hasUnlimitedAccess ?? false;
    final remainingTokens = tokenState.balance?.remainingTokens ?? 0;
    final isTokenLoaded = tokenState.balance != null;

    // 토큰 체크 (무제한 이용권이 아니고 토큰이 부족한 경우)
    // 토큰 데이터가 로드되지 않았으면 체크 스킵 (나중에 소비 시 검증됨)
    if (isTokenLoaded && !hasUnlimitedAccess && remainingTokens < 1) {
      await TokenInsufficientModal.show(
        context: context,
        requiredTokens: 1,
        fortuneType: 'free-chat',
      );
      return;
    }

    final notifier = ref.read(chatMessagesProvider.notifier);
    notifier.addUserMessage(text);
    _textController.clear();
    setState(() {
      _detectedIntents = [];
    });
    _scrollToBottom();

    // 타이핑 인디케이터 표시
    notifier.showTypingIndicator();

    try {
      // 토큰 소비 (무제한 이용권이 아닌 경우만)
      if (!hasUnlimitedAccess) {
        await ref.read(tokenProvider.notifier).consumeTokens(
          fortuneType: 'free-chat',
          amount: 1,
        );
      }

      // AI 호출 (사용자 프로필 정보 포함)
      final userProfile = ref.read(userProfileNotifierProvider).valueOrNull;
      final response = await _freeChatService.sendMessage(
        text,
        context: FreeChatContext(
          userName: userProfile?.name,
          birthDate: userProfile?.birthDate?.toIso8601String(),
          birthTime: userProfile?.birthTime,
          gender: userProfile?.gender.value,
          mbti: userProfile?.mbti,
          zodiacSign: userProfile?.zodiacSign,
          chineseZodiac: userProfile?.chineseZodiac,
          bloodType: userProfile?.bloodType,
        ),
      );

      notifier.hideTypingIndicator();
      notifier.addAiMessage(response);
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ [_handleSendMessage] 자유 채팅 에러: $e');
      notifier.hideTypingIndicator();
      notifier.addAiMessage('죄송해요, 잠시 문제가 생겼어요. 다시 시도해주세요.');
      _scrollToBottom();
    }
  }

  void _handleFortuneTypeSelect(FortuneSurveyType type) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 텍스트 필드 초기화
    _textController.clear();
    setState(() {
      _detectedIntents = [];
      // 꿈해몽 선택 시 버블 표시 초기화
      if (type == FortuneSurveyType.dream) {
        _showDreamBubbles = true;
      }
    });
    _updateChatBackgroundForType(type);

    // 사용자 선택 메시지 추가
    final typeName = _getTypeDisplayName(type);
    chatNotifier.addUserMessage('$typeName 봐주세요');
    _scrollToBottom();

    // 사용자 프로필 가져오기
    final userProfileAsync = ref.read(userProfileNotifierProvider);
    final userProfile = userProfileAsync.valueOrNull;

    // 인사 메시지 생성 및 표시
    final greeting = _buildGreetingMessage(userProfile, type);
    Future.delayed(const Duration(milliseconds: 300), () {
      chatNotifier.addAiMessage(greeting);
      _scrollToBottom();

      // 설문 시작 (연애운은 프로필 성별 자동 적용)
      Map<String, dynamic>? initialAnswers;
      if (type == FortuneSurveyType.love && userProfile?.gender != null) {
        initialAnswers = {'gender': userProfile!.gender};
      }
      surveyNotifier.startSurvey(type, initialAnswers: initialAnswers);

      // dailyCalendar이고 이미 캘린더 연동되어 있으면 첫 단계 건너뛰기
      if (type == FortuneSurveyType.dailyCalendar && _isCalendarSynced) {
        surveyNotifier.answerCurrentStep('sync');
        chatNotifier.addAiMessage('캘린더가 이미 연동되어 있어요! 📅');
      }

      // 궁합: 첫 단계(inputMethod) 건너뛰고 바로 프로필 선택 또는 새로 입력
      if (type == FortuneSurveyType.compatibility) {
        _handleCompatibilityAutoSkip(surveyNotifier);
      }

      // AI 첫 질문 메시지 (설문 단계가 있는 경우)
      Future.delayed(const Duration(milliseconds: 500), () {
        final surveyState = ref.read(chatSurveyProvider);
        if (surveyState.activeProgress != null &&
            surveyState.activeProgress!.config.steps.isNotEmpty) {
          final question = _buildDynamicQuestion(surveyState.activeProgress!);
          chatNotifier.addAiMessage(question);
          _scrollToBottom();
        }
      });
    });
  }

  /// 사용자 프로필 기반 인사 메시지 생성
  String _buildGreetingMessage(UserProfile? profile, FortuneSurveyType type) {
    final name = profile?.name ?? '회원';
    final birthDate = profile?.birthDate;
    final zodiacSign = profile?.zodiacSign;

    String birthInfo = '';
    if (birthDate != null) {
      final formatter = DateFormat('yyyy년 M월 d일');
      birthInfo = formatter.format(birthDate);
      if (profile?.birthTime != null) {
        birthInfo += ' ${profile!.birthTime}생';
      } else {
        birthInfo += '생';
      }
    }

    switch (type) {
      case FortuneSurveyType.daily:
        if (zodiacSign != null) {
          return '$name님! $zodiacSign의 오늘 인사이트를 확인해드릴게요. ✨';
        }
        return '$name님의 오늘 인사이트를 확인해드릴게요! ✨';

      case FortuneSurveyType.newYear:
        final year = DateTime.now().year;
        return '$name님의 $year년 인사이트를 살펴볼게요! 🎊';

      case FortuneSurveyType.traditional:
        if (birthInfo.isNotEmpty) {
          return '$name님의 사주를 분석해볼게요.\n$birthInfo이시네요. 📿';
        }
        return '$name님의 사주를 분석해볼게요! 📿';

      case FortuneSurveyType.career:
        return '$name님! 직업운을 살펴볼게요. 💼';

      case FortuneSurveyType.love:
        return '$name님의 연애운을 봐드릴게요! 💕';

      case FortuneSurveyType.compatibility:
        return '$name님, 누구와의 궁합을 볼까요? 💞';

      case FortuneSurveyType.tarot:
        return '$name님, 타로 카드를 뽑아볼게요! 🃏';

      case FortuneSurveyType.mbti:
        if (profile?.mbtiType != null) {
          return '$name님은 ${profile!.mbtiType}시네요! 맞으신가요? 🧠';
        }
        return 'MBTI 유형을 알려주시면 분석해드릴게요! 🧠';

      case FortuneSurveyType.biorhythm:
        if (birthInfo.isNotEmpty) {
          return '$name님($birthInfo) 기준 바이오리듬을 확인해볼게요! 📊';
        }
        return '$name님의 바이오리듬을 확인해볼게요! 📊';

      case FortuneSurveyType.faceReading:
        return '$name님! AI 관상 분석을 시작해볼게요. 🎭';

      case FortuneSurveyType.personalityDna:
        return '$name님의 성격 DNA를 분석해볼게요! 🧬';

      case FortuneSurveyType.money:
        return '$name님의 재물운을 살펴볼게요! 💰';

      case FortuneSurveyType.luckyItems:
        return '$name님! 오늘의 행운 아이템을 알려드릴게요. 🍀';

      case FortuneSurveyType.lotto:
        return '$name님의 행운 번호를 뽑아볼게요! 🎰';

      case FortuneSurveyType.health:
        return '$name님의 건강 인사이트를 확인해드릴게요! 💊';

      case FortuneSurveyType.dream:
        return '$name님, 꿈 이야기를 들려주세요! 💭';

      case FortuneSurveyType.pastLife:
        return '$name님의 전생을 탐험해볼게요! 🔮';

      case FortuneSurveyType.gameEnhance:
        return '$name님! 오늘의 강화 기운을 확인해볼게요. 🎮✨';

      case FortuneSurveyType.pet:
        return '$name님! 반려동물 궁합을 봐드릴게요. 🐾';

      case FortuneSurveyType.family:
        return '$name님의 가족 인사이트를 살펴볼게요! 👨‍👩‍👧‍👦';

      case FortuneSurveyType.naming:
        return '좋은 이름을 찾아드릴게요, $name님! 📝';

      case FortuneSurveyType.ootdEvaluation:
        return '$name님! 오늘의 패션을 평가해드릴게요. 👔✨';

      default:
        return '안녕하세요, $name님! ${_getTypeDisplayName(type)}를 봐드릴게요. ✨';
    }
  }

  void _handleSurveyAnswer(SurveyOption option) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 사용자 답변 메시지
    final displayText =
        option.emoji != null ? '${option.emoji} ${option.label}' : option.label;
    chatNotifier.addUserMessage(displayText);
    _scrollToBottom();

    // 답변 처리
    surveyNotifier.answerCurrentStep(option.id);

    // 다음 질문 또는 완료 처리
    Future.delayed(const Duration(milliseconds: 300), () {
      final surveyState = ref.read(chatSurveyProvider);

      if (surveyState.isCompleted) {
        // 설문 완료 → 공통 완료 처리로 위임
        _handleSurveyComplete(surveyState);
      } else if (surveyState.activeProgress != null) {
        // 다음 질문
        final question = _buildDynamicQuestion(surveyState.activeProgress!);
        chatNotifier.addAiMessage(question);
        _scrollToBottom();
      }
    });
  }

  /// 텍스트 입력형 설문 답변 처리 (성, 이름 등)
  void _handleTextSurveySubmit(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _handleSurveyAnswerValue(text.trim(), text.trim());
  }

  /// 감사일기 리액션 메시지 풀
  static const _gratitudeReactions = [
    '와, 정말 멋진 일이네요! 💛',
    '듣기만 해도 제 마음이 다 따뜻해져요 🥰',
    '그런 순간이 있었군요, 정말 소중하네요 ✨',
    '일상 속 작은 행복을 발견하셨네요 🌸',
  ];

  /// 범용 설문 답변 처리 (옵션 외 입력: 텍스트, 날짜, 슬라이더 등)
  void _handleSurveyAnswerValue(dynamic value, String displayText) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 현재 설문 상태 확인 (답변 처리 전)
    final beforeState = ref.read(chatSurveyProvider);
    final isGratitude = beforeState.activeProgress?.config.fortuneType ==
        FortuneSurveyType.gratitude;
    final gratitudeStepIndex =
        beforeState.activeProgress?.currentStepIndex ?? 0;

    // 사용자 답변 메시지
    chatNotifier.addUserMessage(displayText);
    _scrollToBottom();

    // 답변 처리
    surveyNotifier.answerCurrentStep(value);

    // 감사일기인 경우 리액션 추가
    if (isGratitude && gratitudeStepIndex < 2) {
      // 아직 완료되지 않은 경우에만 리액션 표시
      Future.delayed(const Duration(milliseconds: 300), () {
        // 랜덤 리액션 선택
        final reaction = _gratitudeReactions[
            gratitudeStepIndex % _gratitudeReactions.length];
        chatNotifier.addAiMessage(reaction);
        _scrollToBottom();

        // 다음 질문 표시
        Future.delayed(const Duration(milliseconds: 500), () {
          final surveyState = ref.read(chatSurveyProvider);
          if (surveyState.activeProgress != null && !surveyState.isCompleted) {
            final question = _buildDynamicQuestion(surveyState.activeProgress!);
            chatNotifier.addAiMessage(question);
            _scrollToBottom();
          }
        });
      });
    } else if (isGratitude && gratitudeStepIndex == 2) {
      // 마지막 답변 후 완료 처리
      Future.delayed(const Duration(milliseconds: 300), () {
        final surveyState = ref.read(chatSurveyProvider);
        if (surveyState.isCompleted) {
          _handleSurveyComplete(surveyState);
        }
      });
    } else {
      // 일반 설문 처리
      Future.delayed(const Duration(milliseconds: 300), () {
        final surveyState = ref.read(chatSurveyProvider);

        if (surveyState.isCompleted) {
          _handleSurveyComplete(surveyState);
        } else if (surveyState.activeProgress != null) {
          final question = _buildDynamicQuestion(surveyState.activeProgress!);
          chatNotifier.addAiMessage(question);
          _scrollToBottom();
        }
      });
    }
  }

  /// 관계 깊이 값 매핑 (Flutter → Edge Function)
  String _mapRelationshipDepth(String? value) {
    const mapping = {
      'short_casual': 'casual',
      'growing': 'moderate',
      'serious': 'deep',
      'deep': 'deep',
      'long_term': 'very_deep',
      'engagement': 'very_deep',
    };
    return mapping[value] ?? 'moderate';
  }

  /// 연락 상태 값 매핑 (Flutter → Edge Function)
  String _mapContactStatus(String? value) {
    const mapping = {
      'blocked_both': 'blocked',
      'blocked_by_them': 'blocked',
      'i_blocked': 'blocked',
      'no_contact': 'noContact',
      'occasional': 'sometimes',
      'frequent': 'often',
      'still_meeting': 'stillMeeting',
    };
    return mapping[value] ?? 'noContact';
  }

  /// 상대방 이름 정규화 ("몰라", "모름" 등 → 빈 문자열로 변환)
  /// Edge Function에서 빈 문자열이면 "그 사람"으로 대체
  String _normalizeExPartnerName(String? value) {
    if (value == null || value.trim().isEmpty) return '';

    final normalized = value.trim().toLowerCase();

    // "모른다"류 패턴
    const unknownPatterns = [
      '몰라',
      '모름',
      '모르',
      '모르겠',
      '기억안',
      '기억 안',
      '생각안',
      '생각 안',
      '잊어',
      '잊었',
      '없어',
      '없음',
      '없다',
      '패스',
      '스킵',
      'skip',
      'pass',
      '그냥',
      '됐어',
      '안알려',
      '안 알려',
      '비밀',
    ];

    for (final pattern in unknownPatterns) {
      if (normalized.contains(pattern)) {
        return ''; // Edge Function에서 "그 사람"으로 대체됨
      }
    }

    // 단순 기호만 입력한 경우
    if (RegExp(r'^[\s\-\.…~?!]+$').hasMatch(normalized)) {
      return '';
    }

    return value.trim();
  }

  /// 다중 선택 설문 답변 처리 (currentState 등)
  void _handleSurveyAnswerMultiple(
    List<String> selectedIds,
    List<SurveyOption> options,
  ) {
    if (selectedIds.isEmpty) return;

    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 선택된 옵션들의 레이블 조합하여 표시
    final selectedOptions =
        options.where((opt) => selectedIds.contains(opt.id)).toList();
    final displayText = selectedOptions
        .map((opt) =>
            opt.emoji != null ? '${opt.emoji} ${opt.label}' : opt.label)
        .join(', ');
    chatNotifier.addUserMessage(displayText);
    _scrollToBottom();

    // 답변 처리 (List로 저장)
    surveyNotifier.answerCurrentStep(selectedIds);

    // 다음 질문 또는 완료 처리
    Future.delayed(const Duration(milliseconds: 300), () {
      final surveyState = ref.read(chatSurveyProvider);

      if (surveyState.isCompleted) {
        _handleSurveyComplete(surveyState);
      } else if (surveyState.activeProgress != null) {
        final question = _buildDynamicQuestion(surveyState.activeProgress!);
        chatNotifier.addAiMessage(question);
        _scrollToBottom();
      }
    });
  }

  /// 동적 질문 생성 (이전 답변 기반 개인화)
  String _buildDynamicQuestion(SurveyProgress progress) {
    final question = progress.currentStep.question;
    final answers = progress.answers;
    final surveyType = progress.config.fortuneType;
    final stepId = progress.currentStep.id;

    // 재회 인사이트: 상대방 이름으로 질문 개인화
    if (surveyType == FortuneSurveyType.exLover) {
      final partnerName = answers['exPartnerName'] as String?;
      if (partnerName != null && partnerName.isNotEmpty) {
        // 은/는 조사 처리 (받침 유무)
        final lastChar = partnerName.characters.last;
        final hasJongseong = _hasKoreanJongseong(lastChar);
        final particle = hasJongseong ? '은' : '는';

        // 질문별 개인화
        if (stepId == 'exPartnerBirthYear') {
          return '$partnerName$particle 몇 년생이야? 👤';
        }
        if (stepId == 'exPartnerMbti') {
          return '$partnerName MBTI 알아? 🎭\n(성격 분석에 도움이 돼)';
        }
      }
    }

    return question;
  }

  /// 한글 종성(받침) 유무 확인
  bool _hasKoreanJongseong(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    // 한글 유니코드 범위: 0xAC00 ~ 0xD7A3
    if (code < 0xAC00 || code > 0xD7A3) return false;
    // 종성 = (code - 0xAC00) % 28
    return (code - 0xAC00) % 28 != 0;
  }

  /// 설문 완료 처리 공통 로직
  void _handleSurveyComplete(ChatSurveyState surveyState) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    final completedType = surveyState.completedType;
    final completedData = surveyState.completedData ?? {};

    // 프로필 생성 완료 처리
    if (completedType == FortuneSurveyType.profileCreation) {
      _handleProfileCreationComplete(completedData);
      return;
    }

    // 사주 분석 특별 처리 (ChatSajuResultCard 사용)
    if (completedType == FortuneSurveyType.traditional) {
      _handleSajuRequest();
      surveyNotifier.clearCompleted();
      return;
    }

    // 감사일기 특별 처리 (API 호출 없이 로컬 표시)
    if (completedType == FortuneSurveyType.gratitude) {
      _handleGratitudeComplete(completedData);
      surveyNotifier.clearCompleted();
      return;
    }

    // 성격 DNA 특별 처리 (PersonalityDNAService 사용)
    if (completedType == FortuneSurveyType.personalityDna) {
      _handlePersonalityDnaComplete(completedData);
      surveyNotifier.clearCompleted();
      return;
    }

    // 부적 특별 처리 (TalismanGenerationService 사용 - 이미지 생성)
    if (completedType == FortuneSurveyType.talisman) {
      _handleTalismanComplete(completedData);
      surveyNotifier.clearCompleted();
      return;
    }

    chatNotifier.showTypingIndicator();
    _scrollToBottom();

    final typeName =
        completedType != null ? _getTypeDisplayName(completedType) : '인사이트';

    // API 호출 (점 3개 로딩 애니메이션 표시 중) - 캐시 우선 확인
    _callFortuneApiWithCache(
      type: completedType ?? FortuneSurveyType.daily,
      answers: completedData,
    ).then((fortune) {
      // 기간별 인사이트: 결과 캐싱 (하루 1회 제한용)
      if (completedType == FortuneSurveyType.dailyCalendar) {
        CacheService().cacheDailyCalendarFortune(fortune);
      }

      // 기간별 인사이트: 선택한 날짜 추출
      DateTime? selectedDate;
      if (completedType == FortuneSurveyType.dailyCalendar) {
        final targetDateAnswer = completedData['targetDate'];
        if (targetDateAnswer is Map) {
          // 다중 날짜 선택 모드: dates 배열에서 첫 번째 날짜 사용
          if (targetDateAnswer['isMultipleDates'] == true) {
            final dates = targetDateAnswer['dates'] as List?;
            if (dates != null && dates.isNotEmpty) {
              final firstDateStr = dates.first as String?;
              if (firstDateStr != null) {
                selectedDate = DateTime.tryParse(firstDateStr);
              }
            }
          } else {
            // 단일 날짜 선택 모드: date 키 사용
            final dateStr = targetDateAnswer['date'] as String?;
            if (dateStr != null) {
              selectedDate = DateTime.tryParse(dateStr);
            }
          }
        } else if (targetDateAnswer is String) {
          selectedDate = DateTime.tryParse(targetDateAnswer);
        }
      }

      // Fortune 객체와 함께 리치 카드 표시 (모든 운세 유형 동일 처리)
      final fortuneTypeStr =
          _mapSurveyTypeToString(completedType ?? FortuneSurveyType.daily);

      // match-insight인 경우 MatchInsight 구성
      MatchInsight? matchInsight;
      if (fortuneTypeStr == 'match-insight') {
        try {
          final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
          final matchData = completedData['match'] as Map<String, dynamic>?;
          final sportStr = completedData['sport'] as String? ?? 'baseball';

          Logger.info(
              '[ChatHome] MatchInsight 구성 시작: sport=$sportStr, matchData=$matchData');
          Logger.info('[ChatHome] metadata keys: ${metadata.keys.toList()}');

          // SportType 변환
          SportType sportType;
          switch (sportStr) {
            case 'soccer':
              sportType = SportType.soccer;
              break;
            case 'basketball':
              sportType = SportType.basketball;
              break;
            case 'volleyball':
              sportType = SportType.volleyball;
              break;
            case 'esports':
              sportType = SportType.esports;
              break;
            case 'american_football':
              sportType = SportType.americanFootball;
              break;
            case 'fighting':
              sportType = SportType.fighting;
              break;
            default:
              sportType = SportType.baseball;
          }

          // 경기 정보 추출
          final homeTeam = matchData?['homeTeam'] as String? ?? '';
          final awayTeam = matchData?['awayTeam'] as String? ?? '';
          final gameTimeStr = matchData?['gameTime'] as String? ??
              matchData?['startTime'] as String?;
          final gameDate = gameTimeStr != null
              ? DateTime.tryParse(gameTimeStr) ?? DateTime.now()
              : DateTime.now();
          final favoriteTeam = completedData['favoriteTeam'] as String?;

          // prediction 파싱
          final predictionData =
              metadata['prediction'] as Map<String, dynamic>? ?? {};
          final prediction = MatchPrediction(
            winProbability:
                (predictionData['winProbability'] as num?)?.toInt() ?? 50,
            confidence: predictionData['confidence'] as String? ?? 'medium',
            keyFactors:
                (predictionData['keyFactors'] as List?)?.cast<String>() ?? [],
            predictedScore: predictionData['predictedScore'] as String?,
            mvpCandidate: predictionData['mvpCandidate'] as String?,
          );

          // favoriteTeamAnalysis 파싱
          final ftaData =
              metadata['favoriteTeamAnalysis'] as Map<String, dynamic>? ?? {};
          final favoriteTeamAnalysis = TeamAnalysis(
            name: ftaData['name'] as String? ?? favoriteTeam ?? homeTeam,
            recentForm: ftaData['recentForm'] as String? ?? '',
            strengths: (ftaData['strengths'] as List?)?.cast<String>() ?? [],
            concerns: (ftaData['concerns'] as List?)?.cast<String>() ?? [],
            keyPlayer: ftaData['keyPlayer'] as String?,
            formEmoji: ftaData['formEmoji'] as String?,
          );

          // opponentAnalysis 파싱
          final oaData =
              metadata['opponentAnalysis'] as Map<String, dynamic>? ?? {};
          final opponentAnalysis = TeamAnalysis(
            name: oaData['name'] as String? ??
                (favoriteTeam == homeTeam ? awayTeam : homeTeam),
            recentForm: oaData['recentForm'] as String? ?? '',
            strengths: (oaData['strengths'] as List?)?.cast<String>() ?? [],
            concerns: (oaData['concerns'] as List?)?.cast<String>() ?? [],
            keyPlayer: oaData['keyPlayer'] as String?,
            formEmoji: oaData['formEmoji'] as String?,
          );

          // fortuneElements 파싱
          final feData =
              metadata['fortuneElements'] as Map<String, dynamic>? ?? {};
          final fortuneElements = FortuneElements(
            luckyColor: feData['luckyColor'] as String? ?? '',
            luckyNumber: (feData['luckyNumber'] as num?)?.toInt() ?? 7,
            luckyTime: feData['luckyTime'] as String? ?? '',
            luckyItem: feData['luckyItem'] as String? ?? '',
            luckySection: feData['luckySection'] as String?,
            luckyAction: feData['luckyAction'] as String?,
          );

          matchInsight = MatchInsight(
            id: fortune.id,
            score: fortune.overallScore ??
                (metadata['score'] as num?)?.toInt() ??
                75,
            content: fortune.content,
            summary: fortune.summary ?? metadata['summary'] as String? ?? '',
            advice: metadata['advice'] as String? ?? '',
            prediction: prediction,
            favoriteTeamAnalysis: favoriteTeamAnalysis,
            opponentAnalysis: opponentAnalysis,
            fortuneElements: fortuneElements,
            cautionMessage: metadata['cautionMessage'] as String? ??
                '이 인사이트는 순수 재미 목적입니다. 도박이나 베팅에 활용하지 마세요.',
            timestamp: DateTime.now(),
            sport: sportType,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            gameDate: gameDate,
            favoriteTeam: favoriteTeam,
            isBlurred: fortune.isBlurred,
            blurredSections: fortune.blurredSections,
          );

          Logger.info(
              '[ChatHome] MatchInsight 구성 성공: score=${matchInsight.score}, $homeTeam vs $awayTeam');
        } catch (e, st) {
          Logger.error('[ChatHome] MatchInsight 구성 실패', e, st);
        }
      }

      // past-life인 경우 PastLifeResult 구성
      PastLifeResult? pastLifeResult;
      if (fortuneTypeStr == 'past-life') {
        try {
          final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
          Logger.info(
              '[ChatHome] PastLifeResult 구성 시작: metadata keys=${metadata.keys.toList()}');

          pastLifeResult = PastLifeResult.fromJson({
            'id': fortune.id,
            ...metadata,
            'isBlurred': fortune.isBlurred,
            'blurredSections': fortune.blurredSections,
          });

          Logger.info(
              '[ChatHome] PastLifeResult 구성 성공: status=${pastLifeResult.pastLifeStatus}, era=${pastLifeResult.pastLifeEra}');
        } catch (e, st) {
          Logger.error('[ChatHome] PastLifeResult 구성 실패', e, st);
        }
      }

      // yearly-encounter인 경우 YearlyEncounterResult 구성
      YearlyEncounterResult? yearlyEncounterResult;
      if (fortuneTypeStr == 'yearly-encounter') {
        try {
          final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
          Logger.info(
              '[ChatHome] YearlyEncounterResult 구성 시작: metadata keys=${metadata.keys.toList()}');

          yearlyEncounterResult = YearlyEncounterResult.fromJson({
            ...metadata,
            'isBlurred': fortune.isBlurred,
            'blurredSections': fortune.blurredSections,
          });

          Logger.info(
              '[ChatHome] YearlyEncounterResult 구성 성공: score=${yearlyEncounterResult.compatibilityScore}');
        } catch (e, st) {
          Logger.error('[ChatHome] YearlyEncounterResult 구성 실패', e, st);
        }
      }

      // 스크롤은 FortuneResultScrollWrapper의 onRendered 콜백으로 자동 처리됨
      chatNotifier.addFortuneResultMessage(
        text: typeName,
        fortuneType: fortuneTypeStr,
        fortune: fortune,
        matchInsight: matchInsight,
        pastLifeResult: pastLifeResult,
        yearlyEncounterResult: yearlyEncounterResult,
        isBlurred: fortune.isBlurred,
        blurredSections: fortune.blurredSections,
        selectedDate: selectedDate,
      );
      surveyNotifier.clearCompleted();
      // 운세 결과 후 추천 칩 표시 (스크롤 없이 - 결과 카드가 보이게 유지)
      Future.delayed(const Duration(milliseconds: 500), () {
        chatNotifier.addSystemMessage();
      });
    }).catchError((error) {
      Logger.error('Fortune API 호출 실패', error);
      chatNotifier.hideTypingIndicator();
      chatNotifier.addAiMessage(
        '죄송해요, 분석 중 문제가 발생했어요. 😢\n'
        '잠시 후 다시 시도해주세요.\n\n'
        '다른 인사이트를 확인해볼까요?',
      );
      surveyNotifier.clearCompleted();
      _scrollToBottom();
    });
  }

  /// 감사일기 완료 처리 (API 호출 없이 로컬 표시 - 일기장 스타일 카드)
  void _handleGratitudeComplete(Map<String, dynamic> data) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);

    final gratitude1 = data['gratitude1'] as String? ?? '';
    final gratitude2 = data['gratitude2'] as String? ?? '';
    final gratitude3 = data['gratitude3'] as String? ?? '';

    // 마지막 답변에 대한 리액션 표시
    chatNotifier.addAiMessage('그런 순간이 있었군요, 정말 소중하네요 ✨');
    _scrollToBottom();

    chatNotifier.showTypingIndicator();

    Future.delayed(const Duration(milliseconds: 500), () {
      // 일기장 스타일 결과 카드 표시
      chatNotifier.addGratitudeResultMessage(
        gratitude1: gratitude1,
        gratitude2: gratitude2,
        gratitude3: gratitude3,
      );
      _scrollToBottom();

      // 완료 후 추천 칩 표시 (스크롤 없이 - 결과가 보이게 유지)
      Future.delayed(const Duration(milliseconds: 500), () {
        chatNotifier.addSystemMessage();
      });
    });
  }

  /// 성격 DNA 완료 처리
  void _handlePersonalityDnaComplete(Map<String, dynamic> data) async {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final userProfileAsync = ref.read(userProfileNotifierProvider);
    final userProfile = userProfileAsync.valueOrNull;
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        await StorageService().getOrCreateGuestId();
    final userName = userProfile?.name ?? '사용자';

    // 설문 답변 또는 프로필 기본값 사용
    final mbti = data['mbti'] as String? ?? userProfile?.mbtiType ?? 'INFP';
    final bloodType =
        data['bloodType'] as String? ?? userProfile?.bloodType ?? 'O';
    final zodiac =
        data['zodiac'] as String? ?? userProfile?.zodiacSign ?? '물병자리';
    final zodiacAnimal =
        data['zodiacAnimal'] as String? ?? userProfile?.chineseZodiac ?? '용';

    chatNotifier.showTypingIndicator();
    _scrollToBottom();

    try {
      final dna = await PersonalityDNAService.generateDNA(
        userId: userId,
        name: userName,
        mbti: mbti,
        bloodType: bloodType,
        zodiac: zodiac,
        zodiacAnimal: zodiacAnimal,
      );

      // 프리미엄 상태 확인
      final isPremium = ref.read(isPremiumProvider);

      // 결과 메시지 추가
      chatNotifier.addPersonalityDnaResult(
        dna: dna,
        isBlurred: !isPremium,
      );
      _scrollToBottom();

      // 완료 후 추천 칩 표시
      Future.delayed(const Duration(milliseconds: 500), () {
        chatNotifier.addSystemMessage();
      });
    } catch (e) {
      Logger.error(
          '[ChatHomePage] PersonalityDNA generation failed', {'error': e});
      chatNotifier.addAiMessage(
        '😢 성격 DNA 분석 중 문제가 발생했어요.\n잠시 후 다시 시도해주세요.',
      );
      _scrollToBottom();
    }
  }

  /// 부적 생성 완료 처리 (TalismanGenerationService 사용)
  void _handleTalismanComplete(Map<String, dynamic> data) async {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);

    // 설문 답변에서 카테고리 추출 (survey option id가 TalismanCategory.id와 일치)
    final purposeId = data['purpose'] as String? ?? 'wealth_career';
    final category =
        TalismanCategory.fromId(purposeId) ?? TalismanCategory.wealthCareer;

    chatNotifier.showTypingIndicator();
    _scrollToBottom();

    try {
      final service = TalismanGenerationService();
      final result = await service.generateTalisman(
        category: category,
      );

      // 프리미엄 상태 확인
      final isPremium = ref.read(isPremiumProvider);

      // 결과 메시지 추가 (이미지 URL + 짧은 설명)
      chatNotifier.addTalismanResult(
        imageUrl: result.imageUrl,
        categoryName: result.categoryName,
        shortDescription: result.shortDescription,
        isBlurred: !isPremium,
      );
      _scrollToBottom();

      // 완료 후 추천 칩 표시
      Future.delayed(const Duration(milliseconds: 500), () {
        chatNotifier.addSystemMessage();
      });
    } catch (e) {
      Logger.error('[ChatHomePage] Talisman generation failed', {'error': e});
      chatNotifier.addAiMessage(
        '😢 부적 생성 중 문제가 발생했어요.\n잠시 후 다시 시도해주세요.',
      );
      _scrollToBottom();
    }
  }

  /// 프로필 생성 완료 처리
  void _handleProfileCreationComplete(Map<String, dynamic> data) async {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);
    final profilesNotifier = ref.read(secondaryProfilesProvider.notifier);

    chatNotifier.showTypingIndicator();
    _scrollToBottom();

    try {
      // 프로필 DB 저장
      final name = data['name'] as String? ?? '';
      final relationship = data['relationship'] as String? ?? 'other';
      final gender = data['gender'] as String? ?? 'male';

      // birthDateTime에서 날짜/시간 추출
      final birthDateTimeData = data['birthDateTime'] as Map<String, dynamic>?;
      String birthDate = '';
      String? birthTime;

      if (birthDateTimeData != null) {
        final isUnknown = birthDateTimeData['isUnknown'] as bool? ?? false;
        if (!isUnknown) {
          birthDate = birthDateTimeData['dateString'] as String? ?? '';
          // 12시진 형식으로 저장 (사주용)
          birthTime = birthDateTimeData['birthTimeSlot'] as String?;
          if (birthTime == 'unknown') birthTime = null;
        }
      }

      final newProfile = await profilesNotifier.addProfile(
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        gender: gender,
        relationship: relationship,
      );

      surveyNotifier.clearCompleted();

      if (newProfile != null) {
        chatNotifier.addAiMessage(
          '$name님 정보를 저장했어요! 💕\n이제 궁합을 봐드릴게요.',
        );
        _scrollToBottom();

        // 궁합 진행 대기 중이었다면 자동으로 궁합 시작
        if (_pendingCompatibilityAfterProfileCreation) {
          setState(() {
            _pendingCompatibilityAfterProfileCreation = false;
          });

          // 잠시 후 궁합 설문 재시작 (프로필 자동 선택)
          Future.delayed(const Duration(milliseconds: 500), () {
            surveyNotifier.startSurvey(FortuneSurveyType.compatibility);

            // 바로 프로필 선택 처리
            Future.delayed(const Duration(milliseconds: 300), () {
              _handleProfileSelect(newProfile);
            });
          });
        }
      } else {
        chatNotifier.addAiMessage(
          '프로필 저장 중 문제가 발생했어요. 😢\n다시 시도해주세요.',
        );
        _scrollToBottom();
      }
    } catch (e) {
      Logger.error('프로필 저장 실패', e);
      surveyNotifier.clearCompleted();
      chatNotifier.addAiMessage(
        '프로필 저장 중 문제가 발생했어요. 😢\n다시 시도해주세요.',
      );
      _scrollToBottom();
    }
  }

  /// 궁합 설문 시작 시 inputMethod 단계 자동 건너뛰기
  Future<void> _handleCompatibilityAutoSkip(
      ChatSurveyNotifier surveyNotifier) async {
    // 프로필 로드 확인 및 새로고침
    final notifier = ref.read(secondaryProfilesProvider.notifier);
    await notifier.refresh();

    final profilesAsync = ref.read(secondaryProfilesProvider);
    profilesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) {
          // 프로필 없음 → 바로 '새로 입력' 모드로 진행
          surveyNotifier.answerCurrentStep('new');
        } else {
          // 프로필 있음 → 바로 프로필 목록 표시 (inputMethod 단계 건너뛰기)
          surveyNotifier.answerCurrentStep('profile');
        }
      },
      loading: () {
        // 아직 로딩 중이면 기본으로 'new' 선택 (안전한 기본값)
        surveyNotifier.answerCurrentStep('new');
      },
      error: (_, __) {
        // 에러 시 'new' 선택
        surveyNotifier.answerCurrentStep('new');
      },
    );
  }

  /// 프로필 선택 처리 (궁합용)
  void _handleProfileSelect(SecondaryProfile? profile) async {
    if (profile == null) {
      // 새로 입력하기 선택 → AddProfileSheet 바텀시트 표시
      final chatNotifier = ref.read(chatMessagesProvider.notifier);

      // 궁합 완료 후 재개 플래그 설정
      setState(() {
        _pendingCompatibilityAfterProfileCreation = true;
      });

      chatNotifier.addUserMessage('새로 입력할게요');

      // AddProfileSheet 바텀시트 표시
      final result = await showModalBottomSheet<SecondaryProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddProfileSheet(),
      );

      // 프로필 생성 완료 시 자동으로 궁합 진행
      if (result != null && mounted) {
        chatNotifier
            .addAiMessage('${result.name}님 정보를 저장했어요! 💕\n이제 궁합을 봐드릴게요.');
        _scrollToBottom();

        // 생성된 프로필로 궁합 진행
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            final displayText = '${result.name} (${result.relationshipText})';
            _handleSurveyAnswerValue({
              'id': result.id,
              'name': result.name,
              'birthDate': result.birthDate,
              'birthTime': result.birthTime,
              'gender': result.gender,
              'isLunar': result.isLunar,
            }, displayText);
          }
        });
      } else if (mounted) {
        // 취소 시 플래그 초기화
        setState(() {
          _pendingCompatibilityAfterProfileCreation = false;
        });
        chatNotifier.addAiMessage('프로필 등록을 취소했어요. 다시 시도하시려면 말씀해주세요!');
        _scrollToBottom();
      }
      return;
    }

    final displayText = '${profile.name} (${profile.relationshipText})';
    _handleSurveyAnswerValue({
      'id': profile.id,
      'name': profile.name,
      'birthDate': profile.birthDate,
      'birthTime': profile.birthTime,
      'gender': profile.gender,
      'isLunar': profile.isLunar,
    }, displayText);
  }

  /// 가족 프로필 선택 처리 (가족운용)
  void _handleFamilyProfileSelect(
      SecondaryProfile? profile, String familyRelation) async {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);

    // 가족 관계 한글 이름
    String familyRelationText;
    switch (familyRelation) {
      case 'parents':
        familyRelationText = '부모님';
        break;
      case 'spouse':
        familyRelationText = '배우자';
        break;
      case 'children':
        familyRelationText = '자녀';
        break;
      case 'siblings':
        familyRelationText = '형제자매';
        break;
      default:
        familyRelationText = '가족';
    }

    if (profile == null) {
      // 새로 등록하기 선택 → AddProfileSheet 바텀시트 표시
      chatNotifier.addUserMessage('$familyRelationText 정보를 새로 등록할게요');
      _scrollToBottom();

      // AddProfileSheet 바텀시트 표시
      final result = await showModalBottomSheet<SecondaryProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddProfileSheet(
          defaultRelationship: 'family',
          defaultFamilyRelation: familyRelation,
        ),
      );

      // 프로필 생성 완료 시 자동으로 진행
      if (result != null && mounted) {
        chatNotifier.addAiMessage('${result.name}님 정보를 저장했어요! 👨‍👩‍👧‍👦');
        _scrollToBottom();

        // 생성된 프로필로 진행
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _handleSurveyAnswerValue({
              'id': result.id,
              'name': result.name,
              'birthDate': result.birthDate,
              'birthTime': result.birthTime,
              'gender': result.gender,
              'isLunar': result.isLunar,
              'familyRelation': familyRelation,
            }, '${result.name} ($familyRelationText)');
          }
        });
      } else if (mounted) {
        chatNotifier.addAiMessage('등록을 취소했어요. 다시 시도하시려면 말씀해주세요!');
        _scrollToBottom();
      }
      return;
    }

    // 기존 프로필 선택
    final displayText = '${profile.name} ($familyRelationText)';
    _handleSurveyAnswerValue({
      'id': profile.id,
      'name': profile.name,
      'birthDate': profile.birthDate,
      'birthTime': profile.birthTime,
      'gender': profile.gender,
      'isLunar': profile.isLunar,
      'familyRelation': familyRelation,
    }, displayText);
  }

  /// 펫 프로필 선택 처리 (반려동물용)
  void _handlePetSelect(PetProfile? pet) {
    if (pet == null) {
      // 새로 입력하기 선택 → 펫 등록 폼 표시
      setState(() {
        _showPetRegistrationForm = true;
      });
      return;
    }

    final displayText = '🐾 ${pet.name} (${pet.species})';
    _handleSurveyAnswerValue({
      'id': pet.id,
      'name': pet.name,
      'species': pet.species,
      'age': pet.age,
      'gender': pet.gender,
      'breed': pet.breed,
    }, displayText);
  }

  /// 펫 등록 완료 처리
  void _handlePetRegistrationComplete(PetProfile newPet) {
    // 폼 숨기기
    setState(() {
      _showPetRegistrationForm = false;
    });

    // Survey 답변에 펫 정보 저장 및 다음 단계로 진행
    // (addUserMessage는 _handleSurveyAnswerValue 내부에서 자동 호출됨)
    _handleSurveyAnswerValue({
      'id': newPet.id,
      'name': newPet.name,
      'species': newPet.species,
      'age': newPet.age,
      'gender': newPet.gender,
      'breed': newPet.breed,
    }, '🐾 ${newPet.name} (${newPet.species})');
  }

  /// 이미지 선택 처리 (관상용)
  void _handleImageSelect(File? file) {
    if (file == null) return;

    final displayText = '📷 사진이 선택되었어요';
    _handleSurveyAnswerValue({
      'imagePath': file.path,
    }, displayText);
  }

  /// 타로 선택 완료 처리
  void _handleTarotComplete(Map<String, dynamic> tarotData) {
    final spreadName = tarotData['spreadDisplayName'] as String? ?? '타로';
    final cardCount = tarotData['cardCount'] as int? ?? 1;
    // BUG FIX: List<dynamic>을 List<int>로 직접 캐스팅하면 null 반환됨
    // map().toList()는 List<dynamic>을 반환하므로 .cast<int>() 사용
    final rawIndices = tarotData['selectedCardIndices'] as List? ?? [];
    final selectedCardIndices = rawIndices.cast<int>();

    final displayText = '🃏 $spreadName (${selectedCardIndices.length}장 선택)';
    _handleSurveyAnswerValue({
      ...tarotData,
      'spreadType': tarotData['spreadType'],
      'cardCount': cardCount,
      'selectedCards': selectedCardIndices,
    }, displayText);
  }

  /// 관상 분석 플로우 완료 핸들러
  void _handleFaceReadingComplete(String imagePath) {
    final displayText = '📷 사진 선택 완료';
    _handleSurveyAnswerValue({
      'imagePath': imagePath,
    }, displayText);
  }

  /// 타로 덱 준비 후 설문 시작
  Future<void> _prepareTarotDeckAndStart(
    ChatSurveyNotifier surveyNotifier,
    ChatMessagesNotifier chatNotifier,
  ) async {
    // 이미 덱이 준비되어 있으면 바로 시작
    if (_todaysTarotDeck != null) {
      _startTarotSurvey(surveyNotifier, chatNotifier);
      return;
    }

    setState(() {
      _isDownloadingTarotDeck = true;
    });

    // 오늘의 덱 이름 가져오기
    final deckName = AssetPackConfig.getTodaysDeck();
    final deckDisplayName = AssetPackConfig.getTarotDeckDisplayName(deckName);

    chatNotifier.addAiMessage(
      '오늘의 타로 덱을 준비하고 있어요... 🎴\n'
      '덱: $deckDisplayName',
    );
    _scrollToBottom();

    try {
      final assetService = AssetDeliveryService();
      await assetService.initialize();

      // 덱 다운로드 (이미 설치되어 있으면 바로 반환)
      final preparedDeck = await assetService.prepareTodaysTarotDeck();

      if (!mounted) return;

      if (preparedDeck != null) {
        setState(() {
          _todaysTarotDeck = preparedDeck;
          _isDownloadingTarotDeck = false;
        });

        chatNotifier.addAiMessage(
          '$deckDisplayName 덱이 준비되었어요! ✨\n'
          '이제 카드를 선택해주세요.',
        );
        _scrollToBottom();

        // 설문 시작
        _startTarotSurvey(surveyNotifier, chatNotifier);
      } else {
        setState(() {
          _isDownloadingTarotDeck = false;
        });

        chatNotifier.addAiMessage(
          '덱 준비 중 문제가 발생했어요. 😢\n'
          '기본 덱으로 진행할게요.',
        );
        _scrollToBottom();

        // 기본 덱으로 진행
        setState(() {
          _todaysTarotDeck = 'rider_waite';
        });
        _startTarotSurvey(surveyNotifier, chatNotifier);
      }
    } catch (e) {
      Logger.error('타로 덱 준비 실패', e);

      if (!mounted) return;

      setState(() {
        _isDownloadingTarotDeck = false;
        _todaysTarotDeck = 'rider_waite'; // 기본 덱으로 폴백
      });

      chatNotifier.addAiMessage(
        '덱 준비 중 문제가 발생했어요. 😢\n'
        '기본 덱으로 진행할게요.',
      );
      _scrollToBottom();

      _startTarotSurvey(surveyNotifier, chatNotifier);
    }
  }

  /// 타로 설문 시작
  void _startTarotSurvey(
    ChatSurveyNotifier surveyNotifier,
    ChatMessagesNotifier chatNotifier,
  ) {
    surveyNotifier.startSurvey(FortuneSurveyType.tarot);

    // AI 첫 질문 메시지
    Future.delayed(const Duration(milliseconds: 500), () {
      final surveyState = ref.read(chatSurveyProvider);
      if (surveyState.activeProgress != null &&
          surveyState.activeProgress!.config.steps.isNotEmpty) {
        final question = _buildDynamicQuestion(surveyState.activeProgress!);
        chatNotifier.addAiMessage(question);
        _scrollToBottom();
      }
    });
  }

  /// 사주 분석 요청 처리 (ChatSajuResultCard 사용)
  Future<void> _handleSajuRequest() async {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final sajuNotifier = ref.read(sajuProvider.notifier);

    chatNotifier.showTypingIndicator();
    _scrollToBottom();

    chatNotifier.addAiMessage(
      '사주팔자를 분석하고 있어요... ✨\n'
      '명식, 오행, 지장간, 12운성, 신살, 합충을 살펴볼게요.',
    );
    _scrollToBottom();

    try {
      // 사주 데이터 가져오기
      await sajuNotifier.fetchUserSaju();
      final sajuState = ref.read(sajuProvider);

      if (sajuState.error != null) {
        chatNotifier.addAiMessage(
          '죄송해요, 사주 분석 중 문제가 발생했어요. 😢\n'
          '${sajuState.error}\n\n'
          '다른 인사이트를 확인해볼까요?',
        );
        _scrollToBottom();
        return;
      }

      if (sajuState.sajuData == null) {
        chatNotifier.addAiMessage(
          '사주 데이터가 없어요.\n'
          '생년월일시를 먼저 등록해주세요.',
        );
        _scrollToBottom();
        return;
      }

      // ChatSajuResultCard로 결과 표시
      // 스크롤은 FortuneResultScrollWrapper의 onRendered 콜백으로 자동 처리됨
      chatNotifier.addSajuResultMessage(
        text: '사주 분석',
        sajuData: sajuState.sajuData!,
        isBlurred: false, // TODO: 프리미엄 상태에 따라 결정
      );

      // 오늘의 운세 자동 호출 (사주 분석 후 무료 제공)
      Future.delayed(const Duration(milliseconds: 500), () async {
        chatNotifier.addAiMessage('이제 오늘의 인사이트를 보여드릴게요... ✨');
        _scrollToBottom(); // AI 메시지는 하단으로 스크롤

        try {
          // 캐시 우선 확인 후 API 호출
          final fortune = await _callFortuneApiWithCache(
            type: FortuneSurveyType.daily,
            answers: {}, // 기본 파라미터로 호출 (mood, schedule, category 없이)
          );

          // 사주 분석 후 무료 제공이므로 isBlurred=false 강제
          // 스크롤은 FortuneResultScrollWrapper의 onRendered 콜백으로 자동 처리됨
          chatNotifier.addFortuneResultMessage(
            text: '오늘의 인사이트',
            fortuneType: 'daily',
            fortune: fortune.copyWith(isBlurred: false),
            isBlurred: false,
            blurredSections: const [],
          );
        } catch (e) {
          Logger.error('오늘의 운세 호출 실패', e);
          chatNotifier.addAiMessage(
            '오늘의 인사이트를 불러오지 못했어요. 😢\n'
            '아래 칩을 눌러 다시 시도해보세요.',
          );
          _scrollToBottom();
        }

        // 추천 칩 표시 (스크롤 없이 - 결과 카드가 보이게 유지)
        Future.delayed(const Duration(milliseconds: 500), () {
          chatNotifier.addSystemMessage();
        });
      });
    } catch (e) {
      Logger.error('사주 분석 실패', e);
      chatNotifier.addAiMessage(
        '죄송해요, 사주 분석 중 문제가 발생했어요. 😢\n'
        '잠시 후 다시 시도해주세요.\n\n'
        '다른 인사이트를 확인해볼까요?',
      );
      _scrollToBottom();
    }
  }

  /// 가족 관심사에 따른 Edge Function 엔드포인트 반환
  /// 가족 관심사를 Edge Function 파라미터로 변환
  String _getFamilyType(String concern) {
    return switch (concern.toLowerCase()) {
      '재물' || 'wealth' || '돈' || '재정' => 'wealth',
      '건강' || 'health' => 'health',
      '자녀' || 'children' || '아이' || '육아' => 'children',
      '관계' || 'relationship' || '소통' => 'relationship',
      '변화' || 'change' || '이사' || '전환' => 'change',
      _ => 'health', // default - 건강운 (fortune-family-all 없음)
    };
  }

  /// 캐시/DB 확인 후 필요시 API 호출 (래퍼 메서드)
  Future<Fortune> _callFortuneApiWithCache({
    required FortuneSurveyType type,
    required Map<String, dynamic> answers,
  }) async {
    final fortuneType = type.name;
    final historyService = FortuneHistoryService();

    // 1. DB에서 오늘 결과 확인
    try {
      final cachedHistory = await historyService.getTodayFortuneByConditions(
        fortuneType: fortuneType,
        inputConditions: answers,
      );

      if (cachedHistory != null && cachedHistory.detailedResult != null) {
        Logger.info(
            '🎯 [ChatHomePage] Cache HIT - returning cached fortune for $fortuneType');
        return await _convertHistoryToFortune(cachedHistory);
      }
    } catch (e) {
      Logger.warning(
          '[ChatHomePage] Cache lookup failed, proceeding to API: $e');
    }

    // 2. 꿈 해몽의 경우 하드코딩된 결과 확인 (롤링 칩 선택 시)
    if (type == FortuneSurveyType.dream) {
      final dreamContent = answers['dreamContent'] as String?;
      if (dreamContent != null) {
        final hardcodedData =
            DreamInterpretations.getInterpretation(dreamContent);
        if (hardcodedData != null) {
          Logger.info(
              '🎯 [ChatHomePage] Using hardcoded dream interpretation: $dreamContent');
          final userId = Supabase.instance.client.auth.currentUser?.id ??
              await StorageService().getOrCreateGuestId();

          // 짧은 딜레이로 자연스러운 로딩 효과
          await Future.delayed(const Duration(milliseconds: 800));

          final fortune = Fortune(
            id: 'hardcoded_dream_${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            type: 'dream',
            content: hardcodedData['interpretation'] as String? ?? '',
            createdAt: DateTime.now(),
            overallScore: hardcodedData['overallScore'] as int?,
            description: hardcodedData['symbolMeaning'] as String?,
            summary: hardcodedData['fortuneMessage'] as String?,
            luckyItems: {
              'color': hardcodedData['luckyColor'],
              'number': hardcodedData['luckyNumber'],
            },
            recommendations: [hardcodedData['advice'] as String? ?? ''],
            additionalInfo: {
              'emoji': hardcodedData['emoji'],
              'title': hardcodedData['title'],
              'psychologicalAnalysis': hardcodedData['psychologicalAnalysis'],
              'categories': hardcodedData['categories'],
            },
            isBlurred: false, // 하드코딩 결과는 블러 없음
            blurredSections: const [],
          );

          // DB 저장
          _saveFortuneToHistory(
            fortune: fortune,
            fortuneType: fortuneType,
            inputConditions: answers,
          );

          return fortune;
        }
      }
    }

    // 3. 캐시 미스 → API 호출
    Logger.info('🔄 [ChatHomePage] Cache MISS - calling API for $fortuneType');
    final fortune = await _callFortuneApi(type: type, answers: answers);

    // 3. DB 저장 (비동기, 실패 무시)
    _saveFortuneToHistory(
      fortune: fortune,
      fortuneType: fortuneType,
      inputConditions: answers,
    );

    return fortune;
  }

  /// FortuneHistory → Fortune 변환 헬퍼
  Future<Fortune> _convertHistoryToFortune(FortuneHistory history) async {
    final data = history.detailedResult ?? {};
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        await StorageService().getOrCreateGuestId();

    return Fortune(
      id: data['id'] as String? ?? history.id,
      userId: data['userId'] as String? ?? userId,
      type: data['type'] as String? ?? history.fortuneType,
      content: data['content'] as String? ?? history.title,
      createdAt: history.createdAt,
      metadata: data['metadata'] as Map<String, dynamic>?,
      tokenCost: data['tokenCost'] as int? ?? 0, // 캐시된 결과는 토큰 소비 없음
      category: data['category'] as String?,
      overallScore:
          data['overallScore'] as int? ?? history.summary['score'] as int?,
      description: data['description'] as String?,
      scoreBreakdown: data['scoreBreakdown'] as Map<String, dynamic>?,
      luckyItems: data['luckyItems'] as Map<String, dynamic>?,
      recommendations: (data['recommendations'] as List?)?.cast<String>(),
      warnings: (data['warnings'] as List?)?.cast<String>(),
      summary: data['summary'] as String?,
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
      greeting: data['greeting'] as String?,
      hexagonScores: (data['hexagonScores'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as int),
      ),
      fiveElements: data['fiveElements'] as Map<String, dynamic>?,
      specialTip: data['specialTip'] as String?,
      period: data['period'] as String?,
      meta: data['meta'] as Map<String, dynamic>?,
      weatherSummary: data['weatherSummary'] as Map<String, dynamic>?,
      overall: data['overall'] as Map<String, dynamic>?,
      categories: data['categories'] as Map<String, dynamic>?,
      sajuInsight: data['sajuInsight'] as Map<String, dynamic>?,
      personalActions:
          (data['personalActions'] as List?)?.cast<Map<String, dynamic>>(),
      notification: data['notification'] as Map<String, dynamic>?,
      shareCard: data['shareCard'] as Map<String, dynamic>?,
      uiBlocks: (data['uiBlocks'] as List?)?.cast<String>(),
      explain: data['explain'] as Map<String, dynamic>?,
      isBlurred: data['isBlurred'] as bool? ?? false,
      blurredSections:
          (data['blurredSections'] as List?)?.cast<String>() ?? const [],
      percentile: data['percentile'] as int?,
      totalTodayViewers: data['totalTodayViewers'] as int?,
      isPercentileValid: data['isPercentileValid'] as bool? ?? false,
    );
  }

  /// DB에 운세 결과 저장 (비동기, 실패 무시)
  void _saveFortuneToHistory({
    required Fortune fortune,
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) {
    // Fire and forget - 저장 실패해도 사용자 경험에 영향 없음
    Future(() async {
      try {
        final historyService = FortuneHistoryService();
        await historyService.saveFortuneResultWithConditions(
          fortuneType: fortuneType,
          title: fortune.content.length > 50
              ? '${fortune.content.substring(0, 50)}...'
              : fortune.content,
          summary: {
            'score': fortune.overallScore,
            'greeting': fortune.greeting,
            'description': fortune.description,
          },
          fortuneData: fortune.toJson(),
          inputConditions: inputConditions,
          score: fortune.overallScore,
        );
        Logger.info('💾 [ChatHomePage] Fortune saved to history: $fortuneType');
      } catch (e) {
        Logger.warning(
            '[ChatHomePage] Failed to save fortune to history (ignored): $e');
      }
    });
  }

  /// 운세 API 호출 - Edge Function 요구사항에 맞게 파라미터 매핑
  Future<Fortune> _callFortuneApi({
    required FortuneSurveyType type,
    required Map<String, dynamic> answers,
  }) async {
    final apiService = ref.read(fortuneApiServiceProvider);
    final userProfileAsync = ref.read(userProfileNotifierProvider);
    final userProfile = userProfileAsync.valueOrNull;
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        await StorageService().getOrCreateGuestId();

    // 공통 유저 정보
    final userName = userProfile?.name ?? '사용자';
    final birthDate = userProfile?.birthDate ?? DateTime(1990, 1, 1);
    final birthDateStr = birthDate.toIso8601String().split('T')[0];
    final age = _calculateAge(userProfile?.birthDate);
    final gender = userProfile?.gender ?? 'unknown';

    Logger.info('🔮 [ChatHomePage] Calling fortune API', {
      'type': type.name,
      'userId': userId,
      'answers': answers,
    });

    switch (type) {
      // ============================================================
      // Daily / Time-based
      // ============================================================
      case FortuneSurveyType.daily:
        // Edge Function 요구: userId, birthDate, birthTime, gender, zodiacSign, zodiacAnimal
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'daily',
          params: {
            'birthDate': birthDateStr,
            'birthTime': userProfile?.birthTime ?? '자시 (23:00 - 01:00)',
            'gender': gender,
            'zodiacSign': userProfile?.zodiacSign ?? '양자리',
            'zodiacAnimal': userProfile?.chineseZodiac ?? '용',
            'mood': answers['mood'],
            'schedule': answers['schedule'],
            'category': answers['category'],
          },
        );

      case FortuneSurveyType.newYear:
        // 새해 운세: goal(희망사항)을 Edge Function에 전달
        final goalId = answers['goal'] as String?;
        final goalLabels = {
          'success': '성공/성취',
          'love': '사랑/만남',
          'wealth': '부자되기',
          'health': '건강/운동',
          'growth': '자기계발',
          'travel': '여행/경험',
          'peace': '마음의 평화',
        };
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'new_year',
          params: {
            'birthDate': birthDateStr,
            'birthTime': userProfile?.birthTime ?? '자시 (23:00 - 01:00)',
            'gender': gender,
            'zodiacSign': userProfile?.zodiacSign,
            'zodiacAnimal': userProfile?.chineseZodiac,
            'goal': goalId,
            'goalLabel': goalLabels[goalId] ?? '새해 목표',
          },
        );

      case FortuneSurveyType.dailyCalendar:
        // 기간별 운세: 선택한 날짜의 운세 조회
        final calendarSync = answers['calendarSync'] as String?;

        final targetDateAnswer = answers['targetDate'];

        // 다중 날짜 형식 체크: {dates: [...], eventsPerDate: {...}, isMultipleDates: true}
        if (targetDateAnswer is Map<String, dynamic> &&
            targetDateAnswer['isMultipleDates'] == true) {
          // 다중 날짜 요청
          final dates = (targetDateAnswer['dates'] as List?)
                  ?.map((d) => d.toString())
                  .toList() ??
              [];
          final eventsPerDate =
              (targetDateAnswer['eventsPerDate'] as Map<String, dynamic>?) ??
                  {};

          // 모든 이벤트를 병합하여 전달
          final allEvents = <Map<String, dynamic>>[];
          for (final events in eventsPerDate.values) {
            if (events is List) {
              allEvents.addAll(events.cast<Map<String, dynamic>>());
            }
          }

          return apiService.getFortune(
            userId: userId,
            fortuneType: 'daily_calendar',
            params: {
              'birthDate': birthDateStr,
              'birthTime': userProfile?.birthTime ?? '자시 (23:00 - 01:00)',
              'gender': gender,
              'zodiacSign': userProfile?.zodiacSign ?? '양자리',
              'zodiacAnimal': userProfile?.chineseZodiac ?? '용',
              'targetDates': dates, // 다중 날짜 배열
              'eventsPerDate': eventsPerDate, // 날짜별 이벤트 맵
              'calendarSynced': calendarSync == 'sync',
              'calendarEvents': allEvents, // 전체 이벤트 (호환성)
              'hasCalendarEvents': allEvents.isNotEmpty,
              'isMultipleDates': true,
            },
          );
        }

        // 단일 날짜 형식 (기존 호환성)
        String? targetDateStr;
        List<Map<String, dynamic>> calendarEvents = [];

        if (targetDateAnswer is Map<String, dynamic>) {
          // 새 형식: {date: '...', events: [...]}
          targetDateStr = targetDateAnswer['date'] as String?;
          final events = targetDateAnswer['events'];
          if (events is List) {
            calendarEvents = events.cast<Map<String, dynamic>>();
          }
        } else if (targetDateAnswer is String) {
          // 기존 형식: ISO8601 문자열
          targetDateStr = targetDateAnswer;
        }

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'daily_calendar',
          params: {
            'birthDate': birthDateStr,
            'birthTime': userProfile?.birthTime ?? '자시 (23:00 - 01:00)',
            'gender': gender,
            'zodiacSign': userProfile?.zodiacSign ?? '양자리',
            'zodiacAnimal': userProfile?.chineseZodiac ?? '용',
            'targetDate': targetDateStr,
            'calendarSynced': calendarSync == 'sync',
            'calendarEvents': calendarEvents,
            'hasCalendarEvents': calendarEvents.isNotEmpty,
          },
        );

      // ============================================================
      // Career
      // ============================================================
      case FortuneSurveyType.career:
        // Edge Function 요구: fortuneType, currentRole OR careerGoal
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'career',
          params: {
            'fortuneType': 'career',
            'currentRole': answers['position'] ?? answers['field'] ?? '일반 직장인',
            'careerGoal': answers['goal'] ?? '성장',
            'experience': answers['experience'] ?? 'mid',
            'field': answers['field'] ?? 'other',
          },
        );

      // ============================================================
      // Love & Relationship
      // ============================================================
      case FortuneSurveyType.love:
        // Edge Function 요구: userName, age, gender, relationshipStatus, datingStyles, valueImportance
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'love',
          params: {
            'userName': userName, // ✅ 유저 이름 (철수님 대신 실제 이름 사용)
            'age': age,
            'gender': gender,
            'relationshipStatus': answers['status'] ?? 'single',
            'datingStyles': ['casual', 'serious'],
            'valueImportance': {
              '외모': 3,
              '성격': 5,
              '경제력': 3,
              '가치관': 5,
              '유머감각': 4,
            },
            'concern': answers['concern'],
            'preferredAgeRange': {'min': age - 5, 'max': age + 5},
            'preferredPersonality': ['따뜻한', '유머있는', '성실한'],
            'preferredMeetingPlaces': ['카페', '레스토랑'],
            'relationshipGoal': '진지한 연애',
            'appearanceConfidence': 5,
            'charmPoints': ['성격', '유머'],
            'lifestyle': '일상적',
            'hobbies': ['영화', '음악'],
          },
        );

      case FortuneSurveyType.compatibility:
        // Edge Function 요구: person1_name, person1_birth_date, person2_name, person2_birth_date
        // Survey step id: 'partner' (SecondaryProfile 객체)
        final partnerProfile = answers['partner'];
        return apiService.getCompatibilityFortune(
          person1: {
            'userId': userId,
            'name': userName,
            'birth_date': birthDateStr,
          },
          person2: {
            'name': partnerProfile?['name'] ?? partnerProfile?.name ?? '상대방',
            'birth_date': partnerProfile?['birthDate'] ??
                partnerProfile?.birthDate?.toIso8601String()?.split('T')[0] ??
                birthDateStr,
          },
        );

      case FortuneSurveyType.blindDate:
        // Edge Function 요구: name, birthDate, gender, meetingDate, meetingTime, meetingType, etc.
        // Survey step ids: 'dateType', 'expectation', 'meetingTime', 'isFirstBlindDate', 'hasPartnerInfo', 'partnerPhoto', 'partnerInstagram'
        final meetingTimeMap = {
          'lunch': '12:00',
          'afternoon': '15:00',
          'dinner': '19:00',
          'night': '21:00',
        };
        final selectedTime = answers['meetingTime'] ?? 'dinner';
        final hasPartnerInfo = answers['hasPartnerInfo'];
        // 이미지는 {'imagePath': '...'} 형태로 저장됨
        final partnerPhotoData = answers['partnerPhoto'];
        final partnerPhotoPath =
            partnerPhotoData is Map ? partnerPhotoData['imagePath'] : null;

        // 사진이 있으면 base64로 변환
        String? partnerPhotoBase64;
        if (hasPartnerInfo == 'photo' && partnerPhotoPath != null) {
          try {
            final file = File(partnerPhotoPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              partnerPhotoBase64 = base64Encode(bytes);
              Logger.info(
                  'Partner photo converted to base64: ${bytes.length} bytes');
            }
          } catch (e) {
            Logger.error('Failed to convert photo to base64', e);
          }
        }

        // analysisType 결정: 사진이 있으면 'photos', 없으면 'basic'
        final analysisType = partnerPhotoBase64 != null ? 'photos' : 'basic';

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'blind-date',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender,
            'meetingDate': DateTime.now().toIso8601String().split('T')[0],
            'meetingTime': meetingTimeMap[selectedTime] ?? '19:00',
            'meetingType': answers['dateType'] ?? 'first',
            'introducer': answers['dateType'] ?? 'friend',
            'expectation': answers['expectation'] ?? 'serious',
            'isFirstBlindDate': answers['isFirstBlindDate'] == 'yes',
            // 상대방 정보 (조건부 수집)
            if (partnerPhotoBase64 != null)
              'partnerPhotos': [partnerPhotoBase64],
            if (hasPartnerInfo == 'instagram' &&
                answers['partnerInstagram'] != null)
              'partnerInstagram': answers['partnerInstagram'],
            'hasPartnerInfo': hasPartnerInfo ?? 'none',
            'analysisType': analysisType,
          },
        );

      case FortuneSurveyType.exLover:
        // Edge Function v2: 8단계 심층 상담 필드
        // Survey step ids: primaryGoal, breakupTime, breakupInitiator, relationshipDepth,
        //                  coreReason, detailedStory, currentState, contactStatus,
        //                  healingDeep, reunionDeep, exMbti, newStartDeep
        final primaryGoal = answers['primaryGoal'] ?? 'healing';
        final goalSpecific = <String, dynamic>{};

        // 목표별 심화 질문 매핑
        if (primaryGoal == 'healing' && answers['healingDeep'] != null) {
          goalSpecific['hardestMoment'] = answers['healingDeep'];
        } else if (primaryGoal == 'reunion_strategy' &&
            answers['reunionDeep'] != null) {
          goalSpecific['whatWillChange'] = answers['reunionDeep'];
        } else if (primaryGoal == 'read_their_mind' &&
            answers['exMbti'] != null) {
          goalSpecific['exCharacteristics'] = answers['exMbti'];
        } else if (primaryGoal == 'new_start' &&
            answers['newStartDeep'] != null) {
          goalSpecific['newRelationshipPriority'] = answers['newStartDeep'];
        }

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'ex-lover',
          params: {
            'name': userName,
            'ex_name':
                _normalizeExPartnerName(answers['exPartnerName'] as String?),
            'ex_mbti': answers['exPartnerMbti'] ?? 'unknown',
            'ex_birth_date': answers['exPartnerBirthYear'] ?? '',
            'primaryGoal': primaryGoal,
            'time_since_breakup': answers['breakupTime'] ?? 'recent',
            'breakup_initiator': answers['breakupInitiator'] ?? 'mutual',
            'relationshipDepth':
                _mapRelationshipDepth(answers['relationshipDepth']),
            'coreReason': answers['coreReason'] ?? 'unknown',
            'breakup_detail': answers['detailedStory'] ?? '',
            'currentState': answers['currentState'] is List
                ? answers['currentState']
                : <String>[],
            'contact_status': _mapContactStatus(answers['contactStatus']),
            if (goalSpecific.isNotEmpty) 'goalSpecific': goalSpecific,
          },
        );

      case FortuneSurveyType.avoidPeople:
        // Edge Function 요구: environment, importantSchedule, moodLevel, stressLevel, etc.
        // Survey step id: 'situation'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'avoid-people',
          params: {
            'environment': answers['situation'] ?? 'work',
            'importantSchedule': false,
            'moodLevel': 5,
            'stressLevel': 5,
            'socialFatigue': 'normal',
            'hasImportantDecision': false,
            'hasSensitiveConversation': false,
            'hasTeamProject': false,
          },
        );

      // ============================================================
      // Traditional / Saju
      // ============================================================
      case FortuneSurveyType.traditional:
        return apiService.getSajuFortune(userId: userId, birthDate: birthDate);

      // ============================================================
      // Personality / MBTI
      // ============================================================
      case FortuneSurveyType.mbti:
        // Edge Function 요구: mbti, name, birthDate, category
        // Survey step ids: 'mbtiConfirm', 'mbtiType', 'category'
        // mbtiConfirm == 'yes' → 프로필 MBTI 사용
        // mbtiConfirm == 'no' → 재선택한 mbtiType 사용
        String mbtiType;
        if (answers['mbtiConfirm'] == 'yes') {
          mbtiType = userProfile?.mbtiType ?? 'INFP';
        } else {
          mbtiType = answers['mbtiType'] ?? userProfile?.mbtiType ?? 'INFP';
        }
        final category = answers['category'] ?? 'overall';
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'mbti',
          params: {
            'mbti': mbtiType,
            'name': userName,
            'birthDate': birthDateStr,
            'category': category,
          },
        );

      case FortuneSurveyType.biorhythm:
        // Edge Function 요구: birthDate, name
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'biorhythm',
          params: {
            'birthDate': birthDateStr,
            'name': userName,
          },
        );

      case FortuneSurveyType.talent:
        // Edge Function 요구: talentArea, currentSkills, goals, experience, timeAvailable, challenges
        // Survey step ids: 'interest' (multiSelect), 'workStyle', 'problemSolving'
        final interestAreas = answers['interest'];
        final workStyleAnswer = answers['workStyle'] ?? 'team';
        final problemSolvingAnswer = answers['problemSolving'] ?? 'logical';
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'talent',
          params: {
            'talentArea': interestAreas is List
                ? interestAreas
                : [interestAreas ?? 'creative'],
            'currentSkills': [workStyleAnswer, problemSolvingAnswer],
            'workStyle': workStyleAnswer,
            'problemSolving': problemSolvingAnswer,
            'goals': '잠재력 발견',
            'experience': '초급',
            'timeAvailable': '주 5시간',
            'challenges': ['시간 부족', '방향성 미확정'],
          },
        );

      // ============================================================
      // 재물운 (Wealth Fortune)
      // ============================================================
      case FortuneSurveyType.money:
        // Edge Function 요구: goal, concern, income, expense, risk, interests, urgency
        // Survey step ids: 'goal', 'concern', 'income', 'expense', 'risk', 'interests', 'urgency'
        final goal = answers['goal'] as String? ?? 'saving';
        final concern = answers['concern'] as String? ?? 'spending';
        final income = answers['income'] as String? ?? 'stable';
        final expense = answers['expense'] as String? ?? 'balanced';
        final risk = answers['risk'] as String? ?? 'balanced';
        final interests = answers['interests'] as List<dynamic>? ?? ['stock'];
        final urgency = answers['urgency'] as String? ?? 'thisYear';

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'wealth',
          params: {
            'goal': goal,
            'concern': concern,
            'income': income,
            'expense': expense,
            'risk': risk,
            'interests': interests,
            'urgency': urgency,
          },
        );

      // ============================================================
      // Health
      // ============================================================
      case FortuneSurveyType.health:
        // Edge Function 요구: current_condition, concerned_body_parts,
        // sleepQuality, exerciseFrequency, stressLevel, mealRegularity
        // Survey step ids: 'concern', 'sleepQuality', 'exerciseFrequency', 'stressLevel', 'mealRegularity'
        final healthConcern = answers['concern'] ?? 'general';
        final sleepQuality = int.tryParse(answers['sleepQuality'] ?? '3') ?? 3;
        final exerciseFrequency =
            int.tryParse(answers['exerciseFrequency'] ?? '3') ?? 3;
        final stressLevel = int.tryParse(answers['stressLevel'] ?? '3') ?? 3;
        final mealRegularity =
            int.tryParse(answers['mealRegularity'] ?? '3') ?? 3;
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'health',
          params: {
            'current_condition': healthConcern,
            'concerned_body_parts': [healthConcern],
            'sleepQuality': sleepQuality,
            'exerciseFrequency': exerciseFrequency,
            'stressLevel': stressLevel,
            'mealRegularity': mealRegularity,
          },
        );

      // ============================================================
      // Lucky Items / Lotto
      // ============================================================
      case FortuneSurveyType.luckyItems:
        // Edge Function 요구: userId, name, birthDate
        // Survey step id: 'category'
        final luckyCategory = answers['category'];
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'lucky-items',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'interests': luckyCategory != null ? [luckyCategory] : [],
          },
        );

      case FortuneSurveyType.lotto:
        // 클라이언트 사이드에서 로또 번호 생성
        final gameCountStr = answers['gameCount'] ?? '1';
        final gameCount = int.tryParse(gameCountStr) ?? 1;

        // LottoNumberGenerator로 번호 생성
        final lottoFortuneResult = LottoNumberGenerator.generate(
          birthDate: birthDate,
          birthTime: userProfile?.birthTime,
          gender: userProfile?.gender.value,
          gameCount: gameCount,
        );

        // Fortune 객체로 변환하여 반환
        // 여러 세트 지원: sets 배열 전체 저장
        final lottoSets = lottoFortuneResult.lottoResult.sets;
        final allSetsData = lottoSets
            .map((set) => {
                  'numbers': set.numbers,
                  'numberElements': set.numberElements,
                })
            .toList();

        // 하위 호환성: 첫 번째 세트를 기본값으로
        final lottoNumbers = lottoFortuneResult.lottoResult.numbers;
        final fortune = Fortune(
          id: 'lotto_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          type: 'lotto',
          content: lottoFortuneResult.lottoResult.fortuneMessage,
          createdAt: DateTime.now(),
          tokenCost: 0, // 클라이언트 생성이므로 토큰 비용 없음
          overallScore: 85,
          period: 'today',
          metadata: {
            'lottoNumbers': lottoNumbers,
            'numberElements': lottoFortuneResult.lottoResult.numberElements,
            'gameCount': gameCount,
            'lottoSets': allSetsData, // 여러 세트 데이터
          },
          additionalInfo: {
            'lottoNumbers': lottoNumbers,
            'lottoSets': allSetsData, // 여러 세트 데이터
            'luckyLocation': {
              'direction': lottoFortuneResult.luckyLocation.direction,
              'shopType': lottoFortuneResult.luckyLocation.shopType,
            },
            'luckyTiming': {
              'day': lottoFortuneResult.luckyTiming.luckyDay,
              'timeSlot': lottoFortuneResult.luckyTiming.luckyTimeSlot,
            },
          },
        );
        return Future.value(fortune);

      // ============================================================
      // Dream / Interactive
      // ============================================================
      case FortuneSurveyType.dream:
        // Edge Function 요구: dream (string)
        // survey step id: 'dreamContent'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'dream',
          params: {
            'dream': answers['dreamContent'] ?? '꿈 내용이 입력되지 않았습니다',
            'emotion': answers['emotion'] ?? 'neutral',
            'inputType': 'text',
            'date': DateTime.now().toIso8601String().split('T')[0],
          },
        );

      case FortuneSurveyType.tarot:
        // ChatTarotFlow에서 수집된 데이터로 타로 API 호출
        // BUG FIX: 타로 데이터는 answers['tarotSelection'] 안에 중첩되어 있음!
        // survey step id가 'tarotSelection'이므로 해당 키 아래에 저장됨
        final tarotData =
            answers['tarotSelection'] as Map<String, dynamic>? ?? {};
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'tarot',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'spreadType': tarotData['spreadType'] ?? 'single',
            'cardCount': tarotData['cardCount'] ?? 1,
            'selectedCards': tarotData['selectedCards'] ?? [],
            'question': answers['purpose'] ?? '오늘의 운세',
            'deck': tarotData['deck'] ?? 'rider_waite',
          },
        );

      // ============================================================
      // Face Reading
      // ============================================================
      case FortuneSurveyType.faceReading:
        // ChatFaceReadingFlow에서 수집된 이미지를 base64로 변환
        // 설문 답변 구조: answers['photo'] = {'imagePath': '...'} (step ID가 'photo')
        final photoData = answers['photo'] as Map<String, dynamic>?;
        final imagePath = photoData?['imagePath'] as String?;
        String? imageBase64;

        Logger.debug('📸 [FaceReading] 이미지 경로 확인', {
          'photoData': photoData,
          'imagePath': imagePath,
        });

        if (imagePath != null && imagePath.isNotEmpty) {
          try {
            final file = File(imagePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              imageBase64 = base64Encode(bytes);
              Logger.debug('📸 [FaceReading] 이미지 base64 변환 완료', {
                'originalPath': imagePath,
                'base64Length': imageBase64.length,
              });
            } else {
              Logger.error('❌ [FaceReading] 이미지 파일이 존재하지 않음', imagePath);
            }
          } catch (e) {
            Logger.error('❌ [FaceReading] 이미지 base64 변환 실패', e);
          }
        } else {
          Logger.error('❌ [FaceReading] 이미지 경로가 없음', {
            'answers_keys': answers.keys.toList(),
            'photoData': photoData,
          });
        }

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'face-reading',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender.toString().split('.').last,
            'userGender': gender.toString().split('.').last,
            'image': imageBase64,
          },
        );

      case FortuneSurveyType.personalityDna:
        // Note: personality Edge Function 없음 → mbti 활용
        final mbtiType = userProfile?.mbtiType ?? 'INFP';
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'mbti',
          params: {
            'mbti': mbtiType,
            'name': userName,
            'birthDate': birthDateStr,
          },
        );

      // ============================================================
      // Lifestyle
      // ============================================================
      case FortuneSurveyType.wish:
        // survey step id: 'wishContent', 'category', 'bokchae'
        // 🧧 복채 토큰 차감 (설문에서 선택한 경우)
        final bokchaeAmount = int.tryParse(answers['bokchae']?.toString() ?? '0') ?? 0;
        if (bokchaeAmount > 0) {
          final tokenNotifier = ref.read(tokenProvider.notifier);
          await tokenNotifier.consumeTokens(
            fortuneType: 'wish-bokchae',
            amount: bokchaeAmount,
            referenceId: 'bokchae-${DateTime.now().millisecondsSinceEpoch}',
          );
        }
        // ✅ API 호출 없이 로컬에서 결과 생성 (꿈해몽처럼 심플하게)
        final wishText = answers['wishContent'] ?? '';
        return Fortune(
          id: 'wish-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          type: 'wish',
          content: wishText,
          createdAt: DateTime.now(),
          additionalInfo: {'wish_text': wishText},
        );

      case FortuneSurveyType.fortuneCookie:
        // 로컬 포춘쿠키 생성기 사용 (API 호출 없음, 일일 저장)
        final cookieResult =
            await FortuneCookieGenerator.getTodayFortuneCookie();
        return Fortune(
          id: 'fortune-cookie-${DateTime.now().toIso8601String().split('T')[0]}',
          userId: userId,
          type: 'fortune-cookie',
          content: cookieResult.data['message'] as String? ?? '',
          createdAt: DateTime.now(),
          overallScore: cookieResult.score,
          luckyItems: {
            'lucky_number': cookieResult.data['lucky_number'],
            'lucky_color': cookieResult.data['lucky_color'],
            'emoji': cookieResult.data['emoji'],
          },
        );

      // ============================================================
      // Health / Sports
      // ============================================================
      case FortuneSurveyType.exercise:
        // Survey step ids: 'goal', 'intensity'
        // Edge Function: fortune-exercise (전용 운동 가이드)
        final surveyGoal = answers['goal'] ?? 'health';
        final surveyIntensity = answers['intensity'] ?? 'moderate';

        // 설문 goal → API exerciseGoal 매핑
        final exerciseGoalMap = {
          'weight': 'diet',
          'muscle': 'strength',
          'health': 'endurance',
          'stress': 'stress_relief',
          'flexibility': 'flexibility',
        };

        // 설문 intensity → experienceLevel/fitnessLevel 매핑
        final experienceLevelMap = {
          'light': 'beginner',
          'moderate': 'intermediate',
          'intense': 'advanced',
        };
        final fitnessLevelMap = {
          'light': 2,
          'moderate': 3,
          'intense': 4,
        };

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'exercise',
          params: {
            'exerciseGoal': exerciseGoalMap[surveyGoal] ?? 'endurance',
            'sportType': 'gym', // 채팅에서는 기본 헬스 추천
            'weeklyFrequency': 3,
            'experienceLevel':
                experienceLevelMap[surveyIntensity] ?? 'intermediate',
            'fitnessLevel': fitnessLevelMap[surveyIntensity] ?? 3,
            'injuryHistory': <String>['none'],
            'preferredTime': 'evening',
          },
        );

      case FortuneSurveyType.sportsGame:
        // fortune-match-insight Edge Function 사용
        // Survey step ids: 'sport' (chips), 'match' (matchSelection object), 'favoriteTeam' (chips)
        // match object: { id, sport, league, homeTeam, awayTeam, gameTime, venue }
        final match = answers['match'] as Map<String, dynamic>?;
        final favoriteTeam = answers['favoriteTeam'] as String?;

        // match 객체에서 필드 추출
        final sport = match?['sport'] as String? ??
            answers['sport'] as String? ??
            'baseball';
        final league = match?['league'] as String? ?? '';
        final homeTeam = match?['homeTeam'] as String? ?? '';
        final awayTeam = match?['awayTeam'] as String? ?? '';
        final gameTime = match?['gameTime'] as String?;

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'match-insight',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'sport': sport,
            'league': league,
            'homeTeam': homeTeam,
            'awayTeam': awayTeam,
            if (gameTime != null) 'gameDate': gameTime,
            if (favoriteTeam != null && favoriteTeam.isNotEmpty)
              'favoriteTeam': favoriteTeam,
          },
        );

      // ============================================================
      // Interactive
      // ============================================================
      case FortuneSurveyType.celebrity:
        // Edge Function 요구: celebrity_id, celebrity_name, connection_type, question_type, category, name, birthDate
        // Survey step ids: 'celebrity' (object), 'connectionType' (chips), 'interest' (chips)
        final celebrity = answers['celebrity'] as Map<String, dynamic>?;
        final connectionType =
            answers['connectionType'] as String? ?? 'ideal_match';
        final interest = answers['interest'] as String? ?? 'overall';
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'celebrity',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'celebrity_id': celebrity?['id'] ?? '',
            'celebrity_name':
                celebrity?['name'] ?? celebrity?['displayName'] ?? '',
            'celebrity_birth_date': celebrity?['birthDate'] ?? '',
            'connection_type': connectionType,
            'question_type': interest,
            'category': 'entertainment',
          },
        );

      case FortuneSurveyType.pastLife:
        // ChatFaceReadingFlow에서 수집된 이미지로 전생탐험 API 호출
        // 설문 답변 구조: answers['photo'] = {'imagePath': '...'} (step ID가 'photo')
        final pastLifePhotoData = answers['photo'] as Map<String, dynamic>?;
        final pastLifeImagePath = pastLifePhotoData?['imagePath'] as String?;
        String? pastLifeImageBase64;

        if (pastLifeImagePath != null && pastLifeImagePath.isNotEmpty) {
          try {
            final file = File(pastLifeImagePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              pastLifeImageBase64 = base64Encode(bytes);
            }
          } catch (e) {
            Logger.error('❌ [PastLife] 이미지 base64 변환 실패', e);
          }
        }

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'past-life',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender,
            'image': pastLifeImageBase64,
          },
        );

      // ============================================================
      // Game Enhance (게임 강화운세 - 입력 없음)
      // ============================================================
      case FortuneSurveyType.gameEnhance:
        // fortune-game-enhance Edge Function 사용
        // 입력 없이 범용 강화운세 제공
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'game-enhance',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender,
          },
        );

      // ============================================================
      // Family / Pet
      // ============================================================
      case FortuneSurveyType.pet:
        // fortune-pet-compatibility Edge Function 사용
        // Survey step id: 'pet' (PetProfile Map 객체)
        // pet 객체: { id, name, species, age, gender, breed, personality, healthNotes, isNeutered }
        final petProfile = answers['pet'] as Map<String, dynamic>?;

        // PetProfile에서 필드 추출 (Edge Function은 snake_case 사용)
        final petName = petProfile?['name'] as String? ?? '반려동물';
        final petSpecies = petProfile?['species'] as String? ?? '강아지';
        final petAge = petProfile?['age'] as int? ?? 1;
        final petGender = petProfile?['gender'] as String? ?? '모름';
        final petBreed = petProfile?['breed'] as String?;
        final petPersonality = petProfile?['personality'] as String?;
        final petHealthNotes = petProfile?['healthNotes'] as String?;
        final petNeutered = petProfile?['isNeutered'] as bool?;

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'pet-compatibility',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'pet_name': petName,
            'pet_species': petSpecies,
            'pet_age': petAge,
            'pet_gender': petGender,
            if (petBreed != null && petBreed.isNotEmpty) 'pet_breed': petBreed,
            if (petPersonality != null && petPersonality.isNotEmpty)
              'pet_personality': petPersonality,
            if (petHealthNotes != null && petHealthNotes.isNotEmpty)
              'pet_health_notes': petHealthNotes,
            if (petNeutered != null) 'pet_neutered': petNeutered,
          },
        );

      case FortuneSurveyType.family:
        // 개별 가족 운세 Edge Function 사용 (fortune-family-{type})
        // Survey step ids: 'concern', 'member', 'familyProfile'
        final familyConcern = answers['concern'] ?? 'health';
        final familyType = _getFamilyType(familyConcern);

        // 가족 구성원 프로필 데이터 (familyProfile 단계에서 수집)
        final familyProfileData =
            answers['familyProfile'] as Map<String, dynamic>?;

        return apiService.getFortune(
          userId: userId,
          fortuneType:
              'family-$familyType', // fortune-family-health, fortune-family-wealth 등
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'family_type': familyType,
            'relationship': answers['member'] ?? 'all',
            // 가족 구성원 정보 추가
            if (familyProfileData != null)
              'familyMember': {
                'name': familyProfileData['name'],
                'birthDate': familyProfileData['birthDate'],
                'birthTime': familyProfileData['birthTime'],
                'gender': familyProfileData['gender'],
                'isLunar': familyProfileData['isLunar'] ?? false,
                'relation': familyProfileData['familyRelation'],
              },
          },
        );

      case FortuneSurveyType.naming:
        // Edge Function 요구: userId, motherBirthDate, expectedBirthDate, babyGender, familyName
        // Survey step ids: 'dueDate', 'gender', 'lastName', 'style'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'naming',
          params: {
            'motherBirthDate': birthDateStr,
            'expectedBirthDate': answers['dueDate'] ?? birthDateStr,
            'babyGender': answers['gender'] ?? 'unknown',
            'familyName': answers['lastName'] ?? '김',
            'nameStyle': answers['style'] ?? 'modern',
          },
        );

      case FortuneSurveyType.babyNickname:
        // Edge Function 요구: userId, nickname, babyDream (optional)
        // Survey step ids: 'nickname', 'babyDream'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'baby-nickname',
          params: {
            'nickname': answers['nickname'] ?? '',
            'babyDream': answers['babyDream'],
          },
        );

      // ============================================================
      // Style / OOTD
      // ============================================================
      case FortuneSurveyType.ootdEvaluation:
        // Edge Function 요구: imageBase64, tpo
        // Survey step ids: 'tpo', 'photo' (imagePath)
        final tpo = answers['tpo'] as String? ?? 'casual';
        final photoData = answers['photo'] as Map<String, dynamic>?;
        final photoPath = photoData?['imagePath'] as String?;

        // 이미지를 base64로 변환
        String? imageBase64;
        if (photoPath != null) {
          try {
            final file = File(photoPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              imageBase64 = base64Encode(bytes);
              Logger.info(
                  'OOTD photo converted to base64: ${bytes.length} bytes');
            }
          } catch (e) {
            Logger.error('Failed to convert OOTD photo to base64', e);
          }
        }

        if (imageBase64 == null) {
          throw Exception('OOTD 평가를 위해 사진이 필요합니다');
        }

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'ootd',
          params: {
            'imageBase64': imageBase64,
            'tpo': tpo,
            'userGender': gender.toString().split('.').last,
            'userName': userName,
          },
        );

      case FortuneSurveyType.talisman:
        // Edge Function 요구: userId, birthDate, concern
        // Survey step ids: 'concern', 'style'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'talisman',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender.toString().split('.').last,
            'concern': answers['concern'] ?? 'protection',
            'style': answers['style'] ?? 'traditional',
          },
        );

      case FortuneSurveyType.exam:
        // Edge Function 요구: exam_category, exam_date, preparation_status (snake_case)
        // Survey step ids: 'examType', 'examDate', 'preparation'
        final examType = answers['examType'] as String?;
        final rawExamDate = _normalizeDateValue(answers['examDate']);
        final resolvedExamDate = rawExamDate.isNotEmpty
            ? rawExamDate
            : (examType == 'csat'
                ? _getCsatDate(DateTime.now())
                    .toIso8601String()
                    .split('T')[0]
                : DateTime.now().toIso8601String().split('T')[0]);
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'exam',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender,
            'exam_category': examType ?? 'general',
            'exam_date': resolvedExamDate,
            'preparation_status': answers['preparation'] ?? 'normal',
          },
        );

      case FortuneSurveyType.moving:
        // 새로운 설문 구조: currentArea, targetArea, movingPeriod, specificDate, purpose, concerns
        final currentLocation = answers['currentArea'] as LocationData?;
        final targetLocation = answers['targetArea'] as LocationData?;

        // 방향 자동 계산
        String direction = 'unknown';
        String? distanceFormatted;
        if (currentLocation?.hasCoordinates == true &&
            targetLocation?.hasCoordinates == true) {
          final directionInfo = DirectionCalculator.getDirectionInfo(
            fromLat: currentLocation!.latitude!,
            fromLng: currentLocation.longitude!,
            toLat: targetLocation!.latitude!,
            toLng: targetLocation.longitude!,
          );
          direction = directionInfo['direction'] as String;
          distanceFormatted = directionInfo['distanceFormatted'] as String?;
        } else if (currentLocation != null && targetLocation != null) {
          // 좌표 없으면 지역명으로 추론
          direction = DirectionCalculator.inferFromRegionNames(
                currentLocation.displayName,
                targetLocation.displayName,
              ) ??
              'unknown';
        }

        // 이사 시기 포맷팅
        final movingPeriod = answers['movingPeriod'] as String? ?? 'undecided';
        final specificDate = answers['specificDate']?.toString();
        final movingDate = specificDate ?? _formatMovingPeriod(movingPeriod);

        // 걱정사항 (다중선택)
        final concerns = answers['concerns'];
        final concernsList =
            concerns is List ? concerns.cast<String>() : <String>[];

        return apiService.getFortune(
          userId: userId,
          fortuneType: 'moving',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender,
            'moveType': 'residence',
            'currentArea': currentLocation?.displayName ?? '',
            'targetArea': targetLocation?.displayName ?? '',
            'currentCoords': currentLocation?.coordsJson,
            'targetCoords': targetLocation?.coordsJson,
            'direction': direction,
            'distance': distanceFormatted,
            'movingPeriod': movingPeriod,
            'movingDate': movingDate,
            'purpose': _mapMovingPurpose(answers['purpose'] as String?),
            'concerns':
                concernsList.isNotEmpty ? concernsList.join(', ') : null,
          },
        );

      case FortuneSurveyType.profileCreation:
        // profileCreation은 운세 API 호출이 아닌 프로필 저장 용도
        // _handleProfileCreationComplete에서 별도 처리됨
        throw UnsupportedError('profileCreation은 운세 API를 사용하지 않습니다');

      case FortuneSurveyType.gratitude:
        // gratitude는 API 호출 없이 로컬에서 처리
        // _handleGratitudeComplete에서 별도 처리됨
        throw UnsupportedError('gratitude는 운세 API를 사용하지 않습니다');

      case FortuneSurveyType.yearlyEncounter:
        // 올해의 인연: AI 이미지 생성 + 텍스트 분석
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'yearly-encounter',
          params: {
            'targetGender': answers['targetGender'],
            'userAge': answers['userAge'],
            'idealMbti': answers['idealMbti'],
            'idealType': answers['idealType'] ?? '',
            'userName': userName,
            'birthDate': birthDateStr,
            'gender': gender,
          },
        );
    }
  }

  /// 생년월일로 나이 계산
  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 25; // 기본값
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 이사 시기 옵션을 날짜 문자열로 변환
  String _formatMovingPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case '1month':
        return now
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0];
      case '3months':
        return now
            .add(const Duration(days: 90))
            .toIso8601String()
            .split('T')[0];
      case '6months':
        return now
            .add(const Duration(days: 180))
            .toIso8601String()
            .split('T')[0];
      case '1year':
        return now
            .add(const Duration(days: 365))
            .toIso8601String()
            .split('T')[0];
      case 'undecided':
      default:
        return now
            .add(const Duration(days: 90))
            .toIso8601String()
            .split('T')[0]; // 기본 3개월
    }
  }

  /// 이사 목적 옵션을 한글로 매핑
  String _mapMovingPurpose(String? purpose) {
    switch (purpose) {
      case 'job':
        return '직장/취업';
      case 'study':
        return '학업/유학';
      case 'marriage':
        return '결혼/독립';
      case 'family':
        return '가족';
      case 'environment':
        return '주거환경 개선';
      case 'investment':
        return '투자/재테크';
      case 'other':
      default:
        return '기타';
    }
  }

  String _getTypeDisplayName(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.daily:
        return '오늘의 인사이트';
      case FortuneSurveyType.career:
        return '오늘의 커리어';
      case FortuneSurveyType.love:
        return '오늘의 연애운';
      case FortuneSurveyType.talent:
        return '오늘의 적성';
      case FortuneSurveyType.tarot:
        return '오늘의 타로';
      case FortuneSurveyType.mbti:
        return '오늘의 MBTI';
      case FortuneSurveyType.newYear:
        return '오늘의 새해운';
      case FortuneSurveyType.dailyCalendar:
        return '오늘의 기간운';
      case FortuneSurveyType.traditional:
        return '오늘의 사주';
      case FortuneSurveyType.faceReading:
        return '오늘의 관상';
      case FortuneSurveyType.personalityDna:
        return '오늘의 성격';
      case FortuneSurveyType.biorhythm:
        return '오늘의 바이오리듬';
      case FortuneSurveyType.compatibility:
        return '오늘의 궁합';
      case FortuneSurveyType.avoidPeople:
        return '오늘의 경계운';
      case FortuneSurveyType.exLover:
        return '오늘의 재회운';
      case FortuneSurveyType.blindDate:
        return '오늘의 소개팅운';
      case FortuneSurveyType.money:
        return '오늘의 재물운';
      case FortuneSurveyType.luckyItems:
        return '오늘의 행운 아이템';
      case FortuneSurveyType.lotto:
        return '오늘의 로또';
      case FortuneSurveyType.wish:
        return '오늘의 소원';
      case FortuneSurveyType.fortuneCookie:
        return '오늘의 메시지';
      case FortuneSurveyType.health:
        return '오늘의 건강';
      case FortuneSurveyType.exercise:
        return '오늘의 운동';
      case FortuneSurveyType.sportsGame:
        return '오늘의 경기운';
      case FortuneSurveyType.dream:
        return '오늘의 해몽';
      case FortuneSurveyType.celebrity:
        return '오늘의 셀럽 궁합';
      case FortuneSurveyType.pastLife:
        return '오늘의 전생탐험';
      case FortuneSurveyType.gameEnhance:
        return '강화운세';
      case FortuneSurveyType.pet:
        return '오늘의 반려운';
      case FortuneSurveyType.family:
        return '오늘의 가족운';
      case FortuneSurveyType.naming:
        return '오늘의 이름운';
      case FortuneSurveyType.babyNickname:
        return '태명 이야기';
      case FortuneSurveyType.ootdEvaluation:
        return '오늘의 OOTD';
      case FortuneSurveyType.talisman:
        return '오늘의 부적';
      case FortuneSurveyType.exam:
        return '오늘의 시험운';
      case FortuneSurveyType.moving:
        return '오늘의 이사운';
      case FortuneSurveyType.profileCreation:
        return '프로필 생성';
      case FortuneSurveyType.gratitude:
        return '감사일기';
      case FortuneSurveyType.yearlyEncounter:
        return '올해의 인연';
    }
  }

  /// FortuneSurveyType을 FortuneCardImages에서 사용하는 문자열로 변환
  String _mapSurveyTypeToString(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.career:
        return 'career';
      case FortuneSurveyType.love:
        return 'love';
      case FortuneSurveyType.talent:
        return 'talent';
      case FortuneSurveyType.daily:
        return 'daily';
      case FortuneSurveyType.tarot:
        return 'tarot';
      case FortuneSurveyType.mbti:
        return 'mbti';
      case FortuneSurveyType.newYear:
        return 'newYear';
      case FortuneSurveyType.dailyCalendar:
        return 'daily_calendar';
      case FortuneSurveyType.traditional:
        return 'traditional';
      case FortuneSurveyType.faceReading:
        return 'face-reading';
      case FortuneSurveyType.personalityDna:
        return 'personality';
      case FortuneSurveyType.biorhythm:
        return 'biorhythm';
      case FortuneSurveyType.compatibility:
        return 'compatibility';
      case FortuneSurveyType.avoidPeople:
        return 'avoid-people';
      case FortuneSurveyType.exLover:
        return 'ex-lover';
      case FortuneSurveyType.blindDate:
        return 'blind-date';
      case FortuneSurveyType.money:
        return 'money';
      case FortuneSurveyType.luckyItems:
        return 'lucky-items';
      case FortuneSurveyType.lotto:
        return 'lotto';
      case FortuneSurveyType.wish:
        return 'wish';
      case FortuneSurveyType.fortuneCookie:
        return 'fortune-cookie';
      case FortuneSurveyType.health:
        return 'health';
      case FortuneSurveyType.exercise:
        return 'health_sports';
      case FortuneSurveyType.sportsGame:
        return 'match-insight';
      case FortuneSurveyType.dream:
        return 'dream';
      case FortuneSurveyType.celebrity:
        return 'celebrity';
      case FortuneSurveyType.pastLife:
        return 'past-life';
      case FortuneSurveyType.gameEnhance:
        return 'game-enhance';
      case FortuneSurveyType.pet:
        return 'pet';
      case FortuneSurveyType.family:
        return 'family';
      case FortuneSurveyType.naming:
        return 'naming';
      case FortuneSurveyType.babyNickname:
        return 'baby-nickname';
      case FortuneSurveyType.ootdEvaluation:
        return 'ootd-evaluation';
      case FortuneSurveyType.talisman:
        return 'talisman';
      case FortuneSurveyType.exam:
        return 'exam';
      case FortuneSurveyType.moving:
        return 'moving';
      case FortuneSurveyType.profileCreation:
        return 'default'; // 프로필 생성은 운세 이미지 불필요
      case FortuneSurveyType.gratitude:
        return 'gratitude'; // 감사일기
      case FortuneSurveyType.yearlyEncounter:
        return 'yearly-encounter'; // 올해의 인연
    }
  }

  /// 꿈해몽 dreamContent 입력 단계인지 확인
  bool _isDreamContentStep(ChatSurveyState surveyState) {
    if (!surveyState.isActive || surveyState.activeProgress == null) {
      return false;
    }
    final config = surveyState.activeProgress!.config;
    final currentStep = surveyState.activeProgress!.currentStep;
    return config.fortuneType == FortuneSurveyType.dream &&
        currentStep.id == 'dreamContent' &&
        _showDreamBubbles;
  }

  /// 채팅용 꿈 칩 위젯 (좌우 흔들리는 칩)
  Widget _buildChatDreamBubbles() {
    return SizedBox(
      height: 350,
      child: FloatingDreamTopicsWidget(
        onTopicSelected: (topic) {
          setState(() => _showDreamBubbles = false);
          // 자동 제출
          Future.delayed(const Duration(milliseconds: 200), () {
            _handleTextSurveySubmit(topic);
          });
        },
      ),
    );
  }

  /// 설문 입력 위젯 빌드 - inputType에 따라 적절한 위젯 반환
  Widget? _buildSurveyInputWidget(
      ChatSurveyState surveyState, List<SurveyOption> options) {
    if (!surveyState.isActive || surveyState.activeProgress == null) {
      return null;
    }

    final currentStep = surveyState.activeProgress!.currentStep;

    switch (currentStep.inputType) {
      case SurveyInputType.chips:
        if (options.isEmpty) return null;
        return ChatSurveyChips(
          options: options,
          onSelect: _handleSurveyAnswer,
        );

      case SurveyInputType.multiSelect:
        if (options.isEmpty) return null;
        // ✅ 다중 선택용 위젯 (완료 버튼 포함)
        return _MultiSelectSurveyWidget(
          options: options,
          maxSelections: 3, // 최대 3개 선택
          onConfirm: (selectedIds) {
            _handleSurveyAnswerMultiple(selectedIds, options);
          },
        );

      case SurveyInputType.slider:
        return ChatSurveySlider(
          onValueChanged: (value) {},
          onSubmit: (value) {
            final displayText = '${value.toInt()}${currentStep.unit ?? ''}';
            _handleSurveyAnswerValue(value, displayText);
          },
          minValue: currentStep.minValue ?? 0,
          maxValue: currentStep.maxValue ?? 100,
          unit: currentStep.unit,
          hintText: currentStep.question,
        );

      case SurveyInputType.profile:
        final profilesAsync = ref.watch(secondaryProfilesProvider);
        return profilesAsync.when(
          data: (profiles) {
            // 저장된 프로필이 없으면 자동으로 "새로 입력" 플로우 시작
            if (profiles.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleProfileSelect(null);
              });
              return const SizedBox.shrink();
            }
            return ChatProfileSelector(
              profiles: profiles,
              onSelect: _handleProfileSelect,
              hintText: '궁합을 볼 상대를 선택하세요',
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(DSSpacing.md),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) {
            // 에러 시에도 자동으로 "새로 입력" 플로우 시작
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleProfileSelect(null);
            });
            return const SizedBox.shrink();
          },
        );

      case SurveyInputType.familyProfile:
        // 가족 프로필 선택 (가족운)
        // 이전 단계에서 선택한 member 값을 가져옴
        final selectedMember =
            surveyState.activeProgress?.answers['member'] as String?;
        if (selectedMember == null || selectedMember == 'all') {
          // 가족 전체 선택 시 이 단계 스킵
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleSurveyAnswerValue(null, '가족 전체');
          });
          return const SizedBox.shrink();
        }
        return ChatFamilyProfileSelector(
          familyRelation: selectedMember,
          onSelect: (profile) =>
              _handleFamilyProfileSelect(profile, selectedMember),
          hintText: currentStep.question,
        );

      case SurveyInputType.petProfile:
        // 펫 등록 폼 표시 중이면 폼 렌더링
        if (_showPetRegistrationForm) {
          return ChatPetRegistrationForm(
            onComplete: _handlePetRegistrationComplete,
            onCancel: () => setState(() => _showPetRegistrationForm = false),
          );
        }
        // 기존 펫 선택 UI
        final petState = ref.watch(petProvider);
        return ChatPetProfileSelector(
          profiles: petState.pets,
          onSelect: _handlePetSelect,
          hintText: '반려동물을 선택하세요',
        );

      case SurveyInputType.voice:
        // 꿈해몽 dreamContent 단계면 FloatingDreamBubbles 표시
        if (_isDreamContentStep(surveyState)) {
          return _buildChatDreamBubbles();
        }
        // 그 외 음성/텍스트 입력은 하단 텍스트 필드 사용 - null 반환하여 활성화
        return null;

      case SurveyInputType.date:
        return ChatDatePicker(
          onDateSelected: (date) {
            final displayText = DateFormat('yyyy년 M월 d일').format(date);
            _handleSurveyAnswerValue(date.toIso8601String(), displayText);
          },
          hintText: currentStep.question,
        );

      case SurveyInputType.birthDateTime:
        return ChatBirthDatetimePicker(
          onSelected: (result) {
            _handleSurveyAnswerValue(
              {
                'dateString': result.dateString,
                'timeString': result.timeString,
                'birthTimeSlot': result.birthTimeSlot,
                'isUnknown': result.isUnknown,
              },
              result.displayText,
            );
          },
          hintText: currentStep.question,
        );

      case SurveyInputType.calendar:
        // dailyCalendar인 경우 바텀시트로 표시
        final isDailyCalendar =
            surveyState.activeProgress?.config.fortuneType ==
                FortuneSurveyType.dailyCalendar;

        if (isDailyCalendar) {
          // calendarSync 답변이 'sync'면 연동 시도
          final calendarSyncAnswer =
              surveyState.activeProgress?.answers['calendarSync'];
          final shouldSync = calendarSyncAnswer == 'sync';

          // 아직 연동 안됐지만 연동 요청한 경우 백그라운드에서 연동 시도
          if (shouldSync && !_isCalendarSynced) {
            _handleCalendarSync();
          }

          // 연동 여부 결정: 이미 연동됐거나, 연동 요청한 경우
          final showEvents = _isCalendarSynced || shouldSync;

          // 바텀시트 열기 버튼
          return _buildCalendarOpenButton(
            context: context,
            onTap: () => _showDailyCalendarBottomSheet(showEvents: showEvents),
          );
        }

        // 기본 캘린더 (다른 운세 타입용)
        return ChatInlineCalendar(
          onDateSelected: (date) {
            final displayText = DateFormat('yyyy년 M월 d일').format(date);
            _handleSurveyAnswerValue(date.toIso8601String(), displayText);
          },
          hintText: currentStep.question,
          showQuickOptions: true,
        );

      case SurveyInputType.image:
        return ChatImageInput(
          onImageSelected: _handleImageSelect,
          hintText: '사진을 선택하거나 촬영하세요',
        );

      case SurveyInputType.ootdImage:
        return OotdPhotoInput(
          onImageSelected: _handleImageSelect,
        );

      case SurveyInputType.text:
        // 텍스트 입력은 하단 텍스트 필드 사용 - null 반환하여 활성화
        return null;

      case SurveyInputType.textWithSkip:
        // "없음" 칩 + 텍스트 입력 (텍스트 입력 시 칩 숨김)
        return _TextWithSkipInput(
          onSkip: () => _handleSurveyAnswerValue('', '없음'),
          textController: _textController,
        );

      case SurveyInputType.grid:
        // Fallback to chips for now
        if (options.isEmpty) return null;
        return ChatSurveyChips(
          options: options,
          onSelect: _handleSurveyAnswer,
        );

      case SurveyInputType.tarot:
        final deckId = _todaysTarotDeck ?? 'rider_waite';
        return ChatTarotFlow(
          onComplete: _handleTarotComplete,
          question: surveyState.activeProgress?.answers['purpose'] as String?,
          deckId: deckId,
          deckDisplayName: AssetPackConfig.getTarotDeckDisplayName(deckId),
        );

      case SurveyInputType.faceReading:
        return ChatFaceReadingFlow(
          onComplete: _handleFaceReadingComplete,
        );

      case SurveyInputType.investmentCategory:
        return ChatInvestmentCategorySelector(
          onCategorySelected: (category) {
            _handleSurveyAnswerValue(category.name, category.label);
          },
        );

      case SurveyInputType.investmentTicker:
        final selectedCategory =
            surveyState.activeProgress?.answers['category'] as String?;
        return ChatInvestmentTickerSelector(
          category: selectedCategory,
          onTickerSelected: (ticker) {
            _handleSurveyAnswerValue(
              {
                'symbol': ticker.symbol,
                'name': ticker.name,
                'category': ticker.category,
                'exchange': ticker.exchange,
              },
              '${ticker.name} (${ticker.symbol})',
            );
          },
        );

      case SurveyInputType.celebritySelection:
        return ChatCelebritySelector(
          onSelect: (celebrity) {
            _handleSurveyAnswerValue(
              {
                'id': celebrity.id,
                'name': celebrity.name,
                'displayName': celebrity.displayName,
                'type': celebrity.celebrityType.name,
                'birthDate': celebrity.birthDate.toIso8601String(),
                'characterImageUrl': celebrity.characterImageUrl,
              },
              '⭐ ${celebrity.displayName}',
            );
          },
        );

      case SurveyInputType.matchSelection:
        final selectedSport =
            surveyState.activeProgress?.answers['sport'] as String? ??
                'baseball';
        return ChatMatchSelector(
          selectedSport: selectedSport,
          onSelect: (game, league) {
            _handleSurveyAnswerValue(
              {
                'id': game.id,
                'sport': game.sport.name,
                'league': league,
                'homeTeam': game.homeTeam,
                'awayTeam': game.awayTeam,
                'gameTime': game.gameTime.toIso8601String(),
                'venue': game.venue,
              },
              '${game.sport.emoji} ${game.matchTitle}',
            );
          },
        );

      case SurveyInputType.location:
        final questionTitle =
            surveyState.activeProgress?.currentStep.question ?? '지역을 선택해주세요';
        // 바텀시트로 위치 선택 표시 (화면 덮어버리는 문제 해결)
        return _buildLocationPickerTrigger(questionTitle);
    }
  }

  /// 위치 선택 버튼 위젯 (바텀시트 트리거)
  Widget _buildLocationPickerTrigger(String questionTitle) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: InkWell(
        onTap: () => _showLocationPickerBottomSheet(questionTitle),
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 20, color: colors.accent),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '📍 지역 선택하기',
                style: typography.bodyMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Icon(Icons.arrow_forward_ios, size: 14, color: colors.accent),
            ],
          ),
        ),
      ),
    );
  }

  /// 위치 선택 바텀시트 표시
  Future<void> _showLocationPickerBottomSheet(String questionTitle) async {
    final result = await showModalBottomSheet<LocationData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final colors = bottomSheetContext.colors;
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.75,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DSRadius.xl),
                ),
              ),
              child: Column(
                children: [
                  // 핸들바
                  Container(
                    margin: const EdgeInsets.only(top: DSSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            questionTitle,
                            style: bottomSheetContext.typography.headingSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                  ),
                  // 위치 선택 위젯
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: ChatLocationPicker(
                        questionTitle: questionTitle,
                        onLocationSelected: (location) {
                          Navigator.pop(bottomSheetContext, location);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // 선택 완료 시 설문 답변 처리
    if (result != null && mounted) {
      _handleSurveyAnswerValue(
        result,
        '📍 ${result.displayName}',
      );
    }
  }

  /// 온보딩 칩 입력 위젯 빌드 (성별/MBTI/혈액형/확인/로그인유도)
  Widget _buildOnboardingChipInput(OnboardingState onboardingState) {
    switch (onboardingState.currentStep) {
      case OnboardingStep.gender:
        return KeyedSubtree(
          key: const ValueKey('onboarding-gender'),
          child: OnboardingGenderSelector(
            onSelect: (gender) {
              ref.read(onboardingChatProvider.notifier).submitGender(gender);
              _scrollToBottom();
            },
          ),
        );

      case OnboardingStep.mbti:
        return KeyedSubtree(
          key: const ValueKey('onboarding-mbti'),
          child: OnboardingMbtiSelector(
            onSelect: (mbti) {
              ref.read(onboardingChatProvider.notifier).submitMbti(mbti);
              _scrollToBottom();
            },
          ),
        );

      case OnboardingStep.bloodType:
        return KeyedSubtree(
          key: const ValueKey('onboarding-bloodtype'),
          child: OnboardingBloodTypeSelector(
            onSelect: (bloodType) {
              ref
                  .read(onboardingChatProvider.notifier)
                  .submitBloodType(bloodType);
              _scrollToBottom();
            },
          ),
        );

      case OnboardingStep.confirmation:
        return KeyedSubtree(
          key: const ValueKey('onboarding-confirmation'),
          child: OnboardingConfirmationCard(
            state: onboardingState,
            onConfirm: () {
              ref.read(onboardingChatProvider.notifier).confirmOnboarding();
              _scrollToBottom();
              // AI 메시지 추가 후 추가 스크롤 (300ms 지연으로 메시지 추가됨)
              Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
            },
            onRestart: () {
              ref.read(onboardingChatProvider.notifier).restartOnboarding();
              _scrollToBottom();
            },
          ),
        );

      case OnboardingStep.loginPrompt:
        return KeyedSubtree(
          key: const ValueKey('onboarding-login'),
          child: OnboardingLoginPromptCard(
            onSignUp: () {
              // 소셜 로그인 바텀시트 표시
              _showSocialLoginBottomSheet(context);
            },
            onSkip: () {
              ref.read(onboardingChatProvider.notifier).skipLoginPrompt();
              _scrollToBottom();
            },
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// 선택형 설문 중인지 확인 (입력란 숨김 조건)
  bool _shouldHideInputField(ChatSurveyState surveyState) {
    if (!surveyState.isActive) return false;
    if (surveyState.activeProgress == null) return false;

    final inputType = surveyState.activeProgress!.currentStep.inputType;
    // 텍스트/음성 입력이 필요한 경우는 입력란 유지
    return inputType != SurveyInputType.text &&
        inputType != SurveyInputType.textWithSkip &&
        inputType != SurveyInputType.voice;
  }

  /// 하단 떠다니는 영역의 높이 계산 (설문 + 온보딩 칩 + 입력란)
  /// [surveyOptions]: 현재 설문의 옵션 목록 (칩 개수에 따라 높이 동적 계산)
  double _calculateBottomPadding(
    ChatSurveyState surveyState,
    OnboardingState onboardingState, {
    List<SurveyOption> surveyOptions = const [],
  }) {
    // 기본 입력란 높이
    double padding = 80;

    // 온보딩 칩 입력 중인 경우 (성별/MBTI/혈액형/확인/로그인유도)
    final onboardingStep = onboardingState.currentStep;
    if (onboardingStep == OnboardingStep.gender) {
      // 성별 선택: 3개 칩 + 건너뛰기 버튼
      padding += 220;
    } else if (onboardingStep == OnboardingStep.mbti) {
      // MBTI 선택: 16개 칩 (4줄) + 건너뛰기 버튼
      padding += 420;
    } else if (onboardingStep == OnboardingStep.bloodType) {
      // 혈액형 선택: 4개 칩 + 건너뛰기 버튼
      padding += 220;
    } else if (onboardingStep == OnboardingStep.confirmation) {
      // 확인 화면: 정보 요약 카드 + 2개 버튼
      padding += 380;
    } else if (onboardingStep == OnboardingStep.loginPrompt) {
      // 로그인 유도: 회원가입 버튼 + 나중에 버튼 + 메시지 여백
      padding += 200;
    } else if (onboardingStep == OnboardingStep.birthDate ||
        onboardingStep == OnboardingStep.birthTime) {
      // 생년월일/시간 피커 (통합 피커는 높이가 큼)
      padding += 400;
    } else if (surveyState.isActive) {
      final inputType = surveyState.activeProgress?.currentStep.inputType;

      if (inputType == SurveyInputType.chips ||
          inputType == SurveyInputType.multiSelect) {
        // ✅ 옵션 개수에 따라 동적 높이 계산
        // 한 줄에 약 2개 칩 (화면 너비 고려), 줄당 약 56px
        final optionCount = surveyOptions.length;
        final rowCount = (optionCount / 2).ceil().clamp(1, 10); // 한 줄에 2개 기준
        final chipAreaHeight = rowCount * 56.0;
        // 질문 헤더(40) + 칩 영역 + 여백(40) - 최소 140, 최대 400
        padding += (chipAreaHeight + 80).clamp(140.0, 400.0);
      } else if (inputType == SurveyInputType.profile ||
          inputType == SurveyInputType.petProfile) {
        // 프로필/펫프로필 선택 (힌트 + 프로필 칩들 + 새로 입력하기 버튼)
        padding += 180;
      } else if (inputType == SurveyInputType.text ||
          inputType == SurveyInputType.textWithSkip ||
          inputType == SurveyInputType.voice) {
        // 꿈해몽 dreamContent 단계는 FloatingDreamTopicsWidget(350px) 표시
        final isDreamContent =
            surveyState.activeProgress?.config.fortuneType ==
                    FortuneSurveyType.dream &&
                surveyState.activeProgress?.currentStep.id == 'dreamContent';
        if (isDreamContent) {
          padding += 350; // FloatingDreamTopicsWidget 높이
        } else {
          // 일반 텍스트/음성 입력
          padding += 20;
        }
      } else if (inputType == SurveyInputType.tarot) {
        // 타로 플로우: 스프레드 선택(140) 또는 카드 선택(280)
        // 카드 선택 단계가 더 높으므로 최대값 사용
        padding += 280;
      } else if (inputType == SurveyInputType.calendar) {
        // 캘린더 입력: 빠른선택(50) + 월헤더(40) + 요일헤더(30) + 그리드(240) + 선택표시(40) + 확인버튼(50)
        padding += 450;
      } else if (inputType == SurveyInputType.matchSelection) {
        // 경기 선택: 헤더(40) + 리스트(360) + 버튼(60) = maxHeight 420 + 여유
        padding += 440;
      } else if (inputType == SurveyInputType.celebritySelection) {
        // 연예인 선택: 검색(50) + 리스트(300) + 여유
        padding += 380;
      } else if (inputType == SurveyInputType.location) {
        // 위치 선택 버튼: 버튼(60) + 패딩(32) + 여유
        padding += 120;
      } else {
        // 기타 입력 타입
        padding += 50;
      }
    } else if (_detectedIntents.isNotEmpty) {
      padding += 40;
    }

    return padding;
  }

  Widget _buildChatBackground() {
    final asset = _chatBackgroundAsset ?? _defaultChatBackgroundAsset;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: SizedBox.expand(
          key: ValueKey(asset),
          child: Opacity(
            opacity: 0.3,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatMessagesProvider);
    final surveyState = ref.watch(chatSurveyProvider);
    final onboardingState = ref.watch(onboardingChatProvider);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 온보딩 상태 변경 시 자동 스크롤
    ref.listen<OnboardingState>(onboardingChatProvider, (previous, next) {
      if (previous?.currentStep != next.currentStep) {
        _scrollToBottom();
      }
    });

    // 설문 상태 변경 시 자동 스크롤 (설문 UI가 나타날 때)
    ref.listen<ChatSurveyState>(chatSurveyProvider, (previous, next) {
      if (previous?.isActive != next.isActive ||
          previous?.activeProgress?.currentStep.id !=
              next.activeProgress?.currentStep.id) {
        _scrollToBottom();
      }
    });

    // 현재 설문 옵션 가져오기
    final surveyOptions = surveyState.isActive
        ? ref.read(chatSurveyProvider.notifier).getCurrentStepOptions()
        : <SurveyOption>[];

    // 현재 설문 스텝이 텍스트/음성 입력인지 확인 (둘 다 하단 텍스트 필드 사용)
    final isTextInputStep = surveyState.isActive &&
        surveyState.activeProgress != null &&
        (surveyState.activeProgress!.currentStep.inputType ==
                SurveyInputType.text ||
            surveyState.activeProgress!.currentStep.inputType ==
                SurveyInputType.textWithSkip ||
            surveyState.activeProgress!.currentStep.inputType ==
                SurveyInputType.voice);

    // 온보딩 이름 입력 중인지 확인 (welcome과 name 단계 모두 포함)
    // ✅ currentStep 기준으로 판단 (needsOnboarding이 stale data로 false일 수 있음)
    final isOnboardingNameStep =
        onboardingState.currentStep == OnboardingStep.welcome ||
            onboardingState.currentStep == OnboardingStep.name;

    // 온보딩 특수 입력 단계 (텍스트 입력 숨김)
    final isOnboardingPickerStep =
        onboardingState.currentStep == OnboardingStep.birthDate ||
            onboardingState.currentStep == OnboardingStep.birthTime;
    final isOnboardingChipStep =
        onboardingState.currentStep == OnboardingStep.gender ||
            onboardingState.currentStep == OnboardingStep.mbti ||
            onboardingState.currentStep == OnboardingStep.bloodType ||
            onboardingState.currentStep == OnboardingStep.confirmation ||
            onboardingState.currentStep == OnboardingStep.loginPrompt;
    final shouldHideInput = _shouldHideInputField(surveyState) ||
        isOnboardingPickerStep ||
        isOnboardingChipStep;

    // ✅ 온보딩 상태 체크 중이면 빈 화면 표시 (깜빡임 방지)
    if (onboardingState.isCheckingStatus) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const SizedBox.shrink(),
      );
    }

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildChatBackground(),
            ),
            Positioned.fill(
              child: SafeArea(
                bottom: false, // MainShell에서 navigation bar padding 처리
                child: GestureDetector(
                  onTap: () {
                    // 배경 탭 시 키보드 dismiss
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
                      // 메인 콘텐츠 (메시지 영역)
                      AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: chatState.isEmpty
                          ? ChatWelcomeView(
                              key: const ValueKey('chat-welcome'),
                              onChipTap: _handleChipTap,
                              bottomPadding: _calculateBottomPadding(
                                surveyState,
                                onboardingState,
                                surveyOptions: surveyOptions,
                              ),
                            )
                          : ChatMessageList(
                              key: const ValueKey('chat-messages'),
                              scrollController: _scrollController,
                              messages: chatState.messages,
                              isTyping: chatState.isTyping,
                              onChipTap: _handleChipTap,
                              onViewAllTap: _handleViewAllTap,
                              bottomPadding: _calculateBottomPadding(
                                surveyState,
                                onboardingState,
                                surveyOptions: surveyOptions,
                              ),
                              onTypingIndicatorRendered: _scrollToBottom,
                              onFortuneResultRendered:
                                  _handleFortuneResultRendered,
                            ),
                    ),

                    // 프로필 아이콘 (투명 오버레이 - 좌측) - 온보딩 중에는 숨김
                    if (onboardingState.currentStep == OnboardingStep.completed)
                      const Positioned(
                        left: DSSpacing.md,
                        top: DSSpacing.sm,
                        child: ProfileHeaderIcon(),
                      ),

                    // 상단 우측 버튼 영역 (게스트 로그인 + 초기화) - 온보딩 중에는 숨김
                    if (onboardingState.currentStep == OnboardingStep.completed)
                      Positioned(
                        right: DSSpacing.sm,
                        top: DSSpacing.xs,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 게스트 로그인 버튼 (심플 버전)
                            const GuestLoginBanner(),
                            const SizedBox(width: DSSpacing.xs),
                            // 초기화 버튼
                            InkWell(
                              onTap: () {
                                ref
                                    .read(chatMessagesProvider.notifier)
                                    .clearConversation();
                                ref
                                    .read(chatSurveyProvider.notifier)
                                    .cancelSurvey();
                                _textController.clear();
                                setState(() {
                                  _detectedIntents = [];
                                });
                              },
                              borderRadius: BorderRadius.circular(DSRadius.full),
                              child: Padding(
                                padding: const EdgeInsets.all(DSSpacing.xs),
                                child: Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 떠다니는 하단 영역 (설문 + 칩 + 입력란)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 설문 입력 영역 (inputType에 따라 다른 위젯) - 슬라이드 업 애니메이션
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              child: surveyState.isActive
                                  ? KeyedSubtree(
                                      key: ValueKey(
                                          surveyState.activeProgress?.currentStep.id ??
                                              'survey'),
                                      child: _buildSurveyInputWidget(
                                            surveyState,
                                            surveyOptions,
                                          ) ??
                                          const SizedBox.shrink(),
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            // 온보딩 날짜+시간 피커 (birthDate 단계에서 표시)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              child: isOnboardingPickerStep
                                  ? KeyedSubtree(
                                      key: const ValueKey('onboarding-picker'),
                                      child: ChatBirthDatetimePicker(
                                        hintText: '생년월일과 태어난 시간을 선택하세요',
                                        onSelected: (result) {
                                          if (result.isUnknown) {
                                            // 날짜 모름 - 기본값으로 처리
                                            ref
                                                .read(onboardingChatProvider.notifier)
                                                .submitBirthDateTime(
                                                  DateTime(1990, 1, 1),
                                                  null,
                                                );
                                          } else if (result.year != null &&
                                              result.month != null &&
                                              result.day != null) {
                                            final date = DateTime(
                                              result.year!,
                                              result.month!,
                                              result.day!,
                                            );
                                            final time = result.hour != null
                                                ? TimeOfDay(
                                                    hour: result.hour!,
                                                    minute: result.minute ?? 0,
                                                  )
                                                : null;
                                            ref
                                                .read(onboardingChatProvider.notifier)
                                                .submitBirthDateTime(date, time);
                                          }
                                          _scrollToBottom();
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            // 온보딩 성별/MBTI/혈액형/확인/로그인 선택
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              child: _buildOnboardingChipInput(onboardingState),
                            ),

                            // 추천 운세 칩 (텍스트 입력 시 - 키워드 기반 + AI 추천)
                            if (!surveyState.isActive &&
                                (_detectedIntents.isNotEmpty ||
                                    _isLoadingRecommendations))
                              FortuneTypeChips(
                                intents: _detectedIntents,
                                onSelect: _handleFortuneTypeSelect,
                                isLoading: _isLoadingRecommendations,
                              ),

                            // 텍스트 입력란 (선택형 설문/온보딩 시 슬라이드 아웃)
                            IgnorePointer(
                              ignoring: shouldHideInput,
                              child: ClipRect(
                                child: AnimatedSlide(
                                  offset: shouldHideInput
                                      ? const Offset(0, 1)
                                      : Offset.zero,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  child: AnimatedOpacity(
                                    opacity: shouldHideInput ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DSSpacing.md,
                                      ),
                                      child: UnifiedVoiceTextField(
                                        controller: _textController,
                                        hintText: isOnboardingNameStep
                                            ? '이름을 입력하세요'
                                            : isTextInputStep
                                                ? '텍스트를 입력하세요...'
                                                : surveyState.isActive
                                                    ? '위 선택지에서 골라주세요'
                                                    : '무엇이든 물어보세요...',
                                        onSubmit: isOnboardingNameStep
                                            ? _handleOnboardingNameSubmit
                                            : isTextInputStep
                                                ? _handleTextSurveySubmit
                                                : surveyState.isActive
                                                    ? (_) {}
                                                    : _handleSendMessage,
                                        enabled: !shouldHideInput &&
                                            (!surveyState.isActive ||
                                                isTextInputStep ||
                                                isOnboardingNameStep),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 포춘쿠키 애니메이션 오버레이
                    if (_showCookieAnimation)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {}, // 배경 탭 방지
                          child: Container(
                            color: colors.background.withValues(alpha: 0.95),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🥠',
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: DSSpacing.md),
                                  Text(
                                    '쿠키가 열리고 있어요!',
                                    style: context.typography.bodyLarge.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: DSSpacing.xl),
                                  CookieShardBreakWidget(
                                    imagePath:
                                        'assets/images/fortune_cards/fortune_cookie_fortune.png',
                                    size: 220,
                                    accentColor: const Color(0xFF9333EA),
                                    onBreakComplete: _onCookieAnimationComplete,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다중 선택 설문 위젯 (완료 버튼 포함)
class _MultiSelectSurveyWidget extends StatefulWidget {
  final List<SurveyOption> options;
  final int maxSelections;
  final void Function(List<String> selectedIds) onConfirm;

  const _MultiSelectSurveyWidget({
    required this.options,
    required this.maxSelections,
    required this.onConfirm,
  });

  @override
  State<_MultiSelectSurveyWidget> createState() =>
      _MultiSelectSurveyWidgetState();
}

class _MultiSelectSurveyWidgetState extends State<_MultiSelectSurveyWidget> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(SurveyOption option) {
    setState(() {
      if (_selectedIds.contains(option.id)) {
        _selectedIds.remove(option.id);
      } else {
        if (_selectedIds.length < widget.maxSelections) {
          _selectedIds.add(option.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 칩 선택 영역
        ChatSurveyChips(
          options: widget.options,
          onSelect: _toggleSelection,
          allowMultiple: true,
          selectedIds: _selectedIds,
        ),
        // 완료 버튼
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () => widget.onConfirm(_selectedIds.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accentSecondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    colors.textTertiary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
              ),
              child: Text(
                _selectedIds.isEmpty
                    ? '선택해주세요'
                    : '완료 (${_selectedIds.length}/${widget.maxSelections})',
                style: context.typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 텍스트 입력 + "없음" 스킵 칩 위젯
class _TextWithSkipInput extends StatefulWidget {
  final VoidCallback onSkip;
  final TextEditingController textController;

  const _TextWithSkipInput({
    required this.onSkip,
    required this.textController,
  });

  @override
  State<_TextWithSkipInput> createState() => _TextWithSkipInputState();
}

class _TextWithSkipInputState extends State<_TextWithSkipInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.textController.text.isNotEmpty;
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.textController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트가 있으면 칩 숨김
    if (_hasText) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        children: [
          GestureDetector(
            onTap: () {
              DSHaptics.light();
              widget.onSkip();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.colors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '🎲 없음',
                style: context.typography.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
