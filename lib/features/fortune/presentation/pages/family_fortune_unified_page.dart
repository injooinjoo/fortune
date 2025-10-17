import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../widgets/standard_fortune_app_bar.dart';

enum FamilyType {
  children('자녀 운세', 'children', '우리 아이의 운세와 성장', Icons.child_care_rounded, [Color(0xFFFBBF24), Color(0xFFF59E0B)], false),
  parenting('육아 운세', 'parenting', '오늘의 육아 조언', Icons.family_restroom_rounded, [Color(0xFF10B981), Color(0xFF059669)], false),
  pregnancy('태교 운세', 'pregnancy', '예비 엄마를 위한 태교 가이드', Icons.pregnant_woman_rounded, [Color(0xFFEC4899), Color(0xFFDB2777)], false),
  harmony('가족 화합', 'family-harmony', '가족 간의 조화와 행복', Icons.home_rounded, [Color(0xFF6366F1), Color(0xFF4F46E5)], false);

  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPremium;

  const FamilyType(this.label, this.value, this.description, this.icon, this.gradientColors, this.isPremium);
}

class FamilyFortuneUnifiedPage extends ConsumerStatefulWidget {
  const FamilyFortuneUnifiedPage({super.key});

  @override
  ConsumerState<FamilyFortuneUnifiedPage> createState() => _FamilyFortuneUnifiedPageState();
}

class _FamilyFortuneUnifiedPageState extends ConsumerState<FamilyFortuneUnifiedPage> {
  int _currentStep = 0;
  FamilyType _selectedType = FamilyType.children;
  
  // Family member information
  String _childName = '';
  int _childAge = 1;
  String _childGender = 'boy'; // boy, girl
  String _relationship = 'parent'; // parent, grandparent, sibling
  
  bool _isLoading = false;
  Fortune? _fortune;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundSecondary,
      appBar: const StandardFortuneAppBar(
        title: '가족 운세',
      ),
      body: _fortune != null
          ? _buildResultScreen()
          : _buildInputScreen(),
    );
  }

  Widget _buildInputScreen() {
    return Stack(
      children: [
        // Step content (프로그레스 인디케이터 제거)
        PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: PageController(initialPage: _currentStep),
          children: [
            _buildStep1FamilyType(),
            _buildStep2FamilyInfo(),
          ],
        ),

        // Floating progress button
        _buildBottomButton(),
      ],
    );
  }


  Widget _buildStep1FamilyType() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 가족 운세를\n보고 싶으신가요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '가족의 화합과 행복을 위한 맞춤 운세를 제공해드려요',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 32),
          
          // Family type selection
          ..._buildFamilyTypeCards(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  List<Widget> _buildFamilyTypeCards() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FamilyType.values.map((type) {
      final isSelected = _selectedType == type;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? TossDesignSystem.tossBlue.withValues(alpha: 0.05) : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.backgroundPrimary),
              border: Border.all(
                color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? TossTheme.primaryBlue : type.gradientColors[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    color: isSelected ? TossDesignSystem.white : type.gradientColors[0],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: TossTheme.primaryBlue,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStep2FamilyInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가족 정보를\n알려주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '더 정확한 운세를 위해 기본 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 32),

          if (_selectedType == FamilyType.children) ...[
            // Child name
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '아이 이름',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _childName = value),
                    style: TextStyle(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                    decoration: InputDecoration(
                      hintText: '아이의 이름을 입력해주세요',
                      hintStyle: TextStyle(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray500),
                      filled: true,
                      fillColor: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: TossTheme.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Child age
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나이',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: TossTheme.primaryBlue),
                          onPressed: () {
                            if (_childAge > 1) setState(() => _childAge--);
                          },
                        ),
                        Expanded(
                          child: Text(
                            '$_childAge세',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: TossTheme.primaryBlue),
                          onPressed: () {
                            if (_childAge < 30) setState(() => _childAge++);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성별',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _childGender = 'boy'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _childGender == 'boy' ? TossTheme.primaryBlue.withValues(alpha: 0.1) : null,
                              border: Border.all(
                                color: _childGender == 'boy' ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                                width: _childGender == 'boy' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.boy,
                                  color: _childGender == 'boy' ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '남자아이',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _childGender == 'boy' ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _childGender = 'girl'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _childGender == 'girl' ? TossTheme.primaryBlue.withValues(alpha: 0.1) : null,
                              border: Border.all(
                                color: _childGender == 'girl' ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                                width: _childGender == 'girl' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.girl,
                                  color: _childGender == 'girl' ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '여자아이',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _childGender == 'girl' ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // For other family types, show general relationship
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나와의 관계',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...['parent', 'grandparent', 'sibling'].map((rel) {
                    final isSelected = _relationship == rel;
                    final labels = {
                      'parent': '부모님',
                      'grandparent': '조부모님',
                      'sibling': '형제자매',
                    };

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _relationship = rel),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.1) : null,
                            border: Border.all(
                              color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                labels[rel]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: TossTheme.primaryBlue,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildBottomButton() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 20,
      right: 20,
      bottom: 16 + bottomPadding,
      child: TossFloatingProgressButton(
        text: _currentStep == 1 ? '가족 운세 보기' : '다음',
        currentStep: _currentStep + 1,
        totalSteps: 2,
        onPressed: _canProceed() ? _handleNext : null,
        isEnabled: _canProceed(),
        isLoading: _isLoading,
        showProgress: true,
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Family type is always selected
      case 1:
        return _selectedType == FamilyType.children 
          ? _childName.isNotEmpty 
          : true; // For other types, no validation needed
      default:
        return false;
    }
  }

  void _handleNext() async {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      await _generateFortune();
    }
  }

  Future<void> _generateFortune() async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final params = {
        'family_type': _selectedType.value,
        'relationship': _relationship,
        if (_selectedType == FamilyType.children) ...{
          'child_name': _childName,
          'child_age': _childAge,
          'child_gender': _childGender,
        },
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: _selectedType.value,
        userId: user.id,
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildResultScreen() {
    if (_fortune == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Family type header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _selectedType.gradientColors[0].withValues(alpha: 0.05),
              border: Border.all(
                color: _selectedType.gradientColors[0].withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.gray900.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedType.gradientColors[0],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _selectedType.icon,
                    color: TossDesignSystem.backgroundPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedType.label,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedType.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fortune content
          TossCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운세 결과',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _fortune!.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: TossButton(
                  text: '다시 해보기',
                  style: TossButtonStyle.secondary,
                  onPressed: () => setState(() {
                    _fortune = null;
                    _currentStep = 0;
                    _childName = '';
                    _childAge = 1;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TossButton(
                  text: '공유하기',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능이 곧 추가될 예정입니다')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}