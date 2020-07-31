import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';
import 'p.dart';

///Tag: blockquote
class Bq {
  Bq._internal();

  static Bq _instance;

  factory Bq() {
    _instance ??= Bq._internal();
    return _instance;
  }

  ///the blockQuote widget
  Widget getBlockQuote(m.Element node) {
    final config = StyleConfig().blockQuoteConfig;

    return Container(
      decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
                color: config?.blockColor ?? defaultBlockColor,
                width: config?.blockWidth ?? 4),
          ),
          color: config?.backgroundColor),
      padding: EdgeInsets.only(left: config?.leftSpace ?? 10),
      child: P().getPWidget(node.children, node,
          textStyle: config?.blockStyle ?? defaultBlockStyle,
          textConfig: config?.textConfig),
    );
  }
}

class BlockQuoteConfig {
  final TextStyle blockStyle;
  final TextConfig textConfig;
  final Color blockColor;
  final Color backgroundColor;
  final double blockWidth;
  final double leftSpace;

  BlockQuoteConfig({
    this.blockStyle,
    this.textConfig,
    this.blockColor,
    this.backgroundColor,
    this.blockWidth,
    this.leftSpace,
  });
}
