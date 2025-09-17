import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';

/// 인지기능 퀘스트 카드 위젯 (토스 스타일)
class CognitiveQuestCard extends StatefulWidget {
  final Map<String, dynamic> quest;
  final VoidCallback? onComplete;
  final int index;
  const CognitiveQuestCard({
    super.key,
    required this.quest,
    this.onComplete,
    this.index = 0,
  });
  @override
  State<CognitiveQuestCard> createState() => _CognitiveQuestCardState();
}
class _CognitiveQuestCardState extends State<CognitiveQuestCard> 
    with SingleTickerProviderStateMixin {
  bool _isCompleted = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  void initState() {
    super.initState();
    _isCompleted = widget.quest['completed'] ?? false;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  void dispose() {
    _controller.dispose();
    super.dispose();
  void _handleTap() {
    if (_isCompleted) return;
    HapticFeedback.lightImpact();
    _controller.forward().then((_) {
      _controller.reverse();
    });
    setState(() {
      _isCompleted = true;
    
    widget.onComplete?.call();
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final difficulty = widget.quest['difficulty'] as String;
    final points = widget.quest['points'] as int;
    final questText = widget.quest['quest'] as String;
    final icon = widget.quest['icon'] as String;
    final type = widget.quest['type'] as String;
    final function = widget.quest['function'] as String;
    final color = _getDifficultyColor(difficulty);
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: TossCard(
            style: TossCardStyle.elevated,
            margin: EdgeInsets.only(bottom: TossDesignSystem.spacingM),
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                border: Border.all(
                  color: _isCompleted 
                      ? TossDesignSystem.successGreen.withOpacity(0.3)
                      : TossDesignSystem.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      // 아이콘
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                      ),
                      SizedBox(width: TossDesignSystem.spacingM),
                      
                      // 타이틀
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: TossDesignSystem.spacingS,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusXS),
                                  child: Text(
                                    function,
                                    style: TossDesignSystem.caption.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                ),
                                SizedBox(width: TossDesignSystem.spacingXS),
                                Text(
                                  type,
                                  style: TossDesignSystem.caption.copyWith(
                                    color: isDark 
                                        ? TossDesignSystem.grayDark400
                                        : TossDesignSystem.gray600,
                              ],
                            ),
                            SizedBox(height: TossDesignSystem.spacingXS),
                            _buildDifficultyBadge(difficulty, color),
                          ],
                      // 포인트
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_isCompleted)
                            Icon(
                              Icons.check_circle_rounded,
                              color: TossDesignSystem.successGreen,
                              size: 24,
                            )
                          else
                            Text(
                              '+$points',
                              style: TossDesignSystem.heading4.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                          if (!_isCompleted)
                              '포인트',
                              style: TossDesignSystem.caption.copyWith(
                                color: isDark 
                                    ? TossDesignSystem.grayDark400
                                    : TossDesignSystem.gray600,
                        ],
                    ],
                  ),
                  
                  SizedBox(height: TossDesignSystem.spacingM),
                  // 퀘스트 내용
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TossDesignSystem.body2.copyWith(
                      color: _isCompleted
                          ? (isDark 
                              ? TossDesignSystem.grayDark400
                              : TossDesignSystem.gray400)
                          : (isDark 
                              ? TossDesignSystem.grayDark900
                              : TossDesignSystem.gray900),
                      decoration: _isCompleted 
                          ? TextDecoration.lineThrough 
                          : TextDecoration.none,
                    ),
                    child: Text(questText),
                  if (_isCompleted) ...[
                    SizedBox(height: TossDesignSystem.spacingS),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: TossDesignSystem.spacingM,
                        vertical: TossDesignSystem.spacingS,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                          Icon(
                            Icons.check_rounded,
                            color: TossDesignSystem.successGreen,
                            size: 16,
                          SizedBox(width: TossDesignSystem.spacingXS),
                          Text(
                            '완료! +$points 포인트 획득',
                            style: TossDesignSystem.caption.copyWith(
                              fontWeight: FontWeight.w600,
                    ).animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: 0.8, end: 1.0),
                  ],
                ],
            ),
          ),
        );
      },
    ).animate()
      .fadeIn(
        delay: Duration(milliseconds: widget.index * 100),
        duration: 400.ms,
      )
      .slideX(
        begin: 0.1,
        end: 0,
      );
  Widget _buildDifficultyBadge(String difficulty, Color color) {
    String label;
    IconData icon;
    switch (difficulty) {
      case 'easy':
        label = '쉬움';
        icon = Icons.star_rounded;
        break;
      case 'medium':
        label = '보통';
      case 'hard':
        label = '어려움';
      case 'legendary':
        label = '전설';
        icon = Icons.auto_awesome_rounded;
      default:
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4),
        Text(
          label,
          style: TossDesignSystem.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
        ),
      ],
  Color _getDifficultyColor(String difficulty) {
        return TossDesignSystem.successGreen;
        return TossDesignSystem.tossBlue;
        return TossDesignSystem.warningOrange;
        return TossDesignSystem.purple;
/// 퀘스트 리스트 컨테이너
class CognitiveQuestList extends StatelessWidget {
  final List<Map<String, dynamic>> quests;
  final Function(String questId)? onQuestComplete;
  const CognitiveQuestList({
    required this.quests,
    this.onQuestComplete,
    return TossSectionCard(
      title: '오늘의 인지기능 퀘스트',
      subtitle: '퀘스트를 완료하고 성장 포인트를 획득하세요',
      style: TossCardStyle.elevated,
      child: Column(
        children: [
          // 진행도 표시
          _buildProgressIndicator(),
          SizedBox(height: TossDesignSystem.spacingL),
          
          // 퀘스트 리스트
          ...quests.asMap().entries.map((entry) {
            return CognitiveQuestCard(
              quest: entry.value,
              index: entry.key,
              onComplete: () => onQuestComplete?.call(entry.value['id']),
            );
          }).toList(),
        ],
      ),
  Widget _buildProgressIndicator() {
    final completedCount = quests.where((q) => q['completed'] == true).length;
    final totalCount = quests.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    return Container(
      padding: EdgeInsets.all(TossDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: TossDesignSystem.tossBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행도',
                style: TossDesignSystem.body3.copyWith(
                  color: TossDesignSystem.gray600,
                '$completedCount / $totalCount 완료',
                  color: TossDesignSystem.tossBlue,
                  fontWeight: FontWeight.bold,
            ],
          SizedBox(height: TossDesignSystem.spacingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: TossDesignSystem.tossBlue.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(TossDesignSystem.tossBlue),
              minHeight: 8,
