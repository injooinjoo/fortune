import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 신의 응답을 표시하는 영적이고 신비로운 위젯
class DivineResponseWidget extends StatefulWidget {
  final String wishText;
  final String category;
  final int urgency;
  final String divineResponse;
  
  const DivineResponseWidget({
    super.key,
    required this.wishText,
    required this.category,
    required this.urgency,
    required this.divineResponse,
  });

  @override
  State<DivineResponseWidget> createState() => _DivineResponseWidgetState();
}

class _DivineResponseWidgetState extends State<DivineResponseWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 신비로운 헤더
            _buildMysticalHeader(),
            const SizedBox(height: 32),
            
            // 소원 요약
            _buildWishSummary(),
            const SizedBox(height: 32),
            
            // 신의 응답
            _buildDivineResponse(),
            const SizedBox(height: 32),
            
            // 행운의 메시지
            _buildLuckyMessage(),
            const SizedBox(height: 40),
            
            // 공유하기 버튼
            _buildShareButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMysticalHeader() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Column(
            children: [
              // 신비로운 심볼들이 떠다니는 효과
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 중앙 빛나는 원
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  TossDesignSystem.white.withValues(alpha:0.8),
                                  TossDesignSystem.white.withValues(alpha:0.1),
                                  TossDesignSystem.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // 중앙 아이콘
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: TossDesignSystem.white,
                        boxShadow: [
                          BoxShadow(
                            color: TossDesignSystem.white.withValues(alpha: 0.54),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 32,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    
                    // 주변 떠다니는 별들
                    ...List.generate(8, (index) {
                      final angle = (index * math.pi * 2) / 8;
                      final radius = 50.0;
                      return Positioned(
                        left: math.cos(angle) * radius + 50,
                        top: math.sin(angle) * radius + 50,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _shimmerAnimation.value + angle,
                              child: Icon(
                                Icons.star,
                                size: 12 + (index % 3) * 4,
                                color: TossDesignSystem.white.withValues(alpha:0.7),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 신비로운 제목
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    TossDesignSystem.white,
                    Color(0xFFFFD700),
                    TossDesignSystem.white,
                  ],
                ).createShader(bounds),
                child: const Text(
                  '✨ 신의 응답 ✨',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '당신의 간절한 소원이 하늘에 닿았습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: TossDesignSystem.white.withValues(alpha:0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TossDesignSystem.white.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: TossDesignSystem.white.withValues(alpha:0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '당신의 소원',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TossDesignSystem.white.withValues(alpha:0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            widget.wishText,
            style: const TextStyle(
              fontSize: 16,
              color: TossDesignSystem.white,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildWishTag('분야', _getCategoryName(widget.category)),
              const SizedBox(width: 12),
              _buildWishTag('간절함', _getUrgencyText(widget.urgency)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWishTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TossDesignSystem.white.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: TossDesignSystem.white.withValues(alpha:0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: TossDesignSystem.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivineResponse() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TossDesignSystem.white.withValues(alpha:0.15),
                TossDesignSystem.white.withValues(alpha:0.05),
              ],
            ),
            border: Border.all(
              color: TossDesignSystem.white.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Shimmer effect
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(_shimmerAnimation.value * 200, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            TossDesignSystem.white.withValues(alpha: 0.0),
                            TossDesignSystem.white.withValues(alpha:0.1),
                            TossDesignSystem.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  TossDesignSystem.white.withValues(alpha:0.9),
                                  TossDesignSystem.white.withValues(alpha:0.3),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.psychology_alt,
                              color: Color(0xFF1A1A2E),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '신이 전하는 메시지',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: TossDesignSystem.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        widget.divineResponse,
                        style: const TextStyle(
                          fontSize: 16,
                          color: TossDesignSystem.white,
                          height: 1.8,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuckyMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withValues(alpha:0.2),
            const Color(0xFFFFA500).withValues(alpha:0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.stars,
                color: const Color(0xFFFFD700),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '행운의 메시지',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _getLuckyMessage(),
            style: const TextStyle(
              fontSize: 14,
              color: TossDesignSystem.white,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: TossButton(
        text: '신의 응답 공유하기',
        onPressed: () {
          // TODO: 공유 기능 구현
        },
        style: TossButtonStyle.primary,
        size: TossButtonSize.large,
        icon: Icon(Icons.share),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case '사랑': return '💕 사랑';
      case '돈': return '💰 재물';
      case '건강': return '🌿 건강';
      case '성공': return '🏆 성공';
      case '가족': return '👨‍👩‍👧‍👦 가족';
      case '학업': return '📚 학업';
      case '기타': return '🌟 기타';
      default: return category;
    }
  }

  String _getUrgencyText(int urgency) {
    switch (urgency) {
      case 1: return '⭐ 조금';
      case 2: return '⭐⭐ 그럭저럭';
      case 3: return '⭐⭐⭐ 꽤 간절';
      case 4: return '⭐⭐⭐⭐ 정말 간절';
      case 5: return '⭐⭐⭐⭐⭐ 온 마음을 다해';
      default: return '';
    }
  }

  String _getLuckyMessage() {
    final messages = [
      '당신의 소원은 이미 우주의 기운을 움직이기 시작했습니다. 믿음을 가지고 기다리세요.',
      '신은 당신의 진심을 보고 계십니다. 포기하지 마시고 꾸준히 노력하세요.',
      '이 소원이 이루어질 때까지 긍정적인 마음을 유지하세요. 기적은 믿는 자에게 찾아옵니다.',
      '하늘이 당신의 편입니다. 소원 성취의 날이 곧 다가올 것입니다.',
      '당신의 소원에는 특별한 힘이 담겨 있습니다. 계속 노력하면 반드시 이루어질 것입니다.',
    ];
    
    final index = (widget.wishText.length + widget.urgency) % messages.length;
    return messages[index];
  }
}