import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/configs.dart';
import '../../span_node.dart';

///Tag: [MarkdownTag.hr]
///
///the horizontal rules widget
///eg: `---`, `_ _ _`, `*  *  *`, etc.
class HrNode extends SpanNode {
  final HrConfig hrConfig;

  HrNode(this.hrConfig);

  @override
  InlineSpan build() {
    return WidgetSpan(
        child: Container(
      height: hrConfig.height,
      color: hrConfig.color,
    ));
  }
}

///config class for [HrNode]
class HrConfig implements LeafConfig {
  final double height;
  final Color color;

  const HrConfig({this.height = 2, this.color = const Color(0xFFd0d7de)});

  @nonVirtual
  @override
  String get tag => MarkdownTag.hr.name;

  static HrConfig get darkConfig => const HrConfig(color: Colors.white);
}
