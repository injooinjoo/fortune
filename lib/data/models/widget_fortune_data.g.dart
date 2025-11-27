// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_fortune_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WidgetFortuneDataImpl _$$WidgetFortuneDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WidgetFortuneDataImpl(
      type: json['type'] as String,
      icon: json['icon'] as String,
      title: json['title'] as String,
      lastUpdated: json['lastUpdated'] as String,
      score: json['score'] as String?,
      message: json['message'] as String?,
      percentile: json['percentile'] as String?,
      extraData: json['extraData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WidgetFortuneDataImplToJson(
        _$WidgetFortuneDataImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'icon': instance.icon,
      'title': instance.title,
      'lastUpdated': instance.lastUpdated,
      'score': instance.score,
      'message': instance.message,
      'percentile': instance.percentile,
      'extraData': instance.extraData,
    };

_$DailyWidgetDataImpl _$$DailyWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyWidgetDataImpl(
      score: json['score'] as String,
      luckyColor: json['luckyColor'] as String?,
      luckyNumber: json['luckyNumber'] as String?,
      message: json['message'] as String?,
      percentile: json['percentile'] as String?,
    );

Map<String, dynamic> _$$DailyWidgetDataImplToJson(
        _$DailyWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'luckyColor': instance.luckyColor,
      'luckyNumber': instance.luckyNumber,
      'message': instance.message,
      'percentile': instance.percentile,
    };

_$LoveWidgetDataImpl _$$LoveWidgetDataImplFromJson(Map<String, dynamic> json) =>
    _$LoveWidgetDataImpl(
      score: json['score'] as String,
      goodDay: json['goodDay'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$LoveWidgetDataImplToJson(
        _$LoveWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'goodDay': instance.goodDay,
      'message': instance.message,
    };

_$CareerWidgetDataImpl _$$CareerWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CareerWidgetDataImpl(
      score: json['score'] as String,
      luckyTime: json['luckyTime'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CareerWidgetDataImplToJson(
        _$CareerWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'luckyTime': instance.luckyTime,
      'message': instance.message,
    };

_$InvestmentWidgetDataImpl _$$InvestmentWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$InvestmentWidgetDataImpl(
      lottoNumbers: (json['lottoNumbers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sector: json['sector'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$InvestmentWidgetDataImplToJson(
        _$InvestmentWidgetDataImpl instance) =>
    <String, dynamic>{
      'lottoNumbers': instance.lottoNumbers,
      'sector': instance.sector,
      'message': instance.message,
    };

_$MbtiWidgetDataImpl _$$MbtiWidgetDataImplFromJson(Map<String, dynamic> json) =>
    _$MbtiWidgetDataImpl(
      mbtiType: json['mbtiType'] as String,
      energyLevel: json['energyLevel'] as String?,
      mood: json['mood'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$MbtiWidgetDataImplToJson(
        _$MbtiWidgetDataImpl instance) =>
    <String, dynamic>{
      'mbtiType': instance.mbtiType,
      'energyLevel': instance.energyLevel,
      'mood': instance.mood,
      'message': instance.message,
    };

_$TarotWidgetDataImpl _$$TarotWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TarotWidgetDataImpl(
      cardName: json['cardName'] as String,
      cardImage: json['cardImage'] as String?,
      interpretation: json['interpretation'] as String?,
    );

Map<String, dynamic> _$$TarotWidgetDataImplToJson(
        _$TarotWidgetDataImpl instance) =>
    <String, dynamic>{
      'cardName': instance.cardName,
      'cardImage': instance.cardImage,
      'interpretation': instance.interpretation,
    };

_$BiorhythmWidgetDataImpl _$$BiorhythmWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BiorhythmWidgetDataImpl(
      physical: json['physical'] as String,
      emotional: json['emotional'] as String,
      intellectual: json['intellectual'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$BiorhythmWidgetDataImplToJson(
        _$BiorhythmWidgetDataImpl instance) =>
    <String, dynamic>{
      'physical': instance.physical,
      'emotional': instance.emotional,
      'intellectual': instance.intellectual,
      'message': instance.message,
    };

_$CompatibilityWidgetDataImpl _$$CompatibilityWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CompatibilityWidgetDataImpl(
      score: json['score'] as String,
      partnerName: json['partnerName'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CompatibilityWidgetDataImplToJson(
        _$CompatibilityWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'partnerName': instance.partnerName,
      'message': instance.message,
    };

_$HealthWidgetDataImpl _$$HealthWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthWidgetDataImpl(
      score: json['score'] as String,
      warningArea: json['warningArea'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$HealthWidgetDataImplToJson(
        _$HealthWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'warningArea': instance.warningArea,
      'message': instance.message,
    };

_$DreamWidgetDataImpl _$$DreamWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$DreamWidgetDataImpl(
      symbol: json['symbol'] as String?,
      meaning: json['meaning'] as String?,
    );

Map<String, dynamic> _$$DreamWidgetDataImplToJson(
        _$DreamWidgetDataImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'meaning': instance.meaning,
    };

_$LuckyItemsWidgetDataImpl _$$LuckyItemsWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$LuckyItemsWidgetDataImpl(
      items:
          (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$LuckyItemsWidgetDataImplToJson(
        _$LuckyItemsWidgetDataImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'message': instance.message,
    };

_$TraditionalSajuWidgetDataImpl _$$TraditionalSajuWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TraditionalSajuWidgetDataImpl(
      summary: json['summary'] as String?,
      todayFortune: json['todayFortune'] as String?,
    );

Map<String, dynamic> _$$TraditionalSajuWidgetDataImplToJson(
        _$TraditionalSajuWidgetDataImpl instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'todayFortune': instance.todayFortune,
    };

_$FaceReadingWidgetDataImpl _$$FaceReadingWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$FaceReadingWidgetDataImpl(
      score: json['score'] as String,
      features: json['features'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$FaceReadingWidgetDataImplToJson(
        _$FaceReadingWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'features': instance.features,
      'message': instance.message,
    };

_$TalentWidgetDataImpl _$$TalentWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TalentWidgetDataImpl(
      area: json['area'] as String?,
      activity: json['activity'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$TalentWidgetDataImplToJson(
        _$TalentWidgetDataImpl instance) =>
    <String, dynamic>{
      'area': instance.area,
      'activity': instance.activity,
      'message': instance.message,
    };

_$BlindDateWidgetDataImpl _$$BlindDateWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BlindDateWidgetDataImpl(
      score: json['score'] as String,
      bestDay: json['bestDay'] as String?,
      advice: json['advice'] as String?,
    );

Map<String, dynamic> _$$BlindDateWidgetDataImplToJson(
        _$BlindDateWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'bestDay': instance.bestDay,
      'advice': instance.advice,
    };

_$ExLoverWidgetDataImpl _$$ExLoverWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ExLoverWidgetDataImpl(
      score: json['score'] as String,
      possibility: json['possibility'] as String?,
      advice: json['advice'] as String?,
    );

Map<String, dynamic> _$$ExLoverWidgetDataImplToJson(
        _$ExLoverWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'possibility': instance.possibility,
      'advice': instance.advice,
    };

_$MovingWidgetDataImpl _$$MovingWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$MovingWidgetDataImpl(
      score: json['score'] as String,
      bestDirection: json['bestDirection'] as String?,
      bestDate: json['bestDate'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$MovingWidgetDataImplToJson(
        _$MovingWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'bestDirection': instance.bestDirection,
      'bestDate': instance.bestDate,
      'message': instance.message,
    };

_$PetCompatibilityWidgetDataImpl _$$PetCompatibilityWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PetCompatibilityWidgetDataImpl(
      score: json['score'] as String,
      petType: json['petType'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$PetCompatibilityWidgetDataImplToJson(
        _$PetCompatibilityWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'petType': instance.petType,
      'message': instance.message,
    };

_$FamilyHarmonyWidgetDataImpl _$$FamilyHarmonyWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$FamilyHarmonyWidgetDataImpl(
      score: json['score'] as String,
      advice: json['advice'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$FamilyHarmonyWidgetDataImplToJson(
        _$FamilyHarmonyWidgetDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'advice': instance.advice,
      'message': instance.message,
    };

_$TimeFortuneWidgetDataImpl _$$TimeFortuneWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeFortuneWidgetDataImpl(
      currentPeriod: json['currentPeriod'] as String,
      score: json['score'] as String,
      nextPeriod: json['nextPeriod'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$TimeFortuneWidgetDataImplToJson(
        _$TimeFortuneWidgetDataImpl instance) =>
    <String, dynamic>{
      'currentPeriod': instance.currentPeriod,
      'score': instance.score,
      'nextPeriod': instance.nextPeriod,
      'message': instance.message,
    };

_$AvoidPeopleWidgetDataImpl _$$AvoidPeopleWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AvoidPeopleWidgetDataImpl(
      warningType: json['warningType'] as String?,
      description: json['description'] as String?,
      advice: json['advice'] as String?,
    );

Map<String, dynamic> _$$AvoidPeopleWidgetDataImplToJson(
        _$AvoidPeopleWidgetDataImpl instance) =>
    <String, dynamic>{
      'warningType': instance.warningType,
      'description': instance.description,
      'advice': instance.advice,
    };
