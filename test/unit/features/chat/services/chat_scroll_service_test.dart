import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/features/chat/services/chat_scroll_service.dart';

void main() {
  group('ChatScrollService', () {
    testWidgets(
      'scrollToBottomInstant keeps following late layout growth',
      (tester) async {
        final key = GlobalKey<_TestChatScrollHarnessState>();

        await tester.pumpWidget(_TestChatScrollHarness(key: key));

        key.currentState!.scrollToBottomInstant();

        await tester.pump(const Duration(milliseconds: 220));
        key.currentState!.expandLastMessage();
        await tester.pump();
        await _pumpScrollFrames(tester, frameCount: 8);

        expect(
          key.currentState!.controller.offset,
          closeTo(
            key.currentState!.controller.position.maxScrollExtent,
            ChatScrollConstants.bottomTolerance,
          ),
        );
      },
    );

    testWidgets(
      'scrollToBottom re-settles after extent increases during animation',
      (tester) async {
        final key = GlobalKey<_TestChatScrollHarnessState>();

        await tester.pumpWidget(_TestChatScrollHarness(key: key));

        key.currentState!.scrollToBottom();

        await tester.pump(const Duration(milliseconds: 220));
        key.currentState!.expandLastMessage();
        await tester.pump();
        await _pumpScrollFrames(tester, frameCount: 12);

        expect(
          key.currentState!.controller.offset,
          closeTo(
            key.currentState!.controller.position.maxScrollExtent,
            ChatScrollConstants.bottomTolerance,
          ),
        );
      },
    );

    testWidgets(
      'scrollToMessageTop keeps the anchor near top after content above grows',
      (tester) async {
        final key = GlobalKey<_TestAnchorScrollHarnessState>();

        await tester.pumpWidget(_TestAnchorScrollHarness(key: key));

        key.currentState!.scrollAnchorToTop();

        await tester.pump(const Duration(milliseconds: 220));
        key.currentState!.expandHeader();
        await tester.pump();
        await _pumpScrollFrames(tester, frameCount: 16);

        final listTop =
            tester.getTopLeft(find.byType(SingleChildScrollView)).dy;
        final anchorRenderBox = key.currentState!.anchorKey.currentContext!
            .findRenderObject() as RenderBox;
        final anchorTop = anchorRenderBox.localToGlobal(Offset.zero).dy;

        expect(anchorTop - listTop, closeTo(320 * 0.14, 24));
      },
    );

    testWidgets(
      'preserveViewportAfterPrepend keeps the current message in place',
      (tester) async {
        final key = GlobalKey<_TestPrependViewportHarnessState>();

        await tester.pumpWidget(_TestPrependViewportHarness(key: key));

        key.currentState!.jumpToOffset(260);
        await tester.pump();

        const markerKey = ValueKey('message-5');
        final beforeTop = tester.getTopLeft(find.byKey(markerKey)).dy;

        final future = key.currentState!.prependHistoryKeepingViewport();
        await tester.pump();
        await _pumpScrollFrames(tester, frameCount: 10);
        await future;

        final afterTop = tester.getTopLeft(find.byKey(markerKey)).dy;

        expect(afterTop, closeTo(beforeTop, 12));
        expect(key.currentState!.controller.offset, greaterThan(260));
      },
    );

    testWidgets(
      'manual upward scroll cancels session-start auto follow so content above stays reachable',
      (tester) async {
        final key = GlobalKey<_TestSessionStartAutoFollowHarnessState>();

        await tester.pumpWidget(_TestSessionStartAutoFollowHarness(key: key));

        key.currentState!.beginSessionStartAnchor();
        await _pumpScrollFrames(tester, frameCount: 12);

        final anchoredOffset = key.currentState!.controller.offset;
        expect(anchoredOffset, greaterThan(0));

        key.currentState!.simulateUserScrollUp();
        await tester.pump();

        final userScrolledOffset = key.currentState!.controller.offset;
        expect(userScrolledOffset, lessThan(anchoredOffset - 40));
        expect(key.currentState!.isAutoScrollPausedByUser, isTrue);

        key.currentState!.addFollowUpAndTriggerAutoScroll();
        await tester.pump();
        await _pumpScrollFrames(tester, frameCount: 12);

        expect(
          key.currentState!.controller.offset,
          closeTo(userScrolledOffset, 12),
        );
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('session-header'))).dy,
          lessThan(110),
        );
      },
    );
  });
}

Future<void> _pumpScrollFrames(
  WidgetTester tester, {
  required int frameCount,
}) async {
  for (var index = 0; index < frameCount; index++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

class _TestChatScrollHarness extends StatefulWidget {
  const _TestChatScrollHarness({super.key});

  @override
  State<_TestChatScrollHarness> createState() => _TestChatScrollHarnessState();
}

class _TestChatScrollHarnessState extends State<_TestChatScrollHarness> {
  final ScrollController controller = ScrollController();
  late final ChatScrollService service = ChatScrollService(
    scrollController: controller,
    isMounted: () => mounted,
  );

  bool _expandedLastMessage = false;

  @override
  void dispose() {
    service.dispose();
    controller.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    service.scrollToBottom();
  }

  void scrollToBottomInstant() {
    service.scrollToBottomInstant();
  }

  void expandLastMessage() {
    setState(() {
      _expandedLastMessage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 320,
            child: ListView.builder(
              controller: controller,
              itemCount: 25,
              itemBuilder: (context, index) {
                final isLastItem = index == 24;
                return Container(
                  height: isLastItem ? (_expandedLastMessage ? 260 : 56) : 72,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.grey.shade300,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TestAnchorScrollHarness extends StatefulWidget {
  const _TestAnchorScrollHarness({super.key});

  @override
  State<_TestAnchorScrollHarness> createState() =>
      _TestAnchorScrollHarnessState();
}

class _TestAnchorScrollHarnessState extends State<_TestAnchorScrollHarness> {
  final ScrollController controller = ScrollController();
  final GlobalKey anchorKey = GlobalKey();
  late final ChatScrollService service = ChatScrollService(
    scrollController: controller,
    isMounted: () => mounted,
  );

  bool _expandedHeader = false;

  @override
  void dispose() {
    service.dispose();
    controller.dispose();
    super.dispose();
  }

  void scrollAnchorToTop() {
    final context = anchorKey.currentContext;
    if (context != null) {
      service.scrollToMessageTop(messageContext: context);
    }
  }

  void expandHeader() {
    setState(() {
      _expandedHeader = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 320,
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: List.generate(20, (index) {
                  if (index == 0) {
                    return Container(
                      height: _expandedHeader ? 240 : 64,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: Colors.blueGrey.shade100,
                    );
                  }

                  final isAnchor = index == 8;
                  return Container(
                    key: isAnchor ? anchorKey : null,
                    height: 72,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: isAnchor
                        ? Colors.orange.shade200
                        : Colors.grey.shade300,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestPrependViewportHarness extends StatefulWidget {
  const _TestPrependViewportHarness({super.key});

  @override
  State<_TestPrependViewportHarness> createState() =>
      _TestPrependViewportHarnessState();
}

class _TestPrependViewportHarnessState
    extends State<_TestPrependViewportHarness> {
  final ScrollController controller = ScrollController();
  late final ChatScrollService service = ChatScrollService(
    scrollController: controller,
    isMounted: () => mounted,
  );

  int _prependedBatchCount = 0;

  @override
  void dispose() {
    service.dispose();
    controller.dispose();
    super.dispose();
  }

  void jumpToOffset(double offset) {
    controller.jumpTo(offset);
  }

  Future<void> prependHistoryKeepingViewport() {
    return service.preserveViewportAfterPrepend(() async {
      setState(() {
        _prependedBatchCount = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final prependedMessages =
        List.generate(4 * _prependedBatchCount, (index) => -(index + 1));
    final messageIds = <int>[
      ...prependedMessages,
      ...List.generate(20, (index) => index),
    ];

    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 320,
            child: ListView.builder(
              controller: controller,
              itemCount: messageIds.length,
              itemBuilder: (context, index) {
                final messageId = messageIds[index];
                return Container(
                  key: ValueKey('message-$messageId'),
                  height: 72,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: messageId < 0
                      ? Colors.blueGrey.shade100
                      : Colors.grey.shade300,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TestSessionStartAutoFollowHarness extends StatefulWidget {
  const _TestSessionStartAutoFollowHarness({super.key});

  @override
  State<_TestSessionStartAutoFollowHarness> createState() =>
      _TestSessionStartAutoFollowHarnessState();
}

class _TestSessionStartAutoFollowHarnessState
    extends State<_TestSessionStartAutoFollowHarness> {
  static const int _baseItemCount = 18;

  final ScrollController controller = ScrollController();
  final GlobalKey anchorKey = GlobalKey();
  late final ChatScrollService service = ChatScrollService(
    scrollController: controller,
    isMounted: () => mounted,
  );

  bool _anchorActive = false;
  bool _autoScrollPausedByUser = false;
  bool _showFollowUp = false;

  bool get isAutoScrollPausedByUser => _autoScrollPausedByUser;

  @override
  void dispose() {
    service.dispose();
    controller.dispose();
    super.dispose();
  }

  void beginSessionStartAnchor() {
    _anchorActive = true;
    _autoScrollPausedByUser = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToAnchor();
    });
  }

  void addFollowUpAndTriggerAutoScroll() {
    setState(() {
      _showFollowUp = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom();
    });
  }

  void simulateUserScrollUp() {
    service.cancelPendingScroll();
    _anchorActive = false;
    _autoScrollPausedByUser = true;
    final nextOffset = (controller.offset - 120).clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
    controller.jumpTo(nextOffset);
  }

  void _scrollToAnchor() {
    final context = anchorKey.currentContext;
    if (context != null) {
      service.scrollToMessageTop(messageContext: context);
    }
  }

  void _scrollToBottom() {
    if (_anchorActive) {
      _scrollToAnchor();
      return;
    }
    if (_autoScrollPausedByUser) {
      return;
    }
    service.scrollToBottom();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!_anchorActive || notification.depth != 0) {
      return false;
    }

    final isUserDrivenScroll = notification is ScrollStartNotification &&
            notification.dragDetails != null ||
        notification is ScrollUpdateNotification &&
            notification.dragDetails != null ||
        notification is OverscrollNotification &&
            notification.dragDetails != null;

    if (isUserDrivenScroll) {
      _anchorActive = false;
      _autoScrollPausedByUser = true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _baseItemCount + (_showFollowUp ? 1 : 0);

    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 320,
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: List.generate(itemCount, (index) {
                    if (index == 0) {
                      return Container(
                        key: const ValueKey('session-header'),
                        height: 96,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        color: Colors.blueGrey.shade100,
                      );
                    }

                    if (index == 7) {
                      return Container(
                        key: anchorKey,
                        height: 72,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        color: Colors.orange.shade200,
                      );
                    }

                    if (_showFollowUp && index == itemCount - 1) {
                      return Container(
                        height: 120,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        color: Colors.green.shade200,
                      );
                    }

                    return Container(
                      height: 72,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: Colors.grey.shade300,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
