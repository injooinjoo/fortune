import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/blood_type_compatibility_matrix.dart';
import '../widgets/blood_type_personality_chart.dart';

class BloodTypeFortunePage extends BaseFortunePage {
  const BloodTypeFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '혈액형 운세',
          description: '혈액형별 성격과 오늘의 운세를 확인해보세요',
          fortuneType: 'blood-type',
          requiresUserInfo: false,
          initialParams: initialParams
        );

  @override
  ConsumerState<BloodTypeFortunePage> createState() => _BloodTypeFortunePageState();
}

class _BloodTypeFortunePageState extends BaseFortunePageState<BloodTypeFortunePage> {
  String? _selectedBloodType;
  String? _selectedRhType = '+';
  String? _selectedType1;
  String? _selectedRh1;
  String? _selectedType2;
  String? _selectedRh2;

  final Map<String, Map<String, dynamic>> _bloodTypeInfo = {
    'A': {
      'title': 'A형',
      'personality': '신중하고 꼼꼼한 성격',
      'icon': Icons.water_drop,
      'color': null,
    },
    'B': {
      'title': 'B형',
      'personality': '자유롭고 창의적인 성격',
      'icon': Icons.explore,
      'color': null,
    },
    'O': {
      'title': 'O형',
      'personality': '열정적이고 리더십이 강한 성격',
      'icon': Icons.local_fire_department,
      'color': null,
    },
    'AB': {
      'title': 'AB형',
      'personality': '이성적이고 독특한 성격',
      'icon': Icons.psychology,
      'color': null,
    },
  };

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_selectedBloodType == null) {
      return null;
    }

    return {
      'bloodType': _selectedBloodType,
      'rhType': _selectedRhType == '-' ? 'negative' : 'positive',
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '혈액형 선택',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _bloodTypeInfo.entries.map((entry) {
                  final isSelected = _selectedBloodType == entry.key;
                  final info = entry.value;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedBloodType = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(16),
                      blur: 10,
                      borderColor: isSelected
                          ? (info['color'] as Color).withValues(alpha: 0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            info['icon'],
                            size: 32,
                            color: isSelected
                                ? info['color'],
    Color
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            info['title'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? info['color'],
    Color
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info['personality'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RH 타입 (선택사항)',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRhOption('+': 'RH+',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRhOption('-': 'RH-',
                  ),
                ],
              ),
            ],
          ),
        ),
      ]
    );
  }

  Widget _buildRhOption(String value, String label) {
    final isSelected = _selectedRhType == value;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRhType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: BorderRadius.circular(12),
        blur: 10,
        borderColor: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.5)
            : Colors.transparent,
        borderWidth: isSelected ? 2 : 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected);
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildFortuneResult() {
    // Add blood type specific sections to the base result
    return Column(
      children: [
        _buildBloodTypeHeader(),
        super.buildFortuneResult(),
        _buildEnhancedPersonalityAnalysis(),
        _buildEnhancedCompatibilitySection(),
        _buildBloodTypeTips(),
      ]
    );
  }

  Widget _buildBloodTypeHeader() {
    if (_selectedBloodType == null) return const SizedBox.shrink();
    
    final info = _bloodTypeInfo[_selectedBloodType!]!;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (info['color'],
                border: Border.all(
                  color: (info['color'],
                  width: 3,
                ),
              ),
              child: Icon(
                info['icon'],
                size: 40,
                color: info['color'],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${info['title']}${_selectedRhType == '-' ? ' RH-' : ''} 운세',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: info['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              info['personality'],
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPersonalityAnalysis() {
    if (_selectedBloodType == null || _selectedRhType == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BloodTypePersonalityChart(
        bloodType: _selectedBloodType!,
        rhType: _selectedRhType!,
        showAnimation: true,
      ),
    );
  }

  Widget _buildEnhancedCompatibilitySection() {
    if (_selectedBloodType == null || _selectedRhType == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BloodTypeCompatibilityMatrix(
        selectedType1: _selectedType1 ?? _selectedBloodType,
        selectedRh1: _selectedRh1 ?? _selectedRhType,
        selectedType2: _selectedType2,
        selectedRh2: _selectedRh2,
        onPairSelected: (type1, rh1, type2, rh2) {
          setState(() {
            _selectedType1 = type1;
            _selectedRh1 = rh1;
            _selectedType2 = type2;
            _selectedRh2 = rh2;
          });
        },
        showAnimation: true,
      ),
    );
  }

  Widget _buildBloodTypeTips() {
    final tips = {
      'A': [
        '오늘은 계획적으로 일을 진행하면 좋은 결과가 있을 것입니다',
        '주변 사람들과의 소통에 더 신경 쓰세요',
        '완벽을 추구하기보다는 80%의 만족도를 목표로 하세요',
      ],
      'B': [
        '창의적인 아이디어가 샘솟는 날입니다',
        '새로운 도전을 시작하기에 좋은 시기입니다',
        '자유로운 시간을 가지며 에너지를 충전하세요',
      ],
      'O': [
        '리더십을 발휘할 수 있는 기회가 찾아옵니다',
        '목표를 향해 적극적으로 나아가세요',
        '팀워크를 중시하면 더 큰 성과를 얻을 수 있습니다',
      ],
      'AB': [
        '직관을 믿고 결정을 내리세요',
        '예술적 활동으로 스트레스를 해소하면 좋습니다',
        '균형잡힌 시각으로 문제를 해결할 수 있습니다',
      ],
    };

    if (_selectedBloodType == null) return const SizedBox.shrink();
    
    final bloodTypeTips = tips[_selectedBloodType!] ?? [];
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 조언',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...bloodTypeTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}