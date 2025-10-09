import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/fortune_constants.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_storage_service.dart';
import '../../utils/date_utils.dart';
import '../../shared/components/app_header.dart';
import '../../presentation/widgets/profile_image_picker.dart';
import '../onboarding/widgets/birth_date_preview.dart';
import '../../core/utils/logger.dart';
import '../../core/theme/toss_design_system.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final StorageService _storageService = StorageService();
  final TextEditingController _nameController = TextEditingController();
  late final SupabaseStorageService _storageService2;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  User? _currentUser;

  // TOSS Design System Helper Methods
  bool _isDarkMode() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor() {
    return _isDarkMode()
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor() {
    return _isDarkMode()
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getBackgroundColor() {
    return _isDarkMode()
        ? TossDesignSystem.grayDark50
        : TossDesignSystem.white;
  }

  Color _getCardColor() {
    return _isDarkMode()
        ? TossDesignSystem.grayDark100
        : TossDesignSystem.white;
  }

  // Form values
  String _birthYear = '';
  String _birthMonth = '';
  String _birthDay = '';
  String? _birthTimePeriod;
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
            final birthDate = DateTime.parse(profile['birth_date']);
            _birthYear = birthDate.year.toString();
            _birthMonth = birthDate.month.toString();
            _birthDay = birthDate.day.toString();
          } catch (e) {
            debugPrint('Error loading profile from Supabase: $e');
          }
        }
        
        _birthTimePeriod = profile['birth_time'];
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
          const SnackBar(
            content: Text('프로필을 불러오는 중 오류가 발생했습니다.'),
            backgroundColor: TossDesignSystem.errorRed,
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
          const SnackBar(
            content: Text('프로필 이미지 업로드에 실패했습니다.'),
            backgroundColor: TossDesignSystem.errorRed,
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
      if (_nameController.text.isEmpty ||
          _birthYear.isEmpty ||
          _birthMonth.isEmpty ||
          _birthDay.isEmpty) {
        throw Exception('필수 정보를 모두 입력해주세요.');
      }
      
      // Upload profile image if there's a pending one
      final uploadedImageUrl = await _uploadProfileImage();
      
      // Convert Korean date to ISO format
      final isoDate = FortuneDateUtils.koreanToIsoDate(
        _birthYear,
        _birthMonth,
        _birthDay,
      );
      
      // Prepare profile data
      final profile = UserProfile(
        id: _currentUser?.id ?? '',
        name: _nameController.text,
        email: _currentUser?.email ?? _originalProfile?['email'] ?? '',
        birthDate: isoDate,
        birthTime: _birthTimePeriod,
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
            'birth_time': _birthTimePeriod,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 성공적으로 업데이트되었습니다.'),
            backgroundColor: TossDesignSystem.successGreen,
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
            backgroundColor: TossDesignSystem.errorRed,
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
        body: const Center(
          child: CircularProgressIndicator(
            color: TossDesignSystem.tossBlue,
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
            padding: const EdgeInsets.all(TossDesignSystem.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Image Picker
                Container(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingL),
                  decoration: TossDesignSystem.cardDecoration(
                    backgroundColor: _getCardColor(),
                    shadows: TossDesignSystem.shadowS,
                  ),
                  child: Column(
                    children: [
                      ProfileImagePicker(
                        currentImageUrl: _profileImageUrl,
                        onImageSelected: _handleImageSelected,
                        isLoading: _isUploadingImage,
                      ),
                      const SizedBox(height: TossDesignSystem.spacingM),
                      Text(
                        '프로필 사진',
                        style: TossDesignSystem.heading4.copyWith(
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacingS),
                      Text(
                        '카메라 또는 갤러리에서 사진을 선택하세요',
                        style: TossDesignSystem.caption.copyWith(
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TossDesignSystem.spacingM),


                Container(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingL),
                  decoration: TossDesignSystem.cardDecoration(
                    backgroundColor: _getCardColor(),
                    shadows: TossDesignSystem.shadowS,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name input
                      TextField(
                        controller: _nameController,
                        style: TossDesignSystem.body1.copyWith(
                          color: _getTextColor(),
                        ),
                        decoration: TossDesignSystem.inputDecoration(
                          hintText: '홍길동',
                        ).copyWith(
                          labelText: '이름',
                          labelStyle: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacingL),

                      // Birth year
                      DropdownButtonFormField<String>(
                        value: _birthYear.isEmpty ? null : _birthYear,
                        style: TossDesignSystem.body1.copyWith(
                          color: _getTextColor(),
                        ),
                        dropdownColor: _getCardColor(),
                        decoration: TossDesignSystem.inputDecoration(
                          hintText: '년도 선택',
                        ).copyWith(
                          labelText: '생년',
                          labelStyle: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(),
                          ),
                        ),
                        items: FortuneDateUtils.getYearOptions().map((year) => DropdownMenuItem(
                          value: year.toString(),
                          child: Text('$year년'),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _birthYear = value ?? '';
                            // Reset day if invalid for new year/month combination
                            if (_birthDay.isNotEmpty) {
                              final maxDays = FortuneDateUtils.getDayOptions(
                                int.parse(value!),
                                _birthMonth.isNotEmpty ? int.parse(_birthMonth) : null,
                              ).length;
                              if (int.parse(_birthDay) > maxDays) {
                                _birthDay = '';
                              }
                            }
                          });
                        },
                        hint: const Text('년도 선택'),
                      ),
                      const SizedBox(height: 16),

                      // Birth month
                      DropdownButtonFormField<String>(
                        value: _birthMonth.isEmpty ? null : _birthMonth,
                        decoration: InputDecoration(
                          labelText: '생월',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: FortuneDateUtils.getMonthOptions().map((month) => DropdownMenuItem(
                          value: month.toString(),
                          child: Text('$month월'),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _birthMonth = value ?? '';
                            // Reset day if invalid for new year/month combination
                            if (_birthDay.isNotEmpty && _birthYear.isNotEmpty) {
                              final maxDays = FortuneDateUtils.getDayOptions(
                                int.parse(_birthYear),
                                int.parse(value!),
                              ).length;
                              if (int.parse(_birthDay) > maxDays) {
                                _birthDay = '';
                              }
                            }
                          });
                        },
                        hint: const Text('월 선택'),
                      ),
                      const SizedBox(height: 16),

                      // Birth day
                      DropdownButtonFormField<String>(
                        value: _birthDay.isEmpty ? null : _birthDay,
                        decoration: InputDecoration(
                          labelText: '생일',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: FortuneDateUtils.getDayOptions(
                          _birthYear.isNotEmpty ? int.parse(_birthYear) : null,
                          _birthMonth.isNotEmpty ? int.parse(_birthMonth) : null,
                        ).map((day) => DropdownMenuItem(
                          value: day.toString(),
                          child: Text('$day일'),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _birthDay = value ?? '');
                        },
                        hint: const Text('일 선택'),
                      ),
                      const SizedBox(height: 16),

                      // Birth time period
                      DropdownButtonFormField<String>(
                        value: _birthTimePeriod,
                        decoration: InputDecoration(
                          labelText: '태어난 시진 (선택사항)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: timePeriods.map((period) => DropdownMenuItem(
                          value: period.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(period.label),
                              Text(
                                period.description,
                                style: TossDesignSystem.caption.copyWith(
                                  color: _getSecondaryTextColor(),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _birthTimePeriod = value);
                        },
                        hint: const Text('시진 선택'),
                      ),
                      const SizedBox(height: 20),

                      // Birth date preview
                      if (_birthYear.isNotEmpty && _birthMonth.isNotEmpty && _birthDay.isNotEmpty)
                        BirthDatePreview(
                          birthYear: _birthYear,
                          birthMonth: _birthMonth,
                          birthDay: _birthDay,
                          birthTimePeriod: _birthTimePeriod,
                        ),
                      const SizedBox(height: 20),

                      // MBTI Selection
                      Text(
                        'MBTI 성격 유형',
                        style: TossDesignSystem.heading4.copyWith(
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacingS),
                      Text(
                        'MBTI를 모르시나요? 온라인 테스트를 통해 확인해보세요.',
                        style: TossDesignSystem.caption.copyWith(
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacingM),
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
                              setState(() => _mbti = type);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? TossDesignSystem.tossBlue
                                    : _getCardColor(),
                                border: Border.all(
                                  color: isSelected
                                      ? TossDesignSystem.tossBlue
                                      : TossDesignSystem.gray300,
                                ),
                                borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: TossDesignSystem.body2.copyWith(
                                    color: isSelected
                                        ? TossDesignSystem.white
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
                        style: TossDesignSystem.heading4.copyWith(
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacingM),
                      Row(
                        children: Gender.values.map((gender) {
                          final isSelected = _gender == gender;
                          
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: gender != Gender.values.last ? 8 : 0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _gender = gender);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: TossDesignSystem.spacingM),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? TossDesignSystem.tossBlue
                                        : _getCardColor(),
                                    border: Border.all(
                                      color: isSelected
                                          ? TossDesignSystem.tossBlue
                                          : TossDesignSystem.gray300,
                                    ),
                                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        gender.icon,
                                        size: 32,
                                        color: isSelected
                                            ? TossDesignSystem.white
                                            : _getTextColor(),
                                      ),
                                      const SizedBox(height: TossDesignSystem.spacingS),
                                      Text(
                                        gender.label,
                                        style: TossDesignSystem.body2.copyWith(
                                          color: isSelected
                                              ? TossDesignSystem.white
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
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      ElevatedButton(
                        onPressed: (_isSaving || _isUploadingImage) ? null : _saveProfile,
                        style: TossDesignSystem.primaryButtonStyle(
                          isEnabled: !_isSaving && !_isUploadingImage,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TossDesignSystem.white,
                                ),
                              )
                            : Text(
                                '저장',
                                style: TossDesignSystem.button.copyWith(
                                  color: TossDesignSystem.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacingM),

                      // Cancel button
                      TextButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        style: TossDesignSystem.ghostButtonStyle(
                          isEnabled: !_isSaving,
                        ),
                        child: Text(
                          '취소',
                          style: TossDesignSystem.button.copyWith(
                            color: _isSaving
                                ? TossDesignSystem.gray400
                                : TossDesignSystem.tossBlue,
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