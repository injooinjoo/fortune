import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/exercise_fortune_model.dart';
import '../../../../core/design_system/tokens/ds_obangseok_colors.dart';
import '../../../../core/widgets/unified_button.dart' show UnifiedButton, BottomButtonSpacing;
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/widgets/simple_blur_overlay.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/providers.dart';

/// 운동 운세 페이지
///
/// 3단계 입력 + 결과 표시
/// - Step 1: 운동 목표 선택
/// - Step 2: 운동 종목 선택
/// - Step 3: 상세 정보 입력
/// - Step 4: 결과 표시 (추천 운동 / 오늘의 루틴 탭)
class ExerciseFortunePage extends ConsumerStatefulWidget {
  const ExerciseFortunePage({super.key});

  @override
  ConsumerState<ExerciseFortunePage> createState() => _ExerciseFortunePageState();
}

class _ExerciseFortunePageState extends ConsumerState<ExerciseFortunePage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentStep = 1;
  bool _isLoading = false;

  // Step 1: 운동 목표
  ExerciseGoal? _selectedGoal;

  // Step 2: 운동 종목
  SportType? _selectedSport;

  // Step 3: 상세 정보
  int _weeklyFrequency = 3;
  ExperienceLevel _experienceLevel = ExperienceLevel.intermediate;
  int _fitnessLevel = 3;
  List<InjuryArea> _injuryHistory = [];
  PreferredTime _preferredTime = PreferredTime.evening;

  // Result
  ExerciseFortuneResult? _result;
  late TabController _resultTabController;

  @override
  void initState() {
    super.initState();
    _resultTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _resultTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? ObangseokColors.hanjiBackgroundDark : ObangseokColors.hanjiBackground,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildGoalSelectionPage(isDark),
                      _buildSportSelectionPage(isDark),
                      _buildDetailsInputPage(isDark),
                      _buildResultPage(isDark),
                    ],
                  ),
                ),
              ],
            ),
            _buildFloatingButtons(isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor:
          isDark ? ObangseokColors.hanjiBackgroundDark : ObangseokColors.hanjiBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: _handleBack,
        icon: Icon(
          Icons.arrow_back_ios,
          color: ObangseokColors.getMeok(context),
          size: 20,
        ),
      ),
      title: Text(
        '오늘의 운동',
        style: TextStyle(
          fontFamily: 'NanumMyeongjo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ObangseokColors.getMeok(context),
        ),
      ),
      centerTitle: true,
    );
  }

  void _handleBack() {
    if (_currentStep > 1 && _currentStep < 4) {
      _goToStep(_currentStep - 1);
    } else {
      context.pop();
    }
  }

  // ============================================================================
  // Step 1: 운동 목표 선택
  // ============================================================================

  Widget _buildGoalSelectionPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '어떤 목표로\n운동하시나요?',
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ObangseokColors.getMeok(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '목표에 맞는 운동을 추천해 드립니다',
            style: TextStyle(
              fontSize: 14,
              color: ObangseokColors.getMeok(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ...ExerciseGoal.values.map((goal) => _buildGoalCard(goal, isDark)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGoalCard(ExerciseGoal goal, bool isDark) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? ObangseokColors.jeok.withOpacity(0.1)
              : (context.colors.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ObangseokColors.jeok : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.nameKo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? ObangseokColors.jeok
                          : ObangseokColors.getMeok(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: ObangseokColors.getMeok(context).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: ObangseokColors.jeok, size: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Step 2: 운동 종목 선택
  // ============================================================================

  Widget _buildSportSelectionPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '어떤 운동을\n하시나요?',
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ObangseokColors.getMeok(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: SportType.values.length,
            itemBuilder: (context, index) {
              final sport = SportType.values[index];
              return _buildSportCard(sport, isDark);
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSportCard(SportType sport, bool isDark) {
    final isSelected = _selectedSport == sport;
    return GestureDetector(
      onTap: () => setState(() => _selectedSport = sport),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ObangseokColors.jeok.withOpacity(0.1)
              : (context.colors.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ObangseokColors.jeok : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(sport.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              sport.nameKo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? ObangseokColors.jeok
                    : ObangseokColors.getMeok(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Step 3: 상세 정보 입력
  // ============================================================================

  Widget _buildDetailsInputPage(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '상세 정보를\n알려주세요',
            style: TextStyle(
              fontFamily: 'NanumMyeongjo',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ObangseokColors.getMeok(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),

          // 주당 운동 횟수
          _buildSectionTitle('주당 운동 횟수', isDark),
          const SizedBox(height: 12),
          _buildFrequencySlider(isDark),
          const SizedBox(height: 24),

          // 운동 경력
          _buildSectionTitle('운동 경력', isDark),
          const SizedBox(height: 12),
          _buildExperienceChips(isDark),
          const SizedBox(height: 24),

          // 체력 수준
          _buildSectionTitle('체력 수준', isDark),
          const SizedBox(height: 12),
          _buildFitnessSlider(isDark),
          const SizedBox(height: 24),

          // 부상 이력
          _buildSectionTitle('부상 이력 (해당 시 선택)', isDark),
          const SizedBox(height: 12),
          _buildInjuryChips(isDark),
          const SizedBox(height: 24),

          // 선호 시간대
          _buildSectionTitle('선호 시간대', isDark),
          const SizedBox(height: 12),
          _buildTimeChips(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ObangseokColors.getMeok(context),
      ),
    );
  }

  Widget _buildFrequencySlider(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1회', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            Text(
              '주 $_weeklyFrequency회',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ObangseokColors.jeok,
              ),
            ),
            Text('7회', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        Slider(
          value: _weeklyFrequency.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          activeColor: ObangseokColors.jeok,
          onChanged: (value) => setState(() => _weeklyFrequency = value.toInt()),
        ),
      ],
    );
  }

  Widget _buildExperienceChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExperienceLevel.values.map((level) {
        final isSelected = _experienceLevel == level;
        return ChoiceChip(
          label: Text('${level.nameKo} (${level.period})'),
          selected: isSelected,
          selectedColor: ObangseokColors.jeok.withOpacity(0.2),
          backgroundColor: context.colors.surface,
          labelStyle: TextStyle(
            color: isSelected ? ObangseokColors.jeok : ObangseokColors.getMeok(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          side: BorderSide(
            color: isSelected ? ObangseokColors.jeok : Colors.grey.shade300,
          ),
          onSelected: (_) => setState(() => _experienceLevel = level),
        );
      }).toList(),
    );
  }

  Widget _buildFitnessSlider(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('낮음', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            Row(
              children: List.generate(5, (index) {
                final isFilled = index < _fitnessLevel;
                return Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled ? ObangseokColors.jeok : Colors.grey.shade400,
                  size: 20,
                );
              }),
            ),
            Text('높음', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        Slider(
          value: _fitnessLevel.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: ObangseokColors.jeok,
          onChanged: (value) => setState(() => _fitnessLevel = value.toInt()),
        ),
      ],
    );
  }

  Widget _buildInjuryChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: InjuryArea.values.map((area) {
        final isSelected = _injuryHistory.contains(area);
        return FilterChip(
          label: Text(area.nameKo),
          selected: isSelected,
          selectedColor: ObangseokColors.jeok.withOpacity(0.2),
          backgroundColor: context.colors.surface,
          labelStyle: TextStyle(
            color: isSelected ? ObangseokColors.jeok : ObangseokColors.getMeok(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          side: BorderSide(
            color: isSelected ? ObangseokColors.jeok : Colors.grey.shade300,
          ),
          onSelected: (selected) {
            setState(() {
              if (area == InjuryArea.none) {
                _injuryHistory = selected ? [InjuryArea.none] : [];
              } else {
                _injuryHistory.remove(InjuryArea.none);
                if (selected) {
                  _injuryHistory.add(area);
                } else {
                  _injuryHistory.remove(area);
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimeChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PreferredTime.values.map((time) {
        final isSelected = _preferredTime == time;
        return ChoiceChip(
          label: Text('${time.emoji} ${time.nameKo}'),
          selected: isSelected,
          selectedColor: ObangseokColors.jeok.withOpacity(0.2),
          backgroundColor: context.colors.surface,
          labelStyle: TextStyle(
            color: isSelected ? ObangseokColors.jeok : ObangseokColors.getMeok(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          side: BorderSide(
            color: isSelected ? ObangseokColors.jeok : Colors.grey.shade300,
          ),
          onSelected: (_) => setState(() => _preferredTime = time),
        );
      }).toList(),
    );
  }

  // ============================================================================
  // Step 4: 결과 페이지
  // ============================================================================

  Widget _buildResultPage(bool isDark) {
    if (_result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final tokenState = ref.watch(tokenProvider);
    final isPremium = tokenState.hasUnlimitedAccess;

    return Column(
      children: [
        // 탭바
        Container(
          color: isDark ? ObangseokColors.hanjiBackgroundDark : ObangseokColors.hanjiBackground,
          child: TabBar(
            controller: _resultTabController,
            labelColor: ObangseokColors.jeok,
            unselectedLabelColor: Colors.grey,
            indicatorColor: ObangseokColors.jeok,
            tabs: const [
              Tab(text: '추천 운동'),
              Tab(text: '오늘의 루틴'),
            ],
          ),
        ),
        // 탭뷰
        Expanded(
          child: TabBarView(
            controller: _resultTabController,
            children: [
              _buildRecommendedExerciseTab(isDark),
              _buildTodayRoutineTab(isDark, isPremium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedExerciseTab(bool isDark) {
    final result = _result!;
    final primary = result.primaryExercise;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 점수 카드
          _buildScoreCard(result, isDark),
          const SizedBox(height: 24),

          // 추천 운동
          if (primary != null) ...[
            Text(
              '오늘의 추천 운동',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ObangseokColors.getMeok(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildPrimaryExerciseCard(primary, isDark),
            const SizedBox(height: 24),
          ],

          // 대체 운동
          if (result.alternatives.isNotEmpty) ...[
            Text(
              '대체 운동',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ObangseokColors.getMeok(context),
              ),
            ),
            const SizedBox(height: 12),
            ...result.alternatives.map((alt) => _buildAlternativeCard(alt, isDark)),
          ],

          // 최적 시간
          if (result.optimalTime != null) ...[
            const SizedBox(height: 24),
            _buildOptimalTimeCard(result.optimalTime!, isDark),
          ],

          // 영양 팁
          if (result.nutritionTip != null) ...[
            const SizedBox(height: 24),
            _buildNutritionCard(result.nutritionTip!, isDark),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreCard(ExerciseFortuneResult result, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ObangseokColors.jeok, ObangseokColors.jeok.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.sportType.emoji} ${result.sportType.nameKo}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.summary,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (result.percentile != null)
                  Text(
                    '상위 ${result.percentile}%',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${result.score}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryExerciseCard(RecommendedExercise exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ObangseokColors.getMeok(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ObangseokColors.jeok.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.intensity.nameKo,
                  style: TextStyle(
                    fontSize: 12,
                    color: ObangseokColors.jeok,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: TextStyle(
              fontSize: 14,
              color: ObangseokColors.getMeok(context).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                exercise.duration,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(Icons.category, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                exercise.category,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          if (exercise.benefits.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: exercise.benefits.map((b) => Chip(
                    label: Text(b, style: const TextStyle(fontSize: 11)),
                    backgroundColor: ObangseokColors.cheong.withOpacity(0.1),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(AlternativeExercise exercise, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ObangseokColors.getMeok(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: ObangseokColors.getMeok(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              exercise.category,
              style: TextStyle(fontSize: 10, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalTimeCard(OptimalTime optimalTime, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObangseokColors.cheong.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: ObangseokColors.cheong, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 운동 시간: ${optimalTime.time}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ObangseokColors.getMeok(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  optimalTime.reason,
                  style: TextStyle(
                    fontSize: 13,
                    color: ObangseokColors.getMeok(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(NutritionTip nutrition, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, size: 20, color: ObangseokColors.hwang),
              const SizedBox(width: 8),
              Text(
                '영양 팁',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.getMeok(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNutritionRow('운동 전', nutrition.preworkout, isDark),
          const SizedBox(height: 8),
          _buildNutritionRow('운동 후', nutrition.postworkout, isDark),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: ObangseokColors.hwang.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: ObangseokColors.hwang),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: ObangseokColors.getMeok(context).withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 오늘의 루틴 탭 (프리미엄)
  // ============================================================================

  Widget _buildTodayRoutineTab(bool isDark, bool isPremium) {
    final result = _result!;
    final routine = result.todayRoutine;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SimpleBlurOverlay(
        isBlurred: result.isSectionBlurred('todayRoutine'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 종목별 루틴
            if (routine != null) ...[
              if (routine.gymRoutine != null) _buildGymRoutineCard(routine.gymRoutine!, isDark),
              if (routine.yogaRoutine != null) _buildYogaRoutineCard(routine.yogaRoutine!, isDark),
              if (routine.cardioRoutine != null) _buildCardioRoutineCard(routine.cardioRoutine!, isDark),
              if (routine.sportsRoutine != null) _buildSportsRoutineCard(routine.sportsRoutine!, isDark),
            ],

            // 주간 계획
            if (result.weeklyPlan != null) ...[
              const SizedBox(height: 24),
              _buildWeeklyPlanCard(result.weeklyPlan!, isDark),
            ],

            // 부상 예방
            if (result.injuryPrevention != null) ...[
              const SizedBox(height: 24),
              _buildInjuryPreventionCard(result.injuryPrevention!, isDark),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGymRoutineCard(GymRoutine routine, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObangseokColors.jeok.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💪', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '${routine.splitTypeKo} - ${routine.todayFocus}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.getMeok(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 웜업
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObangseokColors.cheong.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_run, color: ObangseokColors.cheong, size: 18),
                const SizedBox(width: 8),
                Text('웜업 ${routine.warmupDuration}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    routine.warmupActivities.join(', '),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 운동 목록
          ...routine.exercises.map((exercise) => _buildGymExerciseRow(exercise, isDark)),

          const SizedBox(height: 12),
          // 쿨다운
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObangseokColors.cheong.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.self_improvement, color: ObangseokColors.cheong, size: 18),
                const SizedBox(width: 8),
                Text('쿨다운 ${routine.cooldownDuration}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    routine.cooldownActivities.join(', '),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymExerciseRow(GymExerciseItem exercise, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ObangseokColors.jeok,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${exercise.order}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ObangseokColors.getMeok(context),
                  ),
                ),
                Text(
                  exercise.targetMuscle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${exercise.sets}세트 x ${exercise.reps}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.jeok,
                ),
              ),
              Text(
                '휴식 ${exercise.restSeconds}초',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYogaRoutineCard(YogaRoutine routine, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObangseokColors.cheong.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧘', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                routine.sequenceName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.getMeok(context),
                ),
              ),
              const Spacer(),
              Text(routine.duration, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 16),
          ...routine.poses.map((pose) => _buildYogaPoseRow(pose, isDark)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObangseokColors.cheong.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.air, color: ObangseokColors.cheong, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    routine.breathingFocus,
                    style: TextStyle(
                      fontSize: 13,
                      color: ObangseokColors.getMeok(context),
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

  Widget _buildYogaPoseRow(YogaPose pose, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ObangseokColors.cheong,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${pose.order}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pose.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ObangseokColors.getMeok(context),
                  ),
                ),
                if (pose.sanskritName != null)
                  Text(
                    pose.sanskritName!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          Text(pose.duration, style: TextStyle(fontSize: 13, color: ObangseokColors.cheong)),
        ],
      ),
    );
  }

  Widget _buildCardioRoutineCard(CardioRoutine routine, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObangseokColors.cheong.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                routine.type == 'running' ? '🏃' : routine.type == 'swimming' ? '🏊' : '🚴',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '${routine.totalDistance} / ${routine.totalDuration}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.getMeok(context),
                ),
              ),
              if (routine.targetPace != null) ...[
                const Spacer(),
                Text('목표: ${routine.targetPace}', style: TextStyle(color: ObangseokColors.cheong)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...routine.intervals.map((interval) => _buildCardioIntervalRow(interval, isDark)),
          if (routine.technique.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ObangseokColors.cheong.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('테크닉 팁', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  ...routine.technique.map((t) => Text('• $t', style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardioIntervalRow(CardioInterval interval, bool isDark) {
    Color phaseColor;
    IconData phaseIcon;
    switch (interval.phase) {
      case '워밍업':
        phaseColor = ObangseokColors.cheong;
        phaseIcon = Icons.directions_walk;
        break;
      case '쿨다운':
        phaseColor = ObangseokColors.cheong;
        phaseIcon = Icons.self_improvement;
        break;
      default:
        phaseColor = ObangseokColors.jeok;
        phaseIcon = Icons.flash_on;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(phaseIcon, color: phaseColor, size: 18),
          const SizedBox(width: 8),
          Text(interval.phase, style: TextStyle(fontWeight: FontWeight.w600, color: phaseColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              interval.intensity,
              style: TextStyle(fontSize: 13, color: ObangseokColors.getMeok(context)),
            ),
          ),
          Text(interval.duration, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildSportsRoutineCard(SportsRoutine routine, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObangseokColors.baek.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${routine.sportName} - ${routine.focusArea}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ObangseokColors.getMeok(context),
            ),
          ),
          const SizedBox(height: 16),
          ...routine.drills.map((drill) => _buildDrillRow(drill, isDark)),
        ],
      ),
    );
  }

  Widget _buildDrillRow(SportsDrill drill, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: ObangseokColors.baek,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${drill.order}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(drill.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(drill.duration, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            drill.purpose,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanCard(WeeklyPlan plan, bool isDark) {
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: ObangseokColors.jeok, size: 20),
              const SizedBox(width: 8),
              Text(
                '주간 계획',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.getMeok(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.summary,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (index) {
              final day = days[index];
              final dayName = dayNames[index];
              final activity = plan.getDay(day);
              final isRest = activity.contains('휴식') || activity.contains('완전 휴식');

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isRest ? Colors.grey.shade200 : ObangseokColors.jeok.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isRest ? Colors.grey : ObangseokColors.jeok,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRest ? '휴식' : '운동',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuryPreventionCard(InjuryPrevention prevention, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                '부상 예방',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ObangseokColors.getMeok(context),
                ),
              ),
            ],
          ),
          if (prevention.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...prevention.warnings.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
          if (prevention.stretches.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('추천 스트레칭', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ObangseokColors.cheong)),
            const SizedBox(height: 4),
            ...prevention.stretches.map((s) => Text('• $s', style: const TextStyle(fontSize: 13))),
          ],
        ],
      ),
    );
  }

  // ============================================================================
  // 하단 버튼
  // ============================================================================

  Widget _buildFloatingButtons(bool isDark) {
    if (_currentStep == 4) return const SizedBox.shrink();

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20 + MediaQuery.of(context).padding.bottom,
      child: UnifiedButton(
        text: _currentStep == 3 ? '운동 분석하기' : '다음',
        onPressed: _canProceed() ? _handleNext : null,
        isLoading: _isLoading,
        style: UnifiedButtonStyle.primary,
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return _selectedGoal != null;
      case 2:
        return _selectedSport != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
    } else {
      _generateFortune();
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _generateFortune() async {
    if (_selectedGoal == null || _selectedSport == null) return;

    setState(() => _isLoading = true);

    try {
      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;

      final payload = {
        'exerciseGoal': _selectedGoal!.toApiValue(),
        'sportType': _selectedSport!.toApiValue(),
        'weeklyFrequency': _weeklyFrequency,
        'experienceLevel': _experienceLevel.name,
        'fitnessLevel': _fitnessLevel,
        'injuryHistory': _injuryHistory.isEmpty
            ? ['none']
            : _injuryHistory.map((e) => e.name).toList(),
        'preferredTime': _preferredTime.name,
        'isPremium': isPremium,
      };

      final response = await Supabase.instance.client.functions.invoke(
        'fortune-exercise',
        body: payload,
      );

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        setState(() {
          _result = ExerciseFortuneResult.fromJson(data);
          _currentStep = 4;
        });
        _pageController.animateToPage(
          3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        final error = response.data?['error'] ?? '운동 분석에 실패했습니다';
        Toast.error(context, error);
      }
    } catch (e) {
      Toast.error(context, '운동 분석 중 오류가 발생했습니다');
      debugPrint('Exercise fortune error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
