import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/utils/haptic_utils.dart';

import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../../shared/components/toast.dart';
import '../../../../domain/models/medical_document_models.dart';

/// 문서 업로드 바텀시트
/// PDF 파일 또는 이미지로 건강 문서를 선택
class DocumentUploadBottomSheet extends StatefulWidget {
  final Function(MedicalDocumentUploadResult) onDocumentSelected;

  const DocumentUploadBottomSheet({
    super.key,
    required this.onDocumentSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(MedicalDocumentUploadResult) onDocumentSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => DocumentUploadBottomSheet(
        onDocumentSelected: onDocumentSelected,
      ),
    );
  }

  @override
  State<DocumentUploadBottomSheet> createState() =>
      _DocumentUploadBottomSheetState();
}

class _DocumentUploadBottomSheetState extends State<DocumentUploadBottomSheet> {
  final ImagePicker _imagePicker = ImagePicker();

  MedicalDocumentType _selectedDocumentType = MedicalDocumentType.checkup;
  File? _selectedFile;
  String? _base64Data;
  String _mimeType = '';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              _buildHeader(context),
              const SizedBox(height: 24),

              // 문서 유형 선택
              _buildDocumentTypeSelector(context),
              const SizedBox(height: 20),

              // 파일 선택 옵션
              _buildFileSelectionOptions(context),

              // 선택된 파일 미리보기
              if (_selectedFile != null) ...[
                const SizedBox(height: 20),
                _buildSelectedFilePreview(context),
              ],

              const SizedBox(height: 24),

              // 분석 버튼
              _buildAnalyzeButton(),

              const SizedBox(height: 12),

              // 안내 텍스트
              _buildInfoText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: DSColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF10B981),
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '건강 문서 분석',
                style: context.heading3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '신령이 검진 결과를 분석해드려요',
                style: context.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '문서 유형',
          style: context.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: MedicalDocumentType.values.map((type) {
            final isSelected = _selectedDocumentType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticUtils.selection();
                  setState(() => _selectedDocumentType = type);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: type != MedicalDocumentType.values.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DSColors.success.withValues(alpha: 0.1)
                        : context.colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.success
                          : context.colors.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type.displayName,
                    textAlign: TextAlign.center,
                    style: context.bodySmall.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? DSColors.success
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileSelectionOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '파일 선택',
          style: context.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // PDF 파일 선택
            Expanded(
              child: _buildOptionButton(
                context: context,
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF 파일',
                onTap: _pickPdfFile,
              ),
            ),
            const SizedBox(width: 10),
            // 카메라 촬영
            Expanded(
              child: _buildOptionButton(
                context: context,
                icon: Icons.camera_alt_rounded,
                label: '사진 촬영',
                onTap: _takePhoto,
              ),
            ),
            const SizedBox(width: 10),
            // 갤러리 선택
            Expanded(
              child: _buildOptionButton(
                context: context,
                icon: Icons.photo_library_rounded,
                label: '갤러리',
                onTap: _pickFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: context.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilePreview(BuildContext context) {
    final fileName = _selectedFile?.path.split('/').last ?? '';
    final fileSize = _selectedFile?.lengthSync() ?? 0;
    final fileSizeStr = fileSize < 1024 * 1024
        ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
        : '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DSColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _mimeType.contains('pdf')
                ? Icons.picture_as_pdf_rounded
                : Icons.image_rounded,
            color: DSColors.success,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName.length > 25
                      ? '${fileName.substring(0, 22)}...'
                      : fileName,
                  style: context.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  fileSizeStr,
                  style: context.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _base64Data = null;
              });
            },
            icon: Icon(
              Icons.close_rounded,
              color: context.colors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final isEnabled = _selectedFile != null && _base64Data != null;

    return UnifiedButton(
      text: '분석하기',
      onPressed: isEnabled ? _onAnalyze : null,
      style: UnifiedButtonStyle.primary,
      size: UnifiedButtonSize.large,
    );
  }

  Widget _buildInfoText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: context.colors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '업로드된 문서는 분석에만 사용되며, 분석 후 즉시 삭제됩니다. 의사의 전문적 진단을 대체하지 않습니다.',
              style: context.bodySmall.copyWith(
                color: context.colors.textTertiary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 파일 선택 메서드 ====================

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // 파일 크기 체크 (10MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            Toast.error(context, '파일 크기는 10MB 이하여야 합니다');
          }
          return;
        }

        final bytes = file.bytes;
        if (bytes == null) {
          if (mounted) {
            Toast.error(context, '파일을 읽을 수 없습니다');
          }
          return;
        }

        setState(() {
          _selectedFile = File(file.path ?? '');
          _base64Data = base64Encode(bytes);
          _mimeType = file.extension == 'pdf'
              ? 'application/pdf'
              : 'image/${file.extension}';
        });
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, '파일 선택 중 오류가 발생했습니다');
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, '카메라 접근 중 오류가 발생했습니다');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, '갤러리 접근 중 오류가 발생했습니다');
      }
    }
  }

  Future<void> _processImage(File file) async {
    final bytes = await file.readAsBytes();

    // 파일 크기 체크 (10MB)
    if (bytes.length > 10 * 1024 * 1024) {
      if (mounted) {
        Toast.error(context, '파일 크기는 10MB 이하여야 합니다');
      }
      return;
    }

    setState(() {
      _selectedFile = file;
      _base64Data = base64Encode(bytes);
      _mimeType = 'image/jpeg';
    });
  }

  void _onAnalyze() {
    if (_base64Data == null) return;

    final result = MedicalDocumentUploadResult(
      documentType: _selectedDocumentType,
      file: _selectedFile,
      base64Data: _base64Data,
      mimeType: _mimeType,
      fileName: _selectedFile?.path.split('/').last,
      fileSizeBytes: _selectedFile?.lengthSync(),
    );

    Navigator.pop(context);
    widget.onDocumentSelected(result);
  }
}
