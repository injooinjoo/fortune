import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/models/ex_lover_simple_model.dart';
import '../../domain/models/conditions/ex_lover_fortune_conditions.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/widgets/ads/interstitial_ad_helper.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../widgets/multi_photo_selector.dart';

class ExLoverFortuneSimplePage extends ConsumerStatefulWidget {
  const ExLoverFortuneSimplePage({super.key});

  @override
  ConsumerState<ExLoverFortuneSimplePage> createState() =>
      _ExLoverFortuneSimplePageState();
}

class _ExLoverFortuneSimplePageState
    extends ConsumerState<ExLoverFortuneSimplePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // 각 섹션의 GlobalKey (자동 스크롤용) - 12개로 확장 (스크린샷 추가)
  final List<GlobalKey> _sectionKeys = List.generate(12, (_) => GlobalKey());

  // 1. 상대방 이름/닉네임
  final TextEditingController _exNameController = TextEditingController();

  // 1.5. 상대방 생년월일 (선택)
  DateTime? _exBirthDate;

  // 2. 상대방 MBTI
  String? _exMbti;

  // 3. 관계 기간
  String? _relationshipDuration;

  // 4. 이별 시기
  String? _timeSinceBreakup;

  // 5. 이별 통보자
  String? _breakupInitiator;

  // 6. 현재 연락 상태
  String? _contactStatus;

  // 7. 이별 이유 상세 (STT + 타이핑)
  String? _breakupDetail;

  // 8. 현재 감정
  String? _currentEmotion;

  // 9. 가장 궁금한 것
  String? _mainCuriosity;

  // 10. 카톡/대화 내용 (선택)
  final TextEditingController _chatHistoryController = TextEditingController();

  // 11. 카톡 스크린샷 (선택, 최대 3장)
  List<XFile> _chatScreenshots = [];

  @override
  void dispose() {
    _scrollController.dispose();
    _exNameController.dispose();
    _chatHistoryController.dispose();
    super.dispose();
  }

  /// 선택 완료 시 다음 섹션으로 자동 스크롤
  void _scrollToNextSection(int currentIndex) {
    if (currentIndex >= _sectionKeys.length - 1) return;

    Future.delayed(const Duration(milliseconds: 300), () {
      final nextKey = _sectionKeys[currentIndex + 1];
      final context = nextKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.2, // 화면 상단 20% 위치에 오도록
        );
      }
    });
  }

  bool _canSubmit() {
    return _relationshipDuration != null &&
        _timeSinceBreakup != null &&
        _breakupInitiator != null &&
        _contactStatus != null &&
        (_breakupDetail != null && _breakupDetail!.isNotEmpty) &&
        _currentEmotion != null &&
        _mainCuriosity != null;
  }

  /// XFile 리스트를 base64 문자열 리스트로 변환
  Future<List<String>> _convertPhotosToBase64(List<XFile> photos) async {
    final List<String> base64List = [];
    for (final photo in photos) {
      final bytes = await photo.readAsBytes();
      base64List.add(base64Encode(bytes));
    }
    return base64List;
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: DSColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Future<void> _analyzeAndShowResult() async {
    if (!_canSubmit()) {
      _showMessage('필수 항목을 모두 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;

      Logger.info('[ExLoverFortune] Premium 상태: $isPremium');

      // 스크린샷 base64 변환
      List<String>? screenshotsBase64;
      if (_chatScreenshots.isNotEmpty) {
        Logger.info('[ExLoverFortune] 스크린샷 ${_chatScreenshots.length}장 변환 중...');
        screenshotsBase64 = await _convertPhotosToBase64(_chatScreenshots);
      }

      final conditions = ExLoverFortuneConditions(
        exName: _exNameController.text.isNotEmpty
            ? _exNameController.text
            : null,
        exBirthDate: _exBirthDate,
        exMbti: _exMbti,
        relationshipDuration: _relationshipDuration!,
        timeSinceBreakup: _timeSinceBreakup!,
        breakupInitiator: _breakupInitiator!,
        contactStatus: _contactStatus!,
        breakupDetail: _breakupDetail,
        currentEmotion: _currentEmotion!,
        mainCuriosity: _mainCuriosity!,
        chatHistory: _chatHistoryController.text.isNotEmpty
            ? _chatHistoryController.text
            : null,
        chatScreenshots: screenshotsBase64,
      );

      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      final result = await fortuneService.getFortune(
        fortuneType: 'ex_lover',
        dataSource: FortuneDataSource.api,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: isPremium,
      );

      Logger.info('[ExLoverFortune] 운세 생성 완료: ${result.id}');

      // ✅ 재회운 결과 생성 시 햅틱 피드백 (연애 테마)
      ref.read(fortuneHapticServiceProvider).loveHeartbeat();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      await InterstitialAdHelper.showInterstitialAdWithCallback(
        ref,
        onAdCompleted: () async {
          if (mounted) {
            context.push(
              '/ex-lover-emotional-result',
              extra: result,
            );
          }
        },
        onAdFailed: () async {
          if (mounted) {
            context.push(
              '/ex-lover-emotional-result',
              extra: result,
            );
          }
        },
      );
    } catch (error, stackTrace) {
      Logger.error('[ExLoverFortune] 운세 생성 실패', error, stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('운세 생성 중 오류가 발생했습니다'),
            backgroundColor: DSColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: StandardFortuneAppBar(
        title: '재회운',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 (Center로 감싸서 중앙 정렬)
                const Center(
                  child: PageHeaderSection(
                    emoji: '💜',
                    title: '힘드셨죠?',
                    subtitle: '천천히 답해주세요. 당신의 마음을 읽어드릴게요.',
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // 1. 상대방 이름/닉네임
                _buildSection(
                  key: _sectionKeys[0],
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '그 사람을 뭐라고 불렀나요? (선택)'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _exNameController,
                        decoration: InputDecoration(
                          hintText: '이름 또는 닉네임',
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _scrollToNextSection(0),
                      ),
                    ],
                  ),
                ),

                // 1.5. 상대방 생년월일 (선택)
                _buildSection(
                  key: _sectionKeys[1],
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '그 사람 생년월일을 아시나요? (선택)'),
                      const SizedBox(height: 4),
                      Text(
                        '더 정확한 인연 분석이 가능해요',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      NumericDateInput(
                        selectedDate: _exBirthDate,
                        onDateChanged: (date) {
                          setState(() => _exBirthDate = date);
                          _scrollToNextSection(1);
                        },
                        hintText: 'YYYY년 MM월 DD일',
                        minDate: DateTime(1940),
                        maxDate: DateTime.now(),
                        showAge: true,
                      ),
                      if (_exBirthDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: DSColors.success, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '입력 완료',
                                style: DSTypography.labelSmall.copyWith(
                                  color: DSColors.success,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() => _exBirthDate = null);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(40, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '건너뛰기',
                                  style: DSTypography.labelSmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. 상대방 MBTI
                _buildSection(
                  key: _sectionKeys[2],
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '그 사람 MBTI를 아시나요? (선택)'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mbtiOptions.map((mbti) {
                          final label = mbti == 'unknown' ? '모름' : mbti;
                          return SelectionChip(
                            label: label,
                            isSelected: _exMbti == mbti,
                            onTap: () {
                              setState(() => _exMbti = mbti);
                              _scrollToNextSection(2);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 3. 관계 기간
                _buildSection(
                  key: _sectionKeys[3],
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '얼마나 만났나요?'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: relationshipDurationOptions.map((option) {
                          return SelectionChip(
                            label: option.label,
                            isSelected: _relationshipDuration == option.id,
                            onTap: () {
                              setState(() => _relationshipDuration = option.id);
                              _scrollToNextSection(3);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 4. 이별 시기
                _buildSection(
                  key: _sectionKeys[4],
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '이별한 지 얼마나 되었나요?'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SelectionChip(
                            label: '1개월 미만',
                            isSelected: _timeSinceBreakup == 'recent',
                            onTap: () {
                              setState(() => _timeSinceBreakup = 'recent');
                              _scrollToNextSection(4);
                            },
                          ),
                          SelectionChip(
                            label: '1-3개월',
                            isSelected: _timeSinceBreakup == 'short',
                            onTap: () {
                              setState(() => _timeSinceBreakup = 'short');
                              _scrollToNextSection(4);
                            },
                          ),
                          SelectionChip(
                            label: '3-6개월',
                            isSelected: _timeSinceBreakup == 'medium',
                            onTap: () {
                              setState(() => _timeSinceBreakup = 'medium');
                              _scrollToNextSection(4);
                            },
                          ),
                          SelectionChip(
                            label: '6개월-1년',
                            isSelected: _timeSinceBreakup == 'long',
                            onTap: () {
                              setState(() => _timeSinceBreakup = 'long');
                              _scrollToNextSection(4);
                            },
                          ),
                          SelectionChip(
                            label: '1년 이상',
                            isSelected: _timeSinceBreakup == 'verylong',
                            onTap: () {
                              setState(() => _timeSinceBreakup = 'verylong');
                              _scrollToNextSection(4);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 5. 이별 통보자
                _buildSection(
                  key: _sectionKeys[5],
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '누가 먼저 이별을 말했나요?'),
                      const SizedBox(height: 8),
                      ...breakupInitiatorCards.map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SelectionCard(
                              title: card.title,
                              subtitle: card.description,
                              emoji: card.emoji,
                              isSelected: _breakupInitiator == card.id,
                              onTap: () {
                                setState(() => _breakupInitiator = card.id);
                                _scrollToNextSection(5);
                              },
                            ),
                          )),
                    ],
                  ),
                ),

                // 6. 현재 연락 상태
                _buildSection(
                  key: _sectionKeys[6],
                  index: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '지금 연락하고 있나요?'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: contactStatusOptions.map((option) {
                          return SelectionChip(
                            label: option.label,
                            isSelected: _contactStatus == option.id,
                            onTap: () {
                              setState(() => _contactStatus = option.id);
                              _scrollToNextSection(6);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 7. 이별 이유 상세 (STT + 타이핑)
                _buildSection(
                  key: _sectionKeys[7],
                  index: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '왜 헤어지게 되었나요?'),
                      const SizedBox(height: 4),
                      Text(
                        '음성 또는 텍스트로 자유롭게 말씀해주세요',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      UnifiedVoiceTextField(
                        hintText: '이별하게 된 이유를 말씀해주세요...',
                        transcribingText: '듣고 있어요...',
                        // B07: 실시간 텍스트 변경 시 버튼 활성화
                        onTextChanged: (text) {
                          setState(() => _breakupDetail = text.isNotEmpty ? text : null);
                        },
                        onSubmit: (text) {
                          setState(() => _breakupDetail = text);
                          _scrollToNextSection(7);
                        },
                      ),
                      if (_breakupDetail != null &&
                          _breakupDetail!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: DSColors.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _breakupDetail!,
                                  style: DSTypography.bodyMedium.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() => _breakupDetail = null);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 8. 현재 감정
                _buildSection(
                  key: _sectionKeys[8],
                  index: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '지금 나의 마음은?'),
                      const SizedBox(height: 8),
                      ...emotionCards.map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SelectionCard(
                              title: card.title,
                              subtitle: card.description,
                              emoji: card.emoji,
                              isSelected: _currentEmotion == card.id,
                              onTap: () {
                                setState(() => _currentEmotion = card.id);
                                _scrollToNextSection(8);
                              },
                            ),
                          )),
                    ],
                  ),
                ),

                // 9. 가장 궁금한 것
                _buildSection(
                  key: _sectionKeys[9],
                  index: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '가장 궁금한 것을 하나만 선택해주세요'),
                      const SizedBox(height: 8),
                      ...curiosityCards.map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SelectionCard(
                              title: card.title,
                              subtitle: card.description,
                              emoji: card.icon,
                              isSelected: _mainCuriosity == card.id,
                              onTap: () {
                                setState(() => _mainCuriosity = card.id);
                                _scrollToNextSection(9);
                              },
                            ),
                          )),
                    ],
                  ),
                ),

                // 10. 카톡/대화 내용 (선택)
                _buildSection(
                  key: _sectionKeys[10],
                  index: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '나누었던 대화가 있다면 (선택)'),
                      const SizedBox(height: 4),
                      Text(
                        '카톡이나 문자 대화를 복사해서 붙여넣어 주세요.\n더 정확한 분석에 도움이 돼요.',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _chatHistoryController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: '대화 내용을 붙여넣어주세요...',
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),

                // 11. 카톡 스크린샷 (선택)
                _buildSection(
                  key: _sectionKeys[11],
                  index: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: '카톡 스크린샷이 있다면 (선택)'),
                      const SizedBox(height: 4),
                      Text(
                        '대화 캡처 이미지를 첨부하면 AI가 대화 톤과 감정을 분석해드려요.',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MultiPhotoSelector(
                        maxPhotos: 3,
                        title: '스크린샷 첨부 (최대 3장)',
                        initialPhotos: _chatScreenshots,
                        onPhotosSelected: (photos) {
                          setState(() => _chatScreenshots = photos);
                        },
                      ),
                      if (_chatScreenshots.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: DSColors.success, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${_chatScreenshots.length}장 첨부됨',
                              style: DSTypography.labelSmall.copyWith(
                                color: DSColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Floating 버튼 공간 확보
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Floating Progress Button
          UnifiedButton.floating(
            text: '마음 분석하기',
            onPressed: (_isLoading || !_canSubmit()) ? null : _analyzeAndShowResult,
            isLoading: _isLoading,
            isEnabled: _canSubmit() && !_isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required GlobalKey key,
    required int index,
    required Widget child,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 32),
      child: child,
    ).animate().fadeIn(
          duration: 400.ms,
          delay: (index * 50).ms,
        );
  }
}
