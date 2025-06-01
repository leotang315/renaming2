import 'package:test/test.dart';
import 'package:renaming_share/src/renamer.dart';
import 'package:renaming_share/src/rules/rule_factory.dart';
import 'package:renaming_share/src/models/rename_result.dart';
import 'package:renaming_share/src/models/rename_status.dart';
import 'package:renaming_share/src/models/rename_mode.dart';

void main() {
  group('Renamer', () {
    late Renamer renamer;

    setUp(() {
      renamer = Renamer();
    });

    test('constructor initializes with default values', () {
      expect(renamer.rules, isEmpty);
      expect(renamer.fileList, isEmpty);
      expect(renamer.mappings, isEmpty);
      expect(renamer.dryRun, isFalse);
      expect(renamer.processExtension, isFalse);
    });

    test('addFile adds single file to list', () {
      renamer.addFile('test.txt');
      expect(renamer.fileList, contains('test.txt'));
      expect(renamer.fileList.length, equals(1));
    });

    test('addFiles adds multiple files to list', () {
      renamer.addFiles(['test1.txt', 'test2.txt']);
      expect(renamer.fileList, containsAll(['test1.txt', 'test2.txt']));
      expect(renamer.fileList.length, equals(2));
    });

    test('removeFile removes single file from list', () {
      renamer.addFile('test.txt');
      final removed = renamer.removeFile('test.txt');
      expect(removed, isTrue);
      expect(renamer.fileList, isEmpty);
    });
    
    test('removeFiles removes multiple files from list', () {
      renamer.addFiles(['test1.txt', 'test2.txt', 'test3.txt']);
      final removed = renamer.removeFiles(['test1.txt', 'test2.txt']);
      expect(removed, isTrue);
      expect(renamer.fileList, equals(['test3.txt']));
    });

    test('setDryRun updates dryRun flag', () {
      renamer.setDryRun(true);
      expect(renamer.dryRun, isTrue);
    });

    test('setProcessExtension updates processExtension flag', () {
      renamer.setProcessExtension(true);
      expect(renamer.processExtension, isTrue);
    });
    
    test('addRule adds rule to list', () {
      final rule = RuleFactory.addPrefix('test_');
      renamer.addRule(rule);
      expect(renamer.rules.length, equals(1));
    });
    
    test('clearRules removes all rules', () {
      renamer.addRule(RuleFactory.addPrefix('test_'));
      renamer.addRule(RuleFactory.addSuffix('_test'));
      renamer.clearRules();
      expect(renamer.rules, isEmpty);
    });
    
    test('generateSingleMapping creates correct mapping', () async {
      renamer.addRule(RuleFactory.addPrefix('test_'));
      final result = await renamer.generateSingleMapping('file.txt');
      expect(result.oldPath, equals('file.txt'));
      expect(result.newPath, contains('test_file.txt'));
      expect(result.status, equals(RenameStatus.success));
    });
    
    test('generateSingleMapping handles empty path', () async {
      final result = await renamer.generateSingleMapping('');
      expect(result.status, equals(RenameStatus.error));
      expect(result.message, contains('文件路径为空'));
    });
  });
}