import 'package:markdown/markdown.dart' as m;

/// An inline syntax that matches URLs NOT preceded by whitespace or other
/// valid delimiters.
///
/// Unlike [AutolinkExtensionSyntax] which only matches URLs at the beginning
/// of a line or after whitespace/`*`/`_`/`~`/`(`/`>`, this syntax will match
/// URLs that come immediately after other characters (like letters).
///
/// For example:
/// - `awww.baidu.com` will be parsed as plain text "a" + link "www.baidu.com"
/// - `(www.baidu.com)` will be parsed as "(" + link "www.baidu.com" + ")"
/// - `www.baidu.com` at the start of a line will be parsed as a link
///
/// Note: URLs that are already preceded by valid characters (whitespace, etc.)
/// will be handled by the standard [AutolinkExtensionSyntax], so this syntax
/// only handles the "left without space" cases.
class AutolinkNoLeadingSpaceSyntax extends m.InlineSyntax {
  static const _linkPattern =
      r'(?:(?:https?|ftp):\/\/|www\.)'

      // A valid domain consists of segments of alphanumeric characters,
      // underscores (_) and hyphens (-) separated by periods (.). There must
      // be at least one period, and no underscores may be present in the last
      // two segments of the domain.
      r'(?:[-_a-z0-9]+\.)*(?:[-a-z0-9]+\.[-a-z0-9]+)'

      // After a valid domain, zero or more non-space non-< characters may
      // follow.
      r'[^\s<]*'

      // Trailing punctuation (specifically, ?, !, ., ,, :, *, _, and ~) will
      // not be considered part of the autolink, though they may be included in
      // the interior of the link.
      r'[^\s<?!.,:*_~]';

  AutolinkNoLeadingSpaceSyntax()
      : super(
          _linkPattern,
          caseSensitive: false,
        );

  @override
  bool tryMatch(m.InlineParser parser, [int? startMatchPos]) {
    startMatchPos ??= parser.pos;
    final startMatch = pattern.matchAsPrefix(parser.source, startMatchPos);
    if (startMatch == null) {
      return false;
    }

    // Only match if the link is NOT preceded by valid preceding characters.
    // Valid preceding characters are: newline, space, *, _, ~, (, >
    // If preceded by these, AutolinkExtensionSyntax will handle it.
    if (parser.pos > 0) {
      final precededBy = String.fromCharCode(parser.charAt(parser.pos - 1));
      const validPrecedingChars = {'\n', ' ', '*', '_', '~', '(', '>'};
      if (validPrecedingChars.contains(precededBy)) {
        return false;
      }
    }

    parser.writeText();
    return onMatch(parser, startMatch);
  }

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final consumeLength = _getConsumeLength(match[0]!);

    var text = match[0]!.substring(0, consumeLength);
    text = parser.encodeHtml ? _escapeHtml(text) : text;

    var destination = text;
    if (destination[0] == 'w') {
      // When there is no scheme specified, insert the scheme `http`.
      destination = 'http://$destination';
    }

    final anchor = m.Element.text('a', text)
      ..attributes['href'] = Uri.encodeFull(destination);

    parser
      ..addNode(anchor)
      ..consume(consumeLength);

    return true;
  }

  int _getConsumeLength(String text) {
    var excludedLength = 0;

    // When an autolink ends in `)`, see
    // https://github.github.com/gfm/#example-625.
    if (text.endsWith(')')) {
      final match = RegExp(r'(\(.*)?(\)+)$').firstMatch(text)!;

      if (match[1] == null) {
        excludedLength = match[2]!.length;
      } else {
        var parenCount = 0;
        for (var i = 0; i < text.length; i++) {
          final char = text[i];
          if (char == '(') {
            parenCount++;
          } else if (char == ')') {
            parenCount--;
          }
        }
        if (parenCount < 0) {
          excludedLength = parenCount.abs();
        }
      }
    }
    // If an autolink ends in a semicolon `;`, see
    // https://github.github.com/gfm/#example-627
    else if (text.endsWith(';')) {
      final match = RegExp(r'&[0-9a-z]+;$').firstMatch(text);
      if (match != null) {
        excludedLength = match[0]!.length;
      }
    }

    return text.length - excludedLength;
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
