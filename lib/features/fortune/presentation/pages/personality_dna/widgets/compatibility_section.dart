import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'toss_section_widget.dart';

class CompatibilitySection extends StatelessWidget {
  final Compatibility compatibility;

  const CompatibilitySection({
    super.key,
    required this.compatibility,
  });

  @override
  Widget build(BuildContext context) {
    return TossSectionWidget(
      title: '궁합',
      icon: Icons.people,
      child: Column(
        children: [
          _CompatibilityCard(
            type: '친구',
            mbti: compatibility.friend.mbti,
            description: compatibility.friend.description,
          ),
          const SizedBox(height: 8),
          _CompatibilityCard(
            type: '연인',
            mbti: compatibility.lover.mbti,
            description: compatibility.lover.description,
          ),
          const SizedBox(height: 8),
          _CompatibilityCard(
            type: '동료',
            mbti: compatibility.colleague.mbti,
            description: compatibility.colleague.description,
          ),
        ],
      ),
    );
  }
}

class _CompatibilityCard extends StatelessWidget {
  final String type;
  final String mbti;
  final String description;

  const _CompatibilityCard({
    required this.type,
    required this.mbti,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type,
                style: DSTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mbti,
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
