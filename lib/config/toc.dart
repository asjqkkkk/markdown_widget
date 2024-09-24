import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../widget/blocks/leaf/heading.dart';
import '../widget/markdown.dart';
import '../widget/proxy_rich_text.dart';

///[TocController] combines [TocWidget] and [MarkdownWidget],
///you can use it to control the jump between the two,
/// and each [TocWidget] corresponds to a [MarkdownWidget].
class TocController {
  ///key is index of widgets, value is [Toc]
  final LinkedHashMap<int, Toc> _index2toc = LinkedHashMap();

  ValueCallback<int>? _jumpToIndexCallback;
  ValueCallback<int>? _onIndexChangedCallback;
  ValueCallback<List<Toc>>? _onListChanged;

  void setTocList(List<Toc> list) {
    _index2toc.clear();
    for (final toc in list) {
      _index2toc[toc.widgetIndex] = toc;
    }
    _onListChanged?.call(list);
  }

  set jumpToIndexCallback(ValueCallback<int>? value) {
    _jumpToIndexCallback = value;
  }

  List<Toc> get tocList => List.unmodifiable(_index2toc.values);

  void dispose() {
    _index2toc.clear();
    _onIndexChangedCallback = null;
    _jumpToIndexCallback = null;
    _onListChanged = null;
  }

  void jumpToIndex(int index) {
    _jumpToIndexCallback?.call(index);
  }

  void onIndexChanged(int index) {
    _onIndexChangedCallback?.call(index);
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

class TocWidget extends StatefulWidget {
  ///[controller] must not be null
  final TocController controller;

  ///set the desired scroll physics for the markdown item list
  final ScrollPhysics? physics;

  ///set shrinkWrap to obtained [ListView] (only available when [tocController] is null)
  final bool shrinkWrap;

  /// [ListView] padding
  final EdgeInsetsGeometry? padding;

  ///use [itemBuilder] to return a custom widget
  final TocItemBuilder? itemBuilder;

  const TocWidget({
    Key? key,
    required this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemBuilder,
  }) : super(key: key);

  @override
  State<TocWidget> createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget> {
  final AutoScrollController controller = AutoScrollController();
  int currentIndex = 0;
  final List<Toc> _tocList = [];

  TocController get tocController => widget.controller;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tocController._onListChanged = (list) {
      if (list.length < _tocList.length && currentIndex >= list.length) {
        currentIndex = list.length - 1;
      }
      _refreshList(list);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        refresh();
      });
    };
    tocController._onIndexChangedCallback = (index) {
      final selfIndex = tocController._index2toc[index]?.selfIndex;
      if (selfIndex != null && _tocList.length > selfIndex) {
        refreshIndex(selfIndex);
        controller.scrollToIndex(currentIndex,
            preferPosition: AutoScrollPosition.begin);
      }
    };
    _refreshList(tocController.tocList);
  }

  void _refreshList(List<Toc> list) {
    _tocList.clear();
    _tocList.addAll(List.unmodifiable(list));
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _tocList.clear();
    tocController._onIndexChangedCallback = null;
    tocController._onListChanged = null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      controller: controller,
      itemBuilder: (ctx, index) {
        final currentToc = _tocList[index];
        bool isCurrentToc = index == currentIndex;
        final itemBuilder = widget.itemBuilder;
        if (itemBuilder != null) {
          final result = itemBuilder.call(TocItemBuilderData(
              index, currentToc, currentIndex, refreshIndex));
          if (result != null) return result;
        }
        final node = currentToc.node.copy(
            headingConfig: _TocHeadingConfig(
                TextStyle(
                    fontSize: 16, color: isCurrentToc ? Colors.blue : null),
                currentToc.node.headingConfig.tag));
        final child = ListTile(
          title: Container(
            margin: EdgeInsets.only(
                left: 20.0 * (headingTag2Level[node.headingConfig.tag] ?? 1)),
            child: ProxyRichText(node.build()),
          ),
          onTap: () {
            tocController.jumpToIndex(currentToc.widgetIndex);
            refreshIndex(index);
          },
        );
        return wrapByAutoScroll(index, child, controller);
      },
      itemCount: _tocList.length,
      padding: widget.padding,
    );
  }

  void refreshIndex(int index) {
    currentIndex = index;
    refresh();
  }
}

///use [TocItemBuilder] to return a custom widget
typedef TocItemBuilder = Widget? Function(TocItemBuilderData data);

///pass [TocItemBuilderData] to help build your own [TocItemBuilder]
class TocItemBuilderData {
  ///the index of item
  final int index;

  ///the toc data
  final Toc toc;

  ///current selected index of item
  final int currentIndex;

  ///use [refreshIndexCallback] to change [currentIndex]
  final ValueChanged<int> refreshIndexCallback;

  TocItemBuilderData(
      this.index, this.toc, this.currentIndex, this.refreshIndexCallback);
}

///every heading tag has a special level
final headingTag2Level = <String, int>{
  'h1': 1,
  'h2': 2,
  'h3': 3,
  'h4': 5,
  'h5': 5,
  'h6': 6,
};

class _TocHeadingConfig extends HeadingConfig {
  @override
  final TextStyle style;
  @override
  final String tag;

  _TocHeadingConfig(this.style, this.tag);
}
