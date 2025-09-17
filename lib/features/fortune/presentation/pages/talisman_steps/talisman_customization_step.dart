import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../domain/models/talisman_models.dart';
import '../talisman_enhanced_page.dart';
import '../../widgets/talisman_preview_widget.dart';

class TalismanCustomizationStep extends ConsumerStatefulWidget {
  final TalismanType selectedType;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TalismanCustomizationStep({
    super.key,
    required this.selectedType,
    required this.onNext,
    required this.onBack});

  @override
  ConsumerState<TalismanCustomizationStep> createState() => _TalismanCustomizationStepState();
}

class _TalismanCustomizationStepState extends ConsumerState<TalismanCustomizationStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _personalWishController = TextEditingController();
  
  Color _selectedPrimaryColor = const Color(0xFFFF4500);
  Color _selectedSecondaryColor = const Color(0xFFFFD700);
  String _selectedSymbol = 'classic';
  
  final List<Color> _colorOptions = [
    const Color(0xFFFF4500), // Red-Orange
    const Color(0xFFFFD700), // Gold
    const Color(0xFF4169E1), // Royal Blue
    const Color(0xFF32CD32), // Lime Green
    const Color(0xFF9370DB), // Medium Purple
    const Color(0xFFFF69B4), // Hot Pink
    const Color(0xFF20B2AA), // Light Sea Green
    const Color(0xFF8B008B), // Dark Magenta
    const Color(0xFFFF8C00), // Dark Orange
    const Color(0xFF4B0082), // Indigo
  ];
  
  final Map<String, String> _symbolOptions = {
    'classic', '전통 문양',
    'modern', '현대적 디자인',
    'minimal', '미니멀 스타일',
    'ornate', '화려한 장식'};

  @override
  void initState() {
    super.initState();
    // Load existing state if any
    final state = ref.read(talismanCreationProvider);
    if (state.userName != null) _nameController.text = state.userName!;
    if (state.birthDate != null) _birthDateController.text = state.birthDate!;
    if (state.personalWish != null) _personalWishController.text = state.personalWish!;
    if (state.primaryColor != null) _selectedPrimaryColor = state.primaryColor!;
    if (state.secondaryColor != null) _selectedSecondaryColor = state.secondaryColor!;
    
    // Set default colors based on talisman type
    _selectedPrimaryColor = widget.selectedType.gradientColors[0];
    _selectedSecondaryColor = widget.selectedType.gradientColors[1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _personalWishController.dispose();
    super.dispose();
  }

  void _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR');
    
    if (date != null) {
      _birthDateController.text = '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate(), {
      HapticUtils.lightImpact();
      
      // Save customization data
      ref.read(talismanCreationProvider.notifier).updateUserInfo(
        userName: _nameController.text,
        birthDate: _birthDateController.text,
        personalWish: _personalWishController.text.isNotEmpty 
            ? _personalWishController.text 
            : null);
      
      ref.read(talismanCreationProvider.notifier).updateCustomization(
        primaryColor: _selectedPrimaryColor,
        secondaryColor: _selectedSecondaryColor,
        personalText: _personalWishController.text);
      
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.selectedType.gradientColors),
                      shape: BoxShape.circle),
                    child: Icon(
                      widget.selectedType.icon,
                      color: TossDesignSystem.white,
                      size: 32)).animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.selectedType.displayName} 만들기',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold)).animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    '부적에 담을 정보를 입력해주세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: TossDesignSystem.gray600)).animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)])),
            const SizedBox(height: 32),
            
            // Preview
            Center(
              child: TalismanPreviewWidget(
                type: widget.selectedType,
                primaryColor: _selectedPrimaryColor,
                secondaryColor: _selectedSecondaryColor,
                symbol: _selectedSymbol,
                userName: _nameController.text.isNotEmpty ? _nameController.text : '홍길동')).animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms),
            
            const SizedBox(height: 32),
            
            // User Information
            _buildSectionTitle('기본 정보'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '부적에 새겨질 이름을 입력하세요',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              }).animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _birthDateController,
              readOnly: true,
              onTap: _selectBirthDate,
              decoration: InputDecoration(
                labelText: '생년월일',
                hintText: '생년월일을 선택하세요',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '생년월일을 선택해주세요';
                }
                return null;
              }).animate()
              .fadeIn(duration: 400.ms, delay: 900.ms)
              .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Personal Wish
            _buildSectionTitle('소원 문구 (선택)'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _personalWishController,
              maxLines: 3,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: '부적에 담고 싶은 소원을 적어주세요',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.edit_note)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                counterText: '${_personalWishController.text.length}/50')).animate()
              .fadeIn(duration: 400.ms, delay: 1000.ms)
              .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Color Selection
            _buildSectionTitle('색상 선택'),
            const SizedBox(height: 16),
            
            _buildColorSelection(),
            
            const SizedBox(height: 24),
            
            // Symbol Selection
            _buildSectionTitle('문양 스타일'),
            const SizedBox(height: 16),
            
            _buildSymbolSelection(),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TossButton(
                    text: '이전',
                    onPressed: widget.onBack,
                    style: TossButtonStyle.ghost,
                    size: TossButtonSize.large,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TossButton(
                    text: '다음',
                    onPressed: _handleNext,
                    style: TossButtonStyle.primary,
                    size: TossButtonSize.large,
                  ),
                ),
              ],
            ).animate()
              .fadeIn(duration: 400.ms, delay: 1200.ms),
            
            const SizedBox(height: 20)])));
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold));
  }
  
  Widget _buildColorSelection() {
    return Column(
      children: [
        // Primary color
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '주 색상',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  final isSelected = _selectedPrimaryColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPrimaryColor = color;
                      });
                      HapticUtils.lightImpact();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha: 0.0),
                          width: 3),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2)]),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: TossDesignSystem.white,
                              size: 20)
                          : null));
                }).toList()]),
        const SizedBox(height: 12),
        // Secondary color
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '보조 색상',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  final isSelected = _selectedSecondaryColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSecondaryColor = color;
                      });
                      HapticUtils.lightImpact();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha: 0.0),
                          width: 3),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2)]),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: TossDesignSystem.white,
                              size: 20)
                          : null));
                }).toList()])]).animate()
        .fadeIn(duration: 400.ms, delay: 1100.ms);
  }
  
  Widget _buildSymbolSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _symbolOptions.entries.map((entry) {
        final isSelected = _selectedSymbol == entry.key;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSymbol = entry.key;
            });
            HapticUtils.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray300),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: TossDesignSystem.tossBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2))]),
            child: Text(
              entry.value,
              style: TextStyle(
                color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray900,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)));
      }).toList()).animate()
        .fadeIn(duration: 400.ms, delay: 1200.ms);
  }
}