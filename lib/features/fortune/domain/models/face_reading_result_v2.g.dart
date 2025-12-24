// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_reading_result_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PriorityInsightImpl _$$PriorityInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$PriorityInsightImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      priority: (json['priority'] as num).toInt(),
      category: json['category'] as String,
      score: (json['score'] as num?)?.toInt(),
      relatedFeature: json['relatedFeature'] as String?,
    );

Map<String, dynamic> _$$PriorityInsightImplToJson(
        _$PriorityInsightImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'category': instance.category,
      'score': instance.score,
      'relatedFeature': instance.relatedFeature,
    };

_$FaceReadingResultV2Impl _$$FaceReadingResultV2ImplFromJson(
        Map<String, dynamic> json) =>
    _$FaceReadingResultV2Impl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      gender: json['gender'] as String,
      ageGroup: json['ageGroup'] as String?,
      priorityInsights: (json['priorityInsights'] as List<dynamic>?)
              ?.map((e) => PriorityInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      overallScore: (json['overallScore'] as num).toInt(),
      summaryMessage: json['summaryMessage'] as String,
      overallFortune: json['overallFortune'] as String? ?? '',
      faceType: json['faceType'] as String? ?? '',
      faceCondition: json['faceCondition'] == null
          ? null
          : FaceCondition.fromJson(
              json['faceCondition'] as Map<String, dynamic>),
      emotionAnalysis: json['emotionAnalysis'] == null
          ? null
          : EmotionAnalysis.fromJson(
              json['emotionAnalysis'] as Map<String, dynamic>),
      myeonggungAnalysis: json['myeonggungAnalysis'] == null
          ? null
          : MyeonggungAnalysis.fromJson(
              json['myeonggungAnalysis'] as Map<String, dynamic>),
      miganAnalysis: json['miganAnalysis'] == null
          ? null
          : MiganAnalysis.fromJson(
              json['miganAnalysis'] as Map<String, dynamic>),
      simplifiedOgwan: json['simplifiedOgwan'] == null
          ? null
          : SimplifiedOgwan.fromJson(
              json['simplifiedOgwan'] as Map<String, dynamic>),
      simplifiedSibigung: json['simplifiedSibigung'] == null
          ? null
          : SimplifiedSibigung.fromJson(
              json['simplifiedSibigung'] as Map<String, dynamic>),
      celebrityMatches: (json['celebrityMatches'] as List<dynamic>?)
              ?.map((e) => CelebrityMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      makeupRecommendations: json['makeupRecommendations'] == null
          ? null
          : MakeupStyleRecommendations.fromJson(
              json['makeupRecommendations'] as Map<String, dynamic>),
      luckyFeatureEnhancement: json['luckyFeatureEnhancement'] == null
          ? null
          : LuckyFeatureEnhancement.fromJson(
              json['luckyFeatureEnhancement'] as Map<String, dynamic>),
      leadershipAnalysis: json['leadershipAnalysis'] == null
          ? null
          : LeadershipAnalysis.fromJson(
              json['leadershipAnalysis'] as Map<String, dynamic>),
      watchData: json['watchData'] == null
          ? null
          : WatchFaceReadingData.fromJson(
              json['watchData'] as Map<String, dynamic>),
      isBlurred: json['isBlurred'] as bool? ?? false,
      blurredSections: (json['blurredSections'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      shareableContent: json['shareableContent'] == null
          ? null
          : ShareableContent.fromJson(
              json['shareableContent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FaceReadingResultV2ImplToJson(
        _$FaceReadingResultV2Impl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'gender': instance.gender,
      'ageGroup': instance.ageGroup,
      'priorityInsights': instance.priorityInsights,
      'overallScore': instance.overallScore,
      'summaryMessage': instance.summaryMessage,
      'overallFortune': instance.overallFortune,
      'faceType': instance.faceType,
      'faceCondition': instance.faceCondition,
      'emotionAnalysis': instance.emotionAnalysis,
      'myeonggungAnalysis': instance.myeonggungAnalysis,
      'miganAnalysis': instance.miganAnalysis,
      'simplifiedOgwan': instance.simplifiedOgwan,
      'simplifiedSibigung': instance.simplifiedSibigung,
      'celebrityMatches': instance.celebrityMatches,
      'makeupRecommendations': instance.makeupRecommendations,
      'luckyFeatureEnhancement': instance.luckyFeatureEnhancement,
      'leadershipAnalysis': instance.leadershipAnalysis,
      'watchData': instance.watchData,
      'isBlurred': instance.isBlurred,
      'blurredSections': instance.blurredSections,
      'shareableContent': instance.shareableContent,
    };

_$CelebrityMatchImpl _$$CelebrityMatchImplFromJson(Map<String, dynamic> json) =>
    _$CelebrityMatchImpl(
      name: json['name'] as String,
      matchScore: (json['matchScore'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      matchDescription: json['matchDescription'] as String?,
      commonTraits: (json['commonTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CelebrityMatchImplToJson(
        _$CelebrityMatchImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'matchScore': instance.matchScore,
      'imageUrl': instance.imageUrl,
      'matchDescription': instance.matchDescription,
      'commonTraits': instance.commonTraits,
    };

_$MyeonggungAnalysisImpl _$$MyeonggungAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$MyeonggungAnalysisImpl(
      description: json['description'] as String,
      lifeFortuneMessage: json['lifeFortuneMessage'] as String,
      score: (json['score'] as num).toInt(),
      summary: json['summary'] as String? ?? '',
      detailedAnalysis: json['detailedAnalysis'] as String?,
      destinyTraits: (json['destinyTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      advice: json['advice'] as String?,
      improvementTips: (json['improvementTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MyeonggungAnalysisImplToJson(
        _$MyeonggungAnalysisImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'lifeFortuneMessage': instance.lifeFortuneMessage,
      'score': instance.score,
      'summary': instance.summary,
      'detailedAnalysis': instance.detailedAnalysis,
      'destinyTraits': instance.destinyTraits,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'advice': instance.advice,
      'improvementTips': instance.improvementTips,
    };

_$MiganAnalysisImpl _$$MiganAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$MiganAnalysisImpl(
      description: json['description'] as String,
      fortuneMessage: json['fortuneMessage'] as String,
      score: (json['score'] as num).toInt(),
      summary: json['summary'] as String? ?? '',
      detailedAnalysis: json['detailedAnalysis'] as String?,
      careerAptitudes: (json['careerAptitudes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recommendedFields: (json['recommendedFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      achievementStyle: json['achievementStyle'] as String?,
      cautions: (json['cautions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      advice: json['advice'] as String?,
    );

Map<String, dynamic> _$$MiganAnalysisImplToJson(_$MiganAnalysisImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'fortuneMessage': instance.fortuneMessage,
      'score': instance.score,
      'summary': instance.summary,
      'detailedAnalysis': instance.detailedAnalysis,
      'careerAptitudes': instance.careerAptitudes,
      'recommendedFields': instance.recommendedFields,
      'achievementStyle': instance.achievementStyle,
      'cautions': instance.cautions,
      'advice': instance.advice,
    };

_$SimplifiedOgwanImpl _$$SimplifiedOgwanImplFromJson(
        Map<String, dynamic> json) =>
    _$SimplifiedOgwanImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => SimplifiedOgwanItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
      bestFeature: json['bestFeature'] as String,
      cautionFeature: json['cautionFeature'] as String?,
    );

Map<String, dynamic> _$$SimplifiedOgwanImplToJson(
        _$SimplifiedOgwanImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'summary': instance.summary,
      'bestFeature': instance.bestFeature,
      'cautionFeature': instance.cautionFeature,
    };

_$SimplifiedOgwanItemImpl _$$SimplifiedOgwanItemImplFromJson(
        Map<String, dynamic> json) =>
    _$SimplifiedOgwanItemImpl(
      featureName: json['featureName'] as String,
      featureId: json['featureId'] as String,
      fortuneCategory: json['fortuneCategory'] as String,
      summary: json['summary'] as String,
      score: (json['score'] as num).toInt(),
      detailedAnalysis: json['detailedAnalysis'] as String?,
      emoji: json['emoji'] as String? ?? '',
    );

Map<String, dynamic> _$$SimplifiedOgwanItemImplToJson(
        _$SimplifiedOgwanItemImpl instance) =>
    <String, dynamic>{
      'featureName': instance.featureName,
      'featureId': instance.featureId,
      'fortuneCategory': instance.fortuneCategory,
      'summary': instance.summary,
      'score': instance.score,
      'detailedAnalysis': instance.detailedAnalysis,
      'emoji': instance.emoji,
    };

_$SimplifiedSibigungImpl _$$SimplifiedSibigungImplFromJson(
        Map<String, dynamic> json) =>
    _$SimplifiedSibigungImpl(
      items: (json['items'] as List<dynamic>)
          .map(
              (e) => SimplifiedSibigungItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
      strongestPalace: json['strongestPalace'] as String,
      cautionPalace: json['cautionPalace'] as String?,
    );

Map<String, dynamic> _$$SimplifiedSibigungImplToJson(
        _$SimplifiedSibigungImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'summary': instance.summary,
      'strongestPalace': instance.strongestPalace,
      'cautionPalace': instance.cautionPalace,
    };

_$SimplifiedSibigungItemImpl _$$SimplifiedSibigungItemImplFromJson(
        Map<String, dynamic> json) =>
    _$SimplifiedSibigungItemImpl(
      palaceName: json['palaceName'] as String,
      palaceId: json['palaceId'] as String,
      relatedArea: json['relatedArea'] as String,
      summary: json['summary'] as String,
      score: (json['score'] as num).toInt(),
      detailedAnalysis: json['detailedAnalysis'] as String?,
      emoji: json['emoji'] as String? ?? '',
    );

Map<String, dynamic> _$$SimplifiedSibigungItemImplToJson(
        _$SimplifiedSibigungItemImpl instance) =>
    <String, dynamic>{
      'palaceName': instance.palaceName,
      'palaceId': instance.palaceId,
      'relatedArea': instance.relatedArea,
      'summary': instance.summary,
      'score': instance.score,
      'detailedAnalysis': instance.detailedAnalysis,
      'emoji': instance.emoji,
    };

_$MakeupStyleRecommendationsImpl _$$MakeupStyleRecommendationsImplFromJson(
        Map<String, dynamic> json) =>
    _$MakeupStyleRecommendationsImpl(
      mostAttractiveFeature: json['mostAttractiveFeature'] as String,
      enhancementTip: json['enhancementTip'] as String,
      recommendedStyles: (json['recommendedStyles'] as List<dynamic>)
          .map((e) => MakeupStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
      luckyColor: LuckyColorForMakeup.fromJson(
          json['luckyColor'] as Map<String, dynamic>),
      styleToAvoid: json['styleToAvoid'] as String?,
    );

Map<String, dynamic> _$$MakeupStyleRecommendationsImplToJson(
        _$MakeupStyleRecommendationsImpl instance) =>
    <String, dynamic>{
      'mostAttractiveFeature': instance.mostAttractiveFeature,
      'enhancementTip': instance.enhancementTip,
      'recommendedStyles': instance.recommendedStyles,
      'luckyColor': instance.luckyColor,
      'styleToAvoid': instance.styleToAvoid,
    };

_$MakeupStyleImpl _$$MakeupStyleImplFromJson(Map<String, dynamic> json) =>
    _$MakeupStyleImpl(
      styleName: json['styleName'] as String,
      description: json['description'] as String,
      suitableOccasion: json['suitableOccasion'] as String,
      emoji: json['emoji'] as String? ?? '💄',
    );

Map<String, dynamic> _$$MakeupStyleImplToJson(_$MakeupStyleImpl instance) =>
    <String, dynamic>{
      'styleName': instance.styleName,
      'description': instance.description,
      'suitableOccasion': instance.suitableOccasion,
      'emoji': instance.emoji,
    };

_$LuckyColorForMakeupImpl _$$LuckyColorForMakeupImplFromJson(
        Map<String, dynamic> json) =>
    _$LuckyColorForMakeupImpl(
      colorName: json['colorName'] as String,
      colorCode: json['colorCode'] as String,
      applicationArea: json['applicationArea'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$$LuckyColorForMakeupImplToJson(
        _$LuckyColorForMakeupImpl instance) =>
    <String, dynamic>{
      'colorName': instance.colorName,
      'colorCode': instance.colorCode,
      'applicationArea': instance.applicationArea,
      'reason': instance.reason,
    };

_$LuckyFeatureEnhancementImpl _$$LuckyFeatureEnhancementImplFromJson(
        Map<String, dynamic> json) =>
    _$LuckyFeatureEnhancementImpl(
      featureName: json['featureName'] as String,
      description: json['description'] as String,
      enhancementMethods: (json['enhancementMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      relatedFortune: json['relatedFortune'] as String,
    );

Map<String, dynamic> _$$LuckyFeatureEnhancementImplToJson(
        _$LuckyFeatureEnhancementImpl instance) =>
    <String, dynamic>{
      'featureName': instance.featureName,
      'description': instance.description,
      'enhancementMethods': instance.enhancementMethods,
      'relatedFortune': instance.relatedFortune,
    };

_$LeadershipAnalysisImpl _$$LeadershipAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$LeadershipAnalysisImpl(
      leadershipStyle: json['leadershipStyle'] as String,
      leadershipScore: (json['leadershipScore'] as num).toInt(),
      suitableCareers: (json['suitableCareers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      strength: json['strength'] as String,
      improvementPoint: json['improvementPoint'] as String?,
      businessFortune: json['businessFortune'] as String,
    );

Map<String, dynamic> _$$LeadershipAnalysisImplToJson(
        _$LeadershipAnalysisImpl instance) =>
    <String, dynamic>{
      'leadershipStyle': instance.leadershipStyle,
      'leadershipScore': instance.leadershipScore,
      'suitableCareers': instance.suitableCareers,
      'strength': instance.strength,
      'improvementPoint': instance.improvementPoint,
      'businessFortune': instance.businessFortune,
    };

_$WatchFaceReadingDataImpl _$$WatchFaceReadingDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WatchFaceReadingDataImpl(
      luckyDirection: json['luckyDirection'] as String,
      luckyColor:
          WatchLuckyColor.fromJson(json['luckyColor'] as Map<String, dynamic>),
      luckyTimePeriods: (json['luckyTimePeriods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dailyReminderMessage: json['dailyReminderMessage'] as String,
      briefFortune: json['briefFortune'] as String,
      conditionScore: (json['conditionScore'] as num).toInt(),
      smileScore: (json['smileScore'] as num).toInt(),
    );

Map<String, dynamic> _$$WatchFaceReadingDataImplToJson(
        _$WatchFaceReadingDataImpl instance) =>
    <String, dynamic>{
      'luckyDirection': instance.luckyDirection,
      'luckyColor': instance.luckyColor,
      'luckyTimePeriods': instance.luckyTimePeriods,
      'dailyReminderMessage': instance.dailyReminderMessage,
      'briefFortune': instance.briefFortune,
      'conditionScore': instance.conditionScore,
      'smileScore': instance.smileScore,
    };

_$WatchLuckyColorImpl _$$WatchLuckyColorImplFromJson(
        Map<String, dynamic> json) =>
    _$WatchLuckyColorImpl(
      colorName: json['colorName'] as String,
      colorCode: json['colorCode'] as String,
    );

Map<String, dynamic> _$$WatchLuckyColorImplToJson(
        _$WatchLuckyColorImpl instance) =>
    <String, dynamic>{
      'colorName': instance.colorName,
      'colorCode': instance.colorCode,
    };

_$ShareableContentImpl _$$ShareableContentImplFromJson(
        Map<String, dynamic> json) =>
    _$ShareableContentImpl(
      title: json['title'] as String,
      emotionalQuote: json['emotionalQuote'] as String,
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      shareImageUrl: json['shareImageUrl'] as String?,
      instagramData: json['instagramData'] == null
          ? null
          : InstagramShareData.fromJson(
              json['instagramData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ShareableContentImplToJson(
        _$ShareableContentImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'emotionalQuote': instance.emotionalQuote,
      'highlights': instance.highlights,
      'shareImageUrl': instance.shareImageUrl,
      'instagramData': instance.instagramData,
    };

_$InstagramShareDataImpl _$$InstagramShareDataImplFromJson(
        Map<String, dynamic> json) =>
    _$InstagramShareDataImpl(
      backgroundGradient: (json['backgroundGradient'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mainText: json['mainText'] as String,
      subText: json['subText'] as String,
      suggestedHashtags: (json['suggestedHashtags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$InstagramShareDataImplToJson(
        _$InstagramShareDataImpl instance) =>
    <String, dynamic>{
      'backgroundGradient': instance.backgroundGradient,
      'mainText': instance.mainText,
      'subText': instance.subText,
      'suggestedHashtags': instance.suggestedHashtags,
    };
