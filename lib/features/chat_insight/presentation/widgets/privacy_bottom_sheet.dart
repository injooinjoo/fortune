import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';
import '../../data/storage/insight_storage.dart';

/// 프라이버시 설정 바텀시트 (3개 토글)
class PrivacyBottomSheet extends StatefulWidget {
  final PrivacyConfig currentConfig;
  final ValueChanged<PrivacyConfig> onSave;

  const PrivacyBottomSheet({
    super.key,
    required this.currentConfig,
    required this.onSave,
  });

  /// 바텀시트 표시 헬퍼
  static Future<void> show(BuildContext context) async {
    final config = await InsightStorage.loadPrivacyConfig();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PrivacyBottomSheet(
        currentConfig: config,
        onSave: (newConfig) async {
          await InsightStorage.savePrivacyConfig(newConfig);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  State<PrivacyBottomSheet> createState() => _PrivacyBottomSheetState();
}

class _PrivacyBottomSheetState extends State<PrivacyBottomSheet> {
  late bool _localOnly;
  late bool _serverSent;
  late bool _originalStored;

  @override
  void initState() {
    super.initState();
    _localOnly = widget.currentConfig.localOnly;
    _serverSent = widget.currentConfig.serverSent;
    _originalStored = widget.currentConfig.originalStored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들 바
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 헤더
              Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: colors.textSecondary, size: 24),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '프라이버시 설정',
                    style: typography.headingSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                '대화 분석 데이터의 처리 방식을 설정합니다.',
                style: typography.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 토글 1: 로컬 분석만
              _buildToggleItem(
                context,
                icon: Icons.phone_android,
                title: '로컬 분석만 사용',
                description: '기기에서만 분석하고 서버로 전송하지 않아요',
                value: _localOnly,
                onChanged: (value) {
                  setState(() {
                    _localOnly = value;
                    if (value) _serverSent = false;
                  });
                },
              ),
              const Divider(height: 1),

              // 토글 2: 서버 전송 허용
              _buildToggleItem(
                context,
                icon: Icons.cloud_upload_outlined,
                title: '서버 분석 허용',
                description: '더 정확한 딥 분석을 위해 서버로 전송해요',
                value: _serverSent,
                onChanged: (value) {
                  setState(() {
                    _serverSent = value;
                    if (value) _localOnly = false;
                  });
                },
              ),
              const Divider(height: 1),

              // 토글 3: 원문 저장
              _buildToggleItem(
                context,
                icon: Icons.save_outlined,
                title: '분석 원문 저장',
                description: '대화 원문을 기기에 보관해요 (비활성 권장)',
                value: _originalStored,
                onChanged: (value) {
                  setState(() => _originalStored = value);
                },
              ),

              const SizedBox(height: DSSpacing.lg),

              // 데이터 삭제 버튼
              TextButton.icon(
                onPressed: () => _showDeleteConfirmation(context),
                icon: Icon(Icons.delete_outline, color: colors.error, size: 18),
                label: Text(
                  '모든 분석 데이터 삭제',
                  style: typography.labelMedium.copyWith(color: colors.error),
                ),
              ),

              const SizedBox(height: DSSpacing.md),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: DSButton.primary(
                  text: '저장',
                  onPressed: () {
                    widget.onSave(PrivacyConfig(
                      localOnly: _localOnly,
                      serverSent: _serverSent,
                      originalStored: _originalStored,
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Semantics(
      label: '$title. $description. ${value ? "켜짐" : "꺼짐"}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: colors.textSecondary, size: 20),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: typography.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: colors.success,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final colors = context.colors;
    final typography = context.typography;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          '데이터 삭제',
          style: typography.headingSmall.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          '모든 대화 분석 데이터가 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소',
                style: typography.labelMedium
                    .copyWith(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제',
                style: typography.labelMedium.copyWith(color: colors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await InsightStorage.deleteAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('모든 분석 데이터가 삭제되었습니다'),
            backgroundColor: colors.surface,
          ),
        );
      }
    }
  }
}
