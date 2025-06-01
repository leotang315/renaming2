import 'rule.dart';
import 'StringRegexReplace.dart';

class PatternRule implements Rule {
  @override
  String type;
  @override
  String id;
  @override
  String name;
  final String pattern;

  final String replace;

  PatternRule({
    this.id = '',
    this.name = '',
    required this.pattern,
    required this.replace,
  }) : type = 'pattern';

  @override
  Future<String> apply(String input) async {
    final regex = RegExp(pattern);
    // String result = input.replaceAllMapped(regex, (Match match) {
    //   return "${match.group(3)}/${match.group(2)}/${match.group(1)}";
    // });

    return input.replaceAllWithGroups(regex, replace);
  }

  PatternRule copyWith({
    String? id,
    String? name,
    String? pattern,
    String? replacement,
  }) {
    return PatternRule(
      id: id ?? this.id,
      name: name ?? this.name,
      pattern: pattern ?? this.pattern,
      replace: replacement ?? this.replace,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'pattern': pattern,
    'replacement': replace,
  };

  @override
  factory PatternRule.fromJson(Map<String, dynamic> json) {
    return PatternRule(
      id: json['id'],
      name: json['name'],
      pattern: json['pattern'],
      replace: json['replacement'],
    );
  }
}
