import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import '../../core/utils/supabase_helper.dart';
import '../../core/utils/logger.dart';
import '../../constants/fortune_constants.dart';
import '../../utils/date_utils.dart';
import 'profile_edit_dialogs/index.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/components/base_card.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class UserInfoCard extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback? onProfileUpdated;
  
  const UserInfoCard(
    {
    super.key,
    required this.userProfile,
    this.onProfileUpdated,
  )});

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
          userId: userId),
        updates: updates)
      }
      
      // Notify parent widget to reload
      widget.onProfileUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 업데이트되었습니다'),
            backgroundColor: AppColors.success)))
      }
    } catch (e) {
      Logger.error('Failed to update profile field', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
            content: Text('업데이트 실패: ${e.toString(,
  )}'),
            backgroundColor: AppColors.error)))
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (userProfile == null) return const SizedBox.shrink();
    
    return BaseCard(
      padding: AppSpacing.paddingAll20,
      borderRadius: AppDimensions.borderRadiusMedium),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.1),
        width: 1),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                        Text(
                          '기본 정보',
              ),
              style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
              Text(
                '基本情報',
                          style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
            ])
          SizedBox(height: AppSpacing.spacing5),
          
          // 프로필 이미지와 이름
          Row(
            children: [
              _buildProfileImage(context),
              SizedBox(width: AppSpacing.spacing4),
              Expanded(
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Text(
                          userProfile!['name'] ?? '사용자',
              ),
              style: theme.textTheme.headlineSmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
                    SizedBox(height: AppSpacing.spacing1),
                    if (userProfile!['birth_date'] != null) ...[
                      Row(
                        children: [
                          Text(
                            _calculateAge(userProfile!['birth_date']),
                            style: theme.textTheme.bodyLarge)
                          SizedBox(width: AppSpacing.spacing2),
                          Text(
                            '·',
                          style: theme.textTheme.bodyLarge?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.4,
                          )))
                          SizedBox(width: AppSpacing.spacing2),
                          Text(
                            userProfile!['gender'] == 'male' ? '남성' : '여성'
                            style: theme.textTheme.bodyLarge)
                        ])
                    ]
                  ])))
            ])
          
          SizedBox(height: AppSpacing.spacing6),
          
          // 상세 정보 그리드
          _buildInfoGrid(context),
        ])))
  }
  
  Widget _buildProfileImage(BuildContext context) {
    final theme = Theme.of(context);
    final profileImageUrl = userProfile!['profile_image_url'];
    
    return Container(
      width: 80,
      height: AppSpacing.spacing20,
      decoration: BoxDecoration(,
      shape: BoxShape.circle,
        ),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.2),
          width: 2)),
      child: ClipOval(
        child: profileImageUrl != null && profileImageUrl.isNotEmpty
            ? Image.network(
                profileImageUrl,
                width: 80),
              height: 80),
        fit: BoxFit.cover),
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(context))
            : _buildDefaultAvatar(context))))
  }
  
  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alph,
      a: 0.1),
      child: Icon(
                Icons.person,
        size: 40,
              ),
              color: Theme.of(context).colorScheme.primary)))
  }
  
  Widget _buildInfoGrid(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        _buildInfoRow(context, [
          _InfoItem(
            icon: Icons.cake,
            label: '생년월일'),
        value: _formatBirthDate(userProfile!['birth_date']),
            onTap: () => _showBirthDateEditDialog(context))
          _InfoItem(
            icon: Icons.access_time,
            label: '출생시간',
            value: userProfile!['birth_time'] ?? '미입력'),
        onTap: () => _showBirthTimeEditDialog(context))
        ]),
        SizedBox(height: AppSpacing.spacing3),
        _buildInfoRow(context, [
          _InfoItem(
            icon: Icons.pets,
            label: '띠'),
        value: userProfile!['chinese_zodiac'] ?? _calculateZodiacAnimal(userProfile!['birth_date']),
            onTap: () => _showBirthDateEditDialog(context), // 생년월일 수정 시 자동 계산
          ),
          _InfoItem(
            icon: Icons.stars,
            label: '별자리'),
        value: userProfile!['zodiac_sign'] ?? _calculateZodiacSign(userProfile!['birth_date']),
            onTap: () => _showBirthDateEditDialog(context), // 생년월일 수정 시 자동 계산
          ),
        ]),
        SizedBox(height: AppSpacing.spacing3),
        _buildInfoRow(context, [
          _InfoItem(
            icon: Icons.water_drop,
            label: '혈액형',
            value: userProfile!['blood_type'] != null ? '${userProfile!['blood_type']}형' : '미입력'),
        onTap: () => _showBloodTypeEditDialog(context))
          _InfoItem(
            icon: Icons.psychology,
            label: 'MBTI'),
        value: userProfile!['mbti']?.toUpperCase() ?? '미입력',
            onTap: () => _showMbtiEditDialog(context))
        ]),
      ]
    );
  }
  
  void _showBirthDateEditDialog(BuildContext context) {
    final currentDate = userProfile!['birth_date'] != null
        ? DateTime.tryParse(userProfile!['birth_date'])
        : null;
    
    showDialog(
      context: context),
        builder: (context) => BirthDateEditDialog(,
      initialDate: currentDate),
        onSave: (date) async {
          await _updateProfileField('birth_date', date.toIso8601String().split('T')[0]);
        })))
  }
  
  void _showBirthTimeEditDialog(BuildContext context) {
    showDialog(
      context: context),
        builder: (context) => BirthTimeEditDialog(,
      initialTime: userProfile!['birth_time']),
        onSave: (time) async {
          await _updateProfileField('birth_time', time);
        })))
  }
  
  void _showBloodTypeEditDialog(BuildContext context) {
    showDialog(
      context: context),
        builder: (context) => BloodTypeEditDialog(,
      initialBloodType: userProfile!['blood_type']),
        onSave: (bloodType) async {
          await _updateProfileField('blood_type', bloodType);
        })))
  }
  
  void _showMbtiEditDialog(BuildContext context) {
    showDialog(
      context: context),
        builder: (context) => MbtiEditDialog(,
      initialMbti: userProfile!['mbti']),
        onSave: (mbti) async {
          await _updateProfileField('mbti', mbti);
        })))
  }
  
  Widget _buildInfoRow(BuildContext context, List<_InfoItem> items) {
    return Row(
      children: items.map((item) => Expanded(,
      child: _buildInfoItem(context, item, items)))).toList())
  }
  
  Widget _buildInfoItem(BuildContext context, _InfoItem item, List<_InfoItem> items) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(,
      onTap: item.onTap,
        borderRadius: AppDimensions.borderRadiusSmall,
        child: Container(,
      padding: AppSpacing.paddingAll12),
        margin: EdgeInsets.only(,
      right: items.indexOf(item) == 0 ? 6 : 0,
      left: items.indexOf(item) == 1 ? 6 : 0),
      decoration: BoxDecoration(,
      color: AppColors.textPrimaryDark,
            borderRadius: AppDimensions.borderRadiusSmall),
      child: Row(
            children: [
              Icon(
                item.icon,
                size: AppDimensions.iconSizeSmall,
                color: theme.colorScheme.primary)
              SizedBox(width: AppSpacing.spacing2),
              Expanded(
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
        ),
        style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                    SizedBox(height: AppSpacing.xxxSmall),
                    Text(
                      item.value,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ))))
                  ])))
              // Edit icon hidden but functionality remains
              // if (item.onTap != null,
              //   Icon(
              //     Icons.edit_outlined,
              //     size: AppDimensions.iconSizeXSmall)
              //     color: theme.colorScheme.onSurface.withValues(alph,
      a: 0.4),
              //   ),
            ])))))))
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
      
      // 한국 나이 계산
      final koreanAge = now.year - birth.year + 1;
      
      return '만 $age세 ($koreanAge세)';
    } catch (e) {
      return '나이 미상';
    }
  }
  
  String _formatBirthDate(String? birthDate) {
    if (birthDate == null) return '미입력';
    
    try {
      final date = DateTime.parse(birthDate);
      return DateFormat('yyyy년 M월 d일').format(date);
    } catch (e) {
      return birthDate;
    }
  }
  
  String _calculateZodiacAnimal(String? birthDate) {
    if (birthDate == null) return '미입력';
    
    try {
      final date = DateTime.parse(birthDate);
      const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
      return '${animals[date.year % 12]}띠';
    } catch (e) {
      return '미입력';
    }
  }
  
  String _calculateZodiacSign(String? birthDate) {
    if (birthDate == null) return '미입력';
    
    try {
      final date = DateTime.parse(birthDate);
      final month = date.month;
      final day = date.day;
      
      if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
      if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
      if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '쌍둥이자리';
      if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '게자리';
      if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
      if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
      if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '천칭자리';
      if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '전갈자리';
      if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '사수자리';
      if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
      if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
      return '물고기자리';
    } catch (e) {
      return '미입력';
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  
  const _InfoItem(
    {
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  )});
}