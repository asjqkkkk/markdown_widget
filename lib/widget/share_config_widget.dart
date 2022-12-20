import 'package:flutter/material.dart';

import '../config/configs.dart';

class ShareConfigWidget extends InheritedWidget {
  ShareConfigWidget({
    Key? key,
    required this.config,
    required Widget child,
  }) : super(key: key, child: child);

  ///[config] will be shared in subtrees
  final MarkdownConfig config;

  ///get [ShareConfigWidget] from [context]
  static ShareConfigWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShareConfigWidget>();
  }

  @override
  bool updateShouldNotify(ShareConfigWidget old) {
    return old.config != config;
  }
}