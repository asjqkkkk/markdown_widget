class MarkdownRenderingState {
  static final MarkdownRenderingState _instance = MarkdownRenderingState._internal();

  factory MarkdownRenderingState() {
    return _instance;
  }

  MarkdownRenderingState._internal();

  /// Represents a search query passed in from the Widget. Used to match content in the markdown against the query
  /// for proper search-string highlighting.
  String? query;
}
