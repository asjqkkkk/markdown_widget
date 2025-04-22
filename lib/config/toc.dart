import 'package:flutter/foundation.dart';

import 'package:markdown_widget/config/toc_widget.dart';

import '../widget/blocks/leaf/heading.dart';
import '../widget/markdown.dart';

///[TocController] combines [TocWidget] and [MarkdownWidget],
///you can use it to control the jump between the two,
/// and each [TocWidget] corresponds to a [MarkdownWidget].

import 'package:flutter/material.dart';

class TocController extends ChangeNotifier {
  final Map<int, Toc> _index2toc = {};
  final ValueNotifier<int?> currentScrollIndex = ValueNotifier(null);
  final ValueNotifier<int?> jumpIndex = ValueNotifier(null);

  List<Toc> get tocList => _index2toc.values.toList(growable: false);

  void setTocList(List<Toc> list) {
    _index2toc
      ..clear()
      ..addEntries(list.map((e) => MapEntry(e.widgetIndex, e)));
    notifyListeners();
  }

  void onScrollIndexChanged(int index) {
    if (_index2toc.containsKey(index)) {
      currentScrollIndex.value = getTocByWidgetIndex(index)?.selfIndex;
    }
  }

  void jumpToIndex(int index) {
    jumpIndex.value = tocList[index].widgetIndex;
  }

  Toc? getTocByWidgetIndex(int index) => _index2toc[index];

  @override
  void dispose() {
    currentScrollIndex.dispose();
    jumpIndex.dispose();
    super.dispose();
  }
}

///config for toc
class Toc {
  ///the HeadingNode
  final HeadingNode node;

  ///index of [MarkdownGenerator]'s _children
  final int widgetIndex;

  ///index of [TocController.tocList]
  final int selfIndex;

  Toc({
    required this.node,
    this.widgetIndex = 0,
    this.selfIndex = 0,
  });
}
