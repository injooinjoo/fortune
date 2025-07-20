import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/constants/fortune_type_names.dart';
import '../../data/fortune_explanations.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/ad_loading_screen.dart';

class FortuneExplanationBottomSheet extends ConsumerStatefulWidget {
  final String fortuneType;
  final Map<String, dynamic>? fortuneData;
  final VoidCallback? onFortuneButtonPressed;
  
  const FortuneExplanationBottomSheet({
    super.key,
    required this.fortuneType,
    this.fortuneData,
    this.onFortuneButtonPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String fortuneType,
    Map<String, dynamic>? fortuneData,
    VoidCallback? onFortuneButtonPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => FortuneExplanationBottomSheet(
        fortuneType: fortuneType,
        fortuneData: fortuneData,
        onFortuneButtonPressed: onFortuneButtonPressed,
      ),
    );
  }

  @override
  ConsumerState<FortuneExplanationBottomSheet> createState() => _FortuneExplanationBottomSheetState();
}

class _FortuneExplanationBottomSheetState extends ConsumerState<FortuneExplanationBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  
  // Form controllers for fortune settings
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedMbti;
  String? _selectedBloodType;
  bool _isFormValid = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile != null) {
      _nameController.text = profile.name ?? '';
      _selectedDate = profile.birthDate;
      _selectedGender = profile.gender;
      _selectedMbti = profile.mbtiType;
      // bloodType field not available in current UserProfile model
      _checkFormValidity();
    }
  }
  
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _selectedDate != null &&
          _selectedGender != null;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: screenHeight * 0.9,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHandle(),
                    _buildHeader(theme),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFortuneTypeSection(theme),
                            const SizedBox(height: 24),
                            _buildFortuneSettingsSection(theme),
                            const SizedBox(height: 24),
                            _buildCustomFortuneSection(theme),
                            const SizedBox(height: 24),
                            _buildScoreGuideSection(theme),
                            const SizedBox(height: 24),
                            _buildLuckyItemsSection(theme),
                            // Removed user info section as requested
                            // const SizedBox(height: 24),
                            // _buildRequiredInfoSection(theme),
                            const SizedBox(height: 100),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${FortuneTypeNames.getName(widget.fortuneType)} 가이드',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneSettingsSection(ThemeData theme) {
    return _buildSection(
      title: '운세 설정',
      icon: Icons.settings,
      color: theme.colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정확한 운세를 위해 아래 정보를 입력해주세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Name input
          TextField(
            controller: _nameController,
            onChanged: (_) => _checkFormValidity(),
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          
          // Birth date picker
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _checkFormValidity();
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                    : '생년월일을 선택하세요',
                style: TextStyle(
                  color: _selectedDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Gender selection
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: '남성',
                  icon: Icons.male,
                  selected: _selectedGender == 'male',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedGender = 'male';
                        _checkFormValidity();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceChip(
                  label: '여성',
                  icon: Icons.female,
                  selected: _selectedGender == 'female',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedGender = 'female';
                        _checkFormValidity();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // MBTI selection (optional)
          Text(
            '추가 정보 (선택사항)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // MBTI dropdown
          DropdownButtonFormField<String>(
            value: _selectedMbti,
            decoration: InputDecoration(
              labelText: 'MBTI',
              prefixIcon: const Icon(Icons.psychology),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: ['INTJ', 'INTP', 'ENTJ', 'ENTP', 'INFJ', 'INFP', 'ENFJ', 'ENFP',
                    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ', 'ISTP', 'ISFP', 'ESTP', 'ESFP']
                .map((mbti) => DropdownMenuItem(
                      value: mbti,
                      child: Text(mbti),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMbti = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Blood type selection
          Row(
            children: [
              Text(
                '혈액형: ',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              ...['A', 'B', 'AB', 'O'].map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type),
                  selected: _selectedBloodType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedBloodType = type;
                      });
                    }
                  },
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[100],
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildFortuneTypeSection(ThemeData theme) {
    final explanation = FortuneExplanations.getExplanation(widget.fortuneType);
    
    return _buildSection(
      title: '${explanation['title']} 안내',
      icon: Icons.auto_awesome,
      color: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            explanation['description'] ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            theme,
            title: '운세 특징',
            content: List<String>.from(explanation['features'] ?? []),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            theme,
            title: '활용 팁',
            content: List<String>.from(explanation['tips'] ?? []),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFortuneSection(ThemeData theme) {
    final explanation = FortuneExplanations.getExplanation(widget.fortuneType);
    
    // Build visual data sections based on fortune type
    Widget? visualSection;
    switch (widget.fortuneType) {
      case 'daily':
      case 'weekly':
      case 'monthly':
      case 'yearly':
        visualSection = _buildTimeBasedVisuals(theme, explanation);
        break;
      case 'saju':
        visualSection = _buildSajuVisuals(theme, explanation);
        break;
      case 'mbti':
        visualSection = _buildMbtiVisuals(theme, explanation);
        break;
      case 'zodiac':
        visualSection = _buildZodiacVisuals(theme, explanation);
        break;
      case 'zodiac-animal':
        visualSection = _buildZodiacAnimalVisuals(theme, explanation);
        break;
      case 'tarot':
        visualSection = _buildTarotVisuals(theme, explanation);
        break;
      case 'chemistry':
      case 'compatibility':
        visualSection = _buildCompatibilityVisuals(theme, explanation);
        break;
      case 'love':
        visualSection = _buildLoveVisuals(theme, explanation);
        break;
      case 'career':
        visualSection = _buildCareerVisuals(theme, explanation);
        break;
      case 'wealth':
        visualSection = _buildWealthVisuals(theme, explanation);
        break;
      case 'health':
        visualSection = _buildHealthVisuals(theme, explanation);
        break;
      case 'business':
        visualSection = _buildBusinessVisuals(theme, explanation);
        break;
    }
    
    // Check for special note
    final specialNote = explanation['specialNote'];
    final hasSpecialNote = specialNote != null;
    
    // Custom sections for specific fortune types
    final customSections = explanation['customSections'] as Map<String, dynamic>?;
    final hasCustomSections = customSections != null && customSections.isNotEmpty;
    
    return Column(
      children: [
        if (visualSection != null) ...[
          visualSection,
          const SizedBox(height: 24),
        ],
        if (hasSpecialNote)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    specialNote,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (hasSpecialNote && hasCustomSections) const SizedBox(height: 16),
        if (hasCustomSections)
          Column(
            children: customSections!.entries.map((entry) {
              final section = entry.value as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                      theme.colorScheme.primary.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['title'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section['description'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildScoreGuideSection(ThemeData theme) {
    final scoreInterpretations = FortuneExplanations.getScoreInterpretations();
    
    return _buildSection(
      title: '점수 해석 방법',
      icon: Icons.analytics,
      color: context.fortuneTheme.scoreExcellent,
      child: Column(
        children: scoreInterpretations.map((interpretation) {
          final score = interpretation['range']!;
          Color color;
          if (score.startsWith('90')) {
            color = context.fortuneTheme.scoreExcellent;
          } else if (score.startsWith('70')) {
            color = context.fortuneTheme.scoreGood;
          } else if (score.startsWith('50')) {
            color = context.fortuneTheme.scoreFair;
          } else if (score.startsWith('30')) {
            color = context.fortuneTheme.scoreFair;
          } else {
            color = context.fortuneTheme.scorePoor;
          }
          
          return _buildExpandableScoreItem(
            theme,
            interpretation['range']!,
            interpretation['label']!,
            interpretation['description']!,
            interpretation['advice']!,
            color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLuckyItemsSection(ThemeData theme) {
    final luckyItemExplanations = FortuneExplanations.getLuckyItemExplanations();
    
    return _buildSection(
      title: '행운 아이템 의미',
      icon: Icons.stars,
      color: Colors.amber,
      child: Column(
        children: [
          if (luckyItemExplanations.containsKey('color'))
            _buildEnhancedLuckyItem(theme, 'color', Icons.palette, luckyItemExplanations['color']!),
          if (luckyItemExplanations.containsKey('number'))
            _buildEnhancedLuckyItem(theme, 'number', Icons.looks_one, luckyItemExplanations['number']!),
          if (luckyItemExplanations.containsKey('direction'))
            _buildEnhancedLuckyItem(theme, 'direction', Icons.explore, luckyItemExplanations['direction']!),
          if (luckyItemExplanations.containsKey('time'))
            _buildEnhancedLuckyItem(theme, 'time', Icons.access_time, luckyItemExplanations['time']!),
          if (luckyItemExplanations.containsKey('food'))
            _buildEnhancedLuckyItem(theme, 'food', Icons.restaurant, luckyItemExplanations['food']!),
          if (luckyItemExplanations.containsKey('person'))
            _buildEnhancedLuckyItem(theme, 'person', Icons.person, luckyItemExplanations['person']!),
        ],
      ),
    );
  }


  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, {
    required String title,
    required List<String> content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...content.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: theme.colorScheme.primary)),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExpandableScoreItem(
    ThemeData theme,
    String range,
    String label,
    String description,
    String advice,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              range,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLuckyItem(
    ThemeData theme,
    String type,
    IconData icon,
    Map<String, String> itemData,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.amber[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemData['title'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itemData['description'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 14,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        itemData['usage'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRequiredInfoSection(ThemeData theme) {
    final requiredInfo = _getRequiredInfoForFortuneType(widget.fortuneType);
    final userInfo = _getUserProvidedInfo();
    
    // Check if any required info is missing
    final missingRequiredInfo = requiredInfo['required']!.where((info) => 
      userInfo[info] == null || userInfo[info] == ''
    ).toList();
    
    return _buildSection(
      title: '내 정보',
      icon: Icons.person_outline,
      color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '운세 생성에 사용되는 내 정보입니다.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
              if (missingRequiredInfo.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/profile');
                  },
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('수정'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                  ),
                ),
            ],
          ),
          if (missingRequiredInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, 
                    color: Colors.orange[700], 
                    size: 20
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '더 정확한 운세를 위해 추가 정보를 입력해주세요.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '필수 정보',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                const SizedBox(height: 12),
                ...requiredInfo['required']!.map((info) => _buildInfoItem(
                  theme,
                  info,
                  userInfo[info] != null && userInfo[info] != '',
                  userInfo[info],
                )),
                if (requiredInfo['optional']!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '선택 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...requiredInfo['optional']!.map((info) => _buildInfoItem(
                    theme,
                    info,
                    userInfo[info] != null && userInfo[info] != '',
                    userInfo[info],
                    isOptional: true,
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    String infoType,
    bool hasInfo,
    dynamic infoValue, {
    bool isOptional = false,
  }) {
    final labels = {
      'name': '이름',
      'birthDate': '생년월일',
      'birthTime': '출생 시간',
      'gender': '성별',
      'mbti': 'MBTI',
      'bloodType': '혈액형',
      'zodiacSign': '별자리',
      'chineseZodiac': '띠',
      'location': '지역',
      'partnerName': '상대방 이름',
      'partnerBirthDate': '상대방 생년월일',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            hasInfo ? Icons.check_circle : (isOptional ? Icons.circle_outlined : Icons.warning_amber_rounded),
            size: 20,
            color: hasInfo ? Colors.green : (isOptional ? Colors.grey : Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  labels[infoType] ?? infoType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: hasInfo ? null : Colors.grey[600],
                  ),
                ),
                if (hasInfo)
                  Container(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Text(
                      _formatInfoValue(infoType, infoValue),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/profile');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOptional ? Colors.grey[100] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOptional ? Colors.grey[300]! : Colors.orange[300]!,
                        ),
                      ),
                      child: Text(
                        '입력하기',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOptional ? Colors.grey[700] : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
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

  Map<String, List<String>> _getRequiredInfoForFortuneType(String fortuneType) {
    switch (fortuneType) {
      case 'daily':
      case 'weekly':
      case 'monthly':
      case 'yearly':
        return {
          'required': ['name', 'birthDate'],
          'optional': ['birthTime', 'gender', 'mbti'],
        };
      case 'saju':
        return {
          'required': ['name', 'birthDate', 'birthTime'],
          'optional': ['gender', 'location'],
        };
      case 'mbti':
        return {
          'required': ['name', 'mbti'],
          'optional': ['birthDate', 'gender'],
        };
      case 'zodiac':
        return {
          'required': ['name', 'birthDate'],
          'optional': ['birthTime'],
        };
      case 'chemistry':
      case 'compatibility':
        return {
          'required': ['name', 'birthDate', 'partnerName', 'partnerBirthDate'],
          'optional': ['gender', 'mbti'],
        };
      case 'love':
        return {
          'required': ['name', 'birthDate'],
          'optional': ['gender', 'mbti', 'bloodType'],
        };
      case 'career':
      case 'wealth':
      case 'business':
        return {
          'required': ['name', 'birthDate'],
          'optional': ['mbti', 'location'],
        };
      default:
        return {
          'required': ['name', 'birthDate'],
          'optional': ['gender', 'mbti'],
        };
    }
  }

  Map<String, dynamic> _getUserProvidedInfo() {
    final userProfileAsync = ref.watch(userProfileProvider);
    
    return userProfileAsync.when(
      data: (profile) {
        if (profile != null) {
          // Extract additional info from preferences if available
          final prefs = profile.preferences ?? {};
          return {
            'name': profile.name ?? '',
            'birthDate': profile.birthDate,
            'birthTime': prefs['birthTime'],
            'gender': profile.gender,
            'mbti': profile.mbtiType,
            'bloodType': prefs['bloodType'],
            'zodiacSign': profile.zodiacSign,
            'chineseZodiac': prefs['chineseZodiac'],
            'location': prefs['location'],
          };
        }
        return {};
      },
      loading: () => {},
      error: (_, __) => {},
    );
  }

  String _formatInfoValue(String infoType, dynamic value) {
    if (value == null) return '';
    
    switch (infoType) {
      case 'birthDate':
      case 'partnerBirthDate':
        if (value is DateTime) {
          return '${value.year}년 ${value.month}월 ${value.day}일';
        }
        return value.toString();
      case 'birthTime':
        return value.toString();
      case 'gender':
        return value.toString();
      default:
        return value.toString();
    }
  }

  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: bottomPadding + 16,
        ),
        child: ElevatedButton(
          onPressed: _isFormValid ? () async {
            // Save form data and generate fortune
            final fortuneParams = {
              'name': _nameController.text,
              'birthDate': _selectedDate?.toIso8601String(),
              'gender': _selectedGender,
              'mbti': _selectedMbti,
              'bloodType': _selectedBloodType,
            };
            
            Navigator.of(context).pop();
            
            // Navigate to AdLoadingScreen with fortune params
            // Premium status check removed - not available in current UserProfile model
            final isPremium = false;
            
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdLoadingScreen(
                  fortuneType: widget.fortuneType,
                  fortuneTitle: FortuneTypeNames.getName(widget.fortuneType),
                  isPremium: isPremium,
                  fortuneParams: fortuneParams,
                  onComplete: () {
                    // Fortune generation completed
                  },
                  onSkip: () {
                    // User skipped ad
                  },
                ),
              ),
            );
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid ? theme.colorScheme.primary : Colors.grey[400],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _isFormValid ? 4 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 24),
              const SizedBox(width: 8),
              Text(
                _isFormValid ? '운세보기' : '정보를 입력해주세요',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.2, end: 0, duration: 300.ms),
      ),
    );
  }

  // Visual component builders
  Widget _buildTimeBasedVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final timeFlow = visualData['timeFlow'] as List<dynamic>?;
    final categories = visualData['categories'] as Map<String, dynamic>?;
    
    return Column(
      children: [
        if (timeFlow != null) _buildTimeFlowChart(theme, timeFlow),
        if (timeFlow != null && categories != null) const SizedBox(height: 20),
        if (categories != null) _buildCategoryScores(theme, categories),
      ],
    );
  }

  Widget _buildTimeFlowChart(ThemeData theme, List<dynamic> timeFlow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '24시간 운세 흐름',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...timeFlow.map((item) {
            final data = item as Map<String, dynamic>;
            final score = (data['score'] as num).toDouble();
            Color barColor;
            if (score >= 80) {
              barColor = context.fortuneTheme.scoreExcellent;
            } else if (score >= 60) {
              barColor = context.fortuneTheme.scoreGood;
            } else if (score >= 40) {
              barColor = context.fortuneTheme.scoreFair;
            } else {
              barColor = context.fortuneTheme.scorePoor;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          data['time'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: score / 100,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      barColor,
                                      barColor.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: barColor.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '${score.toInt()}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: score >= 50 ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data['icon'] ?? '',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  if (data['label'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 108, top: 4),
                      child: Text(
                        data['label'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryScores(ThemeData theme, Map<String, dynamic> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분야별 운세',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: categories.entries.map((entry) {
              final score = entry.value as num;
              Color scoreColor;
              if (score >= 80) {
                scoreColor = context.fortuneTheme.scoreExcellent;
              } else if (score >= 60) {
                scoreColor = context.fortuneTheme.scoreGood;
              } else if (score >= 40) {
                scoreColor = context.fortuneTheme.scoreFair;
              } else {
                scoreColor = context.fortuneTheme.scorePoor;
              }
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scoreColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${score}점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSajuVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final fourPillars = visualData['fourPillarsChart'] as List<dynamic>?;
    final fiveElements = visualData['fiveElementsBalance'] as Map<String, dynamic>?;
    
    return Column(
      children: [
        if (fourPillars != null) _buildFourPillarsChart(theme, fourPillars),
        if (fourPillars != null && fiveElements != null) const SizedBox(height: 20),
        if (fiveElements != null) _buildFiveElementsChart(theme, fiveElements),
      ],
    );
  }

  Widget _buildFourPillarsChart(ThemeData theme, List<dynamic> pillars) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.view_column,
                color: Colors.deepPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '사주의 구성',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: pillars.map((item) {
              final pillar = item as Map<String, dynamic>;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        pillar['pillar'] ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pillar['value'] ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pillar['label'] ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        pillar['description'] ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiveElementsChart(ThemeData theme, Map<String, dynamic> elements) {
    final elementColors = {
      '목': Colors.green,
      '화': Colors.red,
      '토': Colors.yellow[700]!,
      '금': Colors.grey,
      '수': Colors.blue,
    };
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오행의 균형',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...elements.entries.map((entry) {
            final element = entry.key;
            final value = (entry.value as num).toDouble();
            final color = elementColors[element] ?? Colors.grey;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      element,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: value / 100,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${value.toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMbtiVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final typeGroups = visualData['typeGroups'] as List<dynamic>?;
    
    return Column(
      children: [
        if (typeGroups != null) _buildMbtiTypeGroups(theme, typeGroups),
      ],
    );
  }

  Widget _buildMbtiTypeGroups(ThemeData theme, List<dynamic> groups) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'MBTI 성격 유형 그룹',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: groups.map((item) {
              final group = item as Map<String, dynamic>;
              final color = Color(int.parse(group['color'].substring(1), radix: 16) + 0xFF000000);
              final types = group['types'] as List<dynamic>;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['group'] ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      types.join(', '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      group['characteristics'] ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final zodiacWheel = visualData['zodiacWheel'] as List<dynamic>?;
    
    return Column(
      children: [
        if (zodiacWheel != null) _buildZodiacWheel(theme, zodiacWheel),
      ],
    );
  }

  Widget _buildZodiacWheel(ThemeData theme, List<dynamic> zodiacSigns) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: Colors.purple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '12궁도 별자리',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: zodiacSigns.map((item) {
              final sign = item as Map<String, dynamic>;
              final elementColors = {
                '불': Colors.red,
                '흙': Colors.brown,
                '공기': Colors.lightBlue,
                '물': Colors.blue,
              };
              final color = elementColors[sign['element']] ?? Colors.purple;
              
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sign['symbol'] ?? '',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sign['sign'] ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sign['period'] ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacAnimalVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    // Simple display for zodiac animals
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pets,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '12지신 동물 띠',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '띠별 상성 관계와 특성을 확인하세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarotVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final tarotCards = visualData['tarotCards'] as List<dynamic>?;
    
    return Column(
      children: [
        if (tarotCards != null) _buildTarotSpread(theme, tarotCards),
      ],
    );
  }

  Widget _buildTarotSpread(ThemeData theme, List<dynamic> cards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.style,
                color: Colors.deepPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '타로 카드 스프레드',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: cards.map((item) {
              final card = item as Map<String, dynamic>;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.withValues(alpha: 0.1),
                        Colors.deepPurple.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        card['position'] ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.deepPurple.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            card['icon'] ?? '',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card['card'] ?? '',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card['meaning'] ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final radarData = visualData['radarChart'] as Map<String, dynamic>?;
    
    return Column(
      children: [
        if (radarData != null) _buildCompatibilityRadar(theme, radarData),
      ],
    );
  }

  Widget _buildCompatibilityRadar(ThemeData theme, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.pink,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '궁합 분석',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) {
            final score = (entry.value as num).toDouble();
            Color barColor;
            if (score >= 80) {
              barColor = Colors.pink;
            } else if (score >= 60) {
              barColor = Colors.orange;
            } else {
              barColor = Colors.grey;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${score.toInt()}점',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: barColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: score / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                barColor,
                                barColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLoveVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final singleRoadmap = visualData['singleRoadmap'] as List<dynamic>?;
    final couplePhases = visualData['couplePhases'] as List<dynamic>?;
    
    return Column(
      children: [
        if (singleRoadmap != null) _buildSingleRoadmap(theme, singleRoadmap),
        if (singleRoadmap != null && couplePhases != null) const SizedBox(height: 20),
        if (couplePhases != null) _buildCouplePhases(theme, couplePhases),
      ],
    );
  }

  Widget _buildSingleRoadmap(ThemeData theme, List<dynamic> roadmap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '싱글을 위한 로드맵',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...roadmap.map((item) {
            final step = item as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.pink.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step['icon'] ?? '',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${step['step']}단계: ${step['title']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          step['description'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.pink.withValues(alpha: 0.5),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCouplePhases(ThemeData theme, List<dynamic> phases) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '커플을 위한 관계 발전 단계',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: phases.map((item) {
              final phase = item as Map<String, dynamic>;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      phase['icon'] ?? '',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phase['phase'] ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      phase['period'] ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final jobTypeScores = visualData['jobTypeScores'] as List<dynamic>?;
    
    return Column(
      children: [
        if (jobTypeScores != null) _buildJobTypeScores(theme, jobTypeScores),
      ],
    );
  }

  Widget _buildJobTypeScores(ThemeData theme, List<dynamic> scores) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '직종별 운세 지수',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...scores.map((item) {
            final job = item as Map<String, dynamic>;
            final score = job['score'] as num;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Text(
                    job['icon'] ?? '',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              job['type'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(5, (index) {
                              return Icon(
                                index < score ? Icons.star : Icons.star_border,
                                size: 16,
                                color: index < score ? Colors.amber : Colors.grey[400],
                              );
                            }),
                          ],
                        ),
                        Text(
                          job['activity'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWealthVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final investmentSignals = visualData['investmentSignals'] as List<dynamic>?;
    
    return Column(
      children: [
        if (investmentSignals != null) _buildInvestmentSignals(theme, investmentSignals),
      ],
    );
  }

  Widget _buildInvestmentSignals(ThemeData theme, List<dynamic> signals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '투자 적기 신호등',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...signals.map((item) {
            final signal = item as Map<String, dynamic>;
            final signalType = signal['signal'] as String;
            Color signalColor;
            IconData signalIcon;
            
            switch (signalType) {
              case 'green':
                signalColor = Colors.green;
                signalIcon = Icons.check_circle;
                break;
              case 'yellow':
                signalColor = Colors.orange;
                signalIcon = Icons.warning;
                break;
              case 'red':
                signalColor = Colors.red;
                signalIcon = Icons.cancel;
                break;
              default:
                signalColor = Colors.grey;
                signalIcon = Icons.help;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: signalColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: signalColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    signalIcon,
                    color: signalColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              signal['type'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: signalColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${signal['percentage']}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: signalColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          signal['note'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHealthVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final healthChecklist = visualData['healthChecklist'] as List<dynamic>?;
    
    return Column(
      children: [
        if (healthChecklist != null) _buildHealthChecklist(theme, healthChecklist),
      ],
    );
  }

  Widget _buildHealthChecklist(ThemeData theme, List<dynamic> checklist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                color: Colors.teal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '건강 관리 체크리스트',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...checklist.map((item) {
            final task = item as Map<String, dynamic>;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.teal,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    task['icon'] ?? '',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task['item'] ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBusinessVisuals(ThemeData theme, Map<String, dynamic> explanation) {
    final visualData = explanation['visualData'] as Map<String, dynamic>?;
    if (visualData == null) return const SizedBox.shrink();
    
    final timeline = visualData['timeline'] as List<dynamic>?;
    final industryScores = visualData['industryScores'] as List<dynamic>?;
    
    return Column(
      children: [
        if (timeline != null) _buildBusinessTimeline(theme, timeline),
        if (timeline != null && industryScores != null) const SizedBox(height: 20),
        if (industryScores != null) _buildIndustryScores(theme, industryScores),
      ],
    );
  }

  Widget _buildBusinessTimeline(ThemeData theme, List<dynamic> timeline) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Colors.indigo,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '사업 성공 타임라인',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final phase = entry.value as Map<String, dynamic>;
                final isLast = index == timeline.length - 1;
                
                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.indigo.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              phase['icon'] ?? '',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          phase['phase'] ?? '',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          phase['duration'] ?? '',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Container(
                        width: 40,
                        height: 2,
                        color: Colors.indigo.withValues(alpha: 0.3),
                        margin: const EdgeInsets.only(bottom: 40),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryScores(ThemeData theme, List<dynamic> scores) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '업종별 추천 지수',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...scores.map((item) {
            final industry = item as Map<String, dynamic>;
            final score = (industry['score'] as num).toDouble();
            final trend = industry['trend'] as String;
            IconData trendIcon;
            Color trendColor;
            
            switch (trend) {
              case '상승':
              case '급상승':
                trendIcon = Icons.trending_up;
                trendColor = Colors.green;
                break;
              case '하락':
                trendIcon = Icons.trending_down;
                trendColor = Colors.red;
                break;
              default:
                trendIcon = Icons.trending_flat;
                trendColor = Colors.grey;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      industry['industry'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: score / 100,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo,
                                  Colors.indigo.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    trendIcon,
                    size: 16,
                    color: trendColor,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

}