import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'base_fortune_page.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/fortune.dart';

class PetCompatibilityPage extends BaseFortunePage {
  const PetCompatibilityPage({
    super.key,
    required super.fortuneType,
    required super.title,
    required super.description,
  });

  @override
  BaseFortunePageState<PetCompatibilityPage> createState() => _PetCompatibilityPageState();
}

class _PetCompatibilityPageState extends BaseFortunePageState<PetCompatibilityPage> {
  // 주인 정보
  String? _ownerName;
  DateTime? _ownerBirthDate;
  String? _ownerZodiacAnimal;

  // 반려동물 정보
  String _petType = 'dog';
  String? _petName;
  String? _petBreed;
  int? _petAge;
  String? _petPersonality;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    try {
      final compatibilityData = _buildAdditionalData();
      params.addAll(compatibilityData);
      
      // Use actual API call
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        userId: user.id,
        params: params,
      );
      
      return fortune;
    } catch (e) {
      Logger.error('반려동물 궁합 생성 실패', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    return _buildAdditionalData();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 궁합'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                if (userProfile == null)
                  _buildLoginPrompt(),
                _buildOwnerInfoForm(),
                _buildPetInfoForm(),
                const SizedBox(height: 16),
                buildFortuneResult(),
                _buildCompatibilityGuide(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(), // The base class handles the generate button
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.pets, size: 48),
          const SizedBox(height: 8),
          const Text(
            '로그인하고 반려동물과의 궁합을 확인해보세요!',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/onboarding'),
            child: const Text('로그인하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoForm() {
    return Card(
      margin: const EdgeInsets.all(16).copyWith(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '주인 정보',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '예: 김철수',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _ownerName = value.isEmpty ? null : value;
                });
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  locale: const Locale('ko', 'KR'),
                );
                if (date != null) {
                  setState(() {
                    _ownerBirthDate = date;
                    _ownerZodiacAnimal = _calculateZodiacAnimal(date.year);
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _ownerBirthDate != null
                          ? '${_ownerBirthDate!.year}년 ${_ownerBirthDate!.month}월 ${_ownerBirthDate!.day}일'
                          : '생년월일을 선택하세요',
                      style: TextStyle(
                        color: _ownerBirthDate != null 
                            ? null 
                            : Theme.of(context).hintColor,
                      ),
                    ),
                    if (_ownerZodiacAnimal != null)
                      Chip(
                        label: Text(_ownerZodiacAnimal!),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '반려동물 정보',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'dog',
                  label: Text('강아지'),
                  icon: Icon(Icons.pets),
                ),
                ButtonSegment(
                  value: 'cat',
                  label: Text('고양이'),
                  icon: Icon(Icons.pets),
                ),
                ButtonSegment(
                  value: 'other',
                  label: Text('기타'),
                  icon: Icon(Icons.more_horiz),
                ),
              ],
              selected: {_petType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _petType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '반려동물 이름',
                hintText: '예: 코코',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _petName = value.isEmpty ? null : value;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_petType != 'other') ...[
              TextFormField(
                decoration: InputDecoration(
                  labelText: _petType == 'dog' ? '견종' : '묘종',
                  hintText: _petType == 'dog' 
                      ? '예: 푸들, 말티즈' 
                      : '예: 코리안숏헤어, 페르시안',
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _petBreed = value.isEmpty ? null : value;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '나이',
                      hintText: '예: 3',
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(),
                      suffixText: '살',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _petAge = int.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '성격',
                      prefixIcon: Icon(Icons.mood),
                      border: OutlineInputBorder(),
                    ),
                    value: _petPersonality,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('활발함')),
                      DropdownMenuItem(value: 'calm', child: Text('차분함')),
                      DropdownMenuItem(value: 'timid', child: Text('소심함')),
                      DropdownMenuItem(value: 'friendly', child: Text('친화적')),
                      DropdownMenuItem(value: 'independent', child: Text('독립적')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _petPersonality = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityGuide() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '반려동물과의 유대감 높이기',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompatibilityTip(
            Icons.schedule,
            '일관된 루틴',
            '규칙적인 일과로 신뢰를 쌓아가세요',
          ),
          _buildCompatibilityTip(
            Icons.chat_bubble_outline,
            '소통의 시간',
            '매일 15분 이상 교감의 시간을 가지세요',
          ),
          _buildCompatibilityTip(
            Icons.sports_handball,
            '함께하는 놀이',
            '적극적인 놀이로 스트레스를 해소시켜주세요',
          ),
          _buildCompatibilityTip(
            Icons.school,
            '긍정적 훈련',
            '칭찬과 보상으로 올바른 행동을 강화하세요',
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityTip(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateZodiacAnimal(int year) {
    const zodiacAnimals = [
      '원숭이띠', '닭띠', '개띠', '돼지띠',
      '쥐띠', '소띠', '호랑이띠', '토끼띠',
      '용띠', '뱀띠', '말띠', '양띠'
    ];
    return zodiacAnimals[year % 12];
  }

  Map<String, dynamic> _buildAdditionalData() {
    final data = <String, dynamic>{};
    
    // 주인 정보
    if (_ownerName != null) data['owner_name'] = _ownerName;
    if (_ownerBirthDate != null) {
      data['owner_birth_date'] = _ownerBirthDate!.toIso8601String();
      data['owner_zodiac_animal'] = _ownerZodiacAnimal;
    }
    
    // 반려동물 정보
    data['pet_type'] = _petType;
    if (_petName != null) data['pet_name'] = _petName;
    if (_petBreed != null) data['pet_breed'] = _petBreed;
    if (_petAge != null) data['pet_age'] = _petAge;
    if (_petPersonality != null) data['pet_personality'] = _petPersonality;
    
    return data;
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('반려동물 궁합 안내'),
        content: const Text(
          '주인과 반려동물의 궁합을 분석합니다.\n\n'
          '• 주인 정보: 이름, 생년월일 (띠)\n'
          '• 반려동물 정보: 종류, 이름, 품종, 나이, 성격\n\n'
          '입력한 정보를 바탕으로 궁합 점수와 관계 발전을 위한 조언을 제공합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}