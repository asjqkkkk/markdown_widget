import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: hr
class Hr {
  Hr._internal();

  static Hr _instance;

  factory Hr() {
    _instance ??= Hr._internal();
    return _instance;
  }

  ///the hr widget
  Widget getHrWidget(m.Element node) {
    final HrConfig hrConfig = StyleConfig().hrConfig;

    return Container(
      height: hrConfig?.height ?? 2,
      color: hrConfig?.color ?? defaultDividerColor,
    );
  }
}

class HrConfig {
  final double height;
  final Color color;

  HrConfig({this.height, this.color});
}
