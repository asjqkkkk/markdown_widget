import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag:  p
///the paragraph widget
class PWidget extends StatelessWidget {
  final List<m.Node>? children;
  final m.Node parentNode;
  final TextStyle? textStyle;
  final TextConfig? textConfig;
  final WrapCrossAlignment crossAxisAlignment;

  const PWidget({
    Key? key,
    this.children,
    required this.parentNode,
    this.textStyle,
    this.textConfig,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildRichText(children, parentNode, textStyle, textConfig, context);
  }

  Widget buildRichText(List<m.Node>? children, m.Node parentNode,
      TextStyle? textStyle, TextConfig? textConfig, BuildContext context) {
    final config = StyleConfig().pConfig;
    return Text.rich(
      getBlockSpan(children, parentNode,
          textStyle ?? config?.textStyle ?? defaultPStyle),
      textAlign: textConfig?.textAlign ??
          config?.textConfig?.textAlign ??
          TextAlign.start,
      textDirection:
          textConfig?.textDirection ?? config?.textConfig?.textDirection,
    );
  }
}

///config class for [PWidget]
class PConfig {
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextStyle? delStyle;
  final TextStyle? emStyle;
  final TextStyle? strongStyle;
  final TextConfig? textConfig;
  final OnLinkTap? onLinkTap;
  final Custom? custom;

  PConfig({
    this.textStyle,
    this.linkStyle,
    this.delStyle,
    this.emStyle,
    this.strongStyle,
    this.textConfig,
    this.onLinkTap,
    this.custom,
  });
}

///config class for [TextStyle]
class TextConfig {
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  TextConfig({this.textAlign, this.textDirection});
}

typedef void OnLinkTap(String? url);
typedef Widget LinkGesture(Widget linkWidget, String? url);
typedef Widget Custom(m.Element element);
