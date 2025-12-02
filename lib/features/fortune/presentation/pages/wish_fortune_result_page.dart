import 'dart:ui'; // ✅ ImageFilter.blur용

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/wish_fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
// ✅ FloatingBottomButton용
import '../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../core/utils/logger.dart'; // ✅ 로그용
import '../../../../presentation/providers/token_provider.dart'; // ✅ Premium 체크용

/// 소원 빌기 결과 페이지 (공감/희망/조언/응원 중심)
class WishFortuneResultPage extends ConsumerStatefulWidget {
  final WishFortuneResult result;
  final String wishText;
  final String category;

  const WishFortuneResultPage({
    super.key,
    required this.result,
    required this.wishText,
    required this.category,
  });

  @override
  ConsumerState<WishFortuneResultPage> createState() => _WishFortuneResultPageState();
}

class _WishFortuneResultPageState extends ConsumerState<WishFortuneResultPage> {
  late PageController _pageController;
  int _currentPage = 0;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);

    // 페이지 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Navigation bar is automatically hidden by Scaffold structure

        // ✅ Premium 체크 및 Blur 상태 설정
        final tokenState = ref.read(tokenProvider);
        final isPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;

        setState(() {
          _isBlurred = !isPremium;
          _blurredSections = _isBlurred
              ? ['advice', 'encouragement', 'specialWords']
              : [];
        });

        debugPrint('🔒 [소원운세] isPremium: $isPremium, isBlurred: $_isBlurred, blurredSections: $_blurredSections');
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
            top: MediaQuery.of(context).padding.top + 8,
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

          // 닫기 버튼 (우측 상단)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => context.go('/fortune'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
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

          // ✅ FloatingBottomButton (블러 상태일 때만 표시)
          if (_isBlurred)
            UnifiedButton.floating(
              text: '광고 보고 전체 내용 확인하기',
              onPressed: _showAdAndUnblur,
              isEnabled: true,
            ),
        ],
      ),
    );
  }

  /// 풀사이즈 카드 빌더
  Widget _buildFullSizeCard(BuildContext context, int index, bool isDark) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 블러 상태일 때 버튼 공간 확보 (버튼 높이 56 + 여유 20)
    final bottomMargin = _isBlurred ? bottomPadding + 120 : bottomPadding + 60;

    return Container(
      height: double.infinity,
      margin: EdgeInsets.fromLTRB(20, topPadding + 40, 20, bottomMargin),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildCardContent(context, index, isDark),
        ),
      ),
    );
  }

  /// 카드 내용 빌더 (5장)
  Widget _buildCardContent(BuildContext context, int index, bool isDark) {
    switch (index) {
      case 0:
        // 무료 섹션 1: 공감 카드
        return _buildEmpathyCard(isDark);
      case 1:
        // 무료 섹션 2: 희망 카드
        return _buildHopeCard(isDark);
      case 2:
        // Premium 섹션 3: 조언 카드
        return _buildBlurWrapper(
          sectionKey: 'advice',
          child: _buildAdviceCard(isDark),
        );
      case 3:
        // Premium 섹션 4: 응원 카드
        return _buildBlurWrapper(
          sectionKey: 'encouragement',
          child: _buildEncouragementCard(isDark),
        );
      case 4:
        // Premium 섹션 5: 신의 한마디 카드
        return _buildBlurWrapper(
          sectionKey: 'specialWords',
          child: _buildSpecialWordsCard(isDark),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 1. 공감 카드
  Widget _buildEmpathyCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(flex: 2),

        // 하트 이모지
        Text(
          '💝',
          style: const TextStyle(fontSize: 56),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const Spacer(flex: 1),

        // 제목
        Text(
          '당신의 마음이 느껴져요',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 20),

        // 공감 메시지
        Flexible(
          flex: 3,
          child: Text(
            widget.result.empathyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        ),

        const Spacer(flex: 2),
      ],
    );
  }

  /// 2. 희망 카드
  Widget _buildHopeCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(flex: 2),

        // 별 이모지
        Text(
          '✨',
          style: const TextStyle(fontSize: 56),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const Spacer(flex: 1),

        // 제목
        Text(
          '당신은 할 수 있어요',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 20),

        // 희망 메시지
        Flexible(
          flex: 3,
          child: Text(
            widget.result.hopeMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        ),

        const Spacer(flex: 2),
      ],
    );
  }

  /// 3. 조언 카드
  Widget _buildAdviceCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(flex: 1),

        // 전구 이모지
        Text(
          '💡',
          style: const TextStyle(fontSize: 48),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const SizedBox(height: 16),

        // 제목
        Text(
          '이렇게 해보세요',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 20),

        // 조언 3개
        Flexible(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.result.advice.asMap().entries.map((entry) {
              final index = entry.key;
              final advice = entry.value;

              return Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: TossDesignSystem.tossBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          advice,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: 0.3, end: 0),
              );
            }).toList(),
          ),
        ),

        const Spacer(flex: 1),
      ],
    );
  }

  /// 4. 응원 카드
  Widget _buildEncouragementCard(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(flex: 2),

        // 응원 이모지
        Text(
          '🙌',
          style: const TextStyle(fontSize: 56),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms),

        const Spacer(flex: 1),

        // 제목
        Text(
          '힘내세요!',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 20),

        // 응원 메시지
        Flexible(
          flex: 3,
          child: Text(
            widget.result.encouragement,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        ),

        const Spacer(flex: 2),
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
        mainAxisSize: MainAxisSize.max,
        children: [
          const Spacer(flex: 2),

          // 신비로운 이모지
          Text(
            '🔮',
            style: const TextStyle(fontSize: 56),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(duration: 1500.ms),

          const Spacer(flex: 1),

          // 제목
          const Text(
            '신이 전하는 한마디',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 20),

          // 특별한 한마디
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '"${widget.result.specialWords}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // ✅ RewardedAd 패턴
  Future<void> _showAdAndUnblur() async {
    debugPrint('[소원운세] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[소원운세] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[소원운세] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[소원운세] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[소원운세] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  // ✅ Blur wrapper helper
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
