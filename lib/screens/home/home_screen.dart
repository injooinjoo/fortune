// 홈 화면은 기본적으로 StoryHomeScreen을 사용
// StoryHomeScreen이 내부적으로 스토리/Tinder 페이지를 선택
export 'story_home_screen.dart' show StoryHomeScreen;

import 'story_home_screen.dart';

class HomeScreen extends StoryHomeScreen {
  const HomeScreen({super.key});
}