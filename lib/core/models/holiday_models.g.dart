// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HolidayInfoImpl _$$HolidayInfoImplFromJson(Map<String, dynamic> json) =>
    _$HolidayInfoImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      type: json['type'] as String,
      isLunar: json['isLunar'] as bool? ?? false,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$HolidayInfoImplToJson(_$HolidayInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'name': instance.name,
      'type': instance.type,
      'isLunar': instance.isLunar,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$AuspiciousDayInfoImpl _$$AuspiciousDayInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AuspiciousDayInfoImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      score: (json['score'] as num).toInt(),
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AuspiciousDayInfoImplToJson(
        _$AuspiciousDayInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'type': instance.type,
      'score': instance.score,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CalendarEventInfoImpl _$$CalendarEventInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarEventInfoImpl(
      date: DateTime.parse(json['date'] as String),
      holidayName: json['holidayName'] as String?,
      specialName: json['specialName'] as String?,
      auspiciousName: json['auspiciousName'] as String?,
      isHoliday: json['isHoliday'] as bool? ?? false,
      isSpecial: json['isSpecial'] as bool? ?? false,
      isAuspicious: json['isAuspicious'] as bool? ?? false,
      auspiciousScore: (json['auspiciousScore'] as num?)?.toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$CalendarEventInfoImplToJson(
        _$CalendarEventInfoImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'holidayName': instance.holidayName,
      'specialName': instance.specialName,
      'auspiciousName': instance.auspiciousName,
      'isHoliday': instance.isHoliday,
      'isSpecial': instance.isSpecial,
      'isAuspicious': instance.isAuspicious,
      'auspiciousScore': instance.auspiciousScore,
      'description': instance.description,
    };
