import 'pattern_rule.dart';
import 'rule.dart';
import 'StringRegexReplace.dart';

class DelimiterDeleteRule extends Rule {
  final String startDelimiter;
  final String endDelimiter;
  final bool keepDelimiters;
  late final PatternRule _patternRule;

  DelimiterDeleteRule({
    required super.name,
    required this.startDelimiter,
    required this.endDelimiter,
    this.keepDelimiters = false,
  }) {
    type = 'delimiter_delete';
    final escapedStartDelim = RegExp.escape(startDelimiter);
    final escapedEndDelim = RegExp.escape(endDelimiter);
    final pattern = '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim';
    final repalce = keepDelimiters ? '$startDelimiter$endDelimiter' : '';
    _patternRule = PatternRule(name: name, pattern: pattern, replace: repalce);
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    // final escapedStartDelim = RegExp.escape(startDelimiter);
    // final escapedEndDelim = RegExp.escape(endDelimiter);
    // final pattern =
    //     keepDelimiters
    //         ? '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim'
    //         : '(?<=$escapedStartDelim)[^$escapedEndDelim]*(?=$escapedEndDelim)';
    // return input.replaceAllWithGroups(RegExp(pattern), '');
    return _patternRule.apply(input);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'startDelimiter': startDelimiter,
    'endDelimiter': endDelimiter,
    'keepDelimiters': keepDelimiters,
  };

  factory DelimiterDeleteRule.fromJson(Map<String, dynamic> json) {
    return DelimiterDeleteRule(
      name: json['name'] as String,
      startDelimiter: json['startDelimiter'] as String,
      endDelimiter: json['endDelimiter'] as String,
      keepDelimiters: json['keepDelimiters'] as bool,
    )..id = json['id'] as String;
  }
}
