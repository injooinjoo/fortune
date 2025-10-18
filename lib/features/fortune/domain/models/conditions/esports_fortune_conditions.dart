import '../fortune_conditions.dart';

/// e스포츠 운세 조건
class EsportsFortuneConditions extends FortuneConditions {
  final String game;
  final String position;
  final String teamRole;
  final DateTime date;

  EsportsFortuneConditions({
    required this.game,
    required this.position,
    required this.teamRole,
    required this.date,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'game:${game.hashCode}',
      'pos:${position.hashCode}',
      'role:${teamRole.hashCode}',
      'date:${_formatDate(date)}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'game': game,
      'position': position,
      'team_role': teamRole,
      'date': date.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'game': game,
      'position': position,
      'team_role': teamRole,
      'date': _formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'game': game,
      'position': position,
      'team_role': teamRole,
      'date': date.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EsportsFortuneConditions &&
          runtimeType == other.runtimeType &&
          game == other.game &&
          position == other.position &&
          teamRole == other.teamRole &&
          date == other.date;

  @override
  int get hashCode =>
      game.hashCode ^ position.hashCode ^ teamRole.hashCode ^ date.hashCode;
}
