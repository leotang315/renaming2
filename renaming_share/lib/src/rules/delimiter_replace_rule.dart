import 'rule.dart';
import 'string_regex_replace.dart';

class DelimiterReplaceRule extends Rule {
  final String startDelimiter;
  final String endDelimiter;
  final String replacement;
  final bool keepDelimiters;

  DelimiterReplaceRule({
    required super.name,
    required this.startDelimiter,
    required this.endDelimiter,
    required this.replacement,
    this.keepDelimiters = false,
  }) {
    type = 'delimiter_replace';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final escapedStartDelim = RegExp.escape(startDelimiter);
    final escapedEndDelim = RegExp.escape(endDelimiter);
    final pattern = keepDelimiters
        ? '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim'
        : '(?<=$escapedStartDelim)[^$escapedEndDelim]*(?=$escapedEndDelim)';
    final finalReplacement = keepDelimiters
        ? '$startDelimiter$replacement$endDelimiter'
        : replacement;
    return input.replaceAllWithGroups(RegExp(pattern), finalReplacement);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'startDelimiter': startDelimiter,
    'endDelimiter': endDelimiter,
    'replacement': replacement,
    'keepDelimiters': keepDelimiters,
  };

  factory DelimiterReplaceRule.fromJson(Map<String, dynamic> json) {
    return DelimiterReplaceRule(
      name: json['name'] as String,
      startDelimiter: json['startDelimiter'] as String,
      endDelimiter: json['endDelimiter'] as String,
      replacement: json['replacement'] as String,
      keepDelimiters: json['keepDelimiters'] as bool,
    )..id = json['id'] as String;
  }
}