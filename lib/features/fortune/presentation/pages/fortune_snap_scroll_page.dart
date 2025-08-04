import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/fortune_snap_scroll.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../domain/entities/fortune.dart';
import 'base_fortune_page.dart';

/// Fortune page that displays multiple fortune results with snap scrolling
/// Each fortune card snaps to the top of the viewport when scrolling
class FortuneSnapScrollPage extends BaseFortunePage {
  final List<String> fortuneTypes;
  
  const FortuneSnapScrollPage({
    Key? key,
    required String title,
    required String description,
    required this.fortuneTypes,
  }) : super(
    key: key,
    title: title,
    description: description,
    fortuneType: 'multi',
    requiresUserInfo: true
  );

  @override
  ConsumerState<FortuneSnapScrollPage> createState() => _FortuneSnapScrollPageState();
}

class _FortuneSnapScrollPageState extends BaseFortunePageState<FortuneSnapScrollPage> {
  final List<FortuneData> _fortunes = [];
  bool _isLoadingAll = false;

  @override
  void initState() {
    super.initState();
    _loadAllFortunes();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // This page doesn't generate a single fortune, it loads multiple fortunes
    // Return a dummy fortune as this method is required by the base class
    return Fortune(
      id: 'multi',
      type: 'multi',
      userId: '',
      content: '',
      createdAt: DateTime.now(),
    );
  }

  Future<void> _loadAllFortunes() async {
    setState(() {
      _isLoadingAll = true;
    });

    try {
      // Load fortunes for each type
      for (final fortuneType in widget.fortuneTypes) {
        // Generate sample fortune data
        // In real implementation, you would call the actual fortune API
        final fortuneData = FortuneData(
          type: fortuneType,
          title: _getTitleForType(fortuneType),
          score: 75 + (widget.fortuneTypes.indexOf(fortuneType) * 5),
          description: _getDescriptionForType(fortuneType),
          details: {
            'luckyColor': _getLuckyColorForType(fortuneType),
            'luckyNumber': widget.fortuneTypes.indexOf(fortuneType) + 1,
            'advice': null,
          },
        );
        
        _fortunes.add(fortuneData);
      }

      setState(() {
        _isLoadingAll = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAll = false;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    if (_isLoadingAll) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Create snap cards from fortunes
    final snapCards = _fortunes.map((fortune) {
      return FortuneSnapCard(
        imagePath: FortuneCardImages.getImagePath(fortune.type),
        title: fortune.title,
        description: widget.title,
        content: _buildFortuneContent(context, fortune),
        imageHeight: 400,
      );
    }).toList();

    return FortuneSnapScrollView(
      cards: snapCards,
      imageHeight: 400,
      snapDistance: 100,
      velocityThreshold: 150,
    );
  }

  Widget _buildFortuneContent(BuildContext context, FortuneData fortune) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(fortune.score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Section
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scoreColor.withValues(alpha: 0.3),
                      scoreColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: scoreColor,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${fortune.score}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '점',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fortune.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreMessage(fortune.score),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Description
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '상세 운세',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fortune.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lucky Items
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                blur: 15,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: fortune.details['luckyColor'],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette,
                        color: fortune.details['luckyColor'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '행운의 색',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                blur: 15,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${fortune.details['luckyNumber']}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '행운의 숫자',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Advice
        if (fortune.details['advice'] != null)
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            blur: 15,
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fortune.details['advice'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'daily':
        return '오늘의 운세';
      case 'love':
        return '연애운';
      case 'money':
        return '재물운';
      case 'health':
        return '건강운';
      case 'career':
        return '직업운';
      default:
        return type;
    }
  }

  String _getDescriptionForType(String type) {
    switch (type) {
      case 'daily':
        return '오늘 하루 전반적인 운세가 좋습니다. 긍정적인 마음가짐으로 하루를 시작하세요.';
      case 'love':
        return '사랑하는 사람과의 관계가 더욱 깊어지는 시기입니다. 솔직한 대화를 나누어보세요.';
      case 'money':
        return '재물운이 상승하고 있습니다. 투자보다는 저축에 집중하는 것이 좋겠습니다.';
      case 'health':
        return '건강 관리에 신경을 써야 할 때입니다. 충분한 휴식과 운동을 병행하세요.';
      case 'career':
        return '새로운 기회가 찾아올 수 있는 시기입니다. 적극적으로 도전해보세요.';
      default:
        return '운세가 전반적으로 좋은 편입니다.';
    }
  }

  Color _getLuckyColorForType(String type) {
    switch (type) {
      case 'daily':
        return Colors.blue;
      case 'love':
        return Colors.pink;
      case 'money':
        return Colors.green;
      case 'health':
        return Colors.teal;
      case 'career':
        return Colors.indigo;
      default:
        return Colors.purple;
    }
  }

  String _getAdviceForType(String type) {
    switch (type) {
      case 'daily':
        return '오늘은 평소보다 일찍 일어나 하루를 시작해보세요.';
      case 'love':
        return '상대방의 말에 귀 기울이고 공감해주세요.';
      case 'money':
        return '충동구매를 피하고 계획적인 소비를 하세요.';
      case 'health':
        return '물을 충분히 마시고 스트레칭을 자주 해주세요.';
      case 'career':
        return '동료들과의 협업을 통해 더 좋은 결과를 얻을 수 있습니다.';
      default:
        return '긍정적인 마음가짐을 유지하세요.';
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 운세입니다!';
    if (score >= 80) return '매우 좋은 운세입니다';
    if (score >= 70) return '좋은 운세입니다';
    if (score >= 60) return '평범한 운세입니다';
    return '조심이 필요한 날입니다';
  }

  @override
  Widget buildInputForm() {
    // No input form needed for snap scroll page
    return const SizedBox.shrink();
  }

  @override
  Widget buildFortuneResult() {
    // Not used - we override buildContent instead
    return const SizedBox.shrink();
  }
}

// Data class for fortune information
class FortuneData {
  final String type;
  final String title;
  final int score;
  final String description;
  final Map<String, dynamic> details;

  FortuneData({
    required this.type,
    required this.title,
    required this.score,
    required this.description,
    required this.details,
  });
}