import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/body_part_selector.dart';
import '../widgets/body_part_grid_selector.dart';
import '../widgets/health_score_card.dart';
import '../widgets/health_timeline_chart.dart';
import '../../domain/models/health_fortune_model.dart';
import '../../data/services/health_fortune_service.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toast.dart';
import '../../../../services/ad_service.dart';

class HealthFortuneTossPage extends StatefulWidget {
  const HealthFortuneTossPage({super.key});

  @override
  State<HealthFortuneTossPage> createState() => _HealthFortuneTossPageState();
}

class _HealthFortuneTossPageState extends State<HealthFortuneTossPage> {
  final PageController _pageController = PageController();
  final HealthFortuneService _healthService = HealthFortuneService();
  
  int _currentStep = 1; // Start from condition selection
  bool _isLoading = false;
  bool _useGridSelector = true; // 그리드 선택기 사용 여부
  
  // 입력 데이터
  ConditionState? _currentCondition;
  List<BodyPart> _selectedBodyParts = [];
  
  // 결과 데이터
  HealthFortuneResult? _fortuneResult;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.pop(context), // Always go back to fortune page
            style: IconButton.styleFrom(
              backgroundColor: TossTheme.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: TossTheme.textBlack,
              size: 20,
            ),
          ),
        ),
        title: Text(
          '건강운세',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행 인디케이터
            if (_currentStep < 3) _buildProgressIndicator(),

            // 페이지 뷰
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildConditionSelectionPage(), // 0: 컨디션 선택 (Start here)
                  _buildBodyPartSelectionPage(), // 1: 신체 부위 선택
                  _buildResultPage(), // 2: 결과 페이지
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(2, (index) { // Changed from 3 to 2 steps
          final isActive = index <= _currentStep - 1; // Adjust for starting at step 1
          final isCompleted = index < _currentStep - 1;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive 
                    ? TossTheme.primaryBlue 
                    : TossTheme.borderGray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate(target: isActive ? 1 : 0)
              .scaleX(duration: 300.ms, curve: Curves.easeOutCubic),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // 헤더 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TossTheme.primaryBlue.withValues(alpha: 0.1),
                  TossTheme.success.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 60,
              color: TossTheme.primaryBlue,
            ),
          ).animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1500.ms),
          
          const SizedBox(height: 32),
          
          // 제목
          Text(
            'AI가 당신의\n건강 상태를 분석해드릴게요',
            style: TossTheme.heading1.copyWith(
              color: TossTheme.textBlack,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // 설명
          Text(
            '오늘의 컨디션과 신경쓰이는 부위를 알려주시면\n맞춤형 건강 조언을 제공해드릴게요',
            style: TossTheme.subtitle1.copyWith(
              color: TossTheme.textGray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 48),
          
          // 특징 리스트
          _buildFeatureList(),
          
          const SizedBox(height: 48),
          
          // 시작 버튼
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '건강 분석 시작하기',
              onPressed: _goToNextStep,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
            ),
          ).animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {'icon': Icons.psychology_rounded, 'title': 'AI 맞춤 분석', 'desc': '개인 상태에 맞는 건강 조언'},
      {'icon': Icons.schedule_rounded, 'title': '시간대별 컨디션', 'desc': '하루 컨디션 변화 예측'},
      {'icon': Icons.healing_rounded, 'title': '실용적 건강 팁', 'desc': '실생활에 도움되는 관리법'},
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TossDesignSystem.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TossTheme.borderGray200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: TossTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: TossTheme.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossTheme.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['desc'] as String,
                      style: TossTheme.body3.copyWith(
                        color: TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: (600 + index * 100).ms)
          .fadeIn(duration: 500.ms)
          .slideX(begin: -0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildConditionSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // 제목
          Text(
            '오늘 몸 상태는\n어떠신가요?',
            style: TossTheme.heading2.copyWith(
              color: TossTheme.textBlack,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '현재 컨디션을 선택해주세요',
            style: TossTheme.subtitle1.copyWith(
              color: TossTheme.textGray600,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 컨디션 선택 옵션들
          ...ConditionState.values.map((condition) {
            final index = ConditionState.values.indexOf(condition);
            return _buildConditionOption(condition, index);
          }).toList(),
          
          const SizedBox(height: 32),
          
          // 다음 버튼
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: _currentCondition != null ? '다음 단계로' : '건너뛰기',
              onPressed: _goToNextStep,
              style: _currentCondition != null 
                  ? TossButtonStyle.primary 
                  : TossButtonStyle.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionOption(ConditionState condition, int index) {
    final isSelected = _currentCondition == condition;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentCondition = condition;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.05) : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? TossTheme.primaryBlue : TossDesignSystem.white.withValues(alpha: 0.0),
                border: isSelected ? null : Border.all(color: TossTheme.borderGray300, width: 2),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: TossDesignSystem.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.displayName,
                    style: TossTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? TossTheme.primaryBlue : TossTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getConditionDescription(condition),
                    style: TossTheme.body3.copyWith(
                      color: TossTheme.textGray600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.arrow_forward_ios,
                color: TossTheme.primaryBlue,
                size: 16,
              ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms)
      .fadeIn(duration: 500.ms)
      .slideX(begin: -0.1, end: 0);
  }

  String _getConditionDescription(ConditionState condition) {
    switch (condition) {
      case ConditionState.excellent:
        return '몸도 마음도 최상의 컨디션이에요';
      case ConditionState.good:
        return '전반적으로 좋은 상태예요';
      case ConditionState.normal:
        return '평상시와 비슷해요';
      case ConditionState.tired:
        return '조금 피곤하고 지쳐있어요';
      case ConditionState.sick:
        return '몸이 아프거나 컨디션이 안 좋아요';
    }
  }

  Widget _buildBodyPartSelectionPage() {
    return Column(
      children: [
        // 선택 모드 토글
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: TossTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _useGridSelector = true;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _useGridSelector ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha: 0.0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _useGridSelector
                          ? [
                              BoxShadow(
                                color: TossDesignSystem.black.withValues(alpha: 0.08),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: _useGridSelector
                              ? TossTheme.primaryBlue
                              : TossTheme.textGray600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '목록 선택',
                          style: TossTheme.body3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _useGridSelector
                                ? TossTheme.primaryBlue
                                : TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _useGridSelector = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_useGridSelector ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha: 0.0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_useGridSelector
                          ? [
                              BoxShadow(
                                color: TossDesignSystem.black.withValues(alpha: 0.08),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: !_useGridSelector
                              ? TossTheme.primaryBlue
                              : TossTheme.textGray600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '실루엣 선택',
                          style: TossTheme.body3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: !_useGridSelector
                                ? TossTheme.primaryBlue
                                : TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 선택기
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _useGridSelector
                ? BodyPartGridSelector(
                    key: const ValueKey('grid'),
                    selectedParts: _selectedBodyParts,
                    onSelectionChanged: (parts) {
                      setState(() {
                        _selectedBodyParts = parts;
                      });
                    },
                  )
                : BodyPartSelector(
                    key: const ValueKey('silhouette'),
                    selectedParts: _selectedBodyParts,
                    onSelectionChanged: (parts) {
                      setState(() {
                        _selectedBodyParts = parts;
                      });
                    },
                  ),
          ),
        ),
        
        // 하단 버튼
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TossButton(
                  text: '건강 분석하기',
                  onPressed: _generateHealthFortune,
                  isLoading: _isLoading,
                  icon: _isLoading ? null : const Icon(Icons.auto_awesome_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _selectedBodyParts.clear();
                  });
                  _generateHealthFortune();
                },
                child: Text(
                  '전체적으로 분석하기',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultPage() {
    if (_fortuneResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 건강 점수 카드
          HealthScoreCard(
            score: _fortuneResult!.overallScore,
            mainMessage: _fortuneResult!.mainMessage,
          ),
          
          // 신체 부위별 상태 (선택된 부위가 있는 경우)
          if (_selectedBodyParts.isNotEmpty) ...[
            _buildBodyPartHealthSection(),
            const SizedBox(height: 20),
          ],
          
          // 건강 관리 추천사항
          _buildRecommendationsSection(),
          
          const SizedBox(height: 20),
          
          // 시간대별 컨디션
          HealthTimelineChart(timeline: _fortuneResult!.timeline),
          
          const SizedBox(height: 20),
          
          // 피해야 할 것들
          _buildAvoidanceSection(),
          
          const SizedBox(height: 20),
          
          // 내일 미리보기
          if (_fortuneResult!.tomorrowPreview != null)
            _buildTomorrowPreviewSection(),
          
          const SizedBox(height: 40),
          
          // 공유 및 다시하기 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TossButton(
                    text: '결과 공유하기',
                    onPressed: _shareResult,
                    style: TossButtonStyle.secondary,
                    icon: const Icon(Icons.share, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TossButton(
                    text: '다시 분석하기',
                    onPressed: _restartAnalysis,
                    icon: const Icon(Icons.refresh, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBodyPartHealthSection() {
    final concernedParts = _fortuneResult!.bodyPartHealthList
        .where((bph) => _selectedBodyParts.contains(bph.bodyPart))
        .toList();
    
    if (concernedParts.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관심 부위 상태',
            style: TossTheme.heading3.copyWith(
              color: TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          
          ...concernedParts.map((bph) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(bph.level.colorValue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(bph.level.colorValue).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bph.bodyPart.displayName,
                        style: TossTheme.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossTheme.textBlack,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(bph.level.colorValue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bph.score}점',
                          style: TossTheme.caption.copyWith(
                            color: TossDesignSystem.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bph.description,
                    style: TossTheme.body3.copyWith(
                      color: TossTheme.textGray600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 건강 관리',
            style: TossTheme.heading3.copyWith(
              color: TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._fortuneResult!.recommendations.map((rec) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    rec.type.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.title,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rec.description,
                          style: TossTheme.body3.copyWith(
                            color: TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAvoidanceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: TossTheme.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘 피해야 할 것들',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fortuneResult!.avoidanceList.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: TossTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TossTheme.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowPreviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TossTheme.primaryBlue.withValues(alpha: 0.1),
            TossTheme.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TossTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '내일 건강 미리보기',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            _fortuneResult!.tomorrowPreview!,
            style: TossTheme.body2.copyWith(
              color: TossTheme.textBlack,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    if (_currentStep < 2) { // Adjusted for 2 steps instead of 3
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) { // Adjusted for starting at step 1
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _generateHealthFortune() async {
    setState(() {
      _isLoading = true;
    });

    // Show ad before generating health fortune
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        try {
          final input = HealthFortuneInput(
            userId: 'test_user_id', // 실제로는 현재 사용자 ID
            currentCondition: _currentCondition,
            concernedBodyParts: _selectedBodyParts.isNotEmpty ? _selectedBodyParts : null,
          );

          final result = await _healthService.generateHealthFortune(input);

          setState(() {
            _fortuneResult = result;
          });

          _goToNextStep();

        } catch (e) {
          Toast.error(context, '건강운세 생성 중 오류가 발생했습니다.');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onAdFailed: () async {
        // Generate health fortune even if ad fails
        try {
          final input = HealthFortuneInput(
            userId: 'test_user_id', // 실제로는 현재 사용자 ID
            currentCondition: _currentCondition,
            concernedBodyParts: _selectedBodyParts.isNotEmpty ? _selectedBodyParts : null,
          );

          final result = await _healthService.generateHealthFortune(input);

          setState(() {
            _fortuneResult = result;
          });

          _goToNextStep();

        } catch (e) {
          Toast.error(context, '건강운세 생성 중 오류가 발생했습니다.');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _shareResult() {
    // TODO: 공유 기능 구현
    Toast.info(context, '공유 기능은 준비 중입니다');
  }

  void _restartAnalysis() {
    setState(() {
      _currentStep = 1; // Start from condition selection
      _currentCondition = null;
      _selectedBodyParts.clear();
      _fortuneResult = null;
    });

    _pageController.animateToPage(
      0, // First page is now condition selection
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}