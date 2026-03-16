import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/chat/services/chat_scroll_service.dart';

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
