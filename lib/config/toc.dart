import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:markdown_widget/toc_widget.dart';

import '../widget/blocks/leaf/heading.dart';
import '../widget/markdown.dart';

///[TocController] combines [TocWidget] and [MarkdownWidget],
///you can use it to control the jump between the two,
/// and each [TocWidget] corresponds to a [MarkdownWidget].
class TocController extends ChangeNotifier {
  ///key is index of widgets, value is [Toc]
  final LinkedHashMap<int, Toc> _index2toc = LinkedHashMap();

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
    currentScrollIndex.value = getTocByWidgetIndex(index)?.widgetIndex;
  }

  void jumpToIndex(int index) {
    jumpIndex.value = getTocByWidgetIndex(index)?.widgetIndex;
  }

  Toc? getTocByWidgetIndex(int index) {
    if (_index2toc.containsKey(index)) {
      return _index2toc[index];
    }
    return null;
  }

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
