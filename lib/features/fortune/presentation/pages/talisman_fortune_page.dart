import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../talisman/domain/models/talisman_wish.dart';
import '../../../talisman/presentation/widgets/talisman_wish_selector.dart';
import '../../../talisman/presentation/widgets/talisman_wish_input.dart';
import '../../../talisman/presentation/widgets/talisman_loading_skeleton.dart';
import '../../../talisman/presentation/widgets/talisman_result_card.dart';
import '../../../talisman/presentation/providers/talisman_provider.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../services/talisman_share_service.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/widgets/social_share_bottom_sheet.dart';

class TalismanFortunePage extends ConsumerStatefulWidget {
  const TalismanFortunePage({super.key});

  @override
  ConsumerState<TalismanFortunePage> createState() => _TalismanFortunePageState();
}

class _TalismanFortunePageState extends ConsumerState<TalismanFortunePage> {
  TalismanCategory? _selectedCategory;
  String? _selectedWish;

  // Floating button state
  bool _isValid = false;
  bool _isGeneratingAI = false;
  final _wishInputKey = GlobalKey<TalismanWishInputState>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authStateProvider).value;
    final userId = authState?.session?.user.id;

    final talismanState = ref.watch(talismanGenerationProvider(userId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // 단계별 뒤로가기 처리
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: colors.textPrimary,
          onPressed: () {
            switch (talismanState.step) {
              case TalismanGenerationStep.categorySelection:
                // 카테고리 선택 → 페이지 나가기
                Navigator.of(context).pop();
                break;
              case TalismanGenerationStep.wishInput:
                // 소원 입력 → 카테고리 선택으로
                ref.read(talismanGenerationProvider(userId).notifier).goBack();
                setState(() {
                  _selectedCategory = null;
                });
                break;
              case TalismanGenerationStep.generation:
                // 생성 중에는 뒤로가기 불가
                break;
              case TalismanGenerationStep.result:
                // 결과 → 처음으로
                ref.read(talismanGenerationProvider(userId).notifier).reset();
                setState(() {
                  _selectedCategory = null;
                  _selectedWish = null;
                });
                break;
            }
          },
        ),
        title: Text(
          '부적',
          style: DSTypography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        // 결과 페이지면 오른쪽 X 버튼
        actions: talismanState.step == TalismanGenerationStep.result
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: colors.textPrimary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
      ),
      body: _buildContent(context, ref, talismanState, userId, colors),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, TalismanGenerationState state, String? userId, DSColorScheme colors) {
    if (state.error != null) {
      return _buildErrorState(context, ref, state.error!, userId, colors);
    }

    switch (state.step) {
      case TalismanGenerationStep.categorySelection:
        return _buildCategorySelection(context, ref, userId);
      case TalismanGenerationStep.wishInput:
        return _buildWishInput(context, ref);
      case TalismanGenerationStep.generation:
        return _buildGenerationAnimation(context, ref);
      case TalismanGenerationStep.result:
        return _buildResult(context, ref, state.design!);
    }
  }

  Widget _buildCategorySelection(BuildContext context, WidgetRef ref, String? userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: TalismanWishSelector(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          ref.read(talismanGenerationProvider(userId).notifier).selectCategory(category);
        },
      ),
    );
  }

  Widget _buildWishInput(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 버튼 높이(58) + 상단 패딩(16) + 하단 Safe Area + 여유 공간
    final scrollBottomPadding = 58 + 16 + bottomPadding + 20;

    // Stack이 화면 전체를 채우도록 SizedBox.expand 사용
    return SizedBox.expand(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, scrollBottomPadding),
            child: TalismanWishInput(
              key: _wishInputKey,
              selectedCategory: _selectedCategory!,
              onWishSubmitted: (_) {
                // AI 부적만 지원하므로 사용되지 않음
              },
              onAIWishSubmitted: (wish, isAIGenerated, imageUrl) async {
                final authState = ref.read(authStateProvider).value;
                final userId = authState?.session?.user.id;

                if (userId == null) {
                  _showLoginRequiredDialog(context);
                  return;
                }

                // 프리미엄 사용자가 아니면 하루 제한 체크
                final tokenState = ref.read(tokenProvider);
                final isPremium = tokenState.hasUnlimitedAccess;

                if (!isPremium) {
                  final talismanService = ref.read(talismanServiceProvider);
                  final canCreate = await talismanService.canCreateTalisman(userId);

                  if (!canCreate) {
                    if (mounted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('오늘은 이미 부적을 만들었어요. 내일 다시 시도해주세요!'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                    return;
                  }
                }

                setState(() {
                  _selectedWish = wish;
                });
                ref.read(talismanGenerationProvider(userId).notifier).generateTalisman(
                  category: _selectedCategory!,
                  specificWish: wish,
                  aiImageUrl: imageUrl, // AI 생성 이미지 URL 전달
                );
              },
              onValidationChanged: (isValid, isLoading) {
                setState(() {
                  _isValid = isValid;
                  _isGeneratingAI = isLoading;
                });
              },
            ),
          ),
          // 다른 페이지와 동일한 위치의 floating button
          UnifiedButton.floating(
            text: _isGeneratingAI ? '부적을 만들고 있어요...' : '🎨 맞춤 부적 만들기',
            onPressed: _isValid && !_isGeneratingAI
                ? () {
                    _wishInputKey.currentState?.handleAISubmit();
                  }
                : null,
            isLoading: _isGeneratingAI,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationAnimation(BuildContext context, WidgetRef ref) {
    return TalismanLoadingSkeleton(
      category: _selectedCategory!,
      wishText: _selectedWish ?? "소원을 이루어보세요",
    );
  }

  Widget _buildResult(BuildContext context, WidgetRef ref, design) {
    return TalismanResultCard(
      talismanDesign: design,
      onSave: () => _handleSave(context, design.imageUrl, design.category.displayName),
      onShare: () => _handleShare(context, design.imageUrl, design.category.displayName),
      onSetWallpaper: () => _handleSetWallpaper(context, design.imageUrl),
    );
  }

  /// 이미지 URL에서 바이트 데이터 다운로드
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('[TalismanFortunePage] 이미지 다운로드 실패: $e');
      return null;
    }
  }

  /// 부적 저장 처리
  Future<void> _handleSave(BuildContext context, String imageUrl, String categoryName) async {
    try {
      HapticFeedback.lightImpact();

      // 로딩 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('부적을 저장하고 있어요...'),
          duration: Duration(seconds: 1),
        ),
      );

      final imageData = await _downloadImage(imageUrl);
      if (imageData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지 다운로드에 실패했습니다')),
          );
        }
        return;
      }

      final shareService = TalismanShareService();
      await shareService.saveToGallery(imageData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$categoryName 부적이 저장되었습니다!'),
            backgroundColor: DSColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('[TalismanFortunePage] 저장 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  /// 부적 공유 처리
  Future<void> _handleShare(BuildContext context, String imageUrl, String categoryName) async {
    try {
      HapticFeedback.lightImpact();

      final imageData = await _downloadImage(imageUrl);
      if (imageData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지 다운로드에 실패했습니다')),
          );
        }
        return;
      }

      if (!context.mounted) return;

      // 공유 바텀시트 표시
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => SocialShareBottomSheet(
          fortuneTitle: '$categoryName 부적',
          fortuneContent: '나만의 $categoryName 부적이 완성되었습니다!',
          userName: '사용자',
          previewImage: imageData,
          onShare: (platform) async {
            final shareService = TalismanShareService();
            await shareService.shareTalisman(
              imageData: imageData,
              platform: platform,
              talismanType: '$categoryName 부적',
              userName: '사용자',
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('[TalismanFortunePage] 공유 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  /// 배경화면 설정 처리
  Future<void> _handleSetWallpaper(BuildContext context, String imageUrl) async {
    try {
      HapticFeedback.lightImpact();

      // 로딩 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('배경화면을 설정하고 있어요...'),
          duration: Duration(seconds: 1),
        ),
      );

      final imageData = await _downloadImage(imageUrl);
      if (imageData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지 다운로드에 실패했습니다')),
          );
        }
        return;
      }

      // 먼저 갤러리에 저장
      final shareService = TalismanShareService();
      await shareService.saveToGallery(imageData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('부적이 저장되었습니다. 갤러리에서 배경화면으로 설정해주세요!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('[TalismanFortunePage] 배경화면 설정 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('배경화면 설정에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, String? userId, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: DSColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            '오류가 발생했습니다',
            style: DSTypography.headingSmall.copyWith(
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: DSTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: UnifiedButton(
              text: '다시 시도',
              onPressed: () {
                ref.read(talismanGenerationProvider(userId).notifier).reset();
                setState(() {
                  _selectedCategory = null;
                  _selectedWish = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인이 필요합니다'),
        content: const Text('부적을 생성하려면 로그인이 필요합니다.'),
        actions: [
          UnifiedButton(
            text: '취소',
            onPressed: () => Navigator.of(context).pop(),
            style: UnifiedButtonStyle.text,
            size: UnifiedButtonSize.medium,
          ),
          UnifiedButton(
            text: '로그인',
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 로그인 페이지로 이동
            },
            style: UnifiedButtonStyle.text,
            size: UnifiedButtonSize.medium,
          ),
        ],
      ),
    );
  }
}