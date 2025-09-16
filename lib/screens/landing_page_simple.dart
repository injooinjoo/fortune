import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LandingPageSimple extends ConsumerStatefulWidget {
  const LandingPageSimple({super.key});

  @override
  ConsumerState<LandingPageSimple> createState() => _LandingPageSimpleState();
}

class _LandingPageSimpleState extends ConsumerState<LandingPageSimple> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    print('🔵 Simple LandingPage initState');
    // 3초 후 자동으로 auth check 완료
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building Simple LandingPage: _isCheckingAuth=$_isCheckingAuth');

    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.purple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Fortune',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '매일 새로운 운세를 만나보세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  print('시작하기 버튼 클릭됨');
                  context.go('/onboarding');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}