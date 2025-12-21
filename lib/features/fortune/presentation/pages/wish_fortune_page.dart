import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/wish_fortune_result.dart';
import './wish_fortune_result_page.dart';
import '../../../../presentation/widgets/ads/interstitial_ad_helper.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/widgets/unified_voice_bubble_input.dart';

/// 소원 카테고리 정의
enum WishCategory {
  love('💕', '사랑', '연애, 결혼, 짝사랑', DSColors.error),
  money('💰', '돈', '재물, 투자, 사업', DSColors.success),
  health('🌿', '건강', '건강, 회복, 장수', DSColors.success),
  success('🏆', '성공', '취업, 승진, 성취', DSColors.warning),
  family('👨‍👩‍👧‍👦', '가족', '가족, 화목, 관계', DSColors.accent),
  study('📚', '학업', '시험, 공부, 성적', DSColors.accent),
  other('🌟', '기타', '소원이 있으시면', DSColors.accentTertiary);

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

  // Accordion sections
  List<AccordionInputSection> _accordionSections = [];

  // ✅ 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 텍스트 변경 리스너 (글자수 업데이트 + 아코디언 상태 업데이트)
    _wishController.addListener(_onWishTextChanged);

    // Accordion 섹션 초기화
    _initializeAccordionSections();
  }

  void _onWishTextChanged() {
    final text = _wishController.text;
    setState(() {});
    _updateAccordionSection(
      'wish',
      text.isNotEmpty ? text : null,
      text.length > 30 ? '${text.substring(0, 30)}...' : text,
    );
  }

  @override
  void dispose() {
    _wishController.removeListener(_onWishTextChanged);
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
        _wishController.text.trim().isNotEmpty;
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
    await InterstitialAdHelper.showInterstitialAdWithCallback(
      ref,
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        // ✅ 좌측 백 버튼 추가 (타로 페이지 패턴)
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        iconTheme: IconThemeData(
          color: colors.textPrimary,
        ),
        title: Text(
          '소원 빌기',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: colors.textSecondary,
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
                  header: _buildTitleSection(colors),
                  sections: _accordionSections,
                  onAllCompleted: null,
                  completionButtonText: '✨ 소원 빌기',
                ),
                // ✅ 하단 버튼 (빨간색 Floating 버튼)
                if (_canSubmit() || _isLoading)
                  UnifiedButton.floatingDanger(
                    text: _isLoading ? '신의 응답을 받는 중...' : '✨ 소원 빌기',
                    isEnabled: _canSubmit() && !_isLoading,
                    onPressed: _canSubmit() && !_isLoading ? _submitWish : null,
                    isLoading: _isLoading,
                  ),
              ],
            ),
    );
  }

  Widget _buildTitleSection(DSColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 동양풍 달과 별 일러스트
        _buildMoonAndStars(colors),
        const SizedBox(height: DSSpacing.lg),
        Text(
          '소원을 빌어보세요',
          style: DSTypography.headingLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          '간절한 마음으로 소원을 빌면 신의 특별한 응답을 받을 수 있어요',
          style: DSTypography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 동양풍 달과 별 일러스트
  Widget _buildMoonAndStars(DSColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moonColor = isDark
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFFFE082);
    final starColor = isDark
        ? const Color(0xFFFFD54F)
        : const Color(0xFFFFB300);

    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 달 (초승달)
          Positioned(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    moonColor,
                    moonColor.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: moonColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // 별들
          Positioned(
            left: 20,
            top: 10,
            child: Icon(Icons.star, size: 14, color: starColor.withValues(alpha: 0.8)),
          ),
          Positioned(
            right: 30,
            top: 5,
            child: Icon(Icons.star, size: 10, color: starColor.withValues(alpha: 0.6)),
          ),
          Positioned(
            right: 50,
            bottom: 15,
            child: Icon(Icons.star, size: 12, color: starColor.withValues(alpha: 0.7)),
          ),
          Positioned(
            left: 40,
            bottom: 10,
            child: Icon(Icons.star, size: 8, color: starColor.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  // ===== 입력 위젯들 =====

  Widget _buildCategoryInput(Function(dynamic) onComplete) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복수 선택 불가',
          style: DSTypography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
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
                onComplete(category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.accent : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: DSTypography.buttonMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: DSTypography.labelSmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? colors.accent : colors.textPrimary,
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
    return UnifiedVoiceBubbleInput(
      controller: _wishController,
      onTextChanged: () {
        final text = _wishController.text;
        _updateAccordionSection(
          'wish',
          text.isNotEmpty ? text : null,
          text.length > 30 ? '${text.substring(0, 30)}...' : text,
        );
      },
      hintText: '소원을 말하거나 적어주세요',
      transcribingText: '듣고 있어요...',
    );
  }

  /// 도움말 다이얼로그
  void _showHelpDialog() {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: colors.accent),
            const SizedBox(width: DSSpacing.sm),
            Text('소원 빌기란?', style: DSTypography.headingSmall),
          ],
        ),
        content: Text(
          '소원 빌기는 운세를 보는 것이 아니라, 당신의 간절한 소원을 신에게 전달하고 신의 응답과 격려를 받는 특별한 경험입니다.\n\n'
          '소원을 작성하면 신이 당신만을 위한 맞춤형 응답과 조언을 주실 것입니다.',
          style: DSTypography.bodyLarge.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('확인', style: DSTypography.buttonMedium),
          ),
        ],
      ),
    );
  }
}
