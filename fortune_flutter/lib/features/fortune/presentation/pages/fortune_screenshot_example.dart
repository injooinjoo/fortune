import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mixins/screenshot_detection_mixin.dart';
import '../../../../shared/components/app_header.dart';

/// Example page demonstrating screenshot detection and sharing
class FortuneScreenshotExamplePage extends ConsumerStatefulWidget {
  const FortuneScreenshotExamplePage({super.key});

  @override
  ConsumerState<FortuneScreenshotExamplePage> createState() => _FortuneScreenshotExamplePageState();
}

class _FortuneScreenshotExamplePageState extends ConsumerState<FortuneScreenshotExamplePage>
    with ScreenshotDetectionMixin {
  final GlobalKey _fortuneKey = GlobalKey();

  @override
  GlobalKey get screenshotKey => _fortuneKey;

  @override
  String get fortuneType => 'daily';

  @override
  String get fortuneTitle => '오늘의 운세';

  @override
  String get fortuneContent => 
      '오늘은 당신에게 행운이 가득한 날입니다. 새로운 기회가 찾아올 것이며, '
      '긍정적인 마음가짐으로 하루를 시작한다면 더욱 좋은 결과를 얻을 수 있을 것입니다. '
      '특히 오후 시간대에는 중요한 결정을 내리기에 좋은 시기입니다.';

  @override
  String? get userName => '홍길동';

  @override
  Map<String, dynamic>? get additionalInfo => {
    '행운의 숫자': '7',
    '행운의 색': '보라색',
    '행운 지수': '85%',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppHeader(
        title: '스크린샷 공유 예제',
        actions: [
          buildShareButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '스크린샷을 찍으면 자동으로 공유 옵션이 표시됩니다!',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Fortune Card
            RepaintBoundary(
              key: _fortuneKey,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.8),
                      theme.primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fortuneTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Content
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            fortuneContent,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (additionalInfo != null) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 20),
                            Row(
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date
                    Text(
                      '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Share Button
            ElevatedButton.icon(
              onPressed: shareEnhancedFortune,
              icon: const Icon(Icons.share),
              label: const Text('운세 공유하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}