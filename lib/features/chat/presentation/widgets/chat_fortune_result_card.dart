import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/design_system/components/traditional/seal_stamp_widget.dart';

import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../fortune/domain/models/mbti_dimension_fortune.dart';
import '../../../fortune/domain/models/wish_fortune_result.dart';
import 'month_highlight_detail_bottom_sheet.dart';
import '../../../../presentation/widgets/fortune_infographic/fortune_infographic_facade.dart';
import '../../../../core/constants/fortune_metadata.dart';
import '../../../fortune/presentation/widgets/infographic/infographic_factory.dart';
import '../../../fortune/presentation/widgets/infographic/templates/image_template.dart';
import '../../../fortune/presentation/widgets/infographic/templates/chart/chart_templates.dart';
import '../../../fortune/presentation/widgets/infographic/category_bar_chart.dart';
import '../../../fortune/presentation/widgets/infographic/lucky_item_row.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
// ds_luck_colors.dart removed - use DSColors from design_system.dart
import '../../../../core/services/wish_local_storage.dart';
import 'fortune_result/fortune_score_circle.dart';
import 'fortune_result/lotto_ball.dart';
import 'fortune_result/category_distribution_painter.dart';

/// 채팅용 운세 결과 리치 카드
///
/// 이미지 헤더, 점수 원형, 카테고리 섹션, 행운 아이템 표시
class ChatFortuneResultCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String fortuneType;
  final String typeName;
  final DateTime? selectedDate;

  const ChatFortuneResultCard({
    super.key,
    required this.fortune,
    required this.fortuneType,
    required this.typeName,
    this.selectedDate,
  });

  @override
  ConsumerState<ChatFortuneResultCard> createState() =>
      _ChatFortuneResultCardState();
}

class _ChatFortuneResultCardState extends ConsumerState<ChatFortuneResultCard> {
  @override
  void initState() {
    super.initState();
    // 🐉 소원빌기: 로컬에 현재 소원 저장
    if (widget.fortuneType == 'wish') {
      _saveWishToLocal();
    }
  }

  /// 현재 소원을 로컬에 저장
  Future<void> _saveWishToLocal() async {
    final currentWish = _wishData;
    if (currentWish != null) {
      await WishLocalStorage.saveWish(currentWish);
    }
  }

  Fortune get fortune => widget.fortune;
  String get fortuneType => widget.fortuneType;
  String get typeName => widget.typeName;
  DateTime? get selectedDate => widget.selectedDate;

  /// 기간별 인사이트 제목 생성 (선택한 날짜 기반)
  String get _dailyCalendarTitle {
    if (selectedDate != null) {
      return '${selectedDate!.month}월 ${selectedDate!.day}일의 내 이야기';
    }
    return '오늘의 내 이야기';
  }

  DateTime _getCsatDate(DateTime now) {
    int year = now.year;
    DateTime csatDate = _thirdThursdayOfNovember(year);
    final today = DateTime(now.year, now.month, now.day);
    if (today.isAfter(csatDate)) {
      year += 1;
      csatDate = _thirdThursdayOfNovember(year);
    }
    return csatDate;
  }

  DateTime _thirdThursdayOfNovember(int year) {
    int count = 0;
    for (int day = 1; day <= 30; day += 1) {
      final date = DateTime(year, 11, day);
      if (date.weekday == DateTime.thursday) {
        count += 1;
        if (count == 3) {
          return date;
        }
      }
    }
    return DateTime(year, 11, 1);
  }

  DateTime? _parseExamDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final parsed = DateTime.parse(value);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      return null;
    }
  }

  DateTime? _resolveExamDate(String examTypeLabel, String? examDateStr) {
    if (examTypeLabel == '수능') {
      return _getCsatDate(DateTime.now());
    }
    return _parseExamDate(examDateStr);
  }

  /// 오늘의 운세 타입 체크 (설문 기반 아닌 운세)
  /// 'daily-calendar'는 기간별 인사이트로, 민화 이미지 사용
  bool get _isDailyFortune =>
      fortuneType == 'daily' || fortuneType == 'daily-calendar';

  /// 연간 운세 타입 체크
  bool get _isYearlyFortune =>
      fortuneType == 'yearly' || fortuneType == 'new-year';

  /// 연간 인사이트 제목 생성 (현재 연도 기반)
  String get _yearlyTitle {
    final year = DateTime.now().year;
    return '나의 $year년 인사이트';
  }

  /// 본문 content를 직접 표시해야 하는 타입 체크
  bool get _shouldShowContent =>
      _isDailyFortune ||
      fortuneType == 'compatibility' ||
      fortuneType == 'blind-date' ||
      fortuneType == 'love' ||
      fortuneType == 'career' ||
      fortuneType == 'exam' ||
      fortuneType == 'talisman' ||
      fortuneType == 'moving';

  /// 경계 대상 caution 데이터 존재 여부 체크
  bool get _hasCautionData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['cautionPeople'] != null ||
        metadata['cautionObjects'] != null;
  }

  /// 경계 대상 caution 데이터 가져오기
  Map<String, dynamic>? get _cautionData =>
      fortune.metadata ?? fortune.additionalInfo;

  /// 바이오리듬 타입 체크
  bool get _isBiorhythm => fortuneType == 'biorhythm';

  /// 로또 타입 체크
  bool get _isLottoType =>
      fortuneType == 'lotto' ||
      fortuneType == 'lottery' ||
      fortuneType == 'lucky-number';

  /// 연애운 상세 추천 존재 여부 체크
  bool get _hasLoveRecommendations {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['recommendations'] != null;
  }

  /// 바이오리듬 데이터 존재 여부 체크
  bool get _hasBiorhythmData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['physical'] != null ||
        metadata['emotional'] != null ||
        metadata['intellectual'] != null;
  }

  /// 재물운 타입 체크
  bool get _isWealth => fortuneType == 'wealth';

  /// 재물운 데이터 존재 여부 체크
  bool get _hasWealthData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['goalAdvice'] != null ||
        metadata['investmentInsights'] != null ||
        metadata['concernResolution'] != null;
  }

  /// 작명 타입 체크
  bool get _isNaming => fortuneType == 'naming';

  /// 작명 데이터 존재 여부 체크
  bool get _hasNamingData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['recommendedNames'] != null ||
        metadata['ohaengAnalysis'] != null;
  }

  /// 시험운 타입 체크
  bool get _isExam => fortuneType == 'exam';

  /// 수능 전용 타입 체크
  bool get _isCsatExam {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    final examType = metadata['exam_type'] as String?;
    final examCategory = metadata['exam_category'] as String?;
    return examCategory == 'csat' || examType == '수능';
  }

  /// 시험운 데이터 존재 여부 체크
  bool get _hasExamData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    // Edge Function 실제 필드명: pass_possibility, cautions, study_methods, lucky_hours
    return metadata['pass_possibility'] != null ||
        metadata['cautions'] != null ||
        metadata['study_methods'] != null ||
        metadata['lucky_hours'] != null;
  }

  bool get _hasCsatData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['csat_focus'] != null ||
        metadata['csat_roadmap'] != null ||
        metadata['csat_routine'] != null ||
        metadata['csat_checklist'] != null;
  }

  /// 건강운 타입 체크
  bool get _isHealth => fortuneType == 'health';

  /// 건강운 데이터 존재 여부 체크
  bool get _hasHealthData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['exercise_advice'] != null ||
        metadata['diet_advice'] != null ||
        metadata['overall_health'] != null;
  }

  /// 운동운 타입 체크
  bool get _isExercise => fortuneType == 'exercise';

  /// 운동운 데이터 존재 여부 체크
  bool get _hasExerciseData {
    // ✅ additionalInfo를 먼저 체크 (FortuneResponseModel.toEntity에서 metadata → additionalInfo로 매핑)
    final exerciseData = fortune.additionalInfo ?? fortune.metadata ?? {};

    // 디버그 로깅
    debugPrint('🏋️ [_hasExerciseData] fortuneType: $fortuneType');
    debugPrint(
        '🏋️ [_hasExerciseData] additionalInfo keys: ${fortune.additionalInfo?.keys.toList()}');
    debugPrint(
        '🏋️ [_hasExerciseData] metadata keys: ${fortune.metadata?.keys.toList()}');
    debugPrint(
        '🏋️ [_hasExerciseData] exerciseData keys: ${exerciseData.keys.toList()}');
    debugPrint(
        '🏋️ [_hasExerciseData] recommendedExercise: ${exerciseData['recommendedExercise'] != null}');
    debugPrint(
        '🏋️ [_hasExerciseData] todayRoutine: ${exerciseData['todayRoutine'] != null}');

    final hasData = exerciseData['recommendedExercise'] != null ||
        exerciseData['todayRoutine'] != null ||
        exerciseData['weeklyPlan'] != null;
    debugPrint('🏋️ [_hasExerciseData] result: $hasData');
    return hasData;
  }

  /// MBTI 타입 체크
  bool get _isMbti => fortuneType == 'mbti';

  /// MBTI dimensions 데이터 존재 여부 체크
  bool get _hasMbtiData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['dimensions'] != null;
  }

  /// MBTI todayTrap 데이터 가져오기
  String? get _mbtiTodayTrap {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['todayTrap'] as String?;
  }

  /// MBTI dimensions 데이터 파싱
  List<MbtiDimensionFortune> get _mbtiDimensions {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    final dimensionsJson = metadata?['dimensions'] as List<dynamic>?;
    return parseDimensions(dimensionsJson);
  }

  // ============ 소원 빌기 (Wish) 관련 ============

  /// 소원 빌기 타입 여부
  bool get _isWish => fortuneType == 'wish';

  /// 소원 빌기 확장 데이터 존재 여부
  bool get _hasWishData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['dragon_message'] != null ||
        metadata['fortune_flow'] != null ||
        metadata['lucky_mission'] != null;
  }

  /// 소원 빌기 결과 파싱
  WishFortuneResult? get _wishData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return null;
    try {
      return WishFortuneResult.fromJson(metadata);
    } catch (e) {
      return null;
    }
  }

  // ============ 부적 (Talisman) 관련 ============

  /// 부적 타입 여부
  bool get _isTalisman => fortuneType == 'talisman';

  /// 부적 상세 데이터 존재 여부
  bool get _hasTalismanData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['details'] != null ||
        metadata['luckyItems'] != null ||
        metadata['warnings'] != null;
  }

  /// 부적 details 데이터 가져오기
  Map<String, dynamic>? get _talismanDetails {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return null;
    final details = metadata['details'];
    return details is Map<String, dynamic> ? details : null;
  }

  /// 부적 luckyItems 배열 가져오기
  List<String> get _talismanLuckyItems {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return [];
    final items = metadata['luckyItems'];
    if (items is List) {
      return items.map((e) => e.toString()).toList();
    }
    return [];
  }

  // ============ 인포그래픽 관련 ============

  /// 인포그래픽 지원 여부 체크
  /// 인포그래픽이 있는 타입은 중복 점수 섹션을 표시하지 않음
  bool get _hasInfographic {
    final mappedKey = _mapFortuneTypeKey(fortuneType);
    final type = FortuneType.fromKey(mappedKey);
    return type != null && InfographicFactory.isSupported(type);
  }

  /// 부적 warnings 배열 가져오기
  List<String> get _talismanWarnings {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return [];
    final warnings = metadata['warnings'];
    if (warnings is List) {
      return warnings.map((e) => e.toString()).toList();
    }
    return [];
  }

  // ============ 가족운 (Family) 관련 ============

  /// 가족운 타입 체크 (모든 가족운 타입)
  bool get _isFamily =>
      fortuneType == 'family' ||
      fortuneType == 'family-health' ||
      fortuneType == 'family-wealth' ||
      fortuneType == 'family-relationship' ||
      fortuneType == 'family-children' ||
      fortuneType == 'family-change';

  /// 가족 건강운 타입 체크
  bool get _isFamilyHealth => fortuneType == 'family-health';

  /// 가족 재물운 타입 체크
  bool get _isFamilyWealth => fortuneType == 'family-wealth';

  /// 가족 관계운 타입 체크
  bool get _isFamilyRelationship => fortuneType == 'family-relationship';

  /// 가족 자녀운 타입 체크
  bool get _isFamilyChildren => fortuneType == 'family-children';

  /// 가족 변화운 타입 체크
  bool get _isFamilyChange => fortuneType == 'family-change';

  /// 가족운 데이터 존재 여부 체크
  bool get _hasFamilyData {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    return metadata['familySynergy'] != null ||
        metadata['monthlyFlow'] != null ||
        metadata['familyAdvice'] != null ||
        metadata['recommendations'] != null ||
        metadata['healthCategories'] != null ||
        metadata['wealthCategories'] != null ||
        metadata['relationshipCategories'] != null ||
        metadata['childrenCategories'] != null ||
        metadata['changeCategories'] != null;
  }

  /// 가족운 카테고리 데이터 (타입별 다른 필드명)
  Map<String, dynamic>? get _familyCategories {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return null;
    if (_isFamilyHealth) {
      return metadata['healthCategories'] as Map<String, dynamic>?;
    }
    if (_isFamilyWealth) {
      return metadata['wealthCategories'] as Map<String, dynamic>?;
    }
    if (_isFamilyRelationship) {
      return metadata['relationshipCategories'] as Map<String, dynamic>?;
    }
    if (_isFamilyChildren) {
      return metadata['childrenCategories'] as Map<String, dynamic>?;
    }
    if (_isFamilyChange) {
      return metadata['changeCategories'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 가족운 familySynergy 데이터
  Map<String, dynamic>? get _familySynergy {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['familySynergy'] as Map<String, dynamic>?;
  }

  /// 가족운 monthlyFlow 데이터
  Map<String, dynamic>? get _familyMonthlyFlow {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['monthlyFlow'] as Map<String, dynamic>?;
  }

  /// 가족운 familyAdvice 데이터
  Map<String, dynamic>? get _familyAdvice {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['familyAdvice'] as Map<String, dynamic>?;
  }

  /// 가족운 recommendations 리스트
  List<String> get _familyRecommendations {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return [];
    final recs = metadata['recommendations'];
    if (recs is List) {
      return recs.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// 가족운 warnings 리스트
  List<String> get _familyWarnings {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return [];
    final warnings = metadata['warnings'];
    if (warnings is List) {
      return warnings.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// 가족운 specialAnswer
  String? get _familySpecialAnswer {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['specialAnswer'] as String?;
  }

  /// 가족운 타입별 특수 조언 데이터 (seasonalAdvice, timingAdvice 등)
  Map<String, dynamic>? get _familySpecialAdvice {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return null;
    if (_isFamilyHealth) {
      return metadata['seasonalAdvice'] as Map<String, dynamic>?;
    }
    if (_isFamilyWealth) {
      return metadata['monthlyTrend'] as Map<String, dynamic>?;
    }
    if (_isFamilyRelationship) {
      return metadata['communicationAdvice'] as Map<String, dynamic>?;
    }
    if (_isFamilyChildren) {
      return metadata['educationAdvice'] as Map<String, dynamic>?;
    }
    if (_isFamilyChange) {
      return metadata['timingAdvice'] as Map<String, dynamic>?;
    }
    return null;
  }

  // ============ 관상 (Face Reading) 관련 ============

  /// 관상 타입 체크
  bool get _isFaceReading =>
      fortuneType == 'face-reading' || fortuneType == 'physiognomy';

  /// 관상 데이터 존재 여부 체크 (V2 + Legacy 지원)
  bool get _hasFaceReadingData {
    final details = _faceReadingDetails;
    if (details == null) return false;

    // V2 형식 체크 (배열 기반)
    if (details['simplifiedOgwan'] != null ||
        details['simplifiedSibigung'] != null ||
        details['priorityInsights'] != null ||
        details['myeonggung_preview'] != null ||
        details['migan_preview'] != null ||
        details['faceCondition_preview'] != null) {
      return true;
    }

    // Legacy 형식 체크 (객체 기반)
    return details['ogwan'] != null ||
        details['samjeong'] != null ||
        details['sibigung'] != null ||
        details['myeonggung'] != null;
  }

  /// 관상 details 데이터 가져오기
  Map<String, dynamic>? get _faceReadingDetails {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['details'] as Map<String, dynamic>?;
  }

  // ─────────────────────────────────────────────────────────────
  // V2 Getters (배열 형식)
  // ─────────────────────────────────────────────────────────────

  /// V2: 간소화된 오관 데이터 (배열)
  /// [{ part, name, hanjaName, score, summary, icon }]
  List<Map<String, dynamic>>? get _faceReadingSimplifiedOgwan {
    final list = _faceReadingDetails?['simplifiedOgwan'] as List<dynamic>?;
    return list?.cast<Map<String, dynamic>>();
  }

  /// V2: 간소화된 십이궁 데이터 (배열)
  /// [{ palace, name, hanjaName, score, summary, icon }]
  List<Map<String, dynamic>>? get _faceReadingSimplifiedSibigung {
    final list = _faceReadingDetails?['simplifiedSibigung'] as List<dynamic>?;
    return list?.cast<Map<String, dynamic>>();
  }

  /// V2: 핵심 인사이트 (배열)
  /// [{ category, icon, title, description, score }]
  List<Map<String, dynamic>>? get _faceReadingPriorityInsights {
    final list = _faceReadingDetails?['priorityInsights'] as List<dynamic>?;
    return list?.cast<Map<String, dynamic>>();
  }

  /// V2: 명궁 프리뷰 { score, summary }
  Map<String, dynamic>? get _faceReadingMyeonggungPreview {
    return _faceReadingDetails?['myeonggung_preview'] as Map<String, dynamic>?;
  }

  /// V2: 미간 프리뷰 { score, summary }
  Map<String, dynamic>? get _faceReadingMiganPreview {
    return _faceReadingDetails?['migan_preview'] as Map<String, dynamic>?;
  }

  /// V2: 얼굴 컨디션 프리뷰 { overallConditionScore, conditionMessage }
  Map<String, dynamic>? get _faceReadingConditionPreview {
    return _faceReadingDetails?['faceCondition_preview']
        as Map<String, dynamic>?;
  }

  /// V2: 눈 프리뷰 { observation, interpretation, score }
  Map<String, dynamic>? get _faceReadingEyePreview {
    return _faceReadingDetails?['eye_preview'] as Map<String, dynamic>?;
  }

  /// V2: 얼굴형 (face_type)
  String? get _faceReadingFaceType {
    return _faceReadingDetails?['face_type'] as String?;
  }

  /// V2: 얼굴형 오행 (face_type_element)
  String? get _faceReadingFaceTypeElement {
    return _faceReadingDetails?['face_type_element'] as String?;
  }

  /// V2: 총운 (overall_fortune)
  String? get _faceReadingOverallFortune {
    return _faceReadingDetails?['overall_fortune'] as String?;
  }

  /// V2: 닮은 연예인 [{ name, similarity_score }]
  List<Map<String, dynamic>>? get _faceReadingSimilarCelebrities {
    final list = _faceReadingDetails?['similar_celebrities'] as List<dynamic>?;
    return list?.cast<Map<String, dynamic>>();
  }

  // ─────────────────────────────────────────────────────────────
  // Legacy Getters (객체 형식, 프리미엄용)
  // ─────────────────────────────────────────────────────────────

  /// Legacy: 관상 오관 (五官) 데이터 - 눈/코/입/귀/눈썹
  Map<String, dynamic>? get _faceReadingOgwan {
    return _faceReadingDetails?['ogwan'] as Map<String, dynamic>?;
  }

  /// Legacy: 관상 삼정 (三停) 데이터 - 상/중/하정
  Map<String, dynamic>? get _faceReadingSamjeong {
    return _faceReadingDetails?['samjeong'] as Map<String, dynamic>?;
  }

  /// Legacy: 관상 십이궁 (十二宮) 데이터
  Map<String, dynamic>? get _faceReadingSibigung {
    return _faceReadingDetails?['sibigung'] as Map<String, dynamic>?;
  }

  /// Legacy: 관상 명궁 분석
  Map<String, dynamic>? get _faceReadingMyeonggung {
    return _faceReadingDetails?['myeonggung'] as Map<String, dynamic>?;
  }

  /// Legacy: 관상 미간 분석
  Map<String, dynamic>? get _faceReadingMigan {
    return _faceReadingDetails?['migan'] as Map<String, dynamic>?;
  }

  /// 관상 동물상 분류
  String? get _faceReadingAnimalType {
    return _faceReadingDetails?['animalType'] as String?;
  }

  /// 관상 종합 메시지
  String? get _faceReadingSummary {
    return _faceReadingDetails?['summaryMessage'] as String? ??
        fortune.summary ??
        fortune.greeting;
  }

  // ============ 반려동물 궁합 (Pet Compatibility) 관련 ============

  /// 펫 궁합 타입 체크
  bool get _isPetCompatibility => fortuneType == 'pet-compatibility';

  /// 펫 속마음 편지 데이터 존재 여부
  bool get _hasPetsVoice {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    final petsVoice = metadata['pets_voice'];
    return petsVoice != null && petsVoice['heartfelt_letter'] != null;
  }

  /// 펫 속마음 편지 데이터
  Map<String, dynamic>? get _petsVoice {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['pets_voice'] as Map<String, dynamic>?;
  }

  /// 교감 미션 데이터 존재 여부
  bool get _hasBondingMission {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    if (metadata == null) return false;
    final mission = metadata['bonding_mission'];
    return mission != null && mission['mission_title'] != null;
  }

  /// 교감 미션 데이터
  Map<String, dynamic>? get _bondingMission {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['bonding_mission'] as Map<String, dynamic>?;
  }

  /// 펫 정보 데이터
  Map<String, dynamic>? get _petInfo {
    final metadata = fortune.metadata ?? fortune.additionalInfo;
    return metadata?['pet_info'] as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isPremium = ref.watch(isSubscriptionActiveProvider);
    final customChildren = _buildCustomLayout(context, isDark, isPremium);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.flat(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: customChildren ??
              [
                // 이미지 헤더
                _buildImageHeader(context),

                // 인포그래픽 요약 섹션 (시험운은 ExamSignalHeader에서 점수 표시하므로 제외)
                if (_buildInfographicSection(context) != null && !_isExam)
                  _buildInfographicSection(context)!,

                // 점수 섹션 (인포그래픽이 있는 타입은 중복되므로 제외)
                if (fortune.overallScore != null &&
                    !_isFaceReading &&
                    !_hasInfographic)
                  _buildScoreSection(context),

                // 인사말/총평
                if (fortune.greeting != null || fortune.summary != null)
                  _buildSummarySection(context),

                // 경계 대상 블러 섹션 (avoid-people)
                if (fortuneType == 'avoid-people' && _hasCautionData)
                  _buildCautionBlurredSections(context, isDark, isPremium),

                // 본문 content 표시 (daily, compatibility, love, career 등)
                if (_shouldShowContent &&
                    fortune.content.isNotEmpty &&
                    fortuneType != 'avoid-people')
                  _buildContentSection(context),

                // 기간별 인사이트 상세 데이터 (daily-calendar)
                if (fortuneType == 'daily-calendar')
                  _buildDailyCalendarSection(context),

                // 카테고리/육각형 점수 표시 (content 표시하지 않는 타입만)
                if (!_shouldShowContent) ...[
                  if (fortune.categories != null &&
                      fortune.categories!.isNotEmpty)
                    _buildCategoriesSection(context),
                  if (fortune.hexagonScores != null &&
                      fortune.hexagonScores!.isNotEmpty)
                    // 반려운세는 프로그레스 바 스타일로 표시
                    if (_isPetCompatibility)
                      _buildPetScoresSection(context)
                    else
                      _buildHexagonScoresSection(context),
                ],

                // 추천 사항
                if (fortune.recommendations != null &&
                    fortune.recommendations!.isNotEmpty)
                  _buildRecommendationsSection(context),

                // 행운 아이템 (인포그래픽에 이미 표시된 경우 제외)
                if (fortune.luckyItems != null &&
                    fortune.luckyItems!.isNotEmpty &&
                    !_hasInfographic)
                  _buildLuckyItemsSection(context),

                // lucky-items 전용: 상세 섹션 표시
                if (fortuneType == 'lucky-items')
                  _buildLuckyItemsDetailSections(context),

                // talent 전용: 상세 섹션 표시
                if (fortuneType == 'talent')
                  _buildTalentDetailSections(context),

                // biorhythm 전용: 3가지 리듬 상세 표시
                if (_isBiorhythm && _hasBiorhythmData)
                  _buildBiorhythmDetailSection(context),

                // lotto 전용: 로또 번호 공 표시
                if (_isLottoType) _buildLottoNumbersSection(context),

                // love 전용: 상세 추천 섹션 (데이트 장소, 패션, 악세서리 등)
                if (fortuneType == 'love' && _hasLoveRecommendations)
                  _buildLoveRecommendationsSection(context),

                // 연간 운세 전용 섹션들 (new_year, yearly)
                if (_isYearlyFortune) ...[
                  // 1. 목표별 맞춤 분석
                  _buildGoalFortuneSection(context, isPremium),
                  // 2. 오행 분석
                  _buildSajuAnalysisSection(context, isPremium),
                  // 3. 월별 하이라이트 (1-3월 무료, 4-12월 프리미엄)
                  _buildMonthlyHighlightsSection(context, isPremium),
                  // 4. 행동 계획
                  _buildActionPlanSection(context, isPremium),
                  // 5. 특별 메시지
                  _buildSpecialMessageSection(context, isPremium),
                ],

                // 재물운 전용 섹션들 (wealth)
                if (_isWealth && _hasWealthData) ...[
                  // 1. 선택한 관심 분야 태그
                  _buildWealthInterestsSection(context),
                  // 2. 목표 맞춤 조언
                  _buildWealthGoalAdviceSection(context, isPremium),
                  // 3. 고민 해결책
                  _buildWealthConcernSection(context, isPremium),
                  // 4. 관심 분야별 투자 인사이트
                  _buildWealthInvestmentInsightsSection(context, isPremium),
                  // 5. 월별 흐름
                  _buildWealthMonthlyFlowSection(context, isPremium),
                  // 6. 실천 항목
                  _buildWealthActionItemsSection(context, isPremium),
                ],

                // 작명 전용 섹션 (naming) - 추천 이름 목록
                if (_isNaming && _hasNamingData)
                  _buildNamingSection(context, isPremium),

                // 시험운 전용 섹션 (exam) - 2025 리뉴얼
                if (_isExam && _hasExamData) ...[
                  if (_isCsatExam && _hasCsatData) ...[
                    _buildCsatSignalHeader(context),
                    _buildCsatFocusSection(context),
                    _buildCsatRoadmapSection(context),
                    _buildCsatRoutineSection(context),
                    _buildCsatChecklistSection(context),
                    _buildExamDdayAdviceSection(context, isPremium),
                    _buildExamMentalCareSection(context, isPremium),
                  ] else ...[
                    // 1. 합격 시그널 헤더 (원형 게이지 + 해시태그)
                    _buildExamSignalHeader(context),
                    // 2. 시험 스탯 (프로그레스 바 3개)
                    _buildExamStatsSection(context),
                    // 3. 오늘의 1점 전략
                    _buildTodayStrategySection(context),
                    // 4. 영물의 기개
                    _buildSpiritAnimalSection(context),
                    // 5. 행운 정보 그리드
                    _buildExamLuckyInfoSection(context, isPremium),
                    // 6. D-day 맞춤 조언
                    _buildExamDdayAdviceSection(context, isPremium),
                    // 7. 멘탈 관리
                    _buildExamMentalCareSection(context, isPremium),
                  ],
                ],

                // 건강운 전용 섹션들 (health)
                if (_isHealth && _hasHealthData)
                  _buildHealthDetailSection(context, isDark),

                // 운동운 전용 섹션들 (exercise)
                if (_isExercise && _hasExerciseData)
                  _buildExerciseDetailSection(context, isDark),

                // MBTI 전용 섹션들 (mbti)
                if (_isMbti && _hasMbtiData) ...[
                  // 1. 오늘의 함정 배너 (위기감 유발)
                  if (_mbtiTodayTrap != null)
                    _buildMbtiTodayTrapSection(context),
                  // 2. 차원별 인사이트 카드 (경고 포함)
                  _buildMbtiDimensionCards(context),
                ],

                // 🐉 소원 빌기 전용 섹션들 (wish)
                if (_isWish && _hasWishData) ...[
                  _buildWishDragonHeaderSection(context), // 용의 한마디
                  _buildWishFortuneFlowSection(context), // 운의 흐름
                  _buildWishLuckyMissionSection(context), // 행운 미션
                  _buildWishDragonWisdomSection(context), // 용의 지혜
                  _buildWishEncouragementSection(context), // 응원 메시지
                  _buildWishAdviceSection(context), // 조언 리스트
                ],

                // 🧿 부적 전용 섹션들 (talisman)
                if (_isTalisman && _hasTalismanData) ...[
                  _buildTalismanDetailsSection(
                      context), // 세부 운세 (종합/애정/직장/건강/금전)
                  _buildTalismanLuckyItemsSection(context), // 행운 아이템
                  _buildTalismanWarningsSection(context), // 주의사항
                ],

                // 👨‍👩‍👧 가족운 전용 섹션들 (family-health/wealth/relationship/children/change)
                if (_isFamily && _hasFamilyData) ...[
                  _buildFamilyCategoriesSection(context, isDark), // 카테고리별 점수
                  _buildFamilySynergySection(context, isDark), // 가족 조화 분석
                  _buildFamilySpecialAdviceSection(
                      context, isDark), // 타입별 특수 조언
                  _buildFamilyMonthlyFlowSection(context, isDark), // 월별 흐름
                  _buildFamilyAdviceTipsSection(context, isDark), // 가족 조언
                  _buildFamilyRecommendationsSection(context, isDark), // 추천사항
                  _buildFamilyWarningsSection(context, isDark), // 주의사항
                  if (_familySpecialAnswer != null &&
                      _familySpecialAnswer!.isNotEmpty)
                    _buildFamilySpecialAnswerSection(
                        context, isDark), // 특별 질문 답변
                ],

                // 🐾 펫 궁합 전용 섹션들 (pet-compatibility)
                if (_isPetCompatibility) ...[
                  // 1. 교감 미션 (FREE - 먼저 표시)
                  if (_hasBondingMission) _buildBondingMissionSection(context),
                  // 2. 펫 속마음 편지 (PREMIUM)
                  if (_hasPetsVoice) _buildPetsVoiceSection(context, isPremium),
                ],

                // 🔮 관상 전용 섹션들 (face-reading)
                if (_isFaceReading && _hasFaceReadingData) ...[
                  _buildFaceReadingDetailSection(context, isDark),
                ],

                const SizedBox(height: DSSpacing.sm),
              ],
        ),
      ),
    );
  }

  List<Widget>? _buildCustomLayout(
    BuildContext context,
    bool isDark,
    bool isPremium,
  ) {
    if (_isDailyFortune) {
      return _buildDailyLayout(context);
    }
    if (_isYearlyFortune) {
      return _buildYearlyLayout(context, isPremium);
    }
    if (fortuneType == 'love') {
      return _buildLoveLayout(context);
    }
    if (_isWealth) {
      return _buildWealthLayout(context, isPremium);
    }
    if (_isHealth) {
      return _buildHealthLayout(context, isDark);
    }
    // 🐉 소원빌기 전용 레이아웃 (API 없이 심플하게)
    if (_isWish) {
      return _buildWishLayout(context);
    }
    return null;
  }

  /// 🐉 소원빌기 전용 레이아웃
  /// 사용자의 소원 텍스트를 깔끔하게 표시 (꿈해몽 스타일, API 호출 없음)
  List<Widget> _buildWishLayout(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    // API 호출 없이 fortune.content에서 소원 텍스트 가져오기
    final wishText = fortune.content;

    return [
      // 소원 텍스트 표시 (사용자가 적은 글)
      if (wishText.isNotEmpty)
        Container(
          margin: const EdgeInsets.all(DSSpacing.md),
          padding: const EdgeInsets.all(DSSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DSColors.accentSecondary.withValues(alpha: 0.95),
                DSColors.accentSecondary.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: DSColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // 별 이모지
              const Text('🌠', style: TextStyle(fontSize: 40)),
              const SizedBox(height: DSSpacing.md),
              // 소원 텍스트
              Text(
                '"$wishText"',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.sm),
              // 안내 문구
              Text(
                '소원이 하늘로 올라갔어요',
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
            begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),
    ];
  }

  /// 연간 운세 전용 레이아웃 (히어로 이미지만 사용, 중복 제거)
  List<Widget> _buildYearlyLayout(BuildContext context, bool isPremium) {
    return [
      // 히어로 이미지만 (점수 섹션 중복 제거) - 무료
      _buildImageHeader(context),
      // 인포그래픽 요약 섹션 - 무료 (점수 미리보기)
      if (_buildInfographicSection(context) != null)
        _buildInfographicSection(context)!,
      // 인사말/총평
      if (fortune.greeting != null || fortune.summary != null)
        _buildSummarySection(context),
      // 본문 content
      if (fortune.content.isNotEmpty) _buildContentSection(context),
      // 행운 아이템 - 인포그래픽에 이미 표시된 경우 제외
      if (fortune.luckyItems != null &&
          fortune.luckyItems!.isNotEmpty &&
          !_hasInfographic)
        _buildLuckyItemsSection(context),
      // 연간 운세 전용 섹션들 (이미 isPremium 파라미터로 내부 블러 처리)
      _buildGoalFortuneSection(context, isPremium),
      _buildSajuAnalysisSection(context, isPremium),
      _buildMonthlyHighlightsSection(context, isPremium),
      _buildActionPlanSection(context, isPremium),
      _buildSpecialMessageSection(context, isPremium),
      const SizedBox(height: DSSpacing.sm),
    ];
  }

  List<Widget> _buildDailyLayout(BuildContext context) {
    return [
      // 히어로 이미지 - 무료
      _buildImageHeader(context),
      // 🆕 갓생 지수 UI (점수 + 심플 도넛 % + 날짜) - 무료 (점수 미리보기)
      _buildGodlifeScoreSection(context),
      // 한줄평 (T/F 모드 메시지)
      _buildOnelinerSection(context),
      // 갓생 치트키 (personalActions)
      _buildCheatKeySection(context),
      // 행운 부스터 (luckyItems 리디자인)
      _buildLuckBoosterSection(context),
      // 기존 콘텐츠 섹션 (선택적 표시)
      if (fortune.content.isNotEmpty) _buildDailyStorySection(context),
      if (fortuneType == 'daily-calendar') _buildDailyCalendarSection(context),
      if (fortune.timeSpecificFortunes != null &&
          fortune.timeSpecificFortunes!.isNotEmpty)
        _buildDailyTimelineSection(context),
      if (fortune.categories != null && fortune.categories!.isNotEmpty)
        _buildCategoriesSection(context),
      if (fortune.hexagonScores != null && fortune.hexagonScores!.isNotEmpty)
        _buildHexagonScoresSection(context),
      if (fortune.recommendations != null &&
          fortune.recommendations!.isNotEmpty)
        _buildRecommendationsSection(context),
      const SizedBox(height: DSSpacing.sm),
    ];
  }

  List<Widget> _buildLoveLayout(BuildContext context) {
    return [
      _buildLoveHeader(context),
      // 인포그래픽 요약 섹션 (점수 원형 포함)
      if (_buildInfographicSection(context) != null)
        _buildInfographicSection(context)!,
      // 프리미엄 섹션들
      if (fortune.greeting != null || fortune.summary != null)
        _buildLoveMoodSection(context),
      if (fortune.content.isNotEmpty) _buildLoveMessageSection(context),
      if (fortune.hexagonScores != null && fortune.hexagonScores!.isNotEmpty)
        _buildLoveChemistrySection(context),
      if (_hasLoveRecommendations) _buildLoveRecommendationsSection(context),
      if (fortune.recommendations != null &&
          fortune.recommendations!.isNotEmpty)
        _buildRecommendationsSection(context),
      // 행운 아이템 - 인포그래픽에 이미 표시된 경우 제외
      if (fortune.luckyItems != null &&
          fortune.luckyItems!.isNotEmpty &&
          !_hasInfographic)
        _buildLuckyItemsSection(context),
      const SizedBox(height: DSSpacing.sm),
    ];
  }

  List<Widget> _buildWealthLayout(
    BuildContext context,
    bool isPremium,
  ) {
    return [
      // 헤더
      _buildWealthHeader(context),
      // 인포그래픽 요약 섹션 (점수 미리보기)
      if (_buildInfographicSection(context) != null)
        _buildInfographicSection(context)!,
      // 스냅샷 섹션
      _buildWealthSnapshotSection(context),
      // 재물운 상세 섹션들 (이미 isPremium 파라미터로 내부 처리)
      if (_hasWealthData) ...[
        _buildWealthInterestsSection(context),
        _buildWealthFocusRow(context, isPremium),
        _buildWealthInvestmentInsightsSection(context, isPremium),
        _buildWealthMonthlyFlowSection(context, isPremium),
        _buildWealthActionItemsSection(context, isPremium),
      ],
      // 추천 사항
      if (fortune.recommendations != null &&
          fortune.recommendations!.isNotEmpty)
        _buildRecommendationsSection(context),
      // 행운 아이템 - 인포그래픽에 이미 표시된 경우 제외
      if (fortune.luckyItems != null &&
          fortune.luckyItems!.isNotEmpty &&
          !_hasInfographic)
        _buildLuckyItemsSection(context),
      const SizedBox(height: DSSpacing.sm),
    ];
  }

  List<Widget> _buildHealthLayout(
    BuildContext context,
    bool isDark,
  ) {
    return [
      // 헤더
      _buildHealthHeader(context),
      // 인포그래픽 요약 섹션 (점수 미리보기)
      if (_buildInfographicSection(context) != null)
        _buildInfographicSection(context)!,
      // 신규 인포그래픽 섹션들
      _buildHealthKeywordChips(context),
      _buildElementBalanceSection(context),
      _buildFoodTable(context),
      _buildTimeActivityGrid(context),
      _buildCompactCautions(context),
      // 추천 사항
      if (fortune.recommendations != null &&
          fortune.recommendations!.isNotEmpty)
        _buildRecommendationsSection(context),
      // 행운 아이템 - 인포그래픽에 이미 표시된 경우 제외
      if (fortune.luckyItems != null &&
          fortune.luckyItems!.isNotEmpty &&
          !_hasInfographic)
        _buildLuckyItemsSection(context),
      const SizedBox(height: DSSpacing.sm),
    ];
  }

  Widget _buildImageHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final title = _isDailyFortune
        ? _dailyCalendarTitle
        : _isYearlyFortune
            ? _yearlyTitle
            : typeName;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DSRadius.card),
          topRight: Radius.circular(DSRadius.card),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (fortune.period != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    _getPeriodLabel(fortune.period!),
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 액션 버튼
          FortuneActionButtons(
            contentId: fortune.id,
            contentType: fortuneType,
            fortuneType: fortuneType,
            shareTitle: typeName,
            shareContent: fortune.summary ?? fortune.content,
            iconColor: colors.textSecondary,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLoveHeader(BuildContext context) {
    return _buildThemedHeader(
      context,
      title: typeName,
      subtitle: '오늘의 설렘 지수',
      badge: 'LOVE',
    );
  }

  Widget _buildWealthHeader(BuildContext context) {
    return _buildThemedHeader(
      context,
      title: typeName,
      subtitle: '오늘의 자산 흐름',
      badge: 'WEALTH',
    );
  }

  Widget _buildHealthHeader(BuildContext context) {
    return _buildThemedHeader(
      context,
      title: typeName,
      subtitle: '컨디션 체크 리포트',
      badge: 'HEALTH',
    );
  }

  Widget _buildThemedHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DSRadius.card),
          topRight: Radius.circular(DSRadius.card),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Text(
                      badge,
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                ],
                Text(
                  title,
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  subtitle,
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (fortune.period != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    _getPeriodLabel(fortune.period!),
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 액션 버튼
          FortuneActionButtons(
            contentId: fortune.id,
            contentType: fortuneType,
            fortuneType: fortuneType,
            shareTitle: typeName,
            shareContent: fortune.summary ?? fortune.content,
            iconColor: colors.textSecondary,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 갓생 리뉴얼 섹션들 (오늘의 갓생 지수 UI)
  // ============================================================

  /// 갓생 지수 섹션 - 제목 + 카테고리 분포 도넛 + 레전드 + 날짜
  Widget _buildGodlifeScoreSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = fortune.overallScore ?? 75;
    final now = widget.selectedDate ?? DateTime.now();

    // fortune.categories에서 상위 3개 추출
    final categories = fortune.categories ?? {};
    final sortedList = categories.entries
        .where((e) => e.key != 'total')
        .map((e) => MapEntry(e.key, (e.value['score'] as num?)?.toInt() ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sortedList.take(3).toList();

    // 총합 (분포 퍼센트 계산용)
    final totalScore = top3.fold<int>(0, (sum, e) => sum + e.value);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.lg,
      ),
      child: Column(
        children: [
          // 제목
          Text(
            '오늘의 갓생 지수',
            style: typography.headingSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // 총점 (도넛 위에 표시, 숫자만)
          Text(
            '$score',
            style: typography.displayLarge.copyWith(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),

          // 카테고리 분포 도넛 차트 + 레전드 (데이터 있을 때만)
          if (top3.isNotEmpty && totalScore > 0) ...[
            const SizedBox(height: DSSpacing.sm),
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: CategoryDistributionDonutPainter(
                  categories: top3,
                  strokeWidth: 20,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: top3.map((entry) {
                final percent = (entry.value / totalScore * 100).round();
                return _buildCategoryLegendItem(
                  context,
                  entry.key,
                  percent,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: DSSpacing.md),

          // 날짜
          Text(
            '${now.year}년 ${now.month}월 ${now.day}일 ${_getWeekdayText(now)}',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 레전드 아이템 위젯 (앱 톤앤매너에 맞춘 칩 스타일)
  Widget _buildCategoryLegendItem(
    BuildContext context,
    String categoryKey,
    int percent,
  ) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    // 카테고리별 색상 (monochrome style)
    const categoryColors = {
      'love': DSColors.error, // 연애
      'money': DSColors.warning, // 재물
      'work': DSColors.info, // 직장
      'health': DSColors.success, // 건강
      'study': DSColors.accentSecondary, // 학업
    };

    // 카테고리별 라벨
    const categoryLabels = {
      'love': '연애',
      'money': '재물',
      'work': '직장',
      'health': '건강',
      'study': '학업',
    };

    final color = categoryColors[categoryKey] ?? colors.textTertiary;
    final label = categoryLabels[categoryKey] ?? categoryKey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 색상 점
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // 라벨 + 퍼센트
          Text(
            '$label $percent%',
            style: typography.labelSmall.copyWith(
              color: isDark ? color : color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 한줄평 섹션 - T/F 모드 메시지 (흰색 카드)
  Widget _buildOnelinerSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // T/F 모드 결정 (MBTI 기반)
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final mbti = userProfile?.mbti;
    final isTMode = _isTMode(mbti);
    final score = fortune.overallScore ?? 75;

    // T/F 모드별 메시지 또는 summary 사용
    String oneliner = _getGodlifeScoreMessage(score, isTMode);

    // summary가 있으면 그것을 우선 사용 (API에서 온 맞춤 메시지)
    if (fortune.summary != null && fortune.summary!.isNotEmpty) {
      oneliner = fortune.summary!;
    }

    // 한줄평용 이모지 선택
    String emoji;
    if (score >= 80) {
      emoji = '✨';
    } else if (score >= 60) {
      emoji = '🌟';
    } else if (score >= 40) {
      emoji = '💫';
    } else {
      emoji = '🌙';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md + 4,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                oneliner,
                style: typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 갓생 치트키 섹션 - 체크박스 스타일 액션 아이템
  Widget _buildCheatKeySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // personalActions 또는 ai_tips 사용
    final actions = fortune.personalActions ?? [];
    final aiTips = fortune.metadata?['ai_tips'] as List<dynamic>? ?? [];

    // 데이터 통합 (personalActions 우선)
    final cheatItems = <Map<String, String>>[];

    if (actions.isNotEmpty) {
      for (final action in actions.take(4)) {
        cheatItems.add({
          'title': action['title']?.toString() ?? '',
          'why': action['why']?.toString() ?? '',
        });
      }
    } else if (aiTips.isNotEmpty) {
      for (final tip in aiTips.take(4)) {
        cheatItems.add({
          'title': tip.toString(),
          'why': '',
        });
      }
    }

    if (cheatItems.isEmpty) return const SizedBox.shrink();

    // MBTI에서 사용자 이름 가져오기 (옵션)
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final userName = userProfile?.name ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          // 라벤더 배경 (사용자 스펙)
          color: DSColors.accentSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    userName.isNotEmpty
                        ? '$userName님을 위한 갓생 치트키'
                        : '오늘의 갓생 치트키',
                    style: typography.labelLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 체크박스 아이템들
            ...cheatItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 빈 체크박스 아이콘 (☐ 스타일)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: DSColors.accentSecondary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: Text(
                          item['title'] ?? '',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 행운 부스터 섹션 - 아이콘 Row 스타일
  Widget _buildLuckBoosterSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final luckyItems = fortune.luckyItems ?? {};
    final sajuInsight =
        fortune.metadata?['sajuInsight'] as Map<String, dynamic>?;

    // 행운 아이템 추출
    final boosterItems = <Map<String, dynamic>>[];

    // 아이템
    final item = sajuInsight?['lucky_item'] ?? luckyItems['item'];
    if (item != null && item.toString().isNotEmpty) {
      boosterItems.add({
        'icon': Icons.star_rounded,
        'label': '행운 아이템',
        'value': item.toString(),
        'color': DSColors.info,
      });
    }

    // 간식/음식
    final food = luckyItems['food'] ?? sajuInsight?['lucky_food'];
    if (food != null && food.toString().isNotEmpty) {
      boosterItems.add({
        'icon': Icons.restaurant_rounded,
        'label': '행운의 간식',
        'value': food.toString(),
        'color': DSColors.warning,
      });
    }

    // 컬러
    final color = luckyItems['color'] ?? sajuInsight?['lucky_color'];
    if (color != null && color.toString().isNotEmpty) {
      boosterItems.add({
        'icon': Icons.palette_rounded,
        'label': '행운의 컬러',
        'value': '${color.toString()} 💜',
        'color': DSColors.accentSecondary,
      });
    }

    // 노래/음악
    final song =
        luckyItems['song'] ?? luckyItems['music'] ?? sajuInsight?['lucky_song'];
    if (song != null && song.toString().isNotEmpty) {
      boosterItems.add({
        'icon': Icons.music_note_rounded,
        'label': '행운의 노래',
        'value': song.toString(),
        'color': DSColors.accentSecondary,
      });
    }

    // 방향 (노래가 없을 경우에만)
    if (song == null || song.toString().isEmpty) {
      final direction =
          luckyItems['direction'] ?? sajuInsight?['luck_direction'];
      if (direction != null && direction.toString().isNotEmpty) {
        boosterItems.add({
          'icon': Icons.explore_rounded,
          'label': '행운의 방향',
          'value': direction.toString(),
          'color': DSColors.info,
        });
      }
    }

    if (boosterItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Text('🚀', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 행운 부스터',
                  style: typography.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 부스터 아이템들
            ...boosterItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                  child: Row(
                    children: [
                      // 아이콘 박스
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              (item['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: item['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      // 텍스트
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['label'] as String,
                              style: typography.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              item['value'] as String,
                              style: typography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStorySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.backgroundSecondary,
              colors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.textPrimary.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 이야기',
                  style: typography.labelMedium.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              fortune.content,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTimelineSection(BuildContext context) {
    final typography = context.typography;
    final slots = fortune.timeSpecificFortunes ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18,
                color: context.colors.accent,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '하루 흐름',
                style: typography.labelMedium.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 220, // 200 → 220: 오버플로우 방지
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
              itemBuilder: (context, index) {
                return _buildDailyTimelineCard(context, slots[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTimelineCard(
    BuildContext context,
    TimeSpecificFortune slot,
  ) {
    final colors = context.colors;
    final typography = context.typography;
    final scoreColor = _getScoreColor(context, slot.score);

    return GestureDetector(
      onTap: () => _showTimeSlotDetailSheet(context, slot),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: scoreColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot.time,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              slot.title,
              style: typography.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                slot.description,
                maxLines: 5, // 긴 텍스트 지원
                overflow: TextOverflow.ellipsis,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                '${slot.score}점',
                style: typography.labelSmall.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeSlotDetailSheet(
      BuildContext context, TimeSpecificFortune slot) {
    final colors = context.colors;
    final typography = context.typography;
    final scoreColor = _getScoreColor(context, slot.score);

    DSBottomSheet.show(
      context: context,
      showHandle: true,
      showClose: true,
      title: slot.time,
      maxHeightFactor: 0.6,
      isScrollable: true,
      padding: const EdgeInsets.all(DSSpacing.bottomSheetPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with score
          Row(
            children: [
              Expanded(
                child: Text(
                  slot.title,
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                child: Text(
                  '${slot.score}점',
                  style: typography.labelMedium.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // Full description
          Text(
            slot.description,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
              height: 1.6,
            ),
          ),
          // Recommendation if available
          if (slot.recommendation != null &&
              slot.recommendation!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.lg),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: colors.accent,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '추천',
                        style: typography.labelMedium.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    slot.recommendation!,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildLoveMoodSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final summary = fortune.summary ?? fortune.greeting ?? '';

    if (summary.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.accentSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('💗', style: typography.bodyLarge),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 무드',
                  style: typography.labelMedium.copyWith(
                    color: colors.accentSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              summary,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoveMessageSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accentSecondary.withValues(alpha: 0.08),
              colors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.accentSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: colors.accentSecondary,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '연애 메시지',
                  style: typography.labelMedium.copyWith(
                    color: colors.accentSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              fortune.content,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoveChemistrySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loveAccent = DSColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: loveAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('💞', style: typography.bodyLarge),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '관계 밸런스',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            FortuneInfographicWidgets.buildRadarChart(
              scores: fortune.hexagonScores!,
              size: 220,
              primaryColor: loveAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWealthSnapshotSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final summary = _resolveSummaryText();
    final score = fortune.overallScore;
    final wealthAccent = DSColors.warning;

    final chips = <Map<String, String>>[];
    if (fortune.specialTip != null && fortune.specialTip!.isNotEmpty) {
      chips.add({'label': '키워드', 'value': fortune.specialTip!});
    }
    final luckyItems = fortune.luckyItems ?? {};
    if (luckyItems['number'] != null) {
      chips.add({'label': '행운 숫자', 'value': luckyItems['number'].toString()});
    }
    if (luckyItems['color'] != null) {
      chips.add({'label': '행운 컬러', 'value': luckyItems['color'].toString()});
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              wealthAccent.withValues(alpha: 0.12),
              colors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: wealthAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (score != null)
                  FortuneScoreCircle(
                    score: score,
                    size: 64,
                    textColor: wealthAccent,
                    borderColor: wealthAccent.withValues(alpha: 0.4),
                  ),
                if (score != null) const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 재물 스냅샷',
                        style: typography.labelMedium.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        summary,
                        style: typography.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.sm),
              Wrap(
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                children: chips
                    .map(
                      (chip) => _buildInlineChip(
                        context,
                        label: chip['label']!,
                        value: chip['value']!,
                        color: wealthAccent,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWealthFocusRow(BuildContext context, bool isPremium) {
    return Column(
      children: [
        _buildWealthGoalAdviceSection(context, isPremium),
        _buildWealthConcernSection(context, isPremium),
      ],
    );
  }

  Widget _buildInlineChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        '$label: $value',
        style: typography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _resolveSummaryText() {
    final summary = fortune.summary?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }
    final greeting = fortune.greeting?.trim();
    if (greeting != null && greeting.isNotEmpty) {
      return greeting;
    }
    final fallback = fortune.content.trim();
    if (fallback.isEmpty) {
      return '오늘의 흐름을 정리했어요.';
    }
    return _truncateText(fallback, 120);
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// fortuneType 문자열을 FortuneType enum 키로 변환
  String _mapFortuneTypeKey(String typeKey) {
    // 내부적으로 사용하는 키와 FortuneType enum 키 매핑
    const keyMapping = {
      'daily-calendar': 'daily',
      'traditional-saju': 'traditionalSaju',
      'premium_saju': 'premiumSaju',
      'face-reading': 'faceReading',
      'personality-dna': 'personality',
      'past-life': 'pastLife',
      'avoid-people': 'avoidPeople',
      'lucky-items': 'luckyItems',
      'lucky-lottery': 'luckyLottery',
      'match-insight': 'sports',
      'blind-date': 'blindDate',
      'ex-lover': 'exLover',
    };
    return keyMapping[typeKey] ?? typeKey;
  }

  /// 인포그래픽 섹션 빌드
  ///
  /// FortuneType에 맞는 인포그래픽을 생성합니다.
  /// 지원되지 않는 타입은 null을 반환합니다.
  Widget? _buildInfographicSection(BuildContext context) {
    final mappedKey = _mapFortuneTypeKey(fortuneType);
    final type = FortuneType.fromKey(mappedKey);

    // DEBUG: 인포그래픽 생성 여부 확인
    debugPrint('🎨 Infographic Debug:');
    debugPrint('  - fortuneType: $fortuneType');
    debugPrint('  - mappedKey: $mappedKey');
    debugPrint('  - FortuneType: $type');
    debugPrint(
        '  - isSupported: ${type != null ? InfographicFactory.isSupported(type) : false}');

    if (type == null || !InfographicFactory.isSupported(type)) {
      debugPrint('  ❌ Infographic NOT rendered (type null or unsupported)');
      return null;
    }

    debugPrint('  ✅ Infographic WILL render');

    final config = InfographicFactory.getConfig(type);
    final score = fortune.overallScore ?? 75;

    Widget? infographic;

    switch (config.templateType) {
      case InfographicTemplateType.score:
        // 카테고리 데이터 변환
        List<CategoryData>? categories;
        if (fortune.categories != null && fortune.categories!.isNotEmpty) {
          categories = fortune.categories!.entries.map((e) {
            final val = e.value;
            final categoryValue = val is num
                ? val.toInt()
                : (val is Map ? (val['score'] as num?)?.toInt() ?? 0 : 0);
            return CategoryData(
              label: e.key,
              value: categoryValue,
            );
          }).toList();
        }

        // 행운 아이템 데이터 변환 (Map<String, dynamic> 형식)
        List<LuckyItem>? luckyItems;
        if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) {
          luckyItems = fortune.luckyItems!.entries.map((entry) {
            final itemType = _parseLuckyItemType(entry.key);
            final value = entry.value;
            final valueStr = value is String ? value : value?.toString() ?? '';
            return LuckyItem(
              type: itemType,
              value: valueStr,
              label: _getLuckyItemLabel(entry.key),
              icon: _getLuckyItemIcon(entry.key),
            );
          }).toList();
        }

        // love 타입: 풍성한 인포그래픽 (인연 확률, 팁, 행운 장소, 럭키 아이템)
        if (type == FortuneType.love) {
          final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
          final encounterProbability =
              metadata['encounterProbability'] as int? ??
                  metadata['encounter_probability'] as int? ??
                  (score > 70 ? score - 20 : score ~/ 2);

          // tips 추출 (recommendations 활용)
          List<String>? tips;
          if (metadata['tips'] != null && metadata['tips'] is List) {
            tips = (metadata['tips'] as List).map((e) => e.toString()).toList();
          } else if (fortune.recommendations != null &&
              fortune.recommendations!.isNotEmpty) {
            tips = fortune.recommendations!.take(3).toList();
          }

          // 행운 장소
          final luckyPlace = metadata['luckyPlace'] as String? ??
              metadata['lucky_place'] as String? ??
              fortune.luckyItems?['place']?.toString();

          // 럭키 아이템 추출 (todaysAdvice 또는 recommendations에서)
          final todaysAdvice =
              metadata['todaysAdvice'] as Map<String, dynamic>?;
          final recommendations =
              metadata['recommendations'] as Map<String, dynamic>?;

          // 행운 색상
          String? luckyColor;
          if (todaysAdvice?['luckyColor'] != null) {
            luckyColor = todaysAdvice!['luckyColor'] as String?;
          } else if (recommendations?['fashion']?['colors'] != null) {
            final colors = recommendations!['fashion']['colors'] as List?;
            if (colors != null && colors.isNotEmpty) {
              final colorStr = colors.first.toString();
              luckyColor = colorStr.split(' - ').first;
            }
          } else if (fortune.luckyItems?['color'] != null) {
            luckyColor = fortune.luckyItems!['color'].toString();
          }

          // 행운 시간
          final luckyTime = todaysAdvice?['luckyTime'] as String? ??
              metadata['luckyTime'] as String? ??
              fortune.luckyItems?['time']?.toString();

          // 행운 아이템
          final luckyItem = todaysAdvice?['luckyItem'] as String? ??
              metadata['luckyItem'] as String? ??
              fortune.luckyItems?['item']?.toString();

          infographic = InfographicFactory.buildLoveInfographic(
            score: score,
            encounterProbability: encounterProbability,
            tips: tips,
            luckyPlace: luckyPlace,
            luckyColor: luckyColor,
            luckyTime: luckyTime,
            luckyItem: luckyItem,
            date: DateTime.now(),
          );
        } else if (type == FortuneType.avoidPeople) {
          // avoid-people 타입: 8개 카테고리 + 행운요소 + 시간대별 전략
          final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

          // 카테고리별 항목 개수 계산
          final Map<String, int> categoryCounts = {};
          final categoryKeys = [
            'cautionPeople',
            'cautionObjects',
            'cautionColors',
            'cautionNumbers',
            'cautionAnimals',
            'cautionPlaces',
            'cautionTimes',
            'cautionDirections',
          ];
          for (final key in categoryKeys) {
            final items = metadata[key] as List?;
            if (items != null && items.isNotEmpty) {
              categoryCounts[key] = items.length;
            }
          }

          // 행운 요소 추출
          final luckyElementsRaw =
              metadata['luckyElements'] as Map<String, dynamic>?;
          Map<String, String>? luckyElements;
          if (luckyElementsRaw != null) {
            luckyElements = {
              if (luckyElementsRaw['color'] != null)
                'color': luckyElementsRaw['color'].toString(),
              if (luckyElementsRaw['number'] != null)
                'number': luckyElementsRaw['number'].toString(),
              if (luckyElementsRaw['direction'] != null)
                'direction': luckyElementsRaw['direction'].toString(),
              if (luckyElementsRaw['time'] != null)
                'time': luckyElementsRaw['time'].toString(),
              if (luckyElementsRaw['item'] != null)
                'item': luckyElementsRaw['item'].toString(),
              if (luckyElementsRaw['person'] != null)
                'person': luckyElementsRaw['person'].toString(),
            };
          }

          // 시간대별 전략 추출
          final timeStrategyRaw =
              metadata['timeStrategy'] as Map<String, dynamic>?;
          Map<String, Map<String, String>>? timeStrategy;
          if (timeStrategyRaw != null) {
            timeStrategy = {};
            for (final period in ['morning', 'afternoon', 'evening']) {
              final periodData =
                  timeStrategyRaw[period] as Map<String, dynamic>?;
              if (periodData != null) {
                timeStrategy[period] = {
                  if (periodData['caution'] != null)
                    'caution': periodData['caution'].toString(),
                  if (periodData['advice'] != null)
                    'advice': periodData['advice'].toString(),
                };
              }
            }
          }

          // 요약 메시지
          final summary = metadata['dailyAdvice'] as String? ?? fortune.summary;

          infographic = InfographicFactory.buildAvoidPeopleInfographic(
            score: score,
            categoryCounts: categoryCounts.isNotEmpty ? categoryCounts : null,
            luckyElements: luckyElements,
            timeStrategy: timeStrategy,
            summary: summary,
          );
        } else {
          infographic = InfographicFactory.buildScoreInfographic(
            fortuneType: type,
            score: score,
            categories: categories,
            luckyItems: luckyItems,
          );
        }
        break;

      case InfographicTemplateType.chart:
        // 차트 타입: 타입별 전용 리치 인포그래픽
        infographic = _buildRichChartInfographic(context, type, score);
        break;

      case InfographicTemplateType.image:
        // 이미지 타입: Face Reading 전용 구현
        if (type == FortuneType.faceReading ||
            type == FortuneType.physiognomy) {
          infographic = _buildFaceReadingInfographic(context, type, score);
        } else {
          // 다른 image 타입은 추후 구현
          return null;
        }
        break;

      case InfographicTemplateType.grid:
        // 그리드 타입: 추후 구현
        return null;

      case InfographicTemplateType.unsupported:
        return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: ClipRRect(
        borderRadius: DSRadius.lgBorder,
        child: infographic,
      ),
    );
  }

  /// 행운 아이템 타입에 맞는 아이콘 반환
  IconData _getLuckyItemIcon(String? type) {
    switch (type) {
      case 'color':
        return Icons.palette;
      case 'number':
        return Icons.pin;
      case 'time':
        return Icons.schedule;
      case 'direction':
        return Icons.explore;
      case 'food':
        return Icons.restaurant;
      case 'place':
        return Icons.place;
      default:
        return Icons.star;
    }
  }

  /// 행운 아이템 타입에 맞는 라벨 반환
  String _getLuckyItemLabel(String? type) {
    switch (type) {
      case 'color':
        return '행운 색상';
      case 'number':
        return '행운 숫자';
      case 'time':
        return '행운 시간';
      case 'direction':
        return '행운 방향';
      case 'food':
        return '행운 음식';
      case 'place':
        return '행운 장소';
      case 'item':
        return '행운 아이템';
      case 'animal':
        return '행운 동물';
      default:
        return '행운';
    }
  }

  /// 문자열을 LuckyItemType으로 변환
  LuckyItemType _parseLuckyItemType(String? type) {
    switch (type) {
      case 'color':
        return LuckyItemType.color;
      case 'number':
        return LuckyItemType.number;
      case 'time':
        return LuckyItemType.time;
      case 'food':
        return LuckyItemType.food;
      case 'item':
        return LuckyItemType.item;
      case 'direction':
        return LuckyItemType.direction;
      case 'place':
        return LuckyItemType.place;
      case 'animal':
        return LuckyItemType.animal;
      default:
        return LuckyItemType.custom;
    }
  }

  // ============ 리치 차트 인포그래픽 빌더 ============

  /// 차트 타입별 리치 인포그래픽 생성
  Widget? _buildRichChartInfographic(
    BuildContext context,
    FortuneType type,
    int score,
  ) {
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    switch (type) {
      case FortuneType.compatibility:
        return _buildCompatibilityChartInfographic(context, metadata, score);
      case FortuneType.saju:
      case FortuneType.traditionalSaju:
        return _buildSajuChartInfographic(context, metadata, score);
      case FortuneType.mbti:
        return _buildMbtiChartInfographic(context, metadata, score);
      case FortuneType.personality:
        return _buildPersonalityChartInfographic(context, metadata, score);
      case FortuneType.talent:
        return _buildTalentChartInfographic(context, metadata, score);
      case FortuneType.investment:
      case FortuneType.wealth:
        return _buildWealthChartInfographic(context, metadata, score);
      case FortuneType.sports:
        return _buildSportsChartInfographic(context, metadata, score);
      default:
        return _buildFallbackChartInfographic(context, score);
    }
  }

  /// 궁합 인포그래픽 빌드
  Widget _buildCompatibilityChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    // 카테고리 추출
    final categories = _extractCompatibilityCategories(metadata, score);

    // 사람 이름 추출
    final personAName = metadata['personAName'] as String? ??
        metadata['person_a_name'] as String? ??
        metadata['userProfile']?['name'] as String?;
    final personBName = metadata['personBName'] as String? ??
        metadata['person_b_name'] as String? ??
        metadata['partnerProfile']?['name'] as String?;

    // 요약 추출
    final summary = fortune.summary ?? metadata['summary'] as String?;

    return InfographicFactory.buildCompatibilityInfographic(
      overallScore: score,
      categories: categories,
      personAName: personAName,
      personBName: personBName,
      summary: summary,
    );
  }

  /// 궁합 카테고리 추출
  List<CompatibilityCategory> _extractCompatibilityCategories(
      Map<String, dynamic> metadata, int overallScore) {
    final List<CompatibilityCategory> categories = [];

    // Edge Function에서 오는 필드명들
    final categoryMap = {
      'emotional': '정서적 궁합',
      'emotional_compatibility': '정서적 궁합',
      'communication': '소통 능력',
      'communication_style': '소통 스타일',
      'values': '가치관 일치',
      'value_alignment': '가치관',
      'lifestyle': '생활방식',
      'long_term': '장기 전망',
      'long_term_potential': '장기 전망',
      'physical': '신체적 궁합',
      'intellectual': '지적 궁합',
    };

    for (final entry in categoryMap.entries) {
      final value = metadata[entry.key];
      if (value != null) {
        final catScore = value is num
            ? value.toInt()
            : (value is Map ? (value['score'] as num?)?.toInt() ?? 70 : 70);
        categories.add(CompatibilityCategory(
          label: entry.value,
          value: catScore,
        ));
      }
    }

    // 카테고리가 없으면 fortune.categories에서 추출
    if (categories.isEmpty && fortune.categories != null) {
      for (final entry in fortune.categories!.entries) {
        final val = entry.value;
        final catScore = val is num
            ? val.toInt()
            : (val is Map ? (val['score'] as num?)?.toInt() ?? 70 : 70);
        categories.add(CompatibilityCategory(
          label: entry.key,
          value: catScore,
        ));
      }
    }

    // 여전히 비어있으면 기본 카테고리 생성
    if (categories.isEmpty) {
      categories.addAll([
        CompatibilityCategory(
            label: '정서적 궁합', value: (overallScore * 0.9).toInt()),
        CompatibilityCategory(
            label: '가치관 일치',
            value: (overallScore * 1.05).toInt().clamp(0, 100)),
        CompatibilityCategory(
            label: '소통 스타일', value: (overallScore * 0.95).toInt()),
        CompatibilityCategory(label: '장기 전망', value: overallScore),
      ]);
    }

    return categories;
  }

  /// 사주 인포그래픽 빌드
  Widget _buildSajuChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    // 사주 4주 추출
    final pillars = _extractSajuPillars(metadata);
    // 오행 추출
    final elements = _extractFiveElements(metadata);
    // 격국/용신
    final geukguk = metadata['geukguk'] as String? ?? metadata['격국'] as String?;
    final yongshin =
        metadata['yongshin'] as String? ?? metadata['용신'] as String?;
    // 해석
    final interpretation =
        fortune.summary ?? metadata['interpretation'] as String?;

    return InfographicFactory.buildSajuInfographic(
      pillars: pillars,
      elements: elements,
      geukguk: geukguk,
      yongshin: yongshin,
      interpretation: interpretation,
      date: DateTime.now(),
    );
  }

  /// 사주 4주 추출
  List<SajuPillar> _extractSajuPillars(Map<String, dynamic> metadata) {
    final List<SajuPillar> pillars = [];
    final sajuData = metadata['saju'] as Map<String, dynamic>? ??
        metadata['fourPillars'] as Map<String, dynamic>? ??
        metadata;

    final pillarNames = ['year', 'month', 'day', 'hour'];

    for (final pillarName in pillarNames) {
      final pillar = sajuData[pillarName] as Map<String, dynamic>?;
      if (pillar != null) {
        pillars.add(SajuPillar(
          heavenlyStem:
              pillar['stem'] as String? ?? pillar['천간'] as String? ?? '?',
          earthlyBranch:
              pillar['branch'] as String? ?? pillar['지지'] as String? ?? '?',
        ));
      }
    }

    // 데이터가 없으면 기본값
    if (pillars.isEmpty) {
      pillars.addAll([
        const SajuPillar(heavenlyStem: '갑', earthlyBranch: '자'),
        const SajuPillar(heavenlyStem: '을', earthlyBranch: '축'),
        const SajuPillar(heavenlyStem: '병', earthlyBranch: '인'),
        const SajuPillar(heavenlyStem: '정', earthlyBranch: '묘'),
      ]);
    }

    return pillars;
  }

  /// 오행 추출
  Map<String, int> _extractFiveElements(Map<String, dynamic> metadata) {
    final elements = <String, int>{};
    final fiveElements = metadata['fiveElements'] as Map<String, dynamic>? ??
        metadata['오행'] as Map<String, dynamic>? ??
        fortune.fiveElements;

    if (fiveElements != null) {
      for (final entry in fiveElements.entries) {
        final value = entry.value;
        elements[entry.key] = value is num ? value.toInt() : 1;
      }
    }

    // 기본값
    if (elements.isEmpty) {
      elements.addAll({'목': 2, '화': 1, '토': 3, '금': 2, '수': 2});
    }

    return elements;
  }

  /// MBTI 인포그래픽 빌드
  Widget _buildMbtiChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    final mbtiType = metadata['mbtiType'] as String? ??
        metadata['mbti'] as String? ??
        metadata['type'] as String? ??
        'INFP';

    final dimensions = _extractMbtiDimensions(metadata);
    final todayMessage = fortune.summary ?? metadata['todayMessage'] as String?;
    final warning =
        metadata['warning'] as String? ?? metadata['caution'] as String?;

    return InfographicFactory.buildMbtiInfographic(
      mbtiType: mbtiType,
      dimensions: dimensions,
      todayMessage: todayMessage,
      warning: warning,
    );
  }

  /// MBTI 차원 추출
  ///
  /// API 응답 형식: {dimension: "E", score: 75, title: "외향형 에너지", ...}
  /// 차트 형식: {leftLabel: "E", rightLabel: "I", value: 75}
  List<MbtiDimension> _extractMbtiDimensions(Map<String, dynamic> metadata) {
    final dimensionsData = metadata['dimensions'] as List<dynamic>?;

    // 차원 페어 매핑 (leftLabel, rightLabel, isLeftSide)
    // isLeftSide: true면 score를 그대로, false면 100 - score
    const dimensionConfig = {
      'E': ('E', 'I', true), // E가 왼쪽
      'I': ('E', 'I', false), // I가 오른쪽
      'S': ('S', 'N', true), // S가 왼쪽
      'N': ('S', 'N', false), // N이 오른쪽
      'T': ('T', 'F', true), // T가 왼쪽
      'F': ('T', 'F', false), // F가 오른쪽
      'J': ('J', 'P', true), // J가 왼쪽
      'P': ('J', 'P', false), // P가 오른쪽
    };

    final Map<String, MbtiDimension> resultMap = {};

    if (dimensionsData != null && dimensionsData.isNotEmpty) {
      for (final dim in dimensionsData) {
        if (dim is Map<String, dynamic>) {
          // API 응답 형식: {dimension: "E", score: 75, ...}
          final dimension =
              dim['dimension'] as String? ?? dim['leftLabel'] as String? ?? '';
          final score = (dim['score'] as num?)?.toInt() ??
              (dim['value'] as num?)?.toInt() ??
              50;

          if (dimension.isNotEmpty && dimensionConfig.containsKey(dimension)) {
            final config = dimensionConfig[dimension]!;
            final leftLabel = config.$1;
            final rightLabel = config.$2;
            final isLeftSide = config.$3;

            // isLeftSide면 score 그대로, 아니면 100 - score
            // 이렇게 하면 score가 높을수록 해당 차원 방향으로 바가 표시됨
            final value = isLeftSide ? score : (100 - score);

            // 같은 쌍의 차원이 이미 있으면 덮어쓰지 않음
            final pairKey = '$leftLabel$rightLabel';
            if (!resultMap.containsKey(pairKey)) {
              resultMap[pairKey] = MbtiDimension(
                leftLabel: leftLabel,
                rightLabel: rightLabel,
                value: value,
              );
            }
          }
        }
      }
    }

    // 결과가 있으면 순서대로 정렬해서 반환
    if (resultMap.isNotEmpty) {
      return [
        if (resultMap.containsKey('EI')) resultMap['EI']!,
        if (resultMap.containsKey('SN')) resultMap['SN']!,
        if (resultMap.containsKey('TF')) resultMap['TF']!,
        if (resultMap.containsKey('JP')) resultMap['JP']!,
      ];
    }

    // 기본값 (API 응답이 없거나 파싱 실패 시)
    return const [
      MbtiDimension(leftLabel: 'E', rightLabel: 'I', value: 60),
      MbtiDimension(leftLabel: 'S', rightLabel: 'N', value: 45),
      MbtiDimension(leftLabel: 'T', rightLabel: 'F', value: 55),
      MbtiDimension(leftLabel: 'J', rightLabel: 'P', value: 40),
    ];
  }

  /// 성격 DNA 인포그래픽 빌드
  Widget _buildPersonalityChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    final mbti = metadata['mbti'] as String? ?? 'INFP';
    final bloodType = metadata['bloodType'] as String? ??
        metadata['blood_type'] as String? ??
        'A';
    final zodiac = metadata['zodiac'] as String? ?? '물병자리';
    final chineseZodiac = metadata['chineseZodiac'] as String? ??
        metadata['chinese_zodiac'] as String? ??
        '용띠';
    final personalityType = metadata['personalityType'] as String? ??
        metadata['personality_type'] as String? ??
        '창의적 몽상가';

    return InfographicFactory.buildPersonalityDnaInfographic(
      mbti: mbti,
      bloodType: bloodType,
      zodiac: zodiac,
      chineseZodiac: chineseZodiac,
      personalityType: personalityType,
    );
  }

  /// 재능 인포그래픽 빌드
  Widget _buildTalentChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    // 재능 차트도 Fallback 사용 (전용 템플릿이 복잡함)
    return _buildFallbackChartInfographic(context, score);
  }

  /// 재물/투자 인포그래픽 빌드
  Widget _buildWealthChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    // 재물 차트도 Fallback 사용
    return _buildFallbackChartInfographic(context, score);
  }

  /// 스포츠 인포그래픽 빌드
  Widget _buildSportsChartInfographic(
    BuildContext context,
    Map<String, dynamic> metadata,
    int score,
  ) {
    final teamA =
        metadata['teamA'] as String? ?? metadata['team_a'] as String? ?? '홈팀';
    final teamB =
        metadata['teamB'] as String? ?? metadata['team_b'] as String? ?? '원정팀';
    final teamAWinRate = metadata['teamAWinRate'] as int? ??
        metadata['team_a_win_rate'] as int? ??
        score;
    final matchInfo =
        metadata['matchInfo'] as String? ?? metadata['match_info'] as String?;

    return InfographicFactory.buildSportsInfographic(
      teamA: teamA,
      teamB: teamB,
      teamAWinRate: teamAWinRate,
      matchInfo: matchInfo,
    );
  }

  /// Fallback 차트 인포그래픽 (데이터 부족 시)
  Widget _buildFallbackChartInfographic(BuildContext context, int score) {
    final colors = context.colors;
    final typography = context.typography;
    final summary = fortune.summary;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: DSRadius.lgBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 점수 원형
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.3),
                width: 4,
              ),
              color: colors.surface,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: typography.displayMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '점',
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 요약 텍스트
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              summary,
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // 카테고리 바 차트 (있으면)
          if (fortune.categories != null && fortune.categories!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.lg),
            ...fortune.categories!.entries.take(4).map((entry) {
              final val = entry.value;
              final catScore = val is num
                  ? val.toInt()
                  : (val is Map ? (val['score'] as num?)?.toInt() ?? 70 : 70);
              return Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                child: _buildCategoryBar(context, entry.key, catScore),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// 카테고리 바 빌드
  Widget _buildCategoryBar(BuildContext context, String label, int value) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Face Reading 인포그래픽 빌드
  Widget _buildFaceReadingInfographic(
    BuildContext context,
    FortuneType type,
    int score,
  ) {
    final metadata = fortune.metadata;
    final details = metadata?['details'] as Map<String, dynamic>?;

    // 퍼센타일 추출
    final percentile = fortune.percentile ??
        metadata?['percentile'] as int? ??
        details?['percentile'] as int?;

    // 인사이트 추출 (오관 데이터에서)
    List<FaceInsight>? insights;
    final ogwan = details?['ogwan'] as Map<String, dynamic>?;
    if (ogwan != null) {
      insights = [];

      // 눈 (감찰관) - 가장 중요
      final eye = ogwan['eye'] as Map<String, dynamic>?;
      if (eye != null) {
        insights.add(FaceInsight(
          label: '핵심',
          part: '눈',
          description: eye['interpretation'] as String? ?? '지혜와 배우자운',
          icon: Icons.visibility_rounded,
          color: context.colors.accent,
        ));
      }

      // 코 (심판관)
      final nose = ogwan['nose'] as Map<String, dynamic>?;
      if (nose != null) {
        insights.add(FaceInsight(
          label: '재물',
          part: '코',
          description: nose['interpretation'] as String? ?? '재물과 사업운',
          icon: Icons.attach_money_rounded,
          color: context.colors.success,
        ));
      }

      // 입 (출납관)
      final mouth = ogwan['mouth'] as Map<String, dynamic>?;
      if (mouth != null) {
        insights.add(FaceInsight(
          label: '언변',
          part: '입',
          description: mouth['interpretation'] as String? ?? '식록과 언변',
          icon: Icons.record_voice_over_rounded,
          color: context.colors.warning,
        ));
      }
    }

    // 감정 분석 추출 (V2 데이터)
    Map<String, int>? emotionAnalysis;
    final emotion = details?['emotionAnalysis'] as Map<String, dynamic>?;
    if (emotion != null) {
      emotionAnalysis = {
        '미소': (emotion['smilePercentage'] as num?)?.toInt() ?? 0,
        '긴장': (emotion['tensionPercentage'] as num?)?.toInt() ?? 0,
        '편안': (emotion['relaxedPercentage'] as num?)?.toInt() ?? 0,
      };
    }

    // 닮은꼴 연예인 추출
    String? celebrityMatch;
    int? celebrityMatchPercent;
    final celebrities = details?['similar_celebrities'] as List<dynamic>?;
    if (celebrities != null && celebrities.isNotEmpty) {
      final first = celebrities.first as Map<String, dynamic>?;
      if (first != null) {
        celebrityMatch = first['name'] as String?;
        celebrityMatchPercent = (first['similarity_score'] as num?)?.toInt();
      }
    }

    return FaceReadingImageTemplate(
      faceImage: null, // 사진은 프라이버시 보호를 위해 표시하지 않음
      score: score,
      percentile: percentile,
      insights: insights,
      emotionAnalysis: emotionAnalysis,
      celebrityMatch: celebrityMatch,
      celebrityMatchPercent: celebrityMatchPercent,
      isShareMode: false,
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final score = fortune.overallScore ?? 0;
    final meokColor = DSColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.md,
      ),
      child: Column(
        children: [
          // 낙관 도장 스타일 점수
          SealStampWidget(
            text: '$score',
            shape: SealStampShape.circle,
            colorScheme: SealStampColorScheme.vermilion,
            size: SealStampSize.large,
            animated: true,
            showInkBleed: true,
          ),
          const SizedBox(height: DSSpacing.md),
          // 점수 메시지
          Text(
            _getScoreMessage(score),
            style: context.typography.headingSmall.copyWith(
              color: meokColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.xs),
          // 점수 설명
          Text(
            _getScoreDescription(score),
            style: context.typography.bodySmall.copyWith(
              color: meokColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '최상의 하루!';
    if (score >= 80) return '아주 좋은 하루';
    if (score >= 70) return '좋은 하루';
    if (score >= 60) return '무난한 하루';
    if (score >= 50) return '평범한 하루';
    if (score >= 40) return '조심이 필요한 날';
    return '신중한 하루를 보내세요';
  }

  /// 전체 본문 내용 표시 (오늘의 운세용)
  Widget _buildContentSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Text(
        fortune.content,
        style: typography.bodyMedium.copyWith(
          color: colors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  /// 기간별 인사이트 (daily_calendar) 상세 섹션
  Widget _buildDailyCalendarSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    final dailyFortunes = metadata['dailyFortunes'] as List<dynamic>?;
    // bestDate/worstDate는 객체 {date, reason} 또는 String일 수 있음
    final bestDateRaw = metadata['bestDate'];
    final worstDateRaw = metadata['worstDate'];
    final bestDate = bestDateRaw is Map<String, dynamic>
        ? bestDateRaw['date'] as String?
        : bestDateRaw as String?;
    final bestDateReason = bestDateRaw is Map<String, dynamic>
        ? bestDateRaw['reason'] as String?
        : null;
    final worstDate = worstDateRaw is Map<String, dynamic>
        ? worstDateRaw['date'] as String?
        : worstDateRaw as String?;
    final worstDateReason = worstDateRaw is Map<String, dynamic>
        ? worstDateRaw['reason'] as String?
        : null;
    final periodTheme = metadata['periodTheme'] as String?;
    final specialMessage = metadata['specialMessage'] as String?;
    final advice = metadata['advice'] as String?;

    // 데이터가 없으면 빈 위젯 반환
    if (dailyFortunes == null && bestDate == null && periodTheme == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 테마
          if (periodTheme != null && periodTheme.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.1),
                    colors.accentSecondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Row(
                children: [
                  Text('🎯', style: typography.headingMedium),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이 기간의 테마',
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        Text(
                          periodTheme,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 베스트/워스트 날짜 (펼쳐서 표시)
          if (bestDate != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildExpandedDateCard(
              context,
              icon: '✨',
              label: '좋은 날',
              date: bestDate,
              color: colors.success,
              reason: bestDateReason,
            ),
          ],
          if (worstDate != null) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildExpandedDateCard(
              context,
              icon: '⚠️',
              label: '주의할 날',
              date: worstDate,
              color: colors.warning,
              reason: worstDateReason,
            ),
          ],

          // 일별 운세 목록
          if (dailyFortunes != null && dailyFortunes.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              '📅 날짜별 운세',
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            ...dailyFortunes.take(5).map((fortune) {
              final fortuneMap = fortune as Map<String, dynamic>?;
              if (fortuneMap == null) return const SizedBox.shrink();

              final date = fortuneMap['date'] as String? ?? '';
              final score = fortuneMap['score'] as int? ?? 0;
              final summary = fortuneMap['summary'] as String? ??
                  fortuneMap['content'] as String? ??
                  '';

              return _buildDailyFortuneItem(
                context,
                date: date,
                score: score,
                summary: summary,
              );
            }),
          ],

          // 특별 메시지
          if (specialMessage != null && specialMessage.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💫', style: typography.bodyLarge),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      specialMessage,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 조언
          if (advice != null && advice.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡', style: typography.bodyLarge),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '조언',
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: DSSpacing.xs),
                        Text(
                          advice,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  /// 날짜 카드 위젯 (펼쳐서 표시 - reason 전체 보임)
  Widget _buildExpandedDateCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String date,
    required Color color,
    String? reason,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘 + 라벨 + 날짜
          Row(
            children: [
              Text(icon, style: typography.headingSmall),
              const SizedBox(width: DSSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    date,
                    style: typography.labelLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // reason이 있으면 구분선과 함께 전체 표시
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              width: double.infinity,
              height: 1,
              color: color.withValues(alpha: 0.2),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              reason,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 일별 운세 아이템
  Widget _buildDailyFortuneItem(
    BuildContext context, {
    required String date,
    required int score,
    required String summary,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    Color scoreColor;
    if (score >= 80) {
      scoreColor = colors.success;
    } else if (score >= 60) {
      scoreColor = colors.info;
    } else if (score >= 40) {
      scoreColor = colors.warning;
    } else {
      scoreColor = colors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // 점수 원형
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: typography.labelMedium.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          // 날짜 및 요약
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (summary.isNotEmpty)
                  Text(
                    summary,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final text = fortune.greeting ?? fortune.summary ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.accentSecondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.accentSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✨', style: typography.bodyLarge),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final categories = fortune.categories!;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리별 운세',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          FortuneInfographicWidgets.buildCategoryCards(
            categories,
            isDarkMode: context.isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonScoresSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final scores = fortune.hexagonScores!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세부 운세',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Center(
            child: FortuneInfographicWidgets.buildRadarChart(
              scores: scores,
              size: 220,
              primaryColor: colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// 반려운세 전용: 프로그레스 바 스타일 점수 표시
  Widget _buildPetScoresSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final scores = fortune.hexagonScores!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 컨디션 지표',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          ...scores.entries.map((entry) {
            final label = entry.key;
            final score = entry.value;
            final progressColor = _getPetScoreColor(score);

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '$score점',
                        style: typography.labelMedium.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: colors.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 반려운세 점수에 따른 색상
  Color _getPetScoreColor(int score) {
    if (score >= 80) return DSColors.success; // 초록
    if (score >= 60) return DSColors.info; // 파랑
    if (score >= 40) return DSColors.warning; // 주황
    return DSColors.error; // 분홍
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // 프리미엄 잠금 메시지 필터링 - 실제 추천만 표시
    final filteredRecommendations = fortune.recommendations!
        .where((rec) => !rec.contains('프리미엄 결제') && !rec.contains('🔒'))
        .toList();

    // 필터 후 빈 리스트면 섹션 자체를 숨김
    if (filteredRecommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💡', style: typography.bodyLarge),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 추천',
                style: typography.labelLarge.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          ...filteredRecommendations.take(3).map((rec) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: typography.bodyMedium.copyWith(
                      color: colors.accentSecondary,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      rec,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsSection(BuildContext context) {
    if (fortune.luckyItems == null || fortune.luckyItems!.isEmpty) {
      return const SizedBox.shrink();
    }

    final luckyItems = fortune.luckyItems!;
    final luckyNumberValue = luckyItems['number'] ?? luckyItems['numbers'];
    final luckyNumbers = <String>[];
    if (luckyNumberValue is List) {
      luckyNumbers.addAll(luckyNumberValue.map((n) => n.toString()));
    } else if (luckyNumberValue != null) {
      luckyNumbers.add(luckyNumberValue.toString());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: FortuneInfographicWidgets.buildTossStyleLuckyTags(
        luckyColor: luckyItems['color'] as String?,
        luckyFood: luckyItems['food'] as String?,
        luckyNumbers: luckyNumbers,
        luckyDirection: luckyItems['direction'] as String?,
      ),
    );
  }

  String _getPeriodLabel(String period) {
    // 로또/행운번호는 항상 오늘 날짜 표시
    if (widget.fortuneType == 'lucky-number' ||
        widget.fortuneType == 'lotto' ||
        widget.fortuneType == 'lottery') {
      final now = DateTime.now();
      return '${now.year}년 ${now.month}월 ${now.day}일';
    }

    return switch (period) {
      'today' => '오늘의 운세',
      'tomorrow' => '내일의 운세',
      'weekly' => '이번 주 운세',
      'monthly' => '이번 달 운세',
      'yearly' => '올해의 운세',
      _ => period,
    };
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '최고의 하루! 🌟';
    if (score >= 80) return '아주 좋은 운세예요! ✨';
    if (score >= 70) return '좋은 기운이 함께해요';
    if (score >= 60) return '평온한 하루가 될 거예요';
    if (score >= 50) return '조심하면 괜찮아요';
    return '차분하게 보내세요';
  }

  // ============================================================
  // T/F 모드 헬퍼 (MBTI 기반 메시지 톤 분기)
  // ============================================================

  /// MBTI에서 T/F 판단
  /// T 포함 → T모드(팩폭형), F 포함 또는 null → F모드(공감형)
  bool _isTMode(String? mbti) {
    if (mbti == null || mbti.isEmpty) return false;
    return mbti.toUpperCase().contains('T');
  }

  /// T/F 모드별 갓생 지수 메시지
  String _getGodlifeScoreMessage(int score, bool isTMode) {
    if (isTMode) {
      // 팩폭형 메시지
      if (score >= 90) return '오늘 진짜 터졌다 🔥';
      if (score >= 75) return '꽤 괜찮은 편';
      if (score >= 60) return '그냥 평균';
      if (score >= 40) return '조심해야 할 듯';
      return '오늘은 집에 있어';
    } else {
      // 공감형 메시지
      if (score >= 90) return '오늘 하루가 빛나요 ✨';
      if (score >= 75) return '좋은 기운이 함께해요';
      if (score >= 60) return '평온한 하루가 될 거예요';
      if (score >= 40) return '조심하면 괜찮아요';
      return '차분하게 보내세요 💙';
    }
  }

  /// 요일 텍스트 반환
  String _getWeekdayText(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${weekdays[date.weekday - 1]}요일';
  }

  /// 경계 대상 미리보기 섹션 (avoid-people fortune)
  // ignore: unused_element
  Widget _buildCautionPreviewSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _cautionData;

    if (data == null) return const SizedBox.shrink();

    final cautionPeople = data['cautionPeople'] as List<dynamic>? ?? [];
    final cautionObjects = data['cautionObjects'] as List<dynamic>? ?? [];

    // 경계인물/사물 중 severity가 high인 것 우선, 없으면 첫 번째 항목
    Map<String, dynamic>? previewPerson;
    Map<String, dynamic>? previewObject;

    // 경계인물 선택 (high severity 우선)
    for (final person in cautionPeople) {
      if (person is Map<String, dynamic>) {
        if (person['severity'] == 'high') {
          previewPerson = person;
          break;
        }
        previewPerson ??= person;
      }
    }

    // 경계사물 선택 (high severity 우선)
    for (final obj in cautionObjects) {
      if (obj is Map<String, dynamic>) {
        if (obj['severity'] == 'high') {
          previewObject = obj;
          break;
        }
        previewObject ??= obj;
      }
    }

    if (previewPerson == null && previewObject == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.error.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Text('👀', style: typography.headingSmall),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 핵심 경계대상',
                        style: typography.labelLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '프리미엄 구독 시 8개 카테고리 전체 공개',
                        style: typography.labelSmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.sm),
            Divider(
                height: 1, color: colors.textPrimary.withValues(alpha: 0.1)),
            const SizedBox(height: DSSpacing.sm),

            // 경계인물 미리보기
            if (previewPerson != null)
              _buildCautionPreviewItem(
                context,
                icon: '👤',
                category: '경계인물',
                title: previewPerson['type'] as String? ?? '',
                description: previewPerson['reason'] as String? ?? '',
                severity: previewPerson['severity'] as String? ?? 'medium',
                cautionSurnames:
                    (previewPerson['cautionSurnames'] as List<dynamic>?)
                        ?.cast<String>(),
                surnameReason: previewPerson['surnameReason'] as String?,
              ),

            if (previewPerson != null && previewObject != null)
              const SizedBox(height: DSSpacing.sm),

            // 경계사물 미리보기
            if (previewObject != null)
              _buildCautionPreviewItem(
                context,
                icon: '📦',
                category: '경계사물',
                title: previewObject['item'] as String? ?? '',
                description: previewObject['reason'] as String? ?? '',
                severity: previewObject['severity'] as String? ?? 'medium',
              ),

            const SizedBox(height: DSSpacing.md),

            // 더 보기 유도 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accentSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                  color: colors.accentSecondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open,
                    size: 14,
                    color: colors.accentSecondary,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '색상, 숫자, 장소, 시간 등 6개 카테고리 더 보기',
                    style: typography.labelSmall.copyWith(
                      color: colors.accentSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 경계 대상 미리보기 개별 아이템
  Widget _buildCautionPreviewItem(
    BuildContext context, {
    required String icon,
    required String category,
    required String title,
    required String description,
    required String severity,
    List<String>? cautionSurnames,
    String? surnameReason,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final severityColor = severity == 'high'
        ? colors.error
        : severity == 'medium'
            ? colors.warning
            : colors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: severityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Flexible(
                    child: Text(
                      title,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                description,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // 경계 성씨 표시
              if (cautionSurnames != null && cautionSurnames.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: cautionSurnames
                      .map(
                        (surname) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DSRadius.xs),
                            border: Border.all(
                              color: colors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '$surname씨',
                            style: typography.labelSmall.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (surnameReason != null && surnameReason.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  '🔮 $surnameReason',
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 경계 대상 블러 처리된 섹션들 (8개 카테고리)
  Widget _buildCautionBlurredSections(
      BuildContext context, bool isDark, bool isPremium) {
    final data = _cautionData;

    if (data == null) return const SizedBox.shrink();

    // 8개 카테고리 정의
    final categories = [
      ('👤', '경계인물', 'cautionPeople', data['cautionPeople']),
      ('📦', '경계사물', 'cautionObjects', data['cautionObjects']),
      ('🎨', '경계색상', 'cautionColors', data['cautionColors']),
      ('🔢', '경계숫자', 'cautionNumbers', data['cautionNumbers']),
      ('🐾', '경계동물', 'cautionAnimals', data['cautionAnimals']),
      ('📍', '경계장소', 'cautionPlaces', data['cautionPlaces']),
      ('⏰', '경계시간', 'cautionTimes', data['cautionTimes']),
      ('🧭', '경계방향', 'cautionDirections', data['cautionDirections']),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((cat) {
          final icon = cat.$1;
          final title = cat.$2;
          final items = cat.$4 as List<dynamic>? ?? [];

          if (items.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: _buildCategoryCard(
              context,
              icon: icon,
              title: title,
              items: items,
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 개별 카테고리 카드
  Widget _buildCategoryCard(
    BuildContext context, {
    required String icon,
    required String title,
    required List<dynamic> items,
    required bool isDark,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final Widget content = Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accentSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  '${items.length}개',
                  style: typography.labelSmall.copyWith(
                    color: colors.accentSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 아이템 목록 (전체 표시)
          ...items.map((item) {
            if (item is! Map<String, dynamic>) return const SizedBox.shrink();

            final itemTitle = item['type'] as String? ??
                item['item'] as String? ??
                item['color'] as String? ??
                item['number']?.toString() ??
                item['animal'] as String? ??
                item['place'] as String? ??
                item['time'] as String? ??
                item['direction'] as String? ??
                '';
            final itemReason = item['reason'] as String? ?? '';
            final severity = item['severity'] as String? ?? 'medium';

            final severityColor = severity == 'high'
                ? colors.error
                : severity == 'medium'
                    ? colors.warning
                    : colors.textSecondary;

            return Padding(
              padding: const EdgeInsets.only(top: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: severityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemTitle,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (itemReason.isNotEmpty)
                          Text(
                            itemReason,
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // 경계 성씨 표시 (cautionPeople만 해당)
                        if (title == '경계인물') ...[
                          if ((item['cautionSurnames'] as List<dynamic>?)
                                  ?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: DSSpacing.xs),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: (item['cautionSurnames']
                                      as List<dynamic>)
                                  .map(
                                    (surname) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            colors.error.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(DSRadius.sm),
                                        border: Border.all(
                                          color: colors.error
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '$surname씨 주의',
                                        style: typography.labelSmall.copyWith(
                                          color: colors.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if ((item['surnameReason'] as String?)?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: DSSpacing.xs),
                            Text(
                              '🔮 ${item['surnameReason']}',
                              style: typography.labelSmall.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    return content;
  }

  /// 작명 추천 이름 섹션 빌드 (naming 전용)
  Widget _buildNamingSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    final recommendedNames =
        metadata['recommendedNames'] as List<dynamic>? ?? [];
    final ohaengAnalysis = metadata['ohaengAnalysis'] as Map<String, dynamic>?;

    if (recommendedNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSSpacing.md),

          // 오행 분석 섹션
          if (ohaengAnalysis != null) ...[
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('☯️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '오행 분석',
                        style: typography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  if (ohaengAnalysis['yongsin'] != null)
                    Text(
                      '용신: ${ohaengAnalysis['yongsin']}',
                      style: typography.bodyMedium.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (ohaengAnalysis['recommendation'] != null) ...[
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      ohaengAnalysis['recommendation'] as String,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 추천 이름 헤더
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '추천 이름',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${recommendedNames.length}개',
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // 추천 이름 목록
          ...recommendedNames.asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value as Map<String, dynamic>;

            return _buildNameCard(context, name, index + 1);
          }),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  /// 개별 이름 카드 빌드
  Widget _buildNameCard(
      BuildContext context, Map<String, dynamic> name, int rank) {
    final colors = context.colors;
    final typography = context.typography;

    final koreanName = name['koreanName'] as String? ?? '';
    final hanjaName = name['hanjaName'] as String? ?? '';
    final hanjaMeaning =
        (name['hanjaMeaning'] as List<dynamic>?)?.cast<String>() ?? [];
    final totalScore = name['totalScore'] as int? ?? 0;
    final analysis = name['analysis'] as String? ?? '';
    final compatibility = name['compatibility'] as String? ?? '';

    return GestureDetector(
      onTap: () => _showNamingDetailBottomSheet(
        context,
        koreanName: koreanName,
        hanjaName: hanjaName,
        hanjaMeaning: hanjaMeaning,
        totalScore: totalScore,
        analysis: analysis,
        compatibility: compatibility,
        rank: rank,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: DSSpacing.sm),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: rank == 1
                    ? colors.accent.withValues(alpha: 0.08)
                    : colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: rank == 1
                      ? colors.accent.withValues(alpha: 0.3)
                      : colors.textPrimary.withValues(alpha: 0.1),
                  width: rank == 1 ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 순위 + 이름 + 점수
                  Row(
                    children: [
                      // 순위 배지
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: rank <= 3
                              ? colors.accent
                              : colors.textSecondary.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: typography.labelSmall.copyWith(
                              color: colors.surface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      // 한글 이름
                      Text(
                        koreanName,
                        style: typography.headingSmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      // 한자 이름
                      if (hanjaName.isNotEmpty)
                        Text(
                          '($hanjaName)',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      const Spacer(),
                      // 점수
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(context, totalScore)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          '$totalScore점',
                          style: typography.labelMedium.copyWith(
                            color: _getScoreColor(context, totalScore),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 한자 의미
                  if (hanjaMeaning.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.sm),
                    Wrap(
                      spacing: DSSpacing.xs,
                      runSpacing: DSSpacing.xs,
                      children: hanjaMeaning.map((meaning) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DSRadius.xs),
                          ),
                          child: Text(
                            meaning,
                            style: typography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // 분석
                  if (analysis.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.sm),
                    Text(
                      analysis,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 궁합
                  if (compatibility.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 14,
                          color: colors.accentSecondary,
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        Expanded(
                          child: Text(
                            compatibility,
                            style: typography.labelSmall.copyWith(
                              color: colors.accentSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 작명 추천 이름 상세보기 바텀시트
  void _showNamingDetailBottomSheet(
    BuildContext context, {
    required String koreanName,
    required String hanjaName,
    required List<String> hanjaMeaning,
    required int totalScore,
    required String analysis,
    required String compatibility,
    required int rank,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더: 이름 + 점수
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
              child: Row(
                children: [
                  // 순위 배지
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? colors.accent
                          : colors.textSecondary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: typography.labelMedium.copyWith(
                          color: colors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  // 이름
                  Text(
                    koreanName,
                    style: typography.headingMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hanjaName.isNotEmpty) ...[
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '($hanjaName)',
                      style: typography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // 점수
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: DSSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(context, totalScore)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Text(
                      '$totalScore점',
                      style: typography.labelLarge.copyWith(
                        color: _getScoreColor(context, totalScore),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 스크롤 가능한 콘텐츠
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 한자 의미
                    if (hanjaMeaning.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '한자 의미',
                            style: typography.labelMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      Wrap(
                        spacing: DSSpacing.xs,
                        runSpacing: DSSpacing.xs,
                        children: hanjaMeaning.map((meaning) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DSRadius.sm),
                            ),
                            child: Text(
                              meaning,
                              style: typography.bodyMedium.copyWith(
                                color: colors.accent,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: DSSpacing.md),
                    ],

                    // 분석 전문
                    if (analysis.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💡',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  '이름 분석',
                                  style: typography.labelMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DSSpacing.sm),
                            Text(
                              analysis,
                              style: typography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DSSpacing.md),
                    ],

                    // 궁합 전문
                    if (compatibility.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.accentSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                          border: Border.all(
                            color:
                                colors.accentSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: colors.accentSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '부모님과의 궁합',
                                  style: typography.labelMedium.copyWith(
                                    color: colors.accentSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DSSpacing.sm),
                            Text(
                              compatibility,
                              style: typography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: DSSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 점수에 따른 색상 반환 (디자인 시스템 통합)
  Color _getScoreColor(BuildContext context, int score) {
    final colors = context.colors;
    if (score >= 90) return colors.success;
    if (score >= 80) return colors.info;
    if (score >= 70) return colors.warning;
    return colors.textTertiary;
  }

  /// 바이오리듬 상세 섹션 빌드 (biorhythm 전용)
  Widget _buildBiorhythmDetailSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    final physical = metadata['physical'] as Map<String, dynamic>?;
    final emotional = metadata['emotional'] as Map<String, dynamic>?;
    final intellectual = metadata['intellectual'] as Map<String, dynamic>?;

    // today_recommendation이 String 또는 Map일 수 있음
    final todayRecRaw = metadata['today_recommendation'];
    final String? todayRec = todayRecRaw is String
        ? todayRecRaw
        : (todayRecRaw is Map
            ? todayRecRaw['text']?.toString() ??
                todayRecRaw['recommendation']?.toString()
            : null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSSpacing.md),
          // 3가지 리듬 카드
          if (physical != null)
            _buildRhythmCard(
              context,
              name: '신체',
              icon: '☀️',
              data: physical,
              color: colors.error,
            ),
          if (emotional != null)
            _buildRhythmCard(
              context,
              name: '감성',
              icon: '🌿',
              data: emotional,
              color: colors.success,
            ),
          if (intellectual != null)
            _buildRhythmCard(
              context,
              name: '지성',
              icon: '🌙',
              data: intellectual,
              color: colors.info,
            ),

          // 오늘의 추천
          if (todayRec != null && todayRec.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.1),
                    colors.accentSecondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🎯', style: typography.headingSmall),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '오늘의 추천',
                        style: typography.labelLarge.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    todayRec,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 로또 번호 공 섹션 빌드 (lotto 전용)
  Widget _buildLottoNumbersSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? {};
    final additionalInfo = fortune.additionalInfo ?? {};

    // lottoNumbers 추출 (metadata 또는 additionalInfo에서)
    List<int> lottoNumbers = [];
    final numbersFromMetadata = metadata['lottoNumbers'];
    final numbersFromAdditional = additionalInfo['lottoNumbers'];

    if (numbersFromMetadata is List) {
      lottoNumbers = numbersFromMetadata.map((e) => e as int).toList();
    } else if (numbersFromAdditional is List) {
      lottoNumbers = numbersFromAdditional.map((e) => e as int).toList();
    }

    if (lottoNumbers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSSpacing.md),
          // 제목
          Row(
            children: [
              Text('🎱', style: typography.headingSmall),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 행운 번호',
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 로또 번호 공들
          Center(
            child: Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              alignment: WrapAlignment.center,
              children: lottoNumbers.map((number) {
                return LottoBall(number: number);
              }).toList(),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 안내 문구
          Center(
            child: Text(
              '사주 기반으로 생성된 번호입니다',
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 리듬 카드 빌드
  Widget _buildRhythmCard(
    BuildContext context, {
    required String name,
    required String icon,
    required Map<String, dynamic> data,
    required Color color,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    final score = data['score'] as int? ?? 0;
    final phase = data['phase'] as String? ?? '';
    final status = data['status'] as String? ?? '';
    final advice = data['advice'] as String? ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘, 이름, 점수
          Row(
            children: [
              Text(icon, style: typography.headingSmall),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '$name 리듬',
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
                child: Text(
                  '$score점',
                  style: typography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.sm),

          // 프로그레스 바 + 상태
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DSRadius.full),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                _getPhaseKorean(phase),
                style: typography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // 상태 메시지
          if (status.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              status,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],

          // 조언
          if (advice.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡',
                  style: typography.labelSmall,
                ),
                const SizedBox(width: DSSpacing.xxs),
                Expanded(
                  child: Text(
                    advice,
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 바이오리듬 phase 한글 변환
  String _getPhaseKorean(String phase) => switch (phase.toLowerCase()) {
        'high' => '최고조',
        'rising' => '상승 중',
        'transition' => '전환기',
        'declining' => '하강 중',
        'recharge' => '재충전',
        _ => phase,
      };

  /// 연애운 상세 추천 섹션 빌드 (love 전용)
  Widget _buildLoveRecommendationsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final recommendations =
        metadata['recommendations'] as Map<String, dynamic>?;

    if (recommendations == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSSpacing.lg),

          // 섹션 타이틀
          Row(
            children: [
              Text('💝', style: typography.headingSmall),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 연애 추천',
                style: typography.labelLarge.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 데이트 장소 추천
          if (recommendations['dateSpots'] != null)
            _buildLoveRecommendationCard(
              context,
              icon: '📍',
              title: '데이트 장소',
              data: recommendations['dateSpots'] as Map<String, dynamic>,
              fields: ['primary', 'timeRecommendation', 'reason'],
              fieldLabels: {
                'primary': '추천 장소',
                'timeRecommendation': '추천 시간',
                'reason': '이유'
              },
            ),

          // 패션 추천
          if (recommendations['fashion'] != null)
            _buildLoveFashionCard(
                context, recommendations['fashion'] as Map<String, dynamic>),

          // 악세서리 추천
          if (recommendations['accessories'] != null)
            _buildLoveRecommendationCard(
              context,
              icon: '💎',
              title: '악세서리',
              data: recommendations['accessories'] as Map<String, dynamic>,
              fields: ['recommended', 'bags', 'avoid'],
              fieldLabels: {'recommended': '추천', 'bags': '가방', 'avoid': '피할 것'},
              listFields: ['recommended', 'avoid'],
            ),

          // 그루밍 추천
          if (recommendations['grooming'] != null)
            _buildLoveRecommendationCard(
              context,
              icon: '✨',
              title: '그루밍',
              data: recommendations['grooming'] as Map<String, dynamic>,
              fields: ['hair', 'makeup', 'nails'],
              fieldLabels: {'hair': '헤어', 'makeup': '메이크업', 'nails': '네일'},
            ),

          // 향수 추천
          if (recommendations['fragrance'] != null)
            _buildLoveRecommendationCard(
              context,
              icon: '🌸',
              title: '향수',
              data: recommendations['fragrance'] as Map<String, dynamic>,
              fields: ['notes', 'mood', 'timing'],
              fieldLabels: {'notes': '추천 향', 'mood': '분위기', 'timing': '타이밍'},
              listFields: ['notes'],
            ),

          // 대화 주제 추천
          if (recommendations['conversation'] != null)
            _buildLoveConversationCard(context,
                recommendations['conversation'] as Map<String, dynamic>),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  /// 연애 추천 카드 빌드
  Widget _buildLoveRecommendationCard(
    BuildContext context, {
    required String icon,
    required String title,
    required Map<String, dynamic> data,
    required List<String> fields,
    required Map<String, String> fieldLabels,
    List<String> listFields = const [],
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final validFields = fields.where((f) => data[f] != null).toList();
    if (validFields.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: typography.bodyLarge),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...validFields.map((field) {
            final value = data[field];
            final label = fieldLabels[field] ?? field;
            final isListField = listFields.contains(field);

            if (isListField && value is List) {
              return Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xxs),
                    ...value.take(3).map((item) => Padding(
                          padding: const EdgeInsets.only(left: DSSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•',
                                  style: typography.bodySmall
                                      .copyWith(color: colors.accent)),
                              const SizedBox(width: DSSpacing.xs),
                              Expanded(
                                child: Text(
                                  item.toString(),
                                  style: typography.bodySmall
                                      .copyWith(color: colors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: typography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    TextSpan(
                      text: value.toString(),
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 패션 추천 카드 빌드 (상세)
  Widget _buildLoveFashionCard(
      BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.08),
            colors.accentSecondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('👔', style: typography.bodyLarge),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '패션 스타일링',
                style: typography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // 스타일
          if (data['style'] != null)
            _buildFashionRow(context, '스타일', data['style'].toString()),

          // 컬러
          if (data['colors'] != null && data['colors'] is List)
            _buildFashionListRow(context, '컬러', data['colors'] as List),

          // 상의
          if (data['topItems'] != null && data['topItems'] is List)
            _buildFashionListRow(context, '상의', data['topItems'] as List),

          // 하의
          if (data['bottomItems'] != null && data['bottomItems'] is List)
            _buildFashionListRow(context, '하의', data['bottomItems'] as List),

          // 아우터
          if (data['outerwear'] != null)
            _buildFashionRow(context, '아우터', data['outerwear'].toString()),

          // 신발
          if (data['shoes'] != null)
            _buildFashionRow(context, '신발', data['shoes'].toString()),

          // 피해야 할 스타일
          if (data['avoidFashion'] != null && data['avoidFashion'] is List)
            _buildFashionListRow(
                context, '⚠️ 피할 것', data['avoidFashion'] as List,
                isWarning: true),
        ],
      ),
    );
  }

  Widget _buildFashionRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFashionListRow(BuildContext context, String label, List items,
      {bool isWarning = false}) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.labelSmall.copyWith(
              color: isWarning ? colors.error : colors.textTertiary,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xxs,
            children: items
                .take(4)
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isWarning
                            ? colors.error.withValues(alpha: 0.1)
                            : colors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                      ),
                      child: Text(
                        item.toString(),
                        style: typography.labelSmall.copyWith(
                          color: isWarning ? colors.error : colors.accent,
                          fontSize: 11,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 대화 추천 카드 빌드
  Widget _buildLoveConversationCard(
      BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💬', style: typography.bodyLarge),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '대화 주제',
                style: typography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // 추천 주제
          if (data['topics'] != null && data['topics'] is List) ...[
            Text(
              '추천 주제',
              style: typography.labelSmall.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...(data['topics'] as List).take(3).map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💡', style: typography.labelSmall),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          topic.toString(),
                          style: typography.bodySmall
                              .copyWith(color: colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // 대화 시작 문장
          if (data['openers'] != null && data['openers'] is List) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '대화 시작 멘트',
              style: typography.labelSmall.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...(data['openers'] as List).take(2).map((opener) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(DSSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Text(
                    '"${opener.toString()}"',
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )),
          ],

          // 피해야 할 주제
          if (data['avoid'] != null && data['avoid'] is List) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '⚠️ 피해야 할 주제',
              style: typography.labelSmall.copyWith(color: colors.error),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...(data['avoid'] as List).take(2).map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('❌', style: typography.labelSmall),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          topic.toString(),
                          style: typography.bodySmall
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // 팁
          if (data['tip'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯', style: typography.labelSmall),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['tip'].toString(),
                      style: typography.bodySmall
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 적성 운세 상세 섹션들 빌드 (talent 전용)
  Widget _buildTalentDetailSections(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = widget.fortune.additionalInfo ?? widget.fortune.metadata ?? {};

    // 데이터 추출
    final description = data['description'] as String? ?? '';
    final talentInsights = data['talentInsights'] as List<dynamic>? ?? [];
    final mentalModel = data['mentalModel'] as Map<String, dynamic>? ?? {};
    final weeklyPlan = data['weeklyPlan'] as List<dynamic>? ?? [];
    final collaboration = data['collaboration'] as Map<String, dynamic>? ?? {};
    final resumeAnalysis =
        data['resumeAnalysis'] as Map<String, dynamic>? ?? {};

    // 데이터가 없으면 빈 위젯 반환
    if (description.isEmpty && talentInsights.isEmpty && mentalModel.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상세 분석 섹션
          if (description.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTalentSection(
              context,
              icon: '📝',
              title: '상세 분석',
              child: Container(
                padding: const EdgeInsets.all(DSSpacing.md),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                child: Text(
                  description,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                  // 전체 내용 표시 (maxLines 제거)
                ),
              ),
            ),
          ],

          // TOP 재능 인사이트 (상위 3개)
          if (talentInsights.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTalentSection(
              context,
              icon: '🌟',
              title: 'TOP 재능',
              child: Column(
                children: talentInsights
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final insight = entry.value as Map<String, dynamic>? ?? {};
                  final talent = insight['talent'] as String? ?? '';
                  final potential = insight['potential'] as int? ?? 0;
                  final insightDesc = insight['description'] as String? ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      border: Border.all(
                        color: colors.textPrimary.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 순위 배지
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: index == 0
                                  ? [DSColors.warning, DSColors.warning]
                                  : index == 1
                                      ? [
                                          DSColors.textSecondary,
                                          DSColors.textSecondary
                                        ]
                                      : [
                                          DSColors.warning
                                              .withValues(alpha: 0.7),
                                          DSColors.warning
                                        ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: typography.labelSmall.copyWith(
                                color: colors.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        // 재능 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      talent,
                                      style: typography.bodyMedium.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getTalentScoreColor(
                                              context, potential)
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(DSRadius.sm),
                                    ),
                                    child: Text(
                                      '$potential점',
                                      style: typography.labelSmall.copyWith(
                                        color: _getTalentScoreColor(
                                            context, potential),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (insightDesc.isNotEmpty) ...[
                                const SizedBox(height: DSSpacing.xs),
                                Text(
                                  insightDesc,
                                  style: typography.bodySmall.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.4,
                                  ),
                                  // 전체 내용 표시 (maxLines 제거)
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // 멘탈 모델 분석
          if (mentalModel.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTalentSection(
              context,
              icon: '🧠',
              title: '멘탈 모델',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mentalModel['thinkingStyle'] != null)
                    _buildMentalModelItem(
                      context,
                      emoji: '💭',
                      label: '사고방식',
                      value: mentalModel['thinkingStyle'] as String,
                    ),
                  if (mentalModel['decisionPattern'] != null)
                    _buildMentalModelItem(
                      context,
                      emoji: '🎯',
                      label: '의사결정',
                      value: mentalModel['decisionPattern'] as String,
                    ),
                  if (mentalModel['learningStyle'] != null)
                    _buildMentalModelItem(
                      context,
                      emoji: '📚',
                      label: '학습스타일',
                      value: mentalModel['learningStyle'] as String,
                    ),
                ],
              ),
            ),
          ],

          // 협업 궁합 (간략하게)
          if (collaboration.isNotEmpty &&
              collaboration['teamRole'] != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTalentSection(
              context,
              icon: '🤝',
              title: '협업 역할',
              child: Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  border:
                      Border.all(color: colors.accent.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Text('👤', style: typography.bodyLarge),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Text(
                        collaboration['teamRole'] as String,
                        style: typography.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 7일 실행 계획 미리보기 (오늘/내일/모레)
          if (weeklyPlan.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Builder(builder: (context) {
              final weekdays = [
                '월요일',
                '화요일',
                '수요일',
                '목요일',
                '금요일',
                '토요일',
                '일요일'
              ];
              final today = DateTime.now().weekday; // 1=월, 7=일

              return _buildTalentSection(
                context,
                icon: '📅',
                title: '7일 실행 계획',
                child: Column(
                  children: weeklyPlan.take(3).map((dayPlan) {
                    final plan = dayPlan as Map<String, dynamic>? ?? {};
                    final day = plan['day'] as String? ?? '';
                    final focus = plan['focus'] as String? ?? '';
                    final activities =
                        plan['activities'] as List<dynamic>? ?? [];

                    // 오늘인지 확인
                    final dayIndex = weekdays.indexOf(day);
                    final isToday = dayIndex >= 0 && (dayIndex + 1) == today;

                    return Container(
                      margin: const EdgeInsets.only(bottom: DSSpacing.xs),
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: isToday
                            ? colors.accent.withValues(alpha: 0.1)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                        border: Border.all(
                          color: isToday
                              ? colors.accent.withValues(alpha: 0.3)
                              : colors.textPrimary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 요일
                          SizedBox(
                            width: 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day.isNotEmpty ? day.substring(0, 1) : '',
                                  style: typography.labelMedium.copyWith(
                                    color: isToday
                                        ? colors.accent
                                        : colors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isToday)
                                  Text(
                                    '오늘',
                                    style: typography.labelSmall.copyWith(
                                      color: colors.accent,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // 집중 영역 및 활동
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  focus,
                                  style: typography.labelMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (activities.isNotEmpty)
                                  Text(
                                    activities.first.toString(),
                                    style: typography.bodySmall.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],

          // 📄 이력서 기반 분석 섹션 (resumeAnalysis가 있을 때만)
          if (resumeAnalysis.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTalentSection(
              context,
              icon: '📄',
              title: '이력서 기반 분석',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 경력 적합도
                  if (resumeAnalysis['careerFit'] != null) ...[
                    _buildResumeAnalysisItem(
                      context,
                      icon: '💼',
                      title: '경력 적합도',
                      content: resumeAnalysis['careerFit'] as String,
                    ),
                    const SizedBox(height: DSSpacing.sm),
                  ],
                  // 보완 필요 스킬
                  if (resumeAnalysis['skillGaps'] != null) ...[
                    _buildResumeAnalysisItem(
                      context,
                      icon: '📈',
                      title: '보완 필요 스킬',
                      content: (resumeAnalysis['skillGaps'] as List<dynamic>)
                          .join('\n'),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                  ],
                  // 이직/전환 방향
                  if (resumeAnalysis['careerTransition'] != null) ...[
                    _buildResumeAnalysisItem(
                      context,
                      icon: '🔄',
                      title: '이직/전환 추천',
                      content: resumeAnalysis['careerTransition'] as String,
                    ),
                    const SizedBox(height: DSSpacing.sm),
                  ],
                  // 숨은 재능
                  if (resumeAnalysis['hiddenPotentials'] != null) ...[
                    _buildResumeAnalysisItem(
                      context,
                      icon: '💎',
                      title: '숨은 재능',
                      content:
                          (resumeAnalysis['hiddenPotentials'] as List<dynamic>)
                              .join('\n'),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                  ],
                  // 경력 가치
                  if (resumeAnalysis['experienceValue'] != null) ...[
                    _buildResumeAnalysisItem(
                      context,
                      icon: '⭐',
                      title: '경력 가치',
                      content: resumeAnalysis['experienceValue'] as String,
                    ),
                    const SizedBox(height: DSSpacing.sm),
                  ],
                  // 포지셔닝 전략
                  if (resumeAnalysis['positioningAdvice'] != null) ...[
                    _buildResumeAnalysisItem(
                      context,
                      icon: '🎯',
                      title: '포지셔닝 전략',
                      content: resumeAnalysis['positioningAdvice'] as String,
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  /// 이력서 분석 항목 빌더
  Widget _buildResumeAnalysisItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String content,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            content,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 적성 운세 섹션 빌더
  Widget _buildTalentSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: DSSpacing.xs),
            Text(
              title,
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        child,
      ],
    );
  }

  /// 멘탈 모델 개별 아이템 빌더
  Widget _buildMentalModelItem(
    BuildContext context, {
    required String emoji,
    required String label,
    required String value,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 재능 점수 색상 반환 (디자인 시스템 통합)
  Color _getTalentScoreColor(BuildContext context, int score) {
    final colors = context.colors;
    if (score >= 90) return colors.success;
    if (score >= 80) return colors.info;
    if (score >= 70) return colors.warning;
    return colors.error;
  }

  /// 행운 아이템 상세 섹션들 빌드 (lucky-items 전용)
  Widget _buildLuckyItemsDetailSections(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = widget.fortune.additionalInfo ?? widget.fortune.metadata ?? {};

    // ✅ 선택된 카테고리 추출 (기본값: 'all' - 전체 표시)
    final selectedCategory = data['selectedCategory'] as String? ?? 'all';
    final showAll = selectedCategory == 'all' || selectedCategory.isEmpty;

    // 카테고리별 표시 여부
    final showFashion = showAll || selectedCategory == 'fashion';
    final showFood = showAll || selectedCategory == 'food';
    final showColor =
        showAll || selectedCategory == 'color' || selectedCategory == 'fashion';
    final showPlace = showAll || selectedCategory == 'place';
    final showNumber = showAll || selectedCategory == 'number';

    // 데이터 추출
    final keyword = data['keyword'] as String? ?? '';
    final element = data['element'] as String? ?? '';
    final color = data['color'] as String? ?? '';
    final direction = data['direction'] as String? ?? '';
    final numbers = data['numbers'] as List<dynamic>? ?? [];
    final relationships = data['relationships'] as List<dynamic>? ?? [];
    final advice =
        data['advice'] as String? ?? data['lucky_advice'] as String? ?? '';
    final luckySummary =
        data['lucky_summary'] as String? ?? data['summary'] as String? ?? '';

    // ✅ 상세 필드 우선 사용 (reason, timing 포함)
    final foodDetail = data['foodDetail'] as List<dynamic>? ??
        data['food'] as List<dynamic>? ??
        [];
    final fashionDetail = data['fashionDetail'] as List<dynamic>? ??
        data['fashion'] as List<dynamic>? ??
        [];
    final colorDetail = data['colorDetail'] as Map<String, dynamic>? ??
        (data['colorDetail'] is Map
            ? data['colorDetail'] as Map<String, dynamic>
            : <String, dynamic>{});
    final placesDetail = data['placesDetail'] as List<dynamic>? ??
        data['places'] as List<dynamic>? ??
        [];
    final jewelryDetail = data['jewelryDetail'] as List<dynamic>? ??
        data['jewelry'] as List<dynamic>? ??
        [];
    final materialDetail = data['materialDetail'] as List<dynamic>? ??
        data['material'] as List<dynamic>? ??
        [];
    final numbersExplanation = data['numbersExplanation'] as String? ?? '';
    final avoidNumbers = data['avoidNumbers'] as List<dynamic>? ?? [];
    final todayTip = data['todayTip'] as String? ?? '';

    // 오늘 날짜 포맷
    final now = DateTime.now();
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오늘 날짜 배지
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: DSSpacing.xs, horizontal: DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📅', style: TextStyle(fontSize: 14)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '$dateStr ($weekday)',
                  style: typography.labelMedium.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // 오행 분석
          if (luckySummary.isNotEmpty || element.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '✨',
              title: '오행 분석',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (element.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                      decoration: BoxDecoration(
                        color: _getLuckyElementColor(element)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.full),
                        border: Border.all(
                            color: _getLuckyElementColor(element)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getLuckyElementEmoji(element),
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: DSSpacing.xs),
                          Text(
                            '오행: $element',
                            style: typography.labelMedium.copyWith(
                              color: _getLuckyElementColor(element),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (luckySummary.isNotEmpty)
                    Text(
                      luckySummary,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

          // 오늘의 키워드
          if (keyword.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '🔑',
              title: '오늘의 키워드',
              child: Wrap(
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                children: keyword
                    .split(',')
                    .map((k) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                          decoration: BoxDecoration(
                            color: colors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DSRadius.full),
                            border: Border.all(
                                color: colors.warning.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            k.trim(),
                            style: typography.labelSmall.copyWith(
                              color: colors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

          // 숫자 (number 카테고리 선택 시 상세 표시)
          if (showNumber && numbers.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '🔢',
              title: '오늘의 행운 숫자',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 행운 숫자들 (원형 배지)
                  Wrap(
                    spacing: DSSpacing.sm,
                    runSpacing: DSSpacing.sm,
                    children: numbers
                        .map((n) => Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colors.info,
                                    colors.info.withValues(alpha: 0.7)
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(DSRadius.full),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.info.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                n.toString(),
                                style: typography.headingMedium.copyWith(
                                  color: colors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  // 숫자 설명
                  if (numbersExplanation.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                      ),
                      child: Text(
                        numbersExplanation,
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  // 피해야 할 숫자
                  if (avoidNumbers.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                        border: Border.all(
                            color: colors.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                          Text('피해야 할 숫자: ',
                              style: typography.labelSmall
                                  .copyWith(color: colors.error)),
                          Text(
                            avoidNumbers.join(', '),
                            style: typography.bodySmall.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // 방향 (place 카테고리 선택 시 표시)
          if (showPlace && direction.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '🧭',
              title: '행운의 방향',
              child: _buildDetailedItemCard(
                context,
                item: direction,
                reason: '오늘 이 방향으로 움직이면 좋은 기운을 받을 수 있어요',
                accentColor: colors.success,
                emoji: '🧭',
              ),
            ),

          // 패션 (fashion 카테고리 선택 시만 표시) - 상세 카드
          if (showFashion && fashionDetail.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '👔',
              title: '오늘의 추천 패션',
              child: Column(
                children: fashionDetail.map((item) {
                  if (item is Map) {
                    return _buildDetailedItemCard(
                      context,
                      item: item['item']?.toString() ?? '',
                      reason: item['reason']?.toString() ?? '',
                      accentColor: colors.accentSecondary,
                      emoji: '👕',
                    );
                  }
                  return _buildDetailedItemCard(
                    context,
                    item: item.toString(),
                    reason: '',
                    accentColor: colors.accentSecondary,
                    emoji: '👕',
                  );
                }).toList(),
              ),
            ),

          // 음식 (food 카테고리 선택 시만 표시) - 상세 카드
          if (showFood && foodDetail.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '🍽️',
              title: '오늘의 추천 음식',
              child: Column(
                children: foodDetail.map((item) {
                  if (item is Map) {
                    return _buildDetailedItemCard(
                      context,
                      item: item['item']?.toString() ?? '',
                      reason: item['reason']?.toString() ?? '',
                      timing: item['timing']?.toString(),
                      accentColor: colors.warning,
                      emoji: '🍜',
                    );
                  }
                  return _buildDetailedItemCard(
                    context,
                    item: item.toString(),
                    reason: '',
                    accentColor: colors.warning,
                    emoji: '🍜',
                  );
                }).toList(),
              ),
            ),

          // 색상 (color 카테고리 선택 시 상세 표시)
          if (showColor && (colorDetail.isNotEmpty || color.isNotEmpty))
            _buildLuckySection(
              context,
              icon: '🎨',
              title: '오늘의 행운 색상',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailedItemCard(
                    context,
                    item: '메인 색상: ${colorDetail['primary'] ?? color}',
                    reason: colorDetail['reason']?.toString() ?? '오행 균형을 위한 색상',
                    accentColor: colors.error,
                    emoji: '🔴',
                  ),
                  if (colorDetail['secondary'] != null)
                    _buildDetailedItemCard(
                      context,
                      item: '보조 색상: ${colorDetail['secondary']}',
                      reason: '메인 색상과 조화로운 조합',
                      accentColor: colors.error.withValues(alpha: 0.7),
                      emoji: '🟠',
                    ),
                ],
              ),
            ),

          // 보석/액세서리 (fashion 카테고리 선택 시만 표시) - 상세 카드
          if (showFashion && jewelryDetail.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '💎',
              title: '행운의 보석/액세서리',
              child: Column(
                children: jewelryDetail.map((item) {
                  if (item is Map) {
                    return _buildDetailedItemCard(
                      context,
                      item: item['item']?.toString() ?? '',
                      reason: item['reason']?.toString() ?? '',
                      accentColor: colors.accent,
                      emoji: '💍',
                    );
                  }
                  return _buildDetailedItemCard(
                    context,
                    item: item.toString(),
                    reason: '',
                    accentColor: colors.accent,
                    emoji: '💍',
                  );
                }).toList(),
              ),
            ),

          // 소재 (fashion 카테고리 선택 시만 표시) - 상세 카드
          if (showFashion && materialDetail.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '🧶',
              title: '행운의 소재',
              child: Column(
                children: materialDetail.map((item) {
                  if (item is Map) {
                    return _buildDetailedItemCard(
                      context,
                      item: item['item']?.toString() ?? '',
                      reason: item['reason']?.toString() ?? '',
                      accentColor: colors.info,
                      emoji: '🧵',
                    );
                  }
                  return _buildDetailedItemCard(
                    context,
                    item: item.toString(),
                    reason: '',
                    accentColor: colors.info,
                    emoji: '🧵',
                  );
                }).toList(),
              ),
            ),

          // 장소 (place 카테고리 선택 시만 표시) - 상세 카드
          if (showPlace && placesDetail.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '📍',
              title: '오늘 가면 좋은 장소',
              child: Column(
                children: placesDetail.map((item) {
                  if (item is Map) {
                    return _buildDetailedItemCard(
                      context,
                      item: item['place']?.toString() ??
                          item['item']?.toString() ??
                          '',
                      reason: item['reason']?.toString() ?? '',
                      timing: item['timing']?.toString(),
                      accentColor: colors.success,
                      emoji: '📍',
                    );
                  }
                  return _buildDetailedItemCard(
                    context,
                    item: item.toString(),
                    reason: '',
                    accentColor: colors.success,
                    emoji: '📍',
                  );
                }).toList(),
              ),
            ),

          // 인간관계 (showAll일 때만 표시)
          if (showAll && relationships.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '👥',
              title: '궁합 좋은 사람',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: relationships
                    .map((rel) => Padding(
                          padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style: typography.bodyMedium
                                      .copyWith(color: colors.textSecondary)),
                              Expanded(
                                child: Text(
                                  rel.toString(),
                                  style: typography.bodySmall
                                      .copyWith(color: colors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          // 종합 조언
          if (advice.isNotEmpty)
            _buildLuckySection(
              context,
              icon: '💡',
              title: '오늘의 추천',
              child: Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                  border:
                      Border.all(color: colors.accent.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        advice,
                        style: typography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 오늘의 핵심 팁
          if (todayTip.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: DSSpacing.md),
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.accent.withValues(alpha: 0.1),
                    colors.accentSecondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      todayTip,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 행운 아이템 섹션 빌더
  Widget _buildLuckySection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }

  /// 마크다운 **bold** 제거
  String _stripMarkdown(String text) {
    return text.replaceAll('**', '');
  }

  /// 상세 아이템 카드 (아이템명 + 이유 + 시간대)
  Widget _buildDetailedItemCard(
    BuildContext context, {
    required String item,
    required String reason,
    String? timing,
    required Color accentColor,
    required String emoji,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    // 마크다운 **bold** 제거
    final cleanItem = _stripMarkdown(item);
    final cleanReason = _stripMarkdown(reason);
    final cleanTiming = timing != null ? _stripMarkdown(timing) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  cleanItem,
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (cleanTiming != null && cleanTiming.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Text(
                    cleanTiming,
                    style: typography.labelSmall.copyWith(color: accentColor),
                  ),
                ),
            ],
          ),
          if (cleanReason.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              cleanReason,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 오행별 색상 반환
  Color _getLuckyElementColor(String element) {
    switch (element) {
      case '목':
        return DSColors.success;
      case '화':
        return DSColors.error;
      case '토':
        return DSColors.warning;
      case '금':
        return DSColors.textSecondary;
      case '수':
        return DSColors.info;
      default:
        return DSColors.textSecondary;
    }
  }

  /// 오행별 이모지 반환
  String _getLuckyElementEmoji(String element) {
    switch (element) {
      case '목':
        return '🌳';
      case '화':
        return '🔥';
      case '토':
        return '🏔️';
      case '금':
        return '⚱️';
      case '수':
        return '💧';
      default:
        return '✨';
    }
  }

  // ============================================================
  // 연간 운세 (new_year, yearly) 전용 섹션들
  // ============================================================

  /// 1. 목표별 맞춤 분석 섹션
  Widget _buildGoalFortuneSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final goalFortune = metadata['goalFortune'] as Map<String, dynamic>?;

    if (goalFortune == null) return const SizedBox.shrink();

    final goalId = goalFortune['goalId'] as String? ?? '';
    final goalLabel = goalFortune['goalLabel'] as String? ?? '새해 목표';
    final emoji = goalFortune['emoji'] as String? ?? '🎯';
    final title = goalFortune['title'] as String? ?? '$goalLabel 분석';
    final prediction = goalFortune['prediction'] as String? ?? '';
    final deepAnalysis = goalFortune['deepAnalysis'] as String? ?? '';
    final bestMonths =
        (goalFortune['bestMonths'] as List<dynamic>?)?.cast<String>() ?? [];
    final cautionMonths =
        (goalFortune['cautionMonths'] as List<dynamic>?)?.cast<String>() ?? [];
    final successFactors =
        (goalFortune['successFactors'] as List<dynamic>?)?.cast<String>() ?? [];
    final actionItems =
        (goalFortune['actionItems'] as List<dynamic>?)?.cast<String>() ?? [];
    final riskAnalysis = goalFortune['riskAnalysis'] as String? ?? '';
    final travelRecommendations =
        goalFortune['travelRecommendations'] as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 예측
          if (prediction.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                prediction,
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),

          // 심화 분석
          if (deepAnalysis.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              '💡 심화 분석',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              deepAnalysis,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          // 좋은 달 / 주의할 달
          if (bestMonths.isNotEmpty || cautionMonths.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Row(
              children: [
                if (bestMonths.isNotEmpty)
                  Expanded(
                    child: _buildMonthBadges(
                        context, '✨ 좋은 달', bestMonths, colors.success),
                  ),
                if (bestMonths.isNotEmpty && cautionMonths.isNotEmpty)
                  const SizedBox(width: DSSpacing.sm),
                if (cautionMonths.isNotEmpty)
                  Expanded(
                    child: _buildMonthBadges(
                        context, '⚠️ 주의할 달', cautionMonths, colors.warning),
                  ),
              ],
            ),
          ],

          // 성공 요소
          if (successFactors.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              '🌟 성공 요소',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: successFactors
                  .map((factor) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.1),
                          borderRadius: DSRadius.lgBorder,
                        ),
                        child: Text(
                          factor,
                          style: typography.labelSmall
                              .copyWith(color: colors.success),
                        ),
                      ))
                  .toList(),
            ),
          ],

          // 행동 항목
          if (actionItems.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              '📋 추천 행동',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...actionItems.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}. ',
                        style: typography.bodySmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: typography.bodySmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // 주의 사항
          if (riskAnalysis.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      riskAnalysis,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 여행 추천지 (travel 목표 전용)
          if (goalId == 'travel' && travelRecommendations != null) ...[
            const SizedBox(height: DSSpacing.lg),
            _buildTravelRecommendationsSection(context, travelRecommendations),
          ],
        ],
      ),
    );
  }

  /// 여행 추천지 섹션 (travel 목표 전용)
  Widget _buildTravelRecommendationsSection(
    BuildContext context,
    Map<String, dynamic> travelRecommendations,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    final domestic = (travelRecommendations['domestic'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final international =
        (travelRecommendations['international'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
    final travelStyle = travelRecommendations['travelStyle'] as String? ?? '';
    final travelTips = (travelRecommendations['travelTips'] as List<dynamic>?)
            ?.cast<String>() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: DSSpacing.sm),
            Text(
              '추천 여행지',
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),

        // 여행 스타일
        if (travelStyle.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    '당신에게 어울리는 여행 스타일: $travelStyle',
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],

        // 국내 여행지
        if (domestic.isNotEmpty) ...[
          Row(
            children: [
              const Text('🇰🇷', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '국내 추천 여행지',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...domestic.map((dest) => _buildDestinationCard(
                context,
                city: dest['city'] as String? ?? '',
                reason: dest['reason'] as String? ?? '',
                bestSeason: dest['bestSeason'] as String? ?? '',
              )),
          const SizedBox(height: DSSpacing.md),
        ],

        // 해외 여행지
        if (international.isNotEmpty) ...[
          Row(
            children: [
              const Text('🌍', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '해외 추천 여행지',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...international.map((dest) => _buildDestinationCard(
                context,
                city: dest['city'] as String? ?? '',
                reason: dest['reason'] as String? ?? '',
                bestSeason: dest['bestSeason'] as String? ?? '',
              )),
          const SizedBox(height: DSSpacing.md),
        ],

        // 여행 팁
        if (travelTips.isNotEmpty) ...[
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '여행 팁',
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          ...travelTips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style:
                          typography.bodySmall.copyWith(color: colors.accent),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  /// 여행지 카드
  Widget _buildDestinationCard(
    BuildContext context, {
    required String city,
    required String reason,
    required String bestSeason,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  city,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (bestSeason.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bestSeason,
                    style: typography.labelSmall.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              reason,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 월 배지 빌더 헬퍼
  Widget _buildMonthBadges(
      BuildContext context, String title, List<String> months, Color color) {
    final typography = context.typography;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: typography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: months
              .map((month) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      month,
                      style: typography.labelSmall
                          .copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  /// 2. 오행 분석 섹션
  Widget _buildSajuAnalysisSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final sajuAnalysis = metadata['sajuAnalysis'] as Map<String, dynamic>?;

    if (sajuAnalysis == null) return const SizedBox.shrink();

    final dominantElement = sajuAnalysis['dominantElement'] as String? ?? '';
    final yearElement = sajuAnalysis['yearElement'] as String? ?? '';
    final compatibility = sajuAnalysis['compatibility'] as String? ?? '보통';
    final compatibilityReason =
        sajuAnalysis['compatibilityReason'] as String? ?? '';
    final elementalAdvice = sajuAnalysis['elementalAdvice'] as String? ?? '';
    final balanceElements =
        (sajuAnalysis['balanceElements'] as List<dynamic>?)?.cast<String>() ??
            [];
    final strengthenTips =
        (sajuAnalysis['strengthenTips'] as List<dynamic>?)?.cast<String>() ??
            [];

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text('☯️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '오행 분석',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 오행 궁합 카드
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getLuckyElementColor(dominantElement).withValues(alpha: 0.1),
                  _getLuckyElementColor(yearElement).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildElementCard(context, '나의 오행', dominantElement),
                    Text(
                      _getCompatibilityEmoji(compatibility),
                      style: const TextStyle(fontSize: 32),
                    ),
                    _buildElementCard(context, '올해 오행', yearElement),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCompatibilityColor(context, compatibility)
                        .withValues(alpha: 0.2),
                    borderRadius: DSRadius.xlBorder,
                  ),
                  child: Text(
                    '궁합: $compatibility',
                    style: typography.labelMedium.copyWith(
                      color: _getCompatibilityColor(context, compatibility),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 궁합 설명
          if (compatibilityReason.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              compatibilityReason,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          // 오행 조언
          if (elementalAdvice.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      elementalAdvice,
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 보완 오행 & 강화 팁
          if (balanceElements.isNotEmpty || strengthenTips.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (balanceElements.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚖️ 보완 필요',
                          style: typography.labelSmall
                              .copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: DSSpacing.xs),
                        Wrap(
                          spacing: 4,
                          children: balanceElements
                              .map((e) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getLuckyElementColor(e)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_getLuckyElementEmoji(e)} $e',
                                      style: typography.labelSmall.copyWith(
                                        color: _getLuckyElementColor(e),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (strengthenTips.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.sm),
              ...strengthenTips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            tip,
                            style: typography.bodySmall
                                .copyWith(color: colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  /// 오행 카드 빌더
  Widget _buildElementCard(BuildContext context, String label, String element) {
    final typography = context.typography;
    final colors = context.colors;
    final elementColor = _getLuckyElementColor(element);

    return Column(
      children: [
        Text(
          label,
          style: typography.labelSmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: DSSpacing.xs),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: elementColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: elementColor, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getLuckyElementEmoji(element),
                    style: const TextStyle(fontSize: 20)),
                Text(
                  element,
                  style: typography.labelSmall.copyWith(
                    color: elementColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCompatibilityEmoji(String compatibility) {
    switch (compatibility) {
      case '높음':
        return '💫';
      case '보통':
        return '🔄';
      case '주의':
        return '⚡';
      default:
        return '🔄';
    }
  }

  /// 궁합 수준별 색상 반환 (디자인 시스템 통합)
  Color _getCompatibilityColor(BuildContext context, String compatibility) {
    final colors = context.colors;
    switch (compatibility) {
      case '높음':
        return colors.success;
      case '보통':
        return colors.info;
      case '주의':
        return colors.warning;
      default:
        return colors.textTertiary;
    }
  }

  /// 3. 월별 하이라이트 섹션
  Widget _buildMonthlyHighlightsSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final monthlyHighlights = (metadata['monthlyHighlights'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    if (monthlyHighlights.isEmpty) return const SizedBox.shrink();

    final currentMonth = DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '월별 하이라이트',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '12개월 전체 보기',
            style: typography.labelSmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: DSSpacing.md),

          // 월별 카드 가로 스크롤
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: monthlyHighlights.length,
              separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
              itemBuilder: (context, index) {
                final monthData = monthlyHighlights[index];
                final monthNum = index + 1;
                final isCurrentMonth = monthNum == currentMonth;

                return _buildMonthCard(
                  context,
                  monthData: monthData,
                  monthNum: monthNum,
                  isCurrentMonth: isCurrentMonth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(
    BuildContext context, {
    required Map<String, dynamic> monthData,
    required int monthNum,
    required bool isCurrentMonth,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final theme = monthData['theme'] as String? ?? '';
    final score = (monthData['score'] as num?)?.toInt() ?? 70;
    final advice = monthData['advice'] as String? ?? '';
    final energyLevel = monthData['energyLevel'] as String? ?? 'Medium';

    final energyColor = _getEnergyColor(context, energyLevel);

    return GestureDetector(
      onTap: () {
        MonthHighlightDetailBottomSheet.show(
          context,
          monthData: monthData,
          monthNum: monthNum,
          isCurrentMonth: isCurrentMonth,
        );
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: isCurrentMonth
              ? colors.accent.withValues(alpha: 0.1)
              : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: isCurrentMonth
                ? colors.accent
                : colors.textPrimary.withValues(alpha: 0.1),
            width: isCurrentMonth ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$monthNum월',
                  style: typography.labelMedium.copyWith(
                    color: isCurrentMonth ? colors.accent : colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: energyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score점',
                    style: typography.labelSmall.copyWith(
                      color: energyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              theme,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: DSSpacing.xs),
            Expanded(
              child: Text(
                advice,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 에너지 수준별 색상 반환 (디자인 시스템 통합)
  Color _getEnergyColor(BuildContext context, String energyLevel) {
    final colors = context.colors;
    switch (energyLevel) {
      case 'High':
        return colors.success;
      case 'Medium':
        return colors.info;
      case 'Low':
        return colors.warning;
      default:
        return colors.textTertiary;
    }
  }

  /// 4. 행동 계획 섹션
  Widget _buildActionPlanSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final actionPlan = metadata['actionPlan'] as Map<String, dynamic>?;

    if (actionPlan == null) return const SizedBox.shrink();

    final immediate =
        (actionPlan['immediate'] as List<dynamic>?)?.cast<String>() ?? [];
    final shortTerm =
        (actionPlan['shortTerm'] as List<dynamic>?)?.cast<String>() ?? [];
    final longTerm =
        (actionPlan['longTerm'] as List<dynamic>?)?.cast<String>() ?? [];

    if (immediate.isEmpty && shortTerm.isEmpty && longTerm.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '행동 계획',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          if (immediate.isNotEmpty)
            _buildActionPlanCategory(
                context, '⚡ 지금 바로 (1-2주)', immediate, colors.error),
          if (shortTerm.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildActionPlanCategory(
                context, '📆 단기 (1-3개월)', shortTerm, colors.warning),
          ],
          if (longTerm.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildActionPlanCategory(
                context, '🎯 장기 (6-12개월)', longTerm, colors.success),
          ],
        ],
      ),
    );
  }

  Widget _buildActionPlanCategory(
      BuildContext context, String title, List<String> items, Color color) {
    final typography = context.typography;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: typography.bodySmall.copyWith(color: color)),
                    Expanded(
                      child: Text(
                        item,
                        style: typography.bodySmall
                            .copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 5. 특별 메시지 섹션
  Widget _buildSpecialMessageSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final specialMessage = metadata['specialMessage'] as String?;

    if (specialMessage == null || specialMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accent.withValues(alpha: 0.1),
              colors.accentSecondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💌', style: TextStyle(fontSize: 24)),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '특별 메시지',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              specialMessage,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 재물운(Wealth) 전용 섹션 빌더들
  // ============================================================

  /// 관심 분야 라벨 맵
  static const Map<String, String> _interestLabels = {
    'realestate': '🏠 부동산',
    'stock': '📈 주식',
    'crypto': '₿ 가상화폐',
    'side': '💼 부업/N잡',
    'saving': '💰 저축',
    'business': '🏢 사업/창업',
  };

  /// 1. 선택한 관심 분야 태그 표시
  Widget _buildWealthInterestsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final surveyData = metadata['surveyData'] as Map<String, dynamic>?;
    final interests = (surveyData?['interests'] as List?)?.cast<String>() ?? [];

    if (interests.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 분석 항목',
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final label = _interestLabels[interest] ?? interest;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: DSRadius.lgBorder,
                  border:
                      Border.all(color: colors.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  label,
                  style: typography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 2. 목표 맞춤 조언 섹션
  Widget _buildWealthGoalAdviceSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final goalAdvice = metadata['goalAdvice'] as Map<String, dynamic>?;

    if (goalAdvice == null) return const SizedBox.shrink();

    final primaryGoal = goalAdvice['primaryGoal'] as String? ?? '재물 목표';
    final timeline = goalAdvice['timeline'] as String? ?? '';
    final strategy = goalAdvice['strategy'] as String? ?? '';
    final monthlyTarget = goalAdvice['monthlyTarget'] as String? ?? '';
    final luckyTiming = goalAdvice['luckyTiming'] as String? ?? '';
    final cautionPeriod = goalAdvice['cautionPeriod'] as String? ?? '';
    final sajuAnalysis = goalAdvice['sajuAnalysis'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '$primaryGoal 달성 전략',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 전략
          if (strategy.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                strategy
                    .replaceAllMapped(
                      RegExp(r'(\d+)\.\s'),
                      (match) => '\n${match.group(1)}. ',
                    )
                    .trim(),
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),

          // 타임라인 & 월별 목표
          if (timeline.isNotEmpty || monthlyTarget.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Row(
              children: [
                if (timeline.isNotEmpty)
                  Expanded(
                    child: _buildWealthInfoCard(
                      context,
                      '📅 권장 기간',
                      timeline,
                      colors.info,
                    ),
                  ),
                if (timeline.isNotEmpty && monthlyTarget.isNotEmpty)
                  const SizedBox(width: DSSpacing.sm),
                if (monthlyTarget.isNotEmpty)
                  Expanded(
                    child: _buildWealthInfoCard(
                      context,
                      '💵 월별 목표',
                      monthlyTarget,
                      colors.success,
                    ),
                  ),
              ],
            ),
          ],

          // 유리한 시기 / 주의 시기
          if (luckyTiming.isNotEmpty || cautionPeriod.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Row(
              children: [
                if (luckyTiming.isNotEmpty)
                  Expanded(
                    child: _buildWealthInfoCard(
                      context,
                      '✨ 유리한 시기',
                      luckyTiming,
                      colors.success,
                    ),
                  ),
                if (luckyTiming.isNotEmpty && cautionPeriod.isNotEmpty)
                  const SizedBox(width: DSSpacing.sm),
                if (cautionPeriod.isNotEmpty)
                  Expanded(
                    child: _buildWealthInfoCard(
                      context,
                      '⚠️ 주의 시기',
                      cautionPeriod,
                      colors.warning,
                    ),
                  ),
              ],
            ),
          ],

          // 사주 분석
          if (sajuAnalysis.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      sajuAnalysis,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 3. 고민 해결책 섹션
  Widget _buildWealthConcernSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final concernResolution =
        metadata['concernResolution'] as Map<String, dynamic>?;

    if (concernResolution == null) return const SizedBox.shrink();

    final primaryConcern =
        concernResolution['primaryConcern'] as String? ?? '고민';
    final analysis = concernResolution['analysis'] as String? ?? '';
    // solution은 String 또는 List일 수 있음
    final rawSolution = concernResolution['solution'];
    final String solution;
    if (rawSolution is List) {
      solution = rawSolution.map((e) => '• $e').join('\n');
    } else if (rawSolution is String) {
      solution = rawSolution;
    } else {
      solution = '';
    }
    final mindset = concernResolution['mindset'] as String? ?? '';
    final sajuPerspective =
        concernResolution['sajuPerspective'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '$primaryConcern 해결책',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 분석
          if (analysis.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border:
                    Border.all(color: colors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                analysis,
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),

          // 해결책
          if (solution.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              '✅ 해결 방안',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              solution,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ],

          // 마음가짐
          if (mindset.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧘', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      mindset,
                      style: typography.bodySmall.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 사주 관점
          if (sajuPerspective.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '🔮 $sajuPerspective',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 4. 투자 인사이트 섹션 (관심 분야별)
  Widget _buildWealthInvestmentInsightsSection(
      BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final investmentInsights =
        metadata['investmentInsights'] as Map<String, dynamic>?;
    final surveyData = metadata['surveyData'] as Map<String, dynamic>?;
    final interests = (surveyData?['interests'] as List?)?.cast<String>() ?? [];

    if (investmentInsights == null || interests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '분야별 인사이트',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          ...interests.map((interest) {
            final insightData =
                investmentInsights[interest] as Map<String, dynamic>?;
            if (insightData == null) return const SizedBox.shrink();
            return _buildWealthInsightCard(context, interest, insightData);
          }),
        ],
      ),
    );
  }

  /// 투자 인사이트 개별 카드
  Widget _buildWealthInsightCard(
      BuildContext context, String interest, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    final label = _interestLabels[interest] ?? interest;
    final score = data['score'] as int? ?? 0;
    final analysis = data['analysis'] as String? ?? '';

    // 분야별 추가 정보
    final additionalInfo = <String, String>{};

    // List 또는 String을 String으로 변환하는 헬퍼
    String toStringValue(dynamic value) {
      if (value is List) {
        return value.join(', ');
      } else if (value is String) {
        return value;
      }
      return value?.toString() ?? '';
    }

    if (interest == 'realestate') {
      if (data['recommendedType'] != null) {
        additionalInfo['추천 유형'] = toStringValue(data['recommendedType']);
      }
      if (data['timing'] != null) {
        additionalInfo['타이밍'] = toStringValue(data['timing']);
      }
      if (data['direction'] != null) {
        additionalInfo['추천 방향'] = toStringValue(data['direction']);
      }
    } else if (interest == 'side') {
      if (data['recommendedAreas'] != null) {
        additionalInfo['추천 분야'] = toStringValue(data['recommendedAreas']);
      }
      if (data['incomeExpectation'] != null) {
        additionalInfo['예상 수입'] = toStringValue(data['incomeExpectation']);
      }
      if (data['startTiming'] != null) {
        additionalInfo['시작 시기'] = toStringValue(data['startTiming']);
      }
    } else if (interest == 'stock') {
      if (data['recommendedSectors'] != null) {
        additionalInfo['추천 섹터'] = toStringValue(data['recommendedSectors']);
      }
      if (data['timing'] != null) {
        additionalInfo['매매 타이밍'] = toStringValue(data['timing']);
      }
      if (data['riskLevel'] != null) {
        additionalInfo['리스크'] = toStringValue(data['riskLevel']);
      }
    } else if (interest == 'crypto') {
      if (data['marketOutlook'] != null) {
        additionalInfo['시장 전망'] = toStringValue(data['marketOutlook']);
      }
      if (data['timing'] != null) {
        additionalInfo['진입 시기'] = toStringValue(data['timing']);
      }
    } else if (interest == 'saving') {
      if (data['recommendedProducts'] != null) {
        additionalInfo['추천 상품'] = toStringValue(data['recommendedProducts']);
      }
      if (data['targetRate'] != null) {
        additionalInfo['목표 금리'] = toStringValue(data['targetRate']);
      }
    } else if (interest == 'business') {
      if (data['recommendedFields'] != null) {
        additionalInfo['추천 분야'] = toStringValue(data['recommendedFields']);
      }
      if (data['timing'] != null) {
        additionalInfo['시작 시기'] = toStringValue(data['timing']);
      }
      if (data['partnerAdvice'] != null) {
        additionalInfo['파트너'] = toStringValue(data['partnerAdvice']);
      }
    }

    final caution = data['caution'] as String? ?? '';
    final sajuMatch = data['sajuMatch'] as String? ?? '';

    // 점수 색상
    final scoreColor = score >= 80
        ? colors.success
        : score >= 60
            ? colors.info
            : colors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 라벨 + 점수
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typography.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score점',
                  style: typography.labelMedium.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // 분석
          if (analysis.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              analysis,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ],

          // 추가 정보
          if (additionalInfo.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: DSSpacing.sm),
            ...additionalInfo.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: typography.labelSmall.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: typography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // 주의사항
          if (caution.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      caution,
                      style: typography.labelSmall.copyWith(
                        color: colors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 사주 궁합
          if (sajuMatch.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              '🔮 $sajuMatch',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 5. 월별 흐름 섹션
  Widget _buildWealthMonthlyFlowSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final monthlyFlow = metadata['monthlyFlow'] as List<dynamic>?;

    if (monthlyFlow == null || monthlyFlow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '월별 재물 흐름',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: monthlyFlow.length,
              itemBuilder: (context, index) {
                final monthData = monthlyFlow[index] as Map<String, dynamic>;
                final month = monthData['month'] as String? ?? '${index + 1}월';
                final score = monthData['score'] as int? ?? 50;
                final trend = monthData['trend'] as String? ?? '';
                final tip = monthData['tip'] as String? ?? '';

                return _buildMonthFlowCard(context, month, score, trend, tip);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 월별 흐름 개별 카드
  Widget _buildMonthFlowCard(
      BuildContext context, String month, int score, String trend, String tip) {
    final colors = context.colors;
    final typography = context.typography;

    final trendEmoji = trend == 'up'
        ? '📈'
        : trend == 'down'
            ? '📉'
            : '➡️';
    final scoreColor = score >= 80
        ? colors.success
        : score >= 60
            ? colors.info
            : score >= 40
                ? colors.warning
                : colors.error;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: typography.labelMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(trendEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: DSSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$score',
              style: typography.labelSmall.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (tip.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              tip,
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 6. 실천 항목 섹션
  Widget _buildWealthActionItemsSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final actionItems =
        (metadata['actionItems'] as List<dynamic>?)?.cast<String>() ?? [];

    if (actionItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '이번 달 실천 항목',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          ...actionItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.accent.withValues(alpha: 0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: typography.labelSmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 재물운 정보 카드 빌더
  Widget _buildWealthInfoCard(
      BuildContext context, String title, String content, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.labelSmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            content,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 시험운 전용 섹션들 (Exam Fortune) - 2025 리뉴얼
  // ============================================================

  /// 수능 전용: 시그널 헤더
  Widget _buildCsatSignalHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    final examScore = metadata['score'] as int? ?? fortune.overallScore ?? 75;
    final statusMessage = metadata['status_message'] as String? ??
        metadata['pass_possibility'] as String? ??
        '실전 감각이 올라오는 시기입니다.';
    final hashtags = (metadata['hashtags'] as List?)?.cast<String>() ??
        ['#수능실전감각', '#실수관리', '#루틴고정'];
    final examTypeLabel = metadata['exam_type'] as String? ?? '수능';

    int daysRemaining = 0;
    final examDateStr = metadata['exam_date'] as String?;
    final examDate = _resolveExamDate(examTypeLabel, examDateStr);
    if (examDate != null) {
      final today = DateTime.now();
      daysRemaining = examDate
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
    }

    String ddayText;
    Color ddayColor;
    if (daysRemaining > 0) {
      ddayText = 'D-$daysRemaining';
      ddayColor = daysRemaining <= 7 ? colors.error : colors.warning;
    } else if (daysRemaining == 0) {
      ddayText = 'D-Day';
      ddayColor = colors.error;
    } else {
      ddayText = 'D+${daysRemaining.abs()}';
      ddayColor = colors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accent.withValues(alpha: 0.18),
              colors.accentSecondary.withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '🧭 수능 실전 리포트',
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ddayColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                    border: Border.all(color: ddayColor),
                  ),
                  child: Text(
                    ddayText,
                    style: typography.labelLarge.copyWith(
                      color: ddayColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  examTypeLabel,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.lg),
            Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 6,
                          backgroundColor: colors.divider,
                          valueColor: AlwaysStoppedAnimation(colors.divider),
                        ),
                      ),
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: examScore / 100,
                          strokeWidth: 6,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            examScore >= 80
                                ? colors.success
                                : examScore >= 60
                                    ? colors.warning
                                    : colors.error,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$examScore',
                            style: typography.headingSmall.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/100',
                            style: typography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: hashtags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.full),
                        ),
                        child: Text(
                          tag,
                          style: typography.labelSmall.copyWith(
                            color: colors.accent,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 수능 전용: 과목 집중 가이드
  Widget _buildCsatFocusSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final focusList = (metadata['csat_focus'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    if (focusList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📌', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '과목 집중 포인트',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...focusList.map((item) {
            final subject = item['subject'] as String? ?? '과목';
            final focus = item['focus'] as String? ?? '';
            final tip = item['tip'] as String? ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.sm, vertical: DSSpacing.xxs),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Text(
                      subject,
                      style: typography.labelMedium.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          focus,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tip.isNotEmpty) ...[
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            tip,
                            style: typography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 수능 전용: D-day 로드맵
  Widget _buildCsatRoadmapSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final roadmap = (metadata['csat_roadmap'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    if (roadmap.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                'D-day 로드맵',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...roadmap.map((item) {
            final phase = item['phase'] as String? ?? '';
            final action = item['action'] as String? ?? '';
            final caution = item['caution'] as String? ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accentSecondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                    color: colors.accentSecondary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase,
                    style: typography.labelMedium.copyWith(
                      color: colors.accentSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    action,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (caution.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xxs),
                    Text(
                      caution,
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 수능 전용: 당일 루틴
  Widget _buildCsatRoutineSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final routine =
        (metadata['csat_routine'] as List<dynamic>?)?.cast<String>() ?? [];

    if (routine.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '당일 루틴',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...routine.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final text = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: typography.labelSmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      text,
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 수능 전용: 체크리스트
  Widget _buildCsatChecklistSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final checklist =
        (metadata['csat_checklist'] as List<dynamic>?)?.cast<String>() ?? [];

    if (checklist.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '수능 체크리스트',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: checklist.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.accentSecondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                  border: Border.all(
                      color: colors.accentSecondary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  item,
                  style: typography.labelSmall.copyWith(
                    color: colors.accentSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 시험운: 합격 시그널 헤더 (원형 게이지 + 해시태그)
  Widget _buildExamSignalHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용
    final examScore = metadata['score'] as int? ?? fortune.overallScore ?? 75;
    final statusMessage = metadata['status_message'] as String? ??
        metadata['pass_possibility'] as String? ??
        '합격 가능성이 좋습니다!';
    final examTypeLabel = metadata['exam_type'] as String? ?? '시험';
    final hashtags = (metadata['hashtags'] as List?)?.cast<String>() ??
        ['#집중력_치트키', '#정답만_보이는_눈', '#합격기원'];

    // D-day 계산
    int daysRemaining = 0;
    final examDateStr = metadata['exam_date'] as String?;
    final examDate = _resolveExamDate(examTypeLabel, examDateStr);
    if (examDate != null) {
      final today = DateTime.now();
      daysRemaining = examDate
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
    }

    String ddayText;
    Color ddayColor;
    if (daysRemaining > 0) {
      ddayText = 'D-$daysRemaining';
      ddayColor = daysRemaining <= 7 ? colors.error : colors.warning;
    } else if (daysRemaining == 0) {
      ddayText = 'D-Day';
      ddayColor = colors.error;
    } else {
      ddayText = 'D+${daysRemaining.abs()}';
      ddayColor = colors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accent.withValues(alpha: 0.15),
              colors.accentSecondary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // 헤더: 🐯 오늘의 시험운 리포트
            Text(
              '🐯 오늘의 시험운 리포트',
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DSSpacing.md),

            // D-day 배지 + 시험 종류
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ddayColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                    border: Border.all(color: ddayColor),
                  ),
                  child: Text(
                    ddayText,
                    style: typography.labelLarge.copyWith(
                      color: ddayColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  examTypeLabel,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.lg),

            // 합격 시그널 원형 게이지
            Row(
              children: [
                // 원형 게이지
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 8,
                          backgroundColor: colors.divider,
                          valueColor: AlwaysStoppedAnimation(colors.divider),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: examScore / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            examScore >= 80
                                ? colors.success
                                : examScore >= 60
                                    ? colors.warning
                                    : colors.error,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$examScore',
                            style: typography.headingMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/100',
                            style: typography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.md),

                // 상태 메시지
                Expanded(
                  child: Text(
                    statusMessage,
                    style: typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 해시태그
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: hashtags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.full),
                        ),
                        child: Text(
                          tag,
                          style: typography.labelSmall.copyWith(
                            color: colors.accent,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 시험운: 시험 스탯 (프로그레스 바 3개)
  Widget _buildExamStatsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // exam_stats 객체에서 데이터 추출
    final examStats = metadata['exam_stats'] as Map<String, dynamic>? ?? {};
    final answerIntuition = examStats['answer_intuition'] as int? ?? 85;
    final answerIntuitionDesc = examStats['answer_intuition_desc'] as String? ??
        '모르는 문제도 정답으로 유도하는 운의 흐름';
    final mentalDefense = examStats['mental_defense'] as int? ?? 80;
    final mentalDefenseDesc =
        examStats['mental_defense_desc'] as String? ?? '시험장의 소음과 긴장감을 차단하는 집중력';
    final memoryAcceleration =
        examStats['memory_acceleration'] as String? ?? 'UP';
    final memoryAccelerationDesc =
        examStats['memory_acceleration_desc'] as String? ??
            '지금 보는 오답 노트가 머릿속에 바로 각인되는 상태';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Text('📊', style: typography.headingSmall),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 시험 스탯',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 정답 직관력
            _buildStatProgressBar(
              context,
              label: '정답 직관력',
              value: answerIntuition,
              description: answerIntuitionDesc,
              color: colors.info,
            ),
            const SizedBox(height: DSSpacing.md),

            // 멘탈 방어력
            _buildStatProgressBar(
              context,
              label: '멘탈 방어력',
              value: mentalDefense,
              description: mentalDefenseDesc,
              color: colors.success,
            ),
            const SizedBox(height: DSSpacing.md),

            // 암기 가속도 (UP/DOWN/STABLE)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '암기 가속도',
                            style: typography.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm,
                              vertical: DSSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: memoryAcceleration == 'UP'
                                  ? colors.success.withValues(alpha: 0.2)
                                  : memoryAcceleration == 'DOWN'
                                      ? colors.error.withValues(alpha: 0.2)
                                      : colors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(DSRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  memoryAcceleration == 'UP'
                                      ? Icons.arrow_upward
                                      : memoryAcceleration == 'DOWN'
                                          ? Icons.arrow_downward
                                          : Icons.remove,
                                  size: 16,
                                  color: memoryAcceleration == 'UP'
                                      ? colors.success
                                      : memoryAcceleration == 'DOWN'
                                          ? colors.error
                                          : colors.warning,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  memoryAcceleration,
                                  style: typography.labelMedium.copyWith(
                                    color: memoryAcceleration == 'UP'
                                        ? colors.success
                                        : memoryAcceleration == 'DOWN'
                                            ? colors.error
                                            : colors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        memoryAccelerationDesc,
                        style: typography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 시험 스탯용 프로그레스 바 위젯
  Widget _buildStatProgressBar(
    BuildContext context, {
    required String label,
    required int value,
    required String description,
    required Color color,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: typography.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(DSRadius.sm),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: colors.divider,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          description,
          style: typography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 시험운: 오늘의 1점 전략
  Widget _buildTodayStrategySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // today_strategy 객체에서 데이터 추출
    final todayStrategy =
        metadata['today_strategy'] as Map<String, dynamic>? ?? {};
    final mainAction = todayStrategy['main_action'] as String? ??
        '가장 헷갈렸던 오답 노트를 딱 10분만 다시 훑어보세요';
    final actionReason =
        todayStrategy['action_reason'] as String? ?? '그 10분이 시험장에서 1점을 결정합니다';
    final luckyFood = todayStrategy['lucky_food'] as String? ?? '다크 초콜릿 한 조각';
    final luckyFoodReason =
        todayStrategy['lucky_food_reason'] as String? ?? '두뇌 회전을 돕는 오늘의 행운 아이템';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Text('🎯', style: typography.headingSmall),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 1점 추가 전략',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 핵심 액션
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('💡', style: typography.bodyLarge),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '핵심 액션',
                        style: typography.labelMedium.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    mainAction,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    '→ $actionReason',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.sm),

            // 럭키 푸드
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🍫', style: typography.bodyLarge),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '럭키 푸드',
                        style: typography.labelMedium.copyWith(
                          color: colors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    luckyFood,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    luckyFoodReason,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 시험운: 영물의 기개 (대형 이모지 중심)
  Widget _buildSpiritAnimalSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // spirit_animal 객체에서 데이터 추출
    final spiritAnimal =
        metadata['spirit_animal'] as Map<String, dynamic>? ?? {};
    final animal = spiritAnimal['animal'] as String? ?? '호랑이';
    final message = spiritAnimal['message'] as String? ?? '날카로운 통찰력이 깃듭니다';
    final direction = spiritAnimal['direction'] as String? ?? '남';

    // 영물별 이모지 매핑
    final animalEmoji = {
          '호랑이': '🐅',
          '용': '🐉',
          '봉황': '🦅',
          '거북이': '🐢',
          '백호': '🐯',
        }[animal] ??
        '🐅';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.warning.withValues(alpha: 0.15),
              colors.warning.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // 헤더
            Text(
              '영물의 기개',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),

            // 대형 이모지 (64px)
            Text(
              animalEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: DSSpacing.xs),

            // 동물명
            Text(
              animal,
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),

            // 메시지
            Text(
              '"$message"',
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),

            // 행운의 방향 (컴팩트)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧭', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '$direction 방향',
                    style: typography.labelMedium.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 시험운: 행운 정보 5열 아이콘 그리드
  Widget _buildExamLuckyInfoSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용 (초단축 값)
    final luckyHours = metadata['lucky_hours'] as String? ?? '';
    final luckyColor = metadata['lucky_color'] as String? ?? '';
    final luckyItem = metadata['lucky_item'] as String? ?? '';
    final luckyFood = metadata['lucky_food'] as String? ?? '';
    final luckyDirection = metadata['lucky_direction'] as String? ?? '';

    // 아무 데이터도 없으면 표시하지 않음
    if (luckyHours.isEmpty && luckyColor.isEmpty) {
      return const SizedBox.shrink();
    }

    // 5열 아이콘 그리드 아이템 (아이콘 + 초단축 값)
    final items = [
      ('⏰', luckyHours),
      ('🎨', luckyColor),
      ('🍀', luckyItem),
      ('🍌', luckyFood),
      ('🧭', luckyDirection),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍀', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '시험 당일 행운 정보',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.where((item) => item.$2.isNotEmpty).map((item) {
              return _buildLuckyIconCell(context, item.$1, item.$2);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 행운 정보 아이콘 셀 (아이콘 + 값)
  Widget _buildLuckyIconCell(BuildContext context, String emoji, String value) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(color: colors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: DSSpacing.xs),
          Text(
            value,
            style: typography.labelSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 시험운: D-day 맞춤 조언
  Widget _buildExamDdayAdviceSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용: dday_advice (단일 문자열)
    final ddayAdviceStr = metadata['dday_advice'] as String? ?? '';
    final overallFortune = metadata['overall_fortune'] as String? ?? '';

    // 조언 목록 생성: dday_advice + overall_fortune
    final ddayAdvice = <String>[];
    if (ddayAdviceStr.isNotEmpty) ddayAdvice.add(ddayAdviceStr);
    if (overallFortune.isNotEmpty) ddayAdvice.add(overallFortune);

    if (ddayAdvice.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                'D-day 맞춤 조언',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...ddayAdvice.asMap().entries.map((entry) {
            final index = entry.key;
            final advice = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accentSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                    color: colors.accentSecondary.withValues(alpha: 0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.accentSecondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: typography.labelSmall.copyWith(
                          color: colors.accentSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      advice,
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 시험운: 멘탈 관리
  Widget _buildExamMentalCareSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용
    final positiveMessage = metadata['positive_message'] as String? ?? '';
    final strengths =
        (metadata['strengths'] as List<dynamic>?)?.cast<String>() ?? [];

    if (positiveMessage.isEmpty && strengths.isEmpty) {
      return const SizedBox.shrink();
    }

    final affirmation = positiveMessage; // positive_message를 affirmation으로 사용

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧘', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '멘탈 관리',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 긍정 확언 (강조)
          if (affirmation.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.1),
                    colors.accentSecondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    '"$affirmation"',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    '시험 전 마음속으로 되뇌어보세요',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: DSSpacing.sm),

          // 강점 리스트
          if (strengths.isNotEmpty) ...[
            Text(
              '💪 당신의 강점',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...strengths.asMap().entries.map((entry) {
              final index = entry.key;
              final strength = entry.value;
              const icons = ['⭐', '🌟', '✨', '💫', '🔥'];
              return _buildExamMentalTipCard(
                context,
                icons[index % icons.length],
                '강점 ${index + 1}',
                strength,
              );
            }),
          ],
        ],
      ),
    );
  }

  /// 시험운: 멘탈 팁 카드 빌더
  Widget _buildExamMentalTipCard(
      BuildContext context, String emoji, String title, String content) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  content,
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 관상 (Face Reading) 전용 섹션
  // ============================================================

  /// 관상 상세 분석 섹션 (오관, 삼정, 십이궁, 명궁, 동물상 등)
  Widget _buildFaceReadingDetailSection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;

    // V2 데이터 (배열 형식)
    final simplifiedOgwan = _faceReadingSimplifiedOgwan;
    final simplifiedSibigung = _faceReadingSimplifiedSibigung;
    final priorityInsights = _faceReadingPriorityInsights;
    final myeonggungPreview = _faceReadingMyeonggungPreview;
    final miganPreview = _faceReadingMiganPreview;
    final conditionPreview = _faceReadingConditionPreview;
    final eyePreview = _faceReadingEyePreview;
    final faceType = _faceReadingFaceType;
    final faceTypeElement = _faceReadingFaceTypeElement;
    final overallFortune = _faceReadingOverallFortune;
    final similarCelebrities = _faceReadingSimilarCelebrities;

    // Legacy 데이터 (객체 형식)
    final ogwan = _faceReadingOgwan;
    final samjeong = _faceReadingSamjeong;
    final sibigung = _faceReadingSibigung;
    final myeonggung = _faceReadingMyeonggung;
    final migan = _faceReadingMigan;
    final animalType = _faceReadingAnimalType;
    final summary = _faceReadingSummary;

    // V2 데이터 존재 여부
    final hasV2Data = simplifiedOgwan != null ||
        simplifiedSibigung != null ||
        priorityInsights != null ||
        myeonggungPreview != null;

    // 관상 테마 색상 - monochrome style
    final faceReadingAccent = DSColors.textPrimary;
    final faceReadingAccentLight = DSColors.info;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSSpacing.md),

          // ─────────────────────────────────────────────────────────────
          // V2 형식 렌더링 (우선)
          // ─────────────────────────────────────────────────────────────
          if (hasV2Data) ...[
            // 총운 (overall_fortune)
            if (overallFortune != null && overallFortune.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '🔮',
                title: '총운',
                accentColor: faceReadingAccent,
                child: Text(
                  overallFortune,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 얼굴형 + 오행
            if (faceType != null && faceType.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '👤',
                title: '얼굴형 분석',
                accentColor: faceReadingAccent,
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        faceReadingAccent.withValues(alpha: 0.1),
                        faceReadingAccentLight.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: DSRadius.mdBorder,
                    border: Border.all(
                      color: faceReadingAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getFaceTypeEmoji(faceType),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faceType,
                              style: typography.labelLarge.copyWith(
                                color: faceReadingAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (faceTypeElement != null) ...[
                              const SizedBox(height: DSSpacing.xxs),
                              Text(
                                '오행: $faceTypeElement',
                                style: typography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 핵심 인사이트 (priorityInsights)
            if (priorityInsights != null && priorityInsights.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '💡',
                title: '핵심 인사이트',
                accentColor: faceReadingAccent,
                child: _buildPriorityInsightsV2(
                    context, priorityInsights, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 오관 (V2 배열)
            if (simplifiedOgwan != null && simplifiedOgwan.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '👁️',
                title: '오관 (五官) 분석',
                accentColor: faceReadingAccent,
                child: _buildSimplifiedOgwanV2(
                    context, simplifiedOgwan, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 명궁 프리뷰
            if (myeonggungPreview != null) ...[
              _buildFaceReadingSection(
                context,
                icon: '✨',
                title: '명궁 분석',
                accentColor: faceReadingAccent,
                child: _buildPreviewCardV2(
                    context, myeonggungPreview, '명궁', faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 미간 프리뷰
            if (miganPreview != null) ...[
              _buildFaceReadingSection(
                context,
                icon: '🌟',
                title: '미간 분석',
                accentColor: faceReadingAccent,
                child: _buildPreviewCardV2(
                    context, miganPreview, '미간', faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 눈 프리뷰
            if (eyePreview != null) ...[
              _buildFaceReadingSection(
                context,
                icon: '👀',
                title: '눈 분석',
                accentColor: faceReadingAccent,
                child:
                    _buildEyePreviewV2(context, eyePreview, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 십이궁 (V2 배열)
            if (simplifiedSibigung != null &&
                simplifiedSibigung.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '🏛️',
                title: '십이궁 (十二宮) 분석',
                accentColor: faceReadingAccent,
                child: _buildSimplifiedSibigungV2(
                    context, simplifiedSibigung, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 컨디션 프리뷰
            if (conditionPreview != null) ...[
              _buildFaceReadingSection(
                context,
                icon: '💪',
                title: '오늘의 컨디션',
                accentColor: faceReadingAccent,
                child: _buildConditionPreviewV2(
                    context, conditionPreview, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 닮은 연예인
            if (similarCelebrities != null &&
                similarCelebrities.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '⭐',
                title: '닮은 연예인',
                accentColor: faceReadingAccent,
                child: _buildSimilarCelebritiesV2(
                    context, similarCelebrities, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],
          ]
          // ─────────────────────────────────────────────────────────────
          // Legacy 형식 렌더링 (V2 없을 때)
          // ─────────────────────────────────────────────────────────────
          else ...[
            // 종합 해석 (summaryMessage)
            if (summary != null && summary.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '🔮',
                title: '종합 해석',
                accentColor: faceReadingAccent,
                child: Text(
                  summary,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 동물상 분류
            if (animalType != null && animalType.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '🐾',
                title: '동물상 분류',
                accentColor: faceReadingAccent,
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        faceReadingAccent.withValues(alpha: 0.1),
                        faceReadingAccentLight.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: DSRadius.mdBorder,
                    border: Border.all(
                      color: faceReadingAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getAnimalEmoji(animalType),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$animalType 상',
                              style: typography.labelLarge.copyWith(
                                color: faceReadingAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: DSSpacing.xxs),
                            Text(
                              _getAnimalDescription(animalType),
                              style: typography.bodySmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 오관 (五官) 분석 - 눈/코/입/귀/눈썹
            if (ogwan != null && ogwan.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '👁️',
                title: '오관 (五官) 분석',
                accentColor: faceReadingAccent,
                child: _buildOgwanAnalysis(context, ogwan, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 명궁 분석
            if (myeonggung != null && myeonggung.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '✨',
                title: '명궁 분석',
                accentColor: faceReadingAccent,
                child: _buildMiganOrMyeonggungAnalysis(
                    context, myeonggung, '명궁', faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 미간 분석
            if (migan != null && migan.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '🌟',
                title: '미간 분석',
                accentColor: faceReadingAccent,
                child: _buildMiganOrMyeonggungAnalysis(
                    context, migan, '미간', faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 삼정 (三停) 분석 - 상/중/하정
            if (samjeong != null && samjeong.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '📐',
                title: '삼정 (三停) 분석',
                accentColor: faceReadingAccent,
                child: _buildSamjeongAnalysis(
                    context, samjeong, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            // 십이궁 (十二宮) 분석
            if (sibigung != null && sibigung.isNotEmpty) ...[
              _buildFaceReadingSection(
                context,
                icon: '🏛️',
                title: '십이궁 (十二宮) 분석',
                accentColor: faceReadingAccent,
                child: _buildSibigungAnalysis(
                    context, sibigung, faceReadingAccent),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // V2 UI 빌더 메서드들
  // ─────────────────────────────────────────────────────────────

  /// V2: 핵심 인사이트 카드
  Widget _buildPriorityInsightsV2(BuildContext context,
      List<Map<String, dynamic>> insights, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: insights.map((insight) {
        final icon = insight['icon'] as String? ?? '💡';
        final title = insight['title'] as String? ?? '';
        final description = insight['description'] as String? ?? '';
        final score = insight['score'] as int?;

        return Container(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.05),
            borderRadius: DSRadius.mdBorder,
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: typography.labelMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(context, score)
                                  .withValues(alpha: 0.2),
                              borderRadius: DSRadius.smBorder,
                            ),
                            child: Text(
                              '$score점',
                              style: typography.labelSmall.copyWith(
                                color: _getScoreColor(context, score),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.xxs),
                    Text(
                      description,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// V2: 간소화된 오관 배열
  Widget _buildSimplifiedOgwanV2(BuildContext context,
      List<Map<String, dynamic>> ogwanList, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: ogwanList.map((item) {
        final icon = item['icon'] as String? ?? '👁️';
        final name = item['name'] as String? ?? '';
        final hanjaName = item['hanjaName'] as String? ?? '';
        final score = item['score'] as int?;
        final summary = item['summary'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: DSRadius.mdBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    name,
                    style: typography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hanjaName.isNotEmpty) ...[
                    const SizedBox(width: DSSpacing.xxs),
                    Text(
                      '($hanjaName)',
                      style: typography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(context, score)
                            .withValues(alpha: 0.2),
                        borderRadius: DSRadius.smBorder,
                      ),
                      child: Text(
                        '$score점',
                        style: typography.labelSmall.copyWith(
                          color: _getScoreColor(context, score),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  summary,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// V2: 간소화된 십이궁 배열
  Widget _buildSimplifiedSibigungV2(BuildContext context,
      List<Map<String, dynamic>> sibigungList, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: sibigungList.map((item) {
        final icon = item['icon'] as String? ?? '🏛️';
        final name = item['name'] as String? ?? '';
        final hanjaName = item['hanjaName'] as String? ?? '';
        final score = item['score'] as int?;
        final summary = item['summary'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: DSRadius.mdBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    name,
                    style: typography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hanjaName.isNotEmpty) ...[
                    const SizedBox(width: DSSpacing.xxs),
                    Text(
                      '($hanjaName)',
                      style: typography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(context, score)
                            .withValues(alpha: 0.2),
                        borderRadius: DSRadius.smBorder,
                      ),
                      child: Text(
                        '$score점',
                        style: typography.labelSmall.copyWith(
                          color: _getScoreColor(context, score),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  summary,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// V2: 프리뷰 카드 (명궁/미간)
  Widget _buildPreviewCardV2(BuildContext context, Map<String, dynamic> preview,
      String label, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    final score = preview['score'] as int?;
    final summary = preview['summary'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: DSRadius.mdBorder,
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (score != null)
            Row(
              children: [
                Text(
                  label,
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getScoreColor(context, score).withValues(alpha: 0.2),
                    borderRadius: DSRadius.smBorder,
                  ),
                  child: Text(
                    '$score',
                    style: typography.labelMedium.copyWith(
                      color: _getScoreColor(context, score),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              summary,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// V2: 눈 프리뷰
  Widget _buildEyePreviewV2(BuildContext context,
      Map<String, dynamic> eyePreview, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    final observation = eyePreview['observation'] as String? ?? '';
    final interpretation = eyePreview['interpretation'] as String? ?? '';
    final score = eyePreview['score'] as int?;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: DSRadius.mdBorder,
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (score != null)
            Row(
              children: [
                Text(
                  '눈',
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getScoreColor(context, score).withValues(alpha: 0.2),
                    borderRadius: DSRadius.smBorder,
                  ),
                  child: Text(
                    '$score',
                    style: typography.labelMedium.copyWith(
                      color: _getScoreColor(context, score),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (observation.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '관찰: $observation',
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (interpretation.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '해석: $interpretation',
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// V2: 컨디션 프리뷰
  Widget _buildConditionPreviewV2(BuildContext context,
      Map<String, dynamic> conditionPreview, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    final score = conditionPreview['overallConditionScore'] as int?;
    final message = conditionPreview['conditionMessage'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: DSRadius.mdBorder,
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (score != null)
            Row(
              children: [
                Text(
                  '컨디션',
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getScoreColor(context, score).withValues(alpha: 0.2),
                    borderRadius: DSRadius.smBorder,
                  ),
                  child: Text(
                    '$score',
                    style: typography.labelMedium.copyWith(
                      color: _getScoreColor(context, score),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              message,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// V2: 닮은 연예인
  Widget _buildSimilarCelebritiesV2(BuildContext context,
      List<Map<String, dynamic>> celebrities, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: celebrities.map((celeb) {
        final name = celeb['name'] as String? ?? '';
        final score = celeb['similarity_score'] as num?;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: DSRadius.smBorder,
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: DSSpacing.xxs),
              Text(
                name,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '${score.toInt()}%',
                  style: typography.labelSmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 얼굴형 이모지
  String _getFaceTypeEmoji(String faceType) {
    final type = faceType.toLowerCase();
    if (type.contains('계란') || type.contains('타원')) return '🥚';
    if (type.contains('둥근') || type.contains('원형')) return '🌕';
    if (type.contains('네모') || type.contains('각진')) return '⬜';
    if (type.contains('긴') || type.contains('장형')) return '📏';
    if (type.contains('하트') || type.contains('역삼각')) return '💜';
    if (type.contains('다이아') || type.contains('마름모')) return '💎';
    return '👤';
  }

  /// 관상 섹션 공통 래퍼
  Widget _buildFaceReadingSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
    required Color accentColor,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: DSSpacing.xs),
            Text(
              title,
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        child,
      ],
    );
  }

  /// 동물상 이모지
  String _getAnimalEmoji(String animalType) {
    final type = animalType.toLowerCase();
    if (type.contains('강아지') || type.contains('개')) return '🐕';
    if (type.contains('고양이')) return '🐱';
    if (type.contains('여우')) return '🦊';
    if (type.contains('토끼')) return '🐰';
    if (type.contains('곰')) return '🐻';
    if (type.contains('사슴')) return '🦌';
    if (type.contains('늑대')) return '🐺';
    if (type.contains('호랑이')) return '🐯';
    if (type.contains('용')) return '🐉';
    if (type.contains('뱀')) return '🐍';
    if (type.contains('말')) return '🐴';
    if (type.contains('원숭이')) return '🐵';
    if (type.contains('공룡')) return '🦕';
    if (type.contains('부엉이') || type.contains('올빼미')) return '🦉';
    if (type.contains('독수리')) return '🦅';
    return '✨';
  }

  /// 동물상 설명
  String _getAnimalDescription(String animalType) {
    final type = animalType.toLowerCase();
    if (type.contains('강아지') || type.contains('개')) {
      return '친근하고 순수한 인상, 믿음직스러운 이미지';
    }
    if (type.contains('고양이')) {
      return '신비롭고 도도한 매력, 독립적인 성향';
    }
    if (type.contains('여우')) {
      return '영리하고 세련된 인상, 매혹적인 분위기';
    }
    if (type.contains('토끼')) {
      return '귀엽고 부드러운 이미지, 상냥한 인상';
    }
    if (type.contains('곰')) {
      return '듬직하고 포근한 이미지, 믿음직한 인상';
    }
    if (type.contains('사슴')) {
      return '순수하고 청초한 이미지, 맑은 눈매';
    }
    if (type.contains('늑대')) {
      return '카리스마 있고 강인한 이미지, 날카로운 인상';
    }
    if (type.contains('호랑이')) {
      return '강렬하고 위엄있는 인상, 리더십 있는 분위기';
    }
    return '독특한 개성과 매력을 가진 인상';
  }

  /// 오관 분석 위젯
  Widget _buildOgwanAnalysis(
    BuildContext context,
    Map<String, dynamic> ogwan,
    Color accentColor,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    final parts = <Map<String, dynamic>>[];

    // 눈 (감찰관)
    if (ogwan['eye'] != null) {
      parts.add({
        'name': '눈 (감찰관)',
        'icon': '👁️',
        'data': ogwan['eye'],
      });
    }
    // 코 (심판관)
    if (ogwan['nose'] != null) {
      parts.add({
        'name': '코 (심판관)',
        'icon': '👃',
        'data': ogwan['nose'],
      });
    }
    // 입 (출납관)
    if (ogwan['mouth'] != null) {
      parts.add({
        'name': '입 (출납관)',
        'icon': '👄',
        'data': ogwan['mouth'],
      });
    }
    // 귀 (채청관)
    if (ogwan['ear'] != null) {
      parts.add({
        'name': '귀 (채청관)',
        'icon': '👂',
        'data': ogwan['ear'],
      });
    }
    // 눈썹 (보수관)
    if (ogwan['eyebrow'] != null) {
      parts.add({
        'name': '눈썹 (보수관)',
        'icon': '🔲',
        'data': ogwan['eyebrow'],
      });
    }

    return Column(
      children: parts.map((part) {
        final data = part['data'] as Map<String, dynamic>;
        final interpretation = data['interpretation'] as String? ?? '';
        final shape = data['shape'] as String?;
        final score = data['score'] as int?;

        return Container(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: DSRadius.smBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(part['icon'] as String,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      part['name'] as String,
                      style: typography.labelMedium.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.sm,
                        vertical: DSSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: DSRadius.smBorder,
                      ),
                      child: Text(
                        '$score점',
                        style: typography.labelSmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (shape != null && shape.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '형태: $shape',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (interpretation.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  interpretation,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 명궁/미간 분석 위젯
  Widget _buildMiganOrMyeonggungAnalysis(
    BuildContext context,
    Map<String, dynamic> data,
    String title,
    Color accentColor,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    final description = data['description'] as String? ?? '';
    final fortuneMessage = data['fortuneMessage'] as String? ??
        data['lifeFortuneMessage'] as String? ??
        '';
    final score = data['score'] as int?;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: DSRadius.smBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (score != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: DSRadius.smBorder,
                  ),
                  child: Text(
                    '$score',
                    style: typography.labelSmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (fortuneMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: DSRadius.smBorder,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💫', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      fortuneMessage,
                      style: typography.bodySmall.copyWith(
                        color: accentColor,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 삼정 분석 위젯
  Widget _buildSamjeongAnalysis(
    BuildContext context,
    Map<String, dynamic> samjeong,
    Color accentColor,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    final sections = <Map<String, dynamic>>[];

    if (samjeong['upper'] != null) {
      sections.add({
        'name': '상정 (이마~눈썹)',
        'meaning': '초년운 · 지적 능력',
        'data': samjeong['upper'],
      });
    }
    if (samjeong['middle'] != null) {
      sections.add({
        'name': '중정 (눈썹~코끝)',
        'meaning': '중년운 · 의지력',
        'data': samjeong['middle'],
      });
    }
    if (samjeong['lower'] != null) {
      sections.add({
        'name': '하정 (코끝~턱)',
        'meaning': '말년운 · 실행력',
        'data': samjeong['lower'],
      });
    }

    return Column(
      children: sections.map((section) {
        final data = section['data'] as Map<String, dynamic>;
        final interpretation = data['interpretation'] as String? ?? '';
        final balance = data['balance'] as String?;
        final score = data['score'] as int?;

        return Container(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: DSRadius.smBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['name'] as String,
                          style: typography.labelMedium.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          section['meaning'] as String,
                          style: typography.labelSmall.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.sm,
                        vertical: DSSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: DSRadius.smBorder,
                      ),
                      child: Text(
                        '$score',
                        style: typography.labelSmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (balance != null && balance.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '균형: $balance',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (interpretation.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  interpretation,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 십이궁 분석 위젯
  Widget _buildSibigungAnalysis(
    BuildContext context,
    Map<String, dynamic> sibigung,
    Color accentColor,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    // 십이궁 이름 매핑
    final palaceNames = {
      'life': '명궁 (命宮)',
      'wealth': '재백궁 (財帛宮)',
      'siblings': '형제궁 (兄弟宮)',
      'property': '전택궁 (田宅宮)',
      'children': '자녀궁 (子女宮)',
      'health': '질액궁 (疾厄宮)',
      'marriage': '부처궁 (夫妻宮)',
      'travel': '천이궁 (遷移宮)',
      'friends': '교우궁 (交友宮)',
      'career': '관록궁 (官祿宮)',
      'fortune': '복덕궁 (福德宮)',
      'parents': '부모궁 (父母宮)',
    };

    final palaces = sibigung.entries.where((e) => e.value is Map).toList();

    return Column(
      children: palaces.map((entry) {
        final key = entry.key;
        final data = entry.value as Map<String, dynamic>;
        final name = palaceNames[key] ?? key;
        final interpretation = data['interpretation'] as String? ?? '';
        final score = data['score'] as int?;

        return Container(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: DSRadius.smBorder,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: typography.labelMedium.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (interpretation.isNotEmpty) ...[
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        interpretation,
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (score != null)
                Container(
                  margin: const EdgeInsets.only(left: DSSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: DSRadius.smBorder,
                  ),
                  child: Text(
                    '$score',
                    style: typography.labelSmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 건강운 전용 섹션
  // ============================================================

  /// 건강운 상세 섹션 (운동 추천, 식단 조언 등)
  Widget _buildHealthDetailSection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    final exerciseAdvice = metadata['exercise_advice'];
    final dietAdvice = metadata['diet_advice'] as String?;
    final overallHealth = metadata['overall_health'] as String?;
    final bodyPartAdvice = metadata['body_part_advice'] as String?;
    final cautions = metadata['cautions'] as List<dynamic>?;
    final recommendedActivities =
        metadata['recommended_activities'] as List<dynamic>?;
    // ✅ 신규: 오행 기반 개인화 조언
    final elementAdvice = metadata['element_advice'] as Map<String, dynamic>?;
    final personalizedFeedback =
        metadata['personalized_feedback'] as Map<String, dynamic>?;

    // 건강 accent 색상 (청록)
    final healthAccent = DSColors.info;
    final healthAccentLight = DSColors.info;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전반 건강 분석
          if (overallHealth != null && overallHealth.isNotEmpty) ...[
            _buildHealthSection(
              context,
              icon: '🏥',
              title: '전반 건강 분석',
              child: Text(
                overallHealth,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ✅ 오행 기반 개인화 조언 (신규)
          if (elementAdvice != null) ...[
            _buildElementAdviceSection(context, elementAdvice, isDark,
                healthAccent, healthAccentLight),
            const SizedBox(height: DSSpacing.md),
          ],

          // ✅ 개인화 피드백 (이전 설문 비교 - 신규)
          if (personalizedFeedback != null) ...[
            _buildPersonalizedFeedbackSection(
                context, personalizedFeedback, isDark, healthAccent),
            const SizedBox(height: DSSpacing.md),
          ],

          // 부위별 조언
          if (bodyPartAdvice != null && bodyPartAdvice.isNotEmpty) ...[
            _buildHealthSection(
              context,
              icon: '🩺',
              title: '부위별 맞춤 조언',
              child: Text(
                bodyPartAdvice,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 운동 추천 (구조화된 UI)
          if (exerciseAdvice != null) ...[
            _buildHealthSection(
              context,
              icon: '🏃',
              title: '오늘의 운동',
              child: exerciseAdvice is Map<String, dynamic>
                  ? _buildStructuredExerciseAdvice(context, exerciseAdvice,
                      isDark, healthAccent, healthAccentLight)
                  : Text(
                      exerciseAdvice.toString(),
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 식단 조언
          if (dietAdvice != null && dietAdvice.isNotEmpty) ...[
            _buildHealthSection(
              context,
              icon: '🍽️',
              title: '식습관 조언',
              child: Text(
                dietAdvice,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 주의사항
          if (cautions != null && cautions.isNotEmpty) ...[
            _buildHealthSection(
              context,
              icon: '⚠️',
              title: '주의사항',
              child: Column(
                children: cautions.map((caution) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•',
                            style: typography.bodySmall
                                .copyWith(color: colors.textSecondary)),
                        const SizedBox(width: DSSpacing.xs),
                        Expanded(
                          child: Text(
                            caution.toString(),
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 추천 활동
          if (recommendedActivities != null &&
              recommendedActivities.isNotEmpty) ...[
            _buildHealthSection(
              context,
              icon: '✨',
              title: '추천 활동',
              child: Column(
                children: recommendedActivities.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•',
                            style: typography.bodySmall
                                .copyWith(color: healthAccent)),
                        const SizedBox(width: DSSpacing.xs),
                        Expanded(
                          child: Text(
                            activity.toString(),
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // 운동운 전용 섹션
  // ============================================================

  /// 운동운 상세 섹션 (추천 운동, 오늘의 루틴 등)
  /// 모든 섹션을 상세하게 표시하고 프리미엄 블러 적용
  Widget _buildExerciseDetailSection(BuildContext context, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;
    // ✅ fortune.additionalInfo 또는 fortune.metadata에 상세 정보가 있음
    // FortuneResult.data → Fortune.additionalInfo로 매핑됨
    final exerciseData = fortune.additionalInfo ?? fortune.metadata ?? {};

    // 디버그 로깅
    debugPrint(
        '🏋️ [_buildExerciseDetailSection] Building exercise detail section');
    debugPrint(
        '🏋️ [_buildExerciseDetailSection] exerciseData keys: ${exerciseData.keys.toList()}');
    debugPrint('🏋️ [_buildExerciseDetailSection] exerciseData: $exerciseData');

    final recommendedExercise =
        exerciseData['recommendedExercise'] as Map<String, dynamic>?;
    final todayRoutine = exerciseData['todayRoutine'] as Map<String, dynamic>?;
    final weeklyPlan = exerciseData['weeklyPlan'] as Map<String, dynamic>?;
    final optimalTime = exerciseData['optimalTime'] as Map<String, dynamic>?;
    final injuryPrevention =
        exerciseData['injuryPrevention'] as Map<String, dynamic>?;
    final nutritionTip = exerciseData['nutritionTip'] as Map<String, dynamic>?;

    debugPrint(
        '🏋️ [_buildExerciseDetailSection] recommendedExercise: $recommendedExercise');
    debugPrint('🏋️ [_buildExerciseDetailSection] todayRoutine: $todayRoutine');
    debugPrint('🏋️ [_buildExerciseDetailSection] optimalTime: $optimalTime');

    // 운동 accent 색상 (오렌지)
    final exerciseAccent = DSColors.warning;
    final exerciseAccentLight = DSColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // 🎯 추천 운동 (무료)
          // ============================================================
          if (recommendedExercise != null) ...[
            _buildHealthSection(
              context,
              icon: '🎯',
              title: '오늘의 추천 운동',
              child: _buildRecommendedExerciseDetail(
                context,
                recommendedExercise,
                exerciseAccent,
                exerciseAccentLight,
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // ⏰ 최적 운동 시간 (무료)
          // ============================================================
          if (optimalTime != null) ...[
            _buildHealthSection(
              context,
              icon: '⏰',
              title: '오늘의 최적 운동 시간',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: DSSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: exerciseAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Text(
                      optimalTime['time'] as String? ?? '',
                      style: typography.labelLarge.copyWith(
                        color: exerciseAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    optimalTime['reason'] as String? ?? '',
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // 📋 오늘의 루틴
          // ============================================================
          if (todayRoutine != null) ...[
            _buildHealthSection(
              context,
              icon: '📋',
              title: '오늘의 루틴',
              child: _buildRoutineDetail(context, todayRoutine, exerciseAccent),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // 📅 주간 계획
          // ============================================================
          if (weeklyPlan != null) ...[
            _buildHealthSection(
              context,
              icon: '📅',
              title: '주간 운동 계획',
              child:
                  _buildWeeklyPlanDetail(context, weeklyPlan, exerciseAccent),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // 🛡️ 부상 예방
          // ============================================================
          if (injuryPrevention != null) ...[
            _buildHealthSection(
              context,
              icon: '🛡️',
              title: '부상 예방 가이드',
              child: _buildInjuryPreventionDetail(
                  context, injuryPrevention, exerciseAccent),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // 🥗 영양 팁 (무료)
          // ============================================================
          if (nutritionTip != null) ...[
            _buildHealthSection(
              context,
              icon: '🥗',
              title: '영양 팁',
              child: _buildNutritionTipDetail(
                  context, nutritionTip, exerciseAccent),
            ),
          ],
        ],
      ),
    );
  }

  /// 추천 운동 상세 (description, precautions, alternatives 포함)
  Widget _buildRecommendedExerciseDetail(
    BuildContext context,
    Map<String, dynamic> data,
    Color accentColor,
    Color accentLightColor,
  ) {
    final typography = context.typography;
    final colors = context.colors;

    // primary 구조 또는 flat 구조 둘 다 지원
    final primary = data['primary'] as Map<String, dynamic>? ?? data;
    final alternatives = data['alternatives'] as List<dynamic>?;

    final name = primary['name'] as String? ?? '';
    final description = primary['description'] as String? ?? '';
    final duration = primary['duration'] as String?;
    final intensity = primary['intensity'] as String?;
    final benefits = primary['benefits'] as List<dynamic>?;
    final precautions = primary['precautions'] as List<dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 운동명 + 강도
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: typography.labelLarge.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (intensity != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getIntensityColor(context, intensity)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getIntensityLabel(intensity),
                  style: typography.labelSmall.copyWith(
                    color: _getIntensityColor(context, intensity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        // 소요 시간
        if (duration != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: colors.textSecondary),
              const SizedBox(width: DSSpacing.xs),
              Text(
                duration,
                style:
                    typography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ],

        // 설명
        if (description.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Text(
            description,
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],

        // 효과 태그
        if (benefits != null && benefits.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: benefits.map((benefit) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  benefit.toString(),
                  style: typography.labelSmall.copyWith(color: accentColor),
                ),
              );
            }).toList(),
          ),
        ],

        // 주의사항
        if (precautions != null && precautions.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(color: colors.warning.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '주의사항',
                      style: typography.labelSmall.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.xs),
                ...precautions.map((p) => Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•',
                              style: typography.bodySmall
                                  .copyWith(color: colors.warning)),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Text(
                              p.toString(),
                              style: typography.bodySmall.copyWith(
                                color: colors.warning,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        // 대체 운동
        if (alternatives != null && alternatives.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          Text(
            '대체 운동',
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          ...alternatives.map((alt) {
            final altMap = alt as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentLightColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    altMap['name'] as String? ?? '',
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (altMap['reason'] != null) ...[
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Text(
                        '- ${altMap['reason']}',
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  /// 강도 라벨
  String _getIntensityLabel(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return '저강도';
      case 'medium':
        return '중강도';
      case 'high':
        return '고강도';
      default:
        return intensity;
    }
  }

  /// 강도 색상 (영어/한글 모두 지원, 디자인 시스템 통합)
  Color _getIntensityColor(BuildContext context, String intensity) {
    final colors = context.colors;
    switch (intensity.toLowerCase()) {
      case 'low':
      case '가벼움':
      case '저강도':
        return colors.success; // 낮음 - 녹색
      case 'medium':
      case '중간':
      case '중강도':
        return colors.warning; // 중간 - 황색
      case 'high':
      case '높음':
      case '고강도':
        return colors.error; // 높음 - 빨강
      default:
        return colors.success;
    }
  }

  /// 오늘의 루틴 상세 표시 (헬스/요가/카디오/스포츠)
  Widget _buildRoutineDetail(
      BuildContext context, Map<String, dynamic> routine, Color accentColor) {
    final typography = context.typography;
    final colors = context.colors;

    // 헬스/크로스핏 루틴
    if (routine['gymRoutine'] != null) {
      final gym = routine['gymRoutine'] as Map<String, dynamic>;
      final exercises = gym['exercises'] as List<dynamic>? ?? [];
      final warmup = gym['warmup'] as Map<String, dynamic>?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  gym['splitType'] as String? ?? '',
                  style: typography.labelSmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                gym['todayFocus'] as String? ?? '',
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (warmup != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '워밍업 ${warmup['duration'] ?? '10분'}',
                  style: typography.bodySmall
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ],
          const SizedBox(height: DSSpacing.sm),
          ...exercises.take(6).map((ex) {
            final exercise = ex as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      exercise['name'] as String? ?? '',
                      style: typography.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  Text(
                    '${exercise['sets'] ?? 3}세트 × ${exercise['reps'] ?? '8-12'}회',
                    style: typography.bodySmall.copyWith(color: accentColor),
                  ),
                  if (exercise['restSeconds'] != null) ...[
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '휴식 ${exercise['restSeconds']}초',
                      style: typography.labelSmall
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (exercises.length > 6)
            Text(
              '+ ${exercises.length - 6}개 더',
              style: typography.labelSmall.copyWith(color: colors.textTertiary),
            ),
        ],
      );
    }

    // 요가/필라테스 루틴
    if (routine['yogaRoutine'] != null) {
      final yoga = routine['yogaRoutine'] as Map<String, dynamic>;
      final poses = yoga['poses'] as List<dynamic>? ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            yoga['sequenceName'] as String? ?? '요가 시퀀스',
            style: typography.labelLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...poses.take(6).map((p) {
            final pose = p as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  const Text('🧘', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pose['name'] as String? ?? '',
                      style: typography.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  Text(
                    pose['duration'] as String? ?? '',
                    style: typography.bodySmall.copyWith(color: accentColor),
                  ),
                ],
              ),
            );
          }),
          if (poses.length > 6)
            Text(
              '+ ${poses.length - 6}개 더',
              style: typography.labelSmall.copyWith(color: colors.textTertiary),
            ),
        ],
      );
    }

    // 카디오 루틴 (러닝/수영/자전거)
    if (routine['cardioRoutine'] != null) {
      final cardio = routine['cardioRoutine'] as Map<String, dynamic>;
      final intervals = cardio['intervals'] as List<dynamic>? ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                cardio['totalDistance'] as String? ?? '',
                style: typography.labelLarge.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '목표 페이스: ${cardio['targetPace'] ?? '-'}',
                style:
                    typography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...intervals.map((i) {
            final interval = i as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getIntervalColor(
                          context, interval['intensity'] as String?),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      interval['phase'] as String? ?? '',
                      style: typography.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  Text(
                    interval['duration'] as String? ?? '',
                    style: typography.bodySmall
                        .copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    interval['intensity'] as String? ?? '',
                    style: typography.labelSmall.copyWith(color: accentColor),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    // 스포츠 루틴 (테니스/골프/클라이밍/격투기)
    if (routine['sportsRoutine'] != null) {
      final sports = routine['sportsRoutine'] as Map<String, dynamic>;
      final drills = sports['drills'] as List<dynamic>? ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sports['focusArea'] as String? ?? '오늘의 훈련',
            style: typography.labelLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...drills.take(5).map((d) {
            final drill = d as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  const Text('⚽', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drill['name'] as String? ?? '',
                          style: typography.bodyMedium
                              .copyWith(color: colors.textPrimary),
                        ),
                        if (drill['purpose'] != null)
                          Text(
                            drill['purpose'] as String,
                            style: typography.labelSmall
                                .copyWith(color: colors.textTertiary),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    drill['duration'] as String? ?? '',
                    style: typography.bodySmall.copyWith(color: accentColor),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// 인터벌 강도 색상 (디자인 시스템 통합)
  Color _getIntervalColor(BuildContext context, String? intensity) {
    final colors = context.colors;
    if (intensity == null) return colors.textTertiary;
    final percent = int.tryParse(intensity.replaceAll('%', '')) ?? 50;
    if (percent <= 40) return colors.success;
    if (percent <= 60) return colors.warning;
    if (percent <= 80) return colors.warning;
    return colors.error;
  }

  /// 주간 계획 상세 표시
  Widget _buildWeeklyPlanDetail(BuildContext context,
      Map<String, dynamic> weeklyPlan, Color accentColor) {
    final typography = context.typography;
    final colors = context.colors;

    final summary = weeklyPlan['summary'] as String? ?? '';
    final schedule = weeklyPlan['schedule'] as Map<String, dynamic>? ?? {};

    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.isNotEmpty) ...[
          Text(
            summary,
            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final day = days[index];
            final activity = schedule[day] as String? ?? '휴식';
            final isRest = activity == '휴식' || activity.isEmpty;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isRest
                      ? colors.surface.withValues(alpha: 0.5)
                      : accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isRest
                        ? colors.border.withValues(alpha: 0.3)
                        : accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      dayLabels[index],
                      style: typography.labelSmall.copyWith(
                        color: isRest ? colors.textTertiary : accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      isRest ? '쉼' : _getShortActivity(activity),
                      style: typography.labelSmall.copyWith(
                        color:
                            isRest ? colors.textTertiary : colors.textPrimary,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 활동명 축약
  String _getShortActivity(String activity) {
    if (activity.length <= 4) return activity;
    return '${activity.substring(0, 3)}..';
  }

  /// 부상 예방 상세 표시
  Widget _buildInjuryPreventionDetail(BuildContext context,
      Map<String, dynamic> injuryPrevention, Color accentColor) {
    final typography = context.typography;
    final colors = context.colors;

    final warnings = injuryPrevention['warnings'] as List<dynamic>? ?? [];
    final warmup = injuryPrevention['warmup'] as String?;
    final stretches = injuryPrevention['stretches'] as List<dynamic>? ?? [];
    final recoveryTips =
        injuryPrevention['recoveryTips'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (warnings.isNotEmpty) ...[
          ...warnings.take(3).map((w) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        w as String,
                        style: typography.bodySmall.copyWith(
                          color: colors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: DSSpacing.xs),
        ],
        if (warmup != null && warmup.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '워밍업: $warmup',
                  style:
                      typography.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        if (stretches.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🧘', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '스트레칭: ${stretches.take(3).join(', ')}',
                  style:
                      typography.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        if (recoveryTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            '💡 회복 팁',
            style: typography.labelMedium.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          ...recoveryTips.take(2).map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $tip',
                  style: typography.bodySmall
                      .copyWith(color: colors.textSecondary),
                ),
              )),
        ],
      ],
    );
  }

  /// 영양 팁 상세 표시
  Widget _buildNutritionTipDetail(BuildContext context,
      Map<String, dynamic> nutritionTip, Color accentColor) {
    final typography = context.typography;
    final colors = context.colors;

    final preworkout = nutritionTip['preworkout'] as String?;
    final postworkout = nutritionTip['postworkout'] as String?;
    final message = nutritionTip['message'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preworkout != null && preworkout.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '운동 전',
                  style: typography.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  preworkout,
                  style:
                      typography.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        if (postworkout != null && postworkout.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '운동 후',
                  style: typography.labelSmall.copyWith(
                    color: colors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  postworkout,
                  style:
                      typography.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ],
        if ((preworkout == null || preworkout.isEmpty) &&
            (postworkout == null || postworkout.isEmpty) &&
            message != null &&
            message.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🥗', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message,
                  style:
                      typography.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 건강운 섹션 공통 wrapper
  Widget _buildHealthSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: DSSpacing.xs),
            Text(
              title,
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        child,
      ],
    );
  }

  // ============================================================
  // 건강운 인포그래픽 섹션 (NEW)
  // ============================================================

  /// 건강 키워드 칩 섹션 (점수 아래 표시)
  Widget _buildHealthKeywordChips(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // health_keyword 파싱 (예: "수면 회복, 활력 충전" 또는 단일 키워드)
    final healthKeyword = metadata['health_keyword'] as String?;
    final percentile = fortune.percentile;
    final score = fortune.overallScore ?? 70;

    // 키워드가 없으면 빈 위젯
    if (healthKeyword == null || healthKeyword.isEmpty) {
      return const SizedBox.shrink();
    }

    // 키워드 파싱 (쉼표 또는 공백으로 분리)
    final keywords = healthKeyword
        .split(RegExp(r'[,\s]+'))
        .where((k) => k.isNotEmpty)
        .take(3)
        .toList();

    // 점수 기반 상태 아이콘
    final statusIcon = score >= 80
        ? '🟢'
        : score >= 60
            ? '🟡'
            : '🔴';
    final statusText = score >= 80
        ? '양호'
        : score >= 60
            ? '보통'
            : '주의';

    final healthAccent = DSColors.info;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: healthAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '컨디션 키워드',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (percentile != null && fortune.isPercentileValid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: healthAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DSRadius.xs),
                    ),
                    child: Text(
                      '상위 ${100 - percentile}%',
                      style: typography.labelSmall.copyWith(
                        color: healthAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: [
                // 상태 칩
                _buildKeywordChip(
                  context,
                  label: '$statusIcon $statusText',
                  isPrimary: true,
                ),
                // 키워드 칩들
                ...keywords.map((keyword) => _buildKeywordChip(
                      context,
                      label: keyword,
                      isPrimary: false,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 키워드 칩 위젯
  Widget _buildKeywordChip(
    BuildContext context, {
    required String label,
    required bool isPrimary,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final healthAccent = DSColors.info;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isPrimary
            ? healthAccent.withValues(alpha: 0.15)
            : colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: isPrimary
            ? Border.all(color: healthAccent.withValues(alpha: 0.3))
            : null,
      ),
      child: Text(
        label,
        style: typography.labelMedium.copyWith(
          color: isPrimary ? healthAccent : colors.textSecondary,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  /// 오행 밸런스 막대 그래프 섹션
  Widget _buildElementBalanceSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final elementAdvice = metadata['element_advice'] as Map<String, dynamic>?;

    if (elementAdvice == null) return const SizedBox.shrink();

    final elementBalance =
        elementAdvice['element_balance'] as Map<String, dynamic>?;
    final lackingElement = elementAdvice['lacking_element'] as String?;
    final vulnerableOrgans =
        elementAdvice['vulnerable_organs'] as List<dynamic>?;

    // 오행 색상
    const elementColors = {
      '목': DSColors.success,
      '화': DSColors.error,
      '토': DSColors.warning,
      '금': DSColors.textSecondary,
      '수': DSColors.info,
    };

    const elementNames = ['목', '화', '토', '금', '수'];
    final healthAccent = DSColors.info;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: healthAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚖️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오행 밸런스',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
            // 오행 막대 그래프
            ...elementNames.map((element) {
              final value =
                  (elementBalance?[element] as num?)?.toDouble() ?? 50;
              final isLacking = element == lackingElement;
              final color = elementColors[element] ?? healthAccent;

              return Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        element,
                        style: typography.labelSmall.copyWith(
                          color: isLacking ? color : colors.textSecondary,
                          fontWeight:
                              isLacking ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: value / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${value.toInt()}',
                        style: typography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    if (isLacking)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text('⚠️', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              );
            }),
            // 부족 오행 요약
            if (lackingElement != null) ...[
              const SizedBox(height: DSSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: (elementColors[lackingElement] ?? healthAccent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '부족: $lackingElement',
                      style: typography.labelSmall.copyWith(
                        color: elementColors[lackingElement] ?? healthAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (vulnerableOrgans != null &&
                        vulnerableOrgans.isNotEmpty) ...[
                      Text(
                        ' → ${vulnerableOrgans.take(2).join(", ")} 주의',
                        style: typography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 추천 음식 테이블
  Widget _buildFoodTable(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final elementFoods = metadata['element_foods'] as List<dynamic>?;

    if (elementFoods == null || elementFoods.isEmpty) {
      return const SizedBox.shrink();
    }

    final healthAccent = DSColors.info;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: healthAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '추천 음식',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            // 테이블 헤더
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: DSSpacing.xs,
                horizontal: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(DSRadius.xs),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '음식',
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '시간',
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '효과',
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            // 테이블 행들
            ...elementFoods.take(3).map((food) {
              final foodMap = food as Map<String, dynamic>?;
              final item = foodMap?['item'] as String? ?? '—';
              final timing = foodMap?['timing'] as String? ?? '—';
              final reason = foodMap?['reason'] as String? ?? '—';
              // reason이 길면 축약
              final shortReason =
                  reason.length > 8 ? '${reason.substring(0, 8)}…' : reason;

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: DSSpacing.xs,
                  horizontal: DSSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.border.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item,
                        style: typography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        timing,
                        style: typography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        shortReason,
                        style: typography.labelSmall.copyWith(
                          color: healthAccent,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 시간대별 활동 그리드
  Widget _buildTimeActivityGrid(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final exerciseAdvice = metadata['exercise_advice'] as Map<String, dynamic>?;

    if (exerciseAdvice == null) return const SizedBox.shrink();

    final morning = exerciseAdvice['morning'] as Map<String, dynamic>?;
    final afternoon = exerciseAdvice['afternoon'] as Map<String, dynamic>?;
    final evening = exerciseAdvice['evening'] as Map<String, dynamic>?;

    // 최소 하나의 시간대 데이터가 있어야 표시
    if (morning == null && afternoon == null && evening == null) {
      return const SizedBox.shrink();
    }

    final healthAccent = DSColors.info;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: healthAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏃', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '시간대별 활동',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            // 3열 그리드
            Row(
              children: [
                if (morning != null)
                  Expanded(
                    child: _buildTimeSlotCell(
                      context,
                      label: '오전',
                      data: morning,
                    ),
                  ),
                if (morning != null && (afternoon != null || evening != null))
                  const SizedBox(width: DSSpacing.xs),
                if (afternoon != null)
                  Expanded(
                    child: _buildTimeSlotCell(
                      context,
                      label: '오후',
                      data: afternoon,
                    ),
                  ),
                if (afternoon != null && evening != null)
                  const SizedBox(width: DSSpacing.xs),
                if (evening != null)
                  Expanded(
                    child: _buildTimeSlotCell(
                      context,
                      label: '저녁',
                      data: evening,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 시간대 셀 위젯
  Widget _buildTimeSlotCell(
    BuildContext context, {
    required String label,
    required Map<String, dynamic> data,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final title = data['title'] as String? ?? '—';
    final duration = data['duration'] as String? ?? '';
    final intensity = data['intensity'] as String? ?? '';

    // 강도에 따른 아이콘
    final intensityIcon = intensity.contains('가벼움') || intensity.contains('낮음')
        ? '🟢'
        : intensity.contains('중간')
            ? '🟡'
            : intensity.contains('높음')
                ? '🔴'
                : '🟢';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            title,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (duration.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              duration,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          if (intensity.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(intensityIcon, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  /// 주의사항 간략 표시
  Widget _buildCompactCautions(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final cautions = metadata['cautions'] as List<dynamic>?;

    if (cautions == null || cautions.isEmpty) {
      return const SizedBox.shrink();
    }

    // 각 주의사항에서 핵심 단어만 추출 (이모지 제거, 짧게)
    final shortCautions = cautions.take(4).map((c) {
      final text = c.toString();
      // 이모지와 앞부분 제거, 핵심만
      final cleaned = text.replaceAll(RegExp(r'^[^\w가-힣]*'), '');
      // 8자 초과 시 축약
      return cleaned.length > 8 ? '${cleaned.substring(0, 8)}…' : cleaned;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: colors.warning.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '주의',
              style: typography.labelSmall.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                shortCautions.map((c) => '• $c').join('  '),
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 건강운 인포그래픽 섹션 끝
  // ============================================================

  /// ✅ 오행 기반 개인화 조언 섹션
  Widget _buildElementAdviceSection(
    BuildContext context,
    Map<String, dynamic> elementAdvice,
    bool isDark,
    Color healthAccent,
    Color healthAccentLight,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    final lackingElement = elementAdvice['lacking_element'] as String?;
    final dominantElement = elementAdvice['dominant_element'] as String?;
    final vulnerableOrgans =
        elementAdvice['vulnerable_organs'] as List<dynamic>?;
    final vulnerableSymptoms =
        elementAdvice['vulnerable_symptoms'] as List<dynamic>?;
    final recommendedFoods =
        elementAdvice['recommended_foods'] as List<dynamic>?;

    // 오행 색상 매핑
    const elementColors = {
      '목': DSColors.success, // 녹색
      '화': DSColors.error, // 빨강
      '토': DSColors.warning, // 황토
      '금': DSColors.textSecondary, // 은색
      '수': DSColors.info, // 파랑
    };

    final elementColor = elementColors[lackingElement] ?? healthAccent;

    return _buildHealthSection(
      context,
      icon: '🌿',
      title: '오행 기반 건강 조언',
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              elementColor.withValues(alpha: isDark ? 0.2 : 0.1),
              elementColor.withValues(alpha: isDark ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: elementColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오행 분석 요약
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                  decoration: BoxDecoration(
                    color: elementColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Text(
                    '$lackingElement(${_getElementHanja(lackingElement)}) 기운 부족',
                    style: typography.labelMedium.copyWith(
                      color: elementColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                if (dominantElement != null)
                  Text(
                    '$dominantElement 기운 강함',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 취약 장기
            if (vulnerableOrgans != null && vulnerableOrgans.isNotEmpty) ...[
              Row(
                children: [
                  Text('💪 주의 장기: ',
                      style: typography.labelSmall
                          .copyWith(color: colors.textSecondary)),
                  Text(
                    vulnerableOrgans.join(', '),
                    style: typography.labelSmall.copyWith(
                      color: elementColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xs),
            ],

            // 취약 증상
            if (vulnerableSymptoms != null &&
                vulnerableSymptoms.isNotEmpty) ...[
              Text(
                '⚠️ 주의 증상: ${vulnerableSymptoms.take(3).join(', ')}',
                style:
                    typography.bodySmall.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: DSSpacing.md),
            ],

            // 추천 음식
            if (recommendedFoods != null && recommendedFoods.isNotEmpty) ...[
              Text(
                '🍽️ 오행 보충 음식',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              ...recommendedFoods.take(3).map((food) {
                final foodMap = food as Map<String, dynamic>?;
                final item = foodMap?['item'] as String? ?? food.toString();
                final reason = foodMap?['reason'] as String?;
                final timing = foodMap?['timing'] as String?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: elementColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: typography.bodySmall
                                .copyWith(color: colors.textSecondary),
                            children: [
                              TextSpan(
                                text: item,
                                style: typography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary),
                              ),
                              if (timing != null) TextSpan(text: ' ($timing)'),
                              if (reason != null) TextSpan(text: ' - $reason'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// 오행 한자 변환
  String _getElementHanja(String? element) {
    const hanjaMap = {'목': '木', '화': '火', '토': '土', '금': '金', '수': '水'};
    return hanjaMap[element] ?? '';
  }

  /// ✅ 개인화 피드백 섹션 (이전 설문 비교)
  Widget _buildPersonalizedFeedbackSection(
    BuildContext context,
    Map<String, dynamic> feedback,
    bool isDark,
    Color healthAccent,
  ) {
    final colors = context.colors;
    final improvements =
        (feedback['improvements'] as List<dynamic>?)?.cast<String>() ?? [];
    final concerns =
        (feedback['concerns'] as List<dynamic>?)?.cast<String>() ?? [];
    final encouragements =
        (feedback['encouragements'] as List<dynamic>?)?.cast<String>() ?? [];

    if (improvements.isEmpty && concerns.isEmpty && encouragements.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildHealthSection(
      context,
      icon: '📊',
      title: '지난 기록 대비 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 개선점 (긍정)
          ...improvements.map((item) => _buildFeedbackItem(
                context,
                icon: '✅',
                text: item,
                color: colors.success,
                isDark: isDark,
              )),

          // 격려
          ...encouragements.map((item) => _buildFeedbackItem(
                context,
                icon: '💪',
                text: item,
                color: healthAccent,
                isDark: isDark,
              )),

          // 주의점 (경고)
          ...concerns.map((item) => _buildFeedbackItem(
                context,
                icon: '⚠️',
                text: item,
                color: colors.warning,
                isDark: isDark,
              )),
        ],
      ),
    );
  }

  /// 피드백 아이템 빌더
  Widget _buildFeedbackItem(
    BuildContext context, {
    required String icon,
    required String text,
    required Color color,
    required bool isDark,
  }) {
    final typography = context.typography;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(DSRadius.sm),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 구조화된 운동 추천 UI (오전/오후 카드 + 주간 그리드)
  Widget _buildStructuredExerciseAdvice(
    BuildContext context,
    Map<String, dynamic> advice,
    bool isDark,
    Color healthAccent,
    Color healthAccentLight,
  ) {
    final colors = context.colors;
    final morning = advice['morning'] as Map<String, dynamic>?;
    final afternoon = advice['afternoon'] as Map<String, dynamic>?;
    final weekly = advice['weekly'] as Map<String, dynamic>?;
    final overallTip = advice['overall_tip'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오전 운동 카드
        if (morning != null)
          _buildExerciseTimeSlotCard(
            context,
            timeSlot: morning,
            icon: Icons.wb_sunny_rounded,
            label: '오전 운동',
            isDark: isDark,
            gradientColors: [
              colors.warning.withValues(alpha: isDark ? 0.3 : 0.2),
              colors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
            ],
            healthAccent: healthAccent,
            healthAccentLight: healthAccentLight,
          ),

        if (morning != null && afternoon != null)
          const SizedBox(height: DSSpacing.sm),

        // 오후 운동 카드
        if (afternoon != null)
          _buildExerciseTimeSlotCard(
            context,
            timeSlot: afternoon,
            icon: Icons.wb_twilight_rounded,
            label: '오후 운동',
            isDark: isDark,
            gradientColors: [
              healthAccent.withValues(alpha: isDark ? 0.3 : 0.2),
              healthAccentLight.withValues(alpha: isDark ? 0.2 : 0.1),
            ],
            healthAccent: healthAccent,
            healthAccentLight: healthAccentLight,
          ),

        if (weekly != null) const SizedBox(height: DSSpacing.md),

        // 주간 운동 계획 그리드
        if (weekly != null)
          _buildWeeklyScheduleGrid(
              context, weekly, isDark, healthAccent, healthAccentLight),

        // 전체 조언 배너
        if (overallTip != null && overallTip.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          _buildOverallTipBanner(
              context, overallTip, isDark, healthAccent, healthAccentLight),
        ],
      ],
    );
  }

  /// 시간대별 운동 카드 (오전/오후)
  Widget _buildExerciseTimeSlotCard(
    BuildContext context, {
    required Map<String, dynamic> timeSlot,
    required IconData icon,
    required String label,
    required bool isDark,
    required List<Color> gradientColors,
    required Color healthAccent,
    required Color healthAccentLight,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final time = timeSlot['time'] as String? ?? '';
    final title = timeSlot['title'] as String? ?? '';
    final description = timeSlot['description'] as String? ?? '';
    final duration = timeSlot['duration'] as String? ?? '';
    final intensity = timeSlot['intensity'] as String? ?? '';
    final tip = timeSlot['tip'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: healthAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘 + 라벨 + 시간
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: healthAccent.withValues(alpha: isDark ? 0.3 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark ? healthAccentLight : healthAccent,
                  size: 16,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      title,
                      style: typography.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 시간 뱃지
              if (time.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: healthAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadius.xs),
                  ),
                  child: Text(
                    time,
                    style: typography.labelSmall.copyWith(
                      color: isDark ? healthAccentLight : healthAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: DSSpacing.xs),

          // 설명
          if (description.isNotEmpty)
            Text(
              description,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.4,
                fontSize: 12,
              ),
            ),

          const SizedBox(height: DSSpacing.xs),

          // 시간/강도 뱃지 row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (duration.isNotEmpty)
                _buildExerciseInfoBadge(context, Icons.timer_outlined, duration,
                    isDark, healthAccent),
              if (intensity.isNotEmpty)
                _buildExerciseInfoBadge(context, Icons.speed_outlined,
                    intensity, isDark, _getIntensityColor(context, intensity)),
            ],
          ),

          // 팁
          if (tip.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 14,
                  color: DSColors.warning,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    tip,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 운동 정보 뱃지 (시간, 강도)
  Widget _buildExerciseInfoBadge(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark,
    Color color,
  ) {
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? color.withValues(alpha: 0.9) : color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: typography.labelTiny.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? color.withValues(alpha: 0.9) : color,
            ),
          ),
        ],
      ),
    );
  }

  /// 주간 운동 계획 그리드
  Widget _buildWeeklyScheduleGrid(
    BuildContext context,
    Map<String, dynamic> weekly,
    bool isDark,
    Color healthAccent,
    Color healthAccentLight,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    final summary = weekly['summary'] as String? ?? '';
    final schedule = weekly['schedule'] as Map<String, dynamic>? ?? {};

    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: isDark ? healthAccentLight : healthAccent,
            ),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '주간 운동 계획',
              style: typography.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        if (summary.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            summary,
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],

        const SizedBox(height: DSSpacing.sm),

        // 7일 그리드
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth =
                (constraints.maxWidth - 36) / 7; // 36 = 6 gaps * 6px

            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(7, (index) {
                final dayKey = days[index];
                final dayLabel = dayLabels[index];
                final activity = schedule[dayKey] as String? ?? '-';
                final isRest = activity.contains('휴식') || activity == '-';

                return _buildDayCell(
                  context,
                  width: itemWidth,
                  dayLabel: dayLabel,
                  activity: activity,
                  isRest: isRest,
                  isDark: isDark,
                  healthAccent: healthAccent,
                  healthAccentLight: healthAccentLight,
                );
              }),
            );
          },
        ),
      ],
    );
  }

  /// 개별 요일 셀
  Widget _buildDayCell(
    BuildContext context, {
    required double width,
    required String dayLabel,
    required String activity,
    required bool isRest,
    required bool isDark,
    required Color healthAccent,
    required Color healthAccentLight,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final bgColor = isRest
        ? colors.textPrimary.withValues(alpha: 0.05)
        : healthAccent.withValues(alpha: isDark ? 0.2 : 0.1);

    final borderColor =
        isRest ? Colors.transparent : healthAccent.withValues(alpha: 0.3);

    final textColor = isRest
        ? colors.textSecondary.withValues(alpha: 0.6)
        : (isDark ? healthAccentLight : healthAccent);

    // 긴 텍스트 자르기
    final truncated =
        activity.length <= 6 ? activity : '${activity.substring(0, 4)}...';

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DSRadius.xs),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // 요일
          Text(
            dayLabel,
            style: typography.labelTiny.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          // 활동
          Text(
            truncated,
            style: typography.labelTiny.copyWith(
              fontSize: 8,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // 휴식 아이콘
          if (isRest)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.self_improvement_rounded,
                size: 12,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  /// 전체 조언 배너
  Widget _buildOverallTipBanner(
    BuildContext context,
    String tip,
    bool isDark,
    Color healthAccent,
    Color healthAccentLight,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            healthAccent.withValues(alpha: isDark ? 0.25 : 0.15),
            healthAccentLight.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: healthAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: healthAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: isDark ? healthAccentLight : healthAccent,
              size: 14,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Text(
              tip,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// MBTI 오늘의 함정 섹션 (위기감 유발 배너)
  Widget _buildMbtiTodayTrapSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final todayTrap = _mbtiTodayTrap;
    if (todayTrap == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.sm, DSSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.warning.withValues(alpha: 0.15),
              colors.warning.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('⚠️', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 함정',
                    style: typography.labelMedium.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    todayTrap,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MBTI 차원별 인사이트 카드 (경고 포함)
  Widget _buildMbtiDimensionCards(BuildContext context) {
    final dimensions = _mbtiDimensions;
    if (dimensions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DSSpacing.md, DSSpacing.md, DSSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '차원별 인사이트',
            style: context.typography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...dimensions.map((dim) => _buildMbtiDimensionCard(context, dim)),
        ],
      ),
    );
  }

  /// 개별 MBTI 차원 카드
  Widget _buildMbtiDimensionCard(
      BuildContext context, MbtiDimensionFortune dimension) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? dimension.color.withValues(alpha: 0.15)
            : dimension.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: dimension.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘 + 타이틀 + 점수
          Row(
            children: [
              Text(dimension.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  dimension.title,
                  style: typography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? dimension.color
                        : dimension.color.withValues(alpha: 0.9),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dimension.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSRadius.xs),
                ),
                child: Text(
                  '${dimension.score}점',
                  style: typography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? dimension.color
                        : dimension.color.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          // 운세 텍스트
          Text(
            dimension.fortune,
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          // 조언
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡',
                  style: typography.bodySmall
                      .copyWith(color: colors.textSecondary)),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  dimension.tip,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          // 경고 섹션 (있을 경우)
          if (dimension.warning != null && dimension.warning!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xs),
            Container(
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(DSRadius.xs),
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dimension.warningIcon,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dimension.warning!,
                      style: typography.bodySmall.copyWith(
                        color: isDark
                            ? colors.error
                            : colors.error.withValues(alpha: 0.9),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============ 소원 빌기 (Wish) 섹션 빌더 ============

  /// 🐉 용의 한마디 (power_line) 헤더 섹션
  Widget _buildWishDragonHeaderSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final wishData = _wishData;
    if (wishData?.dragonMessage == null) return const SizedBox.shrink();

    final dragonMsg = wishData!.dragonMessage!;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.accentSecondary.withValues(alpha: 0.9),
            DSColors.accentSecondary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        boxShadow: [
          BoxShadow(
            color: DSColors.accentSecondary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 용 아이콘
          const Text('🐉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: DSSpacing.sm),
          // power_line (소원 키워드 포함된 메시지)
          Text(
            dragonMsg.powerLine,
            style: typography.headingSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📊 운의 흐름 섹션 (achievement_level, timing, keywords, helper/obstacle)
  Widget _buildWishFortuneFlowSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final wishData = _wishData;
    if (wishData?.fortuneFlow == null) return const SizedBox.shrink();

    final flow = wishData!.fortuneFlow!;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : colors.background,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text('운의 흐름',
                  style: typography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 성취 가능성 레벨
          _buildFlowItem(context, '✨', '성취 가능성', flow.achievementLevel,
              _getAchievementColor(context, flow.achievementLevel)),

          // 행운의 타이밍
          _buildFlowItem(
              context, '⏰', '행운의 시간', flow.luckyTiming, colors.accent),

          // 키워드 해시태그
          if (flow.keywords.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: flow.keywords
                  .map((keyword) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.full),
                        ),
                        child: Text(
                          keyword,
                          style: typography.labelSmall
                              .copyWith(color: colors.accent),
                        ),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: DSSpacing.md),

          // 도움 요소
          if (flow.helper.isNotEmpty)
            _buildFlowItem(
                context, '👤', '도움이 되는 것', flow.helper, colors.success),

          // 주의 요소
          if (flow.obstacle.isNotEmpty)
            _buildFlowItem(
                context, '⚠️', '주의할 것', flow.obstacle, colors.warning),
        ],
      ),
    );
  }

  Widget _buildFlowItem(BuildContext context, String emoji, String label,
      String value, Color accentColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: typography.labelSmall
                        .copyWith(color: colors.textSecondary)),
                Text(
                  value,
                  style: typography.bodyMedium.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 달성도 색상 (디자인 시스템 통합)
  Color _getAchievementColor(BuildContext context, String level) {
    final colors = context.colors;
    switch (level) {
      case '매우 높음':
        return colors.success;
      case '높음':
        return colors.success;
      case '보통':
        return colors.warning;
      case '노력 필요':
        return colors.warning;
      default:
        return colors.textTertiary;
    }
  }

  /// 🍀 행운 미션 섹션 (item, place, color with reasons)
  Widget _buildWishLuckyMissionSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final wishData = _wishData;
    if (wishData?.luckyMission == null) return const SizedBox.shrink();

    final mission = wishData!.luckyMission!;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : colors.background,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Row(
            children: [
              const Text('🍀', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text('오늘의 행운 미션',
                  style: typography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 행운 아이템
          _buildMissionItem(
            context,
            emoji: '🎁',
            title: '행운 아이템',
            value: mission.item,
            reason: mission.itemReason,
          ),

          // 행운 장소
          _buildMissionItem(
            context,
            emoji: '📍',
            title: '행운 장소',
            value: mission.place,
            reason: mission.placeReason,
          ),

          // 행운 색상
          _buildMissionItem(
            context,
            emoji: '🎨',
            title: '행운 색상',
            value: mission.color,
            reason: mission.colorReason,
            colorPreview: _getColorFromName(mission.color),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(
    BuildContext context, {
    required String emoji,
    required String title,
    required String value,
    required String reason,
    Color? colorPreview,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color:
            isDark ? colors.background.withValues(alpha: 0.5) : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: typography.labelSmall
                            .copyWith(color: colors.textSecondary)),
                    if (colorPreview != null) ...[
                      const SizedBox(width: DSSpacing.xs),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorPreview,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  value,
                  style: typography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  reason,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      '빨간색': Colors.red,
      '분홍색': Colors.pink,
      '주황색': Colors.orange,
      '노란색': Colors.yellow,
      '금색': DSColors.warning,
      '초록색': Colors.green,
      '파란색': Colors.blue,
      '남색': Colors.indigo,
      '보라색': Colors.purple,
      '하얀색': Colors.white,
      '검은색': DSColors.background,
      '회색': DSColors.textTertiary,
    };
    return colorMap[colorName] ?? Colors.blue;
  }

  /// 💎 용의 지혜 섹션 (pearl_message, wisdom)
  Widget _buildWishDragonWisdomSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final wishData = _wishData;
    if (wishData?.dragonMessage == null) return const SizedBox.shrink();

    final dragonMsg = wishData!.dragonMessage!;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [DSColors.surfaceSecondary, DSColors.surface]
              : [DSColors.surfaceDark, DSColors.backgroundTertiaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 여의주 메시지
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💎', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '여의주의 빛',
                      style: typography.labelSmall
                          .copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      dragonMsg.pearlMessage,
                      style: typography.bodyMedium.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.md),
          Divider(color: colors.border),
          const SizedBox(height: DSSpacing.md),

          // 용의 지혜
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🐲', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '용의 지혜',
                      style: typography.labelSmall
                          .copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      dragonMsg.wisdom,
                      style: typography.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💪 응원 메시지 섹션
  Widget _buildWishEncouragementSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final wishData = _wishData;
    if (wishData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 공감 메시지
          if (wishData.empathyMessage.isNotEmpty) ...[
            Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text('공감',
                    style: typography.labelMedium
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              wishData.empathyMessage,
              style: typography.bodyMedium.copyWith(height: 1.5),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 희망 메시지
          if (wishData.hopeMessage.isNotEmpty) ...[
            Row(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text('희망',
                    style: typography.labelMedium
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              wishData.hopeMessage,
              style: typography.bodyMedium.copyWith(height: 1.5),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 응원 메시지
          if (wishData.encouragement.isNotEmpty) ...[
            Row(
              children: [
                const Text('💪', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text('응원',
                    style: typography.labelMedium
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              wishData.encouragement,
              style: typography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.accent,
                height: 1.5,
              ),
            ),
          ],

          // 신의 한마디
          if (wishData.specialWords.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      wishData.specialWords,
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📝 조언 리스트 섹션
  Widget _buildWishAdviceSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final wishData = _wishData;
    if (wishData == null || wishData.advice.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : colors.background,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text('오늘의 실천 조언',
                  style: typography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...wishData.advice.asMap().entries.map((entry) {
            final index = entry.key;
            final advice = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: typography.labelSmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      advice,
                      style: typography.bodyMedium.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============ 🧿 부적 (Talisman) 전용 섹션 ============

  /// 부적 세부 운세 섹션 (종합/애정/직장/건강/금전)
  Widget _buildTalismanDetailsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final details = _talismanDetails;
    if (details == null || details.isEmpty) return const SizedBox.shrink();

    // 세부 운세 항목들과 아이콘 매핑
    final detailItems = <Map<String, dynamic>>[
      {'key': 'overall', 'label': '종합운', 'emoji': '🌟'},
      {'key': 'love', 'label': '애정운', 'emoji': '💕'},
      {'key': 'career', 'label': '직장운', 'emoji': '💼'},
      {'key': 'health', 'label': '건강운', 'emoji': '💚'},
      {'key': 'wealth', 'label': '금전운', 'emoji': '💰'},
    ];

    final validItems = detailItems.where((item) {
      final value = details[item['key']];
      return value != null && value.toString().isNotEmpty;
    }).toList();

    if (validItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : colors.background,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧿', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text('세부 운세',
                  style: typography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...validItems.map((item) {
            final value = details[item['key']].toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['emoji'] as String,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: typography.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: DSSpacing.xs),
                        Text(
                          value,
                          style: typography.bodyMedium.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 부적 행운 아이템 섹션
  Widget _buildTalismanLuckyItemsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final luckyItems = _talismanLuckyItems;
    if (luckyItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : colors.background,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍀', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text('행운 아이템',
                  style: typography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: luckyItems
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.full),
                        border: Border.all(
                            color: colors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item,
                        style: typography.labelMedium.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 부적 주의사항 섹션
  Widget _buildTalismanWarningsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;
    final warnings = _talismanWarnings;
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? colors.warning.withValues(alpha: 0.1)
            : colors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text('주의사항',
                  style: typography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          ...warnings.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: typography.bodyMedium.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: typography.bodyMedium.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // 가족운 전용 섹션들 (family-health/wealth/relationship/children/change)
  // ============================================================

  /// 가족운 섹션 헬퍼 위젯
  Widget _buildFamilySection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
    Color? accentColor,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    // accentColor는 child 위젯에서 직접 사용됨

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: DSSpacing.xs),
            Text(
              title,
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        child,
      ],
    );
  }

  /// 가족운 타입별 액센트 색상
  Color get _familyAccentColor {
    if (_isFamilyHealth) return DSColors.success; // 청록 (건강)
    if (_isFamilyWealth) return DSColors.warning; // 금색 (재물)
    if (_isFamilyRelationship) return DSColors.error; // 핑크 (관계)
    if (_isFamilyChildren) return DSColors.info; // 파랑 (자녀)
    if (_isFamilyChange) return DSColors.accentSecondary; // 보라 (변화)
    return DSColors.accentSecondary;
  }

  /// 가족운 타입별 제목 접두어
  String get _familyTypePrefix {
    if (_isFamilyHealth) return '건강';
    if (_isFamilyWealth) return '재물';
    if (_isFamilyRelationship) return '관계';
    if (_isFamilyChildren) return '자녀';
    if (_isFamilyChange) return '변화';
    return '가족';
  }

  /// 1. 카테고리별 점수 섹션
  Widget _buildFamilyCategoriesSection(BuildContext context, bool isDark) {
    final categories = _familyCategories;
    if (categories == null || categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '📊',
        title: '$_familyTypePrefix 카테고리별 분석',
        accentColor: accent,
        child: Column(
          children: categories.entries.map((entry) {
            final category = entry.value as Map<String, dynamic>?;
            if (category == null) return const SizedBox.shrink();

            final score = category['score'] as int? ?? 0;
            final title = category['title'] as String? ?? entry.key;
            final description = category['description'] as String? ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? colors.backgroundSecondary : colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: typography.labelMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          '$score점',
                          style: typography.labelSmall.copyWith(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      description,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 2. 가족 조화 분석 섹션 (familySynergy)
  Widget _buildFamilySynergySection(BuildContext context, bool isDark) {
    final synergy = _familySynergy;
    if (synergy == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    final title = synergy['title'] as String? ?? '가족 조화 분석';
    final compatibility = synergy['compatibility'] as String?;
    final strengthPoints = synergy['strengthPoints'] as List<dynamic>?;
    final improvementAreas = synergy['improvementAreas'] as List<dynamic>?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '💜',
        title: title,
        accentColor: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compatibility != null && compatibility.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                child: Text(
                  compatibility,
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.md),
            ],
            if (strengthPoints != null && strengthPoints.isNotEmpty) ...[
              Text(
                '💪 강점',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              ...strengthPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✓',
                            style:
                                typography.bodySmall.copyWith(color: accent)),
                        const SizedBox(width: DSSpacing.xs),
                        Expanded(
                          child: Text(
                            point.toString(),
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: DSSpacing.sm),
            ],
            if (improvementAreas != null && improvementAreas.isNotEmpty) ...[
              Text(
                '🎯 개선 포인트',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              ...improvementAreas.map((area) => Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('→',
                            style: typography.bodySmall
                                .copyWith(color: colors.textTertiary)),
                        const SizedBox(width: DSSpacing.xs),
                        Expanded(
                          child: Text(
                            area.toString(),
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// 3. 타입별 특수 조언 섹션 (seasonalAdvice, timingAdvice, communicationAdvice 등)
  Widget _buildFamilySpecialAdviceSection(BuildContext context, bool isDark) {
    final advice = _familySpecialAdvice;
    if (advice == null || advice.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    // 타입별 섹션 제목 & 아이콘
    String sectionTitle;
    String sectionIcon;
    if (_isFamilyHealth) {
      sectionTitle = '계절별 건강 조언';
      sectionIcon = '🌿';
    } else if (_isFamilyWealth) {
      sectionTitle = '월별 재물운 트렌드';
      sectionIcon = '📈';
    } else if (_isFamilyRelationship) {
      sectionTitle = '소통 조언';
      sectionIcon = '💬';
    } else if (_isFamilyChildren) {
      sectionTitle = '교육 조언';
      sectionIcon = '📚';
    } else if (_isFamilyChange) {
      sectionTitle = '타이밍 조언';
      sectionIcon = '⏰';
    } else {
      sectionTitle = '특별 조언';
      sectionIcon = '💡';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: sectionIcon,
        title: sectionTitle,
        accentColor: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: advice.entries.map((entry) {
            final value = entry.value?.toString() ?? '';
            if (value.isEmpty) return const SizedBox.shrink();

            // 키를 한글로 변환
            String label = entry.key;
            if (label == 'current_season') label = '현재 계절';
            if (label == 'caution_period') label = '주의 시기';
            if (label == 'best_activity') label = '추천 활동';
            if (label == 'best_period') label = '최적 시기';
            if (label == 'overall_trend') label = '전체 흐름';
            if (label == 'style') label = '대화 스타일';
            if (label == 'topic') label = '대화 주제';
            if (label == 'avoid') label = '피할 주제';
            if (label == 'study_style') label = '학습 스타일';
            if (label == 'best_subject') label = '적합 과목';
            if (label == 'encouragement') label = '격려의 말';
            if (label == 'best_month') label = '최적의 달';
            if (label == 'preparation') label = '준비 사항';

            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? colors.backgroundSecondary : colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.border.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typography.labelSmall.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    value,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 4. 월별 흐름 섹션 (monthlyFlow)
  Widget _buildFamilyMonthlyFlowSection(BuildContext context, bool isDark) {
    final flow = _familyMonthlyFlow;
    if (flow == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    final current = flow['current'] as String?;
    final next = flow['next'] as String?;
    final advice = flow['advice'] as String?;

    if (current == null && next == null && advice == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '📅',
        title: '월별 $_familyTypePrefix운 흐름',
        accentColor: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (current != null && current.isNotEmpty) ...[
              _buildFamilyFlowItem(context, '이번 달', current, accent, isDark),
              const SizedBox(height: DSSpacing.sm),
            ],
            if (next != null && next.isNotEmpty) ...[
              _buildFamilyFlowItem(
                  context, '다음 달', next, colors.textTertiary, isDark),
              const SizedBox(height: DSSpacing.sm),
            ],
            if (advice != null && advice.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: typography.bodySmall),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        advice,
                        style: typography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyFlowItem(BuildContext context, String label,
      String content, Color labelColor, bool isDark) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.border.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.labelSmall.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            content,
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 5. 가족 조언 팁 섹션 (familyAdvice)
  Widget _buildFamilyAdviceTipsSection(BuildContext context, bool isDark) {
    final advice = _familyAdvice;
    if (advice == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    final title = advice['title'] as String? ?? '가족 조언';
    final tips = advice['tips'] as List<dynamic>?;

    if (tips == null || tips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '🏠',
        title: title,
        accentColor: accent,
        child: Column(
          children: tips.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final tip = entry.value.toString();

            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? colors.backgroundSecondary : colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.border.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: typography.labelSmall.copyWith(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      tip,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 6. 추천사항 섹션 (recommendations)
  Widget _buildFamilyRecommendationsSection(BuildContext context, bool isDark) {
    final recommendations = _familyRecommendations;
    if (recommendations.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '✨',
        title: '추천 실천 사항',
        accentColor: accent,
        child: Column(
          children: recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•',
                      style: typography.bodySmall.copyWith(color: accent)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      rec,
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 7. 주의사항 섹션 (warnings)
  Widget _buildFamilyWarningsSection(BuildContext context, bool isDark) {
    final warnings = _familyWarnings;
    if (warnings.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final warningColor = colors.error; // 빨간색

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '⚠️',
        title: '주의사항',
        accentColor: warningColor,
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: warningColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: warningColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: warnings.map((warning) {
              return Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('!',
                        style: typography.bodySmall.copyWith(
                          color: warningColor,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        warning,
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// 8. 특별 질문 답변 섹션 (specialAnswer)
  Widget _buildFamilySpecialAnswerSection(BuildContext context, bool isDark) {
    final answer = _familySpecialAnswer;
    if (answer == null || answer.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final accent = _familyAccentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: _buildFamilySection(
        context,
        icon: '💬',
        title: '특별 질문에 대한 답변',
        accentColor: accent,
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.1),
                accent.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Text(
            answer,
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  // ============ 반려동물 궁합 (Pet Compatibility) UI 빌더 ============

  /// 교감 미션 섹션 (FREE - 블러 없음)
  Widget _buildBondingMissionSection(BuildContext context) {
    final mission = _bondingMission;
    if (mission == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final petInfo = _petInfo;
    final petName = petInfo?['name'] ?? '반려동물';

    // 미션 타입별 이모지와 색상
    final missionType = mission['mission_type'] as String? ?? 'play';
    final (emoji, accentColor) = switch (missionType) {
      'skinship' => ('🤗', DSColors.accentSecondary),
      'play' => ('🎾', DSColors.success),
      'environment' => ('🏠', DSColors.info),
      'communication' => ('💬', DSColors.accentSecondary),
      _ => ('🐾', colors.accent),
    };

    // 난이도별 표시
    final difficulty = mission['difficulty'] as String? ?? 'easy';
    final difficultyLabel = switch (difficulty) {
      'easy' => '쉬움 ⭐',
      'medium' => '보통 ⭐⭐',
      'special' => '특별 ⭐⭐⭐',
      _ => '쉬움 ⭐',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.15),
              accentColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DSRadius.lg),
                  topRight: Radius.circular(DSRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DSRadius.md),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 교감 미션',
                          style: typography.labelSmall.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          mission['mission_title'] ?? '특별한 시간',
                          style: typography.headingSmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Text(
                      difficultyLabel,
                      style: typography.labelSmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 미션 설명
            Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission['mission_description'] ?? '',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (mission['expected_reaction'] != null) ...[
                    const SizedBox(height: DSSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Text('💭', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Text(
                              '$petName의 예상 반응: ${mission['expected_reaction']}',
                              style: typography.bodySmall.copyWith(
                                color: colors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 펫 속마음 편지 섹션 (PREMIUM)
  Widget _buildPetsVoiceSection(BuildContext context, bool isPremium) {
    final petsVoice = _petsVoice;
    if (petsVoice == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    final petInfo = _petInfo;
    final petName = petInfo?['name'] ?? '반려동물';
    final petSpecies = petInfo?['species'] ?? 'dog';

    // 편지 타입별 이모지와 색상
    final letterType = petsVoice['letter_type'] as String? ?? 'comfort';
    final (emoji, accentColor, bgEmoji) = switch (letterType) {
      'comfort' => ('🥺', DSColors.accentSecondary, '💜'),
      'excitement' => ('🤩', DSColors.accentSecondary, '⭐'),
      'gratitude' => ('🥰', DSColors.error, '💕'),
      'longing' => ('😢', DSColors.info, '💙'),
      _ => ('🐾', colors.accent, '💖'),
    };

    // 펫 종류별 아이콘
    final petEmoji = switch (petSpecies) {
      'dog' => '🐕',
      'cat' => '🐈',
      'bird' => '🐦',
      'hamster' => '🐹',
      'rabbit' => '🐰',
      'fish' => '🐠',
      _ => '🐾',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.12),
              accentColor.withValues(alpha: 0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 편지 헤더
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DSRadius.lg),
                  topRight: Radius.circular(DSRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  // 펫 아바타
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Center(
                      child:
                          Text(petEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$petName의 속마음 편지',
                              style: typography.labelMedium.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: DSSpacing.xs),
                            Text(emoji, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        Text(
                          'From: $petName  $bgEmoji',
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 편지 본문
            Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 속마음 편지
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${petsVoice['heartfelt_letter'] ?? ''}"',
                          style: typography.bodyLarge.copyWith(
                            color: colors.textPrimary,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 비밀 고백
                  if (petsVoice['secret_confession'] != null) ...[
                    const SizedBox(height: DSSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🤫', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Text(
                              petsVoice['secret_confession'],
                              style: typography.bodySmall.copyWith(
                                color: colors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // 서명
                  const SizedBox(height: DSSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '- $petName 올림 $petEmoji',
                      style: typography.labelSmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
