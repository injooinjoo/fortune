import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/design_system/design_system.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class CareerFortuneType {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String route;
  final List<String> targetAudience;
  final bool isNew;

  const CareerFortuneType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.route,
    required this.targetAudience,
    this.isNew = false});
}

class CareerFortuneSelector extends StatelessWidget {
  const CareerFortuneSelector({super.key});

  static const List<CareerFortuneType> careerTypes = [
    CareerFortuneType(
      id: 'seeker',
      title: '취업운',
      subtitle: '첫 발걸음',
      description: '새로운 직장을 찾고 있는 분들을 위한 운세',
      icon: Icons.work_outline_rounded,
      gradientColors: [FortuneColors.career, FortuneColors.career],
      route: '/career',
      targetAudience: ['신입', '구직자', '이직 준비']),
    CareerFortuneType(
      id: 'change',
      title: '이직운',
      subtitle: '새로운 도전',
      description: '더 나은 기회를 찾는 분들을 위한 운세',
      icon: Icons.swap_horiz_rounded,
      gradientColors: [FortuneColors.career, FortuneColors.careerDark],
      route: '/career',
      targetAudience: ['경력직', '이직 고민', '커리어 체인지']),
    CareerFortuneType(
      id: 'future',
      title: '직장 미래운',
      subtitle: '내일의 나',
      description: '현재 직장에서의 미래가 궁금한 분들을 위한 운세',
      icon: Icons.trending_up_rounded,
      gradientColors: [FortuneColors.career, FortuneColors.career],
      route: '/career',
      targetAudience: ['재직자', '승진 대상', '연봉 협상']),
    CareerFortuneType(
      id: 'freelance',
      title: '프리랜서운',
      subtitle: '자유로운 영혼',
      description: '독립적인 커리어를 꿈꾸는 분들을 위한 운세',
      icon: Icons.laptop_mac_rounded,
      gradientColors: [FortuneColors.wealth, FortuneColors.wealthDark],
      route: '/career',
      targetAudience: ['프리랜서', '1인 기업', 'N잡러'],
      isNew: true),
    CareerFortuneType(
      id: 'startup',
      title: '창업운',
      subtitle: '도전의 길',
      description: '새로운 사업을 시작하려는 분들을 위한 운세',
      icon: Icons.rocket_launch_rounded,
      gradientColors: [DSColors.textSecondary, DSColors.textSecondary],
      route: '/career',
      targetAudience: ['예비 창업자', '스타트업', '사업가']),
    CareerFortuneType(
      id: 'crisis',
      title: '위기극복운',
      subtitle: '전환점',
      description: '커리어 위기를 겪고 있는 분들을 위한 운세',
      icon: Icons.support_rounded,
      gradientColors: [FortuneColors.mystical, FortuneColors.mysticalLight],
      route: '/career',
      targetAudience: ['번아웃', '구조조정', '커리어 전환'],
      isNew: true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DSColors.background : Colors.white,
      appBar: AppBar(
        title: const Text('커리어 운세'),
        backgroundColor: Colors.transparent,
        elevation: 0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '당신의 커리어 상황은?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? DSColors.textPrimary : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 상황에 맞는 운세를 선택해주세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final careerType = careerTypes[index];
                    return _CareerTypeCard(careerType: careerType);
                  },
                  childCount: careerTypes.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _CareerTypeCard extends StatelessWidget {
  final CareerFortuneType careerType;

  const _CareerTypeCard({
    required this.careerType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push(careerType.route),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: careerType.gradientColors.map((color) => 
            color.withValues(alpha: 0.1)).toList(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: careerType.gradientColors),
                    borderRadius: BorderRadius.circular(DSRadius.md)),
                  child: Icon(
                    careerType.icon,
                    color: Colors.white,
                    size: 24)),
                const Spacer(),
                if (careerType.isNew) Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.textSecondary,
                      borderRadius: BorderRadius.circular(DSRadius.md)),
                    child: Text(
                      'NEW',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)))
              ],
            ),
            const SizedBox(height: 16),
            Text(
              careerType.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? DSColors.textPrimary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              careerType.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: careerType.gradientColors.first,
                fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              careerType.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: careerType.targetAudience.take(2).map((audience) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4 * 0.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.sm)),
                  child: Text(
                    audience,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}