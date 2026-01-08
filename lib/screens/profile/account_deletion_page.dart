import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/theme/typography_unified.dart';
import '../../services/account_deletion_service.dart';
import '../../shared/components/section_header.dart';
import '../../shared/components/toast.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _feedbackController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _ackDataLoss = false;
  bool _ackRetention = false;
  bool _ackSubscription = false;
  bool _isProcessing = false;
  String? _selectedReason;

  static const _reasons = [
    '콘텐츠가 부족해요',
    '가격이 부담돼요',
    '사용 빈도가 낮아요',
    '기술/버그 문제가 있어요',
    '기타',
  ];

  bool get _isSignedIn => Supabase.instance.client.auth.currentUser != null;

  bool get _canSubmit {
    if (!_isSignedIn || _isProcessing) return false;
    return _ackDataLoss &&
        _ackRetention &&
        _ackSubscription &&
        _confirmController.text.trim() == '탈퇴';
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDeletion() async {
    if (!_canSubmit) {
      Toast.warning(context, '필수 확인 항목을 완료해 주세요.');
      return;
    }

    final confirmed = await DSModal.confirm(
      context: context,
      title: '회원 탈퇴',
      message: '정말로 탈퇴하시겠습니까?\n탈퇴 후에는 복구할 수 없습니다.',
      confirmText: '탈퇴',
      cancelText: '취소',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final service = AccountDeletionService();
      await service.deleteAccount(
        reason: _selectedReason,
        feedback: _feedbackController.text.trim().isEmpty
            ? null
            : _feedbackController.text.trim(),
      );

      if (!mounted) return;
      Toast.success(context, '회원 탈퇴가 완료되었습니다.');
      context.go('/chat');
    } catch (e) {
      if (!mounted) return;
      Toast.error(context, '탈퇴 처리 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: context.bodySmall),
          Expanded(
            child: Text(
              text,
              style: context.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: context.colors.warning,
            size: 20,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              '회원 탈퇴는 되돌릴 수 없습니다.\n탈퇴 전 남은 복주머니와 프리미엄 상태를 확인해 주세요.',
              style: context.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonChips() {
    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: _reasons.map((reason) {
        final isSelected = reason == _selectedReason;
        return ChoiceChip(
          label: Text(reason, style: context.labelSmall),
          selected: isSelected,
          selectedColor: context.colors.accent.withValues(alpha: 0.1),
          backgroundColor: context.colors.surface,
          labelStyle: context.labelSmall.copyWith(
            color: isSelected ? context.colors.accent : context.colors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: isSelected
                  ? context.colors.accent
                  : context.colors.border,
            ),
          ),
          onSelected: (selected) {
            setState(() {
              _selectedReason = selected ? reason : null;
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '회원 탈퇴',
          style: context.heading2.copyWith(color: context.colors.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.pageHorizontal,
            vertical: DSSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarningBox(),
              const SizedBox(height: DSSpacing.lg),

              const SectionHeader(title: '탈퇴 시 삭제되는 정보'),
              _buildBullet('프로필 정보, 운세 기록, 맞춤 설정 등 서비스 이용 데이터'),
              _buildBullet('연결된 소셜 계정 정보 및 기기 내 저장 데이터'),
              const SizedBox(height: DSSpacing.md),

              const SectionHeader(title: '법령에 따른 보관'),
              _buildBullet('결제 정보: 전자상거래법에 따라 5년 보관'),
              _buildBullet('서비스 이용 기록: 통신비밀보호법에 따라 3개월 보관'),
              const SizedBox(height: DSSpacing.md),

              const SectionHeader(title: '탈퇴 전 확인'),
              _buildConfirmItem(
                value: _ackDataLoss,
                onChanged: (value) => setState(() => _ackDataLoss = value),
                text: '삭제된 데이터는 복구할 수 없습니다.',
              ),
              _buildConfirmItem(
                value: _ackRetention,
                onChanged: (value) => setState(() => _ackRetention = value),
                text: '법령에 따라 일부 기록은 일정 기간 보관됩니다.',
              ),
              _buildConfirmItem(
                value: _ackSubscription,
                onChanged: (value) => setState(() => _ackSubscription = value),
                text: '남은 복주머니/프리미엄 혜택은 소멸됩니다.',
              ),
              const SizedBox(height: DSSpacing.md),

              const SectionHeader(title: '탈퇴 사유 (선택)'),
              _buildReasonChips(),
              const SizedBox(height: DSSpacing.md),

              const SectionHeader(title: '추가 의견 (선택)'),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '의견을 남겨주시면 서비스 개선에 도움이 됩니다.',
                  hintStyle: context.bodySmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.md),

              const SectionHeader(title: '확인 문구 입력'),
              TextField(
                controller: _confirmController,
                onChanged: (_) => setState(() {}),
                style: context.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '탈퇴를 입력해 주세요',
                  hintStyle: context.bodySmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                '정확히 "탈퇴"를 입력해야 진행할 수 있습니다.',
                style: context.labelSmall.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              if (!_isSignedIn)
                Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.md),
                  child: Text(
                    '로그인 상태에서만 회원 탈퇴를 진행할 수 있습니다.',
                    style: context.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),

              DSButton.destructive(
                text: '회원 탈퇴',
                onPressed: _canSubmit ? _handleDeletion : null,
                size: DSButtonSize.large,
                isLoading: _isProcessing,
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmItem({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String text,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
            ),
            const SizedBox(width: DSSpacing.xs),
            Expanded(
              child: Text(
                text,
                style: context.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
