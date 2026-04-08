import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/fortune/fortune_type_registry.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/navigation/fortune_chat_route.dart';
import 'package:ondo/core/utils/haptic_utils.dart';
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
import '../utils/chat_catalog_preview.dart';
import '../utils/character_chat_surface_style.dart';
import '../widgets/character_message_bubble.dart';
import '../widgets/character_choice_widget.dart';
import '../widgets/wave_typing_indicator.dart';
import '../widgets/pet_profile_create_sheet.dart';
import '../widgets/secondary_profile_create_sheet.dart';
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
import '../../../chat/presentation/widgets/survey/chat_tarot_deck_picker.dart';
import '../../../chat/presentation/widgets/survey/chat_tarot_draw_widget.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/services/unified_calendar_service.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../data/models/secondary_profile.dart';
import '../../../../presentation/providers/pet_profiles_provider.dart';
import '../../../../presentation/providers/secondary_profiles_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../services/storage_service.dart';
import '../../data/services/active_character_chat_registry.dart';
import '../utils/character_chat_theme.dart';
import '../utils/character_chat_preflight_guard.dart';
import '../utils/chat_survey_profile_utils.dart';
import '../utils/pending_chat_auth_intent.dart';

/// 1:1 캐릭터 롤플레이 채팅 패널
class CharacterChatPanel extends ConsumerStatefulWidget {
  final AiCharacter character;
  final VoidCallback? onBack;
  final String? initialFortuneType;
  final bool autoStartFortune;
  final String? entrySource;
  final ChatCatalogPreview? catalogPreview;
  final bool debugSkipRegistrationAuthGate;

  const CharacterChatPanel({
    super.key,
    required this.character,
    this.onBack,
    this.initialFortuneType,
    this.autoStartFortune = false,
    this.entrySource,
    this.catalogPreview,
    this.debugSkipRegistrationAuthGate = false,
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
  final StorageService _storageService = StorageService();
  final Map<String, GlobalKey> _messageAnchorKeys = {};
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _isAuthenticated = false;
  bool _isShowingAuthSheet = false;
  bool _isReplayingPendingAuthIntent = false;

  static const Duration _sessionStartAnchorHoldDuration = Duration(
    milliseconds: 1400,
  );
  static const Duration _archivedHistoryRevealDuration = Duration(
    milliseconds: 650,
  );

  /// Notifier 참조 캐시 (dispose 후 ref 사용 불가 문제 해결)
  CharacterChatNotifier? _cachedNotifier;
  bool _didRedirectToProfile = false;
  String? _consumedAutoStartSignature;
  String? _sessionStartAnchorMessageId;
  Timer? _sessionStartAnchorReleaseTimer;
  bool _isSessionStartAutoScrollPausedByUser = false;
  bool _isArchivedHistoryVisible = false;
  bool _isArchivedHistoryLoading = false;
  bool _isPetProfileManagementMode = false;
  String? _petProfileDeletingId;
  bool _isFortuneChipBarExpanded = false;
  bool _isComposerRecording = false;
  String? _activeThemeFortuneType;
  PendingChatImagePickerTarget? _pendingSurveyImageTarget;
  ImageSource? _pendingSurveyImageSource;

  /// 통합 스크롤 서비스 (ChatScrollService 사용)
  late final ChatScrollService _scrollService;

  CharacterAccentPalette _accentPalette(BuildContext context) {
    return CharacterAccentPalette.from(
      source: widget.character.accentColor,
      brightness: Theme.of(context).brightness,
    );
  }

  bool get _isHaneulPremiumShell => widget.character.id == haneulCharacter.id;

  String? _activeFortuneType() {
    return _activeThemeFortuneType ?? _entryThemeFortuneTypeFor(widget);
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
        '[Survey] mbtiConfirm - name: $name, mbtiType: $mbtiType, hasValue: ${profileAsync.hasValue}',
      );

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
    _activeThemeFortuneType = _entryThemeFortuneTypeFor(widget);
    _initializeAuthStateListener();
    WidgetsBinding.instance.addObserver(this);
    _scrollService = ChatScrollService(
      scrollController: _scrollController,
      isMounted: () => mounted,
    );
    // 기존 대화 불러오기 + 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.catalogPreview != null) return;

      // 🆕 현재 채팅방 진입 표시 (푸시 알림 억제용)
      ActiveCharacterChatRegistry.setActiveCharacterId(widget.character.id);
      ref.read(activeCharacterChatProvider.notifier).state =
          widget.character.id;

      _cachedNotifier = ref.read(
        characterChatProvider(widget.character.id).notifier,
      );
      await _cachedNotifier?.initConversation();
      _cachedNotifier?.clearUnreadCount(); // 채팅방 진입 시 읽음 처리
      // 채팅방 진입 시 맨 아래로 스크롤
      _scrollToBottomInstant();
      await _maybeStartInitialFortuneFlow();
      await _resumePendingAuthIntentIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant CharacterChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousEntryTheme = _entryThemeFortuneTypeFor(oldWidget);
    final nextEntryTheme = _entryThemeFortuneTypeFor(widget);

    if (oldWidget.character.id != widget.character.id ||
        widget.character.specialties.length <= 3) {
      _isFortuneChipBarExpanded = false;
      _activeThemeFortuneType = nextEntryTheme;
    } else if (previousEntryTheme != nextEntryTheme &&
        _activeThemeFortuneType == previousEntryTheme) {
      _activeThemeFortuneType = nextEntryTheme;
    }

    if (widget.catalogPreview != null) {
      return;
    }

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
    if (widget.catalogPreview != null) {
      super.deactivate();
      return;
    }

    // 🆕 채팅방 이탈 표시 (푸시 알림 활성화)
    // Future.microtask로 지연하여 위젯 라이프사이클 충돌 방지
    final notifier = ref.read(activeCharacterChatProvider.notifier);
    Future.microtask(() {
      if (notifier.state == widget.character.id) {
        notifier.state = null;
      }
      if (ActiveCharacterChatRegistry.activeCharacterId ==
          widget.character.id) {
        ActiveCharacterChatRegistry.setActiveCharacterId(null);
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // 화면 이탈 시 저장 (캐시된 notifier 사용 - ref 사용 불가)
    if (widget.catalogPreview == null) {
      if (ActiveCharacterChatRegistry.activeCharacterId ==
          widget.character.id) {
        ActiveCharacterChatRegistry.setActiveCharacterId(null);
      }
      _cachedNotifier?.saveOnExit();
    }
    _textController.dispose();
    _surveyTextController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _scrollService.dispose();
    _sessionStartAnchorReleaseTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.catalogPreview != null) {
      return;
    }

    // 앱이 백그라운드로 갈 때 저장
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveConversation();
    }
  }

  Future<void> _saveConversation() async {
    if (widget.catalogPreview != null) {
      return;
    }

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
    if (_hasActiveSessionStartAnchor) {
      _scrollToSessionStartAnchor();
      return;
    }
    if (_isSessionStartAutoScrollPausedByUser) {
      return;
    }
    _scrollService.scrollToBottom();
  }

  /// 채팅방 진입 시 즉시 맨 아래로 스크롤 (애니메이션 없이)
  void _scrollToBottomInstant() {
    _scrollService.scrollToBottomInstant();
  }

  bool get _hasActiveSessionStartAnchor => _sessionStartAnchorMessageId != null;

  GlobalKey _messageAnchorKeyFor(String messageId) {
    return _messageAnchorKeys.putIfAbsent(
      messageId,
      () => GlobalKey(debugLabel: 'chat-anchor-$messageId'),
    );
  }

  void _beginSessionStartAnchor(String messageId) {
    _sessionStartAnchorReleaseTimer?.cancel();
    _isSessionStartAutoScrollPausedByUser = false;
    _sessionStartAnchorMessageId = messageId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sessionStartAnchorMessageId != messageId) {
        return;
      }
      _scrollToSessionStartAnchor();
    });

    _sessionStartAnchorReleaseTimer = Timer(
      _sessionStartAnchorHoldDuration,
      _clearSessionStartAnchor,
    );
  }

  void _clearSessionStartAnchor() {
    _sessionStartAnchorReleaseTimer?.cancel();
    _sessionStartAnchorReleaseTimer = null;
    _sessionStartAnchorMessageId = null;
    _isSessionStartAutoScrollPausedByUser = false;
  }

  void _pauseSessionStartAutoScrollForUserScroll() {
    _scrollService.cancelPendingScroll();
    _sessionStartAnchorReleaseTimer?.cancel();
    _sessionStartAnchorMessageId = null;
    _isSessionStartAutoScrollPausedByUser = true;
    _sessionStartAnchorReleaseTimer = Timer(
      _sessionStartAnchorHoldDuration,
      () {
        _sessionStartAnchorReleaseTimer = null;
        _isSessionStartAutoScrollPausedByUser = false;
      },
    );
  }

  bool _isUserDrivenScroll(ScrollNotification notification) {
    return notification is ScrollStartNotification &&
            notification.dragDetails != null ||
        notification is ScrollUpdateNotification &&
            notification.dragDetails != null ||
        notification is OverscrollNotification &&
            notification.dragDetails != null;
  }

  List<CharacterChatMessage> _messagesForDisplay(CharacterChatState chatState) {
    if (!_isArchivedHistoryVisible || chatState.archivedMessages.isEmpty) {
      return chatState.messages;
    }
    return [...chatState.archivedMessages, ...chatState.messages];
  }

  Future<void> _revealArchivedHistory() async {
    if (_isArchivedHistoryLoading || _isArchivedHistoryVisible) {
      return;
    }

    setState(() {
      _isArchivedHistoryLoading = true;
    });

    await Future<void>.delayed(_archivedHistoryRevealDuration);
    if (!mounted) return;

    setState(() {
      _isArchivedHistoryLoading = false;
      _isArchivedHistoryVisible = true;
    });
  }

  ScrollPhysics _chatScrollPhysics() {
    // Chat timelines need to stay anchored at the latest message instead of
    // rebounding upward at the lower edge.
    return const AlwaysScrollableScrollPhysics(
      parent: ClampingScrollPhysics(),
    );
  }

  Future<void> _handleArchivedHistoryRefresh(
    CharacterChatState chatState,
  ) async {
    if (chatState.archivedMessages.isEmpty || _isArchivedHistoryVisible) {
      return;
    }

    _pauseSessionStartAutoScrollForUserScroll();
    await _scrollService.preserveViewportAfterPrepend(_revealArchivedHistory);
  }

  bool _handleChatScrollNotification(
    ScrollNotification notification,
    CharacterChatState chatState,
  ) {
    if (notification.depth != 0) {
      return false;
    }

    final isUserDrivenScroll = _isUserDrivenScroll(notification);

    if (_hasActiveSessionStartAnchor && isUserDrivenScroll) {
      _pauseSessionStartAutoScrollForUserScroll();
    }

    return false;
  }

  void _scrollToSessionStartAnchor() {
    final anchorId = _sessionStartAnchorMessageId;
    if (anchorId == null) return;

    final anchorContext = _messageAnchorKeys[anchorId]?.currentContext;
    if (anchorContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _sessionStartAnchorMessageId != anchorId) {
          return;
        }

        final retryContext = _messageAnchorKeys[anchorId]?.currentContext;
        if (retryContext != null) {
          _scrollService.scrollToMessageTop(messageContext: retryContext);
        }
      });
      return;
    }

    _scrollService.scrollToMessageTop(messageContext: anchorContext);
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
    _setActiveThemeFortuneType(fortuneType);
    await _startFortuneFlow(
      fortuneType,
      _getSpecialtyLabel(context, fortuneType),
      triggerHaptic: false,
      resetSurvey: true,
    );
  }

  String? _entryThemeFortuneTypeFor(CharacterChatPanel panel) {
    final rawType =
        panel.catalogPreview?.fortuneType ?? panel.initialFortuneType;
    if (rawType == null || rawType.isEmpty) {
      return null;
    }

    if (!panel.character.isFortuneExpert ||
        !panel.character.specialties.contains(rawType)) {
      return null;
    }

    return rawType;
  }

  void _setActiveThemeFortuneType(String? fortuneType) {
    final normalizedType = fortuneType != null &&
            fortuneType.isNotEmpty &&
            widget.character.specialties.contains(fortuneType)
        ? fortuneType
        : null;

    if (_activeThemeFortuneType == normalizedType || !mounted) {
      _activeThemeFortuneType = normalizedType;
      return;
    }

    setState(() {
      _activeThemeFortuneType = normalizedType;
    });
  }

  bool _hasAuthenticatedSession() {
    if (_isAuthenticated) {
      return true;
    }

    try {
      final auth = Supabase.instance.client.auth;
      return auth.currentSession?.user != null || auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  void _initializeAuthStateListener() {
    try {
      final auth = Supabase.instance.client.auth;
      _isAuthenticated =
          auth.currentSession?.user != null || auth.currentUser != null;
      _authStateSubscription = auth.onAuthStateChange.listen((authState) {
        final wasAuthenticated = _isAuthenticated;
        final nextAuthenticated =
            authState.session?.user != null || auth.currentUser != null;
        if (!mounted || _isAuthenticated == nextAuthenticated) {
          _isAuthenticated = nextAuthenticated;
          return;
        }

        setState(() {
          _isAuthenticated = nextAuthenticated;
        });

        if (!wasAuthenticated && nextAuthenticated) {
          unawaited(_resumePendingAuthIntentIfNeeded());
        }
      });
    } catch (_) {
      _isAuthenticated = false;
    }
  }

  Future<void> _presentAuthenticationSheet() async {
    if (!mounted || _isShowingAuthSheet) {
      return;
    }

    _isShowingAuthSheet = true;
    try {
      await CharacterChatPreflightGuard.promptAuthentication(
        context,
        ref,
        onAuthenticated: () {
          unawaited(_resumePendingAuthIntentIfNeeded());
        },
      );
    } finally {
      _isShowingAuthSheet = false;
    }
  }

  Future<bool> _ensureAuthenticatedForIntent(
    PendingChatAuthIntent intent,
  ) async {
    if (widget.debugSkipRegistrationAuthGate || widget.catalogPreview != null) {
      return true;
    }

    if (_hasAuthenticatedSession()) {
      return true;
    }

    await _storageService.savePendingChatAuthIntent(intent.toJson());
    if (_isShowingAuthSheet) {
      return false;
    }

    await _presentAuthenticationSheet();
    return false;
  }

  Future<bool> _ensureAuthenticatedForProfileRegistration() async {
    if (widget.debugSkipRegistrationAuthGate) {
      return true;
    }

    if (_hasAuthenticatedSession()) {
      return true;
    }

    if (_isShowingAuthSheet) {
      return true;
    }

    await _presentAuthenticationSheet();
    return false;
  }

  Future<bool> _ensureChatActionReady({
    required String actionLabel,
    required int requiredTokens,
    PendingChatAuthIntent? pendingIntent,
    required String trigger,
  }) async {
    if (widget.debugSkipRegistrationAuthGate || widget.catalogPreview != null) {
      return true;
    }

    if (!_hasAuthenticatedSession() && _isShowingAuthSheet) {
      if (pendingIntent != null) {
        await _storageService.savePendingChatAuthIntent(pendingIntent.toJson());
      }
      return false;
    }

    return CharacterChatPreflightGuard.ensureReady(
      context,
      ref,
      actionLabel: actionLabel,
      requiredTokens: requiredTokens,
      pendingIntent: pendingIntent,
      trigger: trigger,
      onAuthenticated: () {
        unawaited(_resumePendingAuthIntentIfNeeded());
      },
    );
  }

  Future<void> _resumePendingAuthIntentIfNeeded() async {
    if (!mounted ||
        !_hasAuthenticatedSession() ||
        _isReplayingPendingAuthIntent) {
      return;
    }

    final rawIntent = await _storageService.getPendingChatAuthIntent();
    if (rawIntent == null) {
      return;
    }

    final pendingIntent = PendingChatAuthIntent.fromJson(rawIntent);
    if (pendingIntent.isExpired || pendingIntent.characterId.isEmpty) {
      await _storageService.clearPendingChatAuthIntent();
      return;
    }

    if (pendingIntent.characterId != widget.character.id) {
      return;
    }

    _isReplayingPendingAuthIntent = true;
    try {
      switch (pendingIntent.type) {
        case PendingChatAuthIntentType.textMessage:
          await _storageService.clearPendingChatAuthIntent();
          await _sendTextMessage(pendingIntent.text ?? '');
          break;
        case PendingChatAuthIntentType.choiceSelection:
          await _storageService.clearPendingChatAuthIntent();
          final choice = pendingIntent.choice;
          if (choice != null) {
            await _submitChoiceSelection(choice);
          }
          break;
        case PendingChatAuthIntentType.fortuneRequest:
          final fortuneType = pendingIntent.fortuneType;
          await _storageService.clearPendingChatAuthIntent();
          if (fortuneType != null && fortuneType.isNotEmpty) {
            if (!mounted) {
              break;
            }
            await _startFortuneFlow(
              fortuneType,
              _getSpecialtyLabel(context, fortuneType),
              triggerHaptic: false,
              resetSurvey: true,
            );
          }
          break;
        case PendingChatAuthIntentType.surveySubmission:
          final fortuneType = pendingIntent.fortuneType;
          final answers = pendingIntent.surveyAnswers;
          await _storageService.clearPendingChatAuthIntent();
          if (fortuneType != null &&
              fortuneType.isNotEmpty &&
              answers != null) {
            await _submitSurveyRequestWithPreflight(
              fortuneType: fortuneType,
              answers: answers,
            );
          }
          break;
        case PendingChatAuthIntentType.openImagePicker:
          final target = pendingIntent.imagePickerTarget;
          if (target == null) {
            await _storageService.clearPendingChatAuthIntent();
            break;
          }

          if (target == PendingChatImagePickerTarget.composerSheet) {
            await _storageService.clearPendingChatAuthIntent();
            if (!mounted) {
              break;
            }
            await _showImagePickerSheet();
            break;
          }

          if (!mounted) {
            break;
          }

          setState(() {
            _pendingSurveyImageTarget = target;
            _pendingSurveyImageSource = pendingIntent.imageSource;
          });
          break;
      }
    } finally {
      _isReplayingPendingAuthIntent = false;
    }
  }

  ImageSource? _pendingImageSourceFor(
    PendingChatImagePickerTarget target,
  ) {
    if (_pendingSurveyImageTarget != target) {
      return null;
    }
    return _pendingSurveyImageSource;
  }

  Future<void> _clearPendingSurveyImageIntent() async {
    if (mounted) {
      setState(() {
        _pendingSurveyImageTarget = null;
        _pendingSurveyImageSource = null;
      });
    } else {
      _pendingSurveyImageTarget = null;
      _pendingSurveyImageSource = null;
    }

    await _storageService.clearPendingChatAuthIntent();
  }

  Future<bool> _ensureAuthenticatedForSurveyImagePick(
    PendingChatImagePickerTarget target,
    ImageSource source,
  ) async {
    return _ensureAuthenticatedForIntent(
      PendingChatAuthIntent.openImagePicker(
        characterId: widget.character.id,
        fortuneType: _activeFortuneType(),
        target: target,
        imageSource: source,
      ),
    );
  }

  Future<void> _handleUnauthorizedError() async {
    if (widget.catalogPreview != null || _hasAuthenticatedSession()) {
      return;
    }

    await CharacterChatPreflightGuard.promptAuthentication(
      context,
      ref,
      onAuthenticated: () {
        unawaited(_resumePendingAuthIntentIfNeeded());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCatalogPreview = widget.catalogPreview != null;
    final usesChipThemes = widget.character.isFortuneExpert;
    final chatState = isCatalogPreview
        ? catalogPreviewChatState(
            preview: widget.catalogPreview!,
            character: widget.character,
          )
        : ref.watch(characterChatProvider(widget.character.id));
    final surveyState = isCatalogPreview
        ? catalogPreviewSurveyState(widget.catalogPreview!)
        : ref.watch(characterChatSurveyProvider(widget.character.id));

    if (!isCatalogPreview) {
      _redirectToProfileIfNoConversation(chatState);
    }

    // 🪙 토큰 부족 및 일반 에러 감지
    if (!isCatalogPreview) {
      ref.listen<CharacterChatState>(
        characterChatProvider(widget.character.id),
        (previous, next) {
          if (next.error != null && next.error != previous?.error) {
            if (next.error == 'UNAUTHORIZED') {
              unawaited(_handleUnauthorizedError());
              Future.delayed(const Duration(milliseconds: 100), () {
                ref
                    .read(characterChatProvider(widget.character.id).notifier)
                    .clearError();
              });
              return;
            }

            if (next.error == 'INSUFFICIENT_TOKENS') {
              unawaited(
                CharacterChatPreflightGuard.showInsufficientTokensDialog(
                  context,
                  ref,
                  actionLabel: '이 작업을 진행하려면',
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.errorOccurredRetry),
                  backgroundColor: context.colors.error,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: context.l10n.confirm,
                    textColor: context.colors.ctaForeground,
                    onPressed: () {},
                  ),
                ),
              );
            }

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
          if (_hasActiveSessionStartAnchor &&
              (nextCount != prevCount || typingStarted)) {
            _scrollToSessionStartAnchor();
            return;
          }
          if (_isSessionStartAutoScrollPausedByUser &&
              (nextCount != prevCount || typingStarted)) {
            return;
          }
          if (nextCount > prevCount || typingStarted) {
            _scrollToBottom();
          }
        },
      );
    }

    final themeSpec = usesChipThemes
        ? resolveCharacterChatTheme(
            brightness: Theme.of(context).brightness,
            character: widget.character,
            fortuneType: _activeFortuneType(),
          )
        : null;

    final content = Column(
      children: [
        _buildHeader(context, usesThemedChrome: usesChipThemes),
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
        if (!surveyState.isActive &&
            widget.character.isFortuneExpert &&
            widget.character.specialties.isNotEmpty)
          _buildFortuneChipBar(chatState),
        if (surveyState.isActive) _buildSurveyInput(surveyState),
        if (chatState.hasConversation && !surveyState.isActive)
          _buildInputArea(),
      ],
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // 뒤로가기 시 저장
          await _saveConversation();
        }
      },
      child: usesChipThemes && themeSpec != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      key: const ValueKey('character-chat-theme-switcher'),
                      duration: DSAnimation.normal,
                      switchInCurve: DSAnimation.emphasized,
                      switchOutCurve: DSAnimation.primary,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _buildChatThemeBackground(themeSpec),
                    ),
                  ),
                ),
                SafeArea(child: content),
              ],
            )
          : Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(child: content),
            ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    bool usesThemedChrome = false,
  }) {
    final accentPalette = _accentPalette(context);
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: usesThemedChrome
            ? colors.surface.withValues(
                alpha: context.isDark ? 0.92 : 0.95,
              )
            : colors.background,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onBack?.call();
            },
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: () => _showCharacterProfile(context),
              behavior: HitTestBehavior.opaque,
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
                            style: context.labelSmall.copyWith(
                              color: accentPalette.onAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.character.name,
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildChatThemeBackground(CharacterChatThemeSpec themeSpec) {
    final colors = context.colors;

    return KeyedSubtree(
      key: ValueKey('character-chat-theme-${themeSpec.themeKey}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: themeSpec.gradientBegin,
                end: themeSpec.gradientEnd,
                colors: themeSpec.gradientColors,
              ),
            ),
          ),
          if (themeSpec.textureAsset != null)
            Opacity(
              opacity: themeSpec.textureOpacity,
              child: Image.asset(
                themeSpec.textureAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.expand(),
              ),
            ),
          if (themeSpec.backgroundAsset != null)
            Opacity(
              opacity: themeSpec.imageOpacity,
              child: Image.asset(
                themeSpec.backgroundAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.expand(),
              ),
            ),
          if (themeSpec.accentTint != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: themeSpec.accentTint,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color:
                  colors.background.withValues(alpha: themeSpec.scrimOpacity),
            ),
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
    if (widget.catalogPreview != null) {
      return;
    }

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
      context.push(
        '/character/${widget.character.id}',
        extra: widget.character,
      );
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
  Widget _buildFortuneChipBar(CharacterChatState chatState) {
    final colors = context.colors;
    final isHaneulChipBar = _isHaneulPremiumShell;
    final activeFortuneType = _activeFortuneType();
    final shouldShowAccordionToggle = widget.character.specialties.length > 3;
    final collapsedHeight = 32.0;
    final chipWidgets = widget.character.specialties.map((specialty) {
      final displayName = _getSpecialtyLabel(context, specialty);
      final surveyType = _mapFortuneTypeToSurveyType(specialty);
      final chipEmoji =
          surveyType != null ? (surveyConfigs[surveyType]?.emoji ?? '✨') : '✨';

      return _buildFortuneChip(
        chatState: chatState,
        specialty: specialty,
        displayName: displayName,
        chipEmoji: chipEmoji,
        isSelected: specialty == activeFortuneType,
      );
    }).toList();

    return AnimatedSize(
      duration: DSAnimation.normal,
      curve: DSAnimation.emphasized,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          DSSpacing.xs,
          16,
          DSSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: DSAnimation.normal,
              switchInCurve: DSAnimation.emphasized,
              switchOutCurve: DSAnimation.primary,
              child: _isFortuneChipBarExpanded
                  ? Container(
                      key: const ValueKey('expanded-fortune-chip-bar'),
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: DSSpacing.sm,
                        runSpacing: DSSpacing.sm,
                        children: chipWidgets,
                      ),
                    )
                  : SizedBox(
                      key: const ValueKey('collapsed-fortune-chip-bar'),
                      height: collapsedHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: chipWidgets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: DSSpacing.sm),
                        itemBuilder: (context, index) {
                          final child = chipWidgets[index];
                          return isHaneulChipBar ? Center(child: child) : child;
                        },
                      ),
                    ),
            ),
            if (shouldShowAccordionToggle) ...[
              Align(
                alignment: Alignment.center,
                child: Semantics(
                  button: true,
                  label: _isFortuneChipBarExpanded
                      ? context.l10n.close
                      : context.l10n.chipViewMore,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      onTap: _toggleFortuneChipBarExpanded,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.md,
                          vertical: 2,
                        ),
                        child: Icon(
                          _isFortuneChipBarExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneChip({
    required CharacterChatState chatState,
    required String specialty,
    required String displayName,
    required String chipEmoji,
    required bool isSelected,
  }) {
    final colors = context.colors;
    final onTap = chatState.isProcessing
        ? null
        : () => _handleFortuneChipTap(specialty, displayName);

    if (_isHaneulPremiumShell) {
      return DSChip(
        label: '$chipEmoji $displayName',
        selected: isSelected,
        style: DSChipStyle.outlined,
        enableHaptic: false,
        onTap: onTap,
      );
    }

    final backgroundColor =
        isSelected ? colors.selectionBackground : colors.surface;
    final foregroundColor =
        isSelected ? colors.selectionForeground : colors.textPrimary;
    final borderColor = isSelected ? colors.selectionBorder : colors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.full),
        child: AnimatedContainer(
          duration: DSAnimation.quick,
          curve: DSAnimation.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(context.radius.full),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chipEmoji,
                style: context.labelMedium.copyWith(
                  color: foregroundColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                displayName,
                style: context.labelMedium.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFortuneChipBarExpanded() {
    final nextExpanded = !_isFortuneChipBarExpanded;
    setState(() {
      _isFortuneChipBarExpanded = nextExpanded;
    });

    final haptic = ref.read(fortuneHapticServiceProvider);
    if (nextExpanded) {
      unawaited(haptic.sectionComplete());
    } else {
      unawaited(haptic.buttonTap());
    }
  }

  /// 운세 칩 탭 핸들러 - 설문이 있으면 설문 시작, 없으면 바로 요청
  Future<void> _handleFortuneChipTap(
    String fortuneType,
    String displayName,
  ) async {
    if (mounted) {
      setState(() {
        _activeThemeFortuneType = fortuneType;
        _isFortuneChipBarExpanded = false;
      });
    } else {
      _activeThemeFortuneType = fortuneType;
    }
    await _startFortuneFlow(fortuneType, displayName, resetSurvey: true);
  }

  Future<void> _sendTextMessage(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return;
    }

    final ready = await _ensureChatActionReady(
      actionLabel: '메시지를 보내려면',
      requiredTokens: CharacterChatPreflightGuard.characterChatTokenCost(),
      pendingIntent: PendingChatAuthIntent.textMessage(
        characterId: widget.character.id,
        text: normalized,
      ),
      trigger: 'text-message',
    );
    if (!ready) {
      return;
    }

    final notifier = ref.read(
      characterChatProvider(widget.character.id).notifier,
    );
    final anchorMessageId = notifier.startFreshUserSessionIfNeeded(normalized);
    if (anchorMessageId != null) {
      _beginSessionStartAnchor(anchorMessageId);
    }
    notifier.sendMessage(
      normalized,
      userMessageAlreadyAdded: anchorMessageId != null,
    );
    if (anchorMessageId == null) {
      _clearSessionStartAnchor();
      _scrollToBottom();
    }
  }

  Future<void> _submitChoiceSelection(CharacterChoice choice) async {
    final ready = await _ensureChatActionReady(
      actionLabel: '답장을 보내려면',
      requiredTokens: CharacterChatPreflightGuard.characterChatTokenCost(),
      pendingIntent: PendingChatAuthIntent.choiceSelection(
        characterId: widget.character.id,
        choice: choice,
      ),
      trigger: 'choice-selection',
    );
    if (!ready) {
      return;
    }

    _clearSessionStartAnchor();
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .handleChoiceSelection(choice);
    _scrollToBottom();
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

    final launchAllowed = await _ensureChatActionReady(
      actionLabel: '운세를 보려면',
      requiredTokens: CharacterChatPreflightGuard.fortuneLaunchTokenCost(
        fortuneType,
      ),
      pendingIntent: PendingChatAuthIntent.fortuneRequest(
        characterId: widget.character.id,
        fortuneType: fortuneType,
      ),
      trigger: 'fortune-start.$fortuneType',
    );
    if (!launchAllowed) {
      return;
    }

    if (resetSurvey) {
      ref
          .read(characterChatSurveyProvider(widget.character.id).notifier)
          .cancelSurvey();
    }

    final chatNotifier = ref.read(
      characterChatProvider(widget.character.id).notifier,
    );
    final useCardFirstFlow = isHaneulCardFirstFortuneFlow(
      characterId: widget.character.id,
      fortuneType: fortuneType,
    );
    final introMessage = useCardFirstFlow
        ? _haneulSessionIntroMessage(fortuneType)
        : context.l10n.fortuneIntroMessage(displayName);
    final requestMessage = useCardFirstFlow
        ? _haneulSessionRequestMessage(fortuneType)
        : context.l10n.tellMeAbout(displayName);

    final surveyType = _mapFortuneTypeToSurveyType(fortuneType);
    final config = surveyType != null ? surveyConfigs[surveyType] : null;
    final hasSurvey =
        surveyType != null && config != null && config.steps.isNotEmpty;

    chatNotifier.startFreshFortuneSession(
      introMessage: introMessage,
      requestMessage: requestMessage,
    );
    if (mounted) {
      setState(() {
        _isArchivedHistoryLoading = false;
        _isArchivedHistoryVisible = false;
      });
    }
    // 운세 칩 플로우에서는 세션 앵커를 사용하지 않고 즉시 맨 아래로 스크롤합니다.
    // 앵커를 사용하면 메시지 수가 적을 때 오버스크롤이 발생하여 RefreshIndicator가
    // 트리거되고 archived 메시지가 노출되는 Bug #4가 발생합니다.
    _clearSessionStartAnchor();
    _scrollToBottomInstant();

    // 설문이 있고 단계가 있으면 설문 시작
    if (hasSurvey) {
      final surveyNotifier = ref.read(
        characterChatSurveyProvider(widget.character.id).notifier,
      );
      var talismanCatalogAvailable = true;
      if (surveyType == FortuneSurveyType.talisman) {
        talismanCatalogAvailable = await _hasActiveTalismanCatalogAssets();
      }

      // 설문 시작
      surveyNotifier.startSurvey(
        surveyType,
        fortuneTypeStr: fortuneType,
        talismanCatalogAvailable: talismanCatalogAvailable,
      );

      // 첫 질문을 캐릭터 메시지로 표시
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final surveyState = ref.read(
          characterChatSurveyProvider(widget.character.id),
        );
        if (surveyState.isActive && surveyState.activeProgress != null) {
          final firstQuestion = _getDynamicStepQuestion(
            surveyState.activeProgress!.currentStep,
          );
          chatNotifier.addCharacterMessage(firstQuestion);
        }
        _scrollToBottomInstant();
      });
    } else {
      // 설문 없이 바로 요청
      // 🆕 사주 타입이면 비주얼 카드로 사주 결과 즉시 보여줌
      if (fortuneType == 'traditional-saju') {
        final sajuData = await chatNotifier.getSajuRawData();
        if (!mounted) return;
        if (sajuData != null && sajuData.isNotEmpty) {
          chatNotifier.addSajuResultMessage(sajuData);
          _scrollToBottom();
        }
      }

      if (!mounted) return;
      ref
          .read(characterChatProvider(widget.character.id).notifier)
          .sendFortuneRequest(
            fortuneType,
            requestMessage,
            userMessageAlreadyAdded: true,
            skipIntroMessage: useCardFirstFlow,
          );
    }
  }

  Future<bool> _hasActiveTalismanCatalogAssets() async {
    try {
      final data = await Supabase.instance.client
          .from('talisman_catalog_assets')
          .select('id')
          .eq('is_active', true)
          .limit(1);
      return data.isNotEmpty;
    } catch (error) {
      debugPrint(
        '[TalismanCatalog] failed to check active catalog assets: $error',
      );
      return false;
    }
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
    _handleSurveyAnswer({'imagePath': image.path, 'displayText': displayText});
  }

  void _handleSurveyAnswer(dynamic answer) {
    _clearSessionStartAnchor();
    final surveyNotifier = ref.read(
      characterChatSurveyProvider(widget.character.id).notifier,
    );
    final chatNotifier = ref.read(
      characterChatProvider(widget.character.id).notifier,
    );

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
      final surveyState = ref.read(
        characterChatSurveyProvider(widget.character.id),
      );

      if (surveyState.isCompleted) {
        // 설문 완료 - 운세 요청
        _handleSurveyComplete(surveyState);
      } else if (surveyState.isActive && surveyState.activeProgress != null) {
        // 다음 질문
        final nextQuestion = _getDynamicStepQuestion(
          surveyState.activeProgress!.currentStep,
        );
        chatNotifier.addCharacterMessage(nextQuestion);
        _scrollToBottom();
      }
    });
  }

  /// 관상 분석 플로우 완료 핸들러
  void _handleFaceReadingComplete(String imagePath) {
    _handleSurveyAnswer({'imagePath': imagePath});
  }

  /// 설문 완료 처리
  Future<void> _handleSurveyComplete(
    CharacterChatSurveyState surveyState,
  ) async {
    final fortuneType = surveyState.fortuneTypeString ?? 'daily';
    final answers = surveyState.completedData ?? {};
    await _submitSurveyRequestWithPreflight(
      fortuneType: fortuneType,
      answers: answers,
    );
  }

  Future<void> _submitSurveyRequestWithPreflight({
    required String fortuneType,
    required Map<String, dynamic> answers,
  }) async {
    final actionLabel =
        fortuneType == 'talisman' ? '부적을 만들려면' : '운세 결과를 보려면';
    final ready = await _ensureChatActionReady(
      actionLabel: actionLabel,
      requiredTokens: CharacterChatPreflightGuard.surveySubmissionTokenCost(
        fortuneType,
        answers,
      ),
      pendingIntent: PendingChatAuthIntent.surveySubmission(
        characterId: widget.character.id,
        fortuneType: fortuneType,
        surveyAnswers: answers,
      ),
      trigger: 'survey-submit.$fortuneType',
    );
    if (!ready) {
      ref
          .read(characterChatProvider(widget.character.id).notifier)
          .setProcessing(false);
      return;
    }

    await _submitSurveyRequestAfterAuth(
      fortuneType: fortuneType,
      answers: answers,
    );
  }

  Future<void> _submitSurveyRequestAfterAuth({
    required String fortuneType,
    required Map<String, dynamic> answers,
  }) async {
    final chatNotifier = ref.read(
      characterChatProvider(widget.character.id).notifier,
    );
    final surveyNotifier = ref.read(
      characterChatSurveyProvider(widget.character.id).notifier,
    );
    final useCardFirstFlow = isHaneulCardFirstFortuneFlow(
      characterId: widget.character.id,
      fortuneType: fortuneType,
    );

    if (!useCardFirstFlow) {
      chatNotifier.addCharacterMessage(context.l10n.analyzingMessage);
    }

    // 🆕 사주 타입이면 비주얼 카드로 사주 결과 즉시 보여줌
    debugPrint('[SajuCard] fortuneType=$fortuneType, checking saju...');
    if (fortuneType == 'traditional-saju') {
      final sajuData = await chatNotifier.getSajuRawData();
      debugPrint(
        '[SajuCard] sajuData=${sajuData != null ? 'loaded (${sajuData.keys.toList()})' : 'null'}',
      );
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
        .sendFortuneRequestWithAnswers(
          fortuneType,
          requestMessage,
          answers,
          userMessageAlreadyAdded: useCardFirstFlow,
          skipIntroMessage: useCardFirstFlow,
        );
    _scrollToBottom();
  }

  String _haneulSessionIntroMessage(String fortuneType) {
    switch (fortuneType) {
      case 'daily':
        return '좋아요. 오늘 흐름만 빠르게 볼게요.';
      case 'daily-calendar':
        return '좋아요. 오늘 일정 흐름만 빠르게 볼게요.';
      case 'new-year':
        return '좋아요. 올해 흐름은 큰 방향만 먼저 깔끔하게 볼게요.';
      case 'fortune-cookie':
        return '좋아요. 오늘 메시지는 짧고 선명하게 꺼내볼게요.';
      default:
        return context.l10n.fortuneIntroMessage(
          _getSpecialtyLabel(context, fortuneType),
        );
    }
  }

  String _haneulSessionRequestMessage(String fortuneType) {
    switch (fortuneType) {
      case 'daily':
        return '오늘 흐름이 궁금해요.';
      case 'daily-calendar':
        return '오늘 일정 흐름이 궁금해요.';
      case 'new-year':
        return '올해 흐름이 궁금해요.';
      case 'fortune-cookie':
        return '오늘 메시지가 궁금해요.';
      default:
        return context.l10n
            .tellMeAbout(_getSpecialtyLabel(context, fortuneType));
    }
  }

  Widget _buildChatList(CharacterChatState chatState) {
    final visibleMessages = _messagesForDisplay(chatState);
    final isHaneulShell = _isHaneulPremiumShell;
    final listView = NotificationListener<ScrollNotification>(
      onNotification: (notification) =>
          _handleChatScrollNotification(notification, chatState),
      child: ListView.builder(
        controller: _scrollController,
        physics: _chatScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isHaneulShell ? 14 : 16,
          vertical: isHaneulShell ? DSSpacing.sm : DSSpacing.xs,
        ),
        itemCount: visibleMessages.length + (chatState.isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == visibleMessages.length && chatState.isTyping) {
            return _buildTypingIndicator();
          }

          final message = visibleMessages[index];

          // 선택지 메시지인 경우
          if (message.isChoice && message.choiceSet != null) {
            return KeyedSubtree(
              key: _messageAnchorKeyFor(message.id),
              child: CharacterChoiceWidget(
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
              ),
            );
          }

          return KeyedSubtree(
            key: _messageAnchorKeyFor(message.id),
            child: CharacterMessageBubble(
              message: message,
              character: widget.character,
              showAvatar: _shouldShowAvatar(visibleMessages, index),
            ),
          );
        },
      ),
    );

    if (chatState.archivedMessages.isEmpty || _isArchivedHistoryVisible) {
      return listView;
    }

    return RefreshIndicator.adaptive(
      onRefresh: () => _handleArchivedHistoryRefresh(chatState),
      child: listView,
    );
  }

  Future<void> _handleChoiceSelection(CharacterChoice choice) async {
    await _submitChoiceSelection(choice);
  }

  Widget _buildTypingIndicator() {
    final accentPalette = _accentPalette(context);
    final colors = context.colors;
    final isHaneulShell = _isHaneulPremiumShell;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isHaneulShell ? DSSpacing.xs : DSSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: isHaneulShell ? 14 : 16,
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
          const SizedBox(width: DSSpacing.sm),
          Container(
            padding: CharacterChatSurfaceStyle.bubblePadding,
            decoration: CharacterChatSurfaceStyle.floatingSurfaceDecoration(
              context,
              backgroundColor: colors.surface,
              borderAlpha: 0.5,
            ),
            child: WaveTypingIndicator(
              dotColor: colors.textTertiary,
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
    final colors = context.colors;
    final surveyNotifier = widget.catalogPreview == null
        ? ref.read(characterChatSurveyProvider(widget.character.id).notifier)
        : null;
    final options = surveyNotifier?.getCurrentStepOptions() ?? step.options;
    final stepBadge =
        '${progress.currentStepIndex + 1}/${progress.config.totalSteps}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm + DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: widget.character.isFortuneExpert
            ? colors.surface.withValues(
                alpha: context.isDark ? 0.92 : 0.95,
              )
            : colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Container(
        padding: CharacterChatSurfaceStyle.floatingSurfacePadding,
        decoration: CharacterChatSurfaceStyle.floatingSurfaceDecoration(
          context,
          backgroundColor: colors.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 진행률 표시
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: DSSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(DSRadius.full),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      stepBadge,
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DSRadius.full),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: progress.progress,
                        backgroundColor: colors.backgroundTertiary,
                        valueColor:
                            AlwaysStoppedAnimation(accentPalette.accent),
                      ),
                    ),
                  ),
                  // 스킵 버튼 (선택적 단계만)
                  if (!step.isRequired)
                    TextButton(
                      onPressed: surveyNotifier == null
                          ? null
                          : () {
                              surveyNotifier.skipCurrentStep();
                              _checkSurveyCompletion();
                            },
                      child: Text(
                        context.l10n.skip,
                        style: context.labelSmall.copyWith(
                          color: colors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 입력 타입별 위젯
            _buildSurveyInputWidget(step, options),
          ],
        ),
      ),
    );
  }

  /// 입력 타입별 설문 위젯 빌드
  Widget _buildSurveyInputWidget(SurveyStep step, List<SurveyOption> options) {
    switch (step.inputType) {
      case SurveyInputType.chips:
        return ChatSurveyChips(options: options, onSelect: _handleSurveyAnswer);

      case SurveyInputType.tarotDeck:
        return ChatTarotDeckPicker(
          onSelect: _handleSurveyAnswer,
        );

      case SurveyInputType.profile:
      case SurveyInputType.familyProfile:
        return _buildStoredProfileSelector(step.inputType);

      case SurveyInputType.petProfile:
        return _buildPetProfileSelector();

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
          onBeforePickImage: (source) => _ensureAuthenticatedForSurveyImagePick(
            PendingChatImagePickerTarget.surveyFaceReading,
            source,
          ),
          initialPickSource: _pendingImageSourceFor(
            PendingChatImagePickerTarget.surveyFaceReading,
          ),
          onInitialPickHandled: () {
            unawaited(_clearPendingSurveyImageIntent());
          },
        );

      case SurveyInputType.image:
        return ChatImageInput(
          onImageSelected: _handleImageSelect,
          hintText: '사진을 선택하거나 촬영하세요',
          onBeforePickImage: (source) => _ensureAuthenticatedForSurveyImagePick(
            PendingChatImagePickerTarget.surveyImage,
            source,
          ),
          initialPickSource: _pendingImageSourceFor(
            PendingChatImagePickerTarget.surveyImage,
          ),
          onInitialPickHandled: () {
            unawaited(_clearPendingSurveyImageIntent());
          },
        );

      case SurveyInputType.ootdImage:
        return OotdPhotoInput(
          onImageSelected: _handleImageSelect,
          onBeforePickImage: (source) => _ensureAuthenticatedForSurveyImagePick(
            PendingChatImagePickerTarget.surveyOotd,
            source,
          ),
          initialPickSource: _pendingImageSourceFor(
            PendingChatImagePickerTarget.surveyOotd,
          ),
          onInitialPickHandled: () {
            unawaited(_clearPendingSurveyImageIntent());
          },
        );

      case SurveyInputType.matchSelection:
        // 이전 단계에서 선택한 종목 가져오기
        final surveyProgress = ref
            .read(characterChatSurveyProvider(widget.character.id))
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

      case SurveyInputType.tarot:
        final answers = ref
                .read(characterChatSurveyProvider(widget.character.id))
                .activeProgress
                ?.answers ??
            const <String, dynamic>{};
        return ChatTarotDrawWidget(
          deckId: answers['deckId']?.toString() ?? 'rider_waite',
          purpose: answers['purpose']?.toString(),
          questionText: answers['questionText']?.toString(),
          onSubmit: _handleSurveyAnswer,
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

  Widget _buildStoredProfileSelector(SurveyInputType inputType) {
    final profilesAsync = ref.watch(secondaryProfilesProvider);
    final surveyState = ref.watch(
      characterChatSurveyProvider(widget.character.id),
    );
    final selectedMember =
        surveyState.activeProgress?.answers['member']?.toString();

    return profilesAsync.when(
      loading: () => _buildSurveyInfoBox(
        message: '저장된 프로필을 불러오는 중이에요...',
        showLoader: true,
      ),
      error: (error, _) => _buildSurveyInfoBox(
        message: '저장된 프로필을 불러오지 못했어요.',
        actionLabel: '다시 불러오기',
        onAction: () {
          ref.read(secondaryProfilesProvider.notifier).refresh();
        },
      ),
      data: (profiles) {
        final filteredProfiles = _filterStoredProfiles(
          profiles,
          inputType: inputType,
          selectedMember: selectedMember,
        );

        if (filteredProfiles.isEmpty) {
          final emptyMessage = inputType == SurveyInputType.familyProfile
              ? '선택한 가족 관계에 맞는 저장 프로필이 없어요.'
              : '선택할 수 있는 저장 프로필이 없어요.';
          return _buildSurveyInfoBox(
            message: emptyMessage,
            actionLabel: '등록하기',
            onAction: () {
              unawaited(
                _showSecondaryProfileCreateSheet(
                  inputType: inputType,
                  selectedMember: selectedMember,
                ),
              );
            },
          );
        }

        final options = filteredProfiles
            .map(
              (profile) => SurveyOption(
                id: profile.id,
                label: _buildStoredProfileOptionLabel(
                  profile,
                  inputType,
                  selectedMember,
                ),
                emoji: _buildStoredProfileEmoji(profile, inputType),
              ),
            )
            .toList(growable: false);
        final profileById = {
          for (final profile in filteredProfiles) profile.id: profile,
        };

        return ChatSurveyChips(
          options: options,
          onSelect: (option) {
            final profile = profileById[option.id];
            if (profile == null) return;

            _handleSurveyAnswer(
              buildStoredProfileSurveyAnswer(
                profile: profile,
                displayText: _buildStoredProfileDisplayText(
                  profile,
                  inputType,
                  selectedMember: selectedMember,
                ),
                selectedFamilyMember: selectedMember,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPetProfileSelector() {
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      loading: () => _buildSurveyInfoBox(
        message: '저장된 반려동물을 불러오는 중이에요...',
        showLoader: true,
      ),
      error: (error, _) => _buildSurveyInfoBox(
        message: '저장된 반려동물을 불러오지 못했어요.',
        actionLabel: '다시 불러오기',
        onAction: () {
          ref.read(petProfilesProvider.notifier).refresh();
        },
      ),
      data: (pets) {
        if (pets.isEmpty) {
          return _buildSurveyInfoBox(
            message: '선택할 수 있는 반려동물이 없어요.',
            actionLabel: '등록하기',
            onAction: () {
              unawaited(_showPetProfileCreateSheet());
            },
          );
        }

        final colors = context.colors;
        final typography = context.typography;
        final options = pets
            .map(
              (pet) => SurveyOption(
                id: pet.id,
                label: _buildPetProfileOptionLabel(pet),
                emoji: '🐾',
              ),
            )
            .toList(growable: false);
        final petById = {for (final pet in pets) pet.id: pet};

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.md,
                0,
                DSSpacing.md,
                DSSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '저장된 반려동물 ${pets.length}마리',
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        if (_isPetProfileManagementMode) ...[
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            '삭제할 반려동물을 선택하면 바로 목록에서 제거돼요.',
                            style: typography.bodySmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _petProfileDeletingId != null
                        ? null
                        : () {
                            setState(() {
                              _isPetProfileManagementMode =
                                  !_isPetProfileManagementMode;
                            });
                          },
                    child: Text(_isPetProfileManagementMode ? '선택 모드' : '관리'),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isPetProfileManagementMode
                  ? _buildPetProfileManagementList(pets)
                  : ChatSurveyChips(
                      options: options,
                      onSelect: (option) {
                        final pet = petById[option.id];
                        if (pet == null) return;

                        _handleSurveyAnswer(
                          buildPetProfileSurveyAnswer(
                            profile: pet,
                            displayText: _buildPetProfileDisplayText(pet),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPetProfileManagementList(List<PetProfile> pets) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        key: const ValueKey('pet-profile-management-list'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final pet in pets)
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(DSSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(DSRadius.md),
                      ),
                      child: Icon(
                        Icons.pets_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: typography.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            _buildPetProfileManagementCaption(pet),
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    DSButton.destructive(
                      text: '삭제',
                      size: DSButtonSize.small,
                      fullWidth: false,
                      isLoading: _petProfileDeletingId == pet.id,
                      onPressed: _petProfileDeletingId != null
                          ? null
                          : () => _deletePetProfile(pet),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildPetProfileManagementCaption(PetProfile profile) {
    final parts = <String>[profile.detailLabel];

    if (profile.age != null) {
      parts.add('${profile.age}살');
    }

    final gender = profile.gender?.trim();
    if (gender != null && gender.isNotEmpty) {
      parts.add(gender);
    }

    return parts.join(' · ');
  }

  Future<void> _deletePetProfile(PetProfile profile) async {
    final shouldDelete = await DSModal.confirm(
      context: context,
      title: '반려동물 삭제',
      message: '${profile.name} 프로필을 삭제할까요?\n삭제 후에는 다시 복구할 수 없어요.',
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      _petProfileDeletingId = profile.id;
    });

    try {
      await ref.read(petProfilesProvider.notifier).deleteProfile(profile.id);

      if (!mounted) {
        return;
      }

      final remainingPets =
          ref.read(petProfilesProvider).valueOrNull ?? const [];

      setState(() {
        _petProfileDeletingId = null;
        if (remainingPets.isEmpty) {
          _isPetProfileManagementMode = false;
        }
      });

      DSToast.success(context, '${profile.name} 프로필을 삭제했어요.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _petProfileDeletingId = null;
      });

      DSToast.error(context, '반려동물 삭제에 실패했어요. 다시 시도해주세요.');
    }
  }

  List<SecondaryProfile> _filterStoredProfiles(
    List<SecondaryProfile> profiles, {
    required SurveyInputType inputType,
    String? selectedMember,
  }) {
    if (inputType != SurveyInputType.familyProfile) {
      return profiles;
    }

    if (selectedMember == null || selectedMember.isEmpty) {
      return profiles
          .where(
            (profile) =>
                profile.relationship == 'family' ||
                profile.relationship == 'lover',
          )
          .toList(growable: false);
    }

    return profiles.where((profile) {
      return profile.matchesFamilyMember(selectedMember);
    }).toList(growable: false);
  }

  Future<void> _showPetProfileCreateSheet() async {
    if (!await _ensureAuthenticatedForProfileRegistration()) {
      return;
    }

    if (!mounted) {
      return;
    }

    final createdProfile = await PetProfileCreateSheet.show(context);
    if (!mounted || createdProfile == null) {
      return;
    }

    setState(() {
      _isPetProfileManagementMode = false;
    });

    _handleSurveyAnswer(
      buildPetProfileSurveyAnswer(
        profile: createdProfile,
        displayText: _buildPetProfileDisplayText(createdProfile),
      ),
    );
  }

  Future<void> _showSecondaryProfileCreateSheet({
    required SurveyInputType inputType,
    String? selectedMember,
  }) async {
    if (!await _ensureAuthenticatedForProfileRegistration()) {
      return;
    }

    if (!mounted) {
      return;
    }

    final createdProfile = await SecondaryProfileCreateSheet.show(
      context,
      selectedFamilyMember:
          inputType == SurveyInputType.familyProfile ? selectedMember : null,
    );
    if (!mounted || createdProfile == null) {
      return;
    }

    _handleSurveyAnswer(
      buildStoredProfileSurveyAnswer(
        profile: createdProfile,
        displayText: _buildStoredProfileDisplayText(
          createdProfile,
          inputType,
          selectedMember: selectedMember,
        ),
        selectedFamilyMember: selectedMember,
      ),
    );
  }

  String _buildStoredProfileOptionLabel(
    SecondaryProfile profile,
    SurveyInputType inputType,
    String? selectedMember,
  ) {
    if (inputType == SurveyInputType.familyProfile) {
      return '${profile.name} · ${profile.familySurveyRelationText(selectedMember: selectedMember)}';
    }

    if (profile.relationship != null) {
      return '${profile.name} · ${profile.relationshipText}';
    }

    return profile.name;
  }

  String _buildStoredProfileDisplayText(
    SecondaryProfile profile,
    SurveyInputType inputType, {
    String? selectedMember,
  }) {
    final label = _buildStoredProfileOptionLabel(
      profile,
      inputType,
      selectedMember,
    );
    final emoji = _buildStoredProfileEmoji(profile, inputType);
    return '$emoji $label';
  }

  String _buildPetProfileOptionLabel(PetProfile profile) {
    return '${profile.name} · ${profile.detailLabel}';
  }

  String _buildPetProfileDisplayText(PetProfile profile) {
    return '🐾 ${_buildPetProfileOptionLabel(profile)}';
  }

  String _buildStoredProfileEmoji(
    SecondaryProfile profile,
    SurveyInputType inputType,
  ) {
    if (inputType == SurveyInputType.familyProfile) {
      return '👨‍👩‍👧‍👦';
    }

    switch (profile.relationship) {
      case 'lover':
        return '💕';
      case 'family':
        return '👨‍👩‍👧‍👦';
      case 'friend':
        return '👥';
      default:
        return '📋';
    }
  }

  Widget _buildSurveyInfoBox({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool showLoader = false,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final accentPalette = _accentPalette(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(color: colors.textPrimary.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLoader) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(accentPalette.accent),
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: DSSpacing.xs),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
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
              Align(
                alignment: Alignment.centerRight,
                child: DSButton.primary(
                  text: context.l10n.selectionComplete,
                  size: DSButtonSize.small,
                  fullWidth: false,
                  onPressed: () {
                    final selectedOptions = options
                        .where((option) => selectedIds.contains(option.id))
                        .toList(growable: false);
                    _handleSurveyAnswer(selectedOptions);
                  },
                ),
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
                    characterChatSurveyProvider(widget.character.id).notifier,
                  )
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
                .map(
                  (e) => {
                    'title': e.title,
                    'startTime': e.startTime?.toIso8601String(),
                    'isAllDay': e.isAllDay,
                    'location': e.location,
                  },
                )
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
      final surveyState = ref.read(
        characterChatSurveyProvider(widget.character.id),
      );
      final chatNotifier = ref.read(
        characterChatProvider(widget.character.id).notifier,
      );

      if (surveyState.isCompleted) {
        _handleSurveyComplete(surveyState);
      } else if (surveyState.isActive && surveyState.activeProgress != null) {
        // 다음 질문 표시
        final nextQuestion = _getDynamicStepQuestion(
          surveyState.activeProgress!.currentStep,
        );
        chatNotifier.addCharacterMessage(nextQuestion);
        _scrollToBottom();
      }
    });
  }

  /// 사진 선택 바텀시트 표시
  Future<void> _showImagePickerSheet({bool skipAuthGate = false}) async {
    final pendingIntent = skipAuthGate
        ? null
        : PendingChatAuthIntent.openImagePicker(
            characterId: widget.character.id,
            fortuneType: _activeFortuneType(),
            target: PendingChatImagePickerTarget.composerSheet,
          );
    final ready = await _ensureChatActionReady(
      actionLabel: '사진을 보내려면',
      requiredTokens: CharacterChatPreflightGuard.characterChatTokenCost(),
      pendingIntent: pendingIntent,
      trigger: skipAuthGate ? 'image-picker.resume' : 'image-picker',
    );
    if (!ready) {
      return;
    }

    if (!mounted) {
      return;
    }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '사진을 추가할 방법을 선택하세요',
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: colors.textPrimary,
              ),
              title: Text('카메라', style: context.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: colors.textPrimary,
              ),
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
    _clearSessionStartAnchor();
    // 사용자 메시지로 이미지 경로 추가 (UI에서 이미지로 표시)
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .sendImageMessage(imageFile.path);
    _scrollToBottom();
  }

  Widget _buildInputArea() {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.sm + 2,
        DSSpacing.md,
        DSSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: widget.character.isFortuneExpert
            ? colors.surface.withValues(
                alpha: context.isDark ? 0.92 : 0.95,
              )
            : colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AnimatedOpacity(
                duration: DSAnimation.fast,
                opacity: _isComposerRecording ? 0.45 : 1,
                child: GestureDetector(
                  onTap: _isComposerRecording
                      ? null
                      : () {
                          unawaited(_showImagePickerSheet());
                        },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: colors.textSecondary,
                      size: 22,
                    ),
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
                        .read(
                          characterChatProvider(widget.character.id).notifier,
                        )
                        .onUserDraftChanged(text);
                  },
                  onRecordingChanged: (isRecording) {
                    if (!mounted || _isComposerRecording == isRecording) {
                      return;
                    }

                    setState(() {
                      _isComposerRecording = isRecording;
                    });
                  },
                  onSubmit: (text) async {
                    if (text.isEmpty) {
                      return;
                    }
                    await _sendTextMessage(text);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowAvatar(List<CharacterChatMessage> messages, int index) {
    final current = messages[index];
    if (current.type != CharacterChatMessageType.character) {
      return true;
    }

    final next = index + 1 < messages.length ? messages[index + 1] : null;
    return next?.type != CharacterChatMessageType.character;
  }
}
