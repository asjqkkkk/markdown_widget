import '../widget/all.dart';

abstract class WidgetConfig {
  ///every config has a tag
  String get tag;
}

//the basic block config interface
abstract class BlockConfig implements WidgetConfig {}

//the inline widget config interface
abstract class InlineConfig implements WidgetConfig {}

//the container block config interface
abstract class ContainerConfig implements BlockConfig {}

//the leaf block config interface
abstract class LeafConfig implements BlockConfig {}

typedef ValueCallback<T> = void Function(T value);

///the tags of markdown, see [https://spec.commonmark.org/0.30/]
enum MarkdownTag {
  ///------------------------------------------------------///
  ///container block: which can contain other blocks///

  /// [blockquote] A block quote marker, optionally preceded by up to three spaces of indentation,
  ///consists of (a) the character > together with a following space of indentation,
  ///or (b) a single character > not followed by a space of indentation.
  blockquote,

  /// [ul] unordered list
  /// [ol] ordered list
  /// [li] A list is a sequence of one or more list items of the same type.
  /// The list items may be separated by any number of blank lines.
  ul,
  ol,
  li,

  /// [table]
  ///
  /// It consists of rows and columns,
  /// with each row separated by a new line and each cell within a row separated by a pipe symbol (|)
  table,
  thead,
  tbody,
  tr,
  th,
  td,

  ///----------------------------------------------------///
  ///leaf block: which can not contain other blocks///

  /// [hr] Thematic breaks, also known as horizontal rules
  hr,

  /// [pre] An indented code block is composed of one or more indented chunks separated by blank lines
  /// A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~)
  pre,

  ///[h1]、[h2]、[h3]、[h4]、[h5]、[h6]
  ///An ATX heading consists of a string of characters
  ///A setext heading consists of one or more lines of text
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,

  /// [a] Link reference definitions,A link reference definition consists of a link label
  a,

  /// [p] A sequence of non-blank lines that cannot be interpreted as other kinds of blocks forms a paragraph
  p,

  ///----------------------------------------------------///
  ///inlines: which is contained by blocks

  ///[code] A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~)
  code,

  ///[em] emphasis, Markdown treats asterisks (*) and underscores (_) as indicators of emphasis
  em,

  ///[del] double '~'swill be wrapped with an HTML <del> tag.
  del,

  ///[br] a hard line break
  br,

  ///[strong] double '*'s or '_'s will be wrapped with an HTML <strong> tag.
  strong,

  ///[img] a image tag
  img,

  ///[input] a checkbox, use '- [ ] ' or '- [x] '
  input,
  other
}

///use [MarkdownConfig] to set various configurations for [MarkdownWidget]
class MarkdownConfig {
  HrConfig get hr => _getConfig<HrConfig>(MarkdownTag.hr, const HrConfig());

  HeadingConfig get h1 =>
      _getConfig<HeadingConfig>(MarkdownTag.h1, const H1Config());

  HeadingConfig get h2 =>
      _getConfig<HeadingConfig>(MarkdownTag.h2, const H2Config());

  HeadingConfig get h3 =>
      _getConfig<HeadingConfig>(MarkdownTag.h3, const H3Config());

  HeadingConfig get h4 =>
      _getConfig<HeadingConfig>(MarkdownTag.h4, const H4Config());

  HeadingConfig get h5 =>
      _getConfig<HeadingConfig>(MarkdownTag.h5, const H5Config());

  HeadingConfig get h6 =>
      _getConfig<HeadingConfig>(MarkdownTag.h6, const H6Config());

  PreConfig get pre =>
      _getConfig<PreConfig>(MarkdownTag.pre, const PreConfig());

  LinkConfig get a => _getConfig<LinkConfig>(MarkdownTag.a, const LinkConfig());

  PConfig get p => _getConfig<PConfig>(MarkdownTag.p, const PConfig());

  BlockquoteConfig get blockquote => _getConfig<BlockquoteConfig>(
      MarkdownTag.blockquote, const BlockquoteConfig());

  ListConfig get li =>
      _getConfig<ListConfig>(MarkdownTag.li, const ListConfig());

  TableConfig get table =>
      _getConfig<TableConfig>(MarkdownTag.table, const TableConfig());

  CodeConfig get code =>
      _getConfig<CodeConfig>(MarkdownTag.code, const CodeConfig());

  ImgConfig get img =>
      _getConfig<ImgConfig>(MarkdownTag.img, const ImgConfig());

  CheckBoxConfig get input =>
      _getConfig<CheckBoxConfig>(MarkdownTag.input, const CheckBoxConfig());

  T _getConfig<T>(MarkdownTag tag, T defaultValue) {
    final config = _tag2Config[tag.name];
    if (config == null || config is! T) {
      return defaultValue;
    }
    return config as T;
  }

  ///default [MarkdownConfig] for [MarkdownWidget]
  static MarkdownConfig get defaultConfig => MarkdownConfig();

  ///[darkConfig] is used for dark mode
  static MarkdownConfig get darkConfig => MarkdownConfig(configs: [
        HrConfig.darkConfig,
        H1Config.darkConfig,
        H2Config.darkConfig,
        H3Config.darkConfig,
        H4Config.darkConfig,
        H5Config.darkConfig,
        H6Config.darkConfig,
        PreConfig.darkConfig,
        PConfig.darkConfig,
        CodeConfig.darkConfig,
        BlockquoteConfig.darkConfig,
      ]);

  ///the key of [_tag2Config] is tag, the value is [WidgetConfig]
  final Map<String, WidgetConfig> _tag2Config = {};

  MarkdownConfig({List<WidgetConfig> configs = const []}) {
    for (final config in configs) {
      _tag2Config[config.tag] = config;
    }
  }

  MarkdownConfig copy({List<WidgetConfig> configs = const []}) {
    for (final config in configs) {
      _tag2Config[config.tag] = config;
    }
    return MarkdownConfig(configs: _tag2Config.values.toList());
  }
}
