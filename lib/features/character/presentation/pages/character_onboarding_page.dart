import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../services/storage_service.dart';

/// 캐릭터 채팅 온보딩 페이지
/// 3장 슬라이드로 기능 안내
class CharacterOnboardingPage extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const CharacterOnboardingPage({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<CharacterOnboardingPage> createState() =>
      _CharacterOnboardingPageState();
}

class _CharacterOnboardingPageState
    extends ConsumerState<CharacterOnboardingPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.theater_comedy_outlined,
      title: '친구와 상황극을 즐겨보세요',
      description: '각 친구마다 다양한 상황과 스토리가 준비되어 있어요.\n대화를 통해 이야기를 이끌어가세요.',
    ),
    _OnboardingSlide(
      icon: Icons.favorite_outline,
      title: '관계가 깊어질수록\n관계 점수가 올라가요',
      description: '친구와 대화할수록 관계 점수가 상승해요.\n더 깊은 이야기를 나눌 수 있게 돼요.',
    ),
    _OnboardingSlide(
      icon: Icons.edit_outlined,
      title: '새 친구를 만나고 싶다면\n상단의 새로운 친구를 눌러보세요',
      description: '추천 친구를 고르거나 직접 만들어서\n새로운 대화를 시작해보세요.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await _storageService.setCharacterOnboardingCompleted();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned(
            top: -72,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface.withValues(alpha: 0.56),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        '건너뛰기',
                        style: typography.labelLarge.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '대화를 더 자연스럽게 시작하는 방법',
                    style: typography.headingMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '처음엔 간단하게 둘러보고, 마음에 드는 흐름부터 시작하면 됩니다.',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return _buildSlide(context, slide, colors);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildIndicator(index, colors),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: DSButton.primary(
                    text: _currentPage == _slides.length - 1 ? '시작하기' : '다음',
                    onPressed: _nextPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    _OnboardingSlide slide,
    DSColorScheme colors,
  ) {
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(context.radius.xxl),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.68),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.8),
                ),
              ),
              child: Icon(
                slide.icon,
                size: 48,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: typography.headingMedium.copyWith(
                color: colors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: typography.bodyLarge.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, DSColorScheme colors) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? colors.ctaBackground : colors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}
