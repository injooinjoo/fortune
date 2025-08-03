import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum RelationshipType {
  love('연애운': 'love': '현재 연애 상황과 앞으로의 전망을 알아보세요',
  compatibility('궁합': 'compatibility', '상대방과의 궁합을 확인해보세요'))
  soulmate('소울메이트': 'soulmate': '운명의 짝을 찾아보세요'))
  marriage('결혼운': 'marriage': '결혼 시기와 결혼 생활을 알아보세요'))
  exLover('전애인': 'ex_lover': '전 애인과의 재회 가능성을 확인해보세요'))
  blindDate('소개팅': 'blind_date': '새로운 만남의 기회를 알아보세요'))
  chemistry('케미스트리': 'chemistry': '상대방과의 케미를 확인해보세요'))
  coupleMatch('커플매칭': 'couple_match': '이상적인 커플 유형을 알아보세요');

  final String label;
  final String value;
  final String description;
  const RelationshipType(this.label, this.value, this.description);
}

class RelationshipFortunePage extends BaseFortunePage {
  final RelationshipType initialType;
  
  const RelationshipFortunePage({
    Key? key,
    this.initialType = RelationshipType.love,
  }) : super(
          key: key,
          title: '연애 & 관계 운세')
          description: '사랑과 인연에 대한 운세를 확인해보세요')
          fortuneType: 'relationship')
          requiresUserInfo: true
        );

  @override
  ConsumerState<RelationshipFortunePage> createState() => _RelationshipFortunePageState();
}

class _RelationshipFortunePageState extends BaseFortunePageState<RelationshipFortunePage> {
  late RelationshipType _selectedType;
  final TextEditingController _partnerNameController = TextEditingController();
  DateTime? _partnerBirthDate;
  String? _partnerGender;
  String? _relationshipStatus;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add relationship-specific parameters
    params['relationshipType'] = _selectedType.value;
    params['relationshipStatus'] = _relationshipStatus;
    
    // Add partner info for compatibility types
    if (_requiresPartnerInfo()) {
      params['partnerName'] = _partnerNameController.text;
      params['partnerBirthDate'] = _partnerBirthDate?.toIso8601String();
      params['partnerGender'] = _partnerGender;
    }
    
    final fortune = await fortuneService.getRelationshipFortune(
      userId: params['userId'],
      fortuneType: _selectedType.value)
      params: params)
    );
    
    return fortune;
  }

  bool _requiresPartnerInfo() {
    return [
      RelationshipType.compatibility,
      RelationshipType.chemistry)
      RelationshipType.coupleMatch)
    ].contains(_selectedType);
  }

  bool _isSoulmateSearch() {
    return _selectedType == RelationshipType.soulmate;
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          // Type Selector
          Text(
            '운세 유형')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)
            ))
          ))
          const SizedBox(height: 16))
          Wrap(
            spacing: 8)
            runSpacing: 8)
            children: RelationshipType.values.map((type) {
              return ChoiceChip(
                label: Text(type.label))
                selected: _selectedType == type)
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  }
                },
                selectedColor: AppColors.primary)
                labelStyle: TextStyle(
                  color: _selectedType == type ? Colors.white : AppColors.textPrimary)
                  fontWeight: FontWeight.w500)
                )
              );
            }).toList())
          ),
          const SizedBox(height: 24))

          // Description
          Container(
            padding: const EdgeInsets.all(16))
            decoration: BoxDecoration(
              color: AppColors.surface)
              borderRadius: BorderRadius.circular(12))
              border: Border.all(color: AppColors.border))
            ))
            child: Row(
              children: [
                Icon(
                  Icons.info_outline)
                  color: AppColors.primary)
                  size: 20)
                ))
                const SizedBox(width: 12))
                Expanded(
                  child: Text(
                    _selectedType.description)
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary)
                    ))
                  ))
                ))
              ])
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0))
          const SizedBox(height: 24))

          // Relationship Status
          Text(
            '현재 상태')
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)
            ))
          ))
          const SizedBox(height: 16))
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'single')
                label: Text('싱글'))
                icon: Icon(Icons.person))
              ))
              ButtonSegment(
                value: 'dating')
                label: Text('연애중'))
                icon: Icon(Icons.favorite))
              ))
              ButtonSegment(
                value: 'married')
                label: Text('기혼'))
                icon: Icon(Icons.family_restroom))
              ))
            ])
            selected: _relationshipStatus != null ? {_relationshipStatus!} : {},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _relationshipStatus = newSelection.first;
              });
            },
          ))
          const SizedBox(height: 24))

          // Partner Info (if required) or Soulmate Search Info
          if (_requiresPartnerInfo() || _isSoulmateSearch()) ...[
            Text(
              _isSoulmateSearch() ? '소울메이트 찾기' : '상대방 정보')
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold)
              ))
            ))
            const SizedBox(height: 16))
            if (!_isSoulmateSearch()) ...[
              TextField(
                controller: _partnerNameController)
                decoration: InputDecoration(
                  labelText: '상대방 이름')
                  prefixIcon: const Icon(Icons.person_outline))
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))
                  ))
                ))
              ))
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface)
                  borderRadius: BorderRadius.circular(12))
                  border: Border.all(color: AppColors.border))
                ))
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start)
                  children: [
                    Row(
                      children: [
                        Icon(Icons.connect_without_contact, color: AppColors.primary))
                        const SizedBox(width: 8))
                        Text(
                          '소울메이트 찾기 안내')
                          style: TextStyle(
                            fontWeight: FontWeight.bold)
                            color: AppColors.primary)
                          ))
                        ))
                      ])
                    ),
                    const SizedBox(height: 8))
                    Text(
                      '당신의 생년월일과 성별 정보를 기반으로 운명의 짝을 찾아드립니다.')
                      style: TextStyle(color: AppColors.textSecondary))
                    ))
                  ])
                ),
              ))
            ])
            if (!_isSoulmateSearch()) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context)
                    initialDate: _partnerBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)))
                    firstDate: DateTime(1950))
                    lastDate: DateTime.now())
                  );
                  if (picked != null) {
                    setState(() {
                      _partnerBirthDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '상대방 생년월일')
                    prefixIcon: const Icon(Icons.calendar_today))
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))
                    ))
                  ))
                  child: Text(
                    _partnerBirthDate != null
                        ? '${_partnerBirthDate!.year}년 ${_partnerBirthDate!.month}월 ${_partnerBirthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: TextStyle(
                      color: _partnerBirthDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary)
                    ))
                  ))
                ))
              ))
              const SizedBox(height: 16))
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'))
                      value: 'male')
                      groupValue: _partnerGender)
                      onChanged: (value) {
                        setState(() {
                          _partnerGender = value;
                        });
                      },
                    ))
                  ))
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'))
                      value: 'female')
                      groupValue: _partnerGender)
                      onChanged: (value) {
                        setState(() {
                          _partnerGender = value;
                        });
                      },
                    ))
                  ))
                ])
              ),
            ])
            const SizedBox(height: 24),
          ])

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canGenerate() ? _onGenerateFortune : null)
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16))
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))
                ))
              ))
              child: const Text(
                '운세 보기')
                style: TextStyle(
                  fontSize: 16)
                  fontWeight: FontWeight.bold)
                ))
              ))
            ))
          ))
        ])
      ),
    );
  }

  bool _canGenerate() {
    if (_relationshipStatus == null) return false;
    
    if (_requiresPartnerInfo()) {
      return _partnerNameController.text.isNotEmpty &&
             _partnerBirthDate != null &&
             _partnerGender != null;
    }
    
    return true;
  }

  void _onGenerateFortune() {
    // Get user profile and generate fortune
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender)
      };
      onGenerateFortune(params);
    }
  }

  @override
  Widget buildFortuneResult(Fortune fortune) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20))
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft)
          end: Alignment.bottomRight)
          colors: [
            AppColors.primary.withValues(alpha: 0.1))
            AppColors.secondary.withValues(alpha: 0.1))
          ])
        ),
        borderRadius: BorderRadius.circular(16))
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3))
          width: 1)
        ))
      ))
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Row(
            children: [
              Icon(
                _getIconForType(_selectedType))
                color: AppColors.primary)
                size: 28)
              ))
              const SizedBox(width: 12))
              Expanded(
                child: Text(
                  '${_selectedType.label} 결과')
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)
                  ))
                ))
              ))
            ])
          ),
          const SizedBox(height: 20))
          Text(
            fortune.content)
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6)
            ))
          ))
          if (fortune.advice != null) ...[
            const SizedBox(height: 20))
            Container(
              padding: const EdgeInsets.all(12))
              decoration: BoxDecoration(
                color: AppColors.surface)
                borderRadius: BorderRadius.circular(8))
              ))
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start)
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates)
                        color: AppColors.secondary)
                        size: 20)
                      ))
                      const SizedBox(width: 8))
                      Text(
                        '조언')
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold)
                          color: AppColors.secondary)
                        ))
                      ))
                    ])
                  ),
                  const SizedBox(height: 8))
                  Text(
                    fortune.advice!)
                    style: Theme.of(context).textTheme.bodyMedium)
                  ))
                ])
              ),
            ))
          ])
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8)
              runSpacing: 8)
              children: fortune.luckyItems!.map((item) {
                return Chip(
                  label: Text(item))
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1))
                  labelStyle: TextStyle(
                    color: AppColors.primary)
                    fontWeight: FontWeight.w500)
                  )
                );
              }).toList())
            ),
          ])
        ],
      ))
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  IconData _getIconForType(RelationshipType type) {
    switch (type) {
      case RelationshipType.love:
        return Icons.favorite;
      case RelationshipType.compatibility:
        return Icons.people;
      case RelationshipType.soulmate:
        return Icons.connect_without_contact;
      case RelationshipType.marriage:
        return Icons.cake;
      case RelationshipType.exLover:
        return Icons.history;
      case RelationshipType.blindDate:
        return Icons.calendar_today;
      case RelationshipType.chemistry:
        return Icons.favorite_border;
      case RelationshipType.coupleMatch:
        return Icons.group;
    }
  }
}