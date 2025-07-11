import "character_type_delete_rule.dart";
import "character_type_replace_rule.dart";
import "delimiter_delete_rule.dart";
import "delimiter_replace_rule.dart";
import "marker_delete_rule.dart";
import "marker_insert_rule.dart";
import "marker_replace_rule.dart";
import "position_insert_rule.dart";
import "pattern_rule.dart";
import "range_delete_rule.dart";
import "range_replace_rule.dart";

abstract class Rule {
  String type = "";
  String id = "";
  String name = "";
  Rule({this.id = "", required this.name});
  Future<String> apply(String input, {int? index});

  Map<String, dynamic> toJson();

  factory Rule.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'position_insert':
        return PositionInsertRule.fromJson(json);
      case 'marker_insert':
        return MarkerInsertRule.fromJson(json);
      case 'marker_delete':
        return MarkerDeleteRule.fromJson(json);
      case 'range_delete':
        return RangeDeleteRule.fromJson(json);
      case 'delimiter_delete':
        return DelimiterDeleteRule.fromJson(json);
      case 'character_type_delete':
        return CharacterTypeDeleteRule.fromJson(json);
      case 'range_replace':
        return RangeReplaceRule.fromJson(json);
      case 'marker_replace':
        return MarkerReplaceRule.fromJson(json);
      case 'character_type_replace':
        return CharacterTypeReplaceRule.fromJson(json);
      case 'delimiter_replace':
        return DelimiterReplaceRule.fromJson(json);
      case 'pattern':
        return PatternRule.fromJson(json);
      default:
        throw Exception('Unknown rule type: $type');
    }
  }
}

enum CharacterType { number, space, letter }
