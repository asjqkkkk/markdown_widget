import 'package:flutter/material.dart';
import 'package:markdown_widget/config/toc.dart';
import 'package:markdown_widget/widget/blocks/leaf/heading.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:markdown_widget/widget/proxy_rich_text.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CustomTocWidget extends StatefulWidget {
  ///[controller] must not be null
  final TocController controller;

  const CustomTocWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomTocWidget> createState() => _CustomTocWidgetState();
}

class _CustomTocWidgetState extends State<CustomTocWidget> {
  final AutoScrollController controller = AutoScrollController();
  int currentIndex = 0;
  final List<Toc> _tocList = [];

  TocController get tocController => widget.controller;

  OverlayPortalController overlayPortalController = OverlayPortalController();

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tocController.addListener(_onTocListChange);
    tocController.currentScrollIndex.addListener(_onScrollUpdate);

    // tocController.onIndexChangedCallback = (index) {
    //   final selfIndex = tocController._index2toc[index]?.selfIndex;
    //   if (selfIndex != null && _tocList.length > selfIndex) {
    //     refreshIndex(selfIndex);
    //     controller.scrollToIndex(currentIndex,
    //         preferPosition: AutoScrollPosition.begin);
    //   }
    // };

    _refreshList(tocController.tocList);
  }

  void _onTocListChange() {
    final list = tocController.tocList;
    if (list.length < _tocList.length && currentIndex >= list.length) {
      currentIndex = list.length - 1;
    }
    _refreshList(list);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      refresh();
    });
  }

  void _onScrollUpdate() {
    final index = tocController.currentScrollIndex.value;
    if (index == null) return;
    setState(() => currentIndex = index);
  }

  void _onTocItemTap(int index) {
    tocController.jumpToIndex(index);
    _refreshIndex(index);
  }

  void _refreshList(List<Toc> list) {
    _tocList.clear();
    _tocList.addAll(list);
  }

  @override
  void dispose() {
    tocController.currentScrollIndex.removeListener(_onScrollUpdate);
    _tocList.clear();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        overlayPortalController.toggle();
      },
      child: OverlayPortal(
        controller: overlayPortalController,
        overlayChildBuilder: (BuildContext context) {
          return Positioned(
            top: 100.0, // Simplified for now
            left: 50.0, // Simplified for now
            width: 200,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  _tocList.length,
                  (index) {
                    final currentToc = _tocList[index];
                    bool isActiveToc = index == currentIndex;

                    final node = _genTocHeadingNode(currentToc, isActiveToc);
                    ;
                    final child = Container(
                      margin: EdgeInsets.only(
                          left: 20.0 *
                              (headingTag2Level[node.headingConfig.tag] ?? 1)),
                      child: InkWell(
                        child: ProxyRichText(node.build()),
                        onTap: () => _onTocItemTap(index),
                      ),
                    );
                    return wrapByAutoScroll(index, child, controller);
                  },
                ),
              ),
            ),
          );
        },
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            _tocList.length,
            (index) {
              final currentToc = _tocList[index];
              print('${_tocList[index].widgetIndex} == $currentIndex');
              bool isActiveToc = index == currentIndex;

              var tag = currentToc.node.headingConfig.tag;
              return Container(
                height: 2,
                width: 10.0 * (7 - (headingTag2Level[tag] ?? 1)),
                color: isActiveToc ? Colors.blue : Colors.amber,
              );
            },
          ),
        ),
      ),
    );
  }

  HeadingNode _genTocHeadingNode(Toc currentToc, bool isActiveToc) {
    return currentToc.node.copy(
      headingConfig: _TocHeadingConfig(
        TextStyle(
          fontSize: 16,
          color: isActiveToc ? Colors.blue : null,
        ),
        currentToc.node.headingConfig.tag,
      ),
    );
  }

  void _refreshIndex(int index) {
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
  'h4': 4,
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
