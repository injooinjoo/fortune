import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/wish_fortune_result.dart';
import './wish_fortune_result_page.dart';
import '../../../../services/ad_service.dart';
import '../../../../services/speech_recognition_service.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import '../../../../core/services/unified_fortune_service.dart';

/// 소원 카테고리 정의
enum WishCategory {
  love('💕', '사랑', '연애, 결혼, 짝사랑', TossDesignSystem.errorRed),
  money('💰', '돈', '재물, 투자, 사업', TossDesignSystem.successGreen),
  health('🌿', '건강', '건강, 회복, 장수', TossDesignSystem.successGreen),
  success('🏆', '성공', '취업, 승진, 성취', TossDesignSystem.warningOrange),
  family('👨‍👩‍👧‍👦', '가족', '가족, 화목, 관계', TossDesignSystem.tossBlue),
  study('📚', '학업', '시험, 공부, 성적', TossDesignSystem.infoBlue),
  other('🌟', '기타', '소원이 있으시면', TossDesignSystem.purple);

  const WishCategory(this.emoji, this.name, this.description, this.color);

  final String emoji;
  final String name;
  final String description;
  final Color color;
}

/// 소원 빌기 페이지 - Accordion 형태
class WishFortunePage extends ConsumerStatefulWidget {
  const WishFortunePage({super.key});

  @override
  ConsumerState<WishFortunePage> createState() => _WishFortunePageState();
}

class _WishFortunePageState extends ConsumerState<WishFortunePage> {
  // Controllers
  final TextEditingController _wishController = TextEditingController();

  // Speech Recognition
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  bool _isRecording = false;

  // Selection state
  WishCategory? _selectedCategory;

  // Accordion sections
  List<AccordionInputSection> _accordionSections = [];

  // ✅ 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 광고 미리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.loadInterstitialAd();
    });

    // 음성 인식 초기화
    _initializeSpeechService();

    // Accordion 섹션 초기화
    _initializeAccordionSections();
  }

  Future<void> _initializeSpeechService() async {
    await _speechService.initialize();
  }

  @override
  void dispose() {
    _wishController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      // 1. 카테고리 선택
      AccordionInputSection(
        id: 'category',
        title: '어떤 소원인가요?',
        icon: Icons.category_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildCategoryInput(onComplete),
        value: _selectedCategory,
        isCompleted: _selectedCategory != null,
        displayValue: _selectedCategory != null
            ? '${_selectedCategory!.emoji} ${_selectedCategory!.name}'
            : null,
      ),

      // 2. 소원 입력 (음성 입력 지원)
      AccordionInputSection(
        id: 'wish',
        title: '소원을 말하거나 적어주세요',
        icon: Icons.mic_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildWishInput(onComplete),
        value: _wishController.text.isNotEmpty ? _wishController.text : null,
        isCompleted: _wishController.text.isNotEmpty,
        displayValue: _wishController.text.isNotEmpty
            ? (_wishController.text.length > 30
                ? '${_wishController.text.substring(0, 30)}...'
                : _wishController.text)
            : null,
      ),
    ];
  }

  void _updateAccordionSection(String id, dynamic value, String? displayValue) {
    final index = _accordionSections.indexWhere((section) => section.id == id);
    if (index != -1) {
      setState(() {
        _accordionSections[index] = AccordionInputSection(
          id: _accordionSections[index].id,
          title: _accordionSections[index].title,
          icon: _accordionSections[index].icon,
          inputWidgetBuilder: _accordionSections[index].inputWidgetBuilder,
          value: value,
          isCompleted: value != null,
          displayValue: displayValue,
        );
      });
    }
  }

  bool _canSubmit() {
    return _selectedCategory != null &&
        _wishController.text.trim().length >= 10;
  }

  /// 소원 빌기 실행
  void _submitWish() async {
    if (!_canSubmit()) return;

    // 하루 1회 제한 체크
    final alreadyWished = await _hasWishedToday();
    if (alreadyWished) {
      _showErrorDialog('오늘은 이미 소원을 빌었어요.\n내일 다시 시도해주세요.');
      return;
    }

    // 광고 표시 후 신의 응답 표시
    AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        if (mounted) {
          _generateDivineResponse();
        }
      },
      onAdFailed: () async {
        if (mounted) {
          _generateDivineResponse();
        }
      },
    );
  }

  /// 신의 응답 생성 (UnifiedFortuneService 사용)
  void _generateDivineResponse() async {
    final wishText = _wishController.text.trim();
    final category = _selectedCategory!.name;

    if (!mounted) return;

    // ✅ 로딩 상태 활성화
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userProfile = await _getUserProfile();

      // UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(supabase);

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'wish',
        dataSource: FortuneDataSource.api,
        inputConditions: {
          'wish_text': wishText,
          'category': category,
          'user_profile': userProfile != null
              ? {
                  'birth_date': userProfile['birth_date'],
                  'zodiac': userProfile['chinese_zodiac'],
                }
              : null,
        },
      );

      if (!mounted) return;

      // ✅ 로딩 상태 해제
      setState(() {
        _isLoading = false;
      });

      // FortuneResult.data를 WishFortuneResult로 변환
      final result = WishFortuneResult.fromJson(fortuneResult.data);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WishFortuneResultPage(
            result: result,
            wishText: wishText,
            category: category,
          ),
        ),
      );
    } catch (e) {
      debugPrint('소원 분석 API 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('소원 분석 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
      }
    }
  }

  /// 사용자 프로필 가져오기
  Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return null;

      final data = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint('프로필 가져오기 오류: $e');
      return null;
    }
  }

  /// 오늘 이미 소원을 빌었는지 체크
  Future<bool> _hasWishedToday() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return false;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final data = await supabase
          .from('wish_fortunes')
          .select()
          .eq('user_id', userId)
          .eq('wish_date', today)
          .maybeSingle();

      return data != null;
    } catch (e) {
      debugPrint('오늘 소원 체크 오류: $e');
      return false;
    }
  }

  /// 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        // ✅ 좌측 백 버튼 추가 (타로 페이지 패턴)
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        iconTheme: IconThemeData(
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
        ),
        title: Text(
          '소원 빌기',
          style: TextStyle(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: _accordionSections.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ✅ Accordion 폼
                AccordionInputFormWithHeader(
                  header: _buildTitleSection(isDark),
                  sections: _accordionSections,
                  onAllCompleted: null,
                  completionButtonText: '✨ 소원 빌기',
                ),
                // ✅ 하단 버튼 (UnifiedButton.floating)
                if (_canSubmit() || _isLoading)
                  UnifiedButton.floating(
                    text: _isLoading ? '신의 응답을 받는 중...' : '✨ 소원 빌기',
                    isEnabled: _canSubmit() && !_isLoading,
                    onPressed: _canSubmit() && !_isLoading ? _submitWish : null,
                    isLoading: _isLoading,
                  ),
              ],
            ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌟 소원을 빌어보세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '간절한 마음으로 소원을 작성하면\n신의 특별한 응답을 받을 수 있어요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ===== 입력 위젯들 =====

  Widget _buildCategoryInput(Function(dynamic) onComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복수 선택 불가',
          style: TypographyUnified.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WishCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _updateAccordionSection(
                    'category',
                    category,
                    '${category.emoji} ${category.name}',
                  );
                });
                TossDesignSystem.hapticLight();
                onComplete(category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: TypographyUnified.buttonMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? TossDesignSystem.tossBlue : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWishInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 텍스트 입력 필드 + 마이크 버튼 (GPT 스타일 - 통합형)
        Container(
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isRecording
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray200),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 텍스트 입력 영역
              TextField(
                controller: _wishController,
                maxLines: 4,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: _isRecording ? '듣고 있어요...' : '소원을 말하거나 적어주세요',
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  hintStyle: TypographyUnified.bodyMedium.copyWith(
                    color: _isRecording
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray500),
                  ),
                ),
                style: TypographyUnified.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
                onChanged: (value) {
                  setState(() {});
                  _updateAccordionSection(
                    'wish',
                    value.isNotEmpty ? value : null,
                    value.length > 30 ? '${value.substring(0, 30)}...' : value,
                  );
                },
              ),

              // 하단 툴바 (글자수 + 마이크)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 글자수
                    Text(
                      '${_wishController.text.length}/10자',
                      style: TypographyUnified.labelSmall.copyWith(
                        color: _wishController.text.length >= 10
                            ? TossDesignSystem.successGreen
                            : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray400),
                      ),
                    ),

                    // 마이크 버튼
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? TossDesignSystem.tossBlue
                              : Colors.transparent,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                          size: 20,
                          color: _isRecording
                              ? Colors.white
                              : (isDark ? TossDesignSystem.gray400 : TossDesignSystem.gray500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 음성 녹음 토글
  void _toggleRecording() async {
    if (_isRecording) {
      // 녹음 중지
      await _speechService.stopListening();
      setState(() {
        _isRecording = false;
      });
    } else {
      // 녹음 시작
      setState(() {
        _isRecording = true;
      });

      TossDesignSystem.hapticMedium();

      // 상태 변경 리스너 등록 (자동 종료 감지)
      _speechService.isListeningNotifier.addListener(_onListeningStateChanged);

      await _speechService.startListening(
        onResult: (result) {
          if (mounted) {
            setState(() {
              // 기존 텍스트에 음성 인식 결과 추가
              final currentText = _wishController.text;
              if (currentText.isEmpty) {
                _wishController.text = result;
              } else {
                _wishController.text = '$currentText $result';
              }
              // 커서를 맨 끝으로 이동
              _wishController.selection = TextSelection.fromPosition(
                TextPosition(offset: _wishController.text.length),
              );

              _updateAccordionSection(
                'wish',
                _wishController.text,
                _wishController.text.length > 30
                    ? '${_wishController.text.substring(0, 30)}...'
                    : _wishController.text,
              );
            });
          }
        },
        onPartialResult: (partial) {
          // 부분 결과 업데이트 (실시간 UI 갱신)
          if (mounted) {
            setState(() {});
          }
        },
      );
    }
  }

  /// 음성 인식 상태 변경 핸들러
  void _onListeningStateChanged() {
    if (!_speechService.isListeningNotifier.value && _isRecording) {
      // 음성 인식이 자동으로 종료된 경우
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      _speechService.isListeningNotifier.removeListener(_onListeningStateChanged);
    }
  }

  /// 도움말 다이얼로그
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: TossDesignSystem.tossBlue),
            const SizedBox(width: 8),
            Text('소원 빌기란?', style: TypographyUnified.heading3),
          ],
        ),
        content: Text(
          '소원 빌기는 운세를 보는 것이 아니라, 당신의 간절한 소원을 신에게 전달하고 신의 응답과 격려를 받는 특별한 경험입니다.\n\n'
          '소원을 작성하면 신이 당신만을 위한 맞춤형 응답과 조언을 주실 것입니다.',
          style: TypographyUnified.bodyMedium.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인', style: TypographyUnified.buttonMedium),
          ),
        ],
      ),
    );
  }
}
