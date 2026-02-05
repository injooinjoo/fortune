import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';

class ExerciseFortunePage extends StatelessWidget {
  const ExerciseFortunePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: context.colors.textPrimary,
              size: 20,
            ),
          ),
        ),
        title: Text(
          '운동운세',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이모지 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colors.accent.withValues(alpha: 0.1),
                      DSColors.success.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 60,
                  color: context.colors.accent,
                ),
              ),

              const SizedBox(height: 32),

              // 제목
              Text(
                '운동운세',
                style: context.heading1.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 설명
              Text(
                '곧 새로운 운동운세가 출시될 예정입니다!\n피트니스, 요가, 런닝 등 다양한 운동 운세를\n확인할 수 있게 됩니다.',
                style: context.heading2.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 기능 미리보기
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.colors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '🏃‍♂️ 런닝 컨디션 예측',
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💪 피트니스 최적 시간',
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🧘‍♀️ 요가 & 명상 가이드',
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 돌아가기 버튼
              SizedBox(
                width: double.infinity,
                child: UnifiedButton(
                  text: '돌아가기',
                  onPressed: () => Navigator.pop(context),
                  style: UnifiedButtonStyle.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
