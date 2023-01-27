import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

final _dbTag = 'db';

class DBNode extends SpanNode {
  final Map<String, String> attribute;
  final MarkdownConfig config;

  String get dbId => attribute['id'] ?? '';

  DBNode(this.attribute, this.config);

  @override
  InlineSpan build() => TextSpan(
    text: '$dbId',
    style: parentStyle?.copyWith(color: Colors.amberAccent) ??
        config.p.textStyle.copyWith(color: Colors.amberAccent),
  );
}

SpanNodeGeneratorWithTag dbGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: _dbTag,
    generator: (e, config, visitor) => DBNode(e.attributes, config));

// class DBSyntax extends m.BlockSyntax {
//   static final _pattern = RegExp(r'((\w+))');
//
//   @override
//   m.Node? parse(m.BlockParser parser) {
//     final match = pattern.firstMatch(parser.current)!;
//     parser.advance();
//     final element = m.Element.withTag(_dbTag);
//     final content = match.input;
//     element.attributes['id'] = content;
//     return element;
//   }
//
//   @override
//   RegExp get pattern => _pattern;
// }

class DBSyntax extends m.InlineSyntax {

  DBSyntax() : super(r'\(\(\w+\)\)');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    m.Element el = m.Element.withTag(_dbTag);
    final input = match.input;
    el.attributes['id'] = input.substring(match.start + 2, match.end - 2);
    parser.addNode(el);
    return true;
  }
}
