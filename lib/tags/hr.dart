import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: hr
///the hr widget
class HrWidget extends StatelessWidget {
  final m.Element node;

  const HrWidget({
    Key? key,
    required this.node,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HrConfig? hrConfig = StyleConfig().hrConfig;

    return Container(
      height: hrConfig?.height ?? 2,
      color: hrConfig?.color ?? defaultDividerColor,
    );
  }
}

///config class for [HrWidget]
class HrConfig {
  final double? height;
  final Color? color;

  HrConfig({this.height, this.color});
}
