import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/design_system/design_system.dart';

/// 채팅 내 관상 분석 플로우 위젯
///
/// 단계:
/// 1. 이미지 선택 (카메라/갤러리)
/// 2. 이미지 미리보기 + 확인/재촬영
/// 3. 분석 완료 콜백
class ChatFaceReadingFlow extends ConsumerStatefulWidget {
  final void Function(String imagePath) onComplete;
  final String? question;

  const ChatFaceReadingFlow({
    super.key,
    required this.onComplete,
    this.question,
  });

  @override
  ConsumerState<ChatFaceReadingFlow> createState() =>
      _ChatFaceReadingFlowState();
}

class _ChatFaceReadingFlowState extends ConsumerState<ChatFaceReadingFlow> {
  _FaceReadingPhase _phase = _FaceReadingPhase.imageSelection;
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
        setState(() {
          _selectedImage = file;
          _phase = _FaceReadingPhase.preview;
        });
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
        setState(() {
          _selectedImage = file;
          _phase = _FaceReadingPhase.preview;
        });
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _retakePhoto() {
    DSHaptics.light();
    setState(() {
      _selectedImage = null;
      _phase = _FaceReadingPhase.imageSelection;
    });
  }

  void _confirmAndAnalyze() {
    if (_selectedImage == null) return;

    DSHaptics.success();
    widget.onComplete(_selectedImage!.path);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      // 투명 배경 - 하단 입력 영역과 일관성 유지
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _phase == _FaceReadingPhase.imageSelection
            ? _buildImageSelector(colors)
            : _buildPreview(colors),
      ),
    );
  }

  Widget _buildImageSelector(DSColorScheme colors) {
    return Row(
      key: const ValueKey('imageSelector'),
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
    );
  }

  Widget _buildPreview(DSColorScheme colors) {
    final typography = context.typography;

    return Column(
      key: const ValueKey('preview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '이 사진으로 분석할까요?',
          style: typography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        // 이미지 미리보기
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DSRadius.md),
              child: Image.file(
                _selectedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 분석 시작 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmAndAnalyze,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('분석 시작'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.ctaBackground,
                        foregroundColor: colors.ctaForeground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  // 다시 찍기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('다시 선택'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(
                          color: colors.textPrimary.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _FaceReadingPhase {
  imageSelection,
  preview,
}

/// 이미지 선택 옵션 칩
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
            color:
                colors.textPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.3),
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
                    color: colors.textPrimary,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: colors.textPrimary,
                ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
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
