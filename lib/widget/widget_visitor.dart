import 'package:flutter/cupertino.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';

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
  final MarkdownConfig config;

  /// add your custom [SpanNodeGeneratorWithTag] to [generators]
  /// that you can customize the conversion of Nodes
  final List<SpanNodeGeneratorWithTag> generators;

  ///this function will be triggered when a [SpanNode] is accepted
  final SpanNodeAcceptCallback? onNodeAccepted;

  ///use [textGenerator] to custom your own [TextNode]
  final TextNodeGenerator? textGenerator;

  WidgetVisitor({
    MarkdownConfig? config,
    this.generators = const [],
    this.onNodeAccepted,
    this.textGenerator,
  }) : this.config = config ?? MarkdownConfig.defaultConfig;

  ///[visit] will return a [SpanNode] list
  List<SpanNode> visit(List<m.Node> nodes) {
    generators.forEach((e) {
      _tag2node[e.tag] = e.generator;
    });
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
    MarkdownTag.h1.name: (e, config, visitor) => HeadingNode(config.h1),
    MarkdownTag.h2.name: (e, config, visitor) => HeadingNode(config.h2),
    MarkdownTag.h3.name: (e, config, visitor) => HeadingNode(config.h3),
    MarkdownTag.h4.name: (e, config, visitor) => HeadingNode(config.h4),
    MarkdownTag.h5.name: (e, config, visitor) => HeadingNode(config.h5),
    MarkdownTag.h6.name: (e, config, visitor) => HeadingNode(config.h6),
    MarkdownTag.li.name: (e, config, visitor) => ListNode(config),
    MarkdownTag.ol.name: (e, config, visitor) =>
        UlOrOLNode(e.tag, e.attributes, config.li),
    MarkdownTag.ul.name: (e, config, visitor) =>
        UlOrOLNode(e.tag, e.attributes, config.li),
    MarkdownTag.blockquote.name: (e, config, visitor) =>
        BlockquoteNode(config.blockquote),
    MarkdownTag.pre.name: (e, config, visitor) =>
        CodeBlockNode(e.textContent, config.pre),
    MarkdownTag.hr.name: (e, config, visitor) => HrNode(config.hr),
    MarkdownTag.table.name: (e, config, visitor) => TableNode(config),
    MarkdownTag.thead.name: (e, config, visitor) => THeadNode(config),
    MarkdownTag.tbody.name: (e, config, visitor) => TBodyNode(config),
    MarkdownTag.tr.name: (e, config, visitor) => TrNode(),
    MarkdownTag.th.name: (e, config, visitor) => ThNode(),
    MarkdownTag.td.name: (e, config, visitor) => TdNode(e.attributes),
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
        ImageNode(e.attributes, config),
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
