import 'package:freezed_annotation/freezed_annotation.dart';

part 'widget_fortune_data.freezed.dart';
part 'widget_fortune_data.g.dart';

/// Base widget fortune data
/// Contains common fields for all fortune types
@freezed
class WidgetFortuneData with _$WidgetFortuneData {
  const factory WidgetFortuneData({
    required String type,
    required String icon,
    required String title,
    required String lastUpdated,
    String? score,
    String? message,
    String? percentile,
    Map<String, dynamic>? extraData,
  }) = _WidgetFortuneData;

  factory WidgetFortuneData.fromJson(Map<String, dynamic> json) =>
      _$WidgetFortuneDataFromJson(json);
}

/// Daily fortune widget data
@freezed
class DailyWidgetData with _$DailyWidgetData {
  const factory DailyWidgetData({
    required String score,
    String? luckyColor,
    String? luckyNumber,
    String? message,
    String? percentile,
  }) = _DailyWidgetData;

  factory DailyWidgetData.fromJson(Map<String, dynamic> json) =>
      _$DailyWidgetDataFromJson(json);
}

/// Love fortune widget data
@freezed
class LoveWidgetData with _$LoveWidgetData {
  const factory LoveWidgetData({
    required String score,
    String? goodDay,
    String? message,
  }) = _LoveWidgetData;

  factory LoveWidgetData.fromJson(Map<String, dynamic> json) =>
      _$LoveWidgetDataFromJson(json);
}

/// Career fortune widget data
@freezed
class CareerWidgetData with _$CareerWidgetData {
  const factory CareerWidgetData({
    required String score,
    String? luckyTime,
    String? message,
  }) = _CareerWidgetData;

  factory CareerWidgetData.fromJson(Map<String, dynamic> json) =>
      _$CareerWidgetDataFromJson(json);
}

/// Investment fortune widget data (includes lotto numbers)
@freezed
class InvestmentWidgetData with _$InvestmentWidgetData {
  const factory InvestmentWidgetData({
    @Default([]) List<String> lottoNumbers,
    String? sector,
    String? message,
  }) = _InvestmentWidgetData;

  factory InvestmentWidgetData.fromJson(Map<String, dynamic> json) =>
      _$InvestmentWidgetDataFromJson(json);
}

/// MBTI fortune widget data
@freezed
class MbtiWidgetData with _$MbtiWidgetData {
  const factory MbtiWidgetData({
    required String mbtiType,
    String? energyLevel,
    String? mood,
    String? message,
  }) = _MbtiWidgetData;

  factory MbtiWidgetData.fromJson(Map<String, dynamic> json) =>
      _$MbtiWidgetDataFromJson(json);
}

/// Tarot fortune widget data
@freezed
class TarotWidgetData with _$TarotWidgetData {
  const factory TarotWidgetData({
    required String cardName,
    String? cardImage,
    String? interpretation,
  }) = _TarotWidgetData;

  factory TarotWidgetData.fromJson(Map<String, dynamic> json) =>
      _$TarotWidgetDataFromJson(json);
}

/// Biorhythm widget data
@freezed
class BiorhythmWidgetData with _$BiorhythmWidgetData {
  const factory BiorhythmWidgetData({
    required String physical,
    required String emotional,
    required String intellectual,
    String? message,
  }) = _BiorhythmWidgetData;

  factory BiorhythmWidgetData.fromJson(Map<String, dynamic> json) =>
      _$BiorhythmWidgetDataFromJson(json);
}

/// Compatibility fortune widget data
@freezed
class CompatibilityWidgetData with _$CompatibilityWidgetData {
  const factory CompatibilityWidgetData({
    required String score,
    String? partnerName,
    String? message,
  }) = _CompatibilityWidgetData;

  factory CompatibilityWidgetData.fromJson(Map<String, dynamic> json) =>
      _$CompatibilityWidgetDataFromJson(json);
}

/// Health fortune widget data
@freezed
class HealthWidgetData with _$HealthWidgetData {
  const factory HealthWidgetData({
    required String score,
    String? warningArea,
    String? message,
  }) = _HealthWidgetData;

  factory HealthWidgetData.fromJson(Map<String, dynamic> json) =>
      _$HealthWidgetDataFromJson(json);
}

/// Dream fortune widget data
@freezed
class DreamWidgetData with _$DreamWidgetData {
  const factory DreamWidgetData({
    String? symbol,
    String? meaning,
  }) = _DreamWidgetData;

  factory DreamWidgetData.fromJson(Map<String, dynamic> json) =>
      _$DreamWidgetDataFromJson(json);
}

/// Lucky items widget data
@freezed
class LuckyItemsWidgetData with _$LuckyItemsWidgetData {
  const factory LuckyItemsWidgetData({
    @Default([]) List<String> items,
    String? message,
  }) = _LuckyItemsWidgetData;

  factory LuckyItemsWidgetData.fromJson(Map<String, dynamic> json) =>
      _$LuckyItemsWidgetDataFromJson(json);
}

/// Traditional Saju widget data
@freezed
class TraditionalSajuWidgetData with _$TraditionalSajuWidgetData {
  const factory TraditionalSajuWidgetData({
    String? summary,
    String? todayFortune,
  }) = _TraditionalSajuWidgetData;

  factory TraditionalSajuWidgetData.fromJson(Map<String, dynamic> json) =>
      _$TraditionalSajuWidgetDataFromJson(json);
}

/// Face reading widget data
@freezed
class FaceReadingWidgetData with _$FaceReadingWidgetData {
  const factory FaceReadingWidgetData({
    required String score,
    String? features,
    String? message,
  }) = _FaceReadingWidgetData;

  factory FaceReadingWidgetData.fromJson(Map<String, dynamic> json) =>
      _$FaceReadingWidgetDataFromJson(json);
}

/// Talent fortune widget data
@freezed
class TalentWidgetData with _$TalentWidgetData {
  const factory TalentWidgetData({
    String? area,
    String? activity,
    String? message,
  }) = _TalentWidgetData;

  factory TalentWidgetData.fromJson(Map<String, dynamic> json) =>
      _$TalentWidgetDataFromJson(json);
}

/// Blind date fortune widget data
@freezed
class BlindDateWidgetData with _$BlindDateWidgetData {
  const factory BlindDateWidgetData({
    required String score,
    String? bestDay,
    String? advice,
  }) = _BlindDateWidgetData;

  factory BlindDateWidgetData.fromJson(Map<String, dynamic> json) =>
      _$BlindDateWidgetDataFromJson(json);
}

/// Ex-lover fortune widget data
@freezed
class ExLoverWidgetData with _$ExLoverWidgetData {
  const factory ExLoverWidgetData({
    required String score,
    String? possibility,
    String? advice,
  }) = _ExLoverWidgetData;

  factory ExLoverWidgetData.fromJson(Map<String, dynamic> json) =>
      _$ExLoverWidgetDataFromJson(json);
}

/// Moving fortune widget data
@freezed
class MovingWidgetData with _$MovingWidgetData {
  const factory MovingWidgetData({
    required String score,
    String? bestDirection,
    String? bestDate,
    String? message,
  }) = _MovingWidgetData;

  factory MovingWidgetData.fromJson(Map<String, dynamic> json) =>
      _$MovingWidgetDataFromJson(json);
}

/// Pet compatibility widget data
@freezed
class PetCompatibilityWidgetData with _$PetCompatibilityWidgetData {
  const factory PetCompatibilityWidgetData({
    required String score,
    String? petType,
    String? message,
  }) = _PetCompatibilityWidgetData;

  factory PetCompatibilityWidgetData.fromJson(Map<String, dynamic> json) =>
      _$PetCompatibilityWidgetDataFromJson(json);
}

/// Family harmony widget data
@freezed
class FamilyHarmonyWidgetData with _$FamilyHarmonyWidgetData {
  const factory FamilyHarmonyWidgetData({
    required String score,
    String? advice,
    String? message,
  }) = _FamilyHarmonyWidgetData;

  factory FamilyHarmonyWidgetData.fromJson(Map<String, dynamic> json) =>
      _$FamilyHarmonyWidgetDataFromJson(json);
}

/// Time-based fortune widget data
@freezed
class TimeFortuneWidgetData with _$TimeFortuneWidgetData {
  const factory TimeFortuneWidgetData({
    required String currentPeriod,
    required String score,
    String? nextPeriod,
    String? message,
  }) = _TimeFortuneWidgetData;

  factory TimeFortuneWidgetData.fromJson(Map<String, dynamic> json) =>
      _$TimeFortuneWidgetDataFromJson(json);
}

/// Avoid people widget data
@freezed
class AvoidPeopleWidgetData with _$AvoidPeopleWidgetData {
  const factory AvoidPeopleWidgetData({
    String? warningType,
    String? description,
    String? advice,
  }) = _AvoidPeopleWidgetData;

  factory AvoidPeopleWidgetData.fromJson(Map<String, dynamic> json) =>
      _$AvoidPeopleWidgetDataFromJson(json);
}

/// Extension to convert widget data to map for native widget
extension WidgetFortuneDataExtension on WidgetFortuneData {
  Map<String, String> toWidgetMap() {
    final map = <String, String>{
      'type': type,
      'icon': icon,
      'title': title,
      'lastUpdated': lastUpdated,
    };

    if (score != null) map['score'] = score!;
    if (message != null) map['message'] = message!;
    if (percentile != null) map['percentile'] = percentile!;

    return map;
  }
}
