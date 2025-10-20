import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../services/mbti_cognitive_functions_service.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../shared/components/toss_card.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/conditions/mbti_fortune_conditions.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';

class MbtiFortunePage extends BaseFortunePage {
  const MbtiFortunePage({
    super.key,
    super.initialParams,
  }) : super(
          title: 'MBTI 운세',
          description: '나의 성격 유형으로 보는 오늘의 운세',
          fortuneType: 'mbti',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<MbtiFortunePage> createState() => _MbtiFortunePageState();
}

class _MbtiFortunePageState extends BaseFortunePageState<MbtiFortunePage> {
  // MBTI selection
  String? _selectedMbti;

  // Categories
  final List<String> _selectedCategories = [];

  // Cognitive functions
  Map<String, double>? _cognitiveFunctions;

  // Energy level (0.0 to 1.0)
  double _energyLevel = 0.0;

  // Accordion state - 초기에는 모두 펼쳐져 있음
  bool _showAllGroups = true;

  // ScrollController for auto-scroll
  final ScrollController _scrollController = ScrollController();

  // GlobalKey for selected MBTI info position
  final GlobalKey _selectedInfoKey = GlobalKey();

  // MBTI Groups for better organization
  static const Map<String, List<String>> _mbtiGroups = {
    '분석가': ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    '외교관': ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    '관리자': ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    '탐험가': ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
  };

  // MBTI Colors with gradient
  static const Map<String, List<Color>> _mbtiColors = {
    // 분석가 - Purple/Blue tones
    'INTJ': [Color(0xFF6B46C1), Color(0xFF9333EA)],
    'INTP': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    'ENTJ': [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    'ENTP': [Color(0xFF8B5CF6), Color(0xFFBB9EFA)],
    // 외교관 - Green/Teal tones
    'INFJ': [Color(0xFF059669), Color(0xFF10B981)],
    'INFP': [Color(0xFF0891B2), Color(0xFF06B6D4)],
    'ENFJ': [Color(0xFF0D9488), Color(0xFF14B8A6)],
    'ENFP': [Color(0xFF10B981), Color(0xFF34D399)],
    // 관리자 - Blue/Navy tones
    'ISTJ': [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    'ISFJ': [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    'ESTJ': [Color(0xFF1F2937), Color(0xFF4B5563)],
    'ESFJ': [Color(0xFF312E81), Color(0xFF4F46E5)],
    // 탐험가 - Orange/Red tones
    'ISTP': [Color(0xFFDC2626), Color(0xFFEF4444)],
    'ISFP': [Color(0xFFEA580C), Color(0xFFF97316)],
    'ESTP': [Color(0xFFE11D48), Color(0xFFF43F5E)],
    'ESFP': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  };

  // MBTI Icons
  static const Map<String, IconData> _mbtiIcons = {
    'INTJ': Icons.psychology,
    'INTP': Icons.science,
    'ENTJ': Icons.business_center,
    'ENTP': Icons.lightbulb,
    'INFJ': Icons.favorite,
    'INFP': Icons.palette,
    'ENFJ': Icons.groups,
    'ENFP': Icons.celebration,
    'ISTJ': Icons.checklist,
    'ISFJ': Icons.shield,
    'ESTJ': Icons.gavel,
    'ESFJ': Icons.handshake,
    'ISTP': Icons.build,
    'ISFP': Icons.brush,
    'ESTP': Icons.sports,
    'ESFP': Icons.music_note,
  };

  // Fortune Categories
  static const List<Map<String, dynamic>> _categories = [
    {'label': '연애운', 'icon': Icons.favorite, 'color': Color(0xFFEC4899)},
    {'label': '직업운', 'icon': Icons.work, 'color': Color(0xFF3B82F6)},
    {'label': '재물운', 'icon': Icons.attach_money, 'color': Color(0xFF10B981)},
    {'label': '건강운', 'icon': Icons.health_and_safety, 'color': Color(0xFFF59E0B)},
    {'label': '대인관계', 'icon': Icons.people, 'color': Color(0xFF8B5CF6)},
    {'label': '학업운', 'icon': Icons.school, 'color': Color(0xFF06B6D4)},
  ];


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Auto-scroll to selected MBTI info
  void _scrollToSelectedInfo() {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_selectedInfoKey.currentContext != null && mounted) {
        final RenderBox? renderBox = _selectedInfoKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final screenHeight = MediaQuery.of(context).size.height;
          final targetScroll = _scrollController.offset + position - (screenHeight * 0.25);

          _scrollController.animateTo(
            targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  Future<void> _handleGenerateFortune() async {
    debugPrint('🔵 [MBTI-TRACE-1] _handleGenerateFortune() started');

    // Just call generateFortuneAction() directly - it handles ads and loading internally
    try {
      debugPrint('🔵 [MBTI-TRACE-2] Calling generateFortuneAction()');
      await generateFortuneAction();
      debugPrint('🔵 [MBTI-TRACE-3] generateFortuneAction() returned');
    } catch (e, stackTrace) {
      debugPrint('❌ [MbtiFortunePage] Error in _handleGenerateFortune: $e');
      debugPrint('📚 [MbtiFortunePage] Stack trace: $stackTrace');
    }
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      debugPrint('⚠️ [MbtiFortunePage] User not logged in, using fallback fortune');
      return _createFallbackFortune('temp_user_id');
    }

    // Generate random energy level for demonstration
    _energyLevel = 0.5 + (math.Random().nextDouble() * 0.5);

    // Calculate cognitive functions for today (do this early so it's always available)
    _cognitiveFunctions = MbtiCognitiveFunctionsService.calculateDailyCognitiveFunctions(
      _selectedMbti!,
      DateTime.now(),
    );

    debugPrint('🔮 [MbtiFortunePage] Generating fortune for MBTI: $_selectedMbti');

    // Fetch user profile for name and birthDate
    String userName = 'Unknown';
    String userBirthDate = DateTime.now().toIso8601String().split('T')[0];

    try {
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile != null) {
        userName = userProfile.name ?? 'Unknown';
        userBirthDate = userProfile.birthDate?.toIso8601String().split('T')[0] ?? userBirthDate;
        debugPrint('📋 [MbtiFortunePage] User profile loaded: $userName, $userBirthDate');
      } else {
        debugPrint('⚠️ [MbtiFortunePage] User profile is null, using defaults');
      }
    } catch (e) {
      debugPrint('⚠️ [MbtiFortunePage] Failed to load user profile: $e, using defaults');
    }

    // UnifiedFortuneService 사용
    try {
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);
      final categories = _selectedCategories.isNotEmpty ? _selectedCategories : ['종합운'];

      debugPrint('📡 [MbtiFortunePage] Calling UnifiedFortuneService - type: $_selectedMbti, categories: $categories');

      final inputConditions = {
        'mbti_type': _selectedMbti,
        'categories': categories,
        'name': userName,
        'birth_date': userBirthDate,
      };

      // Optimization conditions 생성
      final conditions = MbtiFortuneConditions(
        mbtiType: _selectedMbti!,
        date: DateTime.now(),
      );

      final apiStartTime = DateTime.now();
      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'mbti',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions,
      );
      final apiDuration = DateTime.now().difference(apiStartTime).inMilliseconds;

      debugPrint('✅ [MbtiFortunePage] Fortune loaded successfully in ${apiDuration}ms');
      debugPrint('📊 [MbtiFortunePage] API Response data: ${fortuneResult.data}');

      // API 응답에서 실제 운세 데이터 추출
      final data = fortuneResult.data as Map<String, dynamic>? ?? {};
      final todayFortune = data['today_fortune'] as String? ?? fortuneResult.summary['message'] as String? ?? '오늘은 특별한 하루가 될 것입니다.';
      final luckyItems = data['lucky_items'] as Map<String, dynamic>?;

      // FortuneResult를 Fortune으로 변환
      final fortune = Fortune(
        id: 'mbti_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        type: 'mbti',
        content: fortuneResult.title,
        createdAt: DateTime.now(),
        category: 'mbti',
        overallScore: fortuneResult.score ?? 75,
        description: todayFortune,
        luckyItems: luckyItems,
        metadata: {
          'mbti_type': _selectedMbti,
          'categories': categories,
          'cognitive_functions': _cognitiveFunctions,
          'energy_level': _energyLevel,
          'category_fortunes': data['category_fortunes'],
          'advice': data['advice'],
          'warnings': data['warnings'],
          'api_data': data,
        },
      );

      debugPrint('🔄 [MbtiFortunePage] Returning fortune...');
      return fortune;

    } catch (e, stackTrace) {
      // Log error and return fallback - NEVER throw
      debugPrint('❌ [MbtiFortunePage] API failed with error: $e');
      debugPrint('📚 [MbtiFortunePage] Stack trace: $stackTrace');
      debugPrint('🔄 [MbtiFortunePage] Creating fallback fortune...');
      final fallback = _createFallbackFortune(user.id);
      debugPrint('✅ [MbtiFortunePage] Fallback fortune created: ${fallback.id}');
      return fallback;
    }
  }

  Fortune _createFallbackFortune(String userId) {
    debugPrint('🔄 [MbtiFortunePage] Creating fallback fortune for MBTI: $_selectedMbti');

    return Fortune(
      id: 'mbti_fallback_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'mbti',
      content: 'MBTI ${_selectedMbti!} 타입의 오늘 운세입니다.\n\n오늘은 당신의 고유한 성격 특성이 빛을 발하는 날입니다. ${_selectedMbti!} 타입의 강점을 활용하면 좋은 결과를 얻을 수 있을 것입니다.',
      createdAt: DateTime.now(),
      overallScore: 75,
      description: 'MBTI ${_selectedMbti!} 타입의 오늘 운세입니다.\n\n오늘은 당신의 고유한 성격 특성이 빛을 발하는 날입니다. ${_selectedMbti!} 타입의 강점을 활용하면 좋은 결과를 얻을 수 있을 것입니다.',
      metadata: {
        'mbtiType': _selectedMbti!,
        'categories': _selectedCategories.isNotEmpty ? _selectedCategories : ['종합운'],
        'energyLevel': _energyLevel,
        'compatibility': _getCompatibleTypes(_selectedMbti!),
        'generatedAt': DateTime.now().toIso8601String(),
        'fallback': true,
      }
    );
  }

  // Override build to show MBTI selection UI
  @override
  Widget build(BuildContext context) {
    // If fortune exists, use the parent's build method to show result
    if (fortune != null || isLoading || error != null) {
      return super.build(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show MBTI selection UI
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? (isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white),
      appBar: StandardFortuneAppBar(
        title: widget.title,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content with proper Positioned wrapper
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 100, // Space for FloatingBottomButton
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    _buildTitleSection(),
                    const SizedBox(height: 32),

                    // MBTI Groups Selection
                    _buildMbtiGroupsSection(),

                    // Selected MBTI Info
                    if (_selectedMbti != null) ...[
                      const SizedBox(height: 32),
                      Container(
                        key: _selectedInfoKey,
                        child: _buildSelectedMbtiInfo(),
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySelection(),
                    ],
                  ],
                ),
              ),
            ),

            // Floating Bottom Button
            if (_selectedMbti != null)
              TossFloatingProgressButtonPositioned(
                text: '🧠 내 성격이 말하는 오늘',
                onPressed: canGenerateFortune ? () => _handleGenerateFortune() : null,
                isEnabled: canGenerateFortune,
                showProgress: false,
                isVisible: canGenerateFortune,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 MBTI를\n선택해주세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '16가지 성격 유형 중 나와 맞는 유형을 선택하세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMbtiGroupsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Single accordion header
        GestureDetector(
          onTap: () {
            setState(() {
              _showAllGroups = !_showAllGroups;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _showAllGroups
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showAllGroups
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.3)
                    : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
                width: _showAllGroups ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedMbti == null ? 'MBTI 성격 유형 선택' : _selectedMbti!,
                    style: TypographyUnified.buttonMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
                    ),
                  ),
                ),
                Icon(
                  _showAllGroups ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expandable content - all 4 groups
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showAllGroups
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: _mbtiGroups.entries.map((entry) {
                final groupName = entry.key;
                final types = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _getGroupColor(groupName),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Text(
                            groupName,
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: types.map((mbti) => _buildMbtiCard(mbti)).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildMbtiCard(String mbti) {
    final isSelected = _selectedMbti == mbti;
    final colors = _mbtiColors[mbti]!;
    final icon = _mbtiIcons[mbti]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMbti = isSelected ? null : mbti;
          _selectedCategories.clear(); // Clear categories when MBTI changes
          // MBTI 선택 시 모든 그룹 축소
          _showAllGroups = isSelected; // 선택 해제하면 다시 펼침
        });
        HapticFeedback.mediumImpact();

        // MBTI 선택 시 아래 정보로 자동 스크롤
        if (!isSelected) {
          _scrollToSelectedInfo();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.first : (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? TossDesignSystem.white : (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600),
            ),
            SizedBox(height: 4),
            Text(
              mbti,
              style: TypographyUnified.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? TossDesignSystem.white : (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray700),
              ),
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(0.95, 0.95), duration: 100.ms)
        .then()
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 100.ms),
    );
  }

  Widget _buildSelectedMbtiInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _mbtiColors[_selectedMbti]!;

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedMbti!,
                  style: const TextStyle(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w600,
                    
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getMbtiTitle(_selectedMbti!),
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _getMbtiDescription(_selectedMbti!),
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildCategorySelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운세 카테고리 선택 (선택사항)',
          style: TypographyUnified.buttonMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '원하는 카테고리를 선택하면 더 자세한 운세를 볼 수 있어요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategories.contains(category['label']);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 16,
                    color: isSelected ? TossDesignSystem.white : category['color'],
                  ),
                  const SizedBox(width: 4),
                  Text(category['label']),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category['label']);
                  } else {
                    _selectedCategories.remove(category['label']);
                  }
                });
                HapticFeedback.selectionClick();
              },
              selectedColor: category['color'],
              checkmarkColor: TossDesignSystem.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? TossDesignSystem.white
                    : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight,
              side: BorderSide(
                color: isSelected
                    ? category['color']
                    : (isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Energy Level Card
          _buildEnergyCard(),
          const SizedBox(height: 16),

          // Main Fortune Card
          _buildMainFortuneCard(),
          const SizedBox(height: 16),

          // Category Fortunes
          if (_selectedCategories.isNotEmpty) ...[
            _buildCategoryFortunesCard(),
            const SizedBox(height: 16),
          ],

          // Compatibility
          _buildCompatibilityCard(),

          // Bottom spacing for navigation
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEnergyCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _mbtiColors[_selectedMbti!]!;

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full,
                size: 20,
                color: colors.first),
              SizedBox(width: 8),
              Text(
                '오늘의 에너지 레벨',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _energyLevel,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${(_energyLevel * 100).toInt()}% 충전됨',
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.first,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFortuneCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox();

    final colors = _mbtiColors[_selectedMbti!]!;
    final advice = fortune.metadata?['advice'] as String?;
    final warnings = fortune.metadata?['warnings'] as String?;

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_selectedMbti 오늘의 운세',
              style: const TextStyle(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,

              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fortune.description ?? '오늘은 특별한 하루가 될 것입니다.',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              height: 1.6,
            ),
          ),

          // Advice section
          if (advice != null && advice.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: TossDesignSystem.tossBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '조언',
                          style: TypographyUnified.labelMedium.copyWith(
                            color: TossDesignSystem.tossBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advice,
                          style: TypographyUnified.bodySmall.copyWith(
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Warnings section
          if (warnings != null && warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.warningOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: TossDesignSystem.warningOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주의사항',
                          style: TypographyUnified.labelMedium.copyWith(
                            color: TossDesignSystem.warningOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          warnings,
                          style: TypographyUnified.bodySmall.copyWith(
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildLuckyItems(fortune.luckyItems!),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyItems(Map<String, dynamic> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars,
              size: 20,
              color: TossDesignSystem.warningOrange),
            const SizedBox(width: 8),
            Text(
              '오늘의 행운 아이템',
              style: TypographyUnified.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.entries.map((entry) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TossDesignSystem.warningOrange.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TossDesignSystem.warningOrange.withValues(alpha:0.3)),
            ),
            child: Text(
              '${entry.value}',
              style: TypographyUnified.bodySmall.copyWith(
                color: TossDesignSystem.warningOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCognitiveFunctionsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology,
                size: 20,
                color: TossDesignSystem.tossBlue),
              SizedBox(width: 8),
              Text(
                '인지 기능 분석',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // TODO: Implement cognitive functions radar chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '인지 기능 차트',
                style: TextStyle(
                  color: TossDesignSystem.gray500,
                  
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFortunesCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox();

    // API에서 받은 카테고리별 운세 데이터
    final categoryFortunes = fortune.metadata?['category_fortunes'] as Map<String, dynamic>?;

    return Column(
      children: _selectedCategories.map((category) {
        final categoryInfo = _categories.firstWhere(
          (c) => c['label'] == category,
        );

        // API 응답에서 해당 카테고리 운세 가져오기
        String fortuneText = _getCategoryFortune(category);
        if (categoryFortunes != null) {
          // API 응답 구조: category_fortunes: { "연애운": { "fortune": "...", "score": 85 } }
          final categoryData = categoryFortunes[category] as Map<String, dynamic>?;
          if (categoryData != null && categoryData['fortune'] != null) {
            fortuneText = categoryData['fortune'] as String;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      categoryInfo['icon'],
                      size: 20,
                      color: categoryInfo['color'],
                    ),
                    SizedBox(width: 8),
                    Text(
                      category,
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    // 점수 표시 (있는 경우)
                    if (categoryFortunes != null &&
                        categoryFortunes[category] != null &&
                        categoryFortunes[category]['score'] != null) ...[
                      Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryInfo['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${categoryFortunes[category]['score']}점',
                          style: TypographyUnified.labelSmall.copyWith(
                            color: categoryInfo['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  fortuneText,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompatibilityCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compatibleTypes = _getCompatibleTypes(_selectedMbti!);

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people,
                size: 20,
                color: TossDesignSystem.purple),
              SizedBox(width: 8),
              Text(
                '오늘의 궁합',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: compatibleTypes.map((type) {
              final colors = _mbtiColors[type]!;
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: TossDesignSystem.white,
                          fontWeight: FontWeight.w700,
                          
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getCompatibilityLabel(compatibleTypes.indexOf(type)),
                    style: TypographyUnified.labelMedium.copyWith(
                      color: TossDesignSystem.gray600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool get canGenerateFortune => _selectedMbti != null;

  Color _getGroupColor(String group) {
    switch (group) {
      case '분석가':
        return const Color(0xFF8B5CF6);
      case '외교관':
        return const Color(0xFF10B981);
      case '관리자':
        return const Color(0xFF3B82F6);
      case '탐험가':
        return const Color(0xFFF59E0B);
      default:
        return TossDesignSystem.gray500;
    }
  }

  String _getMbtiTitle(String mbti) {
    const titles = {
      'INTJ': '전략가',
      'INTP': '논리술사',
      'ENTJ': '통솔자',
      'ENTP': '변론가',
      'INFJ': '옹호자',
      'INFP': '중재자',
      'ENFJ': '선도자',
      'ENFP': '활동가',
      'ISTJ': '현실주의자',
      'ISFJ': '수호자',
      'ESTJ': '경영자',
      'ESFJ': '집정관',
      'ISTP': '장인',
      'ISFP': '모험가',
      'ESTP': '사업가',
      'ESFP': '연예인',
    };
    return titles[mbti] ?? mbti;
  }

  String _getMbtiDescription(String mbti) {
    const descriptions = {
      'INTJ': '독립적이고 전략적인 사고를 가진 당신은 오늘 큰 그림을 그리기에 좋은 날입니다.',
      'INTP': '논리적이고 창의적인 당신에게 오늘은 새로운 아이디어가 샘솟는 날입니다.',
      'ENTJ': '리더십이 뛰어난 당신은 오늘 중요한 결정을 내리기에 적합한 날입니다.',
      'ENTP': '도전적이고 혁신적인 당신에게 오늘은 새로운 기회가 찾아올 것입니다.',
      'INFJ': '통찰력이 뛰어난 당신은 오늘 다른 사람들을 도울 수 있는 기회가 있을 것입니다.',
      'INFP': '이상주의적이고 창의적인 당신에게 오늘은 영감이 넘치는 날입니다.',
      'ENFJ': '카리스마 있는 당신은 오늘 주변 사람들에게 긍정적인 영향을 줄 것입니다.',
      'ENFP': '열정적이고 창의적인 당신에게 오늘은 새로운 인연을 만날 수 있는 날입니다.',
      'ISTJ': '신뢰할 수 있고 실용적인 당신은 오늘 중요한 일을 성공적으로 마무리할 것입니다.',
      'ISFJ': '헌신적이고 따뜻한 당신에게 오늘은 소중한 사람들과의 시간이 의미 있을 것입니다.',
      'ESTJ': '효율적이고 실행력이 뛰어난 당신은 오늘 목표를 달성하기에 좋은 날입니다.',
      'ESFJ': '사교적이고 배려심 깊은 당신에게 오늘은 인간관계가 더욱 돈독해지는 날입니다.',
      'ISTP': '실용적이고 모험적인 당신은 오늘 새로운 기술을 배우기에 좋은 날입니다.',
      'ISFP': '예술적이고 유연한 당신에게 오늘은 창의력이 빛나는 날입니다.',
      'ESTP': '활동적이고 현실적인 당신은 오늘 즉흥적인 모험을 즐기기에 좋은 날입니다.',
      'ESFP': '자발적이고 열정적인 당신에게 오늘은 즐거운 일이 가득한 날입니다.',
    };
    return descriptions[mbti] ?? '오늘은 당신에게 특별한 날이 될 것입니다.';
  }

  String _getCategoryFortune(String category) {
    // This would be replaced with actual fortune data from API
    const fortunes = {
      '연애운': '오늘은 사랑하는 사람과의 관계가 더욱 깊어질 수 있는 날입니다. 진심을 담은 대화를 나눠보세요.',
      '직업운': '새로운 프로젝트나 기회가 찾아올 수 있습니다. 적극적으로 도전해보세요.',
      '재물운': '예상치 못한 수입이 있을 수 있습니다. 하지만 충동적인 소비는 피하세요.',
      '건강운': '컨디션이 좋은 날입니다. 운동이나 야외 활동을 즐겨보세요.',
      '대인관계': '주변 사람들과의 관계가 원만해집니다. 새로운 인연도 기대해보세요.',
      '학업운': '집중력이 높아지는 날입니다. 어려운 문제도 해결할 수 있을 것입니다.',
    };
    return fortunes[category] ?? '오늘은 $category이 좋은 날입니다.';
  }

  List<String> _getCompatibleTypes(String mbti) {
    // Simplified compatibility logic
    const compatibility = {
      'INTJ': ['ENTP', 'ENFP'],
      'INTP': ['ENTJ', 'ESTJ'],
      'ENTJ': ['INTP', 'ISTP'],
      'ENTP': ['INTJ', 'INFJ'],
      'INFJ': ['ENTP', 'ENFP'],
      'INFP': ['ENFJ', 'ENTJ'],
      'ENFJ': ['INFP', 'ISFP'],
      'ENFP': ['INTJ', 'INFJ'],
      'ISTJ': ['ESFP', 'ESTP'],
      'ISFJ': ['ESFP', 'ESTP'],
      'ESTJ': ['INTP', 'ISTP'],
      'ESFJ': ['ISFP', 'ISTP'],
      'ISTP': ['ESTJ', 'ENTJ'],
      'ISFP': ['ENFJ', 'ESFJ'],
      'ESTP': ['ISTJ', 'ISFJ'],
      'ESFP': ['ISTJ', 'ISFJ'],
    };
    return compatibility[mbti] ?? ['INFJ', 'ENFP'];
  }

  String _getCompatibilityLabel(int index) {
    return index == 0 ? '최고궁합' : '좋은궁합';
  }
}