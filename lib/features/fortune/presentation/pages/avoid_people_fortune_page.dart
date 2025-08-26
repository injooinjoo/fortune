import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/fortune_result.dart';

class AvoidPeopleFortunePage extends ConsumerWidget {
  const AvoidPeopleFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          '피해야 할 사람',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: _AvoidPeopleInputForm(),
    );
  }
}

class _AvoidPeopleInputForm extends StatefulWidget {
  const _AvoidPeopleInputForm({super.key});

  @override
  State<_AvoidPeopleInputForm> createState() => _AvoidPeopleInputFormState();
}

class _AvoidPeopleInputFormState extends State<_AvoidPeopleInputForm> {
  String _situation = 'work';
  String _currentMood = 'normal';
  String _socialPreference = 'moderate';
  String _relationshipStatus = 'single';

  @override
  Widget build(BuildContext context) {
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  '피해야 할 사람',
                  style: TossTheme.heading2.copyWith(
                    color: TossTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '오늘 피해야 할 사람의 특징을 알아보고\n불필요한 스트레스를 예방하세요!',
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

          Text(
            '현재 상황을 선택해주세요',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 상황 선택 카드들
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '어떤 환경에 계신가요?',
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '직장', '학교', '모임', '가족', '연인'
                  ].map((situation) => 
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _situation = situation;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _situation == situation 
                              ? TossTheme.primaryBlue.withOpacity(0.1)
                              : TossTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(20),
                          border: _situation == situation
                              ? Border.all(color: TossTheme.primaryBlue)
                              : null,
                        ),
                        child: Text(
                          situation,
                          style: TossTheme.body2.copyWith(
                            color: _situation == situation 
                                ? TossTheme.primaryBlue 
                                : TossTheme.textBlack,
                            fontWeight: _situation == situation 
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
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 40),

          // 분석 버튼
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '피해야 할 사람 알아보기',
              onPressed: () {
                // 간단한 결과 표시
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('분석 결과', style: TossTheme.heading4),
                    content: Text('오늘은 부정적인 에너지를 가진 사람들과의 접촉을 피하는 것이 좋겠어요. 특히 $_situation 환경에서 주의하세요!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('확인', style: TextStyle(color: TossTheme.primaryBlue)),
                      ),
                    ],
                  ),
                );
              },
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
}