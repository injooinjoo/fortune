import 'package:flutter/material.dart';
import '../../data/models/celebrity_saju.dart';

class CelebritySajuInfoWidget extends StatelessWidget {
  final CelebritySaju celebrity;
  final bool showDetailedInfo;

  const CelebritySajuInfoWidget({
    super.key,
    required this.celebrity,
    this.showDetailedInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Text(
                  celebrity.name.isNotEmpty ? celebrity.name[0] : '?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      celebrity.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${celebrity.category} • ${celebrity.age}세',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (celebrity.agency.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        celebrity.agency,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 사주 정보
          _buildSajuInfo(theme),
          
          if (showDetailedInfo) ...[
            const SizedBox(height: 16),
            _buildDetailedInfo(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSajuInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주팔자',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        
        // 사주 문자열
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            celebrity.sajuString.isNotEmpty ? celebrity.sajuString : '사주 정보 없음',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 오행 분포
        _buildElementDistribution(theme),
      ],
    );
  }

  Widget _buildElementDistribution(ThemeData theme) {
    final elementCounts = {
      '목': celebrity.woodCount,
      '화': celebrity.fireCount,
      '토': celebrity.earthCount,
      '금': celebrity.metalCount,
      '수': celebrity.waterCount,
    };

    final total = elementCounts.values.reduce((a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '오행 분포',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '주요: ${celebrity.dominantElement}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getElementColor(celebrity.dominantElement),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 오행 바차트
        Row(
          children: elementCounts.entries.map((entry) {
            final element = entry.key;
            final count = entry.value;
            final percentage = total > 0 ? (count / total) : 0.0;
            
            return Expanded(
              flex: (percentage * 100).toInt().clamp(1, 100),
              child: Container(
                height: 24,
                margin: const EdgeInsets.only(right: 1),
                decoration: BoxDecoration(
                  color: _getElementColor(element).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    count > 0 ? '$element$count' : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailedInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 생년월일 정보
        if (celebrity.birthDate.isNotEmpty) ...[
          _buildInfoRow(
            theme,
            '생년월일',
            '${celebrity.birthDate} (${celebrity.age}세)',
            Icons.cake,
          ),
        ],
        
        // 출생지 정보
        if (celebrity.birthPlace.isNotEmpty) ...[
          _buildInfoRow(
            theme,
            '출생지',
            celebrity.birthPlace,
            Icons.location_on,
          ),
        ],
        
        // 현재 대운 정보
        if (celebrity.daeunInfo != null) ...[
          _buildInfoRow(
            theme,
            '현재 대운',
            celebrity.currentDaeunPeriod,
            Icons.trending_up,
          ),
        ],
        
        // 십신 정보 (간단히)
        if (celebrity.tenGods != null) ...[
          _buildTenGodsInfo(theme),
        ],
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenGodsInfo(ThemeData theme) {
    final tenGods = celebrity.tenGods!;
    final godsList = <String>[];
    
    tenGods.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        godsList.addAll(value.cast<String>());
      }
    });

    if (godsList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '십신: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Text(
              godsList.take(3).join(', '),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return Colors.green;
      case '화':
        return Colors.red;
      case '토':
        return Colors.brown;
      case '금':
        return Colors.amber.shade700;
      case '수':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}