import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';

class LuckyExamFortunePage extends ConsumerStatefulWidget {
  const LuckyExamFortunePage({super.key});

  @override
  ConsumerState<LuckyExamFortunePage> createState() => _LuckyExamFortunePageState();
}

class _LuckyExamFortunePageState extends ConsumerState<LuckyExamFortunePage> {
  Map<String, dynamic>? _examData;
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
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
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
          '시험 운세',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: _examData != null 
          ? _buildResultView()
          : _buildInputView(),
    );
  }

  Future<void> _analyzeExam() async {
    if (_examType.isEmpty || _examDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('시험 종류와 예정일을 입력해주세요'),
          backgroundColor: TossTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fortuneService = ref.read(fortuneServiceProvider);
      final params = {
        'examType': _examType,
        'examDate': _examDate,
        'studyPeriod': _studyPeriod,
        'confidence': _confidence,
        'difficulty': _difficulty,
      };
      
      final fortune = await fortuneService.getFortune(
        userId: 'user123', // 임시 사용자 ID
        fortuneType: 'lucky-exam',
        params: params,
      );
      
      setState(() {
        _examData = {
          'fortune': fortune,
          'examInfo': params,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
                        const Color(0xFF10B981),
                        const Color(0xFF34D399),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '시험 운세',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '시험 정보를 입력하고\\n맞춤형 합격 운세를 확인하세요!',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
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
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 16),
          
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시험 종류',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => setState(() => _examType = value),
                  decoration: InputDecoration(
                    hintText: '예: 수능, 공무원, 토익, 자격증',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TossTheme.borderGray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TossTheme.primaryBlue),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  '시험 예정일',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => setState(() => _examDate = value),
                  decoration: InputDecoration(
                    hintText: '예: 다음주, 1개월 후, 2024년 11월',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TossTheme.borderGray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TossTheme.primaryBlue),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 준비 상황
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공부 기간',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 8),
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
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : TossTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(20),
                          border: _studyPeriod == period
                              ? Border.all(color: const Color(0xFF10B981))
                              : null,
                        ),
                        child: Text(
                          period,
                          style: TossTheme.body2.copyWith(
                            color: _studyPeriod == period 
                                ? const Color(0xFF10B981)
                                : TossTheme.textBlack,
                            fontWeight: _studyPeriod == period 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  '현재 자신감',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _confidenceLevels.map((level) => 
                    GestureDetector(
                      onTap: () => setState(() => _confidence = level),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _confidence == level 
                              ? TossTheme.primaryBlue.withOpacity(0.1)
                              : TossTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: _confidence == level
                              ? Border.all(color: TossTheme.primaryBlue)
                              : null,
                        ),
                        child: Text(
                          level,
                          style: TossTheme.caption.copyWith(
                            color: _confidence == level 
                                ? TossTheme.primaryBlue
                                : TossTheme.textBlack,
                            fontWeight: _confidence == level 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 40),

          // 분석 버튼
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '시험 합격 운세 보기',
              isLoading: _isLoading,
              onPressed: _analyzeExam,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '분석 결과는 참고용으로만 활용해 주세요',
            style: TossTheme.caption.copyWith(
              color: TossTheme.textGray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final fortune = _examData?['fortune'] as Fortune?;
    if (fortune == null) return const SizedBox.shrink();
    
    return _buildResultViewWithData(context, fortune, () {
      // Share functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('공유 기능은 곧 추가될 예정입니다'),
          backgroundColor: TossTheme.primaryBlue,
        ),
      );
    });
  }

  Widget _buildResultViewWithData(BuildContext context, Fortune result, VoidCallback onShare) {
    final sections = result.categories ?? {};
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildResultSummaryCard(result.summary ?? '시험 합격을 위한 운세입니다.'),
            const SizedBox(height: 20),
            _buildResultCard(
              title: '합격 가능성',
              content: sections['pass_probability'] ?? '합격 가능성을 분석 중입니다.',
              icon: Icons.emoji_events,
              color: TossTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              title: '공부 전략',
              content: sections['study_strategy'] ?? '효과적인 공부 전략을 준비 중입니다.',
              icon: Icons.menu_book,
              color: TossTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              title: '시험 당일 팁',
              content: sections['exam_day_tips'] ?? '시험 당일 주의사항을 확인 중입니다.',
              icon: Icons.lightbulb,
              color: TossTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              title: '집중력 향상법',
              content: sections['concentration'] ?? '집중력 향상 방법을 제공 중입니다.',
              icon: Icons.psychology,
              color: TossTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            if (sections['lucky_study_time'] != null)
              _buildResultCard(
                title: '최적의 공부 시간',
                content: sections['lucky_study_time']!,
                icon: Icons.access_time,
                color: TossTheme.primaryBlue,
              ),
            if (sections['lucky_study_time'] != null) const SizedBox(height: 16),
            if (sections['weekly_plan'] != null)
              _buildResultCard(
                title: '주간 학습 계획',
                content: sections['weekly_plan']!,
                icon: Icons.calendar_view_week,
                color: TossTheme.primaryBlue,
              ),
            if (sections['weekly_plan'] != null) const SizedBox(height: 24),
            TossButton(
              text: '운세 공유하기',
              onPressed: onShare,
              width: double.infinity,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummaryCard(String summary) {
    return TossCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.school,
              size: 40,
              color: TossTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '시험 운세 결과',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: TossTheme.textGray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color}) {
    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TossTheme.textBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: TossTheme.textGray600,
            ),
          ),
        ],
      ),
    );
  }


}