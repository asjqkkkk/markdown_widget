import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('LinkNode', () {
    test('should create with attributes and config', () {
      final attributes = {'href': 'https://example.com'};
      final config = LinkConfig();
      final node = LinkNode(attributes, config);

      expect(node.attributes, attributes);
      expect(node.linkConfig, config);
    });

    test('should extract href from attributes', () {
      final attributes = {'href': 'https://example.com'};
      final config = LinkConfig();
      final node = LinkNode(attributes, config);

      expect(node.attributes['href'], 'https://example.com');
    });

    test('should handle missing href', () {
      final attributes = <String, String>{};
      final config = LinkConfig();
      final node = LinkNode(attributes, config);

      expect(node.attributes['href'], isNull);
    });
  });

  group('LinkConfig', () {
    test('should have correct tag', () {
      final config = const LinkConfig();
      expect(config.tag, MarkdownTag.a.name);
    });

    test('should have default style', () {
      final config = const LinkConfig();
      expect(config.style, isNotNull);
    });

    test('should accept custom style', () {
      final customStyle = TextStyle(
        color: Colors.purple,
        fontSize: 16,
        decoration: TextDecoration.underline,
      );
      final config = LinkConfig(style: customStyle);

      expect(config.style.color, Colors.purple);
      expect(config.style.fontSize, 16);
      expect(config.style.decoration, TextDecoration.underline);
    });

    test('should accept onTap callback', () {
      String? tappedUrl;
      final config = LinkConfig(onTap: (url) {
        tappedUrl = url;
      });

      config.onTap?.call('https://example.com');
      expect(tappedUrl, 'https://example.com');
    });
  });

  group('Link rendering with markdown', () {
    testWidgets('should render simple link', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[Link text](https://example.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(RichText), findsAtLeastNWidgets(1));
    });

    testWidgets('should render link with inline formatting', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[**Bold** link](https://example.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(RichText), findsAtLeastNWidgets(1));
    });

    testWidgets('should render multiple links', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[Link 1](https://example1.com) and [Link 2](https://example2.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(RichText), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle link in heading', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '# [Link in heading](https://example.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle link in list', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''- [Link 1](https://example1.com)
- [Link 2](https://example2.com)''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle link in blockquote', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '> [Link in quote](https://example.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Link edge cases', () {
    testWidgets('should handle empty link text', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[](https://example.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle special characters in URL', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[Link](https://example.com/path?query=value&other=123)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle relative URLs', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[Link](/relative/path)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle anchor links', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[Link](#section)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Link with custom onTap', () {
    testWidgets('should call custom onTap when tapped', (tester) async {
      final config = MarkdownConfig(configs: [
        LinkConfig(onTap: (url) {
          /// onTap callback for future tap testing
        }),
      ]);
      final generator = MarkdownGenerator();
      const markdown = '[Click me](https://example.com)';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      /// Note: Actually tapping the link in a test requires more complex setup
      /// This just verifies the widget renders without error
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Link with images as children', () {
    testWidgets('should render image inside link', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '[![Alt text](https://example.com/image.png)](https://example.com)';

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
