import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum FamilyType {
  children('자녀 운세', 'children', '우리 아이의 운세와 성장', Icons.child_care_rounded, [Color(0xFFFBBF24), Color(0xFFF59E0B)]),
  parenting('육아 운세', 'parenting', '오늘의 육아 조언', Icons.family_restroom_rounded, [Color(0xFF10B981), Color(0xFF059669)]),
  pregnancy('태교 운세', 'pregnancy', '예비 엄마를 위한 태교 가이드', Icons.pregnant_woman_rounded, [Color(0xFFEC4899), Color(0xFFDB2777)]),
  harmony('가족 화합', 'family-harmony', '가족 간의 조화와 행복', Icons.home_rounded, [Color(0xFF6366F1), Color(0xFF4F46E5)]);
  
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPremium;
  
  const FamilyType(this.label, this.value, this.description, this.icon, this.gradientColors, [this.isPremium = false]);
}

class FamilyFortuneUnifiedPage extends BaseFortunePage {
  const FamilyFortuneUnifiedPage({
    Key? key,
  }) : super(
          key: key,
          title: '가족 운세',
          description: '자녀, 육아, 태교, 가족 화합 운세를 확인하세요',
          fortuneType: 'family',
          requiresUserInfo: true
        );

  @override
  ConsumerState<FamilyFortuneUnifiedPage> createState() => _FamilyFortuneUnifiedPageState();
}

class _FamilyFortuneUnifiedPageState extends BaseFortunePageState<FamilyFortuneUnifiedPage> {
  FamilyType _selectedType = FamilyType.children;
  final Map<FamilyType, Fortune?> _fortuneCache = {};
  
  // Family member information
  final List<Map<String, dynamic>> _familyMembers = [];

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add family-specific parameters
    params['familyType'] = _selectedType.value;
    if (_familyMembers.isNotEmpty) {
      params['familyMembers'] = _familyMembers;
    }
    
    // Use generic fortune method with family type
    final fortune = await fortuneService.getFortune(
      userId: params['userId'],
      fortuneType: _selectedType.value,
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
          _buildHeaderCard(,
              .animate(,
              .fadeIn(duration: 600.ms,
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          
          // Type Grid
          Text(
            '운세 유형 선택',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTypeGrid(),
          const SizedBox(height: 24),
          
          // Family Members Input (for children and harmony types,
          if (_selectedType == FamilyType.children || _selectedType == FamilyType.harmony) ...[
            _buildFamilyMembersSection(),
            const SizedBox(height: 24),
          ],
          
          // Generate Button
          if (_fortuneCache[_selectedType] == null)
            _buildGenerateButton(),
          
          // Fortune Result
          if (_fortuneCache[_selectedType] != null) ...[
            _buildFortuneResult(_fortuneCache[_selectedType]!),
            const SizedBox(height: 16),
            _buildRefreshButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6).withValues(alpha: 0.1),
            Color(0xFF10B981).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF3B82F6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.family_restroom_rounded,
            size: 48,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          Text(
            '가족 운세',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '행복한 가정을 위한 오늘의 가족 운세를 확인하세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: FamilyType.values.length,
      itemBuilder: (context, index) {
        final type = FamilyType.values[index];
        return _buildTypeCard(type, index);
      }
    );
  }

  Widget _buildTypeCard(FamilyType type, int index) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? type.gradientColors
                : [Colors.grey[200]!, Colors.grey[300]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    size: 36,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      type.description,
                      style: TextStyle(
                        color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[500],
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (type.isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate(delay: (50 * index).ms,
      .fadeIn(duration: 300.ms,
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0);
  }

  Widget _buildFamilyMembersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '가족 구성원 (선택사항)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedType.gradientColors[0],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: _selectedType.gradientColors[0]),
                onPressed: _showAddFamilyMemberDialog,
              ),
            ],
          ),
          if (_familyMembers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  '가족 구성원을 추가하면 더 정확한 운세를 볼 수 있어요',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          else
            ..._familyMembers.map((member) => _buildFamilyMemberCard(member)).toList(),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _selectedType.gradientColors[0].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            member['relation'] == '자녀'),
            color: _selectedType.gradientColors[0],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'] ?? '이름 없음',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${member['relation']} · ${member['age']}세',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.red[400]),
            onPressed: () {
              setState(() {
                _familyMembers.remove(member);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddFamilyMemberDialog() {
    String name = '';
    String relation = '자녀';
    int age = 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가족 구성원 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '이름'),
              onChanged: (value) => name = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: relation,
              decoration: const InputDecoration(labelText: '관계': null,
              items: ['자녀': '배우자': '부모', '형제자매']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)),
                  .toList(),
              onChanged: (value) => relation = value ?? '자녀',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: '나이'),
              keyboardType: TextInputType.number,
              onChanged: (value) => age = int.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && age > 0) {
                setState(() {
                  _familyMembers.add({
                    'name': name,
                    'relation': relation,
                    'age': null,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onGenerateFortune,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _selectedType.gradientColors[0],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType.icon,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedType.label} 확인하기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _onGenerateFortune,
        icon: const Icon(Icons.refresh),
        label: const Text('다시 보기'),
        style: TextButton.styleFrom(
          foregroundColor: _selectedType.gradientColors[0],
        ),
      ),
    );
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
        'gender': null,
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
            _selectedType.gradientColors[0].withValues(alpha: 0.1),
            _selectedType.gradientColors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedType.gradientColors[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedType.icon,
                color: _selectedType.gradientColors[0],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_selectedType.label} 결과',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _selectedType.gradientColors[0],
                  ),
                ),
              ),
              if (fortune.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${fortune.score}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Main message
          Text(
            fortune.message,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.textColor,
            ),
          ),
          
          // Parenting tips
          if ((_selectedType == FamilyType.parenting || _selectedType == FamilyType.children) && 
              fortune.additionalInfo?['parentingTips'] != null) ...[
            const SizedBox(height: 20),
            _buildParentingTips(List<String>.from(fortune.additionalInfo!['parentingTips'],
          ],
          
          // Pregnancy tips
          if (_selectedType == FamilyType.pregnancy && fortune.additionalInfo?['pregnancyTips'] != null) ...[
            const SizedBox(height: 20),
            _buildPregnancyTips(List<String>.from(fortune.additionalInfo!['pregnancyTips'],
          ],
          
          // Family harmony tips
          if (_selectedType == FamilyType.harmony && fortune.additionalInfo?['harmonyTips'] != null) ...[
            const SizedBox(height: 20),
            _buildHarmonyTips(List<String>.from(fortune.additionalInfo!['harmonyTips'],
          ],
          
          // Advice
          if (fortune.advice != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fortune.advice!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(,
      .fadeIn(duration: 500.ms,
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildParentingTips(List<String> tips) {
    return _buildTipsSection('육아 팁': tips, Icons.child_care);
  }

  Widget _buildPregnancyTips(List<String> tips) {
    return _buildTipsSection('태교 가이드': tips, Icons.pregnant_woman);
  }

  Widget _buildHarmonyTips(List<String> tips) {
    return _buildTipsSection('화합 포인트': tips, Icons.favorite);
  }

  Widget _buildTipsSection(String title, List<String> tips, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0],
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedType.gradientColors[0].withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color: _selectedType.gradientColors[0],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
      ]
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}