import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;

class FortuneBestPracticesPage extends ConsumerStatefulWidget {
  const FortuneBestPracticesPage({super.key});

  @override
  ConsumerState<FortuneBestPracticesPage> createState() => _FortuneBestPracticesPageState();
}

class _FortuneBestPracticesPageState extends ConsumerState<FortuneBestPracticesPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedIndex = -1;

  final List<_PracticeCategory> _categories = [
    _PracticeCategory(
      title: '운세 해석의 기본 원칙',
      icon: Icons.psychology_outlined,
      color: Colors.purple,
      items: [
        _PracticeItem(
          title: '운세는 가이드일 뿐',
          content: '운세는 절대적인 운명이 아닌 삶의 방향을 제시하는 나침반입니다. 스스로의 선택과 노력이 가장 중요합니다.',
        ),
        _PracticeItem(
          title: '긍정적 해석의 중요성',
          content: '부정적인 운세도 주의사항이나 개선점으로 받아들이세요. 모든 운세에는 성장의 기회가 숨어있습니다.',
        ),
        _PracticeItem(
          title: '개인별 맞춤 해석',
          content: '같은 운세도 개인의 상황과 환경에 따라 다르게 적용됩니다. 자신의 현재 상황에 맞게 해석하세요.',
        ),
      ],
    ),
    _PracticeCategory(
      title: '운세 확인 최적 시간',
      icon: Icons.access_time,
      color: Colors.blue,
      items: [
        _PracticeItem(
          title: '일일 운세',
          content: '아침 6시~8시: 하루를 시작하기 전 마음가짐을 정리하고 계획을 세우기 좋은 시간입니다.',
        ),
        _PracticeItem(
          title: '주간/월간 운세',
          content: '오전: 다음 주나 달의 계획을 세울 때 참고하면 효과적입니다.',
        ),
        _PracticeItem(
          title: '연애/재물 운세',
          content: '전: 데이트, 투자, 계약 등 중요한 일정 1-2일 전에 확인하세요.',
        ),
        _PracticeItem(
          title: '사주/신년 운세',
          content: '생일: 1년의 큰 흐름을 파악하고 장기 계획을 세울 때 확인하세요.',
        ),
      ],
    ),
    _PracticeCategory(
      title: '운세별 활용법',
      icon: Icons.category_outlined,
      color: Colors.green,
      items: [
        _PracticeItem(
          title: '오늘의 운세',
          content: '• 행운의 시간대를 활용해 중요한 일정 잡기\n• 주의사항을 참고해 실수 예방\n• 행운의 색상으로 포인트 주기',
        ),
        _PracticeItem(
          title: '연애운',
          content: '• 상대방과의 궁합 참고하여 데이트 코스 정하기\n• 연애 조언을 통해 관계 개선점 찾기\n• 싱글은 만남의 기회 포착하기',
        ),
        _PracticeItem(
          title: '재물운',
          content: '• 투자 시기와 분야 참고하기\n• 지출 주의 시기 파악하기\n• 부업이나 새로운 수입원 모색하기',
        ),
        _PracticeItem(
          title: '건강운',
          content: '• 취약한 신체 부위 집중 관리\n• 운동이나 식단 조절 참고\n• 정기 검진 시기 결정하기',
        ),
      ],
    ),
    _PracticeCategory(
      title: '운세 점수 이해하기',
      icon: Icons.score_outlined,
      color: Colors.orange,
      items: [
        _PracticeItem(
          title: '90-100점: 최상의 운',
          content: '적극적으로 새로운 도전을 시작하기 좋은 시기입니다. 중요한 결정이나 투자에 유리합니다.',
        ),
        _PracticeItem(
          title: '70-89점: 좋은 운',
          content: '안정적인 성과를 기대할 수 있습니다. 꾸준히 노력하면 좋은 결과를 얻을 수 있습니다.',
        ),
        _PracticeItem(
          title: '50-69점: 보통 운',
          content: '큰 변화보다는 현상 유지에 집중하세요. 작은 개선사항들을 차근차근 실행하기 좋습니다.',
        ),
        _PracticeItem(
          title: '30-49점: 주의 필요',
          content: '신중한 판단이 필요한 시기입니다. 새로운 시도보다는 기존 일에 집중하세요.',
        ),
        _PracticeItem(
          title: '0-29점: 충전의 시기',
          content: '휴식과 재정비의 시간입니다. 다음을 위한 준비 기간으로 활용하세요.',
        ),
      ],
    ),
    _PracticeCategory(
      title: '운세 정확도 높이기',
      icon: Icons.tips_and_updates_outlined,
      color: Colors.teal,
      items: [
        _PracticeItem(
          title: '정확한 생년월일시',
          content: '특히 사주 기반 운세는 출생 시간이 중요합니다. 가능한 정확한 정보를 입력하세요.',
        ),
        _PracticeItem(
          title: '프로필 완성도',
          content: '혈액형, MBTI, 직업 등 추가 정보를 입력하면 더 정확한 맞춤 운세를 받을 수 있습니다.',
        ),
        _PracticeItem(
          title: '정기적인 확인',
          content: '운세를 꾸준히 확인하고 기록하면 자신만의 운세 패턴을 발견할 수 있습니다.',
        ),
        _PracticeItem(
          title: '피드백 제공',
          content: '운세의 정확도를 평가하고 피드백을 제공하면 AI가 학습하여 더 정확한 운세를 제공합니다.',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '운세 활용법',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '기본 가이드'),
            Tab(text: '전문가 팁'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 기본 가이드 탭
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인트로 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '운세를 200% 활용하는 방법',
                            style: TextStyle(
                              fontSize: 18 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '운세는 삶의 나침반과 같습니다. 올바른 해석과 활용법을 통해 더 나은 선택을 할 수 있도록 도와드립니다.',
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // 카테고리별 가이드
                ..._categories.map((category) => _buildCategorySection(category, fontScale)),
              ],
            ),
          ),
          
          // 전문가 팁 탭
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildExpertTipCard(
                  title: '운세 전문가의 조언',
                  content: '30년 경력 역술가가 전하는 운세 활용 노하우',
                  tips: [
                    '운세는 미래를 결정짓는 것이 아닌, 가능성을 제시하는 것입니다.',
                    '나쁜 운세일 때는 더욱 신중하게, 좋은 운세일 때는 적극적으로 행동하세요.',
                    '운세에 지나치게 의존하지 말고, 참고 자료로 활용하세요.',
                    '매일 같은 시간에 운세를 확인하면 일관된 해석이 가능합니다.',
                  ],
                  fontScale: fontScale,
                ),
                const SizedBox(height: 16),
                _buildExpertTipCard(
                  title: '심리학자의 관점',
                  content: '운세를 통한 자기 성찰과 동기부여',
                  tips: [
                    '운세는 자기 암시 효과를 통해 실제로 긍정적인 변화를 만들 수 있습니다.',
                    '운세 해석 과정에서 자신의 현재 상태를 객관적으로 돌아볼 수 있습니다.',
                    '목표 설정과 계획 수립에 운세를 활용하면 동기부여가 됩니다.',
                    '운세 일기를 작성하여 자신의 성장 과정을 기록해보세요.',
                  ],
                  fontScale: fontScale,
                ),
                const SizedBox(height: 16),
                _buildExpertTipCard(
                  title: '데이터 분석가의 팁',
                  content: '통계로 본 운세 활용법',
                  tips: [
                    '3개월 이상 운세를 기록하면 자신만의 패턴을 발견할 수 있습니다.',
                    '운세 점수와 실제 결과를 비교하여 정확도를 측정해보세요.',
                    '여러 종류의 운세를 종합적으로 분석하면 더 정확한 예측이 가능합니다.',
                    '계절별, 월별 운세 변화를 관찰하여 장기 계획을 세우세요.',
                  ],
                  fontScale: fontScale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(_PracticeCategory category, double fontScale) {
    final isExpanded = _expandedIndex == _categories.indexOf(category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? _categories.indexOf(category) : -1;
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 24,
            ),
          ),
          title: Text(
            category.title,
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.expand_more,
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: category.items.map((item) => _buildPracticeItem(item, fontScale)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeItem(_PracticeItem item, double fontScale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.content,
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertTipCard({
    required String title,
    required String content,
    required List<String> tips,
    required double fontScale,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PracticeCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_PracticeItem> items;

  _PracticeCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _PracticeItem {
  final String title;
  final String content;

  _PracticeItem({
    required this.title,
    required this.content,
  });
}