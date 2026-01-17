import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';

const mermaidLanguage = 'mermaid';

/// In-memory cache for Mermaid diagrams
class _MermaidCache {
  static final Map<String, _CachedData> _cache = {};

  static _CachedData? get(String key) => _cache[key];

  static void set(String key, _CachedData data) => _cache[key] = data;
}

/// Cached data wrapper
class _CachedData {
  final Uint8List bytes;
  final DateTime timestamp;

  _CachedData(this.bytes) : timestamp = DateTime.now();
}

/// Display mode for Mermaid diagrams
enum MermaidDisplayMode {
  codeOnly,
  diagramOnly,
  codeAndDiagram;

  String get _label {
    switch (this) {
      case codeOnly:
        return 'Code';
      case diagramOnly:
        return 'Diagram';
      case codeAndDiagram:
        return 'Both';
    }
  }

  IconData get _icon {
    switch (this) {
      case codeOnly:
        return Icons.code;
      case diagramOnly:
        return Icons.image;
      case codeAndDiagram:
        return Icons.view_column;
    }
  }
}

/// Configuration for Mermaid diagram rendering
class MermaidConfig {
  final MermaidDisplayMode displayMode;
  final Color? diagramBackgroundColor;
  final EdgeInsetsGeometry diagramPadding;
  final bool showLoadingIndicator;
  final Widget? loadingWidget;
  final Widget Function(MermaidDiagramState)? stateBuilder;

  const MermaidConfig({
    this.displayMode = MermaidDisplayMode.codeAndDiagram,
    this.diagramBackgroundColor,
    this.diagramPadding = const EdgeInsets.all(16.0),
    this.showLoadingIndicator = true,
    this.loadingWidget,
    this.stateBuilder,
  });

  MermaidConfig copyWith({
    MermaidDisplayMode? displayMode,
    Color? diagramBackgroundColor,
    EdgeInsetsGeometry? diagramPadding,
    bool? showLoadingIndicator,
    Widget? loadingWidget,
    Widget Function(MermaidDiagramState)? stateBuilder,
  }) {
    return MermaidConfig(
      displayMode: displayMode ?? this.displayMode,
      diagramBackgroundColor:
          diagramBackgroundColor ?? this.diagramBackgroundColor,
      diagramPadding: diagramPadding ?? this.diagramPadding,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      stateBuilder: stateBuilder ?? this.stateBuilder,
    );
  }
}

/// Base class for Mermaid diagram states
abstract class MermaidDiagramState {
  /// Build the widget for this state
  Widget buildWidget(BuildContext context, MermaidConfig config);

  /// Convenience getters
  bool get isLoading => this is LoadingState;
  bool get isReady => this is ReadyState;
  bool get hasError => this is ErrorState;
}

/// Loading state - diagram is being rendered
class LoadingState extends MermaidDiagramState {
  LoadingState();

  @override
  Widget buildWidget(BuildContext context, MermaidConfig config) {
    return config.loadingWidget ??
        Container(
          padding: config.diagramPadding,
          child: Center(
            child: config.showLoadingIndicator
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Rendering diagram...'),
                    ],
                  )
                : const SizedBox(),
          ),
        );
  }
}

/// Error state - rendering failed
class ErrorState extends MermaidDiagramState {
  final Object error;
  final VoidCallback onRetry;

  ErrorState(this.error, {required this.onRetry});

  @override
  Widget buildWidget(BuildContext context, MermaidConfig config) {
    return Container(
      padding: config.diagramPadding,
      color: config.diagramBackgroundColor?.withValues(alpha: 0.1),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Failed to render diagram'),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Ready state - diagram is ready to display
class ReadyState extends MermaidDiagramState {
  final Uint8List imageBytes;

  ReadyState(this.imageBytes);

  @override
  Widget buildWidget(BuildContext context, MermaidConfig config) {
    final imageWidget = Image.memory(
      imageBytes,
      fit: BoxFit.contain,
      errorBuilder: (ctx, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(height: 8),
              Text('Failed to display diagram'),
            ],
          ),
        );
      },
    );

    // Wrap with SingleChildScrollView for independent horizontal scrolling
    final scrollableImage = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: imageWidget,
    );

    // Wrap with InkWell for tap-to-view functionality
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showImageViewer(context, imageWidget),
          child: scrollableImage,
        ),
      ),
    );
  }

  /// Show the diagram in a full-screen image viewer
  void _showImageViewer(BuildContext context, Widget child) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false, pageBuilder: (_, __, ___) => ImageViewer(child: child)));
  }
}

/// Loader class for fetching Mermaid diagrams from kroki.io
class MermaidLoader {
  static const String _baseUrl = 'https://kroki.io';
  static const String _endpoint = '$_baseUrl/mermaid';

  String _generateCacheKey(String code, String themeName) {
    return '$code|$themeName';
  }

  String _resolveMermaidTheme(bool isDark) {
    return isDark ? 'dark' : 'light';
  }

  Map<String, dynamic>? _buildMermaidThemeVariables(bool isDark) {
    return {
      'background': isDark ? '#00000000' : '#ffffff00',
    };
  }

  String _buildMermaidRequestBody(String code, bool isDark) {
    final theme = _resolveMermaidTheme(isDark);
    final themeVariablesData = _buildMermaidThemeVariables(isDark);
    final themeVariables =
        themeVariablesData != null ? jsonEncode(themeVariablesData) : null;

    // Check if code already contains init directive
    if (code.startsWith('%%{init:')) {
      final initEnd = code.indexOf('}%%');
      if (initEnd != -1) {
        final head = code.substring(0, initEnd);
        final tail = code.substring(initEnd + 2);
        return '$head,$tail';
      }
    }

    // Add init directive with theme
    final themeVariablesPart =
        themeVariables != null ? ',"themeVariables":$themeVariables' : '';
    return "%%{init: {'theme':'$theme'$themeVariablesPart}}%%\n$code";
  }

  /// Check if diagram is cached for the given code and theme
  Uint8List? getCached(String code, bool isDark) {
    final cacheKey = _generateCacheKey(code, _resolveMermaidTheme(isDark));

    final cachedData = _MermaidCache.get(cacheKey);
    if (cachedData != null) {
      debugPrint('[MermaidLoader] Cache hit for diagram');
      return cachedData.bytes;
    }
    return null;
  }

  /// Load a Mermaid diagram as PNG bytes
  Future<Uint8List> loadDiagram(String code, bool isDark) async {
    // Check cache first
    final cached = getCached(code, isDark);
    if (cached != null) {
      return cached;
    }

    // Build request body with kroki.io format
    final requestBody = _buildMermaidRequestBody(code, isDark);

    final stopwatch = Stopwatch()..start();

    debugPrint('[MermaidLoader] Requesting mermaid diagram from $_endpoint');
    debugPrint(
        '[MermaidLoader] Code length: ${code.length}, theme: ${_resolveMermaidTheme(isDark)}');

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'text/plain',
              'Accept': 'image/png',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 15));
      stopwatch.stop();

      debugPrint(
          '[MermaidLoader] Response status: ${response.statusCode}, took: ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;

        // Cache the result
        final cacheKey = _generateCacheKey(code, _resolveMermaidTheme(isDark));
        _MermaidCache.set(cacheKey, _CachedData(imageBytes));

        debugPrint(
            '[MermaidLoader] Successfully loaded diagram (${imageBytes.length} bytes)');
        return imageBytes;
      } else {
        debugPrint(
            '[MermaidLoader] Failed to load diagram: ${response.statusCode}');
        throw Exception(
            'Failed to load diagram: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint('[MermaidLoader] Error: $e');
      throw Exception('Failed to load diagram: $e');
    }
  }
}

/// Controller for Mermaid diagram rendering state
class MermaidController extends ChangeNotifier {
  final String code;
  final bool isDark;

  late MermaidDiagramState _state;
  Timer? _debounceTimer;

  MermaidDiagramState get state => _state;
  bool get isLoading => _state.isLoading;
  bool get isReady => _state.isReady;
  bool get hasError => _state.hasError;

  MermaidController({
    String? code,
    MermaidConfig? config,
    this.isDark = false,
  }) : code = code ?? '' {
    // Check cache on initialization and set appropriate initial state
    if (config != null && this.code.isNotEmpty) {
      final cached = MermaidLoader().getCached(this.code, isDark);
      if (cached != null) {
        _state = ReadyState(cached);
        debugPrint('[MermaidController] Initialized with cached diagram');
      } else {
        _state = LoadingState();
        debugPrint('[MermaidController] Initialized with loading state');
      }
    } else {
      _state = LoadingState();
    }
  }

  void _setState(MermaidDiagramState newState) {
    _state = newState;
    debugPrint('[MermaidController] State changed to: ${newState.runtimeType}');
    if (hasListeners) notifyListeners();
  }

  /// Load the diagram
  Future<void> load(MermaidConfig config) async {
    debugPrint('[MermaidController] Starting diagram load...');
    _setState(LoadingState());

    try {
      final bytes = await MermaidLoader().loadDiagram(code, isDark);
      debugPrint('[MermaidController] Diagram loaded successfully');
      _setState(ReadyState(bytes));
    } on http.ClientException catch (e) {
      debugPrint('[MermaidController] Network error: ${e.message}');
      _setState(ErrorState(
        'Network error: ${e.message}. Please check your internet connection.',
        onRetry: () => load(config),
      ));
    } catch (e) {
      debugPrint('[MermaidController] Error loading diagram: $e');
      _setState(ErrorState(
        'Failed to load diagram: $e',
        onRetry: () => load(config),
      ));
    }
  }

  /// Schedule a diagram load with debouncing
  void scheduleLoad(MermaidConfig config) {
    debugPrint('[MermaidController] Scheduling diagram load (debounced)');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      load(config);
    });
  }

  /// Reset the state to initial
  void reset(MermaidConfig config) {
    _setState(LoadingState());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Widget that displays Mermaid diagram with optional code block
class MermaidDisplayWidget extends StatefulWidget {
  final String code;
  final MermaidConfig config;
  final bool isDark;
  final PreConfig? preConfig;
  final Widget codeContent;

  const MermaidDisplayWidget({
    Key? key,
    required this.code,
    this.config = const MermaidConfig(),
    this.preConfig,
    this.isDark = false,
    required this.codeContent,
  }) : super(key: key);

  @override
  State<MermaidDisplayWidget> createState() => _MermaidDisplayWidgetState();
}

class _MermaidDisplayWidgetState extends State<MermaidDisplayWidget> {
  late MermaidController _controller = MermaidController(
    code: widget.code,
    config: widget.config,
    isDark: widget.isDark,
  );
  MermaidDisplayMode _displayMode = MermaidDisplayMode.codeAndDiagram;

  @override
  void initState() {
    super.initState();
    debugPrint(
        '[MermaidDisplayWidget] initState with code length: ${widget.code.length}');
    _displayMode = widget.config.displayMode;
    debugPrint('[MermaidDisplayWidget] Display mode: $_displayMode');

    if (_shouldShowDiagram) {
      _controller.scheduleLoad(widget.config);
    }
  }

  @override
  void didUpdateWidget(MermaidDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate controller if code, config, or isDark changed
    if (oldWidget.code != widget.code ||
        oldWidget.config != widget.config ||
        oldWidget.isDark != widget.isDark) {
      debugPrint(
          '[MermaidDisplayWidget] Widget properties changed, recreating controller');
      final oldController = _controller;
      _controller = MermaidController(
        code: widget.code,
        config: widget.config,
        isDark: widget.isDark,
      );
      oldController.dispose();

      // Schedule load if diagram should be shown and not already cached
      if (_shouldShowDiagram && !_controller.isReady) {
        _controller.scheduleLoad(widget.config);
      }
    }

    _displayMode = widget.config.displayMode;
  }

  @override
  void dispose() {
    debugPrint('[MermaidDisplayWidget] dispose');
    _controller.dispose();
    super.dispose();
  }

  bool get _shouldShowDiagram {
    return _displayMode == MermaidDisplayMode.diagramOnly ||
        _displayMode == MermaidDisplayMode.codeAndDiagram;
  }

  void _cycleDisplayMode() {
    setState(() {
      final oldMode = _displayMode;
      switch (_displayMode) {
        case MermaidDisplayMode.codeOnly:
          _displayMode = MermaidDisplayMode.diagramOnly;
          break;
        case MermaidDisplayMode.diagramOnly:
          _displayMode = MermaidDisplayMode.codeAndDiagram;
          break;
        case MermaidDisplayMode.codeAndDiagram:
          _displayMode = MermaidDisplayMode.codeOnly;
          break;
      }
      debugPrint(
          '[MermaidDisplayWidget] Display mode changed: $oldMode -> $_displayMode');
      if (_shouldShowDiagram && !_controller.isLoading) {
        _controller.scheduleLoad(widget.config);
      }
    });
  }

  Widget _buildCodeBlock() {
    final splitContents =
        widget.code.trim().split(WidgetVisitor.defaultSplitRegExp);
    if (splitContents.last.isEmpty) splitContents.removeLast();

    // Build the content: code only, or code + diagram
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.codeContent,
        if (_shouldShowDiagram)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final state = _controller.state;
              return state.buildWidget(context, widget.config);
            },
          ),
      ],
    );
    return content;
  }

  Widget _buildModeToggleButton() {
    return Positioned(
      top: 0,
      right: 0,
      child: InkWell(
        onTap: _cycleDisplayMode,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.black54 : Colors.white54,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isDark ? Colors.white24 : Colors.black26,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _displayMode._icon,
                size: 16,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 4),
              Text(
                _displayMode._label,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: widget.preConfig?.decoration,
          margin: widget.preConfig?.margin,
          padding: widget.preConfig?.padding,
          width: double.infinity,
          child: Stack(
            children: [
              _displayMode == MermaidDisplayMode.diagramOnly
                  ? _buildDiagramOnly()
                  : _buildCodeBlock(),
              _buildModeToggleButton(),
            ],
          ),
        );
      },
    );
  }

  /// Build diagram-only view (no code block wrapper)
  Widget _buildDiagramOnly() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final state = _controller.state;
        return Container(
          margin: widget.config.diagramPadding,
          child: state.buildWidget(context, widget.config),
        );
      },
    );
  }
}

/// Create a code wrapper that displays Mermaid diagrams
CodeWrapper createMermaidWrapper({
  MermaidConfig? config,
  bool isDark = false,
  PreConfig? preConfig,
}) {
  final CodeWrapper wrapper = (Widget child, String code, String language) {
    if (!language.isMermaidLanguage) return child;
    return MermaidDisplayWidget(
      code: code,
      config: config ?? const MermaidConfig(),
      isDark: isDark,
      preConfig: preConfig,
      codeContent: child,
    );
  };

  return wrapper;
}

extension MermaidExtension on String? {
  bool get isMermaidLanguage {
    return this != null && this!.toLowerCase() == mermaidLanguage;
  }
}
