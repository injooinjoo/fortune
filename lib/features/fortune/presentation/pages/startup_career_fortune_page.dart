import '../../../../core/theme/toss_design_system.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class StartupCareerFortunePage extends BaseFortunePage {
  const StartupCareerFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '스타트업 전직 운세',
          description: '대기업에서 스타트업으로의 이직 가능성을 진단합니다',
          fortuneType: 'startup-career',
          requiresUserInfo: false,
          initialParams: initialParams,
        );

  @override
  ConsumerState<StartupCareerFortunePage> createState() => _StartupCareerFortunePageState();
}

class _StartupCareerFortunePageState extends BaseFortunePageState<StartupCareerFortunePage> {
  final TextEditingController _currentPositionController = TextEditingController();
  final TextEditingController _startupInterestController = TextEditingController();
  String? _motivation;
  String? _readiness;
  final List<String> _selectedConcerns = [];
  
  final List<String> _motivations = [
    '독립성과 자유',
    '더 큰 임팩트',
    '지분/수익 가능성',
    '빠른 성장과 학습',
    '열정 프로젝트',
    '혁신과 도전',
  ];

  final List<String> _readinessLevels = [
    '정보 수집 중',
    '진지하게 고려 중',
    '구체적 계획 수립 중',
    '준비 완료',
  ];

  final List<String> _concernOptions = [
    '재정적 불안정',
    '워라밸 우려',
    '스킬 부족',
    '네트워크 부족',
    '경험 부족',
    '실패 리스크',
    '가족 반대',
    '타이밍 불확실',
  ];

  @override
  void dispose() {
    _currentPositionController.dispose();
    _startupInterestController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params,
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_currentPositionController.text.isEmpty ||
        _motivation == null ||
        _readiness == null ||
        _selectedConcerns.isEmpty) {
      return null;
    }

    return {
      'currentPosition': _currentPositionController.text,
      'startupInterest': _startupInterestController.text,
      'motivation': _motivation,
      'readiness': _readiness,
      'concerns': _selectedConcerns,
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rocket,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '스타트업 전직 분석',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Current Position
                TextField(
                  controller: _currentPositionController,
                  decoration: InputDecoration(
                    labelText: '현재 포지션/회사',
                    hintText: '예: 삼성전자 과장, 네이버 시니어 개발자',
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Startup Interest (Optional)
                TextField(
                  controller: _startupInterestController,
                  decoration: InputDecoration(
                    labelText: '관심 있는 스타트업 분야 (선택사항)',
                    hintText: '예: 핀테크, 헬스케어, AI, 이커머스',
                    prefixIcon: const Icon(Icons.lightbulb),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Motivation
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '스타트업 전직 동기',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _motivations.map((motivation) {
                    final isSelected = _motivation == motivation;
                    return ChoiceChip(
                      label: Text(motivation),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _motivation = selected ? motivation : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Readiness Level
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '준비 상태',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...(_readinessLevels.map((level) {
                  final isSelected = _readiness == level;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _readiness = level;
                      });
                    },
                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            level,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                })),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Concerns
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: TossDesignSystem.warningYellow),
                    const SizedBox(width: 8),
                    Text(
                      '주요 고민/우려사항 (2개 이상)',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '최대 4개까지 선택 가능',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _concernOptions.map((concern) {
                    final isSelected = _selectedConcerns.contains(concern);
                    return FilterChip(
                      label: Text(concern),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected && _selectedConcerns.length < 4) {
                            _selectedConcerns.add(concern);
                          } else if (!selected) {
                            _selectedConcerns.remove(concern);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}