import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  group('MarkdownConfig', () {
    test('should have default config', () {
      final config = MarkdownConfig.defaultConfig;
      expect(config, isNotNull);
      expect(config, isA<MarkdownConfig>());
    });

    test('should have dark config', () {
      final config = MarkdownConfig.darkConfig;
      expect(config, isNotNull);
      expect(config, isA<MarkdownConfig>());
    });

    test('should create config with custom configs', () {
      final customConfig = PConfig(textStyle: const TextStyle(fontSize: 20));
      final config = MarkdownConfig(configs: [customConfig]);
      expect(config.p.textStyle.fontSize, 20);
    });

    test('should copy config with new configs', () {
      final config = MarkdownConfig();
      final newConfig = config.copy(configs: [
        PConfig(textStyle: const TextStyle(fontSize: 18))
      ]);
      expect(newConfig.p.textStyle.fontSize, 18);
    });

    test('should return correct config tag for each type', () {
      final config = MarkdownConfig();
      expect(config.hr.tag, MarkdownTag.hr.name);
      expect(config.h1.tag, MarkdownTag.h1.name);
      expect(config.h2.tag, MarkdownTag.h2.name);
      expect(config.h3.tag, MarkdownTag.h3.name);
      expect(config.h4.tag, MarkdownTag.h4.name);
      expect(config.h5.tag, MarkdownTag.h5.name);
      expect(config.h6.tag, MarkdownTag.h6.name);
      expect(config.pre.tag, MarkdownTag.pre.name);
      expect(config.a.tag, MarkdownTag.a.name);
      expect(config.p.tag, MarkdownTag.p.name);
      expect(config.blockquote.tag, MarkdownTag.blockquote.name);
      expect(config.li.tag, MarkdownTag.li.name);
      expect(config.table.tag, MarkdownTag.table.name);
      expect(config.code.tag, MarkdownTag.code.name);
      expect(config.img.tag, MarkdownTag.img.name);
      expect(config.input.tag, MarkdownTag.input.name);
    });
  });

  group('HeadingConfig', () {
    test('H1Config should have tag and divider', () {
      final config = const H1Config();
      expect(config.tag, MarkdownTag.h1.name);
      expect(config.divider, isNotNull);
      expect(config.richTextBuilder, isNull);
    });

    test('H1Config should support richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = H1Config(richTextBuilder: builder);
      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });

    test('H1Config should have dark config', () {
      final config = H1Config.darkConfig;
      expect(config, isA<H1Config>());
    });

    test('H2Config should have tag and divider', () {
      final config = const H2Config();
      expect(config.tag, MarkdownTag.h2.name);
      expect(config.divider, isNotNull);
    });

    test('H2Config should have dark config', () {
      final config = H2Config.darkConfig;
      expect(config, isA<H2Config>());
    });

    test('H3Config should have tag and divider', () {
      final config = const H3Config();
      expect(config.tag, MarkdownTag.h3.name);
      expect(config.divider, isNotNull);
    });

    test('H3Config should have dark config', () {
      final config = H3Config.darkConfig;
      expect(config, isA<H3Config>());
    });

    test('H4Config should have tag without divider', () {
      final config = const H4Config();
      expect(config.tag, MarkdownTag.h4.name);
      expect(config.divider, isNull);
    });

    test('H4Config should have dark config', () {
      final config = H4Config.darkConfig;
      expect(config, isA<H4Config>());
    });

    test('H5Config should have tag', () {
      final config = const H5Config();
      expect(config.tag, MarkdownTag.h5.name);
    });

    test('H5Config should have dark config', () {
      final config = H5Config.darkConfig;
      expect(config, isA<H5Config>());
    });

    test('H6Config should have tag', () {
      final config = const H6Config();
      expect(config.tag, MarkdownTag.h6.name);
    });

    test('H6Config should have dark config', () {
      final config = H6Config.darkConfig;
      expect(config, isA<H6Config>());
    });
  });

  group('PConfig', () {
    test('should have tag', () {
      final config = const PConfig();
      expect(config.tag, MarkdownTag.p.name);
    });

    test('should have dark config', () {
      final config = PConfig.darkConfig;
      expect(config, isA<PConfig>());
    });

    test('should accept custom textStyle', () {
      final customStyle = TextStyle(fontSize: 18, color: Colors.blue);
      final config = PConfig(textStyle: customStyle);
      expect(config.textStyle.fontSize, 18);
      expect(config.textStyle.color, Colors.blue);
    });
  });

  group('CodeConfig', () {
    test('should have tag', () {
      final config = const CodeConfig();
      expect(config.tag, MarkdownTag.code.name);
    });

    test('should have dark config', () {
      final config = CodeConfig.darkConfig;
      expect(config, isA<CodeConfig>());
    });
  });

  group('PreConfig', () {
    test('should have tag and language', () {
      final config = const PreConfig();
      expect(config.tag, MarkdownTag.pre.name);
      expect(config.language, 'dart');
      expect(config.wrapCode, false);
    });

    test('should have dark config', () {
      final config = PreConfig.darkConfig;
      expect(config, isA<PreConfig>());
    });

    test('should support builder function', () {
      Widget builder(String code, String? language) => Text(code);
      final config = PreConfig(builder: builder);
      expect(config.builder, isNotNull);
      expect(config.builder, same(builder));
    });

    test('should support wrapper function', () {
      Widget wrapper(Widget child, String code, String? language) =>
          Container(child: child);
      final config = PreConfig(wrapper: wrapper);
      expect(config.wrapper, isNotNull);
      expect(config.wrapper, same(wrapper));
    });

    test('should assert when both builder and wrapper are provided', () {
      expect(
        () => PreConfig(
          builder: (code, lang) => Text(code),
          wrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when both builder and contentWrapper are provided',
        () {
      expect(
        () => PreConfig(
          builder: (code, lang) => Text(code),
          contentWrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when both wrapper and contentWrapper are provided', () {
      expect(
        () => PreConfig(
          wrapper: (child, code, lang) => Container(child: child),
          contentWrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when all three are provided', () {
      expect(
        () => PreConfig(
          builder: (code, lang) => Text(code),
          wrapper: (child, code, lang) => Container(child: child),
          contentWrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should assert when copy with both builder and wrapper', () {
      final config = const PreConfig();
      expect(
        () => config.copy(
          builder: (code, lang) => Text(code),
          wrapper: (child, code, lang) => Container(child: child),
        ),
        throwsAssertionError,
      );
    });

    test('should copy with new values', () {
      final config = const PreConfig();
      final copied = config.copy(language: 'python', wrapCode: true);
      expect(copied.language, 'python');
      expect(copied.wrapCode, true);
    });
  });

  group('LinkConfig', () {
    test('should have tag', () {
      final config = const LinkConfig();
      expect(config.tag, MarkdownTag.a.name);
    });

    test('should accept custom onTap callback', () {
      String? tappedUrl;
      final config = LinkConfig(onTap: (url) => tappedUrl = url);
      config.onTap?.call('https://example.com');
      expect(tappedUrl, 'https://example.com');
    });
  });

  group('ImgConfig', () {
    test('should have tag', () {
      final config = const ImgConfig();
      expect(config.tag, MarkdownTag.img.name);
    });

    test('should support builder function', () {
      Widget builder(String url, Map<String, String> attributes) => Container();
      final config = ImgConfig(builder: builder);
      expect(config.builder, isNotNull);
      expect(config.builder, same(builder));
    });

    test('should support errorBuilder function', () {
      Widget errorBuilder(String url, String? alt, Object error) => Container();
      final config = ImgConfig(errorBuilder: errorBuilder);
      expect(config.errorBuilder, isNotNull);
      expect(config.errorBuilder, same(errorBuilder));
    });
  });

  group('CheckBoxConfig', () {
    test('should have tag', () {
      final config = const CheckBoxConfig();
      expect(config.tag, MarkdownTag.input.name);
    });

    test('should support builder function', () {
      Widget builder(bool checked) => Container();
      final config = CheckBoxConfig(builder: builder);
      expect(config.builder, isNotNull);
      expect(config.builder, same(builder));
    });
  });

  group('BlockquoteConfig', () {
    test('should have tag', () {
      final config = const BlockquoteConfig();
      expect(config.tag, MarkdownTag.blockquote.name);
    });

    test('should have dark config', () {
      final config = BlockquoteConfig.darkConfig;
      expect(config, isA<BlockquoteConfig>());
    });

    test('should support richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = BlockquoteConfig(richTextBuilder: builder);
      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('TableConfig', () {
    test('should have tag', () {
      final config = const TableConfig();
      expect(config.tag, MarkdownTag.table.name);
    });

    test('should support wrapper function', () {
      Widget wrapper(Widget child) => Container(color: Colors.red, child: child);
      final config = TableConfig(wrapper: wrapper);
      expect(config.wrapper, isNotNull);
      expect(config.wrapper, same(wrapper));
    });

    test('should support richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = TableConfig(richTextBuilder: builder);
      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('ListConfig', () {
    test('should have tag', () {
      final config = const ListConfig();
      expect(config.tag, MarkdownTag.li.name);
    });

    test('should support marker function', () {
      Widget marker(bool isOrdered, int depth, int index) => Container();
      final config = ListConfig(marker: marker);
      expect(config.marker, isNotNull);
      expect(config.marker, same(marker));
    });

    test('should support richTextBuilder', () {
      Widget builder(InlineSpan span) => Text('Custom');
      final config = ListConfig(richTextBuilder: builder);
      expect(config.richTextBuilder, isNotNull);
      expect(config.richTextBuilder, same(builder));
    });
  });

  group('HrConfig', () {
    test('should have tag', () {
      final config = const HrConfig();
      expect(config.tag, MarkdownTag.hr.name);
    });

    test('should have dark config', () {
      final config = HrConfig.darkConfig;
      expect(config, isA<HrConfig>());
    });
  });

  group('HeadingDivider', () {
    test('should copy with new values', () {
      final divider = HeadingDivider();
      final copied = divider.copy(color: Colors.red, space: 10);
      expect(copied.color, Colors.red);
      expect(copied.space, 10);
      expect(copied.height, divider.height);
    });

    test('should have predefined h1, h2, h3 dividers', () {
      expect(HeadingDivider.h1, isA<HeadingDivider>());
      expect(HeadingDivider.h2, isA<HeadingDivider>());
      expect(HeadingDivider.h3, isA<HeadingDivider>());
    });
  });
}
