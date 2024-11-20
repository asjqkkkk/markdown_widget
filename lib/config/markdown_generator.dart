import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markdown/markdown.dart' as m;

import '../widget/blocks/leaf/heading.dart';
import '../widget/span_node.dart';
import '../widget/widget_visitor.dart';
import 'configs.dart';
import 'toc.dart';

///use [MarkdownGenerator] to transform markdown data to [Widget] list, so you can render it by any type of [ListView]
class MarkdownGenerator {
  final Iterable<m.InlineSyntax> inlineSyntaxList;
  final Iterable<m.BlockSyntax> blockSyntaxList;
  final EdgeInsets linesMargin;
  final List<SpanNodeGeneratorWithTag> generators;
  final SpanNodeAcceptCallback? onNodeAccepted;
  final m.ExtensionSet? extensionSet;
  final TextNodeGenerator? textGenerator;
  final SpanNodeBuilder? spanNodeBuilder;
  final RichTextBuilder? richTextBuilder;
  final RegExp? splitRegExp;

  MarkdownGenerator({
    this.inlineSyntaxList = const [],
    this.blockSyntaxList = const [],
    this.linesMargin = const EdgeInsets.symmetric(vertical: 8),
    this.generators = const [],
    this.onNodeAccepted,
    this.extensionSet,
    this.textGenerator,
    this.spanNodeBuilder,
    this.richTextBuilder,
    this.splitRegExp,
  });

  ///convert [data] to widgets
  ///[onTocList] can provider [Toc] list
  List<Widget> buildWidgets(
    String data, {
    void Function(SelectedContent? content)? onSelectionChanged,
    Future<void> Function(String)? onCopy,
    ValueCallback<List<Toc>>? onTocList,
    MarkdownConfig? config,
  }) {
    final mdConfig = config ?? MarkdownConfig.defaultConfig;
    final m.Document document = m.Document(
      extensionSet: extensionSet ?? m.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
      inlineSyntaxes: inlineSyntaxList,

      /// Overrides the standard used within the markdown package
      /// so that we can not use `CodeBlockSyntax` and instead just use `FencedCodeBlockSyntax` directly.
      ///
      /// Why: `CodeBlockSyntax` oddly detects lines with a 4-space indent and processes them as code blocks,
      /// which can have unintended & undesirable side-effects.
      blockSyntaxes: [
        const m.EmptyBlockSyntax(),
        const m.HtmlBlockSyntax(),
        const m.SetextHeaderSyntax(),
        const m.HeaderSyntax(),
        const m.FencedCodeBlockSyntax(),
        const m.BlockquoteSyntax(),
        const m.HorizontalRuleSyntax(),
        const m.UnorderedListSyntax(),
        const m.OrderedListSyntax(),
        const m.LinkReferenceDefinitionSyntax(),
        const m.ParagraphSyntax()
      ],
      withDefaultBlockSyntaxes: false,
    );
    final regExp = splitRegExp ?? WidgetVisitor.defaultSplitRegExp;
    final List<String> lines = data.split(regExp);
    final List<m.Node> nodes = document.parseLines(lines);
    final List<Toc> tocList = [];
    final visitor = WidgetVisitor(
      config: mdConfig,
      generators: generators,
      textGenerator: textGenerator,
      richTextBuilder: richTextBuilder,
      splitRegExp: regExp,
      onSelectionChanged: onSelectionChanged,
      onCopy: onCopy,
      onNodeAccepted: (node, index) {
        onNodeAccepted?.call(node, index);
        if (node is HeadingNode) {
          final listLength = tocList.length;
          tocList.add(Toc(node: node, widgetIndex: index, selfIndex: listLength));
        }
      },
    );
    final spans = visitor.visit(nodes);
    onTocList?.call(tocList);
    final List<Widget> widgets = [];
    for (var span in spans) {
      final textSpan = spanNodeBuilder?.call(span) ?? span.build();
      final richText = richTextBuilder?.call(textSpan) ?? Text.rich(textSpan);
      widgets.add(Padding(padding: linesMargin, child: richText));
    }
    return widgets;
  }
}

typedef SpanNodeBuilder = TextSpan Function(SpanNode spanNode);

typedef RichTextBuilder = Widget Function(InlineSpan span);
