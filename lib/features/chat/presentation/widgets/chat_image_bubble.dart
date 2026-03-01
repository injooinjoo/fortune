import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/smart_image.dart';

/// 채팅 이미지 버블 위젯
///
/// SmartImage를 사용하여 URL/Asset 자동 처리.
/// 캡션 지원 및 탭 시 콜백 제공.
class ChatImageBubble extends StatelessWidget {
  /// 이미지 경로 (URL 또는 asset 경로)
  final String imagePath;

  /// 이미지 아래 표시될 캡션 (선택적)
  final String? caption;

  /// 최대 너비 (기본값: 220)
  final double maxWidth;

  /// 최대 높이 (기본값: 200)
  final double maxHeight;

  /// 이미지 탭 시 콜백
  final VoidCallback? onTap;

  /// 사용자 메시지 여부 (정렬 결정)
  final bool isUser;

  const ChatImageBubble({
    super.key,
    required this.imagePath,
    this.caption,
    this.maxWidth = 220,
    this.maxHeight = 200,
    this.onTap,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.xxs,
        horizontal: DSSpacing.md,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 이미지 버블
            GestureDetector(
              onTap: onTap,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SmartImage(
                    path: imagePath,
                    width: maxWidth,
                    height: maxHeight,
                    fit: BoxFit.cover,
                    errorWidget: _buildErrorWidget(colors),
                  ),
                ),
              ),
            ),

            // 캡션 (있으면 표시)
            if (caption != null && caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: DSSpacing.xxs),
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  child: Text(
                    caption!,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 이미지 로드 실패 시 표시할 위젯
  Widget _buildErrorWidget(DSColorScheme colors) {
    return Container(
      width: maxWidth,
      height: maxHeight,
      color: colors.backgroundSecondary,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}
