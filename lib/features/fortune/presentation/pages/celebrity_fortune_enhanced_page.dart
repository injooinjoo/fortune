import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/celebrity_provider.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../data/models/celebrity_simple.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/fortune_card.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/fortune_loading_skeleton.dart';
import '../widgets/fortune_button.dart';
import '../../../../core/theme/toss_design_system.dart';

class CelebrityFortuneEnhancedPage extends ConsumerStatefulWidget {
  const CelebrityFortuneEnhancedPage({super.key});

  @override
  ConsumerState<CelebrityFortuneEnhancedPage> createState() => _CelebrityFortuneEnhancedPageState();
}

class _CelebrityFortuneEnhancedPageState extends ConsumerState<CelebrityFortuneEnhancedPage> {
  int _currentStep = 0;
  CelebrityType? _selectedCategory;
  Celebrity? _selectedCelebrity;
  String _connectionType = 'ideal_match'; // ideal_match, compatibility, career_advice
  String _questionType = 'love'; // love, career, personality, future
  
  bool _isLoading = false;
  Fortune? _fortune;
  late PageController _pageController;
  
  // Search related
  final _searchController = TextEditingController();
  List<Celebrity> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundSecondary,
      appBar: const StandardFortuneAppBar(
        title: '유명인 운세',
      ),
      body: _fortune != null
          ? _buildResultScreen()
          : _buildInputScreen(),
    );
  }

  Widget _buildInputScreen() {
    return Stack(
      children: [
        Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Step content
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStep1CategorySelection(),
                  _buildStep2CelebritySelection(),
                  _buildStep3QuestionType(),
                ],
              ),
            ),

            // 버튼 높이만큼 여백 확보
            const BottomButtonSpacing(),
          ],
        ),

        // Floating 버튼
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: TossTheme.backgroundWhite,
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? TossTheme.primaryBlue : TossTheme.backgroundSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1CategorySelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 분야의 유명인과\n궁합을 보고 싶으신가요?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: TossTheme.textBlack,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '관심 있는 분야를 선택해주세요',
            style: TextStyle(
              fontSize: 15,
              color: TossTheme.textGray500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          
          // All categories option
          _buildCategoryCard(null, '전체', '모든 분야의 유명인', Icons.star),
          const SizedBox(height: 12),
          
          // Individual categories
          ...CelebrityType.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(
                category, 
                category.displayName,
                _getCategoryDescription(category),
                _getCategoryIcon(category),
              ),
            );
          }).toList(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildCategoryCard(CelebrityType? category, String title, String description, IconData icon) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        // 카테고리 선택 후 자동으로 다음 페이지로 이동
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.08) : TossTheme.backgroundWhite,
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? TossTheme.primaryBlue : TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? TossDesignSystem.white : TossTheme.textGray500,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? TossTheme.primaryBlue : TossTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: TossTheme.textGray500,
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
    );
  }

  Widget _buildStep2CelebritySelection() {
    final celebritiesAsyncValue = _selectedCategory != null
        ? ref.watch(celebritiesByCategoryProvider(_selectedCategory!))
        : ref.watch(allCelebritiesProvider);
    
    return celebritiesAsyncValue.when(
      data: (celebrities) => _buildCelebritySelectionContent(celebrities),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }
  
  // 검색 수행 메소드
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    final searchNotifier = ref.read(celebritySearchProvider.notifier);
    await searchNotifier.search(query: query, limit: 20);
    
    final searchResults = ref.read(celebritySearchProvider);
    searchResults.when(
      data: (results) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      },
      loading: () => setState(() => _isSearching = true),
      error: (error, stack) {
        setState(() => _isSearching = false);
        Logger.error('Celebrity search failed', error);
      },
    );
  }

  Widget _buildCelebritySelectionContent(List<Celebrity> celebrities) {
    // 검색 결과가 있으면 검색 결과를 표시, 없으면 전체 목록 표시
    final displayCelebrities = _searchResults.isNotEmpty 
        ? _searchResults.take(20).toList()
        : celebrities.take(20).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '궁합을 보고 싶은\n유명인을 선택해주세요',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: TossTheme.textBlack,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '선택한 유명인과의 운세를 분석해드려요',
            style: TextStyle(
              fontSize: 15,
              color: TossTheme.textGray500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          
          // Search bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              style: TextStyle(
                fontSize: 15,
                color: TossTheme.textBlack,
              ),
              decoration: InputDecoration(
                hintText: '이름으로 검색',
                hintStyle: TextStyle(
                  color: TossTheme.textGray400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: TossTheme.textGray400,
                  size: 20,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Celebrity grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: displayCelebrities.length,
            itemBuilder: (context, index) {
              final celebrity = displayCelebrities[index];
              final isSelected = _selectedCelebrity?.id == celebrity.id;
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCelebrity = celebrity);
                  // 유명인 선택 후 자동으로 다음 페이지로 이동
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted && _selectedCelebrity != null) {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.08) : TossTheme.backgroundWhite,
                    border: Border.all(
                      color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Celebrity avatar
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _getCelebrityColor(celebrity.name),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                celebrity.name.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: TossDesignSystem.white,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: TossDesignSystem.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: TossTheme.primaryBlue,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Celebrity info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                celebrity.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? TossTheme.primaryBlue : TossTheme.textBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                celebrity.celebrityType.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TossTheme.textGray500,
                                ),
                              ),
                              if (celebrity.age != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${celebrity.age}세',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TossTheme.textGray400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildStep3QuestionType() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 것이 궁금하신가요?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: TossTheme.textBlack,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_selectedCelebrity?.name ?? '선택한 유명인'}님과의 관계에서\n궁금한 부분을 선택해주세요',
            style: TextStyle(
              fontSize: 15,
              color: TossTheme.textGray500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          
          // Connection type
          Text(
            '관계 유형',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildConnectionOption('ideal_match', '이상형 매치', '나와 잘 맞는 이상형인지 알아보기', Icons.favorite),
          const SizedBox(height: 12),
          _buildConnectionOption('compatibility', '전체 궁합', '종합적인 궁합 점수와 분석', Icons.people),
          const SizedBox(height: 12),
          _buildConnectionOption('career_advice', '조언 구하기', '인생과 진로에 대한 조언', Icons.lightbulb_outline),
          
          const SizedBox(height: 32),
          
          // Question type
          Text(
            '궁금한 영역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildQuestionOption('love', '연애운', '사랑과 인간관계에 대해', Icons.favorite_border),
          const SizedBox(height: 12),
          _buildQuestionOption('career', '사업운', '일과 성공에 대해', Icons.work_outline),
          const SizedBox(height: 12),
          _buildQuestionOption('personality', '성격 분석', '나의 성격과 특징', Icons.psychology),
          const SizedBox(height: 12),
          _buildQuestionOption('future', '미래 전망', '앞으로의 운세와 기회', Icons.trending_up),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildConnectionOption(String value, String title, String description, IconData icon) {
    final isSelected = _connectionType == value;
    return GestureDetector(
      onTap: () => setState(() => _connectionType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.05) : TossDesignSystem.white,
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? TossTheme.primaryBlue : TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? TossDesignSystem.white : TossTheme.textGray600, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TossTheme.textBlack,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: TossTheme.textGray600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: TossTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionOption(String value, String title, String description, IconData icon) {
    final isSelected = _questionType == value;
    return GestureDetector(
      onTap: () => setState(() => _questionType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFF6B6B).withValues(alpha: 0.05) : TossDesignSystem.white,
          border: Border.all(
            color: isSelected ? Color(0xFFFF6B6B) : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFFF6B6B) : TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? TossDesignSystem.white : TossTheme.textGray600, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TossTheme.textBlack,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: TossTheme.textGray600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Color(0xFFFF6B6B), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final canProceed = (_currentStep == 0 && _selectedCategory != null) ||
                      (_currentStep == 1 && _selectedCelebrity != null) ||
                      (_currentStep == 2);

    // 이전/다음 버튼이 있는 경우 Row로 구성
    if (_currentStep > 0) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TossButton(
                  text: '이전',
                  style: TossButtonStyle.secondary,
                  size: TossButtonSize.large,
                  onPressed: () {
                    _pageController.animateToPage(
                      _currentStep - 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TossButton(
                  text: _currentStep < 2 ? '다음' : _isLoading ? '운세 생성 중...' : '운세 보기',
                  isLoading: _isLoading,
                  size: TossButtonSize.large,
                  onPressed: canProceed ? _handleButtonPress : null,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 첫 번째 스텝에서는 단일 버튼
    return FloatingBottomButton(
      text: '다음',
      isLoading: _isLoading,
      onPressed: canProceed ? _handleButtonPress : null,
    );
  }

  void _handleButtonPress() {
    if (_currentStep < 2) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _generateFortune();
    }
  }

  Future<void> _generateFortune() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final userProfile = await ref.read(userProfileProvider.future);
      
      final params = {
        'celebrity_id': _selectedCelebrity?.id,
        'celebrity_name': _selectedCelebrity?.name,
        'connection_type': _connectionType,
        'question_type': _questionType,
        'category': _selectedCategory?.name,
        'name': userProfile?.name ?? '사용자',
        'birthDate': userProfile?.birthDate?.toIso8601String(),
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: 'celebrity',
        userId: user.id,
        params: params,
      );

      setState(() {
        _fortune = fortune;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Logger.error('유명인운세 생성 실패', e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('운세 생성에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: TossDesignSystem.error,
          ),
        );
      }
    }
  }

  Widget _buildResultScreen() {
    if (_fortune == null) return const SizedBox();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
          // Celebrity info header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TossDesignSystem.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.04),
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
                    color: _getCelebrityColor(_selectedCelebrity?.name ?? ''),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      _selectedCelebrity?.name.substring(0, 1) ?? '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedCelebrity?.name}님과의 궁합',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TossTheme.textBlack,
                        ),
                      ),
                      Text(
                        _getConnectionTypeText(_connectionType),
                        style: TextStyle(
                          fontSize: 14,
                          color: TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(_fortune!.score).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_fortune!.score}점',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _getScoreColor(_fortune!.score),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Main fortune message
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TossDesignSystem.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFF6B6B),
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  _fortune!.message,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: TossTheme.textGray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Recommendations
          if (_fortune!.recommendations?.isNotEmpty ?? false) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TossDesignSystem.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: TossTheme.primaryBlue, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '추천 조언',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: TossTheme.textBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(_fortune!.recommendations ?? []).map((advice) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: TossTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            advice,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: TossTheme.textGray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

              // 버튼 높이만큼 여백 확보
              const BottomButtonSpacing(),
            ],
          ),
        ),

        // Floating 버튼
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TossButton(
                    text: '다시 해보기',
                    style: TossButtonStyle.secondary,
                    onPressed: () => setState(() {
                      _fortune = null;
                      _currentStep = 0;
                      _selectedCelebrity = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TossButton(
                    text: '공유하기',
                    onPressed: () {
                      // TODO: 공유 기능 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('공유 기능이 곧 추가될 예정입니다')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  String _getCategoryDescription(CelebrityType category) {
    switch (category) {
      case CelebrityType.actor:
        return '배우, 탤런트, 영화배우';
      case CelebrityType.soloSinger:
        return '솔로 가수, 뮤지션';
      case CelebrityType.idolMember:
        return '아이돌 멤버, 그룹 가수';
      case CelebrityType.politician:
        return '정치인, 공인, 사회인사';
      case CelebrityType.athlete:
        return '운동선수, 스포츠 스타';
      case CelebrityType.streamer:
        return '스트리머, 인플루언서';
      case CelebrityType.proGamer:
        return '프로게이머, 이스포츠 선수';
      case CelebrityType.business:
        return '기업인, 경영자';
      default:
        return '다양한 분야의 유명인';
    }
  }

  IconData _getCategoryIcon(CelebrityType category) {
    switch (category) {
      case CelebrityType.actor:
        return Icons.movie;
      case CelebrityType.soloSinger:
        return Icons.music_note;
      case CelebrityType.idolMember:
        return Icons.groups;
      case CelebrityType.politician:
        return Icons.account_balance;
      case CelebrityType.athlete:
        return Icons.sports;
      case CelebrityType.streamer:
        return Icons.tv;
      case CelebrityType.proGamer:
        return Icons.sports_esports;
      case CelebrityType.business:
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  Color _getCelebrityColor(String name) {
    final colors = [
      Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1),
      Color(0xFF96CEB4), Color(0xFFDDA0DD), Color(0xFFFFD93D),
      Color(0xFF6C5CE7), Color(0xFFFD79A8), Color(0xFF00B894),
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getConnectionTypeText(String type) {
    switch (type) {
      case 'ideal_match':
        return '이상형 매치';
      case 'compatibility':
        return '전체 궁합';
      case 'career_advice':
        return '조언 구하기';
      default:
        return '궁합 분석';
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.success;
    if (score >= 60) return TossTheme.primaryBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.error;
  }

  Widget _buildLoadingState() {
    return FortuneLoadingSkeleton(
      itemCount: 2,
      showHeader: false,
      loadingMessages: [
        '유명인 정보를 불러오고 있어요...',
        '데이터베이스에서 검색 중...',
        '인기 유명인을 찾는 중...',
      ],
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: FortuneCard(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: TossTheme.textGray600,
            ),
            const SizedBox(height: 24),
            Text(
              '유명인 정보를 불러올 수 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TossTheme.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '잠시 후 다시 시도해주세요',
              style: TextStyle(
                fontSize: 14,
                color: TossTheme.textGray500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FortuneButton.retry(
              onPressed: () {
                // Refresh the provider
                ref.refresh(allCelebritiesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}