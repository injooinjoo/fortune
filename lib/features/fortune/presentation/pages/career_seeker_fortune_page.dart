import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/career_seeker_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class CareerSeekerFortunePage extends ConsumerStatefulWidget {
  const CareerSeekerFortunePage({super.key});

  @override
  ConsumerState<CareerSeekerFortunePage> createState() => _CareerSeekerFortunePageState();
}

class _CareerSeekerFortunePageState extends ConsumerState<CareerSeekerFortunePage> {
  String? _educationLevel;
  String? _desiredField;
  int _jobSearchDuration = 0;
  String? _primaryConcern;
  final List<String> _skillAreas = [];

  final List<String> _educationLevels = [
    '고등학교 졸업', '전문대 재학/졸업', '대학교 재학/졸업', '대학원 재학/졸업', '기타'
  ];
  final List<String> _fields = [
    'IT/개발', '디자인/크리에이티브', '마케팅/홍보', '영업/비즈니스',
    '금융/회계', '인사/총무', '생산/제조', '연구/R&D',
    '의료/헬스케어', '교육/강의', '미디어/엔터', '기타'
  ];
  final List<String> _concerns = [
    '서류 통과가 어려워요', '면접이 너무 떨려요', '원하는 회사가 없어요',
    '경력이 부족해요', '연봉 협상이 걱정돼요', '진로가 확실하지 않아요'
  ];
  final List<String> _skills = [
    '커뮤니케이션', '문제해결', '리더십', '창의성',
    '분석력', '협업', '시간관리', '적응력'
  ];

  bool _canSubmit() {
    return _educationLevel != null && _desiredField != null && _primaryConcern != null;
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'career_seeker',
      title: '취업운',
      description: '새로운 직장을 찾고 있는 분들을 위한 맞춤 운세',
      dataSource: FortuneDataSource.api,

      inputBuilder: (context, onComplete) {
        final theme = Theme.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Education Level
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('학력 사항', style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _educationLevels.map((level) {
                        final isSelected = _educationLevel == level;
                        return InkWell(
                          onTap: () => setState(() => _educationLevel = level),
                          borderRadius: BorderRadius.circular(20),
                          child: Chip(
                            label: Text(level),
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                : theme.colorScheme.surface.withValues(alpha: 0.5),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Desired Field
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('희망 분야', style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _desiredField,
                      decoration: InputDecoration(
                        hintText: '희망하는 직무 분야를 선택하세요',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                      ),
                      items: _fields.map((field) => DropdownMenuItem(value: field, child: Text(field))).toList(),
                      onChanged: (value) => setState(() => _desiredField = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Job Search Duration
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('구직 기간', style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _jobSearchDuration.toDouble(),
                            min: 0,
                            max: 12,
                            divisions: 12,
                            label: _jobSearchDuration == 0 ? '시작 전' : '$_jobSearchDuration개월',
                            onChanged: (value) => setState(() => _jobSearchDuration = value.round()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _jobSearchDuration == 0 ? '시작 전' : '$_jobSearchDuration개월',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Primary Concern
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('가장 큰 고민', style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_concerns.length, (index) {
                      final concern = _concerns[index];
                      final isSelected = _primaryConcern == concern;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _primaryConcern = concern),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                  : theme.colorScheme.surface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(concern, style: theme.textTheme.bodyLarge)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Skill Areas
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('보유 역량 (선택사항)', style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('최대 3개까지 선택 가능', style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        final isSelected = _skillAreas.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected && _skillAreas.length < 3) {
                                _skillAreas.add(skill);
                              } else if (!selected) {
                                _skillAreas.remove(skill);
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

              ElevatedButton(
                onPressed: _canSubmit() ? onComplete : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: TossDesignSystem.tossBlue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('운세 보기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },

      conditionsBuilder: () async {
        return CareerSeekerFortuneConditions(
          targetIndustry: _desiredField ?? '',
          targetPosition: _desiredField ?? '희망 직무',
          preparationMonths: _jobSearchDuration,
          skills: _skillAreas,
          date: DateTime.now(),
        );
      },

      resultBuilder: (context, result) {
        final theme = Theme.of(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '취업운 결과',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.data['content'] as String? ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                if (result.score != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '운세 점수: ${result.score}/100',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: TossDesignSystem.tossBlue,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
