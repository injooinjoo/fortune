import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/theme/toss_design_system.dart';

class MbtiEnergyGauge extends StatelessWidget {
  final Map<String, dynamic> energyLevels;
  final bool isDark;

  const MbtiEnergyGauge({
    super.key,
    required this.energyLevels,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? TossDesignSystem.black.withValues(alpha: 0.2)
              : TossDesignSystem.gray400.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: TossDesignSystem.tossBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 에너지 레벨',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEnergyBar(
            '소셜 배터리',
            energyLevels['socialBattery'] ?? 0,
            TossDesignSystem.tossBlue,
            Icons.people_outline,
            _getSocialDescription(energyLevels['socialBattery'] ?? 0),
          ),
          const SizedBox(height: 20),
          _buildEnergyBar(
            '혼자 배터리',
            energyLevels['aloneBattery'] ?? 0,
            TossDesignSystem.purple,
            Icons.person_outline,
            _getAloneDescription(energyLevels['aloneBattery'] ?? 0),
          ),
          const SizedBox(height: 20),
          _buildEnergyBar(
            '집중력',
            energyLevels['focus'] ?? 0,
            TossDesignSystem.orange,
            Icons.center_focus_strong,
            _getFocusDescription(energyLevels['focus'] ?? 0),
          ),
          const SizedBox(height: 20),
          _buildEnergyBar(
            '유연성',
            energyLevels['flexibility'] ?? 0,
            TossDesignSystem.successGreen,
            Icons.sync_alt,
            _getFlexibilityDescription(energyLevels['flexibility'] ?? 0),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                ? TossDesignSystem.grayDark50
                : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: TossDesignSystem.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getOverallAdvice(),
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
      .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildEnergyBar(
    String label,
    int value,
    Color color,
    IconData icon,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$value%',
              style: TossDesignSystem.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: value / 100,
          padding: EdgeInsets.zero,
          backgroundColor: isDark 
            ? TossDesignSystem.grayDark200
            : TossDesignSystem.gray200,
          progressColor: color,
          barRadius: const Radius.circular(4),
          animateFromLastPercent: true,
          animation: true,
          animationDuration: 1000,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TossDesignSystem.caption.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _getSocialDescription(int value) {
    if (value >= 80) return '사람들과 함께하는 활동에 최적의 에너지를 가지고 있어요';
    if (value >= 60) return '적당한 사교 활동이 가능한 상태예요';
    if (value >= 40) return '가벼운 만남은 괜찮지만 깊은 대화는 부담스러울 수 있어요';
    return '혼자만의 시간이 필요한 타이밍이에요';
  }

  String _getAloneDescription(int value) {
    if (value >= 80) return '혼자서 하는 활동에서 최고의 성과를 낼 수 있어요';
    if (value >= 60) return '개인 작업에 집중하기 좋은 상태예요';
    if (value >= 40) return '혼자 있되 가끔 사람들과의 교류가 필요해요';
    return '누군가와 함께하는 것이 더 도움이 될 거예요';
  }

  String _getFocusDescription(int value) {
    if (value >= 80) return '복잡한 작업도 깊이 몰입할 수 있는 최상의 집중력';
    if (value >= 60) return '중요한 업무를 처리하기에 적합한 집중력';
    if (value >= 40) return '단순한 작업은 가능하지만 복잡한 일은 피하세요';
    return '휴식을 취하거나 가벼운 활동을 추천해요';
  }

  String _getFlexibilityDescription(int value) {
    if (value >= 80) return '변화와 새로운 도전을 즐길 수 있는 상태';
    if (value >= 60) return '계획 변경에도 잘 적응할 수 있어요';
    if (value >= 40) return '예정된 일정을 따르는 것이 편할 거예요';
    return '루틴을 유지하며 안정감을 찾으세요';
  }

  String _getOverallAdvice() {
    final social = energyLevels['socialBattery'] ?? 0;
    final alone = energyLevels['aloneBattery'] ?? 0;
    final focus = energyLevels['focus'] ?? 0;
    final flexibility = energyLevels['flexibility'] ?? 0;
    
    final average = (social + alone + focus + flexibility) / 4;
    
    if (average >= 70) {
      return '오늘은 전반적으로 에너지가 충만한 날! 도전적인 일을 시도해보세요.';
    } else if (average >= 50) {
      return '균형잡힌 하루를 보낼 수 있어요. 중요한 일부터 차근차근 처리하세요.';
    } else {
      return '에너지 충전이 필요한 날이에요. 무리하지 말고 휴식을 취하세요.';
    }
  }
}