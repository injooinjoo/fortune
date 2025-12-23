import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/font_config.dart';

class TalentShareCard extends StatelessWidget {
  final String userName;
  final String todaysFocus;
  final IconData focusIcon;
  final Color focusColor;
  final int activationLevel;
  final Map<String, int> topTalents;
  final List<String> topCareers;

  const TalentShareCard({
    super.key,
    required this.userName,
    required this.todaysFocus,
    required this.focusIcon,
    required this.focusColor,
    required this.activationLevel,
    required this.topTalents,
    required this.topCareers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            focusColor.withValues(alpha:0.8),
            focusColor.withValues(alpha:0.6),
            theme.colorScheme.primary.withValues(alpha:0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  '재능 발견',
                  style: TextStyle(
                    color: Colors.white,
                    
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              userName.isNotEmpty ? '$userName님의' : '나의',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.9),
                
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Today's Focus
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha:0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 재능 포커스',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.8),
                      
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        focusIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        todaysFocus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '활성화 지수: $activationLevel%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontFamily: FontConfig.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Top Talents
            Text(
              '상위 재능',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            ...topTalents.entries.take(3).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: FontConfig.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: FontConfig.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Recommended Careers
            Text(
              '추천 직업',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontFamily: FontConfig.primary,
                
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: topCareers.take(3).map((career) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.3),
                  ),
                ),
                child: Text(
                  career,
                  style: const TextStyle(
                    color: Colors.white,
                    
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            
            const Spacer(),
            
            // Footer
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Colors.white.withValues(alpha:0.6),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '운세앱에서 더 자세한 분석 확인하기',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.6),
                      
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TalentCardGenerator {
  static final GlobalKey _cardKey = GlobalKey();
  
  static Future<Uint8List?> generateTalentCard({
    required String userName,
    required String todaysFocus,
    required IconData focusIcon,
    required Color focusColor,
    required int activationLevel,
    required Map<String, int> topTalents,
    required List<String> topCareers,
  }) async {
    try {
      final widget = RepaintBoundary(
        key: _cardKey,
        child: TalentShareCard(
          userName: userName,
          todaysFocus: todaysFocus,
          focusIcon: focusIcon,
          focusColor: focusColor,
          activationLevel: activationLevel,
          topTalents: topTalents,
          topCareers: topCareers,
        ),
      );
      
      // Create a temporary overlay to render the widget
      final overlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -1000,
          top: -1000,
          child: Material(
            color: Colors.transparent,
            child: widget,
          ),
        ),
      );
      
      // Get the current context's overlay
      final context = _cardKey.currentContext;
      if (context == null) return null;
      
      final overlayState = Overlay.of(context);
      overlayState.insert(overlay);
      
      // Wait for the widget to be rendered
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Capture the image
      final RenderRepaintBoundary boundary = 
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = 
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      // Remove the overlay
      overlay.remove();
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating talent card: $e');
      return null;
    }
  }
}

// Helper widget for displaying the share preview
class TalentSharePreview extends StatelessWidget {
  final String userName;
  final Map<String, int> talentData;
  final VoidCallback onShare;

  const TalentSharePreview({
    super.key,
    required this.userName,
    required this.talentData,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // Get today's focus
    final Map<int, Map<String, dynamic>> dailyFocus = {
      1: {'name': '창의력', 'icon': Icons.palette, 'color': DSColors.accentSecondary},
      2: {'name': '분석력', 'icon': Icons.analytics, 'color': DSColors.accent},
      3: {'name': '소통능력', 'icon': Icons.chat, 'color': DSColors.success},
      4: {'name': '리더십', 'icon': Icons.groups, 'color': DSColors.warning},
      5: {'name': '집중력', 'icon': Icons.center_focus_strong, 'color': DSColors.error},
      6: {'name': '직감력', 'icon': Icons.psychology, 'color': DSColors.accent},
      7: {'name': '회복력', 'icon': Icons.self_improvement, 'color': DSColors.accentTertiary},
    };
    
    final focus = dailyFocus[today.weekday]!;
    final activationLevel = 75 + (today.day % 25);
    
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '공유할 재능 카드',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            TalentShareCard(
              userName: userName,
              todaysFocus: focus['name'],
              focusIcon: focus['icon'],
              focusColor: focus['color'],
              activationLevel: activationLevel,
              topTalents: talentData,
              topCareers: ['UX 디자이너', '마케팅 전략가', '프로덕트 매니저'],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('공유하기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}