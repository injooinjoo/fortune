import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';  // ✅ ImageFilter.blur 사용
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../providers/pet_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/token_provider.dart';  // ✅ Premium 체크용
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/ad_service.dart';  // ✅ RewardedAd용
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
  late Animation<double> _fadeAnimation;

  bool _isInitialized = false;
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
      // ✅ Phase 5-1: Scaffold body를 Stack으로 감쌈
      body: Stack(
        children: [
          // 기존 body 컨텐츠
          _fortune != null
              ? _buildFortuneResult()
              : _buildPetSelection(petState),

          // ✅ Phase 5-2: UnifiedButton.floating 추가 (블러 상태일 때만 표시)
          if (_fortune != null && _fortune!.isBlurred)
            UnifiedButton.floating(
              text: '광고 보고 전체 내용 확인하기',
              onPressed: _showAdAndUnblur,
              style: UnifiedButtonStyle.primary,
              size: UnifiedButtonSize.large,
              icon: Icon(Icons.play_arrow, color: TossDesignSystem.white),
            ),
        ],
      ),
    );
  }

  Widget _buildPetSelection(PetState petState) {
    if (!_isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final species = PetSpecies.fromString(pet.species);
    final petId = pet.id ?? '';

    return Dismissible(
      key: Key(petId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (petId.isEmpty) return false;
        return await showDialog<bool>(
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
                style: TextButton.styleFrom(foregroundColor: TossDesignSystem.errorRed),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        if (petId.isNotEmpty) {
          ref.read(petProvider.notifier).deletePet(petId);
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: TossDesignSystem.errorRed,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline,
          color: TossDesignSystem.white,
          size: 28,
        ),
      ),
      child: Container(
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
                      style: TypographyUnified.displaySmall,
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
                        style: TypographyUnified.heading3.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '${species.displayName} • ${pet.age}세',
                        style: TypographyUnified.bodyMedium.copyWith(
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
            SizedBox(height: 24),
            Text(
              '등록된 반려동물이 없어요',
              style: TypographyUnified.heading3.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '오른쪽 위 + 버튼을 눌러\n반려동물을 등록해보세요',
              textAlign: TextAlign.center,
              style: TypographyUnified.bodyLarge.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
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
                SizedBox(height: 24),

                // Header
                Text(
                  '반려동물 등록',
                  style: TypographyUnified.displaySmall.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '반려동물의 정보를 입력해주세요',
                  style: TypographyUnified.bodyLarge.copyWith(
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
                          style: TypographyUnified.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSpeciesSelector(setModalState),
                        SizedBox(height: 24),

                        // Name input
                        Text(
                          '이름',
                          style: TypographyUnified.bodyLarge.copyWith(
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
                        SizedBox(height: 24),

                        // Age input
                        Text(
                          '나이',
                          style: TypographyUnified.bodyLarge.copyWith(
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
                  style: TypographyUnified.heading3,
                ),
                SizedBox(width: 8),
                Text(
                  species.displayName,
                  style: TypographyUnified.bodyMedium.copyWith(
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

    if (!mounted) return;

    if (pet != null) {
      Logger.info('✅ Pet registration successful, closing bottom sheet');
      if (bottomSheetContext.mounted) Navigator.of(bottomSheetContext).pop();
      _selectPetAndGenerateFortune(pet);
    } else {
      Logger.error('❌ Pet registration failed');
      final petState = ref.read(petProvider);
      if (petState.hasError) {
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


  Future<void> _generateFortune(PetProfile pet) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      // ✅ Premium 체크
      final tokenState = ref.read(tokenProvider);
      final isPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      debugPrint('💎 [PetCompatibilityPage] Premium 상태: $isPremium');

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

      // ✅ 블러 로직 추가
      final isBlurred = !isPremium;
      final blurredSections = isBlurred ? ['detailed_content'] : <String>[];

      debugPrint('🔒 [PetCompatibilityPage] isBlurred: $isBlurred, blurredSections: $blurredSections');

      final fortuneWithBlur = fortune.copyWith(
        isBlurred: isBlurred,
        blurredSections: blurredSections,
      );

      if (mounted) {
        setState(() => _fortune = fortuneWithBlur);
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

  // ✅ Phase 3-1: RewardedAd 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    if (_fortune == null) return;

    debugPrint('[PetCompatibilityPage] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[PetCompatibilityPage] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[PetCompatibilityPage] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[PetCompatibilityPage] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _fortune = _fortune!.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[PetCompatibilityPage] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제해서 콘텐츠 볼 수 있게 함
      if (mounted) {
        setState(() {
          _fortune = _fortune!.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  // ✅ Phase 3-2: 블러 래퍼 헬퍼
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (_fortune == null || !_fortune!.isBlurred || !_fortune!.blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
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
                      style: TypographyUnified.displayLarge,
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
                        style: TypographyUnified.displaySmall.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${species.displayName} • ${selectedPet.age}세',
                        style: TypographyUnified.bodyLarge.copyWith(
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

          // ✅ Phase 4-1 & 4-2: Fortune card (블러 + 프리미엄 배지)
          _buildBlurWrapper(
            sectionKey: 'detailed_content',
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
                      SizedBox(width: 12),
                      Text(
                        '궁합 운세',
                        style: TypographyUnified.heading3.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      const Spacer(),
                      // ✅ 프리미엄 배지
                      if (_fortune!.isBlurred && _fortune!.blurredSections.contains('detailed_content'))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock, size: 12, color: TossTheme.primaryBlue),
                              const SizedBox(width: 4),
                              Text(
                                '프리미엄',
                                style: TypographyUnified.labelSmall.copyWith(
                                  color: TossTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    _fortune!.content,
                    style: TypographyUnified.bodyLarge.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FortuneButtonSpacing.buttonTopSpacing),

          // Action buttons
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