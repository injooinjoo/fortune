import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import '../../core/utils/supabase_helper.dart';
import '../../core/utils/logger.dart';
import '../../utils/date_utils.dart';
import 'profile_edit_dialogs/index.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../shared/components/base_card.dart';

class UserInfoCard extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback? onProfileUpdated;
  
  const UserInfoCard({
    super.key,
    required this.userProfile,
    this.onProfileUpdated});

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  final _storageService = StorageService();
  final _supabase = Supabase.instance.client;
  
  Map<String, dynamic>? get userProfile => widget.userProfile;

  Future<void> _updateProfileField(String field, dynamic value) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      // Update local storage
      if (userProfile != null) {
        final updatedProfile = Map<String, dynamic>.from(userProfile!);
        updatedProfile[field] = value;
        
        // Calculate zodiac and constellation if birth_date is updated
        if (field == 'birth_date' && value != null) {
          updatedProfile['zodiac_sign'] = FortuneDateUtils.getZodiacSign(value);
          updatedProfile['chinese_zodiac'] = FortuneDateUtils.getChineseZodiac(value);
        }
        
        await _storageService.saveUserProfile(updatedProfile);
      }
      
      // Update Supabase if user is authenticated
      if (userId != null) {
        final updates = {field: value};
        
        // Add calculated fields if birth_date is updated
        if (field == 'birth_date' && value != null) {
          updates['zodiac_sign'] = FortuneDateUtils.getZodiacSign(value);
          updates['chinese_zodiac'] = FortuneDateUtils.getChineseZodiac(value);
        }
        
        await SupabaseHelper.updateUserProfile(
          userId: userId,
          updates: updates);
      }
      
      // Notify parent widget to reload
      widget.onProfileUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 업데이트되었습니다'),
            backgroundColor: TossDesignSystem.successGreen));
      }
    } catch (e) {
      Logger.error('Failed to update profile field', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('실패: ${e.toString()}'),
            backgroundColor: TossDesignSystem.errorRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (userProfile == null) return const SizedBox.shrink();
    
    return BaseCard(
      padding: AppSpacing.paddingAll20,
      borderRadius: AppDimensions.borderRadiusMedium,
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기본 정보',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              Text(
                '基本情報',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing5),
          
          // 프로필 이미지와 이름
          Row(
            children: [
              _buildProfileImage(context),
              const SizedBox(width: AppSpacing.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.spacing1),
                    if (userProfile!['birth_date'] != null) ...[
                      Row(
                        children: [
                          Text(
                            _calculateAge(userProfile!['birth_date']),
                            style: theme.textTheme.bodyLarge),
                          const SizedBox(width: AppSpacing.spacing2),
                          Text(
                            '·',
                            style: theme.textTheme.bodyLarge),
                          const SizedBox(width: AppSpacing.spacing2),
                          Text(
                            _getGenderLabel(userProfile!['gender']),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.spacing5),
          
          // 정보 그리드
          _buildInfoGrid(context),
        ],
      ),
    );
  }
  
  Widget _buildProfileImage(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 2)),
      child: ClipOval(
        child: userProfile?['profile_photo_url'] != null
            ? Image.network(
                userProfile!['profile_photo_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(context),
              )
            : _buildDefaultAvatar(context),
      ),
    );
  }
  
  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: 40,
        color: Theme.of(context).colorScheme.primary));
  }
  
  Widget _buildInfoGrid(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(context, [
          _InfoItem(
            icon: Icons.cake,
            label: '생년월일',
            value: _formatBirthDate(userProfile!['birth_date']),
            onTap: () => _showBirthDateEditDialog(context)),
          _InfoItem(
            icon: Icons.access_time,
            label: '출생시간',
            value: userProfile!['birth_time'] ?? '미입력',
            onTap: () => _showBirthTimeEditDialog(context))]),
        const SizedBox(height: AppSpacing.spacing3),
        _buildInfoRow(context, [
          _InfoItem(
            icon: Icons.pets,
            label: '띠',
            value: userProfile!['chinese_zodiac'] ?? _calculateZodiacAnimal(userProfile!['birth_date']),
            onTap: () => _showBirthDateEditDialog(context), // 생년월일 수정 시 자동 계산
          ),
          _InfoItem(
            icon: Icons.stars,
            label: '별자리',
            value: userProfile!['zodiac_sign'] ?? _calculateZodiacSign(userProfile!['birth_date']),
            onTap: () => _showBirthDateEditDialog(context), // 생년월일 수정 시 자동 계산
          )]),
        const SizedBox(height: AppSpacing.spacing3),
        _buildInfoRow(context, [
          _InfoItem(
            icon: Icons.water_drop,
            label: '혈액형',
            value: userProfile!['blood_type'] != null ? '${userProfile!['blood_type']}형' : '미입력',
            onTap: () => _showBloodTypeEditDialog(context)),
          _InfoItem(
            icon: Icons.psychology,
            label: 'MBTI',
            value: userProfile!['mbti']?.toUpperCase() ?? '미입력',
            onTap: () => _showMbtiEditDialog(context))])]);
  }
  
  void _showBirthDateEditDialog(BuildContext context) {
    final currentDate = userProfile!['birth_date'] != null
        ? DateTime.tryParse(userProfile!['birth_date'])
        : null;
    
    showDialog(
      context: context,
      builder: (context) => BirthDateEditDialog(
        initialDate: currentDate,
        onSave: (date) async {
          await _updateProfileField('birth_date', date.toIso8601String().split('T')[0]);
        }));
  }
  
  void _showBirthTimeEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BirthTimeEditDialog(
        initialTime: userProfile!['birth_time'],
        onSave: (time) async {
          await _updateProfileField('birth_time', time);
        }));
  }
  
  void _showBloodTypeEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BloodTypeEditDialog(
        initialBloodType: userProfile!['blood_type'],
        onSave: (bloodType) async {
          await _updateProfileField('blood_type', bloodType);
        }));
  }
  
  void _showMbtiEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MbtiEditDialog(
        initialMbti: userProfile!['mbti'],
        onSave: (mbti) async {
          await _updateProfileField('mbti', mbti);
        }));
  }
  
  Widget _buildInfoRow(BuildContext context, List<_InfoItem> items) {
    return Row(
      children: items.map((item) => Expanded(
        child: _buildInfoItem(context, item, items))).toList());
  }
  
  Widget _buildInfoItem(BuildContext context, _InfoItem item, List<_InfoItem> items) {
    final theme = Theme.of(context);

    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: AppDimensions.borderRadiusSmall,
        child: Container(
          padding: AppSpacing.paddingAll12,
          margin: EdgeInsets.only(
            right: items.indexOf(item) == 0 ? 6 : 0,
            left: items.indexOf(item) == 1 ? 6 : 0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark800
                : TossDesignSystem.gray50,
            borderRadius: AppDimensions.borderRadiusSmall),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: AppDimensions.iconSizeSmall,
                color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.spacing2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxSmall),
                    Text(
                      item.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _calculateAge(String? birthDate) {
    if (birthDate == null) return '나이 미상';
    
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      
      if (now.month < birth.month || 
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      
      return '$age세';
    } catch (e) {
      return '나이 미상';
    }
  }
  
  String _formatBirthDate(String? birthDate) {
    if (birthDate == null) return '미입력';
    
    try {
      final date = DateTime.parse(birthDate);
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } catch (e) {
      return birthDate;
    }
  }
  
  String _calculateZodiacAnimal(String? birthDate) {
    if (birthDate == null) return '미입력';
    
    try {
      return FortuneDateUtils.getChineseZodiac(birthDate);
    } catch (e) {
      return '미입력';
    }
  }
  
  String _calculateZodiacSign(String? birthDate) {
    if (birthDate == null) return '미입력';
    
    try {
      return FortuneDateUtils.getZodiacSign(birthDate);
    } catch (e) {
      return '미입력';
    }
  }

  String _getDisplayName() {
    final name = userProfile!['name'] as String?;
    final email = userProfile!['email'] as String?;
    
    // 이름이 없거나 기본값인 경우
    if (name == null || name.isEmpty || name == '사용자') {
      // 이메일에서 이름 추출 시도
      if (email != null && email.isNotEmpty) {
        // 카카오 형식 이메일이 아닌 경우에만 이메일에서 이름 추출
        if (!email.startsWith('kakao_')) {
          return email.split('@')[0];
        }
      }
      return '사용자';
    }
    
    // 카카오 ID 형식인 경우
    if (name.startsWith('kakao_') && name.contains('@')) {
      return '사용자';
    }
    
    return name;
  }

  String _getGenderLabel(String? gender) {
    if (gender == null) return '미입력';
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      case 'other':
        return '선택 안함';
      default:
        return gender;
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap});
}