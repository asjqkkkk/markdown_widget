import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('MarkdownGenerator', () {
    test('should build widgets from markdown', () {
      final generator = MarkdownGenerator();
      const markdown = '# Hello World\n\nThis is a paragraph.';
      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotNull);
      expect(widgets, isNotEmpty);
    });

    test('should call onTocList with heading nodes', () {
      final generator = MarkdownGenerator();
      const markdown = '''# Heading 1
## Heading 2
### Heading 3''';

      List<Toc>? tocList;
      generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(tocList, isNotNull);
      expect(tocList, hasLength(3));
    });

    test('should filter headings by headingNodeFilter', () {
      bool filterCalled = false;
      final generator = MarkdownGenerator(
        headingNodeFilter: (node) {
          filterCalled = true;
          return node.headingConfig.tag == 'h1';
        },
      );

      const markdown = '''# H1
## H2
### H3''';

      List<Toc>? tocList;
      generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(filterCalled, isTrue);
      expect(tocList, hasLength(1));
      expect(tocList!.first.node.headingConfig.tag, 'h1');
    });

    test('should use default allowAll filter when none provided', () {
      final generator = MarkdownGenerator();
      const markdown = '''# H1
## H2
### H3''';

      List<Toc>? tocList;
      generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(tocList, hasLength(3));
    });

    test('should allowAll static method returns true', () {
      final headingNode = HeadingNode(H1Config(), WidgetVisitor());
      expect(MarkdownGenerator.allowAll(headingNode), isTrue);
    });

    test('should apply custom config', () {
      final generator = MarkdownGenerator();
      const markdown = '# Hello';
      final config = MarkdownConfig(configs: [
        H1Config(style: TextStyle(fontSize: 40, color: Colors.red))
      ]);

      final widgets = generator.buildWidgets(markdown, config: config);

      expect(widgets, isNotEmpty);
    });

    test('should apply custom linesMargin', () {
      final generator = MarkdownGenerator(
        linesMargin: const EdgeInsets.all(20),
      );
      const markdown = 'Test';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should support custom generators', () {
      final generator = MarkdownGenerator(
        generators: [
          SpanNodeGeneratorWithTag(
            tag: 'test',
            generator: (element, config, visitor) {
              return TextNode(text: 'Custom Tag');
            },
          ),
        ],
      );

      const markdown = 'Test';
      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should call onNodeAccepted callback', () {
      int? callCount;
      final generator = MarkdownGenerator(
        onNodeAccepted: (node, index) {
          callCount = (callCount ?? 0) + 1;
        },
      );

      const markdown = '# Heading\n\nParagraph';
      generator.buildWidgets(markdown);

      expect(callCount, isNotNull);
      expect(callCount! >= 1, isTrue);
    });

    test('should support custom textGenerator', () {
      final textNode = TextNode(text: 'Test');
      final generator = MarkdownGenerator(
        textGenerator: (_, __, ___) => textNode,
      );

      const markdown = 'Hello World';
      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should support custom spanNodeBuilder', () {
      final generator = MarkdownGenerator(
        spanNodeBuilder: (spanNode) {
          final built = spanNode.build();
          if (built is TextSpan) return built;
          return TextSpan(text: '');
        },
      );

      const markdown = '# Test';
      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should support custom richTextBuilder', () {
      final generator = MarkdownGenerator(
        richTextBuilder: (span) => Text.rich(span),
      );

      const markdown = '# Test';
      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should support custom splitRegExp', () {
      final generator = MarkdownGenerator(
        splitRegExp: RegExp(r'\n'),
      );

      const markdown = 'Line 1\nLine 2';
      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle empty markdown', () {
      final generator = MarkdownGenerator();
      const markdown = '';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotNull);
    });

    test('should handle markdown with only whitespace', () {
      final generator = MarkdownGenerator();
      const markdown = '   \n\n   ';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotNull);
    });

    test('should handle markdown with code blocks', () {
      final generator = MarkdownGenerator();
      const markdown = '''```dart
void main() {
  print('Hello');
}
```''';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with lists', () {
      final generator = MarkdownGenerator();
      const markdown = '''- Item 1
- Item 2
- Item 3''';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with blockquotes', () {
      final generator = MarkdownGenerator();
      const markdown = '> This is a blockquote';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with tables', () {
      final generator = MarkdownGenerator();
      const markdown = '''| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |''';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with links', () {
      final generator = MarkdownGenerator();
      const markdown = '[Link text](https://example.com)';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with inline code', () {
      final generator = MarkdownGenerator();
      const markdown = 'This is `inline code`';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with horizontal rules', () {
      final generator = MarkdownGenerator();
      const markdown = '---';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with emphasis', () {
      final generator = MarkdownGenerator();
      const markdown = '*italic* and **bold**';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle markdown with checkboxes', () {
      final generator = MarkdownGenerator();
      const markdown = '''- [ ] Unchecked
- [x] Checked''';

      final widgets = generator.buildWidgets(markdown);

      expect(widgets, isNotEmpty);
    });

    test('should handle complex markdown document', () {
      final generator = MarkdownGenerator();
      const markdown = '''# Main Title

## Subtitle

This is a paragraph with **bold** and *italic* text.

- List item 1
- List item 2

> A blockquote

```dart
code here
```

[Link](https://example.com)''';

      List<Toc>? tocList;
      final widgets = generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(widgets, isNotEmpty);
      expect(tocList, isNotEmpty);
    });
  });

  group('MarkdownGenerator with HeadingNodeFilter', () {
    test('should filter out h3 headings', () {
      final generator = MarkdownGenerator(
        headingNodeFilter: (node) => node.headingConfig.tag != 'h3',
      );

      const markdown = '''# H1
## H2
### H3
#### H4''';

      List<Toc>? tocList;
      generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(tocList, hasLength(3));
      for (final toc in tocList!) {
        expect(toc.node.headingConfig.tag, isNot('h3'));
      }
    });

    test('should only include h1 and h2 headings', () {
      final generator = MarkdownGenerator(
        headingNodeFilter: (node) =>
            {'h1', 'h2'}.contains(node.headingConfig.tag),
      );

      const markdown = '''# H1
## H2
### H3
#### H4
##### H5
###### H6''';

      List<Toc>? tocList;
      generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(tocList, hasLength(2));
    });

    test('should exclude all headings when filter returns false', () {
      final generator = MarkdownGenerator(
        headingNodeFilter: (node) => false,
      );

      const markdown = '''# H1
## H2
### H3''';

      List<Toc>? tocList;
      generator.buildWidgets(markdown, onTocList: (list) => tocList = list);

      expect(tocList, isEmpty);
    });
  });

  group('SpanNodeBuilder and RichTextBuilder', () {
    test('should apply custom spanNodeBuilder', () {
      bool builderCalled = false;
      final generator = MarkdownGenerator(
        spanNodeBuilder: (spanNode) {
          builderCalled = true;
          final built = spanNode.build();
          if (built is TextSpan) return built;
          return TextSpan(text: '');
        },
      );

      const markdown = '# Test';
      generator.buildWidgets(markdown);

      expect(builderCalled, isTrue);
    });

    test('should apply custom richTextBuilder', () {
      bool builderCalled = false;
      final generator = MarkdownGenerator(
        richTextBuilder: (span) {
          builderCalled = true;
          return Text.rich(span);
        },
      );

      const markdown = '# Test';
      generator.buildWidgets(markdown);

      expect(builderCalled, isTrue);
    });
  });
}
