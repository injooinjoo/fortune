#!/bin/bash

# Create missing fortune pages for Flutter app

PAGES_DIR="/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter/lib/features/fortune/presentation/pages"

# Define fortune types with their properties
declare -A FORTUNE_PAGES=(
  ["lucky-stock"]="주식 운세|Color(0xFF1E88E5)|Color(0xFF1565C0)|trending_up"
  ["lucky-crypto"]="암호화폐 운세|Color(0xFFFF6F00)|Color(0xFFE65100)|currency_bitcoin"
  ["lucky-yoga"]="요가 운세|Color(0xFF9C27B0)|Color(0xFF7B1FA2)|self_improvement"
  ["lucky-fitness"]="피트니스 운세|Color(0xFFE91E63)|Color(0xFFC2185B)|fitness_center"
  ["health"]="건강운|Color(0xFF4CAF50)|Color(0xFF388E3C)|favorite"
  ["employment"]="취업운|Color(0xFF00ACC1)|Color(0xFF0097A7)|work"
  ["talent"]="재능 발견|Color(0xFFFFB300)|Color(0xFFFF8F00)|stars"
  ["destiny"]="운명|Color(0xFF5E35B1)|Color(0xFF4527A0)|explore"
  ["past-life"]="전생|Color(0xFF6A1B9A)|Color(0xFF4A148C)|history"
  ["wish"]="소원 성취|Color(0xFFFF4081)|Color(0xFFF50057)|star"
  ["timeline"]="인생 타임라인|Color(0xFF00897B)|Color(0xFF00695C)|timeline"
  ["talisman"]="부적|Color(0xFF8D6E63)|Color(0xFF6D4C41)|shield"
  ["yearly"]="연간 운세|Color(0xFFFFD54F)|Color(0xFFFFB300)|calendar_today"
)

# Create each missing fortune page
for FORTUNE_TYPE in "${!FORTUNE_PAGES[@]}"; do
  IFS='|' read -r TITLE COLOR1 COLOR2 ICON <<< "${FORTUNE_PAGES[$FORTUNE_TYPE]}"
  
  # Convert fortune type to class name (e.g., lucky-stock -> LuckyStock)
  CLASS_NAME=$(echo "$FORTUNE_TYPE" | sed -r 's/(^|-)([a-z])/\U\2/g')
  
  # Create the file
  FILE_PATH="$PAGES_DIR/${FORTUNE_TYPE//-/_}_fortune_page.dart"
  
  echo "Creating $FILE_PATH..."
  
  cat > "$FILE_PATH" << EOF
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class ${CLASS_NAME}FortunePage extends ConsumerWidget {
  const ${CLASS_NAME}FortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '$TITLE',
      fortuneType: '$FORTUNE_TYPE',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [$COLOR1, $COLOR2],
      ),
      inputBuilder: (context, onSubmit) => _${CLASS_NAME}InputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _${CLASS_NAME}FortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _${CLASS_NAME}InputForm extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _${CLASS_NAME}InputForm({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 $TITLE를 확인해보세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        
        Center(
          child: Icon(
            Icons.$ICON,
            size: 120,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        
        const SizedBox(height: 32),
        
        Center(
          child: ElevatedButton.icon(
            onPressed: () => onSubmit({}),
            icon: const Icon(Icons.$ICON),
            label: const Text('운세 확인하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _${CLASS_NAME}FortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _${CLASS_NAME}FortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortune = result.fortune;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Fortune Content
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.$ICON,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$TITLE',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  fortune.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score Breakdown
          if (fortune.scoreBreakdown != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '상세 분석',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortune.scoreBreakdown!.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(entry.value).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\${entry.value}점',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _getScoreColor(entry.value),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Lucky Items
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '행운 아이템',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fortune.luckyItems!.entries.map((entry) {
                      return Chip(
                        label: Text('\${entry.key}: \${entry.value}'),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortune.recommendations!.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
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
}
EOF

done

echo "All fortune pages created successfully!"

# Now create a script to add routes
cat > "$PAGES_DIR/../../../../../scripts/add_fortune_routes.dart" << 'EOF'
// Add these routes to app_router.dart

// Import statements to add:
import 'package:fortune/features/fortune/presentation/pages/lucky_lottery_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_stock_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_crypto_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_yoga_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_fitness_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/health_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/employment_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/talent_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/destiny_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/past_life_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/wish_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/timeline_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/talisman_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/yearly_fortune_page.dart';

// Routes to add in the fortune section:
GoRoute(
  path: 'lucky-lottery',
  name: 'fortune-lucky-lottery',
  builder: (context, state) => const LuckyLotteryFortunePage(),
),
GoRoute(
  path: 'lucky-stock',
  name: 'fortune-lucky-stock',
  builder: (context, state) => const LuckyStockFortunePage(),
),
GoRoute(
  path: 'lucky-crypto',
  name: 'fortune-lucky-crypto',
  builder: (context, state) => const LuckyCryptoFortunePage(),
),
GoRoute(
  path: 'lucky-yoga',
  name: 'fortune-lucky-yoga',
  builder: (context, state) => const LuckyYogaFortunePage(),
),
GoRoute(
  path: 'lucky-fitness',
  name: 'fortune-lucky-fitness',
  builder: (context, state) => const LuckyFitnessFortunePage(),
),
GoRoute(
  path: 'health',
  name: 'fortune-health',
  builder: (context, state) => const HealthFortunePage(),
),
GoRoute(
  path: 'employment',
  name: 'fortune-employment',
  builder: (context, state) => const EmploymentFortunePage(),
),
GoRoute(
  path: 'talent',
  name: 'fortune-talent',
  builder: (context, state) => const TalentFortunePage(),
),
GoRoute(
  path: 'destiny',
  name: 'fortune-destiny',
  builder: (context, state) => const DestinyFortunePage(),
),
GoRoute(
  path: 'past-life',
  name: 'fortune-past-life',
  builder: (context, state) => const PastLifeFortunePage(),
),
GoRoute(
  path: 'wish',
  name: 'fortune-wish',
  builder: (context, state) => const WishFortunePage(),
),
GoRoute(
  path: 'timeline',
  name: 'fortune-timeline',
  builder: (context, state) => const TimelineFortunePage(),
),
GoRoute(
  path: 'talisman',
  name: 'fortune-talisman',
  builder: (context, state) => const TalismanFortunePage(),
),
GoRoute(
  path: 'yearly',
  name: 'fortune-yearly',
  builder: (context, state) => const YearlyFortunePage(),
),
EOF

echo "Route addition script created at scripts/add_fortune_routes.dart"