#!/usr/bin/env python3

import os

pages_dir = "/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter/lib/features/fortune/presentation/pages"

# Define all missing fortune pages
fortune_pages = [
    {
        "type": "lucky-crypto",
        "title": "암호화폐 운세",
        "class_name": "LuckyCrypto",
        "colors": ["Color(0xFFFF6F00)", "Color(0xFFE65100)"],
        "icon": "currency_bitcoin",
        "description": "오늘의 암호화폐 투자 운세를 확인해보세요!\\n유망한 코인과 거래 타이밍을 알려드립니다."
    },
    {
        "type": "lucky-yoga",
        "title": "요가 운세",
        "class_name": "LuckyYoga",
        "colors": ["Color(0xFF9C27B0)", "Color(0xFF7B1FA2)"],
        "icon": "self_improvement",
        "description": "오늘의 요가 수행 운세를 확인해보세요!\\n최적의 수련 시간과 자세를 알려드립니다."
    },
    {
        "type": "lucky-fitness",
        "title": "피트니스 운세",
        "class_name": "LuckyFitness",
        "colors": ["Color(0xFFE91E63)", "Color(0xFFC2185B)"],
        "icon": "fitness_center",
        "description": "오늘의 운동 운세를 확인해보세요!\\n효과적인 운동법과 루틴을 알려드립니다."
    },
    {
        "type": "health",
        "title": "건강운",
        "class_name": "Health",
        "colors": ["Color(0xFF4CAF50)", "Color(0xFF388E3C)"],
        "icon": "favorite",
        "description": "오늘의 건강 운세를 확인해보세요!\\n신체 부위별 컨디션과 건강 관리법을 알려드립니다."
    },
    {
        "type": "employment",
        "title": "취업운",
        "class_name": "Employment",
        "colors": ["Color(0xFF00ACC1)", "Color(0xFF0097A7)"],
        "icon": "work",
        "description": "오늘의 취업 운세를 확인해보세요!\\n면접운과 합격 가능성을 알려드립니다."
    },
    {
        "type": "talent",
        "title": "재능 발견",
        "class_name": "Talent",
        "colors": ["Color(0xFFFFB300)", "Color(0xFFFF8F00)"],
        "icon": "stars",
        "description": "당신의 숨겨진 재능을 발견해보세요!\\n잠재력과 발전 가능성을 알려드립니다."
    },
    {
        "type": "destiny",
        "title": "운명",
        "class_name": "Destiny",
        "colors": ["Color(0xFF5E35B1)", "Color(0xFF4527A0)"],
        "icon": "explore",
        "description": "당신의 운명을 확인해보세요!\\n인생의 전환점과 중요한 시기를 알려드립니다."
    },
    {
        "type": "past-life",
        "title": "전생",
        "class_name": "PastLife",
        "colors": ["Color(0xFF6A1B9A)", "Color(0xFF4A148C)"],
        "icon": "history",
        "description": "당신의 전생을 확인해보세요!\\n과거의 인연과 현생의 과업을 알려드립니다."
    },
    {
        "type": "wish",
        "title": "소원 성취",
        "class_name": "Wish",
        "colors": ["Color(0xFFFF4081)", "Color(0xFFF50057)"],
        "icon": "star",
        "description": "소원 성취 가능성을 확인해보세요!\\n소원을 이루기 위한 방법을 알려드립니다."
    },
    {
        "type": "timeline",
        "title": "인생 타임라인",
        "class_name": "Timeline",
        "colors": ["Color(0xFF00897B)", "Color(0xFF00695C)"],
        "icon": "timeline",
        "description": "인생의 중요한 시점들을 확인해보세요!\\n과거, 현재, 미래의 주요 사건을 알려드립니다."
    },
    {
        "type": "talisman",
        "title": "부적",
        "class_name": "Talisman",
        "colors": ["Color(0xFF8D6E63)", "Color(0xFF6D4C41)"],
        "icon": "shield",
        "description": "오늘 필요한 부적을 확인해보세요!\\n액운을 막고 행운을 부르는 방법을 알려드립니다."
    },
    {
        "type": "yearly",
        "title": "연간 운세",
        "class_name": "Yearly",
        "colors": ["Color(0xFFFFD54F)", "Color(0xFFFFB300)"],
        "icon": "calendar_today",
        "description": "올해의 전체 운세를 확인해보세요!\\n월별 운세와 주요 이벤트를 알려드립니다."
    }
]

# Template for fortune page
template = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class {class_name}FortunePage extends ConsumerWidget {{
  const {class_name}FortunePage({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return BaseFortunePageV2(
      title: '{title}',
      fortuneType: '{type}',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [{color1}, {color2}],
      ),
      inputBuilder: (context, onSubmit) => _{class_name}InputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _{class_name}FortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }}
}}

class _{class_name}InputForm extends StatelessWidget {{
  final Function(Map<String, dynamic>) onSubmit;

  const _{class_name}InputForm({{required this.onSubmit}});

  @override
  Widget build(BuildContext context) {{
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '{description}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        
        Center(
          child: Icon(
            Icons.{icon},
            size: 120,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        
        const SizedBox(height: 32),
        
        Center(
          child: ElevatedButton.icon(
            onPressed: () => onSubmit({{}},),
            icon: const Icon(Icons.{icon}),
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
  }}
}}

class _{class_name}FortuneResult extends StatelessWidget {{
  final FortuneResult result;
  final VoidCallback onShare;

  const _{class_name}FortuneResult({{
    required this.result,
    required this.onShare,
  }});

  @override
  Widget build(BuildContext context) {{
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
                      Icons.{icon},
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '{title}',
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
                            '${{entry.value}}점',
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
                    children: fortune.luckyItems!.entries.map((entry) {{
                      return Chip(
                        label: Text('${{entry.key}}: ${{entry.value}}'),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      );
                    }}).toList(),
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
  }}

  Color _getScoreColor(int score) {{
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }}
}}"""

# Create each fortune page
for page in fortune_pages:
    filename = page["type"].replace("-", "_") + "_fortune_page.dart"
    filepath = os.path.join(pages_dir, filename)
    
    content = template.format(
        class_name=page["class_name"],
        title=page["title"],
        type=page["type"],
        color1=page["colors"][0],
        color2=page["colors"][1],
        icon=page["icon"],
        description=page["description"]
    )
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"Created {filename}")

print("\nAll fortune pages created successfully!")
print("\nNow you need to:")
print("1. Add imports to app_router.dart")
print("2. Add routes to app_router.dart")
print("3. Add categories to fortune_list_page.dart")