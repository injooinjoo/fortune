import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/design_system/design_system.dart';

/// 채팅 이미지 입력 위젯 (관상 분석용)
class ChatImageInput extends StatefulWidget {
  final void Function(File image) onImageSelected;
  final String? hintText;
  final Future<bool> Function(ImageSource source)? onBeforePickImage;
  final ImageSource? initialPickSource;
  final VoidCallback? onInitialPickHandled;

  const ChatImageInput({
    super.key,
    required this.onImageSelected,
    this.hintText,
    this.onBeforePickImage,
    this.initialPickSource,
    this.onInitialPickHandled,
  });

  @override
  State<ChatImageInput> createState() => _ChatImageInputState();
}

class _ChatImageInputState extends State<ChatImageInput> {
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
  void didUpdateWidget(covariant ChatImageInput oldWidget) {
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
        preferredCameraDevice: CameraDevice.front,
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
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      // 투명 배경 - 하단 입력 영역과 일관성 유지
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.hintText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Text(
                widget.hintText!,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          if (_selectedImage != null) ...[
            // 선택된 이미지 미리보기
            ClipRRect(
              borderRadius: BorderRadius.circular(DSRadius.md),
              child: Image.file(
                _selectedImage!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          Row(
            children: [
              _ImageOptionChip(
                icon: Icons.camera_alt_outlined,
                label: '카메라',
                onTap: _isLoading ? null : _pickFromCamera,
                isLoading: _isLoading,
              ),
              const SizedBox(width: DSSpacing.xs),
              _ImageOptionChip(
                icon: Icons.photo_library_outlined,
                label: '갤러리',
                onTap: _isLoading ? null : _pickFromGallery,
                isLoading: _isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageOptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ImageOptionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final chipForeground = Color.lerp(
      colors.textPrimary,
      colors.accentTertiary,
      context.isDark ? 0.48 : 0.72,
    )!;
    final chipBackground = Color.alphaBlend(
      colors.accentTertiary.withValues(alpha: context.isDark ? 0.16 : 0.10),
      colors.surface,
    );
    final chipBorder =
        chipForeground.withValues(alpha: context.isDark ? 0.38 : 0.26);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: chipBackground,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: chipBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: chipForeground,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: chipForeground,
                ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: chipForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
