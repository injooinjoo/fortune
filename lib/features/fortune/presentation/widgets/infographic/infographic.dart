// 인포그래픽 위젯 모듈
//
// 운세 결과 페이지에서 사용하는 인포그래픽 위젯들을 제공합니다.
// 인스타그램 최적화된 4:5 비율로 설계되었습니다.
//
// 사용 예시:
// ```dart
// import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic.dart';
//
// // 팩토리를 통한 인포그래픽 생성
// final widget = InfographicFactory.buildInfographic(
//   fortuneType: FortuneType.daily,
//   data: fortuneResult,
//   isShareMode: false,
// );
//
// // 직접 템플릿 사용
// DailyScoreTemplate(
//   score: 85,
//   date: '2025.01.08',
//   categories: [...],
//   luckyItems: [...],
// );
// ```
library;

// 팩토리
export 'infographic_factory.dart';

// 공통 컴포넌트
export 'infographic_container.dart';
export 'score_circle.dart';
export 'category_bar_chart.dart';
export 'lucky_item_row.dart';
export 'versus_bar.dart';
export 'keyword_tags.dart';
export 'app_watermark.dart';
export 'privacy_shield.dart';

// 템플릿
export 'templates/score_template.dart';
export 'templates/chart_template.dart';
export 'templates/image_template.dart';
export 'templates/grid_template.dart';
