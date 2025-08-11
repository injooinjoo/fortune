import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';

class CareerCrisisFortunePage extends BaseFortunePage {
  const CareerCrisisFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '커리어 위기 극복 운세',
          description: '현재의 어려움을 극복할 방법을 찾아드립니다',
          fortuneType: 'career-crisis',
          requiresUserInfo: false,
          initialParams: initialParams,
        );

  @override
  ConsumerState<CareerCrisisFortunePage> createState() => _CareerCrisisFortunePageState();
}

class _CareerCrisisFortunePageState extends BaseFortunePageState<CareerCrisisFortunePage> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _crisisType;
  String? _severity;
  final List<String> _selectedSymptoms = [];
  
  final List<String> _crisisTypes = [
    '번아웃/소진': '직장 내 갈등',
    '성과 부진': '진로 고민',
    '구조조정 위기': '성장 정체',
  ];

  final List<String> _severityLevels = [
    '경미함': '보통',
    '심각함': '매우 심각함',
  ];

  final List<String> _symptomOptions = [
    '의욕 상실': '불안/스트레스',
    '수면 장애': '건강 악화',
    '대인관계 어려움': '자신감 하락',
    '분노/짜증': '사직 충동',
  ];

  @override
  void dispose() {
    _situationController.dispose();
    _durationController.dispose();
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
    if (_situationController.text.isEmpty ||
        _crisisType == null ||
        _severity == null ||
        _selectedSymptoms.isEmpty) {
      return null;
    }

    return {
      'situation': _situationController.text,
      'duration': _durationController.text,
      'crisisType': _crisisType,
      'severity': _severity,
      'symptoms': _selectedSymptoms,
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: theme.colorScheme.errorContainer.withOpacity(0.5),
            child: Padding(
              padding: AppSpacing.paddingAll16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.healing,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(width: AppSpacing.spacing2),
                      Text(
                        '커리어 위기 진단',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.spacing2),
                  Text(
                    '현재의 어려움을 극복할 방법을 찾아드립니다',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.spacing4),
          
          // Situation Description
          GlassCard(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 상황',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.spacing3),
                TextField(
                  controller: _situationController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '현재 상황 설명',
                    hintText: '어떤 어려움을 겪고 계신가요?',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.spacing4),
                TextField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: '지속 기간 (선택사항)',
                    hintText: '예: 3개월, 1년',
                    prefixIcon: const Icon(Icons.timer),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spacing4),
          
          // Crisis Type
          GlassCard(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '위기 유형',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.spacing3),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _crisisTypes.map((type) {
                    final isSelected = _crisisType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _crisisType = selected ? type : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spacing4),
          
          // Severity Level
          GlassCard(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '심각도',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.spacing3),
                ...(_severityLevels.map((level) {
                  final isSelected = _severity == level;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _severity = level;
                      });
                    },
                    borderRadius: AppDimensions.borderRadiusMedium,
                    child: Container(
                      padding: AppSpacing.paddingAll16,
                      margin: const EdgeInsets.only(bottom: AppSpacing.xSmall),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.surface.withOpacity(0.3),
                        borderRadius: AppDimensions.borderRadiusMedium,
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
                          SizedBox(width: AppSpacing.spacing3),
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
          SizedBox(height: AppSpacing.spacing4),
          
          // Symptoms
          GlassCard(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist, color: AppColors.error),
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      '겪고 있는 증상 (2개 이상)',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  '최대 5개까지 선택 가능',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: AppSpacing.spacing3),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _symptomOptions.map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return FilterChip(
                      label: Text(symptom),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected && _selectedSymptoms.length < 5) {
                            _selectedSymptoms.add(symptom);
                          } else if (!selected) {
                            _selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spacing8),
        ],
      ),
    );
  }
}