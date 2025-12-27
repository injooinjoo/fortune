import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/profile_header_icon.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../presentation/providers/secondary_profiles_provider.dart';
import '../../../../providers/pet_provider.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/models/secondary_profile.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../data/services/fortune_api/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';
import '../../domain/models/recommendation_chip.dart';
import '../../domain/models/fortune_survey_config.dart';
import '../../domain/configs/survey_configs.dart';
import '../../domain/services/intent_detector.dart';
import '../providers/chat_messages_provider.dart';
import '../providers/chat_survey_provider.dart';
import '../widgets/chat_welcome_view.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/survey/fortune_type_chips.dart';
import '../widgets/survey/chat_survey_chips.dart';
import '../widgets/survey/chat_voice_input.dart';
import '../widgets/survey/chat_image_input.dart';
import '../widgets/survey/chat_profile_selector.dart';
import '../widgets/survey/chat_pet_profile_selector.dart';
import '../widgets/survey/chat_date_picker.dart';
import '../widgets/survey/chat_inline_calendar.dart';
import '../widgets/survey/chat_survey_slider.dart';
import '../widgets/survey/chat_tarot_flow.dart';
import '../widgets/survey/chat_face_reading_flow.dart';
import '../widgets/survey/chat_birth_datetime_picker.dart';

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

  /// 프로필 생성 완료 후 궁합 진행해야 할지 여부
  bool _pendingCompatibilityAfterProfileCreation = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    if (text.length >= 2) {
      final intents = IntentDetector.detectIntents(text);
      if (mounted) {
        setState(() {
          _detectedIntents = intents.where((i) => i.isConfident).toList();
        });
      }
    } else {
      if (_detectedIntents.isNotEmpty && mounted) {
        setState(() {
          _detectedIntents = [];
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleChipTap(RecommendationChip chip) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // chip.fortuneType을 FortuneSurveyType으로 매핑
    final surveyType = _mapChipToSurveyType(chip.fortuneType);

    if (surveyType != null) {
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

          _callFortuneApi(type: surveyType, answers: {}).then((fortune) {
            // Fortune 객체와 함께 리치 카드 표시
            chatNotifier.addFortuneResultMessage(
              text: typeName,
              fortuneType: fortuneTypeStr,
              fortune: fortune,
              isBlurred: fortune.isBlurred,
            );
            _scrollToBottom();

            // 운세 결과 후 추천 칩 표시
            Future.delayed(const Duration(milliseconds: 500), () {
              chatNotifier.addSystemMessage();
              _scrollToBottom();
            });
          }).catchError((error) {
            Logger.error('Fortune API 호출 실패', error);
            chatNotifier.addAiMessage(
              '죄송해요, 운세 분석 중 문제가 발생했어요. 😢\n'
              '잠시 후 다시 시도해주세요.\n\n'
              '다른 운세를 봐볼까요?',
            );
            _scrollToBottom();
          });
        });
        return;
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

        // 설문 시작
        surveyNotifier.startSurvey(surveyType);

        // AI 첫 질문 메시지
        Future.delayed(const Duration(milliseconds: 500), () {
          final surveyState = ref.read(chatSurveyProvider);
          if (surveyState.activeProgress != null &&
              surveyState.activeProgress!.config.steps.isNotEmpty) {
            final question = surveyState.activeProgress!.currentStep.question;
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
          '${chip.label} 기능은 곧 준비될 예정이에요! 🔮\n다른 운세를 먼저 보시겠어요?',
        );
        _scrollToBottom();
      });
    }
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
      case 'yearly':
        return FortuneSurveyType.yearly;
      case 'newYear':
        return FortuneSurveyType.newYear;
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
      // 가족/반려동물
      case 'pet':
        return FortuneSurveyType.pet;
      case 'family':
        return FortuneSurveyType.family;
      case 'naming':
        return FortuneSurveyType.naming;
      default:
        return null;
    }
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    final notifier = ref.read(chatMessagesProvider.notifier);
    notifier.addUserMessage(text);
    _textController.clear();
    setState(() {
      _detectedIntents = [];
    });
    _scrollToBottom();

    // 의도 감지 결과가 있으면 설문 시작 제안
    final intents = IntentDetector.detectIntents(text);
    if (intents.isNotEmpty && intents.first.isConfident) {
      final primaryIntent = intents.first;
      Future.delayed(const Duration(milliseconds: 500), () {
        notifier.addAiMessage(
          IntentDetector.getSuggestionMessage(primaryIntent.type),
        );
        _scrollToBottom();
      });
    } else {
      notifier.showTypingIndicator();
      Future.delayed(const Duration(seconds: 1), () {
        notifier.addAiMessage('무엇이든 물어보세요! 운세, 타로, 적성 등 다양한 주제로 대화할 수 있어요.');
        _scrollToBottom();
      });
    }
  }

  void _handleFortuneTypeSelect(FortuneSurveyType type) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 텍스트 필드 초기화
    _textController.clear();
    setState(() {
      _detectedIntents = [];
    });

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

      // 설문 시작
      surveyNotifier.startSurvey(type);

      // AI 첫 질문 메시지 (설문 단계가 있는 경우)
      Future.delayed(const Duration(milliseconds: 500), () {
        final surveyState = ref.read(chatSurveyProvider);
        if (surveyState.activeProgress != null &&
            surveyState.activeProgress!.config.steps.isNotEmpty) {
          final question = surveyState.activeProgress!.currentStep.question;
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
          return '$name님! $zodiacSign자리의 오늘 운세를 봐드릴게요. ✨';
        }
        return '$name님의 오늘 운세를 봐드릴게요! ✨';

      case FortuneSurveyType.yearly:
      case FortuneSurveyType.newYear:
        return '$name님의 2025년 운세를 살펴볼게요! 🎊';

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
          return '$name님은 ${profile!.mbtiType}시네요! MBTI 기반 분석을 해볼게요. 🧠';
        }
        return '$name님의 MBTI 분석을 해볼게요! 🧠';

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
        return '$name님의 건강 운세를 봐드릴게요! 💊';

      case FortuneSurveyType.dream:
        return '$name님, 꿈 이야기를 들려주세요! 💭';

      case FortuneSurveyType.pet:
        return '$name님! 반려동물 궁합을 봐드릴게요. 🐾';

      case FortuneSurveyType.family:
        return '$name님의 가족 운세를 살펴볼게요! 👨‍👩‍👧‍👦';

      case FortuneSurveyType.naming:
        return '좋은 이름을 찾아드릴게요, $name님! 📝';

      default:
        return '안녕하세요, $name님! ${_getTypeDisplayName(type)}를 봐드릴게요. ✨';
    }
  }

  void _handleSurveyAnswer(SurveyOption option) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 사용자 답변 메시지
    final displayText = option.emoji != null
        ? '${option.emoji} ${option.label}'
        : option.label;
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
        final question = surveyState.activeProgress!.currentStep.question;
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

  /// 범용 설문 답변 처리 (옵션 외 입력: 텍스트, 날짜, 슬라이더 등)
  void _handleSurveyAnswerValue(dynamic value, String displayText) {
    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final surveyNotifier = ref.read(chatSurveyProvider.notifier);

    // 사용자 답변 메시지
    chatNotifier.addUserMessage(displayText);
    _scrollToBottom();

    // 답변 처리
    surveyNotifier.answerCurrentStep(value);

    // 다음 질문 또는 완료 처리
    Future.delayed(const Duration(milliseconds: 300), () {
      final surveyState = ref.read(chatSurveyProvider);

      if (surveyState.isCompleted) {
        _handleSurveyComplete(surveyState);
      } else if (surveyState.activeProgress != null) {
        final question = surveyState.activeProgress!.currentStep.question;
        chatNotifier.addAiMessage(question);
        _scrollToBottom();
      }
    });
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

    chatNotifier.showTypingIndicator();
    _scrollToBottom();

    final typeName = completedType != null
        ? _getTypeDisplayName(completedType)
        : '운세';

    Future.delayed(const Duration(milliseconds: 800), () {
      chatNotifier.addAiMessage(
        '좋아요! 답변해주신 내용을 바탕으로\n$typeName를 분석하고 있어요... ✨',
      );
      _scrollToBottom();

      _callFortuneApi(
        type: completedType ?? FortuneSurveyType.daily,
        answers: completedData,
      ).then((fortune) {
        // Fortune 객체와 함께 리치 카드 표시
        final fortuneTypeStr = _mapSurveyTypeToString(completedType ?? FortuneSurveyType.daily);
        chatNotifier.addFortuneResultMessage(
          text: typeName,
          fortuneType: fortuneTypeStr,
          fortune: fortune,
          isBlurred: fortune.isBlurred,
        );
        surveyNotifier.clearCompleted();
        _scrollToBottom();
        // 운세 결과 후 추천 칩 표시
        Future.delayed(const Duration(milliseconds: 500), () {
          chatNotifier.addSystemMessage();
          _scrollToBottom();
        });
      }).catchError((error) {
        Logger.error('Fortune API 호출 실패', error);
        chatNotifier.addAiMessage(
          '죄송해요, 운세 분석 중 문제가 발생했어요. 😢\n'
          '잠시 후 다시 시도해주세요.\n\n'
          '다른 운세를 봐볼까요?',
        );
        surveyNotifier.clearCompleted();
        _scrollToBottom();
      });
    });
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

  /// 프로필 선택 처리 (궁합용)
  void _handleProfileSelect(SecondaryProfile? profile) async {
    if (profile == null) {
      // 새로 입력하기 선택 → 채팅 내 프로필 생성 플로우 시작
      final chatNotifier = ref.read(chatMessagesProvider.notifier);
      final surveyNotifier = ref.read(chatSurveyProvider.notifier);

      // 궁합 완료 후 재개 플래그 설정
      setState(() {
        _pendingCompatibilityAfterProfileCreation = true;
      });

      // 현재 궁합 설문 취소하고 프로필 생성 설문 시작
      surveyNotifier.cancelSurvey();

      // 프로필 생성 설문 시작
      chatNotifier.addUserMessage('새로 입력할게요');
      chatNotifier.addAiMessage('좋아요! 궁합 상대 정보를 알려주세요 ✍️');

      Future.delayed(const Duration(milliseconds: 300), () {
        surveyNotifier.startSurvey(FortuneSurveyType.profileCreation);

        Future.delayed(const Duration(milliseconds: 300), () {
          final surveyState = ref.read(chatSurveyProvider);
          if (surveyState.activeProgress != null) {
            final question = surveyState.activeProgress!.currentStep.question;
            chatNotifier.addAiMessage(question);
            _scrollToBottom();
          }
        });
      });
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

  /// 펫 프로필 선택 처리 (반려동물용)
  void _handlePetSelect(PetProfile? pet) {
    if (pet == null) {
      // 새로 입력하기 선택
      final chatNotifier = ref.read(chatMessagesProvider.notifier);
      chatNotifier.addAiMessage(
        '새로운 반려동물 정보를 입력해주세요.\n'
        '이름, 종류, 나이가 필요해요.',
      );
      // TODO: 채팅 내 펫 프로필 입력 플로우
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
    final selectedCards = tarotData['selectedCardIndices'] as List<int>? ?? [];

    final displayText = '🃏 $spreadName (${selectedCards.length}장 선택)';
    _handleSurveyAnswerValue({
      ...tarotData,
      'spreadType': tarotData['spreadType'],
      'cardCount': cardCount,
      'selectedCards': selectedCards,
    }, displayText);
  }

  /// 관상 분석 플로우 완료 핸들러
  void _handleFaceReadingComplete(String imagePath) {
    final displayText = '📷 사진 선택 완료';
    _handleSurveyAnswerValue({
      'imagePath': imagePath,
    }, displayText);
  }

  /// 운세 API 호출 - Edge Function 요구사항에 맞게 파라미터 매핑
  Future<Fortune> _callFortuneApi({
    required FortuneSurveyType type,
    required Map<String, dynamic> answers,
  }) async {
    final apiService = ref.read(fortuneApiServiceProvider);
    final userProfileAsync = ref.read(userProfileNotifierProvider);
    final userProfile = userProfileAsync.valueOrNull;
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

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

      case FortuneSurveyType.yearly:
      case FortuneSurveyType.newYear:
        return apiService.getYearlyFortune(userId: userId);

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
        // Edge Function 요구: age, gender, relationshipStatus, datingStyles, valueImportance
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'love',
          params: {
            'age': age,
            'gender': gender,
            'relationshipStatus': answers['status'] ?? 'single',
            'datingStyles': ['casual', 'serious'],
            'valueImportance': {
              '외모': 3, '성격': 5, '경제력': 3, '가치관': 5, '유머감각': 4,
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
            'birth_date': partnerProfile?['birthDate'] ?? partnerProfile?.birthDate?.toIso8601String()?.split('T')[0] ?? birthDateStr,
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
        final partnerPhotoPath = partnerPhotoData is Map ? partnerPhotoData['imagePath'] : null;

        // 사진이 있으면 base64로 변환
        String? partnerPhotoBase64;
        if (hasPartnerInfo == 'photo' && partnerPhotoPath != null) {
          try {
            final file = File(partnerPhotoPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              partnerPhotoBase64 = base64Encode(bytes);
              Logger.info('Partner photo converted to base64: ${bytes.length} bytes');
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
            if (hasPartnerInfo == 'instagram' && answers['partnerInstagram'] != null)
              'partnerInstagram': answers['partnerInstagram'],
            'hasPartnerInfo': hasPartnerInfo ?? 'none',
            'analysisType': analysisType,
          },
        );

      case FortuneSurveyType.exLover:
        // Edge Function 요구: name, relationship_duration, time_since_breakup, breakup_initiator, etc.
        // Survey step ids: 'breakupTime', 'breakupReason'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'ex-lover',
          params: {
            'name': userName,
            'relationship_duration': '1년',
            'time_since_breakup': answers['breakupTime'] ?? '1개월',
            'breakup_initiator': 'mutual',
            'contact_status': 'no_contact',
            'breakup_detail': answers['breakupReason'] ?? '성격 차이',
            'current_emotion': 'confused',
            'main_curiosity': 'reunion_chance',
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
        // Edge Function 요구: mbti, name, birthDate
        // Survey step id: 'mbtiType'
        final mbtiType = answers['mbtiType'] ?? userProfile?.mbtiType ?? 'INFP';
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'mbti',
          params: {
            'mbti': mbtiType,
            'name': userName,
            'birthDate': birthDateStr,
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
        // Survey step ids: 'interest', 'workStyle', 'problemSolving'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'talent',
          params: {
            'talentArea': answers['interest'] ?? '예술',
            'currentSkills': [answers['workStyle'] ?? '협업형', answers['problemSolving'] ?? '분석형'],
            'goals': '잠재력 발견',
            'experience': '초급',
            'timeAvailable': '주 5시간',
            'challenges': ['시간 부족', '방향성 미확정'],
          },
        );

      // ============================================================
      // Wealth / Money
      // ============================================================
      case FortuneSurveyType.money:
        // Edge Function 요구: ticker (symbol, name, category) - 투자 관련
        return apiService.getWealthFortune(userId: userId);

      // ============================================================
      // Health
      // ============================================================
      case FortuneSurveyType.health:
        // Edge Function 요구: current_condition, concerned_body_parts
        // Survey step id: 'concern'
        final healthConcern = answers['concern'] ?? 'general';
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'health',
          params: {
            'current_condition': healthConcern,
            'concerned_body_parts': [healthConcern],
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
        return apiService.getLuckyNumberFortune(userId: userId);

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
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'tarot',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'spreadType': answers['spreadType'] ?? 'single',
            'cardCount': answers['cardCount'] ?? 1,
            'selectedCards': answers['selectedCards'] ?? [],
            'question': answers['purpose'] ?? '오늘의 운세',
            'deck': answers['deck'] ?? 'rider_waite',
          },
        );

      // ============================================================
      // Face Reading
      // ============================================================
      case FortuneSurveyType.faceReading:
        // ChatFaceReadingFlow에서 수집된 이미지로 관상 API 호출
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'face-reading',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'gender': gender,
            'imagePath': answers['imagePath'],
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
        // survey step id: 'wishContent', 'category'
        return apiService.getWishFortune(
          userId: userId,
          wish: answers['wishContent'] ?? '소원이 입력되지 않았습니다',
        );

      case FortuneSurveyType.fortuneCookie:
        return apiService.getDailyFortune(userId: userId);

      // ============================================================
      // Health / Sports
      // ============================================================
      case FortuneSurveyType.exercise:
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'health',
          params: {
            'current_condition': 'normal',
            'concerned_body_parts': ['전체'],
            'exercise_focus': true,
          },
        );

      case FortuneSurveyType.sportsGame:
        // Note: lucky-sports Edge Function 없음 → daily 활용
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'daily',
          params: {
            'birthDate': birthDateStr,
            'birthTime': userProfile?.birthTime ?? '자시 (23:00 - 01:00)',
            'gender': gender,
            'zodiacSign': userProfile?.zodiacSign ?? '양자리',
            'zodiacAnimal': userProfile?.chineseZodiac ?? '용',
            'category': 'sports',
            'sport': answers['sport'] ?? 'general',
          },
        );

      // ============================================================
      // Interactive
      // ============================================================
      case FortuneSurveyType.celebrity:
        // Edge Function 요구: celebrity_id, celebrity_name, connection_type, question_type, category, name, birthDate
        // Survey step id: 'celebrityName'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'celebrity',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'celebrity_id': answers['celebrityId'] ?? 'unknown',
            'celebrity_name': answers['celebrityName'] ?? '',
            'connection_type': answers['connectionType'] ?? 'general',
            'question_type': answers['questionType'] ?? 'compatibility',
            'category': answers['category'] ?? 'entertainment',
          },
        );

      // ============================================================
      // Family / Pet
      // ============================================================
      case FortuneSurveyType.pet:
        // Survey step id: 'pet' (PetProfile 객체)
        final petProfile = answers['pet'];
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'pet-compatibility',
          params: {
            'ownerName': userName,
            'ownerBirthDate': birthDateStr,
            'petName': petProfile?['name'] ?? petProfile?.name ?? '반려동물',
            'petType': petProfile?['type'] ?? petProfile?.type ?? 'dog',
            'petBirthDate': petProfile?['birthDate'] ?? petProfile?.birthDate?.toIso8601String(),
          },
        );

      case FortuneSurveyType.family:
        // Edge Function 요구: name, birthDate, family_type, relationship
        // Survey step ids: 'concern', 'member'
        return apiService.getFortune(
          userId: userId,
          fortuneType: 'family-harmony',
          params: {
            'name': userName,
            'birthDate': birthDateStr,
            'family_type': answers['concern'] ?? 'nuclear',
            'relationship': answers['member'] ?? 'spouse',
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

      case FortuneSurveyType.profileCreation:
        // profileCreation은 운세 API 호출이 아닌 프로필 저장 용도
        // _handleProfileCreationComplete에서 별도 처리됨
        throw UnsupportedError('profileCreation은 운세 API를 사용하지 않습니다');
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

  String _getTypeDisplayName(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.career:
        return '커리어 운세';
      case FortuneSurveyType.love:
        return '연애 운세';
      case FortuneSurveyType.talent:
        return '적성 찾기';
      case FortuneSurveyType.daily:
        return '오늘의 운세';
      case FortuneSurveyType.tarot:
        return '타로';
      case FortuneSurveyType.mbti:
        return 'MBTI';
      case FortuneSurveyType.yearly:
        return '연간 운세';
      case FortuneSurveyType.newYear:
        return '새해 운세';
      case FortuneSurveyType.traditional:
        return '사주 분석';
      case FortuneSurveyType.faceReading:
        return 'AI 관상';
      case FortuneSurveyType.personalityDna:
        return '성격 DNA';
      case FortuneSurveyType.biorhythm:
        return '바이오리듬';
      case FortuneSurveyType.compatibility:
        return '궁합';
      case FortuneSurveyType.avoidPeople:
        return '경계 대상';
      case FortuneSurveyType.exLover:
        return '재회 운세';
      case FortuneSurveyType.blindDate:
        return '소개팅 운세';
      case FortuneSurveyType.money:
        return '재물운';
      case FortuneSurveyType.luckyItems:
        return '행운 아이템';
      case FortuneSurveyType.lotto:
        return '로또 번호';
      case FortuneSurveyType.wish:
        return '소원';
      case FortuneSurveyType.fortuneCookie:
        return '오늘의 메시지';
      case FortuneSurveyType.health:
        return '건강 운세';
      case FortuneSurveyType.exercise:
        return '운동 추천';
      case FortuneSurveyType.sportsGame:
        return '스포츠 경기';
      case FortuneSurveyType.dream:
        return '꿈 해몽';
      case FortuneSurveyType.celebrity:
        return '유명인 궁합';
      case FortuneSurveyType.pet:
        return '반려동물 궁합';
      case FortuneSurveyType.family:
        return '가족 운세';
      case FortuneSurveyType.naming:
        return '작명';
      case FortuneSurveyType.profileCreation:
        return '프로필 생성';
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
        return 'personality';
      case FortuneSurveyType.yearly:
      case FortuneSurveyType.newYear:
        return 'time';
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
        return 'relationship';
      case FortuneSurveyType.exLover:
        return 'ex-lover';
      case FortuneSurveyType.blindDate:
        return 'love';
      case FortuneSurveyType.money:
        return 'money';
      case FortuneSurveyType.luckyItems:
        return 'lucky_items';
      case FortuneSurveyType.lotto:
        return 'lottery';
      case FortuneSurveyType.wish:
        return 'wish';
      case FortuneSurveyType.fortuneCookie:
        return 'fortune-cookie';
      case FortuneSurveyType.health:
        return 'health';
      case FortuneSurveyType.exercise:
        return 'health_sports';
      case FortuneSurveyType.sportsGame:
        return 'sports';
      case FortuneSurveyType.dream:
        return 'dream';
      case FortuneSurveyType.celebrity:
        return 'celebrity';
      case FortuneSurveyType.pet:
        return 'pet';
      case FortuneSurveyType.family:
        return 'family';
      case FortuneSurveyType.naming:
        return 'naming';
      case FortuneSurveyType.profileCreation:
        return 'default'; // 프로필 생성은 운세 이미지 불필요
    }
  }

  /// 설문 입력 위젯 빌드 - inputType에 따라 적절한 위젯 반환
  Widget? _buildSurveyInputWidget(ChatSurveyState surveyState, List<SurveyOption> options) {
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
        return ChatSurveyChips(
          options: options,
          onSelect: _handleSurveyAnswer,
          allowMultiple: true,
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
          data: (profiles) => ChatProfileSelector(
            profiles: profiles,
            onSelect: _handleProfileSelect,
            hintText: '궁합을 볼 상대를 선택하세요',
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(DSSpacing.md),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => ChatProfileSelector(
            profiles: const [],
            onSelect: _handleProfileSelect,
            hintText: '궁합을 볼 상대를 선택하세요',
          ),
        );

      case SurveyInputType.petProfile:
        final petState = ref.watch(petProvider);
        return ChatPetProfileSelector(
          profiles: petState.pets,
          onSelect: _handlePetSelect,
          hintText: '반려동물을 선택하세요',
        );

      case SurveyInputType.voice:
        return ChatVoiceInput(
          onSubmit: (text) => _handleSurveyAnswerValue(text, text),
          hintText: currentStep.question,
        );

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

      case SurveyInputType.text:
        // 텍스트 입력은 하단 텍스트 필드 사용 - null 반환하여 활성화
        return null;

      case SurveyInputType.grid:
        // Fallback to chips for now
        if (options.isEmpty) return null;
        return ChatSurveyChips(
          options: options,
          onSelect: _handleSurveyAnswer,
        );

      case SurveyInputType.tarot:
        return ChatTarotFlow(
          onComplete: _handleTarotComplete,
          question: surveyState.activeProgress?.answers['purpose'] as String?,
        );

      case SurveyInputType.faceReading:
        return ChatFaceReadingFlow(
          onComplete: _handleFaceReadingComplete,
        );
    }
  }

  /// 하단 떠다니는 영역의 높이 계산 (설문 + 칩 + 입력란)
  double _calculateBottomPadding(ChatSurveyState surveyState) {
    double padding = 80; // 기본 입력란 높이

    if (surveyState.isActive) {
      // 설문이 활성화된 경우 추가 패딩
      padding += 60;
    } else if (_detectedIntents.isNotEmpty) {
      // 추천 칩이 표시되는 경우 추가 패딩
      padding += 50;
    }

    return padding;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatMessagesProvider);
    final surveyState = ref.watch(chatSurveyProvider);
    final colors = context.colors;

    // 현재 설문 옵션 가져오기
    final surveyOptions = surveyState.isActive
        ? ref.read(chatSurveyProvider.notifier).getCurrentStepOptions()
        : <SurveyOption>[];

    // 현재 설문 스텝이 텍스트 입력인지 확인
    final isTextInputStep = surveyState.isActive &&
        surveyState.activeProgress != null &&
        surveyState.activeProgress!.currentStep.inputType == SurveyInputType.text;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false, // MainShell에서 navigation bar padding 처리
        child: Stack(
          children: [
            // 메인 콘텐츠 (메시지 영역)
            chatState.isEmpty
                ? ChatWelcomeView(
                    onChipTap: _handleChipTap,
                    bottomPadding: _calculateBottomPadding(surveyState),
                  )
                : ChatMessageList(
                    scrollController: _scrollController,
                    messages: chatState.messages,
                    isTyping: chatState.isTyping,
                    onChipTap: _handleChipTap,
                    bottomPadding: _calculateBottomPadding(surveyState),
                  ),

            // 프로필 아이콘 (투명 오버레이 - 좌측)
            const Positioned(
              left: DSSpacing.md,
              top: DSSpacing.sm,
              child: ProfileHeaderIcon(),
            ),

            // 초기화 버튼 (투명 오버레이 - 우측)
            Positioned(
              right: DSSpacing.xs,
              top: 0,
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: colors.textTertiary,
                ),
                onPressed: () {
                  ref.read(chatMessagesProvider.notifier).clearConversation();
                  ref.read(chatSurveyProvider.notifier).cancelSurvey();
                  _textController.clear();
                  setState(() {
                    _detectedIntents = [];
                  });
                },
                tooltip: '대화 초기화',
              ),
            ),

            // 떠다니는 하단 영역 (설문 + 칩 + 입력란)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 설문 입력 영역 (inputType에 따라 다른 위젯)
                  if (surveyState.isActive)
                    _buildSurveyInputWidget(surveyState, surveyOptions) ?? const SizedBox.shrink(),

                  // 추천 운세 칩 (텍스트 입력 시)
                  if (!surveyState.isActive && _detectedIntents.isNotEmpty)
                    FortuneTypeChips(
                      intents: _detectedIntents,
                      onSelect: _handleFortuneTypeSelect,
                    ),

                  // 텍스트 입력란
                  Container(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    // 완전 투명 배경 - pill만 보임
                    child: UnifiedVoiceTextField(
                      controller: _textController,
                      hintText: isTextInputStep
                          ? '텍스트를 입력하세요...'
                          : surveyState.isActive
                              ? '위 선택지에서 골라주세요'
                              : '무엇이든 물어보세요...',
                      onSubmit: isTextInputStep
                          ? _handleTextSurveySubmit
                          : surveyState.isActive
                              ? (_) {}
                              : _handleSendMessage,
                      enabled: !surveyState.isActive || isTextInputStep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
