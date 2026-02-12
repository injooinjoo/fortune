import 'package:flutter/material.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';

/// 캐릭터 소개 카드 (첫 대화 시작 전)
class CharacterIntroCard extends StatelessWidget {
  final AiCharacter character;
  final VoidCallback onStartConversation;

  const CharacterIntroCard({
    super.key,
    required this.character,
    required this.onStartConversation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 아바타
          CircleAvatar(
            radius: 48,
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
          const SizedBox(height: 16),
          // 이름
          Text(
            CharacterLocalizer.getName(context, character.id),
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
            children: CharacterLocalizer.getTags(context, character.id).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: character.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: context.labelMedium.copyWith(
                    color: character.accentColor,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // 세계관
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 18,
                      color: character.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.worldview,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: character.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CharacterLocalizer.getWorldview(context, character.id).trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 캐릭터 특징
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: character.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.characterLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: character.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CharacterLocalizer.getPersonality(context, character.id).trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 제작자 코멘트
          Text(
            '"${CharacterLocalizer.getCreatorComment(context, character.id)}"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // 대화 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartConversation,
              style: ElevatedButton.styleFrom(
                backgroundColor: character.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.startConversation,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
