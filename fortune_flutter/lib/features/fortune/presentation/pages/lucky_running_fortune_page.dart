import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'simple_fortune_page.dart';
import '../../domain/models/fortune_result.dart';

class LuckyRunningFortunePage extends ConsumerWidget {
  const LuckyRunningFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleFortunePage(
      title: '런닝 운세',
      fortuneType: 'lucky-running',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
      ),
      inputBuilder: (context, onSubmit) => _RunningInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, regenerate) => _RunningFortuneResult(result: result),
    );
  }
}

class _RunningInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _RunningInputForm({required this.onSubmit});

  @override
  State<_RunningInputForm> createState() => _RunningInputFormState();
}

class _RunningInputFormState extends State<_RunningInputForm> {
  String _runningType = 'morning';
  String _distance = '5k';
  String _terrain = 'road';
  String _goal = 'health';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 런닝 운세를 확인하고\n최고의 컨디션으로 달려보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Running Time
        Text(
          '러닝 시간대',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTimeSelection(theme),
        const SizedBox(height: 24),

        // Distance
        Text(
          '목표 거리',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDistanceSelection(theme),
        const SizedBox(height: 24),

        // Terrain
        Text(
          '러닝 코스',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTerrainSelection(theme),
        const SizedBox(height: 24),

        // Goal
        Text(
          '러닝 목표',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildGoalSelection(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'runningType': _runningType,
                'distance': _distance,
                'terrain': _terrain,
                'goal': _goal,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '런닝 운세 보기',
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

  Widget _buildTimeSelection(ThemeData theme) {
    final times = [
      {'id': 'morning', 'name': '아침', 'icon': Icons.wb_sunny},
      {'id': 'afternoon', 'name': '오후', 'icon': Icons.wb_cloudy},
      {'id': 'evening', 'name': '저녁', 'icon': Icons.nightlight_round},
      {'id': 'night', 'name': '밤', 'icon': Icons.dark_mode},
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
      itemCount: times.length,
      itemBuilder: (context, index) {
        final time = times[index];
        final isSelected = _runningType == time['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _runningType = time['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
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
                  time['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  time['name'] as String,
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

  Widget _buildDistanceSelection(ThemeData theme) {
    final distances = [
      {'id': '5k', 'name': '5km'},
      {'id': '10k', 'name': '10km'},
      {'id': '21k', 'name': '하프'},
      {'id': '42k', 'name': '풀코스'},
    ];

    return Row(
      children: distances.map((distance) {
        final isSelected = _distance == distance['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _distance = distance['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: distance != distances.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
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
                  distance['name'] as String,
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

  Widget _buildTerrainSelection(ThemeData theme) {
    final terrains = [
      {'id': 'road', 'name': '도로', 'icon': Icons.route},
      {'id': 'track', 'name': '트랙', 'icon': Icons.stadium},
      {'id': 'trail', 'name': '트레일', 'icon': Icons.terrain},
      {'id': 'treadmill', 'name': '트레드밀', 'icon': Icons.fitness_center},
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
      itemCount: terrains.length,
      itemBuilder: (context, index) {
        final terrain = terrains[index];
        final isSelected = _terrain == terrain['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _terrain = terrain['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
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
                  terrain['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  terrain['name'] as String,
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

  Widget _buildGoalSelection(ThemeData theme) {
    final goals = [
      {'id': 'health', 'name': '건강', 'icon': Icons.favorite},
      {'id': 'weight', 'name': '다이어트', 'icon': Icons.trending_down},
      {'id': 'speed', 'name': '속도향상', 'icon': Icons.speed},
      {'id': 'marathon', 'name': '대회준비', 'icon': Icons.emoji_events},
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
        final isSelected = _goal == goal['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _goal = goal['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
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

class _RunningFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _RunningFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF3B82F6),
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
                          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_run,
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
                            '오늘의 런닝 운세',
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

        // Best Running Time
        if (result.details?['bestTime'] != null) ...[
          _buildSectionCard(
            context,
            title: '최적의 러닝 시간',
            icon: Icons.schedule,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            content: result.details!['bestTime'],
          ),
          const SizedBox(height: 16),
        ],

        // Running Course
        if (result.details?['course'] != null) ...[
          _buildSectionCard(
            context,
            title: '추천 러닝 코스',
            icon: Icons.map,
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            content: result.details!['course'],
          ),
          const SizedBox(height: 16),
        ],

        // Performance Tips
        if (result.details?['performance'] != null) ...[
          _buildSectionCard(
            context,
            title: '퍼포먼스 팁',
            icon: Icons.trending_up,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            content: result.details!['performance'],
          ),
          const SizedBox(height: 16),
        ],

        // Safety Alert
        if (result.details?['safety'] != null) ...[
          _buildSectionCard(
            context,
            title: '안전 주의사항',
            icon: Icons.warning_amber_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            content: result.details!['safety'],
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