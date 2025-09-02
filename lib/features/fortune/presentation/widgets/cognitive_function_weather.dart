import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';

/// 인지기능 날씨 위젯 (토스 스타일)
class CognitiveFunctionWeather extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final String mbtiType;
  const CognitiveFunctionWeather({
    super.key,
    required this.weatherData,
    required this.mbtiType,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final functions = weatherData['functions'] as Map<String, Map<String, dynamic>>;
    final overall = weatherData['overall'] as Map<String, dynamic>;
    return TossSectionCard(
      title: '인지기능 날씨',
      subtitle: '오늘 당신의 인지기능 상태를 날씨로 표현했어요',
      style: TossCardStyle.elevated,
      child: Column(
        children: [
          // 전체 날씨 요약
          _buildOverallWeather(overall, isDark),
          SizedBox(height: TossDesignSystem.spacingL),
          
          // 각 인지기능 날씨
          _buildFunctionWeatherGrid(functions, isDark),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0);
  }
  Widget _buildOverallWeather(Map<String, dynamic> overall, bool isDark) {
    final condition = overall['condition'] as String;
    final advice = overall['advice'] as String;
    final average = overall['average'] as int;
    
    return Container(
      padding: EdgeInsets.all(TossDesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getWeatherGradient(average),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
          Text(
            _getOverallWeatherIcon(average),
            style: const TextStyle(fontSize: 64),
          ).animate()
            .scale(delay: 200.ms, duration: 600.ms)
            .then()
            .shimmer(duration: 1500.ms),
          SizedBox(height: TossDesignSystem.spacingM),
            condition,
            style: TossDesignSystem.heading2.copyWith(
              color: TossDesignSystem.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingS),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: TossDesignSystem.spacingM,
              vertical: TossDesignSystem.spacingS,
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
            child: Text(
              '평균 활성도 $average%',
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            advice,
            style: TossDesignSystem.body3.copyWith(
              color: TossDesignSystem.white.withOpacity(0.9),
            textAlign: TextAlign.center,
    );
  Widget _buildFunctionWeatherGrid(
      Map<String, Map<String, dynamic>> functions, bool isDark) {
    final entries = functions.entries.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: TossDesignSystem.spacingM,
        mainAxisSpacing: TossDesignSystem.spacingM,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final function = entries[index].key;
        final data = entries[index].value;
        
        return _buildWeatherCard(
          function: function,
          data: data,
          isDark: isDark,
          index: index,
        );
      },
  Widget _buildWeatherCard({
    required String function,
    required Map<String, dynamic> data,
    required bool isDark,
    required int index,
  }) {
    final level = data['level'] as int;
    final condition = data['condition'] as String;
    final icon = data['icon'] as String;
    final name = data['name'] as String;
    return TossCard(
      style: TossCardStyle.outlined,
      padding: EdgeInsets.all(TossDesignSystem.spacingM),
        mainAxisAlignment: MainAxisAlignment.center,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 28),
              SizedBox(width: TossDesignSystem.spacingS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getFunctionColor(function).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusXS),
                child: Text(
                  function,
                  style: TossDesignSystem.caption.copyWith(
                    color: _getFunctionColor(function),
                    fontWeight: FontWeight.bold,
                  ),
            ],
            name,
            style: TossDesignSystem.caption.copyWith(
              color: isDark 
                  ? TossDesignSystem.grayDark600
                  : TossDesignSystem.gray600,
          SizedBox(height: TossDesignSystem.spacingXS),
            style: TossDesignSystem.body2.copyWith(
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
          // 레벨 바
            height: 4,
              color: _getFunctionColor(function).withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: level / 100,
              child: Container(
                  color: _getFunctionColor(function),
                  borderRadius: BorderRadius.circular(2),
            ).animate()
              .scaleX(
                begin: 0,
                end: 1,
                delay: Duration(milliseconds: 100 * index),
                duration: 600.ms,
                curve: Curves.easeOutCubic,
            '$level%',
              color: _getFunctionColor(function),
      .fadeIn(
        delay: Duration(milliseconds: 50 * index),
        duration: 400.ms,
      )
      .scale(
        begin: 0.8,
        end: 1.0,
      );
  List<Color> _getWeatherGradient(int average) {
    if (average >= 70) {
      return [
        const Color(0xFF87CEEB), // Sky blue
        const Color(0xFF98D8E8),
      ];
    } else if (average >= 50) {
        const Color(0xFF93A5BE), // Partly cloudy
        const Color(0xFFB4C5D8),
    } else if (average >= 30) {
        const Color(0xFF8B95A1), // Cloudy
        const Color(0xFFB0B8C1),
    } else {
        const Color(0xFF6B7684), // Stormy
        const Color(0xFF8B95A1),
    }
  String _getOverallWeatherIcon(int average) {
    if (average >= 70) return '☀️';
    if (average >= 50) return '⛅';
    if (average >= 30) return '☁️';
    return '⛈️';
  Color _getFunctionColor(String function) {
    final colors = {
      'Te': TossDesignSystem.errorRed,
      'Ti': const Color(0xFF4ECDC4),
      'Fe': TossDesignSystem.warningOrange,
      'Fi': TossDesignSystem.successGreen,
      'Ne': TossDesignSystem.purple,
      'Ni': const Color(0xFFFFA07A),
      'Se': const Color(0xFFFF8B94),
      'Si': const Color(0xFFB4E7CE),
    };
    return colors[function] ?? TossDesignSystem.tossBlue;
}
/// 인지기능 날씨 미니 위젯 (간단한 표시용)
class CognitiveFunctionWeatherMini extends StatelessWidget {
  const CognitiveFunctionWeatherMini({
          colors: _getWeatherGradient(average).map((c) => c.withOpacity(0.1)).toList(),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        border: Border.all(
          color: _getWeatherGradient(average).first.withOpacity(0.3),
          width: 1,
      child: Row(
            style: const TextStyle(fontSize: 32),
          SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '인지기능 날씨',
                    color: isDark 
                        ? TossDesignSystem.grayDark400
                        : TossDesignSystem.gray600,
                SizedBox(height: TossDesignSystem.spacingXS),
                  condition,
                  style: TossDesignSystem.body2.copyWith(
                        ? TossDesignSystem.grayDark900
                        : TossDesignSystem.gray900,
              ],
              color: _getWeatherGradient(average).first.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
              '$average%',
                color: _getWeatherGradient(average).first,
                fontWeight: FontWeight.bold,
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.05, end: 0);
      return [const Color(0xFF87CEEB), const Color(0xFF98D8E8)];
      return [const Color(0xFF93A5BE), const Color(0xFFB4C5D8)];
      return [const Color(0xFF8B95A1), const Color(0xFFB0B8C1)];
      return [const Color(0xFF6B7684), const Color(0xFF8B95A1)];
