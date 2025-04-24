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
  int currentIndex = 0;
  final List<Toc> _tocList = [];
  final LayerLink _layerLink = LayerLink();

  final AutoScrollController autoScrollController = AutoScrollController();
  OverlayPortalController overlayPortalController = OverlayPortalController();

  TocController get tocController => widget.controller;

  @override
  void initState() {
    super.initState();
    tocController.addListener(_onTocListChange);
    tocController.currentScrollIndex.addListener(_onScrollIndexChanged);

    _refreshList(tocController.tocList);
  }

  @override
  void dispose() {
    tocController.currentScrollIndex.removeListener(_onScrollIndexChanged);
    _tocList.clear();
    autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: overlayPortalController.toggle,
        child: OverlayPortal(
          controller: overlayPortalController,
          overlayChildBuilder: (BuildContext context) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => overlayPortalController.hide(),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                CompositedTransformFollower(
                  link: _layerLink,
                  targetAnchor: Alignment.centerLeft,
                  followerAnchor: Alignment.centerRight,
                  offset: const Offset(-8, 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                      maxWidth: 300,
                      minWidth: 200,
                    ),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 8,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              _tocList.length,
                              _buildTocItem,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              _tocList.length,
              _buildTocBullet,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTocBullet(index) {
    final currentToc = _tocList[index];
    bool isActiveToc = index == currentIndex;

    var tag = currentToc.node.headingConfig.tag;
    return Container(
      height: 2,
      width: 10.0 * (7 - (headingTag2Level[tag] ?? 1)),
      color: isActiveToc ? Colors.blue : Colors.grey,
    );
  }

  Widget _buildTocItem(index) {
    final currentToc = _tocList[index];
    bool isActiveToc = index == currentIndex;

    final node = currentToc.node.copy(
      headingConfig: _TocHeadingConfig(
        TextStyle(
          fontSize: 16,
          color: isActiveToc ? Colors.blue : null,
        ),
        currentToc.node.headingConfig.tag,
      ),
    );

    final child = Container(
      margin: EdgeInsets.only(
          left: 20.0 * (headingTag2Level[node.headingConfig.tag] ?? 1)),
      child: InkWell(
        child: ProxyRichText(node.build()),
        onTap: () {
          tocController.jumpToIndex(currentToc.widgetIndex);
          _refreshIndex(currentToc.selfIndex);
        },
      ),
    );
    return wrapByAutoScroll(index, child, autoScrollController);
  }

  void _onScrollIndexChanged() {
    final index = tocController.currentScrollIndex.value;
    if (index == null) return;

    final selfIndex = tocController.getTocByWidgetIndex(index)?.selfIndex;
    if (selfIndex != null && _tocList.length > selfIndex) {
      _refreshIndex(selfIndex);
    }
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

  void _refreshList(List<Toc> list) {
    _tocList.clear();
    _tocList.addAll(list);
  }

  void _refreshIndex(int index) {
    currentIndex = index;
    refresh();
  }

  void refresh() {
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
