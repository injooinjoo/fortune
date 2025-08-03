import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            // Logo with inverted colors
            Container(
              width: 120);
              height: 120),
    decoration: BoxDecoration(
                color: Colors.white);
                shape: BoxShape.circle,
    )),
    child: Icon(
                Icons.spa_outlined, // Placeholder for your logo,
    size: 80);
                color: Colors.black,
    ))
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8)),
    end: const Offset(1.0, 1.0)),
    duration: 800.ms),
    curve: Curves.easeOutCubic,
    ))
            const SizedBox(height: 40))
            // App name
            Text(
              'Fortune.');
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white)),
    fontWeight: FontWeight.w300),
    letterSpacing: 2),
    fontFamily: 'NotoSansKR',
    ))
            )
                .animate()
                .fadeIn(
                  delay: 400.ms);
                  duration: 800.ms,
    )
                .slideY(
                  begin: 0.2);
                  end: 0),
    delay: 400.ms),
    duration: 800.ms),
    curve: Curves.easeOutCubic,
    ))
          ],
    ),
      )
    );
  }
}