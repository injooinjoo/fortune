import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/toss_design_system.dart';

class SalpuliFortunePage extends BaseFortunePage {
  const SalpuliFortunePage({Key? key})
      : super(
          key: key,
    title: '살풀이 운세',
          description: '액운을 막고 행운을 부르는 전통 운세',
          fortuneType: 'salpuli',
          requiresUserInfo: true
        );

  @override
  ConsumerState<SalpuliFortunePage> createState() => _SalpuliFortunePageState();
}

class _SalpuliFortunePageState extends BaseFortunePageState<SalpuliFortunePage> {
  String? _recentBadLuck;
  String? _worryType;
  List<String> _selectedSymptoms = [];
  String? _birthTime;
  bool _hasAncestralRites = false;
  bool _hasMovedRecently = false;
  String? _healthStatus;

  final List<String> _badLuckTypes = [
    '사업 실패', '건강 악화',
    '인간관계 문제', '금전적 손실',
    '가족 불화', '직장 문제',
    '학업 부진', '연애 실패',
    '사고/재난', '기타'
  ];

  final Map<String, String> _worryTypes = {
    'health': '건강 걱정', 'money': '금전 걱정', 'relationship': '인간관계 걱정', 'career': '진로/직업 걱정', 'family': '가족 걱정', 'future': '미래 불안'
  };

  final List<String> _symptoms = [
    '악몽을 자주 꿈', '몸이 무거움',
    '집중력 저하', '불면증',
    '식욕 부진', '우울감',
    '불안감', '피로감',
    '두통', '소화불량'
  ];

  final Map<String, String> _birthTimes = {
    'ja': '자시 (23:00-01:00)', 'chuk': '축시 (01:00-03:00)', 'in': '인시 (03:00-05:00)', 'myo': '묘시 (05:00-07:00)', 'jin': '진시 (07:00-09:00)', 'sa': '사시 (09:00-11:00)', 'o': '오시 (11:00-13:00)', 'mi': '미시 (13:00-15:00)', 'sin': '신시 (15:00-17:00)', 'yu': '유시 (17:00-19:00)', 'sul': '술시 (19:00-21:00)', 'hae': '해시 (21:00-23:00)'
  };

  // User info form state
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _mbti;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_nameController.text.isEmpty || _birthDate == null || _gender == null) {
      Toast.warning(context, '기본 정보를 입력해주세요.');
      return null;
    }

    return {
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'gender': _gender,
      'mbti': _mbti
    };
  }

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
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    if (_recentBadLuck == null || _worryType == null || 
        _selectedSymptoms.isEmpty || _birthTime == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'recentBadLuck': _recentBadLuck,
      'worryType': _worryType,
      'symptoms': _selectedSymptoms,
      'birthTime': _birthTime,
      'hasAncestralRites': _hasAncestralRites,
      'hasMovedRecently': _hasMovedRecently,
      'healthStatus': _healthStatus
    };
  }

  Widget buildUserInfoForm() {
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [TossDesignSystem.white.withValues(alpha: 0.1), TossDesignSystem.white.withValues(alpha: 0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Birth Date Picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _birthDate = date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _birthDate != null
                    ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                    : '생년월일을 선택하세요',
                style: TextStyle(
                  color: _birthDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '성별',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // User Info Form
        buildUserInfoForm(),
        const SizedBox(height: 16),
        
        // Recent Bad Luck
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '최근 겪은 액운',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '어떤 일로 고민하고 계신가요?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _badLuckTypes.map((type) {
                  final isSelected = _recentBadLuck == type;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _recentBadLuck = type;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(type),
                      backgroundColor: isSelected
                          ? theme.colorScheme.error.withValues(alpha: 0.2)
                          : theme.colorScheme.surface.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.error
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
        
        // Main Worry Type
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '주요 걱정사',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...(_worryTypes.entries.map((entry) {
                final isSelected = _worryType == entry.key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _worryType = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16
                      ),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : TossDesignSystem.white.withValues(alpha: 0.0),
                      borderWidth: isSelected ? 2 : 0,
    child: Row(
                        children: [
                          Radio<String>(
                            value: entry.key,
                            groupValue: _worryType,
                            onChanged: (value) {
                              setState(() {
                                _worryType = value;
                              });
                            },
                          ),
                          Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Symptoms
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 증상',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '해당되는 증상을 모두 선택하세요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                )),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSymptoms.remove(symptom);
                        } else {
                          _selectedSymptoms.add(symptom);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(symptom),
                      backgroundColor: isSelected
                          ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                          : theme.colorScheme.surface.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      ),
                      deleteIcon: isSelected
                          ? const Icon(Icons.check_circle, size: 18)
                          : null,
                      onDeleted: isSelected ? () {} : null
                    )
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Birth Time
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '태어난 시간',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _birthTime,
                decoration: InputDecoration(
                  hintText: '태어난 시간을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withValues(alpha: 0.5)
                ),
                items: _birthTimes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value)
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _birthTime = value;
                  });
                }
              )
            ]
          )
        ),
        const SizedBox(height: 16),
        
        // Additional Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSwitchTile(
                '최근 제사나 차례를 지내셨나요?',
                _hasAncestralRites,
                (value) => setState(() => _hasAncestralRites = value),
                Icons.temple_buddhist_rounded
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                '최근 이사를 하셨나요?',
                _hasMovedRecently,
                (value) => setState(() => _hasMovedRecently = value),
                Icons.home_rounded
              )
            ]
          )
        )
      ]
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge
          )
        ),
        Switch(
          value: value,
          onChanged: onChanged
        )
      ]
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildSalpuliAnalysis(),
        _buildEvilSpiritDiagnosis(),
        _buildPurificationRitual(),
        _buildProtectionCharms(),
        _buildLifeGuidance()
      ]
    );
  }

  Widget _buildSalpuliAnalysis() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  color: theme.colorScheme.primary
                ),
                const SizedBox(width: 8),
                Text(
                  '살풀이 진단',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TossDesignSystem.errorRed.withValues(alpha: 0.1),
                    TossDesignSystem.warningOrange.withValues(alpha: 0.1)
                  ]
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.errorRed.withValues(alpha: 0.3)
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: TossDesignSystem.warningOrange,
                        size: 20
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '현재 상태',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '중간 정도의 액운이 감지됩니다. 조상의 도움이 필요한 시기이며, 정화 의식을 통해 나쁜 기운을 제거할 수 있습니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8)
                    )
                  )
                ]
              )
            ),
            const SizedBox(height: 16),
            _buildSeverityMeter()
          ]
        )
      )
    );
  }

  Widget _buildSeverityMeter() {
    final theme = Theme.of(context);
    final severity = 65; // Example severity percentage
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '액운 강도',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold
              )
            ),
            Text(
              '$severity%',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getSeverityColor(severity)
              )
            )
          ]
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: severity / 100,
            minHeight: 12,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getSeverityColor(severity)
            )
          )
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('약함', style: theme.textTheme.bodySmall),
            Text('보통', style: theme.textTheme.bodySmall),
            Text('강함', style: theme.textTheme.bodySmall)
          ]
        )
      ]
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 70) return TossDesignSystem.errorRed;
    if (severity >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.warningOrange;
  }

  Widget _buildEvilSpiritDiagnosis() {
    final theme = Theme.of(context);
    
    final spirits = [
      {
        'name': '역마살',
        'level': 3,
        'description': '이동과 변화의 기운. 안정이 필요합니다.',
        'color': TossDesignSystem.warningOrange
      },
      {
        'name': '백호살',
        'level': 2,
        'description': '건강 주의. 몸조리가 필요한 시기입니다.',
        'color': TossDesignSystem.warningOrange
      },
      {
        'name': '도화살',
        'level': 1,
        'description': '이성 문제 주의. 신중한 판단이 필요합니다.',
        'color': TossDesignSystem.pinkPrimary
      },
      {
        'name': '천을귀인',
        'level': -2,
        'description': '귀인의 도움. 좋은 인연이 다가옵니다.',
        'color': TossDesignSystem.successGreen
      }
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: theme.colorScheme.primary
                ),
                const SizedBox(width: 8),
                Text(
                  '살 분석',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...spirits.map((spirit) {
              final level = spirit['level'] as int;
              final isPositive = level < 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (spirit['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: spirit['color'] as Color
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPositive ? Icons.star_rounded : Icons.warning_amber_rounded,
                            size: 16,
                            color: spirit['color'] as Color
                          ),
                          const SizedBox(width: 8),
                          Text(
                            spirit['name'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const Spacer(),
                          ...List.generate(
                            level.abs(),
                            (index) => Icon(
                              isPositive ? Icons.star : Icons.circle,
                              size: 12,
                              color: spirit['color'] as Color
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spirit['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                        )
                      )
                    ]
                  )
                )
              );
            }).toList()
          ]
        )
      )
    );
  }

  Widget _buildPurificationRitual() {
    final theme = Theme.of(context);
    
    final rituals = [
      {
        'title': '소금 정화법',
        'description': '굵은 소금을 집 네 모퉁이에 놓고 3일 후 버리세요.',
        'icon': Icons.grain,
        'difficulty': '쉬움'
      },
      {
        'title': '향 피우기',
        'description': '백단향이나 침향을 매일 아침 피워 나쁜 기운을 정화하세요.',
        'icon': Icons.smoke_free,
        'difficulty': '쉬움'
      },
      {
        'title': '청소와 환기',
        'description': '집안을 깨끗이 청소하고 창문을 열어 환기시키세요.',
        'icon': Icons.cleaning_services,
        'difficulty': '쉬움'
      },
      {
        'title': '명상과 기도',
        'description': '매일 10분씩 명상하며 긍정적인 에너지를 모으세요.',
        'icon': Icons.self_improvement,
        'difficulty': '보통'
      }
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.spa_rounded,
                  color: theme.colorScheme.primary
                ),
                const SizedBox(width: 8),
                Text(
                  '정화 의식',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...rituals.map((ritual) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                      theme.colorScheme.secondary.withValues(alpha: 0.05)
                    ]
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2)
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Icon(
                            ritual['icon'] as IconData,
                            size: 20,
                            color: theme.colorScheme.primary
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ritual['title'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold
                            )
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4
                          ),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.successGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Text(
                            ritual['difficulty'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: TossDesignSystem.successGreen
                            )
                          )
                        )
                      ]
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ritual['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8)
                      )
                    )
                  ]
                )
              )
            )).toList()
          ]
        )
      )
    );
  }

  Widget _buildProtectionCharms() {
    final theme = Theme.of(context);
    
    final charms = [
      {
        'name': '오방색 실',
        'purpose': '전체적인 보호',
        'usage': '손목이나 발목에 착용',
        'color': TossDesignSystem.purple
      },
      {
        'name': '호신 부적',
        'purpose': '액운 차단',
        'usage': '지갑이나 주머니에 소지',
        'color': TossDesignSystem.errorRed
      },
      {
        'name': '수정 팔찌',
        'purpose': '에너지 정화',
        'usage': '왼손에 착용',
        'color': TossDesignSystem.tossBlue
      },
      {
        'name': '복주머니',
        'purpose': '복을 부르는 아이템',
        'usage': '집안 현관에 걸기',
        'color': TossDesignSystem.successGreen
      }
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: theme.colorScheme.primary
                ),
                const SizedBox(width: 8),
                Text(
                  '보호 부적',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: charms.map((charm) {
                return GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  blur: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (charm['color'] as Color).withValues(alpha: 0.2),
                          border: Border.all(
                            color: charm['color'] as Color,
                            width: 2
                          )
                        ),
                        child: Center(
                          child: Text(
                            (charm['name'] as String)[0],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: charm['color'] as Color
                            )
                          )
                        )
                      ),
                      const SizedBox(height: 8),
                      Text(
                        charm['name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(
                        charm['purpose'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                        ),
                        textAlign: TextAlign.center
                      )
                    ]
                  )
                );
              }).toList()
            )
          ]
        )
      )
    );
  }

  Widget _buildLifeGuidance() {
    final theme = Theme.of(context);
    
    final guidances = [
      {
        'period': '향후 3개월',
        'advice': '조심스럽게 행동하고 새로운 시작은 피하세요. 기존 일에 집중하며 안정을 추구하는 것이 좋습니다.',
        'lucky': '붉은색, 동쪽 방향'
      },
      {
        'period': '3-6개월',
        'advice': '점차 운이 회복됩니다. 작은 것부터 시작하여 천천히 확장해 나가세요.',
        'lucky': '녹색, 남쪽 방향'
      },
      {
        'period': '6개월 이후',
        'advice': '완전히 회복되어 새로운 도전이 가능합니다. 그동안 준비한 것을 실행에 옮기세요.',
        'lucky': '금색, 서쪽 방향'
      }
    ];
    
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
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary
                ),
                const SizedBox(width: 8),
                Text(
                  '시기별 조언',
                  style: theme.textTheme.headlineSmall
                )
              ]
            ),
            const SizedBox(height: 16),
            ...guidances.map((guidance) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1)
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: theme.colorScheme.primary
                        ),
                        const SizedBox(width: 8),
                        Text(
                          guidance['period'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary
                          )
                        )
                      ]
                    ),
                    const SizedBox(height: 8),
                    Text(
                      guidance['advice'] as String,
                      style: theme.textTheme.bodyMedium
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 14,
                            color: theme.colorScheme.primary
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '행운: ${guidance['lucky']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary
                            )
                          )
                        ]
                      )
                    )
                  ]
                )
              )
            )).toList()
          ]
        )
      )
    );
  }
}