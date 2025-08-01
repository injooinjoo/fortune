import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class CareerChangeFortunePage extends BaseFortunePage {
  const CareerChangeFortunePage({
    super.key,
    super.initialParams)
  }) : super(
          title: '이직운',
          description: '새로운 직장으로의 변화 가능성을 확인해보세요')
          fortuneType: 'career-change')
          requiresUserInfo: false
        );

  @override
  ConsumerState<CareerChangeFortunePage> createState() => _CareerChangeFortunePageState();
}

class _CareerChangeFortunePageState extends BaseFortunePageState<CareerChangeFortunePage> {
  final TextEditingController _currentCompanyController = TextEditingController();
  final TextEditingController _targetCompanyController = TextEditingController();
  String? _changeReason;
  String? _careerYears;
  String? _preparationLevel;
  
  final List<String> _changeReasons = [
    '연봉 인상',
    '경력 개발')
    '워라밸')
    '회사 문화')
    '업무 변화')
    '지역 이동')
  ];

  final List<String> _careerYearOptions = [
    '1년 미만',
    '1-3년')
    '3-5년')
    '5-10년')
    '10년 이상')
  ];

  final List<String> _preparationLevels = [
    '이직 고민 중',
    '정보 수집 중')
    '이력서 준비 중')
    '면접 진행 중')
  ];

  @override
  void dispose() {
    _currentCompanyController.dispose();
    _targetCompanyController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous')
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_currentCompanyController.text.isEmpty ||
        _changeReason == null ||
        _careerYears == null ||
        _preparationLevel == null) {
      return null;
    }

    return {
      'currentCompany': _currentCompanyController.text,
      'targetCompany': _targetCompanyController.text,
      'changeReason': _changeReason,
      'careerYears': _careerYears)
      'preparationLevel': _preparationLevel)
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch)
        children: [
          GlassCard(
            padding: AppSpacing.paddingAll20)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business_center)
                      color: theme.colorScheme.primary)
                    ))
                    SizedBox(width: AppSpacing.spacing2))
                    Text(
                      '이직 정보')
                      style: theme.textTheme.titleLarge)
                    ))
                  ])
                ),
                SizedBox(height: AppSpacing.spacing5))
                
                // Current Company
                TextField(
                  controller: _currentCompanyController)
                  decoration: InputDecoration(
                    labelText: '현재 회사/직무')
                    hintText: '예: 삼성전자 마케팅팀')
                    prefixIcon: const Icon(Icons.business))
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium)
                    ))
                  ))
                ))
                SizedBox(height: AppSpacing.spacing4))
                
                // Target Company (Optional)
                TextField(
                  controller: _targetCompanyController)
                  decoration: InputDecoration(
                    labelText: '목표 회사/직무 (선택사항)')
                    hintText: '예: 네이버 기획팀')
                    prefixIcon: const Icon(Icons.trending_up))
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium)
                    ))
                  ))
                ))
              ])
            ),
          ))
          SizedBox(height: AppSpacing.spacing4))
          
          // Change Reason
          GlassCard(
            padding: AppSpacing.paddingAll20)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                Text(
                  '이직 사유')
                  style: theme.textTheme.titleMedium)
                ))
                SizedBox(height: AppSpacing.spacing3))
                Wrap(
                  spacing: 8)
                  runSpacing: 8)
                  children: _changeReasons.map((reason) {
                    final isSelected = _changeReason == reason;
                    return ChoiceChip(
                      label: Text(reason))
                      selected: isSelected)
                      onSelected: (selected) {
                        setState(() {
                          _changeReason = selected ? reason : null;
                        });
                      },
                    );
                  }).toList())
                ),
              ])
            ),
          ))
          SizedBox(height: AppSpacing.spacing4))
          
          // Career Years
          GlassCard(
            padding: AppSpacing.paddingAll20)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                Text(
                  '경력 기간')
                  style: theme.textTheme.titleMedium)
                ))
                SizedBox(height: AppSpacing.spacing3))
                ...(_careerYearOptions.map((years) {
                  final isSelected = _careerYears == years;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _careerYears = years;
                      });
                    },
                    borderRadius: AppDimensions.borderRadiusMedium)
                    child: Container(
                      padding: AppSpacing.paddingAll16)
                      margin: const EdgeInsets.only(bottom: AppSpacing.xSmall))
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface.withValues(alpha: 0.3))
                        borderRadius: AppDimensions.borderRadiusMedium)
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.2))
                        ))
                      ))
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked)
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5))
                          ))
                          SizedBox(width: AppSpacing.spacing3))
                          Text(
                            years)
                            style: theme.textTheme.bodyLarge)
                          ))
                        ])
                      ),
                    ))
                  );
                })))
              ],
            ))
          ))
          SizedBox(height: AppSpacing.spacing4))
          
          // Preparation Level
          GlassCard(
            padding: AppSpacing.paddingAll20)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                Text(
                  '준비 상태')
                  style: theme.textTheme.titleMedium)
                ))
                SizedBox(height: AppSpacing.spacing3))
                Wrap(
                  spacing: 8)
                  runSpacing: 8)
                  children: _preparationLevels.map((level) {
                    final isSelected = _preparationLevel == level;
                    return ChoiceChip(
                      label: Text(level))
                      selected: isSelected)
                      onSelected: (selected) {
                        setState(() {
                          _preparationLevel = selected ? level : null;
                        });
                      },
                    );
                  }).toList())
                ),
              ])
            ),
          ))
          SizedBox(height: AppSpacing.spacing8))
        ])
      )
    );
  }
}