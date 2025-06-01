import 'package:test/test.dart';
import 'package:renaming_share/src/rules/rule.dart';
import 'package:renaming_share/src/rules/pattern_rule.dart';

void main() {
  group('Rule', () {
    test('fromJson creates correct rule instance based on type', () {
      final json = {
        'type': 'pattern',
        'id': 'test-id',
        'name': 'Test Rule',
        'pattern': 'test-pattern',
        'replacement': 'test-replacement'
      };
      
      final rule = Rule.fromJson(json);
      
      expect(rule, isA<PatternRule>());
      expect(rule.id, equals('test-id'));
      expect(rule.name, equals('Test Rule'));
      expect(rule.type, equals('pattern'));
    });
    
    test('fromJson throws exception for unknown rule type', () {
      final json = {
        'type': 'unknown',
        'id': 'test-id',
        'name': 'Test Rule'
      };
      
      expect(() => Rule.fromJson(json), throwsException);
    });
  });
}