import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/screenshot_detection_service.dart';
import '../../../../services/native_platform_service.dart';
import '../../../../core/utils/logger.dart';

/// Mixin to add screenshot detection functionality to fortune pages
mixin ScreenshotDetectionMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  StreamSubscription<dynamic>? _screenshotSubscription;
  late ScreenshotDetectionService _screenshotService;
  
  /// The global key for capturing the widget as image
  GlobalKey get screenshotKey;
  
  /// The fortune type (e.g., 'daily', 'love', 'career')
  String get fortuneType;
  
  /// The title of the current fortune
  String get fortuneTitle;
  
  /// The content of the current fortune
  String get fortuneContent;
  
  /// Optional user name for personalized sharing
  String? get userName => null;
  
  /// Optional additional info to display (e.g., lucky numbers, colors)
  Map<String, dynamic>? get additionalInfo => null;
  
  @override
  void initState() {
    super.initState();
    _screenshotService = ref.read(screenshotDetectionServiceProvider);
    _initializeScreenshotDetection();
  }
  
  @override
  void dispose() {
    _screenshotSubscription?.cancel();
    super.dispose();
  }
  
  void _initializeScreenshotDetection() {
    // Listen for screenshot events
    _screenshotSubscription = NativePlatformService.nativeEventStream.listen((event) {
      if (event is Map && event['type'] == 'screenshot_detected') {
        _onScreenshotDetected();
      }
    });
  }
  
  void _onScreenshotDetected() {
    Logger.info('Screenshot detected on fortune page');
    
    // Show enhanced sharing bottom sheet
    if (mounted) {
      _screenshotService.showScreenshotSharingDialog(
        context: context,
        fortuneType: fortuneType,
        fortuneTitle: fortuneTitle,
        fortuneContent: fortuneContent,
        userName: userName,
        additionalInfo: additionalInfo,
      );
    }
  }
  
  /// Share the fortune with enhanced styling
  Future<void> shareEnhancedFortune() async {
    await _screenshotService.showScreenshotSharingDialog(
      context: context,
      fortuneType: fortuneType,
      fortuneTitle: fortuneTitle,
      fortuneContent: fortuneContent,
      userName: userName,
      additionalInfo: additionalInfo,
    );
  }
  
  /// Build a share button widget
  Widget buildShareButton() {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: shareEnhancedFortune,
      tooltip: '공유하기',
    );
  }
  
  /// Build a save button widget with menu
  Widget buildShareMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'share') {
          await shareEnhancedFortune();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_outlined, size: 20),
              SizedBox(width: 12),
              Text('공유하기'),
            ],
          ),
        ),
      ],
    );
  }
}