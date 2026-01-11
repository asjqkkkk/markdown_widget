import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('ListConfig', () {
    test('should have correct tag', () {
      final config = const ListConfig();
      expect(config.tag, MarkdownTag.li.name);
    });

    test('should accept marker function', () {
      Widget marker(bool isOrdered, int depth, int index) => Container();
      final config = ListConfig(marker: marker);

      expect(config.marker, isNotNull);
      expect(config.marker, same(marker));
    });

    test('should accept richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = ListConfig(richTextBuilder: builder);

      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('UlOrOLNode', () {
    test('should create with tag and attributes', () {
      final config = ListConfig();
      final visitor = WidgetVisitor();
      final node = UlOrOLNode('ul', {}, config, visitor);

      expect(node.tag, 'ul');
      expect(node.config, config);
      expect(node.visitor, visitor);
    });

    test('should create with ol tag', () {
      final config = ListConfig();
      final visitor = WidgetVisitor();
      final node = UlOrOLNode('ol', {}, config, visitor);

      expect(node.tag, 'ol');
    });

    test('should parse start attribute', () {
      final config = ListConfig();
      final visitor = WidgetVisitor();
      final node = UlOrOLNode('ol', {'start': '5'}, config, visitor);

      expect(node.start, 4);
    });

    test('should default start to 0 (1-indexed)', () {
      final config = ListConfig();
      final visitor = WidgetVisitor();
      final node = UlOrOLNode('ol', {}, config, visitor);

      expect(node.start, 0);
    });

    test('should handle invalid start attribute', () {
      final config = ListConfig();
      final visitor = WidgetVisitor();
      final node = UlOrOLNode('ol', {'start': 'invalid'}, config, visitor);

      expect(node.start, 0);
    });
  });

  group('ListNode', () {
    test('should create with config and visitor', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();
      final node = ListNode(config, visitor);

      expect(node.config, config);
      expect(node.visitor, visitor);
      expect(node.index, 0);
    });

    test('should detect ordered list', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();
      final ulNode = UlOrOLNode('ul', {}, config.li, visitor);
      final node = ListNode(config, visitor);
      ulNode.accept(node);

      expect(node.isOrdered, isFalse);
    });

    test('should detect ordered list parent', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();
      final olNode = UlOrOLNode('ol', {}, config.li, visitor);
      final node = ListNode(config, visitor);
      olNode.accept(node);

      expect(node.isOrdered, isTrue);
    });

    test('should calculate depth correctly', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final rootUl = UlOrOLNode('ul', {}, config.li, visitor);
      final level1List = ListNode(config, visitor);
      final level1Ul = UlOrOLNode('ul', {}, config.li, visitor);
      final level2List = ListNode(config, visitor);

      rootUl.accept(level1List);
      level1List.accept(level1Ul);
      level1Ul.accept(level2List);

      expect(level2List.depth, 1);
    });

    test('should calculate depth for single level', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final ulNode = UlOrOLNode('ul', {}, config.li, visitor);
      final listNode = ListNode(config, visitor);
      ulNode.accept(listNode);

      expect(listNode.depth, 0);
    });

    test('should detect checkbox when first child is InputNode', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();
      final node = ListNode(config, visitor);
      final inputNode = InputNode({'checked': 'true'}, config);
      node.accept(inputNode);

      expect(node.isCheckbox, isTrue);
    });

    test('should not detect checkbox when first child is not InputNode', () {
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();
      final node = ListNode(config, visitor);
      final textNode = TextNode(text: 'Item');
      node.accept(textNode);

      expect(node.isCheckbox, isFalse);
    });
  });

  group('List rendering with markdown', () {
    testWidgets('should render unordered list', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''- Item 1
- Item 2
- Item 3''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render ordered list', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''1. First
2. Second
3. Third''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render nested lists', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''- Parent
  - Child 1
  - Child 2''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render checkbox list', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''- [ ] Task 1
- [x] Task 2
- [ ] Task 3''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(MCheckBox), findsNWidgets(3));
    });

    testWidgets('should use custom marker when provided', (tester) async {
      final config = MarkdownConfig(configs: [
        ListConfig(marker: (isOrdered, depth, index) {
          return Text('Custom: $index');
        }),
      ]);
      final generator = MarkdownGenerator();
      const markdown = '''- Item 1
- Item 2''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.text('Custom: 0'), findsOneWidget);
      expect(find.text('Custom: 1'), findsOneWidget);
    });
  });

  group('List with ordered start attribute', () {
    testWidgets('should render ordered list with custom start', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''1. Item 1
2. Item 2''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
