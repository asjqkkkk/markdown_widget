# Mermaid Diagram Support

This page demonstrates the Mermaid diagram rendering support in markdown_widget.

## Features

- **Multiple Diagram Types**: Support for various Mermaid diagram types including flowcharts, sequence diagrams, state diagrams, ER diagrams, and more.
- **Theme Support**: Automatically switches between light and dark themes based on app settings.
- **Interactive**: Click the toggle button to switch between:
  - **Code**: View the raw Mermaid code
  - **Diagram**: View only the rendered diagram
  - **Both**: View both code and diagram side by side
- **Caching**: Diagrams are cached in memory for faster rendering on subsequent views.
- **Debouncing**: Automatic debouncing (500ms) when editing to prevent excessive API calls.
- **Fullscreen Viewer**: Click on any rendered diagram to view it in a fullscreen image viewer.
- **Horizontal Scrolling**: Wide diagrams can be scrolled horizontally independently from the code block.

## Usage

### Basic Usage

Use the `createMermaidWrapper` function with your `PreConfig`:

```dart
final preConfig = PreConfig(
  wrapper: createMermaidWrapper(
    config: const MermaidConfig(),
    isDark: isDark,
    preConfig: preConfig,
  ),
);

MarkdownWidget(
  data: markdown,
  config: config.copy(configs: [preConfig]),
)
```

### Custom Configuration

You can customize the rendering behavior using `MermaidConfig`:

```dart
MermaidConfig(
  displayMode: MermaidDisplayMode.codeAndDiagram,
  diagramBackgroundColor: Colors.grey.withValues(alpha: 0.1),
  diagramPadding: EdgeInsets.all(16.0),
  showLoadingIndicator: true,
  loadingWidget: CustomLoadingWidget(),
  stateBuilder: (state) => CustomStateWidget(state),
)
```

### Display Modes

- `MermaidDisplayMode.codeOnly`: Show only the code block
- `MermaidDisplayMode.diagramOnly`: Show only the rendered diagram
- `MermaidDisplayMode.codeAndDiagram`: Show both (default)

### Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `displayMode` | `MermaidDisplayMode` | `codeAndDiagram` | Initial display mode |
| `diagramBackgroundColor` | `Color?` | `null` | Background color for error states |
| `diagramPadding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16.0)` | Padding around the diagram |
| `showLoadingIndicator` | `bool` | `true` | Show loading indicator during rendering |
| `loadingWidget` | `Widget?` | `null` | Custom loading widget |
| `stateBuilder` | `Widget Function(MermaidDiagramState)?` | `null` | Custom state builder |

## How It Works

1. The `createMermaidWrapper` creates a `CodeWrapper` that intercepts code blocks with `language="mermaid"`
2. It extracts the Mermaid code and sends it to the Kroki.io API
3. The API returns a PNG image of the diagram
4. The diagram is displayed with the following states:
   - **Loading**: Shows a loading indicator while rendering
   - **Ready**: Displays the rendered diagram (clickable for fullscreen view)
   - **Error**: Shows error message with retry button

## Technical Details

- **API**: Uses [Kroki.io](https://kroki.io) for rendering diagrams
- **Output Format**: PNG images
- **Request Timeout**: 15 seconds
- **Caching**: In-memory cache with unlimited entries
- **Debounce**: 500ms delay to prevent excessive API calls
- **Cache Key**: `code|themeName` for efficient lookups

## Supported Diagram Types

- Flowchart (`graph`)
- Sequence Diagram (`sequenceDiagram`)
- State Diagram (`stateDiagram-v2`)
- Entity Relationship Diagram (`erDiagram`)
- User Journey (`journey`)
- Git Graph (`gitGraph`)
- Mindmap (`mindmap`)
- Timeline (`timeline`)
- And more...

For a full list of supported Mermaid diagram types, see the [Mermaid documentation](https://mermaid.js.org/intro/).

## Image Viewer Features

- **Fullscreen View**: Click any rendered diagram to view it fullscreen
- **Pan & Zoom**: Use the `InteractiveViewer` to pan and zoom diagrams
- **Hero Animation**: Smooth transition when opening/closing the viewer
- **Close Button**: Click anywhere or use the close button to exit

## Error Handling

The implementation includes comprehensive error handling:
- Network timeout detection (15 seconds)
- HTTP error handling with descriptive messages
- Retry functionality for failed renders
- Graceful fallback to code-only view on errors
