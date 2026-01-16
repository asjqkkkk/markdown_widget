import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('HeadingNode', () {
    test('should create with headingConfig and visitor', () {
      final config = H1Config();
      final visitor = WidgetVisitor();
      final node = HeadingNode(config, visitor);

      expect(node.headingConfig, config);
      expect(node.visitor, visitor);
    });

    test('should copy with new headingConfig', () {
      final originalConfig = H1Config();
      final visitor = WidgetVisitor();
      final node = HeadingNode(originalConfig, visitor);
      node.accept(TextNode(text: 'Original'));

      final newConfig = H2Config();
      final copied = node.copy(headingConfig: newConfig);

      expect(copied.headingConfig, newConfig);
      expect(copied.visitor, visitor);
      expect(copied.children.length, 1);
    });

    test('should copy children', () {
      final config = H1Config();
      final visitor = WidgetVisitor();
      final node = HeadingNode(config, visitor);
      final child = TextNode(text: 'Heading Text');
      node.accept(child);

      final copied = node.copy();

      expect(copied.children.length, 1);
      expect(copied.children.first, isA<TextNode>());
    });

    test('should have style from headingConfig', () {
      final config = H1Config();
      final visitor = WidgetVisitor();
      final node = HeadingNode(config, visitor);

      expect(node.style, config.style);
    });
  });

  group('H1Config', () {
    test('should have correct tag', () {
      final config = const H1Config();
      expect(config.tag, MarkdownTag.h1.name);
    });

    test('should have default style', () {
      final config = const H1Config();
      expect(config.style, isNotNull);
    });

    test('should have divider', () {
      final config = const H1Config();
      expect(config.divider, isNotNull);
      expect(config.divider, isA<HeadingDivider>());
    });

    test('should have dark config', () {
      final config = H1Config.darkConfig;
      expect(config, isA<H1Config>());
    });

    test('should accept richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom H1');
      final config = H1Config(richTextBuilder: builder);

      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('H2Config', () {
    test('should have correct tag', () {
      final config = const H2Config();
      expect(config.tag, MarkdownTag.h2.name);
    });

    test('should have default style', () {
      final config = const H2Config();
      expect(config.style, isNotNull);
    });

    test('should have divider', () {
      final config = const H2Config();
      expect(config.divider, isNotNull);
      expect(config.divider, isA<HeadingDivider>());
    });

    test('should have dark config', () {
      final config = H2Config.darkConfig;
      expect(config, isA<H2Config>());
    });

    test('should accept richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom H2');
      final config = H2Config(richTextBuilder: builder);

      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('H3Config', () {
    test('should have correct tag', () {
      final config = const H3Config();
      expect(config.tag, MarkdownTag.h3.name);
    });

    test('should have default style', () {
      final config = const H3Config();
      expect(config.style, isNotNull);
    });

    test('should have divider', () {
      final config = const H3Config();
      expect(config.divider, isNotNull);
    });

    test('should have dark config', () {
      final config = H3Config.darkConfig;
      expect(config, isA<H3Config>());
    });
  });

  group('H4Config', () {
    test('should have correct tag', () {
      final config = const H4Config();
      expect(config.tag, MarkdownTag.h4.name);
    });

    test('should have no divider', () {
      final config = const H4Config();
      expect(config.divider, isNull);
    });

    test('should have dark config', () {
      final config = H4Config.darkConfig;
      expect(config, isA<H4Config>());
    });
  });

  group('H5Config', () {
    test('should have correct tag', () {
      final config = const H5Config();
      expect(config.tag, MarkdownTag.h5.name);
    });

    test('should have no divider', () {
      final config = const H5Config();
      expect(config.divider, isNull);
    });

    test('should have dark config', () {
      final config = H5Config.darkConfig;
      expect(config, isA<H5Config>());
    });
  });

  group('H6Config', () {
    test('should have correct tag', () {
      final config = const H6Config();
      expect(config.tag, MarkdownTag.h6.name);
    });

    test('should have no divider', () {
      final config = const H6Config();
      expect(config.divider, isNull);
    });

    test('should have dark config', () {
      final config = H6Config.darkConfig;
      expect(config, isA<H6Config>());
    });
  });

  group('Heading rendering with markdown', () {
    testWidgets('should render h1 heading', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '# Heading 1';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render h2 heading', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '## Heading 2';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render h3-h6 headings', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render heading with inline formatting', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '# **Bold** and *italic* heading';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should generate TOC entries', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''# H1
## H2
### H3''';

      List<TocItem>? tocList;
      generator.buildWidgets(markdown, config: config, onTocList: (list) => tocList = list);

      expect(tocList, isNotNull);
      expect(tocList, hasLength(3));
      /// Use ! to assert non-null after the hasLength check
      expect(tocList![0].node.headingConfig.tag, 'h1');
      expect(tocList![1].node.headingConfig.tag, 'h2');
      expect(tocList![2].node.headingConfig.tag, 'h3');
    });

    testWidgets('should render heading with divider', (tester) async {
      final config = MarkdownConfig();
      final generator = MarkdownGenerator();
      const markdown = '''# Heading with divider

Content below.''';

      final widgets = generator.buildWidgets(markdown, config: config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: widgets),
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('HeadingDivider', () {
    test('should copy with new values', () {
      final divider = HeadingDivider();
      final copied = divider.copy(color: Colors.red, space: 10, height: 2);

      expect(copied.color, Colors.red);
      expect(copied.space, 10);
      expect(copied.height, 2);
    });

    test('should keep original values when not copying', () {
      final divider = HeadingDivider(
        color: Colors.blue,
        space: 5,
        height: 1.5,
      );
      final copied = divider.copy();

      expect(copied.color, divider.color);
      expect(copied.space, divider.space);
      expect(copied.height, divider.height);
    });
  });
}
