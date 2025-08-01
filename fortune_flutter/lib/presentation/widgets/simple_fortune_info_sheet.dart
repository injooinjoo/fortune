import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/fortune_emotional_descriptions.dart';
import '../providers/providers.dart';
import '../screens/ad_loading_screen.dart';
import '../../core/constants/fortune_type_names.dart';
import '../../core/utils/supabase_helper.dart';
import '../../core/utils/logger.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class SimpleFortunInfoSheet extends ConsumerStatefulWidget {
  final String fortuneType;
  final String? title;
  final String? description;
  final VoidCallback? onFortuneButtonPressed;
  final VoidCallback? onDismiss;
  
  const SimpleFortunInfoSheet(
    {
    super.key,
    required this.fortuneType,
    this.title,
    this.description,
    this.onFortuneButtonPressed,
    this.onDismiss,
  )});

  static Future<void> show(
    BuildContext context, {
    required String fortuneType,
    String? title,
    String? description,
    VoidCallback? onFortuneButtonPressed,
    VoidCallback? onDismiss,
  )}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true),
        barrierColor: Colors.transparent, // Remove background dimming
      useRootNavigator: true, // This ensures the modal appears above navigation bar
      builder: (context) => SimpleFortunInfoSheet(,
      fortuneType: fortuneType,
        title: title,
        description: description,
        onFortuneButtonPressed: onFortuneButtonPressed,
        onDismiss: onDismiss)
      ))).then((_) {
      // Call onDismiss when the bottom sheet is closed
      onDismiss?.call();
    });
  }

  @override
  ConsumerState<SimpleFortunInfoSheet> createState() => _SimpleFortunInfoSheetState();
}

class _SimpleFortunInfoSheetState extends ConsumerState<SimpleFortunInfoSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Input values
  String? _selectedMbti;
  String? _selectedBloodType;
  String? _inputText;
  
  // Editing state
  final Map<String, bool> _isEditing = {};
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  String? _selectedBirthTime;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this),
        duration: AppAnimations.durationMedium
    );
    _animationController.forward();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile != null) {
      _selectedMbti = profile.mbtiType;
      _selectedBloodType = profile.preferences?['blood_type'] as String?;
      _selectedGender = profile.gender;
      _selectedBirthDate = profile.birthDate;
      
      // Birth time is now stored directly in the profile
      _selectedBirthTime = profile.birthTime;
      
      // Initialize controllers with existing values
      if (profile.name != null) {
        _controllers['name'] = TextEditingController(text: profile.name);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final fortuneInfo = FortuneEmotionalDescriptions.getDescription(widget.fortuneType);
    final emotionalDescription = (fortuneInfo['emotionalDescription'] ?? '') as String;
    final requiresInput = (fortuneInfo['requiresInput'] ?? false) as bool;
    
    return AnimatedBuilder(
      animation: _animationController),
        builder: (context, child) {
        return SizedBox(
          height: screenHeight * 0.5, // 50% of screen height
          child: Stack(,
      children: [
              Container(
                decoration: BoxDecoration(,
      color: theme.brightness == Brightness.dark 
                      ? AppColors.textPrimary 
                      : AppColors.textPrimaryDark,
        ),
        borderRadius: const BorderRadius.only(,
      topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
      boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alph,
      a: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5))
                  ])
                child: Column(,
      children: [
                    _buildHandle(),
                    Expanded(
                      child: SingleChildScrollView(,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                        child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                            // Title if provided
                            if (widget.title != null) ...[
                              Text(
                                widget.title!),
        style: theme.textTheme.headlineSmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))).animate().fadeIn(duration: 300.ms),
                              SizedBox(height: AppSpacing.spacing4),
                            ]
                            // Description (use provided description or fallback to emotional description,
                            Text(
                              widget.description ?? emotionalDescription),
        style: theme.textTheme.bodyLarge?.copyWith(,
      height: 1.8,
                          ),
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.8))))).animate().fadeIn(duratio,
      n: 400.ms, delay: 100.ms),
                            
                            if (requiresInput) ...[
                              SizedBox(height: AppSpacing.spacing8),
                              _buildInputSection(theme, fortuneInfo),
                            ]
                            SizedBox(height: AppSpacing.spacing8),
                            
                            // Divider
                            Container(
                              height: 1),
              color: theme.colorScheme.onSurface.withValues(alph,
      a: 0.1))
                            SizedBox(height: AppSpacing.spacing6),
                            
                            // User information section (moved to bottom,
                            _buildUserInfoSection(theme),
                          ])))))
                  ])))
              _buildBottomButton(context),
            ])))
      }
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(to,
      p: AppSpacing.small, bottom: AppSpacing.xSmall),
      width: 40,
      height: 4,
      decoration: BoxDecoration(,
      color: AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
      )
  }

  Widget _buildUserInfoSection(ThemeData theme) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        Text(
                          '운세를 보기 위한 정보',
                          style: theme.textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold),
        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          )))).animate().fadeIn(duration: 300.ms),
        SizedBox(height: AppSpacing.spacing4),
        
        // User info cards
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(,
      color: theme.colorScheme.surface,
            borderRadius: AppDimensions.borderRadiusLarge,
        ),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.2))),
      child: Column(
            children: [
              _buildInfoRow(
                theme,
                icon: Icons.person_rounded,
                label: '이름',
                value: _controllers['name']?.text.isNotEmpty == true 
                    ? _controllers['name']!.text 
                    : profile?.name
                isRequired: true,
                fieldKey: 'name',
                fieldType: 'text')
              SizedBox(height: AppSpacing.spacing3),
              _buildInfoRow(
                theme,
                icon: Icons.cake_rounded,
                label: '생년월일',
                value: _selectedBirthDate != null 
                  ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                  : profile?.birthDate != null 
                    ? '${profile!.birthDate!.year}년 ${profile.birthDate!.month}월 ${profile.birthDate!.day}일'
                    : null
                isRequired: true,
                fieldKey: 'birthDate',
                fieldType: 'date')
              SizedBox(height: AppSpacing.spacing3),
              _buildInfoRow(
                theme,
                icon: Icons.wc_rounded,
                label: '성별',
                value: _selectedGender == 'male' ? '남성' : 
                       _selectedGender == 'female' ? '여성' : 
                       profile?.gender == 'male' ? '남성' : 
                       profile?.gender == 'female' ? '여성' : null
                isRequired: true,
                fieldKey: 'gender',
                fieldType: 'gender')
              
              // Fortune-specific fields
              if (widget.fortuneType == 'saju' || widget.fortuneType == 'traditional') ...[
                SizedBox(height: AppSpacing.spacing3),
                _buildInfoRow(
                  theme,
                  icon: Icons.access_time_rounded,
                  label: '태어난 시간',
                  value: _selectedBirthTime ?? profile?.birthTime,
                  isRequired: _selectedBirthTime == null && profile?.birthTime == null,
      fieldKey: 'birthTime',
                  fieldType: 'time')
              ]
              if (widget.fortuneType == 'mbti') ...[
                SizedBox(height: AppSpacing.spacing3),
                _buildInfoRow(
                  theme,
                  icon: Icons.psychology_rounded,
                  label: 'MBTI',
                  value: _selectedMbti ?? profile?.mbtiType,
                  isRequired: _selectedMbti == null && profile?.mbtiType == null,
      fieldKey: 'mbti',
                  fieldType: 'text')
              ]
              if (widget.fortuneType == 'blood-type') ...[
                SizedBox(height: AppSpacing.spacing3),
                _buildInfoRow(
                  theme,
                  icon: Icons.water_drop_rounded,
                  label: '혈액형',
                  value: _selectedBloodType ?? profile?.preferences?['blood_type'] as String?,
                  isRequired: _selectedBloodType == null && profile?.preferences?['blood_type'] == null,
      fieldKey: 'bloodType',
                  fieldType: 'text')
              ]
            ])))).animate().fadeIn(duration: 300.ms, delay: 100.ms),
      ]
    );
  }
  
  Widget _buildInfoRow(ThemeData theme, {
    required IconData icon,
    required String label,
    String? value,
    bool isRequired = false,
    required String fieldKey)
    String fieldType = 'text', // text, date, gender, time
  }) {
    final hasValue = value != null && value.isNotEmpty;
    final isEditing = _isEditing[fieldKey] ?? false;
    
    if (!hasValue && !isEditing) {
      // Show edit button if no value
      return InkWell(
        onTap: () => setState(() => _isEditing[fieldKey] = true),
        borderRadius: AppDimensions.borderRadiusMedium,
        child: Padding(,
      padding: EdgeInsets.symmetric(vertic,
      al: AppSpacing.spacing1),
          child: Row(,
      children: [
              Icon(
                icon,
                size: AppDimensions.iconSizeSmall),
        color: theme.colorScheme.onSurface.withValues(alph,
      a: 0.4))
              SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Text(
                          label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                    Text(
                      isRequired ? '입력 필요' : '선택 사항',
                          style: theme.textTheme.bodyMedium?.copyWith(,
      color: isRequired ? theme.colorScheme.error : theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6, fontWeight: isRequired ? FontWeight.w500 : FontWeight.normal,
                          )))
                  ])))
              Icon(
                Icons.edit_rounded,
                size: AppDimensions.iconSizeSmall,
                color: theme.colorScheme.primary)
            ])
        )
    }
    
    if (isEditing) {
      // Show editing widget based on field type
      return _buildEditingWidget(theme, fieldKey: fieldKey, fieldType: fieldType, label: label, icon: icon);
    }
    
    // Show value with check mark and make it clickable
    return InkWell(
      onTap: () => setState(() => _isEditing[fieldKey] = true),
      borderRadius: AppDimensions.borderRadiusMedium,
      child: Padding(,
      padding: EdgeInsets.symmetric(vertic,
      al: AppSpacing.spacing1),
        child: Row(,
      children: [
            Icon(
              icon,
              size: AppDimensions.iconSizeSmall,
              color: theme.colorScheme.primary)
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text(
                          label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                  Text(
                    value!,
                          style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface,
                          ))))
                ])))
            Icon(
              Icons.edit_rounded,
              size: AppDimensions.iconSizeSmall),
        color: theme.colorScheme.primary.withValues(alph,
      a: 0.6))
          ])
      )
  }

  Widget _buildEditingWidget(
    ThemeData theme, {
    required String fieldKey,
    required String fieldType,
    required String label,
    required IconData icon,
  )}) {
    switch (fieldType) {
      case 'text':
        _controllers[fieldKey] ??= TextEditingController();
        return Row(
          children: [
            Icon(icon, size: AppDimensions.iconSizeSmall, color: theme.colorScheme.primary),
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                  SizedBox(height: AppSpacing.spacing1),
                  TextField(
                    controller: _controllers[fieldKey],
      style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(,
      isDense: true),
        contentPadding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing2),
                      hintText: '$label 입력',
                      border: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusSmall)
                      ))
                    onSubmitted: (_) => setState(() => _isEditing[fieldKey] = false))
                ])))
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => setState(() => _isEditing[fieldKey] = false),
              color: theme.colorScheme.primary)
          ])
        
      case 'date':
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context),
        initialDate: _selectedBirthDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now()
            if (picked != null) {
              setState(() {
                _selectedBirthDate = picked;
                _isEditing[fieldKey] = false;
              });
            }
          }
          child: Row(,
      children: [
              Icon(icon, size: AppDimensions.iconSizeSmall, color: theme.colorScheme.primary),
              SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                    Container(
                      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing2),
                      decoration: BoxDecoration(,
      border: Border.all(col,
      or: theme.colorScheme.outline),
                        borderRadius: AppDimensions.borderRadiusSmall),
      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: AppDimensions.iconSizeXSmall, color: theme.colorScheme.primary),
                          SizedBox(width: AppSpacing.spacing2),
                          Text(
                            '날짜 선택',
        ),
        style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.primary,
                          ))))
                        ])))
                  ])))
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _isEditing[fieldKey] = false),
                color: theme.colorScheme.error)
            ]
          )
        
      case 'gender':
        return Row(
          children: [
            Icon(icon, size: AppDimensions.iconSizeSmall, color: theme.colorScheme.primary),
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                  SizedBox(height: AppSpacing.spacing1),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(,
      isDense: true),
        contentPadding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing2),
                      border: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusSmall)
                      ))
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('남성')
                      DropdownMenuItem(value: 'female', child: Text('여성')
                    ]
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _isEditing[fieldKey] = false;
                      });
                    })
                ])))
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _isEditing[fieldKey] = false),
              color: theme.colorScheme.error)
          ]
        );
        
      case 'time':
        return Row(
          children: [
            Icon(icon, size: AppDimensions.iconSizeSmall, color: theme.colorScheme.primary),
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                  SizedBox(height: AppSpacing.spacing1),
                  DropdownButtonFormField<String>(
                    value: _selectedBirthTime,
                    decoration: InputDecoration(,
      isDense: true),
        contentPadding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing2),
                      border: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusSmall)
                      ))
                    items: const [
                      DropdownMenuItem(value: '자시 (23:00-01:00)', child: Text('자시 (23:00-01:00)')
                      DropdownMenuItem(value: '축시 (01:00-03:00)', child: Text('축시 (01:00-03:00)')
                      DropdownMenuItem(value: '인시 (03:00-05:00)', child: Text('인시 (03:00-05:00)')
                      DropdownMenuItem(value: '묘시 (05:00-07:00)', child: Text('묘시 (05:00-07:00)')
                      DropdownMenuItem(value: '진시 (07:00-09:00)', child: Text('진시 (07:00-09:00)')
                      DropdownMenuItem(value: '사시 (09:00-11:00)', child: Text('사시 (09:00-11:00)')
                      DropdownMenuItem(value: '오시 (11:00-13:00)', child: Text('오시 (11:00-13:00)')
                      DropdownMenuItem(value: '미시 (13:00-15:00)', child: Text('미시 (13:00-15:00)')
                      DropdownMenuItem(value: '신시 (15:00-17:00)', child: Text('신시 (15:00-17:00)')
                      DropdownMenuItem(value: '유시 (17:00-19:00)', child: Text('유시 (17:00-19:00)')
                      DropdownMenuItem(value: '술시 (19:00-21:00)', child: Text('술시 (19:00-21:00)')
                      DropdownMenuItem(value: '해시 (21:00-23:00)', child: Text('해시 (21:00-23:00)')
                    ]
                    onChanged: (value) {
                      setState(() {
                        _selectedBirthTime = value;
                        _isEditing[fieldKey] = false;
                      });
                    })
                ])))
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _isEditing[fieldKey] = false),
              color: theme.colorScheme.error)
          ]
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
  
  Future<bool> _validateAndSaveProfile() async {
    try {
      final profile = ref.read(userProfileProvider).value;
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user == null) {
        Logger.error('[SimpleFortunInfoSheet] No authenticated user');
        return false;
      }
      
      // Collect all the data
      final name = _controllers['name']?.text.isNotEmpty == true 
          ? _controllers['name']!.text 
          : profile?.name;
      final birthDate = _selectedBirthDate ?? profile?.birthDate;
      final gender = _selectedGender ?? profile?.gender;
      
      // Validate required fields
      if (name == null || name.isEmpty) {
        _showErrorSnackBar('이름을 입력해주세요');
        return false;
      }
      
      if (birthDate == null) {
        _showErrorSnackBar('생년월일을 입력해주세요');
        return false;
      }
      
      if (gender == null) {
        _showErrorSnackBar('성별을 선택해주세요');
        return false;
      }
      
      // Validate fortune-specific fields
      if ((widget.fortuneType == 'saju' || widget.fortuneType == 'traditional') && 
          _selectedBirthTime == null && profile?.birthTime == null) {
        _showErrorSnackBar('태어난 시간을 선택해주세요');
        return false;
      }
      
      if (widget.fortuneType == 'mbti' && 
          _selectedMbti == null && profile?.mbtiType == null) {
        _showErrorSnackBar('MBTI를 입력해주세요');
        return false;
      }
      
      if (widget.fortuneType == 'blood-type' && 
          _selectedBloodType == null && profile?.preferences?['blood_type'] == null) {
        _showErrorSnackBar('혈액형을 선택해주세요');
        return false;
      }
      
      // Prepare update data
      final updateData = <String, dynamic>{
        'id': user.id
        'email': user.email,
        'name': name,
        'birth_date': birthDate.toIso8601String().split('T')[0]
        'gender': gender,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add optional fields
      if (_selectedMbti != null) {
        updateData['mbti_type'] = _selectedMbti;
      }
      
      // Add birth time as direct field
      if (_selectedBirthTime != null) {
        updateData['birth_time'] = _selectedBirthTime;
      }
      
      // Handle preferences
      final preferences = Map<String, dynamic>.from(profile?.preferences ?? {});
      
      if (_selectedBloodType != null) {
        preferences['blood_type'] = _selectedBloodType;
      }
      
      if (preferences.isNotEmpty) {
        updateData['preferences'] = preferences;
      }
      
      // Save to Supabase
      await Supabase.instance.client.from('user_profiles').upsert(updateData);
      
      Logger.info('[SimpleFortunInfoSheet] Profile updated successfully');
      
      // Refresh the profile provider
      ref.invalidate(userProfileProvider);
      
      return true;
    } catch (e) {
      Logger.error('[SimpleFortunInfoSheet] Failed to save profile', e);
      _showErrorSnackBar('프로필 저장에 실패했습니다');
      return false;
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      )
  }

  Widget _buildInputSection(ThemeData theme, Map<String, dynamic> fortuneInfo) {
    final inputType = fortuneInfo['inputType'] ?? 'text';
    final inputLabel = fortuneInfo['inputLabel'] ?? '';
    final inputHint = fortuneInfo['inputHint'] ?? '';
    final dropdownOptions = fortuneInfo['dropdownOptions'] as List<String>?;
    
    if (inputType == 'dropdown' && dropdownOptions != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        Text(
                          inputLabel,
                          style: theme.textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold),
        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          )))
          SizedBox(height: AppSpacing.spacing3),
          Container(
            padding: AppSpacing.paddingHorizontal16,
            decoration: BoxDecoration(,
      color: theme.colorScheme.surface,
              borderRadius: AppDimensions.borderRadiusLarge,
        ),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.2))),
      child: DropdownButtonHideUnderline(,
      child: DropdownButton<String>(,
      value: widget.fortuneType == 'mbti' ? _selectedMbti : _selectedBloodType),
        hint: Text(inputHint),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_rounded),
                items: dropdownOptions.map((option) => DropdownMenuItem(,
      value: option),
        child: Text(option)))).toList(),
                onChanged: (value) {
                  setState(() {
                    if (widget.fortuneType == 'mbti') {
                      _selectedMbti = value;
                    } else if (widget.fortuneType == 'blood-type') {
                      _selectedBloodType = value;
                    }
                  });
                })))))
        ])).animate().fadeIn(duration: 300.ms, delay: 200.ms);
    } else if (inputType == 'text') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                        Text(
                          inputLabel,
                          style: theme.textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold),
        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          )))
          SizedBox(height: AppSpacing.spacing3),
          TextField(
            onChanged: (value) {
              setState(() {
                _inputText = value;
              });
            }
            decoration: InputDecoration(,
      hintText: inputHint,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusLarge),
        borderSide: BorderSide(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.2))),
      enabledBorder: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusLarge),
        borderSide: BorderSide(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.2))),
      focusedBorder: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusLarge,
                borderSide: BorderSide(,
      color: theme.colorScheme.primary,
                  width: 2)
                ))))))
        ])).animate().fadeIn(duration: 300.ms, delay: 200.ms);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 100 + bottomPadding, // Add explicit height
      child: Container(,
      decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? AppColors.textPrimary 
              : AppColors.textPrimaryDark,
        ),
        boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alph,
      a: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2))
          ])
        padding: EdgeInsets.only(to,
      p: AppSpacing.medium, left: AppSpacing.xLarge, right: AppSpacing.xLarge),
        child: ElevatedButton(,
      onPressed: () async {
            // First validate and save profile if needed
            final isValid = await _validateAndSaveProfile();
            
            if (!isValid) {
              // Don't proceed if validation failed
              return;
            }
            
            // Close the bottom sheet first
            if (mounted) {
              Navigator.of(context).pop();
            }
            
            // Call onDismiss to ensure overlay is removed
            widget.onDismiss?.call();
            
            if (widget.onFortuneButtonPressed != null) {
              widget.onFortuneButtonPressed!();
            } else {
              // Default behavior - navigate to AdLoadingScreen
              final isPremium = ref.read(hasUnlimitedAccessProvider);
              
              await Navigator.push(
                context)
                MaterialPageRoute(
                  builder: (context) => AdLoadingScreen(,
      fortuneType: widget.fortuneType),
        fortuneTitle: FortuneTypeNames.getName(widget.fortuneType),
                    isPremium: isPremium,
                    fortuneParams: {
                      if (_selectedMbti != null) 'mbti': _selectedMbti,
                      if (_selectedBloodType != null) 'bloodType': _selectedBloodType,
                      if (_inputText != null) 'input': _inputText,
                    }
                    onComplete: () {
                      // Fortune generation completed
                    }
                    onSkip: () {
                      // User skipped ad
                    })
                )
            }
          }
          style: ElevatedButton.styleFrom(,
      backgroundColor: theme.colorScheme.primary),
        foregroundColor: AppColors.textPrimaryDark),
        minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(,
      borderRadius: AppDimensions.borderRadiusLarge),
      elevation: 4),
      child: Row(,
      mainAxisAlignment: MainAxisAlignment.center),
        children: [
              const Icon(Icons.auto_awesome, size: AppDimensions.iconSizeMedium),
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '운세보기'),
        style: theme.textTheme.titleMedium?.copyWith(,
      color: AppColors.textPrimaryDark,
                          ),
        fontWeight: FontWeight.bold)
                ))
            ])))).animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.2, end: 0, duration: 300.ms),
      )
  }
}