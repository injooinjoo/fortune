import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/services/fashion_image_service.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../../../../presentation/providers/ad_provider.dart';
import '../../../../../../core/services/fortune_haptic_service.dart';

/// 패션 이미지 생성 Provider
final fashionImageProvider = StateNotifierProvider.autoDispose<
    FashionImageNotifier, AsyncValue<FashionImageResult?>>((ref) {
  return FashionImageNotifier();
});

class FashionImageNotifier extends StateNotifier<AsyncValue<FashionImageResult?>> {
  FashionImageNotifier() : super(const AsyncValue.data(null));

  final _service = FashionImageService();

  Future<void> generateImage(FashionImageRequest request) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.generateFashionImage(request: request);
      state = AsyncValue.data(result);
    } catch (e, st) {
      Logger.error('[FashionImage] 생성 실패', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadTodaysImage(FashionStyleType styleType) async {
    try {
      final result = await _service.getTodaysFashionImage(styleType);
      if (result != null) {
        state = AsyncValue.data(result);
      }
    } catch (e) {
      Logger.error('[FashionImage] 오늘 이미지 로드 실패', e);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 패션 이미지 생성 섹션 위젯
///
/// 사용자의 오행 기반 패션 추천을 NanoBanana AI로 시각화합니다.
/// 35 Souls 소비 또는 광고 시청으로 이용 가능합니다.
class FashionImageSection extends ConsumerStatefulWidget {
  final Map<String, dynamic>? fashionDetail;
  final Map<String, dynamic>? colorDetail;
  final String? gender;

  const FashionImageSection({
    super.key,
    this.fashionDetail,
    this.colorDetail,
    this.gender,
  });

  @override
  ConsumerState<FashionImageSection> createState() => _FashionImageSectionState();
}

class _FashionImageSectionState extends ConsumerState<FashionImageSection> {
  FashionStyleType _selectedStyle = FashionStyleType.neat;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // 오늘 이미 생성한 이미지가 있으면 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fashionImageProvider.notifier).loadTodaysImage(_selectedStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fashionImageState = ref.watch(fashionImageProvider);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.1),
            colors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: colors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 패션 이미지',
                      style: DSTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '오늘의 추천 스타일을 시각화해보세요',
                      style: DSTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 스타일 선택 칩
          _buildStyleSelector(colors),

          const SizedBox(height: 16),

          // 결과 또는 생성 버튼
          fashionImageState.when(
            data: (result) {
              if (result != null) {
                return _buildImageResult(result, colors);
              }
              return _buildGenerateButton(colors);
            },
            loading: () => _buildLoadingState(colors),
            error: (e, _) => _buildErrorState(e, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector(DSColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FashionStyleType.values.map((style) {
          final isSelected = style == _selectedStyle;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref.read(fortuneHapticServiceProvider).selection();
                setState(() => _selectedStyle = style);
                // 선택한 스타일의 오늘 이미지 확인
                ref.read(fashionImageProvider.notifier).loadTodaysImage(style);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colors.accent : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.accent : colors.border,
                  ),
                ),
                child: Text(
                  style.displayName,
                  style: DSTypography.bodySmall.copyWith(
                    color: isSelected ? Colors.white : colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGenerateButton(DSColorScheme colors) {
    return GestureDetector(
      onTap: _isGenerating ? null : _handleGenerateImage,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '패션 이미지 생성하기',
              style: DSTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '광고 시청 후 무료 생성',
              style: DSTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.accent, colors.accent.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '생성하기',
                    style: DSTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildLoadingState(DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'AI가 패션 이미지를 생성하고 있어요...',
            style: DSTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '약 10-20초 소요',
            style: DSTypography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 40),
          const SizedBox(height: 12),
          Text(
            '이미지 생성에 실패했어요',
            style: DSTypography.bodyMedium.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '잠시 후 다시 시도해주세요',
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              ref.read(fashionImageProvider.notifier).reset();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '다시 시도',
                style: DSTypography.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageResult(FashionImageResult result, DSColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 생성된 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 9 / 16, // 세로 이미지 (전신샷)
            child: CachedNetworkImage(
              imageUrl: result.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colors.surfaceSecondary,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colors.surfaceSecondary,
                child: Icon(Icons.broken_image, color: colors.textSecondary),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 스타일 정보 라벨
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style, size: 14, color: colors.accent),
                  const SizedBox(width: 4),
                  Text(
                    _selectedStyle.displayName,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(fashionImageProvider.notifier).reset();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '다른 스타일',
                      style: DSTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleGenerateImage() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      final adService = ref.read(adServiceProvider);

      // 광고 준비 확인
      if (!adService.isRewardedAdReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 준비하는 중입니다...')),
        );
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고 로드에 실패했습니다.')),
            );
          }
          setState(() => _isGenerating = false);
          return;
        }
      }

      // 광고 표시
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, rewardItem) async {
          Logger.info('[FashionImage] ✅ 광고 보상 획득, 이미지 생성 시작');
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();
          await _generateFashionImage();
        },
      );
    } catch (e) {
      Logger.error('[FashionImage] 광고 표시 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateFashionImage() async {
    // fashionDetail에서 아이템 정보 추출
    final fashion = widget.fashionDetail ?? {};
    final colorData = widget.colorDetail ?? {};

    final top = fashion['top'] as String? ?? '화이트 셔츠';
    final bottom = fashion['bottom'] as String? ?? '네이비 슬랙스';
    final outer = fashion['outer'] as String?;
    final shoes = fashion['shoes'] as String? ?? '깔끔한 로퍼';

    final mainColor = colorData['mainColor'] as String? ?? '네이비';
    final colorTone = (colorData['colorTone'] as String?)?.contains('웜') == true
        ? 'warm'
        : 'cool';

    final gender = widget.gender ?? 'female';

    final request = FashionImageRequest(
      gender: gender,
      styleType: _selectedStyle,
      outfitData: FashionOutfitData(
        top: FashionItem(item: top, color: mainColor),
        bottom: FashionItem(item: bottom, color: mainColor),
        outer: outer != null ? FashionItem(item: outer, color: mainColor) : null,
        shoes: FashionItem(item: shoes, color: mainColor),
      ),
      colorTone: colorTone,
    );

    await ref.read(fashionImageProvider.notifier).generateImage(request);
  }
}
