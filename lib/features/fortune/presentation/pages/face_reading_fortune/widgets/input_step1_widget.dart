import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/components/image_upload_selector.dart';
import '../../../../../../presentation/providers/user_profile_notifier.dart';

class InputStep1Widget extends ConsumerStatefulWidget {
  final bool isDark;
  final Function(ImageUploadResult) onImageSelected;

  const InputStep1Widget({
    super.key,
    required this.isDark,
    required this.onImageSelected,
  });

  @override
  ConsumerState<InputStep1Widget> createState() => _InputStep1WidgetState();
}

class _InputStep1WidgetState extends ConsumerState<InputStep1Widget> {
  bool _isLoadingProfileImage = false;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileImageUrl = userProfileAsync.valueOrNull?.profileImageUrl;
    final hasProfileImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Compact Header
          _buildCompactHeader(),

          const SizedBox(height: 20),

          // 프로필 사진 옵션 (있는 경우만)
          if (hasProfileImage) ...[
            _buildProfileImageOption(profileImageUrl),
            const SizedBox(height: 16),
            _buildDividerWithText('또는'),
            const SizedBox(height: 16),
          ],

          // Upload Section (바로 표시)
          _buildUploadSection(),

          const SizedBox(height: 24),

          // Compact Feature Hints (하단에 작게)
          _buildCompactFeatureHints(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 프로필 사진 사용 옵션
  Widget _buildProfileImageOption(String imageUrl) {
    return GestureDetector(
      onTap: _isLoadingProfileImage ? null : () => _useProfileImage(imageUrl),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark
              ? DSColors.backgroundSecondary
              : DSColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DSColors.accent.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // 프로필 사진 미리보기
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: DSColors.backgroundTertiary,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: DSColors.backgroundTertiary,
                  child: const Icon(Icons.person, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 프로필 사진 사용',
                    style: DSTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white : DSColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '탭하여 선택',
                    style: DSTypography.labelSmall.copyWith(
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 로딩 또는 화살표
            if (_isLoadingProfileImage)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: DSColors.accent,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  /// 프로필 이미지 다운로드 후 선택
  Future<void> _useProfileImage(String imageUrl) async {
    setState(() {
      _isLoadingProfileImage = true;
    });

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/profile_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);

        // ImageUploadResult 생성하여 콜백 호출
        final result = ImageUploadResult(
          imageFile: file,
          type: ImageUploadType.gallery,
        );
        widget.onImageSelected(result);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필 사진을 불러오는데 실패했습니다.'),
              backgroundColor: DSColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [InputStep1Widget] Failed to download profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 사진을 불러오는데 실패했습니다.'),
            backgroundColor: DSColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfileImage = false;
        });
      }
    }
  }

  /// "또는" 구분선
  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: DSColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: DSTypography.labelSmall.copyWith(
              color: DSColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: DSColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// 간소화된 상단 헤더
  Widget _buildCompactHeader() {
    return Row(
      children: [
        // 작은 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9C27B0),
                Color(0xFF7B1FA2),
              ],
            ),
          ),
          child: const Icon(
            Icons.face_retouching_natural,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // 제목 + 뱃지
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '관상 분석',
                style: DSTypography.headingMedium.copyWith(
                  color: widget.isDark ? Colors.white : DSColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '얼굴 특징 정밀 분석',
                style: DSTypography.labelSmall.copyWith(
                  color: widget.isDark ? const Color(0xFFCE93D8) : DSColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 하단 간소화된 특징 힌트
  Widget _buildCompactFeatureHints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? DSColors.backgroundSecondary
            : DSColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHintItem(Icons.psychology, '성격'),
          _buildHintItem(Icons.stars, '운세'),
          _buildHintItem(Icons.tips_and_updates, '조언'),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildHintItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: widget.isDark ? DSColors.textTertiary : DSColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: DSTypography.labelSmall.copyWith(
            color: widget.isDark ? DSColors.textSecondary : DSColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Text(
                '사진 업로드',
                style: DSTypography.bodyLarge.copyWith(
                  color: widget.isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: DSColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '필수',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // 예외: 초소형 필수 태그
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

        const SizedBox(height: 12),

        ImageUploadSelector(
          title: '',
          description: '',
          onImageSelected: widget.onImageSelected,
          showInstagramOption: true,
          imageHeight: 200,
          guidelines: const [
            '정면을 바라보는 사진',
            '밝은 조명 권장',
            '선글라스/마스크 제거',
            '1인 사진만 가능',
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
      ],
    );
  }
}
