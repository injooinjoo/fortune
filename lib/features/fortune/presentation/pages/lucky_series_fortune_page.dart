import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/shared/components/app_header.dart' show FontSize;
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';

class LuckySeriesFortunePage extends ConsumerWidget {
  const LuckySeriesFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '행운의 시리즈',
      fortuneType: 'lucky-series',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)]),
      inputBuilder: (context, onSubmit) => _LuckySeriesInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _LuckySeriesFortuneResult(
        result: result,
        onShare: onShare));
  }
}

class _LuckySeriesInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _LuckySeriesInputForm({required this.onSubmit});

  @override
  State<_LuckySeriesInputForm> createState() => _LuckySeriesInputFormState();
}

class _LuckySeriesInputFormState extends State<_LuckySeriesInputForm> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGenre;
  String? _selectedPlatform;
  
  final List<String> _genres = [
    '드라마', '예능',
    '영화', '애니메이션',
    '다큐멘터리', 'K-POP',
    '팟캐스트', '웹툰',
    '소설'
  ];
  
  final List<String> _platforms = [
    'Netflix', '웨이브',
    '티빙', '쿠팡플레이',
    '디즈니+', 'YouTube',
    'Spotify', '카카오페이지',
    '네이버웹툰'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF7F7FD5),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 당신에게 행운을 가져다줄\n시리즈를 찾아보세요!',
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
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                      : '생년월일을 선택하세요',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _birthDate != null 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Genre Selection
        Text(
          '좋아하는 장르',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres.map((genre) {
            final isSelected = _selectedGenre == genre;
            return ChoiceChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGenre = selected ? genre : null;
                });
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Platform Selection
        Text(
          '자주 사용하는 플랫폼',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _platforms.map((platform) {
            final isSelected = _selectedPlatform == platform;
            return ChoiceChip(
              label: Text(platform),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPlatform = selected ? platform : null;
                });
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: '행운의 시리즈 확인하기',
            onPressed: () {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이름을 입력해주세요')),
                );
                return;
              }
              if (_birthDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('생년월일을 선택해주세요')),
                );
                return;
              }
              
              widget.onSubmit({
                'name': _nameController.text,
                'birthDate': _birthDate!.toIso8601String(),
                'genre': _selectedGenre ?? '전체',
                'platform': _selectedPlatform ?? '전체',
              });
            },
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ),
      ],
    );
  }
}

class _LuckySeriesFortuneResult extends ConsumerWidget {
  double _getFontSizeOffset(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return -2.0;
      case FontSize.medium:
        return 0.0;
      case FontSize.large:
        return 2.0;
    }
  }
  final FortuneResult result;
  final VoidCallback onShare;

  const _LuckySeriesFortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Extract series recommendations from result
    final mainSeries = result.additionalInfo?['mainSeries'] ?? {};
    final subSeries = result.additionalInfo?['subSeries'] ?? {};
    final avoidSeries = result.additionalInfo?['avoidSeries'] ?? {};
    final reasons = result.recommendations ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Lucky Series Card
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tv,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 행운 시리즈',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mainSeries['title'] ?? '특별한 시리즈',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20 + fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (mainSeries['platform'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mainSeries['platform'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (mainSeries['description'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    mainSeries['description'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 14 + fontSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Sub Series Recommendation
        if (subSeries.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.recommend,
                        color: theme.colorScheme.secondary,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '보조 추천 시리즈',
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  Text(
                    subSeries['title'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
                      fontSize: 16 + fontSize)),
                  if (subSeries['platform'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subSeries['platform'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Why This Series
        if (reasons.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: TossDesignSystem.warningOrange,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '왜 이 시리즈인가요?',
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  ...reasons.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reason,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              fontSize: 14 + fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Series to Avoid
        if (avoidSeries.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: TossDesignSystem.warningOrange,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '오늘은 피하세요',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    avoidSeries['title'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14 + fontSize,
                    ),
                  ),
                  if (avoidSeries['reason'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      avoidSeries['reason'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12 + fontSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20)],
        
        // Share Button
        Center(
          child: TossButton(
            text: '운세 공유하기',
            onPressed: onShare,
            style: TossButtonStyle.ghost,
            size: TossButtonSize.medium,
            icon: Icon(Icons.share),
          ),
        ),
      ],
    );
  }
}