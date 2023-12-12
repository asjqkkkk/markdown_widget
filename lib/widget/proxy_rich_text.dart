import 'package:flutter/material.dart';

import '../config/markdown_generator.dart';

///use [ProxyRichText] to give `textScaleFactor` a default value
class ProxyRichText extends StatelessWidget {
  final InlineSpan textSpan;
  final RichTextBuilder? richTextBuilder;

  const ProxyRichText(
    this.textSpan, {
    Key? key,
    this.richTextBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return richTextBuilder?.call(textSpan) ?? Text.rich(textSpan);
  }
}
