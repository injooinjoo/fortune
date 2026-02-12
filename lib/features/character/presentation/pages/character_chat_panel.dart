import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/fortune_metadata.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../../domain/models/character_choice.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_chat_survey_provider.dart';
import '../providers/active_chat_provider.dart';
import '../widgets/character_intro_card.dart';
import '../widgets/character_message_bubble.dart';
import '../widgets/character_choice_widget.dart';
import '../widgets/wave_typing_indicator.dart';
// 설문 관련 imports
import '../../../chat/domain/models/fortune_survey_config.dart';
import '../../../chat/domain/configs/survey_configs.dart';
import '../../../chat/presentation/widgets/survey/chat_survey_chips.dart';
import '../../../chat/presentation/widgets/survey/chat_birth_datetime_picker.dart';
import '../../../chat/presentation/widgets/survey/chat_survey_slider.dart';

/// 1:1 캐릭터 롤플레이 채팅 패널
class CharacterChatPanel extends ConsumerStatefulWidget {
  final AiCharacter character;
  final VoidCallback? onBack;

  const CharacterChatPanel({
    super.key,
    required this.character,
    this.onBack,
  });

  @override
  ConsumerState<CharacterChatPanel> createState() => _CharacterChatPanelState();
}

class _CharacterChatPanelState extends ConsumerState<CharacterChatPanel>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  /// Notifier 참조 캐시 (dispose 후 ref 사용 불가 문제 해결)
  CharacterChatNotifier? _cachedNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 기존 대화 불러오기 + 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // 🆕 현재 채팅방 진입 표시 (푸시 알림 억제용)
      ref.read(activeCharacterChatProvider.notifier).state =
          widget.character.id;

      _cachedNotifier =
          ref.read(characterChatProvider(widget.character.id).notifier);
      await _cachedNotifier?.initConversation();
      _cachedNotifier?.clearUnreadCount();  // 채팅방 진입 시 읽음 처리
      // 채팅방 진입 시 맨 아래로 스크롤
      _scrollToBottomInstant();
    });
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
    _scrollController.dispose();
    _focusNode.dispose();
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 채팅방 진입 시 즉시 맨 아래로 스크롤 (애니메이션 없이)
  void _scrollToBottomInstant() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _startConversation() {
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .startConversation(widget.character.firstMessage);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(characterChatProvider(widget.character.id));
    final surveyState = ref.watch(characterChatSurveyProvider(widget.character.id));

    // 🪙 토큰 부족 및 일반 에러 감지
    ref.listen<CharacterChatState>(
      characterChatProvider(widget.character.id),
      (previous, next) {
        if (next.error != null && next.error != previous?.error) {
          if (next.error == 'INSUFFICIENT_TOKENS') {
            // 에러 클리어
            ref.read(characterChatProvider(widget.character.id).notifier).clearError();

            // 토큰 부족 모달 표시
            TokenInsufficientModal.show(
              context: context,
              requiredTokens: 1,
              fortuneType: 'character-chat',
            );
          } else {
            // 일반 에러 - SnackBar로 표시
            ref.read(characterChatProvider(widget.character.id).notifier).clearError();

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
          }
        }

        // 📜 새 메시지 추가 시 자동 스크롤 (다른 채팅앱처럼)
        final prevCount = previous?.messages.length ?? 0;
        final nextCount = next.messages.length;
        if (nextCount > prevCount) {
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
                        : CharacterIntroCard(
                            character: widget.character,
                            onStartConversation: _startConversation,
                          ),
              ),
              // 설문 UI (설문 진행 중일 때)
              if (surveyState.isActive) _buildSurveyInput(surveyState),
              // 입력 영역 (대화 시작 후에만, 설문 중이 아닐 때)
              if (chatState.hasConversation && !surveyState.isActive) _buildInputArea(chatState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 백버튼
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
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
                    backgroundColor: widget.character.accentColor,
                    backgroundImage: widget.character.avatarAsset.isNotEmpty
                        ? AssetImage(widget.character.avatarAsset)
                        : null,
                    child: widget.character.avatarAsset.isEmpty
                        ? Text(
                            widget.character.initial,
                            style: context.bodySmall.copyWith(
                              color: Colors.white,
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          widget.character.personality.length > 30
                              ? '${widget.character.personality.substring(0, 30)}...'
                              : widget.character.personality,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    HapticFeedback.lightImpact();
    context.push('/character/${widget.character.id}', extra: widget.character);
  }

  /// 운세 전문가 칩 바 (전문 분야 운세 칩들)
  Widget _buildFortuneChipBar(dynamic chatState) {
    // 밝은 색상이면 더 어둡게 조정하여 흰 배경에서 가독성 확보
    Color chipColor = widget.character.accentColor;
    if (chipColor.computeLuminance() > 0.4) {
      final hsl = HSLColor.fromColor(chipColor);
      chipColor = hsl.withLightness((hsl.lightness * 0.65).clamp(0.25, 0.45)).toColor();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.character.specialties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final specialty = widget.character.specialties[index];
          final fortuneType = FortuneType.fromKey(specialty);
          final displayName = fortuneType?.displayName ?? specialty;

          return GestureDetector(
            onTap: chatState.isProcessing
                ? null
                : () => _handleFortuneChipTap(specialty, displayName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: chipColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: chipColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    displayName,
                    style: context.labelMedium.copyWith(
                      color: chipColor,
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
  void _handleFortuneChipTap(String fortuneType, String displayName) {
    HapticFeedback.lightImpact();

    // fortuneType을 FortuneSurveyType으로 매핑
    final surveyType = _mapFortuneTypeToSurveyType(fortuneType);
    final config = surveyType != null ? surveyConfigs[surveyType] : null;

    // 설문이 있고 단계가 있으면 설문 시작
    if (surveyType != null && config != null && config.steps.isNotEmpty) {
      // 캐릭터 메시지로 설문 시작 안내
      final chatNotifier = ref.read(characterChatProvider(widget.character.id).notifier);
      chatNotifier.addCharacterMessage(
        context.l10n.fortuneIntroMessage(displayName),
      );

      // 설문 시작
      ref.read(characterChatSurveyProvider(widget.character.id).notifier)
          .startSurvey(surveyType, fortuneTypeStr: fortuneType);

      // 첫 질문을 캐릭터 메시지로 표시
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final surveyState = ref.read(characterChatSurveyProvider(widget.character.id));
        if (surveyState.isActive && surveyState.activeProgress != null) {
          final firstQuestion = surveyState.activeProgress!.currentStep.question;
          chatNotifier.addCharacterMessage(firstQuestion);
        }
        _scrollToBottom();
      });
    } else {
      // 설문 없이 바로 요청
      final requestMessage = context.l10n.tellMeAbout(displayName);
      ref.read(characterChatProvider(widget.character.id).notifier)
          .sendFortuneRequest(fortuneType, requestMessage);
    }
    _scrollToBottom();
  }

  /// fortuneType 문자열을 FortuneSurveyType으로 매핑
  FortuneSurveyType? _mapFortuneTypeToSurveyType(String fortuneType) {
    const mapping = {
      'daily': FortuneSurveyType.daily,
      'career': FortuneSurveyType.career,
      'love': FortuneSurveyType.love,
      'talent': FortuneSurveyType.talent,
      'tarot': FortuneSurveyType.tarot,
      'mbti': FortuneSurveyType.mbti,
      'newYear': FortuneSurveyType.newYear,
      'daily_calendar': FortuneSurveyType.dailyCalendar,
      'traditional': FortuneSurveyType.traditional,
      'faceReading': FortuneSurveyType.faceReading,
      'talisman': FortuneSurveyType.talisman,
      'personalityDna': FortuneSurveyType.personalityDna,
      'biorhythm': FortuneSurveyType.biorhythm,
      'compatibility': FortuneSurveyType.compatibility,
      'avoidPeople': FortuneSurveyType.avoidPeople,
      'exLover': FortuneSurveyType.exLover,
      'blindDate': FortuneSurveyType.blindDate,
      'money': FortuneSurveyType.money,
      'luckyItems': FortuneSurveyType.luckyItems,
      'lotto': FortuneSurveyType.lotto,
      'wish': FortuneSurveyType.wish,
      'fortuneCookie': FortuneSurveyType.fortuneCookie,
      'health': FortuneSurveyType.health,
      'exercise': FortuneSurveyType.exercise,
      'sportsGame': FortuneSurveyType.sportsGame,
      'dream': FortuneSurveyType.dream,
      'celebrity': FortuneSurveyType.celebrity,
      'pastLife': FortuneSurveyType.pastLife,
      'gameEnhance': FortuneSurveyType.gameEnhance,
      'pet': FortuneSurveyType.pet,
      'family': FortuneSurveyType.family,
      'naming': FortuneSurveyType.naming,
      'babyNickname': FortuneSurveyType.babyNickname,
      'ootdEvaluation': FortuneSurveyType.ootdEvaluation,
      'exam': FortuneSurveyType.exam,
      'moving': FortuneSurveyType.moving,
      'gratitude': FortuneSurveyType.gratitude,
      'yearlyEncounter': FortuneSurveyType.yearlyEncounter,
    };
    return mapping[fortuneType];
  }

  /// 설문 답변 처리
  void _handleSurveyAnswer(dynamic answer) {
    final surveyNotifier = ref.read(characterChatSurveyProvider(widget.character.id).notifier);
    final chatNotifier = ref.read(characterChatProvider(widget.character.id).notifier);

    // 답변을 사용자 메시지로 표시
    String answerText;
    if (answer is List) {
      answerText = answer.join(', ');
    } else if (answer is Map) {
      answerText = answer.values.join(', ');
    } else {
      answerText = answer.toString();
    }
    chatNotifier.addUserMessage(answerText);

    // 답변 처리
    surveyNotifier.answerCurrentStep(answer);

    // 다음 단계 확인
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final surveyState = ref.read(characterChatSurveyProvider(widget.character.id));

      if (surveyState.isCompleted) {
        // 설문 완료 - 운세 요청
        _handleSurveyComplete(surveyState);
      } else if (surveyState.isActive && surveyState.activeProgress != null) {
        // 다음 질문
        final nextQuestion = surveyState.activeProgress!.currentStep.question;
        chatNotifier.addCharacterMessage(nextQuestion);
        _scrollToBottom();
      }
    });
  }

  /// 설문 완료 처리
  void _handleSurveyComplete(CharacterChatSurveyState surveyState) {
    final chatNotifier = ref.read(characterChatProvider(widget.character.id).notifier);
    final surveyNotifier = ref.read(characterChatSurveyProvider(widget.character.id).notifier);

    // 완료 메시지
    chatNotifier.addCharacterMessage(context.l10n.analyzingMessage);

    // 설문 데이터로 운세 요청
    final fortuneType = surveyState.fortuneTypeString ?? 'daily';
    final answers = surveyState.completedData ?? {};

    // 설문 초기화
    surveyNotifier.clearCompleted();

    // 운세 요청 (설문 답변 포함)
    final displayName = FortuneType.fromKey(fortuneType)?.displayName ?? fortuneType;
    final requestMessage = context.l10n.showResults(displayName);

    ref.read(characterChatProvider(widget.character.id).notifier)
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
                final defaultChoice = message.choiceSet!
                    .choices[message.choiceSet!.defaultChoiceIndex!];
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: widget.character.accentColor,
            backgroundImage: widget.character.avatarAsset.isNotEmpty
                ? AssetImage(widget.character.avatarAsset)
                : null,
            child: widget.character.avatarAsset.isEmpty
                ? Text(
                    widget.character.initial,
                    style: context.labelMedium.copyWith(
                      color: Colors.white,
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
    final surveyNotifier = ref.read(characterChatSurveyProvider(widget.character.id).notifier);
    final options = surveyNotifier.getCurrentStepOptions();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
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
                    valueColor: AlwaysStoppedAnimation(widget.character.accentColor),
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
                      style: context.labelSmall.copyWith(color: Colors.grey[500]),
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
          onSelect: (option) => _handleSurveyAnswer(option.id),
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

      default:
        // 기타 복잡한 입력은 chips로 대체하거나 스킵
        if (options.isNotEmpty) {
          return ChatSurveyChips(
            options: options,
            onSelect: (option) => _handleSurveyAnswer(option.id),
          );
        }
        return _buildTextInput(step);
    }
  }

  /// 다중 선택 칩 위젯
  Widget _buildMultiSelectChips(List<SurveyOption> options) {
    final selectedIds = <String>{};

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
                onPressed: () => _handleSurveyAnswer(selectedIds.toList()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.character.accentColor,
                  foregroundColor: Colors.white,
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

  /// 텍스트 입력 위젯
  Widget _buildTextInput(SurveyStep step) {
    final textController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: context.l10n.pleaseEnter,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (text) {
              if (text.isNotEmpty) {
                _handleSurveyAnswer(text);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              _handleSurveyAnswer(textController.text);
            }
          },
          icon: Icon(Icons.send, color: widget.character.accentColor),
        ),
        if (step.inputType == SurveyInputType.textWithSkip)
          TextButton(
            onPressed: () {
              ref.read(characterChatSurveyProvider(widget.character.id).notifier)
                  .skipCurrentStep();
              _checkSurveyCompletion();
            },
            child: Text(context.l10n.none),
          ),
      ],
    );
  }

  /// 설문 완료 여부 확인 (스킵 후)
  void _checkSurveyCompletion() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final surveyState = ref.read(characterChatSurveyProvider(widget.character.id));
      final chatNotifier = ref.read(characterChatProvider(widget.character.id).notifier);

      if (surveyState.isCompleted) {
        _handleSurveyComplete(surveyState);
      } else if (surveyState.isActive && surveyState.activeProgress != null) {
        // 다음 질문 표시
        final nextQuestion = surveyState.activeProgress!.currentStep.question;
        chatNotifier.addCharacterMessage(nextQuestion);
        _scrollToBottom();
      }
    });
  }

  Widget _buildInputArea(dynamic chatState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: UnifiedVoiceTextField(
        controller: _textController,
        hintText: context.l10n.enterMessage,
        enabled: true,  // 연속 메시지 전송 허용 (카카오톡처럼)
        onSubmit: (text) {
          if (text.isNotEmpty) {
            ref.read(characterChatProvider(widget.character.id).notifier).sendMessage(text);
            _scrollToBottom();
          }
        },
      ),
    );
  }
}

