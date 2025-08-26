import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';

/// 투자 카테고리 열거형
enum InvestmentCategory {
  stock('주식', '주식시장의 기회를 찾아보세요', '📈', AppColors.tossBlue),
  crypto('암호화폐', '디지털 자산의 미래를 예측하세요', '🪙', Color(0xFFF57C00)),
  realEstate('부동산', '안정적인 부동산 투자 시기를 알아보세요', '🏠', Color(0xFF388E3C)),
  business('사업/창업', '새로운 사업 기회를 발견하세요', '💼', Color(0xFF7B1FA2));

  const InvestmentCategory(this.title, this.description, this.emoji, this.color);
  
  final String title;
  final String description;
  final String emoji;
  final Color color;
}

/// 위험 성향 열거형
enum RiskLevel {
  conservative('안정형', '안전한 투자를 선호', Color(0xFF00D67A)),
  balanced('균형형', '적절한 위험을 감수', AppColors.tossBlue),
  aggressive('공격형', '높은 수익을 추구', Color(0xFFFF3B30));

  const RiskLevel(this.title, this.description, this.color);
  
  final String title;
  final String description;
  final Color color;
}

class InvestmentFortunePage extends ConsumerStatefulWidget {
  const InvestmentFortunePage({super.key});

  @override
  ConsumerState<InvestmentFortunePage> createState() => _InvestmentFortunePageState();
}

class _InvestmentFortunePageState extends ConsumerState<InvestmentFortunePage> {
  Fortune? _fortune;
  bool _isLoading = false;
  
  // 선택된 설정들
  InvestmentCategory? _selectedCategory;
  int _investmentAmount = 100;
  RiskLevel _selectedRiskLevel = RiskLevel.balanced;
  int _investmentPeriod = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tossBackground,
      appBar: _buildAppBar(),
      body: _fortune != null 
        ? _buildResultView()
        : _buildMainView(),
    );
  }

  /// 토스 스타일 앱바
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.tossTextPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '투자운세',
        style: TextStyle(
          color: AppColors.tossTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 메인 뷰 (운세 요약 + 카테고리 선택)
  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayFortuneCard(),
          const SizedBox(height: 32),
          _buildSectionTitle('어떤 투자를 고민 중이신가요?'),
          const SizedBox(height: 16),
          _buildCategoryGrid(),
          const SizedBox(height: 100), // 하단 여백
        ],
      ),
    );
  }

  /// 오늘의 투자운세 요약 카드
  Widget _buildTodayFortuneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.tossBlueBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.tossBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '오늘의 투자운세',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tossTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '75',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tossBlue,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '점',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tossTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '차분하고 안정적인 투자 시기입니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.tossTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.tossBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  /// 섹션 타이틀
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.tossTextPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  /// 투자 카테고리 그리드
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: InvestmentCategory.values.length,
      itemBuilder: (context, index) {
        final category = InvestmentCategory.values[index];
        return _buildCategoryCard(category, index);
      },
    );
  }

  /// 개별 카테고리 카드
  Widget _buildCategoryCard(InvestmentCategory category, int index) {
    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.tossTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.description,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.tossTextSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  /// 카테고리 선택 시 호출
  void _onCategorySelected(InvestmentCategory category) {
    setState(() {
      _selectedCategory = category;
    });
    
    _showInvestmentInputSheet(category);
  }

  /// 투자 상세 입력 바텀 시트
  void _showInvestmentInputSheet(InvestmentCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInvestmentInputSheet(category),
    );
  }

  /// 투자 입력 바텀 시트 내용
  Widget _buildInvestmentInputSheet(InvestmentCategory category) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 헤더
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${category.title} 투자운세',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tossTextPrimary,
                            ),
                          ),
                          Text(
                            '투자 성향을 알려주세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.tossTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.tossTextSecondary),
                    ),
                  ],
                ),
              ),
              
              // 입력 폼
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountSection(),
                      const SizedBox(height: 32),
                      _buildRiskLevelSection(),
                      const SizedBox(height: 32),
                      _buildPeriodSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // 하단 버튼
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _generateFortune(category),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tossBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '투자운세 확인하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 투자 금액 섹션
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '투자 예정 금액',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.tossTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '$_investmentAmount만원',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.tossBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.tossBlue,
            inactiveTrackColor: AppColors.gray200,
            thumbColor: AppColors.tossBlue,
            overlayColor: AppColors.tossBlue.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
          ),
          child: Slider(
            value: _investmentAmount.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            onChanged: (value) {
              setState(() {
                _investmentAmount = value.round();
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '10만원',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tossTextSecondary,
              ),
            ),
            Text(
              '1000만원',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tossTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 위험 성향 섹션
  Widget _buildRiskLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '투자 성향',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.tossTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...RiskLevel.values.map((risk) {
          final isSelected = _selectedRiskLevel == risk;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRiskLevel = risk;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? risk.color.withValues(alpha: 0.1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? risk.color : AppColors.gray200,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? risk.color : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? risk.color : AppColors.gray300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            risk.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? risk.color : AppColors.tossTextPrimary,
                            ),
                          ),
                          Text(
                            risk.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.tossTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 투자 기간 섹션
  Widget _buildPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '투자 기간',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.tossTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [1, 3, 6, 12, 24].map((months) {
            final isSelected = _investmentPeriod == months;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: months == 24 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _investmentPeriod = months;
                    });
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.tossBlue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.tossBlue : AppColors.gray200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$months개월',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.tossTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 운세 생성
  Future<void> _generateFortune(InvestmentCategory category) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final userProfile = await ref.read(userProfileProvider.future);
      final params = {
        'investmentType': category.name,
        'amount': _investmentAmount,
        'riskLevel': _selectedRiskLevel.name,
        'period': _investmentPeriod,
        'name': userProfile?.name ?? '사용자',
        'birthDate': userProfile?.birthDate?.toIso8601String(),
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: 'investment',
        userId: user.id,
        params: params,
      );

      setState(() {
        _fortune = fortune;
        _isLoading = false;
      });

      // 바텀 시트 닫기
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Logger.error('Investment fortune generation failed', e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('운세 생성에 실패했습니다: ${e.toString()}'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  /// 결과 화면
  Widget _buildResultView() {
    if (_fortune == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFortuneScoreCard(),
          const SizedBox(height: 24),
          _buildFortuneContentCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// 운세 점수 카드
  Widget _buildFortuneScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${_selectedCategory?.title} 투자운세',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.tossTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 점수 원형 표시
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: (_fortune?.score ?? 0) / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(_fortune?.score ?? 0),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_fortune?.score ?? 0}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _getScoreColor(_fortune?.score ?? 0),
                          height: 1,
                        ),
                      ),
                      Text(
                        '점',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.tossTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Text(
            _getScoreDescription(_fortune?.score ?? 0),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.tossTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  /// 운세 내용 카드
  Widget _buildFortuneContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI 운세 분석',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.tossTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _fortune?.content ?? '운세 내용을 불러올 수 없습니다.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.tossTextPrimary,
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0);
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _fortune = null;
                _selectedCategory = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tossBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '다른 투자 운세 보기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // 공유 기능 구현
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tossTextPrimary,
              side: const BorderSide(color: AppColors.gray200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '공유하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3, end: 0);
  }

  /// 점수에 따른 색상
  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.positive;
    if (score >= 60) return AppColors.tossBlue;
    if (score >= 40) return AppColors.caution;
    return AppColors.negative;
  }

  /// 점수에 따른 설명
  String _getScoreDescription(int score) {
    if (score >= 90) return '매우 좋은 투자 시기입니다';
    if (score >= 80) return '좋은 투자 기회가 있습니다';
    if (score >= 70) return '안정적인 투자를 권합니다';
    if (score >= 60) return '신중한 투자가 필요합니다';
    if (score >= 40) return '투자를 미루는 것이 좋겠습니다';
    return '투자는 잠시 보류하세요';
  }
}