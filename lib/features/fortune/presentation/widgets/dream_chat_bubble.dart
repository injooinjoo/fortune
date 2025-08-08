import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../providers/dream_chat_provider.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

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
        vertical: AppSpacing.spacing2,
        horizontal: AppSpacing.spacing4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: AppSpacing.spacing3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAvatar)
                  Text(
                    '해몽가',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.deepPurple.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: AppSpacing.spacing1),
                GlassContainer(
                  padding: AppSpacing.paddingAll16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.3),
                      Colors.deepPurple.withOpacity(0.2),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.4,
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
      height: AppDimensions.buttonHeightSmall,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.6),
            Colors.deepPurple.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 24,
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
        vertical: AppSpacing.spacing2,
        horizontal: AppSpacing.spacing4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: AppSpacing.spacing15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: AppSpacing.paddingAll16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.4,
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
        vertical: AppSpacing.spacing2,
        horizontal: AppSpacing.spacing4,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.6),
                  Colors.deepPurple.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
          const SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '해몽가',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.deepPurple.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing1),
                GlassContainer(
                  padding: AppSpacing.paddingAll16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.3),
                      Colors.deepPurple.withOpacity(0.2),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.content,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing2),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70,
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
        vertical: AppSpacing.spacing2,
        horizontal: AppSpacing.spacing4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.6),
                  Colors.deepPurple.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '해몽가',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.deepPurple.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing1),
                GlassContainer(
                  padding: AppSpacing.paddingAll20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.4),
                      Colors.deepPurple.withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.3),
                  ),
                  child: MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        height: 1.5,
                      ),
                      h1: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.deepPurple.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                      h3: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.deepPurple.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                      strong: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      blockquote: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
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
        vertical: AppSpacing.spacing2,
        horizontal: AppSpacing.spacing4,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.6),
                  Colors.deepPurple.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing3),
          GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing5,
              vertical: AppSpacing.spacing3,
            ),
            borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delayMs: 0),
                const SizedBox(width: AppSpacing.spacing1),
                _Dot(delayMs: 200),
                const SizedBox(width: AppSpacing.spacing1),
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
      width: 8,
      height: AppSpacing.spacing2,
      decoration: const BoxDecoration(
        color: Colors.white60,
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