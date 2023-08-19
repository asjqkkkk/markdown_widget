import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/selection_transformer.dart';

import '../config/configs.dart';
import '../config/markdown_generator.dart';

///use [MarkdownBlock] to build markdown by [Column]
///it does not support scrolling by default, but it will adapt to the width automatically.
class MarkdownBlock extends StatelessWidget {
  ///the markdown data
  final String data;

  ///make text selectable
  final bool selectable;

  ///the configs of markdown
  final MarkdownConfig? config;

  ///config for [MarkdownGenerator]
  final MarkdownGeneratorConfig? markdownGeneratorConfig;

  const MarkdownBlock({
    Key? key,
    required this.data,
    this.selectable = true,
    this.config,
    this.markdownGeneratorConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final generatorConfig =
        markdownGeneratorConfig ?? MarkdownGeneratorConfig();
    final markdownGenerator = MarkdownGenerator(
      config: config,
      inlineSyntaxes: generatorConfig.inlineSyntaxList,
      blockSyntaxes: generatorConfig.blockSyntaxList,
      linesMargin: generatorConfig.linesMargin,
      generators: generatorConfig.generators,
      onNodeAccepted: generatorConfig.onNodeAccepted,
      textGenerator: generatorConfig.textGenerator,
    );
    final widgets = markdownGenerator.buildWidgets(data);
    final column = Column(
      children: widgets,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    return selectable ? SelectionArea(child: SelectionTransformer.separated(child: column)) : column;
  }
}
