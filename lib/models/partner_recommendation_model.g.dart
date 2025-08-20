// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_recommendation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartnerRecommendationModelAdapter
    extends TypeAdapter<PartnerRecommendationModel> {
  @override
  final int typeId = 4;

  @override
  PartnerRecommendationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartnerRecommendationModel(
      best: (fields[0] as List).cast<String>(),
      good: (fields[1] as List).cast<String>(),
      avoid: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PartnerRecommendationModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.best)
      ..writeByte(1)
      ..write(obj.good)
      ..writeByte(2)
      ..write(obj.avoid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerRecommendationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartnerRecommendationsModelAdapter
    extends TypeAdapter<PartnerRecommendationsModel> {
  @override
  final int typeId = 5;

  @override
  PartnerRecommendationsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartnerRecommendationsModel(
      byZodiacAnimal: fields[0] as PartnerRecommendationModel,
      byZodiacSign: fields[1] as PartnerRecommendationModel,
      byMBTI: fields[2] as PartnerRecommendationModel,
    );
  }

  @override
  void write(BinaryWriter writer, PartnerRecommendationsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.byZodiacAnimal)
      ..writeByte(1)
      ..write(obj.byZodiacSign)
      ..writeByte(2)
      ..write(obj.byMBTI);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerRecommendationsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
