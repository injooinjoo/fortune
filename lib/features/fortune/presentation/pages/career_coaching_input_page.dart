import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../domain/models/career_coaching_model.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/accordion_input_section.dart';

class CareerCoachingInputPage extends ConsumerStatefulWidget {
  const CareerCoachingInputPage({super.key});

  @override
  ConsumerState<CareerCoachingInputPage> createState() => _CareerCoachingInputPageState();
}

class _CareerCoachingInputPageState extends ConsumerState<CareerCoachingInputPage> {
  // 현재 상황
  String? _currentRole;
  String? _experienceLevel;
  String? _primaryConcern;
  String? _industry;

  // F20: 분야 및 맞춤 포지션
  String? _field;
  String? _position;

  // 목표와 가치
  String? _shortTermGoal;
  String? _coreValue;
  final Set<String> _skillsToImprove = {};

  // Accordion sections
  List<AccordionInputSection> _accordionSections = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAccordionSections();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      // F20: 1. 분야 선택 (먼저 분야를 선택하면 맞춤 포지션 표시)
      AccordionInputSection(
        id: 'field',
        title: '분야 선택',
        icon: Icons.category_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildFieldInput(onComplete),
        value: _field,
        isCompleted: _field != null,
        displayValue: _field != null
            ? fieldOptions.firstWhere((f) => f.id == _field).title
            : null,
      ),

      // F20: 2. 맞춤 포지션 (선택한 분야에 따라 동적 표시)
      AccordionInputSection(
        id: 'position',
        title: '포지션',
        icon: Icons.person_outline,
        inputWidgetBuilder: (context, onComplete) => _buildPositionInput(onComplete),
        value: _position,
        isCompleted: _position != null,
        displayValue: _position != null && _field != null
            ? fieldPositions[_field]?.firstWhere((p) => p.id == _position).title
            : null,
      ),

      // 3. 경력 수준
      AccordionInputSection(
        id: 'currentRole',
        title: '경력 수준',
        icon: Icons.work_outline,
        inputWidgetBuilder: (context, onComplete) => _buildCurrentRoleInput(onComplete),
        value: _currentRole,
        isCompleted: _currentRole != null,
        displayValue: _currentRole != null
            ? roleOptions.firstWhere((role) => role.id == _currentRole).title
            : null,
      ),

      // 4. 핵심 고민
      AccordionInputSection(
        id: 'primaryConcern',
        title: '핵심 고민',
        icon: Icons.psychology_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildPrimaryConcernInput(onComplete),
        value: _primaryConcern,
        isCompleted: _primaryConcern != null,
        displayValue: _primaryConcern != null
            ? concernCards.firstWhere((concern) => concern.id == _primaryConcern).title
            : null,
      ),

      // 3. 단기 목표 (3-6개월)
      AccordionInputSection(
        id: 'shortTermGoal',
        title: '단기 목표 (3-6개월)',
        icon: Icons.rocket_launch,
        inputWidgetBuilder: (context, onComplete) => _buildShortTermGoalInput(onComplete),
        value: _shortTermGoal,
        isCompleted: _shortTermGoal != null,
        displayValue: _shortTermGoal != null
            ? goalOptions.firstWhere((goal) => goal.id == _shortTermGoal).title
            : null,
      ),

      // 4. 핵심 가치
      AccordionInputSection(
        id: 'coreValue',
        title: '핵심 가치',
        icon: Icons.favorite_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildCoreValueInput(onComplete),
        value: _coreValue,
        isCompleted: _coreValue != null,
        displayValue: _coreValue != null
            ? valueOptions.firstWhere((value) => value.id == _coreValue).title
            : null,
      ),

      // 5. 개선하고 싶은 스킬 (다중 선택)
      AccordionInputSection(
        id: 'skillsToImprove',
        title: '개선하고 싶은 스킬',
        icon: Icons.trending_up_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildSkillsToImproveInput(onComplete),
        value: _skillsToImprove.toList(),
        isCompleted: _skillsToImprove.isNotEmpty,
        displayValue: _skillsToImprove.isNotEmpty
            ? _skillsToImprove.join(', ')
            : null,
        isMultiSelect: true, // 다중 선택 - 선택 후에도 닫히지 않음
      ),
    ];
  }

  void _updateAccordionSection(String id, dynamic value, String? displayValue) {
    final index = _accordionSections.indexWhere((section) => section.id == id);
    if (index != -1) {
      setState(() {
        _accordionSections[index] = AccordionInputSection(
          id: _accordionSections[index].id,
          title: _accordionSections[index].title,
          icon: _accordionSections[index].icon,
          inputWidgetBuilder: _accordionSections[index].inputWidgetBuilder,
          value: value,
          isCompleted: value != null && (value is! String || value.isNotEmpty) && (value is! List || value.isNotEmpty),
          displayValue: displayValue,
          isMultiSelect: _accordionSections[index].isMultiSelect,
        );
      });
    }
  }

  bool _canGenerate() {
    // 필수: F20 분야, 포지션, 경력수준, 핵심 고민, 단기 목표, 핵심 가치, 개선 스킬 1개 이상
    return _field != null &&
        _position != null &&
        _currentRole != null &&
        _primaryConcern != null &&
        _shortTermGoal != null &&
        _coreValue != null &&
        _skillsToImprove.isNotEmpty;
  }

  Future<void> _analyzeAndShowResult() async {
    if (!_canGenerate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('필수 정보를 모두 입력해주세요'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 API 호출로 교체
      // final result = await fortuneService.getFortune(...);

      // 임시로 3초 대기 (API 호출 시뮬레이션)
      await Future.delayed(const Duration(seconds: 3));

      final input = CareerCoachingInput(
        currentRole: _currentRole!,
        experienceLevel: _experienceLevel ?? 'mid',
        primaryConcern: _primaryConcern!,
        industry: _industry,
        field: _field,         // F20: 분야
        position: _position,   // F20: 맞춤 포지션
        shortTermGoal: _shortTermGoal!,
        coreValue: _coreValue!,
        skillsToImprove: _skillsToImprove.toList(),
      );

      if (mounted) {
        context.pushNamed(
          'career-coaching-result',
          extra: input,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('분석 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const StandardFortuneAppBar(
        title: '직업',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _accordionSections.isEmpty
                ? Center(child: CircularProgressIndicator())
                : AccordionInputFormWithHeader(
                    header: _buildTitleSection(isDark),
                    sections: _accordionSections,
                    onAllCompleted: null,
                    completionButtonText: '분석 시작',
                  ),
            if (_canGenerate())
              UnifiedButton.floating(
                text: '🚀 분석 시작하기',
                onPressed: _isLoading ? null : _analyzeAndShowResult,
                isEnabled: !_isLoading,
                isLoading: _isLoading,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return const PageHeaderSection(
      emoji: '💼',
      title: '맞춤 직업 전략',
      subtitle: '현재 상황과 목표를 분석해서\n최적의 성장 로드맵을 제시해드려요',
    );
  }

  // ===== 입력 위젯들 =====

  /// F20: 분야 선택 입력 위젯
  Widget _buildFieldInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: fieldOptions.map((field) {
        final isSelected = _field == field.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _field = field.id;
              // 분야가 바뀌면 포지션 초기화
              _position = null;
              _updateAccordionSection('field', field.id, field.title);
              _updateAccordionSection('position', null, null);
            });
            ref.read(fortuneHapticServiceProvider).selection();
            onComplete(field.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : isDark
                      ? AppColors.inputBackgroundDark
                      : AppColors.inputBackgroundLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGreen
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(field.emoji, style: TextStyle(fontSize: FontConfig.heading3)),
                const SizedBox(height: 4),
                Text(
                  field.title,
                  style: TextStyle(
                    fontSize: FontConfig.labelMedium,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentGreen
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  field.description,
                  style: TextStyle(
                    fontSize: FontConfig.captionLarge,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// F20: 맞춤 포지션 선택 입력 위젯 (선택한 분야에 따라 동적 표시)
  Widget _buildPositionInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 분야가 선택되지 않았으면 안내 메시지
    if (_field == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.inputBackgroundDark
              : AppColors.inputBackgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '먼저 분야를 선택해주세요',
            style: TextStyle(
              fontSize: FontConfig.labelMedium,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    // 선택한 분야의 포지션 목록
    final positions = fieldPositions[_field] ?? [];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: positions.map((position) {
        final isSelected = _position == position.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _position = position.id;
              _updateAccordionSection('position', position.id, position.title);
            });
            ref.read(fortuneHapticServiceProvider).selection();
            onComplete(position.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : isDark
                      ? AppColors.inputBackgroundDark
                      : AppColors.inputBackgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGreen
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(position.emoji, style: TextStyle(fontSize: FontConfig.buttonMedium)),
                const SizedBox(width: 8),
                Text(
                  position.title,
                  style: TextStyle(
                    fontSize: FontConfig.labelMedium,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentGreen
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentRoleInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: roleOptions.map((role) {
        final isSelected = _currentRole == role.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRole = role.id;
              _updateAccordionSection('currentRole', role.id, role.title);
            });
            ref.read(fortuneHapticServiceProvider).selection();
            onComplete(role.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : isDark
                      ? AppColors.inputBackgroundDark
                      : AppColors.inputBackgroundLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGreen
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(role.emoji, style: TextStyle(fontSize: FontConfig.heading3)),
                const SizedBox(height: 4),
                Text(
                  role.title,
                  style: TextStyle(
                    fontSize: FontConfig.labelMedium,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentGreen
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrimaryConcernInput(Function(dynamic) onComplete) {
    return Column(
      children: concernCards.map((concern) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SelectionCard(
            title: concern.title,
            subtitle: concern.description,
            emoji: concern.emoji,
            isSelected: _primaryConcern == concern.id,
            onTap: () {
              setState(() {
                _primaryConcern = concern.id;
                _updateAccordionSection('primaryConcern', concern.id, concern.title);
              });
              ref.read(fortuneHapticServiceProvider).selection();
              onComplete(concern.id);
            },
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildShortTermGoalInput(Function(dynamic) onComplete) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goalOptions.map((goal) =>
        SelectionChip(
          label: '${goal.emoji} ${goal.title}',
          isSelected: _shortTermGoal == goal.id,
          onTap: () {
            setState(() {
              _shortTermGoal = goal.id;
              _updateAccordionSection('shortTermGoal', goal.id, goal.title);
            });
            ref.read(fortuneHapticServiceProvider).selection();
            onComplete(goal.id);
          },
        ),
      ).toList(),
    );
  }

  Widget _buildCoreValueInput(Function(dynamic) onComplete) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: valueOptions.map((value) =>
        SelectionChip(
          label: value.title,
          isSelected: _coreValue == value.id,
          onTap: () {
            setState(() {
              _coreValue = value.id;
              _updateAccordionSection('coreValue', value.id, value.title);
            });
            ref.read(fortuneHapticServiceProvider).selection();
            onComplete(value.id);
          },
        ),
      ).toList(),
    );
  }

  Widget _buildSkillsToImproveInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복수 선택 가능',
          style: TextStyle(
            fontSize: FontConfig.labelSmall,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        ...skillCategories.entries.map((category) =>
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel(text: category.key),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.value.map((skill) =>
                    SelectionChip(
                      label: skill,
                      isSelected: _skillsToImprove.contains(skill),
                      onTap: () {
                        setState(() {
                          if (_skillsToImprove.contains(skill)) {
                            _skillsToImprove.remove(skill);
                          } else {
                            _skillsToImprove.add(skill);
                          }
                          _updateAccordionSection(
                            'skillsToImprove',
                            _skillsToImprove.toList(),
                            _skillsToImprove.join(', '),
                          );
                        });
                        ref.read(fortuneHapticServiceProvider).selection();
                        onComplete(_skillsToImprove.toList());
                      },
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
