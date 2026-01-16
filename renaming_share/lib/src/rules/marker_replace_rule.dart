import 'package:renaming_share/src/rules/string_regex_replace.dart';

import 'rule.dart';

class MarkerReplaceRule extends Rule {
  final String marker;
  final String content;

  MarkerReplaceRule({
    required super.name,
    required this.marker,
    required this.content,
  }) {
    type = 'marker_replace';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final regex = RegExp(marker);
    return input.replaceAllWithGroups(regex, content);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'pattern': marker,
    'content': content,
  };

  factory MarkerReplaceRule.fromJson(Map<String, dynamic> json) {
    return MarkerReplaceRule(
      name: json['name'] as String,
      marker: json['marker'] as String,
      content: json['content'] as String,
    )..id = json['id'] as String;
  }
}
