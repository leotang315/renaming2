import 'package:test/test.dart';
import 'package:renaming_share/src/rules/rule_factory.dart';

void main() {
  group('RuleFactory', () {
    test('addPrefix creates correct rule', () async {
      final rule = RuleFactory.addPrefix('test_');
      final result = await rule.apply('file');
      expect(result, equals('test_file'));
    });

    test('addSuffix creates correct rule', () async {
      final rule = RuleFactory.addSuffix('_test');
      final result = await rule.apply('file');
      expect(result, equals('file_test'));
    });

    test('addAfterPattern creates correct rule', () async {
      final rule = RuleFactory.addAfterPattern(r'123', '_v');
      final result = await rule.apply('file123');
      expect(result, equals('file123_v'));
    });

    test('addBeforePattern creates correct rule', () async {
      final rule = RuleFactory.addBeforePattern(r'123', 'v');
      final result = await rule.apply('file123');
      expect(result, equals('filev123'));
    });

    test('addAtPosition creates correct rule', () async {
      final rule = RuleFactory.addAtPosition(4, '_test_');
      final result = await rule.apply('filename.txt');
      expect(result, equals('file_test_name.txt'));
    });

    test('addBeforeLastN creates correct rule', () async {
      final rule = RuleFactory.addBeforeLastN(4, '_v2_');
      final result = await rule.apply('file.txt');
      expect(result, equals('file_v2_.txt'));
    });

    test('removePattern creates correct rule', () async {
      final rule = RuleFactory.removePattern(r'123');
      final result = await rule.apply('file123.txt');
      expect(result, equals('file.txt'));
    });

    test('removeNumbers creates correct rule', () async {
      final rule = RuleFactory.removeNumbers();
      final result = await rule.apply('file123.txt');
      expect(result, equals('file.txt'));
    });

    test('removeSpaces creates correct rule', () async {
      final rule = RuleFactory.removeSpaces();
      final result = await rule.apply('file name.txt');
      expect(result, equals('filename.txt'));
    });

    test('removeLetters creates correct rule', () async {
      final rule = RuleFactory.removeLetters();
      final result = await rule.apply('file123.txt');
      expect(result, equals('123.'));
    });

    test('removeAtPosition creates correct rule', () async {
      final rule = RuleFactory.removeAtPosition(4);
      final result = await rule.apply('filename.txt');
      expect(result, equals('fileame.txt'));
    });

    test('removeFromEnd creates correct rule', () async {
      final rule = RuleFactory.removeFromEnd(4);
      final result = await rule.apply('filename.txt');
      expect(result, equals('filename'));
    });

    test('removeRange creates correct rule', () async {
      final rule = RuleFactory.removeRange(4, 8);
      final result = await rule.apply('filename.txt');
      expect(result, equals('file.txt'));
    });

    test('removeBetweenDelimiters creates correct rule', () async {
      final rule = RuleFactory.removeBetweenDelimiters('[', ']');
      final result = await rule.apply('file[version].txt');
      expect(result, equals('file[].txt'));
    });

    test('removeWithDelimiters creates correct rule', () async {
      final rule = RuleFactory.removeWithDelimiters('[', ']');
      final result = await rule.apply('file[version].txt');
      expect(result, equals('file.txt'));
    });

    test('replacePattern creates correct rule', () async {
      final rule = RuleFactory.replacePattern('old', 'new');
      final result = await rule.apply('oldfile.txt');
      expect(result, equals('newfile.txt'));
    });

    test('replaceSpaces creates correct rule', () async {
      final rule = RuleFactory.replaceSpaces('_');
      final result = await rule.apply('file name.txt');
      expect(result, equals('file_name.txt'));
    });

    test('replaceNumbers creates correct rule', () async {
      final rule = RuleFactory.replaceNumbers('X');
      final result = await rule.apply('file123.txt');
      expect(result, equals('fileXXX.txt'));
    });

    test('replaceLetters creates correct rule', () async {
      final rule = RuleFactory.replaceLetters('X');
      final result = await rule.apply('file123.txt');
      expect(result, equals('XXXX123.XXX'));
    });

    test('replaceAtPosition creates correct rule', () async {
      final rule = RuleFactory.replaceAtPosition(4, 'X');
      final result = await rule.apply('filename.txt');
      expect(result, equals('fileXame.txt'));
    });

    test('replaceRange creates correct rule', () async {
      final rule = RuleFactory.replaceRange(4, 8, 'X');
      final result = await rule.apply('filename.txt');
      expect(result, equals('fileX.txt'));
    });

    test('replaceBetweenDelimiters creates correct rule', () async {
      final rule = RuleFactory.replaceBetweenDelimiters('[', ']', 'new');
      final result = await rule.apply('file[version].txt');
      expect(result, equals('file[new].txt'));
    });
  });
}
