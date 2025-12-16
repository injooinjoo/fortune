import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/services/debug_premium_service.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../presentation/providers/subscription_provider.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/toast.dart';
import '../../../../../services/ad_service.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../services/vision_api_service.dart';
import '../../widgets/fortune_loading_skeleton.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import '../../../../../core/widgets/gpt_style_typing_text.dart';

// 분리된 위젯들
import 'constants/blind_date_options.dart';
import 'widgets/blind_date_tab_selector.dart';
import 'widgets/blind_date_success_prediction.dart';
import 'widgets/blind_date_first_impression.dart';
import 'widgets/blind_date_conversation_topics.dart';
import 'widgets/blind_date_outfit_recommendation.dart';
import 'widgets/blind_date_location_advice.dart';
import 'widgets/blind_date_dos_donts.dart';
import 'widgets/blind_date_chat_analysis.dart';
import 'widgets/blind_date_photo_analysis.dart';

class BlindDateFortunePage extends ConsumerStatefulWidget {
  const BlindDateFortunePage({super.key});

  @override
  ConsumerState<BlindDateFortunePage> createState() =>
      _BlindDateFortunePageState();
}

class _BlindDateFortunePageState extends ConsumerState<BlindDateFortunePage> {
  // Loading and error state
  bool _isLoading = false;
  String? _errorMessage;
  FortuneResult? _fortuneResult;

  // Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ✅ GPT 스타일 타이핑 효과
  int _currentTypingSection = 0;

  // Meeting Info
  DateTime? _meetingDate;
  String? _meetingTime;
  String? _meetingType;
  String? _introducer;

  // Preferences
  final List<String> _importantQualities = [];
  String? _agePreference;
  String? _idealFirstDate;

  // Self Assessment
  String? _confidence;
  final List<String> _concerns = [];
  String? _pastExperience;
  bool _isFirstBlindDate = false;

  // Photo Analysis
  List<XFile> _myPhotos = [];
  List<XFile> _partnerPhotos = [];
  BlindDateAnalysis? _photoAnalysis;
  bool _isAnalyzingPhotos = false;

  // Chat Analysis
  final _chatContentController = TextEditingController();
  String? _chatPlatform;

  // Tab Index
  int _selectedTabIndex = 0;

  // User info form state
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _mbti;

  @override
  void initState() {
    super.initState();

    // Pre-fill user data with profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.maybeWhen(
        data: (profile) => profile,
        orElse: () => null,
      );

      if (userProfile != null && mounted) {
        setState(() {
          _nameController.text = userProfile.name ?? '';
          _birthDate = userProfile.birthDate;
          _gender = userProfile.gender;
          _mbti = userProfile.mbtiType;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _chatContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _fortuneResult != null
          ? AppBar(
              backgroundColor: colors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: const SizedBox.shrink(),
              title: Text(
                '소개팅',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colors.textPrimary,
                  ),
                  onPressed: () => GoRouter.of(context).go('/fortune'),
                ),
              ],
            )
          : const StandardFortuneAppBar(title: '소개팅'),
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? FortuneResultSkeleton(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : _fortuneResult != null
                        ? _buildFortuneResult()
                        : _buildInputForm(),
            if (_fortuneResult == null && !_isLoading && _errorMessage == null)
              UnifiedButton.floating(
                text: '운세 보기',
                isEnabled: true,
                onPressed: () async {
                  await AdService.instance.showInterstitialAdWithCallback(
                    onAdCompleted: () async => await _generateFortune(),
                    onAdFailed: () async => await _generateFortune(),
                  );
                },
                icon: Icon(Icons.auto_awesome_rounded, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final colors = context.colors;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '알 수 없는 오류',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            UnifiedButton(
              text: '다시 시도',
              onPressed: _generateFortune,
              style: UnifiedButtonStyle.primary,
              size: UnifiedButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateFortune() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userInfo = await _getUserInfo();
      if (userInfo == null) {
        setState(() => _isLoading = false);
        return;
      }

      final params = await _getFortuneParams();
      if (params == null) {
        setState(() => _isLoading = false);
        return;
      }

      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // Base64 인코딩된 사진 데이터 준비
      List<String>? myEncodedPhotos;
      List<String>? partnerEncodedPhotos;

      if (_myPhotos.isNotEmpty) {
        myEncodedPhotos = [];
        for (final photo in _myPhotos) {
          final bytes = await photo.readAsBytes();
          myEncodedPhotos.add(base64Encode(bytes));
        }
      }

      if (_partnerPhotos.isNotEmpty) {
        partnerEncodedPhotos = [];
        for (final photo in _partnerPhotos) {
          final bytes = await photo.readAsBytes();
          partnerEncodedPhotos.add(base64Encode(bytes));
        }
      }

      // Premium 상태 확인
      final debugPremium = await DebugPremiumService.isOverrideEnabled();
      final tokenState = ref.read(tokenProvider);
      final realPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      final isPremium = debugPremium || realPremium;

      // Analysis Type 결정
      String analysisType = 'basic';
      if (_chatContentController.text.isNotEmpty &&
          (myEncodedPhotos?.isNotEmpty ?? false)) {
        analysisType = 'comprehensive';
      } else if (myEncodedPhotos?.isNotEmpty ?? false) {
        analysisType = 'photos';
      } else if (_chatContentController.text.isNotEmpty) {
        analysisType = 'chat';
      }

      final inputConditions = {
        'name': params['name'],
        'birth_date': params['birthDate'],
        'gender': params['gender'],
        'mbti': params['mbti'],
        'meeting_date': params['meetingDate'],
        'meeting_time': params['meetingTime'],
        'meeting_type': params['meetingType'],
        'introducer': params['introducer'],
        'important_qualities': params['importantQualities'],
        'age_preference': params['agePreference'],
        'ideal_first_date': params['idealFirstDate'],
        'confidence': params['confidence'],
        'concerns': params['concerns'],
        'past_experience': params['pastExperience'],
        'is_first_blind_date': params['isFirstBlindDate'],
        'analysis_type': analysisType,
        'my_photos': myEncodedPhotos,
        'partner_photos': partnerEncodedPhotos,
        'chat_content': _chatContentController.text.isEmpty
            ? null
            : _chatContentController.text,
        'chat_platform': _chatPlatform,
        if (params['photoAnalysis'] != null)
          'photo_analysis': params['photoAnalysis'],
        'isPremium': isPremium,
      };

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'blind_date',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
      );

      // Blur 상태 설정
      _isBlurred = !isPremium;
      _blurredSections = _isBlurred
          ? [
              'success_prediction',
              'first_impression',
              'conversation_topics',
              'outfit',
              'location',
              'dos_donts'
            ]
          : [];

      setState(() {
        _fortuneResult = fortuneResult;
        _isLoading = false;
        _currentTypingSection = 0;  // 타이핑 섹션 리셋
      });

      // 소개팅 운세 결과 공개 햅틱 (하트비트 + 점수)
      final haptic = ref.read(fortuneHapticServiceProvider);
      final score = fortuneResult.score ?? 70;
      haptic.loveHeartbeat();
      Future.delayed(const Duration(milliseconds: 300), () {
        haptic.scoreReveal(score);
      });
    } catch (e, stackTrace) {
      Logger.error('[BlindDateFortunePage] 운세 생성 실패', e, stackTrace);
      setState(() {
        _errorMessage = '운세를 생성하는 중 오류가 발생했습니다. 다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo() async {
    if (_nameController.text.isEmpty ||
        _birthDate == null ||
        _gender == null) {
      Toast.warning(context, '기본 정보를 입력해주세요.');
      return null;
    }

    return {
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'gender': _gender,
      'mbti': _mbti,
    };
  }

  Future<Map<String, dynamic>?> _getFortuneParams() async {
    final userInfo = await _getUserInfo();
    if (userInfo == null) return null;

    if (_myPhotos.isNotEmpty) {
      await _analyzePhotos();
    }

    if (_meetingDate == null ||
        _meetingTime == null ||
        _meetingType == null ||
        _introducer == null ||
        _importantQualities.isEmpty ||
        _agePreference == null ||
        _idealFirstDate == null ||
        _confidence == null) {
      if (mounted) {
        Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      }
      return null;
    }

    return {
      ...userInfo,
      'meetingDate': _meetingDate!.toIso8601String(),
      'meetingTime': _meetingTime,
      'meetingType': _meetingType,
      'introducer': _introducer,
      'importantQualities': _importantQualities,
      'agePreference': _agePreference,
      'idealFirstDate': _idealFirstDate,
      'confidence': _confidence,
      'concerns': _concerns,
      'pastExperience': _pastExperience,
      'isFirstBlindDate': _isFirstBlindDate,
      if (_photoAnalysis != null)
        'photoAnalysis': {
          'myStyle': _photoAnalysis!.myStyle,
          'myPersonality': _photoAnalysis!.myPersonality,
          'partnerStyle': _photoAnalysis!.partnerStyle,
          'partnerPersonality': _photoAnalysis!.partnerPersonality,
          'matchingScore': _photoAnalysis!.matchingScore,
        },
    };
  }

  Future<void> _analyzePhotos() async {
    if (_myPhotos.isEmpty && _partnerPhotos.isEmpty) return;

    setState(() => _isAnalyzingPhotos = true);

    try {
      Logger.info(
          '[BlindDate] Photos prepared: my=${_myPhotos.length}, partner=${_partnerPhotos.length}');

      if (mounted) {
        Toast.success(context, '사진이 준비되었습니다');
      }
    } catch (e) {
      Logger.error('Photo preparation failed', e);
      if (mounted) {
        Toast.error(context, '사진 준비에 실패했습니다');
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzingPhotos = false);
      }
    }
  }

  Widget _buildInputForm() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Selector
          BlindDateTabSelector(
            selectedIndex: _selectedTabIndex,
            onTabChanged: (index) => setState(() => _selectedTabIndex = index),
          ),
          const SizedBox(height: 24),

          // Selected Tab Content
          if (_selectedTabIndex == 0) ...[
            _buildUserInfoForm(),
            const SizedBox(height: 16),
          ] else if (_selectedTabIndex == 1) ...[
            BlindDatePhotoAnalysis(
              myPhotos: _myPhotos,
              partnerPhotos: _partnerPhotos,
              isAnalyzingPhotos: _isAnalyzingPhotos,
              onMyPhotosSelected: (photos) =>
                  setState(() => _myPhotos = photos),
              onPartnerPhotosSelected: (photos) =>
                  setState(() => _partnerPhotos = photos),
              onAnalyzePressed: _analyzePhotos,
              userInfoForm: _buildUserInfoForm(),
            ),
            const SizedBox(height: 16),
          ] else if (_selectedTabIndex == 2) ...[
            BlindDateChatAnalysis(
              chatContentController: _chatContentController,
              chatPlatform: _chatPlatform,
              onPlatformChanged: (platform) =>
                  setState(() => _chatPlatform = platform),
            ),
            const SizedBox(height: 16),
          ],

          // Meeting Details
          _buildMeetingDetailsSection(theme, isDark),
          const SizedBox(height: 16),

          // Preferences
          _buildPreferencesSection(theme, isDark),
          const SizedBox(height: 16),

          // Self Assessment
          _buildSelfAssessmentSection(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildUserInfoForm() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(text: '👤 기본 정보'),
          const SizedBox(height: 16),
          PillTextField(
            controller: _nameController,
            labelText: '이름',
            hintText: '이름을 입력하세요',
          ),
          const SizedBox(height: 16),
          NumericDateInput(
            label: '생년월일',
            selectedDate: _birthDate,
            onDateChanged: (date) => setState(() => _birthDate = date),
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: true,
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: '성별'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectionChip(
                label: '남성',
                isSelected: _gender == 'male',
                onTap: () {
                  setState(() => _gender = 'male');
                  HapticFeedback.selectionClick();
                },
              ),
              SelectionChip(
                label: '여성',
                isSelected: _gender == 'female',
                onTap: () {
                  setState(() => _gender = 'female');
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: 'MBTI (선택)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'INTJ', 'INTP', 'ENTJ', 'ENTP',
              'INFJ', 'INFP', 'ENFJ', 'ENFP',
              'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
              'ISTP', 'ISFP', 'ESTP', 'ESFP'
            ].map((mbti) => SelectionChip(
              label: mbti,
              isSelected: _mbti == mbti,
              onTap: () {
                setState(() => _mbti = mbti);
                HapticFeedback.selectionClick();
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingDetailsSection(ThemeData theme, bool isDark) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(text: '📅 만남 정보'),
          const SizedBox(height: 16),
          NumericDateInput(
            label: '만남 예정일',
            selectedDate: _meetingDate,
            onDateChanged: (date) => setState(() => _meetingDate = date),
            minDate: DateTime.now(),
            maxDate: DateTime.now().add(const Duration(days: 90)),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: '만남 시간대'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: meetingTimeOptions.entries.map((entry) {
              return SelectionChip(
                label: entry.value,
                isSelected: _meetingTime == entry.key,
                onTap: () {
                  setState(() => _meetingTime = entry.key);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: '만남 방식'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: meetingTypeOptions.entries.map((entry) {
              return SelectionChip(
                label: entry.value,
                isSelected: _meetingType == entry.key,
                onTap: () {
                  setState(() => _meetingType = entry.key);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: '소개 경로'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: introducerOptions.entries.map((entry) {
              return SelectionChip(
                label: entry.value,
                isSelected: _introducer == entry.key,
                onTap: () {
                  setState(() => _introducer = entry.key);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeData theme, bool isDark) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(text: '💕 선호 사항'),
          const SizedBox(height: 16),
          const FieldLabel(text: '중요하게 생각하는 것 (3개 이상)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: qualityOptions.map((quality) {
              final isSelected = _importantQualities.contains(quality);
              return SelectionChip(
                label: quality,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _importantQualities.remove(quality);
                    } else {
                      _importantQualities.add(quality);
                    }
                  });
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: '나이 선호도'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: agePreferenceOptions.entries.map((entry) {
              return SelectionChip(
                label: entry.value,
                isSelected: _agePreference == entry.key,
                onTap: () {
                  setState(() => _agePreference = entry.key);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: '이상적인 첫 데이트'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: idealDateOptions.entries.map((entry) {
              return SelectionChip(
                label: entry.value,
                isSelected: _idealFirstDate == entry.key,
                onTap: () {
                  setState(() => _idealFirstDate = entry.key);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfAssessmentSection(ThemeData theme, bool isDark) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(text: '🧠 자기 평가'),
          const SizedBox(height: 16),
          const FieldLabel(text: '소개팅 자신감'),
          ...confidenceLevelOptions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectionCard(
                title: entry.value,
                subtitle: '',
                emoji: _getConfidenceEmoji(confidenceLevelOptions.keys.toList().indexOf(entry.key)),
                isSelected: _confidence == entry.key,
                onTap: () {
                  setState(() => _confidence = entry.key);
                  HapticFeedback.selectionClick();
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          const FieldLabel(text: '걱정되는 부분 (선택)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: concernOptions.map((concern) {
              final isSelected = _concerns.contains(concern);
              return SelectionChip(
                label: concern,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _concerns.remove(concern);
                    } else {
                      _concerns.add(concern);
                    }
                  });
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          CardCheckbox(
            label: '첫 소개팅인가요?',
            value: _isFirstBlindDate,
            onChanged: (value) {
              setState(() => _isFirstBlindDate = value == true);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  String _getConfidenceEmoji(int index) {
    final emojis = ['😰', '😟', '😐', '😊', '😎'];
    return emojis[index];
  }

  Widget _buildFortuneResult() {
    if (_fortuneResult == null) {
      return const SizedBox.shrink();
    }

    final successRate = calculateSuccessRate(
      meetingTime: _meetingTime,
      meetingType: _meetingType,
      confidence: _confidence,
      concerns: _concerns,
      isFirstBlindDate: _isFirstBlindDate,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMainFortuneContent(),
              const SizedBox(height: 16),
              if (_photoAnalysis != null)
                BlindDatePhotoAnalysisResult(analysis: _photoAnalysis!),
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'success_prediction',
                child: BlindDateSuccessPrediction(successRate: successRate),
              ),
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'first_impression',
                child: const BlindDateFirstImpression(),
              ),
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'conversation_topics',
                child: const BlindDateConversationTopics(),
              ),
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'outfit',
                child: BlindDateOutfitRecommendation(meetingType: _meetingType),
              ),
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'location',
                child: BlindDateLocationAdvice(meetingType: _meetingType),
              ),
              UnifiedBlurWrapper(
                isBlurred: _isBlurred,
                blurredSections: _blurredSections,
                sectionKey: 'dos_donts',
                child: const BlindDateDosDonts(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        if (_isBlurred && !ref.watch(isPremiumProvider))
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
          ),
      ],
    );
  }

  Widget _buildMainFortuneContent() {
    final colors = context.colors;
    final fortuneData = _fortuneResult!.data;
    final content = fortuneData['content'] as String? ?? '';
    final score = _fortuneResult!.score;

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '소개팅 운세 결과',
            style: DSTypography.headingMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: DSSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: DSTypography.displayLarge.copyWith(
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/100',
                  style: DSTypography.headingMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: DSSpacing.md),
          // ✅ GPT 스타일 타이핑 효과 적용
          GptStyleTypingText(
            text: content,
            style: DSTypography.bodyLarge.copyWith(
              color: colors.textPrimary,
            ),
            startTyping: _currentTypingSection >= 0,
            showGhostText: true,
            onComplete: () {
              if (mounted) setState(() => _currentTypingSection = 1);
            },
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }

  Future<void> _showAdAndUnblur() async {
    try {
      final adService = AdService.instance;

      if (!adService.isRewardedAdReady) {
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: DSColors.error,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[소개팅운세] 광고 표시 실패', e, stackTrace);

      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: DSColors.warning,
          ),
        );
      }
    }
  }

  // ✅ UnifiedBlurWrapper로 마이그레이션 완료 (2024-12-07)
}
