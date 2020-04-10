import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:markdown_widget/config/platform.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TocListWidget extends StatefulWidget {
  final LinkedHashMap<int, Toc> tocList;
  final TocController controller;

  const TocListWidget({
    Key key,
    this.tocList,
    this.controller,
  }) : super(key: key);

  @override
  _TocListWidgetState createState() => _TocListWidgetState();
}

class _TocListWidgetState extends State<TocListWidget> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  Toc currentToc;

  @override
  void initState() {
    bool isMobile = PlatformDetector().isMobile();
    widget?.controller?.addListener(() {
      final toc = widget.controller.toc;
      if (toc == null) return;
      if (currentToc == toc) return;
      currentToc = toc;
      if (itemScrollController.isAttached && !isMobile)
        itemScrollController.scrollTo(
            index: currentToc.selfIndex, duration: Duration(milliseconds: 1));
      refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.tocList;
    final keys = list?.keys?.toList();
    return list == null
        ? Center(child: CircularProgressIndicator())
        : NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowGlow();
              return true;
            },
            child: ScrollablePositionedList.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final tocIndex = keys[index];
                final toc = list[tocIndex];
                return ListTile(
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
              initialScrollIndex: widget?.controller?.toc?.selfIndex ?? 0,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
            ),
          );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
