import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';

enum SportType {
  golf('골프', 'golf', Icons.golf_course, Color(0xFF10B981)),
  tennis('테니스', 'tennis', Icons.sports_tennis, Color(0xFFEF4444)),
  baseball('야구', 'baseball', Icons.sports_baseball, Color(0xFF3B82F6)),
  swimming('수영', 'swimming', Icons.pool, Color(0xFF06B6D4)),
  yoga('요가', 'yoga', Icons.self_improvement, Color(0xFF8B5CF6)),
  hiking('등산', 'hiking', Icons.terrain, Color(0xFF059669)),
  cycling('자전거', 'cycling', Icons.directions_bike, Color(0xFFF59E0B)),
  running('러닝', 'running', Icons.directions_run, Color(0xFFDC2626)),
  fitness('피트니스', 'fitness', Icons.fitness_center, Color(0xFF7C3AED)),
  fishing('낚시', 'fishing', Icons.phishing, Color(0xFF0891B2));
  
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const SportType(this.label, this.value, this.icon, this.color);
}

class SportsFortunePage extends ConsumerStatefulWidget {
  final SportType initialType;
  
  const SportsFortunePage({
    super.key,
    this.initialType = SportType.fitness,
  });

  @override
  ConsumerState<SportsFortunePage> createState() => _SportsFortunePageState();
}

class _SportsFortunePageState extends ConsumerState<SportsFortunePage> {
  late SportType _selectedType;
  Map<String, dynamic>? _sportsData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  Future<void> _analyzeSports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fortuneService = ref.read(fortuneServiceProvider);
      final params = {
        'sport_type': _selectedType.value,
        'sport_name': _selectedType.label,
      };
      
      final fortune = await fortuneService.getSportsFortune(
        userId: 'user123', // 임시 사용자 ID
        params: params,
      );
      
      setState(() {
        _sportsData = {
          'fortune': fortune,
          'sport_type': _selectedType,
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
          '스포츠/운동 운세',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: _sportsData != null 
          ? _buildResultView()
          : _buildInputView(),
    );
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
                        TossTheme.primaryBlue,
                        const Color(0xFF00C896),
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
                    Icons.sports_tennis,
                    color: Colors.white,
                    size: 36,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '오늘의 운동 운세',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '어떤 운동을 하실 예정인가요?\n맞춤형 운세를 알려드릴게요!',
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

          // 운동 선택 섹션
          Text(
            '운동 종목을 선택해주세요',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: SportType.values.length,
            itemBuilder: (context, index) {
              final sport = SportType.values[index];
              final isSelected = sport == _selectedType;
              
              return TossCard(
                onTap: () {
                  setState(() {
                    _selectedType = sport;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? sport.color.withOpacity(0.1) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: sport.color, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sport.icon,
                        size: 32,
                        color: isSelected ? sport.color : TossTheme.textGray600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sport.label,
                        style: TossTheme.body2.copyWith(
                          color: isSelected ? sport.color : TossTheme.textBlack,
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 50).ms)
               .fadeIn(duration: 400.ms)
               .slideY(begin: 0.3);
            },
          ),

          const SizedBox(height: 40),

          // 분석 버튼
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '운동 운세 분석하기',
              isLoading: _isLoading,
              onPressed: _analyzeSports,
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
    final fortune = _sportsData!['fortune'] as Fortune;
    final sportType = _sportsData!['sport_type'] as SportType;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                    color: sportType.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: sportType.color, width: 2),
                  ),
                  child: Icon(
                    sportType.icon,
                    color: sportType.color,
                    size: 36,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  '${sportType.label} 운세',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  fortune.summary ?? '오늘의 ${sportType.label} 운세',
                  style: TossTheme.body1.copyWith(
                    color: sportType.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          // 운세 내용
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
                        color: sportType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: sportType.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '오늘의 운세',
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
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 16),

          // 추천 사항
          if (fortune.advice?.isNotEmpty == true)
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
                        '오늘의 추천',
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
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 32),

          // 다시 분석하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _sportsData = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: TossTheme.primaryBlue,
                side: BorderSide(color: TossTheme.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                '다른 운동으로 분석하기',
                style: TossTheme.body1.copyWith(
                  color: TossTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}