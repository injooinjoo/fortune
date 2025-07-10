import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'simple_fortune_page.dart';
import '../../domain/models/fortune_result.dart';

class LuckySwimFortunePage extends ConsumerWidget {
  const LuckySwimFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleFortunePage(
      title: '수영 운세',
      fortuneType: 'lucky-swim',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      ),
      inputBuilder: (context, onSubmit) => _SwimInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, regenerate) => _SwimFortuneResult(result: result),
    );
  }
}

class _SwimInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _SwimInputForm({required this.onSubmit});

  @override
  State<_SwimInputForm> createState() => _SwimInputFormState();
}

class _SwimInputFormState extends State<_SwimInputForm> {
  String _poolType = 'indoor';
  String _strokeType = 'freestyle';
  String _swimLevel = 'beginner';
  String _swimGoal = 'fitness';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 수영 운세를 확인하고\n물 속에서 행운을 만나보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Pool Type
        Text(
          '수영장 환경',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPoolType(theme),
        const SizedBox(height: 24),

        // Stroke Type
        Text(
          '주 영법',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStrokeType(theme),
        const SizedBox(height: 24),

        // Swim Level
        Text(
          '수영 실력',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSwimLevel(theme),
        const SizedBox(height: 24),

        // Swim Goal
        Text(
          '수영 목표',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSwimGoal(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'poolType': _poolType,
                'strokeType': _strokeType,
                'swimLevel': _swimLevel,
                'swimGoal': _swimGoal,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '수영 운세 보기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoolType(ThemeData theme) {
    final types = [
      {'id': 'indoor', 'name': '실내', 'icon': Icons.pool},
      {'id': 'outdoor', 'name': '야외', 'icon': Icons.wb_sunny},
      {'id': 'ocean', 'name': '바다', 'icon': Icons.waves},
      {'id': 'lake', 'name': '호수', 'icon': Icons.water},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _poolType == type['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _poolType = type['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  type['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrokeType(ThemeData theme) {
    final strokes = [
      {'id': 'freestyle', 'name': '자유형'},
      {'id': 'backstroke', 'name': '배영'},
      {'id': 'breaststroke', 'name': '평영'},
      {'id': 'butterfly', 'name': '접영'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: strokes.length,
      itemBuilder: (context, index) {
        final stroke = strokes[index];
        final isSelected = _strokeType == stroke['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _strokeType = stroke['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                stroke['name'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwimLevel(ThemeData theme) {
    final levels = [
      {'id': 'beginner', 'name': '초급'},
      {'id': 'intermediate', 'name': '중급'},
      {'id': 'advanced', 'name': '상급'},
      {'id': 'master', 'name': '마스터'},
    ];

    return Row(
      children: levels.map((level) {
        final isSelected = _swimLevel == level['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _swimLevel = level['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: level != levels.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                      )
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  level['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwimGoal(ThemeData theme) {
    final goals = [
      {'id': 'fitness', 'name': '체력향상', 'icon': Icons.fitness_center},
      {'id': 'technique', 'name': '기술향상', 'icon': Icons.school},
      {'id': 'competition', 'name': '대회준비', 'icon': Icons.emoji_events},
      {'id': 'recreation', 'name': '취미활동', 'icon': Icons.mood},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final isSelected = _swimGoal == goal['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _swimGoal = goal['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  goal['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  goal['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SwimFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _SwimFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF06B6D4),
          borderRadius: BorderRadius.circular(20),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pool,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 수영 운세',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            result.date ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  result.mainFortune ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Best Swimming Time
        if (result.details?['bestTime'] != null) ...[
          _buildSectionCard(
            context,
            title: '최적의 수영 시간',
            icon: Icons.schedule,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            content: result.details!['bestTime'],
          ),
          const SizedBox(height: 16),
        ],

        // Stroke Tips
        if (result.details?['strokeTips'] != null) ...[
          _buildSectionCard(
            context,
            title: '영법별 운세',
            icon: Icons.waves,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            content: result.details!['strokeTips'],
          ),
          const SizedBox(height: 16),
        ],

        // Training Focus
        if (result.details?['training'] != null) ...[
          _buildSectionCard(
            context,
            title: '오늘의 훈련 포인트',
            icon: Icons.fitness_center,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            content: result.details!['training'],
          ),
          const SizedBox(height: 16),
        ],

        // Pool Etiquette
        if (result.details?['etiquette'] != null) ...[
          _buildSectionCard(
            context,
            title: '수영장 에티켓 운',
            icon: Icons.people,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
            ),
            content: result.details!['etiquette'],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required String content,
  }) {
    final theme = Theme.of(context);

    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}