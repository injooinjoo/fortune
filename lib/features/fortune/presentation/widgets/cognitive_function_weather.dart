import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';

class CognitiveFunctionWeather extends StatelessWidget {
  final Map<String, dynamic> cognitiveWeather;
  final bool isDark;

  const CognitiveFunctionWeather({
    super.key,
    required this.cognitiveWeather,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final functions = cognitiveWeather['functions'] as List<dynamic>? ?? [];
    final todayHighlight = cognitiveWeather['todayHighlight'] as String? ?? '';
    final todayChallenge = cognitiveWeather['todayChallenge'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  TossDesignSystem.grayDark100,
                  TossDesignSystem.grayDark200.withValues(alpha: 0.5),
                ]
              : [
                  TossDesignSystem.white,
                  TossDesignSystem.gray50.withValues(alpha: 0.5),
                ],
        ),
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
                  color: TossDesignSystem.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_cloudy_outlined,
                  color: TossDesignSystem.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '인지기능 날씨',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '오늘의 인지기능 상태를 날씨로 표현했어요',
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: functions.length,
            itemBuilder: (context, index) {
              final function = functions[index] as Map<String, dynamic>;
              return _buildFunctionCard(function).animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .slideX(begin: -0.1, end: 0);
            },
          ),
          const SizedBox(height: 24),
          _buildInsightCard(
            title: '오늘의 강점',
            content: todayHighlight,
            icon: Icons.star_outline,
            color: TossDesignSystem.orange,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            title: '주의 필요',
            content: todayChallenge,
            icon: Icons.warning_amber_outlined,
            color: TossDesignSystem.purple,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
      .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildFunctionCard(Map<String, dynamic> function) {
    final name = function['name'] as String? ?? '';
    final weather = function['weather'] as String? ?? '';
    final level = function['level'] as int? ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark 
          ? TossDesignSystem.grayDark50.withValues(alpha: 0.5)
          : TossDesignSystem.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getFunctionColor(name).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(weather),
            size: 24,
            color: _getFunctionColor(name),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getFunctionKoreanName(name),
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getWeatherDescription(weather),
                  style: TossDesignSystem.caption.copyWith(
                    color: _getFunctionColor(name),
                    fontWeight: FontWeight.w600,
                    
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getFunctionColor(name).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$level',
              style: TossDesignSystem.caption.copyWith(
                color: _getFunctionColor(name),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.body3.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.grain;
      case 'stormy':
        return Icons.thunderstorm;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _getWeatherDescription(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '매우 활발';
      case 'partly cloudy':
        return '적당히 활발';
      case 'cloudy':
        return '보통';
      case 'rainy':
        return '저조';
      case 'stormy':
        return '혼란';
      default:
        return '보통';
    }
  }

  Color _getFunctionColor(String function) {
    if (function.contains('Ti') || function.contains('Te')) {
      return TossDesignSystem.tossBlue;
    } else if (function.contains('Fi') || function.contains('Fe')) {
      return TossDesignSystem.purple;
    } else if (function.contains('Ni') || function.contains('Ne')) {
      return TossDesignSystem.orange;
    } else if (function.contains('Si') || function.contains('Se')) {
      return TossDesignSystem.successGreen;
    }
    return TossDesignSystem.gray600;
  }

  String _getFunctionKoreanName(String function) {
    final Map<String, String> functionNames = {
      'Ti': '내향 사고',
      'Te': '외향 사고',
      'Fi': '내향 감정',
      'Fe': '외향 감정',
      'Ni': '내향 직관',
      'Ne': '외향 직관',
      'Si': '내향 감각',
      'Se': '외향 감각',
    };
    return functionNames[function] ?? function;
  }
}