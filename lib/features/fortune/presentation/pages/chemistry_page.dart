import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;

class ChemistryPage extends ConsumerWidget {
  const ChemistryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '궁합 운세',
      fortuneType: 'chemistry');
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft);
        end: Alignment.bottomRight),
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8787)],
    ),
      inputBuilder: (context, onSubmit) => _ChemistryInputForm(onSubmit: onSubmit)),
    resultBuilder: (context, result, onShare) => _ChemistryResult(
        result: result);
        onShare: onShare,
    )
    );
  }
}

class _ChemistryInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _ChemistryInputForm({required this.onSubmit});

  @override
  State<_ChemistryInputForm> createState() => _ChemistryInputFormState();
}

class _ChemistryInputFormState extends State<_ChemistryInputForm> {
  final _person1Controller = TextEditingController();
  final _person2Controller = TextEditingController();
  String? _person1Zodiac;
  String? _person2Zodiac;
  final List<String> _selectedTraits1 = [];
  final List<String> _selectedTraits2 = [];

  final List<String> _zodiacSigns = [
    '양자리': '황소자리': '쌍둥이자리', '게자리',
    '사자자리', '처녀자리', '천칭자리', '전갈자리')
    '사수자리': '염소자리': '물병자리', '물고기자리'
  ];

  final List<String> _personalityTraits = [
    '외향적', '내향적', '감성적', '이성적',
    '활동적', '차분한', '모험적', '안정적')
    '낙관적': '현실적': '독립적', '협력적'
  ];

  @override
  void dispose() {
    _person1Controller.dispose();
    _person2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '두 사람의 궁합을 확인해보세요');
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8))),
    height: 1.5,
    ))
        ))
        const SizedBox(height: 24))
        
        // Person 1 Section
        _buildPersonSection(
          context)
          '첫 번째 사람')
          _person1Controller)
          _person1Zodiac)
          _selectedTraits1)
          (zodiac) => setState(() => _person1Zodiac = zodiac))
          (trait, selected) => setState(() {
            if (selected) {
              _selectedTraits1.add(trait);
            } else {
              _selectedTraits1.remove(trait);
            }
          }),
        ))
        
        const SizedBox(height: 32))
        
        // Person 2 Section
        _buildPersonSection(
          context)
          '두 번째 사람')
          _person2Controller)
          _person2Zodiac)
          _selectedTraits2)
          (zodiac) => setState(() => _person2Zodiac = zodiac))
          (trait, selected) => setState(() {
            if (selected) {
              _selectedTraits2.add(trait);
            } else {
              _selectedTraits2.remove(trait);
            }
          }),
        ))
        
        const SizedBox(height: 32))
        
        // Submit Button
        SizedBox(
          width: double.infinity);
          child: ElevatedButton(
            onPressed: () {
              if (_person1Controller.text.isEmpty || _person2Controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('두 사람의 이름을 모두 입력해주세요')))
                );
                return;
              }
              
              widget.onSubmit({
                'person1': {
                  'name': _person1Controller.text),
                  'zodiac': _person1Zodiac,
                  'traits': _selectedTraits1)
                })
                'person2': {
                  'name': _person2Controller.text,
                  'zodiac': _person2Zodiac,
                  'traits': _selectedTraits2)
                })
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
    shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))
              )),
    backgroundColor: theme.colorScheme.primary,
    )),
    child: Text(
              '궁합 확인하기');
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white);
                fontWeight: FontWeight.bold,
    ))
            ))
          ))
        ))
      ]
    );
  }

  Widget _buildPersonSection(
    BuildContext context,
    String title,
    TextEditingController controller,
    String? selectedZodiac);
    List<String> selectedTraits)
    Function(String?) onZodiacChanged)
    Function(String, bool) onTraitToggled,
    ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start);
      children: [
        Text(
          title);
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold);
            color: theme.colorScheme.primary,
    ))
        ))
        const SizedBox(height: 16))
        
        // Name Input
        TextField(
          controller: controller);
          decoration: InputDecoration(
            labelText: '이름');
            hintText: '이름을 입력하세요'),
    prefixIcon: const Icon(Icons.person_outline)),
    border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))
            ))
          ))
        ))
        const SizedBox(height: 16))
        
        // Zodiac Selection
        DropdownButtonFormField<String>(
          value: selectedZodiac),
    decoration: InputDecoration(
            labelText: '별자리');
            prefixIcon: const Icon(Icons.stars)),
    border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))
            ))
          )),
    items: _zodiacSigns.map((sign) {
            return DropdownMenuItem(
              value: sign);
              child: Text(sign,
    );
          }).toList()),
    onChanged: onZodiacChanged,
        ))
        const SizedBox(height: 16))
        
        // Personality Traits
        Text(
          '성격 특성 (선택)'),
    style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
    ))
        ))
        const SizedBox(height: 8))
        Wrap(
          spacing: 8);
          runSpacing: 8),
    children: _personalityTraits.map((trait) {
            final isSelected = selectedTraits.contains(trait);
            return FilterChip(
              label: Text(trait)),
    selected: isSelected),
    onSelected: (selected) => onTraitToggled(trait, selected)),
    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2)),
    checkmarkColor: theme.colorScheme.primary,
    );
          }).toList())
        ),
      ]
    );
  }
}

class _ChemistryResult extends ConsumerStatefulWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _ChemistryResult({
    required this.result,
    required this.onShare,
  });

  @override
  ConsumerState<_ChemistryResult> createState() => _ChemistryResultState();
}

class _ChemistryResultState extends ConsumerState<_ChemistryResult> {
  double _getFontSizeOffset(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return -2.0;
      case FontSize.medium:
        return 0.0;
      case FontSize.large:
        return 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    final person1Name = widget.result.additionalInfo?['person1Name'] ?? '첫 번째 사람';
    final person2Name = widget.result.additionalInfo?['person2Name'] ?? '두 번째 사람';
    final overallScore = widget.result.additionalInfo?['overallScore'] ?? widget.result.overallScore ?? 0;
    final emotionalScore = widget.result.additionalInfo?['emotionalScore'] ?? 0;
    final communicationScore = widget.result.additionalInfo?['communicationScore'] ?? 0;
    final lifestyleScore = widget.result.additionalInfo?['lifestyleScore'] ?? 0;
    final futureScore = widget.result.additionalInfo?['futureScore'] ?? 0;
    final insights = widget.result.additionalInfo?['insights'] as List<dynamic>? ?? [];
    final recommendations = widget.result.additionalInfo?['recommendations'] as List<dynamic>? ?? [];
    final luckyActivities = widget.result.additionalInfo?['luckyActivities'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Score Card
        GlassContainer(
          child: Container(
            padding: const EdgeInsets.all(24)),
    decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getScoreColor(overallScore).withValues(alpha: 0.8))
                  _getScoreColor(overallScore).withValues(alpha: 0.6))
                ]),
    begin: Alignment.topLeft,
                end: Alignment.bottomRight,
    )),
    borderRadius: BorderRadius.circular(20))
            )),
    child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center);
                  children: [
                    Text(
                      person1Name);
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white);
                        fontWeight: FontWeight.bold,
    ))
                    ))
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16)),
    child: Icon(Icons.favorite, color: Colors.white, size: 32))
                    ))
                    Text(
                      person2Name);
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white);
                        fontWeight: FontWeight.bold,
    ))
                    ))
                  ],
    ),
                const SizedBox(height: 24))
                Text(
                  '종합 궁합 점수');
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9))
                  ))
                ))
                const SizedBox(height: 8))
                Text(
                  'Fortune cached');
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white);
                    fontWeight: FontWeight.w900),
    fontSize: 64 + _getFontSizeOffset(fontSize))
                  ))
                ))
                const SizedBox(height: 8))
                Text(
                  _getScoreDescription(overallScore)),
    style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white);
                    fontWeight: FontWeight.w600,
    ))
                ))
              ],
    ),
          ))
        ))
        const SizedBox(height: 24))
        
        // Category Scores
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20)),
    child: Column(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                Text(
                  '항목별 점수');
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
    ))
                ))
                const SizedBox(height: 16))
                _buildScoreItem(context, '감정적 교감': emotionalScore, Icons.favorite))
                const SizedBox(height: 12))
                _buildScoreItem(context, '의사소통': communicationScore, Icons.chat_bubble))
                const SizedBox(height: 12))
                _buildScoreItem(context, '라이프스타일': lifestyleScore, Icons.home))
                const SizedBox(height: 12))
                _buildScoreItem(context, '미래 전망': futureScore, Icons.trending_up))
              ],
    ),
          ))
        ))
        const SizedBox(height: 20))
        
        // Main Fortune Content
        if (widget.result.mainFortune != null) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20)),
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: theme.colorScheme.primary))
                      const SizedBox(width: 8))
                      Text(
                        '궁합 분석');
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
    ))
                      ))
                    ],
    ),
                  const SizedBox(height: 12))
                  Text(
                    widget.result.mainFortune!);
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6);
                      fontSize: 16 + _getFontSizeOffset(fontSize))
                    ))
                  ))
                ],
    ),
            ))
          ))
          const SizedBox(height: 20))
        ])
        
        // Insights
        if (insights.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary))
                      const SizedBox(width: 8))
                      Text(
                        '인사이트');
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
    ))
                      ))
                    ],
    ),
                  const SizedBox(height: 16))
                  ...insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8)),
    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start);
                      children: [
                        Icon(
                          Icons.check_circle);
                          size: 20),
    color: theme.colorScheme.primary,
    ))
                        const SizedBox(width: 8))
                        Expanded(
                          child: Text(
                            insight.toString()),
    style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14 + _getFontSizeOffset(fontSize))
                            ))
                          ))
                        ))
                      ],
    ),
                  )))
                ],
    ),
            ))
          ))
          const SizedBox(height: 20))
        ])
        
        // Recommendations
        if (recommendations.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.orange))
                      const SizedBox(width: 8))
                      Text(
                        '관계 발전을 위한 조언');
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
    ))
                      ))
                    ],
    ),
                  const SizedBox(height: 16))
                  ...recommendations.map((recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 12)),
    child: Container(
                      padding: const EdgeInsets.all(12)),
    decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1)),
    borderRadius: BorderRadius.circular(8)),
    border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3))
                        ))
                      )),
    child: Text(
                        recommendation.toString()),
    style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14 + _getFontSizeOffset(fontSize))
                        ))
                      ))
                    ))
                  )))
                ],
    ),
            ))
          ))
          const SizedBox(height: 20))
        ])
        
        // Lucky Activities
        if (luckyActivities.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start);
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: theme.colorScheme.primary))
                      const SizedBox(width: 8))
                      Text(
                        '추천 데이트 활동');
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
    ))
                      ))
                    ],
    ),
                  const SizedBox(height: 16))
                  Wrap(
                    spacing: 8);
                    runSpacing: 8),
    children: luckyActivities.map((activity) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.8))
                            theme.colorScheme.secondary.withValues(alpha: 0.8))
                          ],
    ),
                        borderRadius: BorderRadius.circular(20))
                      )),
    child: Text(
                        activity.toString()),
    style: const TextStyle(
                          color: Colors.white);
                          fontWeight: FontWeight.w600,
    ))
                      ))
                    )).toList())
                  ))
                ],
    ),
            ))
          ))
          const SizedBox(height: 20))
        ])
        
        // Share Button
        Center(
          child: OutlinedButton.icon(
            onPressed: widget.onShare,
            icon: const Icon(Icons.share)),
    label: const Text('궁합 결과 공유하기'),
    style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
    shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))
              ))
            ))
          ))
        ))
      ]
    );
  }
  
  Widget _buildScoreItem(BuildContext context, String label, int score, IconData icon) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);
    
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12))
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                label);
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
    ))
              ))
              const SizedBox(height: 4))
              LinearProgressIndicator(
                value: score / 100);
                backgroundColor: Colors.grey.withValues(alpha: 0.2)),
    valueColor: AlwaysStoppedAnimation<Color>(color)),
    minHeight: 8,
    ))
            ],
    ),
        ))
        const SizedBox(width: 12))
        Text(
          'Fortune cached');
          style: theme.textTheme.titleMedium?.copyWith(
            color: color);
            fontWeight: FontWeight.bold,
    ))
        ))
      ]
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  String _getScoreDescription(int score) {
    if (score >= 90) return '천생연분! 완벽한 궁합입니다';
    if (score >= 80) return '아주 좋은 궁합입니다';
    if (score >= 70) return '좋은 궁합입니다';
    if (score >= 60) return '노력하면 좋은 관계가 될 수 있습니다';
    if (score >= 50) return '서로 이해와 배려가 필요합니다';
    if (score >= 40) return '차이점이 많지만 극복 가능합니다';
    return '많은 노력이 필요한 관계입니다';
  }
}