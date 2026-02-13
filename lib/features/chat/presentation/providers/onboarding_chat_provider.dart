import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../constants/fortune_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../models/user_profile.dart';
// Gender enum 사용을 위해 export 확인 (fortune_constants.dart에 있음)
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../services/storage_service.dart';
import '../../../../utils/date_utils.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/life_category.dart';
import 'chat_messages_provider.dart';

const _uuid = Uuid();

/// 온보딩 단계
enum OnboardingStep {
  /// 웰컴 메시지
  welcome,

  /// 인생 컨설팅 대분류 선택 (연애, 돈, 커리어, 건강)
  lifeCategory,

  /// 세부 고민 선택
  subConcern,

  /// 이름 입력
  name,

  /// 생년월일 입력
  birthDate,

  /// 태어난 시간 입력
  birthTime,

  /// 성별 선택 (PASS 가능)
  gender,

  /// MBTI 선택 (PASS 가능)
  mbti,

  /// 혈액형 선택 (PASS 가능)
  bloodType,

  /// 정보 확인 화면
  confirmation,

  /// 로그인/회원가입 유도
  loginPrompt,

  /// 완료
  completed,
}

/// 온보딩 상태
class OnboardingState {
  final OnboardingStep currentStep;
  final LifeCategory? primaryLifeCategory; // 인생 컨설팅 대분류
  final String? subConcern; // 세부 고민 ID
  final String? name;
  final DateTime? birthDate;
  final TimeOfDay? birthTime;
  final Gender? gender;
  final String? mbti;
  final String? bloodType;
  final bool isProcessing;
  final bool needsOnboarding;
  final bool isCheckingStatus; // ✅ 온보딩 상태 체크 중인지 (깜빡임 방지용)

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.primaryLifeCategory,
    this.subConcern,
    this.name,
    this.birthDate,
    this.birthTime,
    this.gender,
    this.mbti,
    this.bloodType,
    this.isProcessing = false,
    this.needsOnboarding = true,
    this.isCheckingStatus = true, // ✅ 기본값 true (체크 중)
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    LifeCategory? primaryLifeCategory,
    String? subConcern,
    String? name,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    Gender? gender,
    String? mbti,
    String? bloodType,
    bool? isProcessing,
    bool? needsOnboarding,
    bool? isCheckingStatus,
    bool clearLifeCategory = false,
    bool clearSubConcern = false,
    bool clearGender = false,
    bool clearMbti = false,
    bool clearBloodType = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      primaryLifeCategory: clearLifeCategory ? null : (primaryLifeCategory ?? this.primaryLifeCategory),
      subConcern: clearSubConcern ? null : (subConcern ?? this.subConcern),
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: clearGender ? null : (gender ?? this.gender),
      mbti: clearMbti ? null : (mbti ?? this.mbti),
      bloodType: clearBloodType ? null : (bloodType ?? this.bloodType),
      isProcessing: isProcessing ?? this.isProcessing,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      isCheckingStatus: isCheckingStatus ?? this.isCheckingStatus,
    );
  }
}

/// 온보딩 채팅 프로바이더
class OnboardingChatNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  final StorageService _storageService = StorageService();

  OnboardingChatNotifier(this._ref) : super(const OnboardingState()) {
    _checkOnboardingStatus();
    _listenToAuthChanges();
  }

  /// Auth 상태 변경 감지 (로그인/로그아웃 시 온보딩 상태 업데이트)
  void _listenToAuthChanges() {
    _ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState == null) return;

        // 로그아웃 이벤트 감지
        if (authState.event == AuthChangeEvent.signedOut) {
          debugPrint(
              '🔍 [OnboardingChatNotifier] User signed out - resetting onboarding');
          _resetForGuestUser();
        }

        // 로그인 이벤트 감지 - DB에서 온보딩 상태 재확인
        if (authState.event == AuthChangeEvent.signedIn) {
          debugPrint(
              '🔍 [OnboardingChatNotifier] User signed in - re-checking onboarding status');
          _recheckOnboardingAfterLogin();
        }
      });
    });
  }

  /// 로그인 후 온보딩 상태 재확인
  /// 온보딩 단계에 따라 다르게 처리
  Future<void> _recheckOnboardingAfterLogin() async {
    debugPrint('🔍 [_recheckOnboardingAfterLogin] currentStep: ${state.currentStep}');

    // 온보딩 단계에 따라 처리
    switch (state.currentStep) {
      case OnboardingStep.welcome:
      case OnboardingStep.name:
        // ✅ 초기 단계에서 "바로 로그인하기" 클릭 → handleEarlyLogin
        debugPrint('🔐 [_recheckOnboardingAfterLogin] Early login detected, calling handleEarlyLogin');
        await handleEarlyLogin();
        break;

      case OnboardingStep.loginPrompt:
        // ✅ 온보딩 완료 후 로그인 유도 단계 → skipLoginPrompt
        debugPrint('🔐 [_recheckOnboardingAfterLogin] Login prompt step, calling skipLoginPrompt');
        skipLoginPrompt();
        break;

      default:
        // ✅ 다른 단계 (birthDate, birthTime, gender 등) → 상태 체크만
        debugPrint('🔐 [_recheckOnboardingAfterLogin] Other step, calling _checkOnboardingStatus');
        state = state.copyWith(isCheckingStatus: true);
        await _checkOnboardingStatus();
        break;
    }
  }

  /// 로그아웃 시 게스트 사용자용 온보딩 리셋
  void _resetForGuestUser() {
    // 채팅 메시지 초기화
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);
    chatNotifier.clearConversation();

    // 온보딩 상태 리셋 (새 온보딩 필요)
    state = const OnboardingState(
      currentStep: OnboardingStep.welcome,
      needsOnboarding: true,
      isCheckingStatus: false,
    );

    debugPrint(
        '🔍 [OnboardingChatNotifier] State reset for guest: needsOnboarding=${state.needsOnboarding}');
  }

  /// 온보딩 필요 여부 확인
  Future<void> _checkOnboardingStatus() async {
    // 이미 온보딩이 진행 중이면 상태를 덮어쓰지 않음
    // ✅ isCheckingStatus가 false면 startOnboarding()이 이미 호출됨 → 무시
    if (state.currentStep != OnboardingStep.welcome ||
        !state.isCheckingStatus) {
      debugPrint(
          '🔍 [_checkOnboardingStatus] Skipping (step: ${state.currentStep}, isChecking: ${state.isCheckingStatus})');
      if (state.isCheckingStatus) {
        state = state.copyWith(isCheckingStatus: false);
      }
      return;
    }

    try {
      final client = _ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;

      // 로그인된 사용자의 경우 DB에서 확인
      if (user != null) {
        final profile = await client
            .from('user_profiles')
            .select('onboarding_completed, name, birth_date, birth_time')
            .eq('id', user.id)
            .maybeSingle();

        // ✅ 비동기 작업 후 재확인: startOnboarding()이 호출됐으면 무시
        if (!state.isCheckingStatus) {
          debugPrint(
              '🔍 [_checkOnboardingStatus] startOnboarding() was called during async, aborting');
          return;
        }

        if (profile != null && profile['onboarding_completed'] == true) {
          state = state.copyWith(
            needsOnboarding: false,
            currentStep: OnboardingStep.completed,
            name: profile['name'],
            isCheckingStatus: false,
          );
          return;
        }

        // 소셜 로그인에서 이름 가져오기
        final socialName =
            user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
        if (socialName != null && socialName.toString().isNotEmpty) {
          state = state.copyWith(name: socialName.toString());
        }
      }

      // ✅ 비동기 작업 후 재확인
      if (!state.isCheckingStatus) {
        debugPrint(
            '🔍 [_checkOnboardingStatus] startOnboarding() was called during async, aborting');
        return;
      }

      // 로컬 스토리지 확인
      final localProfile = await _storageService.getUserProfile();

      // ✅ 비동기 작업 후 재확인
      if (!state.isCheckingStatus) {
        debugPrint(
            '🔍 [_checkOnboardingStatus] startOnboarding() was called during async, aborting');
        return;
      }

      if (localProfile != null &&
          localProfile['onboarding_completed'] == true) {
        state = state.copyWith(
          needsOnboarding: false,
          currentStep: OnboardingStep.completed,
          isCheckingStatus: false,
        );
        return;
      }

      // 온보딩 필요
      state = state.copyWith(needsOnboarding: true, isCheckingStatus: false);
    } catch (e) {
      Logger.error('Error checking onboarding status', e);
      // ✅ 에러 발생 시에도 재확인
      if (state.isCheckingStatus) {
        state = state.copyWith(needsOnboarding: true, isCheckingStatus: false);
      }
    }
  }

  /// 온보딩 시작 (웰컴 메시지 추가)
  void startOnboarding() {
    // ✅ 핵심: 온보딩 상태를 완전히 리셋 (재시작 시에도 정상 동작하도록)
    state = const OnboardingState(
      currentStep: OnboardingStep.welcome,
      needsOnboarding: true,
      isCheckingStatus: false,
    );
    debugPrint(
        '🔍 [startOnboarding] State reset: needsOnboarding=${state.needsOnboarding}, currentStep=${state.currentStep}');

    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 웰컴 메시지
    chatNotifier.addAiMessage('안녕하세요! ✨\n당신의 인생 컨설턴트가 되어드릴게요.');

    // 짧은 딜레이 후 관심 분야 질문
    Future.delayed(const Duration(milliseconds: 500), () {
      _askForLifeCategory();
    });
  }

  /// 인생 컨설팅 대분류 질문
  void _askForLifeCategory() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    chatNotifier.addAiMessage('먼저 가장 관심있는 영역을 선택해주세요.');

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.lifeCategory,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );

    state = state.copyWith(currentStep: OnboardingStep.lifeCategory);
  }

  /// 인생 컨설팅 대분류 선택 처리
  void submitLifeCategory(LifeCategory category) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 사용자 응답 추가
    chatNotifier.addUserMessage(category.label);

    state = state.copyWith(
      primaryLifeCategory: category,
      currentStep: OnboardingStep.subConcern,
    );

    // 세부 고민 질문으로 이동
    Future.delayed(const Duration(milliseconds: 300), () {
      _askForSubConcern();
    });
  }

  /// 세부 고민 질문
  void _askForSubConcern() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    final categoryLabel = state.primaryLifeCategory?.label ?? '이 분야';
    chatNotifier.addAiMessage('$categoryLabel에서 어떤 부분이\n가장 궁금하세요?');

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.subConcern,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
  }

  /// 세부 고민 선택 처리
  void submitSubConcern(String concernId) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 선택한 세부 고민의 라벨 찾기
    final category = state.primaryLifeCategory;
    final concerns = category != null ? subConcernsByCategory[category] : null;
    final selectedConcern = concerns?.firstWhere(
      (c) => c.id == concernId,
      orElse: () => SubConcern(id: concernId, label: concernId, category: category!),
    );

    chatNotifier.addUserMessage(selectedConcern?.label ?? concernId);

    state = state.copyWith(
      subConcern: concernId,
      currentStep: OnboardingStep.name,
    );

    // 이름 질문으로 이동
    Future.delayed(const Duration(milliseconds: 300), () {
      _askForName();
    });
  }

  /// 이름 질문
  void _askForName() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 이미 이름이 있으면 확인
    if (state.name != null && state.name!.isNotEmpty) {
      chatNotifier.addAiMessage('${state.name}님이 맞으신가요?\n아니라면 이름을 알려주세요.');
    } else {
      chatNotifier.addAiMessage('먼저 이름이 어떻게 되세요?');
    }

    // 온보딩 입력 메시지 추가
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.name,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );

    state = state.copyWith(currentStep: OnboardingStep.name);
  }

  /// 이름에서 불필요한 접미사 제거 (라고 합니다, 입니다 등)
  String _cleanName(String rawName) {
    String cleaned = rawName.trim();

    // 일반적인 한국어 이름 패턴에서 접미사 제거
    final suffixPatterns = [
      RegExp(r'라고\s*합니다\.?$'),
      RegExp(r'이라고\s*합니다\.?$'),
      RegExp(r'입니다\.?$'),
      RegExp(r'이에요\.?$'),
      RegExp(r'예요\.?$'),
      RegExp(r'이야\.?$'),
      RegExp(r'야\.?$'),
      RegExp(r'요\.?$'),
    ];

    for (final pattern in suffixPatterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    // 접두사 제거 (저는, 제 이름은 등)
    final prefixPatterns = [
      RegExp(r'^저는\s*'),
      RegExp(r'^제\s*이름은\s*'),
      RegExp(r'^이름은\s*'),
      RegExp(r'^나는\s*'),
      RegExp(r'^내\s*이름은\s*'),
    ];

    for (final pattern in prefixPatterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    return cleaned.trim();
  }

  /// 이름 입력 처리
  void submitName(String name) {
    if (name.trim().isEmpty) return;

    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 사용자 응답 추가 (원본 표시)
    chatNotifier.addUserMessage(name);

    // 이름 정리 (접미사/접두사 제거)
    final cleanedName = _cleanName(name);

    // ✅ 핵심: name과 currentStep을 동시에 업데이트 (레이스 컨디션 방지)
    state = state.copyWith(
      name: cleanedName,
      currentStep: OnboardingStep.birthDate,
    );
    debugPrint(
        '🔍 [submitName] raw: $name, cleaned: $cleanedName, newStep: ${state.currentStep}');

    // UI 메시지는 비동기로 추가 (상태 변경 후)
    Future.delayed(const Duration(milliseconds: 300), () {
      _showBirthDateQuestion();
    });
  }

  /// 생년월일 질문 메시지 표시 (currentStep은 submitName에서 이미 업데이트됨)
  void _showBirthDateQuestion() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    chatNotifier.addAiMessage('${state.name}님 반가워요! ✨\n생년월일을 알려주세요.');

    // 온보딩 입력 메시지 추가 (생년월일 피커 표시용)
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.birthDate,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
    // currentStep은 이미 submitName()에서 업데이트됨 - 여기서 다시 하지 않음
  }

  /// 생년월일 입력 처리
  void submitBirthDate(DateTime date) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 포맷팅된 날짜 표시
    final formattedDate = '${date.year}년 ${date.month}월 ${date.day}일';
    chatNotifier.addUserMessage(formattedDate);

    state = state.copyWith(birthDate: date);

    // 태어난 시간 질문
    Future.delayed(const Duration(milliseconds: 300), () {
      _askForBirthTime();
    });
  }

  /// 생년월일+시간 동시 입력 처리 (통합 피커용)
  void submitBirthDateTime(DateTime date, TimeOfDay? time) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 포맷팅된 날짜+시간 표시
    String displayText = '${date.year}년 ${date.month}월 ${date.day}일';
    if (time != null) {
      displayText += ' ${time.hour}시';
      if (time.minute > 0) {
        displayText += ' ${time.minute}분';
      }
    }
    chatNotifier.addUserMessage(displayText);

    state = state.copyWith(
      birthDate: date,
      birthTime: time ?? const TimeOfDay(hour: 12, minute: 0),
      currentStep: OnboardingStep.gender,
    );

    // 성별 질문으로 이동
    Future.delayed(const Duration(milliseconds: 300), () {
      _showGenderQuestion();
    });
  }

  /// 태어난 시간 질문
  void _askForBirthTime() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    chatNotifier
        .addAiMessage('사주를 더 정확하게 보려면\n태어난 시간도 알려주세요.\n\n모르시면 "모름"을 선택하셔도 돼요.');

    // 온보딩 입력 메시지 추가
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.birthTime,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );

    state = state.copyWith(currentStep: OnboardingStep.birthTime);
  }

  /// 태어난 시간 입력 처리
  void submitBirthTime(TimeOfDay? time) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    if (time != null) {
      final formattedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      chatNotifier.addUserMessage(formattedTime);
    } else {
      chatNotifier.addUserMessage('모름');
    }

    state = state.copyWith(
      birthTime: time ?? const TimeOfDay(hour: 12, minute: 0),
      currentStep: OnboardingStep.gender,
    );

    // 성별 질문으로 이동
    Future.delayed(const Duration(milliseconds: 300), () {
      _showGenderQuestion();
    });
  }

  /// 성별 질문 메시지 표시
  void _showGenderQuestion() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    chatNotifier.addAiMessage('성별을 알려주시면\n더 맞춤화된 정보를 드릴 수 있어요.\n\n건너뛰셔도 괜찮아요!');

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.gender,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
  }

  /// 성별 입력 처리 (PASS 가능)
  void submitGender(Gender? gender) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    if (gender != null) {
      chatNotifier.addUserMessage(gender.label);
    } else {
      chatNotifier.addUserMessage('건너뛰기');
    }

    state = state.copyWith(
      gender: gender,
      currentStep: OnboardingStep.mbti,
      clearGender: gender == null,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _showMbtiQuestion();
    });
  }

  /// MBTI 질문 메시지 표시
  void _showMbtiQuestion() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    chatNotifier.addAiMessage('MBTI를 알고 계신가요? 🧠\n성격 유형에 맞는 조언을 드릴게요!');

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.mbti,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
  }

  /// MBTI 입력 처리 (PASS 가능)
  void submitMbti(String? mbti) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    if (mbti != null) {
      chatNotifier.addUserMessage(mbti);
    } else {
      chatNotifier.addUserMessage('건너뛰기');
    }

    state = state.copyWith(
      mbti: mbti,
      currentStep: OnboardingStep.bloodType,
      clearMbti: mbti == null,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _showBloodTypeQuestion();
    });
  }

  /// 혈액형 질문 메시지 표시
  void _showBloodTypeQuestion() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    chatNotifier.addAiMessage('마지막으로 혈액형은요? 🩸\n더 세심한 맞춤 정보를 드릴게요!');

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.bloodType,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
  }

  /// 혈액형 입력 처리 (PASS 가능)
  void submitBloodType(String? bloodType) {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    if (bloodType != null) {
      chatNotifier.addUserMessage(bloodType);
    } else {
      chatNotifier.addUserMessage('건너뛰기');
    }

    state = state.copyWith(
      bloodType: bloodType,
      currentStep: OnboardingStep.confirmation,
      clearBloodType: bloodType == null,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _showConfirmation();
    });
  }

  /// 정보 확인 화면 표시
  void _showConfirmation() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    // 수집된 정보 요약
    final birthDateStr = state.birthDate != null
        ? '${state.birthDate!.year}년 ${state.birthDate!.month}월 ${state.birthDate!.day}일'
        : '미입력';
    final birthTimeStr = state.birthTime != null
        ? '${state.birthTime!.hour}시 ${state.birthTime!.minute}분'
        : '모름';

    // 세부 고민 라벨 찾기
    String subConcernLabel = '미입력';
    if (state.primaryLifeCategory != null && state.subConcern != null) {
      final concerns = subConcernsByCategory[state.primaryLifeCategory];
      final concern = concerns?.firstWhere(
        (c) => c.id == state.subConcern,
        orElse: () => SubConcern(id: '', label: state.subConcern!, category: state.primaryLifeCategory!),
      );
      subConcernLabel = concern?.label ?? state.subConcern!;
    }

    final summaryMessage = '''${state.name}님의 정보를 확인해주세요 📋

• 관심 분야: ${state.primaryLifeCategory?.label ?? '미입력'}
• 세부 고민: $subConcernLabel
• 생년월일: $birthDateStr
• 태어난 시간: $birthTimeStr
• 성별: ${state.gender?.label ?? '미입력'}
• MBTI: ${state.mbti ?? '미입력'}
• 혈액형: ${state.bloodType ?? '미입력'}

이 정보가 맞나요?''';

    chatNotifier.addAiMessage(summaryMessage);

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.confirmation,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
  }

  /// 확인 화면에서 "맞아요" 선택
  void confirmOnboarding() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);
    chatNotifier.addUserMessage('맞아요! ✅');

    state = state.copyWith(currentStep: OnboardingStep.loginPrompt);

    Future.delayed(const Duration(milliseconds: 300), () {
      _showLoginPrompt();
    });
  }

  /// 확인 화면에서 "처음부터" 선택
  void restartOnboarding() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);
    chatNotifier.addUserMessage('처음부터 다시 할게요');

    state = state.copyWith(
      currentStep: OnboardingStep.lifeCategory,
      clearLifeCategory: true,
      clearSubConcern: true,
      name: null,
      birthDate: null,
      birthTime: null,
      clearGender: true,
      clearMbti: true,
      clearBloodType: true,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _askForLifeCategory();
    });
  }

  /// 로그인/회원가입 유도 화면 표시
  void _showLoginPrompt() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    final client = _ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;

    // 이미 로그인된 경우 바로 완료
    if (user != null) {
      _completeOnboarding();
      return;
    }

    chatNotifier.addAiMessage('''정보가 저장되었어요! 🎉

계정을 만들면 기록이 영구 보관되고,
다른 기기에서도 이용할 수 있어요.

지금 가입하시겠어요?''');

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.onboardingInput,
      timestamp: DateTime.now(),
      onboardingInputType: OnboardingInputType.loginPrompt,
    );
    chatNotifier.state = chatNotifier.state.copyWith(
      messages: [...chatNotifier.state.messages, message],
    );
  }

  /// 로그인 유도 건너뛰기
  void skipLoginPrompt() {
    final chatNotifier = _ref.read(chatMessagesProvider.notifier);
    chatNotifier.addUserMessage('나중에 할게요');

    _completeOnboarding();
  }

  /// 온보딩 완료
  Future<void> _completeOnboarding() async {
    state = state.copyWith(isProcessing: true);

    final chatNotifier = _ref.read(chatMessagesProvider.notifier);

    try {
      final client = _ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;

      final birthTimeString =
          '${state.birthTime!.hour.toString().padLeft(2, '0')}:${state.birthTime!.minute.toString().padLeft(2, '0')}';

      final profile = UserProfile(
        id: user?.id ?? '',
        name: state.name!,
        email: user?.email ?? '',
        birthDate: state.birthDate,
        birthTime: birthTimeString,
        mbti: state.mbti,
        gender: state.gender ?? Gender.other,
        zodiacSign:
            FortuneDateUtils.getZodiacSign(state.birthDate!.toIso8601String()),
        chineseZodiac: FortuneDateUtils.getChineseZodiac(
            state.birthDate!.toIso8601String()),
        onboardingCompleted: true,
        subscriptionStatus: SubscriptionStatus.free,
        fortuneCount: 0,
        premiumFortunesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 저장
      await _storageService.saveUserProfile(profile.toJson());

      // Supabase 저장 (로그인된 경우)
      if (user != null) {
        // DB 체크 제약조건: blood_type은 'A', 'B', 'O', 'AB' 형식
        // UI에서는 "A형", "B형" 등으로 표시하므로 변환 필요
        String? bloodTypeForDb;
        if (state.bloodType != null) {
          bloodTypeForDb = state.bloodType!.replaceAll('형', '');
        }

        await client.from('user_profiles').upsert({
          'id': user.id,
          'email': user.email,
          'name': state.name,
          'birth_date': state.birthDate!.toIso8601String(),
          'birth_time': birthTimeString,
          'gender': (state.gender ?? Gender.other).value,
          'mbti': state.mbti,
          'blood_type': bloodTypeForDb,
          'primary_life_category': state.primaryLifeCategory?.value,
          'sub_concern': state.subConcern,
          'onboarding_completed': true,
          'zodiac_sign': profile.zodiacSign,
          'chinese_zodiac': profile.chineseZodiac,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // 프로필 새로고침
        _ref.read(userProfileNotifierProvider.notifier).refresh();
      }

      // 관심 분야에 맞는 완료 메시지
      final categoryMessage = _getCategoryWelcomeMessage();
      chatNotifier.addAiMessage(
          '감사합니다, ${state.name}님! 🎉\n$categoryMessage');

      // 관심 분야에 맞는 추천 칩 표시
      final recommendedChips = _getRecommendedChipsForCategory();
      chatNotifier.addSystemMessage(chipIds: recommendedChips);

      state = state.copyWith(
        currentStep: OnboardingStep.completed,
        needsOnboarding: false,
        isProcessing: false,
      );

      Logger.info('✅ Chat onboarding completed for ${state.name}');
    } catch (e) {
      Logger.error('Error completing onboarding', e);
      chatNotifier.addAiMessage('저장 중 오류가 발생했어요. 다시 시도해주세요.');
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 관심 분야에 따른 환영 메시지
  String _getCategoryWelcomeMessage() {
    switch (state.primaryLifeCategory) {
      case LifeCategory.loveRelationship:
        return '연애와 관계에 대한 인사이트를 준비했어요.\n어떤 것부터 확인해볼까요?';
      case LifeCategory.moneyFinance:
        return '재정과 돈에 대한 인사이트를 준비했어요.\n어떤 것부터 확인해볼까요?';
      case LifeCategory.careerStudy:
        return '커리어와 학업에 대한 인사이트를 준비했어요.\n어떤 것부터 확인해볼까요?';
      case LifeCategory.healthWellness:
        return '건강과 웰빙에 대한 인사이트를 준비했어요.\n어떤 것부터 확인해볼까요?';
      default:
        return '이제 맞춤 정보를 받아보실 수 있어요.\n무엇이 궁금하세요?';
    }
  }

  /// 관심 분야에 따른 추천 칩 목록
  List<String> _getRecommendedChipsForCategory() {
    switch (state.primaryLifeCategory) {
      case LifeCategory.loveRelationship:
        return ['compatibility', 'tarot', 'love', 'yearlyEncounter'];
      case LifeCategory.moneyFinance:
        return ['money', 'luckyItems', 'tarot', 'career'];
      case LifeCategory.careerStudy:
        return ['career', 'talent', 'exam', 'tarot'];
      case LifeCategory.healthWellness:
        return ['health', 'biorhythm', 'breathing', 'coaching'];
      default:
        return ['daily', 'tarot', 'coaching', 'love'];
    }
  }

  /// 온보딩 건너뛰기 (게스트 모드)
  void skipOnboarding() {
    state = state.copyWith(
      needsOnboarding: false,
      currentStep: OnboardingStep.completed,
    );

    final chatNotifier = _ref.read(chatMessagesProvider.notifier);
    chatNotifier.addAiMessage('오늘 어떤 도움이 필요하세요? ✨\n아래에서 원하는 항목을 선택해보세요!');
    chatNotifier.addSystemMessage(chipIds: [
      'daily_fortune',
      'love_fortune',
      'tarot',
    ]);
  }

  /// 온보딩 초기 단계에서 로그인 시 호출
  /// (이름 입력 전에 "바로 로그인하기"를 통해 로그인한 경우)
  Future<void> handleEarlyLogin() async {
    debugPrint('🔐 [handleEarlyLogin] Checking existing profile after login...');

    try {
      final client = _ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;

      if (user == null) {
        debugPrint('⚠️ [handleEarlyLogin] No user found');
        return;
      }

      // 기존 프로필 확인
      final profile = await client
          .from('user_profiles')
          .select('onboarding_completed, name, birth_date, birth_time')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile['onboarding_completed'] == true) {
        // 기존 프로필이 있고 온보딩 완료된 사용자 → 온보딩 건너뛰기
        debugPrint('✅ [handleEarlyLogin] Existing profile found, skipping onboarding');

        // 프로필 새로고침
        _ref.read(userProfileNotifierProvider.notifier).refresh();

        // 온보딩 완료 처리
        state = state.copyWith(
          needsOnboarding: false,
          currentStep: OnboardingStep.completed,
          isCheckingStatus: false,
        );

        final chatNotifier = _ref.read(chatMessagesProvider.notifier);
        chatNotifier.addAiMessage(
          '${profile['name']}님, 다시 오셨군요! 반가워요 ✨\n무엇이 궁금하세요?'
        );
        chatNotifier.addSystemMessage(chipIds: [
          'daily_fortune',
          'love_fortune',
          'career_fortune',
          'tarot',
        ]);
      } else {
        // 기존 프로필이 없거나 온보딩 미완료 → 온보딩 계속
        debugPrint('🔄 [handleEarlyLogin] No complete profile, continuing onboarding');

        // 소셜 로그인에서 이름 가져오기
        final socialName = user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            user.email?.split('@').first;

        if (socialName != null && socialName.isNotEmpty) {
          // 이름이 있으면 이름 단계 완료하고 다음 단계로
          state = state.copyWith(isCheckingStatus: false);
          submitName(socialName);
        } else {
          // 이름이 없으면 이름 입력 단계 유지
          state = state.copyWith(isCheckingStatus: false);
        }
      }
    } catch (e) {
      debugPrint('❌ [handleEarlyLogin] Error: $e');
      state = state.copyWith(isCheckingStatus: false);
    }
  }
}

/// 온보딩 채팅 프로바이더
final onboardingChatProvider =
    StateNotifierProvider<OnboardingChatNotifier, OnboardingState>(
  (ref) => OnboardingChatNotifier(ref),
);
