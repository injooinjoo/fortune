import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../../domain/models/character_affinity.dart';
import '../../domain/models/character_choice.dart';
import '../../domain/models/response_delay_config.dart';
import '../../domain/models/ai_character.dart';
import '../../data/services/character_chat_service.dart';
import '../../data/services/character_chat_local_service.dart';
import '../../data/services/character_affinity_service.dart';
import '../../data/services/character_message_notification_service.dart';
import '../../data/services/character_proactive_context_service.dart';
import '../../data/services/character_proactive_media_service.dart';
import '../../data/services/follow_up_scheduler.dart';
import '../../data/default_characters.dart';
import '../../data/fortune_characters.dart';
import '../../../../core/fortune/fortune_type_registry.dart';
import '../../../../core/services/chat_sync_service.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../services/app_icon_badge_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/moving_fortune_input_mapper.dart';
import '../../../../constants/fortune_constants.dart';
import '../../../../models/user_profile.dart';
import '../../../../services/remote_config_service.dart';
import '../../../../core/services/fortune_generators/fortune_cookie_generator.dart';
import '../../../fortune/domain/models/conditions/character_chat_fortune_conditions.dart';
import '../../../fortune/domain/services/lotto_number_generator.dart';
import '../../../fortune/presentation/providers/saju_provider.dart';
import 'active_chat_provider.dart';
import 'character_provider.dart';
import 'character_fortune_adapter.dart';
import '../utils/character_tone_policy.dart';
import '../utils/character_tone_rollout.dart';
import '../utils/character_voice_profile_registry.dart';

/// 캐릭터별 채팅 상태 Provider (family)
final characterChatProvider = StateNotifierProvider.family<
    CharacterChatNotifier, CharacterChatState, String>(
  (ref, characterId) => CharacterChatNotifier(ref, characterId),
);

/// 호기심 탭 캐릭터 운세 요청 전용 Unified 서비스
///
/// character-chat 토큰은 상위 로직에서 이미 차감하므로 토큰 트랜잭션은 비활성화합니다.
final characterUnifiedFortuneServiceProvider = Provider<UnifiedFortuneService>(
  (ref) => UnifiedFortuneService(
    Supabase.instance.client,
    enableTokenValidation: false,
  ),
);

/// 캐릭터 채팅 상태 관리자
/// 모든 캐릭터 목록 (스토리 + 운세)
final _allCharacters = [...defaultCharacters, ...fortuneCharacters];

class CharacterChatNotifier extends StateNotifier<CharacterChatState> {
  static const String _firstMeetConversationMode = 'first_meet_v1';
  static const Duration _readIdleIcebreakerDelay = Duration(seconds: 10);

  /// metadata에서 제외할 내부/UI 전용 키
  static const _metadataSkipKeys = {
    'surveyData',
    'disclaimer',
    'fortuneType',
    'fortune_type',
  };
  final String _characterId;
  final Ref _ref;
  final CharacterChatService _service = CharacterChatService();
  final FollowUpScheduler _followUpScheduler = FollowUpScheduler();
  final CharacterChatLocalService _localService = CharacterChatLocalService();
  final CharacterAffinityService _affinityService = CharacterAffinityService();
  final CharacterProactiveContextService _proactiveContextService =
      CharacterProactiveContextService();
  final CharacterProactiveMediaService _proactiveMediaService =
      CharacterProactiveMediaService();
  final StorageService _storageService = StorageService();

  /// 현재 캐릭터 정보 캐시
  AiCharacter? _cachedCharacter;
  Timer? _readIdleIcebreakerTimer;
  String? _pendingReadIdleAnchorMessageId;
  String? _lastReadIdleIcebreakerAnchorMessageId;
  DateTime? _lastReadIdleIcebreakerSentAt;
  bool _isUserDrafting = false;
  Future<void> _sendQueue = Future<void>.value();

  CharacterChatNotifier(this._ref, this._characterId)
      : super(CharacterChatState(characterId: _characterId)) {
    // 로컬 미리보기 preload는 provider 생성 경로를 막지 않도록
    // 마이크로태스크로 분리합니다.
    Future.microtask(() async {
      try {
        await _checkLocalConversation();
      } catch (error) {
        Logger.warning(
          '[CharacterChat] Failed to preload local conversation preview.',
          {
            'characterId': _characterId,
            'error': error.toString(),
          },
        );
      }
    });
  }

  /// 로컬 저장소에서 대화 존재 여부 확인
  Future<void> _checkLocalConversation() async {
    final hasLocal = await _localService.hasConversation(_characterId);
    if (hasLocal && state.messages.isEmpty) {
      // 대화가 있으면 메시지를 미리 로드 (캐릭터 리스트에서 미리보기용)
      final messages = await _localService.loadConversation(_characterId);
      if (messages.isNotEmpty && mounted) {
        // 마지막으로 읽은 시간 이후의 캐릭터 메시지 수 계산
        final lastReadTime =
            await _localService.getLastReadTimestamp(_characterId);
        int unread = 0;
        if (lastReadTime != null) {
          unread = messages
              .where((m) =>
                  m.type == CharacterChatMessageType.character &&
                  m.timestamp.isAfter(lastReadTime))
              .length;
        }
        state = state.copyWith(messages: messages, unreadCount: unread);
      }
    }
  }

  /// 캐릭터 정보 가져오기 (캐시)
  AiCharacter get _character {
    _cachedCharacter ??= _allCharacters.firstWhere(
      (c) => c.id == _characterId,
    );
    return _cachedCharacter!;
  }

  bool get _isLutsCharacter => _characterId == 'luts';

  bool get _skipSimulatedReplyDelay => _character.isFortuneExpert;

  Future<void> _waitForReadDelayIfNeeded() async {
    if (_skipSimulatedReplyDelay) return;

    final readDelay = ResponseDelayConfig.calculateReadDelay();
    await Future.delayed(Duration(milliseconds: readDelay));
  }

  Future<void> _waitForGeneratedReplyDelayIfNeeded({
    required String? emotionTag,
    required String responseText,
  }) async {
    if (_skipSimulatedReplyDelay) return;

    final emotion = ResponseDelayConfig.parseEmotion(emotionTag);
    final typingDelay = ResponseDelayConfig.calculateTypingDelay(
      emotion: emotion,
      responseLength: responseText.length,
    );
    await Future.delayed(Duration(milliseconds: typingDelay));
  }

  Future<void> _waitForUiDelayIfNeeded(Duration duration) async {
    if (_skipSimulatedReplyDelay) return;
    await Future.delayed(duration);
  }

  String? _resolveModelPreference() {
    if (!_isLutsCharacter) return null;
    final remoteConfig = _ref.read(remoteConfigProvider);
    return remoteConfig.getCharacterLutsModelPreference();
  }

  Future<CharacterChatMessage> _buildFollowUpMessageWithOptionalMedia(
    String text,
  ) async {
    final baseMessage = CharacterChatMessage.character(
      text,
      _characterId,
      origin: MessageOrigin.followUp,
    );

    if (!_isLutsCharacter) {
      return baseMessage;
    }

    final remoteConfig = _ref.read(remoteConfigProvider);
    if (!remoteConfig.isCharacterLutsProactiveImageEnabled()) {
      return baseMessage;
    }

    try {
      final maxPerDay = remoteConfig.getCharacterLutsProactiveImageMaxPerDay();
      final canSend = await _localService.canSendProactiveImage(
        _characterId,
        maxPerDay: maxPerDay,
      );
      if (!canSend) {
        return baseMessage;
      }

      final contextDecision = _proactiveContextService.resolve(
        messages: state.messages,
        now: DateTime.now(),
      );
      if (contextDecision == null) {
        return baseMessage;
      }

      final media = await _proactiveMediaService.resolveFollowUpMedia(
        characterId: _characterId,
        category: contextDecision.category,
        contextText: contextDecision.contextText,
        styleHint: contextDecision.styleHint,
      );
      if (media == null) {
        return baseMessage;
      }

      await _localService.markProactiveImageSent(_characterId);

      return baseMessage.copyWith(
        imageAsset: media.imageAsset,
        imageUrl: media.imageUrl,
        mediaCategory: media.category,
      );
    } catch (error) {
      Logger.warning(
        '[CharacterChat] Failed to attach proactive media. Fallback to text.',
        {'characterId': _characterId, 'error': error.toString()},
      );
      return baseMessage;
    }
  }

  void _appendFollowUpMessage(CharacterChatMessage message) {
    final isCurrentChatActive = _isCurrentChatActive();
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isCharacterTyping: false,
      unreadCount:
          isCurrentChatActive ? state.unreadCount : state.unreadCount + 1,
    );

    if (isCurrentChatActive) {
      _localService.saveLastReadTimestamp(_characterId);
    }
  }

  /// 유저 프로필 정보를 API용 Map으로 변환
  Map<String, dynamic>? _getUserProfileMap() {
    try {
      final profileAsync = _ref.read(userProfileProvider);
      return profileAsync.maybeWhen(
        data: (profile) {
          if (profile == null) return null;

          // 나이 계산 (birthDate로부터)
          int? age;
          if (profile.birthDate != null) {
            final now = DateTime.now();
            age = now.year - profile.birthDate!.year;
            if (now.month < profile.birthDate!.month ||
                (now.month == profile.birthDate!.month &&
                    now.day < profile.birthDate!.day)) {
              age--;
            }
          }

          return {
            if (profile.name.isNotEmpty) 'name': profile.name,
            if (age != null) 'age': age,
            'gender': profile.gender.value, // Gender enum의 value
            if (profile.mbti != null) 'mbti': profile.mbti,
            if (profile.bloodType != null) 'bloodType': profile.bloodType,
            if (profile.zodiacSign != null) 'zodiacSign': profile.zodiacSign,
            if (profile.chineseZodiac != null)
              'zodiacAnimal': profile.chineseZodiac,
            // naming API용 birthDate (YYYY-MM-DD 형식)
            if (profile.birthDate != null)
              'birthDate': profile.birthDate!.toIso8601String().split('T')[0],
            if (profile.birthTime != null) 'birthTime': profile.birthTime,
          };
        },
        orElse: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 운세 타입별 맞춤 인트로 메시지 시스템
  // ─────────────────────────────────────────────────────────────

  /// 설문 답변 ID → 한국어 라벨 변환 맵
  static const _answerLabels = <String, String>{
    // 연애 상태
    'single': '솔로', 'dating': '연애 중', 'crush': '짝사랑',
    'complicated': '복잡한 관계',
    // 연애 고민
    'meeting': '만남/인연', 'confession': '고백 타이밍',
    'conflict': '갈등 해결',
    // 연애 스타일
    'clingy': '애정 표현 많이', 'independent': '개인 시간 중요',
    // 이상형 성격
    'kind': '따뜻한', 'funny': '유머러스', 'smart': '똑똑한',
    'stable': '안정적인', 'passionate': '열정적인', 'calm': '차분한',
    // 이상형 외모 (여성상)
    'cat': '고양이상', 'fox': '여우상', 'puppy': '강아지상',
    'rabbit': '토끼상', 'deer': '사슴상', 'squirrel': '다람쥐상',
    // 이상형 외모 (남성상)
    'arab': '아랍상', 'tofu': '두부상', 'nerd': '너드남',
    'beast': '짐승남', 'gentle': '젠틀남', 'warm': '훈훈남',
    // 직업 분야
    'tech': 'IT/개발', 'finance': '금융/재무',
    'healthcare': '의료/헬스케어', 'education': '교육',
    'creative': '크리에이티브', 'marketing': '마케팅/광고',
    'sales': '영업/세일즈', 'hr': '인사/HR',
    'legal': '법률/법무', 'manufacturing': '제조/생산', 'other': '기타',
    // 경력
    'student': '학생/취준생', 'junior': '신입 (0-2년)',
    'mid': '주니어 (3-5년)', 'senior': '시니어 (6-10년)',
    'lead': '리드급 (10년+)', 'executive': '임원급',
    // 직업/커리어 고민
    'growth': '성장/자기계발', 'direction': '방향성 고민',
    'change': '이직/전직', 'balance': '워라밸', 'salary': '연봉/처우',
    'relationship': '관계/인간관계',
    // 궁합 관계
    'lover': '연인', 'friend': '친구',
    'colleague': '동료/지인', 'family': '가족',
    // 타로 목적
    'love': '연애/관계', 'career': '일/커리어',
    'decision': '결정/선택', 'guidance': '조언/가이드',
    // MBTI 분석 카테고리
    'personality': '성향 분석',
    // 경계 상황
    'work': '직장/비즈니스', 'money': '금전 거래',
    // 새해 목표
    'success': '성공/성취', 'wealth': '부자되기',
    'health': '건강/운동', 'travel': '여행/경험', 'peace': '마음의 평화',
    // 재능 관련
    'solo': '혼자 집중해서', 'team': '팀과 협업하며',
    'logical': '논리적으로 분석', 'intuitive': '직관적으로 판단',
    'beginner': '처음 시작', 'some': '조금 해봤어요',
    'intermediate': '어느 정도 경험', 'experienced': '전문가 수준',
    'minimal': '주 1-2시간', 'moderate': '주 5-10시간',
    'significant': '주 10시간 이상', 'fulltime': '풀타임 가능',
    'time': '시간 부족', 'motivation': '동기부여 어려움',
    'resources': '자원/비용 부담', 'confidence': '자신감 부족',
    // 사주 분석 유형
    'comprehensive': '종합 분석',
    // 관상 분석 포인트
    'overall': '종합 관상', 'fortune': '재물/복',
    // 이사운
    '1month': '1개월 이내', '3months': '3개월 이내',
    '6months': '6개월 이내', 'year': '1년 이내', 'undecided': '아직 미정',
    'marriage': '결혼/독립', 'better_life': '더 나은 환경',
    'investment': '투자 목적',
    // 작명 (naming)
    'known': '알아요', 'unknown': '아직 몰라요', 'male': '남아', 'female': '여아',
    'traditional': '전통적', 'modern': '현대적', 'unique': '독특한',
    'cute': '귀여운', 'strong': '강인한',
    // 캘린더
    'sync': '캘린더 연동', 'skip': '건너뛰기',
    // 공통
    'yes': '네', 'no': '아니요',
    'profile': '프로필에서 선택', 'new': '직접 입력',
  };

  /// 운세 타입별 맞춤 인트로 메시지 생성
  /// [fortuneType]: 운세 타입 (e.g., 'daily', 'love', 'career')
  /// [surveyAnswers]: 설문 답변 (설문이 있는 운세 타입에서 전달)
  String? _buildFortuneIntroMessage(
    String fortuneType, {
    Map<String, dynamic>? surveyAnswers,
  }) {
    // traditional-saju는 만세력 카드가 인트로 역할을 하므로 null 반환
    if (fortuneType == 'traditional-saju') return null;

    try {
      final profileAsync = _ref.read(userProfileProvider);
      return profileAsync.maybeWhen(
        data: (profile) {
          if (profile == null) return null;

          final name = profile.name.isNotEmpty ? profile.name : null;
          final buffer = StringBuffer();

          // 1. 캐릭터 맞춤 인사말
          buffer.writeln(_getIntroGreeting(fortuneType, name));
          buffer.writeln();

          // 2. 운세 타입별 관련 프로필 정보
          final profileLines = _getRelevantProfileLines(fortuneType, profile);
          for (final line in profileLines) {
            buffer.writeln(line);
          }

          // 3. 설문 답변 (있는 경우)
          if (surveyAnswers != null && surveyAnswers.isNotEmpty) {
            final answerLines =
                _getSurveyAnswerLines(fortuneType, surveyAnswers);
            if (answerLines.isNotEmpty) {
              if (profileLines.isNotEmpty) buffer.writeln();
              buffer.writeln('📋 입력해주신 정보:');
              for (final line in answerLines) {
                buffer.writeln(line);
              }
            }
          }

          // 4. 마무리
          buffer.writeln();
          buffer.write(_getIntroClosing(fortuneType));

          return buffer.toString();
        },
        orElse: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  /// 운세 타입별 맞춤 인사말
  String _getIntroGreeting(String fortuneType, String? name) {
    final d = name != null ? '$name님' : '회원님';

    switch (fortuneType) {
      // ─── 하늘 (lifestyle) ───
      case 'daily':
        return '$d의 오늘 하루를 살펴볼게요~ ☀️';
      case 'new-year':
        return '$d의 새해 운세를 봐드릴게요~ 🎊';
      case 'daily-calendar':
        return '$d의 오늘의 운세 캘린더를 확인해볼게요~ 📅';
      case 'fortune-cookie':
        return '$d에게 행운의 메시지를 준비해볼게요~ 🥠';
      // ─── 무현 도사 (traditional) ───
      case 'face-reading':
        return '$d의 관상을 한번 봐드리겠습니다... 🔮';
      case 'naming':
        return '$d을 위한 좋은 이름을 찾아보겠습니다... ✍️👶';
      // ─── 스텔라 (zodiac) ───
      case 'zodiac':
        return '$d의 별자리 운세를 읽어볼게요~ ⭐';
      case 'zodiac-animal':
        return '$d의 띠별 운세를 확인해볼게요~ 🐾';
      case 'constellation':
        return '$d의 별자리 에너지를 분석해볼게요~ 🌟';
      case 'birthstone':
        return '$d의 탄생석 이야기를 들려드릴게요~ 💎';
      // ─── Dr. 마인드 (personality) ───
      case 'mbti':
        return '$d의 MBTI를 깊이 분석해볼게요~ 🧠';
      case 'personality-dna':
        return '$d의 성격 DNA를 분석해볼게요~ 🧬';
      case 'talent':
        return '$d의 숨겨진 재능을 찾아볼게요~ ✨';
      case 'past-life':
        return '$d의 전생의 흔적을 더듬어볼게요~ 🌀';
      // ─── 로제 (love) ───
      case 'love':
        return '$d의 연애운을 살펴볼게요~ 💕';
      case 'compatibility':
        return '$d의 궁합을 봐드릴게요~ 💞';
      case 'blind-date':
        return '$d의 소개팅 운을 살펴볼게요~ 💘';
      case 'ex-lover':
        return '$d의 재회 운세를 봐드릴게요... 💔';
      case 'avoid-people':
        return '$d이 주의해야 할 인연을 살펴볼게요~ ⚠️';
      case 'celebrity':
        return '$d의 유명인 궁합을 분석해볼게요~ 🌟';
      case 'yearly-encounter':
        return '$d의 올해 만남 운을 살펴볼게요~ 💫';
      // ─── 제임스 김 (career) ───
      case 'career':
        return '$d의 커리어 운세를 분석해드리겠습니다~ 💼';
      case 'wealth':
        return '$d의 재물운을 살펴보겠습니다~ 💰';
      case 'exam':
        return '$d의 시험운을 분석해드리겠습니다~ 📝';
      // ─── 럭키 (lucky) ───
      case 'lucky-items':
        return '$d의 오늘의 행운 아이템을 찾아볼게요~ 🍀';
      case 'lotto':
        return '$d의 행운의 숫자를 뽑아볼게요~ 🎰';
      case 'ootd-evaluation':
        return '$d의 오늘 패션을 평가해볼게요~ 👗';
      // ─── 마르코 (sports) ───
      case 'match-insight':
        return '$d을 위한 경기 인사이트를 준비해볼게요~ ⚽';
      case 'game-enhance':
        return '$d의 게임 운세를 살펴볼게요~ 🎮';
      case 'exercise':
        return '$d의 운동 운세를 확인해볼게요~ 💪';
      // ─── 리나 (fengshui) ───
      case 'moving':
        return '$d의 이사 풍수를 살펴보겠습니다~ 🏠';
      // ─── 루나 (special) ───
      case 'tarot':
        return '$d을 위해 타로 카드를 펼쳐볼게요~ 🃏';
      case 'dream':
        return '$d의 꿈을 해석해볼게요~ 🌙';
      case 'health':
        return '$d의 건강운을 살펴볼게요~ 🏥';
      case 'biorhythm':
        return '$d의 바이오리듬을 분석해볼게요~ 📊';
      case 'family':
        return '$d의 가족운을 살펴볼게요~ 👨‍👩‍👧‍👦';
      case 'pet-compatibility':
        return '$d의 반려동물 궁합을 봐드릴게요~ 🐾';
      case 'talisman':
        return '$d을 위한 부적을 만들어드릴게요~ 🧧';
      case 'wish':
        return '$d의 소원 성취 운세를 봐드릴게요~ ⭐';
      default:
        return '$d의 운세를 살펴볼게요~ ✨';
    }
  }

  /// 운세 타입별 관련 프로필 필드 집합 반환
  Set<String> _relevantFieldsFor(String fortuneType) {
    switch (fortuneType) {
      // 전통/사주 계열 (생년월일+시간+성별+띠)
      case 'face-reading':
      case 'naming':
        return {'birth', 'birthTime', 'gender', 'chineseZodiac'};
      // 별자리 계열
      case 'zodiac':
      case 'constellation':
        return {'birth', 'zodiac'};
      case 'zodiac-animal':
        return {'birth', 'chineseZodiac'};
      case 'birthstone':
        return {'birth'};
      // 성격/심리 계열
      case 'mbti':
        return {'mbti'};
      case 'personality-dna':
        return {'birth', 'mbti', 'bloodType'};
      case 'talent':
        return {'birth', 'mbti'};
      case 'past-life':
        return {'birth', 'gender'};
      // 연애 계열
      case 'love':
      case 'blind-date':
      case 'yearly-encounter':
      case 'celebrity':
        return {'birth', 'gender', 'zodiac'};
      case 'compatibility':
        return {'birth', 'birthTime', 'gender'};
      case 'ex-lover':
      case 'avoid-people':
        return {'birth', 'gender'};
      // 직업/재물 계열
      case 'career':
      case 'wealth':
      case 'exam':
        return {'birth', 'zodiac', 'chineseZodiac'};
      // 행운 계열
      case 'lucky-items':
      case 'lotto':
        return {'birth', 'zodiac', 'chineseZodiac'};
      case 'ootd-evaluation':
        return {};
      // 스포츠 계열
      case 'match-insight':
      case 'game-enhance':
        return {};
      case 'exercise':
        return {'birth', 'gender'};
      // 풍수
      case 'moving':
        return {'birth', 'birthTime', 'chineseZodiac'};
      // 특별 계열
      case 'tarot':
        return {'birth', 'zodiac'};
      case 'dream':
        return {};
      case 'health':
        return {'birth', 'gender', 'bloodType'};
      case 'biorhythm':
        return {'birth'};
      case 'family':
        return {'birth', 'chineseZodiac'};
      case 'pet-compatibility':
        return {};
      case 'talisman':
        return {'birth', 'birthTime', 'chineseZodiac'};
      case 'wish':
        return {'birth', 'zodiac'};
      // 라이프스타일
      case 'daily':
      case 'new-year':
        return {'birth', 'zodiac', 'chineseZodiac'};
      case 'daily-calendar':
        return {'birth', 'zodiac'};
      case 'fortune-cookie':
        return {};
      default:
        return {'birth', 'gender', 'zodiac', 'chineseZodiac'};
    }
  }

  /// 운세 타입별 관련 프로필 정보 라인 생성
  List<String> _getRelevantProfileLines(
      String fortuneType, UserProfile profile) {
    final lines = <String>[];
    final fields = _relevantFieldsFor(fortuneType);

    if (fields.contains('birth') && profile.birthDate != null) {
      final bd = profile.birthDate!;
      final lunarTag = profile.isLunarBirthdate == true ? ' (음력)' : '';
      lines.add('🎂 생년월일: ${bd.year}년 ${bd.month}월 ${bd.day}일$lunarTag');
    }
    if (fields.contains('birthTime')) {
      if (profile.birthTime != null && profile.birthTime!.isNotEmpty) {
        lines.add('🕐 태어난 시간: ${profile.birthTime}');
      } else if (profile.birthHour != null && profile.birthHour!.isNotEmpty) {
        lines.add('🕐 태어난 시간: ${profile.birthHour}시');
      }
    }
    if (fields.contains('gender') && profile.gender != Gender.other) {
      lines.add('👤 성별: ${profile.gender.label}');
    }
    if (fields.contains('chineseZodiac') && profile.chineseZodiac != null) {
      lines.add('🐾 띠: ${profile.chineseZodiac}');
    }
    if (fields.contains('zodiac') && profile.zodiacSign != null) {
      lines.add('⭐ 별자리: ${profile.zodiacSign}');
    }
    if (fields.contains('mbti') && profile.mbti != null) {
      lines.add('🧠 MBTI: ${profile.mbti}');
    }
    if (fields.contains('bloodType') && profile.bloodType != null) {
      lines.add('🩸 혈액형: ${profile.bloodType}형');
    }

    return lines;
  }

  /// 설문 답변 ID를 한국어 라벨로 변환
  String _resolveAnswerLabel(dynamic value) {
    if (value is String) {
      return _answerLabels[value] ?? value;
    }
    if (value is List) {
      return value
          .map((v) => _answerLabels[v.toString()] ?? v.toString())
          .join(', ');
    }
    return value.toString();
  }

  /// 설문 답변 라인 추가 헬퍼
  void _addSurveyLine(
    List<String> lines,
    Map<String, dynamic> answers,
    String key,
    String label,
  ) {
    final value = answers[key];
    if (value == null) return;
    final display = _resolveAnswerLabel(value);
    if (display.isNotEmpty) {
      lines.add('$label: $display');
    }
  }

  /// 운세 타입별 설문 답변 라인 생성
  List<String> _getSurveyAnswerLines(
    String fortuneType,
    Map<String, dynamic> answers,
  ) {
    final lines = <String>[];

    switch (fortuneType) {
      // ─── 로제 (love) ───
      case 'love':
        _addSurveyLine(lines, answers, 'status', '💕 연애 상태');
        _addSurveyLine(lines, answers, 'concern', '💫 궁금한 점');
        _addSurveyLine(lines, answers, 'datingStyle', '💝 연애 스타일');
        _addSurveyLine(lines, answers, 'idealPersonality', '✨ 이상형 성격');
        _addSurveyLine(lines, answers, 'idealLooks', '👀 이상형 외모');
        break;
      case 'compatibility':
        _addSurveyLine(lines, answers, 'partnerName', '👤 상대방');
        _addSurveyLine(lines, answers, 'relationship', '🤝 관계');
        break;
      case 'blind-date':
        _addSurveyLine(lines, answers, 'idealPersonality', '✨ 이상형 성격');
        _addSurveyLine(lines, answers, 'idealLooks', '👀 이상형 외모');
        _addSurveyLine(lines, answers, 'dealbreaker', '🚫 절대 안 되는 점');
        break;
      case 'ex-lover':
        _addSurveyLine(lines, answers, 'primaryGoal', '🎯 상담 목표');
        _addSurveyLine(lines, answers, 'breakupReason', '💔 이별 사유');
        _addSurveyLine(lines, answers, 'currentFeelings', '💭 현재 감정');
        _addSurveyLine(lines, answers, 'partnerContact', '📱 연락 상태');
        break;
      case 'avoid-people':
        _addSurveyLine(lines, answers, 'situation', '⚠️ 상황');
        break;
      case 'celebrity':
        _addSurveyLine(lines, answers, 'preference', '🌟 선호 스타일');
        break;
      case 'yearly-encounter':
        _addSurveyLine(lines, answers, 'preference', '💫 만남 선호');
        break;
      // ─── 제임스 김 (career) ───
      case 'career':
        _addSurveyLine(lines, answers, 'field', '💼 분야');
        _addSurveyLine(lines, answers, 'position', '🏢 직무');
        _addSurveyLine(lines, answers, 'experience', '📊 경력');
        _addSurveyLine(lines, answers, 'concern', '💫 고민');
        break;
      case 'wealth':
        _addSurveyLine(lines, answers, 'concern', '💰 재물 고민');
        break;
      case 'exam':
        _addSurveyLine(lines, answers, 'examType', '📝 시험 종류');
        _addSurveyLine(lines, answers, 'concern', '💫 고민');
        break;
      // ─── Dr. 마인드 (personality) ───
      case 'mbti':
        _addSurveyLine(lines, answers, 'mbtiType', '🧠 MBTI 유형');
        _addSurveyLine(lines, answers, 'category', '📂 분석 카테고리');
        break;
      case 'personality-dna':
        _addSurveyLine(lines, answers, 'focus', '🧬 분석 포인트');
        break;
      case 'talent':
        _addSurveyLine(lines, answers, 'interest', '🎯 관심 분야');
        _addSurveyLine(lines, answers, 'workStyle', '💼 작업 스타일');
        _addSurveyLine(lines, answers, 'thinkingStyle', '🧠 사고 방식');
        _addSurveyLine(lines, answers, 'experience', '📊 경험');
        _addSurveyLine(lines, answers, 'availability', '⏰ 투자 가능 시간');
        _addSurveyLine(lines, answers, 'challenge', '💪 어려운 점');
        break;
      case 'past-life':
        _addSurveyLine(lines, answers, 'curiosity', '🌀 궁금한 점');
        break;
      // ─── 루나 (special) ───
      case 'tarot':
        _addSurveyLine(lines, answers, 'purpose', '🔮 상담 주제');
        break;
      case 'dream':
        _addSurveyLine(lines, answers, 'dreamType', '💭 꿈 유형');
        _addSurveyLine(lines, answers, 'dreamContent', '📝 꿈 내용');
        break;
      case 'health':
        _addSurveyLine(lines, answers, 'concern', '🏥 건강 고민');
        break;
      case 'biorhythm':
        _addSurveyLine(lines, answers, 'concern', '📊 궁금한 점');
        break;
      case 'family':
        _addSurveyLine(lines, answers, 'concern', '👨‍👩‍👧‍👦 가족 고민');
        break;
      case 'pet-compatibility':
        _addSurveyLine(lines, answers, 'petType', '🐾 반려동물 종류');
        _addSurveyLine(lines, answers, 'petName', '💝 이름');
        break;
      case 'talisman':
        _addSurveyLine(lines, answers, 'purpose', '🧧 부적 목적');
        break;
      case 'wish':
        _addSurveyLine(lines, answers, 'wish', '⭐ 소원');
        break;
      // ─── 무현 도사 (traditional) ───
      case 'face-reading':
        _addSurveyLine(lines, answers, 'focus', '🔮 분석 포인트');
        break;
      case 'naming':
        _addSurveyLine(lines, answers, 'purpose', '✍️ 작명 목적');
        _addSurveyLine(lines, answers, 'babyDream', '🌙 태몽');
        break;
      // ─── 하늘 (lifestyle) ───
      case 'daily':
        _addSurveyLine(lines, answers, 'interest', '💫 관심사');
        break;
      case 'new-year':
        _addSurveyLine(lines, answers, 'goal', '🎯 새해 목표');
        break;
      case 'daily-calendar':
        _addSurveyLine(lines, answers, 'calendarSync', '📅 캘린더 연동');
        break;
      case 'fortune-cookie':
        _addSurveyLine(lines, answers, 'mood', '🥠 오늘 기분');
        break;
      // ─── 럭키 (lucky) ───
      case 'lucky-items':
        _addSurveyLine(lines, answers, 'category', '🍀 카테고리');
        break;
      case 'lotto':
        _addSurveyLine(lines, answers, 'style', '🎰 번호 스타일');
        break;
      case 'ootd-evaluation':
        _addSurveyLine(lines, answers, 'style', '👗 스타일');
        break;
      // ─── 마르코 (sports) ───
      case 'match-insight':
        _addSurveyLine(lines, answers, 'sport', '⚽ 종목');
        _addSurveyLine(lines, answers, 'team', '🏟️ 응원 팀');
        break;
      case 'game-enhance':
        _addSurveyLine(lines, answers, 'gameType', '🎮 게임 종류');
        _addSurveyLine(lines, answers, 'goal', '🎯 목표');
        break;
      case 'exercise':
        _addSurveyLine(lines, answers, 'goal', '🎯 운동 목표');
        _addSurveyLine(lines, answers, 'preference', '💪 선호 운동');
        break;
      // ─── 리나 (fengshui) ───
      case 'moving':
        _addSurveyLine(lines, answers, 'currentArea', '📍 현재 지역');
        _addSurveyLine(lines, answers, 'targetArea', '🏠 이사 지역');
        _addSurveyLine(lines, answers, 'movingPeriod', '📅 이사 시기');
        _addSurveyLine(lines, answers, 'purpose', '📦 이사 사유');
        break;
    }

    return lines;
  }

  /// 운세 타입별 마무리 메시지
  String _getIntroClosing(String fortuneType) {
    switch (fortuneType) {
      // ─── 하늘 (lifestyle) ───
      case 'daily':
        return '이 정보로 오늘의 운세 봐드릴게요! 잠시만요~ ✨';
      case 'new-year':
        return '새해 운세 꼼꼼히 봐드릴게요! 🎊';
      case 'daily-calendar':
        return '오늘의 운세 캘린더 준비할게요! 📅';
      case 'fortune-cookie':
        return '행운의 메시지 열어볼게요~ 🥠';
      // ─── 무현 도사 (traditional) ───
      case 'face-reading':
        return '관상을 살펴보겠습니다... 잠시만 기다려주십시오 🔮';
      case 'naming':
        return '좋은 이름과 태명을 찾아보겠습니다... ✍️👶';
      // ─── 스텔라 (zodiac) ───
      case 'zodiac':
        return '별자리의 메시지를 읽어드릴게요! ⭐';
      case 'zodiac-animal':
        return '띠별 운세를 자세히 봐드릴게요! 🐾';
      case 'constellation':
        return '별자리 에너지를 분석해드릴게요! 🌟';
      case 'birthstone':
        return '탄생석의 이야기를 전해드릴게요! 💎';
      // ─── Dr. 마인드 (personality) ───
      case 'mbti':
        return 'MBTI 심층 분석 시작할게요! 🧠';
      case 'personality-dna':
        return '성격 DNA 분석 들어갑니다! 🧬';
      case 'talent':
        return '숨겨진 재능을 발굴해볼게요! ✨';
      case 'past-life':
        return '전생의 기억을 더듬어볼게요... 🌀';
      // ─── 로제 (love) ───
      case 'love':
        return '연애운 꼼꼼히 봐드릴게요! 잠시만요~ 💕';
      case 'compatibility':
        return '궁합을 자세히 분석해드릴게요! 💞';
      case 'blind-date':
        return '소개팅 운세 분석 시작! 💘';
      case 'ex-lover':
        return '재회 운세를 정성스럽게 봐드릴게요... 💔';
      case 'avoid-people':
        return '조심해야 할 인연을 알려드릴게요! ⚠️';
      case 'celebrity':
        return '유명인 궁합 분석 중~ 🌟';
      case 'yearly-encounter':
        return '올해의 만남 운세 분석 시작! 💫';
      // ─── 제임스 김 (career) ───
      case 'career':
        return '커리어 운세 분석 시작하겠습니다! 💼';
      case 'wealth':
        return '재물운을 꼼꼼히 살펴보겠습니다! 💰';
      case 'exam':
        return '시험운 분석에 들어가겠습니다! 📝';
      // ─── 럭키 (lucky) ───
      case 'lucky-items':
        return '오늘의 행운 아이템 찾아볼게요~ 🍀';
      case 'lotto':
        return '행운의 숫자를 뽑아볼게요~ 🎰';
      case 'ootd-evaluation':
        return '패션 평가 시작! 👗';
      // ─── 마르코 (sports) ───
      case 'match-insight':
        return '경기 분석 시작할게요! ⚽';
      case 'game-enhance':
        return '게임 운세 분석 시작! 🎮';
      case 'exercise':
        return '운동 운세 확인해볼게요! 💪';
      // ─── 리나 (fengshui) ───
      case 'moving':
        return '이사 풍수를 정성껏 살펴보겠습니다~ 🏠';
      // ─── 루나 (special) ───
      case 'tarot':
        return '카드가 말해주는 이야기를 전해드릴게요~ 🃏';
      case 'dream':
        return '꿈의 의미를 해석해볼게요~ 🌙';
      case 'health':
        return '건강운을 꼼꼼히 살펴볼게요! 🏥';
      case 'biorhythm':
        return '바이오리듬 분석 시작! 📊';
      case 'family':
        return '가족운을 정성껏 봐드릴게요! 👨‍👩‍👧‍👦';
      case 'pet-compatibility':
        return '반려동물 궁합을 분석해볼게요! 🐾';
      case 'talisman':
        return '정성을 담아 부적을 만들어드릴게요! 🧧';
      case 'wish':
        return '소원 성취 운세 분석 시작! ⭐';
      default:
        return '운세 봐드릴게요! 잠시만 기다려주세요~ ✨';
    }
  }

  Map<String, dynamic> _buildAffinityContext() {
    return {
      'phase': state.affinity.phase.name,
      'lovePoints': state.affinity.lovePoints,
      'currentStreak': state.affinity.currentStreak,
    };
  }

  CharacterVoiceProfile get _voiceProfile =>
      CharacterVoiceProfileRegistry.profileFor(_characterId);

  bool get _isTonePolicyEnabledCharacter =>
      CharacterToneRollout.isEnabledCharacter(_characterId);

  bool get _isIdleIcebreakerEnabledCharacter =>
      CharacterToneRollout.isIdleIcebreakerEnabledCharacter(_characterId);

  CharacterToneProfile _buildToneProfile({String? currentUserMessage}) {
    if (!_isTonePolicyEnabledCharacter) return CharacterToneProfile.neutral;
    final profileMap = _getUserProfileMap();
    final knownUserName = profileMap?['name'] as String?;
    return CharacterTonePolicy.fromConversation(
      messages: state.messages,
      currentUserMessage: currentUserMessage,
      knownUserName: knownUserName,
    );
  }

  String _buildToneStyleGuidePrompt(CharacterToneProfile profile) {
    if (!_isTonePolicyEnabledCharacter) return '';
    final guardPrompt = CharacterTonePolicy.buildStyleGuidePrompt(
      profile,
      voiceProfile: _voiceProfile,
      affinityPhase: state.affinity.phase,
    );
    return '[CHARACTER_STYLE_GUARD_V1:$_characterId]\n$guardPrompt';
  }

  String _applyTemplateTone(
    String message, {
    CharacterToneProfile? profile,
  }) {
    if (!_isTonePolicyEnabledCharacter) return message;
    final resolvedProfile = profile ?? _buildToneProfile();
    return CharacterTonePolicy.applyTemplateTone(
      message,
      resolvedProfile,
      voiceProfile: _voiceProfile,
      affinityPhase: state.affinity.phase,
    );
  }

  String _applyGeneratedTone(
    String message, {
    CharacterToneProfile? profile,
    bool encourageContinuity = false,
  }) {
    if (!_isTonePolicyEnabledCharacter) return message;
    final resolvedProfile = profile ?? _buildToneProfile();
    return CharacterTonePolicy.applyGeneratedTone(
      message,
      resolvedProfile,
      voiceProfile: _voiceProfile,
      encourageContinuity: encourageContinuity,
      affinityPhase: state.affinity.phase,
    );
  }

  String _buildFirstMeetOpening() {
    if (_isTonePolicyEnabledCharacter) {
      const toneProfile = CharacterToneProfile.neutral;
      return _applyTemplateTone(
        CharacterTonePolicy.buildFirstMeetOpening(
          _character.name,
          toneProfile,
          voiceProfile: _voiceProfile,
          affinityPhase: state.affinity.phase,
        ),
        profile: toneProfile,
      );
    }

    final name = _character.name;
    return '안녕하세요, $name예요. 만나서 반가워요.';
  }

  bool _isFirstMeetThread([List<CharacterChatMessage>? messages]) {
    final source = messages ?? state.messages;
    CharacterChatMessage? firstCharacterMessage;

    for (final message in source) {
      if (message.type == CharacterChatMessageType.character) {
        firstCharacterMessage = message;
        break;
      }
    }

    if (firstCharacterMessage == null) return false;
    return firstCharacterMessage.text == _buildFirstMeetOpening();
  }

  int _assistantTurnCount([List<CharacterChatMessage>? messages]) {
    final source = messages ?? state.messages;
    return source
        .where((message) => message.type == CharacterChatMessageType.character)
        .length;
  }

  bool _isFirstMeetPhase(AffinityPhase phase) =>
      phase == AffinityPhase.stranger || phase == AffinityPhase.acquaintance;

  bool _shouldApplyFirstMeetMode([List<CharacterChatMessage>? messages]) {
    final source = messages ?? state.messages;
    return _isFirstMeetThread(source) &&
        _isFirstMeetPhase(state.affinity.phase) &&
        _assistantTurnCount(source) < 4;
  }

  bool _isCurrentChatActive() {
    final activeChatId = _ref.read(activeCharacterChatProvider);
    return activeChatId == _characterId;
  }

  bool _containsQuestion(String text) =>
      text.contains('?') || text.contains('？');

  bool _isQuestionLikeText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (_containsQuestion(trimmed)) return true;

    final koQuestionEnding = RegExp(
      r'(나요|까요|인가요|한가요|있나요|없나요|맞나요|될까요|할까요)$',
      caseSensitive: false,
    );
    final jaQuestionEnding = RegExp(
      r'(ですか|ますか|でしょうか|かな|の)$',
      caseSensitive: false,
    );
    final enQuestionStart = RegExp(
      r'^(who|what|when|where|why|how|do|does|did|is|are|am|can|could|would|will|should)\b',
      caseSensitive: false,
    );

    return koQuestionEnding.hasMatch(trimmed) ||
        jaQuestionEnding.hasMatch(trimmed) ||
        enQuestionStart.hasMatch(trimmed);
  }

  bool _isLowSignalIcebreakerIntent(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;
    if (_isQuestionLikeText(trimmed)) return false;

    final language = CharacterTonePolicy.detectLanguage(trimmed);
    final intent = CharacterTonePolicy.detectTurnIntent(
      text: trimmed,
      language: language,
    );

    return intent == CharacterTurnIntent.greeting ||
        intent == CharacterTurnIntent.gratitude ||
        intent == CharacterTurnIntent.shortReply;
  }

  bool _hasUnresolvedRecentUserQuestion() {
    for (var i = state.messages.length - 1; i >= 0; i--) {
      final message = state.messages[i];
      if (message.type != CharacterChatMessageType.user) continue;

      if (!_isQuestionLikeText(message.text)) {
        return false;
      }

      final hasCharacterReplyAfter = state.messages
          .skip(i + 1)
          .any((m) => m.type == CharacterChatMessageType.character);
      return !hasCharacterReplyAfter;
    }

    return false;
  }

  bool _isReadIdleCooldownActive() {
    if (_lastReadIdleIcebreakerSentAt == null) return false;
    final elapsed = DateTime.now().difference(_lastReadIdleIcebreakerSentAt!);
    return elapsed.inSeconds < 120;
  }

  bool _matchesReadIdleIcebreakerContext(CharacterChatMessage anchorMessage) {
    final anchorIndex =
        state.messages.indexWhere((m) => m.id == anchorMessage.id);
    if (anchorIndex < 0) return false;

    CharacterChatMessage? latestUserBeforeAnchor;
    var userCountBeforeAnchor = 0;
    for (var i = 0; i < anchorIndex; i++) {
      final message = state.messages[i];
      if (message.type != CharacterChatMessageType.user) continue;
      userCountBeforeAnchor += 1;
      latestUserBeforeAnchor = message;
    }

    // 아이스브레이킹은 대화 초반(사용자 0~1회 발화)에서만 사용.
    if (userCountBeforeAnchor >= 2) return false;
    if (latestUserBeforeAnchor == null) return true;

    return _isLowSignalIcebreakerIntent(latestUserBeforeAnchor.text);
  }

  void _cancelReadIdleIcebreaker() {
    _readIdleIcebreakerTimer?.cancel();
    _readIdleIcebreakerTimer = null;
    _pendingReadIdleAnchorMessageId = null;
  }

  CharacterChatMessage? _findLastCharacterMessage() {
    for (var i = state.messages.length - 1; i >= 0; i--) {
      final message = state.messages[i];
      if (message.type == CharacterChatMessageType.character) {
        return message;
      }
    }
    return null;
  }

  bool _shouldScheduleReadIdleIcebreaker(CharacterChatMessage anchorMessage) {
    if (!_isIdleIcebreakerEnabledCharacter) return false;
    if (!_isCurrentChatActive()) return false;
    if (!_isFirstMeetPhase(state.affinity.phase)) return false;
    if (_isUserDrafting) return false;
    if (anchorMessage.origin != MessageOrigin.aiReply) return false;
    if (_isQuestionLikeText(anchorMessage.text)) return false;
    if (_hasUnresolvedRecentUserQuestion()) return false;
    if (_isReadIdleCooldownActive()) return false;
    if (!_matchesReadIdleIcebreakerContext(anchorMessage)) return false;
    if (state.isTyping || state.isProcessing) return false;
    if (_lastReadIdleIcebreakerAnchorMessageId == anchorMessage.id) {
      return false;
    }
    return true;
  }

  void _scheduleReadIdleIcebreaker({
    required CharacterChatMessage anchorMessage,
  }) {
    _cancelReadIdleIcebreaker();
    if (!_shouldScheduleReadIdleIcebreaker(anchorMessage)) return;

    _pendingReadIdleAnchorMessageId = anchorMessage.id;
    _readIdleIcebreakerTimer = Timer(_readIdleIcebreakerDelay, () {
      unawaited(_sendReadIdleIcebreakerIfStillIdle(anchorMessage.id));
    });
  }

  void _scheduleReadIdleIcebreakerForReadEvent() {
    final anchorMessage = _findLastCharacterMessage();
    if (anchorMessage == null) return;
    _scheduleReadIdleIcebreaker(anchorMessage: anchorMessage);
  }

  Future<void> _sendReadIdleIcebreakerIfStillIdle(
      String anchorMessageId) async {
    if (!mounted) return;
    if (_pendingReadIdleAnchorMessageId != anchorMessageId) return;
    if (!_isCurrentChatActive()) return;
    if (_isUserDrafting) return;
    if (state.isTyping || state.isProcessing) return;
    if (_lastReadIdleIcebreakerAnchorMessageId == anchorMessageId) return;

    final anchorIndex =
        state.messages.indexWhere((m) => m.id == anchorMessageId);
    if (anchorIndex < 0) return;
    final anchorMessage = state.messages[anchorIndex];
    if (anchorMessage.origin != MessageOrigin.aiReply) return;
    if (!_matchesReadIdleIcebreakerContext(anchorMessage)) return;
    if (_hasUnresolvedRecentUserQuestion()) return;
    if (_isReadIdleCooldownActive()) return;

    final hasUserReplyAfterAnchor = state.messages
        .skip(anchorIndex + 1)
        .any((m) => m.type == CharacterChatMessageType.user);
    if (hasUserReplyAfterAnchor) return;

    final lastMessage = state.messages.isNotEmpty ? state.messages.last : null;
    if (lastMessage == null ||
        lastMessage.type != CharacterChatMessageType.character) {
      return;
    }

    final toneProfile = _buildToneProfile();
    final icebreaker = CharacterTonePolicy.buildReadIdleIcebreakerQuestion(
      toneProfile,
      voiceProfile: _voiceProfile,
      affinityPhase: state.affinity.phase,
      now: DateTime.now(),
      recentAssistantText: anchorMessage.text,
    );
    final normalized = _applyTemplateTone(
      icebreaker,
      profile: toneProfile,
    );
    if (normalized.isEmpty) return;

    _lastReadIdleIcebreakerAnchorMessageId = anchorMessageId;
    _lastReadIdleIcebreakerSentAt = DateTime.now();
    _pendingReadIdleAnchorMessageId = null;
    addCharacterMessage(
      normalized,
      scheduleReadIdleIcebreaker: false,
      origin: MessageOrigin.followUp,
    );
  }

  String _buildFirstMeetPrompt({required int introTurn}) {
    final safeIntroTurn = introTurn < 1 ? 1 : (introTurn > 4 ? 4 : introTurn);
    final String goal;
    if (safeIntroTurn == 1) {
      goal = '첫 인사 직후 단계: 사용자의 현재 관심사 한 가지를 듣고 가볍게 공감하세요.';
    } else if (safeIntroTurn == 2) {
      goal = '두 번째 단계: 사용자의 성향/대화 톤을 파악하는 질문 1개만 하세요.';
    } else if (safeIntroTurn == 3) {
      goal = '세 번째 단계: 관심사나 대화 선호를 확인하고 관계 기반은 최소로 유지하세요.';
    } else {
      goal = '네 번째 단계: 아이스브레이킹 마무리. 필요하면 본론으로 자연스럽게 전환하세요.';
    }

    return '''
[FIRST_MEET MODE - $_firstMeetConversationMode]
- 현재 introTurn: $safeIntroTurn
- 목표: $goal

필수 규칙:
1) 질문은 필요할 때만 0~1개 사용하세요.
2) 사전 관계/사건/공동 과거를 절대 가정하지 마세요.
3) 친밀 호칭 강요 금지. 기본 호칭은 중립적으로 유지하세요.
4) 초반 3~4턴은 소개/성향 파악 중심으로 진행하세요.
5) 사용자가 명시적으로 운세/문제 해결을 요청하면 즉시 본론으로 전환하세요.
6) 답변을 단절형 문장으로 끝내지 말고, 짧은 브릿지 문장이나 가벼운 질문으로 자연스럽게 이어가세요.
''';
  }

  /// 유저 메시지 추가
  void addUserMessage(String text) {
    _isUserDrafting = false;
    _cancelReadIdleIcebreaker();
    final message = CharacterChatMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, message],
      isProcessing: true,
    );

    // 사용자가 응답했으므로 Follow-up 타이머 취소
    _followUpScheduler.cancelFollowUp(_characterId);

    // DB 동기화 큐에 추가 (debounced)
    _queueForSync();
  }

  /// 사용자 이미지 메시지 전송 (OOTD, 관상 등)
  void sendImageMessage(String imagePath, {String? caption}) {
    _isUserDrafting = false;
    _cancelReadIdleIcebreaker();
    final message =
        CharacterChatMessage.userWithImage(imagePath, text: caption);
    state = state.copyWith(
      messages: [...state.messages, message],
      isProcessing: true,
    );

    // 사용자가 응답했으므로 Follow-up 타이머 취소
    _followUpScheduler.cancelFollowUp(_characterId);

    // DB 동기화 큐에 추가 (debounced)
    _queueForSync();

    // 이미지 분석 요청 (OOTD 등)
    _requestImageAnalysis(imagePath, caption);
  }

  /// 이미지 분석 요청 (캐릭터가 사진에 대해 응답)
  Future<void> _requestImageAnalysis(String imagePath, String? caption) async {
    // 캐릭터 타이핑 시작
    state = state.copyWith(isTyping: true, isCharacterTyping: true);

    try {
      // 1) 이미지를 base64로 변환
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('이미지 파일을 찾을 수 없습니다');
      }
      final bytes = await file.readAsBytes();
      final imageBase64 = base64Encode(bytes);

      // 2) 최근 메시지에서 TPO 추출
      final tpo = _extractTpoFromRecentMessages();

      // 3) 사용자 정보
      final userProfile = _getUserProfileMap();
      final userId = await _resolveFortuneUserId();

      if (!mounted) return;

      // 4) 안내 메시지 먼저 표시
      addCharacterMessage(
        '사진 잘 받았어요! 📸 분석해볼게요~',
        scheduleReadIdleIcebreaker: false,
        suppressNotification: true,
      );
      state = state.copyWith(isTyping: true, isCharacterTyping: true);

      // 5) fortune-ootd Edge Function 호출
      final response = await Supabase.instance.client.functions.invoke(
        'fortune-ootd',
        body: {
          'imageBase64': imageBase64,
          'tpo': tpo,
          'userId': userId,
          'userName': userProfile?['name'],
          'userGender': userProfile?['gender'],
        },
      );

      if (!mounted) return;

      final data = response.data;
      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'OOTD 분석에 실패했습니다');
      }

      // 6) 결과를 캐릭터 스타일 메시지로 변환
      final result = data['data'];
      final messages = _formatOotdResult(result, tpo);

      // 7) 멀티 버블로 전송
      for (int i = 0; i < messages.length; i++) {
        if (i > 0) {
          state = state.copyWith(isTyping: true, isCharacterTyping: true);
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
        }
        addCharacterMessage(
          messages[i],
          scheduleReadIdleIcebreaker: i == messages.length - 1,
          suppressNotification: i < messages.length - 1,
        );
      }
    } catch (e) {
      Logger.warning(
          '[CharacterChat] Image analysis failed', {'error': e.toString()});
      if (mounted) {
        addCharacterMessage(
          '앗, 사진 분석 중에 문제가 생겼어요 😅 다시 한번 보내주실래요?',
          scheduleReadIdleIcebreaker: true,
        );
      }
    }
  }

  /// 최근 메시지에서 TPO(상황) 키워드 추출
  String _extractTpoFromRecentMessages() {
    final recentMessages = state.messages
        .where((m) => m.type == CharacterChatMessageType.user)
        .toList()
        .reversed
        .take(5);

    final tpoKeywords = {
      'date': ['데이트', '소개팅', '만남'],
      'interview': ['면접', '인터뷰', '취업'],
      'work': ['출근', '회사', '직장', '사무실', '오피스'],
      'casual': ['일상', '캐주얼', '편한', '평소'],
      'party': ['파티', '모임', '행사', '축하'],
      'wedding': ['결혼식', '경조사', '돌잔치', '장례'],
      'travel': ['여행', '휴가', '관광'],
      'sports': ['운동', '헬스', '러닝', '조깅', '등산'],
    };

    for (final msg in recentMessages) {
      final text = msg.text.toLowerCase();
      for (final entry in tpoKeywords.entries) {
        for (final keyword in entry.value) {
          if (text.contains(keyword)) {
            return entry.key;
          }
        }
      }
    }

    return 'casual'; // 기본값
  }

  /// OOTD 분석 결과를 캐릭터 스타일 메시지로 포맷
  List<String> _formatOotdResult(Map<String, dynamic> result, String tpo) {
    final details = result['details'] as Map<String, dynamic>? ?? {};
    final score = result['score'] ?? details['overallScore'] ?? 0;
    final grade = details['overallGrade'] ?? 'B';
    final comment = details['overallComment'] ?? result['content'] ?? '';
    final highlights =
        (details['highlights'] as List<dynamic>?)?.cast<String>() ?? [];
    final suggestions =
        (details['softSuggestions'] as List<dynamic>?)?.cast<String>() ?? [];
    final styleKeywords =
        (details['styleKeywords'] as List<dynamic>?)?.cast<String>() ?? [];
    final celebrityMatch = details['celebrityMatch'] as Map<String, dynamic>?;

    final messages = <String>[];

    // 메시지 1: 총평 + 점수
    final gradeEmoji = switch (grade) {
      'S' => '🌟',
      'A' => '✨',
      'B' => '💫',
      _ => '🌱',
    };
    messages.add('$gradeEmoji 코디 점수: $score점 ($grade등급)\n\n$comment');

    // 메시지 2: 칭찬 포인트
    if (highlights.isNotEmpty) {
      final highlightText = highlights.map((h) => '💕 $h').join('\n');
      messages.add('오늘 코디의 포인트!\n\n$highlightText');
    }

    // 메시지 3: 스타일 키워드 + 제안
    final parts = <String>[];
    if (styleKeywords.isNotEmpty) {
      parts.add('🏷️ 스타일: ${styleKeywords.join(', ')}');
    }
    if (suggestions.isNotEmpty) {
      parts.add('\n💡 스타일링 팁\n${suggestions.map((s) => '• $s').join('\n')}');
    }
    if (celebrityMatch != null && celebrityMatch['name'] != null) {
      parts.add(
          '\n⭐ 셀럽 매칭: ${celebrityMatch['name']} (${celebrityMatch['similarity']}% 유사)\n${celebrityMatch['reason'] ?? ''}');
    }
    if (parts.isNotEmpty) {
      messages.add(parts.join('\n'));
    }

    return messages.isEmpty ? ['코디 분석 결과를 준비 중이에요!'] : messages;
  }

  /// 캐릭터 메시지 추가
  ///
  /// [suppressNotification] true이면 알림/Follow-up/동기화를 억제 (멀티 버블 중간 메시지용)
  void addCharacterMessage(
    String text, {
    int? affinityChange,
    bool scheduleReadIdleIcebreaker = true,
    MessageOrigin origin = MessageOrigin.aiReply,
    bool suppressNotification = false,
  }) {
    final message = CharacterChatMessage.character(
      text,
      _characterId,
      affinityChange: affinityChange,
      origin: origin,
    );
    final isCurrentChatActive = _isCurrentChatActive();
    final nextUnreadCount =
        isCurrentChatActive ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
      isCharacterTyping: false, // DM 목록에서 "입력 중..." 해제
      unreadCount: nextUnreadCount,
    );

    if (isCurrentChatActive) {
      _localService.saveLastReadTimestamp(_characterId);
    }

    if (!suppressNotification) {
      // 🆕 채팅방에 없으면 푸시 알림 + 진동 (카카오톡 스타일)
      _triggerNotificationIfNeeded(text);

      // 캐릭터 응답 후 Follow-up 스케줄 시작
      _startFollowUpSchedule();
    }

    if (scheduleReadIdleIcebreaker) {
      _scheduleReadIdleIcebreaker(anchorMessage: message);
    } else {
      _cancelReadIdleIcebreaker();
    }

    // DB 동기화 큐에 추가 (debounced)
    _queueForSync();
  }

  /// 사주 결과 비주얼 카드 메시지 추가 (구조화 데이터 포함)
  void addSajuResultMessage(Map<String, dynamic> sajuData) {
    final formatted = _formatValueForContext(sajuData).trim();
    final fallbackText = formatted.isEmpty ? '사주 분석 결과' : formatted;
    final message = CharacterChatMessage.character(
      fallbackText,
      _characterId,
      origin: MessageOrigin.aiReply,
      sajuData: sajuData,
    );
    final isCurrentChatActive = _isCurrentChatActive();
    final nextUnreadCount =
        isCurrentChatActive ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
      isCharacterTyping: false,
      unreadCount: nextUnreadCount,
    );

    if (isCurrentChatActive) {
      _localService.saveLastReadTimestamp(_characterId);
    }

    _triggerNotificationIfNeeded('사주 분석 결과');
    _startFollowUpSchedule();
    _queueForSync();
  }

  /// 운세 응답을 멀티 버블로 분할하여 순차 전달
  ///
  /// 1차: "---" 구분자로 분할 시도
  /// 2차: 콘텐츠 패턴 기반 강제 분할 (LLM이 구분자 미생성 시)
  /// 3차: 길이 기반 분할 (200자 이상이면 문장 단위로 2-4개)
  Future<void> _addSplitFortuneMessages(
    String fullResponse, {
    int? affinityChange,
    CharacterToneProfile? toneProfile,
  }) async {
    // 1차: "---" 구분자 분할 (tone 적용 전 raw 응답)
    var sections = fullResponse
        .split(RegExp(r'\n---\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 2차: 구분자 없으면 콘텐츠 패턴 기반 분할
    if (sections.length <= 1) {
      sections = _splitByContentPatterns(fullResponse);
    }

    // 3차: 패턴도 없으면 길이 기반 분할
    if (sections.length <= 1 && fullResponse.length > 200) {
      sections = _splitByLength(fullResponse);
    }

    // 그래도 1개 이하면 단일 메시지
    if (sections.length <= 1) {
      final toned = _applyGeneratedTone(fullResponse, profile: toneProfile);
      addCharacterMessage(toned, affinityChange: affinityChange);
      return;
    }

    for (int i = 0; i < sections.length; i++) {
      if (!mounted) return;

      final isLast = i == sections.length - 1;

      // 각 섹션별로 tone 적용 (enforceKakaoSingleBubble 포함)
      final tonedSection =
          _applyGeneratedTone(sections[i], profile: toneProfile);

      // 중간 메시지: 알림/Follow-up 억제, 호감도 없음
      // 마지막 메시지: 알림 O, 호감도 표시
      addCharacterMessage(
        tonedSection,
        affinityChange: isLast ? affinityChange : null,
        suppressNotification: !isLast,
        scheduleReadIdleIcebreaker: isLast,
      );

      // 마지막이 아니면 타이핑 딜레이 후 다음 섹션
      if (!isLast) {
        setTyping(true);
        await _waitForUiDelayIfNeeded(
          Duration(milliseconds: _calculateSectionDelay(sections[i].length)),
        );
        if (!mounted) return;
      }
    }
  }

  /// 운세 응답의 콘텐츠 패턴을 감지하여 섹션 분할
  ///
  /// 운세 결과에 자주 나타나는 헤딩/주제 패턴을 기준으로 분할
  List<String> _splitByContentPatterns(String text) {
    // 운세 응답에서 자주 사용되는 섹션 헤딩 패턴
    // 예: *오늘의 기운:, ❤️ 주의할 점:, 😊 행운 아이템:, [종합 점수] 등
    final sectionPattern = RegExp(
      r'\n(?='
      r'(?:\*|★|☆|●|◆|▶|►|■|□|💫|✨|🌟|⭐|💪|❤️|💛|💚|💜|🧡|💙|🖤|😊|😉|🤗|💕|🎯|📌|🔮|🌙|☀️|🌈|🍀|🎁|💎|👉|📍|🔑|💡|🎊|🎉|⚡|🔥|🌸|🌺|🏆|💰|📈|🙏|💖|🫶|💗)' // 이모지/마커로 시작
      r'|'
      r'(?:\[.+?\])' // [대괄호 헤딩]
      r'|'
      r'(?:오늘의\s*기운|종합|총평|럭키|행운\s*아이템|추천\s*사항|주의\s*사항|주의할\s*점|실천\s*포인트|시간대별|특별\s*팁|한줄\s*요약|조언)' // 한국어 헤딩
      r')',
      caseSensitive: false,
    );

    // 원본에서 매칭 위치 기반으로 섹션 재구성
    final matches = sectionPattern.allMatches(text).toList();
    if (matches.isEmpty) return [text.trim()];

    final sections = <String>[];

    // 첫 매칭 전 텍스트 (인삿말/도입부)
    final firstPart = text.substring(0, matches.first.start).trim();
    if (firstPart.isNotEmpty) {
      sections.add(firstPart);
    }

    // 각 매칭 구간
    for (int i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
      final section = text.substring(start, end).trim();
      if (section.isNotEmpty) {
        sections.add(section);
      }
    }

    // 너무 작은 섹션(30자 미만)은 이전 섹션에 병합
    final merged = <String>[];
    for (final section in sections) {
      if (merged.isNotEmpty && section.length < 30) {
        merged.last = '${merged.last}\n$section';
      } else {
        merged.add(section);
      }
    }

    // 최대 5개 섹션으로 제한 (너무 많으면 마지막에 합침)
    if (merged.length > 5) {
      final last = merged.sublist(4).join('\n');
      return [...merged.sublist(0, 4), last];
    }

    return merged.length > 1 ? merged : [text.trim()];
  }

  /// 긴 텍스트를 문장 단위로 2-4개 섹션으로 분할
  List<String> _splitByLength(String text) {
    // 문장 종결 패턴으로 분할
    final sentences = text.split(RegExp(r'(?<=[.!?。！？~♡♥])\s+')).toList();
    if (sentences.length <= 1) return [text.trim()];

    // 목표: 2-4개 섹션, 각 50자 이상
    final targetCount = (sentences.length / 3).ceil().clamp(2, 4);
    final sentencesPerSection = (sentences.length / targetCount).ceil();

    final sections = <String>[];
    for (int i = 0; i < sentences.length; i += sentencesPerSection) {
      final end = (i + sentencesPerSection).clamp(0, sentences.length);
      final section = sentences.sublist(i, end).join(' ').trim();
      if (section.isNotEmpty) {
        sections.add(section);
      }
    }

    return sections.length > 1 ? sections : [text.trim()];
  }

  /// 섹션 길이 기반 타이핑 딜레이 계산 (300-800ms)
  int _calculateSectionDelay(int sectionLength) {
    if (sectionLength < 50) return 300;
    if (sectionLength < 100) return 450;
    if (sectionLength < 200) return 600;
    return 800;
  }

  /// Proactive 메시지 추가 (점심 사진 등 시간대 기반 자발적 메시지)
  ///
  /// [message] CharacterChatMessage - 이미 생성된 proactive 메시지
  void addProactiveMessage(CharacterChatMessage message) {
    final toneProfile = _buildToneProfile();
    final normalizedMessage = _isTonePolicyEnabledCharacter
        ? message.copyWith(
            text: _applyTemplateTone(
              message.text,
              profile: toneProfile,
            ),
            origin: MessageOrigin.proactive,
          )
        : message.copyWith(origin: MessageOrigin.proactive);

    final isCurrentChatActive = _isCurrentChatActive();
    final nextUnreadCount =
        isCurrentChatActive ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      messages: [...state.messages, normalizedMessage],
      isTyping: false,
      isProcessing: false,
      isCharacterTyping: false,
      unreadCount: nextUnreadCount,
    );

    if (isCurrentChatActive) {
      _localService.saveLastReadTimestamp(_characterId);
    }

    // 🆕 채팅방에 없으면 푸시 알림 + 진동 (카카오톡 스타일)
    _triggerNotificationIfNeeded(normalizedMessage.text);

    _scheduleReadIdleIcebreaker(anchorMessage: normalizedMessage);

    // DB 동기화 큐에 추가
    _queueForSync();
  }

  /// 카카오톡 스타일 알림 트리거 (채팅방에 없을 때만)
  void _triggerNotificationIfNeeded(String messageText) {
    // 현재 열려있는 채팅방 확인
    final activeChatId = _ref.read(activeCharacterChatProvider);

    // 이 캐릭터의 채팅방에 있으면 알림 안함 (카카오톡 동작)
    if (activeChatId == _characterId) return;

    // 푸시 알림 + 진동
    CharacterMessageNotificationService().notifyNewMessage(
      characterId: _characterId,
      characterName: _character.name,
      messagePreview: messageText,
    );

    // 앱 아이콘 배지 업데이트 (전체 unread 합산)
    _updateTotalUnreadBadge();
  }

  /// 앱 아이콘 배지 숫자 업데이트 (전체 캐릭터 unread 합산)
  void _updateTotalUnreadBadge() {
    int total = 0;
    for (final char in _allCharacters) {
      try {
        final chatState = _ref.read(characterChatProvider(char.id));
        total += chatState.unreadCount;
      } catch (_) {
        // Provider 없는 경우 무시
      }
    }
    AppIconBadgeService.updateBadgeCount(total);
  }

  /// DB 동기화 큐에 메시지 추가 (debounced)
  void _queueForSync() {
    if (state.messages.isEmpty) return;

    // ⚡ 로컬 저장 (debounced 3초) - 스트리밍 중 매번 저장하지 않음
    _localService.saveConversationDebounced(_characterId, state.messages);

    // 서버 동기화 (debounced 3초)
    ChatSyncService.instance.queueForSync(
      chatId: _characterId,
      chatType: 'character',
      messages: state.messages.map((m) => m.toJson()).toList(),
    );
  }

  /// Follow-up 스케줄 시작
  void _startFollowUpSchedule() {
    final pattern = _character.behaviorPattern;

    _followUpScheduler.scheduleFollowUp(
      characterId: _characterId,
      pattern: pattern,
      onFollowUp: _handleFollowUp,
    );
  }

  /// Follow-up 콜백 처리
  void _handleFollowUp(int attemptNumber, String? message) {
    // Follow-up 메시지가 있으면 사용, 없으면 API 호출
    if (message != null && message.isNotEmpty) {
      _sendFollowUpMessage(message);
    } else {
      _generateFollowUpMessage(attemptNumber);
    }
  }

  /// 미리 정의된 Follow-up 메시지 전송
  Future<void> _sendFollowUpMessage(String message) async {
    // 타이핑 인디케이터
    setTyping(true);

    final toneProfile = _buildToneProfile();
    final normalizedMessage = _applyTemplateTone(
      message,
      profile: toneProfile,
    );

    // 캐릭터 응답 속도에 맞는 딜레이
    await _waitForUiDelayIfNeeded(_character.behaviorPattern.getTypingDelay());

    // 메시지 추가 (Follow-up이므로 새로운 스케줄은 시작하지 않음)
    final msg = await _buildFollowUpMessageWithOptionalMedia(
      normalizedMessage,
    );
    _appendFollowUpMessage(msg);
  }

  /// AI로 Follow-up 메시지 생성
  Future<void> _generateFollowUpMessage(int attemptNumber) async {
    setTyping(true);

    try {
      final toneProfile = _buildToneProfile();

      // 메시지 히스토리 준비
      final recentMessages = state.messages.length > 10
          ? state.messages.sublist(state.messages.length - 10)
          : state.messages;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // Follow-up 컨텍스트 추가
      final followUpPrompt = '''
[시스템: 사용자가 한동안 응답이 없습니다. 캐릭터답게 자연스럽게 먼저 말을 걸어주세요.
- 이것은 $attemptNumber번째 시도입니다.
- 너무 길게 말하지 말고, 짧고 자연스럽게 말해주세요.
- 캐릭터의 성격과 말투를 유지해주세요.]
''';

      final toneStylePrompt = _buildToneStyleGuidePrompt(toneProfile).trim();
      final enhancedSystemPrompt = [
        _character.systemPrompt,
        followUpPrompt,
        if (toneStylePrompt.isNotEmpty) toneStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedSystemPrompt,
        messages: history,
        userMessage: '[사용자 응답 대기 중]',
        modelPreference: _resolveModelPreference(),
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 타이핑 딜레이
      await _waitForUiDelayIfNeeded(
          _character.behaviorPattern.getTypingDelay());

      // 메시지 추가
      final msg = await _buildFollowUpMessageWithOptionalMedia(
        _applyGeneratedTone(
          response.response,
          profile: toneProfile,
        ),
      );
      _appendFollowUpMessage(msg);
    } catch (e) {
      setTyping(false);
      // Follow-up 실패는 무시 (필수 기능 아님)
    }
  }

  /// Follow-up 스케줄 취소
  void cancelFollowUp() {
    _followUpScheduler.cancelFollowUp(_characterId);
  }

  /// 대기 중인 유저 메시지에 대한 AI 응답 생성 (앱 재시작 시)
  Future<void> _generatePendingResponse() async {
    if (state.messages.isEmpty) return;

    final lastMessage = state.messages.last;
    // 마지막이 유저 메시지가 아니면 무시
    if (lastMessage.type != CharacterChatMessageType.user) return;

    // 이미 처리 중이면 무시
    if (state.isTyping || state.isProcessing) return;

    setTyping(true);

    try {
      final toneProfile =
          _buildToneProfile(currentUserMessage: lastMessage.text);
      final useFirstMeetMode = _shouldApplyFirstMeetMode();
      final introTurn = _assistantTurnCount();

      // 메시지 히스토리 준비 (마지막 유저 메시지 제외)
      final messagesWithoutLast = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutLast.length > 20
          ? messagesWithoutLast.sublist(messagesWithoutLast.length - 20)
          : messagesWithoutLast;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();
      final firstMeetPrompt =
          useFirstMeetMode ? _buildFirstMeetPrompt(introTurn: introTurn) : '';
      final toneStylePrompt = _buildToneStyleGuidePrompt(toneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        emojiInstruction,
        if (firstMeetPrompt.isNotEmpty) firstMeetPrompt,
        if (toneStylePrompt.isNotEmpty) toneStylePrompt,
      ].join('\n\n');

      // API 호출
      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: lastMessage.text,
        modelPreference: _resolveModelPreference(),
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
        conversationMode: useFirstMeetMode ? _firstMeetConversationMode : null,
        introTurn: useFirstMeetMode ? introTurn : null,
      );

      // 타이핑 딜레이
      await _waitForGeneratedReplyDelayIfNeeded(
        emotionTag: response.emotionTag,
        responseText: response.response,
      );

      _ackPendingUserMessagesBeforeCharacterReply();

      // 캐릭터 응답 추가
      addCharacterMessage(
        _applyGeneratedTone(
          response.response,
          profile: toneProfile,
        ),
      );
    } catch (e) {
      setError(e.toString());
    }
  }

  /// 시스템 메시지 추가
  void addSystemMessage(String text) {
    final message = CharacterChatMessage.system(text);
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  /// 타이핑 인디케이터 설정
  void setTyping(bool typing) {
    if (typing) {
      _cancelReadIdleIcebreaker();
    }
    state = state.copyWith(
      isTyping: typing,
      isCharacterTyping: typing, // DM 목록용
    );
  }

  /// 아직 읽지 않은 사용자 메시지를 모두 읽음 처리 (sent -> read)
  ///
  /// 연속 전송 시 이전 메시지의 "1"이 남는 현상을 막기 위해
  /// 마지막 하나가 아니라 pending 상태 전체를 정리합니다.
  void markPendingUserMessagesAsRead() {
    final now = DateTime.now();
    final messages = List<CharacterChatMessage>.from(state.messages);
    var hasChanged = false;

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.type == CharacterChatMessageType.user &&
          message.status == MessageStatus.sent) {
        messages[i] = message.copyWith(
          status: MessageStatus.read,
          readAt: now,
        );
        hasChanged = true;
      }
    }

    if (hasChanged) {
      state = state.copyWith(messages: messages);
      _queueForSync();
    }
  }

  void _ackPendingUserMessagesBeforeCharacterReply() {
    markPendingUserMessagesAsRead();
  }

  /// @deprecated Use [markPendingUserMessagesAsRead]
  void markLastUserMessageAsRead() => markPendingUserMessagesAsRead();

  /// 읽지 않은 메시지 수 초기화 (채팅방 진입 시)
  void clearUnreadCount() {
    state = state.copyWith(unreadCount: 0);
    // 마지막으로 읽은 시간 저장 (앱 재시작 후에도 유지)
    _localService.saveLastReadTimestamp(_characterId);
    _scheduleReadIdleIcebreakerForReadEvent();
  }

  void onUserDraftChanged(String draftText) {
    final hasDraft = draftText.trim().isNotEmpty;
    if (_isUserDrafting == hasDraft) return;

    _isUserDrafting = hasDraft;
    if (hasDraft) {
      _cancelReadIdleIcebreaker();
      return;
    }

    _scheduleReadIdleIcebreakerForReadEvent();
  }

  /// 읽지 않은 메시지 수 증가 (캐릭터 메시지 도착 시, 채팅방 밖에서)
  void incrementUnreadCount() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);
  }

  /// 처리 중 상태 설정
  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(
      error: error,
      isTyping: false,
      isProcessing: false,
    );
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 레거시 대화 초기화 (비동기 정리 API로 위임)
  void clearConversation() {
    unawaited(clearConversationData());
  }

  /// 대화/호감도/서버 스레드까지 포함한 명시적 초기화
  Future<void> clearConversationData() async {
    _cancelReadIdleIcebreaker();
    cancelFollowUp();

    await _service.deleteConversation(_characterId);
    await _affinityService.deleteAffinity(
      _characterId,
      deleteFromServer: true,
    );

    // 서버 동기화 큐에도 빈 메시지를 반영해 레이스 조건을 줄임
    await ChatSyncService.instance.queueForSync(
      chatId: _characterId,
      chatType: 'character',
      messages: const <Map<String, dynamic>>[],
    );

    final selectedCharacter = _ref.read(selectedCharacterProvider);
    if (selectedCharacter?.id == _characterId) {
      _ref.read(activeCharacterChatProvider.notifier).state = null;
      _ref.read(chatModeProvider.notifier).state = ChatMode.fortune;
      _ref.read(selectedCharacterProvider.notifier).state = null;
    }

    state = CharacterChatState(characterId: _characterId);
  }

  /// 호감도 업데이트 (기존 호환용)
  void updateAffinity(AffinityEvent event) {
    updateAffinityWithPoints(event.points, event.interactionType);
  }

  /// 호감도 업데이트 (동적 포인트 지원)
  void updateAffinityWithPoints(int points,
      [AffinityInteractionType interactionType =
          AffinityInteractionType.neutral]) {
    final previousPhase = state.affinity.phase;
    final newAffinity = state.affinity.addPointsWithTracking(
      points,
      interactionType: interactionType,
    );
    state = state.copyWith(affinity: newAffinity);

    // 단계 전환 감지
    if (newAffinity.phase != previousPhase &&
        newAffinity.phase.index > previousPhase.index) {
      _onPhaseTransition(previousPhase, newAffinity.phase);
    }

    // 백그라운드에서 저장 (debounced)
    _affinityService.saveAffinity(_characterId, newAffinity,
        syncToServer: true);
  }

  /// 단계 전환 시 호출
  void _onPhaseTransition(AffinityPhase previousPhase, AffinityPhase newPhase) {
    final transition = PhaseTransitionResult(
      previousPhase: previousPhase,
      newPhase: newPhase,
    );

    // 축하 메시지를 시스템 메시지로 추가
    if (transition.isUpgrade && transition.celebrationMessage.isNotEmpty) {
      final systemMessage = CharacterChatMessage.system(
        '🎉 ${transition.celebrationMessage}\n✨ ${transition.unlockDescription}',
      );
      state = state.copyWith(
        messages: [...state.messages, systemMessage],
      );
    }
  }

  /// 호감도 직접 설정 (불러오기용)
  void setAffinity(CharacterAffinity affinity) {
    state = state.copyWith(affinity: affinity);
  }

  /// 메시지 전송 (API 호출 포함) - 인스타그램 DM 스타일 딜레이 적용
  Future<void> sendMessage(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return Future.value();

    // 🪙 토큰 소비 체크 (즉시 실행 - UI 차단 전에 확인)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);

    // 유저 메시지를 즉시 UI에 반영 (큐 대기 없이)
    addUserMessage(normalized);

    _sendQueue = _sendQueue.then((_) async {
      try {
        await _sendMessageInternal(normalized, hasUnlimitedAccess);
      } catch (e) {
        Logger.error('[CharacterChat] send queue failed', e);
      }
    });
    return _sendQueue;
  }

  Future<void> _sendMessageInternal(
      String text, bool hasUnlimitedAccess) async {
    if (text.trim().isEmpty) return;

    // 🪙 토큰 소비 체크 (4토큰/메시지)
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 1단계: 유저 메시지는 이미 sendMessage()에서 추가됨

    // 2단계: 읽음 딜레이 (0.5~1.5초) - AI가 메시지를 "봤다"는 느낌
    await _waitForReadDelayIfNeeded();

    // 3단계: 읽음 처리 → pending "1" 전체 정리
    markPendingUserMessagesAsRead();

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      final toneProfile = _buildToneProfile(currentUserMessage: text);
      final useFirstMeetMode = _shouldApplyFirstMeetMode();
      final introTurn = _assistantTurnCount();

      // 메시지 히스토리 준비 (최근 20개, 방금 추가한 사용자 메시지 제외)
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();
      final firstMeetPrompt =
          useFirstMeetMode ? _buildFirstMeetPrompt(introTurn: introTurn) : '';
      final toneStylePrompt = _buildToneStyleGuidePrompt(toneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        emojiInstruction,
        if (firstMeetPrompt.isNotEmpty) firstMeetPrompt,
        if (toneStylePrompt.isNotEmpty) toneStylePrompt,
      ].join('\n\n');

      // API 호출
      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: text,
        modelPreference: _resolveModelPreference(),
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
        conversationMode: useFirstMeetMode ? _firstMeetConversationMode : null,
        introTurn: useFirstMeetMode ? introTurn : null,
      );

      // 5단계: 감정 기반 타이핑 딜레이 (클라이언트 측)
      await _waitForGeneratedReplyDelayIfNeeded(
        emotionTag: response.emotionTag,
        responseText: response.response,
      );

      // 호감도 포인트 계산 (애니메이션용)
      final affinityPoints = response.affinityDelta.points;
      final normalizedResponse = _applyGeneratedTone(
        response.response,
        profile: toneProfile,
        encourageContinuity: useFirstMeetMode,
      );

      _ackPendingUserMessagesBeforeCharacterReply();

      // 6단계: 캐릭터 응답 추가 (호감도 변경값 포함)
      addCharacterMessage(normalizedResponse, affinityChange: affinityPoints);

      // 호감도 동적 업데이트 (AI 평가 기반)
      final interactionType = response.affinityDelta.isPositive
          ? AffinityInteractionType.positive
          : response.affinityDelta.isNegative
              ? AffinityInteractionType.negative
              : AffinityInteractionType.neutral;
      updateAffinityWithPoints(affinityPoints, interactionType);
    } catch (e) {
      setError(e.toString());
    }
  }

  /// 첫 메시지로 대화 시작 (unreadCount 증가 없이 - 사용자가 채팅방에 있으므로)
  void startConversation([String? legacyFirstMessage]) {
    if (legacyFirstMessage != null) {
      // 하위 호환: 전달값이 있더라도 first-meet 시작 문구를 항상 사용합니다.
    }
    if (state.messages.isEmpty) {
      final message = CharacterChatMessage.character(
          _buildFirstMeetOpening(), _characterId);
      state = state.copyWith(
        messages: [...state.messages, message],
        // unreadCount는 증가시키지 않음 - 사용자가 이미 채팅방에 있음
      );
    }
  }

  /// 운세 상담 요청 (운세 전문가 캐릭터용)
  /// 실제 운세 API를 호출하여 상세한 운세 데이터를 가져온 후, 캐릭터가 전달
  Future<void> sendFortuneRequest(
      String fortuneType, String requestMessage) async {
    // 🪙 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 1단계: 유저 메시지 추가
    addUserMessage(requestMessage);

    // 2단계: 읽음 딜레이
    await _waitForReadDelayIfNeeded();

    // 3단계: 읽음 처리
    markPendingUserMessagesAsRead();

    // 3.5단계: 신상정보 인트로 메시지 (운세 보기 전 사용자 정보 열거)
    final introMessage = _buildFortuneIntroMessage(fortuneType);
    if (introMessage != null) {
      setTyping(true);
      await _waitForUiDelayIfNeeded(const Duration(milliseconds: 800));
      setTyping(false);
      addCharacterMessage(introMessage);
      await _waitForUiDelayIfNeeded(const Duration(milliseconds: 500));
    }

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      final toneProfile = _buildToneProfile(currentUserMessage: requestMessage);
      // 🆕 실제 운세 API 호출하여 상세 데이터 가져오기
      final fortuneData = await _fetchFortuneData(fortuneType, {});
      final fortuneDataContext = _formatFortuneDataForContext(fortuneData);

      // 🆕 사주 타입이면 pillar 표를 맨 앞에 추가
      String enrichedContext = fortuneDataContext;
      Logger.info('[SajuTable] sendFortuneRequest fortuneType=$fortuneType');
      if (fortuneType == 'traditional-saju') {
        // sajuProvider에 데이터가 없으면 먼저 로드
        if (_ref.read(sajuProvider).sajuData == null) {
          Logger.info('[SajuTable] sajuData null → fetchUserSaju() 호출');
          await _ref.read(sajuProvider.notifier).fetchUserSaju();
        }
        final sajuTable = _formatSajuPillarTable();
        Logger.info(
            '[SajuTable] sendFortuneRequest sajuTable.length=${sajuTable.length}');
        if (sajuTable.isNotEmpty) {
          enrichedContext = '$sajuTable\n\n$fortuneDataContext';
          Logger.info('[SajuTable] enrichedContext에 사주 표 추가 완료');
        }
      }

      // 메시지 히스토리 준비
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();

      // 운세 상담: 시스템 프롬프트에는 간단한 지시, 유저 메시지에 운세 데이터 포함
      // (LLM이 시스템 프롬프트의 운세 데이터를 무시하는 문제 해결)
      var fortuneSystemInstruction = '''
[운세 상담 모드]
이번 메시지는 운세 상담 요청입니다. 유저 메시지 안에 운세 분석 결과 데이터가 포함되어 있습니다.
반드시 해당 데이터를 상세하게 전달하세요. 한 줄 요약은 절대 금지입니다.
최소 200자 이상으로 점수, 본문, 행운 아이템, 추천/주의 사항을 모두 포함하세요.

[중요: 말풍선 분리 규칙]
응답을 주제별로 나누어 각 섹션 사이에 반드시 "---" 구분자를 넣어주세요.
예시 구조:
- 종합 점수/요약
---
- 본문 상세 해석
---
- 행운 아이템/럭키 포인트
---
- 추천 사항 & 주의 사항
각 섹션은 자연스러운 대화체로, 하나의 독립된 메시지처럼 작성하세요.
"---"는 반드시 줄 맨 앞에 단독으로 적어주세요.
$emojiInstruction
''';

      // 🆕 사주 타입 전용 시스템 지시문
      if (fortuneType == 'traditional-saju') {
        fortuneSystemInstruction += '''
사주팔자 명식 표가 포함되어 있습니다. 반드시 이 표를 먼저 보여주고,
각 주(柱)의 천간/지지/오행 의미를 해석해주세요.
사주 명식 → 오행 분석 → 질문 답변 순서로 진행하세요.
''';
      }

      // 🆕 새해 운세 전용 시스템 지시문
      if (fortuneType == 'new-year') {
        fortuneSystemInstruction += '''

[새해 운세 응답 구조]
반드시 아래 순서로 섹션을 나누어 "---" 구분자와 함께 응답하세요:

1. 🎊 인사말 + 종합 점수 (greeting, overallScore)
---
2. 🎯 새해 목표 운세 (goalFortune - 목표별 예측, 좋은 시기, 행동 지침)
---
3. ✨ 사주 오행 분석 (sajuAnalysis - 오행 궁합, 기운 조언)
---
4. 🍀 행운 요소 (luckyItems - 색상, 숫자, 방향, 아이템)
---
5. 💪 추천 사항 & 행동 계획 (recommendations, actionPlan)

각 섹션은 데이터를 친근하게 풀어서 설명해주세요.
월별 하이라이트(monthlyHighlights)는 필요시 관련 섹션에 자연스럽게 녹여주세요.
''';
      }

      // 운세 데이터를 유저 메시지에 직접 포함 (LLM이 가장 주목하는 위치)
      final fortuneUserMessage = '''
$requestMessage

아래는 나의 실제 운세 분석 결과야. 이 데이터를 바탕으로 상세하게 알려줘:

$enrichedContext

위 운세 데이터의 점수, 내용, 행운 아이템, 추천 사항, 주의 사항을 빠짐없이 자세하게 전달해줘.
''';

      final toneStylePrompt = _buildToneStyleGuidePrompt(toneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        fortuneSystemInstruction,
        if (toneStylePrompt.isNotEmpty) toneStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: fortuneUserMessage,
        modelPreference: _resolveModelPreference(),
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 5단계: 감정 기반 타이핑 딜레이
      await _waitForGeneratedReplyDelayIfNeeded(
        emotionTag: response.emotionTag,
        responseText: response.response,
      );

      // 호감도 포인트 계산 (애니메이션용)
      final affinityPoints = response.affinityDelta.points;

      _ackPendingUserMessagesBeforeCharacterReply();

      // 6단계: 캐릭터 응답을 멀티 버블로 분할 전달
      // raw response를 먼저 분할 → 각 섹션에 tone 적용
      // (tone 적용 시 enforceKakaoSingleBubble이 줄바꿈을 제거하므로)
      await _addSplitFortuneMessages(
        response.response,
        affinityChange: affinityPoints,
        toneProfile: toneProfile,
      );

      // 호감도 동적 업데이트 (AI 평가 기반)
      final interactionType = response.affinityDelta.isPositive
          ? AffinityInteractionType.positive
          : response.affinityDelta.isNegative
              ? AffinityInteractionType.negative
              : AffinityInteractionType.neutral;
      updateAffinityWithPoints(affinityPoints, interactionType);
    } catch (e) {
      Logger.error('[CharacterChat] Fortune request failed', e);
      setError(e.toString());
    }
  }

  /// 운세 상담 요청 (설문 답변 포함 - 캐릭터가 설문 결과 기반으로 상담)
  /// 실제 운세 API를 호출하여 상세한 운세 데이터를 가져온 후, 캐릭터가 전달
  Future<void> sendFortuneRequestWithAnswers(
    String fortuneType,
    String requestMessage,
    Map<String, dynamic> surveyAnswers,
  ) async {
    // 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 1단계: 유저 메시지 추가
    addUserMessage(requestMessage);

    // 2단계: 읽음 딜레이
    await _waitForReadDelayIfNeeded();

    // 3단계: 읽음 처리
    markPendingUserMessagesAsRead();

    // 3.5단계: 신상정보 인트로 메시지 (운세 보기 전 사용자 정보 + 설문 답변 열거)
    final introMessage = _buildFortuneIntroMessage(
      fortuneType,
      surveyAnswers: surveyAnswers,
    );
    if (introMessage != null) {
      setTyping(true);
      await _waitForUiDelayIfNeeded(const Duration(milliseconds: 800));
      setTyping(false);
      addCharacterMessage(introMessage);
      await _waitForUiDelayIfNeeded(const Duration(milliseconds: 500));
    }

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      final toneProfile = _buildToneProfile(currentUserMessage: requestMessage);
      // 🆕 실제 운세 API 호출하여 상세 데이터 가져오기 (설문 답변 포함)
      final fortuneData = await _fetchFortuneData(fortuneType, surveyAnswers);
      final fortuneDataContext = _formatFortuneDataForContext(fortuneData);

      // 🆕 사주 타입이면 pillar 표를 맨 앞에 추가
      String enrichedContext = fortuneDataContext;
      Logger.info(
          '[SajuTable] sendFortuneRequestWithAnswers fortuneType=$fortuneType');
      if (fortuneType == 'traditional-saju') {
        // sajuProvider에 데이터가 없으면 먼저 로드
        if (_ref.read(sajuProvider).sajuData == null) {
          Logger.info(
              '[SajuTable] sajuData null → fetchUserSaju() 호출 (WithAnswers)');
          await _ref.read(sajuProvider.notifier).fetchUserSaju();
        }
        final sajuTable = _formatSajuPillarTable();
        Logger.info(
            '[SajuTable] WithAnswers sajuTable.length=${sajuTable.length}');
        if (sajuTable.isNotEmpty) {
          enrichedContext = '$sajuTable\n\n$fortuneDataContext';
          Logger.info('[SajuTable] WithAnswers enrichedContext에 사주 표 추가 완료');
        }
      }

      // 메시지 히스토리 준비
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();

      // 설문 답변을 사람이 읽기 쉬운 형식으로 변환
      final answersDescription = _formatSurveyAnswers(surveyAnswers);

      // 운세 상담: 시스템 프롬프트에는 간단한 지시, 유저 메시지에 운세 데이터 포함
      var fortuneSystemInstruction = '''
[운세 상담 모드]
이번 메시지는 운세 상담 요청입니다. 유저 메시지 안에 운세 분석 결과 데이터가 포함되어 있습니다.
반드시 해당 데이터를 상세하게 전달하세요. 한 줄 요약은 절대 금지입니다.
최소 200자 이상으로 점수, 본문, 행운 아이템, 추천/주의 사항을 모두 포함하세요.
사용자의 설문 답변을 언급하면서 더 친근하고 맞춤화된 조언을 해주세요.

[중요: 말풍선 분리 규칙]
응답을 주제별로 나누어 각 섹션 사이에 반드시 "---" 구분자를 넣어주세요.
예시 구조:
- 종합 점수/요약
---
- 본문 상세 해석
---
- 행운 아이템/럭키 포인트
---
- 추천 사항 & 주의 사항
각 섹션은 자연스러운 대화체로, 하나의 독립된 메시지처럼 작성하세요.
"---"는 반드시 줄 맨 앞에 단독으로 적어주세요.
$emojiInstruction
''';

      // 🆕 사주 타입 전용 시스템 지시문
      if (fortuneType == 'traditional-saju') {
        fortuneSystemInstruction += '''
사주팔자 명식 표가 포함되어 있습니다. 반드시 이 표를 먼저 보여주고,
각 주(柱)의 천간/지지/오행 의미를 해석해주세요.
사주 명식 → 오행 분석 → 질문 답변 순서로 진행하세요.
''';
      }

      // 🆕 새해 운세 전용 시스템 지시문
      if (fortuneType == 'new-year') {
        fortuneSystemInstruction += '''

[새해 운세 응답 구조]
반드시 아래 순서로 섹션을 나누어 "---" 구분자와 함께 응답하세요:

1. 🎊 인사말 + 종합 점수 (greeting, overallScore)
---
2. 🎯 새해 목표 운세 (goalFortune - 목표별 예측, 좋은 시기, 행동 지침)
---
3. ✨ 사주 오행 분석 (sajuAnalysis - 오행 궁합, 기운 조언)
---
4. 🍀 행운 요소 (luckyItems - 색상, 숫자, 방향, 아이템)
---
5. 💪 추천 사항 & 행동 계획 (recommendations, actionPlan)

각 섹션은 데이터를 친근하게 풀어서 설명해주세요.
월별 하이라이트(monthlyHighlights)는 필요시 관련 섹션에 자연스럽게 녹여주세요.
''';
      }

      // 운세 데이터를 유저 메시지에 직접 포함 (LLM이 가장 주목하는 위치)
      final fortuneUserMessage = '''
$requestMessage

내가 답한 설문 내용:
$answersDescription

아래는 나의 실제 운세 분석 결과야. 이 데이터를 바탕으로 상세하게 알려줘:

$enrichedContext

위 운세 데이터의 점수, 내용, 행운 아이템, 추천 사항, 주의 사항을 빠짐없이 자세하게 전달해줘.
''';

      final toneStylePrompt = _buildToneStyleGuidePrompt(toneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        fortuneSystemInstruction,
        if (toneStylePrompt.isNotEmpty) toneStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: fortuneUserMessage,
        modelPreference: _resolveModelPreference(),
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 5단계: 감정 기반 타이핑 딜레이
      await _waitForGeneratedReplyDelayIfNeeded(
        emotionTag: response.emotionTag,
        responseText: response.response,
      );

      // 호감도 포인트 계산 (애니메이션용)
      final affinityPoints = response.affinityDelta.points;

      _ackPendingUserMessagesBeforeCharacterReply();

      // 6단계: 캐릭터 응답을 멀티 버블로 분할 전달
      // raw response를 먼저 분할 → 각 섹션에 tone 적용
      await _addSplitFortuneMessages(
        response.response,
        affinityChange: affinityPoints,
        toneProfile: toneProfile,
      );

      // 호감도 동적 업데이트 (AI 평가 기반)
      final interactionType = response.affinityDelta.isPositive
          ? AffinityInteractionType.positive
          : response.affinityDelta.isNegative
              ? AffinityInteractionType.negative
              : AffinityInteractionType.neutral;
      updateAffinityWithPoints(affinityPoints, interactionType);
    } catch (e) {
      Logger.error('[CharacterChat] Fortune request with answers failed', e);
      setError(e.toString());
    }
  }

  /// 설문 답변을 사람이 읽기 쉬운 형식으로 변환
  String _formatSurveyAnswers(Map<String, dynamic> answers) {
    if (answers.isEmpty) return '(설문 답변 없음)';

    final buffer = StringBuffer();
    for (final entry in answers.entries) {
      final key = entry.key;
      final value = entry.value;

      if (_isImageAnswerEntry(key, value)) {
        buffer.writeln('  - $key: 사진 업로드 완료');
        continue;
      }

      // 값 형식에 따라 처리
      String formattedValue;
      if (value is List) {
        formattedValue = value.join(', ');
      } else if (value is Map) {
        formattedValue =
            value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      } else {
        formattedValue = value.toString();
      }

      buffer.writeln('  - $key: $formattedValue');
    }
    return buffer.toString();
  }

  bool _isImageAnswerEntry(String key, dynamic value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey == 'photo' || lowerKey == 'imagepath' || lowerKey == 'image') {
      return true;
    }

    if (value is Map<String, dynamic>) {
      return value.containsKey('imagePath') || value.containsKey('image');
    }

    if (value is Map) {
      return value.containsKey('imagePath') || value.containsKey('image');
    }

    return false;
  }

  Future<Map<String, dynamic>> _normalizeSurveyAnswersForApi(
    String apiFortuneType,
    Map<String, dynamic> answers,
  ) async {
    final normalizedAnswers = Map<String, dynamic>.from(answers);

    // ─── naming: 설문 필드 → API 필드 매핑 ───
    if (apiFortuneType == 'naming') {
      final userProfile = _getUserProfileMap();

      // motherBirthDate: 사용자(엄마) 생년월일
      if (userProfile?['birthDate'] != null) {
        normalizedAnswers['motherBirthDate'] = userProfile!['birthDate'];
      }
      if (userProfile?['birthTime'] != null) {
        normalizedAnswers['motherBirthTime'] = userProfile!['birthTime'];
      }

      // expectedBirthDate: 예정일 (dueDate → expectedBirthDate)
      if (normalizedAnswers.containsKey('dueDate')) {
        normalizedAnswers['expectedBirthDate'] = normalizedAnswers['dueDate'];
        normalizedAnswers.remove('dueDate');
      }

      // babyGender: 아기 성별 (gender → babyGender)
      if (normalizedAnswers.containsKey('gender')) {
        normalizedAnswers['babyGender'] = normalizedAnswers['gender'];
        normalizedAnswers.remove('gender');
      }

      // familyName: 성씨 (lastName → familyName)
      if (normalizedAnswers.containsKey('lastName')) {
        normalizedAnswers['familyName'] = normalizedAnswers['lastName'];
        normalizedAnswers.remove('lastName');
      }

      // nameStyle: 이름 스타일 (style → nameStyle)
      if (normalizedAnswers.containsKey('style')) {
        normalizedAnswers['nameStyle'] = normalizedAnswers['style'];
        normalizedAnswers.remove('style');
      }

      // 불필요한 필드 제거
      normalizedAnswers.remove('dueDateKnown');

      return normalizedAnswers;
    }

    // ─── career: 설문 필드 → API 필드 매핑 ───
    if (apiFortuneType == 'career') {
      // field + position → currentRole 매핑
      const fieldLabels = {
        'tech': 'IT/개발',
        'finance': '금융/재무',
        'healthcare': '의료/헬스케어',
        'education': '교육',
        'creative': '크리에이티브',
        'marketing': '마케팅/광고',
        'sales': '영업/세일즈',
        'hr': '인사/HR',
        'legal': '법률/법무',
        'manufacturing': '제조/생산',
        'other': '기타',
      };

      const positionLabels = {
        // tech
        'frontend': '프론트엔드 개발자',
        'backend': '백엔드 개발자',
        'fullstack': '풀스택 개발자',
        'mobile': '모바일 개발자',
        'data': '데이터/AI 엔지니어',
        'devops': 'DevOps 엔지니어',
        'pm': 'PM/PO',
        // finance
        'analyst': '애널리스트',
        'accountant': '회계사',
        'banker': '은행원',
        'trader': '트레이더',
        'auditor': '감사',
        // healthcare
        'doctor': '의사',
        'nurse': '간호사',
        'pharmacist': '약사',
        'researcher': '연구원',
        'admin': '행정',
        // education
        'teacher': '교사',
        'professor': '교수',
        'tutor': '강사',
        // creative
        'designer': '디자이너',
        'writer': '작가/카피라이터',
        'photographer': '포토그래퍼',
        'director': '감독/PD',
        // marketing
        'marketer': '마케터',
        'planner': '기획자',
        'brand': '브랜드 매니저',
        'performance': '퍼포먼스 마케터',
        // sales
        'sales_rep': '영업 담당자',
        'account': '어카운트 매니저',
        'bd': 'BD/사업개발',
        // hr
        'recruiter': '채용 담당자',
        'hrbp': 'HRBP',
        'training': '교육/연수 담당',
        // legal
        'lawyer': '변호사',
        'paralegal': '법무팀',
        'compliance': '컴플라이언스',
        // manufacturing
        'engineer': '엔지니어',
        'manager': '생산 관리자',
        'quality': '품질 관리자',
        // other
        'general': '일반 사무직',
        'specialist': '전문직',
        'freelance': '프리랜서',
      };

      final field = normalizedAnswers['field'] as String?;
      final position = normalizedAnswers['position'] as String?;
      final concern = normalizedAnswers['concern'] as String?;

      // currentRole: field + position 조합
      if (field != null || position != null) {
        final fieldLabel = fieldLabels[field] ?? field ?? '';
        final positionLabel = positionLabels[position] ?? position ?? '';
        normalizedAnswers['currentRole'] = '$fieldLabel $positionLabel'.trim();
      }

      // concern → primaryConcern (Edge Function 기대 필드)
      if (concern != null) {
        normalizedAnswers['primaryConcern'] = concern;
        normalizedAnswers['primary_concern'] = concern; // snake_case도 추가
      }

      // 기본값: timeHorizon
      normalizedAnswers['timeHorizon'] ??= '3년 후';

      return normalizedAnswers;
    }

    // ─── exam: 설문 필드 → API 필드 매핑 ───
    if (apiFortuneType == 'exam') {
      // examType 레이블 매핑
      const examTypeLabels = {
        'license': '자격증',
        'employment': '취업/공채',
        'academic': '학업/수능',
        'language': '어학(토익/토플)',
        'certification': '전문자격',
        'civil_service': '공무원',
        'other': '기타',
      };

      // preparation 레이블 매핑
      const preparationLabels = {
        'excellent': '매우 자신있음',
        'good': '자신있음',
        'average': '보통',
        'poor': '불안',
        'very_poor': '매우 불안',
      };

      final examType = normalizedAnswers['examType'] as String?;
      final examDate = normalizedAnswers['examDate'];
      final preparation = normalizedAnswers['preparation'] as String?;

      // examType → exam_type
      if (examType != null) {
        normalizedAnswers['exam_type'] = examTypeLabels[examType] ?? examType;
        normalizedAnswers['exam_category'] = examType;
      }

      // examDate (객체) → exam_date (문자열)
      if (examDate is Map<String, dynamic>) {
        // selectedDate 또는 date에서 날짜 추출
        final selectedDate = examDate['selectedDate'] as String?;
        final dateStr = examDate['date'] as String?;
        if (selectedDate != null && selectedDate.isNotEmpty) {
          normalizedAnswers['exam_date'] = selectedDate;
        } else if (dateStr != null) {
          // ISO 날짜에서 날짜 부분만 추출
          normalizedAnswers['exam_date'] = dateStr.split('T').first;
        }
      } else if (examDate is String) {
        normalizedAnswers['exam_date'] = examDate;
      }

      // preparation → confidence
      if (preparation != null) {
        normalizedAnswers['confidence'] =
            preparationLabels[preparation] ?? preparation;
        normalizedAnswers['preparation_status'] = preparation;
      }

      return normalizedAnswers;
    }

    // ─── moving: 설문 필드 → API 필드 매핑 ───
    if (apiFortuneType == 'moving') {
      return MovingFortuneInputMapper.normalize(normalizedAnswers);
    }

    // ─── face-reading: 이미지 처리 ───
    if (apiFortuneType != 'face-reading') {
      return normalizedAnswers;
    }

    final photoData = normalizedAnswers['photo'];
    String? imagePath;

    if (photoData is Map<String, dynamic>) {
      imagePath = photoData['imagePath'] as String?;
    } else if (photoData is Map) {
      final rawPath = photoData['imagePath'];
      if (rawPath is String) {
        imagePath = rawPath;
      }
    }

    if (imagePath == null || imagePath.isEmpty) {
      throw Exception('Face AI 분석용 사진이 없어요. 사진을 다시 올려주세요.');
    }

    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      Logger.warning('[CharacterChat] Face-reading image file missing', {
        'fortuneType': apiFortuneType,
      });
      throw Exception('선택한 사진 파일을 찾을 수 없어요. 다시 업로드해주세요.');
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      if (imageBytes.isEmpty) {
        throw Exception('사진 파일이 비어 있어요. 다른 사진으로 다시 시도해주세요.');
      }

      normalizedAnswers
        ..remove('photo')
        ..remove('imagePath')
        ..['image'] = base64Encode(imageBytes);
    } on Exception {
      rethrow;
    } catch (error) {
      Logger.error(
          '[CharacterChat] Face-reading image conversion failed', error);
      throw Exception('사진 처리 중 오류가 발생했어요. 다시 업로드해주세요.');
    }

    return normalizedAnswers;
  }

  Future<String> _resolveFortuneUserId() async {
    final profileAsync = _ref.read(userProfileProvider);
    final profileId = profileAsync.maybeWhen(
      data: (profile) => profile?.id,
      orElse: () => null,
    );

    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }

    return _storageService.getOrCreateGuestId();
  }

  /// 🆕 로컬 전용 운세 타입 처리 (Edge Function 없는 타입)
  Future<Fortune?> _getLocalFortune(
    String fortuneType,
    Map<String, dynamic> answers,
  ) async {
    switch (fortuneType) {
      case 'fortune-cookie':
        // chat_home_page.dart 패턴 재사용 - 로컬 포춘쿠키 생성기
        try {
          final cookieResult =
              await FortuneCookieGenerator.getTodayFortuneCookie();
          final userId = await _resolveFortuneUserId();
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
            recommendations: [
              if (cookieResult.data['action_mission'] != null)
                cookieResult.data['action_mission'] as String,
            ],
            specialTip: cookieResult.data['lucky_time'] as String?,
          );
        } catch (e) {
          Logger.warning(
              '[CharacterChat] FortuneCookie local generation failed',
              {'error': e.toString()});
          return null;
        }

      case 'lotto':
        // chat_home_page.dart 패턴 참고 - 로컬 로또 번호 생성기
        try {
          final profileAsync = _ref.read(userProfileProvider);
          final profile = profileAsync.maybeWhen(
            data: (p) => p,
            orElse: () => null,
          );

          if (profile?.birthDate == null) {
            Logger.warning(
                '[CharacterChat] Lotto: birthDate required but not available');
            return null;
          }

          final gameCount =
              int.tryParse(answers['gameCount']?.toString() ?? '1') ?? 1;
          final result = LottoNumberGenerator.generate(
            birthDate: profile!.birthDate!,
            birthTime: profile.birthTime,
            gender: profile.gender.value,
            gameCount: gameCount,
          );

          // sets가 있으면 sets 사용, 없으면 단일 numbers 사용
          final numbersText = result.lottoResult.sets.isNotEmpty
              ? result.lottoResult.sets
                  .asMap()
                  .entries
                  .map((e) => '${e.key + 1}게임: ${e.value.numbers.join(", ")}')
                  .join('\n')
              : '1게임: ${result.lottoResult.numbers.join(", ")}';

          final userId = await _resolveFortuneUserId();
          return Fortune(
            id: 'lotto-${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            type: 'lotto',
            content:
                '🎰 행운의 로또 번호\n\n$numbersText\n\n💬 ${result.lottoResult.fortuneMessage}',
            createdAt: DateTime.now(),
            specialTip:
                '${result.luckyTiming.luckyDay} ${result.luckyTiming.luckyTimeSlot}',
          );
        } catch (e) {
          Logger.warning('[CharacterChat] Lotto local generation failed',
              {'error': e.toString()});
          return null;
        }

      case 'wish':
        final userId = await _resolveFortuneUserId();
        final wishText = answers['wishContent']?.toString() ?? '';
        return Fortune(
          id: 'wish-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          type: 'wish',
          content: wishText,
          createdAt: DateTime.now(),
          additionalInfo: {'wish_text': wishText},
        );

      default:
        return null; // 로컬 처리 아닌 타입 → API 호출 진행
    }
  }

  /// 🆕 운세 API 호출하여 Fortune 데이터 가져오기
  Future<Fortune?> _fetchFortuneData(
    String fortuneType,
    Map<String, dynamic> answers,
  ) async {
    // 🆕 로컬 전용 타입 먼저 체크
    final localFortune = await _getLocalFortune(fortuneType, answers);
    if (localFortune != null) return localFortune;

    // 로컬 전용 타입은 API 호출 스킵
    if (FortuneTypeRegistry.isLocalOnly(fortuneType)) {
      return null;
    }

    final unifiedService = _ref.read(characterUnifiedFortuneServiceProvider);
    final userProfile = _getUserProfileMap();

    // fortuneType을 canonical API 타입으로 매핑
    final apiFortuneType = FortuneTypeRegistry.resolveApiType(
      fortuneType,
      answers: answers,
    );
    final normalizedAnswers =
        await _normalizeSurveyAnswersForApi(apiFortuneType, answers);

    // 사용자 프로필 정보 추가
    final params = <String, dynamic>{
      ...normalizedAnswers,
      if (userProfile != null) ...userProfile,
    };

    Logger.info('[CharacterChat] Calling unified fortune route', {
      'fortuneType': apiFortuneType,
      'hasParams': params.isNotEmpty,
    });

    // 유저 ID 가져오기 (비로그인은 guest_<uuid> 사용)
    final userId = await _resolveFortuneUserId();

    final conditions = CharacterChatFortuneConditions(
      fortuneType: apiFortuneType,
      answers: normalizedAnswers,
      userProfileMergedParams: params,
    );

    final result = await unifiedService.getFortune(
      fortuneType: apiFortuneType,
      dataSource: FortuneDataSource.api,
      inputConditions: params,
      conditions: conditions,
    );

    final fortune = CharacterFortuneAdapter.fromFortuneResult(
      result: result,
      userId: userId,
      fortuneType: apiFortuneType,
    );

    Logger.info('[CharacterChat] Unified fortune route success', {
      'fortuneType': apiFortuneType,
      'hasContent': fortune.content.isNotEmpty,
      'score': fortune.overallScore,
    });

    return fortune;
  }

  /// 중첩된 Map/List를 읽기 쉬운 텍스트로 변환하는 헬퍼
  String _formatValueForContext(dynamic value, {int indent = 1}) {
    final prefix = '  ' * indent;

    if (value == null) return '';

    if (value is String) {
      return value.isEmpty ? '' : value;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    if (value is List) {
      if (value.isEmpty) return '';
      final buffer = StringBuffer();
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          final parts = <String>[];
          for (final entry in item.entries) {
            if (entry.value != null && entry.value.toString().isNotEmpty) {
              parts.add('${entry.key}: ${entry.value}');
            }
          }
          if (parts.isNotEmpty) {
            buffer.writeln('$prefix- ${parts.join(' | ')}');
          }
        } else if (item != null && item.toString().isNotEmpty) {
          buffer.writeln('$prefix- $item');
        }
      }
      return buffer.toString().trimRight();
    }

    if (value is Map<String, dynamic>) {
      if (value.isEmpty) return '';
      final buffer = StringBuffer();
      for (final entry in value.entries) {
        if (entry.value == null) continue;
        final formatted =
            _formatValueForContext(entry.value, indent: indent + 1);
        if (formatted.isEmpty) continue;

        if (entry.value is Map || entry.value is List) {
          buffer.writeln('$prefix- ${entry.key}:');
          buffer.writeln(formatted);
        } else {
          buffer.writeln('$prefix- ${entry.key}: $formatted');
        }
      }
      return buffer.toString().trimRight();
    }

    return value.toString();
  }

  /// 🆕 Fortune 데이터를 캐릭터 컨텍스트용 텍스트로 변환 (모든 운세 타입 지원)
  String _formatFortuneDataForContext(Fortune? fortune) {
    if (fortune == null) {
      return '(운세 데이터를 가져오지 못했습니다. 일반적인 조언을 제공해주세요.)';
    }

    final buffer = StringBuffer();

    // ── 기본 정보 ──
    if (fortune.category != null && fortune.category!.isNotEmpty) {
      buffer.writeln('🏷️ 운세 유형: ${fortune.category}');
    }
    if (fortune.period != null && fortune.period!.isNotEmpty) {
      buffer.writeln('📅 기간: ${fortune.period}');
    }

    // ── 인사말 ──
    if (fortune.greeting != null && fortune.greeting!.isNotEmpty) {
      buffer.writeln('👋 인사말: ${fortune.greeting}');
    }

    // ── 기본 운세 내용 ──
    if (fortune.content.isNotEmpty) {
      buffer.writeln('📌 운세 내용: ${fortune.content}');
    }

    // ── 전체 점수 ──
    if (fortune.overallScore != null) {
      buffer.writeln('⭐ 전체 점수: ${fortune.overallScore}점');
    }

    // ── 퍼센타일 ──
    if (fortune.isPercentileValid && fortune.percentile != null) {
      buffer.writeln(
          '🏆 상위 ${fortune.percentile}% (오늘 ${fortune.totalTodayViewers ?? "?"}명 중)');
    }

    // ── 설명 ──
    if (fortune.description != null && fortune.description!.isNotEmpty) {
      buffer.writeln('📝 설명: ${fortune.description}');
    }

    // ── 요약 ──
    if (fortune.summary != null && fortune.summary!.isNotEmpty) {
      buffer.writeln('📋 요약: ${fortune.summary}');
    }

    // ── 육각형 점수 (연애, 재물, 건강 등) ──
    if (fortune.hexagonScores != null && fortune.hexagonScores!.isNotEmpty) {
      buffer.writeln('📊 세부 점수:');
      fortune.hexagonScores!.forEach((key, value) {
        buffer.writeln('  - $key: $value점');
      });
    }

    // ── 점수 세부 분류 ──
    if (fortune.scoreBreakdown != null && fortune.scoreBreakdown!.isNotEmpty) {
      buffer.writeln('📈 점수 분석:');
      fortune.scoreBreakdown!.forEach((key, value) {
        buffer.writeln('  - $key: $value');
      });
    }

    // ── 카테고리별 운세 (love, money, work, health, social) ──
    if (fortune.categories != null && fortune.categories!.isNotEmpty) {
      buffer.writeln('🔮 카테고리별 운세:');
      fortune.categories!.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final score = value['score'];
          final desc =
              value['description'] ?? value['summary'] ?? value['advice'];
          buffer.writeln(
              '  - $key: ${score != null ? "$score점" : ""} ${desc ?? ""}');
        } else if (value != null) {
          buffer.writeln('  - $key: $value');
        }
      });
    }

    // ── 사주 인사이트 ──
    if (fortune.sajuInsight != null && fortune.sajuInsight!.isNotEmpty) {
      buffer.writeln('🔯 사주 인사이트:');
      buffer.writeln(_formatValueForContext(fortune.sajuInsight));
    }

    // ── 오행 분석 ──
    if (fortune.fiveElements != null && fortune.fiveElements!.isNotEmpty) {
      buffer.writeln('🌊 오행 분석:');
      buffer.writeln(_formatValueForContext(fortune.fiveElements));
    }

    // ── 시간대별 운세 ──
    if (fortune.timeSpecificFortunes != null &&
        fortune.timeSpecificFortunes!.isNotEmpty) {
      buffer.writeln('⏰ 시간대별 운세:');
      for (final tsf in fortune.timeSpecificFortunes!) {
        buffer.writeln(
            '  - ${tsf.time} (${tsf.title}): ${tsf.score}점 - ${tsf.description}');
        if (tsf.recommendation != null && tsf.recommendation!.isNotEmpty) {
          buffer.writeln('    추천: ${tsf.recommendation}');
        }
      }
    }

    // ── 띠별 운세 ──
    if (fortune.birthYearFortunes != null &&
        fortune.birthYearFortunes!.isNotEmpty) {
      buffer.writeln('🐲 띠별 운세:');
      for (final byf in fortune.birthYearFortunes!) {
        buffer.writeln(
            '  - ${byf.zodiacAnimal} (${byf.birthYear}): ${byf.description}');
        if (byf.advice != null && byf.advice!.isNotEmpty) {
          buffer.writeln('    조언: ${byf.advice}');
        }
      }
    }

    // ── 행운 아이템 (기본) ──
    if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) {
      buffer.writeln('🍀 행운 아이템:');
      fortune.luckyItems!.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buffer.writeln('  - $key: $value');
        }
      });
    }

    // ── 행운 아이템 (상세) ──
    if (fortune.detailedLuckyItems != null &&
        fortune.detailedLuckyItems!.isNotEmpty) {
      buffer.writeln('🎁 상세 행운 아이템:');
      fortune.detailedLuckyItems!.forEach((category, items) {
        buffer.writeln('  [$category]');
        for (final item in items) {
          buffer.write('  - ${item.value} (${item.category})');
          if (item.reason.isNotEmpty) buffer.write(' - ${item.reason}');
          if (item.timeRange != null) buffer.write(' [${item.timeRange}]');
          if (item.situation != null) buffer.write(' (${item.situation})');
          buffer.writeln();
        }
      });
    }

    // ── 추천 실천 사항 ──
    if (fortune.personalActions != null &&
        fortune.personalActions!.isNotEmpty) {
      buffer.writeln('🎯 추천 실천 사항:');
      for (final action in fortune.personalActions!) {
        final title = action['title'] ?? action['action'] ?? '';
        final desc = action['description'] ?? action['reason'] ?? '';
        final timing = action['timing'] ?? action['time'] ?? '';
        buffer.writeln(
            '  - $title${desc.toString().isNotEmpty ? ": $desc" : ""}${timing.toString().isNotEmpty ? " ($timing)" : ""}');
      }
    }

    // ── 추천 사항 ──
    if (fortune.recommendations != null &&
        fortune.recommendations!.isNotEmpty) {
      buffer.writeln('💡 추천 사항:');
      for (final rec in fortune.recommendations!) {
        buffer.writeln('  - $rec');
      }
    }

    // ── 주의 사항 ──
    if (fortune.warnings != null && fortune.warnings!.isNotEmpty) {
      buffer.writeln('⚠️ 주의 사항:');
      for (final warning in fortune.warnings!) {
        buffer.writeln('  - $warning');
      }
    }

    // ── 특별 팁 ──
    if (fortune.specialTip != null && fortune.specialTip!.isNotEmpty) {
      buffer.writeln('✨ 특별 팁: ${fortune.specialTip}');
    }

    // ── 날씨 연동 ──
    if (fortune.weatherSummary != null && fortune.weatherSummary!.isNotEmpty) {
      buffer.writeln('🌤️ 날씨 연동:');
      buffer.writeln(_formatValueForContext(fortune.weatherSummary));
    }

    // ── 운세 상세 데이터 (metadata - 운세 타입별 고유 데이터) ──
    if (fortune.metadata != null && fortune.metadata!.isNotEmpty) {
      final metadataToFormat = Map<String, dynamic>.from(fortune.metadata!)
        ..removeWhere(
            (key, value) => _metadataSkipKeys.contains(key) || value == null);

      if (metadataToFormat.isNotEmpty) {
        buffer.writeln('📖 운세 상세 분석:');

        // 알려진 키에 대해 한국어 라벨 매핑
        const labelMap = {
          // MBTI
          'dimensions': '성격 차원 분석',
          'todayTrap': '오늘의 함정',
          'mbtiDescription': 'MBTI 설명',
          'cognitiveStrengths': '인지적 강점',
          'challenges': '도전 과제',
          // Wealth
          'wealthPotential': '재물 잠재력',
          'elementAnalysis': '오행 재물 분석',
          'goalAdvice': '목표 달성 전략',
          'cashflowInsight': '현금 흐름 인사이트',
          'concernResolution': '고민 해결',
          'investmentInsights': '투자 인사이트',
          'luckyElements': '행운 요소',
          'monthlyFlow': '월별 흐름',
          'actionItems': '실천 항목',
          // Avoid-people
          'cautionPeople': '경계 인물',
          'cautionObjects': '경계 사물',
          'cautionColors': '경계 색상',
          'cautionNumbers': '경계 숫자',
          'cautionAnimals': '경계 동물',
          'cautionPlaces': '경계 장소',
          'cautionTimes': '경계 시간',
          'cautionDirections': '경계 방향',
          'timeStrategy': '시간대 전략',
          // Time
          'timeSlots': '시간대별 분석',
          'cautionActivities': '경계 활동',
          'traditionalElements': '전통 요소',
          'bestTime': '최고 시간',
          'worstTime': '주의 시간',
          // Biorhythm
          'physical': '신체 리듬',
          'emotional': '감정 리듬',
          'intellectual': '지성 리듬',
          'today_recommendation': '오늘의 추천',
          'weekly_forecast': '주간 예보',
          'important_dates': '중요 날짜',
          'weekly_activities': '주간 활동',
          'personal_analysis': '개인 분석',
          'lifestyle_advice': '라이프스타일 조언',
          'health_tips': '건강 팁',
          // Naming
          'recommendedNames': '추천 이름',
          'ohaengAnalysis': '오행 분석',
          'namingTips': '작명 팁',
          // Ex-lover
          'hardTruth': '냉정한 진실',
          'theirPerspective': '상대방의 시선',
          'strategicAdvice': '전략적 조언',
          'emotionalPrescription': '감정 처방전',
          'reunion_possibility': '재회 가능성',
          'reunionAssessment': '재회 분석',
          'reunionCap': '재회 상한',
          'contact_status': '연락 상태',
          'relationshipDepth': '관계 깊이',
          'currentState': '현재 상태',
          'comfort_message': '위로 메시지',
          'closingMessage': '마무리 메시지',
          'openingMessage': '시작 메시지',
          'breakupAnalysis': '이별 분석',
          'emotionalJourney': '감정 여정',
          'actionPlan': '실천 계획',
          // Pet
          'pets_voice': '반려동물 속마음',
          'bonding_mission': '유대감 미션',
          'daily_condition': '오늘의 컨디션',
          'owner_bond': '주인과의 유대감',
          'activity_recommendation': '활동 추천',
          'care_tips': '케어 팁',
          'health_check': '건강 체크',
          'weather_advice': '날씨 조언',
          'special_message': '특별 메시지',
          'pet_info': '반려동물 정보',
          'today_story': '오늘의 이야기',
          'breed_specific': '품종별 특성',
          'health_insight': '건강 인사이트',
          'emotional_care': '감정 케어',
          'special_tips': '특별 팁',
          'lucky_items': '행운 아이템',
          'pet_content': '반려동물 콘텐츠',
          'pet_summary': '반려동물 요약',
          // Love
          'loveProfile': '연애 프로필',
          'detailedAnalysis': '상세 분석',
          'todaysAdvice': '오늘의 조언',
          'predictions': '예측',
          // Compatibility
          'overall_compatibility': '전체 궁합',
          'personality_match': '성격 궁합',
          'loveMatch': '연애 궁합',
          'marriageMatch': '결혼 궁합',
          'communicationMatch': '소통 궁합',
          'strengths': '강점',
          'cautions': '주의점',
          'detailed_advice': '상세 조언',
          'zodiac_animal': '띠',
          'star_sign': '별자리',
          'destiny_number': '운명의 숫자',
          'age_difference': '나이 차이',
          'loveStyle': '연애 스타일',
          // General
          'overallScore': '전체 점수',
          'luckyColor': '행운의 색상',
          'luckyNumber': '행운의 숫자',
          'energyLevel': '에너지 레벨',
        };

        for (final entry in metadataToFormat.entries) {
          final label = labelMap[entry.key] ?? entry.key;
          final formatted = _formatValueForContext(entry.value);
          if (formatted.isEmpty) continue;

          if (entry.value is Map || entry.value is List) {
            buffer.writeln('  [$label]');
            buffer.writeln(formatted);
          } else {
            buffer.writeln('  - $label: $formatted');
          }
        }
      }
    } else if (fortune.additionalInfo != null &&
        fortune.additionalInfo!.isNotEmpty) {
      // metadata가 없고 additionalInfo만 있는 경우
      final infoToFormat = Map<String, dynamic>.from(fortune.additionalInfo!)
        ..removeWhere(
            (key, value) => _metadataSkipKeys.contains(key) || value == null);

      if (infoToFormat.isNotEmpty) {
        buffer.writeln('📖 추가 정보:');
        buffer.writeln(_formatValueForContext(infoToFormat));
      }
    }

    return buffer.toString();
  }

  /// 대화 스레드 초기화 (DB에서 불러오기)
  Future<void> initConversation() async {
    // 채팅방 진입 시 항상 읽지 않은 메시지 초기화 (isInitialized 체크 전에!)
    clearUnreadCount();

    // 이미 초기화됨
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      // 호감도 로드 (로컬 우선, 서버 폴백)
      final affinity = await _affinityService.loadAffinity(_characterId);
      state = state.copyWith(affinity: affinity);

      final messages = await _service.loadConversation(_characterId);

      if (messages.isNotEmpty) {
        // DB에서 불러온 대화가 있으면 사용
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          isInitialized: true,
        );

        // 마지막 메시지가 유저면 → AI 응답 생성 (앱 재시작 시 무시 방지)
        if (messages.last.type == CharacterChatMessageType.user) {
          _generatePendingResponse();
        } else {
          // 캐릭터 메시지면 Follow-up 스케줄 시작
          _startFollowUpSchedule();
        }
      } else {
        // 첫 진입은 초기 상태와 첫 메시지를 한 번에 반영해
        // 빈 initialized 상태가 렌더링되지 않도록 합니다.
        final firstMessage = CharacterChatMessage.character(
            _buildFirstMeetOpening(), _characterId);
        state = state.copyWith(
          messages: [firstMessage],
          isLoading: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      // 로드 실패 시에도 첫 메시지로 안전하게 진입합니다.
      final firstMessage = CharacterChatMessage.character(
          _buildFirstMeetOpening(), _characterId);
      state = state.copyWith(
        messages: [firstMessage],
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  /// 대화 스레드 저장 (화면 이탈 시 호출)
  Future<bool> saveOnExit() async {
    // 호감도 저장 (항상)
    await _affinityService.saveAffinity(_characterId, state.affinity);

    // 펜딩된 로컬 저장 즉시 flush
    await _localService.flushPendingConversations();

    // 메시지가 없으면 저장 안 함
    if (state.messages.isEmpty) return true;

    return await _service.saveConversation(_characterId, state.messages);
  }

  /// 선택지 메시지 추가
  void addChoiceMessage(ChoiceSet choiceSet, {String? situation}) {
    final message =
        CharacterChatMessage.choice(choiceSet, situation: situation);
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
    );
  }

  /// 선택지 선택 처리 - 인스타그램 DM 스타일 딜레이 적용
  Future<void> handleChoiceSelection(CharacterChoice choice) async {
    // 🪙 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 선택지 메시지 제거 (마지막 메시지가 선택지인 경우)
    final messages = List<CharacterChatMessage>.from(state.messages);
    if (messages.isNotEmpty && messages.last.isChoice) {
      messages.removeLast();
    }

    // 사용자 선택을 메시지로 추가 (status: sent)
    final userMessage = CharacterChatMessage.user(choice.text);
    messages.add(userMessage);

    state = state.copyWith(
      messages: messages,
      isProcessing: true,
    );

    // 호감도 변화 적용
    if (choice.affinityChange != 0) {
      final newAffinity = state.affinity.addPoints(choice.affinityChange);
      state = state.copyWith(affinity: newAffinity);
    }

    // 읽음 딜레이 (0.5~1.5초)
    await _waitForReadDelayIfNeeded();

    // 읽음 처리 → pending "1" 전체 정리
    markPendingUserMessagesAsRead();

    // 타이핑 시작
    setTyping(true);

    try {
      final toneProfile = _buildToneProfile(currentUserMessage: choice.text);
      // 선택에 대한 캐릭터 반응 요청 (방금 추가한 사용자 선택 제외)
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();
      final toneStylePrompt = _buildToneStyleGuidePrompt(toneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        emojiInstruction,
        if (toneStylePrompt.isNotEmpty) toneStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: '(사용자가 "${choice.text}"를 선택함)',
        modelPreference: _resolveModelPreference(),
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 감정 기반 타이핑 딜레이
      await _waitForGeneratedReplyDelayIfNeeded(
        emotionTag: response.emotionTag,
        responseText: response.response,
      );

      _ackPendingUserMessagesBeforeCharacterReply();

      addCharacterMessage(
        _applyGeneratedTone(
          response.response,
          profile: toneProfile,
        ),
      );
    } catch (e) {
      setError(e.toString());
    }
  }

  /// 현재 활성 선택지가 있는지 확인
  bool get hasActiveChoice {
    return state.messages.isNotEmpty && state.messages.last.isChoice;
  }

  /// 현재 활성 선택지 가져오기
  ChoiceSet? get activeChoiceSet {
    if (!hasActiveChoice) return null;
    return state.messages.last.choiceSet;
  }

  /// 사주 명식 표 텍스트를 외부에서 접근 가능하도록 제공
  /// (character_chat_panel에서 분석 시작 시 즉시 표시용)
  /// sajuProvider에 데이터가 없으면 fetchUserSaju()로 로드 후 표 생성
  Future<String> getSajuPillarTableText() async {
    // sajuProvider에 데이터가 없으면 먼저 로드
    final currentState = _ref.read(sajuProvider);
    if (currentState.sajuData == null) {
      Logger.info('[SajuTable] sajuData가 null → fetchUserSaju() 호출');
      await _ref.read(sajuProvider.notifier).fetchUserSaju();
    }
    return _formatSajuPillarTable();
  }

  /// sajuProvider에서 원시 사주 데이터 가져오기 (비주얼 카드 렌더링용)
  /// ChatSajuResultCard가 직접 처리할 수 있는 Map 형식으로 반환
  Future<Map<String, dynamic>?> getSajuRawData() async {
    final currentState = _ref.read(sajuProvider);
    if (currentState.sajuData == null) {
      Logger.info('[SajuCard] sajuData null → fetchUserSaju() 호출');
      await _ref.read(sajuProvider.notifier).fetchUserSaju();
    }
    return _ref.read(sajuProvider).sajuData;
  }

  /// 사주 4주를 텍스트 표 형식으로 포맷팅
  /// sajuProvider에서 유저의 사주 데이터를 가져와 명식 표로 변환
  String _formatSajuPillarTable() {
    final sajuState = _ref.read(sajuProvider);
    final sajuData = sajuState.sajuData;
    Logger.info('[SajuTable] sajuData == null? ${sajuData == null}');
    if (sajuData != null) {
      Logger.info('[SajuTable] keys: ${sajuData.keys.toList()}');
      Logger.info('[SajuTable] year: ${sajuData['year']}');
      Logger.info('[SajuTable] day: ${sajuData['day']}');
    }
    if (sajuData == null) return '';

    final pillars = ['hour', 'day', 'month', 'year'];
    final pillarLabels = {
      'hour': '시주(時柱)',
      'day': '일주(日柱)',
      'month': '월주(月柱)',
      'year': '년주(年柱)',
    };

    // 각 주의 천간/지지 데이터 추출
    final stemChars = <String>[];
    final stemHanjas = <String>[];
    final stemElements = <String>[];
    final branchChars = <String>[];
    final branchHanjas = <String>[];
    final branchElements = <String>[];
    final branchAnimals = <String>[];
    final tenshinList = <String>[];

    final dayStemChar = (sajuData['day']?['cheongan']
            as Map<String, dynamic>?)?['char'] as String? ??
        '';

    for (final key in pillars) {
      final pillarData = sajuData[key] as Map<String, dynamic>?;
      final cheongan = pillarData?['cheongan'] as Map<String, dynamic>?;
      final jiji = pillarData?['jiji'] as Map<String, dynamic>?;

      stemChars.add(cheongan?['char'] as String? ?? '-');
      stemHanjas.add(cheongan?['hanja'] as String? ?? '-');
      stemElements.add(cheongan?['element'] as String? ?? '-');
      branchChars.add(jiji?['char'] as String? ?? '-');
      branchHanjas.add(jiji?['hanja'] as String? ?? '-');
      branchElements.add(jiji?['element'] as String? ?? '-');
      branchAnimals.add(jiji?['animal'] as String? ?? '-');

      // 십성 계산
      if (key == 'day') {
        tenshinList.add('일간(나)');
      } else {
        final targetStem = cheongan?['char'] as String? ?? '';
        tenshinList.add(_getTenshinForContext(dayStemChar, targetStem));
      }
    }

    // 표 구성
    final buf = StringBuffer();
    buf.writeln('📜 사주팔자 명식 (四柱八字)');
    buf.writeln('');

    // 헤더
    buf.writeln(
        '        ${pillarLabels['hour']}  ${pillarLabels['day']}  ${pillarLabels['month']}  ${pillarLabels['year']}');

    // 천간 행
    buf.writeln(
        '천간:    ${stemChars[0]}(${stemHanjas[0]})     ${stemChars[1]}(${stemHanjas[1]})     ${stemChars[2]}(${stemHanjas[2]})     ${stemChars[3]}(${stemHanjas[3]})');
    buf.writeln(
        '        ${stemElements[0]}       ${stemElements[1]}       ${stemElements[2]}       ${stemElements[3]}');

    // 지지 행
    buf.writeln(
        '지지:    ${branchChars[0]}(${branchHanjas[0]})     ${branchChars[1]}(${branchHanjas[1]})     ${branchChars[2]}(${branchHanjas[2]})     ${branchChars[3]}(${branchHanjas[3]})');
    buf.writeln(
        '        ${branchAnimals[0]}       ${branchAnimals[1]}       ${branchAnimals[2]}       ${branchAnimals[3]}');
    buf.writeln(
        '        ${branchElements[0]}       ${branchElements[1]}       ${branchElements[2]}       ${branchElements[3]}');

    // 십성 행
    buf.writeln(
        '십성:    ${tenshinList[0]}     ${tenshinList[1]}     ${tenshinList[2]}     ${tenshinList[3]}');

    // 오행 분포
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    if (elements != null) {
      buf.writeln('');
      final elementOrder = ['목', '화', '토', '금', '수'];
      final elementParts = elementOrder
          .map((e) => '$e(${_getElementHanja(e)}) ${elements[e] ?? 0}')
          .join(' | ');
      buf.writeln('오행 분포: $elementParts');
    }

    // 주된/부족한 오행
    final dominant = sajuData['dominantElement'] as String?;
    final lacking = sajuData['lackingElement'] as String?;
    if (dominant != null && dominant.isNotEmpty) {
      final parts = <String>[];
      parts.add('주된 오행: $dominant(${_getElementHanja(dominant)})');
      if (lacking != null && lacking.isNotEmpty) {
        parts.add('부족한 오행: $lacking(${_getElementHanja(lacking)})');
      }
      buf.writeln(parts.join(' | '));
    }

    return buf.toString();
  }

  /// 오행 한자 매핑
  String _getElementHanja(String element) {
    const map = {'목': '木', '화': '火', '토': '土', '금': '金', '수': '水'};
    return map[element] ?? element;
  }

  /// 십성 판단 (일간 기준 상생상극 관계)
  /// CompactPillarTable._getTenshin() 로직 재사용
  String _getTenshinForContext(String dayStem, String targetStem) {
    if (dayStem.isEmpty || targetStem.isEmpty) return '-';

    const stemElements = {
      '갑': '목',
      '을': '목',
      '병': '화',
      '정': '화',
      '무': '토',
      '기': '토',
      '경': '금',
      '신': '금',
      '임': '수',
      '계': '수',
    };
    const stemYinYang = {
      '갑': '양',
      '을': '음',
      '병': '양',
      '정': '음',
      '무': '양',
      '기': '음',
      '경': '양',
      '신': '음',
      '임': '양',
      '계': '음',
    };

    final dayElement = stemElements[dayStem] ?? '';
    final targetElement = stemElements[targetStem] ?? '';
    final dayYinYang = stemYinYang[dayStem] ?? '';
    final targetYinYang = stemYinYang[targetStem] ?? '';

    if (dayElement.isEmpty || targetElement.isEmpty) return '-';

    final isSameYinYang = dayYinYang == targetYinYang;

    // 같은 오행 = 비견/겁재
    if (dayElement == targetElement) {
      return isSameYinYang ? '비견' : '겁재';
    }

    // 나를 생하는 것 = 인성
    const generatingMap = {'목': '수', '화': '목', '토': '화', '금': '토', '수': '금'};
    if (generatingMap[dayElement] == targetElement) {
      return isSameYinYang ? '편인' : '정인';
    }

    // 내가 생하는 것 = 식상
    if (generatingMap[targetElement] == dayElement) {
      return isSameYinYang ? '식신' : '상관';
    }

    // 나를 극하는 것 = 관성
    const controllingMap = {'목': '금', '화': '수', '토': '목', '금': '화', '수': '토'};
    if (controllingMap[dayElement] == targetElement) {
      return isSameYinYang ? '편관' : '정관';
    }

    // 내가 극하는 것 = 재성
    if (controllingMap[targetElement] == dayElement) {
      return isSameYinYang ? '편재' : '정재';
    }

    return '-';
  }

  @override
  void dispose() {
    _cancelReadIdleIcebreaker();
    super.dispose();
  }
}
