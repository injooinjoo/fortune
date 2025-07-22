import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

enum TraditionalType {
  saju('정통 사주', 'saju', '사주팔자로 보는 운명', Icons.auto_awesome_rounded, [Color(0xFFEF4444), Color(0xFFEC4899)], true),
  sajuChart('사주 차트', 'saju-chart', '시각적 사주 분석', Icons.insights_rounded, [Color(0xFF5E35B1), Color(0xFF4527A0)], false),
  tojeong('토정비결', 'tojeong', '전통 토정비결', Icons.menu_book_rounded, [Color(0xFF8B5CF6), Color(0xFF7C3AED)], true),
  tarot('타로카드', 'tarot', '타로카드 점술', Icons.style_rounded, [Color(0xFF9333EA), Color(0xFF7C3AED)], true),
  dream('꿈 해몽', 'dream', '꿈의 의미 해석', Icons.bedtime_rounded, [Color(0xFF6366F1), Color(0xFF4F46E5)], false),
  physiognomy('관상', 'physiognomy', '얼굴로 보는 운세', Icons.face_rounded, [Color(0xFFEC4899), Color(0xFFDB2777)], false),
  talisman('부적', 'talisman', '액운을 막는 부적', Icons.shield_rounded, [Color(0xFF8D6E63), Color(0xFF6D4C41)], false);

  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPremium;
  
  const TraditionalType(this.label, this.value, this.description, this.icon, this.gradientColors, this.isPremium);
}

class TraditionalFortuneUnifiedPage extends ConsumerStatefulWidget {
  const TraditionalFortuneUnifiedPage({super.key});

  @override
  ConsumerState<TraditionalFortuneUnifiedPage> createState() => _TraditionalFortuneUnifiedPageState();
}

class _TraditionalFortuneUnifiedPageState extends ConsumerState<TraditionalFortuneUnifiedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전통 운세'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.1, end: 0),
            const SizedBox(height: 24),
            
            // Traditional Fortune Grid
            Text(
              '운세 선택',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTraditionalGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEF4444).withOpacity(0.1),
            Color(0xFFEC4899).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFEF4444).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          Text(
            '전통 운세',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '5000년 역사의 동양 철학과 서양의 신비로운 타로까지',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: TraditionalType.values.length,
      itemBuilder: (context, index) {
        final type = TraditionalType.values[index];
        return _buildTraditionalCard(type, index);
      },
    );
  }

  Widget _buildTraditionalCard(TraditionalType type, int index) {
    return InkWell(
      onTap: () => _navigateToFortune(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: type.gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: type.gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    type.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Premium Badge
            if (type.isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate(delay: (50 * index).ms)
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  void _navigateToFortune(TraditionalType type) {
    // Special handling for different fortune types
    switch (type) {
      case TraditionalType.saju:
        context.push('/fortune/saju');
        break;
      case TraditionalType.sajuChart:
        context.push('/fortune/saju-chart');
        break;
      case TraditionalType.tarot:
        // Navigate to existing tarot page
        context.push('/interactive/tarot');
        break;
      case TraditionalType.dream:
        // Navigate to dream fortune chat page
        context.push('/fortune/dream-chat');
        break;
      default:
        // For others, navigate to traditional fortune page with type parameter
        context.push('/fortune/traditional?type=${type.value}');
        break;
    }
  }
}