import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Special fortune item model
class SpecialFortuneItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String route;
  final bool isNew;
  final bool isPremium;
  final DateTime? availableUntil;
  final List<Color> gradientColors;

  const SpecialFortuneItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.route,
    this.isNew = false,
    this.isPremium = false,
    this.availableUntil,
    required this.gradientColors});
}

// Mock data for special fortunes
final List<SpecialFortuneItem> specialFortunes = [
  SpecialFortuneItem(
    id: 'new-year-2025',
    title: '2025 을사년 신년운세',
    description: '뱀의 해를 맞이하는 당신의 한 해 운세',
    imageUrl: 'https://placehold.co/600x240/png',
    route: '/fortune/new-year',
    isNew: true,
    gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFD93D)]),
  SpecialFortuneItem(
    id: 'valentine-2025',
    title: '발렌타인 특별 연애운',
    description: '2월 14일까지 특별한 연애운 이벤트',
    imageUrl: 'https://placehold.co/600x240/png',
    route: '/fortune/love',
    availableUntil: DateTime(2025, 2, 14),
    gradientColors: const [Color(0xFFEC4899), Color(0xFFDB2777)]),
  SpecialFortuneItem(
    id: 'spring-fortune',
    title: '봄맞이 재테크 운세',
    description: '새 계절의 시작과 함께하는 재물운',
    imageUrl: 'https://placehold.co/600x240/png',
    route: '/fortune/wealth',
    gradientColors: const [Color(0xFF10B981), Color(0xFF059669)])];

// Love fortune items
final List<SpecialFortuneItem> loveFortunes = [
  SpecialFortuneItem(
    id: 'celebrity-match',
    title: '연예인 궁합',
    description: '최애와의 궁합은?',
    imageUrl: 'https://placehold.co/300x160/png',
    route: '/fortune/celebrity-match',
    gradientColors: const [Color(0xFFFF4081), Color(0xFFF50057)]),
  SpecialFortuneItem(
    id: 'marriage-timing',
    title: '결혼 시기',
    description: '평생의 인연을 만날 시기',
    imageUrl: 'https://placehold.co/300x160/png',
    route: '/fortune/marriage',
    isPremium: true,
    gradientColors: const [Color(0xFFDB2777), Color(0xFFBE185D)]),
  SpecialFortuneItem(
    id: 'ex-lover',
    title: '전 애인 운세',
    description: '다시 만날 수 있을까요?',
    imageUrl: 'https://placehold.co/300x160/png',
    route: '/fortune/ex-lover',
    gradientColors: const [Color(0xFF9333EA), Color(0xFF7C3AED)])];

// Fun content items
final List<SpecialFortuneItem> funContents = [
  SpecialFortuneItem(
    id: 'name-fortune',
    title: '이름풀이',
    description: '당신의 이름에 담긴 운명',
    imageUrl: 'https://placehold.co/300x160/png',
    route: '/fortune/name',
    isNew: true,
    gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)]),
  SpecialFortuneItem(
    id: 'pet-fortune',
    title: '반려동물 운세',
    description: '우리집 댕냥이의 오늘',
    imageUrl: 'https://placehold.co/300x160/png',
    route: '/fortune/pet',
    isNew: true,
    gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)]),
  SpecialFortuneItem(
    id: 'food-fortune',
    title: '음식 운세',
    description: '오늘 뭐 먹지?',
    imageUrl: 'https://placehold.co/300x160/png',
    route: '/fortune/lucky-food',
    gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)])];

class SpecialPage extends ConsumerWidget {
  const SpecialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppHeader(
        title: '특별 운세',
        showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            if (specialFortunes.isNotEmpty) ...[
              Text(
                '이벤트 운세',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: fontSize.value + 4,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: specialFortunes.length,
                  itemBuilder: (context, index) {
                    final item = specialFortunes[index];
                    return _buildBannerCard(context, theme, fontSize.value, item);
                  })),
              const SizedBox(height: 32)],

            // Love Fortune Section
            _buildSection(
              context,
              theme,
              fontSize.value,
              title: '연애 운세',
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFEC4899),
              items: loveFortunes),
            const SizedBox(height: 32),

            // Fun Contents Section
            _buildSection(
              context,
              theme,
              fontSize.value,
              title: '재미있는 운세',
              icon: Icons.celebration_rounded,
              iconColor: const Color(0xFFF59E0B),
              items: funContents),
            const SizedBox(height: 32),

            // Coming Soon Section
            _buildComingSoonSection(theme, fontSize.value)])));
  }

  Widget _buildBannerCard(
    BuildContext context,
    ThemeData theme,
    double fontSize,
    SpecialFortuneItem item) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradientColors)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceContainerHighest),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported))),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7)])),
            
            // Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize - 6,
                              fontWeight: FontWeight.bold)),
                      if (item.isNew) const SizedBox(width: 8),
                      if (item.availableUntil != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          child: Text(
                            '${item.availableUntil!.month}/${item.availableUntil!.day}까지',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize - 6,
                              fontWeight: FontWeight.bold)))]),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: fontSize,
                      color: Colors.white.withOpacity(0.9))])])));
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    double fontSize, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<SpecialFortuneItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(context, theme, fontSize, item);
            }))]);
  }

  Widget _buildItemCard(
    BuildContext context,
    ThemeData theme,
    double fontSize,
    SpecialFortuneItem item) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: SizedBox(
        width: 280,
        child: Stack(
          children: [
            GlassContainer(
              borderRadius: BorderRadius.circular(16),
              blur: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: item.gradientColors)),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainerHighest),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported))),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: fontSize - 2,
                            color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)])]),
            
            // Badges
            if (item.isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize - 6,
                      fontWeight: FontWeight.bold)),
            if (item.isPremium)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                    borderRadius: BorderRadius.circular(8),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.white))]));
  }

  Widget _buildComingSoonSection(ThemeData theme, double fontSize) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withOpacity(0.1),
          theme.colorScheme.secondary.withOpacity(0.1)]),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            size: 48,
            color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            '더 많은 특별 운세가 준비 중이에요!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            '매주 새로운 운세가 추가됩니다',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center)]));
  }
}