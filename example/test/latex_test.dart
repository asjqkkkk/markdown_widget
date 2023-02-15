import 'package:flutter_test/flutter_test.dart';

void main() {
  const input =
      'I\'m the first latex:\$latex1\$, and I\'m the another one:\$latex2\$,'
      '    then I\'m the first block latex:\$\$block latex1\$\$; And I\'m the second'
      ' block latex:\$\$block latex2\$\$';
  final _latexReg = RegExp(r'(\$\$[^\$]+?\$\$)|(\$[^\$]+?\$)');

  test('test for block latex regex', () {
    if (_latexReg.hasMatch(input)) {
      final allMatches = _latexReg.allMatches(input);
      for (var regExpMatch in allMatches) {
        print('latex  result----:${regExpMatch[0]}');
      }
    }
  });
}
