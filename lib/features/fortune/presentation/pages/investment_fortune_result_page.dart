import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_theme.dart';
import 'investment_fortune_input_page.dart';

class InvestmentFortuneResultPage extends ConsumerStatefulWidget {
  final InvestmentFortuneParams params;

  const InvestmentFortuneResultPage({
    super.key,
    required this.params,
  });

  @override
  ConsumerState<InvestmentFortuneResultPage> createState() =>
      _InvestmentFortuneResultPageState();
}

class _InvestmentFortuneResultPageState
    extends ConsumerState<InvestmentFortuneResultPage> {
  late ScrollController _scrollController;
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() {
        _showFloatingButton = true;
      });
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() {
        _showFloatingButton = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate fortune score based on params
    final fortuneScore = _calculateFortuneScore();
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: TossTheme.backgroundWhite,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.close, color: TossTheme.textBlack),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: TossTheme.textBlack),
                onPressed: _shareResult,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildScoreSection(fortuneScore),
                _buildDivider(),
                _buildTodayFortune(),
                _buildDivider(),
                _buildRecommendedAssets(),
                _buildDivider(),
                _buildTimingAnalysis(),
                _buildDivider(),
                _buildRiskWarnings(),
                _buildDivider(),
                _buildActionItems(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton.extended(
              onPressed: _scrollToTop,
              backgroundColor: TossTheme.primaryBlue,
              label: Row(
                children: [
                  const Icon(Icons.arrow_upward, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '위로',
                    style: TossTheme.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ).animate(target: _showFloatingButton ? 1 : 0)
              .fadeIn(duration: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
          : null,
    );
  }

  Widget _buildScoreSection(int score) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '오늘의 투자 운세',
            style: TossTheme.heading3.copyWith(
              color: TossTheme.textGray600,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          
          // Score Display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: TossTheme.borderGray200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ).animate()
                  .custom(
                    duration: 1500.ms,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: (score / 100) * value,
                        strokeWidth: 12,
                        backgroundColor: TossTheme.borderGray200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(score),
                        ),
                      );
                    },
                  ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: _getScoreColor(score),
                      height: 1,
                    ),
                  ).animate()
                    .custom(
                      duration: 1500.ms,
                      builder: (context, value, child) {
                        return Text(
                          '${(score * value).toInt()}',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            color: _getScoreColor(score),
                            height: 1,
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreMessage(score),
                    style: TossTheme.body3.copyWith(
                      color: TossTheme.textGray600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // User Profile Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileItem(
                  '투자 스타일',
                  widget.params.style.displayName,
                ),
                _buildProfileItem(
                  '리스크 성향',
                  widget.params.riskTolerance.displayName,
                ),
                _buildProfileItem(
                  '월 투자금',
                  '${widget.params.monthlyAmount.toInt()}만원',
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TossTheme.caption.copyWith(
            color: TossTheme.textGray500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TossTheme.body3.copyWith(
            fontWeight: FontWeight.w600,
            color: TossTheme.textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayFortune() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: TossTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 운세',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TossTheme.primaryBlue.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFortuneMessage(),
                  style: TossTheme.body2.copyWith(
                    height: 1.6,
                    color: TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: TossTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '오늘은 신중한 판단이 필요한 날입니다',
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 400.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildRecommendedAssets() {
    final assets = _getRecommendedAssets();
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: TossTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '추천 투자처',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...assets.asMap().entries.map((entry) {
            final index = entry.key;
            final asset = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossTheme.borderGray200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: asset['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      asset['icon'],
                      color: asset['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset['name'],
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          asset['description'],
                          style: TossTheme.caption.copyWith(
                            color: TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: asset['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      asset['percentage'],
                      style: TossTheme.caption.copyWith(
                        color: asset['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: (600 + index * 100).ms)
              .slideX(begin: 0.05, end: 0);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimingAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule,
                  color: TossTheme.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '투자 타이밍',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossTheme.warning.withOpacity(0.05),
                  TossTheme.warning.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TossTheme.warning.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: TossTheme.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오전 10시 - 11시',
                      style: TossTheme.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TossTheme.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '최적',
                        style: TossTheme.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '오전 시간대에 집중력이 높아 좋은 판단을 내릴 수 있습니다',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 800.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildRiskWarnings() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: TossTheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '주의사항',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossTheme.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TossTheme.error.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildWarningItem(
                  '충동적인 매매는 피하세요',
                  '감정적인 결정보다는 계획에 따른 투자를 하세요',
                ),
                const SizedBox(height: 12),
                _buildWarningItem(
                  '분산 투자를 실천하세요',
                  '한 곳에 모든 자금을 투자하지 마세요',
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 900.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildWarningItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: TossTheme.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.priority_high,
            color: TossTheme.error,
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TossTheme.body3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItems() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: TossTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 실천사항',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionCard(
            '포트폴리오 점검',
            '현재 보유 자산의 비중을 확인하고 리밸런싱하세요',
            Icons.pie_chart,
            TossTheme.primaryBlue,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            '투자 일지 작성',
            '오늘의 투자 결정과 그 이유를 기록해두세요',
            Icons.edit_note,
            TossTheme.success,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            '시장 동향 파악',
            '주요 경제 지표와 뉴스를 확인하세요',
            Icons.newspaper,
            TossTheme.warning,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 1000.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossTheme.borderGray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossTheme.body3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: TossTheme.textGray400,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      color: TossTheme.backgroundSecondary,
    );
  }

  int _calculateFortuneScore() {
    // Simple scoring logic based on parameters
    int score = 50; // Base score

    // Style bonus
    switch (widget.params.style) {
      case InvestmentStyle.conservative:
        score += 10;
        break;
      case InvestmentStyle.balanced:
        score += 15;
        break;
      case InvestmentStyle.growth:
        score += 20;
        break;
      case InvestmentStyle.aggressive:
        score += 25;
        break;
    }

    // Risk adjustment
    switch (widget.params.riskTolerance) {
      case RiskTolerance.veryLow:
        score += 5;
        break;
      case RiskTolerance.low:
        score += 10;
        break;
      case RiskTolerance.medium:
        score += 15;
        break;
      case RiskTolerance.high:
        score += 10;
        break;
    }

    // Add some randomness for daily variation
    score += DateTime.now().day % 10;

    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossTheme.success;
    if (score >= 60) return TossTheme.primaryBlue;
    if (score >= 40) return TossTheme.warning;
    return TossTheme.error;
  }

  String _getScoreMessage(int score) {
    if (score >= 80) return '최고의 투자운!';
    if (score >= 60) return '좋은 기회가 있어요';
    if (score >= 40) return '신중한 접근 필요';
    return '오늘은 관망하세요';
  }

  String _getFortuneMessage() {
    final score = _calculateFortuneScore();
    if (score >= 80) {
      return '오늘은 투자 운이 매우 좋은 날입니다. 준비해둔 투자 계획이 있다면 실행에 옮기기 좋은 시기입니다. 다만 과도한 욕심은 금물이니 적정선에서 만족하는 것이 중요합니다.';
    } else if (score >= 60) {
      return '전반적으로 안정적인 투자 운세입니다. 장기적인 관점에서 접근한다면 좋은 결과를 얻을 수 있을 것입니다. 단기적인 변동에 흔들리지 마세요.';
    } else if (score >= 40) {
      return '오늘은 신중한 접근이 필요한 날입니다. 새로운 투자보다는 기존 포트폴리오를 점검하고 정리하는 시간을 가져보세요.';
    } else {
      return '투자 운이 좋지 않은 날입니다. 오늘은 투자 결정을 미루고 시장을 관찰하며 학습하는 시간으로 활용하세요.';
    }
  }

  List<Map<String, dynamic>> _getRecommendedAssets() {
    // Based on user's investment style and risk tolerance
    if (widget.params.style == InvestmentStyle.conservative) {
      return [
        {
          'name': '채권형 펀드',
          'description': '안정적인 수익률',
          'percentage': '40%',
          'icon': Icons.account_balance,
          'color': TossTheme.success,
        },
        {
          'name': '예금/적금',
          'description': '원금 보장',
          'percentage': '30%',
          'icon': Icons.savings,
          'color': TossTheme.primaryBlue,
        },
        {
          'name': '배당주',
          'description': '꾸준한 배당 수익',
          'percentage': '30%',
          'icon': Icons.trending_up,
          'color': TossTheme.warning,
        },
      ];
    } else if (widget.params.style == InvestmentStyle.balanced) {
      return [
        {
          'name': '인덱스 펀드',
          'description': '시장 평균 수익률',
          'percentage': '40%',
          'icon': Icons.show_chart,
          'color': TossTheme.primaryBlue,
        },
        {
          'name': '우량주',
          'description': '안정적인 대형주',
          'percentage': '35%',
          'icon': Icons.business,
          'color': TossTheme.success,
        },
        {
          'name': '채권',
          'description': '포트폴리오 안정화',
          'percentage': '25%',
          'icon': Icons.receipt_long,
          'color': TossTheme.warning,
        },
      ];
    } else {
      return [
        {
          'name': '성장주',
          'description': '높은 성장 잠재력',
          'percentage': '50%',
          'icon': Icons.rocket_launch,
          'color': TossTheme.error,
        },
        {
          'name': 'ETF',
          'description': '섹터별 분산 투자',
          'percentage': '30%',
          'icon': Icons.pie_chart,
          'color': TossTheme.primaryBlue,
        },
        {
          'name': '해외 주식',
          'description': '글로벌 분산 투자',
          'percentage': '20%',
          'icon': Icons.public,
          'color': TossTheme.success,
        },
      ];
    }
  }

  void _shareResult() {
    HapticFeedback.mediumImpact();
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('공유 기능 준비 중입니다'),
        backgroundColor: TossTheme.textBlack,
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}