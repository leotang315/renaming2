import "pattern_rule.dart";

abstract class Rule {
  String type = "";
  String id = "";
  String name = "";

  Future<String> apply(String input, {int? index});

  Map<String, dynamic> toJson();

  factory Rule.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'pattern':
        return PatternRule.fromJson(json);
      // 添加其他规则类型...
      default:
        throw Exception('Unknown rule type: $type');
    }
  }
}
