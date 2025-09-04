import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';

class CareerFortuneInput {
  final String jobStatus;
  final String experience;
  final String industry;
  final double satisfaction;
  final String sixMonthGoal;
  final String importantValue;
  final List<String> specificConcerns;
  final String customConcern;

  CareerFortuneInput({
    required this.jobStatus,
    required this.experience,
    required this.industry,
    required this.satisfaction,
    required this.sixMonthGoal,
    required this.importantValue,
    required this.specificConcerns,
    required this.customConcern,
  });
}

class CareerFortunePage extends ConsumerStatefulWidget {
  const CareerFortunePage({super.key});

  @override
  ConsumerState<CareerFortunePage> createState() => _CareerFortunePageState();
}

class _CareerFortunePageState extends ConsumerState<CareerFortunePage> {
  int _currentStep = 0;
  bool _isLoading = false;
  Fortune? _fortune;

  // Step 1 data
  String _jobStatus = '';
  String _experience = '';
  String _industry = '';

  // Step 2 data
  double _satisfaction = 3.0;
  String _sixMonthGoal = '';
  String _importantValue = '';

  // Step 3 data
  List<String> _specificConcerns = [];
  final TextEditingController _customConcernController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_fortune != null) {
      return _buildResultView();
    }

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
          '커리어 운세',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index <= _currentStep;
                final isCompleted = index < _currentStep;
                
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? TossTheme.primaryBlue 
                          : TossTheme.backgroundSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).animate()
                   .scaleX(
                     duration: 300.ms,
                     begin: isCompleted ? 1.0 : 0.0,
                     end: 1.0,
                   ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: _buildCurrentStep(),
          ),
          
          // Bottom navigation
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: TossButton(
                      text: '이전',
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: TossButtonStyle.secondary,
                    ),
                  ),
                
                if (_currentStep > 0) const SizedBox(width: 12),
                
                Expanded(
                  child: TossButton(
                    text: _currentStep == 2 ? '운세 분석하기' : '다음',
                    onPressed: _canProceed() ? _proceedToNext : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                        TossTheme.primaryBlue,
                        TossTheme.primaryBlue.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: TossTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.work_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '현재 상황을 알려주세요',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '당신의 현재 직업 상황을 바탕으로\n더 정확한 커리어 운세를 제공해드려요',
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

          // Job Status
          Text(
            '현재 직업 상태',
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
                ...['재직중', '구직중', '학생', '프리랜서', '창업준비', '기타'].map((status) => 
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<String>(
                        value: status,
                        groupValue: _jobStatus,
                        onChanged: (value) => setState(() => _jobStatus = value!),
                        activeColor: TossTheme.primaryBlue,
                      ),
                      title: Text(
                        status,
                        style: TossTheme.body1.copyWith(
                          color: TossTheme.textBlack,
                        ),
                      ),
                      onTap: () => setState(() => _jobStatus = status),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 24),

          // Experience
          Text(
            '경력 수준',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['신입 (0-2년)', '주니어 (2-5년)', '시니어 (5-10년)', '리드 (10년+)', '임원급'].map((exp) => 
              GestureDetector(
                onTap: () => setState(() => _experience = exp),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _experience == exp 
                        ? TossTheme.primaryBlue.withOpacity(0.1)
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(24),
                    border: _experience == exp
                        ? Border.all(color: TossTheme.primaryBlue)
                        : null,
                  ),
                  child: Text(
                    exp,
                    style: TossTheme.body2.copyWith(
                      color: _experience == exp 
                          ? TossTheme.primaryBlue
                          : TossTheme.textBlack,
                      fontWeight: _experience == exp 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ).toList(),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 24),

          // Industry
          Text(
            '업계/분야',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['IT/개발', '마케팅', '디자인', '영업', '금융', '컨설팅', '의료', '교육', '제조', '서비스', '공공기관', '기타'].map((industry) => 
              GestureDetector(
                onTap: () => setState(() => _industry = industry),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _industry == industry 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: _industry == industry
                        ? Border.all(color: const Color(0xFF10B981))
                        : null,
                  ),
                  child: Text(
                    industry,
                    style: TossTheme.caption.copyWith(
                      color: _industry == industry 
                          ? const Color(0xFF10B981)
                          : TossTheme.textBlack,
                      fontWeight: _industry == industry 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ).toList(),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                        const Color(0xFFEC4899),
                        const Color(0xFFBE185D),
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
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '마음과 목표를 들려주세요',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '현재의 감정과 앞으로의 목표를 통해\n더 개인화된 조언을 드릴게요',
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

          // Satisfaction
          Text(
            '현재 만족도',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['😭', '😟', '😐', '😊', '🤩'].asMap().entries.map((entry) {
                    int index = entry.key;
                    String emoji = entry.value;
                    bool isSelected = _satisfaction.round() - 1 == index;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _satisfaction = index + 1.0),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFFEC4899).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: isSelected
                              ? Border.all(color: const Color(0xFFEC4899), width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFEC4899),
                    inactiveTrackColor: TossTheme.backgroundSecondary,
                    thumbColor: const Color(0xFFEC4899),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _satisfaction,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) => setState(() => _satisfaction = value),
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('매우 불만', style: TossTheme.caption.copyWith(color: TossTheme.textGray600)),
                    Text('매우 만족', style: TossTheme.caption.copyWith(color: TossTheme.textGray600)),
                  ],
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 24),

          // 6 Month Goal
          Text(
            '6개월 후 목표',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['승진/성과', '이직/전직', '스킬업', '워라벨', '연봉상승', '창업/독립', '안정성', '새로운 도전'].map((goal) => 
              GestureDetector(
                onTap: () => setState(() => _sixMonthGoal = goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _sixMonthGoal == goal 
                        ? const Color(0xFFEC4899).withOpacity(0.1)
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(24),
                    border: _sixMonthGoal == goal
                        ? Border.all(color: const Color(0xFFEC4899))
                        : null,
                  ),
                  child: Text(
                    goal,
                    style: TossTheme.body2.copyWith(
                      color: _sixMonthGoal == goal 
                          ? const Color(0xFFEC4899)
                          : TossTheme.textBlack,
                      fontWeight: _sixMonthGoal == goal 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ).toList(),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 24),

          // Important Value
          Text(
            '가장 중요하게 생각하는 가치',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['성장', '안정', '자유', '인정', '돈', '관계', '의미', '도전'].map((value) => 
              GestureDetector(
                onTap: () => setState(() => _importantValue = value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _importantValue == value 
                        ? const Color(0xFF8B5CF6).withOpacity(0.1)
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: _importantValue == value
                        ? Border.all(color: const Color(0xFF8B5CF6))
                        : null,
                  ),
                  child: Text(
                    value,
                    style: TossTheme.caption.copyWith(
                      color: _importantValue == value 
                          ? const Color(0xFF8B5CF6)
                          : TossTheme.textBlack,
                      fontWeight: _importantValue == value 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ).toList(),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                        const Color(0xFF8B5CF6),
                        const Color(0xFF7C3AED),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '구체적인 고민을 나눠주세요',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '현재 가장 큰 고민이나 궁금한 점을\n선택하거나 직접 작성해주세요',
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

          // Preset concerns
          Text(
            '주요 관심사 (복수 선택 가능)',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '상사/동료 관계',
              '업무 스트레스',
              '커리어 방향성',
              '연봉 협상',
              '이직 타이밍',
              '스킬 개발',
              '워라벨',
              '승진 전략',
              '부서 이동',
              '창업/독립',
              '새로운 분야 도전',
              '나이/경력 고민'
            ].map((concern) => 
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_specificConcerns.contains(concern)) {
                      _specificConcerns.remove(concern);
                    } else {
                      _specificConcerns.add(concern);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _specificConcerns.contains(concern) 
                        ? const Color(0xFF8B5CF6).withOpacity(0.1)
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: _specificConcerns.contains(concern)
                        ? Border.all(color: const Color(0xFF8B5CF6))
                        : null,
                  ),
                  child: Text(
                    concern,
                    style: TossTheme.caption.copyWith(
                      color: _specificConcerns.contains(concern) 
                          ? const Color(0xFF8B5CF6)
                          : TossTheme.textBlack,
                      fontWeight: _specificConcerns.contains(concern) 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ).toList(),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 24),

          // Custom concern
          Text(
            '추가 질문이나 구체적인 고민',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          TossCard(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _customConcernController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '예: 현재 회사에서 3년째 근무 중인데, 언제 이직하는 게 좋을까요?',
                hintStyle: TossTheme.body2.copyWith(
                  color: TossTheme.textGray600.withOpacity(0.7),
                ),
                border: InputBorder.none,
              ),
              style: TossTheme.body2.copyWith(
                color: TossTheme.textBlack,
              ),
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TossTheme.primaryBlue,
                    const Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TossTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 60,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .rotate(duration: 2000.ms),
            
            const SizedBox(height: 32),
            
            Text(
              '커리어 운세 분석 중...',
              style: TossTheme.heading3.copyWith(
                color: TossTheme.textBlack,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '당신만의 맞춤형 커리어 조언을 준비하고 있어요',
              style: TossTheme.body2.copyWith(
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
    if (_fortune == null) return const SizedBox.shrink();
    
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
          '커리어 운세 결과',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                // Share functionality
              },
              style: IconButton.styleFrom(
                backgroundColor: TossTheme.backgroundSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.share,
                color: TossTheme.textBlack,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main result card
            TossCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TossTheme.primaryBlue,
                          const Color(0xFF8B5CF6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    '커리어 운세 분석 완료!',
                    style: TossTheme.heading2.copyWith(
                      color: TossTheme.textBlack,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _fortune!.content,
                    style: TossTheme.body1.copyWith(
                      color: TossTheme.textGray600,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
            
            const SizedBox(height: 20),
            
            // Score breakdown if available
            if (_fortune!.scoreBreakdown != null) ...[
              TossCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '세부 분석',
                      style: TossTheme.heading4.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ..._fortune!.scoreBreakdown!.entries.map((entry) => 
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TossTheme.body2.copyWith(
                                color: TossTheme.textBlack,
                              ),
                            ),
                            Text(
                              '${entry.value}%',
                              style: TossTheme.body2.copyWith(
                                color: TossTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
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
            
            // Recommendations
            if (_fortune!.recommendations != null && _fortune!.recommendations!.isNotEmpty) ...[
              TossCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추천 행동',
                      style: TossTheme.heading4.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ..._fortune!.recommendations!.map((rec) => 
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
                                color: TossTheme.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                rec,
                                style: TossTheme.body2.copyWith(
                                  color: TossTheme.textBlack,
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
              
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _jobStatus.isNotEmpty && _experience.isNotEmpty && _industry.isNotEmpty;
      case 1:
        return _sixMonthGoal.isNotEmpty && _importantValue.isNotEmpty;
      case 2:
        return _specificConcerns.isNotEmpty || _customConcernController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _proceedToNext() async {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      await _generateFortune();
    }
  }

  Future<void> _generateFortune() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fortuneService = ref.read(fortuneServiceProvider);
      final params = {
        'jobStatus': _jobStatus,
        'experience': _experience,
        'industry': _industry,
        'satisfaction': _satisfaction,
        'sixMonthGoal': _sixMonthGoal,
        'importantValue': _importantValue,
        'specificConcerns': _specificConcerns,
        'customConcern': _customConcernController.text,
      };

      final fortune = await fortuneService.getFortune(
        userId: 'user123',
        fortuneType: 'career',
        params: params,
      );

      setState(() {
        _fortune = fortune;
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

  @override
  void dispose() {
    _customConcernController.dispose();
    super.dispose();
  }
}