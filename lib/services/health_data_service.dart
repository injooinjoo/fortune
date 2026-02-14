import 'package:flutter/foundation.dart';

/// 건강 데이터 서비스
///
/// NOTE:
/// 외부 건강 플랫폼 연동은 App Review 대응을 위해 비활성화되었습니다.
/// API 호환성을 위해 서비스 인터페이스와 데이터 모델은 유지합니다.
/// 프리미엄 사용자 전용 기능
class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  bool _isAuthorized = false;

  /// 건강 데이터 권한 요청
  Future<bool> requestAuthorization() async {
    _isAuthorized = false;
    debugPrint(
        '[HealthDataService] Health integration is disabled for this build.');
    return false;
  }

  /// 권한 상태 확인
  bool get isAuthorized => _isAuthorized;

  /// 최근 7일간 건강 데이터 가져오기
  Future<HealthSummary?> getHealthSummary() async {
    return null;
  }
}

/// 건강 데이터 요약 모델
class HealthSummary {
  // 활동
  final int? averageDailySteps;
  final int? todaySteps;
  final int? averageDailyCalories;
  final int? todayCalories;
  final double? averageDailyDistanceKm;
  final int? workoutCountWeek;

  // 수면
  final double? averageSleepHours;
  final double? lastNightSleepHours;

  // 심박수
  final int? averageHeartRate;
  final int? restingHeartRate;

  // 신체 측정
  final double? weightKg;

  // 혈압
  final int? systolicBp;
  final int? diastolicBp;

  // 기타
  final double? bloodGlucose;
  final double? bloodOxygen;

  // 메타데이터
  final DateTime dataStartDate;
  final DateTime dataEndDate;

  HealthSummary({
    this.averageDailySteps,
    this.todaySteps,
    this.averageDailyCalories,
    this.todayCalories,
    this.averageDailyDistanceKm,
    this.workoutCountWeek,
    this.averageSleepHours,
    this.lastNightSleepHours,
    this.averageHeartRate,
    this.restingHeartRate,
    this.weightKg,
    this.systolicBp,
    this.diastolicBp,
    this.bloodGlucose,
    this.bloodOxygen,
    required this.dataStartDate,
    required this.dataEndDate,
  });

  /// API 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      // 활동
      'average_daily_steps': averageDailySteps,
      'today_steps': todaySteps,
      'average_daily_calories': averageDailyCalories,
      'today_calories': todayCalories,
      'average_daily_distance_km': averageDailyDistanceKm?.toStringAsFixed(2),
      'workout_count_week': workoutCountWeek,

      // 수면
      'average_sleep_hours': averageSleepHours?.toStringAsFixed(1),
      'last_night_sleep_hours': lastNightSleepHours?.toStringAsFixed(1),

      // 심박수
      'average_heart_rate': averageHeartRate,
      'resting_heart_rate': restingHeartRate,

      // 신체 측정
      'weight_kg': weightKg?.toStringAsFixed(1),

      // 혈압
      'systolic_bp': systolicBp,
      'diastolic_bp': diastolicBp,

      // 기타
      'blood_glucose': bloodGlucose?.toStringAsFixed(1),
      'blood_oxygen': bloodOxygen?.toStringAsFixed(1),

      // 메타데이터
      'data_period':
          '${dataStartDate.toString().split(' ')[0]} ~ ${dataEndDate.toString().split(' ')[0]}',
    };
  }

  /// 한국어 요약 텍스트 생성
  String toSummaryText() {
    final lines = <String>[];

    if (averageDailySteps != null) {
      lines.add(
          '일평균 걸음 수: ${averageDailySteps!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}보');
    }
    if (averageSleepHours != null) {
      lines.add('일평균 수면 시간: ${averageSleepHours!.toStringAsFixed(1)}시간');
    }
    if (averageHeartRate != null) {
      lines.add('평균 심박수: ${averageHeartRate}bpm');
    }
    if (restingHeartRate != null) {
      lines.add('안정시 심박수: ${restingHeartRate}bpm');
    }
    if (weightKg != null) {
      lines.add('체중: ${weightKg!.toStringAsFixed(1)}kg');
    }
    if (systolicBp != null && diastolicBp != null) {
      lines.add('혈압: $systolicBp/$diastolicBp mmHg');
    }
    if (bloodGlucose != null) {
      lines.add('혈당: ${bloodGlucose!.toStringAsFixed(0)} mg/dL');
    }
    if (bloodOxygen != null) {
      lines.add('산소포화도: ${bloodOxygen!.toStringAsFixed(1)}%');
    }
    if (workoutCountWeek != null && workoutCountWeek! > 0) {
      lines.add('주간 운동 횟수: $workoutCountWeek회');
    }

    return lines.isEmpty ? '수집된 건강 데이터가 없습니다' : lines.join('\n');
  }

  /// 건강 데이터가 있는지 확인
  bool get hasData {
    return averageDailySteps != null ||
        averageSleepHours != null ||
        averageHeartRate != null ||
        weightKg != null ||
        systolicBp != null ||
        bloodGlucose != null ||
        bloodOxygen != null;
  }
}
