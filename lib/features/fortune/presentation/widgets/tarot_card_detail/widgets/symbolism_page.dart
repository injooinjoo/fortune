import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/constants/tarot/tarot_helper.dart';

class SymbolismPage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;

  const SymbolismPage({
    super.key,
    required this.cardInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드의 상징',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TossDesignSystem.spacingM),

          // Keywords
          if (cardInfo['keywords'] != null) ...[
            _buildSectionTitle(context, '핵심 키워드'),
            const SizedBox(height: TossDesignSystem.spacingXS),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (cardInfo['keywords'] as List).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.spacingM,
                    vertical: TossDesignSystem.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TossDesignSystem.purple.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: TossDesignSystem.spacingXL)
          ],

          // Imagery
          if (cardInfo['imagery'] != null) ...[
            _buildSectionTitle(context, '이미지 해석'),
            const SizedBox(height: TossDesignSystem.spacingXS),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingS),
              child: Text(
                cardInfo['imagery'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacingXL)
          ],

          // Element meaning
          _buildSectionTitle(context, '원소의 의미'),
          const SizedBox(height: TossDesignSystem.spacingXS),
          _buildElementMeaning(context, cardInfo['element']),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildElementMeaning(BuildContext context, String? element) {
    final elementData = {
      '불': {
        'color': TossDesignSystem.errorRed,
        'meaning': '열정, 창의성, 행동력, 영감',
        'description': '불의 원소는 적극적이고 역동적인 에너지를 상징합니다.'
      },
      '물': {
        'color': TossDesignSystem.primaryBlue,
        'meaning': '감정, 직관, 치유, 흐름',
        'description': '물의 원소는 감정의 깊이와 직관적 지혜를 나타냅니다.'
      },
      '공기': {
        'color': TossDesignSystem.warningOrange,
        'meaning': '지성, 소통, 아이디어, 자유',
        'description': '공기의 원소는 명확한 사고와 의사소통을 상징합니다.'
      },
      '땅': {
        'color': TossDesignSystem.successGreen,
        'meaning': '안정, 실용성, 물질, 인내',
        'description': '땅의 원소는 현실적이고 안정적인 기반을 나타냅니다.'
      }
    };

    final data = elementData[element] ??
        {
          'color': TossDesignSystem.purple,
          'meaning': '신비, 변화, 가능성',
          'description': '이 카드는 특별한 에너지를 담고 있습니다.'
        };

    return GlassContainer(
      padding: const EdgeInsets.all(TossDesignSystem.spacingXS),
      gradient: LinearGradient(
        colors: [
          (data['color'] as Color).withValues(alpha: 0.1),
          (data['color'] as Color).withValues(alpha: 0.1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                TarotHelper.getElementIcon(element ?? ''),
                color: data['color'] as Color,
                size: 24,
              ),
              const SizedBox(width: TossDesignSystem.spacingXS),
              Text(
                element ?? '특별한 원소',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacingXS),
          Text(
            data['meaning'] as String,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: TossDesignSystem.spacingXXS),
          Text(
            data['description'] as String,
            style: TextStyle(
              color: TossDesignSystem.white.withValues(alpha: 0.7),
              fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
