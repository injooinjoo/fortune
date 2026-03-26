import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/extensions/l10n_extension.dart';
import 'package:fortune/core/utils/haptic_utils.dart';
import '../../../../core/widgets/paper_runtime_chrome.dart';
import '../../../../core/widgets/paper_runtime_surface_kit.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';

/// 인스타그램 스타일 캐릭터 프로필 페이지
class CharacterProfilePage extends ConsumerStatefulWidget {
  final String characterId;
  final AiCharacter? character;

  const CharacterProfilePage({
    super.key,
    required this.characterId,
    this.character,
  });

  @override
  ConsumerState<CharacterProfilePage> createState() =>
      _CharacterProfilePageState();
}

class _CharacterProfilePageState extends ConsumerState<CharacterProfilePage> {
  late AiCharacter _character;
  bool _didHandleOpenChatRoute = false;

  @override
  void initState() {
    super.initState();
    final characters = ref.read(charactersProvider);
    _character = widget.character ??
        ref.read(characterByIdProvider(widget.characterId)) ??
        characters.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleOpenChatRoute();
    });
  }

  void _handleOpenChatRoute() {
    if (_didHandleOpenChatRoute) return;

    final uri = GoRouterState.of(context).uri;
    final shouldOpenChat = uri.queryParameters['openCharacterChat'] == 'true';
    if (!shouldOpenChat) return;

    _didHandleOpenChatRoute = true;
    final queryParameters = <String, String>{
      'openCharacterChat': 'true',
      'characterId': _character.id,
      if (uri.queryParameters['fortuneType'] case final fortuneType?
          when fortuneType.isNotEmpty)
        'fortuneType': fortuneType,
      if (uri.queryParameters['autoStartFortune'] case final autoStart?
          when autoStart.isNotEmpty)
        'autoStartFortune': autoStart,
      if (uri.queryParameters['entrySource'] case final entrySource?
          when entrySource.isNotEmpty)
        'entrySource': entrySource,
    };
    context.go(
      Uri(path: '/chat', queryParameters: queryParameters).toString(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCharacter = widget.character ??
        ref.watch(characterByIdProvider(widget.characterId));
    if (resolvedCharacter != null) {
      _character = resolvedCharacter;
    }

    final colors = context.colors;
    final chatState = ref.watch(characterChatProvider(_character.id));
    final affinity = chatState.affinity;
    final messageCount = chatState.messages.length;
    final tags = CharacterLocalizer.resolveTags(context, _character).take(4);
    final avatarTextColor = _bestReadableForeground(
      background: _character.accentColor,
      primary: DSColors.textPrimary,
      secondary: DSColors.textPrimaryDark,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PaperRuntimeAppBar(
        title: CharacterLocalizer.resolveName(context, _character),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
        ),
      ),
      body: PaperRuntimeBackground(
        applySafeArea: false,
        ringAlignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_character.avatarAsset.isNotEmpty)
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: _character.accentColor,
                    child: ClipOval(
                      child: SmartImage(
                        path: _character.avatarAsset,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: _character.accentColor,
                    child: Text(
                      _character.initial,
                      style: context.heading2.copyWith(
                        color: avatarTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: DSSpacing.lg),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          count: '$messageCount',
                          label: context.l10n.conversation,
                        ),
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          count: '${affinity.lovePercent}%',
                          label: context.l10n.affinity,
                        ),
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          count: CharacterLocalizer.getAffinityPhaseName(
                            context,
                            affinity.phase,
                          ),
                          label: context.l10n.relationship,
                          isText: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xl),
            Text(
              CharacterLocalizer.resolveName(context, _character),
              style: context.heading3.copyWith(
                color: colors.textPrimary,
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.xs),
              Text(
                tags.map((tag) => '#$tag').join(' '),
                style: context.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: DSSpacing.sm),
            Text(
              CharacterLocalizer.resolveShortDescription(context, _character),
              style: context.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            _buildMessageButton(context),
            const SizedBox(height: DSSpacing.lg),
            _buildSection(
              context: context,
              icon: Icons.auto_stories,
              title: context.l10n.worldview,
              content: CharacterLocalizer.resolveWorldview(context, _character)
                  .trim(),
            ),
            const SizedBox(height: DSSpacing.md),
            _buildSection(
              context: context,
              icon: Icons.person_outline,
              title: context.l10n.characterLabel,
              content:
                  CharacterLocalizer.resolvePersonality(context, _character)
                      .trim(),
            ),
            if (_character.npcProfiles != null &&
                _character.npcProfiles!.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.md),
              _buildNpcSection(context),
            ],
            const SizedBox(height: DSSpacing.md),
            PaperRuntimePanel(
              elevated: false,
              child: Text(
                '"${CharacterLocalizer.resolveCreatorComment(context, _character)}"',
                style: context.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 컬럼
  Widget _buildStatColumn(
    BuildContext context, {
    required String count,
    required String label,
    bool isText = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: (isText ? context.bodySmall : context.heading4).copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 메시지 보내기 버튼
  Widget _buildMessageButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticUtils.lightImpact();
          ref
              .read(characterChatProvider(_character.id).notifier)
              .startConversation(_character.firstMessage);
          // 캐릭터 선택 provider 설정 → SwipeHomeShell이 감지하여 채팅 패널 열기
          ref.read(selectedCharacterProvider.notifier).state = _character;
          ref.read(chatModeProvider.notifier).state = ChatMode.character;
          // 프로필 페이지 닫기
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: Text(
          context.l10n.sendMessage,
          style: context.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.textPrimary,
          foregroundColor: context.colors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.full),
          ),
        ),
      ),
    );
  }

  Color _bestReadableForeground({
    required Color background,
    required Color primary,
    required Color secondary,
  }) {
    final primaryContrast = _contrastRatio(background, primary);
    final secondaryContrast = _contrastRatio(background, secondary);
    return primaryContrast >= secondaryContrast ? primary : secondary;
  }

  double _contrastRatio(Color a, Color b) {
    final luminanceA = a.computeLuminance();
    final luminanceB = b.computeLuminance();
    final lighter = luminanceA >= luminanceB ? luminanceA : luminanceB;
    final darker = luminanceA >= luminanceB ? luminanceB : luminanceA;
    return (lighter + 0.05) / (darker + 0.05);
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return PaperRuntimePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: _character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: context.bodyMedium.copyWith(
              height: 1.6,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNpcSection(BuildContext context) {
    return PaperRuntimePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                size: 20,
                color: _character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.characterList,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_character.npcProfiles?.entries ?? []).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: context.bodyMedium.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          TextSpan(text: entry.value),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(context.l10n.resetConversation),
              onTap: () {
                Navigator.pop(ctx);
                _showResetConfirmDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(context.l10n.shareProfile),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: 공유 기능
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.resetConversation),
        content: Text(
          context.l10n.resetConversationConfirm(
              CharacterLocalizer.resolveName(context, _character)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              unawaited(
                ref
                    .read(characterChatProvider(_character.id).notifier)
                    .clearConversationData(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.conversationResetSuccess(
                      CharacterLocalizer.resolveName(context, _character))),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
  }
}
