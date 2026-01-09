# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

markdown_widget is a Flutter package for rendering Markdown content with advanced features including Table of Contents (TOC), code highlighting, and multi-platform support.

## Development Commands

### Package Development
```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run analyzer
dart analyze

# Run example app (from repo root)
cd example && flutter run

# Build example for web (for local testing)
cd example && flutter build web

# Run asset conversion script for web demo
dart run example/build_script/script_convert_asset.dart
```

### Platform Build Commands
```bash
# Android
cd example && flutter build apk --release
cd example && flutter build appbundle --release

# iOS
cd example && flutter build ios --release --no-codesign

# Web
cd example && flutter build web

# Desktop
cd example && flutter build windows --release
cd example && flutter build macos --release
cd example && flutter build linux --release
```

## Architecture Overview

### Core Package Structure (`/lib`)
The package follows a modular architecture where different markdown elements are handled by specialized widgets:

- **Main Entry**: `lib/markdown_widget.dart` exports the main `MarkdownWidget` class and related APIs
- **Widgets Layer**: `lib/widget/` contains the core rendering logic
  - `markdown.dart`: Primary widget that orchestrates markdown rendering
  - `inlines/`: Handles inline elements (text formatting, links, images, code spans)
  - `blocks/container/`: Container blocks that can contain other blocks (lists, tables, blockquotes)
  - `blocks/leaf/`: Leaf blocks that cannot contain other blocks (headings, paragraphs, code blocks)
- **Configuration**: `lib/config/` provides extensive customization options
  - `configs.dart`: Main `MarkdownConfig` class for styling and behavior
  - `toc.dart`: Table of Contents implementation with scroll-to-index functionality
  - `markdown_generator.dart`: Generator for custom widget trees from markdown

### Key Design Patterns

1. **Visitor Pattern**: The markdown AST (Abstract Syntax Tree) is processed using visitor pattern implementations in `lib/config/markdown_generator.dart`. This allows flexible transformation of markdown elements into Flutter widgets.

2. **Configuration-Driven Styling**: All visual aspects are controlled through config objects (e.g., `MarkdownConfig`, `HeadingConfig`, `CodeConfig`). This allows runtime theming changes and easy customization.

3. **Platform Abstraction**: Platform-specific features (link launching, visibility detection) are abstracted through Flutter plugins, enabling true cross-platform support.

4. **Extension System**: Custom markdown syntax and tags can be added by extending `SpanNodeGeneratorWithTag` and integrating with the markdown parser's syntax extensions.

### Example Application (`/example`)
The example app demonstrates advanced usage patterns including:
- Custom syntax extensions (LaTeX, HTML support)
- Integration with state management (Redux)
- Multi-language documentation
- Navigation and routing patterns

## Testing Approach

Tests are located in `/test/` and focus on:
- Widget rendering verification (`widget_test.dart`)
- AST node processing (`node_test.dart`)
- Visitor pattern implementation (`widget_visitor_test.dart`)

Run the full test suite with `flutter test` from the root directory.

## CI/CD Workflows

The project uses GitHub Actions with separate workflows for each platform. Key workflows:
- **build_web.yml**: Tests, builds, and deploys web demo to GitHub Pages
- **coverage_action.yml**: Generates coverage reports for PRs
- **build_*.yml**: Platform-specific release builds for Android, iOS, Web, Windows, macOS, Linux

Environment variable `FLUTTER_VERSION` controls Flutter version (default: 3.27.4).

## Important Implementation Notes

1. **TOC Implementation**: The Table of Contents feature relies on `scroll_to_index` and `visibility_detector` packages to track and scroll to headings.

2. **Code Highlighting**: Uses the `highlight` package with themes provided by `flutter_highlight`. Themes can be customized via `PreConfig`.

3. **Platform-Specific Considerations**: The web version requires asset conversion for media files using the build script.

4. **Dependency Management**: The package keeps Flutter SDK constraint to `>=3.0.0 <4.0.0` and updates major dependencies regularly.

5. **Branch Strategy**: Main development happens on the `dev` branch. PRs should target `master` branch.
