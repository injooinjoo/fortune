/// 이사운 데이터 모델
class MovingFortuneData {
  final int overallScore;
  final String bestDirection;
  final Map<String, int> directionScores;
  final List<double> monthlyScores;
  final List<DateTime> luckyDates;
  final Map<String, int> budgetBreakdown;
  final List<ChecklistItem> checklistItems;
  final Map<String, int> houseTypeScores;

  MovingFortuneData({
    required this.overallScore,
    required this.bestDirection,
    required this.directionScores,
    required this.monthlyScores,
    required this.luckyDates,
    required this.budgetBreakdown,
    required this.checklistItems,
    required this.houseTypeScores,
  });
}

/// 체크리스트 아이템
class ChecklistItem {
  final String timing;
  final String task;
  final bool isCompleted;

  ChecklistItem(this.timing, this.task, this.isCompleted);
}
