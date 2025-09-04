import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';

class MbtiQuestCard extends StatefulWidget {
  final List<dynamic> dailyQuests;
  final bool isDark;

  const MbtiQuestCard({
    super.key,
    required this.dailyQuests,
    required this.isDark,
  });

  @override
  State<MbtiQuestCard> createState() => _MbtiQuestCardState();
}

class _MbtiQuestCardState extends State<MbtiQuestCard> {
  List<bool> questCompleted = [];

  @override
  void initState() {
    super.initState();
    questCompleted = List.generate(widget.dailyQuests.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = questCompleted.where((c) => c).length;
    final totalCount = widget.dailyQuests.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TossDesignSystem.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: TossDesignSystem.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 퀘스트',
                      style: TossDesignSystem.heading3.copyWith(
                        color: widget.isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '완료하고 성장 포인트를 획득하세요',
                      style: TossDesignSystem.caption.copyWith(
                        color: widget.isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.tossBlue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '진행도',
                      style: TossDesignSystem.body3.copyWith(
                        color: widget.isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      ),
                    ),
                    Text(
                      '$completedCount / $totalCount 완료',
                      style: TossDesignSystem.body3.copyWith(
                        color: TossDesignSystem.tossBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: TossDesignSystem.tossBlue.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(TossDesignSystem.tossBlue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quest List
          ...List.generate(widget.dailyQuests.length, (index) {
            final quest = widget.dailyQuests[index] as Map<String, dynamic>;
            return _buildQuestItem(quest, index).animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index))
              .slideX(begin: -0.1, end: 0);
          }),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
      .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildQuestItem(Map<String, dynamic> quest, int index) {
    final title = quest['title'] as String? ?? '';
    final description = quest['description'] as String? ?? '';
    final difficulty = quest['difficulty'] as String? ?? 'easy';
    final points = quest['points'] as int? ?? 10;
    final icon = quest['icon'] as String? ?? '🎯';
    final isCompleted = questCompleted[index];
    
    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          HapticFeedback.lightImpact();
          setState(() {
            questCompleted[index] = true;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted 
            ? TossDesignSystem.green.withOpacity(0.05)
            : (widget.isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
              ? TossDesignSystem.green.withOpacity(0.3)
              : (widget.isDark 
                ? TossDesignSystem.grayDark200.withOpacity(0.5)
                : TossDesignSystem.gray200.withOpacity(0.5)),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getDifficultyColor(difficulty).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TossDesignSystem.body2.copyWith(
                            color: widget.isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            fontWeight: FontWeight.w500,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      _buildDifficultyBadge(difficulty),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TossDesignSystem.caption.copyWith(
                      color: widget.isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: TossDesignSystem.green,
                size: 24,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(difficulty).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$points',
                  style: TossDesignSystem.body3.copyWith(
                    color: _getDifficultyColor(difficulty),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    String label;
    IconData icon;
    
    switch (difficulty.toLowerCase()) {
      case 'easy':
        label = '쉬움';
        icon = Icons.star;
        break;
      case 'medium':
        label = '보통';
        icon = Icons.star_half;
        break;
      case 'hard':
        label = '어려움';
        icon = Icons.star;
        break;
      case 'legendary':
        label = '전설';
        icon = Icons.auto_awesome;
        break;
      default:
        label = '쉬움';
        icon = Icons.star;
    }
    
    final color = _getDifficultyColor(difficulty);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TossDesignSystem.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return TossDesignSystem.green;
      case 'medium':
        return TossDesignSystem.tossBlue;
      case 'hard':
        return TossDesignSystem.orange;
      case 'legendary':
        return TossDesignSystem.purple;
      default:
        return TossDesignSystem.gray600;
    }
  }
}