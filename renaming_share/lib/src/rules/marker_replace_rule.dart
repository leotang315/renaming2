import 'package:renaming_share/src/rules/StringRegexReplace.dart';

import 'rule.dart';

class MarkerReplaceRule extends Rule {
  final String maker;
  final String content;

  MarkerReplaceRule({
    required super.name,
    required this.maker,
    required this.content,
  }) {
    type = 'marker_replace';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final regex = RegExp(maker);
    return input.replaceAllWithGroups(regex, content);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'pattern': maker,
    'content': content,
  };

  factory MarkerReplaceRule.fromJson(Map<String, dynamic> json) {
    return MarkerReplaceRule(
      name: json['name'] as String,
      maker: json['marker'] as String,
      content: json['content'] as String,
    )..id = json['id'] as String;
  }
}
