import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';

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

class _MovingResultTossState extends State<MovingResultToss> {
  late int _overallScore;
  late String _scoreDescription;
  late List<DateTime> _luckyDates;
  late String _luckyDirection;
  late String _mainAdvice;

  @override
  void initState() {
    super.initState();
    _generateFortune();
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
    return Padding(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        children: [
          const SizedBox(height: TossTheme.spacingXL),
          
          // 인사말
          Text(
            '${widget.name}님의\n이사운을 확인해 보세요',
            style: TossTheme.heading1.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: TossTheme.spacingXXL),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 메인 점수 카드
                  _buildScoreCard(),
                  
                  const SizedBox(height: TossTheme.spacingL),
                  
                  // 핵심 조언
                  _buildMainAdviceCard(),
                  
                  const SizedBox(height: TossTheme.spacingL),
                  
                  // 추천 날짜
                  _buildLuckyDatesCard(),
                  
                  const SizedBox(height: TossTheme.spacingL),
                  
                  // 길방향
                  _buildDirectionCard(),
                  
                  const SizedBox(height: TossTheme.spacingL),
                  
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
                  child: OutlinedButton(
                    onPressed: _shareResult,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: TossTheme.primaryBlue),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TossTheme.radiusM),
                      ),
                    ),
                    child: Text(
                      '결과 공유하기',
                      style: TossTheme.button.copyWith(
                        color: TossTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: TossTheme.spacingS),
                
                // 다시 보기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TossTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TossTheme.radiusM),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '다른 조건으로 다시 보기',
                      style: TossTheme.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingXL),
      child: Column(
        children: [
          Text(
            '종합 이사운',
            style: TossTheme.heading3.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TossTheme.textBlack,
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingL),
          
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
                    backgroundColor: TossTheme.borderGray200,
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
                      style: TossTheme.heading1.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _getScoreColor(),
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      '점',
                      style: TossTheme.body2.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getScoreColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingL),
          
          Text(
            _scoreDescription,
            style: TossTheme.body2.copyWith(
              fontSize: 18,
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
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💡', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '핵심 조언',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TossTheme.spacingM),
          
          Text(
            _mainAdvice,
            style: TossTheme.body2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: TossTheme.textGray600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyDatesCard() {
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📅', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '추천 이사 날짜',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TossTheme.spacingM),
          
          ..._luckyDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final rank = ['1순위', '2순위', '3순위'][index];
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _luckyDates.length - 1 ? TossTheme.spacingS : 0
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TossTheme.spacingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: index == 0 
                          ? TossTheme.primaryBlue 
                          : TossTheme.borderGray300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      rank,
                      style: TossTheme.caption.copyWith(
                        color: index == 0 ? Colors.white : TossTheme.textGray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: TossTheme.spacingS),
                  Text(
                    '${date.month}월 ${date.day}일 (${_getWeekdayName(date.weekday)})',
                    style: TossTheme.body2,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDirectionCard() {
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingXL),
      child: Column(
        children: [
          Row(
            children: [
              Text('🧭', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '길방향',
                style: TossTheme.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TossTheme.spacingM),
          
          Container(
            padding: const EdgeInsets.all(TossTheme.spacingL),
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossTheme.radiusM),
            ),
            child: Column(
              children: [
                Text(
                  _luckyDirection,
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: TossTheme.spacingXS),
                Text(
                  '${widget.currentArea}에서 $_luckyDirection 방향으로',
                  style: TossTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이사 정보',
            style: TossTheme.heading3.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TossTheme.textBlack,
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingM),
          
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
      padding: const EdgeInsets.only(bottom: TossTheme.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TossTheme.caption,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TossTheme.body2,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    if (_overallScore >= 80) {
      return Colors.green;
    } else if (_overallScore >= 60) {
      return TossTheme.primaryBlue;
    } else {
      return Colors.orange;
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  void _shareResult() {
    // 햅틱 피드백
    HapticFeedback.mediumImpact();
    
    // 공유 기능 (실제 구현 시)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('결과가 클립보드에 복사되었습니다'),
        backgroundColor: TossTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}