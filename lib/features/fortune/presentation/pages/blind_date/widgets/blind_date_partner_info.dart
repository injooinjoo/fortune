import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/widgets/app_widgets.dart';
import '../../../../../../widgets/multi_photo_selector.dart';
import '../constants/blind_date_options.dart';

/// 상대 정보 통합 섹션 (사진 + 대화 내용) - 모두 선택적
class BlindDatePartnerInfo extends StatelessWidget {
  final List<XFile> partnerPhotos;
  final ValueChanged<List<XFile>> onPartnerPhotosSelected;
  final TextEditingController chatContentController;
  final String? chatPlatform;
  final ValueChanged<String?> onPlatformChanged;

  const BlindDatePartnerInfo({
    super.key,
    required this.partnerPhotos,
    required this.onPartnerPhotosSelected,
    required this.chatContentController,
    required this.chatPlatform,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(text: '💕 상대 정보 (선택)'),
          const SizedBox(height: 8),
          Text(
            '상대방 사진이나 대화 내용이 있으면 더 정확한 분석이 가능해요',
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 상대 사진 섹션
          _buildPartnerPhotoSection(context),
          const SizedBox(height: 24),

          // 대화 내용 섹션
          _buildChatSection(context),
        ],
      ),
    );
  }

  Widget _buildPartnerPhotoSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 18,
              color: colors.accent,
            ),
            const SizedBox(width: 8),
            Text(
              '상대방 사진',
              style: DSTypography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MultiPhotoSelector(
          title: '사진 선택 (최대 3장)',
          maxPhotos: 3,
          onPhotosSelected: onPartnerPhotosSelected,
          initialPhotos: partnerPhotos,
        ),
      ],
    );
  }

  Widget _buildChatSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 18,
              color: colors.accent,
            ),
            const SizedBox(width: 8),
            Text(
              '대화 내용',
              style: DSTypography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 플랫폼 선택
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chatPlatformOptions.entries.map((entry) {
            final isSelected = chatPlatform == entry.key;
            return SelectionChip(
              label: entry.value,
              isSelected: isSelected,
              onTap: () {
                onPlatformChanged(entry.key);
                HapticFeedback.selectionClick();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // 대화 내용 입력
        TextField(
          controller: chatContentController,
          maxLines: 6,
          maxLength: 500,
          style: DSTypography.bodyMedium.copyWith(
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '상대방과의 대화 내용을 붙여넣으세요\n예: 나: 안녕하세요! / 상대: 반가워요~',
            hintStyle: DSTypography.bodyMedium.copyWith(
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(color: colors.accent, width: 2),
            ),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),

        // 안내 문구
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 14,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '대화 내용은 분석 후 안전하게 삭제됩니다',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
