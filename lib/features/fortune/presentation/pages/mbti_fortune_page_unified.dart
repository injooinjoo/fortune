import 'dart:ui'; // ✅ Phase 18-1: ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/widgets/fortune_result_widgets.dart';
import '../../../../core/models/fortune_result.dart';
import '../../domain/models/conditions/mbti_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
// ✅ Phase 18-2
import '../../../../presentation/providers/ad_provider.dart'; // ✅ Phase 18-2
import '../../../../presentation/providers/user_profile_notifier.dart';

import '../../../../core/widgets/unified_button.dart';
/// MBTI 운세 페이지 (UnifiedFortuneService 버전)
///
/// **개선 사항**:
/// - ✅ BaseFortunePage 제거 (중복 호출 방지)
/// - ✅ UnifiedFortuneBaseWidget 사용 (72% API 비용 절감)
/// - ✅ FortuneResultWidgets 사용 (재사용 가능한 UI)
/// - ✅ 코드 길이: 1276 라인 → 약 500 라인 (60% 감소)
class MbtiFortunePageUnified extends ConsumerStatefulWidget {
  const MbtiFortunePageUnified({super.key});

  @override
  ConsumerState<MbtiFortunePageUnified> createState() =>
      _MbtiFortunePageUnifiedState();
}

class _MbtiFortunePageUnifiedState
    extends ConsumerState<MbtiFortunePageUnified> {
  // ==================== State ====================

  String? _selectedMbti;
  final List<String> _selectedCategories = [];
  bool _showAllGroups = true;
  final ScrollController _scrollController = ScrollController();

  // ✅ Phase 18-3: Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ==================== MBTI Data ====================

  static const Map<String, List<String>> _mbtiGroups = {
    '분석가': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    '외교관': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    '관리자': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    '탐험가': ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
  };

  static const Map<String, List<Color>> _mbtiColors = {
    'INTJ': [Color(0xFF6B46C1), Color(0xFF9333EA)],
    'INTP': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    'ENTJ': [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    'ENTP': [Color(0xFF8B5CF6), Color(0xFFBB9EFA)],
    'INFJ': [Color(0xFF059669), Color(0xFF10B981)],
    'INFP': [Color(0xFF0891B2), Color(0xFF06B6D4)],
    'ENFJ': [Color(0xFF0D9488), Color(0xFF14B8A6)],
    'ENFP': [Color(0xFF10B981), Color(0xFF34D399)],
    'ISTJ': [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    'ISFJ': [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    'ESTJ': [Color(0xFF1F2937), Color(0xFF4B5563)],
    'ESFJ': [Color(0xFF312E81), Color(0xFF4F46E5)],
    'ISTP': [Color(0xFFDC2626), Color(0xFFEF4444)],
    'ISFP': [Color(0xFFEA580C), Color(0xFFF97316)],
    'ESTP': [Color(0xFFE11D48), Color(0xFFF43F5E)],
    'ESFP': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  };

  static const List<Map<String, dynamic>> _categories = [
    {'label': '연애운', 'icon': Icons.favorite, 'color': Color(0xFFEC4899)},
    {'label': '직업운', 'icon': Icons.work, 'color': Color(0xFF3B82F6)},
    {'label': '재물운', 'icon': Icons.attach_money, 'color': Color(0xFF10B981)},
    {'label': '건강운', 'icon': Icons.health_and_safety, 'color': Color(0xFFF59E0B)},
    {'label': '대인관계', 'icon': Icons.people, 'color': Color(0xFF8B5CF6)},
    {'label': '학업운', 'icon': Icons.school, 'color': Color(0xFF06B6D4)},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'mbti',
      title: 'MBTI 운세',
      description: '나의 성격 유형으로 보는 오늘의 운세',

      // ✅ 입력 폼
      inputBuilder: (context, onSubmit) => _buildInputForm(onSubmit),

      // ✅ 최적화 조건 (72% 비용 절감!)
      conditionsBuilder: () async {
        final userProfileAsync = ref.read(userProfileProvider);
        final userProfile = userProfileAsync.maybeWhen(
          data: (profile) => profile,
          orElse: () => null,
        );

        return MbtiFortuneConditions(
          mbtiType: _selectedMbti!,
          date: DateTime.now(),
          name: userProfile?.name ?? '사용자',
          birthDate: userProfile?.birthDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        );
      },

      // ✅ 결과 화면 (FortuneResultWidgets 재사용)
      resultBuilder: (context, result) => _buildResultView(result),
    );
  }

  // ==================== Input Form ====================

  Widget _buildInputForm(VoidCallback onSubmit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSubmit = _selectedMbti != null;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildTitleSection(),
              const SizedBox(height: 32),

              // MBTI 선택
              _buildMbtiGroupsSection(isDark),

              // 선택된 MBTI 정보
              if (_selectedMbti != null) ...[
                const SizedBox(height: 32),
                _buildSelectedMbtiInfo(isDark),
                const SizedBox(height: 24),
                _buildCategorySelection(isDark),
              ],
            ],
          ),
        ),

        // 제출 버튼
        if (canSubmit)
          UnifiedButton.floating(
            text: '🧠 내 성격이 말하는 오늘',
            onPressed: onSubmit,
            isEnabled: true,
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 MBTI를\n선택해주세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '16가지 성격 유형 중 나와 맞는 유형을 선택하세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark
                ? TossDesignSystem.grayDark100
                : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMbtiGroupsSection(bool isDark) {
    return Column(
      children: [
        // Accordion 헤더
        GestureDetector(
          onTap: () {
            setState(() {
              _showAllGroups = !_showAllGroups;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _showAllGroups
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark
                      ? TossDesignSystem.grayDark700
                      : TossDesignSystem.gray50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showAllGroups
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.3)
                    : (isDark
                        ? TossDesignSystem.grayDark400
                        : TossDesignSystem.gray200),
                width: _showAllGroups ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedMbti ?? 'MBTI 성격 유형 선택',
                    style: TypographyUnified.buttonMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
                    ),
                  ),
                ),
                Icon(
                  _showAllGroups
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // MBTI 그리드
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showAllGroups
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: _mbtiGroups.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 그룹 라벨
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _getGroupColor(entry.key),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Text(
                            entry.key,
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? TossDesignSystem.white
                                  : TossDesignSystem.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // MBTI 카드
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: entry.value
                          .map((mbti) => _buildMbtiCard(mbti, isDark))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildMbtiCard(String mbti, bool isDark) {
    final isSelected = _selectedMbti == mbti;
    final colors = _mbtiColors[mbti]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMbti = mbti;
        });
        HapticFeedback.mediumImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: colors) : null,
          color: isSelected
              ? null
              : (isDark
                  ? TossDesignSystem.grayDark700
                  : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors[0]
                : (isDark
                    ? TossDesignSystem.grayDark400
                    : TossDesignSystem.gray200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            mbti,
            style: TypographyUnified.buttonSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? TossDesignSystem.white : TossDesignSystem.gray800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMbtiInfo(bool isDark) {
    final colors = _mbtiColors[_selectedMbti]!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMbti!,
            style: TypographyUnified.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMbtiDescription(_selectedMbti!),
            style: TypographyUnified.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 운을 보고 싶으신가요?',
          style: TypographyUnified.buttonMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat['label']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(cat['label']);
                  } else {
                    _selectedCategories.add(cat['label'] as String);
                  }
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (cat['color'] as Color).withValues(alpha: 0.1)
                      : (isDark
                          ? TossDesignSystem.grayDark700
                          : TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (cat['color'] as Color)
                        : (isDark
                            ? TossDesignSystem.grayDark400
                            : TossDesignSystem.gray200),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? (cat['color'] as Color)
                          : (isDark
                              ? TossDesignSystem.grayDark100
                              : TossDesignSystem.gray600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? (cat['color'] as Color)
                            : (isDark
                                ? TossDesignSystem.grayDark100
                                : TossDesignSystem.gray600),
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

  // ==================== Blur Methods ====================

  // ✅ Phase 18-5: 광고 보고 블러 제거 로직
  Future<void> _showAdAndUnblur() async {
    final adService = ref.read(adServiceProvider);

    await adService.showRewardedAd(
      onUserEarnedReward: (ad, reward) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });
      },
    );
  }

  // ✅ Phase 18-5: 블러 처리 헬퍼
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Result View ====================

  Widget _buildResultView(FortuneResult result) {
    // ✅ Phase 18-4: result.isBlurred 동기화
    if (_isBlurred != result.isBlurred || _blurredSections.length != result.blurredSections.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isBlurred = result.isBlurred;
            _blurredSections = List<String>.from(result.blurredSections);
          });
        }
      });
    }

    final data = result.data as Map<String, dynamic>? ?? {};
    final scoreBreakdown = data['score_breakdown'] as Map<String, dynamic>? ?? {};
    final luckyItems = data['lucky_items'] as Map<String, dynamic>? ?? {};
    final description = data['today_fortune'] as String? ?? result.summary['message'] as String? ?? '';
    final recommendations = (data['recommendations'] as List?)?.cast<String>() ?? [];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
          // ✅ 점수 카드 (FortuneResultWidgets 재사용!)
          FortuneResultWidgets.buildScoreCard(
            context: context,
            score: result.score ?? 75,
            fortuneType: 'mbti',
            category: 'MBTI 운세 - $_selectedMbti',
            fortuneData: data,
          ),
          const SizedBox(height: 16),

          // ✅ 세부 점수 (FortuneResultWidgets 재사용!)
          if (scoreBreakdown.isNotEmpty)
            _buildBlurWrapper(
              sectionKey: 'score_breakdown',
              child: FortuneResultWidgets.buildScoreBreakdown(
                context: context,
                scoreBreakdown: scoreBreakdown,
              ),
            ),
          const SizedBox(height: 16),

          // ✅ 행운 아이템 (FortuneResultWidgets 재사용!)
          if (luckyItems.isNotEmpty)
            _buildBlurWrapper(
              sectionKey: 'lucky_items',
              child: FortuneResultWidgets.buildLuckyItems(
                context: context,
                luckyItems: luckyItems,
              ),
            ),
          const SizedBox(height: 16),

          // ✅ 본문 (FortuneResultWidgets 재사용!)
          if (description.isNotEmpty)
            _buildBlurWrapper(
              sectionKey: 'description',
              child: FortuneResultWidgets.buildDescription(
                context: context,
                ref: ref,
                description: description,
                fortuneType: 'mbti',
                fortuneData: data,
              ),
            ),
          const SizedBox(height: 16),

          // ✅ 추천 사항 (FortuneResultWidgets 재사용!)
          if (recommendations.isNotEmpty)
            _buildBlurWrapper(
              sectionKey: 'recommendations',
              child: FortuneResultWidgets.buildRecommendations(
                context: context,
                recommendations: recommendations,
              ),
            ),
          const SizedBox(height: 32),
            ],
          ),
        ),

        // ✅ Phase 18-7: 광고 보고 전체보기 버튼
        if (_isBlurred)
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 116), // bottom: 100 효과
          ),
      ],
    );
  }

  // ==================== Helpers ====================

  Color _getGroupColor(String groupName) {
    switch (groupName) {
      case '분석가':
        return const Color(0xFF8B5CF6);
      case '외교관':
        return const Color(0xFF10B981);
      case '관리자':
        return const Color(0xFF3B82F6);
      case '탐험가':
        return const Color(0xFFF59E0B);
      default:
        return TossDesignSystem.tossBlue;
    }
  }

  String _getMbtiDescription(String mbti) {
    const descriptions = {
      'INTJ': '전략적 사고를 가진 완벽주의자',
      'INTP': '논리적이고 창의적인 사색가',
      'ENTJ': '대담한 지도자형 인간',
      'ENTP': '영리한 발명가형 인간',
      'INFJ': '선의의 옹호자형 인간',
      'INFP': '열정적인 중재자형 인간',
      'ENFJ': '정의로운 사회운동가',
      'ENFP': '재기발랄한 활동가',
      'ISTJ': '청렴결백한 논리주의자',
      'ISFJ': '용감한 수호자형 인간',
      'ESTJ': '엄격한 관리자형 인간',
      'ESFJ': '사교적인 외교관형 인간',
      'ISTP': '만능 재주꾼형 인간',
      'ISFP': '호기심 많은 예술가',
      'ESTP': '모험을 즐기는 사업가',
      'ESFP': '자유로운 영혼의 연예인',
    };
    return descriptions[mbti] ?? '';
  }
}
