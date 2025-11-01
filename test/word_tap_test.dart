import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/widget/span_node.dart';

void main() {
  group('TappableTextNode', () {
    test('should create tappable spans for words', () {
      final node = TappableTextNode(
        text: 'Hello world test',
        onTapWord: (word) {},
      );

      final span = node.build() as TextSpan;

      // Should create a TextSpan with children (words + spaces)
      expect(span.children, isNotNull);
      expect(span.children!.length, greaterThan(0));
    });

    test('should split text correctly preserving whitespace', () {
      final node = TappableTextNode(
        text: 'Hello  world\ttest\n',
        onTapWord: (word) {},
      );

      final parts = node.splitTextWithSpaces('Hello  world\ttest\n');

      expect(parts, [
        'Hello',
        '  ',
        'world',
        '\t',
        'test',
        '\n',
      ]);
    });

    test('should handle punctuation in words', () {
      final node = TappableTextNode(
        text: 'Hello, world! How are you?',
        onTapWord: (word) {},
      );

      final parts = node.splitTextWithSpaces('Hello, world! How are you?');

      expect(parts, [
        'Hello,',
        ' ',
        'world!',
        ' ',
        'How',
        ' ',
        'are',
        ' ',
        'you?',
      ]);
    });

    test('should fallback to regular TextSpan when no callback', () {
      final node = TappableTextNode(
        text: 'Hello world',
        onTapWord: null,
      );

      final span = node.build() as TextSpan;

      // Should create a simple TextSpan without children
      expect(span.children, isNull);
      expect(span.toPlainText(), equals('Hello world'));
    });
  });
}