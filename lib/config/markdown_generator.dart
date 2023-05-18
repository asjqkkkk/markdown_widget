import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

import '../widget/blocks/leaf/heading.dart';
import '../widget/widget_visitor.dart';
import 'configs.dart';
import 'toc.dart';

///use [MarkdownGenerator] to transform markdown data to [Widget] list, so you can render it by any type of [ListView]
class MarkdownGenerator {
  final MarkdownConfig config;
  final Iterable<m.InlineSyntax> inlineSyntaxes;
  final Iterable<m.BlockSyntax> blockSyntaxes;
  final EdgeInsets linesMargin;
  final List<SpanNodeGeneratorWithTag> generators;
  final SpanNodeAcceptCallback? onNodeAccepted;
  final TextNodeGenerator? textGenerator;

  MarkdownGenerator({
    MarkdownConfig? config,
    this.inlineSyntaxes = const [],
    this.blockSyntaxes = const [],
    this.linesMargin = const EdgeInsets.symmetric(vertical: 8),
    this.generators = const [],
    this.onNodeAccepted,
    this.textGenerator,
  }) : this.config = config ?? MarkdownConfig.defaultConfig;

  ///convert [data] to widgets
  ///[onTocList] can provider [Toc] list
  List<Widget> buildWidgets(String data,
      {ValueCallback<List<Toc>>? onTocList}) {
    final m.Document document = m.Document(
      extensionSet: m.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
      inlineSyntaxes: inlineSyntaxes,
      blockSyntaxes: blockSyntaxes,
    );
    final List<String> lines = data.split(RegExp(r'(\r?\n)|(\r?\t)|(\r)'));
    final List<m.Node> nodes = document.parseLines(lines);
    final List<Toc> tocList = [];
    final visitor = WidgetVisitor(
        config: config,
        generators: generators,
        textGenerator: textGenerator,
        onNodeAccepted: (node, index) {
          onNodeAccepted?.call(node, index);
          if (node is HeadingNode) {
            final listLength = tocList.length;
            tocList.add(
                Toc(node: node, widgetIndex: index, selfIndex: listLength));
          }
        });
    final spans = visitor.visit(nodes);
    onTocList?.call(tocList);
    final List<Widget> widgets = [];
    spans.forEach((span) {
      InlineSpan inlineSpan = span.build();
      if(inlineSpan is TextSpan){
        ///fix: line breaks are not effective when copying.
        ///see [https://github.com/asjqkkkk/markdown_widget/issues/105]
        ///see [https://github.com/asjqkkkk/markdown_widget/issues/95]
        inlineSpan.children?.add(TextSpan(text: '\r'));
      }
      widgets.add(Padding(
        padding: linesMargin,
        child: Text.rich(inlineSpan),
      ));
    });
    return widgets;
  }
}

///use [MarkdownGeneratorConfig] for [MarkdownGenerator]
class MarkdownGeneratorConfig {
  final Iterable<m.InlineSyntax> inlineSyntaxList;
  final Iterable<m.BlockSyntax> blockSyntaxList;
  final EdgeInsets linesMargin;
  final List<SpanNodeGeneratorWithTag> generators;
  final SpanNodeAcceptCallback? onNodeAccepted;
  final TextNodeGenerator? textGenerator;

  MarkdownGeneratorConfig({
    this.inlineSyntaxList = const [],
    this.blockSyntaxList = const [],
    this.linesMargin = const EdgeInsets.all(4),
    this.generators = const [],
    this.onNodeAccepted,
    this.textGenerator,
  });
}
