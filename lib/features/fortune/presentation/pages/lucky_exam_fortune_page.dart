import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../widgets/fortune_button.dart';
import '../constants/fortune_button_spacing.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/standard_fortune_page_layout.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../data/services/fortune_api_service.dart';
import 'dart:math' as math;
import '../../../../services/ad_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';

class LuckyExamFortunePage extends ConsumerStatefulWidget {
  const LuckyExamFortunePage({super.key});

  @override
  ConsumerState<LuckyExamFortunePage> createState() => _LuckyExamFortunePageState();
}

class _LuckyExamFortunePageState extends ConsumerState<LuckyExamFortunePage> {
  Fortune? _fortuneResult;
  bool _isLoading = false;
  
  String _examType = '';
  String _examDate = '';
  String _studyPeriod = '1개월';
  String _confidence = '보통';
  String _difficulty = '보통';

  final List<String> _studyPeriods = ['1주일', '2주일', '1개월', '3개월', '6개월', '1년 이상'];
  final List<String> _confidenceLevels = ['매우 불안', '불안', '보통', '자신있음', '매우 자신있음'];
  final List<String> _difficultyLevels = ['매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: TossDesignSystem.gray50,
      appBar: const StandardFortuneAppBar(
        title: '시험 운세',
      ),
      body: _fortuneResult != null
          ? _buildResultView(isDark)
          : _buildInputView(isDark),
    );
  }

  Future<void> _analyzeExam() async {
    if (_examType.isEmpty || _examDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('시험 종류와 예정일을 입력해주세요'),
          backgroundColor: TossDesignSystem.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // UnifiedFortuneService용 input_conditions 구성 (snake_case)
      final inputConditions = {
        'exam_type': _examType,
        'exam_date': _examDate,
        'study_period': _studyPeriod,
        'confidence': _confidence,
        'difficulty': _difficulty,
      };

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'exam',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
      );

      final fortune = _convertToFortune(fortuneResult);

      setState(() {
        _fortuneResult = fortune;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Generate mock data on error
      _generateMockResult();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('서버 연결 중 오류가 발생했습니다. 샘플 데이터를 표시합니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  void _generateMockResult() {
    // Generate mock fortune result for testing
    final random = math.Random();
    final overallScore = 70 + random.nextInt(25);
    
    setState(() {
      _fortuneResult = Fortune(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user',
        type: 'lucky-exam',
        content: _generateMockContent(overallScore),
        overallScore: overallScore,
        scoreBreakdown: {
          '합격 가능성': overallScore,
          '준비도': 65 + random.nextInt(30),
          '시험 당일 운': 60 + random.nextInt(35),
          '집중력': 70 + random.nextInt(25),
        },
        recommendations: _generateMockRecommendations(),
        luckyItems: {
          'color': ['파란색', '흰색'],
          'number': ['7', '3'],
          'item': ['샤프펜슬', '시계'],
          'food': ['초콜릿', '바나나'],
        },
        createdAt: DateTime.now(),
      );
      _isLoading = false;
    });
  }

  String _generateMockContent(int score) {
    if (score >= 85) {
      return '${_examType} 시험에서 좋은 결과가 예상됩니다! 지금까지의 노력이 빛을 발할 때입니다. 자신감을 가지고 차분하게 준비하세요. 시험 당일 컨디션 관리가 중요합니다.';
    } else if (score >= 70) {
      return '${_examType} 시험 준비가 순조롭게 진행되고 있습니다. 남은 기간 동안 약점 보완에 집중하면 좋은 결과를 얻을 수 있을 것입니다. 긍정적인 마음가짐을 유지하세요.';
    } else {
      return '${_examType} 시험을 위해 조금 더 집중이 필요한 시기입니다. 기본기를 다시 한번 점검하고, 실전 연습을 늘려보세요. 포기하지 않는다면 충분히 좋은 결과를 얻을 수 있습니다.';
    }
  }

  List<String> _generateMockRecommendations() {
    return [
      '오전 시간을 활용한 집중 학습을 추천합니다',
      '시험 일주일 전부터는 새로운 내용보다 복습에 집중하세요',
      '충분한 수면과 규칙적인 생활 패턴을 유지하세요',
      '시험장에 일찍 도착하여 마음을 안정시키세요',
      '자신감을 갖되 겸손한 마음으로 임하세요',
    ];
  }

  Widget _buildInputView(bool isDark) {
    return StandardFortunePageLayout(
      buttonText: '운세 분석하기',
      onButtonPressed: () async {
        await AdService.instance.showInterstitialAdWithCallback(
          onAdCompleted: () async {
            _analyzeExam();
          },
          onAdFailed: () async {
            // Still allow fortune generation even if ad fails
            _analyzeExam();
          },
        );
      },
      isLoading: _isLoading,
      buttonIcon: const Icon(Icons.auto_awesome),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 카드
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.successGreen,
                        TossDesignSystem.successGreen.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: TossDesignSystem.white,
                    size: 40,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '시험 운세',
                  style: TossDesignSystem.heading2,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '시험 정보를 입력하고\n맞춤형 합격 운세를 확인하세요!',
                  style: TossDesignSystem.body2.copyWith(
                    color: TossDesignSystem.gray600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

          const SizedBox(height: 32),

          // 시험 정보 입력
          Text(
            '시험 정보를 입력해주세요',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시험 종류
                Text(
                  '시험 종류',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _examType = value,
                  decoration: InputDecoration(
                    hintText: '예: 수능, 토익, 자격증 시험',
                    hintStyle: TossDesignSystem.body2.copyWith(
                      color: TossDesignSystem.gray400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TossDesignSystem.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TossDesignSystem.tossBlue),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 시험 예정일
                Text(
                  '시험 예정일',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _examDate = value,
                  decoration: InputDecoration(
                    hintText: '예: 2024년 3월 15일',
                    hintStyle: TossDesignSystem.body2.copyWith(
                      color: TossDesignSystem.gray400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TossDesignSystem.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TossDesignSystem.tossBlue),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 24),

          // 준비 상황
          Text(
            '준비 상황',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 공부 기간
                Text(
                  '공부 기간',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _studyPeriods.map((period) => 
                    GestureDetector(
                      onTap: () => setState(() => _studyPeriod = period),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _studyPeriod == period 
                              ? TossDesignSystem.tossBlue
                              : TossDesignSystem.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          period,
                          style: TossDesignSystem.caption.copyWith(
                            color: _studyPeriod == period 
                                ? TossDesignSystem.white 
                                : TossDesignSystem.gray700,
                            fontWeight: _studyPeriod == period 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // 자신감
                Text(
                  '자신감',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _confidenceLevels.map((level) => 
                    GestureDetector(
                      onTap: () => setState(() => _confidence = level),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _confidence == level 
                              ? TossDesignSystem.successGreen
                              : TossDesignSystem.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level,
                          style: TossDesignSystem.caption.copyWith(
                            color: _confidence == level 
                                ? TossDesignSystem.white 
                                : TossDesignSystem.gray700,
                            fontWeight: _confidence == level 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // 난이도
                Text(
                  '예상 난이도',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _difficultyLevels.map((level) => 
                    GestureDetector(
                      onTap: () => setState(() => _difficulty = level),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _difficulty == level 
                              ? TossDesignSystem.warningOrange
                              : TossDesignSystem.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level,
                          style: TossDesignSystem.caption.copyWith(
                            color: _difficulty == level 
                                ? TossDesignSystem.white 
                                : TossDesignSystem.gray700,
                            fontWeight: _difficulty == level 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isDark) {
    if (_fortuneResult == null) return const SizedBox.shrink();

    final fortune = _fortuneResult!;
    final score = fortune.overallScore ?? 75;

    return StandardFortuneResultLayout(
      child: Column(
        children: [
          // 메인 결과 카드
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 점수 시각화
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: CircularScorePainter(
                          score: score,
                          gradientColors: [
                            TossDesignSystem.successGreen,
                            TossDesignSystem.tossBlue,
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score',
                            style: TossDesignSystem.heading1.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: TossDesignSystem.successGreen,
                            ),
                          ),
                          Text(
                            '합격 가능성',
                            style: TossDesignSystem.caption.copyWith(
                              color: TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  _examType,
                  style: TossDesignSystem.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fortune.content,
                    style: TossDesignSystem.body2.copyWith(
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 20),
          
          // 세부 점수
          if (fortune.scoreBreakdown != null) ...[
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, 
                        color: TossDesignSystem.tossBlue, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '세부 분석',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...fortune.scoreBreakdown!.entries.map((entry) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TossDesignSystem.body2.copyWith(
                                  color: TossDesignSystem.gray700,
                                ),
                              ),
                              Text(
                                '${entry.value}점',
                                style: TossDesignSystem.body2.copyWith(
                                  color: TossDesignSystem.tossBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: entry.value / 100,
                            backgroundColor: TossDesignSystem.gray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(entry.value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),
            
            const SizedBox(height: 20),
          ],
          
          // 추천 사항
          if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) ...[
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, 
                        color: TossDesignSystem.warningOrange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '합격 전략',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...fortune.recommendations!.map((rec) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.warningOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rec,
                              style: TossDesignSystem.body2.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
            
            const SizedBox(height: 20),
          ],
          
          // 행운 아이템
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) ...[
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, 
                        color: TossDesignSystem.warningOrange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '행운 아이템',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (fortune.luckyItems!['color'] != null)
                        ...fortune.luckyItems!['color']!.map((color) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: TossDesignSystem.warningOrange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.palette, size: 16, color: TossDesignSystem.warningOrange),
                                const SizedBox(width: 4),
                                Text(
                                  color,
                                  style: TossDesignSystem.caption.copyWith(
                                    color: TossDesignSystem.warningOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      if (fortune.luckyItems!['number'] != null)
                        ...fortune.luckyItems!['number']!.map((number) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: TossDesignSystem.tossBlue.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tag, size: 16, color: TossDesignSystem.tossBlue),
                                const SizedBox(width: 4),
                                Text(
                                  number,
                                  style: TossDesignSystem.caption.copyWith(
                                    color: TossDesignSystem.tossBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
          ],


          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}

// Custom Painter for Circular Score
class CircularScorePainter extends CustomPainter {
  final int score;
  final List<Color> gradientColors;

  CircularScorePainter({
    required this.score,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = TossDesignSystem.gray200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * score / 100),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * score / 100,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on _LuckyExamFortunePageState {
  /// FortuneResult를 Fortune 엔티티로 변환
  Fortune _convertToFortune(FortuneResult fortuneResult) {
    return Fortune(
      id: fortuneResult.id ?? '',
      userId: Supabase.instance.client.auth.currentUser?.id ?? '',
      fortuneType: 'exam',
      title: fortuneResult.title,
      content: fortuneResult.data['content'] as String? ?? '',
      summary: fortuneResult.summary['message'] as String? ?? '',
      score: fortuneResult.score,
      fortuneData: fortuneResult.data,
      createdAt: fortuneResult.createdAt ?? DateTime.now(),
      lastViewedAt: fortuneResult.lastViewedAt,
      viewCount: fortuneResult.viewCount ?? 0,
    );
  }
}