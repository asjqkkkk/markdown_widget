import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  final MarkdownGenerator? markdownGenerator;

  /// Whether or not to render the markdown as a Sliver
  final bool sliver;

  final void Function(SelectedContent? content)? onSelectionChanged;

  /// A search query that will be used to paint a yellow highlight on matches within the markdown content.
  final String? query;

  const MarkdownWidget({
    Key? key,
    required this.data,
    this.tocController,
    this.physics,
    this.shrinkWrap = false,
    this.selectable = false,
    this.onSelectionChanged,
    this.padding,
    this.config,
    this.sliver = false,
    this.markdownGenerator,
    this.query,
  }) : super(key: key);

  @override
  MarkdownWidgetState createState() => MarkdownWidgetState();
}

class MarkdownWidgetState extends State<MarkdownWidget> {
  ///use [markdownGenerator] to transform markdown data to [Widget] list
  late MarkdownGenerator markdownGenerator;

  ///The markdown string converted by MarkdownGenerator will be retained in the [_widgets]
  final List<Widget> _widgets = [];

  ///[TocController] combines [TocWidget] and [MarkdownWidget]
  TocController? _tocController;

  ///[AutoScrollController] provides the scroll to index mechanism
  final AutoScrollController controller = AutoScrollController();

  ///every [VisibilityDetector]'s child which is visible will be kept with [indexTreeSet]
  final indexTreeSet = SplayTreeSet<int>((a, b) => a - b);

  ///if the [ScrollDirection] of [ListView] is [ScrollDirection.forward], [isForward] will be true
  bool isForward = true;

  @override
  void initState() {
    super.initState();

    _tocController = widget.tocController;
    _tocController?.jumpToIndexCallback = (index) {
      controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        updateState();
      });
    });
  }

  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    super.didUpdateWidget(widget);
    clearState();
    updateState();
  }

  ///when we've got the data, we need update data without setState() to avoid the flicker of the view
  void updateState() {
    MarkdownRenderingState().query = widget.query;

    indexTreeSet.clear();
    markdownGenerator = widget.markdownGenerator ?? MarkdownGenerator();

    final result = markdownGenerator.buildWidgets(
      widget.data,
      onSelectionChanged: widget.onSelectionChanged,
      onTocList: (tocList) {
        _tocController?.setTocList(tocList);
      },
      config: widget.config,
    );

    _widgets.addAll(result);
  }

  ///this method will be called when [updateState] or [dispose]
  void clearState() {
    indexTreeSet.clear();
    _widgets.clear();
  }

  @override
  void dispose() {
    clearState();
    controller.dispose();
    _tocController?.jumpToIndexCallback = null;
    MarkdownRenderingState().query = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget markdownWidget = widget.sliver
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _widgets,
          )
        : NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final ScrollDirection direction = notification.direction;
              isForward = direction == ScrollDirection.forward;
              return true;
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.text, // Apply text cursor consistently
              child: SingleChildScrollView(
                physics: widget.physics,
                controller: controller,
                padding: widget.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _widgets.length,
                    (index) => wrapByAutoScroll(
                      index,
                      wrapByVisibilityDetector(index, _widgets[index]),
                      controller,
                    ),
                  ),
                ),
              ),
            ),
          );

    // This is the ONLY SelectionArea in the entire widget tree
    return widget.selectable
        ? SelectionArea(
            child: markdownWidget,
            onSelectionChanged: widget.onSelectionChanged,
          )
        : markdownWidget;
  }

  ///wrap widget by [VisibilityDetector] that can know if [child] is visible
  Widget wrapByVisibilityDetector(int index, Widget child) {
    return VisibilityDetector(
      key: ValueKey(index.toString()),
      onVisibilityChanged: (VisibilityInfo info) {
        final visibleFraction = info.visibleFraction;
        if (isForward) {
          visibleFraction == 0 ? indexTreeSet.remove(index) : indexTreeSet.add(index);
        } else {
          visibleFraction == 1.0 ? indexTreeSet.add(index) : indexTreeSet.remove(index);
        }
        if (indexTreeSet.isNotEmpty) {
          _tocController?.onIndexChanged(indexTreeSet.first);
        }
      },
      child: child,
    );
  }
}

///wrap widget by [AutoScrollTag] that can use [AutoScrollController] to scrollToIndex
Widget wrapByAutoScroll(int index, Widget child, AutoScrollController controller) {
  return AutoScrollTag(
    key: Key(index.toString()),
    controller: controller,
    index: index,
    child: child,
    highlightColor: Colors.black.withOpacity(0.1),
  );
}
