import 'package:test/test.dart';
import 'package:renaming_share/src/models/rename_mode.dart';

void main() {
  group('RenameMode', () {
    test('fromString should return correct RenameMode', () {
      expect(RenameMode.fromString('normal'), equals(RenameMode.normal));
      expect(RenameMode.fromString('error'), equals(RenameMode.error));
      expect(RenameMode.fromString('undo'), equals(RenameMode.undo));
      expect(RenameMode.fromString('invalid'), equals(RenameMode.normal));
    });
    
    test('value property should return correct string representation', () {
      expect(RenameMode.normal.value, equals('normal'));
      expect(RenameMode.error.value, equals('error'));
      expect(RenameMode.undo.value, equals('undo'));
    });
  });
}