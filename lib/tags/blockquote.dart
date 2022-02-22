import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: blockquote
///the blockQuote widget
class BlockQuoteWidget extends StatelessWidget {
  final m.Element node;

  const BlockQuoteWidget({
    Key? key,
    required this.node,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = StyleConfig().blockQuoteConfig;

    return Container(
      decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
                color: config?.blockColor ?? defaultBlockColor!,
                width: config?.blockWidth ?? 4),
          ),
          color: config?.backgroundColor),
      padding: EdgeInsets.only(left: config?.leftSpace ?? 10),
      child: PWidget(
        children: node.children,
        parentNode: node,
        textStyle: config?.blockStyle ?? defaultBlockStyle,
        textConfig: config?.textConfig,
      ),
    );
  }
}

///config class for [BlockQuoteWidget]
class BlockQuoteConfig {
  final TextStyle? blockStyle;
  final TextConfig? textConfig;
  final Color? blockColor;
  final Color? backgroundColor;
  final double? blockWidth;
  final double? leftSpace;

  BlockQuoteConfig({
    this.blockStyle,
    this.textConfig,
    this.blockColor,
    this.backgroundColor,
    this.blockWidth,
    this.leftSpace,
  });
}
