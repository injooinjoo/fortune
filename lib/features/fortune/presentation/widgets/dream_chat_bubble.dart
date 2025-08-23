import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/toss_theme.dart';
import '../providers/dream_chat_provider.dart';

class DreamChatBubble extends StatelessWidget {
  final DreamChatMessage message;
  final bool showAvatar;

  const DreamChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.fortuneTeller:
        return _FortuneTellerBubble(message: message, showAvatar: showAvatar);
      case MessageType.user:
        return _UserBubble(message: message);
      case MessageType.loading:
        return _LoadingBubble(message: message);
      case MessageType.result:
        return _ResultBubble(message: message);
    }
  }
}

class _FortuneTellerBubble extends StatelessWidget {
  final DreamChatMessage message;
  final bool showAvatar;

  const _FortuneTellerBubble({required this.message, required this.showAvatar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TossTheme.spacingS,
        horizontal: TossTheme.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: TossTheme.spacingS),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: TossTheme.spacingXS),
                    child: Text(
                      '해몽가',
                      style: TossTheme.caption.copyWith(
                        color: TossTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(TossTheme.spacingM),
                  decoration: BoxDecoration(
                    color: TossTheme.backgroundWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(TossTheme.radiusS),
                      topRight: Radius.circular(TossTheme.radiusL),
                      bottomLeft: Radius.circular(TossTheme.radiusL),
                      bottomRight: Radius.circular(TossTheme.radiusL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TossTheme.body3.copyWith(
                      color: TossTheme.textBlack,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return content.animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: TossTheme.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: TossTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final DreamChatMessage message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TossTheme.spacingS,
        horizontal: TossTheme.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 60),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(TossTheme.spacingM),
                  decoration: BoxDecoration(
                    color: TossTheme.primaryBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(TossTheme.radiusL),
                      topRight: Radius.circular(TossTheme.radiusS),
                      bottomLeft: Radius.circular(TossTheme.radiusL),
                      bottomRight: Radius.circular(TossTheme.radiusL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TossTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TossTheme.body3.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return content.animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

class _LoadingBubble extends StatelessWidget {
  final DreamChatMessage message;

  const _LoadingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TossTheme.spacingS,
        horizontal: TossTheme.spacingM,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TossTheme.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: TossTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
          const SizedBox(width: TossTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: TossTheme.spacingXS),
                  child: Text(
                    '해몽가',
                    style: TossTheme.caption.copyWith(
                      color: TossTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(TossTheme.spacingM),
                  decoration: BoxDecoration(
                    color: TossTheme.backgroundWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(TossTheme.radiusS),
                      topRight: Radius.circular(TossTheme.radiusL),
                      bottomLeft: Radius.circular(TossTheme.radiusL),
                      bottomRight: Radius.circular(TossTheme.radiusL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.content,
                          style: TossTheme.body3.copyWith(
                            color: TossTheme.textBlack,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: TossTheme.spacingS),
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TossTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return content.animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }
}

class _ResultBubble extends StatelessWidget {
  final DreamChatMessage message;

  const _ResultBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TossTheme.spacingS,
        horizontal: TossTheme.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TossTheme.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: TossTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: TossTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: TossTheme.spacingXS),
                  child: Text(
                    '해몽가',
                    style: TossTheme.caption.copyWith(
                      color: TossTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(TossTheme.spacingL),
                  decoration: BoxDecoration(
                    color: TossTheme.backgroundWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(TossTheme.radiusS),
                      topRight: Radius.circular(TossTheme.radiusL),
                      bottomLeft: Radius.circular(TossTheme.radiusL),
                      bottomRight: Radius.circular(TossTheme.radiusL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: TossTheme.borderGray200,
                      width: 1,
                    ),
                  ),
                  child: MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TossTheme.body3.copyWith(
                        color: TossTheme.textBlack,
                        height: 1.6,
                      ),
                      h1: TossTheme.heading3.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: TossTheme.body1.copyWith(
                        color: TossTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      h3: TossTheme.subtitle1.copyWith(
                        color: TossTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      strong: TossTheme.body3.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      blockquote: TossTheme.body3.copyWith(
                        color: TossTheme.textGray600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return content
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TossTheme.spacingS,
        horizontal: TossTheme.spacingM,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TossTheme.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: TossTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: TossTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TossTheme.spacingM,
              vertical: TossTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: TossTheme.backgroundWhite,
              borderRadius: BorderRadius.circular(TossTheme.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delayMs: 0),
                const SizedBox(width: TossTheme.spacingXS),
                _Dot(delayMs: 200),
                const SizedBox(width: TossTheme.spacingXS),
                _Dot(delayMs: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delayMs;
  const _Dot({required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: TossTheme.textGray400,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 600.ms,
          delay: Duration(milliseconds: delayMs),
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
        )
        .then()
        .scale(
          duration: 600.ms,
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.8, 0.8),
        );
  }
}