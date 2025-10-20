import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/wish_fortune_result.dart';
import './wish_fortune_result_tinder.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';

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

  // Selection state
  WishCategory? _selectedCategory;
  int? _urgencyLevel;

  // Accordion sections
  List<AccordionInputSection> _accordionSections = [];

  @override
  void initState() {
    super.initState();

    // 광고 미리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.loadInterstitialAd();
    });

    // Accordion 섹션 초기화
    _initializeAccordionSections();
  }

  @override
  void dispose() {
    _wishController.dispose();
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

      // 2. 소원 입력
      AccordionInputSection(
        id: 'wish',
        title: '소원을 자세히 적어주세요',
        icon: Icons.edit_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildWishInput(onComplete),
        value: _wishController.text.isNotEmpty ? _wishController.text : null,
        isCompleted: _wishController.text.isNotEmpty,
        displayValue: _wishController.text.isNotEmpty
            ? (_wishController.text.length > 30
                ? '${_wishController.text.substring(0, 30)}...'
                : _wishController.text)
            : null,
      ),

      // 3. 긴급도 선택
      AccordionInputSection(
        id: 'urgency',
        title: '얼마나 간절한가요?',
        icon: Icons.favorite_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildUrgencyInput(onComplete),
        value: _urgencyLevel,
        isCompleted: _urgencyLevel != null,
        displayValue: _urgencyLevel != null
            ? _getUrgencyText(_urgencyLevel!)
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
        _wishController.text.trim().isNotEmpty &&
        _urgencyLevel != null;
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
    final urgency = _urgencyLevel!;

    if (!mounted) return;

    // 간단한 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.cardBackgroundDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: TossDesignSystem.tossBlue,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  '신의 응답을 받는 중...',
                  style: TypographyUnified.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

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
          'urgency': urgency,
          'user_profile': userProfile != null
              ? {
                  'birth_date': userProfile['birth_date'],
                  'zodiac': userProfile['chinese_zodiac'],
                }
              : null,
        },
      );

      if (!mounted) return;

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // FortuneResult.data를 WishFortuneResult로 변환
      final result = WishFortuneResult.fromJson(fortuneResult.data);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WishFortuneResultTinder(
            result: result,
            wishText: wishText,
            category: category,
            urgency: urgency,
          ),
        ),
      );
    } catch (e) {
      debugPrint('소원 분석 API 오류: $e');
      if (mounted) {
        Navigator.of(context).pop();
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
      appBar: StandardFortuneAppBar(
        title: '소원 빌기',
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
      body: SafeArea(
        child: Stack(
          children: [
            _accordionSections.isEmpty
                ? Center(child: CircularProgressIndicator())
                : AccordionInputFormWithHeader(
                    header: _buildTitleSection(isDark),
                    sections: _accordionSections,
                    onAllCompleted: null,
                    completionButtonText: '✨ 소원 빌기',
                  ),
            if (_canSubmit())
              TossFloatingProgressButtonPositioned(
                text: '✨ 소원 빌기',
                onPressed: _canSubmit() ? () => _submitWish() : null,
                isEnabled: _canSubmit(),
                showProgress: false,
                isVisible: _canSubmit(),
              ),
          ],
        ),
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
                      ? TossDesignSystem.tossBlue.withOpacity(0.1)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '마음을 담아 작성해주세요',
          style: TypographyUnified.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _wishController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '마음을 담아 소원을 적어보세요...',
            filled: true,
            fillColor: TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TossDesignSystem.tossBlue, width: 2),
            ),
          ),
          style: TypographyUnified.bodyMedium,
          onChanged: (value) {
            // UI 상태만 업데이트 (onComplete 호출 안함)
            _updateAccordionSection(
              'wish',
              value.isNotEmpty ? value : null,
              value.length > 30 ? '${value.substring(0, 30)}...' : value,
            );
          },
        ),
        const SizedBox(height: 12),
        // 다음 버튼 (10자 이상 입력 시 활성화)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _wishController.text.trim().length >= 10
                ? () {
                    final value = _wishController.text.trim();
                    _updateAccordionSection(
                      'wish',
                      value,
                      value.length > 30 ? '${value.substring(0, 30)}...' : value,
                    );
                    onComplete(value);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TossDesignSystem.tossBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: TossDesignSystem.gray200,
            ),
            child: Text(
              '다음',
              style: TypographyUnified.buttonMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyInput(Function(dynamic) onComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '간절함의 정도를 선택해주세요',
          style: TypographyUnified.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [1, 2, 3, 4, 5].map((level) {
            final isSelected = _urgencyLevel == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _urgencyLevel = level;
                    _updateAccordionSection(
                      'urgency',
                      level,
                      _getUrgencyText(level),
                    );
                  });
                  TossDesignSystem.hapticLight();
                  onComplete(level);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TossDesignSystem.tossBlue.withOpacity(0.1)
                        : TossDesignSystem.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '⭐' * level,
                        style: TypographyUnified.buttonMedium,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getUrgencyText(level),
                          style: TypographyUnified.buttonMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? TossDesignSystem.tossBlue : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: TossDesignSystem.tossBlue,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getUrgencyText(int level) {
    switch (level) {
      case 1:
        return '조금 바라는 정도예요';
      case 2:
        return '그럭저럭 이루고 싶어요';
      case 3:
        return '꽤 간절해요';
      case 4:
        return '정말 간절해요';
      case 5:
        return '온 마음을 다해 빌어요';
      default:
        return '';
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
