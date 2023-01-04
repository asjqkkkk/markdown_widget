import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../config/configs.dart';
import '../../span_node.dart';


///Tag: [MarkdownTag.p]
///
///A sequence of non-blank lines that cannot be interpreted as other kinds of blocks forms a paragraph
class ParagraphNode extends ElementNode {
  final PConfig pConfig;

  ParagraphNode(this.pConfig);

  @override
  InlineSpan build() {
    return TextSpan(
        children: List.generate(children.length, (index) {
      final child = children[index];
      return child.build();
    }));
  }

  @override
  TextStyle? get style => pConfig.textStyle.merge(parentStyle);
}

///config class for paragraphs, tag: p
class PConfig implements LeafConfig {
  final TextStyle textStyle;

  const PConfig({this.textStyle = const TextStyle(fontSize: 16)});

  static PConfig get darkConfig =>
      PConfig(textStyle: const TextStyle(fontSize: 16));

  @nonVirtual
  @override
  String get tag => MarkdownTag.p.name;
}

///Tag: [MarkdownTag.del]
///
///double '~'swill be wrapped with an HTML <del> tag.
class DelNode extends ElementNode {
  @override
  TextStyle get style =>
      TextStyle(decoration: TextDecoration.lineThrough).merge(parentStyle);
}

///Tag: [MarkdownTag.strong]
///
/// double '*'s or '_'s will be wrapped with an HTML <strong> tag.
class StrongNode extends ElementNode {
  @override
  TextStyle get style =>
      TextStyle(fontWeight: FontWeight.bold).merge(parentStyle);
}

///Tag: [MarkdownTag.em]
///
/// emphasis, Markdown treats asterisks (*) and underscores (_) as indicators of emphasis
class EmNode extends ElementNode {
  @override
  TextStyle get style =>
      TextStyle(fontStyle: FontStyle.italic).merge(parentStyle);
}

///Tag: [MarkdownTag.br]
///
///  a hard line break
class BrNode extends SpanNode {
  @override
  InlineSpan build() {
    return TextSpan(text: '\n', style: parentStyle);
  }
}
