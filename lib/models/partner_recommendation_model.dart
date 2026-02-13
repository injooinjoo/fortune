import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'partner_recommendation_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class PartnerRecommendationModel extends HiveObject {
  @HiveField(0)
  final List<String> best;

  @HiveField(1)
  final List<String> good;

  @HiveField(2)
  final List<String> avoid;

  PartnerRecommendationModel({
    required this.best,
    required this.good,
    required this.avoid,
  });

  factory PartnerRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerRecommendationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRecommendationModelToJson(this);
}

@HiveType(typeId: 5)
@JsonSerializable()
class PartnerRecommendationsModel extends HiveObject {
  @HiveField(0)
  final PartnerRecommendationModel byZodiacAnimal;

  @HiveField(1)
  final PartnerRecommendationModel byZodiacSign;

  @HiveField(2)
  final PartnerRecommendationModel byMBTI;

  PartnerRecommendationsModel({
    required this.byZodiacAnimal,
    required this.byZodiacSign,
    required this.byMBTI,
  });

  factory PartnerRecommendationsModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerRecommendationsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRecommendationsModelToJson(this);
}
