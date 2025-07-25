import 'package:flutter/material.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class FortuneDisplay extends StatelessWidget {
  final String title;
  final String description;
  final int overallScore;
  final Map<String, dynamic>? luckyItems;
  final String? advice;
  final Map<String, dynamic>? detailedFortune;
  final String? warningMessage;

  const FortuneDisplay({
    Key? key,
    required this.title,
    required this.description,
    required this.overallScore,
    this.luckyItems,
    this.advice,
    this.detailedFortune,
    this.warningMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildOverallScore(context),
        if (luckyItems != null) ...[
          const SizedBox(height: 24),
          _buildLuckyItems(context),
        ],
        if (detailedFortune != null) ...[
          const SizedBox(height: 24),
          _buildDetailedFortune(context),
        ],
        if (advice != null) ...[
          const SizedBox(height: 24),
          _buildAdvice(context),
        ],
        if (warningMessage != null) ...[
          const SizedBox(height: 24),
          _buildWarning(context),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(BuildContext context) {
    final scoreColor = _getScoreColor(overallScore);
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          scoreColor.withValues(alpha: 0.2),
          scoreColor.withValues(alpha: 0.1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '종합 운세',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getScoreDescription(overallScore),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scoreColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$overallScore',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItems(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 행운 아이템',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: luckyItems!.entries.map((entry) {
              return _buildLuckyItemChip(
                entry.key,
                entry.value.toString(),
                context,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItemChip(String label, String value, BuildContext context) {
    IconData icon;
    Color color;
    
    switch (label) {
      case '숫자':
      case 'number':
        icon = Icons.looks_one;
        color = Colors.blue;
        break;
      case '색상':
      case 'color':
        icon = Icons.palette;
        color = Colors.purple;
        break;
      case '방향':
      case 'direction':
        icon = Icons.explore;
        color = Colors.green;
        break;
      case '시간':
      case 'time':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      default:
        icon = Icons.star;
        color = Colors.amber;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFortune(BuildContext context) {
    return Column(
      children: detailedFortune!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(entry.key),
                      color: _getCategoryColor(entry.key),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(entry.key),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdvice(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          Colors.green.withValues(alpha: 0.2),
          Colors.green.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '조언',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          Colors.orange.withValues(alpha: 0.2),
          Colors.orange.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '주의사항',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            warningMessage!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return '매우 좋음';
    if (score >= 60) return '좋음';
    if (score >= 40) return '보통';
    return '주의 필요';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '재물운':
      case '금전운':
        return Icons.attach_money;
      case '연애운':
      case '애정운':
        return Icons.favorite;
      case '건강운':
        return Icons.favorite_border;
      case '직업운':
      case '사업운':
        return Icons.work;
      case '학업운':
        return Icons.school;
      default:
        return Icons.auto_awesome;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '재물운':
      case '금전운':
        return Colors.amber;
      case '연애운':
      case '애정운':
        return Colors.pink;
      case '건강운':
        return Colors.green;
      case '직업운':
      case '사업운':
        return Colors.blue;
      case '학업운':
        return Colors.purple;
      default:
        return Colors.cyan;
    }
  }
}