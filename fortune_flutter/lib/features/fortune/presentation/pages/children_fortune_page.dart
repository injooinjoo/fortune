import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'base_fortune_page.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/fortune.dart';

class ChildrenFortunePage extends BaseFortunePage {
  final String? specificFortuneType;

  const ChildrenFortunePage({
    super.key,
    required super.fortuneType,
    required super.title,
    required super.description,
    this.specificFortuneType,
  });

  @override
  BaseFortunePageState<ChildrenFortunePage> createState() => _ChildrenFortunePageState();
}

class _ChildrenFortunePageState extends BaseFortunePageState<ChildrenFortunePage> {
  String _selectedFortuneType = 'children';
  String? _childName;
  DateTime? _childBirthDate;
  String? _childGender;
  String? _parentRelation;
  int? _numberOfChildren;

  @override
  void initState() {
    super.initState();
    _selectedFortuneType = widget.specificFortuneType ?? widget.fortuneType;
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    try {
      final childInfo = _buildAdditionalData();
      params.addAll(childInfo);
      params['fortune_type'] = _selectedFortuneType;
      
      // Use actual API call
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        userId: user.id,
        params: params,
      );
      
      return fortune;
    } catch (e) {
      Logger.error('자녀/육아 운세 생성 실패', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final params = _buildAdditionalData();
    params['fortune_type'] = _selectedFortuneType;
    return params;
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
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
                _buildChildrenInfoForm(),
                const SizedBox(height: 16),
                buildFortuneResult(),
                _buildParentingTips(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildGenerateButton(),
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
          const Icon(Icons.child_care, size: 48),
          const SizedBox(height: 8),
          const Text(
            '로그인하고 자녀와 가족을 위한 특별한 운세를 확인해보세요!',
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

  Widget _buildChildrenInfoForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedFortuneType == 'pregnancy' ? '예비 부모 정보' : '자녀 정보',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_selectedFortuneType != 'pregnancy') ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '자녀 이름',
                  hintText: '예: 수민, 지우',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _childName = value.isEmpty ? null : value;
                  });
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    locale: const Locale('ko', 'KR'),
                  );
                  if (date != null) {
                    setState(() {
                      _childBirthDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '자녀 생년월일',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _childBirthDate != null
                        ? '${_childBirthDate!.year}년 ${_childBirthDate!.month}월 ${_childBirthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: TextStyle(
                      color: _childBirthDate != null 
                          ? null 
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'male',
                    label: Text('아들'),
                    icon: Icon(Icons.boy),
                  ),
                  ButtonSegment(
                    value: 'female',
                    label: Text('딸'),
                    icon: Icon(Icons.girl),
                  ),
                ],
                selected: _childGender != null ? {_childGender!} : {},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _childGender = newSelection.firstOrNull;
                  });
                },
              ),
            ] else ...[
              // 태교 운세인 경우
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'mother',
                    label: Text('예비 엄마'),
                    icon: Icon(Icons.pregnant_woman),
                  ),
                  ButtonSegment(
                    value: 'father',
                    label: Text('예비 아빠'),
                    icon: Icon(Icons.man),
                  ),
                ],
                selected: _parentRelation != null ? {_parentRelation!} : {},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _parentRelation = newSelection.firstOrNull;
                  });
                },
              ),
            ],
            if (_selectedFortuneType == 'family-harmony') ...[
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '자녀 수',
                  hintText: '예: 2',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                  suffixText: '명',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _numberOfChildren = int.tryParse(value);
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _buildAdditionalData() {
    final data = <String, dynamic>{};
    
    if (_childName != null) data['child_name'] = _childName;
    if (_childBirthDate != null) {
      data['child_birth_date'] = _childBirthDate!.toIso8601String();
    }
    if (_childGender != null) data['child_gender'] = _childGender;
    if (_parentRelation != null) data['parent_relation'] = _parentRelation;
    if (_numberOfChildren != null) data['number_of_children'] = _numberOfChildren;
    
    return data;
  }

  String _getPageTitle() {
    switch (_selectedFortuneType) {
      case 'children':
        return '자녀 운세';
      case 'parenting':
        return '육아 운세';
      case 'pregnancy':
        return '태교 운세';
      case 'family-harmony':
        return '가족 화합 운세';
      default:
        return '자녀 운세';
    }
  }

  Widget _buildParentingTips() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _getParentingTipsTitle(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getParentingTips().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    tip,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _getParentingTipsTitle() {
    switch (_selectedFortuneType) {
      case 'pregnancy':
        return '태교 팁';
      case 'parenting':
        return '육아 팁';
      case 'family-harmony':
        return '가족 화합 팁';
      default:
        return '자녀 교육 팁';
    }
  }

  List<String> _getParentingTips() {
    switch (_selectedFortuneType) {
      case 'pregnancy':
        return [
          '규칙적인 산책으로 태아와 교감하세요',
          '클래식 음악이나 동화 읽기로 정서적 안정을 주세요',
          '스트레스를 피하고 긍정적인 생각을 유지하세요',
          '영양가 있는 음식으로 건강한 태교를 실천하세요',
        ];
      case 'parenting':
        return [
          '아이의 눈높이에서 대화하고 공감해주세요',
          '일관된 규칙과 사랑으로 안정감을 주세요',
          '놀이를 통해 창의성과 상상력을 키워주세요',
          '충분한 칭찬과 격려로 자존감을 높여주세요',
        ];
      case 'family-harmony':
        return [
          '가족 모두가 참여하는 정기적인 가족 시간을 가지세요',
          '서로의 의견을 존중하고 경청하는 분위기를 만드세요',
          '함께하는 취미 활동으로 유대감을 강화하세요',
          '감사 일기나 칭찬 릴레이로 긍정적인 가족 문화를 만드세요',
        ];
      default:
        return [
          '아이의 개성과 재능을 존중하고 지지해주세요',
          '실수를 성장의 기회로 삼을 수 있도록 격려하세요',
          '독서 습관을 길러 상상력과 어휘력을 키워주세요',
          '적절한 자율성을 부여해 책임감을 배우게 하세요',
        ];
    }
  }

  Widget _buildGenerateButton() {
    // isLoading is already available from BaseFortunePageState
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isLoading ? null : () async {
            await generateFortuneAction();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  '운세 보기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자녀/육아 운세 안내'),
        content: Text(
          _selectedFortuneType == 'pregnancy'
              ? '예비 부모님을 위한 태교 운세입니다.\n\n'
                '• 예비 엄마/아빠 선택\n'
                '• 태교 활동 추천\n'
                '• 정서적 안정을 위한 조언\n\n'
                '건강한 임신과 출산을 위한 맞춤형 가이드를 제공합니다.'
              : '자녀 정보를 입력하면 더 정확한 운세를 받을 수 있습니다.\n\n'
                '• 이름: 자녀의 이름\n'
                '• 생년월일: 자녀의 생일\n'
                '• 성별: 아들/딸\n\n'
                '입력한 정보를 바탕으로 맞춤형 육아 조언을 제공합니다.',
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