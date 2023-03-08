import 'package:flutter/material.dart';

///use [ProxyRichText] to give `textScaleFactor` a default value
class ProxyRichText extends StatelessWidget {
  final InlineSpan textSpan;
  final TextStyle? style;

  const ProxyRichText(
    this.textSpan, {
    Key? key,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      textSpan,
      textScaleFactor: 1.0,
      style: style,
    );
  }
}
