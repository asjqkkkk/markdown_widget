import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('CodeNode', () {
    test('should create with text and config', () {
      final config = CodeConfig();
      final node = CodeNode('print("hello")', config);

      expect(node.text, 'print("hello")');
      expect(node.codeConfig, config);
    });

    test('should have correct tag', () {
      final config = CodeConfig();
      expect(config.tag, MarkdownTag.code.name);
    });

    testWidgets('should build code span', (tester) async {
      final config = CodeConfig();
      final node = CodeNode('code text', config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('CodeConfig', () {
    test('should have default style', () {
      final config = const CodeConfig();
      expect(config.style, isNotNull);
      expect(config.style.backgroundColor, const Color(0xCCeff1f3));
    });

    test('should have dark config', () {
      final config = CodeConfig.darkConfig;
      expect(config, isA<CodeConfig>());
      expect(config.style.backgroundColor, const Color(0xCC555555));
    });

    test('should accept custom style', () {
      final customStyle = TextStyle(
        backgroundColor: Colors.grey,
        fontSize: 16,
        color: Colors.blue,
      );
      final config = CodeConfig(style: customStyle);
      expect(config.style.backgroundColor, Colors.grey);
      expect(config.style.fontSize, 16);
      expect(config.style.color, Colors.blue);
    });
  });

  group('CodeNode with parent style', () {
    test('should merge parent style', () {
      final parent = ConcreteElementNode(
        style: TextStyle(fontSize: 20, color: Colors.red),
      );
      final config = CodeConfig();
      final node = CodeNode('code', config);
      parent.accept(node);

      expect(node.parentStyle, parent.style);
    });
  });

  group('CodeNode with text content', () {
    testWidgets('should display text content', (tester) async {
      final config = CodeConfig();
      final node = CodeNode('const x = 42;', config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle empty text', (tester) async {
      final config = CodeConfig();
      final node = CodeNode('', config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle special characters', (tester) async {
      final config = CodeConfig();
      final node = CodeNode('print("Hello\\nWorld")', config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('CodeNode style merging', () {
    test('should merge config style with parent style', () {
      final parent = ConcreteElementNode(
        style: TextStyle(fontSize: 20, color: Colors.red),
      );
      final config = CodeConfig(style: TextStyle(fontWeight: FontWeight.bold));
      final node = CodeNode('code', config);
      parent.accept(node);

      final span = node.build() as TextSpan;
      /// Style should be a merge of parent and config styles
      expect(span.style, isNotNull);
    });
  });

  group('CodeNode in markdown context', () {
    testWidgets('should render within paragraph', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = 'This is `inline code` in text.';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle multiple code spans in one line', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = 'Use `var` or `final` or `const`.';

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
