import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;

class TimelineFortunePage extends ConsumerWidget {
  const TimelineFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '타임라인 운세',
      fortuneType: 'timeline',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      inputBuilder: (context, onSubmit) => _TimelineInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _TimelineFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _TimelineInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _TimelineInputForm({required this.onSubmit});

  @override
  State<_TimelineInputForm> createState() => _TimelineInputFormState();
}

class _TimelineInputFormState extends State<_TimelineInputForm> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _timelinePeriod;
  final List<String> _selectedFocusAreas = [];
  String? _currentLifeStage;
  
  final List<String> _periods = [
    '3개월',
    '6개월',
    '1년',
    '3년',
    '5년',
    '10년',
    '평생',
  ];
  
  final List<String> _focusAreas = [
    '연애/결혼',
    '직업/커리어',
    '건강',
    '재물',
    '학업',
    '가족',
    '인간관계',
    '자기계발',
    '사업',
    '이사/이주',
    '여행',
    '창작활동',
  ];
  
  final List<String> _lifeStages = [
    '학생',
    '취업준비생',
    '사회초년생',
    '중견직장인',
    '관리자',
    '사업가',
    '프리랜서',
    '은퇴준비',
    '은퇴자',
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
              primary: const Color(0xFF6366F1),
            ),
          ),
          child: child!,
        );
      },
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '미래의 중요한 순간들을 예측하고\n인생의 전환점을 미리 준비하세요.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
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
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Gender Selection
          Text(
            '성별',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('남성'),
                  value: '남성',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('여성'),
                  value: '여성',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary.withOpacity(0.7)),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _birthDate != null 
                          ? theme.colorScheme.onSurface 
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Timeline Period Selection
          Text(
            '예측 기간',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periods.map((period) {
              final isSelected = _timelinePeriod == period;
              return ChoiceChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _timelinePeriod = selected ? period : null;
                  });
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Focus Areas Selection
          Text(
            '관심 분야 (최대 3개)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _focusAreas.map((area) {
              final isSelected = _selectedFocusAreas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedFocusAreas.length < 3) {
                      _selectedFocusAreas.add(area);
                    } else if (!selected) {
                      _selectedFocusAreas.remove(area);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('최대 3개까지 선택 가능합니다')),
                      );
                    }
                  });
                },
                selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Current Life Stage
          Text(
            '현재 인생 단계',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currentLifeStage,
            decoration: InputDecoration(
              hintText: '선택하세요',
              prefixIcon: const Icon(Icons.stairs),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
            ),
            items: _lifeStages.map((stage) => DropdownMenuItem(
              value: stage,
              child: Text(stage),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _currentLifeStage = value;
              });
            },
          ),
          const SizedBox(height: 32),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이름을 입력해주세요')),
                  );
                  return;
                }
                if (_gender == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('성별을 선택해주세요')),
                  );
                  return;
                }
                if (_birthDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('생년월일을 선택해주세요')),
                  );
                  return;
                }
                if (_timelinePeriod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('예측 기간을 선택해주세요')),
                  );
                  return;
                }
                
                widget.onSubmit({
                  'name': _nameController.text,
                  'gender': _gender,
                  'birthDate': _birthDate!.toIso8601String(),
                  'period': _timelinePeriod,
                  'focusAreas': _selectedFocusAreas.isEmpty ? ['연애/결혼'] : _selectedFocusAreas,
                  'lifeStage': _currentLifeStage ?? '사회초년생',
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                '타임라인 보기',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineFortuneResult extends ConsumerWidget {
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

  const _TimelineFortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSizeEnum = ref.watch(fontSizeProvider);
    final fontSize = _getFontSizeOffset(fontSizeEnum);
    
    // Extract timeline data from result
    final timelineScore = result.overallScore ?? 82;
    final timelineEvents = result.additionalInfo?['timelineEvents'] ?? [];
    final majorTurningPoints = result.additionalInfo?['majorTurningPoints'] ?? [];
    final fortunePeaks = result.additionalInfo?['fortunePeaks'] ?? [];
    final cautionPeriods = result.additionalInfo?['cautionPeriods'] ?? [];
    final longTermOutlook = result.additionalInfo?['longTermOutlook'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Timeline Score Card
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
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '타임라인 정확도',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$timelineScore%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: _getScoreColor(timelineScore),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24 + fontSize,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.insights,
                                color: _getScoreColor(timelineScore),
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (result.summary != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    result.summary!,
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
        
        // Timeline Events
        if (timelineEvents.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_note,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '주요 이벤트 타임라인',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...timelineEvents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final event = entry.value;
                    final isLast = index == timelineEvents.length - 1;
                    
                    return _TimelineItem(
                      date: event['date'] ?? '',
                      title: event['title'] ?? '',
                      description: event['description'] ?? '',
                      type: event['type'] ?? 'normal',
                      isLast: isLast,
                      fontSize: fontSize,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Major Turning Points
        if (majorTurningPoints.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.change_circle,
                        color: Colors.purple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '인생 전환점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...majorTurningPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.1),
                            Colors.purple.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color: Colors.purple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                point['period'] ?? '',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            point['description'] ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13 + fontSize,
                            ),
                          ),
                          if (point['advice'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '💡 ${point['advice']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 11 + fontSize,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Fortune Peaks
        if (fortunePeaks.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '행운 절정기',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortunePeaks.map((peak) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  peak['period'] ?? '',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14 + fontSize,
                                  ),
                                ),
                                Text(
                                  peak['area'] ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green[700],
                                    fontSize: 11 + fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Caution Periods
        if (cautionPeriods.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '주의 기간',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...cautionPeriods.map((period) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                period['period'] ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13 + fontSize,
                                ),
                              ),
                              Text(
                                period['warning'] ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 11 + fontSize,
                                ),
                              ),
                            ],
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
        
        // Long Term Outlook
        if (longTermOutlook.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.landscape,
                        color: Colors.indigo,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '장기 전망',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    longTermOutlook,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 14 + fontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Recommendations
        if (result.recommendations?.isNotEmpty ?? false) ...[
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
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '타임라인 활용 조언',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(result.recommendations ?? []).map((tip) => Padding(
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
                            tip,
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
        
        // Share Button
        Center(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: const Text('타임라인 공유하기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

// Custom Timeline Item Widget
class _TimelineItem extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final String type;
  final bool isLast;
  final double fontSize;
  
  const _TimelineItem({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    required this.isLast,
    required this.fontSize,
  });
  
  Color _getTypeColor() {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'danger':
        return Colors.red;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getTypeIcon() {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'danger':
        return Icons.error;
      case 'info':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTypeColor();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Icon(
                _getTypeIcon(),
                color: color,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11 + fontSize,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14 + fontSize,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12 + fontSize,
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}