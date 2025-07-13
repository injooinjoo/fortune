import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';

class LuckyHikingFortunePage extends ConsumerWidget {
  const LuckyHikingFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '등산 운세',
      fortuneType: 'lucky-hiking',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      ),
      inputBuilder: (context, onSubmit) => _HikingInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _HikingFortuneResult(result: result),
    );
  }
}

class _HikingInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _HikingInputForm({required this.onSubmit});

  @override
  State<_HikingInputForm> createState() => _HikingInputFormState();
}

class _HikingInputFormState extends State<_HikingInputForm> {
  String _difficulty = 'moderate';
  String _duration = 'halfday';
  String _purpose = 'recreation';
  String _season = _getCurrentSeason();

  static String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 등산 운세를 확인하고\n안전하고 즐거운 산행을 즐기세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Difficulty Level
        Text(
          '난이도',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDifficulty(theme),
        const SizedBox(height: 24),

        // Duration
        Text(
          '예상 시간',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDuration(theme),
        const SizedBox(height: 24),

        // Purpose
        Text(
          '등산 목적',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPurpose(theme),
        const SizedBox(height: 24),

        // Season
        Text(
          '계절',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSeason(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'difficulty': _difficulty,
                'duration': _duration,
                'purpose': _purpose,
                'season': _season,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '등산 운세 보기',
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

  Widget _buildDifficulty(ThemeData theme) {
    final levels = [
      {'id': 'easy', 'name': '초급', 'icon': Icons.hiking},
      {'id': 'moderate', 'name': '중급', 'icon': Icons.terrain},
      {'id': 'hard', 'name': '상급', 'icon': Icons.landscape},
      {'id': 'extreme', 'name': '전문가', 'icon': Icons.filter_hdr},
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
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isSelected = _difficulty == level['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _difficulty = level['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  level['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  level['name'] as String,
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

  Widget _buildDuration(ThemeData theme) {
    final durations = [
      {'id': 'short', 'name': '2시간 이내'},
      {'id': 'halfday', 'name': '반나절'},
      {'id': 'fullday', 'name': '종일'},
      {'id': 'overnight', 'name': '1박2일'},
    ];

    return Row(
      children: durations.map((duration) {
        final isSelected = _duration == duration['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _duration = duration['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: duration != durations.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  duration['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurpose(ThemeData theme) {
    final purposes = [
      {'id': 'recreation', 'name': '휴식', 'icon': Icons.spa},
      {'id': 'exercise', 'name': '운동', 'icon': Icons.fitness_center},
      {'id': 'photography', 'name': '사진', 'icon': Icons.photo_camera},
      {'id': 'meditation', 'name': '명상', 'icon': Icons.self_improvement},
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
      itemCount: purposes.length,
      itemBuilder: (context, index) {
        final purpose = purposes[index];
        final isSelected = _purpose == purpose['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _purpose = purpose['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  purpose['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  purpose['name'] as String,
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

  Widget _buildSeason(ThemeData theme) {
    final seasons = [
      {'id': 'spring', 'name': '봄', 'icon': Icons.local_florist},
      {'id': 'summer', 'name': '여름', 'icon': Icons.wb_sunny},
      {'id': 'autumn', 'name': '가을', 'icon': Icons.park},
      {'id': 'winter', 'name': '겨울', 'icon': Icons.ac_unit},
    ];

    return Row(
      children: seasons.map((season) {
        final isSelected = _season == season['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _season = season['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: season != seasons.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    season['icon'] as IconData,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    season['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HikingFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _HikingFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF10B981),
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
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.terrain,
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
                            '오늘의 등산 운세',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            result.date ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

        // Best Trail
        if (result.details?['bestTrail'] != null) ...[
          _buildSectionCard(
            context,
            title: '추천 등산로',
            icon: Icons.route,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            content: result.details!['bestTrail'],
          ),
          const SizedBox(height: 16),
        ],

        // Safety Tips
        if (result.details?['safety'] != null) ...[
          _buildSectionCard(
            context,
            title: '안전 수칙',
            icon: Icons.security,
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            content: result.details!['safety'],
          ),
          const SizedBox(height: 16),
        ],

        // Weather Conditions
        if (result.details?['weather'] != null) ...[
          _buildSectionCard(
            context,
            title: '날씨 및 산행 조건',
            icon: Icons.cloud_queue,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            content: result.details!['weather'],
          ),
          const SizedBox(height: 16),
        ],

        // Equipment
        if (result.details?['equipment'] != null) ...[
          _buildSectionCard(
            context,
            title: '필수 장비',
            icon: Icons.backpack,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
            ),
            content: result.details!['equipment'],
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