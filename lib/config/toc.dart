import 'dart:collection';

import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/config/toc_widget.dart';

import '../widget/blocks/leaf/heading.dart';
import '../widget/markdown.dart';

///[TocController] combines [TocWidget] and [MarkdownWidget],
///you can use it to control the jump between the two,
/// and each [TocWidget] corresponds to a [MarkdownWidget].
class TocController {
  ///key is index of widgets, value is [Toc]
  LinkedHashMap<int, Toc> get index2toc => LinkedHashMap();

  ValueCallback<int>? jumpToIndexCallback;
  ValueCallback<int>? onIndexChangedCallback;
  ValueCallback<List<Toc>>? onListChanged;

  List<Toc> get tocList => List.unmodifiable(index2toc.values);

  void setTocList(List<Toc> list) {
    index2toc.clear();
    for (final toc in list) {
      index2toc[toc.widgetIndex] = toc;
    }
    onListChanged?.call(list);
  }

  void dispose() {
    index2toc.clear();
    onIndexChangedCallback = null;
    jumpToIndexCallback = null;
    onListChanged = null;
  }

  void jumpToIndex(int index) {
    jumpToIndexCallback?.call(index);
  }

  void onIndexChanged(int index) {
    onIndexChangedCallback?.call(index);
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
