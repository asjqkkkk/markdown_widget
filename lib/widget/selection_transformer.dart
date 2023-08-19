import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef SelectionTransform = String Function(Iterable<String>);

/// A widget that transforms the text selection when copied.
///
/// This uses the [SelectionContainer] with a custom [SelectionContainerDelegate] to override the
/// [getSelectedContent] method with a custom implementation.
///
/// Use this by wrapping a subtree under [SelectionArea], e.g:
/// ```dart
/// SelectionArea(
///   child: SelectionTransformer.separated(
///     child: Column(children: [
///       Text("Hello"),
///       Text("World"),
///     ]),
///   ),
/// )
/// ```
class SelectionTransformer extends StatefulWidget {
  const SelectionTransformer({super.key, required this.transform, required this.child});

  /// A [SelectionTransformer] that adds a separator string between each child selections.
  SelectionTransformer.separated({super.key, String separator = '\n', required this.child})
      : transform = _separatedSelectionTransform(separator);

  /// A [SelectionTransformer] that lays out the child selection in a tabular layout.
  ///
  /// As an example, take a widget subtree that produces the following child selections
  /// (e.g. using the [Table] widget):
  ///
  /// 'Url', 'example.com', 'Status', '404', 'Body', 'Not Found'
  ///
  /// The tabular transformer with a column count of 2 would produce the following output:
  ///
  /// Url    example.com
  /// Status 404
  /// Body   Not Found
  ///
  SelectionTransformer.tabular({super.key, required int columns, required this.child})
      : transform = _tabularSelectionTransform(columns);

  static SelectionTransform _separatedSelectionTransform(String separator) =>
          (selections) => selections.join(separator);

  static SelectionTransform _tabularSelectionTransform(int columns) {
    return (selections) {
      var maxColumnWidths = List<int>.filled(columns - 1, 0);
      var indexedSelections = selections.toList().asMap().entries;
      for (var entry in indexedSelections) {
        var i = entry.key;
        var s = entry.value;
        for (var j = 0; j < columns - 1; j++) {
          if (i % columns == j && s.length > maxColumnWidths[j]) {
            maxColumnWidths[j] = s.length;
          }
        }
      }
      var buffer = StringBuffer();
      for (var entry in indexedSelections) {
        var i = entry.key;
        var s = entry.value;
        var j = i % columns;
        if (j < columns - 1) {
          buffer.write('${s.padRight(maxColumnWidths[j])}\t');
        } else {
          buffer.write(s);
          if (i < indexedSelections.length - 1) {
            buffer.write('\n');
          }
        }
      }
      return buffer.toString();
    };
  }

  final SelectionTransform transform;
  final Widget child;

  @override
  State<StatefulWidget> createState() => SelectionTransformerState();
}

class SelectionTransformerState extends State<SelectionTransformer> {
  late final delegate = SeparatedSelectionContainerDelegate(transform);

  String transform(Iterable<String> selections) {
    return widget.transform(selections);
  }

  @override
  void dispose() {
    delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionContainer(
      delegate: delegate,
      child: widget.child,
    );
  }
}

class SeparatedSelectionContainerDelegate extends MultiSelectableSelectionContainerDelegate {
  SeparatedSelectionContainerDelegate(this.transform);

  final SelectionTransform transform;

  @override
  SelectedContent? getSelectedContent() {
    final List<SelectedContent> selections = <SelectedContent>[];
    for (final Selectable selectable in selectables) {
      final SelectedContent? data = selectable.getSelectedContent();
      if (data != null) {
        selections.add(data);
      }
    }
    if (selections.isEmpty) {
      return null;
    }
    return SelectedContent(
      plainText: transform(selections.map((s) => s.plainText)),
    );
  }

  // START: Copied from [_SelectableRegionContainerDelegate]

  // Needed as [MultiSelectableSelectionContainerDelegate] does not provide a
  // default implementation for [ensureChildUpdated].

  final Set<Selectable> _hasReceivedStartEvent = <Selectable>{};
  final Set<Selectable> _hasReceivedEndEvent = <Selectable>{};

  Offset? _lastStartEdgeUpdateGlobalPosition;
  Offset? _lastEndEdgeUpdateGlobalPosition;

  @override
  void remove(Selectable selectable) {
    _hasReceivedStartEvent.remove(selectable);
    _hasReceivedEndEvent.remove(selectable);
    super.remove(selectable);
  }

  void _updateLastEdgeEventsFromGeometries() {
    if (currentSelectionStartIndex != -1) {
      final Selectable start = selectables[currentSelectionStartIndex];
      final Offset localStartEdge =
          start.value.startSelectionPoint!.localPosition + Offset(0, -start.value.startSelectionPoint!.lineHeight / 2);
      _lastStartEdgeUpdateGlobalPosition = MatrixUtils.transformPoint(start.getTransformTo(null), localStartEdge);
    }
    if (currentSelectionEndIndex != -1) {
      final Selectable end = selectables[currentSelectionEndIndex];
      final Offset localEndEdge =
          end.value.endSelectionPoint!.localPosition + Offset(0, -end.value.endSelectionPoint!.lineHeight / 2);
      _lastEndEdgeUpdateGlobalPosition = MatrixUtils.transformPoint(end.getTransformTo(null), localEndEdge);
    }
  }

  @override
  SelectionResult handleSelectAll(SelectAllSelectionEvent event) {
    final SelectionResult result = super.handleSelectAll(event);
    for (final Selectable selectable in selectables) {
      _hasReceivedStartEvent.add(selectable);
      _hasReceivedEndEvent.add(selectable);
    }
    // Synthesize last update event so the edge updates continue to work.
    _updateLastEdgeEventsFromGeometries();
    return result;
  }

  /// Selects a word in a selectable at the location
  /// [SelectWordSelectionEvent.globalPosition].
  @override
  SelectionResult handleSelectWord(SelectWordSelectionEvent event) {
    final SelectionResult result = super.handleSelectWord(event);
    if (currentSelectionStartIndex != -1) {
      _hasReceivedStartEvent.add(selectables[currentSelectionStartIndex]);
    }
    if (currentSelectionEndIndex != -1) {
      _hasReceivedEndEvent.add(selectables[currentSelectionEndIndex]);
    }
    _updateLastEdgeEventsFromGeometries();
    return result;
  }

  @override
  SelectionResult handleClearSelection(ClearSelectionEvent event) {
    final SelectionResult result = super.handleClearSelection(event);
    _hasReceivedStartEvent.clear();
    _hasReceivedEndEvent.clear();
    _lastStartEdgeUpdateGlobalPosition = null;
    _lastEndEdgeUpdateGlobalPosition = null;
    return result;
  }

  @override
  SelectionResult handleSelectionEdgeUpdate(SelectionEdgeUpdateEvent event) {
    if (event.type == SelectionEventType.endEdgeUpdate) {
      _lastEndEdgeUpdateGlobalPosition = event.globalPosition;
    } else {
      _lastStartEdgeUpdateGlobalPosition = event.globalPosition;
    }
    return super.handleSelectionEdgeUpdate(event);
  }

  @override
  void dispose() {
    _hasReceivedStartEvent.clear();
    _hasReceivedEndEvent.clear();
    super.dispose();
  }

  @override
  SelectionResult dispatchSelectionEventToChild(Selectable selectable, SelectionEvent event) {
    switch (event.type) {
      case SelectionEventType.startEdgeUpdate:
        _hasReceivedStartEvent.add(selectable);
        ensureChildUpdated(selectable);
        break;
      case SelectionEventType.endEdgeUpdate:
        _hasReceivedEndEvent.add(selectable);
        ensureChildUpdated(selectable);
        break;
      case SelectionEventType.clear:
        _hasReceivedStartEvent.remove(selectable);
        _hasReceivedEndEvent.remove(selectable);
        break;
      case SelectionEventType.selectAll:
      case SelectionEventType.selectWord:
        break;
      case SelectionEventType.granularlyExtendSelection:
      case SelectionEventType.directionallyExtendSelection:
        _hasReceivedStartEvent.add(selectable);
        _hasReceivedEndEvent.add(selectable);
        ensureChildUpdated(selectable);
        break;
    }
    return super.dispatchSelectionEventToChild(selectable, event);
  }

  @override
  void ensureChildUpdated(Selectable selectable) {
    if (_lastEndEdgeUpdateGlobalPosition != null && _hasReceivedEndEvent.add(selectable)) {
      final SelectionEdgeUpdateEvent synthesizedEvent = SelectionEdgeUpdateEvent.forEnd(
        globalPosition: _lastEndEdgeUpdateGlobalPosition!,
      );
      if (currentSelectionEndIndex == -1) {
        handleSelectionEdgeUpdate(synthesizedEvent);
      }
      selectable.dispatchSelectionEvent(synthesizedEvent);
    }
    if (_lastStartEdgeUpdateGlobalPosition != null && _hasReceivedStartEvent.add(selectable)) {
      final SelectionEdgeUpdateEvent synthesizedEvent = SelectionEdgeUpdateEvent.forStart(
        globalPosition: _lastStartEdgeUpdateGlobalPosition!,
      );
      if (currentSelectionStartIndex == -1) {
        handleSelectionEdgeUpdate(synthesizedEvent);
      }
      selectable.dispatchSelectionEvent(synthesizedEvent);
    }
  }

  @override
  void didChangeSelectables() {
    if (_lastEndEdgeUpdateGlobalPosition != null) {
      handleSelectionEdgeUpdate(
        SelectionEdgeUpdateEvent.forEnd(
          globalPosition: _lastEndEdgeUpdateGlobalPosition!,
        ),
      );
    }
    if (_lastStartEdgeUpdateGlobalPosition != null) {
      handleSelectionEdgeUpdate(
        SelectionEdgeUpdateEvent.forStart(
          globalPosition: _lastStartEdgeUpdateGlobalPosition!,
        ),
      );
    }
    final Set<Selectable> selectableSet = selectables.toSet();
    _hasReceivedEndEvent.removeWhere((Selectable selectable) => !selectableSet.contains(selectable));
    _hasReceivedStartEvent.removeWhere((Selectable selectable) => !selectableSet.contains(selectable));
    super.didChangeSelectables();
  }

// END: Copied from [_SelectableRegionContainerDelegate]
}