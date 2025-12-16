import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/fortune_haptic_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/fortune_constants.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_storage_service.dart';
import '../../utils/date_utils.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/numeric_date_input.dart';
import '../../shared/components/numeric_time_input.dart';
import '../../presentation/widgets/profile_image_picker.dart';
import '../onboarding/widgets/birth_date_preview.dart';
import '../../core/utils/logger.dart';
import '../../core/design_system/design_system.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final StorageService _storageService = StorageService();
  final TextEditingController _nameController = TextEditingController();
  late final SupabaseStorageService _storageService2;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  User? _currentUser;

  // Design System Helper Methods
  Color _getTextColor() {
    return context.colors.textPrimary;
  }

  Color _getSecondaryTextColor() {
    return context.colors.textSecondary;
  }

  Color _getBackgroundColor() {
    return context.colors.background;
  }

  Color _getCardColor() {
    return context.colors.surface;
  }

  // Parse time from birth time string like "축시 (01:00 - 03:00)"
  TimeOfDay? _parseTimeFromBirthTime(String birthTime) {
    try {
      // Extract time from parentheses, e.g., "축시 (01:00 - 03:00)" -> "01:00"
      final timeMatch = RegExp(r'\((\d{2}):(\d{2})').firstMatch(birthTime);
      if (timeMatch != null) {
        final hour = int.parse(timeMatch.group(1)!);
        final minute = int.parse(timeMatch.group(2)!);
        return TimeOfDay(hour: hour, minute: minute);
      }

      // Fallback: try to parse as "HH:MM" directly
      if (birthTime.contains(':')) {
        final parts = birthTime.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0].trim());
          final minute = int.tryParse(parts[1].trim().substring(0, 2));
          if (hour != null && minute != null) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      }
    } catch (e) {
      Logger.error('Failed to parse birth time: $birthTime', e);
    }
    return null;
  }

  // Form values
  DateTime? _birthDate;
  String? _birthTime;
  String? _mbti;
  Gender? _gender;
  String? _profileImageUrl;
  XFile? _pendingImageFile;

  // Original values for comparison
  Map<String, dynamic>? _originalProfile;

  @override
  void initState() {
    super.initState();
    _storageService2 = SupabaseStorageService(Supabase.instance.client);
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      setState(() => _isLoading = true);
      
      // Get current user
      final session = Supabase.instance.client.auth.currentSession;
      _currentUser = session?.user;
      
      // Load profile from local storage first
      final localProfile = await _storageService.getUserProfile();
      
      // If authenticated, try to load from Supabase as well
      Map<String, dynamic>? supabaseProfile;
      if (_currentUser != null) {
        try {
          final response = await Supabase.instance.client
              .from('user_profiles')
              .select()
              .eq('id', _currentUser!.id)
              .maybeSingle();
          supabaseProfile = response;
        } catch (e) {
          debugPrint('Error loading profile from Supabase: $e');
        }
      }
      
      // Use Supabase profile if available, otherwise use local profile
      final profile = supabaseProfile ?? localProfile;
      
      if (profile != null) {
        _originalProfile = Map<String, dynamic>.from(profile);
        
        // Populate form fields
        _nameController.text = profile['name'] ?? '';

        // Parse birth date
        if (profile['birth_date'] != null) {
          try {
            _birthDate = DateTime.parse(profile['birth_date']);
          } catch (e) {
            debugPrint('Error parsing birth date: $e');
          }
        }

        _birthTime = profile['birth_time'];
        _mbti = profile['mbti'];
        _profileImageUrl = profile['profile_image_url'];

        // Parse gender
        if (profile['gender'] != null) {
          _gender = Gender.values.firstWhere(
            (g) => g.value == profile['gender'],
            orElse: () => Gender.other,
          );
        }
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로필을 불러오는 중 오류가 발생했습니다.'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleImageSelected(XFile imageFile) async {
    setState(() {
      _pendingImageFile = imageFile;
    });
  }
  
  Future<String?> _uploadProfileImage() async {
    if (_pendingImageFile == null || _currentUser == null) return _profileImageUrl;
    
    setState(() => _isUploadingImage = true);
    
    try {
      final imageUrl = await _storageService2.uploadProfileImage(
        userId: _currentUser!.id,
        imageFile: _pendingImageFile!,
      );
      
      if (imageUrl != null) {
        // Clean up old images
        await _storageService2.cleanupOldProfileImages(
          userId: _currentUser!.id,
          currentImageUrl: imageUrl,
        );
      }
      
      return imageUrl;
    } catch (e) {
      Logger.error('Error uploading profile image', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로필 이미지 업로드에 실패했습니다.'),
            backgroundColor: context.colors.error,
          ),
        );
      }
      return _profileImageUrl;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    try {
      // Validate required fields
      if (_nameController.text.isEmpty || _birthDate == null) {
        throw Exception('필수 정보를 모두 입력해주세요.');
      }

      // Upload profile image if there's a pending one
      final uploadedImageUrl = await _uploadProfileImage();

      // ISO date from DateTime
      final isoDate = _birthDate!.toIso8601String().split('T')[0];

      // Prepare profile data
      final profile = UserProfile(
        id: _currentUser?.id ?? '',
        name: _nameController.text,
        email: _currentUser?.email ?? _originalProfile?['email'] ?? '',
        birthDate: isoDate,
        birthTime: _birthTime,
        mbti: _mbti,
        gender: _gender ?? Gender.other,
        zodiacSign: FortuneDateUtils.getZodiacSign(isoDate),
        chineseZodiac: FortuneDateUtils.getChineseZodiac(isoDate),
        onboardingCompleted: true,
        subscriptionStatus: SubscriptionStatus.free,
        fortuneCount: _originalProfile?['fortune_count'] ?? 0,
        premiumFortunesCount: _originalProfile?['premium_fortunes_count'] ?? 0,
        profileImageUrl: uploadedImageUrl ?? _profileImageUrl,
        linkedProviders: _originalProfile?['linked_providers'] != null
            ? List<String>.from(_originalProfile!['linked_providers'])
            : null,
        primaryProvider: _originalProfile?['primary_provider'],
        createdAt: _originalProfile?['created_at'] != null
            ? DateTime.parse(_originalProfile!['created_at'])
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _storageService.saveUserProfile(profile.toJson());

      // If authenticated, sync with Supabase
      if (_currentUser != null) {
        try {
          await Supabase.instance.client.from('user_profiles').upsert({
            'id': _currentUser!.id,
            'email': _currentUser!.email,
            'name': _nameController.text,
            'birth_date': isoDate,
            'birth_time': _birthTime,
            'mbti': _mbti,
            'gender': _gender?.value,
            'profile_image_url': uploadedImageUrl ?? _profileImageUrl,
            'onboarding_completed': true,
            'zodiac_sign': profile.zodiacSign,
            'chinese_zodiac': profile.chineseZodiac,
            'updated_at': DateTime.now().toIso8601String(),
          });
          debugPrint('✅ Profile synced with Supabase successfully');
          debugPrint('✅ Updated profile name: ${_nameController.text}');
        } catch (e) {
          debugPrint('Error loading profile from Supabase: $e');
          // Continue even if Supabase sync fails
        }
      }
      
      if (mounted) {
        // 저장 완료 햅틱
        ref.read(fortuneHapticServiceProvider).sectionComplete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로필이 성공적으로 업데이트되었습니다.'),
            backgroundColor: context.colors.success,
          ),
        );

        // 프로필 업데이트 성공 시 true를 반환하여 이전 화면에 알림
        context.pop(true);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(),
        body: Center(
          child: CircularProgressIndicator(
            color: context.colors.accent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: '프로필 편집',
              backgroundColor: _getBackgroundColor(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(DSSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Image Picker
                Container(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  decoration: BoxDecoration(
                    color: _getCardColor(),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfileImagePicker(
                        currentImageUrl: _profileImageUrl,
                        onImageSelected: _handleImageSelected,
                        isLoading: _isUploadingImage,
                      ),
                      const SizedBox(height: DSSpacing.md),
                      Text(
                        '프로필 사진',
                        style: DSTypography.labelLarge.copyWith(
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      Text(
                        '카메라 또는 갤러리에서 사진을 선택하세요',
                        style: DSTypography.bodySmall.copyWith(
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DSSpacing.md),


                Container(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  decoration: BoxDecoration(
                    color: _getCardColor(),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name input
                      TextField(
                        controller: _nameController,
                        style: DSTypography.bodyMedium.copyWith(
                          color: _getTextColor(),
                        ),
                        decoration: InputDecoration(
                          hintText: '홍길동',
                          labelText: '이름',
                          labelStyle: DSTypography.bodySmall.copyWith(
                            color: _getSecondaryTextColor(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.sm),
                          ),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.lg),

                      // Birth date input (숫자패드)
                      NumericDateInput(
                        initialDate: _birthDate,
                        label: '생년월일',
                        hint: 'YYYY-MM-DD',
                        onDateChanged: (date) {
                          setState(() {
                            _birthDate = date;
                          });
                        },
                        firstDate: DateTime(1900, 1, 1),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 20),

                      // Birth time input (숫자패드)
                      NumericTimeInput(
                        initialTime: _birthTime != null
                            ? _parseTimeFromBirthTime(_birthTime!)
                            : null,
                        label: '태어난 시간',
                        hint: 'HH:MM',
                        required: false,
                        onTimeChanged: (time) {
                          setState(() {
                            _birthTime = time;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Birth date preview
                      if (_birthDate != null)
                        BirthDatePreview(
                          birthYear: _birthDate!.year.toString(),
                          birthMonth: _birthDate!.month.toString(),
                          birthDay: _birthDate!.day.toString(),
                          birthTimePeriod: _birthTime,
                        ),
                      const SizedBox(height: 20),

                      // MBTI Selection
                      Text(
                        'MBTI 성격 유형',
                        style: DSTypography.labelLarge.copyWith(
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      Text(
                        'MBTI를 모르시나요? 온라인 테스트를 통해 확인해보세요.',
                        style: DSTypography.bodySmall.copyWith(
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.md),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2,
                        ),
                        itemCount: mbtiTypes.length,
                        itemBuilder: (context, index) {
                          final type = mbtiTypes[index];
                          final isSelected = _mbti == type;

                          return InkWell(
                            onTap: () {
                              ref.read(fortuneHapticServiceProvider).selection();
                              setState(() => _mbti = type);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colors.accent
                                    : _getCardColor(),
                                border: Border.all(
                                  color: isSelected
                                      ? context.colors.accent
                                      : context.colors.border,
                                ),
                                borderRadius: BorderRadius.circular(DSRadius.sm),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: DSTypography.bodySmall.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : _getTextColor(),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Gender Selection
                      Text(
                        '성별',
                        style: DSTypography.labelLarge.copyWith(
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.md),
                      Row(
                        children: [
                          ...Gender.values.map((gender) {
                            final isSelected = _gender == gender;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: gender != Gender.values.last ? 8 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    ref.read(fortuneHapticServiceProvider).selection();
                                    setState(() => _gender = gender);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? context.colors.accent
                                          : _getCardColor(),
                                      border: Border.all(
                                        color: isSelected
                                            ? context.colors.accent
                                            : context.colors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(DSRadius.sm),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          gender.icon,
                                          size: 32,
                                          color: isSelected
                                              ? Colors.white
                                              : _getTextColor(),
                                        ),
                                        const SizedBox(height: DSSpacing.sm),
                                        Text(
                                          gender.label,
                                          style: DSTypography.bodySmall.copyWith(
                                            color: isSelected
                                                ? Colors.white
                                                : _getTextColor(),
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      ElevatedButton(
                        onPressed: (_isSaving || _isUploadingImage) ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.ctaBackground,
                          foregroundColor: context.colors.ctaForeground,
                          disabledBackgroundColor: context.colors.ctaBackground.withValues(alpha: 0.5),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DSRadius.md),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '저장',
                                style: DSTypography.buttonMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: DSSpacing.md),

                      // Cancel button
                      TextButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DSRadius.md),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: DSTypography.buttonMedium.copyWith(
                            color: _isSaving
                                ? context.colors.textTertiary
                                : context.colors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}