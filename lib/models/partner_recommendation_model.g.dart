// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerRecommendationModel _$PartnerRecommendationModelFromJson(
        Map<String, dynamic> json) =>
    PartnerRecommendationModel(
      best: (json['best'] as List<dynamic>).map((e) => e as String).toList(),
      good: (json['good'] as List<dynamic>).map((e) => e as String).toList(),
      avoid: (json['avoid'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PartnerRecommendationModelToJson(
        PartnerRecommendationModel instance) =>
    <String, dynamic>{
      'best': instance.best,
      'good': instance.good,
      'avoid': instance.avoid,
    };

PartnerRecommendationsModel _$PartnerRecommendationsModelFromJson(
        Map<String, dynamic> json) =>
    PartnerRecommendationsModel(
      byZodiacAnimal: PartnerRecommendationModel.fromJson(
          json['byZodiacAnimal'] as Map<String, dynamic>),
      byZodiacSign: PartnerRecommendationModel.fromJson(
          json['byZodiacSign'] as Map<String, dynamic>),
      byMBTI: PartnerRecommendationModel.fromJson(
          json['byMBTI'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PartnerRecommendationsModelToJson(
        PartnerRecommendationsModel instance) =>
    <String, dynamic>{
      'byZodiacAnimal': instance.byZodiacAnimal,
      'byZodiacSign': instance.byZodiacSign,
      'byMBTI': instance.byMBTI,
    };
