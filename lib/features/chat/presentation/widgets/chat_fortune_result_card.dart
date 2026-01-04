import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../services/ad_service.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../fortune/domain/models/mbti_dimension_fortune.dart';
import '../../../fortune/domain/models/wish_fortune_result.dart';
import 'month_highlight_detail_bottom_sheet.dart';

/// 채팅용 운세 결과 리치 카드
///
/// 이미지 헤더, 점수 원형, 카테고리 섹션, 행운 아이템 표시
class ChatFortuneResultCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String fortuneType;
  final String typeName;
  final bool isBlurred;
  final DateTime? selectedDate;

  const ChatFortuneResultCard({
    super.key,
    required this.fortune,
    required this.fortuneType,
    required this.typeName,
    this.isBlurred = false,
    this.selectedDate,
  });

  @override
  ConsumerState<ChatFortuneResultCard> createState() => _ChatFortuneResultCardState();
}

class _ChatFortuneResultCardState extends ConsumerState<ChatFortuneResultCard> {
  late bool _isBlurred;
  late List<String> _blurredSections;

  @override
  void initState() {
    super.initState();
    _isBlurred = widget.isBlurred;
    _blurredSections = widget.isBlurred && widget.fortuneType == 'avoid-people'
        ? ['cautionPeople', 'cautionObjects', 'cautionColors', 'cautionNumbers',
           'cautionAnimals', 'cautionPlaces', 'cautionTimes', 'cautionDirections']
        : [];
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

  /// 오늘의 운세 타입 체크 (설문 기반 아닌 운세)
  /// 'daily_calendar'는 기간별 인사이트로, 민화 이미지 사용
  bool get _isDailyFortune =>
      fortuneType == 'daily' ||
      fortuneType == 'time' ||
      fortuneType == 'daily_calendar';

  /// 연간 운세 타입 체크 (다양한 형식 지원: new-year, new_year, newYear)
  bool get _isYearlyFortune =>
      fortuneType == 'yearly' ||
      fortuneType == 'new-year' ||
      fortuneType == 'new_year' ||
      fortuneType == 'newYear';

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
    return metadata['cautionPeople'] != null || metadata['cautionObjects'] != null;
  }

  /// 경계 대상 caution 데이터 가져오기
  Map<String, dynamic>? get _cautionData => fortune.metadata ?? fortune.additionalInfo;

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

  /// 재물운 타입 체크 (wealth 또는 money)
  bool get _isWealth => fortuneType == 'wealth' || fortuneType == 'money';

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
  /// 'exercise' 또는 'health_sports' (FortuneSurveyType.exercise → _mapSurveyTypeToString)
  bool get _isExercise => fortuneType == 'exercise' || fortuneType == 'health_sports';

  /// 운동운 데이터 존재 여부 체크
  bool get _hasExerciseData {
    // ✅ additionalInfo를 먼저 체크 (FortuneResponseModel.toEntity에서 metadata → additionalInfo로 매핑)
    final exerciseData = fortune.additionalInfo ?? fortune.metadata ?? {};

    // 디버그 로깅
    debugPrint('🏋️ [_hasExerciseData] fortuneType: $fortuneType');
    debugPrint('🏋️ [_hasExerciseData] additionalInfo keys: ${fortune.additionalInfo?.keys.toList()}');
    debugPrint('🏋️ [_hasExerciseData] metadata keys: ${fortune.metadata?.keys.toList()}');
    debugPrint('🏋️ [_hasExerciseData] exerciseData keys: ${exerciseData.keys.toList()}');
    debugPrint('🏋️ [_hasExerciseData] recommendedExercise: ${exerciseData['recommendedExercise'] != null}');
    debugPrint('🏋️ [_hasExerciseData] todayRoutine: ${exerciseData['todayRoutine'] != null}');

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
    if (_isFamilyHealth) return metadata['healthCategories'] as Map<String, dynamic>?;
    if (_isFamilyWealth) return metadata['wealthCategories'] as Map<String, dynamic>?;
    if (_isFamilyRelationship) return metadata['relationshipCategories'] as Map<String, dynamic>?;
    if (_isFamilyChildren) return metadata['childrenCategories'] as Map<String, dynamic>?;
    if (_isFamilyChange) return metadata['changeCategories'] as Map<String, dynamic>?;
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
    if (_isFamilyHealth) return metadata['seasonalAdvice'] as Map<String, dynamic>?;
    if (_isFamilyWealth) return metadata['monthlyTrend'] as Map<String, dynamic>?;
    if (_isFamilyRelationship) return metadata['communicationAdvice'] as Map<String, dynamic>?;
    if (_isFamilyChildren) return metadata['educationAdvice'] as Map<String, dynamic>?;
    if (_isFamilyChange) return metadata['timingAdvice'] as Map<String, dynamic>?;
    return null;
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

  /// 인사이트 민화 이미지 목록 (날짜별 랜덤 선택)
  static const List<String> _minhwaImages = [
    'assets/images/minhwa/minhwa_overall_tiger.webp',
    'assets/images/minhwa/minhwa_overall_dragon.webp',
    'assets/images/minhwa/minhwa_overall_moon.webp',
    'assets/images/minhwa/minhwa_overall_phoenix.webp',
    'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'assets/images/minhwa/minhwa_overall_turtle.webp',
  ];

  /// 연간 운세 전용 민화 이미지 (새해/풍요 테마)
  static const List<String> _yearlyMinhwaImages = [
    'assets/images/minhwa/minhwa_overall_dragon.webp',
    'assets/images/minhwa/minhwa_overall_phoenix.webp',
    'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'assets/images/minhwa/minhwa_saju_tiger_dragon.webp',
    'assets/images/minhwa/minhwa_saju_fourguardians.webp',
    'assets/images/minhwa/minhwa_money_treasure.webp',
  ];

  /// 오늘 날짜 기반 민화 이미지 선택 (하루 동안 일관성 유지)
  String _getTodayMinhwaImage() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _minhwaImages.length;
    return _minhwaImages[index];
  }

  /// 연간 운세용 민화 이미지 선택 (월별로 다른 이미지)
  String _getYearlyMinhwaImage() {
    final today = DateTime.now();
    final index = today.month % _yearlyMinhwaImages.length;
    return _yearlyMinhwaImages[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = ref.watch(isPremiumProvider);

    return Container(
      width: double.infinity,
      // 수평 마진은 ListView 패딩이 아닌 카드 자체에서 적용
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md, // 화면 가장자리와의 여백
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이미지 헤더
          _buildImageHeader(context),

          // 점수 섹션
          if (fortune.overallScore != null) _buildScoreSection(context),

          // 인사말/총평
          if (fortune.greeting != null || fortune.summary != null)
            _buildSummarySection(context),

          // 경계 대상 미리보기 (avoid-people) - 블러 상태일 때만 표시
          if (fortuneType == 'avoid-people' && _hasCautionData && _isBlurred)
            _buildCautionPreviewSection(context),

          // 경계 대상 블러 섹션 (avoid-people)
          if (fortuneType == 'avoid-people' && _hasCautionData)
            _buildCautionBlurredSections(context, isDark, isPremium),

          // 본문 content 표시 (daily, compatibility, love, career 등)
          if (_shouldShowContent && fortune.content.isNotEmpty && fortuneType != 'avoid-people')
            _buildContentSection(context),

          // 기간별 인사이트 상세 데이터 (daily_calendar)
          if (fortuneType == 'daily_calendar')
            _buildDailyCalendarSection(context),

          // 카테고리/육각형 점수 표시 (content 표시하지 않는 타입만)
          if (!_shouldShowContent) ...[
            if (fortune.categories != null && fortune.categories!.isNotEmpty)
              _buildCategoriesSection(context),
            if (fortune.hexagonScores != null &&
                fortune.hexagonScores!.isNotEmpty)
              _buildHexagonScoresSection(context),
          ],

          // 추천 사항
          if (fortune.recommendations != null &&
              fortune.recommendations!.isNotEmpty)
            _buildRecommendationsSection(context),

          // 행운 아이템
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty)
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
          if (_isLottoType)
            _buildLottoNumbersSection(context),

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
            _buildWishDragonHeaderSection(context),    // 용의 한마디
            _buildWishFortuneFlowSection(context),     // 운의 흐름
            _buildWishLuckyMissionSection(context),    // 행운 미션
            _buildWishDragonWisdomSection(context),    // 용의 지혜
            _buildWishEncouragementSection(context),   // 응원 메시지
            _buildWishAdviceSection(context),          // 조언 리스트
          ],

          // 🧿 부적 전용 섹션들 (talisman)
          if (_isTalisman && _hasTalismanData) ...[
            _buildTalismanDetailsSection(context),      // 세부 운세 (종합/애정/직장/건강/금전)
            _buildTalismanLuckyItemsSection(context),   // 행운 아이템
            _buildTalismanWarningsSection(context),     // 주의사항
          ],

          // 👨‍👩‍👧 가족운 전용 섹션들 (family-health/wealth/relationship/children/change)
          if (_isFamily && _hasFamilyData) ...[
            _buildFamilyCategoriesSection(context, isDark),     // 카테고리별 점수
            _buildFamilySynergySection(context, isDark),        // 가족 조화 분석
            _buildFamilySpecialAdviceSection(context, isDark),  // 타입별 특수 조언
            _buildFamilyMonthlyFlowSection(context, isDark),    // 월별 흐름
            _buildFamilyAdviceTipsSection(context, isDark),     // 가족 조언
            _buildFamilyRecommendationsSection(context, isDark), // 추천사항
            _buildFamilyWarningsSection(context, isDark),       // 주의사항
            if (_familySpecialAnswer != null && _familySpecialAnswer!.isNotEmpty)
              _buildFamilySpecialAnswerSection(context, isDark), // 특별 질문 답변
          ],

          // 🐾 펫 궁합 전용 섹션들 (pet-compatibility)
          if (_isPetCompatibility) ...[
            // 1. 교감 미션 (FREE - 먼저 표시)
            if (_hasBondingMission)
              _buildBondingMissionSection(context),
            // 2. 펫 속마음 편지 (PREMIUM)
            if (_hasPetsVoice)
              _buildPetsVoiceSection(context, isPremium),
          ],

          // 광고 버튼 (avoid-people 블러 상태일 때만)
          if (fortuneType == 'avoid-people' && _isBlurred && !isPremium)
            _buildAdUnlockButton(context),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    // daily/yearly fortune은 민화 이미지 사용, 그 외는 기존 이미지
    final imagePath = _isDailyFortune
        ? _getTodayMinhwaImage()
        : _isYearlyFortune
            ? _getYearlyMinhwaImage()
            : FortuneCardImages.getImagePath(fortuneType);

    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          SmartImage(
            path: imagePath,
            fit: BoxFit.cover,
          ),

          // 반투명 오버레이 (텍스트 가독성용, 색상 그라데이션 제거)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          // 타이틀
          Positioned(
            left: DSSpacing.md,
            right: DSSpacing.md,
            bottom: DSSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDailyFortune
                      ? _dailyCalendarTitle
                      : _isYearlyFortune
                          ? _yearlyTitle
                          : typeName,
                  style: typography.headingSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: colors.textPrimary.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (fortune.period != null)
                  Text(
                    _getPeriodLabel(fortune.period!),
                    style: typography.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),

          // 좋아요 + 공유 버튼
          Positioned(
            top: DSSpacing.sm,
            right: DSSpacing.sm,
            child: FortuneActionButtons(
              contentId: fortune.id,
              contentType: fortuneType,
              shareTitle: typeName,
              shareContent: fortune.summary ?? fortune.content,
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = fortune.overallScore ?? 0;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        children: [
          // 점수 원형
          _FortuneScoreCircle(
            score: score,
            size: 72,
          ),
          const SizedBox(width: DSSpacing.md),

          // 점수 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '종합 운세',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(score),
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getScoreAdvice(score),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              color: const Color(0xFF10B981),
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
              color: const Color(0xFFF59E0B),
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
                             fortuneMap['content'] as String? ?? '';

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
                        const SizedBox(height: 4),
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
      scoreColor = const Color(0xFF10B981);
    } else if (score >= 60) {
      scoreColor = const Color(0xFF3B82F6);
    } else if (score >= 40) {
      scoreColor = const Color(0xFFF59E0B);
    } else {
      scoreColor = const Color(0xFFEF4444);
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

    final categoryItems = <Widget>[];
    categories.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final score = value['score'] as int?;
        final description = value['description'] as String?;
        final emoji = _getCategoryEmoji(key);

        categoryItems.add(
          _FortuneCategoryTile(
            title: _getCategoryTitle(key),
            emoji: emoji,
            score: score,
            description: description ?? '',
          ),
        );
      }
    });

    if (categoryItems.isEmpty) return const SizedBox.shrink();

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
          ...categoryItems,
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
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: scores.entries.map((entry) {
              final emoji = _getCategoryEmoji(entry.key);
              final title = _getCategoryTitle(entry.key);
              return _HexagonScoreChip(
                emoji: emoji,
                title: title,
                score: entry.value,
              );
            }).toList(),
          ),
        ],
      ),
    );
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
    final colors = context.colors;
    final typography = context.typography;
    final items = fortune.luckyItems!;

    final luckyWidgets = <Widget>[];

    if (items['color'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '🎨',
        label: '행운색',
        value: items['color'].toString(),
      ));
    }
    if (items['number'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '🔢',
        label: '행운숫자',
        value: items['number'].toString(),
      ));
    }
    if (items['direction'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '🧭',
        label: '행운방향',
        value: items['direction'].toString(),
      ));
    }
    if (items['time'] != null) {
      luckyWidgets.add(_LuckyItemChip(
        emoji: '⏰',
        label: '행운시간',
        value: items['time'].toString(),
      ));
    }

    if (luckyWidgets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍀 행운 아이템',
            style: typography.labelLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: luckyWidgets,
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    // 로또/행운번호는 항상 오늘 날짜 표시
    if (widget.fortuneType == 'lucky-number' || widget.fortuneType == 'lotto' || widget.fortuneType == 'lottery') {
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

  String _getScoreAdvice(int score) {
    if (score >= 80) return '적극적으로 도전해보세요';
    if (score >= 60) return '계획대로 진행하세요';
    return '중요한 결정은 미루세요';
  }

  String _getCategoryEmoji(String key) {
    return switch (key.toLowerCase()) {
      // 기존 운세 카테고리
      'love' || '연애운' || '연애' => '💕',
      'money' || '금전운' || '재물운' || '재물' => '💰',
      'work' || 'career' || '직업운' || '사업운' || '직업' => '💼',
      'health' || '건강운' || '건강' => '🏥',
      'social' || '대인운' || '인간관계' => '👥',
      'study' || '학업운' || '학업' => '📚',
      '총운' => '⭐',
      // 적성 운세 hexagonScores
      'creativity' => '💡',
      'technique' => '⚙️',
      'passion' => '🔥',
      'discipline' => '📈',
      'uniqueness' => '🦄',
      'marketvalue' => '💎',
      _ => '✨',
    };
  }

  String _getCategoryTitle(String key) {
    return switch (key.toLowerCase()) {
      // 기존 운세 카테고리
      'love' => '연애운',
      'money' => '금전운',
      'work' || 'career' => '직업운',
      'health' => '건강운',
      'social' => '대인운',
      'study' => '학업운',
      // 적성 운세 hexagonScores
      'creativity' => '창의성',
      'technique' => '기술력',
      'passion' => '열정',
      'discipline' => '꾸준함',
      'uniqueness' => '독창성',
      'marketvalue' => '시장가치',
      _ => key,
    };
  }

  /// 경계 대상 미리보기 섹션 (avoid-people fortune)
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
                        '광고 시청 시 8개 카테고리 전체 공개',
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
            Divider(height: 1, color: colors.textPrimary.withValues(alpha: 0.1)),
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
                cautionSurnames: (previewPerson['cautionSurnames'] as List<dynamic>?)?.cast<String>(),
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
                  Text(
                    title,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
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
                  children: cautionSurnames.map((surname) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  ).toList(),
                ),
              ],
              if (surnameReason != null && surnameReason.isNotEmpty) ...[
                const SizedBox(height: 2),
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
  Widget _buildCautionBlurredSections(BuildContext context, bool isDark, bool isPremium) {
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
          final sectionKey = cat.$3;
          final items = cat.$4 as List<dynamic>? ?? [];

          if (items.isEmpty) return const SizedBox.shrink();

          final shouldBlur = _isBlurred &&
              _blurredSections.contains(sectionKey) &&
              !isPremium;

          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: _buildBlurredCategoryCard(
              context,
              icon: icon,
              title: title,
              items: items,
              shouldBlur: shouldBlur,
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 블러 처리된 개별 카테고리 카드
  Widget _buildBlurredCategoryCard(
    BuildContext context, {
    required String icon,
    required String title,
    required List<dynamic> items,
    required bool shouldBlur,
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
                              item['direction'] as String? ?? '';
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
                          if ((item['cautionSurnames'] as List<dynamic>?)?.isNotEmpty == true) ...[
                            const SizedBox(height: DSSpacing.xs),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: (item['cautionSurnames'] as List<dynamic>).map((surname) =>
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(DSRadius.sm),
                                    border: Border.all(
                                      color: colors.error.withValues(alpha: 0.3),
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
                              ).toList(),
                            ),
                          ],
                          if ((item['surnameReason'] as String?)?.isNotEmpty == true) ...[
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

    // 블러 처리
    if (shouldBlur) {
      return Stack(
        children: [
          // 블러된 컨텐츠
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: content,
          ),
          // 반투명 오버레이
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark
                        ? TossDesignSystem.backgroundDark
                        : TossDesignSystem.backgroundLight)
                        .withValues(alpha: 0.3),
                    (isDark
                        ? TossDesignSystem.backgroundDark
                        : TossDesignSystem.backgroundLight)
                        .withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          // 자물쇠 아이콘
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.lock_outline,
                size: 28,
                color: colors.textSecondary.withValues(alpha: 0.5),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: colors.accentSecondary.withValues(alpha: 0.2),
                  ),
            ),
          ),
        ],
      );
    }

    return content;
  }

  /// 광고 보고 전체 내용 보기 버튼
  Widget _buildAdUnlockButton(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Material(
        color: colors.accentSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: InkWell(
          onTap: _showAdAndUnblur,
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '🎁 광고 보고 전체 내용 보기',
                  style: typography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    try {
      Logger.info('[ChatFortuneResultCard] 광고 시청 시작');

      final adService = AdService();

      // 광고가 준비되지 않았으면 로드
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중...'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        await adService.loadRewardedAd();

        // 광고 로딩 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러오지 못했습니다. 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      // 광고 표시
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          Logger.info('[ChatFortuneResultCard] 광고 시청 완료, 블러 해제');

          // 햅틱 피드백
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // 게이지 증가
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'avoid-people');
          }

          // 블러 해제
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            // 구독 유도 스낵바
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e) {
      Logger.error('[ChatFortuneResultCard] 광고 표시 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  /// 작명 추천 이름 섹션 빌드 (naming 전용)
  Widget _buildNamingSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    final recommendedNames = metadata['recommendedNames'] as List<dynamic>? ?? [];
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
            final isBlurred = !isPremium && index >= 3; // 비프리미엄은 상위 3개만

            return _buildNameCard(context, name, index + 1, isBlurred);
          }),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  /// 개별 이름 카드 빌드
  Widget _buildNameCard(BuildContext context, Map<String, dynamic> name, int rank, bool isBlurred) {
    final colors = context.colors;
    final typography = context.typography;

    final koreanName = name['koreanName'] as String? ?? '';
    final hanjaName = name['hanjaName'] as String? ?? '';
    final hanjaMeaning = (name['hanjaMeaning'] as List<dynamic>?)?.cast<String>() ?? [];
    final totalScore = name['totalScore'] as int? ?? 0;
    final analysis = name['analysis'] as String? ?? '';
    final compatibility = name['compatibility'] as String? ?? '';

    return Container(
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
                            color: Colors.white,
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
                        color: _getScoreColor(totalScore).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                      ),
                      child: Text(
                        '$totalScore점',
                        style: typography.labelMedium.copyWith(
                          color: _getScoreColor(totalScore),
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
                      const SizedBox(width: 4),
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

          // 블러 오버레이
          if (isBlurred)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DSRadius.md),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: colors.surface.withValues(alpha: 0.3),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.md,
                          vertical: DSSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, size: 16, color: Colors.white),
                            const SizedBox(width: DSSpacing.xs),
                            Text(
                              '프리미엄 전용',
                              style: typography.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 점수에 따른 색상 반환
  Color _getScoreColor(int score) {
    if (score >= 90) return TossDesignSystem.successGreen;
    if (score >= 80) return TossDesignSystem.tossBlue;
    if (score >= 70) return TossDesignSystem.warningOrange;
    return TossDesignSystem.gray500;
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
        : (todayRecRaw is Map ? todayRecRaw['text']?.toString() ?? todayRecRaw['recommendation']?.toString() : null);

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
              color: const Color(0xFFEF4444),
            ),
          if (emotional != null)
            _buildRhythmCard(
              context,
              name: '감성',
              icon: '🌿',
              data: emotional,
              color: const Color(0xFF22C55E),
            ),
          if (intellectual != null)
            _buildRhythmCard(
              context,
              name: '지성',
              icon: '🌙',
              data: intellectual,
              color: const Color(0xFF3B82F6),
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
                return _LottoBall(number: number);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
    final recommendations = metadata['recommendations'] as Map<String, dynamic>?;

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
              fieldLabels: {'primary': '추천 장소', 'timeRecommendation': '추천 시간', 'reason': '이유'},
            ),

          // 패션 추천
          if (recommendations['fashion'] != null)
            _buildLoveFashionCard(context, recommendations['fashion'] as Map<String, dynamic>),

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
            _buildLoveConversationCard(context, recommendations['conversation'] as Map<String, dynamic>),

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
                    const SizedBox(height: 2),
                    ...value.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(left: DSSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•', style: typography.bodySmall.copyWith(color: colors.accent)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
  Widget _buildLoveFashionCard(BuildContext context, Map<String, dynamic> data) {
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
            _buildFashionListRow(context, '⚠️ 피할 것', data['avoidFashion'] as List, isWarning: true),
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

  Widget _buildFashionListRow(BuildContext context, String label, List items, {bool isWarning = false}) {
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
          const SizedBox(height: 2),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xxs,
            children: items.take(4).map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// 대화 추천 카드 빌드
  Widget _buildLoveConversationCard(BuildContext context, Map<String, dynamic> data) {
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
            const SizedBox(height: 4),
            ...(data['topics'] as List).take(3).map((topic) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡', style: typography.labelSmall),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      topic.toString(),
                      style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
            const SizedBox(height: 4),
            ...(data['openers'] as List).take(2).map((opener) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
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
            const SizedBox(height: 4),
            ...(data['avoid'] as List).take(2).map((topic) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('❌', style: typography.labelSmall),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      topic.toString(),
                      style: typography.bodySmall.copyWith(color: colors.textSecondary),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯', style: typography.labelSmall),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data['tip'].toString(),
                      style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
    final resumeAnalysis = data['resumeAnalysis'] as Map<String, dynamic>? ?? {};

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
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
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
                children: talentInsights.take(3).toList().asMap().entries.map((entry) {
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
                                  ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                  : index == 1
                                      ? [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)]
                                      : [const Color(0xFFCD7F32), const Color(0xFFB8860B)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: typography.labelSmall.copyWith(
                                color: Colors.white,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getTalentScoreColor(potential).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(DSRadius.sm),
                                    ),
                                    child: Text(
                                      '$potential점',
                                      style: typography.labelSmall.copyWith(
                                        color: _getTalentScoreColor(potential),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (insightDesc.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  insightDesc,
                                  style: typography.bodySmall.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
          if (collaboration.isNotEmpty && collaboration['teamRole'] != null) ...[
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
                  border: Border.all(color: colors.accent.withValues(alpha: 0.15)),
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
              final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
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
                    final activities = plan['activities'] as List<dynamic>? ?? [];

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
                                    color: isToday ? colors.accent : colors.textSecondary,
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
                                    maxLines: 1,
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
                      content: (resumeAnalysis['skillGaps'] as List<dynamic>).join('\n'),
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
                      content: (resumeAnalysis['hiddenPotentials'] as List<dynamic>).join('\n'),
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
          color: DSColors.accent.withValues(alpha: 0.2),
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
                  color: DSColors.accent,
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
  Widget _buildTalentSection(BuildContext context, {
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
  Widget _buildMentalModelItem(BuildContext context, {
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

  /// 재능 점수 색상 반환
  Color _getTalentScoreColor(int score) {
    if (score >= 90) return const Color(0xFF10B981);
    if (score >= 80) return const Color(0xFF3B82F6);
    if (score >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
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
    final showColor = showAll || selectedCategory == 'color' || selectedCategory == 'fashion';
    final showPlace = showAll || selectedCategory == 'place';
    final showNumber = showAll || selectedCategory == 'number';

    // 데이터 추출
    final keyword = data['keyword'] as String? ?? '';
    final element = data['element'] as String? ?? '';
    final color = data['color'] as String? ?? '';
    final direction = data['direction'] as String? ?? '';
    final numbers = data['numbers'] as List<dynamic>? ?? [];
    final relationships = data['relationships'] as List<dynamic>? ?? [];
    final advice = data['advice'] as String? ?? data['lucky_advice'] as String? ?? '';
    final luckySummary = data['lucky_summary'] as String? ?? data['summary'] as String? ?? '';

    // ✅ 상세 필드 우선 사용 (reason, timing 포함)
    final foodDetail = data['foodDetail'] as List<dynamic>? ?? data['food'] as List<dynamic>? ?? [];
    final fashionDetail = data['fashionDetail'] as List<dynamic>? ?? data['fashion'] as List<dynamic>? ?? [];
    final colorDetail = data['colorDetail'] as Map<String, dynamic>? ?? (data['colorDetail'] is Map ? data['colorDetail'] as Map<String, dynamic> : <String, dynamic>{});
    final placesDetail = data['placesDetail'] as List<dynamic>? ?? data['places'] as List<dynamic>? ?? [];
    final jewelryDetail = data['jewelryDetail'] as List<dynamic>? ?? data['jewelry'] as List<dynamic>? ?? [];
    final materialDetail = data['materialDetail'] as List<dynamic>? ?? data['material'] as List<dynamic>? ?? [];
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
            padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs, horizontal: DSSpacing.sm),
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
                      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                      decoration: BoxDecoration(
                        color: _getLuckyElementColor(element).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.full),
                        border: Border.all(color: _getLuckyElementColor(element).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getLuckyElementEmoji(element), style: const TextStyle(fontSize: 14)),
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
                children: keyword.split(',').map((k) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                    border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    k.trim(),
                    style: typography.labelSmall.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
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
                    children: numbers.map((n) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.info, colors.info.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(DSRadius.full),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )).toList(),
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
                      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.sm),
                        border: Border.all(color: colors.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                          Text('피해야 할 숫자: ', style: typography.labelSmall.copyWith(color: colors.error)),
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
                      item: item['place']?.toString() ?? item['item']?.toString() ?? '',
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
                children: relationships.map((rel) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                      Expanded(
                        child: Text(
                          rel.toString(),
                          style: typography.bodySmall.copyWith(color: colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
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
                  border: Border.all(color: colors.accent.withValues(alpha: 0.15)),
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
  Widget _buildLuckySection(BuildContext context, {
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

  /// 행운 아이템 칩 빌더
  Widget _buildLuckyChip(BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color chipColor,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(color: chipColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: DSSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: typography.labelSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 아이템 목록을 칩 형태로 표시
  Widget _buildLuckyItemsChips(BuildContext context, List<dynamic> items, Color chipColor) {
    final colors = context.colors;
    final typography = context.typography;

    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DSRadius.sm),
          border: Border.all(color: chipColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          item.toString(),
          style: typography.labelSmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
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
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs, vertical: 2),
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
        return const Color(0xFF4CAF50);
      case '화':
        return const Color(0xFFE53935);
      case '토':
        return const Color(0xFFFF9800);
      case '금':
        return const Color(0xFFFFD700);
      case '수':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
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
    final bestMonths = (goalFortune['bestMonths'] as List<dynamic>?)?.cast<String>() ?? [];
    final cautionMonths = (goalFortune['cautionMonths'] as List<dynamic>?)?.cast<String>() ?? [];
    final successFactors = (goalFortune['successFactors'] as List<dynamic>?)?.cast<String>() ?? [];
    final actionItems = (goalFortune['actionItems'] as List<dynamic>?)?.cast<String>() ?? [];
    final riskAnalysis = goalFortune['riskAnalysis'] as String? ?? '';
    final travelRecommendations = goalFortune['travelRecommendations'] as Map<String, dynamic>?;

    // 프리미엄 체크 - 블러 처리
    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              if (isBlurred)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '프리미엄',
                    style: typography.labelSmall.copyWith(color: colors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 블러 또는 콘텐츠
          if (isBlurred)
            _buildBlurredPlaceholder(context, '목표별 맞춤 분석을 확인하세요')
          else ...[
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
                      child: _buildMonthBadges(context, '✨ 좋은 달', bestMonths, const Color(0xFF10B981)),
                    ),
                  if (bestMonths.isNotEmpty && cautionMonths.isNotEmpty)
                    const SizedBox(width: DSSpacing.sm),
                  if (cautionMonths.isNotEmpty)
                    Expanded(
                      child: _buildMonthBadges(context, '⚠️ 주의할 달', cautionMonths, const Color(0xFFF59E0B)),
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
                children: successFactors.map((factor) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    factor,
                    style: typography.labelSmall.copyWith(color: const Color(0xFF10B981)),
                  ),
                )).toList(),
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
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
        ?.cast<Map<String, dynamic>>() ?? [];
    final international = (travelRecommendations['international'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ?? [];
    final travelStyle = travelRecommendations['travelStyle'] as String? ?? '';
    final travelTips = (travelRecommendations['travelTips'] as List<dynamic>?)
        ?.cast<String>() ?? [];

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
                  style: typography.bodySmall.copyWith(color: colors.accent),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
  Widget _buildMonthBadges(BuildContext context, String title, List<String> months, Color color) {
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
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: months.map((month) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              month,
              style: typography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          )).toList(),
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
    final compatibilityReason = sajuAnalysis['compatibilityReason'] as String? ?? '';
    final elementalAdvice = sajuAnalysis['elementalAdvice'] as String? ?? '';
    final balanceElements = (sajuAnalysis['balanceElements'] as List<dynamic>?)?.cast<String>() ?? [];
    final strengthenTips = (sajuAnalysis['strengthenTips'] as List<dynamic>?)?.cast<String>() ?? [];

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              if (isBlurred)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '프리미엄',
                    style: typography.labelSmall.copyWith(color: colors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          if (isBlurred)
            _buildBlurredPlaceholder(context, '오행 궁합 분석을 확인하세요')
          else ...[
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getCompatibilityColor(compatibility).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '궁합: $compatibility',
                      style: typography.labelMedium.copyWith(
                        color: _getCompatibilityColor(compatibility),
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
                            style: typography.labelSmall.copyWith(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: balanceElements.map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getLuckyElementColor(e).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_getLuckyElementEmoji(e)} $e',
                                style: typography.labelSmall.copyWith(
                                  color: _getLuckyElementColor(e),
                                ),
                              ),
                            )).toList(),
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
                          style: typography.bodySmall.copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
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
        const SizedBox(height: 4),
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
                Text(_getLuckyElementEmoji(element), style: const TextStyle(fontSize: 20)),
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
      case '높음': return '💫';
      case '보통': return '🔄';
      case '주의': return '⚡';
      default: return '🔄';
    }
  }

  Color _getCompatibilityColor(String compatibility) {
    switch (compatibility) {
      case '높음': return const Color(0xFF10B981);
      case '보통': return const Color(0xFF3B82F6);
      case '주의': return const Color(0xFFF59E0B);
      default: return const Color(0xFF9E9E9E);
    }
  }

  /// 3. 월별 하이라이트 섹션 (1-3월 무료, 4-12월 프리미엄)
  Widget _buildMonthlyHighlightsSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final monthlyHighlights = (metadata['monthlyHighlights'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final blurredMonthIndices = (metadata['blurredMonthIndices'] as List<dynamic>?)?.cast<int>() ?? [];

    if (monthlyHighlights.isEmpty) return const SizedBox.shrink();

    final currentMonth = DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
            isPremium ? '12개월 전체 보기' : '1-3월 무료 • 4-12월 프리미엄',
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
                final isBlurredMonth = !isPremium && blurredMonthIndices.contains(index);
                final monthNum = index + 1;
                final isCurrentMonth = monthNum == currentMonth;

                return _buildMonthCard(
                  context,
                  monthData: monthData,
                  monthNum: monthNum,
                  isBlurred: isBlurredMonth,
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
    required bool isBlurred,
    required bool isCurrentMonth,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    final theme = monthData['theme'] as String? ?? '';
    final score = (monthData['score'] as num?)?.toInt() ?? 70;
    final advice = monthData['advice'] as String? ?? '';
    final energyLevel = monthData['energyLevel'] as String? ?? 'Medium';

    final energyColor = _getEnergyColor(energyLevel);

    return GestureDetector(
      onTap: isBlurred
          ? null
          : () {
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
            color: isCurrentMonth ? colors.accent : colors.textPrimary.withValues(alpha: 0.1),
            width: isCurrentMonth ? 2 : 1,
          ),
        ),
        child: isBlurred
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$monthNum월',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.sm),
                Icon(Icons.lock_outline, color: colors.textTertiary, size: 24),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '프리미엄',
                  style: typography.labelSmall.copyWith(color: colors.accent),
                ),
              ],
            )
          : Column(
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                const SizedBox(height: 4),
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

  Color _getEnergyColor(String energyLevel) {
    switch (energyLevel) {
      case 'High': return const Color(0xFF10B981);
      case 'Medium': return const Color(0xFF3B82F6);
      case 'Low': return const Color(0xFFF59E0B);
      default: return const Color(0xFF9E9E9E);
    }
  }

  /// 4. 행동 계획 섹션
  Widget _buildActionPlanSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final actionPlan = metadata['actionPlan'] as Map<String, dynamic>?;

    if (actionPlan == null) return const SizedBox.shrink();

    final immediate = (actionPlan['immediate'] as List<dynamic>?)?.cast<String>() ?? [];
    final shortTerm = (actionPlan['shortTerm'] as List<dynamic>?)?.cast<String>() ?? [];
    final longTerm = (actionPlan['longTerm'] as List<dynamic>?)?.cast<String>() ?? [];

    if (immediate.isEmpty && shortTerm.isEmpty && longTerm.isEmpty) {
      return const SizedBox.shrink();
    }

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              if (isBlurred)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '프리미엄',
                    style: typography.labelSmall.copyWith(color: colors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          if (isBlurred)
            _buildBlurredPlaceholder(context, '맞춤 행동 계획을 확인하세요')
          else ...[
            if (immediate.isNotEmpty)
              _buildActionPlanCategory(context, '⚡ 지금 바로 (1-2주)', immediate, const Color(0xFFEF4444)),
            if (shortTerm.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.md),
              _buildActionPlanCategory(context, '📆 단기 (1-3개월)', shortTerm, const Color(0xFFF59E0B)),
            ],
            if (longTerm.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.md),
              _buildActionPlanCategory(context, '🎯 장기 (6-12개월)', longTerm, const Color(0xFF10B981)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildActionPlanCategory(BuildContext context, String title, List<String> items, Color color) {
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
                Text('• ', style: TextStyle(color: color, fontSize: 12)),
                Expanded(
                  child: Text(
                    item,
                    style: typography.bodySmall.copyWith(color: colors.textPrimary),
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

    if (specialMessage == null || specialMessage.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
        child: isBlurred
            ? Row(
                children: [
                  const Text('💌', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '특별 메시지',
                          style: typography.labelMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '프리미엄으로 확인하세요',
                          style: typography.labelSmall.copyWith(color: colors.accent),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.lock_outline, color: colors.accent, size: 20),
                ],
              )
            : Column(
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

  /// 블러 플레이스홀더 빌더
  Widget _buildBlurredPlaceholder(BuildContext context, String message) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: colors.textTertiary, size: 32),
          const SizedBox(height: DSSpacing.sm),
          Text(
            message,
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '프리미엄 구독하기',
              style: typography.labelSmall.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
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

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              if (isBlurred)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '프리미엄',
                    style: typography.labelSmall.copyWith(color: colors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          if (isBlurred)
            _buildBlurredPlaceholder(context, '목표 달성 전략을 확인하세요')
          else ...[
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
                  strategy,
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
                        const Color(0xFF6366F1),
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
                        const Color(0xFF10B981),
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
                        const Color(0xFF10B981),
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
                        const Color(0xFFF59E0B),
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
        ],
      ),
    );
  }

  /// 3. 고민 해결책 섹션
  Widget _buildWealthConcernSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final concernResolution = metadata['concernResolution'] as Map<String, dynamic>?;

    if (concernResolution == null) return const SizedBox.shrink();

    final primaryConcern = concernResolution['primaryConcern'] as String? ?? '고민';
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
    final sajuPerspective = concernResolution['sajuPerspective'] as String? ?? '';

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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

          if (isBlurred)
            _buildBlurredPlaceholder(context, '고민 해결책을 확인하세요')
          else ...[
            // 분석
            if (analysis.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(DSSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
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
                          color: const Color(0xFF10B981),
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
        ],
      ),
    );
  }

  /// 4. 투자 인사이트 섹션 (관심 분야별)
  Widget _buildWealthInvestmentInsightsSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final investmentInsights = metadata['investmentInsights'] as Map<String, dynamic>?;
    final surveyData = metadata['surveyData'] as Map<String, dynamic>?;
    final interests = (surveyData?['interests'] as List?)?.cast<String>() ?? [];

    if (investmentInsights == null || interests.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              if (isBlurred)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '프리미엄',
                    style: typography.labelSmall.copyWith(color: colors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          if (isBlurred)
            _buildBlurredPlaceholder(context, '분야별 상세 분석을 확인하세요')
          else
            ...interests.map((interest) {
              final insightData = investmentInsights[interest] as Map<String, dynamic>?;
              if (insightData == null) return const SizedBox.shrink();
              return _buildWealthInsightCard(context, interest, insightData);
            }),
        ],
      ),
    );
  }

  /// 투자 인사이트 개별 카드
  Widget _buildWealthInsightCard(BuildContext context, String interest, Map<String, dynamic> data) {
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
      if (data['recommendedType'] != null) additionalInfo['추천 유형'] = toStringValue(data['recommendedType']);
      if (data['timing'] != null) additionalInfo['타이밍'] = toStringValue(data['timing']);
      if (data['direction'] != null) additionalInfo['추천 방향'] = toStringValue(data['direction']);
    } else if (interest == 'side') {
      if (data['recommendedAreas'] != null) additionalInfo['추천 분야'] = toStringValue(data['recommendedAreas']);
      if (data['incomeExpectation'] != null) additionalInfo['예상 수입'] = toStringValue(data['incomeExpectation']);
      if (data['startTiming'] != null) additionalInfo['시작 시기'] = toStringValue(data['startTiming']);
    } else if (interest == 'stock') {
      if (data['recommendedSectors'] != null) additionalInfo['추천 섹터'] = toStringValue(data['recommendedSectors']);
      if (data['timing'] != null) additionalInfo['매매 타이밍'] = toStringValue(data['timing']);
      if (data['riskLevel'] != null) additionalInfo['리스크'] = toStringValue(data['riskLevel']);
    } else if (interest == 'crypto') {
      if (data['marketOutlook'] != null) additionalInfo['시장 전망'] = toStringValue(data['marketOutlook']);
      if (data['timing'] != null) additionalInfo['진입 시기'] = toStringValue(data['timing']);
    } else if (interest == 'saving') {
      if (data['recommendedProducts'] != null) additionalInfo['추천 상품'] = toStringValue(data['recommendedProducts']);
      if (data['targetRate'] != null) additionalInfo['목표 금리'] = toStringValue(data['targetRate']);
    } else if (interest == 'business') {
      if (data['recommendedFields'] != null) additionalInfo['추천 분야'] = toStringValue(data['recommendedFields']);
      if (data['timing'] != null) additionalInfo['시작 시기'] = toStringValue(data['timing']);
      if (data['partnerAdvice'] != null) additionalInfo['파트너'] = toStringValue(data['partnerAdvice']);
    }

    final caution = data['caution'] as String? ?? '';
    final sajuMatch = data['sajuMatch'] as String? ?? '';

    // 점수 색상
    final scoreColor = score >= 80
        ? const Color(0xFF10B981)
        : score >= 60
            ? const Color(0xFF6366F1)
            : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.textPrimary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
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
                        color: const Color(0xFFB45309),
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

    if (monthlyFlow == null || monthlyFlow.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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

          if (isBlurred)
            _buildBlurredPlaceholder(context, '월별 재물 흐름을 확인하세요')
          else
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
  Widget _buildMonthFlowCard(BuildContext context, String month, int score, String trend, String tip) {
    final colors = context.colors;
    final typography = context.typography;

    final trendEmoji = trend == 'up' ? '📈' : trend == 'down' ? '📉' : '➡️';
    final scoreColor = score >= 80
        ? const Color(0xFF10B981)
        : score >= 60
            ? const Color(0xFF6366F1)
            : score >= 40
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444);

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
          const SizedBox(height: 4),
          Text(trendEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
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
            const SizedBox(height: 4),
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
    final actionItems = (metadata['actionItems'] as List<dynamic>?)?.cast<String>() ?? [];

    if (actionItems.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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

          if (isBlurred)
            _buildBlurredPlaceholder(context, '실천 항목을 확인하세요')
          else
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
  Widget _buildWealthInfoCard(BuildContext context, String title, String content, Color accentColor) {
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
          const SizedBox(height: 4),
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
    if (examDateStr != null) {
      try {
        final examDate = DateTime.parse(examDateStr);
        final today = DateTime.now();
        daysRemaining = examDate.difference(DateTime(today.year, today.month, today.day)).inDays;
      } catch (_) {}
    }

    String ddayText;
    Color ddayColor;
    if (daysRemaining > 0) {
      ddayText = 'D-$daysRemaining';
      ddayColor = daysRemaining <= 7 ? Colors.red : Colors.orange;
    } else if (daysRemaining == 0) {
      ddayText = 'D-Day';
      ddayColor = Colors.red;
    } else {
      ddayText = 'D+${daysRemaining.abs()}';
      ddayColor = colors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
                            examScore >= 80 ? Colors.green :
                            examScore >= 60 ? Colors.orange : Colors.red,
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
              children: hashtags.map((tag) => Container(
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
              )).toList(),
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
    final mentalDefenseDesc = examStats['mental_defense_desc'] as String? ??
                               '시험장의 소음과 긴장감을 차단하는 집중력';
    final memoryAcceleration = examStats['memory_acceleration'] as String? ?? 'UP';
    final memoryAccelerationDesc = examStats['memory_acceleration_desc'] as String? ??
                                    '지금 보는 오답 노트가 머릿속에 바로 각인되는 상태';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              color: Colors.blue,
            ),
            const SizedBox(height: DSSpacing.md),

            // 멘탈 방어력
            _buildStatProgressBar(
              context,
              label: '멘탈 방어력',
              value: mentalDefense,
              description: mentalDefenseDesc,
              color: Colors.green,
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
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : memoryAcceleration == 'DOWN'
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : Colors.orange.withValues(alpha: 0.2),
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
                                      ? Colors.green
                                      : memoryAcceleration == 'DOWN'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  memoryAcceleration,
                                  style: typography.labelMedium.copyWith(
                                    color: memoryAcceleration == 'UP'
                                        ? Colors.green
                                        : memoryAcceleration == 'DOWN'
                                            ? Colors.red
                                            : Colors.orange,
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
    final todayStrategy = metadata['today_strategy'] as Map<String, dynamic>? ?? {};
    final mainAction = todayStrategy['main_action'] as String? ??
                       '가장 헷갈렸던 오답 노트를 딱 10분만 다시 훑어보세요';
    final actionReason = todayStrategy['action_reason'] as String? ??
                         '그 10분이 시험장에서 1점을 결정합니다';
    final luckyFood = todayStrategy['lucky_food'] as String? ?? '다크 초콜릿 한 조각';
    final luckyFoodReason = todayStrategy['lucky_food_reason'] as String? ??
                            '두뇌 회전을 돕는 오늘의 행운 아이템';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
                color: Colors.orange.withValues(alpha: 0.1),
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
                          color: Colors.orange,
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

  /// 시험운: 영물의 기개
  Widget _buildSpiritAnimalSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // spirit_animal 객체에서 데이터 추출
    final spiritAnimal = metadata['spirit_animal'] as Map<String, dynamic>? ?? {};
    final animal = spiritAnimal['animal'] as String? ?? '호랑이';
    final message = spiritAnimal['message'] as String? ??
                    '호랑이의 눈매처럼 날카로운 통찰력이 당신에게 깃듭니다';
    final direction = spiritAnimal['direction'] as String? ?? '남쪽';
    final directionTip = spiritAnimal['direction_tip'] as String? ??
                         '남쪽 향해 공부하면 막힌 아이디어가 호랑이 기세처럼 터져 나옵니다';

    // 영물별 이모지 매핑
    final animalEmoji = {
      '호랑이': '🐯',
      '용': '🐉',
      '봉황': '🦅',
      '거북이': '🐢',
      '백호': '🐅',
    }[animal] ?? '🐯';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.15),
              Colors.orange.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Text(animalEmoji, style: typography.headingMedium),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '$animal의 기개',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 영물 메시지
            Text(
              '"$message"',
              style: typography.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: DSSpacing.md),

            // 행운의 방향
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Row(
                children: [
                  Text('💡', style: typography.bodyLarge),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '행운의 방향: $direction',
                          style: typography.labelMedium.copyWith(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: DSSpacing.xxs),
                        Text(
                          directionTip,
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
          ],
        ),
      ),
    );
  }

  /// 시험운: D-day & 합격 가능성 배너 (레거시 - 제거 예정)
  Widget _buildExamDdaySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용
    final examScore = metadata['score'] as int? ?? fortune.overallScore ?? 75;
    final passMessage = metadata['pass_possibility'] as String? ?? '합격 가능성이 좋습니다!';
    final examKeyword = metadata['exam_keyword'] as String? ?? '합격';
    final examTypeLabel = metadata['exam_type'] as String? ?? metadata['title'] as String? ?? '시험';

    // D-day 계산: exam_date에서 계산
    int daysRemaining = 0;
    final examDateStr = metadata['exam_date'] as String?;
    if (examDateStr != null) {
      try {
        final examDate = DateTime.parse(examDateStr);
        final today = DateTime.now();
        daysRemaining = examDate.difference(DateTime(today.year, today.month, today.day)).inDays;
      } catch (_) {}
    }

    // D-day 텍스트
    String ddayText;
    Color ddayColor;
    if (daysRemaining > 0) {
      ddayText = 'D-$daysRemaining';
      ddayColor = daysRemaining <= 7 ? Colors.red : Colors.orange;
    } else if (daysRemaining == 0) {
      ddayText = 'D-Day';
      ddayColor = Colors.red;
    } else {
      ddayText = 'D+${daysRemaining.abs()}';
      ddayColor = colors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
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
            // D-day 배지
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
                    style: typography.headingSmall.copyWith(
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
            const SizedBox(height: DSSpacing.md),

            // 합격 가능성 원형 게이지
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 원
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      backgroundColor: colors.divider,
                      valueColor: AlwaysStoppedAnimation(colors.divider),
                    ),
                  ),
                  // 진행률 원
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: examScore / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        examScore >= 80 ? Colors.green :
                        examScore >= 60 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                  // 점수 텍스트
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$examScore',
                        style: typography.headingLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        examKeyword,
                        style: typography.labelMedium.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.sm),

            // 합격 메시지
            Text(
              '합격 가능성',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              passMessage,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 시험운: 행운 정보 그리드
  Widget _buildExamLuckyInfoSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용
    final luckyHours = metadata['lucky_hours'] as String? ?? '';
    final focusSubject = metadata['focus_subject'] as String? ?? '';
    final examKeyword = metadata['exam_keyword'] as String? ?? '';
    final preparationStatus = metadata['preparation_status'] as String? ?? '';
    final timePoint = metadata['time_point'] as String? ?? '';

    // 아무 데이터도 없으면 표시하지 않음
    if (luckyHours.isEmpty && focusSubject.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;

    // 시험 시점 라벨 변환
    String timePointLabel = '';
    switch (timePoint) {
      case 'preparation':
        timePointLabel = '장기 준비';
        break;
      case 'intensive':
        timePointLabel = '집중 준비';
        break;
      case 'final_week':
        timePointLabel = '마지막 주';
        break;
      case 'test_day':
        timePointLabel = '시험 당일';
        break;
    }

    final items = [
      ('⏰', '행운의 시간', luckyHours),
      ('🎯', '집중 과목', focusSubject),
      ('🏷️', '시험운 키워드', examKeyword),
      ('📚', '준비 상태', preparationStatus),
      if (timePointLabel.isNotEmpty) ('📅', '시험 시점', timePointLabel),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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

          if (isBlurred)
            _buildBlurredPlaceholder(context, '프리미엄으로 행운 정보 확인')
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: DSSpacing.sm,
              mainAxisSpacing: DSSpacing.sm,
              children: items.where((item) => item.$3.isNotEmpty).map((item) {
                return Container(
                  padding: const EdgeInsets.all(DSSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                    border: Border.all(color: colors.accent.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Text(item.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.$2,
                              style: typography.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              item.$3,
                              style: typography.bodySmall.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
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

    final isBlurred = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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

          if (isBlurred)
            _buildBlurredPlaceholder(context, 'D-day 조언 확인하기')
          else
            ...ddayAdvice.asMap().entries.map((entry) {
              final index = entry.key;
              final advice = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.accentSecondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                  border: Border.all(color: colors.accentSecondary.withValues(alpha: 0.1)),
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

  /// 시험운: 공부법 & 집중력
  Widget _buildExamStudyTipsSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용: study_methods (배열)
    final studyMethods = (metadata['study_methods'] as List<dynamic>?)?.cast<String>() ?? [];

    if (studyMethods.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;

    // 아이콘 목록
    const icons = ['💡', '🎯', '⏰', '🧠', '📖'];
    final tips = studyMethods.asMap().entries.map((entry) {
      final index = entry.key;
      final method = entry.value;
      return (icons[index % icons.length], '추천 학습법 ${index + 1}', method);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '공부법 & 집중력',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          if (isBlurred)
            _buildBlurredPlaceholder(context, '공부법 팁 확인하기')
          else
            ...tips.where((tip) => tip.$3.isNotEmpty).map((tip) {
              return Container(
                margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.$2,
                            style: typography.labelSmall.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tip.$3,
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
            }),
        ],
      ),
    );
  }

  /// 시험운: 주의사항
  Widget _buildExamWarningsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용: cautions (배열)
    final warnings = (metadata['cautions'] as List<dynamic>?)?.cast<String>() ?? [];

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '주의사항',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 주의사항 리스트
          ...warnings.map((warning) {
            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      warning,
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

  /// 시험운: 멘탈 관리
  Widget _buildExamMentalCareSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};

    // Edge Function 실제 필드명 사용
    final positiveMessage = metadata['positive_message'] as String? ?? '';
    final strengths = (metadata['strengths'] as List<dynamic>?)?.cast<String>() ?? [];

    if (positiveMessage.isEmpty && strengths.isEmpty) return const SizedBox.shrink();

    final isBlurred = !isPremium;
    final affirmation = positiveMessage; // positive_message를 affirmation으로 사용

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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

          if (isBlurred)
            _buildBlurredPlaceholder(context, '멘탈 관리 팁 확인하기')
          else ...[
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
        ],
      ),
    );
  }

  /// 시험운: 멘탈 팁 카드 빌더
  Widget _buildExamMentalTipCard(BuildContext context, String emoji, String title, String content) {
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
                const SizedBox(height: 2),
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

  /// 시험운: 사주 분석 (Premium)
  Widget _buildExamSajuSection(BuildContext context, bool isPremium) {
    final colors = context.colors;
    final typography = context.typography;
    final metadata = fortune.metadata ?? fortune.additionalInfo ?? {};
    final sajuAnalysis = metadata['sajuAnalysis'] as Map<String, dynamic>?;

    if (sajuAnalysis == null) return const SizedBox.shrink();

    final isBlurred = !isPremium;
    final elementStrength = sajuAnalysis['elementStrength'] as String? ?? '';
    final studyElement = sajuAnalysis['studyElement'] as String? ?? '';
    final examDayEnergy = sajuAnalysis['examDayEnergy'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('☯️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '사주 기반 분석',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSRadius.xs),
                ),
                child: Text(
                  'Premium',
                  style: typography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          if (isBlurred)
            _buildBlurredPlaceholder(context, '사주 분석 확인하기')
          else ...[
            if (elementStrength.isNotEmpty)
              _buildExamSajuItem(context, '🔥', '오행 강점', elementStrength),
            if (studyElement.isNotEmpty)
              _buildExamSajuItem(context, '📖', '학업 기운', studyElement),
            if (examDayEnergy.isNotEmpty)
              _buildExamSajuItem(context, '📅', '시험일 기운', examDayEnergy),
          ],
        ],
      ),
    );
  }

  /// 시험운: 사주 분석 아이템 빌더
  Widget _buildExamSajuItem(BuildContext context, String emoji, String title, String content) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(color: colors.accent.withValues(alpha: 0.1)),
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
                const SizedBox(height: 2),
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
    final recommendedActivities = metadata['recommended_activities'] as List<dynamic>?;
    // ✅ 신규: 오행 기반 개인화 조언
    final elementAdvice = metadata['element_advice'] as Map<String, dynamic>?;
    final personalizedFeedback = metadata['personalized_feedback'] as Map<String, dynamic>?;

    // 건강 accent 색상 (청록)
    const healthAccent = Color(0xFF38A169);
    const healthAccentLight = Color(0xFF68D391);

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
            _buildElementAdviceSection(context, elementAdvice, isDark, healthAccent, healthAccentLight),
            const SizedBox(height: DSSpacing.md),
          ],

          // ✅ 개인화 피드백 (이전 설문 비교 - 신규)
          if (personalizedFeedback != null) ...[
            _buildPersonalizedFeedbackSection(context, personalizedFeedback, isDark, healthAccent),
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
                  ? _buildStructuredExerciseAdvice(context, exerciseAdvice, isDark, healthAccent, healthAccentLight)
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
                        Text('•', style: typography.bodySmall.copyWith(color: colors.textSecondary)),
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
          if (recommendedActivities != null && recommendedActivities.isNotEmpty) ...[
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
                        Text('•', style: typography.bodySmall.copyWith(color: healthAccent)),
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
    debugPrint('🏋️ [_buildExerciseDetailSection] Building exercise detail section');
    debugPrint('🏋️ [_buildExerciseDetailSection] exerciseData keys: ${exerciseData.keys.toList()}');
    debugPrint('🏋️ [_buildExerciseDetailSection] exerciseData: $exerciseData');

    final recommendedExercise = exerciseData['recommendedExercise'] as Map<String, dynamic>?;
    final todayRoutine = exerciseData['todayRoutine'] as Map<String, dynamic>?;
    final weeklyPlan = exerciseData['weeklyPlan'] as Map<String, dynamic>?;
    final optimalTime = exerciseData['optimalTime'] as Map<String, dynamic>?;
    final injuryPrevention = exerciseData['injuryPrevention'] as Map<String, dynamic>?;
    final nutritionTip = exerciseData['nutritionTip'] as Map<String, dynamic>?;

    debugPrint('🏋️ [_buildExerciseDetailSection] recommendedExercise: $recommendedExercise');
    debugPrint('🏋️ [_buildExerciseDetailSection] todayRoutine: $todayRoutine');
    debugPrint('🏋️ [_buildExerciseDetailSection] optimalTime: $optimalTime');

    // 운동 accent 색상 (오렌지)
    const exerciseAccent = Color(0xFFED8936);
    const exerciseAccentLight = Color(0xFFFBD38D);

    // 운동 블러 섹션 정의
    const exerciseBlurredSections = ['todayRoutine', 'weeklyPlan', 'injuryPrevention'];

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
          // 📋 오늘의 루틴 (프리미엄)
          // ============================================================
          if (todayRoutine != null) ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: exerciseBlurredSections,
              sectionKey: 'todayRoutine',
              fortuneType: 'exercise',
              sigmaX: 8.0,
              sigmaY: 8.0,
              child: _buildHealthSection(
                context,
                icon: '📋',
                title: '오늘의 루틴',
                child: _buildRoutineDetail(context, todayRoutine, exerciseAccent),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // 📅 주간 계획 (프리미엄)
          // ============================================================
          if (weeklyPlan != null) ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: exerciseBlurredSections,
              sectionKey: 'weeklyPlan',
              fortuneType: 'exercise',
              sigmaX: 8.0,
              sigmaY: 8.0,
              child: _buildHealthSection(
                context,
                icon: '📅',
                title: '주간 운동 계획',
                child: _buildWeeklyPlanDetail(context, weeklyPlan, exerciseAccent),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // ============================================================
          // 🛡️ 부상 예방 (프리미엄)
          // ============================================================
          if (injuryPrevention != null) ...[
            UnifiedBlurWrapper(
              isBlurred: _isBlurred,
              blurredSections: exerciseBlurredSections,
              sectionKey: 'injuryPrevention',
              fortuneType: 'exercise',
              sigmaX: 8.0,
              sigmaY: 8.0,
              child: _buildHealthSection(
                context,
                icon: '🛡️',
                title: '부상 예방 가이드',
                child: _buildInjuryPreventionDetail(context, injuryPrevention, exerciseAccent),
              ),
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
              child: _buildNutritionTipDetail(context, nutritionTip, exerciseAccent),
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
                  color: _getIntensityColor(intensity).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getIntensityLabel(intensity),
                  style: typography.labelSmall.copyWith(
                    color: _getIntensityColor(intensity),
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
              const SizedBox(width: 4),
              Text(
                duration,
                style: typography.bodySmall.copyWith(color: colors.textSecondary),
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
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '주의사항',
                      style: typography.labelSmall.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...precautions.map((p) => Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•', style: typography.bodySmall.copyWith(color: Colors.orange[700])),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.toString(),
                          style: typography.bodySmall.copyWith(
                            color: Colors.orange[800],
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
                  const SizedBox(width: 8),
                  Text(
                    altMap['name'] as String? ?? '',
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (altMap['reason'] != null) ...[
                    const SizedBox(width: 8),
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
      case 'low': return '저강도';
      case 'medium': return '중강도';
      case 'high': return '고강도';
      default: return intensity;
    }
  }

  /// 강도 색상 (영어/한글 모두 지원)
  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '가벼움':
      case '저강도':
        return const Color(0xFF68D391); // 연두
      case 'medium':
      case '중간':
      case '중강도':
        return const Color(0xFFFFA726); // 주황
      case 'high':
      case '높음':
      case '고강도':
        return const Color(0xFFEF5350); // 빨강
      default:
        return const Color(0xFF38A169);
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
                const SizedBox(width: 4),
                Text(
                  '워밍업 ${warmup['duration'] ?? '10분'}',
                  style:
                      typography.bodySmall.copyWith(color: colors.textSecondary),
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
                    const SizedBox(width: 8),
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
                      color:
                          _getIntervalColor(interval['intensity'] as String?),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      interval['phase'] as String? ?? '',
                      style: typography.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  Text(
                    interval['duration'] as String? ?? '',
                    style:
                        typography.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(width: 8),
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

  /// 인터벌 강도 색상
  Color _getIntervalColor(String? intensity) {
    if (intensity == null) return Colors.grey;
    final percent = int.tryParse(intensity.replaceAll('%', '')) ?? 50;
    if (percent <= 40) return Colors.green;
    if (percent <= 60) return Colors.yellow.shade700;
    if (percent <= 80) return Colors.orange;
    return Colors.red;
  }

  /// 주간 계획 상세 표시
  Widget _buildWeeklyPlanDetail(
      BuildContext context, Map<String, dynamic> weeklyPlan, Color accentColor) {
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
                    const SizedBox(height: 4),
                    Text(
                      isRest ? '쉼' : _getShortActivity(activity),
                      style: typography.labelSmall.copyWith(
                        color: isRest ? colors.textTertiary : colors.textPrimary,
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
                          color: Colors.orange.shade700,
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
                  style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
                  style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
          const SizedBox(height: 4),
          ...recoveryTips.take(2).map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $tip',
                  style:
                      typography.bodySmall.copyWith(color: colors.textSecondary),
                ),
              )),
        ],
      ],
    );
  }

  /// 영양 팁 상세 표시
  Widget _buildNutritionTipDetail(
      BuildContext context, Map<String, dynamic> nutritionTip, Color accentColor) {
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
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '운동 전',
                  style: typography.labelSmall.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preworkout,
                  style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '운동 후',
                  style: typography.labelSmall.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  postworkout,
                  style: typography.bodySmall.copyWith(color: colors.textPrimary),
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
                  style: typography.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 루틴 요약 빌드 (헬스/요가/카디오/스포츠)
  Widget _buildRoutineSummary(
      BuildContext context, Map<String, dynamic> routine, Color accentColor) {
    final typography = context.typography;
    final colors = context.colors;

    // 헬스 루틴
    if (routine['gymRoutine'] != null) {
      final gym = routine['gymRoutine'] as Map<String, dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${gym['splitType'] ?? ''} - ${gym['todayFocus'] ?? ''}',
            style: typography.labelLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '${(gym['exercises'] as List?)?.length ?? 0}개 운동',
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    // 요가 루틴
    if (routine['yogaRoutine'] != null) {
      final yoga = routine['yogaRoutine'] as Map<String, dynamic>;
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
          const SizedBox(height: DSSpacing.xs),
          Text(
            '${(yoga['poses'] as List?)?.length ?? 0}개 동작',
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    // 카디오 루틴
    if (routine['cardioRoutine'] != null) {
      final cardio = routine['cardioRoutine'] as Map<String, dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cardio['totalDistance'] ?? ''} ${cardio['type'] ?? ''}',
            style: typography.labelLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '목표 페이스: ${cardio['targetPace'] ?? '-'}',
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    // 스포츠 루틴
    if (routine['sportsRoutine'] != null) {
      final sports = routine['sportsRoutine'] as Map<String, dynamic>;
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
          const SizedBox(height: DSSpacing.xs),
          Text(
            '${(sports['drills'] as List?)?.length ?? 0}개 드릴',
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
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
    final vulnerableOrgans = elementAdvice['vulnerable_organs'] as List<dynamic>?;
    final vulnerableSymptoms = elementAdvice['vulnerable_symptoms'] as List<dynamic>?;
    final recommendedFoods = elementAdvice['recommended_foods'] as List<dynamic>?;

    // 오행 색상 매핑
    const elementColors = {
      '목': Color(0xFF38A169), // 녹색
      '화': Color(0xFFE53E3E), // 빨강
      '토': Color(0xFFD69E2E), // 황토
      '금': Color(0xFFA0AEC0), // 은색
      '수': Color(0xFF3182CE), // 파랑
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
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
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
                  Text('💪 주의 장기: ', style: typography.labelSmall.copyWith(color: colors.textSecondary)),
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
            if (vulnerableSymptoms != null && vulnerableSymptoms.isNotEmpty) ...[
              Text(
                '⚠️ 주의 증상: ${vulnerableSymptoms.take(3).join(', ')}',
                style: typography.bodySmall.copyWith(color: colors.textSecondary),
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
                            style: typography.bodySmall.copyWith(color: colors.textSecondary),
                            children: [
                              TextSpan(
                                text: item,
                                style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
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
    final improvements = (feedback['improvements'] as List<dynamic>?)?.cast<String>() ?? [];
    final concerns = (feedback['concerns'] as List<dynamic>?)?.cast<String>() ?? [];
    final encouragements = (feedback['encouragements'] as List<dynamic>?)?.cast<String>() ?? [];

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
            color: const Color(0xFF38A169),
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
            color: const Color(0xFFD69E2E),
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
              const Color(0xFFFFA726).withValues(alpha: isDark ? 0.3 : 0.2),
              const Color(0xFFFFCC02).withValues(alpha: isDark ? 0.2 : 0.1),
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

        if (weekly != null)
          const SizedBox(height: DSSpacing.md),

        // 주간 운동 계획 그리드
        if (weekly != null)
          _buildWeeklyScheduleGrid(context, weekly, isDark, healthAccent, healthAccentLight),

        // 전체 조언 배너
        if (overallTip != null && overallTip.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          _buildOverallTipBanner(context, overallTip, isDark, healthAccent, healthAccentLight),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                _buildExerciseInfoBadge(context, Icons.timer_outlined, duration, isDark, healthAccent),
              if (intensity.isNotEmpty)
                _buildExerciseInfoBadge(context, Icons.speed_outlined, intensity, isDark, _getIntensityColor(intensity)),
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
                  color: Color(0xFFFFA726),
                ),
                const SizedBox(width: 4),
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
            style: TextStyle(
              fontSize: 10,
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
          const SizedBox(height: 4),
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
            final itemWidth = (constraints.maxWidth - 36) / 7; // 36 = 6 gaps * 6px

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

    final bgColor = isRest
        ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
        : healthAccent.withValues(alpha: isDark ? 0.2 : 0.1);

    final borderColor = isRest
        ? Colors.transparent
        : healthAccent.withValues(alpha: 0.3);

    final textColor = isRest
        ? colors.textSecondary.withValues(alpha: 0.6)
        : (isDark ? healthAccentLight : healthAccent);

    // 긴 텍스트 자르기
    final truncated = activity.length <= 6 ? activity : '${activity.substring(0, 4)}...';

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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          // 활동
          Text(
            truncated,
            style: TextStyle(
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
      padding: const EdgeInsets.fromLTRB(DSSpacing.md, DSSpacing.sm, DSSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B35).withValues(alpha: 0.15),
              const Color(0xFFFF9500).withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
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
                      color: const Color(0xFFFF6B35),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
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
      padding: const EdgeInsets.fromLTRB(DSSpacing.md, DSSpacing.md, DSSpacing.md, 0),
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
  Widget _buildMbtiDimensionCard(BuildContext context, MbtiDimensionFortune dimension) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    color: isDark ? dimension.color : dimension.color.withValues(alpha: 0.9),
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
                    color: isDark ? dimension.color : dimension.color.withValues(alpha: 0.9),
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
              Text('💡', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
              const SizedBox(width: 4),
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
                  Text(dimension.warningIcon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dimension.warning!,
                      style: typography.bodySmall.copyWith(
                        color: isDark ? colors.error : colors.error.withValues(alpha: 0.9),
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
    final typography = context.typography;
    final wishData = _wishData;
    if (wishData?.dragonMessage == null) return const SizedBox.shrink();

    final dragonMsg = wishData!.dragonMessage!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.9),
            const Color(0xFF0D47A1).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.3),
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
              color: Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishData = _wishData;
    if (wishData?.fortuneFlow == null) return const SizedBox.shrink();

    final flow = wishData!.fortuneFlow!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              Text('운의 흐름', style: typography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 성취 가능성 레벨
          _buildFlowItem(context, '✨', '성취 가능성', flow.achievementLevel, _getAchievementColor(flow.achievementLevel)),

          // 행운의 타이밍
          _buildFlowItem(context, '⏰', '행운의 시간', flow.luckyTiming, colors.accent),

          // 키워드 해시태그
          if (flow.keywords.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: flow.keywords.map((keyword) => Container(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
                child: Text(
                  keyword,
                  style: typography.labelSmall.copyWith(color: colors.accent),
                ),
              )).toList(),
            ),
          ],

          const SizedBox(height: DSSpacing.md),

          // 도움 요소
          if (flow.helper.isNotEmpty)
            _buildFlowItem(context, '👤', '도움이 되는 것', flow.helper, colors.success),

          // 주의 요소
          if (flow.obstacle.isNotEmpty)
            _buildFlowItem(context, '⚠️', '주의할 것', flow.obstacle, colors.warning),
        ],
      ),
    );
  }

  Widget _buildFlowItem(BuildContext context, String emoji, String label, String value, Color accentColor) {
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
                Text(label, style: typography.labelSmall.copyWith(color: colors.textSecondary)),
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

  Color _getAchievementColor(String level) {
    switch (level) {
      case '매우 높음':
        return const Color(0xFF4CAF50); // Green
      case '높음':
        return const Color(0xFF8BC34A); // Light Green
      case '보통':
        return const Color(0xFFFFC107); // Amber
      case '노력 필요':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// 🍀 행운 미션 섹션 (item, place, color with reasons)
  Widget _buildWishLuckyMissionSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishData = _wishData;
    if (wishData?.luckyMission == null) return const SizedBox.shrink();

    final mission = wishData!.luckyMission!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              Text('오늘의 행운 미션', style: typography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colors.background.withValues(alpha: 0.5) : colors.surface,
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
                    Text(title, style: typography.labelSmall.copyWith(color: colors.textSecondary)),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
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
      '금색': const Color(0xFFFFD700),
      '초록색': Colors.green,
      '파란색': Colors.blue,
      '남색': Colors.indigo,
      '보라색': Colors.purple,
      '하얀색': Colors.white,
      '검은색': Colors.black,
      '회색': Colors.grey,
    };
    return colorMap[colorName] ?? Colors.blue;
  }

  /// 💎 용의 지혜 섹션 (pearl_message, wisdom)
  Widget _buildWishDragonWisdomSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishData = _wishData;
    if (wishData?.dragonMessage == null) return const SizedBox.shrink();

    final dragonMsg = wishData!.dragonMessage!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF37474F), const Color(0xFF263238)]
              : [const Color(0xFFF5F5F5), const Color(0xFFEEEEEE)],
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
                      style: typography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 4),
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
                      style: typography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 4),
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
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
                Text('공감', style: typography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
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
                Text('희망', style: typography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
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
                Text('응원', style: typography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishData = _wishData;
    if (wishData == null || wishData.advice.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              Text('오늘의 실천 조언', style: typography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              Text('세부 운세', style: typography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
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
                  Text(item['emoji'] as String, style: const TextStyle(fontSize: 18)),
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
                        const SizedBox(height: 4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final luckyItems = _talismanLuckyItems;
    if (luckyItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              Text('행운 아이템', style: typography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: luckyItems.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                item,
                style: typography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// 부적 주의사항 섹션
  Widget _buildTalismanWarningsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warnings = _talismanWarnings;
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
              Text('주의사항', style: typography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
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
    if (_isFamilyHealth) return const Color(0xFF38A169);     // 청록 (건강)
    if (_isFamilyWealth) return const Color(0xFFD69E2E);     // 금색 (재물)
    if (_isFamilyRelationship) return const Color(0xFFE91E63); // 핑크 (관계)
    if (_isFamilyChildren) return const Color(0xFF2196F3);   // 파랑 (자녀)
    if (_isFamilyChange) return const Color(0xFF9C27B0);     // 보라 (변화)
    return const Color(0xFF9B59B6);
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
    if (categories == null || categories.isEmpty) return const SizedBox.shrink();

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
                    Text('✓', style: typography.bodySmall.copyWith(color: accent)),
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
                    Text('→', style: typography.bodySmall.copyWith(color: colors.textTertiary)),
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
              _buildFamilyFlowItem(context, '다음 달', next, colors.textTertiary, isDark),
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

  Widget _buildFamilyFlowItem(BuildContext context, String label, String content, Color labelColor, bool isDark) {
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
                  Text('•', style: typography.bodySmall.copyWith(color: accent)),
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
    const warningColor = Color(0xFFE53E3E); // 빨간색

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
                    Text('!', style: typography.bodySmall.copyWith(
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
      'skinship' => ('🤗', const Color(0xFFFF6B9D)),
      'play' => ('🎾', const Color(0xFF4CAF50)),
      'environment' => ('🏠', const Color(0xFF2196F3)),
      'communication' => ('💬', const Color(0xFFFF9800)),
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
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
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
                    padding: const EdgeInsets.all(8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
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
      'comfort' => ('🥺', const Color(0xFF9C27B0), '💜'),
      'excitement' => ('🤩', const Color(0xFFFF9800), '⭐'),
      'gratitude' => ('🥰', const Color(0xFFE91E63), '💕'),
      'longing' => ('😢', const Color(0xFF2196F3), '💙'),
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

    final shouldBlur = !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: UnifiedBlurWrapper(
        isBlurred: shouldBlur,
        blurredSections: shouldBlur ? ['pets_voice'] : [],
        sectionKey: 'pets_voice',
        fortuneType: 'pet-compatibility',
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
                        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Center(
                        child: Text(petEmoji, style: const TextStyle(fontSize: 28)),
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
                              const SizedBox(width: 4),
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
                          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
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
      ),
    );
  }
}

/// 점수 원형 위젯
class _FortuneScoreCircle extends StatefulWidget {
  final int score;
  final double size;

  const _FortuneScoreCircle({
    required this.score,
    this.size = 72,
  });

  @override
  State<_FortuneScoreCircle> createState() => _FortuneScoreCircleState();
}

class _FortuneScoreCircleState extends State<_FortuneScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final displayScore = (progress * 100).round();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ScoreCirclePainter(
              progress: progress,
              backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
              progressColor: _getScoreColor(widget.score),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayScore',
                    style: typography.headingMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '점',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFF3B82F6); // Blue
    if (score >= 40) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ScoreCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 카테고리 타일 위젯
class _FortuneCategoryTile extends StatelessWidget {
  final String title;
  final String emoji;
  final int? score;
  final String description;

  const _FortuneCategoryTile({
    required this.title,
    required this.emoji,
    this.score,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(DSRadius.md),
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
                Row(
                  children: [
                    Text(
                      title,
                      style: typography.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (score != null) ...[
                      const SizedBox(width: DSSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score!).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          '$score점',
                          style: typography.labelSmall.copyWith(
                            color: _getScoreColor(score!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// 육각형 점수 칩
class _HexagonScoreChip extends StatelessWidget {
  final String emoji;
  final String title;
  final int score;

  const _HexagonScoreChip({
    required this.emoji,
    required this.title,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            title,
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: typography.labelMedium.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// 행운 아이템 칩
class _LuckyItemChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _LuckyItemChip({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accentSecondary.withValues(alpha: 0.1),
            colors.accentSecondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accentSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 로또 번호 공 위젯
/// 번호 범위에 따른 색상:
/// 1-10: 노랑, 11-20: 파랑, 21-30: 빨강, 31-40: 회색, 41-45: 초록
class _LottoBall extends StatelessWidget {
  final int number;

  const _LottoBall({required this.number});

  Color get _ballColor {
    if (number <= 10) return const Color(0xFFFFC107); // 노랑
    if (number <= 20) return const Color(0xFF2196F3); // 파랑
    if (number <= 30) return const Color(0xFFE91E63); // 빨강
    if (number <= 40) return const Color(0xFF9E9E9E); // 회색
    return const Color(0xFF4CAF50); // 초록
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            _ballColor.withValues(alpha: 0.9),
            _ballColor,
            _ballColor.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _ballColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
