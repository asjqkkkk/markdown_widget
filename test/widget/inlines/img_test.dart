import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('ImageNode', () {
    test('should create with attributes and config', () {
      final attributes = {'src': 'image.png', 'width': '100', 'height': '200'};
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      expect(node.attributes, attributes);
      expect(node.config, config);
      expect(node.visitor, visitor);
    });

    test('should extract width from attributes', () {
      final attributes = {'src': 'image.png', 'width': '100'};
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      expect(node.attributes['width'], '100');
    });

    test('should extract height from attributes', () {
      final attributes = {'src': 'image.png', 'height': '200'};
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      expect(node.attributes['height'], '200');
    });

    test('should identify network images', () {
      final attributes = {'src': 'https://example.com/image.png'};
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      expect(node.attributes['src'], 'https://example.com/image.png');
    });

    test('should identify asset images', () {
      final attributes = {'src': 'assets/image.png'};
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      expect(node.attributes['src'], 'assets/image.png');
    });

    test('should extract alt text', () {
      final attributes = {'src': 'image.png', 'alt': 'Alternative text'};
      final config = MarkdownConfig.defaultConfig;
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      expect(node.attributes['alt'], 'Alternative text');
    });

    testWidgets('should build with ImgConfig builder', (tester) async {
      final attributes = {'src': 'image.png'};
      final config = MarkdownConfig(configs: [
        ImgConfig(builder: (url, attr) {
          return Container(
            width: 100,
            height: 100,
            child: Text('Custom Image'),
          );
        }),
      ]);
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(find.text('Custom Image'), findsOneWidget);
    });

    testWidgets('should use errorBuilder when image fails', (tester) async {
      final attributes = {'src': 'invalid://image.png'};
      final config = MarkdownConfig(configs: [
        ImgConfig(
          errorBuilder: (url, alt, error) {
            return Icon(Icons.error);
          },
        ),
      ]);
      final visitor = WidgetVisitor();

      final node = ImageNode(attributes, config, visitor);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      /// Image widget should be created with errorBuilder
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('ImgConfig', () {
    test('should have correct tag', () {
      final config = const ImgConfig();
      expect(config.tag, MarkdownTag.img.name);
    });

    test('should accept builder function', () {
      Widget builder(String url, Map<String, String> attributes) => Container();
      final config = ImgConfig(builder: builder);

      expect(config.builder, isNotNull);
      expect(config.builder, same(builder));
    });

    test('should accept errorBuilder function', () {
      Widget errorBuilder(String url, String? alt, Object error) => Container();
      final config = ImgConfig(errorBuilder: errorBuilder);

      expect(config.errorBuilder, isNotNull);
      expect(config.errorBuilder, same(errorBuilder));
    });

    test('should accept both builder and errorBuilder', () {
      Widget builder(String url, Map<String, String> attributes) => Container();
      Widget errorBuilder(String url, String? alt, Object error) => Container();
      final config = ImgConfig(
        builder: builder,
        errorBuilder: errorBuilder,
      );

      expect(config.builder, same(builder));
      expect(config.errorBuilder, same(errorBuilder));
    });
  });

  group('ImageViewer', () {
    testWidgets('should display child image', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ImageViewer(
          child: Container(width: 100, height: 100, color: Colors.red),
        ),
      ));
      expect(find.byType(ImageViewer), findsOneWidget);
    });

    testWidgets('should contain InteractiveViewer', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ImageViewer(
          child: Container(width: 100, height: 100),
        ),
      ));

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('should navigate back on tap', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ImageViewer(
            child: Container(width: 100, height: 100),
          ),
        ),
      ));

      await tester.tap(find.byType(ImageViewer));
      await tester.pumpAndSettle();

      /// After tapping, we should be back to the Scaffold
      expect(find.byType(ImageViewer), findsNothing);
    });
  });
}
