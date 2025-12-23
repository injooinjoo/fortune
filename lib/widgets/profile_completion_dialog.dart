import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/fortune_design_system.dart';
import '../core/theme/typography_unified.dart';

class ProfileCompletionDialog extends StatelessWidget {
  final List<String> missingFields;
  
  const ProfileCompletionDialog({
    super.key,
    required this.missingFields,
  });

  static Future<void> show(BuildContext context, List<String> missingFields) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfileCompletionDialog(missingFields: missingFields),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 32,
                color: TossDesignSystem.tossBlue,
              ),
            ).animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              '운세가 정확하려면\n정보가 더 필요합니다',
              style: TossDesignSystem.heading3.copyWith(
                color: TossDesignSystem.gray900,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms),
            
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              _buildSubtitleText(),
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.gray600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Missing fields chip list
            if (missingFields.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: missingFields.map((field) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      field,
                      style: TossDesignSystem.caption1.copyWith(
                        color: TossDesignSystem.gray700,
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: (400 + missingFields.indexOf(field) * 50).ms, duration: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      delay: (400 + missingFields.indexOf(field) * 50).ms,
                      duration: 300.ms,
                    )
                ).toList(),
              ),
            
            const SizedBox(height: 24),
            
            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to onboarding with partial completion mode
                  context.go('/onboarding/toss-style?partial=true');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TossDesignSystem.tossBlue,
                  foregroundColor: TossDesignSystem.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '정보 입력하기',
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TossDesignSystem.white,
                  ),
                ),
              ),
            ).animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 400.ms),
            
            const SizedBox(height: 12),
            
            // Skip button (optional)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '나중에 하기',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.gray500,
                ),
              ),
            ).animate()
              .fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 300.ms,
        curve: Curves.easeOut,
      );
  }
  
  String _buildSubtitleText() {
    if (missingFields.length == 1) {
      return '${missingFields.first}을(를) 입력하면\n더 정확한 운세를 볼 수 있어요';
    } else if (missingFields.length == 2) {
      return '${missingFields.join('과 ')}을(를) 입력하면\n더 정확한 운세를 볼 수 있어요';
    } else {
      return '필요한 정보를 입력하면\n더 정확한 운세를 볼 수 있어요';
    }
  }
}