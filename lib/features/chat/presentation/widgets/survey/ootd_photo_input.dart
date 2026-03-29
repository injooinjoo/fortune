import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/design_system/design_system.dart';

/// OOTD 사진 입력 위젯 (촬영 가이드 포함)
///
/// 상단에 촬영 팁을 표시하고 하단에 카메라/갤러리 버튼을 제공합니다.
class OotdPhotoInput extends StatefulWidget {
  final void Function(File image) onImageSelected;
  final String? hintText;
  final Future<bool> Function(ImageSource source)? onBeforePickImage;
  final ImageSource? initialPickSource;
  final VoidCallback? onInitialPickHandled;

  const OotdPhotoInput({
    super.key,
    required this.onImageSelected,
    this.hintText,
    this.onBeforePickImage,
    this.initialPickSource,
    this.onInitialPickHandled,
  });

  @override
  State<OotdPhotoInput> createState() => _OotdPhotoInputState();
}

class _OotdPhotoInputState extends State<OotdPhotoInput> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  bool _didConsumeInitialPick = false;

  @override
  void initState() {
    super.initState();
    _maybeConsumeInitialPick();
  }

  @override
  void didUpdateWidget(covariant OotdPhotoInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPickSource != widget.initialPickSource) {
      _maybeConsumeInitialPick();
    }
  }

  Future<void> _pickFromCamera() async {
    DSHaptics.light();
    final allowed = await widget.onBeforePickImage?.call(ImageSource.camera);
    if (allowed == false) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear, // OOTD는 후면 카메라 선호
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        final file = File(photo.path);
        setState(() => _selectedImage = file);
        widget.onImageSelected(file);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    DSHaptics.light();
    final allowed = await widget.onBeforePickImage?.call(ImageSource.gallery);
    if (allowed == false) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() => _selectedImage = file);
        widget.onImageSelected(file);
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _maybeConsumeInitialPick() {
    final source = widget.initialPickSource;
    if (_didConsumeInitialPick || source == null) {
      return;
    }

    _didConsumeInitialPick = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.onInitialPickHandled?.call();
      if (source == ImageSource.camera) {
        _pickFromCamera();
        return;
      }
      _pickFromGallery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 촬영 가이드 카드
          _buildPhotoGuideCard(context, isDark),
          const SizedBox(height: DSSpacing.md),

          // 선택된 이미지 미리보기
          if (_selectedImage != null) ...[
            _buildImagePreview(context),
            const SizedBox(height: DSSpacing.sm),
          ],

          // 카메라/갤러리 버튼
          Row(
            children: [
              Expanded(
                child: _ImageOptionButton(
                  icon: Icons.camera_alt_outlined,
                  label: '카메라',
                  onTap: _isLoading ? null : _pickFromCamera,
                  isLoading: _isLoading,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _ImageOptionButton(
                  icon: Icons.photo_library_outlined,
                  label: '갤러리',
                  onTap: _isLoading ? null : _pickFromGallery,
                  isLoading: _isLoading,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 촬영 가이드 카드
  Widget _buildPhotoGuideCard(BuildContext context, bool isDark) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surface.withValues(alpha: 0.8) : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Text('📷', style: TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '이렇게 찍어주세요!',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 팁 목록
          _buildTipItem(
            context,
            '📏',
            '전신 촬영',
            '머리부터 발끝까지 전체가 보이게',
            isDark,
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTipItem(
            context,
            '🧍',
            '정면 포즈',
            '카메라를 정면으로 바라보세요',
            isDark,
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTipItem(
            context,
            '💡',
            '밝은 조명',
            '자연광이나 밝은 실내에서 촬영',
            isDark,
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildTipItem(
            context,
            '🪞',
            '거울 셀카 OK',
            '전신 거울 앞 셀카도 좋아요',
            isDark,
          ),
        ],
      ),
    );
  }

  /// 촬영 팁 아이템
  Widget _buildTipItem(
    BuildContext context,
    String emoji,
    String title,
    String description,
    bool isDark,
  ) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.sm),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                description,
                style: context.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 이미지 미리보기
  Widget _buildImagePreview(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        // 재선택 버튼
        Positioned(
          top: DSSpacing.xs,
          right: DSSpacing.xs,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedImage = null);
            },
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
        // 선택됨 표시
        Positioned(
          bottom: DSSpacing.xs,
          left: DSSpacing.xs,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.success,
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: colors.ctaForeground),
                const SizedBox(width: 4),
                Text(
                  '사진 선택됨',
                  style: context.labelSmall.copyWith(
                    color: colors.ctaForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 이미지 선택 버튼
class _ImageOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color color;

  const _ImageOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 18, color: color),
              const SizedBox(width: DSSpacing.xs),
              Text(
                label,
                style: context.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
