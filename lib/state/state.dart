import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' show TextSpan;

class MarkdownRenderingState {
  static final MarkdownRenderingState _instance = MarkdownRenderingState._internal();

  factory MarkdownRenderingState() {
    return _instance;
  }

  MarkdownRenderingState._internal();

  Map<String, TextSpan> lightThemeCache = {};
  Map<String, TextSpan> darkThemeCache = {};

  void Function(SelectedContent? content)? onSelectionChanged;
}
