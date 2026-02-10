import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/fortune_metadata.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/ai_character.dart';
import '../providers/character_chat_provider.dart';

/// 캐릭터 프로필 BottomSheet
class CharacterProfileSheet extends ConsumerWidget {
  final AiCharacter character;
  final VoidCallback? onResetConversation;
  final ScrollController? scrollController;

  const CharacterProfileSheet({
    super.key,
    required this.character,
    this.onResetConversation,
    this.scrollController,
  });

  /// BottomSheet로 표시
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required AiCharacter character,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => CharacterProfileSheet(
          character: character,
          scrollController: scrollController,
          onResetConversation: () {
            // 대화 초기화
            ref.read(characterChatProvider(character.id).notifier).clearConversation();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${character.name}와의 대화가 초기화되었습니다'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DSColors.backgroundDark : DSColors.backgroundDark;
    final sectionBgColor = isDark ? DSColors.surfaceDark : Colors.grey[100];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // 인스타그램 스타일 프로필 헤더
                  _buildInstagramHeader(context, ref),
                  const SizedBox(height: 16),
                  // 이름
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // 태그
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: character.tags.take(5).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: character.accentColor.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$tag',
                          style: context.bodySmall.copyWith(
                            color: character.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // 짧은 설명
                  Text(
                    character.shortDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // 세계관 섹션
                  _buildSection(
                    context: context,
                    icon: Icons.auto_stories,
                    title: '세계관',
                    content: character.worldview.trim(),
                    bgColor: sectionBgColor!,
                  ),
                  const SizedBox(height: 12),
                  // 성격 섹션
                  _buildSection(
                    context: context,
                    icon: Icons.person,
                    title: '캐릭터',
                    content: character.personality.trim(),
                    bgColor: sectionBgColor,
                  ),
                  // 전문 분야 (운세 전문가인 경우)
                  if (character.isFortuneExpert && character.specialties.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSpecialtiesSection(context, sectionBgColor),
                  ],
                  // NPC 프로필 (있는 경우)
                  if (character.npcProfiles != null &&
                      character.npcProfiles!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildNpcSection(context, sectionBgColor),
                  ],
                  const SizedBox(height: 16),
                  // 호감도 섹션
                  _buildAffinitySection(context, ref, sectionBgColor),
                  const SizedBox(height: 16),
                  // 제작자 코멘트
                  Text(
                    '"${character.creatorComment}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // 액션 버튼
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 인스타그램 스타일 프로필 헤더 (아바타 + 통계)
  Widget _buildInstagramHeader(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(characterChatProvider(character.id));
    final affinity = chatState.affinity;
    final messageCount = chatState.messages.length;

    return Row(
      children: [
        // 큰 아바타
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: character.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 44,
            backgroundColor: character.accentColor,
            child: Text(
              character.initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // 통계 (인스타 스타일)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                context,
                count: '$messageCount',
                label: '대화',
              ),
              _buildStatColumn(
                context,
                count: '${affinity.lovePercent}%',
                label: '호감도',
              ),
              _buildStatColumn(
                context,
                count: affinity.phaseName,
                label: '관계',
                isText: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 통계 컬럼 위젯
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
            color: character.accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: character.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesSection(BuildContext context, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                '전문 분야',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: character.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: character.specialties.map((specialty) {
              final fortuneType = FortuneType.fromKey(specialty);
              final displayName = fortuneType?.displayName ?? specialty;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: character.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: character.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      size: 14,
                      color: character.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      displayName,
                      style: context.bodySmall.copyWith(
                        color: character.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAffinitySection(BuildContext context, WidgetRef ref, Color bgColor) {
    final chatState = ref.watch(characterChatProvider(character.id));
    final affinity = chatState.affinity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 20,
                color: character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                '호감도',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: character.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 호감도 바
          Row(
            children: [
              Text(
                affinity.loveEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로그레스 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: affinity.lovePercent / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          character.accentColor,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 퍼센트 + 단계
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${affinity.lovePercent}%',
                          style: context.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: character.accentColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: character.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            affinity.phaseName,
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: character.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNpcSection(BuildContext context, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                size: 20,
                color: character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                '등장인물',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: character.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...character.npcProfiles!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: character.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showResetConfirmDialog(context),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('대화 초기화'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[400],
              side: BorderSide(color: Colors.red[400]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 초기화'),
        content: Text(
          '${character.name}와의 대화 내용이 모두 삭제됩니다.\n정말 초기화하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog 닫기
              onResetConversation?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}
