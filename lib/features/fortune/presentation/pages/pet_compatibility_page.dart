import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../providers/pet_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/widgets/hexagon_chart.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../constants/fortune_button_spacing.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/standard_fortune_page_layout.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';

class PetCompatibilityPage extends ConsumerStatefulWidget {
  final String fortuneType;
  final String title;
  final String description;

  const PetCompatibilityPage({
    super.key,
    required this.fortuneType,
    required this.title,
    required this.description,
  });

  @override
  ConsumerState<PetCompatibilityPage> createState() => _PetCompatibilityPageState();
}

class _PetCompatibilityPageState extends ConsumerState<PetCompatibilityPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  Fortune? _fortune;

  // Pet registration form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  PetSpecies _selectedSpecies = PetSpecies.dog;

  // ✅ 새로운 필드들
  PetGender _selectedGender = PetGender.unknown;
  String? _selectedBreed;
  PetPersonality? _selectedPersonality;
  bool? _isNeutered;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePets();
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  Future<void> _initializePets() async {
    try {
      final user = ref.read(userProvider).value;
      if (user != null) {
        await ref.read(petProvider.notifier).loadUserPets(user.id);
      }
    } catch (e) {
      Logger.error('Failed to initialize pets', e);
    } finally {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final petState = ref.watch(petProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: StandardFortuneAppBar(
        title: widget.title,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, size: 20, color: colors.accent),
            ),
            onPressed: () => _showAddPetBottomSheet(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          _fortune != null
              ? _buildFortuneResult()
              : _buildPetSelection(petState),

          // ✅ FloatingBottomButton (블러 상태일 때만, 구독자 제외)
          if (_fortune != null && _fortune!.isBlurred && !ref.watch(isPremiumProvider))
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: UnifiedButton(
                text: '광고 보고 전체 내용 확인하기',
                onPressed: _showAdAndUnblur,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
                icon: Icon(Icons.play_arrow, color: Colors.white),
                width: double.infinity,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetSelection(PetState petState) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: petState.hasPets
            ? _buildPetList(petState.pets)
            : _buildEmptyState(),
        );
      },
    );
  }

  Widget _buildPetList(List<PetProfile> pets) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return _buildPetCard(pet, index);
      },
    );
  }

  Widget _buildPetCard(PetProfile pet, int index) {
    final colors = context.colors;
    final species = PetSpecies.fromString(pet.species);
    final petId = pet.id ?? '';

    return Dismissible(
      key: Key(petId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (petId.isEmpty) return false;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('반려동물 삭제'),
            content: Text('${pet.name}을(를) 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: DSColors.error),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ?? false;

        if (confirmed) {
          await ref.read(petProvider.notifier).deletePet(petId);
        }
        return confirmed;
      },
      onDismissed: (direction) {},
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: DSColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => _selectPetAndGenerateFortune(pet),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(species.emoji, style: context.displaySmall),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pet.name,
                            style: context.heading2.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          if (pet.gender != '모름') ...[
                            const SizedBox(width: 6),
                            Text(
                              PetGender.fromString(pet.gender).symbol,
                              style: context.bodyMedium.copyWith(
                                color: pet.gender == '수컷' ? colors.accent : DSColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        '${species.displayName} • ${pet.age}세${pet.breed != null ? ' • ${pet.breed}' : ''}',
                        style: context.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      if (pet.personality != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${PetPersonality.fromString(pet.personality)?.emoji ?? ''} ${pet.personality}',
                            style: context.labelSmall.copyWith(
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 16, color: colors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .slideX(begin: 0.3)
     .fadeIn(duration: 600.ms);
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.pets, size: 40, color: colors.accent),
            ),
            SizedBox(height: 24),
            Text(
              '등록된 반려동물이 없어요',
              style: context.heading2.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '오른쪽 위 + 버튼을 눌러\n반려동물을 등록해보세요',
              textAlign: TextAlign.center,
              style: context.bodyLarge.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),
            UnifiedButton(
              text: '반려동물 등록하기',
              onPressed: () => _showAddPetBottomSheet(),
              style: UnifiedButtonStyle.primary,
              size: UnifiedButtonSize.large,
            ),
          ],
        ),
      ),
    ).animate()
     .scale(begin: const Offset(0.8, 0.8))
     .fadeIn(duration: 800.ms);
  }

  void _showAddPetBottomSheet() {
    _nameController.clear();
    _ageController.text = '1';
    _selectedSpecies = PetSpecies.dog;
    _selectedGender = PetGender.unknown;
    _selectedBreed = null;
    _selectedPersonality = null;
    _isNeutered = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddPetForm(),
    );
  }

  Widget _buildAddPetForm() {
    final colors = context.colors;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Header
                Text(
                  '반려동물 등록',
                  style: context.displaySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '반려동물의 정보를 입력해주세요',
                  style: context.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === 필수 정보 섹션 ===
                        _buildSectionTitle('필수 정보', colors),
                        const SizedBox(height: 12),

                        // Species selection
                        _buildFieldLabel('종류', colors),
                        const SizedBox(height: 8),
                        _buildSpeciesSelector(setModalState),
                        SizedBox(height: 20),

                        // Name input
                        _buildFieldLabel('이름', colors),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: '반려동물의 이름을 입력하세요',
                          colors: colors,
                          onChanged: (_) => setModalState(() {}),
                        ),
                        SizedBox(height: 20),

                        // Age input
                        _buildFieldLabel('나이', colors),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _ageController,
                          hint: '나이를 입력하세요',
                          colors: colors,
                          keyboardType: TextInputType.number,
                          suffix: '세',
                          onChanged: (_) => setModalState(() {}),
                        ),
                        SizedBox(height: 20),

                        // Gender selection
                        _buildFieldLabel('성별', colors),
                        const SizedBox(height: 8),
                        _buildGenderSelector(setModalState, colors),

                        const SizedBox(height: 32),

                        // === 선택 정보 섹션 ===
                        _buildSectionTitle('선택 정보', colors, subtitle: '더 정확한 운세를 위해'),
                        const SizedBox(height: 12),

                        // Breed selection
                        _buildFieldLabel('품종', colors, isOptional: true),
                        const SizedBox(height: 8),
                        _buildBreedSelector(setModalState, colors),
                        SizedBox(height: 20),

                        // Personality selection
                        _buildFieldLabel('성격', colors, isOptional: true),
                        const SizedBox(height: 8),
                        _buildPersonalitySelector(setModalState, colors),
                        SizedBox(height: 20),

                        // Neutered selection
                        _buildFieldLabel('중성화 여부', colors, isOptional: true),
                        const SizedBox(height: 8),
                        _buildNeuteredSelector(setModalState, colors),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Register button
                Consumer(
                  builder: (context, ref, child) {
                    final petState = ref.watch(petProvider);
                    return UnifiedButton(
                      text: '등록하기',
                      onPressed: _canRegisterPet() ? () => _registerPet(context) : null,
                      isLoading: petState.isCreating,
                      size: UnifiedButtonSize.large,
                      width: double.infinity,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, DSColorScheme colors, {String? subtitle}) {
    return Row(
      children: [
        Text(
          title,
          style: context.heading3.copyWith(
            color: colors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: context.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label, DSColorScheme colors, {bool isOptional = false}) {
    return Row(
      children: [
        Text(
          label,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        if (isOptional) ...[
          const SizedBox(width: 4),
          Text(
            '(선택)',
            style: context.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required DSColorScheme colors,
    TextInputType? keyboardType,
    String? suffix,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textTertiary),
        suffixText: suffix,
        suffixStyle: TextStyle(color: colors.textPrimary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildSpeciesSelector(StateSetter setModalState) {
    final colors = context.colors;
    final mainSpecies = [PetSpecies.dog, PetSpecies.cat, PetSpecies.rabbit, PetSpecies.hamster, PetSpecies.bird, PetSpecies.other];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: mainSpecies.map((species) {
        final isSelected = _selectedSpecies == species;
        return GestureDetector(
          onTap: () => setModalState(() {
            _selectedSpecies = species;
            _selectedBreed = null; // 종류 변경 시 품종 초기화
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                ? colors.accent.withValues(alpha: 0.1)
                : (colors.surfaceSecondary),
              border: Border.all(
                color: isSelected ? colors.accent : (colors.border),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(species.emoji, style: context.bodyLarge),
                SizedBox(width: 6),
                Text(
                  species.displayName,
                  style: context.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.accent : (colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenderSelector(StateSetter setModalState, DSColorScheme colors) {
    return Row(
      children: PetGender.values.map((gender) {
        final isSelected = _selectedGender == gender;
        return Expanded(
          child: GestureDetector(
            onTap: () => setModalState(() => _selectedGender = gender),
            child: Container(
              margin: EdgeInsets.only(right: gender != PetGender.unknown ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                  ? colors.accent.withValues(alpha: 0.1)
                  : (colors.surfaceSecondary),
                border: Border.all(
                  color: isSelected ? colors.accent : (colors.border),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    gender.symbol,
                    style: TextStyle(
                      fontSize: FontConfig.heading4,
                      color: isSelected
                        ? (gender == PetGender.male ? colors.accent : gender == PetGender.female ? DSColors.error : colors.textTertiary)
                        : colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gender.displayName,
                    style: context.bodySmall.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? colors.accent : (colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBreedSelector(StateSetter setModalState, DSColorScheme colors) {
    final breeds = PetBreeds.getBreedsForSpecies(_selectedSpecies.displayName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBreed,
          hint: Text(
            '품종을 선택하세요',
            style: TextStyle(color: colors.textTertiary),
          ),
          isExpanded: true,
          dropdownColor: colors.surface,
          items: breeds.map((breed) {
            return DropdownMenuItem<String>(
              value: breed,
              child: Text(
                breed,
                style: TextStyle(color: colors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (value) => setModalState(() => _selectedBreed = value),
        ),
      ),
    );
  }

  Widget _buildPersonalitySelector(StateSetter setModalState, DSColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PetPersonality.values.map((personality) {
        final isSelected = _selectedPersonality == personality;
        return GestureDetector(
          onTap: () => setModalState(() {
            _selectedPersonality = isSelected ? null : personality;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                ? colors.accent.withValues(alpha: 0.1)
                : (colors.surfaceSecondary),
              border: Border.all(
                color: isSelected ? colors.accent : (colors.border),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(personality.emoji, style: context.bodySmall),
                SizedBox(width: 4),
                Text(
                  personality.displayName,
                  style: context.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.accent : (colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNeuteredSelector(StateSetter setModalState, DSColorScheme colors) {
    return Row(
      children: [
        _buildNeuteredOption(setModalState, colors, true, '완료'),
        const SizedBox(width: 10),
        _buildNeuteredOption(setModalState, colors, false, '미완료'),
        const SizedBox(width: 10),
        _buildNeuteredOption(setModalState, colors, null, '모름'),
      ],
    );
  }

  Widget _buildNeuteredOption(StateSetter setModalState, DSColorScheme colors, bool? value, String label) {
    final isSelected = _isNeutered == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => _isNeutered = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
              ? colors.accent.withValues(alpha: 0.1)
              : (colors.surfaceSecondary),
            border: Border.all(
              color: isSelected ? colors.accent : (colors.border),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: context.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colors.accent : (colors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canRegisterPet() {
    return _nameController.text.trim().isNotEmpty &&
           _ageController.text.trim().isNotEmpty &&
           int.tryParse(_ageController.text) != null;
  }

  Future<void> _registerPet(BuildContext bottomSheetContext) async {
    Logger.info('🐾 Starting pet registration process');

    final user = ref.read(userProvider).value;
    if (user == null) {
      Logger.error('❌ User is null, cannot register pet');
      return;
    }

    final age = int.tryParse(_ageController.text) ?? 1;
    Logger.info('📝 Pet info - Name: ${_nameController.text.trim()}, Species: ${_selectedSpecies.displayName}, Age: $age');

    final pet = await ref.read(petProvider.notifier).createPet(
      userId: user.id,
      species: _selectedSpecies.displayName,
      name: _nameController.text.trim(),
      age: age,
      gender: _selectedGender.displayName,
      breed: _selectedBreed,
      personality: _selectedPersonality?.displayName,
      isNeutered: _isNeutered,
    );

    if (!mounted) return;

    if (pet != null) {
      Logger.info('✅ Pet registration successful');
      if (bottomSheetContext.mounted) Navigator.of(bottomSheetContext).pop();
      _selectPetAndGenerateFortune(pet);
    } else {
      Logger.error('❌ Pet registration failed');
      final petState = ref.read(petProvider);
      if (petState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(petState.error!), backgroundColor: DSColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('반려동물 등록에 실패했습니다. 다시 시도해주세요.'), backgroundColor: DSColors.error),
        );
      }
    }
  }

  Future<void> _selectPetAndGenerateFortune(PetProfile pet) async {
    ref.read(petProvider.notifier).selectPet(pet);
    await _generateFortune(pet);
  }

  Future<void> _generateFortune(PetProfile pet) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final tokenState = ref.read(tokenProvider);
      final isPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      debugPrint('💎 [PetCompatibilityPage] Premium 상태: $isPremium');

      // ✅ 확장된 파라미터 전송
      final params = {
        'pet_name': pet.name,
        'pet_species': pet.species,
        'pet_age': pet.age,
        'pet_gender': pet.gender,
        'pet_breed': pet.breed ?? '',
        'pet_personality': pet.personality ?? '',
        'pet_health_notes': pet.healthNotes ?? '',
        'pet_neutered': pet.isNeutered,
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        userId: user.id,
        params: params,
      );

      // ✅ 새로운 블러 섹션 목록
      final isBlurred = !isPremium;
      final blurredSections = isBlurred ? [
        'pets_voice',
        'health_insight',
        'activity_recommendation',
        'emotional_care',
        'special_tips',
      ] : <String>[];

      final fortuneWithBlur = fortune.copyWith(
        isBlurred: isBlurred,
        blurredSections: blurredSections,
      );

      if (mounted) {
        setState(() => _fortune = fortuneWithBlur);

        // 반려동물 궁합 결과 공개 햅틱
        ref.read(fortuneHapticServiceProvider).compatibilityReveal(70);
      }
    } catch (e) {
      Logger.error('Failed to generate pet fortune', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운세 생성에 실패했습니다. 다시 시도해주세요.'), backgroundColor: DSColors.error),
        );
      }
    }
  }

  Future<void> _showAdAndUnblur() async {
    if (_fortune == null) return;

    try {
      final adService = AdService.instance;

      if (!adService.isRewardedAdReady) {
        await adService.loadRewardedAd();
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'), backgroundColor: DSColors.error),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'pet-compatibility');
          }

          if (mounted) {
            setState(() {
              _fortune = _fortune!.copyWith(isBlurred: false, blurredSections: []);
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[PetCompatibilityPage] 광고 표시 실패', e, stackTrace);
      if (mounted) {
        setState(() {
          _fortune = _fortune!.copyWith(isBlurred: false, blurredSections: []);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'), backgroundColor: DSColors.warning),
        );
      }
    }
  }

  // ✅ UnifiedBlurWrapper로 마이그레이션 완료 (2024-12-07)

  Widget _buildFortuneResult() {
    final colors = context.colors;
    final petState = ref.watch(petProvider);
    final selectedPet = petState.selectedPet;

    if (_fortune == null || selectedPet == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final species = PetSpecies.fromString(selectedPet.species);
    final data = _fortune!.metadata ?? {};

    return StandardFortuneResultLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Pet info card
          _buildPetInfoHeader(selectedPet, species, colors),
          const SizedBox(height: 20),

          // ✅ 육각형 차트
          if (data['hexagonScores'] != null)
            _buildHexagonChart(data, colors),
          const SizedBox(height: 20),

          // ✅ 무료 섹션: 오늘의 컨디션
          _buildDailyConditionCard(data, colors),
          const SizedBox(height: 16),

          // ✅ 무료 섹션: 주인과의 궁합
          _buildOwnerBondCard(data, colors),
          const SizedBox(height: 16),

          // ✅ 무료 섹션: 행운 아이템
          _buildLuckyItemsCard(data, colors),
          const SizedBox(height: 20),

          // ✅ 프리미엄 섹션: Pet's Voice (킬러 피처!)
          UnifiedBlurWrapper(
            isBlurred: _fortune!.isBlurred,
            blurredSections: _fortune!.blurredSections,
            sectionKey: 'pets_voice',
            child: _buildPetsVoiceCard(data, species, colors),
          ),
          const SizedBox(height: 16),

          // ✅ 프리미엄 섹션: 건강 인사이트
          UnifiedBlurWrapper(
            isBlurred: _fortune!.isBlurred,
            blurredSections: _fortune!.blurredSections,
            sectionKey: 'health_insight',
            child: _buildHealthInsightCard(data, colors),
          ),
          const SizedBox(height: 16),

          // ✅ 프리미엄 섹션: 활동 추천
          UnifiedBlurWrapper(
            isBlurred: _fortune!.isBlurred,
            blurredSections: _fortune!.blurredSections,
            sectionKey: 'activity_recommendation',
            child: _buildActivityCard(data, colors),
          ),
          const SizedBox(height: 16),

          // ✅ 프리미엄 섹션: 감정 케어
          UnifiedBlurWrapper(
            isBlurred: _fortune!.isBlurred,
            blurredSections: _fortune!.blurredSections,
            sectionKey: 'emotional_care',
            child: _buildEmotionalCareCard(data, colors),
          ),
          const SizedBox(height: 16),

          // ✅ 프리미엄 섹션: 특별 조언
          UnifiedBlurWrapper(
            isBlurred: _fortune!.isBlurred,
            blurredSections: _fortune!.blurredSections,
            sectionKey: 'special_tips',
            child: _buildSpecialTipsCard(data, colors),
          ),

          // Action buttons
          if (!_fortune!.isBlurred) ...[
            const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),
            FortuneButtonPositionHelper.parallel(
              leftButton: UnifiedButton(
                text: '다른 반려동물',
                style: UnifiedButtonStyle.secondary,
                size: UnifiedButtonSize.large,
                onPressed: () {
                  setState(() => _fortune = null);
                  ref.read(petProvider.notifier).clearSelectedPet();
                },
              ),
              rightButton: UnifiedButton(
                text: '공유하기',
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('공유 기능이 곧 추가될 예정입니다')),
                  );
                },
              ),
            ),
          ] else
            const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildPetInfoHeader(PetProfile pet, PetSpecies species, DSColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.1),
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(species.emoji, style: context.displayMedium)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pet.name,
                      style: context.heading1.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    if (pet.gender != '모름') ...[
                      const SizedBox(width: 6),
                      Text(
                        PetGender.fromString(pet.gender).symbol,
                        style: TextStyle(
                          fontSize: FontConfig.buttonMedium,
                          color: pet.gender == '수컷' ? colors.accent : DSColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${species.displayName} • ${pet.age}세${pet.breed != null ? ' • ${pet.breed}' : ''}',
                  style: context.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonChart(Map<String, dynamic> data, DSColorScheme colors) {
    final hexagonData = data['hexagonScores'] as Map<String, dynamic>?;
    if (hexagonData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text('오늘의 운세 지수', style: context.heading3.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: HexagonChart(
              scores: hexagonData.map((k, v) => MapEntry(k, (v as num).toInt())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyConditionCard(Map<String, dynamic> data, DSColorScheme colors) {
    final condition = data['daily_condition'] as Map<String, dynamic>?;
    if (condition == null) return const SizedBox.shrink();

    final score = condition['overall_score'] as int? ?? 0;
    final energyLevel = condition['energy_level'] as String? ?? 'medium';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.favorite, color: DSColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text('오늘의 컨디션', style: context.heading3.copyWith(color: colors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$score점', style: context.heading3.copyWith(color: colors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            condition['mood_prediction'] as String? ?? '',
            style: context.bodyLarge.copyWith(
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildEnergyBadge(energyLevel),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  condition['energy_description'] as String? ?? '',
                  style: context.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBadge(String level) {
    final color = level == 'high' ? DSColors.success : level == 'medium' ? DSColors.warning : DSColors.textTertiary;
    final label = level == 'high' ? '활발' : level == 'medium' ? '보통' : '차분';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: context.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOwnerBondCard(Map<String, dynamic> data, DSColorScheme colors) {
    final bond = data['owner_bond'] as Map<String, dynamic>?;
    if (bond == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.favorite_border, color: DSColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text('주인과의 궁합', style: context.heading3.copyWith(color: colors.textPrimary)),
              const Spacer(),
              Text('${bond['bond_score'] ?? 0}점', style: context.heading3.copyWith(color: DSColors.error)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            bond['bonding_tip'] as String? ?? '',
            style: context.bodyLarge.copyWith(color: colors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, color: colors.accent, size: 16),
              const SizedBox(width: 6),
              Text('최적 시간: ${bond['best_time'] ?? ''}', style: context.bodySmall.copyWith(color: colors.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsCard(Map<String, dynamic> data, DSColorScheme colors) {
    final items = data['lucky_items'] as Map<String, dynamic>?;
    if (items == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.stars, color: DSColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text('행운 아이템', style: context.heading3.copyWith(color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLuckyChip('🎨', items['color'] ?? ''),
              _buildLuckyChip('🍖', items['snack'] ?? ''),
              _buildLuckyChip('🎯', items['activity'] ?? ''),
              _buildLuckyChip('⏰', items['time'] ?? ''),
              _buildLuckyChip('📍', items['spot'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyChip(String emoji, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DSColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: context.bodySmall),
          const SizedBox(width: 6),
          Text(text, style: context.bodySmall.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPetsVoiceCard(Map<String, dynamic> data, PetSpecies species, DSColorScheme colors) {
    final voice = data['pets_voice'] as Map<String, dynamic>?;
    if (voice == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.05),
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(species.emoji, style: context.heading2),
              ),
              const SizedBox(width: 12),
              Text("Pet's Voice", style: context.heading3.copyWith(color: const Color(0xFF8B5CF6))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, size: 12, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 4),
                    Text('프리미엄', style: context.labelSmall.copyWith(color: const Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildVoiceBubble('☀️ 아침 인사', voice['morning_message'] ?? '', colors),
          const SizedBox(height: 12),
          _buildVoiceBubble('💕 전하고 싶은 말', voice['to_owner'] ?? '', colors),
          const SizedBox(height: 12),
          _buildVoiceBubble('🤫 비밀 소원', voice['secret_wish'] ?? '', colors),
        ],
      ),
    );
  }

  Widget _buildVoiceBubble(String label, String message, DSColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelSmall.copyWith(color: colors.textTertiary)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Text(
            '"$message"',
            style: context.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInsightCard(Map<String, dynamic> data, DSColorScheme colors) {
    final health = data['health_insight'] as Map<String, dynamic>?;
    if (health == null) return const SizedBox.shrink();

    final checkPoints = (health['check_points'] as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.health_and_safety, color: DSColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text('건강 인사이트', style: context.heading3.copyWith(color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(health['overall'] ?? '', style: context.bodyMedium.copyWith(color: colors.textPrimary, height: 1.5)),
          const SizedBox(height: 12),
          ...checkPoints.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: DSColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(point, style: context.bodySmall.copyWith(color: colors.textSecondary))),
              ],
            ),
          )),
          if (health['seasonal_tip'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DSColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny, color: DSColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(health['seasonal_tip'], style: context.bodySmall.copyWith(color: DSColors.warning))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> data, DSColorScheme colors) {
    final activity = data['activity_recommendation'] as Map<String, dynamic>?;
    if (activity == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_run, color: colors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text('활동 추천', style: context.heading3.copyWith(color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityRow('🌅 아침', activity['morning'] ?? '', colors),
          _buildActivityRow('☀️ 오후', activity['afternoon'] ?? '', colors),
          _buildActivityRow('🌙 저녁', activity['evening'] ?? '', colors),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: colors.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(activity['special_activity'] ?? '', style: context.bodySmall.copyWith(color: colors.accent, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String time, String activity, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: context.bodySmall),
          const SizedBox(width: 12),
          Expanded(child: Text(activity, style: context.bodySmall.copyWith(color: colors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildEmotionalCareCard(Map<String, dynamic> data, DSColorScheme colors) {
    final emotion = data['emotional_care'] as Map<String, dynamic>?;
    if (emotion == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: DSColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text('감정 케어', style: context.heading3.copyWith(color: colors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emotion['primary_emotion'] ?? '', style: context.labelSmall.copyWith(color: const Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(emotion['bonding_tip'] ?? '', style: context.bodyMedium.copyWith(color: colors.textPrimary, height: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DSColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: DSColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('스트레스 신호: ${emotion['stress_indicator'] ?? ''}', style: context.bodySmall.copyWith(color: DSColors.error))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialTipsCard(Map<String, dynamic> data, DSColorScheme colors) {
    final tips = (data['special_tips'] as List<dynamic>?)?.cast<String>() ?? [];
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lightbulb_outline, color: DSColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text('특별 조언', style: context.heading3.copyWith(color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text('${entry.key + 1}', style: context.labelSmall.copyWith(color: DSColors.warning, fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.value, style: context.bodyMedium.copyWith(color: colors.textPrimary, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
