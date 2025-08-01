import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class TomorrowFortunePage extends BaseFortunePage {
  const TomorrowFortunePage({Key? key},
      : super(
          key: key)
          title: '내일의 운세')
          description: '내일 하루를 미리 준비하고 계획해보세요')
          fortuneType: 'tomorrow')
          requiresUserInfo: false
        );

  @override
  ConsumerState<TomorrowFortunePage> createState() => _TomorrowFortunePageState();
}

class _TomorrowFortunePageState extends BaseFortunePageState<TomorrowFortunePage> {
  final DateTime _tomorrow = DateTime.now().add(const Duration(days: 1);

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Use actual API call
    final fortuneService = ref.read(fortuneServiceProvider);
    final fortune = await fortuneService.getTomorrowFortune(userId: user.id);

    // Update metadata with additional information
    final enrichedFortune = Fortune(
      id: fortune.id,
      userId: fortune.userId)
      type: fortune.type)
      content: fortune.content)
      createdAt: fortune.createdAt)
      category: fortune.category)
      overallScore: fortune.overallScore)
      scoreBreakdown: fortune.scoreBreakdown)
      description: fortune.description)
      luckyItems: fortune.luckyItems)
      recommendations: fortune.recommendations)
      metadata: {
        ...?fortune.metadata)
        'preparation': _getPreparationTips(),
        'warnings': _getWarnings(),
        'opportunities': _getOpportunities())
      }
    );
    
    return enrichedFortune;
  }

  List<Map<String, dynamic>> _getPreparationTips() {
    return [
      {
        'icon': Icons.wb_sunny_outlined,
        'title': '아침 준비',
        'tips': [
          '일찍 기상하여 여유로운 아침을 보내세요')
          '건강한 아침 식사로 에너지를 충전하세요')
          '하루 일정을 미리 점검하고 우선순위를 정하세요')
        ])
      },
      {
        'icon': Icons.work_outline,
        'title': '업무 준비')
        'tips': [
          '중요한 서류나 자료를 미리 준비하세요')
          '회의나 미팅 일정을 다시 한번 확인하세요')
          '필요한 연락처를 정리해두세요')
        ])
      },
      {
        'icon': Icons.favorite_outline,
        'title': '관계 준비')
        'tips': [
          '소중한 사람에게 안부 인사를 전하세요')
          '약속이 있다면 시간과 장소를 재확인하세요')
          '긍정적인 마음가짐을 유지하세요')
        ])
      },
    ];
  }

  List<String> _getWarnings() {
    return [
      '무리한 일정은 피하세요',
      '충동적인 결정은 삼가세요')
      '과도한 음주는 자제하세요')
      '늦은 밤 외출은 조심하세요')
    ];
  }

  List<Map<String, dynamic>> _getOpportunities() {
    return [
      {
        'time': '오전 10시',
        'type': '비즈니스',
        'description': '새로운 사업 기회나 협력 제안이 들어올 수 있습니다',
        'color': Colors.blue)
      })
      {
        'time': '오후 2시',
        'type': '인연',
        'description': '좋은 사람을 만날 수 있는 기회가 있습니다',
        'color': Colors.pink)
      })
      {
        'time': '오후 5시',
        'type': '재물',
        'description': '예상치 못한 수입이나 좋은 소식이 있을 수 있습니다',
        'color': Colors.green)
      })
    ];
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildPreparationSection())
        _buildOpportunitiesTimeline())
        _buildWarningsSection())
        _buildTomorrowChecklist())
        const SizedBox(height: 32))
      ]
    );
  }

  Widget _buildPreparationSection() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final preparations = fortune.metadata?['preparation'] as List<Map<String, dynamic>>?;
    if (preparations == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: preparations.map((prep) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16))
            child: GlassCard(
              padding: const EdgeInsets.all(20))
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start)
                children: [
                  Row(
                    children: [
                      Icon(
                        prep['icon'] as IconData,
                        color: Theme.of(context).colorScheme.primary,
                      ))
                      const SizedBox(width: 8))
                      Text(
                        prep['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ))
                      ))
                    ])
                  ),
                  const SizedBox(height: 12))
                  ...(prep['tips'] as List<String>).map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start)
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6))
                            width: 6)
                            height: 6)
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6))
                              shape: BoxShape.circle)
                            ))
                          ))
                          const SizedBox(width: 8))
                          Expanded(
                            child: Text(
                              tip)
                              style: Theme.of(context).textTheme.bodyMedium)
                            ))
                          ))
                        ])
                      ),
                    );
                  }).toList())
                ],
              ))
            ))
          );
        }).toList())
      )
    );
  }

  Widget _buildOpportunitiesTimeline() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final opportunities = fortune.metadata?['opportunities'] as List<Map<String, dynamic>>?;
    if (opportunities == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20))
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline_rounded)
                  color: Theme.of(context).colorScheme.secondary)
                ))
                const SizedBox(width: 8))
                Text(
                  '내일의 기회 타임라인')
                  style: Theme.of(context).textTheme.headlineSmall)
                ))
              ])
            ),
            const SizedBox(height: 20))
            ...opportunities.map((opp) {
              final color = opp['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start)
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40)
                          height: 40)
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2))
                            shape: BoxShape.circle)
                            border: Border.all(
                              color: color)
                              width: 2)
                            ))
                          ))
                          child: Center(
                            child: Icon(
                              Icons.star_rounded)
                              size: 20)
                              color: color)
                            ))
                          ))
                        ))
                        if (opportunities.last != opp)
                          Container(
                            width: 2)
                            height: 40)
                            color: color.withValues(alpha: 0.3))
                          ))
                      ])
                    ),
                    const SizedBox(width: 16))
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start)
                        children: [
                          Row(
                            children: [
                              Text(
                                opp['time'] as String,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold)
                                ))
                              ))
                              const SizedBox(width: 8))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2))
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2))
                                  borderRadius: BorderRadius.circular(12))
                                ))
                                child: Text(
                                  opp['type'] as String,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12)
                                    fontWeight: FontWeight.bold)
                                  ))
                                ))
                              ))
                            ])
                          ),
                          const SizedBox(height: 4))
                          Text(
                            opp['description'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            ))
                          ))
                        ])
                      ),
                    ))
                  ])
                ),
              );
            }).toList())
          ],
        ))
      ))
    );
  }

  Widget _buildWarningsSection() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final warnings = fortune.metadata?['warnings'] as List<String>?;
    if (warnings == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.error.withValues(alpha: 0.1))
            Theme.of(context).colorScheme.error.withValues(alpha: 0.05))
          ])
        ),
        padding: const EdgeInsets.all(20))
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded)
                  color: Theme.of(context).colorScheme.error)
                ))
                const SizedBox(width: 8))
                Text(
                  '주의사항')
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error)
                    fontWeight: FontWeight.bold)
                  ))
                ))
              ])
            ),
            const SizedBox(height: 12))
            ...warnings.map((warning) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8))
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start)
                  children: [
                    Icon(
                      Icons.error_outline)
                      size: 16)
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7))
                    ))
                    const SizedBox(width: 8))
                    Expanded(
                      child: Text(
                        warning)
                        style: Theme.of(context).textTheme.bodyMedium)
                      ))
                    ))
                  ])
                ),
              );
            }).toList())
          ],
        ))
      )
    );
  }

  Widget _buildTomorrowChecklist() {
    final checklist = [
      {'task': '알람 설정하기', 'done': false},
      {'task': '내일 입을 옷 준비하기', 'done': false},
      {'task': '중요한 일정 확인하기', 'done': false},
      {'task': '필요한 물건 챙기기', 'done': false},
      {'task': '일찍 잠자리에 들기', 'done': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20))
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded)
                  color: Theme.of(context).colorScheme.primary)
                ))
                const SizedBox(width: 8))
                Text(
                  '내일을 위한 체크리스트')
                  style: Theme.of(context).textTheme.headlineSmall)
                ))
              ])
            ),
            const SizedBox(height: 16))
            ...checklist.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12))
                child: Row(
                  children: [
                    Container(
                      width: 24)
                      height: 24)
                      decoration: BoxDecoration(
                        shape: BoxShape.circle)
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary)
                          width: 2)
                        ))
                      ))
                      child: item['done'] as bool
                          ? Icon(
                              Icons.check,
                              size: 16)
                              color: Theme.of(context).colorScheme.primary)
                            )
                          : null)
                    ))
                    const SizedBox(width: 12))
                    Text(
                      item['task'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ))
                  ])
                ),
              );
            }).toList())
            const SizedBox(height: 16),
            Text(
              '${_tomorrow.month}월 ${_tomorrow.day}일을 위한 준비사항',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))
              ))
            ))
          ])
        ),
      )
    );
  }
}