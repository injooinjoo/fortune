import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_widget_data.freezed.dart';
part 'shared_widget_data.g.dart';

/// 위젯 표시 상태
enum WidgetDisplayState {
  /// 오늘 데이터 (정상)
  today,

  /// 어제 데이터 (앱 미접속 - engagement 유도)
  yesterday,

  /// 데이터 없음 (신규 사용자)
  empty,
}

/// 위젯용 통합 데이터 모델
/// fortune-daily와 fortune-investment 데이터를 위젯에 필요한 형태로 변환
@freezed
class SharedWidgetData with _$SharedWidgetData {
  const factory SharedWidgetData({
    /// 총운 데이터
    required WidgetOverallData overall,

    /// 카테고리별 운세 (연애/금전/직장/학업/건강)
    required Map<String, WidgetCategoryData> categories,

    /// 시간대별 운세 (아침/오후/저녁)
    required List<WidgetTimeSlotData> timeSlots,

    /// 로또 번호 (상위 5개)
    required List<int> lottoNumbers,

    /// 데이터 갱신 시각
    required DateTime updatedAt,

    /// 데이터 유효 날짜 (YYYY-MM-DD)
    required String validDate,

    /// 위젯 표시 상태 (today/yesterday/empty)
    @Default(WidgetDisplayState.today) WidgetDisplayState displayState,

    /// Engagement 유도 메시지 (앱 미접속 시)
    String? engagementMessage,
  }) = _SharedWidgetData;

  factory SharedWidgetData.fromJson(Map<String, dynamic> json) =>
      _$SharedWidgetDataFromJson(json);
}

/// 총운 위젯용 데이터
@freezed
class WidgetOverallData with _$WidgetOverallData {
  const factory WidgetOverallData({
    /// 총점 (0-100)
    required int score,

    /// 등급 (대길, 길, 평, 흉, 대흉)
    required String grade,

    /// 한줄 메시지
    required String message,

    /// 상세 설명 (Medium 위젯용)
    String? description,
  }) = _WidgetOverallData;

  factory WidgetOverallData.fromJson(Map<String, dynamic> json) =>
      _$WidgetOverallDataFromJson(json);
}

/// 카테고리 위젯용 데이터
@freezed
class WidgetCategoryData with _$WidgetCategoryData {
  const factory WidgetCategoryData({
    /// 카테고리 키 (love, money, work, study, health)
    required String key,

    /// 카테고리 이름 (연애운, 금전운, 직장운, 학업운, 건강운)
    required String name,

    /// 점수 (0-100)
    required int score,

    /// 한줄 메시지
    required String message,

    /// 아이콘 이모지
    required String icon,
  }) = _WidgetCategoryData;

  factory WidgetCategoryData.fromJson(Map<String, dynamic> json) =>
      _$WidgetCategoryDataFromJson(json);
}

/// 시간대 위젯용 데이터
@freezed
class WidgetTimeSlotData with _$WidgetTimeSlotData {
  const factory WidgetTimeSlotData({
    /// 시간대 키 (morning, afternoon, evening)
    required String key,

    /// 시간대 이름 (오전, 오후, 저녁)
    required String name,

    /// 시간 범위 (예: "06:00-12:00")
    required String timeRange,

    /// 점수 (0-100)
    required int score,

    /// 한줄 메시지
    required String message,

    /// 아이콘 이모지
    required String icon,
  }) = _WidgetTimeSlotData;

  factory WidgetTimeSlotData.fromJson(Map<String, dynamic> json) =>
      _$WidgetTimeSlotDataFromJson(json);
}

/// SharedWidgetData 확장 메서드
extension SharedWidgetDataX on SharedWidgetData {
  /// 현재 시간에 해당하는 시간대 데이터 반환
  WidgetTimeSlotData? get currentTimeSlot {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return timeSlots.firstWhere(
        (slot) => slot.key == 'morning',
        orElse: () => timeSlots.first,
      );
    } else if (hour >= 12 && hour < 18) {
      return timeSlots.firstWhere(
        (slot) => slot.key == 'afternoon',
        orElse: () => timeSlots.first,
      );
    } else {
      return timeSlots.firstWhere(
        (slot) => slot.key == 'evening',
        orElse: () => timeSlots.first,
      );
    }
  }

  /// 데이터가 오늘 날짜에 유효한지 확인
  bool get isValidForToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return validDate == todayStr;
  }

  /// 위젯 저장용 JSON 문자열 생성 (최적화된 크기)
  Map<String, dynamic> toWidgetJson() {
    return {
      // Overall (총운 위젯용)
      'o_score': overall.score,
      'o_grade': overall.grade,
      'o_msg': overall.message,
      'o_desc': overall.description,

      // Categories (카테고리 위젯용)
      'cat': categories.map(
        (key, value) => MapEntry(key, {
          'n': value.name,
          's': value.score,
          'm': value.message,
          'i': value.icon,
        }),
      ),

      // TimeSlots (시간대 위젯용)
      'ts': timeSlots
          .map((slot) => {
                'k': slot.key,
                'n': slot.name,
                'r': slot.timeRange,
                's': slot.score,
                'm': slot.message,
                'i': slot.icon,
              })
          .toList(),

      // Lotto (로또 위젯용)
      'lotto': lottoNumbers,

      // Metadata
      'updated': updatedAt.toIso8601String(),
      'date': validDate,
    };
  }

  /// 위젯 저장용 JSON에서 복원
  static SharedWidgetData fromWidgetJson(Map<String, dynamic> json) {
    final catMap = json['cat'] as Map<String, dynamic>;
    final tsList = json['ts'] as List<dynamic>;

    return SharedWidgetData(
      overall: WidgetOverallData(
        score: json['o_score'] as int,
        grade: json['o_grade'] as String,
        message: json['o_msg'] as String,
        description: json['o_desc'] as String?,
      ),
      categories: catMap.map(
        (key, value) {
          final v = value as Map<String, dynamic>;
          return MapEntry(
            key,
            WidgetCategoryData(
              key: key,
              name: v['n'] as String,
              score: v['s'] as int,
              message: v['m'] as String,
              icon: v['i'] as String,
            ),
          );
        },
      ),
      timeSlots: tsList.map((slot) {
        final s = slot as Map<String, dynamic>;
        return WidgetTimeSlotData(
          key: s['k'] as String,
          name: s['n'] as String,
          timeRange: s['r'] as String,
          score: s['s'] as int,
          message: s['m'] as String,
          icon: s['i'] as String,
        );
      }).toList(),
      lottoNumbers: (json['lotto'] as List<dynamic>).cast<int>(),
      updatedAt: DateTime.parse(json['updated'] as String),
      validDate: json['date'] as String,
    );
  }
}
