import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/design_system/design_system.dart';

/// 채팅 이미지 입력 위젯 (관상 분석용)
class ChatImageInput extends StatefulWidget {
  final void Function(File image) onImageSelected;
  final String? hintText;

  const ChatImageInput({
    super.key,
    required this.onImageSelected,
    this.hintText,
  });

  @override
  State<ChatImageInput> createState() => _ChatImageInputState();
}

class _ChatImageInputState extends State<ChatImageInput> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickFromCamera() async {
    DSHaptics.light();
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
    final isDark = context.isDark;

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
            color: colors.accentSecondary.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.accentSecondary.withValues(alpha: 0.3),
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
                    color: colors.accentSecondary,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: colors.accentSecondary,
                ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: colors.accentSecondary,
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
