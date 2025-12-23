import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../domain/models/conditions/naming_fortune_conditions.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../services/ad_service.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../presentation/providers/subscription_provider.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../core/utils/fortune_completion_helper.dart';
import '../../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../../core/theme/obangseok_colors.dart';
import '../../../../../core/theme/typography_unified.dart';

class NamingFortunePage extends ConsumerStatefulWidget {
  const NamingFortunePage({super.key});

  @override
  ConsumerState<NamingFortunePage> createState() => _NamingFortunePageState();
}

class _NamingFortunePageState extends ConsumerState<NamingFortunePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Blur 상태
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  bool _hasInitializedBlur = false;

  // Step 1: 엄마 정보
  DateTime? _motherBirthDate;
  String? _motherBirthTime;

  // Step 2: 아기 정보
  DateTime? _expectedBirthDate;
  String _babyGender = '';

  // Step 3: 성씨
  String _familyName = '';
  final String _familyNameHanja = '';
  final TextEditingController _familyNameController = TextEditingController();

  // Step 4: 추가 옵션
  String _nameStyle = '';
  final List<String> _desiredMeanings = [];

  @override
  void dispose() {
    _pageController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _motherBirthDate != null &&
      _expectedBirthDate != null &&
      _babyGender.isNotEmpty &&
      _familyName.isNotEmpty;

  void _nextStep() {
    if (_currentStep < 3) {
      HapticFeedback.lightImpact();
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'naming',
      title: '작명 운세',
      description: '사주 오행 기반 아기 이름 추천',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildStep1MotherInfo(isDark),
                      _buildStep2BabyInfo(isDark),
                      _buildStep3FamilyName(isDark),
                      _buildStep4Options(isDark),
                    ],
                  ),
                ),
              ],
            ),
            _buildStepButton(onComplete, isDark),
          ],
        );
      },
      conditionsBuilder: () async {
        return NamingFortuneConditions(
          motherBirthDate: _motherBirthDate!,
          motherBirthTime: _motherBirthTime,
          expectedBirthDate: _expectedBirthDate!,
          babyGender: _babyGender,
          familyName: _familyName,
          familyNameHanja:
              _familyNameHanja.isNotEmpty ? _familyNameHanja : null,
          nameStyle: _nameStyle.isNotEmpty ? _nameStyle : null,
          desiredMeanings:
              _desiredMeanings.isNotEmpty ? _desiredMeanings : null,
        );
      },
      resultBuilder: (context, result) {
        // Blur 상태 초기화
        if (!_hasInitializedBlur && result.isBlurred == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(fortuneHapticServiceProvider).mysticalReveal();

              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections =
                    result.isBlurred ? ['names4to10', 'detailedAnalysis'] : [];
                _hasInitializedBlur = true;
              });
            }
          });
        }

        return Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                  child: Column(
                    children: [
                      // 헤더 이미지 (기린 민화)
                      _buildHeaderImage(),
                      const SizedBox(height: 16),

                      // 오행 분석 카드 (무료)
                      _buildOhaengAnalysisCard(result.data),
                      const SizedBox(height: 16),

                      // 추천 이름 리스트
                      _buildNameRecommendations(result.data),
                      const SizedBox(height: 16),

                      // 작명 팁
                      _buildNamingTipsCard(result.data),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // 광고 버튼
            if (_isBlurred && !ref.watch(isPremiumProvider))
              UnifiedButton.floating(
                text: '🎁 광고 보고 전체 이름 보기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
              ),
          ],
        );
      },
    );
  }

  // ===== Step 1: 엄마 정보 =====
  Widget _buildStep1MotherInfo(bool isDark) {
    final times = [
      '자시 (23:00-01:00)',
      '축시 (01:00-03:00)',
      '인시 (03:00-05:00)',
      '묘시 (05:00-07:00)',
      '진시 (07:00-09:00)',
      '사시 (09:00-11:00)',
      '오시 (11:00-13:00)',
      '미시 (13:00-15:00)',
      '신시 (15:00-17:00)',
      '유시 (17:00-19:00)',
      '술시 (19:00-21:00)',
      '해시 (21:00-23:00)',
      '모름',
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PageHeaderSection(
                emoji: '👩',
                title: '엄마 정보',
                subtitle: '엄마의 사주를 분석하여\n아기와의 조화를 살펴봅니다',
              ),
              const SizedBox(height: 40),
              const FieldLabel(text: '엄마 생년월일'),
              NumericDateInput(
                label: '생년월일',
                selectedDate: _motherBirthDate,
                onDateChanged: (date) {
                  setState(() => _motherBirthDate = date);
                  HapticFeedback.selectionClick();
                },
                minDate: DateTime(1950),
                maxDate: DateTime.now(),
                showAge: true,
              ),
              const SizedBox(height: 24),
              const FieldLabel(text: '엄마 출생시간 (선택)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: times.map((time) {
                  final shortTime = time.split(' ').first;
                  return SelectionChip(
                    label: shortTime,
                    isSelected: _motherBirthTime == time,
                    onTap: () {
                      setState(() => _motherBirthTime = time);
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step 2: 아기 정보 =====
  Widget _buildStep2BabyInfo(bool isDark) {
    const genderOptions = [
      ('👦', '남아'),
      ('👧', '여아'),
      ('❓', '모름'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PageHeaderSection(
                emoji: '👶',
                title: '아기 정보',
                subtitle: '출산예정일과 성별을 입력해주세요',
              ),
              const SizedBox(height: 40),
              const FieldLabel(text: '출산예정일'),
              NumericDateInput(
                label: '출산예정일',
                selectedDate: _expectedBirthDate,
                onDateChanged: (date) {
                  setState(() => _expectedBirthDate = date);
                  HapticFeedback.selectionClick();
                },
                minDate: DateTime.now().subtract(const Duration(days: 30)),
                maxDate: DateTime.now().add(const Duration(days: 365)),
                showAge: false,
              ),
              const SizedBox(height: 32),
              const FieldLabel(text: '아기 성별'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: genderOptions.map((option) {
                  final genderValue = option.$2 == '남아'
                      ? 'male'
                      : option.$2 == '여아'
                          ? 'female'
                          : 'unknown';
                  return SelectionChip(
                    label: '${option.$1} ${option.$2}',
                    isSelected: _babyGender == genderValue,
                    onTap: () {
                      setState(() => _babyGender = genderValue);
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step 3: 성씨 입력 =====
  Widget _buildStep3FamilyName(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PageHeaderSection(
                emoji: '✍️',
                title: '성씨 입력',
                subtitle: '아기의 성을 입력해주세요',
              ),
              const SizedBox(height: 40),

              const FieldLabel(text: '성 (한글)'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _familyNameController,
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  style: TypographyUnified.heading1.copyWith(
                    color: isDark
                        ? ObangseokColors.baekDark
                        : ObangseokColors.meok,
                  ),
                  decoration: InputDecoration(
                    hintText: '예: 김',
                    hintStyle: TypographyUnified.heading2.copyWith(
                      color: (isDark
                              ? ObangseokColors.baekDark
                              : ObangseokColors.meok)
                          .withValues(alpha: 0.3),
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ObangseokColors.hwang.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ObangseokColors.hwang,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _familyName = value);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 인기 성씨 빠른 선택
              const FieldLabel(text: '또는 성씨 선택'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임']
                    .map((name) {
                  return SelectionChip(
                    label: name,
                    isSelected: _familyName == name,
                    onTap: () {
                      setState(() {
                        _familyName = name;
                        _familyNameController.text = name;
                      });
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step 4: 추가 옵션 =====
  Widget _buildStep4Options(bool isDark) {
    const styleOptions = [
      ('📜', '전통적', 'traditional'),
      ('✨', '현대적', 'modern'),
      ('🌸', '순우리말', 'korean'),
    ];

    const meaningOptions = [
      ('💪', '건강'),
      ('🎓', '학업/성공'),
      ('💕', '사랑/행복'),
      ('🌟', '밝음/희망'),
      ('🛡️', '보호/안전'),
      ('🌈', '조화/균형'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PageHeaderSection(
                emoji: '💫',
                title: '이름 스타일',
                subtitle: '원하시는 이름 스타일을 선택해주세요',
              ),
              const SizedBox(height: 40),
              const FieldLabel(text: '이름 스타일 (선택)'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: styleOptions.map((option) {
                  return SelectionChip(
                    label: '${option.$1} ${option.$2}',
                    isSelected: _nameStyle == option.$3,
                    onTap: () {
                      setState(() => _nameStyle = option.$3);
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const FieldLabel(text: '원하는 의미 (복수 선택 가능)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: meaningOptions.map((option) {
                  final isSelected = _desiredMeanings.contains(option.$2);
                  return SelectionChip(
                    label: '${option.$1} ${option.$2}',
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _desiredMeanings.remove(option.$2);
                        } else {
                          _desiredMeanings.add(option.$2);
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step Button =====
  Widget _buildStepButton(VoidCallback onComplete, bool isDark) {
    final isEnabled = _currentStep == 0
        ? _motherBirthDate != null
        : _currentStep == 1
            ? _expectedBirthDate != null && _babyGender.isNotEmpty
            : _currentStep == 2
                ? _familyName.isNotEmpty
                : _canSubmit;

    final buttonText = _currentStep == 0
        ? (_motherBirthDate == null ? '생년월일을 입력해주세요' : '다음')
        : _currentStep == 1
            ? (_expectedBirthDate == null
                ? '출산예정일을 입력해주세요'
                : _babyGender.isEmpty
                    ? '성별을 선택해주세요'
                    : '다음')
            : _currentStep == 2
                ? (_familyName.isEmpty ? '성을 입력해주세요' : '다음')
                : '✨ 이름 추천받기';

    return UnifiedButton.floating(
      text: buttonText,
      onPressed: () {
        if (_currentStep < 3) {
          if (!isEnabled) return;
          _nextStep();
        } else {
          onComplete();
        }
      },
      isEnabled: isEnabled,
      showProgress: true,
      currentStep: _currentStep + 1,
      totalSteps: 4,
    );
  }

  // ===== 헤더 이미지 (기린 민화) =====
  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          'assets/images/minhwa/minhwa_naming_baby.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ObangseokColors.hwang.withValues(alpha: 0.3),
                    ObangseokColors.jeok.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🦒', style: TextStyle(fontSize: 80)),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===== 결과 카드들 =====
  Widget _buildOhaengAnalysisCard(Map<String, dynamic> data) {
    final ohaeng = data['ohaengAnalysis'] as Map<String, dynamic>? ?? {};
    final distribution = ohaeng['distribution'] as Map<String, dynamic>? ?? {};
    final missing = (ohaeng['missing'] as List?)?.cast<String>() ?? [];
    final yongsin = ohaeng['yongsin'] as String? ?? '';
    final recommendation = ohaeng['recommendation'] as String? ?? '';

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('☯️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text('오행 분석', style: DSTypography.headingMedium),
            ],
          ),
          const SizedBox(height: 20),

          // 오행 분포 바
          _buildOhaengBar(distribution),
          const SizedBox(height: 16),

          if (missing.isNotEmpty) ...[
            Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('부족한 오행: ${missing.join(', ')}',
                    style: DSTypography.bodyMedium
                        .copyWith(color: DSColors.warning)),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (yongsin.isNotEmpty) ...[
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('용신: $yongsin',
                    style: DSTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (recommendation.isNotEmpty)
            Text(recommendation, style: DSTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildOhaengBar(Map<String, dynamic> distribution) {
    final elements = [
      ('木', ObangseokColors.cheong, distribution['木'] ?? 0),
      ('火', ObangseokColors.jeok, distribution['火'] ?? 0),
      ('土', ObangseokColors.hwang, distribution['土'] ?? 0),
      ('金', Colors.grey, distribution['金'] ?? 0),
      ('水', ObangseokColors.heuk, distribution['水'] ?? 0),
    ];

    final total = elements.fold<int>(0, (sum, e) => sum + (e.$3 as int));

    return Row(
      children: elements.map((e) {
        final ratio = total > 0 ? (e.$3 as int) / total : 0.2;
        return Expanded(
          flex: ((ratio * 100).round()).clamp(10, 100),
          child: Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: e.$2,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${e.$1}\n${e.$3}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNameRecommendations(Map<String, dynamic> data) {
    final names =
        (data['recommendedNames'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (names.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 헤더
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text('추천 이름 TOP ${names.length}',
                  style: DSTypography.headingMedium),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 이름 카드들
        ...names.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          final isBlurredItem = _isBlurred && index >= 3; // 4위부터 블러

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UnifiedBlurWrapper(
              isBlurred: isBlurredItem,
              blurredSections: isBlurredItem ? ['names4to10'] : [],
              sectionKey: 'names4to10',
              child: _buildNameCard(name, index + 1),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNameCard(Map<String, dynamic> name, int rank) {
    final koreanName = name['koreanName'] as String? ?? '';
    final hanjaName = name['hanjaName'] as String? ?? '';
    final hanjaMeaning = (name['hanjaMeaning'] as List?)?.cast<String>() ?? [];
    final pronunciationOhaeng = name['pronunciationOhaeng'] as String? ?? '';
    final strokeOhaeng = name['strokeOhaeng'] as String? ?? '';
    final totalScore = name['totalScore'] as int? ?? 0;
    final analysis = name['analysis'] as String? ?? '';

    final rankColor = rank == 1
        ? ObangseokColors.hwang
        : rank == 2
            ? Colors.grey.shade400
            : rank == 3
                ? Colors.brown.shade300
                : DSColors.textSecondary;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 순위 + 이름
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_familyName$koreanName',
                      style: DSTypography.headingMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (hanjaName.isNotEmpty)
                      Text(
                        hanjaName,
                        style: DSTypography.bodySmall
                            .copyWith(color: DSColors.textSecondary),
                      ),
                  ],
                ),
              ),
              // 점수
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ObangseokColors.hwang.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalScore점',
                  style: DSTypography.labelMedium.copyWith(
                    color: ObangseokColors.hwang,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 한자 의미
          if (hanjaMeaning.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: hanjaMeaning
                  .map((m) => Chip(
                        label: Text(m, style: const TextStyle(fontSize: 12)),
                        backgroundColor: DSColors.surface,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],

          // 오행 분석
          Row(
            children: [
              if (pronunciationOhaeng.isNotEmpty) ...[
                const Text('🗣️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(pronunciationOhaeng, style: DSTypography.bodySmall),
                const SizedBox(width: 16),
              ],
              if (strokeOhaeng.isNotEmpty) ...[
                const Text('✍️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(strokeOhaeng, style: DSTypography.bodySmall),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // 분석
          if (analysis.isNotEmpty)
            Text(analysis,
                style: DSTypography.bodySmall
                    .copyWith(color: DSColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNamingTipsCard(Map<String, dynamic> data) {
    final tips = (data['namingTips'] as List?)?.cast<String>() ?? [];
    final warnings = (data['warnings'] as List?)?.cast<String>() ?? [];

    if (tips.isEmpty && warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return UnifiedBlurWrapper(
      isBlurred: _isBlurred,
      blurredSections: _blurredSections,
      sectionKey: 'detailedAnalysis',
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text('작명 팁', style: DSTypography.headingSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓',
                          style: TextStyle(color: DSColors.success)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip, style: DSTypography.bodySmall)),
                    ],
                  ),
                )),
            if (warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
                            style: DSTypography.bodySmall
                                .copyWith(color: DSColors.warning),
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

  // ===== 광고 & 블러 해제 =====
  Future<void> _showAdAndUnblur() async {
    try {
      Logger.info('[작명 운세] 광고 시청 & 블러 해제 시작');

      final adService = AdService();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('광고를 준비하는 중...')),
          );
        }

        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고를 불러오지 못했습니다. 다시 시도해주세요.')),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'naming');

            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e) {
      Logger.error('[작명 운세] 광고 표시 실패: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러올 수 없습니다.')),
        );
      }
    }
  }
}
