import 'package:flutter/cupertino.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';

import '../config/markdown_generator.dart';

///use [WidgetVisitor] that can transform MarkdownNode to [SpanNode]s
///and you can use [SpanNode] with [Text.rich] or [RichText] to get widget
class WidgetVisitor implements m.NodeVisitor {
  ///remain the result of [visit] function
  final List<SpanNode> _spans = [];

  ///the index of [_spans]
  int _currentSpanIndex = 0;

  ///[visitElementBefore] will push a [SpanNode] onto [_spansStack]
  ///[visitElementAfter] will pop the last [SpanNode] off
  final List<SpanNode> _spansStack = [];

  ///[MarkdownConfig] is used to define the UI display
  late MarkdownConfig config;

  /// add your custom [SpanNodeGeneratorWithTag] to [generators]
  /// that you can customize the conversion of Nodes
  final List<SpanNodeGeneratorWithTag> generators;

  ///this function will be triggered when a [SpanNode] is accepted
  final SpanNodeAcceptCallback? onNodeAccepted;

  ///use [textGenerator] to custom your own [TextNode]
  final TextNodeGenerator? textGenerator;

  ///use [richTextBuilder] to custom your own [Text.rich]
  final RichTextBuilder? richTextBuilder;

  ///use [splitRegExp] to split markdown data
  final RegExp? splitRegExp;

  static RegExp defaultSplitRegExp = RegExp(r'(\r?\n)|(\r)');

  WidgetVisitor({
    MarkdownConfig? config,
    this.generators = const [],
    this.onNodeAccepted,
    this.textGenerator,
    this.richTextBuilder,
    this.splitRegExp,
  }) {
    this.config = config ?? MarkdownConfig.defaultConfig;
    for (var e in generators) {
      _tag2node[e.tag] = e.generator;
    }
  }

  ///[visit] will return a [SpanNode] list
  List<SpanNode> visit(List<m.Node> nodes) {
    _spans.clear();
    _currentSpanIndex = 0;
    for (final node in nodes) {
      final emptyNode = ConcreteElementNode();
      _spans.add(emptyNode);
      _currentSpanIndex = _spans.length - 1;
      _spansStack.add(emptyNode);
      node.accept(this);
      _spansStack.removeLast();
    }
    final result = List.of(_spans);
    _spans.clear();
    _spansStack.clear();
    return result;
  }

  @override
  bool visitElementBefore(m.Element element) {
    final node = getNodeByElement(element, config);
    final last = _spansStack.last;
    if (last is ElementNode) {
      last.accept(node);
      onNodeAccepted?.call(node, _currentSpanIndex);
    }
    _spansStack.add(node);

    return true;
  }

  @override
  void visitElementAfter(m.Element element) {
    _spansStack.removeLast();
  }

  @override
  void visitText(m.Text text) {
    final last = _spansStack.last;
    if (last is ElementNode) {
      final textNode = textGenerator?.call(text, config, this) ??
          TextNode(text: text.text, style: config.p.textStyle);
      last.accept(textNode);
      onNodeAccepted?.call(textNode, _currentSpanIndex);
    }
  }

  ///every tag has it's own [SpanNodeGenerator]
  final _tag2node = <String, SpanNodeGenerator>{
    MarkdownTag.h1.name: (e, config, visitor) =>
        HeadingNode(config.h1, visitor),
    MarkdownTag.h2.name: (e, config, visitor) =>
        HeadingNode(config.h2, visitor),
    MarkdownTag.h3.name: (e, config, visitor) =>
        HeadingNode(config.h3, visitor),
    MarkdownTag.h4.name: (e, config, visitor) =>
        HeadingNode(config.h4, visitor),
    MarkdownTag.h5.name: (e, config, visitor) =>
        HeadingNode(config.h5, visitor),
    MarkdownTag.h6.name: (e, config, visitor) =>
        HeadingNode(config.h6, visitor),
    MarkdownTag.li.name: (e, config, visitor) => ListNode(config, visitor),
    MarkdownTag.ol.name: (e, config, visitor) =>
        UlOrOLNode(e.tag, e.attributes, config.li, visitor),
    MarkdownTag.ul.name: (e, config, visitor) =>
        UlOrOLNode(e.tag, e.attributes, config.li, visitor),
    MarkdownTag.blockquote.name: (e, config, visitor) =>
        BlockquoteNode(config.blockquote, visitor),
    MarkdownTag.pre.name: (e, config, visitor) =>
        CodeBlockNode(e, config.pre, visitor),
    MarkdownTag.hr.name: (e, config, visitor) => HrNode(config.hr),
    MarkdownTag.table.name: (e, config, visitor) => TableNode(config),
    MarkdownTag.thead.name: (e, config, visitor) => THeadNode(config, visitor),
    MarkdownTag.tbody.name: (e, config, visitor) => TBodyNode(config, visitor),
    MarkdownTag.tr.name: (e, config, visitor) => TrNode(),
    MarkdownTag.th.name: (e, config, visitor) => ThNode(),
    MarkdownTag.td.name: (e, config, visitor) => TdNode(e.attributes, visitor),
    MarkdownTag.p.name: (e, config, visitor) => ParagraphNode(config.p),
    MarkdownTag.input.name: (e, config, visitor) =>
        InputNode(e.attributes, config),
    MarkdownTag.a.name: (e, config, visitor) =>
        LinkNode(e.attributes, config.a),
    MarkdownTag.del.name: (e, config, visitor) => DelNode(),
    MarkdownTag.strong.name: (e, config, visitor) => StrongNode(),
    MarkdownTag.em.name: (e, config, visitor) => EmNode(),
    MarkdownTag.br.name: (e, config, visitor) => BrNode(),
    MarkdownTag.code.name: (e, config, visitor) =>
        CodeNode(e.textContent, config.code),
    MarkdownTag.img.name: (e, config, visitor) =>
        ImageNode(e.attributes, config, visitor),
  };

  SpanNode getNodeByElement(m.Element element, MarkdownConfig config) {
    return _tag2node[element.tag]?.call(element, config, this) ??
        textGenerator?.call(element, config, this) ??
        TextNode(text: element.textContent);
  }
}

///use [SpanNodeGenerator] will return a [SpanNode]
typedef SpanNodeGenerator = SpanNode Function(
    m.Element e, MarkdownConfig config, WidgetVisitor visitor);

///use [TextNodeGenerator] to custom your own [TextNode]
typedef TextNodeGenerator = SpanNode? Function(
    m.Node node, MarkdownConfig config, WidgetVisitor visitor);

///when a [SpanNope] is visited, this callback will be triggered
typedef SpanNodeAcceptCallback = void Function(SpanNode node, int nodeIndex);

///use [SpanNodeGeneratorWithTag] that you can custom your own [SpanNodeGenerator] with tag
class SpanNodeGeneratorWithTag {
  final String tag;
  final SpanNodeGenerator generator;

  SpanNodeGeneratorWithTag({required this.tag, required this.generator});
}

///wrap [child] by another widget
typedef WidgetWrapper = Widget Function(Widget child);
