import 'rule.dart';
import 'position_insert_rule.dart';
import 'marker_insert_rule.dart';
import 'marker_delete_rule.dart';
import 'range_delete_rule.dart';
import 'delimiter_delete_rule.dart';
import 'character_type_delete_rule.dart';
import 'range_replace_rule.dart';
import 'marker_replace_rule.dart';
import 'character_type_replace_rule.dart';
import 'delimiter_replace_rule.dart';
import 'pattern_rule.dart';

typedef RuleParser = Rule Function(Map<String, dynamic> json);

class RuleRegistry {
  static final Map<String, RuleParser> _parsers = {
    'position_insert': PositionInsertRule.fromJson,
    'marker_insert': MarkerInsertRule.fromJson,
    'marker_delete': MarkerDeleteRule.fromJson,
    'range_delete': RangeDeleteRule.fromJson,
    'delimiter_delete': DelimiterDeleteRule.fromJson,
    'character_type_delete': CharacterTypeDeleteRule.fromJson,
    'range_replace': RangeReplaceRule.fromJson,
    'marker_replace': MarkerReplaceRule.fromJson,
    'character_type_replace': CharacterTypeReplaceRule.fromJson,
    'delimiter_replace': DelimiterReplaceRule.fromJson,
    'pattern': PatternRule.fromJson,
  };

  static void register(String type, RuleParser parser) {
    _parsers[type] = parser;
  }

  static Rule parse(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final parser = _parsers[type];
    if (parser == null) {
      throw Exception('Unknown rule type: $type');
    }
    return parser(json);
  }
}
