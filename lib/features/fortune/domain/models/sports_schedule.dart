import 'package:freezed_annotation/freezed_annotation.dart';

part 'sports_schedule.freezed.dart';
part 'sports_schedule.g.dart';

/// 스포츠 종목 타입
enum SportType {
  @JsonValue('baseball')
  baseball,
  @JsonValue('soccer')
  soccer,
  @JsonValue('basketball')
  basketball,
  @JsonValue('volleyball')
  volleyball,
  @JsonValue('esports')
  esports,
  @JsonValue('american_football')
  americanFootball,
  @JsonValue('fighting')
  fighting,
}

/// SportType 확장 메서드
extension SportTypeExtension on SportType {
  String get displayName {
    switch (this) {
      case SportType.baseball:
        return '야구';
      case SportType.soccer:
        return '축구';
      case SportType.basketball:
        return '농구';
      case SportType.volleyball:
        return '배구';
      case SportType.esports:
        return 'e스포츠';
      case SportType.americanFootball:
        return '미식축구';
      case SportType.fighting:
        return '격투기';
    }
  }

  String get emoji {
    switch (this) {
      case SportType.baseball:
        return '⚾';
      case SportType.soccer:
        return '⚽';
      case SportType.basketball:
        return '🏀';
      case SportType.volleyball:
        return '🏐';
      case SportType.esports:
        return '🎮';
      case SportType.americanFootball:
        return '🏈';
      case SportType.fighting:
        return '🥊';
    }
  }

  /// 기본 리그 (한국 리그 우선, 해외는 대표 리그)
  String get league {
    switch (this) {
      case SportType.baseball:
        return 'KBO';
      case SportType.soccer:
        return 'K리그';
      case SportType.basketball:
        return 'KBL';
      case SportType.volleyball:
        return 'V리그';
      case SportType.esports:
        return 'LCK';
      case SportType.americanFootball:
        return 'NFL';
      case SportType.fighting:
        return 'UFC';
    }
  }
}

/// 스포츠 팀 모델
@freezed
class SportsTeam with _$SportsTeam {
  const factory SportsTeam({
    required String id,
    required String name,
    required String shortName,
    required SportType sport,
    required String league,
    String? logoUrl,
    String? primaryColor,
    String? city,
  }) = _SportsTeam;

  factory SportsTeam.fromJson(Map<String, dynamic> json) =>
      _$SportsTeamFromJson(json);
}

/// 경기 상태
enum GameStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('live')
  live,
  @JsonValue('finished')
  finished,
  @JsonValue('postponed')
  postponed,
  @JsonValue('cancelled')
  cancelled,
}

/// 스포츠 경기 모델
@freezed
class SportsGame with _$SportsGame {
  const factory SportsGame({
    required String id,
    required SportType sport,
    required String homeTeam,
    required String awayTeam,
    required DateTime gameTime,
    required String venue,
    @Default(GameStatus.scheduled) GameStatus status,
    String? league,
    String? season,
    String? homeTeamLogo,
    String? awayTeamLogo,
    int? homeScore,
    int? awayScore,
    Map<String, dynamic>? stats,
  }) = _SportsGame;

  factory SportsGame.fromJson(Map<String, dynamic> json) =>
      _$SportsGameFromJson(json);
}

/// SportsGame 확장 메서드
extension SportsGameExtension on SportsGame {
  /// 경기 표시 문자열 (예: "LG vs 삼성")
  String get matchTitle => '$homeTeam vs $awayTeam';

  /// 경기 날짜 포맷 (예: "1/15 (수) 18:30")
  String get formattedDateTime {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[gameTime.weekday - 1];
    final month = gameTime.month;
    final day = gameTime.day;
    final hour = gameTime.hour.toString().padLeft(2, '0');
    final minute = gameTime.minute.toString().padLeft(2, '0');
    return '$month/$day ($weekday) $hour:$minute';
  }

  /// 경기 진행 상태 텍스트
  String get statusText {
    switch (status) {
      case GameStatus.scheduled:
        return '예정';
      case GameStatus.live:
        return '진행중';
      case GameStatus.finished:
        return '종료';
      case GameStatus.postponed:
        return '연기';
      case GameStatus.cancelled:
        return '취소';
    }
  }

  /// 오늘 경기인지 확인
  bool get isToday {
    final now = DateTime.now();
    return gameTime.year == now.year &&
        gameTime.month == now.month &&
        gameTime.day == now.day;
  }

  /// 앞으로 있을 경기인지 확인
  bool get isUpcoming => gameTime.isAfter(DateTime.now());
}
