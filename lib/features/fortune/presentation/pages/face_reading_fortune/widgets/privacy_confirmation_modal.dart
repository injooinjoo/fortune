import 'package:flutter/material.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 개인정보 처리 동의 확인 모달
/// 촬영 전 사용자에게 개인정보 처리에 대해 안내합니다.
class PrivacyConfirmationModal extends StatefulWidget {
  /// 동의 후 콜백
  final VoidCallback onConfirm;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 다시 보지 않기 활성화 여부
  final bool showDontShowAgain;

  /// 다시 보지 않기 체크 콜백
  final ValueChanged<bool>? onDontShowAgainChanged;

  const PrivacyConfirmationModal({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.showDontShowAgain = true,
    this.onDontShowAgainChanged,
  });

  /// 모달 표시
  static Future<bool> show(
    BuildContext context, {
    bool showDontShowAgain = true,
    ValueChanged<bool>? onDontShowAgainChanged,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrivacyConfirmationModal(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        showDontShowAgain: showDontShowAgain,
        onDontShowAgainChanged: onDontShowAgainChanged,
      ),
    );
    return result ?? false;
  }

  @override
  State<PrivacyConfirmationModal> createState() =>
      _PrivacyConfirmationModalState();
}

class _PrivacyConfirmationModalState extends State<PrivacyConfirmationModal> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? DSColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 48,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // 제목
              Text(
                '안심하고 촬영하세요',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                '촬영한 사진은 관상 분석에만 사용되며,\n서버에 저장되지 않고 즉시 삭제돼요.',
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(
                  color: DSColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 개인정보 처리 항목들
              _buildPrivacyItem(
                context,
                icon: Icons.photo_camera_outlined,
                title: '분석 전용',
                description: '사진은 관상 분석에만 사용됩니다',
              ),
              const SizedBox(height: 12),
              _buildPrivacyItem(
                context,
                icon: Icons.delete_forever_outlined,
                title: '즉시 삭제',
                description: '분석 완료 후 사진은 자동으로 삭제됩니다',
              ),
              const SizedBox(height: 12),
              _buildPrivacyItem(
                context,
                icon: Icons.cloud_off_outlined,
                title: '서버 미저장',
                description: '사진은 서버에 저장되지 않습니다',
              ),
              const SizedBox(height: 24),

              // 다시 보지 않기
              if (widget.showDontShowAgain)
                GestureDetector(
                  onTap: () {
                    setState(() => _dontShowAgain = !_dontShowAgain);
                    widget.onDontShowAgainChanged?.call(_dontShowAgain);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        onChanged: (value) {
                          setState(() => _dontShowAgain = value ?? false);
                          widget.onDontShowAgainChanged?.call(_dontShowAgain);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        '다시 보지 않기',
                        style: context.labelMedium.copyWith(
                          color: DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // 버튼들
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: context.buttonMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 확인 버튼
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: widget.onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '동의하고 촬영하기',
                        style: context.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: context.labelSmall.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green.shade400,
          ),
        ],
      ),
    );
  }
}
