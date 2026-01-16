import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

void main() {
  group('TocController', () {
    late TocController controller;

    setUp(() {
      controller = TocController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize with empty toc list', () {
      expect(controller.tocList, isEmpty);
    });

    test('should set toc list', () {
      final headingNode = HeadingNode(H1Config(), WidgetVisitor());
      final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);
      controller.setTocList([toc]);

      expect(controller.tocList, hasLength(1));
      expect(controller.tocList.first.node, headingNode);
    });

    test('should replace toc list when setting new list', () {
      final headingNode1 = HeadingNode(H1Config(), WidgetVisitor());
      final headingNode2 = HeadingNode(H2Config(), WidgetVisitor());
      final toc1 = TocItem(node: headingNode1, widgetIndex: 0, tocListIndex: 0);
      final toc2 = TocItem(node: headingNode2, widgetIndex: 1, tocListIndex: 1);

      controller.setTocList([toc1]);
      expect(controller.tocList, hasLength(1));

      controller.setTocList([toc2]);
      expect(controller.tocList, hasLength(1));
      expect(controller.tocList.first.node, headingNode2);
    });

    test('should set and call jumpToWidgetIndexCallback', () {
      int? jumpedIndex;
      controller.jumpToWidgetIndexCallback = (index) {
        jumpedIndex = index;
      };

      controller.jumpToWidgetIndex(5);
      expect(jumpedIndex, 5);
    });

    test('should clear all data on dispose', () {
      final headingNode = HeadingNode(H1Config(), WidgetVisitor());
      final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);
      controller.setTocList([toc]);

      controller.dispose();

      expect(controller.tocList, isEmpty);
    });
  });

  group('TocItem', () {
    test('should create with required parameters', () {
      final headingNode = HeadingNode(H1Config(), WidgetVisitor());
      final toc = TocItem(
        node: headingNode,
        widgetIndex: 5,
        tocListIndex: 10,
      );

      expect(toc.node, headingNode);
      expect(toc.widgetIndex, 5);
      expect(toc.tocListIndex, 10);
    });

    test('should have default index values', () {
      final headingNode = HeadingNode(H1Config(), WidgetVisitor());
      final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);

      expect(toc.widgetIndex, 0);
      expect(toc.tocListIndex, 0);
    });
  });

  group('headingTag2Level', () {
    test('should map h1 to level 1', () {
      expect(headingTag2Level['h1'], 1);
    });

    test('should map h2 to level 2', () {
      expect(headingTag2Level['h2'], 2);
    });

    test('should map h3 to level 3', () {
      expect(headingTag2Level['h3'], 3);
    });

    test('should map h4 to level 4', () {
      expect(headingTag2Level['h4'], 4);
    });

    test('should map h5 to level 5', () {
      expect(headingTag2Level['h5'], 5);
    });

    test('should map h6 to level 6', () {
      expect(headingTag2Level['h6'], 6);
    });

    test('should return null for unknown tags', () {
      expect(headingTag2Level['h7'], isNull);
      expect(headingTag2Level['p'], isNull);
    });
  });

  group('TocItemBuilderData', () {
    test('should create with all parameters', () {
      final headingNode = HeadingNode(H1Config(), WidgetVisitor());
      final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);
      final data = TocItemBuilderData(
          index: 5,
          toc: toc,
          currentIndex: 10,
          refreshIndexCallback: (index) {},
          autoScrollController: AutoScrollController());

      expect(data.index, 5);
      expect(data.toc, toc);
      expect(data.currentIndex, 10);
      expect(data.refreshIndexCallback, isNotNull);
    });
  });

  testWidgets('TocWidget should build with default styles', (tester) async {
    final controller = TocController();
    final headingNode = HeadingNode(H1Config(), WidgetVisitor());
    final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);
    controller.setTocList([toc]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TocWidget(controller: controller),
      ),
    ));

    expect(find.byType(TocWidget), findsOneWidget);
  });

  testWidgets('TocWidget should apply custom styles', (tester) async {
    final controller = TocController();
    final headingNode = HeadingNode(H1Config(), WidgetVisitor());
    final textNode = TextNode(text: 'Heading 1');
    headingNode.accept(textNode);
    final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);
    controller.setTocList([toc]);

    const customStyle = TextStyle(fontSize: 20, color: Colors.red);
    const customCurrentStyle = TextStyle(fontSize: 24, color: Colors.blue);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TocWidget(
          controller: controller,
          tocTextStyle: customStyle,
          currentTocTextStyle: customCurrentStyle,
        ),
      ),
    ));

    expect(find.byType(TocWidget), findsOneWidget);
  });

  testWidgets('TocWidget should use itemBuilder when provided', (tester) async {
    final controller = TocController();
    final headingNode = HeadingNode(H1Config(), WidgetVisitor());
    final textNode = TextNode(text: 'Heading 1');
    headingNode.accept(textNode);
    final toc = TocItem(node: headingNode, widgetIndex: 0, tocListIndex: 0);
    controller.setTocList([toc]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TocWidget(
          controller: controller,
          itemBuilder: (data) {
            return Container(
              key: Key('toc-${data.index}'),
              child: Text('Custom: ${data.index}'),
            );
          },
        ),
      ),
    ));

    expect(find.byType(TocWidget), findsOneWidget);
    expect(find.text('Custom: 0'), findsOneWidget);
  });
}
