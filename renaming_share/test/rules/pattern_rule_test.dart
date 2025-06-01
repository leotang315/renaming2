import 'package:test/test.dart';
import 'package:renaming_share/src/rules/pattern_rule.dart';

void main() {
  group('PatternRule', () {
    test('apply performs pattern replacement correctly', () async {
      final rule = PatternRule(pattern: r'(\w+)\s+(\w+)', replace: '\$2_\$1');

      final result = await rule.apply('Hello World');
      expect(result, equals('World_Hello'));
    });

    test('copyWith creates new instance with updated values', () {
      final original = PatternRule(
        id: 'test',
        name: 'Test Rule',
        pattern: 'old',
        replace: 'new',
      );

      final copied = original.copyWith(
        name: 'Updated Rule',
        pattern: 'updated',
      );

      expect(copied.id, equals(original.id));
      expect(copied.name, equals('Updated Rule'));
      expect(copied.pattern, equals('updated'));
      expect(copied.replace, equals(original.replace));
    });

    test('toJson and fromJson work correctly', () {
      final original = PatternRule(
        id: 'test-id',
        name: 'Test Rule',
        pattern: 'test-pattern',
        replace: 'test-replacement',
      );

      final json = original.toJson();
      final fromJson = PatternRule.fromJson(json);

      expect(fromJson.id, equals(original.id));
      expect(fromJson.name, equals(original.name));
      expect(fromJson.pattern, equals(original.pattern));
      expect(fromJson.replace, equals(original.replace));
      expect(fromJson.type, equals('pattern'));
    });
  });
}
