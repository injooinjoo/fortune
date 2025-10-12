import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';

class CareerFutureFortunePage extends BaseFortunePage {
  const CareerFutureFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '커리어 운세',
          description: '당신의 커리어 미래를 함께 그려봅시다',
          fortuneType: 'career-future',
          requiresUserInfo: false,
          initialParams: initialParams,
        );

  @override
  ConsumerState<CareerFutureFortunePage> createState() => _CareerFutureFortunePageState();
}

class _CareerFutureFortunePageState extends BaseFortunePageState<CareerFutureFortunePage> {
  final TextEditingController _currentRoleController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  String? _timeHorizon;
  String? _careerPath;
  final List<String> _selectedSkills = [];
  
  final List<String> _timeHorizons = [
    '1년 후', '3년 후',
    '5년 후', '10년 후',
  ];

  final List<String> _careerPaths = [
    '전문가 (기술 심화)', '관리자 (팀/조직 관리)',
    '창업가', '컨설턴트/프리랜서',
    '임원/경영진',
  ];

  final List<String> _skillOptions = [
    '리더십', '기술 전문성',
    '커뮤니케이션', '전략적 사고',
    '혁신/창의성', '데이터 분석',
    '네트워킹', '글로벌 역량',
  ];

  @override
  void dispose() {
    _currentRoleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = UnifiedFortuneService(Supabase.instance.client);

    // UnifiedFortuneService용 input_conditions 구성 (snake_case)
    final inputConditions = {
      'career_type': widget.fortuneType,
      'current_role': params['currentRole'],
      'goal': params['careerGoal'],
      'time_horizon': params['timeHorizon'],
      'career_path': params['careerPath'],
      'selected_skills': params['skills'],
    };

    final fortuneResult = await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      dataSource: FortuneDataSource.api,
      inputConditions: inputConditions,
    );

    return _convertToFortune(fortuneResult);
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_currentRoleController.text.isEmpty ||
        _timeHorizon == null ||
        _careerPath == null ||
        _selectedSkills.isEmpty) {
      return null;
    }

    return {
      'currentRole': _currentRoleController.text,
      'careerGoal': _goalController.text,
      'timeHorizon': _timeHorizon,
      'careerPath': _careerPath,
      'skills': _selectedSkills
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
                      Icons.rocket_launch,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: TossDesignSystem.spacingS),
                    Text(
                      '커리어 미래 계획',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: TossDesignSystem.spacingM),
                
                // Current Role
                TextField(
                  controller: _currentRoleController,
                  decoration: InputDecoration(
                    labelText: '현재 직무/직책',
                    hintText: '예: 프로덕트 매니저, 시니어 개발자',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                  ),
                ),
                SizedBox(height: TossDesignSystem.spacingM),
                
                // Career Goal (Optional)
                TextField(
                  controller: _goalController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '커리어 목표 (선택사항)',
                    hintText: '예: CTO, 스타트업 창업, 글로벌 기업 진출',
                    prefixIcon: const Icon(Icons.flag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingM),
          
          // Time Horizon
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예측 시점',
                  style: theme.textTheme.titleMedium),
                SizedBox(height: TossDesignSystem.spacingS),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeHorizons.map((time) {
                    final isSelected = _timeHorizon == time;
                    return ChoiceChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _timeHorizon = selected ? time : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingM),
          
          // Career Path
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '희망 커리어 경로',
                  style: theme.textTheme.titleMedium),
                SizedBox(height: TossDesignSystem.spacingS),
                ...(_careerPaths.map((path) {
                  final isSelected = _careerPath == path;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _careerPath = path;
                      });
                    },
                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
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
                          SizedBox(width: TossDesignSystem.spacingS),
                          Expanded(
                            child: Text(
                              path,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingM),
          
          // Skills to Develop
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: TossDesignSystem.warningOrange),
                    SizedBox(width: TossDesignSystem.spacingS),
                    Text(
                      '개발하고 싶은 역량 (2개 이상)',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: TossDesignSystem.spacingS),
                Text(
                  '최대 5개까지 선택 가능',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: TossDesignSystem.spacingS),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skillOptions.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected && _selectedSkills.length < 5) {
                            _selectedSkills.add(skill);
                          } else if (!selected) {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingXL),
        ],
      ),
    );
  }

  /// FortuneResult를 Fortune 엔티티로 변환
  Fortune _convertToFortune(FortuneResult fortuneResult) {
    return Fortune(
      id: fortuneResult.id ?? '',
      userId: ref.read(userProvider).value?.id ?? '',
      type: fortuneResult.type,
      content: fortuneResult.data['content'] as String? ?? '',
      createdAt: fortuneResult.createdAt ?? DateTime.now(),
      overallScore: fortuneResult.score,
      summary: fortuneResult.summary['message'] as String?,
      metadata: fortuneResult.data,
    );
  }
}