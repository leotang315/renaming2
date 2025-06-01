import 'package:test/test.dart';
import 'package:renaming_share/src/models/rename_result.dart';
import 'package:renaming_share/src/models/rename_status.dart';

void main() {
  group('RenameResult', () {
    test('constructor sets values correctly', () {
      final result = RenameResult(
        oldPath: 'old/path',
        newPath: 'new/path',
        status: RenameStatus.success,
        message: 'test message'
      );
      
      expect(result.oldPath, equals('old/path'));
      expect(result.newPath, equals('new/path'));
      expect(result.status, equals(RenameStatus.success));
      expect(result.message, equals('test message'));
    });

    test('copyWith creates new instance with updated values', () {
      final original = RenameResult(
        oldPath: 'old/path',
        newPath: 'new/path',
        status: RenameStatus.pending
      );

      final copied = original.copyWith(
        status: RenameStatus.success,
        message: 'updated'
      );

      expect(copied.oldPath, equals(original.oldPath));
      expect(copied.newPath, equals(original.newPath));
      expect(copied.status, equals(RenameStatus.success));
      expect(copied.message, equals('updated'));
    });

    test('toJson and fromJson work correctly', () {
      final original = RenameResult(
        oldPath: 'old/path',
        newPath: 'new/path',
        status: RenameStatus.success,
        message: 'test'
      );

      final json = original.toJson();
      final fromJson = RenameResult.fromJson(json);

      expect(fromJson.oldPath, equals(original.oldPath));
      expect(fromJson.newPath, equals(original.newPath));
      expect(fromJson.status, equals(original.status));
      expect(fromJson.message, equals(original.message));
    });
  });
}