import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('BlockquoteConfig', () {
    test('should have correct tag', () {
      final config = const BlockquoteConfig();
      expect(config.tag, MarkdownTag.blockquote.name);
    });

    test('should have dark config', () {
      final config = BlockquoteConfig.darkConfig;
      expect(config, isA<BlockquoteConfig>());
    });

    test('should accept richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = BlockquoteConfig(richTextBuilder: builder);

      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('BlockquoteNode', () {
    test('should create with config and visitor', () {
      final config = BlockquoteConfig();
      final visitor = WidgetVisitor();
      final node = BlockquoteNode(config, visitor);

      expect(node.config, config);
      expect(node.visitor, visitor);
    });

    test('should merge parent style', () {
      final parent = ConcreteElementNode(
        style: TextStyle(fontSize: 20, color: Colors.red),
      );
      final config = BlockquoteConfig();
      final visitor = WidgetVisitor();
      final node = BlockquoteNode(config, visitor);
      parent.accept(node);

      expect(node.parentStyle, parent.style);
    });
  });

  group('Blockquote rendering with markdown', () {
    testWidgets('should render simple blockquote', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '> This is a blockquote';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should render multi-line blockquote', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''> Line 1
> Line 2
> Line 3''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should render nested blockquotes', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''> Outer quote
>> Inner quote''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should render blockquote with inline formatting', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '> This is **bold** and *italic* text';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should use dark config', (tester) async {
      final config = MarkdownConfig.darkConfig;
      final generator = MarkdownGenerator();
      const markdown = '> This is a blockquote with dark config';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should use custom richTextBuilder', (tester) async {
      Widget builder(InlineSpan span) => Container(
        color: Colors.yellow,
        child: Text.rich(span),
      );
      final config = MarkdownConfig(configs: [
        BlockquoteConfig(richTextBuilder: builder),
      ]);
      final generator = MarkdownGenerator();
      const markdown = '> Custom styled blockquote';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
  });

  group('Blockquote edge cases', () {
    testWidgets('should handle empty blockquote', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '>';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      /// Should still render without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle blockquote with code', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '> ```dart\n> code here\n> ```';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle blockquote with links', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '> [Link text](https://example.com) in quote';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Blockquote in markdown document', () {
    testWidgets('should handle blockquote among other elements', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''# Title

Regular paragraph.

> Blockquote here

More text.''';

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
