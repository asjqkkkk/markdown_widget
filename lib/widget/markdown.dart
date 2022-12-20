import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../config/markdown_generator.dart';

class MarkdownWidget extends StatefulWidget {
  ///the markdown data
  final String data;

  ///if [tocController] is not null, you can use [tocListener] to get current TOC index
  final TocController? tocController;

  ///set the desired scroll physics for the markdown item list
  final ScrollPhysics? physics;

  ///set shrinkWrap to obtained [ListView] (only available when [tocController] is null)
  final bool shrinkWrap;

  /// [ListView] padding
  final EdgeInsetsGeometry? padding;

  ///make text selectable
  final bool selectable;

  ///the configs of markdown
  final MarkdownConfig? config;

  ///config for [MarkdownGenerator]
  final MarkdownGeneratorConfig? markdownGeneratorConfig;

  const MarkdownWidget({
    Key? key,
    required this.data,
    this.tocController,
    this.physics,
    this.shrinkWrap = false,
    this.selectable = true,
    this.padding,
    this.config,
    this.markdownGeneratorConfig,
  }) : super(key: key);

  @override
  _MarkdownWidgetState createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget> {
  late MarkdownGenerator markdownGenerator;
  List<Widget> widgets = [];
  late TocController _tocController;
  final AutoScrollController controller = AutoScrollController();
  final indexTreeSet = SplayTreeSet<int>((a, b) => a - b);

  MarkdownConfig get _config => markdownGenerator.config;

  @override
  void initState() {
    super.initState();
    _tocController = widget.tocController ?? TocController();
    _tocController.jumpToIndexCallback = (index) {
      controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    };
    updateState();
  }

  ///when we've got the data, we need update data without setState() to avoid the flicker of the view
  void updateState() {
    indexTreeSet.clear();
    final generatorConfig =
        widget.markdownGeneratorConfig ?? MarkdownGeneratorConfig();
    markdownGenerator = MarkdownGenerator(
      config: widget.config,
      inlineSyntaxes: generatorConfig.inlineSyntaxes,
      blockSyntaxes: generatorConfig.blockSyntaxes,
      linesMargin: generatorConfig.linesMargin,
      generators: generatorConfig.generators,
      onNodeAccepted: generatorConfig.onNodeAccepted,
      textGenerator: generatorConfig.textGenerator,
    );
    final result =
        markdownGenerator.buildWidgets(widget.data, onTocList: (tocList) {
      _tocController.setTocList(tocList);
    });
    widgets.addAll(result);
  }

  ///this method will be called when update
  void clearState() {
    widgets.clear();
  }

  @override
  void dispose() {
    clearState();
    controller.dispose();
    _tocController.jumpToIndexCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildMarkdownWidget();
  }

  Widget buildMarkdownWidget() {
    final markdownWidget = ShareConfigWidget(
      config: _config,
      child: ListView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        controller: controller,
        itemBuilder: (ctx, index) => wrapByAutoScroll(
            index, wrapByVisibilityDetector(index, widgets[index]), controller),
        itemCount: widgets.length,
        padding: widget.padding,
      ),
    );
    return widget.selectable
        ? SelectionArea(child: markdownWidget)
        : markdownWidget;
  }

  Widget wrapByVisibilityDetector(int index, Widget child) {
    return VisibilityDetector(
      key: ValueKey(index.toString()),
      onVisibilityChanged: (VisibilityInfo info) {
        final visibleFraction = info.visibleFraction;
        if (visibleFraction > 0) {
          indexTreeSet.add(index);
        } else if (visibleFraction == 0.0) {
          indexTreeSet.remove(index);
        }
        if (indexTreeSet.isNotEmpty) {
          _tocController.onIndexChanged(indexTreeSet.first);
        }
      },
      child: child,
    );
  }

  ///call [setState] method
  void refresh() {
    if (mounted) setState(() {});
  }

  ///the listener of [ScrollablePositionedList]
  void indexListener() {}

  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    clearState();
    updateState();
    super.didUpdateWidget(widget);
  }
}

Widget wrapByAutoScroll(
    int index, Widget child, AutoScrollController controller) {
  return AutoScrollTag(
    key: Key(index.toString()),
    controller: controller,
    index: index,
    child: child,
    highlightColor: Colors.black.withOpacity(0.1),
  );
}
