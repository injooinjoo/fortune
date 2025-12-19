import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/components/app_card.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 토스 스타일 이사운 결과 페이지
class MovingResultToss extends StatefulWidget {
  final String name;
  final DateTime birthDate;
  final String currentArea;
  final String targetArea;
  final String movingPeriod;
  final String purpose;
  final VoidCallback onRetry;

  const MovingResultToss({
    super.key,
    required this.name,
    required this.birthDate,
    required this.currentArea,
    required this.targetArea,
    required this.movingPeriod,
    required this.purpose,
    required this.onRetry,
  });

  @override
  State<MovingResultToss> createState() => _MovingResultTossState();
}

class _MovingResultTossState extends State<MovingResultToss> with TickerProviderStateMixin {
  late int _overallScore;
  late String _scoreDescription;
  late List<DateTime> _luckyDates;
  late String _luckyDirection;
  late String _mainAdvice;

  late AnimationController _scoreController;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();
    _generateFortune();
    
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
      _cardController.forward();
    });
  }

  void _generateFortune() {
    // 간단한 운세 생성 로직
    final random = math.Random();
    _overallScore = 65 + random.nextInt(30); // 65-95점 사이
    
    // 점수별 설명
    if (_overallScore >= 90) {
      _scoreDescription = '최고의 이사운입니다!';
    } else if (_overallScore >= 80) {
      _scoreDescription = '매우 좋은 이사운이에요';
    } else if (_overallScore >= 70) {
      _scoreDescription = '좋은 이사운입니다';
    } else {
      _scoreDescription = '보통의 이사운이에요';
    }

    // 길한 날짜 생성 (다음 3개월)
    _luckyDates = [];
    final now = DateTime.now();
    for (int i = 0; i < 3; i++) {
      final date = now.add(Duration(days: 10 + i * 15 + random.nextInt(10)));
      _luckyDates.add(date);
    }

    // 길방향
    final directions = ['동쪽', '서쪽', '남쪽', '북쪽'];
    _luckyDirection = directions[random.nextInt(directions.length)];

    // 메인 조언
    _mainAdvice = _getMainAdvice();
  }

  String _getMainAdvice() {
    switch (widget.purpose) {
      case '직장 때문에':
        return '직장과 가까운 곳일수록 업무 운이 상승합니다';
      case '결혼해서':
        return '두 사람의 화합을 위해 남향집을 추천드려요';
      case '교육 환경':
        return '아이의 학업운을 위해 조용한 환경이 좋겠어요';
      case '더 나은 환경':
        return '새로운 시작에는 깨끗하고 밝은 집이 최고예요';
      case '투자 목적':
        return '장기적인 관점에서 교통이 편리한 곳을 선택하세요';
      default:
        return '가족 모두가 행복할 수 있는 따뜻한 집을 찾으세요';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            children: [
              SizedBox(height: DSSpacing.xl),
          
          // 인사말
          Text(
            '${widget.name}님의\n이사운을 확인해 보세요',
            style: context.displayLarge.copyWith(
              
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: DSSpacing.xxl),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 메인 점수 카드
                  _buildScoreCard(),
                  
                  const SizedBox(height: DSSpacing.lg),
                  
                  // 핵심 조언
                  _buildMainAdviceCard(),
                  
                  const SizedBox(height: DSSpacing.lg),
                  
                  // 추천 날짜
                  _buildLuckyDatesCard(),
                  
                  const SizedBox(height: DSSpacing.lg),
                  
                  // 길방향
                  _buildDirectionCard(),
                  
                  const SizedBox(height: DSSpacing.lg),
                  
                  // 이사 정보 요약
                  _buildSummaryCard(),
                ],
              ),
            ),
          ),
          
          // 하단 버튼들
          SafeArea(
            child: Column(
              children: [
                // 공유하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: UnifiedButton(
                    text: '결과 공유하기',
                    onPressed: _shareResult,
                    style: UnifiedButtonStyle.ghost,
                    size: UnifiedButtonSize.large,
                  ),
                ),
                
                const SizedBox(height: DSSpacing.sm),
                
                // 다시 보기 버튼
                SizedBox(
                  width: double.infinity,
                  child: UnifiedButton(
                    text: '다시 보기',
                    onPressed: widget.onRetry,
                    style: UnifiedButtonStyle.primary,
                    size: UnifiedButtonSize.large,
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
  }

  Widget _buildScoreCard() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        children: [
          Text(
            '종합 이사운',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w700,
              color: DSColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: DSSpacing.lg),
          
          // 원형 점수 표시
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _overallScore / 100,
                    strokeWidth: 8,
                    backgroundColor: DSColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_overallScore',
                      style: context.displayLarge.copyWith(
                        
                        fontWeight: FontWeight.w800,
                        color: _getScoreColor(),
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      '점',
                      style: context.bodyMedium.copyWith(
                        
                        fontWeight: FontWeight.w600,
                        color: _getScoreColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: DSSpacing.lg),
          
          Text(
            _scoreDescription,
            style: context.bodyMedium.copyWith(
              
              fontWeight: FontWeight.w700,
              color: _getScoreColor(),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAdviceCard() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💡', style: context.displaySmall),
              SizedBox(width: DSSpacing.sm),
              Text(
                '핵심 조언',
                style: context.heading3.copyWith(
                  
                  fontWeight: FontWeight.w700,
                  color: DSColors.textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: DSSpacing.md),
          
          Text(
            _mainAdvice,
            style: context.bodyMedium.copyWith(
              
              fontWeight: FontWeight.w400,
              color: DSColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyDatesCard() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📅', style: context.displaySmall),
              SizedBox(width: DSSpacing.sm),
              Text(
                '추천 이사 날짜',
                style: context.heading3.copyWith(
                  
                  fontWeight: FontWeight.w700,
                  color: DSColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.md),
          
          ..._luckyDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final rank = ['1순위', '2순위', '3순위'][index];
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _luckyDates.length - 1 ? DSSpacing.sm : 0
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: index == 0 
                          ? DSColors.accent 
                          : DSColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      rank,
                      style: context.labelSmall.copyWith(
                        color: index == 0 ? Colors.white : DSColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '${date.month}월 ${date.day}일 (${_getWeekdayName(date.weekday)})',
                    style: context.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDirectionCard() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Text('🧭', style: context.displaySmall),
              SizedBox(width: DSSpacing.sm),
              Text(
                '길방향',
                style: context.heading3.copyWith(
                  
                  fontWeight: FontWeight.w700,
                  color: DSColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.md),
          
          Container(
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Column(
              children: [
                Text(
                  _luckyDirection,
                  style: context.heading2.copyWith(
                    color: DSColors.accent,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '${widget.currentArea}에서 $_luckyDirection 방향으로',
                  style: context.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이사 정보',
            style: context.heading3.copyWith(
              
              fontWeight: FontWeight.w700,
              color: DSColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: DSSpacing.md),
          
          _buildInfoRow('현재', widget.currentArea),
          _buildInfoRow('목적지', widget.targetArea),
          _buildInfoRow('시기', widget.movingPeriod),
          _buildInfoRow('목적', widget.purpose),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: context.labelSmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    if (_overallScore >= 80) {
      return DSColors.success;
    } else if (_overallScore >= 60) {
      return DSColors.accent;
    } else {
      return DSColors.warning;
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _shareResult() {
    // 햅틱 피드백
    HapticFeedback.mediumImpact();
    
    // 공유 기능 (실제 구현 시)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('결과가 클립보드에 복사되었습니다'),
        backgroundColor: DSColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}