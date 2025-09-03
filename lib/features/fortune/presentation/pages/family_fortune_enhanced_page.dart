import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/fortune_button.dart';
import '../widgets/fortune_card.dart';
import '../widgets/family_fortune_card.dart';
import '../widgets/family_harmony_meter.dart';
import '../widgets/family_relationship_chart.dart';

/// 가족 운세 타입
enum FamilyType {
  parentChild('parent-child', '부모-자녀', '자녀와의 소통과 성장', Icons.child_care_rounded, [Color(0xFFFBBF24), Color(0xFFF59E0B)]),
  couple('couple', '부부', '배우자와의 조화와 사랑', Icons.favorite_rounded, [Color(0xFFEC4899), Color(0xFFDB2777)]),
  siblings('siblings', '형제자매', '형제간 우애와 화합', Icons.group_rounded, [Color(0xFF10B981), Color(0xFF059669)]),
  extended('extended', '대가족', '세대간 소통과 화합', Icons.home_rounded, [Color(0xFF6366F1), Color(0xFF4F46E5)]),
  singleParent('single-parent', '한부모', '특별한 유대와 성장', Icons.volunteer_activism, [Color(0xFF8B5CF6), Color(0xFF7C3AED)]);
  
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  
  const FamilyType(this.value, this.label, this.description, this.icon, this.gradientColors);
}

class FamilyFortuneEnhancedPage extends ConsumerStatefulWidget {
  const FamilyFortuneEnhancedPage({super.key});

  @override
  ConsumerState<FamilyFortuneEnhancedPage> createState() => _FamilyFortuneEnhancedPageState();
}

class _FamilyFortuneEnhancedPageState extends ConsumerState<FamilyFortuneEnhancedPage> {
  FamilyType _selectedType = FamilyType.parentChild;
  final List<FamilyMember> _familyMembers = [];
  Fortune? _fortune;
  bool _showAdvancedOptions = false;
  
  // Quick family presets
  final Map<String, List<FamilyMember>> _familyPresets = {
    '핵가족': [
      const FamilyMember(name: '아빠', role: '아버지', emoji: '👨'),
      const FamilyMember(name: '엄마', role: '어머니', emoji: '👩'),
      const FamilyMember(name: '자녀', role: '아들', emoji: '👦'),
    ],
    '대가족': [
      const FamilyMember(name: '할아버지', role: '할아버지', emoji: '👴'),
      const FamilyMember(name: '할머니', role: '할머니', emoji: '👵'),
      const FamilyMember(name: '아빠', role: '아버지', emoji: '👨'),
      const FamilyMember(name: '엄마', role: '어머니', emoji: '👩'),
      const FamilyMember(name: '자녀', role: '아들', emoji: '👦'),
    ],
    '한부모': [
      const FamilyMember(name: '엄마', role: '어머니', emoji: '👩'),
      const FamilyMember(name: '자녀', role: '아들', emoji: '👦'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: _buildAppBar(isDark),
      body: _fortune != null 
          ? _buildResultView(isDark)
          : _buildInputView(isDark),
    );
  }
  
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      elevation: 0,
      title: Text(
        '가족 운세',
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
        if (_fortune != null)
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: TossDesignSystem.tossBlue,
            ),
            onPressed: _resetFortune,
          ),
      ],
    );
  }
  
  Widget _buildInputView(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDark),
          
          // Family type selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '가족 유형 선택',
              style: TossDesignSystem.heading4.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
          ),
          ...FamilyType.values.map((type) => FamilyFortuneCard(
            title: type.label,
            subtitle: type.description,
            icon: type.icon,
            gradientColors: type.gradientColors,
            isSelected: _selectedType == type,
            onTap: () => setState(() => _selectedType = type),
          )),
          
          const SizedBox(height: 24),
          
          // Quick family presets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '빠른 가족 구성',
              style: TossDesignSystem.heading4.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _familyPresets.entries.map((entry) => FamilyMemberChip(
                label: entry.key,
                icon: Icons.people,
                isSelected: false,
                onTap: () {
                  setState(() {
                    _familyMembers.clear();
                    _familyMembers.addAll(entry.value);
                  });
                },
                color: TossDesignSystem.tossBlue,
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Family members
          if (_familyMembers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '가족 구성원',
                    style: TossDesignSystem.heading4.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _familyMembers.clear()),
                    child: Text(
                      '초기화',
                      style: TossDesignSystem.body3.copyWith(
                        color: TossDesignSystem.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _familyMembers.map((member) => Chip(
                  avatar: Text(member.emoji),
                  label: Text(member.name),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _familyMembers.remove(member));
                  },
                  backgroundColor: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  deleteIconColor: TossDesignSystem.gray600,
                )).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Advanced options toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
              child: Row(
                children: [
                  Icon(
                    _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                    color: TossDesignSystem.gray600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '상세 옵션',
                    style: TossDesignSystem.body3.copyWith(
                      color: TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_showAdvancedOptions) ...[
            const SizedBox(height: 16),
            FortuneCard(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '특별한 상황',
                    style: TossDesignSystem.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...['재혼 가정', '다문화 가정', '조손 가정', '입양 가정'].map(
                    (situation) => CheckboxListTile(
                      title: Text(
                        situation,
                        style: TossDesignSystem.body3,
                      ),
                      value: false,
                      onChanged: (value) {},
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Generate button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FortuneButton(
              text: '가족 운세 보기',
              onPressed: _familyMembers.isEmpty ? null : _generateFortune,
              type: FortuneButtonType.primary,
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.tossBlue,
            TossDesignSystem.purple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              Text(
                DateTime.now().toString().split(' ')[0],
                style: TossDesignSystem.body3.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '우리 가족의\n특별한 하루',
            style: TossDesignSystem.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '가족 간의 사랑과 화합을 위한\n맞춤형 운세를 확인해보세요',
            style: TossDesignSystem.body3.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildResultView(bool isDark) {
    if (_fortune == null) return const SizedBox.shrink();
    
    final harmonyData = _fortune!.additionalInfo?['harmony'] ?? {};
    final memberFortunes = _fortune!.additionalInfo?['member_fortunes'] ?? {};
    final todayActivity = _fortune!.additionalInfo?['today_activity'] ?? {};
    final categories = _fortune!.additionalInfo?['categories'] ?? {};
    final weeklyTrend = _fortune!.additionalInfo?['weekly_trend'] ?? {};
    final conflictPrevention = _fortune!.additionalInfo?['conflict_prevention'] ?? {};
    final luckyElements = _fortune!.additionalInfo?['lucky_elements'] ?? {};
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Harmony meter
          Padding(
            padding: const EdgeInsets.all(20),
            child: FamilyHarmonyMeter(
              score: harmonyData['score'] ?? 0,
              level: harmonyData['level'] ?? '',
              description: harmonyData['description'] ?? '',
            ),
          ),
          
          // Main fortune message
          FortuneCard(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: '오늘의 가족 운세',
            child: Text(
              _fortune!.content,
              style: TossDesignSystem.body2.copyWith(
                color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                height: 1.6,
              ),
            ),
          ),
          
          // Today's activity
          if (todayActivity.isNotEmpty)
            FamilyActivityCard(
              activity: todayActivity['activity'] ?? '',
              description: todayActivity['description'] ?? '',
              difficulty: todayActivity['difficulty'] ?? '',
              duration: todayActivity['duration'] ?? '',
              benefit: todayActivity['benefit'] ?? '',
            ),
          
          // Member fortunes
          if (memberFortunes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '구성원별 운세',
                style: TossDesignSystem.heading4.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
              ),
            ),
            ...memberFortunes.entries.map((entry) {
              final member = entry.value as Map<String, dynamic>;
              return FamilyMemberFortuneCard(
                name: entry.key,
                mood: member['mood'] ?? '',
                energy: member['energy'] ?? 0,
                advice: member['advice'] ?? '',
                luckyTime: member['luckyTime'] ?? '',
              );
            }).toList(),
          ],
          
          // Category chart
          if (categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: FamilyCategoryChart(categories: categories),
            ),
          
          // Weekly trend
          if (weeklyTrend.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: FamilyWeeklyTrendChart(weeklyTrend: weeklyTrend),
            ),
          
          // Conflict prevention tip
          if (conflictPrevention.isNotEmpty)
            FortuneCard(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: '갈등 예방 팁',
              backgroundColor: TossDesignSystem.warningOrange.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conflictPrevention['situation'] ?? '',
                    style: TossDesignSystem.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TossDesignSystem.warningOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '예방: ${conflictPrevention['prevention'] ?? ''}',
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '해결: ${conflictPrevention['solution'] ?? ''}',
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    ),
                  ),
                ],
              ),
            ),
          
          // Lucky elements
          if (luckyElements.isNotEmpty)
            FortuneCard(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: '오늘의 행운 요소',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildLuckyElement('시간', luckyElements['time'], Icons.schedule, TossDesignSystem.tossBlue),
                  _buildLuckyElement('장소', luckyElements['place'], Icons.place, TossDesignSystem.purple),
                  _buildLuckyElement('활동', luckyElements['activity'], Icons.directions_run, TossDesignSystem.successGreen),
                  _buildLuckyElement('색상', luckyElements['color'], Icons.palette, TossDesignSystem.warningOrange),
                  _buildLuckyElement('음식', luckyElements['food'], Icons.restaurant, TossDesignSystem.errorRed),
                ],
              ),
            ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: FortuneButton(
                    text: '다시 보기',
                    onPressed: _resetFortune,
                    type: FortuneButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FortuneButton(
                    text: '공유하기',
                    onPressed: _shareFortune,
                    type: FortuneButtonType.primary,
                    icon: const Icon(Icons.share, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildLuckyElement(String label, dynamic value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ${value ?? ''}',
            style: TossDesignSystem.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _generateFortune() async {
    try {
      final authState = ref.read(authStateProvider).value;
      if (authState == null) {
        throw Exception('로그인이 필요합니다');
      }
      
      final params = {
        'family_type': _selectedType.value,
        'family_members': _familyMembers.map((m) => {
          'name': m.name,
          'role': m.role,
          'emoji': m.emoji,
        }).toList(),
      };
      
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: 'family-harmony',
        userId: authState.session?.user.id ?? '',
        params: params,
      );
      
      setState(() => _fortune = fortune);
    } catch (e) {
      Logger.error('가족 운세 생성 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운세 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }
  
  void _resetFortune() {
    setState(() {
      _fortune = null;
      _familyMembers.clear();
      _selectedType = FamilyType.parentChild;
    });
  }
  
  void _shareFortune() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능이 곧 추가될 예정입니다')),
    );
  }
}