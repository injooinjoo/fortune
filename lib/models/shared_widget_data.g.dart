// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_widget_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedWidgetDataImpl _$$SharedWidgetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SharedWidgetDataImpl(
      overall:
          WidgetOverallData.fromJson(json['overall'] as Map<String, dynamic>),
      categories: (json['categories'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, WidgetCategoryData.fromJson(e as Map<String, dynamic>)),
      ),
      timeSlots: (json['timeSlots'] as List<dynamic>)
          .map((e) => WidgetTimeSlotData.fromJson(e as Map<String, dynamic>))
          .toList(),
      lottoNumbers: (json['lottoNumbers'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      validDate: json['validDate'] as String,
    );

Map<String, dynamic> _$$SharedWidgetDataImplToJson(
        _$SharedWidgetDataImpl instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'categories': instance.categories,
      'timeSlots': instance.timeSlots,
      'lottoNumbers': instance.lottoNumbers,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'validDate': instance.validDate,
    };

_$WidgetOverallDataImpl _$$WidgetOverallDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WidgetOverallDataImpl(
      score: (json['score'] as num).toInt(),
      grade: json['grade'] as String,
      message: json['message'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$WidgetOverallDataImplToJson(
        _$WidgetOverallDataImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'grade': instance.grade,
      'message': instance.message,
      'description': instance.description,
    };

_$WidgetCategoryDataImpl _$$WidgetCategoryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WidgetCategoryDataImpl(
      key: json['key'] as String,
      name: json['name'] as String,
      score: (json['score'] as num).toInt(),
      message: json['message'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$$WidgetCategoryDataImplToJson(
        _$WidgetCategoryDataImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'score': instance.score,
      'message': instance.message,
      'icon': instance.icon,
    };

_$WidgetTimeSlotDataImpl _$$WidgetTimeSlotDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WidgetTimeSlotDataImpl(
      key: json['key'] as String,
      name: json['name'] as String,
      timeRange: json['timeRange'] as String,
      score: (json['score'] as num).toInt(),
      message: json['message'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$$WidgetTimeSlotDataImplToJson(
        _$WidgetTimeSlotDataImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'timeRange': instance.timeRange,
      'score': instance.score,
      'message': instance.message,
      'icon': instance.icon,
    };
