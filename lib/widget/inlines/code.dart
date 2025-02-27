import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runtime_client/foundation.dart';
import 'package:runtime_client/particle.dart';

import '../../config/configs.dart';
import '../../state/state.dart';
import '../span_node.dart';

///Tag:  [MarkdownTag.code]
///the code textSpan
class CodeNode extends ElementNode {
  final CodeConfig codeConfig;
  final String text;

  CodeNode(this.text, this.codeConfig);

  @override
  InlineSpan build() {
    String? query = MarkdownRenderingState().query;

    if (query == null) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: codeConfig.style.backgroundColor,
            borderRadius: ParticleRounding.extraSmall,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              text,
              style: codeConfig.style.merge(parentStyle).codeFont.copyWith(
                    fontSize: (codeConfig.style.fontSize ?? 14) * 0.9,
                    backgroundColor: Colors.transparent,
                  ),
            ),
          ),
        ),
      );
    }

    List<InlineSpan> children = [];

    text.splitMapJoin(
      RegExp(RegExp.escape(query), caseSensitive: false, unicode: true),
      onMatch: (Match match) {
        children.add(TextSpan(
          text: match.group(0),
          style: style.merge(parentStyle).copyWith(color: Colors.black, backgroundColor: Colors.yellow),
        ));

        return '';
      },
      onNonMatch: (value) {
        children.add(TextSpan(
          text: value,
          style: style.merge(parentStyle),
        ));

        return '';
      },
    );

    return TextSpan(
      children: children,
    );
  }

  @override
  TextStyle get style => codeConfig.style.merge(parentStyle);
}

///config class for code, tag: code
class CodeConfig implements InlineConfig {
  final TextStyle style;

  const CodeConfig({this.style = const TextStyle(backgroundColor: Color(0xCCeff1f3))});

  static CodeConfig get darkConfig => CodeConfig(style: const TextStyle(backgroundColor: Color(0xCC555555)));

  @nonVirtual
  @override
  String get tag => MarkdownTag.code.name;
}
