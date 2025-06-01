import 'package:test/test.dart';
import 'package:renaming_share/src/models/rename_status.dart';

void main() {
  group('RenameStatus', () {
    test('fromString should return correct RenameStatus', () {
      expect(RenameStatus.fromString('pending'), equals(RenameStatus.pending));
      expect(RenameStatus.fromString('success'), equals(RenameStatus.success));
      expect(RenameStatus.fromString('error'), equals(RenameStatus.error));
      expect(RenameStatus.fromString('invalid'), equals(RenameStatus.pending));
    });
    
    test('value property should return correct string representation', () {
      expect(RenameStatus.pending.value, equals('pending'));
      expect(RenameStatus.success.value, equals('success'));
      expect(RenameStatus.error.value, equals('error'));
    });
  });
}