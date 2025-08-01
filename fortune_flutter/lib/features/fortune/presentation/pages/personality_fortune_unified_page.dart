import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum PersonalityType {
  mbti('MBTI', 'mbti', 'MBTI 성격 기반 운세', Icons.psychology_rounded, [Color(0xFF6366F1), Color(0xFF3B82F6)]),
  bloodType('혈액형', 'blood-type', '혈액형별 성격과 운세', Icons.water_drop_rounded, [Color(0xFFDC2626), Color(0xFFEF4444)]);

  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  
  const PersonalityType(this.label, this.value, this.description, this.icon, this.gradientColors);
}

class PersonalityFortuneUnifiedPage extends BaseFortunePage {
  const PersonalityFortuneUnifiedPage({
    Key? key,
  }) : super(
          key: key,
          title: '성격 운세',
          description: 'MBTI와 혈액형으로 보는 성격 기반 운세',
          fortuneType: 'personality',
          requiresUserInfo: true
        );

  @override
  ConsumerState<PersonalityFortuneUnifiedPage> createState() => _PersonalityFortuneUnifiedPageState();
}

class _PersonalityFortuneUnifiedPageState extends BaseFortunePageState<PersonalityFortuneUnifiedPage> {
  PersonalityType _selectedType = PersonalityType.mbti;
  final Map<PersonalityType, Fortune?> _fortuneCache = {};
  
  // Personality information
  String? _mbtiType;
  String? _bloodType;

  // MBTI types
  final List<String> _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'
  ];

  // Blood types
  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add personality-specific parameters
    params['personalityType'] = _selectedType.value;
    if (_selectedType == PersonalityType.mbti && _mbtiType != null) {
      params['mbti'] = _mbtiType;
    } else if (_selectedType == PersonalityType.bloodType && _bloodType != null) {
      params['bloodType'] = _bloodType;
    }
    
    final fortune = await fortuneService.getPersonalityFortune(
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
          
          // Type Selector
          Text(
            '성격 유형 선택',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTypeSelector(),
          const SizedBox(height: 24),
          
          // Personality Type Selection
          _buildPersonalityTypeSelection(),
          const SizedBox(height: 24),
          
          // Generate Button
          if (_fortuneCache[_selectedType] == null && _canGenerateFortune())
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
            Color(0xFF6366F1).withValues(alpha: 0.1),
            Color(0xFFDC2626).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF6366F1).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology_rounded,
            size: 48,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          Text(
            '성격 운세',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '당신의 성격 유형에 맞는 맞춤형 운세를 확인하세요',
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

  Widget _buildTypeSelector() {
    return Row(
      children: PersonalityType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == PersonalityType.values.last ? 0 : 8,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? type.gradientColors
                        : [Colors.grey[200]!, Colors.grey[300]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: TextStyle(
                        color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[500],
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate(,
              .fadeIn(duration: 300.ms,
              .slideX(begin: type == PersonalityType.mbti ? -0.2 : 0.2, end: 0),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalityTypeSelection() {
    if (_selectedType == PersonalityType.mbti) {
      return _buildMBTISelection();
    } else {
      return _buildBloodTypeSelection();
    }
  }

  Widget _buildMBTISelection() {
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
          Text(
            'MBTI 유형 선택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedType.gradientColors[0],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: _mbtiTypes.length,
            itemBuilder: (context, index) {
              final mbti = _mbtiTypes[index];
              final isSelected = _mbtiType == mbti;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _mbtiType = mbti;
                    _fortuneCache[_selectedType] = null;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedType.gradientColors[0]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      mbti,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedType.gradientColors[0].withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: _selectedType.gradientColors[0],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MBTI를 모르시나요? 무료 성격유형 검사를 해보세요!',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeSelection() {
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
          Text(
            '혈액형 선택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedType.gradientColors[0],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _bloodTypes.map((blood) {
              final isSelected = _bloodType == blood;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: blood == _bloodTypes.last ? 0 : 8,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _bloodType = blood;
                        _fortuneCache[_selectedType] = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: _selectedType.gradientColors,
                            : null,
                        color: isSelected ? null : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _selectedType.gradientColors[0].withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          '$blood형',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildBloodTypeDescription(),
        ],
      ),
    );
  }

  Widget _buildBloodTypeDescription() {
    if (_bloodType == null) return const SizedBox.shrink();
    
    final descriptions = {
      'A': '꼼꼼하고 신중한 성격의 A형',
      'B': '자유롭고 창의적인 성격의 B형',
      'O': '활발하고 사교적인 성격의 O형',
      'AB': '이성적이고 독창적인 성격의 AB형',
    };
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _selectedType.gradientColors[0].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.water_drop,
            size: 18,
            color: _selectedType.gradientColors[0],
          ),
          const SizedBox(width: 8),
          Text(
            descriptions[_bloodType] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  bool _canGenerateFortune() {
    if (_selectedType == PersonalityType.mbti) {
      return _mbtiType != null;
    } else {
      return _bloodType != null;
    }
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canGenerateFortune() ? _onGenerateFortune : null,
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
              '${_selectedType.label} 운세 확인하기',
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
    if (profile != null && _canGenerateFortune()) {
      setState(() {
        _fortuneCache[_selectedType] = null;
      });
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
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
                  _selectedType == PersonalityType.mbti
                      ? '$_mbtiType 운세'
                      : '$_bloodType형 운세',
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
          
          // Personality traits
          if (fortune.additionalInfo?['personalityTraits'] != null) ...[
            const SizedBox(height: 20),
            _buildPersonalityTraits(List<String>.from(fortune.additionalInfo!['personalityTraits'] as List)),
          ],
          
          // Compatibility
          if (fortune.additionalInfo?['compatibility'] != null) ...[
            const SizedBox(height: 20),
            _buildCompatibility(fortune.additionalInfo!['compatibility'] as Map<String, dynamic>),
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

  Widget _buildPersonalityTraits(List<String> traits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 성격 특성',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: traits.map((trait) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedType.gradientColors[0].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedType.gradientColors[0].withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              trait,
              style: TextStyle(
                fontSize: 13,
                color: _selectedType.gradientColors[0],
              ),
            ),
          )).toList(),
        ),
      ]
    );
  }

  Widget _buildCompatibility(Map<String, dynamic> compatibility) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 궁합',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _selectedType.gradientColors[0].withValues(alpha: 0.05),
                _selectedType.gradientColors[1].withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (compatibility['best'] != null)
                _buildCompatibilityRow('최고의 궁합', compatibility['best'], Colors.green),
              if (compatibility['good'] != null)
                _buildCompatibilityRow('좋은 궁합', compatibility['good'], Colors.blue),
              if (compatibility['caution'] != null)
                _buildCompatibilityRow('주의할 궁합', compatibility['caution'], Colors.orange),
            ],
          ),
        ),
      ]
    );
  }

  Widget _buildCompatibilityRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}