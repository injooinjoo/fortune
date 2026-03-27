import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/fortune_constants.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
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
    final currentUser = ref.watch(supabaseProvider).auth.currentUser;
    final email = currentUser?.email ?? _originalProfile?.email ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PaperRuntimeAppBar(
        title: '프로필 수정',
        leadingText: '취소',
        onLeadingTextTap: () => Navigator.of(context).maybePop(),
        trailing: TextButton(
          onPressed: _isLoading || _isSaving ? null : _saveProfile,
          child: Text(
            _isSaving ? '저장 중' : '저장',
            style: context.bodyMedium.copyWith(
              color: _isLoading || _isSaving
                  ? colors.textTertiary
                  : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PaperRuntimeBackground(
              showRings: false,
              applySafeArea: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.pageHorizontal,
                  DSSpacing.md,
                  DSSpacing.pageHorizontal,
                  DSSpacing.xxl,
                ),
                children: [
                  Center(
                    child: ProfileImagePicker(
                      currentImageUrl: _profileImageUrl,
                      isLoading: _isUploadingImage,
                      onImageSelected: (image) {
                        setState(() {
                          _pendingImageFile = image;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _FieldBlock(
                    label: '이름',
                    child: TextField(
                      controller: _nameController,
                      style: context.bodyLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: paperRuntimeInputDecoration(
                        context,
                        hintText: '이름을 입력해 주세요',
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  _FieldBlock(
                    label: '이메일',
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(text: email),
                      style: context.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                      decoration: paperRuntimeInputDecoration(
                        context,
                        enabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  _FieldBlock(
                    label: '생년월일',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DSRadius.xxl),
                      onTap: _pickBirthDate,
                      child: IgnorePointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: _birthDate == null
                                ? ''
                                : _formatDate(_birthDate!),
                          ),
                          style: context.bodyLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                          decoration: paperRuntimeInputDecoration(
                            context,
                            hintText: '생년월일을 선택해 주세요',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  _FieldBlock(
                    label: '성별',
                    child: Row(
                      children: Gender.values.take(2).map((gender) {
                        final selected = _gender == gender;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: gender == Gender.male ? DSSpacing.sm : 0,
                            ),
                            child: PaperRuntimeButton(
                              label: gender.label,
                              onPressed: () {
                                setState(() {
                                  _gender = gender;
                                });
                              },
                              expanded: true,
                              variant: selected
                                  ? PaperRuntimeButtonVariant.primary
                                  : PaperRuntimeButtonVariant.secondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  PaperRuntimeExpandablePanel(
                    title: '추가 정보',
                    subtitle: '태어난 시간, MBTI, 혈액형',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldBlock(
                          label: '태어난 시간',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(DSRadius.xxl),
                            onTap: _pickBirthTime,
                            child: IgnorePointer(
                              child: TextField(
                                controller: TextEditingController(
                                  text: _birthTime ?? '',
                                ),
                                style: context.bodyLarge.copyWith(
                                  color: colors.textPrimary,
                                ),
                                decoration: paperRuntimeInputDecoration(
                                  context,
                                  hintText: '시간을 선택해 주세요',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.lg),
                        _FieldBlock(
                          label: 'MBTI',
                          child: DropdownButtonFormField<String>(
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
                            style: context.bodyLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                            decoration: paperRuntimeInputDecoration(
                              context,
                              hintText: '선택해 주세요',
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.lg),
                        _FieldBlock(
                          label: '혈액형',
                          child: DropdownButtonFormField<String>(
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
                            style: context.bodyLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                            decoration: paperRuntimeInputDecoration(
                              context,
                              hintText: '선택해 주세요',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

class _FieldBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldBlock({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        child,
      ],
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}년 ${date.month}월 ${date.day}일';
}
