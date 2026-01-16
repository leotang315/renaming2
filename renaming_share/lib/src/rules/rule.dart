import 'rule_registry.dart';

abstract class Rule {
  String type = "";
  String id = "";
  String name = "";
  Rule({this.id = "", required this.name});
  Future<String> apply(String input, {int? index});

  Map<String, dynamic> toJson();

  factory Rule.fromJson(Map<String, dynamic> json) {
    return RuleRegistry.parse(json);
  }
}

enum CharacterType { number, space, letter }
