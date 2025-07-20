import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/glassmorphism/glass_container.dart';

class UserInfoVisualization extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final String fortuneType;
  final List<Color>? gradientColors;
  
  const UserInfoVisualization({
    super.key,
    required this.userInfo,
    required this.fortuneType,
    this.gradientColors,
  });
  
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildInfoGrid(context),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors ?? [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForFortuneType(),
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '입력된 정보',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoGrid(BuildContext context) {
    final List<Widget> infoItems = [];
    
    // Name
    if (userInfo['name'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.person,
        label: '이름',
        value: userInfo['name'],
      ));
    }
    
    // Birth date and derived info
    if (userInfo['birthDate'] != null) {
      final birthDate = DateTime.parse(userInfo['birthDate']);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.cake,
        label: '생년월일',
        value: _formatDate(birthDate),
      ));
      
      // Age
      final age = _calculateAge(birthDate);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.calendar_today,
        label: '나이',
        value: '$age세',
      ));
      
      // Zodiac animal
      final zodiacAnimal = _getZodiacAnimal(birthDate.year);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.pets,
        label: '띠',
        value: zodiacAnimal,
      ));
      
      // Zodiac sign
      final zodiacSign = _getZodiacSign(birthDate);
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.stars,
        label: '별자리',
        value: zodiacSign,
      ));
    }
    
    // Blood type
    if (userInfo['bloodType'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.water_drop,
        label: '혈액형',
        value: '${userInfo['bloodType']}형',
      ));
    }
    
    // MBTI
    if (userInfo['mbti'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.psychology,
        label: 'MBTI',
        value: userInfo['mbti'].toUpperCase(),
      ));
    }
    
    // Birth time
    if (userInfo['birthTime'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: Icons.access_time,
        label: '출생시간',
        value: userInfo['birthTime'],
      ));
    }
    
    // Gender
    if (userInfo['gender'] != null) {
      infoItems.add(_buildInfoItem(
        context,
        icon: userInfo['gender'] == 'male' ? Icons.male : Icons.female,
        label: '성별',
        value: userInfo['gender'] == 'male' ? '남성' : '여성',
      ));
    }
    
    // For compatibility - show both people
    if (userInfo['person1'] != null && userInfo['person2'] != null) {
      return Column(
        children: [
          _buildPersonSection(context, '첫 번째 사람', userInfo['person1'], Colors.pink),
          const SizedBox(height: 16),
          _buildConnectionIndicator(context),
          const SizedBox(height: 16),
          _buildPersonSection(context, '두 번째 사람', userInfo['person2'], Colors.blue),
        ],
      );
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: infoItems,
    );
  }
  
  Widget _buildPersonSection(BuildContext context, String title, Map<String, dynamic> person, Color accentColor) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
                  color: accentColor,
                ),
              if (person['birthDate'] != null) ...[
                _buildInfoItem(
                  context,
                  icon: Icons.cake,
                  label: '생일',
                  value: _formatDate(DateTime.parse(person['birthDate'])),
                  color: accentColor,
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.pets,
                  label: '띠',
                  value: _getZodiacAnimal(DateTime.parse(person['birthDate']).year),
                  color: accentColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionIndicator(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.pink.shade300, Colors.blue.shade300],
          ),
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 24,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 1.seconds,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
          duration: 1.seconds,
        ),
    );
  }
  
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final itemColor = color ?? theme.colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: itemColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: itemColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: itemColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: itemColor,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 100.ms)
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