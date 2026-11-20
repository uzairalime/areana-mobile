import 'package:arana360/core/widgets/scroll_hide_bottom_nav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late BottomNavVisibilityController controller;

  setUp(() {
    controller = BottomNavVisibilityController(hideThreshold: 10);
  });

  tearDown(() => controller.dispose());

  group('BottomNavVisibilityController', () {
    test('stays visible until down-scroll crosses the threshold', () {
      controller.applyScroll(axis: Axis.vertical, pixels: 40, delta: 6);
      expect(controller.visible, isTrue);
      controller.applyScroll(axis: Axis.vertical, pixels: 46, delta: 6);
      expect(controller.visible, isFalse);
    });

    test('shows again after an up-scroll crosses the threshold', () {
      controller.hide();
      controller.applyScroll(axis: Axis.vertical, pixels: 80, delta: -6);
      expect(controller.visible, isFalse);
      controller.applyScroll(axis: Axis.vertical, pixels: 74, delta: -6);
      expect(controller.visible, isTrue);
    });

    test('always shows near the top of the list', () {
      controller.hide();
      controller.applyScroll(axis: Axis.vertical, pixels: 4, delta: 20);
      expect(controller.visible, isTrue);
    });

    test('ignores horizontal scroll', () {
      controller.applyScroll(axis: Axis.horizontal, pixels: 80, delta: 40);
      expect(controller.visible, isTrue);
    });

    test('show and hide are idempotent', () {
      var ticks = 0;
      controller.addListener(() => ticks++);
      controller.show();
      controller.hide();
      controller.hide();
      controller.show();
      controller.show();
      expect(ticks, 2);
      expect(controller.visible, isTrue);
    });
  });

  testWidgets('scroll listener hides then shows the shared controller', (
    tester,
  ) async {
    final nav = BottomNavVisibilityController(hideThreshold: 10);
    addTearDown(nav.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: BottomNavVisibilityScope(
          controller: nav,
          child: Scaffold(
            body: ScrollHideBottomNav(
              child: ListView(
                children: [
                  for (var i = 0; i < 40; i++)
                    SizedBox(height: 72, child: Text('row-$i')),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pump();
    expect(nav.visible, isFalse);

    await tester.drag(find.byType(ListView), const Offset(0, 160));
    await tester.pump();
    expect(nav.visible, isTrue);
  });

  testWidgets('bar fades out and back in with visibility', (tester) async {
    var visible = true;
    late StateSetter setVisible;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setVisible = setState;
            return FadeSlideBottomNav(
              visible: visible,
              child: const SizedBox(key: Key('nav-child'), height: 48),
            );
          },
        ),
      ),
    );

    FadeTransition fade() {
      return tester.widget(
        find.descendant(
          of: find.byType(FadeSlideBottomNav),
          matching: find.byType(FadeTransition),
        ),
      );
    }

    expect(fade().opacity.value, 1);

    setVisible(() => visible = false);
    await tester.pump();
    await tester.pump(FadeSlideBottomNav.reverseDuration);
    expect(fade().opacity.value, 0);

    setVisible(() => visible = true);
    await tester.pump();
    await tester.pump(FadeSlideBottomNav.duration);
    expect(fade().opacity.value, 1);
  });
}
