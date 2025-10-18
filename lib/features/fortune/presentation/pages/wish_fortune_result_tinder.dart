import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/wish_fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 틴더 스타일 소원 빌기 결과 페이지 (공감/희망/조언/응원 중심)
class WishFortuneResultTinder extends ConsumerStatefulWidget {
  final WishFortuneResult result;
  final String wishText;
  final String category;
  final int urgency;

  const WishFortuneResultTinder({
    super.key,
    required this.result,
    required this.wishText,
    required this.category,
    required this.urgency,
  });

  @override
  ConsumerState<WishFortuneResultTinder> createState() => _WishFortuneResultTinderState();
}

class _WishFortuneResultTinderState extends ConsumerState<WishFortuneResultTinder> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);

    // 페이지 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Navigation bar is automatically hidden by Scaffold structure
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // PageView (틴더 카드 스타일 - 5장)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildFullSizeCard(context, index, isDark);
              },
            ),
          ),

          // 프로그레스 바 (맨 위)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: (_currentPage + 1) / 5,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // 닫기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),

          // 페이지 인디케이터 (중앙 하단)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? TossDesignSystem.tossBlue
                          : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 풀사이즈 카드 빌더
  Widget _buildFullSizeCard(BuildContext context, int index, bool isDark) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: double.infinity,
      margin: EdgeInsets.fromLTRB(20, topPadding + 60, 20, 80),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: _buildCardContent(context, index, isDark),
        ),
      ),
    );
  }

  /// 카드 내용 빌더 (5장)
  Widget _buildCardContent(BuildContext context, int index, bool isDark) {
    switch (index) {
      case 0:
        return _buildEmpathyCard(isDark);
      case 1:
        return _buildHopeCard(isDark);
      case 2:
        return _buildAdviceCard(isDark);
      case 3:
        return _buildEncouragementCard(isDark);
      case 4:
        return _buildSpecialWordsCard(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 1. 공감 카드
  Widget _buildEmpathyCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // 하트 이모지
        Text(
          '💝',
          style: TypographyUnified.displayLarge,
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const SizedBox(height: 40),

        // 제목
        Text(
          '당신의 마음이 느껴져요',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 32),

        // 공감 메시지
        Text(
          widget.result.empathyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 60),
      ],
    );
  }

  /// 2. 희망 카드
  Widget _buildHopeCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // 별 이모지
        Text(
          '✨',
          style: TypographyUnified.displayLarge,
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const SizedBox(height: 40),

        // 제목
        Text(
          '당신은 할 수 있어요',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 32),

        // 희망 메시지
        Text(
          widget.result.hopeMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 60),
      ],
    );
  }

  /// 3. 조언 카드
  Widget _buildAdviceCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // 전구 이모지
        Text(
          '💡',
          style: TypographyUnified.displayLarge,
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const SizedBox(height: 40),

        // 제목
        Text(
          '이렇게 해보세요',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 40),

        // 조언 3개
        ...widget.result.advice.asMap().entries.map((entry) {
          final index = entry.key;
          final advice = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    advice,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: 0.3, end: 0);
        }),

        const SizedBox(height: 40),
      ],
    );
  }

  /// 4. 응원 카드
  Widget _buildEncouragementCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // 응원 이모지
        Text(
          '🙌',
          style: TypographyUnified.displayLarge,
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const SizedBox(height: 40),

        // 제목
        Text(
          '힘내세요!',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 32),

        // 응원 메시지
        Text(
          widget.result.encouragement,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 60),
      ],
    );
  }

  /// 5. 신의 한마디 카드
  Widget _buildSpecialWordsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TossDesignSystem.tossBlue,
            TossDesignSystem.tossBlue.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // 신비로운 이모지
          Text(
            '🔮',
            style: TypographyUnified.displayLarge,
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(duration: 1500.ms),

          const SizedBox(height: 40),

          // 제목
          const Text(
            '신이 전하는 한마디',
            style: TextStyle(
              color: Colors.white,
              
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 32),

          // 특별한 한마디
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '"${widget.result.specialWords}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                
                height: 1.6,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
