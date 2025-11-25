import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday_models.freezed.dart';
part 'holiday_models.g.dart';

@freezed
class HolidayInfo with _$HolidayInfo {
  const factory HolidayInfo({
    required String id,
    required DateTime date,
    required String name,
    required String type, // 'holiday', 'special', 'memorial'
    @Default(false) bool isLunar,
    String? description,
    DateTime? createdAt,
  }) = _HolidayInfo;

  factory HolidayInfo.fromJson(Map<String, dynamic> json) => _$HolidayInfoFromJson(json);
}

@freezed
class AuspiciousDayInfo with _$AuspiciousDayInfo {
  const factory AuspiciousDayInfo({
    required String id,
    required DateTime date,
    required String type, // 'moving', 'wedding', 'opening', 'travel'
    required int score, // 0-100
    String? description,
    DateTime? createdAt,
  }) = _AuspiciousDayInfo;

  factory AuspiciousDayInfo.fromJson(Map<String, dynamic> json) => _$AuspiciousDayInfoFromJson(json);
}

@freezed
class CalendarEventInfo with _$CalendarEventInfo {
  const factory CalendarEventInfo({
    required DateTime date,
    String? holidayName,
    String? specialName,
    String? auspiciousName,
    @Default(false) bool isHoliday,
    @Default(false) bool isSpecial,
    @Default(false) bool isAuspicious,
    int? auspiciousScore,
    String? description,
    // 디바이스 캘린더 연동 필드
    @Default(false) bool hasDeviceEvents,
    @Default(0) int deviceEventCount,
  }) = _CalendarEventInfo;

  factory CalendarEventInfo.fromJson(Map<String, dynamic> json) => _$CalendarEventInfoFromJson(json);
}