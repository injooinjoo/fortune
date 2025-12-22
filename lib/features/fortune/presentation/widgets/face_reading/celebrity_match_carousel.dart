import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';

/// Celebrity Match Carousel
/// 닮은꼴 연예인 스와이프 캐러셀
class CelebrityMatchCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> celebrities;
  final bool isBlurred;
  final VoidCallback? onUnlockRequested;

  const CelebrityMatchCarousel({
    super.key,
    required this.celebrities,
    this.isBlurred = false,
    this.onUnlockRequested,
  });

  @override
  State<CelebrityMatchCarousel> createState() => _CelebrityMatchCarouselState();
}

class _CelebrityMatchCarouselState extends State<CelebrityMatchCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.celebrities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  DSColors.backgroundSecondary.withValues(alpha: 0.5),
                  DSColors.surface.withValues(alpha: 0.5),
                ]
              : [
                  DSColors.warning.withValues(alpha: 0.05),
                  Colors.amber.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DSColors.warning, Colors.amber],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: DSColors.warning.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '닮은꼴 유명인',
                        style: DSTypography.headingSmall.copyWith(
                          color: isDark
                              ? DSColors.textPrimary
                              : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '스와이프하여 더 보기',
                        style: DSTypography.labelSmall.copyWith(
                          color: isDark
                              ? DSColors.textSecondary
                              : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 페이지 인디케이터
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.celebrities.length}',
                    style: DSTypography.labelSmall.copyWith(
                      color: DSColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 캐러셀
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.celebrities.length,
              itemBuilder: (context, index) {
                final celebrity = widget.celebrities[index];
                return _buildCelebrityCard(celebrity, index, isDark);
              },
            ),
          ),

          const SizedBox(height: 16),

          // 페이지 도트 인디케이터
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.celebrities.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? DSColors.warning
                        : (isDark
                            ? DSColors.textTertiary
                            : DSColors.textTertiary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildCelebrityCard(
    Map<String, dynamic> celebrity,
    int index,
    bool isDark,
  ) {
    final name = celebrity['celebrity_name']?.toString() ??
        celebrity['name']?.toString() ??
        '유명인';
    final type = celebrity['celebrity_type']?.toString() ??
        celebrity['occupation']?.toString() ??
        '연예인';
    final similarityScore = celebrity['similarity_score'] ?? 0;
    final matchedFeatures = (celebrity['matched_features'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (celebrity['similar_parts']?.toString().split(',') ?? []);
    final characterImageUrl = celebrity['character_image_url']?.toString();
    final reason =
        celebrity['reason']?.toString() ?? '비슷한 관상 특징을 가지고 있습니다.';

    // 타입별 색상
    final Color accentColor = _getAccentColor(type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DSColors.backgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // 캐릭터 이미지 또는 이니셜 아바타
                  _buildAvatar(name, characterImageUrl, accentColor),

                  const SizedBox(width: 16),

                  // 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 이름
                        Text(
                          name,
                          style: DSTypography.headingSmall.copyWith(
                            color: isDark
                                ? DSColors.textPrimary
                                : DSColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 타입 배지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTypeLabel(type),
                            style: DSTypography.labelSmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 유사도 점수
                        if (similarityScore > 0) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: DSColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '유사도 $similarityScore%',
                                style: DSTypography.bodyMedium.copyWith(
                                  color: DSColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // 닮은 부위 태그
                        if (matchedFeatures.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: matchedFeatures.take(4).map((feature) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? DSColors.border
                                      : DSColors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  feature.trim(),
                                  style: DSTypography.labelSmall.copyWith(
                                    color: isDark
                                        ? DSColors.textSecondary
                                        : DSColors.textSecondary,
                                    fontSize: 11, // 예외: 초소형 특징 태그
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        // 이유
                        if (reason.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            reason,
                            style: DSTypography.bodySmall.copyWith(
                              color: isDark
                                  ? DSColors.textSecondary
                                  : DSColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 순위 배지
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: index == 0
                        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                        : index == 1
                            ? [const Color(0xFFC0C0C0), const Color(0xFF808080)]
                            : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: DSTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.2);
  }

  Widget _buildAvatar(String name, String? imageUrl, Color accentColor) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            // 로딩 상태 표시
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: accentColor.withValues(alpha: 0.1),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildInitialAvatar(name, accentColor);
            },
          ),
        ),
      );
    }

    return _buildInitialAvatar(name, accentColor);
  }

  Widget _buildInitialAvatar(String name, Color accentColor) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor, accentColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: DSTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _getAccentColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('actor') || lowerType.contains('배우')) {
      return DSColors.accentSecondary;
    } else if (lowerType.contains('singer') ||
        lowerType.contains('idol') ||
        lowerType.contains('가수') ||
        lowerType.contains('아이돌')) {
      return DSColors.accent;
    } else if (lowerType.contains('athlete') ||
        lowerType.contains('운동') ||
        lowerType.contains('스포츠')) {
      return DSColors.success;
    } else if (lowerType.contains('streamer') ||
        lowerType.contains('gamer') ||
        lowerType.contains('게이머')) {
      return const Color(0xFF9146FF); // Twitch purple
    } else if (lowerType.contains('business') || lowerType.contains('기업')) {
      return const Color(0xFF2C3E50);
    } else if (lowerType.contains('politician') || lowerType.contains('정치')) {
      return const Color(0xFF1ABC9C);
    } else {
      return DSColors.warning;
    }
  }

  String _getTypeLabel(String type) {
    final typeMap = {
      'actor': '배우',
      'solo_singer': '솔로 가수',
      'idol_member': '아이돌',
      'athlete': '운동선수',
      'pro_gamer': '프로게이머',
      'streamer': '스트리머',
      'business': '기업인',
      'politician': '정치인',
    };
    return typeMap[type.toLowerCase()] ?? type;
  }
}
