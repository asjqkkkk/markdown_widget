import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('InputNode', () {
    test('should create with attributes and config', () {
      final attributes = {'checked': 'true'};
      final config = MarkdownConfig.defaultConfig;
      final node = InputNode(attributes, config);

      expect(node.attr, attributes);
      expect(node.config, config);
    });

    test('should parse checked attribute as true', () {
      final attributes = {'checked': 'true'};
      final config = MarkdownConfig.defaultConfig;
      final node = InputNode(attributes, config);

      expect(node.attr['checked'], 'true');
    });

    test('should parse checked attribute as false', () {
      final attributes = {'checked': 'false'};
      final config = MarkdownConfig.defaultConfig;
      final node = InputNode(attributes, config);

      expect(node.attr['checked'], 'false');
    });

    test('should handle missing checked attribute', () {
      final attributes = <String, String>{};
      final config = MarkdownConfig.defaultConfig;
      final node = InputNode(attributes, config);

      expect(node.attr['checked'], isNull);
    });

    test('should parse checked attribute case-insensitively', () {
      final attributes = {'checked': 'TRUE'};
      final config = MarkdownConfig.defaultConfig;
      final node = InputNode(attributes, config);

      expect(node.attr['checked'], 'TRUE');
    });
  });

  group('CheckBoxConfig', () {
    test('should have correct tag', () {
      final config = const CheckBoxConfig();
      expect(config.tag, MarkdownTag.input.name);
    });

    test('should accept builder function', () {
      Widget builder(bool checked) => Container();
      final config = CheckBoxConfig(builder: builder);

      expect(config.builder, isNotNull);
      expect(config.builder, same(builder));
    });
  });

  group('MCheckBox', () {
    testWidgets('should render checked icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MCheckBox(checked: true),
        ),
      ));

      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('should render unchecked icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MCheckBox(checked: false),
        ),
      ));

      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('should render multiple checkboxes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              MCheckBox(checked: true),
              MCheckBox(checked: false),
              MCheckBox(checked: true),
            ],
          ),
        ),
      ));

      expect(find.byType(MCheckBox), findsNWidgets(3));
    });
  });

  group('CheckBoxBuilder', () {
    testWidgets('should use custom builder when provided', (tester) async {
      final config = MarkdownConfig(configs: [
        CheckBoxConfig(builder: (checked) {
          return Container(
            width: 30,
            height: 30,
            child: Text(checked ? '✓' : '✗'),
          );
        }),
      ]);

      final attributes = {'checked': 'true'};
      final node = InputNode(attributes, config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('should pass checked state to builder', (tester) async {
      bool? passedChecked;
      final config = MarkdownConfig(configs: [
        CheckBoxConfig(builder: (checked) {
          passedChecked = checked;
          return SizedBox();
        }),
      ]);

      final attributes = {'checked': 'true'};
      final node = InputNode(attributes, config);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Text.rich(node.build()),
        ),
      ));

      expect(passedChecked, isTrue);
    });
  });
}
