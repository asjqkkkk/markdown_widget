
import 'package:flutter/material.dart';
import 'markdown_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TocListWidget extends StatefulWidget {
  final TocController controller;
  final TocItem tocItem;
  final Widget emptyWidget;

  const TocListWidget({
    Key key,
    @required this.controller, this.tocItem, this.emptyWidget,
  }) : super(key: key);

  @override
  _TocListWidgetState createState() => _TocListWidgetState();
}

class _TocListWidgetState extends State<TocListWidget> {
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  Toc currentToc;
  LinkedHashMap<int, Toc> tocList;

  @override
  void initState() {
    final controller = widget.controller;
    tocList = controller?.tocList;
    currentToc = controller?.currentToc;
    controller?.addListener(() {
      bool needRefresh = false;
      final toc = controller.currentToc;
      if(tocList != controller.tocList){
        tocList = controller.tocList;
        needRefresh = true;
      }
      if (toc != null && currentToc != toc){
        currentToc = toc;
        if (itemScrollController.isAttached)
          itemScrollController.scrollTo(
              index: currentToc.selfIndex, duration: Duration(milliseconds: 50));
        needRefresh = true;
      }
      if(needRefresh) refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keys = tocList?.keys?.toList();
    return (tocList == null || tocList.isEmpty)
        ? buildEmptyWidget()
        : NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowGlow();
        return true;
      },
      child: ScrollablePositionedList.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final tocIndex = keys[index];
          final toc = tocList[tocIndex];
          bool isCurrent = (toc == currentToc);
          if(toc == null) return Container();
          return widget?.tocItem?.call(toc, isCurrent) ?? ListTile(
            title: Container(
              margin: EdgeInsets.only(left: 20.0 * toc.tagLevel),
              child: Text(
                toc.name,
                style: TextStyle(
                  color: toc == currentToc ? Colors.blue : null,
                ),
              ),
            ),
            onTap: () {
              widget?.controller?.scrollController?.jumpTo(
                  index: tocIndex);
            },
          );
        },
        initialScrollIndex: widget?.controller?.currentToc?.selfIndex ?? 0,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
      ),
    );
  }

  Widget buildEmptyWidget() => widget.emptyWidget ?? Center(child: Text('🤷‍', style: TextStyle(fontSize: 30),),);

  void refresh() {
    if (mounted) setState(() {});
  }
}


///you need to set [ItemScrollController], so [TocListener] will be trigger
class TocController extends ChangeNotifier {
  final ItemScrollController scrollController = ItemScrollController();

  Toc currentToc;

  LinkedHashMap<int, Toc> tocList;

  bool setToc(Toc toc) {
    if (this.currentToc == toc) return false;
    this.currentToc = toc;
    return true;
  }

  bool setTocList(LinkedHashMap<int, Toc> tocList){
    if(this.tocList == tocList) return false;
    this.tocList = tocList;
    return true;
  }

  Future<void> scrollTo(
      {@required int index,
        double alignment = 0,
        @required Duration duration,
        Curve curve = Curves.linear})  => scrollController.scrollTo(index: index, duration: duration, curve: curve);

  void jumpTo({@required int index, double alignment = 0}) => scrollController.jumpTo(index: index, alignment: alignment);

  int get endIndex {
    if(tocList == null || tocList.isEmpty) return 0;
    final keys = tocList.keys.toList();
    final lastKey = keys.last;
    final index = tocList[lastKey].index;
    return index;
  }

  int get startIndex => 0;

  bool get isAttached => scrollController.isAttached;

  void refresh() {
    notifyListeners();
  }
}

class Toc {
  ///title name
  final String name;

  ///h1~h6
  final String tag;

  ///0~5   ->   h1~h6
  final int tagLevel;

  ///index of [MarkdownGenerator]'s _children
  final int index;

  ///index of [TocController.tocList]
  final int selfIndex;

  Toc(this.name, this.tag, this.index, this.selfIndex, this.tagLevel);

  @override
  String toString() {
    return 'Toc{name: $name, tag: $tag, tagLevel: $tagLevel, index: $index, selfIndex: $selfIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (other is Toc) {
      return other.name == name &&
          other.index == index &&
          other.tag == tag &&
          other.selfIndex == selfIndex &&
          other.tagLevel == tagLevel;
    } else
      return false;
  }

  @override
  int get hashCode => super.hashCode;
}

typedef Widget TocItem(Toc toc, bool isCurrent);
