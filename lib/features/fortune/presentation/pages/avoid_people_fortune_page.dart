import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';

class AvoidPeopleFortunePage extends ConsumerWidget {
  const AvoidPeopleFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '피해야 할 사람',
      fortuneType: 'avoid-people',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      ),
      inputBuilder: (context, onSubmit) => _AvoidPeopleInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _AvoidPeopleFortuneResult(result: result),
    );
  }
}

class _AvoidPeopleInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _AvoidPeopleInputForm({required this.onSubmit});

  @override
  State<_AvoidPeopleInputForm> createState() => _AvoidPeopleInputFormState();
}

class _AvoidPeopleInputFormState extends State<_AvoidPeopleInputForm> {
  String _situation = 'work';
  String _currentMood = 'normal';
  String _socialPreference = 'moderate';
  String _relationshipStatus = 'single';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 피해야 할 사람의 특징을 알아보고\n불필요한 스트레스를 예방하세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Current Situation
        Text(
          '현재 상황',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSituation(theme),
        const SizedBox(height: 24),

        // Current Mood
        Text(
          '오늘의 기분',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCurrentMood(theme),
        const SizedBox(height: 24),

        // Social Preference
        Text(
          '사교 성향',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSocialPreference(theme),
        const SizedBox(height: 24),

        // Relationship Status
        Text(
          '관계 상태',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildRelationshipStatus(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'situation': _situation,
                'currentMood': _currentMood,
                'socialPreference': _socialPreference,
                'relationshipStatus': null,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '피해야 할 사람 확인하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildSituation(ThemeData theme) {
    final situations = [
      {'id': 'work': 'name': '직장/학교': 'icon'},
      {'id': 'social': 'name': '사교모임': 'icon'},
      {'id': 'family', 'name': '가족모임', 'icon'},
      {'id': 'date', 'name': '데이트', 'icon'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ,
      itemCount: situations.length,
      itemBuilder: (context, index) {
        final situation = situations[index];
        final isSelected = _situation == situation['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _situation = situation['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
                  situation['icon'],
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  situation['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCurrentMood(ThemeData theme) {
    final moods = [
      {'id': 'great': 'name': '좋음': 'icon'},
      {'id': 'normal', 'name': '보통', 'icon'},
      {'id': 'tired', 'name': '피곤', 'icon'},
      {'id': 'stressed', 'name': '스트레스', 'icon'},
    ];

    return Row(
      children: moods.map((mood) {
        final isSelected = _currentMood == mood['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentMood = mood['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: mood != moods.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
                    mood['icon'],
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList()
    );
  }

  Widget _buildSocialPreference(ThemeData theme) {
    final preferences = [
      {'id': 'introvert': 'name': '혼자가 좋아'},
      {'id': 'moderate': 'name': '적당히'},
      {'id': 'extrovert', 'name': '사람이 좋아'},
    ];

    return Row(
      children: preferences.map((preference) {
        final isSelected = _socialPreference == preference['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _socialPreference = preference['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: preference != preferences.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
                  preference['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList()
    );
  }

  Widget _buildRelationshipStatus(ThemeData theme) {
    final statuses = [
      {'id': 'single': 'name': '싱글'},
      {'id': 'dating': 'name': '연애중'},
      {'id': 'married', 'name': '기혼'},
      {'id': 'complicated', 'name': '복잡'},
    ];

    return Row(
      children: statuses.map((status) {
        final isSelected = _relationshipStatus == status['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _relationshipStatus = status['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: status != statuses.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
                  status['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList()
    );
  }
}

class _AvoidPeopleFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _AvoidPeopleFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFFDC2626),
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
                          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
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
                            '오늘 피해야 할 사람',
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

        // People Types to Avoid
        if (result.details?['peopleTypes'] != null) ...[
          _buildSectionCard(
            context,
            title: '주의해야 할 유형',
            icon: Icons.person_off,
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            content: result.details!['peopleTypes'],
          ),
          const SizedBox(height: 16),
        ],

        // Behavioral Signs
        if (result.details?['behavioralSigns'] != null) ...[
          _buildSectionCard(
            context,
            title: '행동 특징',
            icon: Icons.psychology_alt,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            content: result.details!['behavioralSigns'],
          ),
          const SizedBox(height: 16),
        ],

        // Situations to Avoid
        if (result.details?['situations'] != null) ...[
          _buildSectionCard(
            context,
            title: '피해야 할 상황',
            icon: Icons.dangerous,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
            ),
            content: result.details!['situations'],
          ),
          const SizedBox(height: 16),
        ],

        // Protection Strategies
        if (result.details?['protection'] != null) ...[
          _buildSectionCard(
            context,
            title: '대처 방법',
            icon: Icons.shield,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            content: result.details!['protection'],
          ),
          const SizedBox(height: 16),
        ],

        // Positive Encounters
        if (result.details?['positiveEncounters'] != null) ...[
          _buildSectionCard(
            context,
            title: '좋은 만남',
            icon: Icons.people_alt,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            content: result.details!['positiveEncounters'],
          ),
        ],
      ]
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
      )
    );
  }
}