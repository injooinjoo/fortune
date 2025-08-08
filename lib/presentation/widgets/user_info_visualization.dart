import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class UserInfoVisualization extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final String fortuneType;
  final List<Color>? gradientColors;
  
  const UserInfoVisualization({
    super.key,
    required this.userInfo,
    required this.fortuneType,
    this.gradientColors});
  
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: AppSpacing.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: AppSpacing.spacing5),
          _buildInfoGrid(context)])).animate()
      .fadeIn(duration: const Duration(milliseconds: 500))
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingAll8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors ?? [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7)]),
            borderRadius: AppDimensions.borderRadiusMedium),
          child: Icon(
            _getIconForFortuneType(),
            color: AppColors.textPrimaryDark,
            size: AppDimensions.iconSizeMedium)),
        SizedBox(width: AppSpacing.spacing3),
        Text(
          '입력된 정보',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold))]);
  }
  
  Widget _buildInfoGrid(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> infoItems = [];
    
    // Name
    if (userInfo['name'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.person,
        label: '이름',
        value: userInfo['name']));
    }
    
    // Birth date and derived info
    if (userInfo['birthDate'] != null) {
      final birthDate = DateTime.parse(userInfo['birthDate']);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.cake,
        label: '생년월일',
        value: _formatDate(birthDate)));
      
      // Age
      final age = _calculateAge(birthDate);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.calendar_today,
        label: '나이',
        value: '$age세'));
      
      // Zodiac animal
      final zodiacAnimal = _getZodiacAnimal(birthDate.year);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.pets,
        label: '띠',
        value: zodiacAnimal));
      
      // Zodiac sign
      final zodiacSign = _getZodiacSign(birthDate);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.stars,
        label: '별자리',
        value: zodiacSign));
    }
    
    // Blood type
    if (userInfo['bloodType'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.water_drop,
        label: '혈액형',
        value: '${userInfo['bloodType']}형'));
    }
    
    // MBTI
    if (userInfo['mbti'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.psychology,
        label: 'MBTI',
        value: userInfo['mbti']));
    }
    
    // Birth time
    if (userInfo['birthTime'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.access_time,
        label: '출생시간',
        value: userInfo['birthTime']));
    }
    
    // Gender
    if (userInfo['gender'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: userInfo['gender'] == 'male' ? Icons.male : Icons.female,
        label: '성별',
        value: userInfo['gender'] == 'male' ? '남성' : '여성'));
    }
    
    // For compatibility - show both people
    if (userInfo['person1'] != null && userInfo['person2'] != null) {
      return Column(
        children: [
          _buildPersonSection(context, '첫 번째 사람', userInfo['person1'], theme.colorScheme.primary),
          SizedBox(height: AppSpacing.spacing4),
          _buildConnectionIndicator(context),
          SizedBox(height: AppSpacing.spacing4),
          _buildPersonSection(context, '두 번째 사람', userInfo['person2'], theme.colorScheme.secondary)]);
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: infoItems);
  }
  
  Widget _buildPersonSection(BuildContext context, String title, Map<String, dynamic> person, Color accentColor) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold)),
          SizedBox(height: AppSpacing.spacing3),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (person['name'] != null)
                _buildInfoItem(
                  context,
                  icon: Icons.person,
                  label: '이름',
                  value: person['name'],
                  color: accentColor),
              if (person['birthDate'] != null) ...[
                _buildInfoItem(
                  context,
                  icon: Icons.cake,
                  label: '생일',
                  value: _formatDate(DateTime.parse(person['birthDate'])),
                  color: accentColor),
                _buildInfoItem(
                  context,
                  icon: Icons.pets,
                  label: '띠',
                  value: _getZodiacAnimal(DateTime.parse(person['birthDate']).year),
                  color: accentColor)]])]));
  }
  
  Widget _buildConnectionIndicator(BuildContext context) {
    return Center(
      child: Container(
        padding: AppSpacing.paddingAll12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.pink.withOpacity(0.5), AppColors.primary.withOpacity(0.5)])),
        child: const Icon(
          Icons.favorite,
          color: AppColors.textPrimaryDark,
          size: AppDimensions.iconSizeMedium))).animate(onPlay: (controller) => controller.repeat())
      .scale(
        begin: const Offset(1, 1),
        end: const Offset(1.2, 1.2),
        duration: const Duration(seconds: 1))
      .then()
      .scale(
        begin: const Offset(1.2, 1.2),
        end: const Offset(1, 1),
        duration: const Duration(seconds: 1));
  }
  
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color}) {
    final theme = Theme.of(context);
    final itemColor = color ?? theme.colorScheme.primary;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing3,
        vertical: AppSpacing.spacing2),
      decoration: BoxDecoration(
        color: itemColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: itemColor.withOpacity(0.3),
          width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSizeXSmall, color: itemColor),
          SizedBox(width: AppSpacing.xSmall),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6))),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: itemColor))])).animate()
      .fadeIn(delay: const Duration(milliseconds: 100))
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
  
  IconData _getIconForFortuneType() {
    switch (fortuneType) {
      case 'daily':
      case 'today':
      case 'tomorrow':
        return Icons.today;
      case 'love':
      case 'compatibility':
        return Icons.favorite;
      case 'career':
        return Icons.work;
      case 'wealth':
        return Icons.attach_money;
      case 'health':
        return Icons.health_and_safety;
      case 'saju':
        return Icons.auto_awesome;
      case 'mbti':
        return Icons.psychology;
      case 'zodiac':
        return Icons.stars;
      default:
        return Icons.auto_awesome;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
  
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  String _getZodiacAnimal(int year) {
    const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return '${animals[year % 12]}띠';
  }
  
  String _getZodiacSign(DateTime date) {
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
  }
}