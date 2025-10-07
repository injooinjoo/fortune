import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'story_home_screen.dart';
import 'fortune_completion_page_tinder.dart';
import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../presentation/providers/fortune_provider.dart';

/// 홈 화면 - 스토리를 이미 본 경우와 처음 보는 경우를 구분
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final supabase = Supabase.instance.client;
  bool _hasViewedStoryToday = false;
  bool _isCheckingViewStatus = true;

  @override
  void initState() {
    super.initState();
    _checkViewedStatus();
  }

  Future<void> _checkViewedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final lastViewedDate = prefs.getString('last_fortune_viewed_date');

      if (mounted) {
        setState(() {
          _hasViewedStoryToday = lastViewedDate == todayKey;
          _isCheckingViewStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking viewed status: $e');
      if (mounted) {
        setState(() {
          _isCheckingViewStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 체크 중일 때는 로딩 표시
    if (_isCheckingViewStatus) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 이미 스토리를 본 경우 바로 Tinder 완료 페이지 표시
    if (_hasViewedStoryToday) {
      debugPrint('🎯 Already viewed story today - showing FortuneCompletionPageTinder');

      // 운세 데이터 가져오기
      final fortuneState = ref.watch(fortuneProvider);

      return fortuneState.when(
        data: (fortune) {
          if (fortune != null) {
            return FortuneCompletionPageTinder(
              fortune: fortune,
              userName: null, // UserProfile은 StoryHomeScreen에서 처리
              userProfile: null,
              overall: null,
              categories: null,
              sajuInsight: null,
            );
          }
          // 운세 데이터가 없으면 StoryHomeScreen으로
          return const StoryHomeScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const StoryHomeScreen(),
      );
    }

    // 처음 보는 경우 StoryHomeScreen 표시
    debugPrint('🎬 First time viewing - showing StoryHomeScreen');
    return const StoryHomeScreen();
  }
}