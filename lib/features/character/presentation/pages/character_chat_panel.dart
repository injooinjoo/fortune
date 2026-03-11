import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/fortune/fortune_type_registry.dart';
import '../../../../core/extensions/l10n_extension.dart';
import 'package:fortune/core/utils/haptic_utils.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';
import '../../data/fortune_characters.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../../domain/models/character_choice.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_chat_survey_provider.dart';
import '../providers/active_chat_provider.dart';
import '../utils/character_accent_palette.dart';
import '../widgets/character_message_bubble.dart';
import '../widgets/character_choice_widget.dart';
import '../widgets/wave_typing_indicator.dart';
import '../../../chat/services/chat_scroll_service.dart';
// 설문 관련 imports
import '../../../chat/domain/models/fortune_survey_config.dart';
import '../../../chat/domain/configs/survey_configs.dart';
import '../../../chat/presentation/widgets/survey/chat_survey_chips.dart';
import '../../../chat/presentation/widgets/survey/chat_birth_datetime_picker.dart';
import '../../../chat/presentation/widgets/survey/chat_survey_slider.dart';
import '../../../chat/presentation/widgets/survey/chat_inline_calendar.dart';
import '../../../chat/presentation/widgets/survey/chat_face_reading_flow.dart';
import '../../../chat/presentation/widgets/survey/ootd_photo_input.dart';
import '../../../chat/presentation/widgets/survey/chat_image_input.dart';
import '../../../chat/presentation/widgets/survey/chat_match_selector.dart';
import '../../../../core/services/unified_calendar_service.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';

/// 1:1 캐릭터 롤플레이 채팅 패널
class CharacterChatPanel extends ConsumerStatefulWidget {
  final AiCharacter character;
  final VoidCallback? onBack;
  final String? initialFortuneType;
  final bool autoStartFortune;
  final String? entrySource;

  const CharacterChatPanel({
    super.key,
    required this.character,
    this.onBack,
    this.initialFortuneType,
    this.autoStartFortune = false,
    this.entrySource,
  });

  @override
  ConsumerState<CharacterChatPanel> createState() => _CharacterChatPanelState();
}

class _CharacterChatPanelState extends ConsumerState<CharacterChatPanel>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _surveyTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  /// Notifier 참조 캐시 (dispose 후 ref 사용 불가 문제 해결)
  CharacterChatNotifier? _cachedNotifier;
  bool _didRedirectToProfile = false;
  String? _consumedAutoStartSignature;

  /// 통합 스크롤 서비스 (ChatScrollService 사용)
  late final ChatScrollService _scrollService;

  CharacterAccentPalette _accentPalette(BuildContext context) {
    return CharacterAccentPalette.from(
      source: widget.character.accentColor,
      brightness: Theme.of(context).brightness,
    );
  }

  /// 동적 질문 생성 (mbtiConfirm 등 사용자 정보 포함 필요 시)
  String _getDynamicStepQuestion(SurveyStep step) {
    // mbtiConfirm 스텝: 사용자 MBTI 타입을 포함한 질문 생성
    if (step.id == 'mbtiConfirm') {
      // userProfileNotifierProvider에서 직접 가져오기 (더 안정적)
      final profileAsync = ref.read(userProfileNotifierProvider);
      final profile = profileAsync.valueOrNull;

      final name = profile?.name ?? '회원';
      final mbtiType = profile?.mbtiType;

      debugPrint(
          '[Survey] mbtiConfirm - name: $name, mbtiType: $mbtiType, hasValue: ${profileAsync.hasValue}');

      if (mbtiType != null && mbtiType.isNotEmpty) {
        return '$name님은 $mbtiType시네요! 맞으신가요? 🧠';
      }
      // MBTI 없으면 바로 선택하도록 안내
      return 'MBTI 유형을 알려주시면 분석해드릴게요! 🧠';
    }

    // 기본: step의 원래 question 반환
    return step.question;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollService = ChatScrollService(
      scrollController: _scrollController,
      isMounted: () => mounted,
    );
    // 기존 대화 불러오기 + 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // 🆕 현재 채팅방 진입 표시 (푸시 알림 억제용)
      ref.read(activeCharacterChatProvider.notifier).state =
          widget.character.id;

      _cachedNotifier =
          ref.read(characterChatProvider(widget.character.id).notifier);
      await _cachedNotifier?.initConversation();
      _cachedNotifier?.clearUnreadCount(); // 채팅방 진입 시 읽음 처리
      // 채팅방 진입 시 맨 아래로 스크롤
      _scrollToBottomInstant();
      await _maybeStartInitialFortuneFlow();
    });
  }

  @override
  void didUpdateWidget(covariant CharacterChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousSignature = _buildAutoStartSignature(oldWidget);
    final nextSignature = _buildAutoStartSignature(widget);
    if (previousSignature != nextSignature) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _maybeStartInitialFortuneFlow();
      });
    }
  }

  @override
  void deactivate() {
    // 🆕 채팅방 이탈 표시 (푸시 알림 활성화)
    // Future.microtask로 지연하여 위젯 라이프사이클 충돌 방지
    final notifier = ref.read(activeCharacterChatProvider.notifier);
    Future.microtask(() {
      notifier.state = null;
    });
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 화면 이탈 시 저장 (캐시된 notifier 사용 - ref 사용 불가)
    _cachedNotifier?.saveOnExit();
    _textController.dispose();
    _surveyTextController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _scrollService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 백그라운드로 갈 때 저장
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveConversation();
    }
  }

  Future<void> _saveConversation() async {
    // mounted 상태에서는 ref 사용, 아니면 캐시된 notifier 사용
    if (mounted) {
      await ref
          .read(characterChatProvider(widget.character.id).notifier)
          .saveOnExit();
    } else {
      await _cachedNotifier?.saveOnExit();
    }
  }

  /// 최하단으로 스크롤 (애니메이션)
  void _scrollToBottom() {
    _scrollService.scrollToBottom();
  }

  /// 채팅방 진입 시 즉시 맨 아래로 스크롤 (애니메이션 없이)
  void _scrollToBottomInstant() {
    _scrollService.scrollToBottomInstant();
  }

  String? _buildAutoStartSignature(CharacterChatPanel panel) {
    final fortuneType = panel.initialFortuneType;
    if (!panel.autoStartFortune || fortuneType == null || fortuneType.isEmpty) {
      return null;
    }

    return [
      panel.character.id,
      fortuneType,
      panel.entrySource ?? '-',
    ].join('|');
  }

  Future<void> _maybeStartInitialFortuneFlow() async {
    final signature = _buildAutoStartSignature(widget);
    final fortuneType = widget.initialFortuneType;

    if (signature == null ||
        fortuneType == null ||
        fortuneType.isEmpty ||
        _consumedAutoStartSignature == signature) {
      return;
    }

    final expectedExpert = findFortuneExpert(fortuneType);
    if (expectedExpert == null || expectedExpert.id != widget.character.id) {
      return;
    }

    _consumedAutoStartSignature = signature;
    await _startFortuneFlow(
      fortuneType,
      _getSpecialtyLabel(context, fortuneType),
      triggerHaptic: false,
      resetSurvey: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(characterChatProvider(widget.character.id));
    final surveyState =
        ref.watch(characterChatSurveyProvider(widget.character.id));
    _redirectToProfileIfNoConversation(chatState);

    // 🪙 토큰 부족 및 일반 에러 감지
    ref.listen<CharacterChatState>(
      characterChatProvider(widget.character.id),
      (previous, next) {
        if (next.error != null && next.error != previous?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.errorOccurredRetry),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: context.l10n.confirm,
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );

          Future.delayed(const Duration(milliseconds: 100), () {
            ref
                .read(characterChatProvider(widget.character.id).notifier)
                .clearError();
          });
        }

        // 📜 새 메시지 추가 또는 타이핑 시작 시 자동 스크롤 (다른 채팅앱처럼)
        final prevCount = previous?.messages.length ?? 0;
        final nextCount = next.messages.length;
        final typingStarted = next.isTyping && !(previous?.isTyping ?? false);
        if (nextCount > prevCount || typingStarted) {
          _scrollToBottom();
        }
      },
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // 뒤로가기 시 저장
          await _saveConversation();
        }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(context),
              const Divider(height: 1),
              // 운세 전문가 칩 바 (운세 전문가일 때만)
              if (widget.character.isFortuneExpert &&
                  widget.character.specialties.isNotEmpty)
                _buildFortuneChipBar(chatState),
              // 채팅 영역
              Expanded(
                child: chatState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chatState.hasConversation
                        ? _buildChatList(chatState)
                        : const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
              ),
              // 설문 UI (설문 진행 중일 때)
              if (surveyState.isActive) _buildSurveyInput(surveyState),
              // 입력 영역 (대화 시작 후에만, 설문 중이 아닐 때)
              if (chatState.hasConversation && !surveyState.isActive)
                _buildInputArea(chatState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final accentPalette = _accentPalette(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 백버튼
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onBack?.call();
            },
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // 프로필 영역 (탭 가능)
          Expanded(
            child: GestureDetector(
              onTap: () => _showCharacterProfile(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: accentPalette.accent,
                    backgroundImage: widget.character.avatarAsset.isNotEmpty
                        ? AssetImage(widget.character.avatarAsset)
                        : null,
                    child: widget.character.avatarAsset.isEmpty
                        ? Text(
                            widget.character.initial,
                            style: context.bodySmall.copyWith(
                              color: accentPalette.onAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.character.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          widget.character.personality.length > 30
                              ? '${widget.character.personality.substring(0, 30)}...'
                              : widget.character.personality,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showCharacterProfile(context),
          ),
        ],
      ),
    );
  }

  void _showCharacterProfile(BuildContext context) {
    HapticUtils.lightImpact();
    context.push('/character/${widget.character.id}', extra: widget.character);
  }

  void _redirectToProfileIfNoConversation(CharacterChatState chatState) {
    if (!chatState.isInitialized ||
        chatState.isLoading ||
        chatState.hasConversation ||
        _didRedirectToProfile) {
      return;
    }

    _didRedirectToProfile = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onBack?.call();
      context.push('/character/${widget.character.id}',
          extra: widget.character);
    });
  }

  /// specialty 키 → l10n 라벨 매핑
  String _getSpecialtyLabel(BuildContext context, String specialty) {
    final l10n = context.l10n;
    switch (FortuneTypeRegistry.labelKeyOf(specialty)) {
      case 'fortuneDaily':
        return l10n.fortuneDaily;
      case 'fortuneDailyCalendar':
        return l10n.fortuneDailyCalendar;
      case 'fortuneNewYear':
        return l10n.fortuneNewYear;
      case 'fortuneTraditional':
        return l10n.fortuneTraditional;
      case 'fortuneSaju':
        return l10n.fortuneSaju;
      case 'fortuneTarot':
        return l10n.fortuneTarot;
      case 'fortuneFaceReading':
        return l10n.fortuneFaceReading;
      case 'fortuneTalisman':
        return l10n.fortuneTalisman;
      case 'fortunePastLife':
        return l10n.fortunePastLife;
      case 'fortuneDream':
        return l10n.fortuneDream;
      case 'fortuneLove':
        return l10n.fortuneLove;
      case 'fortuneCompatibility':
        return l10n.fortuneCompatibility;
      case 'fortuneBlindDate':
        return l10n.fortuneBlindDate;
      case 'fortuneExLover':
        return l10n.fortuneExLover;
      case 'fortuneAvoidPeople':
        return l10n.fortuneAvoidPeople;
      case 'fortuneYearlyEncounter':
        return l10n.fortuneYearlyEncounter;
      case 'fortuneCelebrity':
        return l10n.fortuneCelebrity;
      case 'fortuneMbti':
        return l10n.fortuneMbti;
      case 'fortunePersonalityDna':
        return l10n.fortunePersonalityDna;
      case 'fortuneTalent':
        return l10n.fortuneTalent;
      case 'fortuneBiorhythm':
        return l10n.fortuneBiorhythm;
      case 'fortuneCareer':
        return l10n.fortuneCareer;
      case 'fortuneWealth':
        return l10n.fortuneWealth;
      case 'fortuneLuckyExam':
        return l10n.fortuneLuckyExam;
      case 'fortuneLuckyItems':
        return l10n.fortuneLuckyItems;
      case 'fortuneLuckyLottery':
        return l10n.fortuneLuckyLottery;
      case 'fortuneOotdEvaluation':
        return l10n.fortuneOotdEvaluation;
      case 'fortuneZodiac':
        return l10n.fortuneZodiac;
      case 'fortuneConstellation':
        return l10n.fortuneConstellation;
      case 'fortuneZodiacAnimal':
        return l10n.fortuneZodiacAnimal;
      case 'fortuneBirthstone':
        return l10n.fortuneBirthstone;
      case 'fortuneHealth':
        return l10n.fortuneHealth;
      case 'fortuneExercise':
        return l10n.fortuneExercise;
      case 'fortuneSportsGame':
        return l10n.fortuneSportsGame;
      case 'fortuneGameEnhance':
        return l10n.fortuneGameEnhance;
      case 'fortuneFamily':
        return l10n.fortuneFamily;
      case 'fortunePet':
        return l10n.fortunePet;
      case 'fortuneNaming':
        return l10n.fortuneNaming;
      case 'fortuneBabyNickname':
        return l10n.fortuneBabyNickname;
      case 'fortuneMoving':
        return l10n.fortuneMoving;
      case 'fortuneFortuneCookie':
        return l10n.fortuneFortuneCookie;
      case 'fortuneBreathing':
        return l10n.fortuneBreathing;
      case 'fortuneCoaching':
        return l10n.fortuneCoaching;
      case 'fortuneDecisionHelper':
        return l10n.fortuneDecisionHelper;
      case 'fortuneDailyReview':
        return l10n.fortuneDailyReview;
      case 'fortuneWeeklyReview':
        return l10n.fortuneWeeklyReview;
      case 'fortuneChatInsight':
        return l10n.fortuneChatInsight;
      case 'fortuneWish':
        return l10n.fortuneWish;
      case 'chipViewAll':
        return l10n.chipViewAll;
      default:
        return specialty;
    }
  }

  /// 운세 전문가 칩 바 (전문 분야 운세 칩들)
  Widget _buildFortuneChipBar(dynamic chatState) {
    final colors = context.colors;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.character.specialties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final specialty = widget.character.specialties[index];
          final displayName = _getSpecialtyLabel(context, specialty);
          final surveyType = _mapFortuneTypeToSurveyType(specialty);
          final chipEmoji = surveyType != null
              ? (surveyConfigs[surveyType]?.emoji ?? '✨')
              : '✨';

          return GestureDetector(
            onTap: chatState.isProcessing
                ? null
                : () => _handleFortuneChipTap(specialty, displayName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chipEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    displayName,
                    style: context.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 운세 칩 탭 핸들러 - 설문이 있으면 설문 시작, 없으면 바로 요청
  Future<void> _handleFortuneChipTap(
      String fortuneType, String displayName) async {
    await _startFortuneFlow(fortuneType, displayName);
  }

  Future<void> _startFortuneFlow(
    String fortuneType,
    String displayName, {
    bool triggerHaptic = true,
    bool resetSurvey = false,
  }) async {
    if (triggerHaptic) {
      HapticUtils.lightImpact();
    }

    if (resetSurvey) {
      ref
          .read(characterChatSurveyProvider(widget.character.id).notifier)
          .cancelSurvey();
    }

    // fortuneType을 FortuneSurveyType으로 매핑
    final surveyType = _mapFortuneTypeToSurveyType(fortuneType);
    final config = surveyType != null ? surveyConfigs[surveyType] : null;

    // 설문이 있고 단계가 있으면 설문 시작
    if (surveyType != null && config != null && config.steps.isNotEmpty) {
      // 캐릭터 메시지로 설문 시작 안내
      final chatNotifier =
          ref.read(characterChatProvider(widget.character.id).notifier);
      chatNotifier.addCharacterMessage(
        context.l10n.fortuneIntroMessage(displayName),
      );

      // 설문 시작
      ref
          .read(characterChatSurveyProvider(widget.character.id).notifier)
          .startSurvey(surveyType, fortuneTypeStr: fortuneType);

      // 첫 질문을 캐릭터 메시지로 표시
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final surveyState =
            ref.read(characterChatSurveyProvider(widget.character.id));
        if (surveyState.isActive && surveyState.activeProgress != null) {
          final firstQuestion =
              _getDynamicStepQuestion(surveyState.activeProgress!.currentStep);
          chatNotifier.addCharacterMessage(firstQuestion);
        }
        _scrollToBottom();
      });
    } else {
      // 설문 없이 바로 요청
      // 🆕 사주 타입이면 비주얼 카드로 사주 결과 즉시 보여줌
      if (fortuneType == 'traditional-saju') {
        final chatNotifier =
            ref.read(characterChatProvider(widget.character.id).notifier);
        final sajuData = await chatNotifier.getSajuRawData();
        if (!mounted) return;
        if (sajuData != null && sajuData.isNotEmpty) {
          chatNotifier.addSajuResultMessage(sajuData);
          _scrollToBottom();
        }
      }

      if (!mounted) return;
      final requestMessage = context.l10n.tellMeAbout(displayName);
      ref
          .read(characterChatProvider(widget.character.id).notifier)
          .sendFortuneRequest(fortuneType, requestMessage);
    }
    _scrollToBottom();
  }

  /// fortuneType 문자열을 FortuneSurveyType으로 매핑
  FortuneSurveyType? _mapFortuneTypeToSurveyType(String fortuneType) {
    return FortuneSurveyTypeCanonicalX.fromCanonicalId(fortuneType);
  }

  String _formatSurveyOptionText(SurveyOption option) {
    if (option.emoji != null && option.emoji!.isNotEmpty) {
      return '${option.emoji!} ${option.label}';
    }
    return option.label;
  }

  /// 달력 답변을 보기 좋게 포맷팅
  String _formatCalendarAnswer(Map<dynamic, dynamic> answer) {
    final selectedDate = answer['selectedDate'] as String?;
    final eventCount = answer['eventCount'] as int? ?? 0;

    if (selectedDate == null) {
      return '날짜 선택됨';
    }

    // 'YYYY-MM-DD' 형식 파싱
    final parts = selectedDate.split('-');
    if (parts.length != 3) {
      return selectedDate;
    }

    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;

    // 요일 계산
    final date = DateTime(year, month, day);
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[(date.weekday - 1) % 7];

    // 포맷팅: "2026년 2월 26일 (목)"
    String formatted = '$year년 $month월 $day일 ($weekday)';

    // 일정이 있으면 표시
    if (eventCount > 0) {
      formatted += ' · 일정 $eventCount개';
    }

    return '📅 $formatted';
  }

  /// 설문 답변 처리
  /// 이미지 선택 처리 (소개팅 가이드 등)
  void _handleImageSelect(File image) {
    final displayText = '📷 사진이 선택되었어요';
    _handleSurveyAnswer({
      'imagePath': image.path,
      'displayText': displayText,
    });
  }

  void _handleSurveyAnswer(dynamic answer) {
    final surveyNotifier =
        ref.read(characterChatSurveyProvider(widget.character.id).notifier);
    final chatNotifier =
        ref.read(characterChatProvider(widget.character.id).notifier);

    dynamic answerValue = answer;

    // 답변을 사용자 메시지로 표시
    String answerText;
    if (answer is SurveyOption) {
      answerValue = answer.id;
      answerText = _formatSurveyOptionText(answer);
    } else if (answer is List && answer.every((item) => item is SurveyOption)) {
      final selectedOptions = answer.cast<SurveyOption>();
      answerValue = selectedOptions.map((option) => option.id).toList();
      answerText = selectedOptions.map(_formatSurveyOptionText).join(', ');
    } else if (answer is List) {
      answerText = answer.join(', ');
    } else if (answer is Map) {
      // 달력 답변 특별 처리
      if (answer.containsKey('selectedDate')) {
        answerText = _formatCalendarAnswer(answer);
      } else if (answer.containsKey('imagePath')) {
        answerText = '📷 사진 선택 완료';
      } else if (answer.containsKey('displayText')) {
        answerText = answer['displayText'] as String;
      } else {
        answerText = answer.values.join(', ');
      }
    } else {
      answerText = answer.toString();
    }
    chatNotifier.addUserMessage(answerText);

    // 답변 처리
    surveyNotifier.answerCurrentStep(answerValue);

    // 다음 단계 확인
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final surveyState =
          ref.read(characterChatSurveyProvider(widget.character.id));

      if (surveyState.isCompleted) {
        // 설문 완료 - 운세 요청
        _handleSurveyComplete(surveyState);
      } else if (surveyState.isActive && surveyState.activeProgress != null) {
        // 다음 질문
        final nextQuestion =
            _getDynamicStepQuestion(surveyState.activeProgress!.currentStep);
        chatNotifier.addCharacterMessage(nextQuestion);
        _scrollToBottom();
      }
    });
  }

  /// 관상 분석 플로우 완료 핸들러
  void _handleFaceReadingComplete(String imagePath) {
    _handleSurveyAnswer({
      'imagePath': imagePath,
    });
  }

  /// 설문 완료 처리
  Future<void> _handleSurveyComplete(
      CharacterChatSurveyState surveyState) async {
    final chatNotifier =
        ref.read(characterChatProvider(widget.character.id).notifier);
    final surveyNotifier =
        ref.read(characterChatSurveyProvider(widget.character.id).notifier);

    // 완료 메시지
    chatNotifier.addCharacterMessage(context.l10n.analyzingMessage);

    // 설문 데이터로 운세 요청
    final fortuneType = surveyState.fortuneTypeString ?? 'daily';
    final answers = surveyState.completedData ?? {};

    // 🆕 사주 타입이면 비주얼 카드로 사주 결과 즉시 보여줌
    debugPrint('[SajuCard] fortuneType=$fortuneType, checking saju...');
    if (fortuneType == 'traditional-saju') {
      final sajuData = await chatNotifier.getSajuRawData();
      debugPrint(
          '[SajuCard] sajuData=${sajuData != null ? 'loaded (${sajuData.keys.toList()})' : 'null'}');
      if (sajuData != null && sajuData.isNotEmpty) {
        chatNotifier.addSajuResultMessage(sajuData);
        _scrollToBottom();
      } else {
        debugPrint('[SajuCard] ⚠️ 사주 데이터가 비어있음! sajuProvider 데이터 없음');
      }
    }

    // 설문 초기화
    surveyNotifier.clearCompleted();

    if (!mounted) return;

    // 운세 요청 (설문 답변 포함)
    final displayName = _getSpecialtyLabel(context, fortuneType);
    final requestMessage = context.l10n.showResults(displayName);

    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .sendFortuneRequestWithAnswers(fortuneType, requestMessage, answers);
    _scrollToBottom();
  }

  Widget _buildChatList(dynamic chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isTyping) {
          return _buildTypingIndicator();
        }

        final message = chatState.messages[index] as CharacterChatMessage;

        // 선택지 메시지인 경우
        if (message.isChoice && message.choiceSet != null) {
          return CharacterChoiceWidget(
            choiceSet: message.choiceSet!,
            character: widget.character,
            onChoiceSelected: (choice) => _handleChoiceSelection(choice),
            onTimeout: () {
              // 타임아웃 시 기본 선택지 선택
              if (message.choiceSet!.defaultChoiceIndex != null) {
                final defaultChoice = message
                    .choiceSet!.choices[message.choiceSet!.defaultChoiceIndex!];
                _handleChoiceSelection(defaultChoice);
              }
            },
          );
        }

        return CharacterMessageBubble(
          message: message,
          character: widget.character,
        );
      },
    );
  }

  void _handleChoiceSelection(CharacterChoice choice) {
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .handleChoiceSelection(choice);
    _scrollToBottom();
  }

  Widget _buildTypingIndicator() {
    final accentPalette = _accentPalette(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: accentPalette.accent,
            backgroundImage: widget.character.avatarAsset.isNotEmpty
                ? AssetImage(widget.character.avatarAsset)
                : null,
            child: widget.character.avatarAsset.isEmpty
                ? Text(
                    widget.character.initial,
                    style: context.labelMedium.copyWith(
                      color: accentPalette.onAccent,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: WaveTypingIndicator(
              dotColor: Colors.grey[500],
              dotSize: 8,
              bounceHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// 설문 입력 UI 빌드
  Widget _buildSurveyInput(CharacterChatSurveyState surveyState) {
    if (!surveyState.isActive || surveyState.activeProgress == null) {
      return const SizedBox.shrink();
    }

    final progress = surveyState.activeProgress!;
    final step = progress.currentStep;
    final accentPalette = _accentPalette(context);
    final surveyNotifier =
        ref.read(characterChatSurveyProvider(widget.character.id).notifier);
    final options = surveyNotifier.getCurrentStepOptions();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 진행률 표시
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: Row(
              children: [
                Text(
                  '${progress.currentStepIndex + 1}/${progress.config.totalSteps}',
                  style: context.labelSmall.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(accentPalette.accent),
                  ),
                ),
                // 스킵 버튼 (선택적 단계만)
                if (!step.isRequired)
                  TextButton(
                    onPressed: () {
                      surveyNotifier.skipCurrentStep();
                      _checkSurveyCompletion();
                    },
                    child: Text(
                      context.l10n.skip,
                      style:
                          context.labelSmall.copyWith(color: Colors.grey[500]),
                    ),
                  ),
              ],
            ),
          ),
          // 입력 타입별 위젯
          _buildSurveyInputWidget(step, options),
        ],
      ),
    );
  }

  /// 입력 타입별 설문 위젯 빌드
  Widget _buildSurveyInputWidget(SurveyStep step, List<SurveyOption> options) {
    switch (step.inputType) {
      case SurveyInputType.chips:
        return ChatSurveyChips(
          options: options,
          onSelect: _handleSurveyAnswer,
        );

      case SurveyInputType.multiSelect:
        return _buildMultiSelectChips(options);

      case SurveyInputType.slider:
        return ChatSurveySlider(
          minValue: step.minValue ?? 1,
          maxValue: step.maxValue ?? 10,
          initialValue: ((step.minValue ?? 1) + (step.maxValue ?? 10)) / 2,
          unit: step.unit,
          onValueChanged: (value) {}, // 실시간 변경은 무시
          onSubmit: (value) => _handleSurveyAnswer(value.toInt()),
        );

      case SurveyInputType.birthDateTime:
        return ChatBirthDatetimePicker(
          onSelected: (result) {
            _handleSurveyAnswer({
              'year': result.year,
              'month': result.month,
              'day': result.day,
              'hour': result.hour,
              'minute': result.minute,
              'isUnknown': result.isUnknown,
            });
          },
        );

      case SurveyInputType.text:
      case SurveyInputType.textWithSkip:
        return _buildTextInput(step);

      case SurveyInputType.calendar:
        return _buildCalendarInput(step);

      case SurveyInputType.faceReading:
        return ChatFaceReadingFlow(
          onComplete: _handleFaceReadingComplete,
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

      case SurveyInputType.matchSelection:
        // 이전 단계에서 선택한 종목 가져오기
        final surveyProgress = ref
            .read(
              characterChatSurveyProvider(widget.character.id),
            )
            .activeProgress;
        final selectedSport = surveyProgress?.answers['sport']?.toString();
        return ChatMatchSelector(
          selectedSport: selectedSport,
          onSelect: (game, league) {
            _handleSurveyAnswer({
              'gameId': game.id,
              'homeTeam': game.homeTeam,
              'awayTeam': game.awayTeam,
              'league': league,
              'gameTime': game.gameTime.toIso8601String(),
              'displayText': '${game.homeTeam} vs ${game.awayTeam} ($league)',
            });
          },
        );

      default:
        // 기타 복잡한 입력은 chips로 대체하거나 스킵
        if (options.isNotEmpty) {
          return ChatSurveyChips(
            options: options,
            onSelect: _handleSurveyAnswer,
          );
        }
        return _buildTextInput(step);
    }
  }

  /// 다중 선택 칩 위젯
  Widget _buildMultiSelectChips(List<SurveyOption> options) {
    final selectedIds = <String>{};
    final accentPalette = _accentPalette(context);

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatSurveyChips(
              options: options,
              onSelect: (option) {
                setState(() {
                  if (selectedIds.contains(option.id)) {
                    selectedIds.remove(option.id);
                  } else {
                    selectedIds.add(option.id);
                  }
                });
              },
              allowMultiple: true,
              selectedIds: selectedIds,
            ),
            const SizedBox(height: DSSpacing.sm),
            if (selectedIds.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  final selectedOptions = options
                      .where((option) => selectedIds.contains(option.id))
                      .toList(growable: false);
                  _handleSurveyAnswer(selectedOptions);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPalette.accent,
                  foregroundColor: accentPalette.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(context.l10n.selectionComplete),
              ),
          ],
        );
      },
    );
  }

  /// 텍스트 입력 위젯 (UnifiedVoiceTextField 스타일 통일)
  Widget _buildTextInput(SurveyStep step) {
    return Row(
      children: [
        // 카메라 버튼 없음 (텍스트 설문에는 이미지 불필요)
        Expanded(
          child: UnifiedVoiceTextField(
            controller: _surveyTextController,
            hintText: context.l10n.pleaseEnter,
            enabled: true,
            onSubmit: (text) {
              if (text.isNotEmpty) {
                _handleSurveyAnswer(text);
                _surveyTextController.clear();
              }
            },
          ),
        ),
        if (step.inputType == SurveyInputType.textWithSkip)
          TextButton(
            onPressed: () {
              ref
                  .read(
                      characterChatSurveyProvider(widget.character.id).notifier)
                  .skipCurrentStep();
              _checkSurveyCompletion();
            },
            child: Text(context.l10n.none),
          ),
      ],
    );
  }

  /// 캘린더 입력 위젯 (날짜별 운세용)
  Widget _buildCalendarInput(SurveyStep step) {
    final calendarService = UnifiedCalendarService();
    final isCalendarSynced = calendarService.isGoogleConnected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
      child: ChatInlineCalendar(
        hintText: step.question,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        showQuickOptions: true,
        showEventsAfterSelection: true,
        isCalendarSynced: isCalendarSynced,
        onLoadEvents: (date) async {
          return await calendarService.getEventsForDate(date);
        },
        onDateSelected: (date) {
          // 단순 날짜 선택만 (이벤트 표시 전)
        },
        onDateConfirmed: (date, events) {
          // 날짜 + 이벤트 선택 완료
          _handleSurveyAnswer({
            'date': date.toIso8601String(),
            'selectedDate':
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            'events': events
                .map((e) => {
                      'title': e.title,
                      'startTime': e.startTime?.toIso8601String(),
                      'isAllDay': e.isAllDay,
                      'location': e.location,
                    })
                .toList(),
            'eventCount': events.length,
          });
        },
      ),
    );
  }

  /// 설문 완료 여부 확인 (스킵 후)
  void _checkSurveyCompletion() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final surveyState =
          ref.read(characterChatSurveyProvider(widget.character.id));
      final chatNotifier =
          ref.read(characterChatProvider(widget.character.id).notifier);

      if (surveyState.isCompleted) {
        _handleSurveyComplete(surveyState);
      } else if (surveyState.isActive && surveyState.activeProgress != null) {
        // 다음 질문 표시
        final nextQuestion =
            _getDynamicStepQuestion(surveyState.activeProgress!.currentStep);
        chatNotifier.addCharacterMessage(nextQuestion);
        _scrollToBottom();
      }
    });
  }

  /// 사진 선택 바텀시트 표시
  void _showImagePickerSheet() {
    HapticUtils.lightImpact();
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading:
                  Icon(Icons.camera_alt_outlined, color: colors.textPrimary),
              title: Text('카메라', style: context.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.photo_library_outlined, color: colors.textPrimary),
              title: Text('갤러리', style: context.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택 처리
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        _handleImageMessage(file);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  /// 이미지 메시지 처리 (채팅에 이미지 전송)
  void _handleImageMessage(File imageFile) {
    // 사용자 메시지로 이미지 경로 추가 (UI에서 이미지로 표시)
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .sendImageMessage(imageFile.path);
    _scrollToBottom();
  }

  Widget _buildInputArea(dynamic chatState) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          // 사진 첨부 버튼
          GestureDetector(
            onTap: _showImagePickerSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                color: colors.textSecondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 텍스트 입력 필드
          Expanded(
            child: UnifiedVoiceTextField(
              controller: _textController,
              hintText: context.l10n.enterMessage,
              enabled: true,
              onTextChanged: (text) {
                ref
                    .read(characterChatProvider(widget.character.id).notifier)
                    .onUserDraftChanged(text);
              },
              onSubmit: (text) {
                if (text.isNotEmpty) {
                  ref
                      .read(characterChatProvider(widget.character.id).notifier)
                      .sendMessage(text);
                  _scrollToBottom();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
