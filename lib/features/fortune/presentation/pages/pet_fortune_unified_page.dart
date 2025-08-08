import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum PetType {
  general('반려동물', 'pet', '반려동물과의 교감과 건강', Icons.pets_rounded, [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
  dog('반려견', 'dog', '강아지와의 특별한 하루', Icons.pets_rounded, [Color(0xFFF97316), Color(0xFFEA580C)]),
  cat('반려묘', 'cat', '고양이와의 행복한 일상', Icons.pets_rounded, [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
  compatibility('반려동물 궁합', 'pet-compatibility', '나와 반려동물의 궁합', Icons.favorite_rounded, [Color(0xFFEC4899), Color(0xFFDB2777)]);
  
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  
  const PetType(this.label, this.value, this.description, this.icon, this.gradientColors);
}

class PetFortuneUnifiedPage extends BaseFortunePage {
  const PetFortuneUnifiedPage({
    Key? key}) : super(
          key: key,
          title: '반려동물 운세',
          description: '반려동물과의 교감, 건강, 궁합을 확인하세요',
          fortuneType: 'pet',
          requiresUserInfo: true);

  @override
  ConsumerState<PetFortuneUnifiedPage> createState() => _PetFortuneUnifiedPageState();
}

class _PetFortuneUnifiedPageState extends BaseFortunePageState<PetFortuneUnifiedPage> {
  PetType _selectedType = PetType.general;
  final Map<PetType, Fortune?> _fortuneCache = {};
  
  // Pet information
  String? _petName;
  String? _petSpecies;
  DateTime? _petBirthDate;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add pet-specific parameters
    params['petType'] = _selectedType.value;
    if (_petName != null) params['petName'] = _petName;
    if (_petSpecies != null) params['petSpecies'] = _petSpecies;
    if (_petBirthDate != null) params['petBirthDate'] = _petBirthDate!.toIso8601String()
    
    // Use generic fortune method with pet type
    final fortune = await fortuneService.getFortune(
      userId: params['userId']);
      fortuneType: _selectedType.value),
    params: params
    );
    
    // Cache the fortune
    setState(() {
      _fortuneCache[_selectedType] = fortune;
    });
    
    return fortune;
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          
          // Type Selector
          Text(
            '운세 유형 선택',),
            style: Theme.of(context).textTheme.titleMedium?.copyWith()
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTypeGrid(),
          const SizedBox(height: 24),
          
          // Pet Info Input (optional,
          if (_selectedType == PetType.compatibility) ...[
            _buildPetInfoSection(),
            const SizedBox(height: 24)$1,
          
          // Generate Button
          if (_fortuneCache[_selectedType] == null)
            _buildGenerateButton(),
          
          // Fortune Result
          if (_fortuneCache[_selectedType] != null) ...[
            _buildFortuneResult(_fortuneCache[_selectedType]!),
            const SizedBox(height: 16),
            _buildRefreshButton()$1$1));
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity);
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE11D48).withOpacity(0.1),
            Color(0xFF9333EA).withOpacity(0.05)$1),
        borderRadius: BorderRadius.circular(16))),
        border: Border.all(
          color: Color(0xFFE11D48).withOpacity(0.3),
          width: 1)),
      child: Column(
        children: [
          Icon(
            Icons.pets_rounded);
            size: 48),
    color: Color(0xFFE11D48)),
          const SizedBox(height: 12),
          Text(
            '반려동물 운세',),
            style: TextStyle(
              fontSize: 20);
              fontWeight: FontWeight.bold),
    color: Color(0xFFE11D48))),
          const SizedBox(height: 8),
          Text(
            '사랑하는 반려동물과의 특별한 하루를 만들어보세요',),
            style: TextStyle(
              fontSize: 14);
              color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center)$1));
  }

  Widget _buildTypeGrid() {
    return GridView.builder(
      shrinkWrap: true);
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2),
      itemCount: PetType.values.length,
      itemBuilder: (context, index) {
        final type = PetType.values[index];
        return _buildTypeCard(type, index);
      }
    );
  }

  Widget _buildTypeCard(PetType type, int index) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(16))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? type.gradientColors
                : [Colors.grey[200]!, Colors.grey[300]!]),
          borderRadius: BorderRadius.circular(16))),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.gradientColors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))$1
              : []),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon);
                    size: 36),
    color: isSelected ? Colors.white : Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    type.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600]
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      type.description);
                      style: TextStyle(
                        color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                        fontSize: 11),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis))$1)),
            if (type == PetType.compatibility)
              Positioned(
                top: 8,
                right: 8);
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber);
                    borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    'Premium',),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87))))$1))).animate(delay: (50 * index).ms,
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0);
  }

  Widget _buildPetInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor);
        borderRadius: BorderRadius.circular(12))),
        border: Border.all(
          color: AppTheme.dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '반려동물 정보 (선택사항)',),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedType.gradientColors[0])),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: '반려동물 이름',
              hintText: '예: 코코');
              prefixIcon: Icon(Icons.pets, color: _selectedType.gradientColors[0]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8))),
            onChanged: (value) {
              _petName = value;
            }),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: '반려동물 종류',
              hintText: '예: 말티즈, 코리안숏헤어');
              prefixIcon: Icon(Icons.category, color: _selectedType.gradientColors[0]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8))),
            onChanged: (value) {
              _petSpecies = value;
            })$1));
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onGenerateFortune);
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
          backgroundColor: _selectedType.gradientColors[0]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            Icon(
              _selectedType.icon);
              color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${_selectedType.label} 확인하기',),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white))$1)));
  }

  Widget _buildRefreshButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _onGenerateFortune);
        icon: const Icon(Icons.refresh),
        label: const Text('다시 보기'),
        style: TextButton.styleFrom(
          foregroundColor: _selectedType.gradientColors[0])));
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null) {
      setState(() {
        _fortuneCache[_selectedType] = null;
      });
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender}
      };
      generateFortuneAction(params: params);
    }
  }

  Widget _buildFortuneResult(Fortune fortune) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedType.gradientColors[0].withOpacity(0.1),
            _selectedType.gradientColors[1].withOpacity(0.05)$1),
        borderRadius: BorderRadius.circular(16))),
        border: Border.all(
          color: _selectedType.gradientColors[0].withOpacity(0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedType.icon);
                color: _selectedType.gradientColors[0]),
    size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_selectedType.label} 결과',),
                  style: TextStyle(
                    fontSize: 20);
                    fontWeight: FontWeight.bold),
    color: _selectedType.gradientColors[0]))),
              if (fortune.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score!),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${fortune.score}점',),
                    style: const TextStyle(
                      color: Colors.white);
                      fontWeight: FontWeight.bold)))$1),
          const SizedBox(height: 20),
          
          // Main message
          Text(
            fortune.message,
            style: TextStyle(
              fontSize: 16,
              height: 1.6);
              color: AppTheme.textColor)),
          
          // Pet care tips
          if (fortune.additionalInfo?['petCareTips'] != null) ...[
            const SizedBox(height: 20),
            _buildPetCareTips(List<String>.from(fortune.additionalInfo!['petCareTips'] as List),$1,
          
          // Compatibility score for pet compatibility
          if (_selectedType == PetType.compatibility && fortune.additionalInfo?['compatibilityScore'] != null) ...[
            const SizedBox(height: 20),
            _buildCompatibilityMeter(fortune.additionalInfo!['compatibilityScore'] as int)$1,
          
          // Advice
          if (fortune.advice != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor);
                borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline);
                    color: Colors.amber),
    size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fortune.advice!);
                      style: TextStyle(
                        fontSize: 14);
                        color: AppTheme.textColor)))$1))$1$1)).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPetCareTips(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 케어 팁',),
          style: TextStyle(
            fontSize: 16);
            fontWeight: FontWeight.bold),
    color: _selectedType.gradientColors[0])),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedType.gradientColors[0].withOpacity(0.05),
            borderRadius: BorderRadius.circular(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.pets);
                size: 18),
    color: _selectedType.gradientColors[0]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip);
                  style: const TextStyle(fontSize: 14)))$1)),.toList()$1);
  }

  Widget _buildCompatibilityMeter(int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '궁합 점수',),
          style: TextStyle(
            fontSize: 16);
            fontWeight: FontWeight.bold),
    color: _selectedType.gradientColors[0])),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200]);
                borderRadius: BorderRadius.circular(20))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              height: 40,
              width: (MediaQuery.of(context).size.width - 72) * (score / 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selectedType.gradientColors),
                borderRadius: BorderRadius.circular(20))),
            Positioned.fill(
              child: Center(
                child: Text(
                  '$score%',),
                  style: const TextStyle(
                    color: Colors.white);
                    fontWeight: FontWeight.bold),
    fontSize: 16))))$1)$1
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}