import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';
import 'p.dart';

class Bq {
  Bq._internal();

  static Bq _instance;

  factory Bq() {
    _instance ??= Bq._internal();
    return _instance;
  }

  Widget getBlockQuote(m.Element node) {
    final blockConfig = StyleConfig().blockQuoteConfig;

    return Container(
      decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
                color: blockConfig?.blockColor ?? defaultBlockColor,
                width: blockConfig?.blockWidth ?? 4),
          ),
          color: blockConfig?.backgroundColor),
      padding: EdgeInsets.only(left: blockConfig?.leftSpace ?? 10),
      child: P().getPWidget(node.children, node,
          textStyle: blockConfig?.blockStyle ?? defaultBlockStyle),
    );
  }
}

class BlockQuoteConfig {
  final TextStyle blockStyle;
  final Color blockColor;
  final Color backgroundColor;
  final double blockWidth;
  final double leftSpace;

  BlockQuoteConfig({
    this.blockStyle,
    this.blockColor,
    this.backgroundColor,
    this.blockWidth,
    this.leftSpace,
  });
}
