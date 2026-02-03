import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/design_system/design_system.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';

/// Face AI 홈 화면 - 1번 탭
class FaceAiHomeScreen extends ConsumerStatefulWidget {
  const FaceAiHomeScreen({super.key});

  @override
  ConsumerState<FaceAiHomeScreen> createState() => _FaceAiHomeScreenState();
}

class _FaceAiHomeScreenState extends ConsumerState<FaceAiHomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final ImagePicker _imagePicker = ImagePicker();

  /// 카메라 페이지로 이동 (Face Mesh 효과 포함)
  void _openCamera() {
    context.push('/face-ai/camera');
  }

  /// 갤러리에서 사진 선택
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        context.push('/face-reading', extra: {
          'capturedImageFile': file,
          'fromFaceAi': true,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileImageUrl = userProfileAsync.valueOrNull?.profileImageUrl;
    final hasProfileImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context, isDark),

            // 페이지 인디케이터
            _buildPageIndicator(),

            // 스와이프 카드
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // 1. 카메라 CTA 카드
                  _buildCameraCtaCard(context, isDark, hasProfileImage, profileImageUrl),

                  // 2. Face AI 소개 카드
                  _buildIntroCard(context, isDark),

                  // 3. 분석 팁 카드
                  _buildTipsCard(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Face AI 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
                  Color(0xFF7B1FA2), // 고유 색상 - Face AI 테마
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.3), // 고유 색상 - Face AI 테마
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 타이틀
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Face AI',
                style: context.headingMedium.copyWith(
                  color: isDark ? Colors.white : DSColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'AI 얼굴 특징 분석',
                style: context.labelSmall.copyWith(
                  color: const Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 히스토리 버튼
          IconButton(
            onPressed: () {
              context.push('/profile/history');
            },
            icon: Icon(
              Icons.history,
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? const Color(0xFF9C27B0) // 고유 색상 - Face AI 테마
                  : const Color(0xFF9C27B0).withValues(alpha: 0.2), // 고유 색상 - Face AI 테마
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCameraCtaCard(
    BuildContext context,
    bool isDark,
    bool hasProfileImage,
    String? profileImageUrl,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 메인 CTA 영역
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? DSColors.backgroundSecondary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // 아이콘 영역
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9C27B0).withValues(alpha: 0.1), // 고유 색상 - Face AI 테마
                        const Color(0xFF7B1FA2).withValues(alpha: 0.1), // 고유 색상 - Face AI 테마
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 56,
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.8), // 고유 색상 - Face AI 테마
                  ),
                ).animate()
                    .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                Text(
                  '오늘의 얼굴 분석하기',
                  style: context.headingMedium.copyWith(
                    color: isDark ? Colors.white : DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  'AI가 당신의 얼굴 특징을 분석하여\n성격과 인상을 알려드려요',
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.copyWith(
                    color: DSColors.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 24),

                // 카메라 & 갤러리 버튼
                Row(
                  children: [
                    // 카메라 버튼 (Face Mesh 포함)
                    Expanded(
                      child: GestureDetector(
                        onTap: _openCamera,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
                                Color(0xFF7B1FA2), // 고유 색상 - Face AI 테마
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9C27B0).withValues(alpha: 0.3), // 고유 색상 - Face AI 테마
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '카메라로 촬영',
                                style: context.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Face Mesh 효과',
                                style: context.labelSmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 갤러리 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DSColors.backgroundTertiary
                                : DSColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF9C27B0).withValues(alpha: 0.3), // 고유 색상 - Face AI 테마
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                color: Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '갤러리에서 선택',
                                style: context.labelMedium.copyWith(
                                  color: isDark ? Colors.white : DSColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '사진 업로드',
                                style: context.labelSmall.copyWith(
                                  color: DSColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              ],
            ),
          ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),

          const SizedBox(height: 20),

          // 프로필 사진 옵션 (있는 경우)
          if (hasProfileImage)
            _buildProfileImageOption(context, isDark, profileImageUrl!),

          const SizedBox(height: 20),

          // 하단 기능 힌트
          _buildFeatureHints(isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileImageOption(BuildContext context, bool isDark, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // 프로필 사진으로 분석 시작
        context.push('/face-reading', extra: {
          'profileImageUrl': imageUrl,
          'fromFaceAi': true,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? DSColors.backgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3), // 고유 색상 - Face AI 테마
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 56,
                  height: 56,
                  color: DSColors.backgroundTertiary,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 56,
                  height: 56,
                  color: DSColors.backgroundTertiary,
                  child: const Icon(Icons.person, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 프로필 사진으로 분석',
                    style: context.bodyMedium.copyWith(
                      color: isDark ? Colors.white : DSColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '탭하여 빠르게 시작',
                    style: context.labelSmall.copyWith(
                      color: DSColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildFeatureHints(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DSColors.backgroundSecondary : DSColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHintItem(Icons.psychology, '성격 분석', isDark),
          _buildHintItem(Icons.auto_awesome, '인상 분석', isDark),
          _buildHintItem(Icons.tips_and_updates, '맞춤 조언', isDark),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildHintItem(IconData icon, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFF9C27B0).withValues(alpha: 0.7), // 고유 색상 - Face AI 테마
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroCard(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? DSColors.backgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1), // 고유 색상 - Face AI 테마
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Face AI란?',
                  style: context.headingSmall.copyWith(
                    color: isDark ? Colors.white : DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildIntroItem(
              '1',
              '얼굴 특징 분석',
              'AI가 얼굴의 이목구비, 윤곽, 표정 등을 분석합니다',
              isDark,
            ),

            const SizedBox(height: 16),

            _buildIntroItem(
              '2',
              '성격 인사이트',
              '얼굴 특징을 바탕으로 성격적 특성을 알려드려요',
              isDark,
            ),

            const SizedBox(height: 16),

            _buildIntroItem(
              '3',
              '첫인상 분석',
              '다른 사람들에게 어떤 인상을 주는지 확인하세요',
              isDark,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DSColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: DSColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '재미로 보는 엔터테인먼트 콘텐츠입니다',
                      style: context.bodySmall.copyWith(
                        color: DSColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildIntroItem(String number, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF9C27B0).withValues(alpha: 0.1), // 고유 색상 - Face AI 테마
          ),
          child: Center(
            child: Text(
              number,
              style: context.labelMedium.copyWith(
                color: const Color(0xFF9C27B0), // 고유 색상 - Face AI 테마
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  color: isDark ? Colors.white : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.bodySmall.copyWith(
                  color: DSColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? DSColors.backgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DSColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: DSColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '분석 팁',
                  style: context.headingSmall.copyWith(
                    color: isDark ? Colors.white : DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildTipItem(
              Icons.wb_sunny_outlined,
              '밝은 조명',
              '자연광이나 밝은 실내 조명에서 촬영하세요',
              isDark,
            ),

            const SizedBox(height: 16),

            _buildTipItem(
              Icons.face,
              '정면 촬영',
              '카메라를 정면으로 바라보고 촬영하세요',
              isDark,
            ),

            const SizedBox(height: 16),

            _buildTipItem(
              Icons.visibility_off,
              '장애물 제거',
              '선글라스, 마스크 등은 벗어주세요',
              isDark,
            ),

            const SizedBox(height: 16),

            _buildTipItem(
              Icons.sentiment_satisfied,
              '자연스러운 표정',
              '편안하고 자연스러운 표정이 좋아요',
              isDark,
            ),
          ],
        ),
      ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DSColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: DSColors.success,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  color: isDark ? Colors.white : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.bodySmall.copyWith(
                  color: DSColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
