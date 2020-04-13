import 'dart:collection';
import 'markdown_generator.dart';
import 'config/style_config.dart';
import 'config/widget_config.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'markdown_toc.dart';

export 'markdown_toc.dart';
export 'dart:collection';
export 'config/style_config.dart';
export 'package:markdown_widget/markdown_generator.dart';

class MarkdownWidget extends StatefulWidget {
  final String data;

  ///you can custom your widget by [widgetConfig]
  final WidgetConfig widgetConfig;

  ///you can use [styleConfig] to set default widget style, such as [pConfig.onTapLink]
  final StyleConfig styleConfig;

  final EdgeInsetsGeometry childMargin;

  ///if [controller] is not null, you can use [tocListener] to get current TOC index
  final TocController controller;

  const MarkdownWidget({
    Key key,
    @required this.data,
    this.widgetConfig,
    this.styleConfig,
    this.childMargin,
    this.controller,
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
    initialState();
    super.initState();
  }

  void initialState() {
    markdownGenerator = MarkdownGenerator(
      data: widget.data,
      childMargin: widget.childMargin,
    );
    tocList.addAll(markdownGenerator.tocList);
    widgets.addAll(markdownGenerator.widgets);
    if(widget.controller != null) itemPositionsListener.itemPositions.addListener(indexListener);
  }

  void clearState() {
    tocList.clear();
    widgets.clear();
    markdownGenerator.clear();
    markdownGenerator = null;
    if(widget.controller != null) itemPositionsListener.itemPositions.removeListener(indexListener);
    hasInitialed = false;
  }

  @override
  void dispose() {
    clearState();
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
            itemScrollController: widget?.controller?.scrollController,
            itemPositionsListener: itemPositionsListener,
          );
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  void indexListener() {
    bool needRefresh = false;
    final controller = widget?.controller;
    if(itemPositionsListener.itemPositions.value.isNotEmpty){
      final current = itemPositionsListener.itemPositions.value.elementAt(0);
      final toc = tocList[current.index] ??
          tocList[current.index + 1] ??
          tocList[current.index - 1];
      if (toc != null && (controller?.setToc(toc) ?? false)) needRefresh = true;
    }
    if (!hasInitialed) {
      hasInitialed = true;
      if(controller?.setTocList(markdownGenerator.tocList) ?? false) needRefresh = true;
    }
    if(needRefresh) controller?.refresh();
  }


  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    if (oldWidget.data != widget.data ||
        oldWidget.styleConfig != widget.styleConfig ||
        oldWidget.widgetConfig != widget.widgetConfig ||
        oldWidget.childMargin != widget.childMargin) {
      clearState();
      widget?.controller?.jumpTo(index: 0);
      initialState();
    }
    super.didUpdateWidget(widget);
  }


}

