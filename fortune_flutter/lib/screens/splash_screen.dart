import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/shared/components/fortune_loading_indicator.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session != null) {
      context.go('/home');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 배경 그라데이션 효과
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.purple.withOpacity(0.15),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // 반짝이는 별 효과
          ...List.generate(30, (index) {
            final random = math.Random(index);
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, delay: (index * 100).ms)
                .fadeIn(duration: 1000.ms),
            );
          }),
          
          // 메인 컨텐츠
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 컨테이너 with glow effect
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 회전하는 광환 효과
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.purple.withOpacity(0.0),
                                Colors.purple.withOpacity(0.3),
                                Colors.blue.withOpacity(0.3),
                                Colors.purple.withOpacity(0.0),
                              ],
                            ),
                          ),
                        )
                          .animate(onPlay: (controller) => controller.repeat())
                          .rotate(duration: 3000.ms),
                        
                        // Center logo
                        SvgPicture.asset(
                          'assets/images/main_logo.svg',
                          width: 100,
                          height: 100,
                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 1200.ms)
                    .scale(
                      begin: Offset(0.5, 0.5),
                      end: Offset(1.0, 1.0),
                      duration: 1000.ms,
                      curve: Curves.easeOutBack,
                    ),
                  
                  const SizedBox(height: 50),
                  
                  // Fortune. text with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.purple.shade200,
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Fortune.',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 3,
                        fontFamily: 'NotoSansKR',
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 800.ms, duration: 1000.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 800.ms,
                      duration: 1000.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .shimmer(delay: 1800.ms, duration: 1500.ms),
                  
                  const SizedBox(height: 20),
                  
                  // Tagline
                  Text(
                    '당신의 운명을 밝혀드립니다',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1,
                      fontFamily: 'NotoSansKR',
                    ),
                  ).animate()
                    .fadeIn(delay: 1200.ms, duration: 800.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: 1200.ms,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
                ],
              ),
            ),
          ),
          
          // 하단 로딩 인디케이터
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: FortuneLoadingIndicator(
                  size: 30,
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ).animate()
              .fadeIn(delay: 1500.ms, duration: 600.ms)
              .scale(
                delay: 1500.ms,
                duration: 600.ms,
                begin: Offset(0.8, 0.8),
                end: Offset(1.0, 1.0),
              ),
          ),
        ],
      ),
    );
  }
}