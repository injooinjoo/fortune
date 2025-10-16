import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/components/toast.dart';
// Adjusted const usage for Flutter 3.5
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/custom_calendar_date_picker.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../data/models/celebrity_simple.dart';
import '../../../../presentation/providers/celebrity_provider.dart';
import '../../../../core/theme/toss_design_system.dart';

class SameBirthdayCelebrityFortunePage extends ConsumerWidget {
  const SameBirthdayCelebrityFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '같은 생일 연예인 운세',
      fortuneType: 'same-birthday-celebrity',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF1744), Color(0xFFE91E63)],
      ),
      inputBuilder: (context, onSubmit) => _SameBirthdayInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _SameBirthdayFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _SameBirthdayInputForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _SameBirthdayInputForm({required this.onSubmit});

  @override
  ConsumerState<_SameBirthdayInputForm> createState() => _SameBirthdayInputFormState();
}

class _SameBirthdayInputFormState extends ConsumerState<_SameBirthdayInputForm> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String _lunarSolarType = 'solar';
  List<Celebrity> _sameBirthdayCelebrities = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '생일이 같은 연예인과의 특별한 인연!\n오늘의 운세를 확인해보세요.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Name Input
        Text(
          '이름',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '이름을 입력하세요',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Birth Date Selection
        Text(
          '생년월일',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            DateTime? selectedDate;
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
              builder: (context) => CustomCalendarDatePicker(
                initialDate: _birthDate ?? DateTime(1990, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onDateChanged: (date) {
                  selectedDate = date;
                },
                onConfirm: () {
                  Navigator.pop(context);
                  if (selectedDate != null) {
                    setState(() {
                      _birthDate = selectedDate;
                      // Find celebrities with the same birthday asynchronously
                      ref.read(celebritiesWithBirthdayProvider(selectedDate!).future).then((celebrities) {
                        setState(() {
                          _sameBirthdayCelebrities = celebrities;
                        });
                      });
                    });
                  }
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _birthDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Lunar/Solar Selection
        Text(
          '양력/음력',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('양력'),
                value: 'solar',
                groupValue: _lunarSolarType,
                onChanged: (value) {
                  setState(() {
                    _lunarSolarType = value!;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _lunarSolarType == 'solar' 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('음력'),
                value: 'lunar',
                groupValue: _lunarSolarType,
                onChanged: (value) {
                  setState(() {
                    _lunarSolarType = value!;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _lunarSolarType == 'lunar' 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Show celebrities with same birthday
        if (_sameBirthdayCelebrities.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '같은 생일의 연예인 (${_sameBirthdayCelebrities.length}명)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sameBirthdayCelebrities.take(5).map((celebrity) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Text(
                          celebrity.name.substring(0, 1),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      label: Text(
                        celebrity.name,
                        style: theme.textTheme.bodySmall,
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
                if (_sameBirthdayCelebrities.length > 5) ...[
                  const SizedBox(height: 8),
                  Text(
                    '그 외 ${_sameBirthdayCelebrities.length - 5}명',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty) {
                Toast.error(context, '이름을 입력해주세요');
                return;
              }
              if (_birthDate == null) {
                Toast.error(context, '생년월일을 선택해주세요');
                return;
              }
              
              // Include celebrity information in the submission
              final celebrityData = _sameBirthdayCelebrities.map((celebrity) => {
                'id': celebrity.id,
                'name': celebrity.name,
                'category': celebrity.celebrityType.displayName,
                'age': celebrity.age,
                'zodiac': celebrity.zodiacSign,
                'description': celebrity.notes ?? celebrity.celebrityType.displayName,
              }).toList();
              
              widget.onSubmit({
                'user_name': _nameController.text,
                'birth_date': _birthDate!.toIso8601String(),
                'lunar_solar': _lunarSolarType,
                'same_birthday_celebrities': celebrityData,
                'celebrity_count': _sameBirthdayCelebrities.length,
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '같은 생일 연예인 찾기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _SameBirthdayFortuneResult extends ConsumerWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _SameBirthdayFortuneResult({
    required this.result,
    required this.onShare,
  });

  double _getFontSize(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 14.0;
      case FontSize.medium:
        return 16.0;
      case FontSize.large:
        return 18.0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    // Extract celebrities and fortune data
    final celebrities = result.details?['celebrities'] as List<dynamic>? ?? [];
    final birthdayEnergy = result.details?['birthday_energy'] as Map<String, dynamic>?;
    final predictions = result.details?['predictions'] as Map<String, dynamic>?;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Birthday Energy Card
          if (birthdayEnergy != null) ...[
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake, size: 32, color: TossDesignSystem.pinkPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          birthdayEnergy['date'] ?? '',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    birthdayEnergy['description'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: _getFontSize(fontSize),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Same Birthday Celebrities
          if (celebrities.isNotEmpty) ...[
            Text(
              '같은 생일의 연예인들',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...celebrities.map((celeb) {
              final celebrity = celeb as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                              theme.colorScheme.secondary.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            celebrity['emoji'] ?? '⭐',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              celebrity['name'] ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              celebrity['category'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (celebrity['description'] != null)
                              Text(
                                celebrity['description'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
          
          // Main Fortune Summary
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 운세',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.details?['summary'] ?? result.summary,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: _getFontSize(fontSize),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Lucky Elements
          Row(
            children: [
              Expanded(
                child: _buildLuckyCard(
                  context,
                  '행운의 숫자',
                  result.details?['lucky_number'] ?? '',
                  Icons.looks_one,
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLuckyCard(
                  context,
                  '행운의 색상',
                  result.details?['lucky_color'] ?? '',
                  Icons.palette,
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLuckyCard(
                  context,
                  '행운의 방향',
                  result.details?['lucky_direction'] ?? '',
                  Icons.explore,
                  theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLuckyCard(
                  context,
                  '행운의 시간',
                  result.details?['lucky_time'] ?? '',
                  Icons.access_time,
                  TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Predictions Section
          if (predictions != null) ...[
            Text(
              '분야별 운세',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPredictionCard(
              context,
              '연애운',
              predictions['love'] ?? '',
              Icons.favorite,
              const Color(0xFFFF6B9D),
              _getFontSize(fontSize),
            ),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              '재물운',
              predictions['wealth'] ?? '',
              Icons.payments,
              const Color(0xFFF7B731),
              _getFontSize(fontSize),
            ),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              '건강운',
              predictions['health'] ?? '',
              Icons.favorite_border,
              const Color(0xFF5F27CD),
              _getFontSize(fontSize),
            ),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              '대인관계운',
              predictions['social'] ?? '',
              Icons.people,
              const Color(0xFF4ECDC4),
              _getFontSize(fontSize),
            ),
          ],
          
          // Celebrity Connection Message
          if (result.details?['celebrity_connection'] != null) ...[
            const SizedBox(height: 20),
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TossDesignSystem.purple.withValues(alpha: 0.1),
                  TossDesignSystem.pinkPrimary.withValues(alpha: 0.05),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: TossDesignSystem.warningOrange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '연예인과의 특별한 인연',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.details?['celebrity_connection'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: _getFontSize(fontSize),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color backgroundColor) {
    final theme = Theme.of(context);
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          backgroundColor.withValues(alpha: 0.5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
    double fontSize) {
    final theme = Theme.of(context);
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}