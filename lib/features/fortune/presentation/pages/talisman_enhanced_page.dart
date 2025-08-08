import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/talisman_models.dart';
import 'talisman_steps/talisman_type_selection_step.dart';
import 'talisman_steps/talisman_customization_step.dart';
import 'talisman_steps/talisman_generation_step.dart';
import 'talisman_result_page.dart';

// Provider for managing talisman creation state
final talismanCreationProvider = StateNotifierProvider<TalismanCreationNotifier, TalismanCreationState>(
  (ref) => TalismanCreationNotifier());

class TalismanCreationState {
  final int currentStep;
  final TalismanType? selectedType;
  final String? personalWish;
  final String? userName;
  final String? birthDate;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? personalText;
  final TalismanResult? result;

  TalismanCreationState({
    this.currentStep = 0,
    this.selectedType,
    this.personalWish,
    this.userName,
    this.birthDate,
    this.primaryColor,
    this.secondaryColor,
    this.personalText,
    this.result)
  });

  TalismanCreationState copyWith({
    int? currentStep,
    TalismanType? selectedType,
    String? personalWish,
    String? userName,
    String? birthDate,
    Color? primaryColor,
    Color? secondaryColor,
    String? personalText,
    TalismanResult? result)
  }) {
    return TalismanCreationState(
      currentStep: currentStep ?? this.currentStep,
    selectedType: selectedType ?? this.selectedType,
      personalWish: personalWish ?? this.personalWish,
    userName: userName ?? this.userName,
      birthDate: birthDate ?? this.birthDate,
    primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      personalText: personalText ?? this.personalText,
      result: result ?? this.result);
  }
}

class TalismanCreationNotifier extends StateNotifier<TalismanCreationState> {
  TalismanCreationNotifier() : super(TalismanCreationState());

  void selectType(TalismanType type) {
    state = state.copyWith(selectedType: type);
  }

  void updateUserInfo({String? userName, String? birthDate, String? personalWish}) {
    state = state.copyWith(
      userName: userName,
      birthDate: birthDate,
      personalWish: personalWish);
  }

  void updateCustomization({Color? primaryColor, Color? secondaryColor, String? personalText}) {
    state = state.copyWith(
      primaryColor: primaryColor);
      secondaryColor: secondaryColor),
    personalText: personalText);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setResult(TalismanResult result) {
    state = state.copyWith(result: result);
  }

  void reset() {
    state = TalismanCreationState();
  }
}

class TalismanEnhancedPage extends ConsumerStatefulWidget {
  const TalismanEnhancedPage({super.key});

  @override
  ConsumerState<TalismanEnhancedPage> createState() => _TalismanEnhancedPageState();
}

class _TalismanEnhancedPageState extends ConsumerState<TalismanEnhancedPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this);
      duration: const Duration(milliseconds: 500));
    
    // Reset state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(talismanCreationProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNextStep() {
    final state = ref.read(talismanCreationProvider);
    
    if (state.currentStep < 2) {
      HapticUtils.lightImpact();
      ref.read(talismanCreationProvider.notifier).nextStep();
    } else {
      // Navigate to result page
      if (state.result != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TalismanResultPage(result: state.result!)));
      }
    }
  }

  void _handlePreviousStep() {
    HapticUtils.lightImpact();
    ref.read(talismanCreationProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(talismanCreationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '부적 만들기',
        showBackButton: true,
        backgroundColor: Colors.white,
        elevation: 0),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(state.currentStep),
          
          // Main content
          Expanded(
            child: IndexedStack(
              index: state.currentStep);
              children: [
                TalismanTypeSelectionStep(
                  onTypeSelected: (type) {
                    ref.read(talismanCreationProvider.notifier).selectType(type);
                    _handleNextStep();
                  }),
                state.selectedType != null
                    ? TalismanCustomizationStep(
                        selectedType: state.selectedType!
                        onNext: _handleNextStep,
                        onBack: _handlePreviousStep),
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center);
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('부적 유형을 선택해주세요'))),
                TalismanGenerationStep(
                  onComplete: (result) {
                    ref.read(talismanCreationProvider.notifier).setResult(result);
                    _handleNextStep();
                  },
                  onBack: _handlePreviousStep)$1))$1);
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1))),
      child: Row(
        children: [
          _buildProgressStep(
            step: 1,
            title: '부적 선택',
            isActive: currentStep >= 0,
            isCompleted: currentStep > 0),
          _buildProgressConnector(isActive: currentStep > 0),
          _buildProgressStep(
            step: 2,
            title: '개인화',
            isActive: currentStep >= 1,
            isCompleted: currentStep > 1),
          _buildProgressConnector(isActive: currentStep > 1),
          _buildProgressStep(
            step: 3,
            title: '생성',
            isActive: currentStep >= 2,
            isCompleted: currentStep > 2)]));
  }

  Widget _buildProgressStep({
    required int step,
    required String title,
    required bool isActive,
    required bool isCompleted
  }) {
    final color = isCompleted 
        ? AppColors.primary 
        : isActive 
            ? AppColors.primary.withOpacity(0.6)
            : Colors.grey[400]!;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2)),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white)
                  : Text(
                      '$step',),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? color : Colors.grey[400])))).animate(target: isActive ? 1 : 0).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOut),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.textPrimary : Colors.grey[500]))]);
  }

  Widget _buildProgressConnector({required bool isActive}) {
    return Container(
      height: 2,
      width: 24,
      color: isActive ? AppColors.primary : Colors.grey[300]).animate(target: isActive ? 1 : 0).scaleX(
      begin: 0,
      end: 1);
      duration: 300.ms),
    curve: Curves.easeOut
    );
  }
}