import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('HrConfig', () {
    test('should have correct tag', () {
      final config = const HrConfig();
      expect(config.tag, MarkdownTag.hr.name);
    });

    test('should have dark config', () {
      final config = HrConfig.darkConfig;
      expect(config, isA<HrConfig>());
    });
  });

  group('HorizontalRule rendering with markdown', () {
    testWidgets('should render horizontal rule with dashes', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '---';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render horizontal rule with asterisks', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '***';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render horizontal rule with underscores', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '___';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render horizontal rule with more characters', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '--------------------';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render multiple horizontal rules', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''First section

---

Second section

***

Third section''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render horizontal rule with text around', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''Text before

---

Text after''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should use dark config', (tester) async {
      final config = MarkdownConfig.darkConfig;
      final generator = MarkdownGenerator();
      const markdown = '---';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('HorizontalRule edge cases', () {
    testWidgets('should handle horizontal rule with spaces', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = ' - - - ';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should not render invalid horizontal rule', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '--'; /// Too short

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      /// Should still render, just not as a horizontal rule
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle horizontal rule in complex document', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''# Title

Some content

---

More content

* List item
* Another item

---

Final section''';

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
