import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/models/shared_widget_data.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // 5. 바이오리듬 데이터 fetch 및 저장 (Watch용)
      await _fetchAndSaveBiorhythm(userId);

      // 6. 행운 아이템 저장 (Watch용)
      await _saveLuckyItems(dailyFortune.luckyItems);

      // 7. 모든 위젯 업데이트 알림
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

  /// 로또 번호 생성
  /// NOTE: fortune-investment는 특정 ticker(주식) 분석용이므로 로또 번호 생성에 적합하지 않음
  /// 날짜 기반 행운 번호 생성기 사용
  static Future<List<int>> _fetchLottoNumbers(String userId) async {
    // 날짜 기반으로 일관된 행운 번호 생성
    return _generateDefaultLottoNumbers();
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

  /// 바이오리듬 데이터 fetch 및 저장 (Watch용)
  static Future<void> _fetchAndSaveBiorhythm(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      // 사용자 프로필에서 생년월일 조회
      final userProfile = await supabase
          .from('user_profiles')
          .select('name, birth_date')
          .eq('id', userId)
          .maybeSingle();

      if (userProfile == null || userProfile['birth_date'] == null) {
        Logger.warning('[WidgetDataService] 바이오리듬용 프로필 없음');
        return;
      }

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-biorhythm',
        body: {
          'birthDate': userProfile['birth_date'],
          'name': userProfile['name'] ?? '사용자',
          'isPremium': false, // 위젯용이므로 기본값
        },
      );

      if (response.status != 200) {
        Logger.warning('[WidgetDataService] fortune-biorhythm 호출 실패: ${response.status}');
        return;
      }

      final data = response.data as Map<String, dynamic>;
      final bioData = data['data'] as Map<String, dynamic>?;

      if (bioData == null) {
        Logger.warning('[WidgetDataService] 바이오리듬 데이터 없음');
        return;
      }

      // 바이오리듬 데이터 저장 (Watch에서 접근)
      final physical = bioData['physical'] as Map<String, dynamic>?;
      final emotional = bioData['emotional'] as Map<String, dynamic>?;
      final intellectual = bioData['intellectual'] as Map<String, dynamic>?;

      await HomeWidget.saveWidgetData<int>(
        'bio_physical_score',
        physical?['score'] as int? ?? 50,
      );
      await HomeWidget.saveWidgetData<int>(
        'bio_emotional_score',
        emotional?['score'] as int? ?? 50,
      );
      await HomeWidget.saveWidgetData<int>(
        'bio_intellectual_score',
        intellectual?['score'] as int? ?? 50,
      );
      await HomeWidget.saveWidgetData<String>(
        'bio_physical_status',
        physical?['status'] as String? ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'bio_emotional_status',
        emotional?['status'] as String? ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'bio_intellectual_status',
        intellectual?['status'] as String? ?? '',
      );
      await HomeWidget.saveWidgetData<int>(
        'bio_overall_score',
        bioData['overall_score'] as int? ?? 50,
      );
      await HomeWidget.saveWidgetData<String>(
        'bio_status_message',
        bioData['status_message'] as String? ?? '',
      );

      Logger.info('[WidgetDataService] 바이오리듬 데이터 저장 완료');
    } catch (e) {
      Logger.warning('[WidgetDataService] 바이오리듬 저장 실패 (선택적 기능): $e');
    }
  }

  /// 행운 아이템 저장 (Watch용)
  static Future<void> _saveLuckyItems(Map<String, dynamic>? luckyItems) async {
    try {
      if (luckyItems == null) {
        Logger.info('[WidgetDataService] 행운 아이템 데이터 없음');
        return;
      }

      // 행운의 색
      final color = luckyItems['color'] as String?;
      if (color != null) {
        await HomeWidget.saveWidgetData<String>('lucky_color', color);
      }

      // 행운의 숫자
      final number = luckyItems['number'];
      if (number != null) {
        await HomeWidget.saveWidgetData<String>(
          'lucky_number',
          number.toString(),
        );
      }

      // 행운의 방향
      final direction = luckyItems['direction'] as String?;
      if (direction != null) {
        await HomeWidget.saveWidgetData<String>('lucky_direction', direction);
      }

      // 행운의 시간
      final time = luckyItems['time'] as String?;
      if (time != null) {
        await HomeWidget.saveWidgetData<String>('lucky_time', time);
      }

      // 행운의 아이템
      final item = luckyItems['item'] as String?;
      if (item != null) {
        await HomeWidget.saveWidgetData<String>('lucky_item', item);
      }

      Logger.info('[WidgetDataService] 행운 아이템 저장 완료');
    } catch (e) {
      Logger.warning('[WidgetDataService] 행운 아이템 저장 실패: $e');
    }
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

  /// 위젯 설치 여부 확인
  /// Android: MethodChannel로 AppWidgetManager 조회
  /// iOS: 감지 불가 → 항상 true 반환
  static Future<bool> isWidgetInstalled() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final result =
            await const MethodChannel('com.beyond.fortune/widget_refresh')
                .invokeMethod<Map<dynamic, dynamic>>('isWidgetInstalled');
        return result?['installed'] == true;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS WidgetKit은 위젯 설치 감지 API 없음 → 항상 true
        return true;
      }
      return false;
    } catch (e) {
      Logger.warning('[WidgetDataService] 위젯 감지 실패: $e');
      // 실패 시 보수적으로 true 반환 (데이터 준비)
      return true;
    }
  }

  /// 하위 호환성을 위한 별칭
  @Deprecated('Use isWidgetInstalled() instead')
  static Future<bool> isWidgetActive() => isWidgetInstalled();

  // ============================================================
  // Engagement 관련 메서드 (듀오링고 스타일 앱 진입 유도)
  // ============================================================

  /// 랜덤 engagement 메시지 반환 (총운용)
  static String getEngagementMessage() {
    final messages = [
      '오늘의 운세 미리보기 🔮',
      '터치해서 오늘 운세 확인',
      '오늘은 어떤 하루가 될까요? ✨',
      '새로운 하루, 새로운 운세 🌅',
      '행운이 기다리고 있어요 🍀',
    ];
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  /// 카테고리별 engagement 메시지 반환
  static String getCategoryEngagementMessage(String categoryKey) {
    final messages = {
      'love': [
        '오늘의 연애운 확인 💕',
        '사랑의 기운이 감돌아요 💗',
        '설레는 하루가 될까요? 💘',
      ],
      'money': [
        '오늘의 금전운 확인 💰',
        '재물 운이 궁금하신가요? 💵',
        '행운의 숫자를 확인하세요 🍀',
      ],
      'work': [
        '오늘의 직장운 확인 💼',
        '성공적인 하루가 될까요? 📈',
        '업무 운을 확인해보세요 ⭐',
      ],
      'study': [
        '오늘의 학업운 확인 📚',
        '집중력이 좋은 하루일까요? 🎯',
        '시험 운을 확인해보세요 ✏️',
      ],
      'health': [
        '오늘의 건강운 확인 💪',
        '활력 넘치는 하루가 될까요? 🏃',
        '컨디션을 확인해보세요 ❤️',
      ],
    };

    final categoryMessages = messages[categoryKey] ?? messages['love']!;
    final random = Random();
    return categoryMessages[random.nextInt(categoryMessages.length)];
  }

  /// Supabase 캐시에서 위젯 데이터 조회 (백그라운드용)
  static Future<WidgetCacheResult?> fetchFromSupabaseCache(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.functions.invoke(
        'widget-cache',
        body: {'userId': userId},
      );

      if (response.status != 200) {
        Logger.warning('[WidgetDataService] widget-cache 호출 실패: ${response.status}');
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      return WidgetCacheResult.fromJson(data);
    } catch (e) {
      Logger.error('[WidgetDataService] fetchFromSupabaseCache 실패: $e');
      return null;
    }
  }

  /// Engagement 상태와 함께 위젯 데이터 저장
  static Future<void> saveWidgetDataWithEngagement({
    SharedWidgetData? todayData,
    SharedWidgetData? yesterdayData,
  }) async {
    try {
      SharedWidgetData dataToSave;

      if (todayData != null) {
        // 오늘 데이터 있음 - 정상 표시
        dataToSave = todayData.copyWith(
          displayState: WidgetDisplayState.today,
          engagementMessage: null,
        );
      } else if (yesterdayData != null) {
        // 어제 데이터만 있음 - engagement 유도
        dataToSave = yesterdayData.copyWith(
          displayState: WidgetDisplayState.yesterday,
          engagementMessage: getEngagementMessage(),
        );
      } else {
        // 데이터 없음 - 신규 사용자
        dataToSave = _createEmptyWidgetData();
      }

      await _saveWidgetData(dataToSave);
      await _saveEngagementState(dataToSave.displayState, dataToSave.engagementMessage);
      await _notifyWidgets();

      Logger.info('[WidgetDataService] saveWidgetDataWithEngagement 완료: ${dataToSave.displayState}');
    } catch (e) {
      Logger.error('[WidgetDataService] saveWidgetDataWithEngagement 실패: $e');
    }
  }

  /// Engagement 상태 저장 (네이티브 위젯에서 직접 접근)
  static Future<void> _saveEngagementState(
    WidgetDisplayState state,
    String? engagementMessage,
  ) async {
    await HomeWidget.saveWidgetData<String>('display_state', state.name);
    await HomeWidget.saveWidgetData<bool>('is_yesterday', state == WidgetDisplayState.yesterday);
    await HomeWidget.saveWidgetData<bool>('is_empty', state == WidgetDisplayState.empty);

    if (engagementMessage != null) {
      await HomeWidget.saveWidgetData<String>('engagement_message', engagementMessage);
    }
  }

  /// 빈 위젯 데이터 생성 (신규 사용자용)
  static SharedWidgetData _createEmptyWidgetData() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return SharedWidgetData(
      overall: const WidgetOverallData(
        score: 0,
        grade: '-',
        message: '운세를 받아보세요 ✨',
      ),
      categories: {
        for (final key in ['love', 'money', 'work', 'study', 'health'])
          key: WidgetCategoryData(
            key: key,
            name: _categoryNames[key] ?? key,
            score: 0,
            message: '',
            icon: _categoryIcons[key] ?? '✨',
          ),
      },
      timeSlots: [
        for (final entry in _timeSlotInfo.entries)
          WidgetTimeSlotData(
            key: entry.key,
            name: entry.value['name']!,
            timeRange: entry.value['range']!,
            score: 0,
            message: '',
            icon: entry.value['icon']!,
          ),
      ],
      lottoNumbers: [],
      updatedAt: now,
      validDate: todayStr,
      displayState: WidgetDisplayState.empty,
      engagementMessage: '운세를 받아보세요 ✨',
    );
  }

  /// 저장된 사용자 ID 로드 (백그라운드용)
  static Future<String?> loadStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('widget_user_id');
  }

  /// 사용자 ID 저장 (백그라운드 접근용)
  static Future<void> storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('widget_user_id', userId);
  }

  /// 저장된 사용자 ID 삭제 (로그아웃 시)
  static Future<void> clearStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('widget_user_id');
  }
}

/// Supabase 캐시 조회 결과
class WidgetCacheResult {
  final WidgetCacheData? today;
  final WidgetCacheData? yesterday;
  final bool hasData;

  WidgetCacheResult({
    this.today,
    this.yesterday,
    required this.hasData,
  });

  factory WidgetCacheResult.fromJson(Map<String, dynamic> json) {
    return WidgetCacheResult(
      today: json['today'] != null
          ? WidgetCacheData.fromJson(json['today'] as Map<String, dynamic>)
          : null,
      yesterday: json['yesterday'] != null
          ? WidgetCacheData.fromJson(json['yesterday'] as Map<String, dynamic>)
          : null,
      hasData: json['hasData'] as bool? ?? false,
    );
  }

  /// 캐시 데이터를 SharedWidgetData로 변환
  SharedWidgetData? toSharedWidgetData({required bool isToday}) {
    final data = isToday ? today : yesterday;
    if (data == null) return null;

    final now = DateTime.now();

    return SharedWidgetData(
      overall: WidgetOverallData(
        score: data.overallScore,
        grade: data.overallGrade,
        message: data.overallMessage ?? '',
      ),
      categories: data.categories.map(
        (key, value) => MapEntry(
          key,
          WidgetCategoryData(
            key: key,
            name: WidgetDataService._categoryNames[key] ?? key,
            score: value['score'] as int? ?? 80,
            message: value['message'] as String? ?? '',
            icon: WidgetDataService._categoryIcons[key] ?? '✨',
          ),
        ),
      ),
      timeSlots: data.timeSlots.map((slot) {
        final key = slot['key'] as String? ?? 'morning';
        final info = WidgetDataService._timeSlotInfo[key] ??
            WidgetDataService._timeSlotInfo['morning']!;
        return WidgetTimeSlotData(
          key: key,
          name: slot['name'] as String? ?? info['name']!,
          timeRange: info['range']!,
          score: slot['score'] as int? ?? 80,
          message: slot['message'] as String? ?? '',
          icon: info['icon']!,
        );
      }).toList(),
      lottoNumbers: data.lottoNumbers,
      updatedAt: now,
      validDate: data.fortuneDate,
      displayState: isToday ? WidgetDisplayState.today : WidgetDisplayState.yesterday,
      engagementMessage: isToday ? null : WidgetDataService.getEngagementMessage(),
    );
  }
}

/// 캐시 데이터 모델
class WidgetCacheData {
  final String fortuneDate;
  final int overallScore;
  final String overallGrade;
  final String? overallMessage;
  final Map<String, dynamic> categories;
  final List<Map<String, dynamic>> timeSlots;
  final List<int> lottoNumbers;

  WidgetCacheData({
    required this.fortuneDate,
    required this.overallScore,
    required this.overallGrade,
    this.overallMessage,
    required this.categories,
    required this.timeSlots,
    required this.lottoNumbers,
  });

  factory WidgetCacheData.fromJson(Map<String, dynamic> json) {
    return WidgetCacheData(
      fortuneDate: json['fortune_date'] as String? ?? '',
      overallScore: json['overall_score'] as int? ?? 80,
      overallGrade: json['overall_grade'] as String? ?? '길',
      overallMessage: json['overall_message'] as String?,
      categories: (json['categories'] as Map<String, dynamic>?) ?? {},
      timeSlots: ((json['time_slots'] as List<dynamic>?) ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      lottoNumbers: ((json['lotto_numbers'] as List<dynamic>?) ?? [])
          .map((e) => e as int)
          .toList(),
    );
  }
}
