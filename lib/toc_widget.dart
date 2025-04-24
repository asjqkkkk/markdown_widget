import 'package:flutter/material.dart';
import 'package:markdown_widget/config/toc.dart';
import 'package:markdown_widget/widget/blocks/leaf/heading.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:markdown_widget/widget/proxy_rich_text.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

const defaultTocTextStyle = TextStyle(fontSize: 16);
const defaultCurrentTocTextStyle = TextStyle(fontSize: 16, color: Colors.blue);

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

  /// use [tocTextStyle] to set the style of the toc item
  final TextStyle tocTextStyle;

  /// use [currentTocTextStyle] to set the style of the current toc item
  final TextStyle currentTocTextStyle;

  const TocWidget({
    Key? key,
    required this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemBuilder,
    TextStyle? tocTextStyle,
    TextStyle? currentTocTextStyle,
  })  : tocTextStyle = tocTextStyle ?? defaultTocTextStyle,
        currentTocTextStyle = currentTocTextStyle ?? defaultCurrentTocTextStyle,
        super(key: key);

  @override
  State<TocWidget> createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget> {
  final AutoScrollController controller = AutoScrollController();
  int currentIndex = 0;
  final List<Toc> _tocList = [];

  TocController get tocController => widget.controller;

  @override
  void initState() {
    super.initState();
    tocController.addListener(_onListChanged);
    tocController.currentScrollIndex.addListener(_onScrollIndexChanged);

    _refreshList(tocController.tocList);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _tocList.clear();
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
              index, currentToc, currentIndex, _refreshIndex));
          if (result != null) return result;
        }
        final node = currentToc.node.copy(
            headingConfig: _TocHeadingConfig(
                isCurrentToc ? widget.currentTocTextStyle : widget.tocTextStyle,
                currentToc.node.headingConfig.tag));
        final child = ListTile(
          title: Container(
            margin: EdgeInsets.only(
                left: 20.0 * (headingTag2Level[node.headingConfig.tag] ?? 1)),
            child: ProxyRichText(node.build()),
          ),
          onTap: () => _onTocItemTap(currentToc),
        );
        return wrapByAutoScroll(index, child, controller);
      },
      itemCount: _tocList.length,
      padding: widget.padding,
    );
  }

  void _onTocItemTap(Toc item) {
    tocController.jumpToIndex(item.widgetIndex);
    _refreshIndex(item.selfIndex);
    controller.scrollToIndex(currentIndex,
        preferPosition: AutoScrollPosition.begin);
  }

  void _onScrollIndexChanged() {
    final index = tocController.currentScrollIndex.value;
    if (index == null) return;

    final selfIndex = tocController.getTocByWidgetIndex(index)?.selfIndex;
    if (selfIndex != null && _tocList.length > selfIndex) {
      _refreshIndex(selfIndex);
      controller.scrollToIndex(currentIndex,
          preferPosition: AutoScrollPosition.begin);
    }
  }

  void _onListChanged() {
    final list = tocController.tocList;
    if (list.length < _tocList.length && currentIndex >= list.length) {
      currentIndex = list.length - 1;
    }
    _refreshList(list);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _refresh();
    });
  }

  void _refreshList(List<Toc> list) {
    _tocList.clear();
    _tocList.addAll(List.unmodifiable(list));
  }

  void _refreshIndex(int index) {
    currentIndex = index;
    _refresh();
  }

  void _refresh() {
    if (mounted) setState(() {});
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
