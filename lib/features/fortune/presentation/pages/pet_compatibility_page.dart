import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../providers/pet_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../constants/fortune_button_spacing.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/standard_fortune_page_layout.dart';

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
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isInitialized = false;
  final bool _showAddPetForm = false;
  Fortune? _fortune;
  
  // Pet registration form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  PetSpecies _selectedSpecies = PetSpecies.dog;
  
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
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
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
    _scaleController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final petState = ref.watch(petProvider);

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundSecondary,
      appBar: StandardFortuneAppBar(
        title: widget.title,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, size: 20, color: TossTheme.primaryBlue),
            ),
            onPressed: () => _showAddPetBottomSheet(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _fortune != null
          ? _buildFortuneResult()
          : _buildPetSelection(petState),
    );
  }

  Widget _buildPetSelection(PetState petState) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: petState.hasPets 
                  ? _buildPetList(petState.pets)
                  : _buildEmptyState(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossTheme.primaryBlue,
            TossTheme.primaryBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TossTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossDesignSystem.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.pets,
                  color: TossDesignSystem.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '반려동물 궁합',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: TossDesignSystem.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '나와 반려동물의 특별한 궁합을\n확인해보세요',
            style: TextStyle(
              fontSize: 16,
              color: TossDesignSystem.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 800.ms).fadeIn();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final species = PetSpecies.fromString(pet.species);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectPetAndGenerateFortune(pet),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: TossDesignSystem.black.withValues(alpha: 0.06),
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
                  color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    species.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${species.displayName} • ${pet.age}세',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: TossTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .slideX(begin: 0.3)
     .fadeIn(duration: 600.ms);
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.black.withValues(alpha: 0.06),
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
                color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.pets,
                size: 40,
                color: TossTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '등록된 반려동물이 없어요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '오른쪽 위 + 버튼을 눌러\n반려동물을 등록해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),
            TossButton(
              text: '반려동물 등록하기',
              onPressed: () => _showAddPetBottomSheet(),
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
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
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => _buildAddPetForm(),
    );
  }

  Widget _buildAddPetForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
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
                      color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Text(
                  '반려동물 등록',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '반려동물의 정보를 입력해주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Species selection
                        Text(
                          '종류',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSpeciesSelector(setModalState),
                        const SizedBox(height: 24),

                        // Name input
                        Text(
                          '이름',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                          decoration: InputDecoration(
                            hintText: '반려동물의 이름을 입력하세요',
                            hintStyle: TextStyle(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400),
                            filled: true,
                            fillColor: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: TossTheme.primaryBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onChanged: (value) => setModalState(() {}),
                        ),
                        const SizedBox(height: 24),

                        // Age input
                        Text(
                          '나이',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                          decoration: InputDecoration(
                            hintText: '나이를 입력하세요',
                            hintStyle: TextStyle(color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400),
                            suffixText: '세',
                            suffixStyle: TextStyle(color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                            filled: true,
                            fillColor: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: TossTheme.primaryBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onChanged: (value) => setModalState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),

                // Register button
                Consumer(
                  builder: (context, ref, child) {
                    final petState = ref.watch(petProvider);
                    return TossButton(
                      text: '등록하기',
                      onPressed: _canRegisterPet() ? () => _registerPet(context) : null,
                      isLoading: petState.isCreating,
                      size: TossButtonSize.large,
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

  Widget _buildSpeciesSelector(StateSetter setModalState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PetSpecies.values.map((species) {
        final isSelected = _selectedSpecies == species;
        return GestureDetector(
          onTap: () => setModalState(() => _selectedSpecies = species),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                ? TossTheme.primaryBlue.withValues(alpha: 0.1)
                : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray50),
              border: Border.all(
                color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  species.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  species.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
    Logger.info('📝 Pet info - Name: ${_nameController.text.trim()}, Species: ${_selectedSpecies.displayName}, Age: $age, UserId: ${user.id}');
    
    final pet = await ref.read(petProvider.notifier).createPet(
      userId: user.id,
      species: _selectedSpecies.displayName,
      name: _nameController.text.trim(),
      age: age,
    );

    if (pet != null && mounted) {
      Logger.info('✅ Pet registration successful, closing bottom sheet');
      Navigator.of(bottomSheetContext).pop();
      _selectPetAndGenerateFortune(pet);
    } else {
      Logger.error('❌ Pet registration failed');
      final petState = ref.read(petProvider);
      if (petState.hasError && mounted) {
        Logger.error('🔥 Pet state error: ${petState.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(petState.error!),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      } else {
        // Generic error message if no specific error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('반려동물 등록에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _selectPetAndGenerateFortune(PetProfile pet) async {
    ref.read(petProvider.notifier).selectPet(pet);
    await _generateFortune(pet);
  }

  void _resetFortune() {
    setState(() {
      _fortune = null;
    });
  }

  Future<void> _generateFortune(PetProfile pet) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final params = {
        'pet_name': pet.name,
        'pet_species': pet.species,
        'pet_age': pet.age,
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        userId: user.id,
        params: params,
      );

      if (mounted) {
        setState(() => _fortune = fortune);
      }
    } catch (e) {
      Logger.error('Failed to generate pet fortune', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('운세 생성에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildFortuneResult() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final petState = ref.watch(petProvider);
    final selectedPet = petState.selectedPet;

    if (_fortune == null || selectedPet == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final species = PetSpecies.fromString(selectedPet.species);

    return StandardFortuneResultLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet info card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossTheme.primaryBlue.withValues(alpha: 0.1),
                  isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: TossTheme.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      species.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPet.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${species.displayName} • ${selectedPet.age}세',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fortune card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: TossTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '궁합 운세',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _fortune!.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),

          // Action buttons
          FortuneButtonPositionHelper.parallel(
            leftButton: TossButton(
              text: '다른 반려동물',
              style: TossButtonStyle.secondary,
              size: TossButtonSize.large,
              onPressed: () {
                setState(() => _fortune = null);
                ref.read(petProvider.notifier).clearSelectedPet();
              },
            ),
            rightButton: TossButton(
              text: '공유하기',
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('공유 기능이 곧 추가될 예정입니다'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}