import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';

class BusinessFortunePage extends ConsumerWidget {
  const BusinessFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '사업 운세',
      fortuneType: 'business',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
      ),
      inputBuilder: (context, onSubmit) => _BusinessInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _BusinessFortuneResult(result: result),
    );
  }
}

class _BusinessInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _BusinessInputForm({required this.onSubmit});

  @override
  State<_BusinessInputForm> createState() => _BusinessInputFormState();
}

class _BusinessInputFormState extends State<_BusinessInputForm> {
  String _businessType = 'current';
  String _industry = 'tech';
  String _businessStage = 'growth';
  String _mainConcern = 'revenue';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 사업 운세를 확인하고\n성공적인 비즈니스를 이끌어보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Business Type
        Text(
          '사업 상태',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildBusinessType(theme),
        const SizedBox(height: 24),

        // Industry
        Text(
          '업종',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildIndustry(theme),
        const SizedBox(height: 24),

        // Business Stage
        Text(
          '사업 단계',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildBusinessStage(theme),
        const SizedBox(height: 24),

        // Main Concern
        Text(
          '주요 관심사',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMainConcern(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'businessType': _businessType,
                'industry': _industry,
                'businessStage': _businessStage,
                'mainConcern': _mainConcern,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '사업 운세 보기',
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

  Widget _buildBusinessType(ThemeData theme) {
    final types = [
      {'id': 'current', 'name': '운영중', 'icon': Icons.business},
      {'id': 'planning', 'name': '준비중', 'icon': Icons.lightbulb},
      {'id': 'expansion', 'name': '확장중', 'icon': Icons.expand},
      {'id': 'pivot', 'name': '전환중', 'icon': Icons.refresh},
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
        final isSelected = _businessType == type['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _businessType = type['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
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

  Widget _buildIndustry(ThemeData theme) {
    final industries = [
      {'id': 'tech', 'name': 'IT/테크'},
      {'id': 'retail', 'name': '유통/판매'},
      {'id': 'service', 'name': '서비스업'},
      {'id': 'manufacturing', 'name': '제조업'},
    ];

    return Row(
      children: industries.map((industry) {
        final isSelected = _industry == industry['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _industry = industry['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: industry != industries.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
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
                  industry['name'] as String,
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

  Widget _buildBusinessStage(ThemeData theme) {
    final stages = [
      {'id': 'startup', 'name': '스타트업'},
      {'id': 'growth', 'name': '성장기'},
      {'id': 'mature', 'name': '안정기'},
      {'id': 'renewal', 'name': '재도약기'},
    ];

    return Row(
      children: stages.map((stage) {
        final isSelected = _businessStage == stage['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _businessStage = stage['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: stage != stages.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
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
                  stage['name'] as String,
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

  Widget _buildMainConcern(ThemeData theme) {
    final concerns = [
      {'id': 'revenue', 'name': '매출증대', 'icon': Icons.trending_up},
      {'id': 'expansion', 'name': '사업확장', 'icon': Icons.zoom_out_map},
      {'id': 'partnership', 'name': '파트너십', 'icon': Icons.handshake},
      {'id': 'innovation', 'name': '혁신전략', 'icon': Icons.auto_awesome},
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
      itemCount: concerns.length,
      itemBuilder: (context, index) {
        final concern = concerns[index];
        final isSelected = _mainConcern == concern['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _mainConcern = concern['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
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
                  concern['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  concern['name'] as String,
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

class _BusinessFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _BusinessFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF0891B2),
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
                          colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business,
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
                            '오늘의 사업 운세',
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

        // Business Opportunities
        if (result.details?['opportunities'] != null) ...[
          _buildSectionCard(
            context,
            title: '비즈니스 기회',
            icon: Icons.lightbulb,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            content: result.details!['opportunities'],
          ),
          const SizedBox(height: 16),
        ],

        // Partnership Luck
        if (result.details?['partnership'] != null) ...[
          _buildSectionCard(
            context,
            title: '파트너십 운',
            icon: Icons.handshake,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            content: result.details!['partnership'],
          ),
          const SizedBox(height: 16),
        ],

        // Financial Outlook
        if (result.details?['financial'] != null) ...[
          _buildSectionCard(
            context,
            title: '재무 전망',
            icon: Icons.account_balance,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            content: result.details!['financial'],
          ),
          const SizedBox(height: 16),
        ],

        // Strategic Advice
        if (result.details?['strategy'] != null) ...[
          _buildSectionCard(
            context,
            title: '전략적 조언',
            icon: Icons.psychology,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
            ),
            content: result.details!['strategy'],
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