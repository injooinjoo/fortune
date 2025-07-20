import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/fortune_card_images.dart';
import '../../core/constants/fortune_type_names.dart';
// import 'package:qr_flutter/qr_flutter.dart'; // TODO: Add qr_flutter package

class EnhancedShareableFortuneCard extends StatelessWidget {
  final String fortuneType;
  final String title;
  final String content;
  final String? userName;
  final DateTime? date;
  final Map<String, dynamic>? additionalInfo;
  final ShareCardTemplate template;

  const EnhancedShareableFortuneCard({
    super.key,
    required this.fortuneType,
    required this.title,
    required this.content,
    this.userName,
    this.date,
    this.additionalInfo,
    this.template = ShareCardTemplate.modern,
  });

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case ShareCardTemplate.modern:
        return _buildModernTemplate();
      case ShareCardTemplate.traditional:
        return _buildTraditionalTemplate();
      case ShareCardTemplate.minimal:
        return _buildMinimalTemplate();
      case ShareCardTemplate.instagram:
        return _buildInstagramTemplate();
    }
  }

  Widget _buildModernTemplate() {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        gradient: _getGradientForFortuneType(fortuneType),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFortuneContent(),
                const SizedBox(height: 24),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalTemplate() {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Traditional Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF8D6E63),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Center(
              child: Text(
                '⊹ 오늘의 운세 ⊹',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (userName != null) ...[
                  Text(
                    userName!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBCAAA4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTraditionalFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTemplate() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fortune Type Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getColorForFortuneType(fortuneType).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForFortuneType(fortuneType),
              color: _getColorForFortuneType(fortuneType),
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
          ),
          if (userName != null) ...[
            const SizedBox(height: 8),
            Text(
              userName!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Minimal Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fortune AI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    date != null 
                        ? '${date!.year}.${date!.month}.${date!.day}'
                        : 'AI가 알려주는 나만의 운세',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramTemplate() {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: _getInstagramGradient(),
        ),
        child: Stack(
          children: [
            // Background Effects
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Spacer(),
                    // Main Content Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fortune Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: _getGradientForFortuneType(fortuneType),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForFortuneType(fortuneType),
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (userName != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '@$userName',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Instagram Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Fortune AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForFortuneType(fortuneType),
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FortuneTypeNames.getName(fortuneType),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (userName != null) ...[
            Text(
              userName!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getColorForFortuneType(fortuneType),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (additionalInfo != null) ...[
            const SizedBox(height: 16),
            _buildAdditionalInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getColorForFortuneType(fortuneType).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: additionalInfo!.entries.map((entry) {
          return Column(
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getColorForFortuneType(fortuneType),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.qr_code_2,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fortune AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI가 알려주는 나만의 운세',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (date != null)
          Text(
            '${date!.year}.${date!.month.toString().padLeft(2, '0')}.${date!.day.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildTraditionalFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 1,
              color: const Color(0xFFBCAAA4),
            ),
            const SizedBox(width: 12),
            Text(
              '福',
              style: TextStyle(
                fontSize: 24,
                color: const Color(0xFF8D6E63),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 30,
              height: 1,
              color: const Color(0xFFBCAAA4),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Fortune AI · 행운이 가득하길',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF8D6E63),
          ),
        ),
      ],
    );
  }

  LinearGradient _getGradientForFortuneType(String type) {
    final baseColor = _getColorForFortuneType(type);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.9),
        baseColor,
        baseColor.withValues(alpha: 0.8),
      ],
    );
  }

  LinearGradient _getInstagramGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF833AB4),
        Color(0xFFF56040),
        Color(0xFFFCAF45),
      ],
    );
  }

  Color _getColorForFortuneType(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return Colors.purple;
      case 'love':
      case 'compatibility':
        return Colors.pink;
      case 'money':
      case 'wealth':
        return Colors.green;
      case 'career':
      case 'business':
        return Colors.blue;
      case 'health':
        return Colors.orange;
      case 'zodiac':
        return Colors.indigo;
      default:
        return Colors.purple;
    }
  }

  IconData _getIconForFortuneType(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return Icons.today;
      case 'love':
      case 'compatibility':
        return Icons.favorite;
      case 'money':
      case 'wealth':
        return Icons.attach_money;
      case 'career':
      case 'business':
        return Icons.work;
      case 'health':
        return Icons.favorite_border;
      case 'zodiac':
        return Icons.stars;
      default:
        return Icons.auto_awesome;
    }
  }
}

enum ShareCardTemplate {
  modern,
  traditional,
  minimal,
  instagram,
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (var i = 0; i < size.width; i += spacing.toInt()) {
      for (var j = 0; j < size.height; j += spacing.toInt()) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          4,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}