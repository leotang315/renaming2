import 'package:test/test.dart';
import 'package:renaming_share/src/rules/string_regex_replace.dart';

void main() {
  group('StringRegexReplace', () {
    test('replaceAllWithGroups replaces numbered groups correctly', () {
      const input = 'hello 2023-12-31 world';
      final regex = RegExp(r'(\d{4})-(\d{2})-(\d{2})');

      final result = input.replaceAllWithGroups(regex, r'${3}/${2}/${1}');
      expect(result, equals('hello 31/12/2023 world'));
    });

    test('replaceAllWithGroups handles simple group references', () {
      const input = 'John Doe';
      final regex = RegExp(r'(\w+)\s+(\w+)');

      final result = input.replaceAllWithGroups(regex, r'$2, $1');
      expect(result, equals('Doe, John'));
    });

    test('replaceAllWithGroups handles multiple matches', () {
      const input = 'apple orange banana';
      final regex = RegExp(r'(\w+)');

      final result = input.replaceAllWithGroups(regex, r'[$1]');
      expect(result, equals('[apple] [orange] [banana]'));
    });
  });
}
