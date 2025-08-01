import 'package: flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'base_fortune_page.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/fortune.dart';

class PetFortunePage extends BaseFortunePage {
  final String? petType;

  const PetFortunePage({
    super.key,
    required super.fortuneType,
    required super.title,
    required super.description,
    this.petType)
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
        fortuneType: widget.fortuneType)
        userId: user.id)
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              _showHelpDialog(context);
            },
          )$1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                if (userProfile == null)
                  _buildLoginPrompt(),
                _buildPetInfoForm(),
                const SizedBox(height: 16),
                buildFortuneResult(),
                _buildPetCareTips()$1,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0)
            child: _buildGenerateButton(),
          )$1,
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.pets, size: 48),
          const SizedBox(height: 8),
          const Text(
            '로그인하고 반려동물과의 특별한 운세를 확인해보세요!')
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/onboarding'),
            child: const Text('로그인하기'),
          )$1,
      ),
    );
  }

  Widget _buildPetInfoForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Text(
              '반려동물 정보')
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_selectedPetType == 'general') ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'general')
                    label: Text('일반'),
                    icon: Icon(Icons.pets),
                  ),
                  ButtonSegment(
                    value: 'dog')
                    label: Text('강아지'),
                    icon: Icon(Icons.pets),
                  ),
                  ButtonSegment(
                    value: 'cat')
                    label: Text('고양이'),
                    icon: Icon(Icons.pets),
                  )$1,
                selected: {_selectedPetType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedPetType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16)$1,
            TextFormField(
              decoration: const InputDecoration(
                labelText: '반려동물 이름',
                hintText: '예: 코코, 루루')
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
            if (_selectedPetType != 'general') ...[
              TextFormField(
                decoration: InputDecoration(
                  labelText: _selectedPetType == 'dog' ? '견종' : '묘종'
                  hintText: _selectedPetType == 'dog' 
                      ? '예: 푸들, 말티즈, 믹스견' 
                      : '예: 코리안숏헤어, 러시안블루, 믹스묘')
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _petBreed = value.isEmpty ? null : value;
                  });
                },
              ),
              const SizedBox(height: 12)$1,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '나이')
                      hintText: '예: 3')
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
                )$1,
            )$1,
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
      case 'dog':
        return '반려견 운세';
      case 'cat':
        return '반려묘 운세';
      default:
        return '반려동물 운세';
    }
  }

  Widget _buildPetCareTips() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates)
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '반려동물 케어 팁')
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )$1,
          ),
          const SizedBox(height: 12),
          ..._getPetCareTips().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    tip)
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )$1,
            ),
          )).toList()$1,
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
          '사회성 훈련으로 다른 강아지들과 잘 어울리게 해주세요'$1;
      case 'cat':
        return [
          '고양이의 독립성을 존중하며 적당한 거리를 유지하세요',
          '캣타워나 스크래처로 본능적 행동을 충족시켜주세요',
          '깨끗한 화장실 환경을 항상 유지해주세요',
          '놀이를 통해 사냥 본능을 만족시켜주세요'$1;
      default: return [
          '반려동물의 특성에 맞는 환경을 제공해주세요',
          '정기적인 건강 검진으로 질병을 예방하세요',
          '충분한 애정과 관심으로 유대감을 형성하세요',
          '균형 잡힌 식단으로 건강을 지켜주세요'$1;
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )$1,
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
                  height: 24
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2)
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              : const Text(
                  '운세 보기',
                  style: TextStyle(
                    fontSize: 16)
                    fontWeight: FontWeight.bold)
                  ),
                ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context)
      builder: (context) => AlertDialog(
        title: const Text('반려동물 운세 안내'),
        content: const Text(
          '반려동물의 정보를 입력하면 더 정확한 운세를 받을 수 있습니다.\n\n'
          '• 이름: 반려동물의 이름\n'
          '• 품종: 강아지나 고양이의 품종\n'
          '• 나이: 반려동물의 나이\n\n'
          '입력한 정보를 바탕으로 맞춤형 운세를 제공합니다.')
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          )$1,
      ),
    );
  }
}