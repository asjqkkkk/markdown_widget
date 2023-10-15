import 'package:flutter/material.dart';

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

  ///to generator markdown data
  final MarkdownGenerator? generator;

  const MarkdownBlock({
    Key? key,
    required this.data,
    this.selectable = true,
    this.config,
    this.generator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markdownGenerator = generator ?? MarkdownGenerator();
    final widgets = markdownGenerator.buildWidgets(data, config: config);
    final column = Column(
      children: widgets,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    return selectable ? SelectionArea(child: column) : column;
  }
}
