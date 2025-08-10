// 새로운 스토리 중심 홈 화면
// 기존 HomeScreen을 StoryHomeScreen으로 완전 대체

export 'story_home_screen.dart' show StoryHomeScreen;

import 'story_home_screen.dart';

// HomeScreen은 이제 StoryHomeScreen의 별칭
class HomeScreen extends StoryHomeScreen {
  const HomeScreen({super.key});
}