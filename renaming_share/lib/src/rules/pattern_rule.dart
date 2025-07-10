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
  Future<String> apply(String input, {int? index}) async {
    final regex = RegExp(pattern);
    var replacement = replace;
    
    // 如果提供了索引，替换模板中的 ${index} 变量
    if (index != null) {
      replacement = replacement.replaceAll(r'${index}', index.toString());
    }
    
    return input.replaceAllWithGroups(regex, replacement);
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
