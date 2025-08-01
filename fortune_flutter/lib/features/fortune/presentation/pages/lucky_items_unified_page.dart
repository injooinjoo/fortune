import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LuckyItemsUnifiedPage extends BaseFortunePage {
  const LuckyItemsUnifiedPage({
    Key? key,
  }) : super(
          key: key,
          title: '오늘의 행운 아이템',
          description: '행운의 색깔, 숫자, 음식, 아이템을 한 번에 확인하세요',
          fortuneType: 'lucky_items',
          requiresUserInfo: true
        );

  @override
  ConsumerState<LuckyItemsUnifiedPage> createState() => _LuckyItemsUnifiedPageState();
}

class _LuckyItemsUnifiedPageState extends BaseFortunePageState<LuckyItemsUnifiedPage> {
  Fortune? _fortuneResult;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Get all lucky items in one request
    params['includeAll'] = true;
    
    final fortune = await fortuneService.getLuckyItemsFortune(
      userId: params['userId'],
      params: params
    );
    
    setState(() {
      _fortuneResult = fortune;
    });
    
    return fortune;
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          
          // Generate Button (if no result yet)
          if (_fortuneResult == null) ...[
            _buildGenerateButton(),
          ] else ...[
            // Lucky Items Grid
            _buildLuckyItemsGrid(),
            const SizedBox(height: 24),
            
            // Overall Message
            if (_fortuneResult!.message.isNotEmpty)
              _buildOverallMessage(),
            
            // Refresh Button
            const SizedBox(height: 16),
            _buildRefreshButton(),
          ],
        ],
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
            Color(0xFF7C3AED).withValues(alpha: 0.1),
            Color(0xFF3B82F6).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF7C3AED).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),
          Text(
            '오늘의 행운 아이템',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '당신에게 행운을 가져다줄 특별한 아이템들을 확인해보세요',
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

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onGenerateFortune,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Color(0xFF7C3AED),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              '행운 아이템 확인하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyItemsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 색깔',
                icon: Icons.palette_rounded,
                value: _fortuneResult?.luckyColor ?? '',
                gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 숫자',
                icon: Icons.looks_one_rounded,
                value: _fortuneResult?.luckyNumber?.toString() ?? '',
                gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 음식',
                icon: Icons.restaurant_rounded,
                value: _fortuneResult?.luckyItems?['food'] as String? ?? '',
                gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 아이템',
                icon: Icons.diamond_rounded,
                value: _fortuneResult?.luckyItems?['item'] as String? ?? '',
                gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLuckyItemCard({
    required String title,
    required IconData icon,
    required String value,
    required List<Color> gradientColors,
    required int delay,
  }) {
    // Special handling for color
    Widget valueWidget;
    if (title == '행운의 색깔' && value.isNotEmpty) {
      // Try to parse color name to actual color
      Color? displayColor = _getColorFromName(value);
      if (displayColor != null) {
        valueWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: displayColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      } else {
        valueWidget = Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }
    } else {
      valueWidget = Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center
      );
    }

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(child: valueWidget),
        ],
      ),
    ).animate(delay: delay.ms)
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildOverallMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFF7C3AED),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '종합 운세',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _fortuneResult!.message,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textColor,
            ),
          ),
          if (_fortuneResult!.advice != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF7C3AED).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _fortuneResult!.advice!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 400.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildRefreshButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _onGenerateFortune,
        icon: const Icon(Icons.refresh),
        label: const Text('다시 보기'),
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFF7C3AED),
        ),
      ),
    );
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null) {
      setState(() {
        _fortuneResult = null;
      });
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
      };
      generateFortuneAction(params: params);
    }
  }

  Color? _getColorFromName(String colorName) {
    final colorMap = {
      '빨간색': Colors.red,
      '파란색': Colors.blue,
      '노란색': Colors.yellow,
      '초록색': Colors.green,
      '보라색': Colors.purple,
      '주황색': Colors.orange,
      '분홍색': Colors.pink,
      '하얀색': Colors.white,
      '검은색': Colors.black,
      '회색': Colors.grey,
      '갈색': Colors.brown,
      '금색': Colors.amber,
      '은색': Colors.grey[300],
      '하늘색': Colors.lightBlue,
      '남색': Colors.indigo,
      '청록색': Colors.teal,
    };
    
    return colorMap[colorName];
  }
}