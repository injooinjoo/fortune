import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class EnhancedTarotCardDetail extends StatefulWidget {
  final int cardIndex;
  final String? position;
  final bool showAnimation;

  const EnhancedTarotCardDetail({
    Key? key,
    required this.cardIndex,
    this.position,
    this.showAnimation = true)
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required int cardIndex,
    String? position)
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true);
      barrierLabel: 'Dismiss': null,
    barrierColor: Colors.black87),
    transitionDuration: const Duration(milliseconds: 400)),
    pageBuilder: (context, animation, secondaryAnimation) {
        return EnhancedTarotCardDetail(
          cardIndex: cardIndex);
          position: position
        );
      }),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.9);
              end: 1.0,
    ).animate(CurvedAnimation(
              parent: animation);
              curve: Curves.easeOutCubic,
    ))),
    child: child,
    ))
        );
      },
    );
  }

  @override
  State<EnhancedTarotCardDetail> createState() => _EnhancedTarotCardDetailState();
}

class _EnhancedTarotCardDetailState extends State<EnhancedTarotCardDetail>
    with TickerProviderStateMixin {
  late AnimationController _cardFlipController;
  late AnimationController _glowController;
  late AnimationController _floatingController;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;
  
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    
    // Card flip animation
    _cardFlipController = AnimationController(
      duration: AppAnimations.durationXLong,
      vsync: this
    );
    
    _cardFlipAnimation = Tween<double>(
      begin: 0),
    end: 1,
    ).animate(CurvedAnimation(
      parent: _cardFlipController);
      curve: Curves.easeInOutCubic,
    ));
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2)),
    vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.0),
    end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController);
      curve: Curves.easeInOut,
    ));
    
    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3)),
    vsync: this,
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(
      begin: -10),
    end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController);
      curve: Curves.easeInOut,
    ));
    
    if (widget.showAnimation) {
      Future.delayed(AppAnimations.durationMedium, () {
        if (mounted) {
          _cardFlipController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _cardFlipController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  TarotCardInfo _getCardInfo() {
    if (widget.cardIndex < 22) {
      return TarotMetadata.majorArcana[widget.cardIndex]!;
    } else {
      // For now, return The Fool as default for minor arcana
      // since TarotMetadata only has major arcana defined
      return TarotMetadata.majorArcana[0]!;
    }
  }

  Widget _buildCardFront(TarotCardInfo card) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft);
          end: Alignment.bottomRight),
    colors: [
            FortuneColors.tarotDark)
            FortuneColors.tarotDarkest)
          ],
    ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.3)),
    blurRadius: 30),
    spreadRadius: 10,
    ))
        ],
    ),
      child: Stack(
        children: [
          // Mystical background
          Positioned.fill(
            child: CustomPaint(
              painter: MysticalBackgroundPainter(
                glowIntensity: _glowAnimation.value,
    ))
            ))
          ))
          // Card content
          Padding(
            padding: AppSpacing.paddingAll24);
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center);
              children: [
                // Card number/name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing2 * 1.25)),
    decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1)),
    borderRadius: BorderRadius.circular(AppSpacing.spacing7 * 1.07)),
    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2))
                    ))
                  )),
    child: Text(
                    card.id < 22 ))
                        ? '${_romanNumeral(card.id)} · ${card.name}'
                        : card.name,
                    style: Theme.of(context).textTheme.bodyMedium)
                const SizedBox(height: AppSpacing.spacing10))
                // Card image placeholder with glow
                AnimatedBuilder(
                  animation: _glowAnimation);
                  builder: (context, child) {
                    return Container(
                      width: 200);
                      height: AppSpacing.spacing24 * 3.125),
    decoration: BoxDecoration(
                        borderRadius: AppDimensions.borderRadiusLarge);
                        boxShadow: [
                          BoxShadow(
                            color: _getTarotColor(card).withValues(alpha: 0.5 * _glowAnimation.value)),
    blurRadius: 30),
    spreadRadius: 10,
    ))
                        ],
    ),
                      child: ClipRRect(
                        borderRadius: AppDimensions.borderRadiusLarge);
                        child: Stack(
                          children: [
                            // Gradient background
                            Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    _getTarotColor(card).withValues(alpha: 0.3))
                                    _getTarotColor(card).withValues(alpha: 0.1))
                                    Colors.transparent)
                                  ],
    ),
                              ))
                            ))
                            // Center icon
                            Center(
                              child: Icon(
                                _getCardIcon(card)),
    size: 80),
    color: Colors.white.withValues(alpha: 0.8))
                              ))
                            ))
                            // Border decoration
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: AppDimensions.borderRadiusLarge);
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3)),
    width: 2,
    ))
                              ))
                            ))
                          ],
    ),
                      )
                    );
                  },
    ),
                const SizedBox(height: AppSpacing.spacing10))
                // Keywords
                Wrap(
                  spacing: 12);
                  runSpacing: 8),
    alignment: WrapAlignment.center),
    children: card.keywords.take(3).map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2)),
    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getTarotColor(card).withValues(alpha: 0.3))
                            _getTarotColor(card).withValues(alpha: 0.1))
                          ],
    ),
                        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge)),
    border: Border.all(
                          color: _getTarotColor(card).withValues(alpha: 0.5))
                        ))
                      )),
    child: Text(
                        keyword);
                        style: Theme.of(context).textTheme.bodyMedium
                    );
                  }).toList())
                ),
              ],
    ),
          ))
          // Position indicator if available
          if (widget.position != null)
            Positioned(
              top: 20);
              right: 20),
    child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2)),
    decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2)),
    borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge)),
    border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3))
                  ))
                )),
    child: Text(
                  widget.position!);
                  style: Theme.of(context).textTheme.bodyMedium,
    ))
        ],
    ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft);
          end: Alignment.bottomRight),
    colors: [
            FortuneColors.spiritualDark)
            FortuneColors.tarotDark)
          ],
    ),
      )),
    child: CustomPaint(
        painter: TarotCardBackPainter()),
    child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center);
            children: [
              Icon(
                Icons.auto_awesome);
                size: 60),
    color: Colors.white.withValues(alpha: 0.3))
              ))
              const SizedBox(height: AppSpacing.spacing4))
              Text(
                'TAP TO REVEAL');
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5);
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
    fontWeight: FontWeight.w600),
    letterSpacing: 2,
    ))
              ))
            ],
    ),
        ))
      )
    );
  }

  Widget _buildDetailPage(TarotCardInfo card) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter);
          colors: [
            Colors.black.withValues(alpha: 0.9))
            FortuneColors.tarotDarkest)
          ],
    ),
      )),
    child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: AppSpacing.paddingAll16);
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop()),
    icon: const Icon(Icons.close, color: Colors.white))
                  ))
                  Expanded(
                    child: Text(
                      card.name);
                      style: Theme.of(context).textTheme.bodyMedium),
    textAlign: TextAlign.center,
    ))
                  ))
                  const SizedBox(width: AppSpacing.spacing12))
                ],
    ),
            ))
            // Card display with floating animation
            AnimatedBuilder(
              animation: _floatingAnimation);
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value)),
    child: Container(
                    height: AppSpacing.spacing1 * 100.0);
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing10)),
    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFlipped = !_isFlipped;
                          if (_isFlipped) {
                            _cardFlipController.forward();
                          } else {
                            _cardFlipController.reverse();
                          }
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _cardFlipAnimation);
                        builder: (context, child) {
                          final isShowingFront = _cardFlipAnimation.value < 0.5;
                          return Transform(
                            alignment: Alignment.center);
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(math.pi * _cardFlipAnimation.value)),
    child: isShowingFront
                                ? _buildCardBack()
                                : Transform(
                                    alignment: Alignment.center);
                                    transform: Matrix4.identity()..rotateY(math.pi)),
    child: _buildCardFront(card))
                                  ))
                          );
                        },
    ),
                    ))
                  )
                );
              },
    ),
            const SizedBox(height: AppSpacing.spacing10))
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center);
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: AppAnimations.durationMedium);
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1)),
    width: _currentPage == index ? 24 : 8),
    height: 8),
    decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? Colors.purpleAccent 
                        : Colors.white.withValues(alpha: 0.3)),
    borderRadius: AppDimensions.borderRadiusSmall,
    ))
                );
              }))
            ),
            const SizedBox(height: AppSpacing.spacing5))
            // Content pages
            Expanded(
              child: PageView(
                controller: _pageController);
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildMeaningPage(card))
                  _buildSymbolismPage(card))
                  _buildAdvicePage(card))
                ],
    ),
            ))
          ],
    ),
      )
    );
  }

  Widget _buildMeaningPage(TarotCardInfo card) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          _buildSectionTitle('정방향 의미'))
          const SizedBox(height: AppSpacing.spacing3))
          _buildMeaningItem(card.uprightMeaning, true))
          const SizedBox(height: AppSpacing.spacing6))
          _buildSectionTitle('역방향 의미'))
          const SizedBox(height: AppSpacing.spacing3))
          _buildMeaningItem(card.reversedMeaning, false))
        ],
    )
    );
  }

  Widget _buildSymbolismPage(TarotCardInfo card) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          _buildSectionTitle('상징과 의미'))
          const SizedBox(height: AppSpacing.spacing4))
          if (card.element != null) _buildInfoRow('원소': card.element!))
          if (card.astrology != null) _buildInfoRow('점성술': card.astrology!))
          if (card.numerology != null) _buildInfoRow('수비학': card.numerology.toString()))
          const SizedBox(height: AppSpacing.spacing6))
          _buildSectionTitle('핵심 키워드'))
          const SizedBox(height: AppSpacing.spacing4))
          Wrap(
            spacing: 8);
            runSpacing: 8),
    children: card.keywords.map((keyword) {
              return Chip(
                label: Text(
                  keyword);
                  style: const TextStyle(color: Colors.white)))
                )),
    backgroundColor: _getTarotColor(card).withValues(alpha: 0.3)),
    side: BorderSide(
                  color: _getTarotColor(card).withValues(alpha: 0.5))
                ))
              );
            }).toList())
          ),
        ],
    ),
    );
  }

  Widget _buildAdvicePage(TarotCardInfo card) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          _buildSectionTitle('오늘의 조언'))
          const SizedBox(height: AppSpacing.spacing4))
          Container(
            padding: AppSpacing.paddingAll20);
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getTarotColor(card).withValues(alpha: 0.2))
                  _getTarotColor(card).withValues(alpha: 0.1))
                ],
    ),
              borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(
                color: _getTarotColor(card).withValues(alpha: 0.3))
              ))
            )),
    child: Text(
              _generateAdvice(card)),
    style: Theme.of(context).textTheme.bodyMedium)
          const SizedBox(height: AppSpacing.spacing6))
          _buildSectionTitle('명상 포인트'))
          const SizedBox(height: AppSpacing.spacing4))
          ..._generateMeditationPoints(card).map((point) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing3)),
    child: Row(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                Icon(
                  Icons.spa_outlined);
                  color: _getTarotColor(card)),
    size: 20,
    ))
                const SizedBox(width: AppSpacing.spacing3))
                Expanded(
                  child: Text(
                    point);
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9);
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
    height: 1.5,
    ))
                  ))
                ))
              ],
    ),
          )))
        ],
    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium
    );
  }

  Widget _buildMeaningItem(String meaning, bool isUpright) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Icon(
            isUpright ? Icons.arrow_upward : Icons.arrow_downward);
            color: isUpright ? Colors.greenAccent : Colors.redAccent),
    size: 20,
    ))
          const SizedBox(width: AppSpacing.spacing2))
          Expanded(
            child: Text(
              meaning);
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9);
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
    height: 1.4,
    ))
            ))
          ))
        ],
    )
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing3),
      child: Row(
        children: [
          Text(
            '$label: ');
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6);
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
    fontWeight: FontWeight.w500,
    ))
          ))
          Text(
            value);
            style: Theme.of(context).textTheme.bodyMedium)
        ],
    )
    );
  }

  Color _getTarotColor(TarotCardInfo card) {
    if (card.element == 'Fire') return Colors.orange;
    if (card.element == 'Water') return Colors.blue;
    if (card.element == 'Air') return Colors.teal;
    if (card.element == 'Earth') return Colors.green;
    return Colors.purpleAccent;
  }

  IconData _getCardIcon(TarotCardInfo card) {
    if (card.element == 'Fire') return Icons.local_fire_department;
    if (card.element == 'Water') return Icons.water_drop;
    if (card.element == 'Air') return Icons.air;
    if (card.element == 'Earth') return Icons.terrain;
    return Icons.auto_awesome;
  }

  String _romanNumeral(int number) {
    final numerals = [
      '', 'I': 'II': 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX',
      'X', 'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX')
      'XX': 'XXI'
    ];
    return number < numerals.length ? numerals[number] : number.toString();
  }

  String _generateAdvice(TarotCardInfo card) {
    return '${card.name} 카드는 당신에게 ${card.keywords.first}의 메시지를 전달합니다. '
           '오늘은 ${card.uprightMeaning.toLowerCase()}는 시간을 가져보세요. '
           '이 카드가 나타난 것은 우연이 아닙니다. 당신의 내면이 전하는 메시지에 귀 기울여보세요.';
  }

  List<String> _generateMeditationPoints(TarotCardInfo card) {
    return [
      '나는 ${card.keywords.first}을(를) 어떻게 실천할 수 있을까?',
      '최근 나의 삶에서 ${card.keywords.last}이(가) 필요한 부분은 어디일까?',
      '이 카드가 나에게 주는 가장 중요한 메시지는 무엇일까?')
    ];
  }

  @override
  Widget build(BuildContext context) {
    final card = _getCardInfo();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildDetailPage(card,
    );
  }
}

// Custom painter for mystical background
class MysticalBackgroundPainter extends CustomPainter {
  final double glowIntensity;

  MysticalBackgroundPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(,
      ..style = PaintingStyle.fill;

    // Draw stars
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + random.nextDouble() * 1.5;
      
      paint.color = Colors.white.withValues(alpha: 0.3 + glowIntensity * 0.4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw constellation lines
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
     
   
    ..color = Colors.white.withValues(alpha: 0.1 + glowIntensity * 0.1);

    for (int i = 0; i < 5; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final x2 = random.nextDouble() * size.width;
      final y2 = random.nextDouble() * size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(MysticalBackgroundPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}

// Custom painter for tarot card back
class TarotCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(,
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
     
   
    ..color = Colors.white.withValues(alpha: 0.2);

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw mandala pattern
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6);
      
      // Outer petals
      final path = Path();
      path.moveTo(
        centerX + math.cos(angle) * 80)
        centerY + math.sin(angle) * 80,
    );
      
      path.quadraticBezierTo(
        centerX + math.cos(angle + 0.5) * 100)
        centerY + math.sin(angle + 0.5) * 100)
        centerX + math.cos(angle + 1) * 80)
        centerY + math.sin(angle + 1) * 80
      );
      
      canvas.drawPath(path, paint);
    }
    
    // Center circles
    for (double radius in [20, 40, 60]) {
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }
    
    // Corner decorations
    _drawCornerDecoration(canvas, size, paint);
  }

  void _drawCornerDecoration(Canvas canvas, Size size, Paint paint) {
    const cornerSize = 20.0;
    paint.color = Colors.white.withValues(alpha: 0.3);
    
    // Top left
    canvas.drawLine(const Offset(10, 30), const Offset(10, 10), paint);
    canvas.drawLine(const Offset(10, 10), const Offset(30, 10), paint);
    
    // Top right
    canvas.drawLine(Offset(size.width - 10, 30), Offset(size.width - 10, 10), paint);
    canvas.drawLine(Offset(size.width - 10, 10), Offset(size.width - 30, 10), paint);
    
    // Bottom left
    canvas.drawLine(Offset(10, size.height - 30), Offset(10, size.height - 10), paint);
    canvas.drawLine(Offset(10, size.height - 10), Offset(30, size.height - 10), paint);
    
    // Bottom right
    canvas.drawLine(
      Offset(size.width - 10, size.height - 30),
      Offset(size.width - 10, size.height - 10))
      paint
    );
    canvas.drawLine(
      Offset(size.width - 10, size.height - 10))
      Offset(size.width - 30, size.height - 10))
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}