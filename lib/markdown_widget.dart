import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'markdown_generator.dart';
import 'config/style_config.dart';
import 'config/widget_config.dart';

class MarkdownWidget extends StatefulWidget {
  final String data;

  ///you can custom your widget by [widgetConfig]
  final WidgetConfig widgetConfig;

  ///you can use [styleConfig] to set default widget style, such as [pConfig.onTapLink]
  final StyleConfig styleConfig;

  final EdgeInsetsGeometry childMargin;

  ///if [controller] is null, it will return a ListView; if not null, you can use markdown TOC feature
  final ItemScrollController controller;

  ///if [controller] is not null, you can use [tocListener] to get current TOC index
  final TocListener tocListener;

  ///get all TOC node
  final TocList tocListBuilder;

  ///see [lazyLoadWidgets], if true, it will load 10、20、30..n widgets dynamic
  final bool lazyLoad;

  const MarkdownWidget({
    Key key,
    @required this.data,
    this.widgetConfig,
    this.styleConfig,
    this.childMargin,
    this.controller,
    this.tocListener, this.tocListBuilder, this.lazyLoad = true,
  }) : super(key: key);

  @override
  _MarkdownWidgetState createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget> {
  MarkdownGenerator markdownGenerator;
  List<Widget> widgets = [];
  LinkedHashMap<int, Toc> tocList = LinkedHashMap();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool hasInitialed = false;

  @override
  void initState() {
    markdownGenerator = MarkdownGenerator(
      data: widget.data,
      childMargin: widget.childMargin,
    );
    tocList.addAll(markdownGenerator.tocList);
    widget?.tocListBuilder?.call(markdownGenerator.tocList);
    itemPositionsListener.itemPositions.addListener(indexListener);
    lazyLoadWidgets();
    super.initState();
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(indexListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller == null
        ? ListView.builder(
            itemBuilder: (ctx, index) => widgets[index],
            itemCount: widgets.length,
          )
        : ScrollablePositionedList.builder(
            itemCount: widgets.length,
            itemBuilder: (context, index) => widgets[index],
            itemScrollController: widget.controller,
            itemPositionsListener: itemPositionsListener,
          );
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  void indexListener() {
    final current = itemPositionsListener.itemPositions.value.elementAt(0);
    final toc = tocList[current.index] ?? tocList[current.index + 1] ?? tocList[current.index - 1];
    if(toc != null) widget?.tocListener?.call(toc);
  }

  void lazyLoadWidgets(){
    if(widget.lazyLoad && markdownGenerator.widgets.length > 20){
      final length = markdownGenerator.widgets.length;
      int loadSize = 10;
      int index = loadSize;
      final first = markdownGenerator.widgets.getRange(0, index);
      widgets.addAll(first);
      refresh();
      int deep = 0;
      while(index < length){
        final end =  index + loadSize;
        loadSize += 10;
        final children = markdownGenerator.widgets.getRange(index, end > length ? length : end);
        index = end;
        deep++;
        Future.delayed(Duration(milliseconds: 400 * (deep))).then((value){
          widgets.addAll(children);
          refresh();
        });
      }
    } else {
      widgets.addAll(markdownGenerator.widgets);
      refresh();
    }
  }
}

///you need to set [ItemScrollController], so [TocListener] will be trigger
typedef void TocListener(Toc toc);

typedef void TocList(LinkedHashMap<int, Toc> tocList);
