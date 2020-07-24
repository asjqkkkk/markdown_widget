import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: input
InlineSpan getInputSpan(m.Element node) {
  bool checked = true;
  if (node.attributes['checked'] != null) {
    checked = node.attributes['checked'].toLowerCase() == 'true';
  }
  return WidgetSpan(
    child: StyleConfig()?.checkBoxBuilder?.call(checked, node.attributes) ??
        defaultCheckBox(node.attributes, checked: checked),
  );
}

///the check box widget
Widget defaultCheckBox(
  Map<String, String> attributes, {
  bool checked,
}) {
  if (checked == null && attributes['checked'] != null) {
    checked = attributes['checked'].toLowerCase() == 'true';
  }
  if (checked == null) checked = true;
  final config = StyleConfig()?.checkBoxConfig;
  return MCheckBox(
    value: checked,
    config: config,
  );
}

typedef Widget CheckBoxBuilder(bool checked, Map<String, String> attributes);

class CheckBoxConfig {
  final Color color;
  final double size;

  CheckBoxConfig({this.color, this.size});
}

class MCheckBox extends StatefulWidget {
  final CheckBoxConfig config;
  final bool value;

  const MCheckBox({Key key, this.config, this.value = true}) : super(key: key);

  @override
  _MCheckBoxState createState() => _MCheckBoxState();
}

class _MCheckBoxState extends State<MCheckBox> {
  bool value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        value ? Icons.check_box : Icons.check_box_outline_blank,
        size: widget.config?.size ?? 15,
        color: widget.config?.color,
      ),
      onTap: () {
        setState(() {
          value = !value;
        });
      },
    );
  }
}
