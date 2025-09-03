import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'base_fortune_page.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../widgets/fortune_card.dart';
import '../widgets/fortune_button.dart';
import '../widgets/fortune_loading_skeleton.dart';
import '../widgets/pet_fortune_result_card.dart';

class PetFortunePage extends BaseFortunePage {
  final String? petType;

  const PetFortunePage({
    super.key,
    required super.fortuneType,
    required super.title,
    required super.description,
    this.petType,
  });

  @override
  BaseFortunePageState<PetFortunePage> createState() => _PetFortunePageState();
}

class _PetFortunePageState extends BaseFortunePageState<PetFortunePage> {
  String _selectedPetType = 'general';
  String? _petName;
  String? _petBreed;
  int? _petAge;
  String? _petPersonality;

  @override
  void initState() {
    super.initState();
    _selectedPetType = widget.petType ?? 'general';
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    try {
      final petInfo = _buildAdditionalData();
      params.addAll(petInfo);
      
      // Use actual API call
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        userId: user.id,
        params: params
      );
      
      return fortune;
    } catch (e) {
      Logger.error('반려동물 운세 생성 실패', e);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
        elevation: 0,
        title: Text(
          _getPageTitle(),
          style: TossDesignSystem.heading3.copyWith(
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
            ),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                if (userProfile == null)
                  _buildLoginPrompt(isDark),
                _buildPetInfoForm(isDark),
                const SizedBox(height: 16),
                if (isLoading)
                  const FortuneLoadingSkeleton(
                    itemCount: 3,
                    showHeader: true,
                    loadingMessage: '반려동물 운세를 분석하고 있어요...',
                  )
                else if (fortuneResult != null)
                  PetFortuneResultCard(
                    fortune: fortuneResult!,
                    petName: _petName ?? '반려동물',
                    petSpecies: _selectedPetType == 'dog' ? '강아지' : 
                               _selectedPetType == 'cat' ? '고양이' : '반려동물',
                    petAge: _petAge ?? 1,
                    onRetry: () => generateFortuneAction(),
                  ),
                if (!isLoading && fortuneResult == null)
                  _buildPetCareTips(isDark),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildGenerateButton(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(bool isDark) {
    return FortuneCard(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: 40,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '로그인하고 반려동물과의\n특별한 운세를 확인해보세요!',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FortuneButton(
            text: '로그인하기',
            onPressed: () => context.push('/onboarding'),
            type: FortuneButtonType.primary,
            width: double.infinity,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPetInfoForm(bool isDark) {
    return FortuneCard(
      title: '반려동물 정보',
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            if (_selectedPetType == 'general') ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'general',
                    label: Text('일반'),
                    icon: Icon(Icons.pets)),
                  ButtonSegment(
                    value: 'dog',
                    label: Text('강아지'),
                    icon: Icon(Icons.pets)),
                  ButtonSegment(
                    value: 'cat',
                    label: Text('고양이'),
                    icon: Icon(Icons.pets))],
                selected: {_selectedPetType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedPetType = newSelection.first;
                  });
                }),
              const SizedBox(height: 16)],
            TextFormField(
              decoration: const InputDecoration(
                labelText: '반려동물 이름',
                hintText: '예: 코코, 루루',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  _petName = value.isEmpty ? null : value;
                });
              }),
            const SizedBox(height: 12),
            if (_selectedPetType != 'general') ...[
              TextFormField(
                decoration: InputDecoration(
                  labelText: _selectedPetType == 'dog' ? '견종' : '묘종',
                  hintText: _selectedPetType == 'dog' 
                      ? '예: 푸들, 말티즈, 믹스견' 
                      : '예: 코리안숏헤어, 러시안블루, 믹스묘',
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {
                    _petBreed = value.isEmpty ? null : value;
                  });
                }),
              const SizedBox(height: 12)],
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '나이',
                      hintText: '예: 3',
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(),
                      suffixText: '살'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _petAge = int.tryParse(value);
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

  Map<String, dynamic> _buildAdditionalData() {
    final data = <String, dynamic>{};
    
    if (_petName != null) data['pet_name'] = _petName;
    if (_petBreed != null) data['pet_breed'] = _petBreed;
    if (_petAge != null) data['pet_age'] = _petAge;
    if (_petPersonality != null) data['pet_personality'] = _petPersonality;
    if (_selectedPetType != 'general') data['pet_type'] = _selectedPetType;
    
    return data;
  }

  String _getPageTitle() {
    switch (_selectedPetType) {
      case 'dog': return '반려견 운세';
      case 'cat': return '반려묘 운세';
      default:
        return '반려동물 운세';
    }
  }

  Widget _buildPetCareTips(bool isDark) {
    return FortuneCard(
      title: '💡 반려동물 케어 팁',
      margin: const EdgeInsets.all(20),
      backgroundColor: TossDesignSystem.tossBlue.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          ..._getPetCareTips().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    tip,
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<String> _getPetCareTips() {
    switch (_selectedPetType) {
      case 'dog':
        return [
          '매일 규칙적인 산책으로 건강을 유지해주세요',
          '충분한 놀이 시간으로 스트레스를 해소시켜주세요',
          '정기적인 그루밍으로 피부 건강을 체크하세요',
          '사회성 훈련으로 다른 강아지들과 잘 어울리게 해주세요',
        ];
      case 'cat': 
        return [
          '고양이의 독립성을 존중하며 적당한 거리를 유지하세요',
          '캣타워나 스크래처로 본능적 행동을 충족시켜주세요',
          '깨끗한 화장실 환경을 항상 유지해주세요',
          '놀이를 통해 사냥 본능을 만족시켜주세요',
        ];
      default: 
        return [
          '반려동물의 특성에 맞는 환경을 제공해주세요',
          '정기적인 건강 검진으로 질병을 예방하세요',
          '충분한 애정과 관심으로 유대감을 형성하세요',
          '균형 잡힌 식단으로 건강을 지켜주세요',
        ];
    }
  }

  Widget _buildGenerateButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: FortuneButton.analyze(
          onPressed: isLoading ? null : () async {
            await generateFortuneAction();
          },
          isLoading: isLoading,
          text: '반려동물 운세 보기',
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('반려동물 운세 안내'),
        content: const Text(
          '반려동물의 정보를 입력하면 더 정확한 운세를 받을 수 있습니다.\n\n'
          '• 이름: 반려동물의 이름\n'
          '• 품종: 강아지나 고양이의 품종\n'
          '• 나이: 반려동물의 나이\n\n'
          '입력한 정보를 바탕으로 맞춤형 운세를 제공합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인')
          )
        ]
      )
    );
  }
}