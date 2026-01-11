import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('TableConfig', () {
    test('should have correct tag', () {
      final config = const TableConfig();
      expect(config.tag, MarkdownTag.table.name);
    });

    test('should accept wrapper function', () {
      Widget wrapper(Widget child) => Container(color: Colors.red, child: child);
      final config = TableConfig(wrapper: wrapper);

      expect(config.wrapper, isNotNull);
      expect(config.wrapper, same(wrapper));
    });

    test('should accept richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = TableConfig(richTextBuilder: builder);

      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('Table rendering with markdown', () {
    testWidgets('should render simple table', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render table with alignment', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''| Left | Center | Right |
|:-----|:------:|------:|
| L    | C      | R     |''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render table with multiple rows', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''| H1 | H2 |
|----|----|
| A  | B  |
| C  | D  |
| E  | F  |''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render table with inline formatting', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''| **Bold** | *Italic* | `Code` |
|----------|----------|---------|
| Text     | Text     | Text    |''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should use custom wrapper when provided', (tester) async {
      Widget wrapper(Widget child) => Container(
        color: Colors.blue,
        child: child,
      );
      final config = MarkdownConfig(configs: [
        TableConfig(wrapper: wrapper),
      ]);
      final generator = MarkdownGenerator();
      const markdown = '''| H1 | H2 |
|----|----|
| A  | B  |''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
  });

  group('Table edge cases', () {
    testWidgets('should handle empty table', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '| | |';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle table with special characters', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''| Name | Value |
|------|-------|
| Test | 123   |
| Data | "quote" |''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle table with links', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''| Header |
|--------|
| [Link](https://example.com) |''';

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
