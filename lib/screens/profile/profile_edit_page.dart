import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/fortune_constants.dart';
import '../../core/design_system/design_system.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/profile_image_picker.dart';
import '../../services/supabase_storage_service.dart';
import '../../utils/date_utils.dart' as legacy_date_utils;

const _bloodTypes = ['A', 'B', 'O', 'AB'];

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _storageService = SupabaseStorageService(Supabase.instance.client);

  UserProfile? _originalProfile;
  DateTime? _birthDate;
  String? _birthTime;
  Gender? _gender;
  String? _mbti;
  String? _bloodType;
  String? _profileImageUrl;
  XFile? _pendingImageFile;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadInitialProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProfile() async {
    final profile = await ref
        .read(userProfileNotifierProvider.notifier)
        .ensureLoaded(trigger: 'profileEdit.init');

    if (!mounted) {
      return;
    }

    setState(() {
      _originalProfile = profile;
      _nameController.text = profile?.name ?? '';
      _birthDate = profile?.birthDate;
      _birthTime = profile?.birthTime;
      _gender = profile?.gender;
      _mbti = profile?.mbti;
      _bloodType = profile?.bloodType;
      _profileImageUrl = profile?.profileImageUrl;
      _isLoading = false;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 24, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _birthDate = picked;
    });
  }

  Future<void> _pickBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _parseBirthTime(_birthTime) ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _birthTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _saveProfile() async {
    final currentUser = ref.read(supabaseProvider).auth.currentUser;
    if (currentUser == null) {
      _showMessage('로그인 상태에서만 저장할 수 있어요.', isError: true);
      return;
    }

    if (_nameController.text.trim().isEmpty || _birthDate == null) {
      _showMessage('이름과 생년월일을 입력해 주세요.', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uploadedImageUrl = await _uploadImageIfNeeded(currentUser.id);
      final birthDateIso = _birthDate!.toIso8601String().split('T')[0];
      final updatedProfile = (_originalProfile ??
              UserProfile(
                id: currentUser.id,
                name: _nameController.text.trim(),
                email: currentUser.email ?? '',
                onboardingCompleted: true,
              ))
          .copyWith(
        id: currentUser.id,
        name: _nameController.text.trim(),
        email: currentUser.email ?? _originalProfile?.email ?? '',
        birthDate: _birthDate,
        birthTime: _birthTime,
        gender: _gender ?? Gender.other,
        mbti: _mbti,
        bloodType: _bloodType,
        zodiacSign:
            legacy_date_utils.FortuneDateUtils.getZodiacSign(birthDateIso),
        chineseZodiac:
            legacy_date_utils.FortuneDateUtils.getChineseZodiac(birthDateIso),
        profileImageUrl: uploadedImageUrl ?? _profileImageUrl,
        onboardingCompleted: true,
      );

      await ref
          .read(userProfileNotifierProvider.notifier)
          .updateProfile(updatedProfile);

      if (!mounted) {
        return;
      }

      _showMessage('프로필을 저장했어요.');
      Navigator.of(context).pop();
    } catch (error) {
      _showMessage('프로필 저장에 실패했어요: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String?> _uploadImageIfNeeded(String userId) async {
    if (_pendingImageFile == null) {
      return _profileImageUrl;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _storageService.uploadProfileImage(
        userId: userId,
        imageFile: _pendingImageFile!,
      );

      if (imageUrl != null) {
        await _storageService.cleanupOldProfileImages(
          userId: userId,
          currentImageUrl: imageUrl,
        );
      }

      return imageUrl ?? _profileImageUrl;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? context.colors.error : context.colors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '내 정보 수정',
          style: context.heading3.copyWith(color: colors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.pageHorizontal,
                DSSpacing.md,
                DSSpacing.pageHorizontal,
                DSSpacing.xxl,
              ),
              children: [
                DSCard.elevated(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    children: [
                      ProfileImagePicker(
                        currentImageUrl: _profileImageUrl,
                        isLoading: _isUploadingImage,
                        onImageSelected: (image) {
                          setState(() {
                            _pendingImageFile = image;
                          });
                        },
                      ),
                      const SizedBox(height: DSSpacing.md),
                      Text(
                        '프로필 사진과 기본 정보를 수정할 수 있어요.',
                        style: context.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DSSpacing.xl),
                DSSectionHeader(title: '기본 정보', uppercase: false),
                DSCard.outlined(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(label: '이름'),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '이름을 입력해 주세요',
                        ),
                      ),
                      const SizedBox(height: DSSpacing.lg),
                      _PickerRow(
                        label: '생년월일',
                        value: _birthDate == null
                            ? '선택해 주세요'
                            : _formatDate(_birthDate!),
                        onTap: _pickBirthDate,
                      ),
                      const SizedBox(height: DSSpacing.md),
                      _PickerRow(
                        label: '태어난 시간',
                        value: _birthTime ?? '선택해 주세요',
                        onTap: _pickBirthTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DSSpacing.xl),
                DSSectionHeader(title: '프로필 성향', uppercase: false),
                DSCard.outlined(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(label: '성별'),
                      DSChoiceChips(
                        options: Gender.values
                            .map((gender) => gender.label)
                            .toList(),
                        selected: _gender == null
                            ? null
                            : Gender.values.indexOf(_gender!),
                        onSelected: (index) {
                          setState(() {
                            _gender = Gender.values[index];
                          });
                        },
                      ),
                      const SizedBox(height: DSSpacing.lg),
                      _FieldLabel(label: 'MBTI'),
                      DropdownButtonFormField<String>(
                        initialValue: _mbti,
                        items: mbtiTypes
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _mbti = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: '선택해 주세요',
                        ),
                      ),
                      const SizedBox(height: DSSpacing.lg),
                      _FieldLabel(label: '혈액형'),
                      DropdownButtonFormField<String>(
                        initialValue: _bloodType,
                        items: _bloodTypes
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _bloodType = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: '선택해 주세요',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.sm,
          DSSpacing.pageHorizontal,
          DSSpacing.md,
        ),
        child: DSButton.primary(
          text: _isSaving ? '저장 중...' : '저장하기',
          onPressed: _isSaving ? null : _saveProfile,
        ),
      ),
    );
  }

  TimeOfDay? _parseBirthTime(String? birthTime) {
    if (birthTime == null || birthTime.isEmpty) {
      return null;
    }

    final match = RegExp(r'(\d{2}):(\d{2})').firstMatch(birthTime);
    if (match == null) {
      return null;
    }

    return TimeOfDay(
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Text(
        label,
        style: context.bodyMedium.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: context.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Icon(
              Icons.chevron_right,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}
