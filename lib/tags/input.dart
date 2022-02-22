import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: input
InlineSpan getInputSpan(m.Element node) {
  bool checked = true;
  if (node.attributes['checked'] != null) {
    checked = node.attributes['checked']!.toLowerCase() == 'true';
  }
  return WidgetSpan(
    child: StyleConfig().checkBoxBuilder?.call(checked, node.attributes) ??
        MCheckBox(
            attributes: node.attributes, config: StyleConfig().checkBoxConfig),
  );
}

typedef Widget CheckBoxBuilder(bool checked, Map<String, String> attributes);

///config class for [MCheckBox]
class CheckBoxConfig {
  final Color? color;
  final double? size;

  CheckBoxConfig({this.color, this.size});
}

///the check box widget
class MCheckBox extends StatefulWidget {
  final CheckBoxConfig? config;
  final Map<String, String> attributes;

  const MCheckBox({
    Key? key,
    this.config,
    required this.attributes,
  }) : super(key: key);

  @override
  _MCheckBoxState createState() => _MCheckBoxState();
}

class _MCheckBoxState extends State<MCheckBox> {
  late bool value;

  @override
  void initState() {
    bool checked = false;
    if (widget.attributes['checked'] != null) {
      checked = widget.attributes['checked']!.toLowerCase() == 'true';
    }
    value = checked;
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
