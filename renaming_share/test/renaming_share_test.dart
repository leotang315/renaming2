import 'package:test/test.dart';
import 'package:renaming_share/renaming_share.dart';

void main() {
  group('RenameShare Library', () {
    test('exports all necessary components', () {
      // 验证导出的类和函数可以被访问
      expect(Renamer, isNotNull);
      expect(RenameMode.values, isNotEmpty);
      expect(RenameStatus.values, isNotEmpty);
      expect(Rule, isNotNull);
      expect(RuleFactory, isNotNull);
    });
  });
}