import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('SpanNode', () {
    test('TextNode should build with text and style', () {
      final node = TextNode(text: 'Hello World');
      final span = node.build();

      expect(span, isA<TextSpan>());
      expect((span as TextSpan).text, 'Hello World');
    });

    test('TextNode should have custom style', () {
      const customStyle = TextStyle(fontSize: 18, color: Colors.red);
      final node = TextNode(text: 'Test', style: customStyle);
      final span = node.build() as TextSpan;

      expect(span.style?.fontSize, 18);
      expect(span.style?.color, Colors.red);
    });

    test('TextNode should have default style when not provided', () {
      final node = TextNode(text: 'Test');
      expect(node.style, const TextStyle());
    });
  });

  group('ElementNode', () {
    test('should accept children', () {
      final parent = ConcreteElementNode();
      final child = TextNode(text: 'Child');

      parent.accept(child);

      expect(parent.children, hasLength(1));
      expect(parent.children.first, child);
    });

    test('should set parent on child acceptance', () {
      final parent = ConcreteElementNode();
      final child = TextNode(text: 'Child');

      parent.accept(child);

      expect(child.parent, parent);
    });

    test('should build children span', () {
      final parent = ConcreteElementNode();
      parent.accept(TextNode(text: 'Hello '));
      parent.accept(TextNode(text: 'World'));

      final span = parent.build();
      expect(span, isA<TextSpan>());

      final textSpan = span as TextSpan;
      expect(textSpan.children, hasLength(2));
    });

    test('should handle null child acceptance', () {
      final parent = ConcreteElementNode();
      parent.accept(null);

      expect(parent.children, isEmpty);
    });

    test('should chain multiple children', () {
      final parent = ConcreteElementNode();
      for (int i = 0; i < 5; i++) {
        parent.accept(TextNode(text: 'Child $i '));
      }

      expect(parent.children, hasLength(5));
    });

    test('should support nested ElementNodes', () {
      final grandParent = ConcreteElementNode();
      final parent = ConcreteElementNode();
      final child = TextNode(text: 'Child');

      grandParent.accept(parent);
      parent.accept(child);

      expect(grandParent.children, hasLength(1));
      expect(parent.children, hasLength(1));
      expect(child.parent, parent);
      expect(parent.parent, grandParent);
    });

    test('child should access parent style through parentStyle', () {
      final parent = ConcreteElementNode(
        style: TextStyle(fontSize: 20, color: Colors.red),
      );
      final child = TextNode(text: 'Child');

      parent.accept(child);

      expect(child.parentStyle, parent.style);
      expect(child.parentStyle?.fontSize, 20);
    });
  });

  group('ConcreteElementNode', () {
    test('should create with tag', () {
      final node = ConcreteElementNode(tag: 'div');
      expect(node.tag, 'div');
    });

    test('should create with style', () {
      const style = TextStyle(fontSize: 16);
      final node = ConcreteElementNode(style: style);
      expect(node.style, style);
    });

    test('should create with tag and style', () {
      const style = TextStyle(fontSize: 16);
      final node = ConcreteElementNode(tag: 'p', style: style);
      expect(node.tag, 'p');
      expect(node.style, style);
    });

    test('should have default empty tag', () {
      final node = ConcreteElementNode();
      expect(node.tag, '');
    });

    test('should have default style', () {
      final node = ConcreteElementNode();
      expect(node.style, const TextStyle());
    });
  });

  group('Parent-child relationships', () {
    test('deeply nested nodes should access ancestors', () {
      final root = ConcreteElementNode();
      final level1 = ConcreteElementNode();
      final level2 = ConcreteElementNode();
      final leaf = TextNode(text: 'Leaf');

      root.accept(level1);
      level1.accept(level2);
      level2.accept(leaf);

      expect(leaf.parent, level2);
      expect(level2.parent, level1);
      expect(level1.parent, root);
    });

    test('onAccepted callback should be called when accepted', () {
      bool callbackCalled = false;
      SpanNode? capturedParent;

      final parent = ConcreteElementNode();
      final child = TestNodeWithCallback(
        onAcceptedCallback: (p) {
          callbackCalled = true;
          capturedParent = p;
        },
      );

      parent.accept(child);

      expect(callbackCalled, isTrue);
      expect(capturedParent, parent);
    });
  });

  group('SpanNode with complex structures', () {
    test('should build mixed content tree', () {
      final root = ConcreteElementNode();
      root.accept(TextNode(text: 'Plain text '));

      final bold = ConcreteElementNode(style: TextStyle(fontWeight: FontWeight.bold));
      bold.accept(TextNode(text: 'bold text'));
      root.accept(bold);

      root.accept(TextNode(text: ' and more'));

      final span = root.build() as TextSpan;
      expect(span.children, hasLength(3));
    });

    test('should handle empty ElementNode', () {
      final node = ConcreteElementNode();
      final span = node.build();

      expect(span, isA<TextSpan>());
      final textSpan = span as TextSpan;
      expect(textSpan.children, isEmpty);
    });

    test('should handle ElementNode with only text children', () {
      final node = ConcreteElementNode();
      node.accept(TextNode(text: 'First'));
      node.accept(TextNode(text: 'Second'));
      node.accept(TextNode(text: 'Third'));

      final span = node.build() as TextSpan;
      expect(span.children, hasLength(3));
    });
  });

  group('SpanNode style propagation', () {
    test('style should propagate down the tree', () {
      final root = ConcreteElementNode(
        style: TextStyle(fontSize: 20, color: Colors.blue),
      );

      final child1 = TextNode(text: 'Child 1');
      final child2 = TextNode(text: 'Child 2');

      root.accept(child1);
      root.accept(child2);

      expect(child1.parentStyle?.fontSize, 20);
      expect(child2.parentStyle?.fontSize, 20);
    });

    test('style should be chainable', () {
      final grandParent = ConcreteElementNode(
        style: TextStyle(fontSize: 24),
      );

      final parent = ConcreteElementNode(
        style: TextStyle(color: Colors.red),
      );

      final child = TextNode(
        text: 'Child',
        style: TextStyle(fontWeight: FontWeight.bold),
      );

      grandParent.accept(parent);
      parent.accept(child);

      expect(child.parentStyle?.color, Colors.red);
    });
  });
}

/// Test helper class to expose onAccepted callback
class TestNodeWithCallback extends SpanNode {
  final void Function(SpanNode parent) onAcceptedCallback;

  TestNodeWithCallback({required this.onAcceptedCallback});

  @override
  InlineSpan build() => TextSpan(text: 'Test');

  @override
  void onAccepted(SpanNode parent) {
    super.onAccepted(parent);
    onAcceptedCallback(parent);
  }
}
