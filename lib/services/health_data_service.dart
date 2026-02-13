import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// 건강 데이터 서비스 (Apple Health / Google Fit 연동)
/// 프리미엄 사용자 전용 기능
class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  final Health _health = Health();
  bool _isAuthorized = false;

  /// 요청할 건강 데이터 유형 목록
  static final List<HealthDataType> _healthTypes = [
    // 활동 데이터
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.WORKOUT,

    // 수면 데이터
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,

    // 신체 측정
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_FAT_PERCENTAGE,

    // 심박수
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,

    // 혈압 (iOS만)
    if (Platform.isIOS) ...[
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ],

    // 혈당
    HealthDataType.BLOOD_GLUCOSE,

    // 산소포화도
    HealthDataType.BLOOD_OXYGEN,

    // 수분 섭취
    HealthDataType.WATER,
  ];

  /// 건강 데이터 권한 요청
  Future<bool> requestAuthorization() async {
    try {
      // Health 패키지 설정
      await _health.configure();

      // 권한 요청
      final hasPermissions = await _health.hasPermissions(
        _healthTypes,
        permissions: _healthTypes.map((_) => HealthDataAccess.READ).toList(),
      );

      if (hasPermissions == true) {
        _isAuthorized = true;
        return true;
      }

      final authorized = await _health.requestAuthorization(
        _healthTypes,
        permissions: _healthTypes.map((_) => HealthDataAccess.READ).toList(),
      );

      _isAuthorized = authorized;
      return authorized;
    } catch (e) {
      debugPrint('Health authorization error: $e');
      return false;
    }
  }

  /// 권한 상태 확인
  bool get isAuthorized => _isAuthorized;

  /// 최근 7일간 건강 데이터 가져오기
  Future<HealthSummary?> getHealthSummary() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return null;
    }

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final yesterday = now.subtract(const Duration(days: 1));

      // 건강 데이터 가져오기
      final healthData = await _health.getHealthDataFromTypes(
        types: _healthTypes,
        startTime: weekAgo,
        endTime: now,
      );

      // 데이터 요약
      return _summarizeHealthData(healthData, weekAgo, now, yesterday);
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      return null;
    }
  }

  /// 건강 데이터 요약 생성
  HealthSummary _summarizeHealthData(
    List<HealthDataPoint> data,
    DateTime weekAgo,
    DateTime now,
    DateTime yesterday,
  ) {
    // 걸음 수
    final stepsData =
        data.where((d) => d.type == HealthDataType.STEPS).toList();
    final avgSteps = _calculateAverageDailyValue(stepsData, 7);
    final todaySteps = _getTodayValue(stepsData);

    // 수면 시간
    final sleepData = data
        .where((d) =>
            d.type == HealthDataType.SLEEP_ASLEEP ||
            d.type == HealthDataType.SLEEP_IN_BED)
        .toList();
    final avgSleep = _calculateAverageSleepHours(sleepData, 7);
    final lastNightSleep = _getLastNightSleep(sleepData);

    // 심박수
    final heartRateData =
        data.where((d) => d.type == HealthDataType.HEART_RATE).toList();
    final avgHeartRate = _calculateAverageValue(heartRateData);
    final restingHeartRateData =
        data.where((d) => d.type == HealthDataType.RESTING_HEART_RATE).toList();
    final restingHeartRate = _getLatestValue(restingHeartRateData);

    // 활동 칼로리
    final caloriesData = data
        .where((d) => d.type == HealthDataType.ACTIVE_ENERGY_BURNED)
        .toList();
    final avgCalories = _calculateAverageDailyValue(caloriesData, 7);
    final todayCalories = _getTodayValue(caloriesData);

    // 걸은 거리
    final distanceData = data
        .where((d) => d.type == HealthDataType.DISTANCE_WALKING_RUNNING)
        .toList();
    final avgDistance = _calculateAverageDailyValue(distanceData, 7);

    // 체중
    final weightData =
        data.where((d) => d.type == HealthDataType.WEIGHT).toList();
    final latestWeight = _getLatestValue(weightData);

    // 혈압
    final systolicData = data
        .where((d) => d.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC)
        .toList();
    final diastolicData = data
        .where((d) => d.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC)
        .toList();
    final latestSystolic = _getLatestValue(systolicData);
    final latestDiastolic = _getLatestValue(diastolicData);

    // 혈당
    final glucoseData =
        data.where((d) => d.type == HealthDataType.BLOOD_GLUCOSE).toList();
    final latestGlucose = _getLatestValue(glucoseData);

    // 산소포화도
    final oxygenData =
        data.where((d) => d.type == HealthDataType.BLOOD_OXYGEN).toList();
    final latestOxygen = _getLatestValue(oxygenData);

    // 운동 횟수
    final workoutData =
        data.where((d) => d.type == HealthDataType.WORKOUT).toList();
    final workoutCount = workoutData.length;

    return HealthSummary(
      // 활동
      averageDailySteps: avgSteps?.round(),
      todaySteps: todaySteps?.round(),
      averageDailyCalories: avgCalories?.round(),
      todayCalories: todayCalories?.round(),
      averageDailyDistanceKm: avgDistance != null ? avgDistance / 1000 : null,
      workoutCountWeek: workoutCount,

      // 수면
      averageSleepHours: avgSleep,
      lastNightSleepHours: lastNightSleep,

      // 심박수
      averageHeartRate: avgHeartRate?.round(),
      restingHeartRate: restingHeartRate?.round(),

      // 신체 측정
      weightKg: latestWeight,

      // 혈압
      systolicBp: latestSystolic?.round(),
      diastolicBp: latestDiastolic?.round(),

      // 기타
      bloodGlucose: latestGlucose,
      bloodOxygen: latestOxygen,

      // 메타데이터
      dataStartDate: weekAgo,
      dataEndDate: now,
    );
  }

  /// 일일 평균값 계산
  double? _calculateAverageDailyValue(List<HealthDataPoint> data, int days) {
    if (data.isEmpty) return null;

    // 날짜별로 그룹화
    final dailyTotals = <DateTime, double>{};
    for (final point in data) {
      final date = DateTime(
          point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
      final value = _extractNumericValue(point);
      if (value != null) {
        dailyTotals[date] = (dailyTotals[date] ?? 0) + value;
      }
    }

    if (dailyTotals.isEmpty) return null;

    final total = dailyTotals.values.reduce((a, b) => a + b);
    return total / dailyTotals.length;
  }

  /// 오늘 값 계산
  double? _getTodayValue(List<HealthDataPoint> data) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todayData =
        data.where((d) => d.dateFrom.isAfter(todayStart)).toList();
    if (todayData.isEmpty) return null;

    final values =
        todayData.map(_extractNumericValue).whereType<double>().toList();

    if (values.isEmpty) return null;

    return values.fold<double>(0.0, (a, b) => a + b);
  }

  /// 평균 수면 시간 계산 (시간 단위)
  double? _calculateAverageSleepHours(List<HealthDataPoint> data, int days) {
    if (data.isEmpty) return null;

    // 날짜별로 그룹화
    final dailySleep = <DateTime, double>{};
    for (final point in data) {
      final date = DateTime(
          point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
      final minutes = point.dateTo.difference(point.dateFrom).inMinutes;
      dailySleep[date] = (dailySleep[date] ?? 0) + minutes;
    }

    if (dailySleep.isEmpty) return null;

    final totalMinutes = dailySleep.values.reduce((a, b) => a + b);
    return (totalMinutes / dailySleep.length) / 60;
  }

  /// 어젯밤 수면 시간
  double? _getLastNightSleep(List<HealthDataPoint> data) {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final todayStart = DateTime(today.year, today.month, today.day);

    final lastNightData = data
        .where((d) =>
            d.dateFrom.isAfter(yesterday) &&
            d.dateTo.isBefore(todayStart.add(const Duration(hours: 12))))
        .toList();

    if (lastNightData.isEmpty) return null;

    final totalMinutes = lastNightData.fold(
        0,
        (sum, point) =>
            sum + point.dateTo.difference(point.dateFrom).inMinutes);

    return totalMinutes / 60;
  }

  /// 평균값 계산
  double? _calculateAverageValue(List<HealthDataPoint> data) {
    if (data.isEmpty) return null;

    final values = data.map(_extractNumericValue).whereType<double>().toList();
    if (values.isEmpty) return null;

    return values.reduce((a, b) => a + b) / values.length;
  }

  /// 최신 값 가져오기
  double? _getLatestValue(List<HealthDataPoint> data) {
    if (data.isEmpty) return null;

    data.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
    return _extractNumericValue(data.first);
  }

  /// 숫자값 추출
  double? _extractNumericValue(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
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
