import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

Iterable<TextSpan> textSpans(InlineSpan span) sync* {
  if (span is TextSpan) {
    yield span;
    for (final child in span.children ?? <InlineSpan>[]) {
      yield* textSpans(child);
    }
  }
}

void main() {
  test('explicit inline-code properties override the prose style', () {
    final parent = ConcreteElementNode(
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 24,
        color: Colors.red,
        backgroundColor: Colors.white,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.5,
        height: 1.4,
      ),
    );
    final node = CodeNode(
        'value',
        const CodeConfig(
            style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          color: Colors.blue,
          backgroundColor: Colors.yellow,
        )));
    parent.accept(node);
    final span = node.build() as TextSpan;
    expect(span.text, 'value');
    expect(span.style!.fontFamily, 'monospace');
    expect(span.style!.fontSize, 18);
    expect(span.style!.color, Colors.blue);
    expect(span.style!.backgroundColor, Colors.yellow);
    expect(span.style!.fontWeight, FontWeight.bold);
    expect(span.style!.fontStyle, FontStyle.italic);
    expect(span.style!.letterSpacing, 1.5);
    expect(span.style!.height, 1.4);
  });

  test('default code style retains unspecified parent properties', () {
    final parent = ConcreteElementNode(
        style: const TextStyle(
      fontFamily: 'serif',
      fontSize: 20,
      color: Colors.red,
    ));
    final node = CodeNode('value', const CodeConfig());
    parent.accept(node);
    expect(node.style.fontFamily, 'serif');
    expect(node.style.fontSize, 20);
    expect(node.style.color, Colors.red);
    expect(node.style.backgroundColor, const Color(0xCCeff1f3));
  });

  test('code without a parent keeps configured style', () {
    const style = TextStyle(fontFamily: 'monospace', color: Colors.blue);
    final node = CodeNode('value', const CodeConfig(style: style));
    expect(node.style, style);
  });

  test('non-inheriting code style does not inherit parent properties', () {
    const style =
        TextStyle(inherit: false, fontFamily: 'monospace', fontSize: 18);
    final parent =
        ConcreteElementNode(style: const TextStyle(color: Colors.red));
    final node = CodeNode('value', const CodeConfig(style: style));
    parent.accept(node);
    expect(node.style, style);
  });

  testWidgets('Markdown preserves prose and emphasis around configured code',
      (tester) async {
    final captured = <InlineSpan>[];
    final widgets = MarkdownGenerator(richTextBuilder: (span) {
      captured.add(span);
      return Text.rich(span);
    }).buildWidgets('Plain **`bold`** and *`italic`*.',
        config: MarkdownConfig(configs: [
          const PConfig(
              textStyle: TextStyle(
                  fontFamily: 'serif', fontSize: 24, color: Colors.red)),
          const CodeConfig(
              style: TextStyle(
                  fontFamily: 'monospace', backgroundColor: Colors.yellow)),
        ]));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Column(children: widgets))));
    final spans = captured.expand(textSpans).toList();
    final bold = spans.singleWhere((span) => span.text == 'bold');
    final italic = spans.singleWhere((span) => span.text == 'italic');
    for (final span in [bold, italic]) {
      expect(span.style!.fontFamily, 'monospace');
      expect(span.style!.fontSize, 24);
      expect(span.style!.color, Colors.red);
      expect(span.style!.backgroundColor, Colors.yellow);
    }
    expect(bold.style!.fontWeight, FontWeight.bold);
    expect(italic.style!.fontStyle, FontStyle.italic);
    expect(spans.singleWhere((span) => span.text == 'Plain ').style!.fontFamily,
        'serif');
    expect(captured.single.toPlainText(), 'Plain bold and italic.');
  });
}
