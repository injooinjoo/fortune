import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import 'instagram_share_card.dart';

/// 공유 미리보기 모달
/// SNS 공유 전 미리보기 및 옵션 선택
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class SharePreviewModal extends StatefulWidget {
  /// 핵심 인사이트 메시지
  final String insightMessage;

  /// 매력 포인트
  final String charmPoint;

  /// 오늘의 문구
  final String todayQuote;

  /// 감정 데이터 (선택)
  final EmotionShareData? emotionData;

  /// 사용자 이름
  final String? userName;

  /// 공유 완료 콜백
  final void Function(ShareOption option)? onShare;

  const SharePreviewModal({
    super.key,
    required this.insightMessage,
    required this.charmPoint,
    required this.todayQuote,
    this.emotionData,
    this.userName,
    this.onShare,
  });

  /// 모달 표시
  static Future<void> show(
    BuildContext context, {
    required String insightMessage,
    required String charmPoint,
    required String todayQuote,
    EmotionShareData? emotionData,
    String? userName,
    void Function(ShareOption option)? onShare,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharePreviewModal(
        insightMessage: insightMessage,
        charmPoint: charmPoint,
        todayQuote: todayQuote,
        emotionData: emotionData,
        userName: userName,
        onShare: onShare,
      ),
    );
  }

  @override
  State<SharePreviewModal> createState() => _SharePreviewModalState();
}

class _SharePreviewModalState extends State<SharePreviewModal> {
  ShareCardType _selectedCardType = ShareCardType.insight;
  bool _includeAppLogo = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? DSColors.borderDark : DSColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 헤더
          _buildHeader(context, isDark),
          const SizedBox(height: 20),

          // 카드 타입 선택
          _buildCardTypeSelector(context, isDark),
          const SizedBox(height: 20),

          // 미리보기
          _buildPreview(context, isDark),
          const SizedBox(height: 20),

          // 옵션
          _buildOptions(context, isDark),
          const SizedBox(height: 20),

          // 공유 버튼들
          _buildShareButtons(context, isDark),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms);
  }

  /// 헤더
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('📤', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 나 공유하기',
                  style: context.heading4.copyWith(
                    color: isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                  ),
                ),
                Text(
                  '예쁜 카드로 친구들과 나눠요',
                  style: context.labelSmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 카드 타입 선택
  Widget _buildCardTypeSelector(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: ShareCardType.values.map((type) {
          final isSelected = _selectedCardType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCardType = type),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DSColors.accent
                      : isDark
                          ? DSColors.borderDark.withValues(alpha: 0.5)
                          : DSColors.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTypeEmoji(type),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTypeLabel(type),
                      style: context.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? DSColors.textSecondaryDark
                                : DSColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 미리보기
  Widget _buildPreview(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildPreviewCard(),
      ),
    );
  }

  /// 미리보기 카드
  Widget _buildPreviewCard() {
    switch (_selectedCardType) {
      case ShareCardType.insight:
        return InstagramShareCard(
          size: 280,
          insightMessage: widget.insightMessage,
          charmPoint: widget.charmPoint,
          todayQuote: widget.todayQuote,
          userName: _includeAppLogo ? widget.userName : null,
        );
      case ShareCardType.emotion:
        if (widget.emotionData != null) {
          return EmotionShareCard(
            size: 280,
            emotion: widget.emotionData!.emotion,
            emotionEmoji: widget.emotionData!.emoji,
            message: widget.emotionData!.message,
            emotionPercentage: widget.emotionData!.percentage,
          );
        }
        return InstagramShareCard(
          size: 280,
          insightMessage: widget.insightMessage,
          charmPoint: widget.charmPoint,
          todayQuote: widget.todayQuote,
        );
      case ShareCardType.minimal:
        return _buildMinimalCard();
    }
  }

  /// 미니멀 카드
  Widget _buildMinimalCard() {
    return Container(
      width: 280,
      height: 280,
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            widget.todayQuote,
            style: TextStyle(
              fontSize: 16,
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (_includeAppLogo)
            Text(
              '관상은 과학이다',
              style: TextStyle(
                fontSize: 10,
                color: DSColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  /// 옵션
  Widget _buildOptions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _includeAppLogo = !_includeAppLogo),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _includeAppLogo
                      ? DSColors.accent.withValues(alpha: 0.1)
                      : isDark
                          ? DSColors.borderDark.withValues(alpha: 0.3)
                          : DSColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _includeAppLogo
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: _includeAppLogo
                          ? DSColors.accent
                          : isDark
                              ? DSColors.textSecondaryDark
                              : DSColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '앱 로고 포함',
                      style: context.labelSmall.copyWith(
                        color: _includeAppLogo
                            ? DSColors.accent
                            : isDark
                                ? DSColors.textSecondaryDark
                                : DSColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공유 버튼들
  Widget _buildShareButtons(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 인스타그램 스토리
          _buildShareButton(
            context,
            icon: Icons.camera_alt,
            label: '인스타그램 스토리',
            color: const Color(0xFFE1306C),
            onTap: () => _handleShare(ShareOption.instagramStory),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 이미지 저장
              Expanded(
                child: _buildShareButton(
                  context,
                  icon: Icons.download,
                  label: '이미지 저장',
                  color: DSColors.accent,
                  onTap: () => _handleShare(ShareOption.saveImage),
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 10),
              // 더보기
              Expanded(
                child: _buildShareButton(
                  context,
                  icon: Icons.share,
                  label: '더보기',
                  color: DSColors.accentSecondary,
                  onTap: () => _handleShare(ShareOption.more),
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 공유 버튼
  Widget _buildShareButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isCompact ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 공유 처리
  void _handleShare(ShareOption option) {
    widget.onShare?.call(option);
    Navigator.of(context).pop();
  }

  /// 타입 이모지
  String _getTypeEmoji(ShareCardType type) {
    switch (type) {
      case ShareCardType.insight:
        return '✨';
      case ShareCardType.emotion:
        return '😊';
      case ShareCardType.minimal:
        return '🎨';
    }
  }

  /// 타입 라벨
  String _getTypeLabel(ShareCardType type) {
    switch (type) {
      case ShareCardType.insight:
        return '인사이트';
      case ShareCardType.emotion:
        return '감정';
      case ShareCardType.minimal:
        return '미니멀';
    }
  }
}

/// 카드 타입
enum ShareCardType {
  insight,
  emotion,
  minimal,
}

/// 공유 옵션
enum ShareOption {
  instagramStory,
  saveImage,
  more,
}

/// 감정 공유 데이터
class EmotionShareData {
  final String emotion;
  final String emoji;
  final String message;
  final int percentage;

  EmotionShareData({
    required this.emotion,
    required this.emoji,
    required this.message,
    required this.percentage,
  });
}
