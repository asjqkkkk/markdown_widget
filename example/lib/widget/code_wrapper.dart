import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;

  const CodeWrapperWidget({Key? key, required this.child, required this.text})
      : super(key: key);

  @override
  State<CodeWrapperWidget> createState() => _PreWrapperState();
}

class _PreWrapperState extends State<CodeWrapperWidget> {
  late Widget _switchWidget;
  bool hasCopied = false;

  @override
  void initState() {
    super.initState();
    _switchWidget = Icon(Icons.copy_rounded, key: UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              child: AnimatedSwitcher(
                child: _switchWidget,
                duration: Duration(milliseconds: 200),
              ),
              onTap: () async {
                if (hasCopied) return;
                await Clipboard.setData(ClipboardData(text: widget.text));
                _switchWidget = Icon(Icons.check, key: UniqueKey());
                refresh();
                Future.delayed(Duration(seconds: 2), () {
                  hasCopied = false;
                  _switchWidget = Icon(Icons.copy_rounded, key: UniqueKey());
                  refresh();
                });
              },
            ),
          ),
          alignment: Alignment.topRight,
        )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
