import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/career_change_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class CareerChangeFortunePage extends ConsumerStatefulWidget {
  const CareerChangeFortunePage({super.key});

  @override
  ConsumerState<CareerChangeFortunePage> createState() => _CareerChangeFortunePageState();
}

class _CareerChangeFortunePageState extends ConsumerState<CareerChangeFortunePage> {
  final TextEditingController _currentCompanyController = TextEditingController();
  final TextEditingController _targetCompanyController = TextEditingController();
  String? _changeReason;
  String? _careerYears;
  String? _preparationLevel;

  final List<String> _changeReasons = [
    '연봉 인상', '경력 개발', '워라밸', '회사 문화', '업무 변화', '지역 이동',
  ];
  final List<String> _careerYearOptions = [
    '1년 미만', '1-3년', '3-5년', '5-10년', '10년 이상',
  ];
  final List<String> _preparationLevels = [
    '이직 고민 중', '정보 수집 중', '이력서 준비 중', '면접 진행 중',
  ];

  @override
  void dispose() {
    _currentCompanyController.dispose();
    _targetCompanyController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    return _currentCompanyController.text.isNotEmpty &&
           _changeReason != null &&
           _careerYears != null &&
           _preparationLevel != null;
  }

  int _getExperienceYears(String careerYearsStr) {
    if (careerYearsStr.contains('1년 미만')) return 0;
    if (careerYearsStr.contains('1-3년')) return 2;
    if (careerYearsStr.contains('3-5년')) return 4;
    if (careerYearsStr.contains('5-10년')) return 7;
    if (careerYearsStr.contains('10년 이상')) return 10;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'career-change',
      title: '이직운',
      description: '새로운 직장으로의 변화 가능성을 확인해보세요',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) {
        final theme = Theme.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SingleChildScrollView(
          padding: AppSpacing.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                padding: AppSpacing.paddingAll20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business_center, color: theme.colorScheme.primary),
                        SizedBox(width: AppSpacing.spacing2),
                        Text(
                          '이직 정보',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDark ? TossDesignSystem.textPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.spacing5),

                    TextField(
                      controller: _currentCompanyController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: '현재 회사/직무',
                        hintText: '예: 삼성전자 마케팅팀',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacing4),

                    TextField(
                      controller: _targetCompanyController,
                      decoration: InputDecoration(
                        labelText: '목표 회사/직무 (선택사항)',
                        hintText: '예: 네이버 기획팀',
                        prefixIcon: const Icon(Icons.trending_up),
                        border: OutlineInputBorder(
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.spacing4),

              GlassCard(
                padding: AppSpacing.paddingAll20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이직 사유', style: theme.textTheme.titleMedium),
                    SizedBox(height: AppSpacing.spacing3),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _changeReasons.map((reason) {
                        final isSelected = _changeReason == reason;
                        return ChoiceChip(
                          label: Text(reason),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _changeReason = selected ? reason : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.spacing4),

              GlassCard(
                padding: AppSpacing.paddingAll20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('경력 기간', style: theme.textTheme.titleMedium),
                    SizedBox(height: AppSpacing.spacing3),
                    ...(_careerYearOptions.map((years) {
                      final isSelected = _careerYears == years;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _careerYears = years;
                          });
                        },
                        borderRadius: AppDimensions.borderRadiusMedium,
                        child: Container(
                          padding: AppSpacing.paddingAll16,
                          margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : theme.colorScheme.surface.withValues(alpha: 0.3),
                            borderRadius: AppDimensions.borderRadiusMedium,
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
                              SizedBox(width: AppSpacing.spacing3),
                              Text(years, style: theme.textTheme.bodyLarge),
                            ],
                          ),
                        ),
                      );
                    })),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.spacing4),

              GlassCard(
                padding: AppSpacing.paddingAll20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('준비 상태', style: theme.textTheme.titleMedium),
                    SizedBox(height: AppSpacing.spacing3),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _preparationLevels.map((level) {
                        final isSelected = _preparationLevel == level;
                        return ChoiceChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _preparationLevel = selected ? level : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.spacing8),

              ElevatedButton(
                onPressed: _canSubmit() ? onComplete : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: TossDesignSystem.tossBlue,
                ),
                child: const Text('운세 보기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },

      conditionsBuilder: () async {
        return CareerChangeFortuneConditions(
          currentJob: _currentCompanyController.text,
          targetJob: _targetCompanyController.text,
          experienceYears: _getExperienceYears(_careerYears ?? ''),
          motivation: _changeReason ?? '',
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
                  '이직운 결과',
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
