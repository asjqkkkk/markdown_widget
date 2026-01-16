import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../widget/blocks/leaf/heading.dart';
import '../widget/markdown.dart';
import '../widget/proxy_rich_text.dart';

/// Callback type for index change events
typedef TocIndexCallback = void Function(int index);

/// Callback type for TOC list change events
typedef TocListCallback = void Function(List<TocItem> list);

/// [TocController] manages the state and coordination between [TocWidget] and [MarkdownWidget].
///
/// It provides:
/// - Jump functionality: TOC items can scroll to specific headings in the markdown content
/// - Bidirectional synchronization: Scroll position changes notify the TOC to update the current item
/// - External listener support: External code can listen to index and list changes
///
/// Each [TocController] instance should be used with one [TocWidget] and one [MarkdownWidget].
class TocController {
  /// Maps the widget index in the markdown tree to the corresponding TOC item
  final LinkedHashMap<int, TocItem> _widgetIndex2TocItem = LinkedHashMap();

  /// Internal callback to jump to a specific index in the markdown content
  /// Set by the MarkdownWidget to handle scroll-to-index operations
  TocIndexCallback? _jumpToWidgetIndexCallback;

  /// Listeners notified when the current heading index changes
  final Set<TocIndexCallback> _indexChangeListeners = {};

  /// Listeners notified when the TOC list is updated
  final Set<TocListCallback> _listChangeListeners = {};

  /// Whether the controller has been disposed
  bool _isDisposed = false;

  /// Returns the current list of TOC items.
  ///
  /// The list is unmodifiable to prevent external modifications.
  List<TocItem> get tocList => List.unmodifiable(_widgetIndex2TocItem.values);

  /// Whether the controller has been disposed
  bool get isDisposed => _isDisposed;

  /// Sets the callback that handles jumping to a specific widget index.
  ///
  /// This is typically set by the MarkdownWidget to enable
  /// scroll-to-index functionality when TOC items are tapped.
  ///
  /// The callback parameter is the index in the MarkdownGenerator's widget tree.
  set jumpToWidgetIndexCallback(TocIndexCallback? callback) {
    _jumpToWidgetIndexCallback = callback;
  }

  /// Adds a listener that is called when the current heading index changes.
  ///
  /// The [listener] will be called with the new widget index.
  /// Use [removeIndexListener] to remove the listener when done.
  ///
  /// Example:
  /// ```dart
  /// controller.addIndexListener((index) {
  ///   print('Current heading index: $index');
  /// });
  /// ```
  void addIndexListener(TocIndexCallback listener) {
    if (_isDisposed) return;
    _indexChangeListeners.add(listener);
  }

  /// Removes a previously added index change listener.
  void removeIndexListener(TocIndexCallback listener) {
    _indexChangeListeners.remove(listener);
  }

  /// Adds a listener that is called when the TOC list is updated.
  ///
  /// The [listener] will be called with the new list of TOC items.
  /// Use [removeTocListListener] to remove the listener when done.
  void addTocListListener(TocListCallback listener) {
    if (_isDisposed) return;
    _listChangeListeners.add(listener);
  }

  /// Removes a previously added list change listener.
  void removeTocListListener(TocListCallback listener) {
    _listChangeListeners.remove(listener);
  }

  /// Updates the TOC list with new items.
  ///
  /// This method is called when the markdown content is parsed and
  /// headings are extracted. It replaces the existing TOC items.
  void setTocList(List<TocItem> list) {
    if (_isDisposed) return;

    _widgetIndex2TocItem.clear();
    for (final item in list) {
      _widgetIndex2TocItem[item.widgetIndex] = item;
    }
    _notifyListChanged(List.unmodifiable(list));
  }

  /// Finds the TOC item for a given widget index.
  ///
  /// Returns null if no TOC item exists for the given index.
  TocItem? findTocItemByWidgetIndex(int widgetIndex) {
    return _widgetIndex2TocItem[widgetIndex];
  }

  /// Scrolls the markdown content to the heading at the specified widget index.
  ///
  /// The [widgetIndex] corresponds to the index in the MarkdownGenerator's widget tree.
  /// This triggers the [_jumpToWidgetIndexCallback] if it has been set.
  void jumpToWidgetIndex(int widgetIndex) {
    if (_isDisposed) return;
    _jumpToWidgetIndexCallback?.call(widgetIndex);
  }

  /// Notifies all listeners that the current heading index has changed.
  ///
  /// This is called by the MarkdownWidget when scrolling causes
  /// a new heading to become visible.
  ///
  /// The [widgetIndex] is the index in the MarkdownGenerator's widget tree
  /// of the newly visible heading.
  void notifyIndexChanged(int widgetIndex) {
    if (_isDisposed) return;

    for (final listener in _indexChangeListeners) {
      try {
        listener.call(widgetIndex);
      } catch (e) {
        // Ignore errors in listeners to prevent one bad listener from breaking others
        debugPrint('Error in TocIndexCallback: $e');
      }
    }
  }

  /// Notifies all listeners that the TOC list has changed.
  void _notifyListChanged(List<TocItem> list) {
    for (final listener in _listChangeListeners) {
      try {
        listener.call(list);
      } catch (e) {
        debugPrint('Error in TocListCallback: $e');
      }
    }
  }

  /// Releases all resources and listeners associated with this controller.
  ///
  /// After calling dispose, the controller should not be used.
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _widgetIndex2TocItem.clear();
    _indexChangeListeners.clear();
    _listChangeListeners.clear();
    _jumpToWidgetIndexCallback = null;
  }
}

/// Represents a single item in the Table of Contents.
///
/// Each [TocItem] corresponds to a heading in the markdown document
/// and contains information needed for TOC display and navigation.
class TocItem {
  /// The heading node containing the heading text, level, and styling
  final HeadingNode node;

  /// The index of this heading in the MarkdownGenerator's widget tree.
  ///
  /// This index is used to scroll to the correct position when
  /// the TOC item is tapped.
  final int widgetIndex;

  /// The index of this item in the TOC list.
  ///
  /// This is used for positioning within the TOC UI itself.
  final int tocListIndex;

  TocItem({
    required this.node,
    required this.widgetIndex,
    required this.tocListIndex,
  });

  @override
  String toString() =>
      'TocItem(widgetIndex: $widgetIndex, tocListIndex: $tocListIndex, level: ${node.headingConfig.tag})';
}

const defaultTocTextStyle = TextStyle(fontSize: 16);
const defaultCurrentTocTextStyle = TextStyle(fontSize: 16, color: Colors.blue);

/// A widget that displays a Table of Contents for markdown content.
///
/// The [TocWidget] shows a list of all headings in the markdown document.
/// It automatically highlights the currently visible heading and supports
/// tap-to-scroll functionality.
class TocWidget extends StatefulWidget {
  /// The controller that manages TOC state and coordination.
  ///
  /// This must not be null and should be shared with the corresponding
  /// [MarkdownWidget].
  final TocController controller;

  /// The scroll physics for the TOC list view.
  final ScrollPhysics? physics;

  /// Whether the list view should shrink-wrap its content.
  ///
  /// When true, the list takes up only as much vertical space as needed.
  final bool shrinkWrap;

  /// Padding for the list view.
  final EdgeInsetsGeometry? padding;

  /// Custom builder for TOC items.
  ///
  /// If provided, this will be called for each TOC item to build
  /// a custom widget. Return null to use the default ListTile.
  final TocItemBuilder? itemBuilder;

  /// Text style for non-current TOC items.
  final TextStyle tocTextStyle;

  /// Text style for the currently active TOC item.
  final TextStyle currentTocTextStyle;

  const TocWidget({
    super.key,
    required this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemBuilder,
    TextStyle? tocTextStyle,
    TextStyle? currentTocTextStyle,
  })  : tocTextStyle = tocTextStyle ?? defaultTocTextStyle,
        currentTocTextStyle = currentTocTextStyle ?? defaultCurrentTocTextStyle;

  @override
  State<TocWidget> createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget> {
  final AutoScrollController _scrollController = AutoScrollController();
  int _currentTocListIndex = 0;
  final List<TocItem> _tocList = [];

  TocController get controller => widget.controller;

  /// Refreshes the widget to rebuild the UI.
  void refresh() {
    if (mounted) setState(() {});
  }

  /// Updates the current TOC index and refreshes the UI.
  void refreshCurrentIndex(int tocListIndex) {
    _currentTocListIndex = tocListIndex;
    refresh();
  }

  @override
  void initState() {
    super.initState();
    _initListeners();
    _refreshList(controller.tocList);
  }

  void _initListeners() {
    // Listen for TOC list changes
    controller.addTocListListener(_onTocListChanged);

    // Listen for index changes (when markdown scrolling causes new heading to become visible)
    controller.addIndexListener(_onWidgetIndexChanged);
  }

  void _onTocListChanged(List<TocItem> list) {
    if (list.length < _tocList.length && _currentTocListIndex >= list.length) {
      _currentTocListIndex = list.length - 1;
    }
    _refreshList(list);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void _onWidgetIndexChanged(int widgetIndex) {
    final tocItem = controller.findTocItemByWidgetIndex(widgetIndex);
    if (tocItem != null && _tocList.length > tocItem.tocListIndex) {
      refreshCurrentIndex(tocItem.tocListIndex);
      _scrollToCurrentItem();
    }
  }

  void _scrollToCurrentItem() {
    _scrollController.scrollToIndex(_currentTocListIndex,
        preferPosition: AutoScrollPosition.begin);
  }

  void _refreshList(List<TocItem> list) {
    _tocList.clear();
    _tocList.addAll(List.unmodifiable(list));
  }

  @override
  void didUpdateWidget(TocWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      // Remove listeners from old controller
      oldWidget.controller.removeTocListListener(_onTocListChanged);
      oldWidget.controller.removeIndexListener(_onWidgetIndexChanged);

      // Add listeners to new controller
      _initListeners();
      _refreshList(widget.controller.tocList);
    }
  }

  @override
  void dispose() {
    controller.removeTocListListener(_onTocListChanged);
    controller.removeIndexListener(_onWidgetIndexChanged);
    _scrollController.dispose();
    _tocList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      controller: _scrollController,
      itemBuilder: (context, index) {
        final currentToc = _tocList[index];
        final isCurrentToc = index == _currentTocListIndex;

        // Use custom builder if provided
        final itemBuilder = widget.itemBuilder;
        if (itemBuilder != null) {
          final result = itemBuilder.call(TocItemBuilderData(
            index: index,
            toc: currentToc,
            currentIndex: _currentTocListIndex,
            refreshIndexCallback: refreshCurrentIndex,
            autoScrollController: _scrollController,
          ));
          if (result != null) return result;
        }

        // Default TOC item widget
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
          onTap: () {
            controller.jumpToWidgetIndex(currentToc.widgetIndex);
            refreshCurrentIndex(index);
          },
        );

        return wrapByAutoScroll(index, child, _scrollController);
      },
      itemCount: _tocList.length,
      padding: widget.padding,
    );
  }
}

/// Builder function for creating custom TOC item widgets.
///
/// Returns a custom widget for the TOC item, or null to use the default ListTile.
typedef TocItemBuilder = Widget? Function(TocItemBuilderData data);

/// Data passed to [TocItemBuilder] for building custom TOC items.
class TocItemBuilderData {
  /// The index of this item in the TOC list
  final int index;

  /// The TOC item data
  final TocItem toc;

  /// The currently selected TOC list index
  final int currentIndex;

  /// Callback to change the current index.
  ///
  /// Use this to update which TOC item is highlighted.
  final ValueChanged<int> refreshIndexCallback;

  /// The [AutoScrollController] used for scrolling the TOC list.
  final AutoScrollController autoScrollController;

  TocItemBuilderData({
    required this.index,
    required this.toc,
    required this.currentIndex,
    required this.refreshIndexCallback,
    required this.autoScrollController,
  });
}

/// Maps heading tag names to their hierarchy level.
///
/// Used for indentation in the TOC display.
final headingTag2Level = <String, int>{
  'h1': 1,
  'h2': 2,
  'h3': 3,
  'h4': 4,
  'h5': 5,
  'h6': 6,
};

/// Internal [HeadingConfig] implementation for TOC items.
///
/// Uses the TOC's text styles instead of the default heading styles.
class _TocHeadingConfig extends HeadingConfig {
  @override
  final TextStyle style;

  @override
  final String tag;

  _TocHeadingConfig(this.style, this.tag);
}
