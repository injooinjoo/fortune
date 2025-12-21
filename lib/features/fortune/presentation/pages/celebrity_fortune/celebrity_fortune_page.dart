import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../presentation/providers/fortune_provider.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../domain/entities/fortune.dart';
import '../../../../../data/models/celebrity_simple.dart';
import '../../../../../core/utils/logger.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import 'widgets/widgets.dart';

class CelebrityFortuneEnhancedPage extends ConsumerStatefulWidget {
  const CelebrityFortuneEnhancedPage({super.key});

  @override
  ConsumerState<CelebrityFortuneEnhancedPage> createState() => _CelebrityFortuneEnhancedPageState();
}

class _CelebrityFortuneEnhancedPageState extends ConsumerState<CelebrityFortuneEnhancedPage> {
  int _currentStep = 0;
  CelebrityType? _selectedCategory;
  Celebrity? _selectedCelebrity;
  String _connectionType = 'ideal_match';
  String _questionType = 'love';

  bool _isLoading = false;
  Fortune? _fortune;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isResultScreen = _fortune != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: isResultScreen
          ? AppBar(
              backgroundColor: colors.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                '유명인 궁합',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.close, color: colors.textPrimary),
                  onPressed: () => context.pop(),
                ),
              ],
            )
          : const StandardFortuneAppBar(
              title: '유명인',
            ),
      body: isResultScreen
          ? CelebrityResultScreen(
              fortune: _fortune!,
              selectedCelebrity: _selectedCelebrity,
              connectionType: _connectionType,
              onReset: () => setState(() {
                _fortune = null;
                _currentStep = 0;
                _selectedCelebrity = null;
              }),
            )
          : _buildInputScreen(),
    );
  }

  Widget _buildInputScreen() {
    return Stack(
      children: [
        PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentStep = index;
            });
          },
          children: [
            CategorySelectionStep(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) => setState(() => _selectedCategory = category),
            ),
            CelebritySelectionStep(
              selectedCategory: _selectedCategory,
              selectedCelebrity: _selectedCelebrity,
              onCelebritySelected: (celebrity) => setState(() => _selectedCelebrity = celebrity),
            ),
            QuestionTypeStep(
              selectedCelebrityName: _selectedCelebrity?.name,
              connectionType: _connectionType,
              questionType: _questionType,
              onConnectionTypeChanged: (value) => setState(() => _connectionType = value),
              onQuestionTypeChanged: (value) => setState(() => _questionType = value),
            ),
          ],
        ),

        // Floating 버튼
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildBottomButton() {
    final canProceed = (_currentStep == 0 && _selectedCategory != null) ||
                      (_currentStep == 1 && _selectedCelebrity != null) ||
                      (_currentStep == 2);

    final buttonText = _currentStep < 2
        ? '다음'
        : (_isLoading ? '운세 생성 중...' : '운세 보기');

    return UnifiedButton.progress(
      text: buttonText,
      currentStep: _currentStep + 1,
      totalSteps: 3,
      onPressed: canProceed ? _handleButtonPress : null,
      isEnabled: canProceed,
      isFloating: true,
      isLoading: _isLoading,
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
            backgroundColor: DSColors.error,
          ),
        );
      }
    }
  }
}
