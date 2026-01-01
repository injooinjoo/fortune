import 'package:freezed_annotation/freezed_annotation.dart';
import 'sports_schedule.dart';

part 'match_insight.freezed.dart';
part 'match_insight.g.dart';

/// 경기 인사이트 결과 모델
@freezed
class MatchInsight with _$MatchInsight {
  const factory MatchInsight({
    required String id,
    @Default('match-insight') String fortuneType,
    required int score,
    required String content,
    required String summary,
    required String advice,
    required MatchPrediction prediction,
    required TeamAnalysis favoriteTeamAnalysis,
    required TeamAnalysis opponentAnalysis,
    required FortuneElements fortuneElements,
    required String cautionMessage,
    @Default(false) bool isBlurred,
    @Default([]) List<String> blurredSections,
    required DateTime timestamp,
    int? percentile,
    // 경기 정보
    required SportType sport,
    required String homeTeam,
    required String awayTeam,
    required DateTime gameDate,
    String? favoriteTeam,
  }) = _MatchInsight;

  factory MatchInsight.fromJson(Map<String, dynamic> json) =>
      _$MatchInsightFromJson(json);
}

/// 경기 예측 모델
@freezed
class MatchPrediction with _$MatchPrediction {
  const factory MatchPrediction({
    required int winProbability,
    required String confidence, // 'high' | 'medium' | 'low'
    required List<String> keyFactors,
    String? predictedScore,
    String? mvpCandidate,
  }) = _MatchPrediction;

  factory MatchPrediction.fromJson(Map<String, dynamic> json) =>
      _$MatchPredictionFromJson(json);
}

/// MatchPrediction 확장 메서드
extension MatchPredictionExtension on MatchPrediction {
  String get confidenceText {
    switch (confidence) {
      case 'high':
        return '높음';
      case 'medium':
        return '중간';
      case 'low':
        return '낮음';
      default:
        return confidence;
    }
  }

  String get confidenceEmoji {
    switch (confidence) {
      case 'high':
        return '🔥';
      case 'medium':
        return '⚡';
      case 'low':
        return '💭';
      default:
        return '❓';
    }
  }
}

/// 팀 분석 모델
@freezed
class TeamAnalysis with _$TeamAnalysis {
  const factory TeamAnalysis({
    required String name,
    required String recentForm,
    required List<String> strengths,
    required List<String> concerns,
    String? keyPlayer,
    String? formEmoji, // 예: "🔥" (상승세), "📉" (하락세)
  }) = _TeamAnalysis;

  factory TeamAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TeamAnalysisFromJson(json);
}

/// 행운 요소 모델
@freezed
class FortuneElements with _$FortuneElements {
  const factory FortuneElements({
    required String luckyColor,
    required int luckyNumber,
    required String luckyTime,
    required String luckyItem,
    String? luckySection, // 야구: "3회", 축구: "전반", e스포츠: "1세트"
    String? luckyAction, // "응원가 부르기", "파도타기"
  }) = _FortuneElements;

  factory FortuneElements.fromJson(Map<String, dynamic> json) =>
      _$FortuneElementsFromJson(json);
}

/// MatchInsight 확장 메서드
extension MatchInsightExtension on MatchInsight {
  /// 경기 제목
  String get matchTitle => '$homeTeam vs $awayTeam';

  /// 종목 이모지
  String get sportEmoji => sport.emoji;

  /// 종목 리그명
  String get leagueName => sport.league;

  /// 승률 바 진행도 (0.0 ~ 1.0)
  double get winProbabilityProgress => prediction.winProbability / 100.0;

  /// 기본 면책 메시지
  static const String defaultCautionMessage =
      '이 인사이트는 순수 재미 목적입니다. 도박이나 베팅에 활용하지 마세요.';

  /// Empty/Default 인스턴스
  static MatchInsight empty() => MatchInsight(
        id: '',
        score: 50,
        content: '',
        summary: '',
        advice: '',
        prediction: const MatchPrediction(
          winProbability: 50,
          confidence: 'medium',
          keyFactors: [],
        ),
        favoriteTeamAnalysis: const TeamAnalysis(
          name: '',
          recentForm: '',
          strengths: [],
          concerns: [],
        ),
        opponentAnalysis: const TeamAnalysis(
          name: '',
          recentForm: '',
          strengths: [],
          concerns: [],
        ),
        fortuneElements: const FortuneElements(
          luckyColor: '',
          luckyNumber: 0,
          luckyTime: '',
          luckyItem: '',
        ),
        cautionMessage: defaultCautionMessage,
        timestamp: DateTime.now(),
        sport: SportType.baseball,
        homeTeam: '',
        awayTeam: '',
        gameDate: DateTime.now(),
      );
}
