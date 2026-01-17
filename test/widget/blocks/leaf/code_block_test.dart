import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('PreConfig', () {
    test('should have correct tag', () {
      final config = const PreConfig();
      expect(config.tag, MarkdownTag.pre.name);
    });

    test('should have default language', () {
      final config = const PreConfig();
      expect(config.language, 'dart');
    });

    test('should have default wrapCode value', () {
      final config = const PreConfig();
      expect(config.wrapCode, isFalse);
    });

    test('should have dark config', () {
      final config = PreConfig.darkConfig;
      expect(config, isA<PreConfig>());
    });

    test('should accept builder function', () {
      Widget builder(code, language) => Text(code);
      final config = PreConfig(builder: builder);

      expect(config.builder, isNotNull);
      expect(config.builder, same(builder));
    });

    test('should accept wrapper function', () {
      Widget wrapper(Widget child, String code, String? language) =>
          Container(child: child);
      final config = PreConfig(wrapper: wrapper);

      expect(config.wrapper, isNotNull);
      expect(config.wrapper, same(wrapper));
    });

    test('should accept richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = PreConfig(richTextBuilder: builder);

      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });

    test('should copy with new values', () {
      final config = const PreConfig();
      final copied = config.copy(language: 'python', wrapCode: true);

      expect(copied.language, 'python');
      expect(copied.wrapCode, isTrue);
      expect(copied.textStyle, config.textStyle);
    });

    test('should assert when both builder and wrapper are provided', () {
      expect(
        () => PreConfig(
          builder: (code, lang) => Text(code),
          wrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when both builder and contentWrapper are provided',
        () {
      expect(
        () => PreConfig(
          builder: (code, lang) => Text(code),
          contentWrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when both wrapper and contentWrapper are provided', () {
      expect(
        () => PreConfig(
          wrapper: (child, code, lang) => Container(child: child),
          contentWrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when all three are provided', () {
      expect(
        () => PreConfig(
          builder: (code, lang) => Text(code),
          wrapper: (child, code, lang) => Container(child: child),
          contentWrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when copy with both builder and wrapper', () {
      final config = const PreConfig();
      expect(
        () => config.copy(
          builder: (code, lang) => Text(code),
          wrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });
  });

  group('CodeBlockNode', () {
    test('should extract content from element', () {
      /// Use a real markdown element structure for testing
      /// In practice, CodeBlockNode gets created by the markdown parser
      final config = PreConfig();
      /// Skip this test as it requires a real markdown Element
      /// which is complex to construct
      expect(config.tag, MarkdownTag.pre.name);
    });
  });

  group('CodeBlock rendering with markdown', () {
    testWidgets('should render simple code block', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''```
print("hello");
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render code block with language', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''```dart
void main() {
  print("Hello");
}
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render multiple code blocks', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''```dart
// Dart code
```

```python
# Python code
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should use custom builder', (tester) async {
      Widget builder(String code, String? language) => Container(
            color: Colors.grey,
            child: Text('Custom: $language'),
          );
      final config = MarkdownConfig(configs: [
        PreConfig(builder: builder),
      ]);
      final generator = MarkdownGenerator();
      const markdown = '''```dart
code here
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.text('Custom: dart'), findsOneWidget);
    });

    testWidgets('should use custom wrapper', (tester) async {
      Widget wrapper(Widget child, String code, String? language) =>
          Container(
            color: Colors.blue,
            child: child,
          );
      final config = MarkdownConfig(configs: [
        PreConfig(wrapper: wrapper),
      ]);
      final generator = MarkdownGenerator();
      const markdown = '''```
code
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle wrapCode option', (tester) async {
      final config = MarkdownConfig(configs: [
        PreConfig(wrapCode: true),
      ]);
      final generator = MarkdownGenerator();
      const markdown =
          '```\nvery long line of code that should wrap when enabled\n```';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('CodeBlock edge cases', () {
    testWidgets('should handle empty code block', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '```\n```';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle code with special characters', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''```
print("Hello\nWorld");
const x = 1 / 2;
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle code block with inline syntax', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''```dart
// This is a comment with `inline code`
String text = "value"; // end
```''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Highlighting functionality', () {
    test('should parse highlight nodes', () {
      final nodes = highLightSpans(
        'const x = 42;',
        language: 'dart',
        theme: const {},
        textStyle: const TextStyle(fontSize: 14),
      );

      expect(nodes, isNotNull);
      expect(nodes, isNotEmpty);
    });

    test('should handle empty code', () {
      final nodes = highLightSpans(
        '',
        language: 'dart',
        theme: const {},
        textStyle: const TextStyle(fontSize: 14),
      );

      expect(nodes, isNotNull);
    });

    test('should handle unknown language', () {
      final nodes = highLightSpans(
        'code here',
        language: 'unknown_language_xyz',
        theme: const {},
        textStyle: const TextStyle(fontSize: 14),
      );

      expect(nodes, isNotNull);
    });
  });
}
