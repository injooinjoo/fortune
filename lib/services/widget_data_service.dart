import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/models/shared_widget_data.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 위젯용 통합 데이터 서비스
/// fortune-daily와 fortune-investment 데이터를 fetch하여 위젯용으로 변환/저장
class WidgetDataService {
  static const String _sharedDataKey = 'unified_fortune_widget_data';
  static const String _appGroupId = 'group.com.beyond.fortune';

  // 카테고리 매핑
  static const Map<String, String> _categoryNames = {
    'love': '연애운',
    'money': '금전운',
    'work': '직장운',
    'study': '학업운',
    'health': '건강운',
  };

  static const Map<String, String> _categoryIcons = {
    'love': '💕',
    'money': '💰',
    'work': '💼',
    'study': '📚',
    'health': '💪',
  };

  // 시간대 매핑
  static const Map<String, Map<String, String>> _timeSlotInfo = {
    'morning': {'name': '오전', 'range': '06:00-12:00', 'icon': '🌅'},
    'afternoon': {'name': '오후', 'range': '12:00-18:00', 'icon': '☀️'},
    'evening': {'name': '저녁', 'range': '18:00-24:00', 'icon': '🌙'},
  };

  /// 위젯 서비스 초기화
  static Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(_appGroupId);
      }
      Logger.info('[WidgetDataService] 초기화 완료');
    } catch (e) {
      Logger.warning('[WidgetDataService] 초기화 실패 (선택적 기능): $e');
    }
  }

  /// 위젯용 데이터 fetch 및 저장
  /// 백그라운드에서 호출되거나 앱 시작 시 호출
  static Future<SharedWidgetData?> fetchAndSaveForWidget({
    required String userId,
  }) async {
    try {
      Logger.info('[WidgetDataService] 위젯 데이터 fetch 시작');

      // 1. fortune-daily 데이터 가져오기
      final dailyFortune = await _fetchDailyFortune(userId);
      if (dailyFortune == null) {
        Logger.warning('[WidgetDataService] Daily fortune fetch 실패');
        return null;
      }

      // 2. fortune-investment 데이터 가져오기 (로또 번호)
      final lottoNumbers = await _fetchLottoNumbers(userId);

      // 3. SharedWidgetData로 변환
      final widgetData = _convertToWidgetData(dailyFortune, lottoNumbers);

      // 4. 저장
      await _saveWidgetData(widgetData);

      // 5. 모든 위젯 업데이트 알림
      await _notifyWidgets();

      Logger.info('[WidgetDataService] 위젯 데이터 저장 완료');
      return widgetData;
    } catch (e, stackTrace) {
      Logger.error('[WidgetDataService] 위젯 데이터 fetch 실패', e, stackTrace);
      return null;
    }
  }

  /// Daily Fortune API 호출
  static Future<Fortune?> _fetchDailyFortune(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      // 사용자 프로필 조회
      final userProfile = await supabase
          .from('user_profiles')
          .select(
              'name, birth_date, birth_time, gender, zodiac_sign, chinese_zodiac')
          .eq('id', userId)
          .maybeSingle();

      if (userProfile == null) {
        Logger.warning('[WidgetDataService] 사용자 프로필 없음');
        return null;
      }

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-daily',
        body: {
          'userId': userId,
          'birthDate': userProfile['birth_date'],
          'birthTime': userProfile['birth_time'],
          'gender': userProfile['gender'],
          'zodiacSign': userProfile['zodiac_sign'],
          'zodiacAnimal': userProfile['chinese_zodiac'],
        },
      );

      if (response.status != 200) {
        Logger.warning('[WidgetDataService] fortune-daily 호출 실패: ${response.status}');
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      return _parseFortuneFromResponse(data);
    } catch (e) {
      Logger.error('[WidgetDataService] _fetchDailyFortune 오류: $e');
      return null;
    }
  }

  /// Fortune 응답 파싱
  static Fortune _parseFortuneFromResponse(Map<String, dynamic> data) {
    // fortune 키가 있으면 그 안의 데이터 사용
    final fortuneData = data['fortune'] as Map<String, dynamic>? ?? data;

    return Fortune(
      id: fortuneData['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: fortuneData['userId'] as String? ?? '',
      type: 'daily',
      content: fortuneData['content'] as String? ?? '',
      createdAt: DateTime.now(),
      overallScore: fortuneData['overallScore'] as int? ?? 80,
      overall: fortuneData['overall'] as Map<String, dynamic>?,
      categories: fortuneData['categories'] as Map<String, dynamic>?,
      timeSpecificFortunes: _parseTimeSlots(fortuneData['timeSlots']),
      luckyItems: fortuneData['luckyItems'] as Map<String, dynamic>?,
    );
  }

  /// 시간대 데이터 파싱
  static List<TimeSpecificFortune>? _parseTimeSlots(dynamic timeSlots) {
    if (timeSlots == null) return null;
    if (timeSlots is! List) return null;

    return timeSlots.map((slot) {
      final s = slot as Map<String, dynamic>;
      return TimeSpecificFortune(
        time: s['time'] as String? ?? '',
        title: s['title'] as String? ?? '',
        score: s['score'] as int? ?? 80,
        description: s['description'] as String? ?? '',
        recommendation: s['recommendation'] as String?,
      );
    }).toList();
  }

  /// 로또 번호 가져오기
  static Future<List<int>> _fetchLottoNumbers(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.functions.invoke(
        'fortune-investment',
        body: {'userId': userId},
      );

      if (response.status != 200) {
        Logger.warning('[WidgetDataService] fortune-investment 호출 실패');
        return _generateDefaultLottoNumbers();
      }

      final data = response.data as Map<String, dynamic>;
      final luckyNumbers = data['luckyNumbers'] as List<dynamic>?;

      if (luckyNumbers != null && luckyNumbers.isNotEmpty) {
        return luckyNumbers.take(5).map((n) => n as int).toList();
      }

      // additionalInfo에서 로또 번호 찾기
      final additionalInfo = data['additionalInfo'] as Map<String, dynamic>?;
      final numbers = additionalInfo?['lottoNumbers'] as List<dynamic>?;

      if (numbers != null && numbers.isNotEmpty) {
        return numbers.take(5).map((n) => n as int).toList();
      }

      return _generateDefaultLottoNumbers();
    } catch (e) {
      Logger.error('[WidgetDataService] _fetchLottoNumbers 오류: $e');
      return _generateDefaultLottoNumbers();
    }
  }

  /// 기본 로또 번호 생성 (fallback)
  static List<int> _generateDefaultLottoNumbers() {
    final now = DateTime.now();
    // 날짜 기반으로 일관된 번호 생성
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final numbers = <int>[];
    for (var i = 0; i < 5; i++) {
      numbers.add(((seed * (i + 1) * 7) % 45) + 1);
    }
    return numbers.toSet().toList()..sort();
  }

  /// Fortune을 SharedWidgetData로 변환
  static SharedWidgetData _convertToWidgetData(
    Fortune fortune,
    List<int> lottoNumbers,
  ) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Overall 데이터 추출
    final overallData = fortune.overall ?? {};
    final overall = WidgetOverallData(
      score: fortune.overallScore ?? (overallData['score'] as int?) ?? 80,
      grade: _getGradeFromScore(fortune.overallScore ?? 80),
      message: overallData['summary'] as String? ?? fortune.content,
      description: overallData['description'] as String?,
    );

    // Categories 데이터 추출
    final categoriesData = fortune.categories ?? {};
    final categories = <String, WidgetCategoryData>{};

    for (final key in ['love', 'money', 'work', 'study', 'health']) {
      final catData = categoriesData[key] as Map<String, dynamic>? ?? {};
      categories[key] = WidgetCategoryData(
        key: key,
        name: _categoryNames[key] ?? key,
        score: catData['score'] as int? ?? 80,
        message: catData['message'] as String? ?? catData['summary'] as String? ?? '',
        icon: _categoryIcons[key] ?? '✨',
      );
    }

    // TimeSlots 데이터 추출
    final timeSlots = <WidgetTimeSlotData>[];
    final timeSpecificFortunes = fortune.timeSpecificFortunes;

    if (timeSpecificFortunes != null && timeSpecificFortunes.isNotEmpty) {
      for (final slot in timeSpecificFortunes) {
        final key = _getTimeSlotKey(slot.time);
        final info = _timeSlotInfo[key] ?? _timeSlotInfo['morning']!;
        timeSlots.add(WidgetTimeSlotData(
          key: key,
          name: info['name']!,
          timeRange: info['range']!,
          score: slot.score,
          message: slot.description,
          icon: info['icon']!,
        ));
      }
    } else {
      // 기본 시간대 데이터 생성
      for (final entry in _timeSlotInfo.entries) {
        timeSlots.add(WidgetTimeSlotData(
          key: entry.key,
          name: entry.value['name']!,
          timeRange: entry.value['range']!,
          score: fortune.overallScore ?? 80,
          message: '오늘의 ${entry.value['name']} 운세',
          icon: entry.value['icon']!,
        ));
      }
    }

    return SharedWidgetData(
      overall: overall,
      categories: categories,
      timeSlots: timeSlots,
      lottoNumbers: lottoNumbers,
      updatedAt: now,
      validDate: todayStr,
    );
  }

  /// 점수로 등급 계산
  static String _getGradeFromScore(int score) {
    if (score >= 90) return '대길';
    if (score >= 75) return '길';
    if (score >= 50) return '평';
    if (score >= 25) return '흉';
    return '대흉';
  }

  /// 시간 문자열에서 시간대 키 추출
  static String _getTimeSlotKey(String time) {
    // "06:00-12:00" 또는 "오전" 같은 형식 처리
    if (time.contains('오전') || time.contains('morning') || time.contains('06')) {
      return 'morning';
    }
    if (time.contains('오후') || time.contains('afternoon') || time.contains('12')) {
      return 'afternoon';
    }
    return 'evening';
  }

  /// 위젯 데이터 저장
  static Future<void> _saveWidgetData(SharedWidgetData data) async {
    try {
      final jsonStr = jsonEncode(data.toWidgetJson());
      await HomeWidget.saveWidgetData<String>(_sharedDataKey, jsonStr);

      // 개별 위젯용 데이터도 저장 (네이티브에서 직접 접근 가능하도록)

      // 총운 위젯용
      await HomeWidget.saveWidgetData<int>('overall_score', data.overall.score);
      await HomeWidget.saveWidgetData<String>('overall_grade', data.overall.grade);
      await HomeWidget.saveWidgetData<String>('overall_message', data.overall.message);

      // 시간대 위젯용 (현재 시간대)
      final currentSlot = data.currentTimeSlot;
      if (currentSlot != null) {
        await HomeWidget.saveWidgetData<String>('timeslot_name', currentSlot.name);
        await HomeWidget.saveWidgetData<int>('timeslot_score', currentSlot.score);
        await HomeWidget.saveWidgetData<String>('timeslot_message', currentSlot.message);
        await HomeWidget.saveWidgetData<String>('timeslot_icon', currentSlot.icon);
      }

      // 로또 위젯용
      await HomeWidget.saveWidgetData<String>(
        'lotto_numbers',
        data.lottoNumbers.join(', '),
      );

      // 카테고리 위젯용 (모든 카테고리 저장)
      for (final entry in data.categories.entries) {
        await HomeWidget.saveWidgetData<int>('cat_${entry.key}_score', entry.value.score);
        await HomeWidget.saveWidgetData<String>('cat_${entry.key}_message', entry.value.message);
      }

      // 메타데이터
      await HomeWidget.saveWidgetData<String>('valid_date', data.validDate);
      await HomeWidget.saveWidgetData<String>(
        'last_updated',
        '${data.updatedAt.hour}:${data.updatedAt.minute.toString().padLeft(2, '0')}',
      );

      Logger.info('[WidgetDataService] 위젯 데이터 저장 완료');
    } catch (e) {
      Logger.error('[WidgetDataService] 위젯 데이터 저장 실패: $e');
    }
  }

  /// 모든 위젯에 업데이트 알림
  static Future<void> _notifyWidgets() async {
    try {
      // 네이티브 위젯 업데이트
      await NativePlatformService.updateWidget(
        widgetType: 'all',
        data: {'action': 'refresh'},
      );

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS 위젯들 업데이트
        await HomeWidget.updateWidget(iOSName: 'FortuneOverallWidget');
        await HomeWidget.updateWidget(iOSName: 'FortuneCategoryWidget');
        await HomeWidget.updateWidget(iOSName: 'FortuneTimeSlotWidget');
        await HomeWidget.updateWidget(iOSName: 'FortuneLottoWidget');
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android 위젯들 업데이트
        await HomeWidget.updateWidget(androidName: 'OverallAppWidget');
        await HomeWidget.updateWidget(androidName: 'CategoryAppWidget');
        await HomeWidget.updateWidget(androidName: 'TimeSlotAppWidget');
        await HomeWidget.updateWidget(androidName: 'LottoAppWidget');
      }

      Logger.info('[WidgetDataService] 위젯 업데이트 알림 완료');
    } catch (e) {
      Logger.warning('[WidgetDataService] 위젯 업데이트 알림 실패: $e');
    }
  }

  /// 저장된 위젯 데이터 로드
  static Future<SharedWidgetData?> loadWidgetData() async {
    try {
      final jsonStr = await HomeWidget.getWidgetData<String>(_sharedDataKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SharedWidgetDataX.fromWidgetJson(json);
    } catch (e) {
      Logger.error('[WidgetDataService] 위젯 데이터 로드 실패: $e');
      return null;
    }
  }

  /// 오늘 데이터가 유효한지 확인
  static Future<bool> isDataValidForToday() async {
    try {
      final validDate = await HomeWidget.getWidgetData<String>('valid_date');
      if (validDate == null) return false;

      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return validDate == todayStr;
    } catch (e) {
      return false;
    }
  }

  /// 위젯 활성화 여부 확인 (iOS/Android)
  static Future<bool> isWidgetActive() async {
    try {
      // 실제로는 네이티브 코드에서 위젯 활성화 여부를 확인해야 함
      // 현재는 항상 true 반환 (추후 네이티브 연동 필요)
      return true;
    } catch (e) {
      return false;
    }
  }
}
