import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';

/// MBTI 에너지 게이지 위젯 (토스 스타일)
class MbtiEnergyGauge extends StatelessWidget {
  final int socialBattery;
  final int aloneBattery;
  final int totalEnergy;
  final Map<String, dynamic> burnoutRisk;
  final bool isExtrovert;
  const MbtiEnergyGauge({
    super.key,
    required this.socialBattery,
    required this.aloneBattery,
    required this.totalEnergy,
    required this.burnoutRisk,
    required this.isExtrovert,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TossSectionCard(
      title: '오늘의 에너지 레벨',
      subtitle: '당신의 에너지 충전 상태를 확인하세요',
      style: TossCardStyle.elevated,
      child: Column(
        children: [
          // 메인 에너지 표시
          _buildMainEnergyDisplay(isDark),
          SizedBox(height: TossDesignSystem.spacingL),
          
          // 세부 배터리 표시
          Row(
            children: [
              Expanded(
                child: _buildBatteryCard(
                  title: '사회적 에너지',
                  value: socialBattery,
                  icon: Icons.people_rounded,
                  color: TossDesignSystem.tossBlue,
                  isDark: isDark,
                  isPrimary: isExtrovert,
                ),
              ),
              SizedBox(width: TossDesignSystem.spacingM),
                  title: '개인 에너지',
                  value: aloneBattery,
                  icon: Icons.person_rounded,
                  color: TossDesignSystem.purple,
                  isPrimary: !isExtrovert,
            ],
          ),
          // 번아웃 위험도
          _buildBurnoutRiskIndicator(isDark),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0);
  }
  Widget _buildMainEnergyDisplay(bool isDark) {
    return Container(
      padding: EdgeInsets.all(TossDesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getEnergyGradient(totalEnergy),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
          Icon(
            _getEnergyIcon(totalEnergy),
            size: 48,
            color: TossDesignSystem.white,
          SizedBox(height: TossDesignSystem.spacingM),
          Text(
            '$totalEnergy%',
            style: TossDesignSystem.display2.copyWith(
              color: TossDesignSystem.white,
              fontWeight: FontWeight.bold,
            ),
          SizedBox(height: TossDesignSystem.spacingXS),
            _getEnergyStatus(totalEnergy),
            style: TossDesignSystem.body2.copyWith(
              color: TossDesignSystem.white.withOpacity(0.9),
      .scale(delay: 200.ms, duration: 400.ms)
      .shimmer(delay: 600.ms, duration: 1000.ms);
  Widget _buildBatteryCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required bool isPrimary,
  }) {
      padding: EdgeInsets.all(TossDesignSystem.spacingM),
        color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        border: isPrimary ? Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ) : null,
        crossAxisAlignment: CrossAxisAlignment.start,
              Icon(icon, size: 20, color: color),
              SizedBox(width: TossDesignSystem.spacingXS),
                child: Text(
                  title,
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
          SizedBox(height: TossDesignSystem.spacingS),
            '$value%',
            style: TossDesignSystem.heading3.copyWith(
              color: color,
          _buildProgressBar(value, color),
          if (isPrimary) ...[
            SizedBox(height: TossDesignSystem.spacingXS),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: TossDesignSystem.spacingS,
                vertical: TossDesignSystem.spacingXS,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
              child: Text(
                '주 에너지원',
                style: TossDesignSystem.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
          ],
    );
  Widget _buildProgressBar(int value, Color color) {
      height: 8,
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value / 100,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            borderRadius: BorderRadius.circular(4),
        ).animate()
          .scaleX(
            begin: 0,
            end: 1,
            duration: 800.ms,
            curve: Curves.easeOutCubic,
  Widget _buildBurnoutRiskIndicator(bool isDark) {
    final percentage = burnoutRisk['percentage'] as int;
    final level = burnoutRisk['level'] as String;
    final advice = burnoutRisk['advice'] as String;
    
    Color riskColor;
    IconData riskIcon;
    switch (level) {
      case '안전':
        riskColor = TossDesignSystem.successGreen;
        riskIcon = Icons.check_circle_rounded;
        break;
      case '주의':
        riskColor = TossDesignSystem.tossBlue;
        riskIcon = Icons.info_rounded;
      case '경고':
        riskColor = TossDesignSystem.warningOrange;
        riskIcon = Icons.warning_rounded;
      default:
        riskColor = TossDesignSystem.errorRed;
        riskIcon = Icons.error_rounded;
    }
        color: riskColor.withOpacity(0.1),
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 1,
              Icon(riskIcon, color: riskColor, size: 24),
              SizedBox(width: TossDesignSystem.spacingS),
              Text(
                '번아웃 위험도',
                style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacingS,
                  vertical: TossDesignSystem.spacingXS,
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                  level,
                    color: riskColor,
                    fontWeight: FontWeight.bold,
          ClipRRect(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: riskColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(riskColor),
              minHeight: 8,
            advice,
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
  List<Color> _getEnergyGradient(int energy) {
    if (energy >= 80) {
      return [TossDesignSystem.successGreen, TossDesignSystem.successGreen.withOpacity(0.8)];
    } else if (energy >= 60) {
      return [TossDesignSystem.tossBlue, TossDesignSystem.tossBlue.withOpacity(0.8)];
    } else if (energy >= 40) {
      return [TossDesignSystem.warningOrange, TossDesignSystem.warningOrange.withOpacity(0.8)];
    } else {
      return [TossDesignSystem.errorRed, TossDesignSystem.errorRed.withOpacity(0.8)];
  IconData _getEnergyIcon(int energy) {
    if (energy >= 80) return Icons.battery_full_rounded;
    if (energy >= 60) return Icons.battery_5_bar_rounded;
    if (energy >= 40) return Icons.battery_3_bar_rounded;
    if (energy >= 20) return Icons.battery_1_bar_rounded;
    return Icons.battery_alert_rounded;
  String _getEnergyStatus(int energy) {
    if (energy >= 80) return '최상의 컨디션';
    if (energy >= 60) return '양호한 상태';
    if (energy >= 40) return '보통 상태';
    if (energy >= 20) return '휴식 필요';
    return '충전 필요';
}
