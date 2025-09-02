import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../constants/fortune_button_spacing.dart';

class CompatibilityPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;
  
  const CompatibilityPage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends ConsumerState<CompatibilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _person1NameController = TextEditingController();
  final _person2NameController = TextEditingController();
  DateTime? _person1BirthDate;
  DateTime? _person2BirthDate;
  
  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // 사용자 프로필 정보로 미리 채우기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProfileAsync = ref.read(userProfileProvider);
      userProfileAsync.when(
        data: (userProfile) {
          if (userProfile != null) {
            setState(() {
              _person1NameController.text = userProfile.name ?? '';
              _person1BirthDate = userProfile.birthDate;
            });
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  @override
  void dispose() {
    _person1NameController.dispose();
    _person2NameController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker({required bool isPerson1}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isPerson1 
          ? _person1BirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25))
          : _person2BirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: TossTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (isPerson1) {
          _person1BirthDate = selectedDate;
        } else {
          _person2BirthDate = selectedDate;
        }
      });
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _analyzeCompatibility() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이름을 입력해주세요'),
          backgroundColor: TossTheme.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    
    if (_person1BirthDate == null || _person2BirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('생년월일을 선택해주세요'),
          backgroundColor: TossTheme.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        'person1': {
          'name': _person1NameController.text,
          'birthDate': _person1BirthDate!.toIso8601String(),
        },
        'person2': {
          'name': _person2NameController.text,
          'birthDate': _person2BirthDate!.toIso8601String(),
        },
      };
      
      final fortune = await fortuneService.getCompatibilityFortune(
        person1: params['person1'] as Map<String, dynamic>,
        person2: params['person2'] as Map<String, dynamic>,
      );
      
      // Parse scores from fortune response
      Map<String, double> scores = {};
      
      // Extract overall score
      double overallScore = (fortune.overallScore ?? 75) / 100.0;
      scores['전체 궁합'] = overallScore;
      
      // Parse detailed scores from fortune content or metadata
      if (fortune.metadata != null && fortune.metadata!['scores'] != null) {
        final detailedScores = fortune.metadata!['scores'] as Map<String, dynamic>;
        scores['사랑 궁합'] = (detailedScores['love'] ?? 80) / 100.0;
        scores['결혼 궁합'] = (detailedScores['marriage'] ?? 75) / 100.0;
        scores['일상 궁합'] = (detailedScores['daily'] ?? 70) / 100.0;
        scores['소통 궁합'] = (detailedScores['communication'] ?? 78) / 100.0;
      } else {
        // Calculate based on overall score with slight variations
        scores['사랑 궁합'] = (overallScore + 0.05).clamp(0.0, 1.0);
        scores['결혼 궁합'] = (overallScore - 0.03).clamp(0.0, 1.0);
        scores['일상 궁합'] = (overallScore - 0.07).clamp(0.0, 1.0);
        scores['소통 궁합'] = overallScore;
      }
      
      setState(() {
        _compatibilityData = {
          'fortune': fortune,
          'scores': scores,
        };
        _isLoading = false;
      });
      
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        String errorMessage = '궁합 분석 중 오류가 발생했습니다';
        if (e.toString().contains('404')) {
          errorMessage = '궁합 분석 서비스를 사용할 수 없습니다';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: TossTheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

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
          '궁합 분석',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: _compatibilityData != null 
          ? _buildResultView()
          : _buildInputView(),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
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
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEC4899),
                          Color(0xFF8B5CF6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 36,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    '두 사람의 궁합',
                    style: TossTheme.heading2.copyWith(
                      color: TossTheme.textBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    '이름과 생년월일을 입력하면\n두 사람의 궁합을 자세히 분석해드릴게요',
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

            // 첫 번째 사람 정보
            Text(
              '첫 번째 사람 (나)',
              style: TossTheme.heading4.copyWith(
                color: TossTheme.textBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _person1NameController,
                    decoration: InputDecoration(
                      labelText: '이름',
                      hintText: '이름을 입력해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TossTheme.borderGray300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TossTheme.primaryBlue,
                        ),
                      ),
                    ),
                    style: TossTheme.body1.copyWith(
                      color: TossTheme.textBlack,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: () => _showDatePicker(isPerson1: true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TossTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _person1BirthDate != null 
                              ? TossTheme.primaryBlue 
                              : TossTheme.borderGray300,
                          width: _person1BirthDate != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '생년월일',
                                style: TossTheme.caption.copyWith(
                                  color: TossTheme.textGray600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _person1BirthDate != null
                                    ? '${_person1BirthDate!.year}년 ${_person1BirthDate!.month}월 ${_person1BirthDate!.day}일'
                                    : '생년월일을 선택해주세요',
                                style: TossTheme.body2.copyWith(
                                  color: _person1BirthDate != null 
                                      ? TossTheme.textBlack 
                                      : TossTheme.textGray600,
                                  fontWeight: _person1BirthDate != null 
                                      ? FontWeight.w500 
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            color: _person1BirthDate != null 
                                ? TossTheme.primaryBlue 
                                : TossTheme.textGray600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

            const SizedBox(height: 24),

            // 두 번째 사람 정보
            Text(
              '두 번째 사람 (상대방)',
              style: TossTheme.heading4.copyWith(
                color: TossTheme.textBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _person2NameController,
                    decoration: InputDecoration(
                      labelText: '이름',
                      hintText: '상대방 이름을 입력해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TossTheme.borderGray300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TossTheme.primaryBlue,
                        ),
                      ),
                    ),
                    style: TossTheme.body1.copyWith(
                      color: TossTheme.textBlack,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: () => _showDatePicker(isPerson1: false),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TossTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _person2BirthDate != null 
                              ? TossTheme.primaryBlue 
                              : TossTheme.borderGray300,
                          width: _person2BirthDate != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '생년월일',
                                style: TossTheme.caption.copyWith(
                                  color: TossTheme.textGray600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _person2BirthDate != null
                                    ? '${_person2BirthDate!.year}년 ${_person2BirthDate!.month}월 ${_person2BirthDate!.day}일'
                                    : '생년월일을 선택해주세요',
                                style: TossTheme.body2.copyWith(
                                  color: _person2BirthDate != null 
                                      ? TossTheme.textBlack 
                                      : TossTheme.textGray600,
                                  fontWeight: _person2BirthDate != null 
                                      ? FontWeight.w500 
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            color: _person2BirthDate != null 
                                ? TossTheme.primaryBlue 
                                : TossTheme.textGray600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

            const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),

            // 분석 버튼
            FortuneButtonPositionHelper.inline(
              child: TossButton(
                text: '궁합 분석하기',
                isLoading: _isLoading,
                onPressed: _analyzeCompatibility,
                size: TossButtonSize.large,
                width: double.infinity,
              ),
              topSpacing: 0,
              bottomSpacing: 16,
            ),

            Text(
              '분석 결과는 참고용으로만 활용해 주세요',
              style: TossTheme.caption.copyWith(
                color: TossTheme.textGray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final fortune = _compatibilityData!['fortune'] as Fortune;
    final scores = _compatibilityData!['scores'] as Map<String, double>;
    final overallScore = scores['전체 궁합'] ?? 0.85;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 전체 궁합 점수
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '${_person1NameController.text} ❤️ ${_person2NameController.text}',
                  style: TossTheme.heading3.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: overallScore,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(overallScore * 100).round()}점',
                        style: TossTheme.heading1.copyWith(
                          color: _getScoreColor(overallScore),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _getScoreText(overallScore),
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                  progressColor: _getScoreColor(overallScore),
                  backgroundColor: TossTheme.borderGray200,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1200,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  fortune.summary ?? '궁합 분석 결과',
                  style: TossTheme.body1.copyWith(
                    color: _getScoreColor(overallScore),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          // 세부 궁합 점수
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TossTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: TossTheme.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '세부 궁합 분석',
                      style: TossTheme.heading4.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                ...scores.entries.where((e) => e.key != '전체 궁합').map((entry) {
                  final index = scores.keys.toList().indexOf(entry.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TossTheme.body2.copyWith(
                                color: TossTheme.textBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(entry.value * 100).round()}점',
                              style: TossTheme.body2.copyWith(
                                color: _getScoreColor(entry.value),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: TossTheme.borderGray200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(entry.value),
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ).animate(delay: (index * 100).ms)
                     .fadeIn(duration: 600.ms)
                     .slideX(begin: 0.3),
                  );
                }).toList(),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 궁합 설명
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Color(0xFFEC4899),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '궁합 분석 결과',
                      style: TossTheme.heading4.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  fortune.content,
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textBlack,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),

          if (fortune.advice?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            
            TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TossTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          color: TossTheme.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '관계 개선 조언',
                        style: TossTheme.heading4.copyWith(
                          color: TossTheme.textBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    fortune.advice!,
                    style: TossTheme.body2.copyWith(
                      color: TossTheme.textBlack,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
          ],

          const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),

          // 다시 분석하기 버튼
          FortuneButtonPositionHelper.inline(
            child: TossButton(
              text: '다른 사람과 궁합 보기',
              onPressed: () {
                setState(() {
                  _compatibilityData = null;
                  _person2NameController.clear();
                  _person2BirthDate = null;
                });
              },
              style: TossButtonStyle.secondary,
              size: TossButtonSize.large,
              width: double.infinity,
            ),
            topSpacing: 0,
            bottomSpacing: FortuneButtonSpacing.buttonBottomSpacing,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return const Color(0xFF10B981); // 매우 좋음 - 초록
    if (score >= 0.8) return const Color(0xFF3B82F6); // 좋음 - 파랑
    if (score >= 0.7) return const Color(0xFFF59E0B); // 보통 - 노랑
    if (score >= 0.6) return const Color(0xFFEF4444); // 나쁨 - 빨강
    return TossTheme.textGray600; // 매우 나쁨 - 회색
  }

  String _getScoreText(double score) {
    if (score >= 0.9) return '매우 좋음';
    if (score >= 0.8) return '좋음';
    if (score >= 0.7) return '보통';
    if (score >= 0.6) return '나쁨';
    return '매우 나쁨';
  }
}