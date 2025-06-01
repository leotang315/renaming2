import 'rule.dart';
import 'pattern_rule.dart';

class RuleFactory {
  RuleFactory._();
  // Add prefix
  static Rule addPrefix(String prefix) {
    return PatternRule(name: "AddPrefix", pattern: r'^', replace: prefix);
  }

  // Add suffix
  static Rule addSuffix(String suffix) {
    return PatternRule(name: "AddSuffix", pattern: r'$', replace: suffix);
  }

  // Add after pattern
  static Rule addAfterPattern(String pattern, String content) {
    final escapedPattern = RegExp.escape(pattern);
    return PatternRule(
      name: "AddAfterPattern",
      pattern: '($escapedPattern)',
      replace: '\${1}$content',
    );
  }

  // Add before pattern
  static Rule addBeforePattern(String pattern, String content) {
    final escapedPattern = RegExp.escape(pattern);
    return PatternRule(
      name: "AddBeforePattern",
      pattern: '($escapedPattern)',
      replace: '$content\${1}',
    );
  }

  // Add at position
  static Rule addAtPosition(int pos, String content) {
    return PatternRule(
      name: "AddAtPosition",
      pattern: '^(.{$pos})(.*)\$',
      replace: '\${1}$content\${2}',
    );
  }

  // Add before last N characters
  static Rule addBeforeLastN(int n, String content) {
    return PatternRule(
      name: "AddBeforeLastN",
      pattern: '^(.*?)(.{$n})\$',
      replace: '\${1}$content\${2}',
    );
  }

  // Remove pattern
  static Rule removePattern(String pattern) {
    final escapedPattern = RegExp.escape(pattern);
    return PatternRule(
      name: "RemovePattern",
      pattern: escapedPattern,
      replace: "",
    );
  }

  // Remove numbers
  static Rule removeNumbers() {
    return PatternRule(name: "RemoveNumbers", pattern: r'\d+', replace: "");
  }

  // Remove spaces
  static Rule removeSpaces() {
    return PatternRule(name: "RemoveSpaces", pattern: r'\s+', replace: "");
  }

  // Remove letters
  static Rule removeLetters() {
    return PatternRule(
      name: "RemoveLetters",
      pattern: r'[a-zA-Z]+',
      replace: "",
    );
  }

  // Remove at position
  static Rule removeAtPosition(int pos) {
    return PatternRule(
      name: "RemoveAtPosition",
      pattern: '^(.{$pos}).(.*)\$',
      replace: '\${1}\${2}',
    );
  }

  // Remove from end
  static Rule removeFromEnd(int n) {
    return PatternRule(
      name: "RemoveFromEnd",
      pattern: '^(.*?)(.{$n})\$',
      replace: '\${1}',
    );
  }

  // Remove range
  static Rule removeRange(int start, int end) {
    return PatternRule(
      name: "RemoveRange",
      pattern: '^(.{$start}).{${end - start}}(.*)\$',
      replace: '\${1}\${2}',
    );
  }

  // Remove between delimiters (keeping delimiters)
  static Rule removeBetweenDelimiters(String startDelim, String endDelim) {
    final escapedStartDelim = RegExp.escape(startDelim);
    final escapedEndDelim = RegExp.escape(endDelim);
    return PatternRule(
      name: "RemoveBetweenDelimiters",
      pattern: '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim',
      replace: '$startDelim$endDelim',
    );
  }

  // Remove with delimiters (including delimiters)
  static Rule removeWithDelimiters(String startDelim, String endDelim) {
    final escapedStartDelim = RegExp.escape(startDelim);
    final escapedEndDelim = RegExp.escape(endDelim);
    return PatternRule(
      name: "RemoveWithDelimiters",
      pattern: '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim',
      replace: "",
    );
  }

  // Replace pattern
  static Rule replacePattern(String oldPattern, String newPattern) {
    final escapedOldPattern = RegExp.escape(oldPattern);
    return PatternRule(
      name: "ReplacePattern",
      pattern: escapedOldPattern,
      replace: newPattern,
    );
  }

  // Replace spaces
  static Rule replaceSpaces(String replacement) {
    return PatternRule(
      name: "ReplaceSpaces",
      pattern: r'\s+',
      replace: replacement,
    );
  }

  // Replace numbers
  static Rule replaceNumbers(String replacement) {
    return PatternRule(
      name: "ReplaceNumbers",
      pattern: r'\d',
      replace: replacement,
    );
  }

  // Replace letters
  static Rule replaceLetters(String replacement) {
    return PatternRule(
      name: "ReplaceLetters",
      pattern: r'[a-zA-Z]',
      replace: replacement,
    );
  }

  // Replace at position
  static Rule replaceAtPosition(int pos, String replacement) {
    return PatternRule(
      name: "ReplaceAtPosition",
      pattern: '^(.{$pos}).(.*)\$',
      replace: '\${1}$replacement\${2}',
    );
  }

  // Replace range
  static Rule replaceRange(int start, int end, String replacement) {
    return PatternRule(
      name: "ReplaceRange",
      pattern: '^(.{$start}).{${end - start}}(.*)\$',
      replace: '\${1}$replacement\${2}',
    );
  }

  // Replace between delimiters
  static Rule replaceBetweenDelimiters(
    String startDelim,
    String endDelim,
    String replacement,
  ) {
    final escapedStartDelim = RegExp.escape(startDelim);
    final escapedEndDelim = RegExp.escape(endDelim);
    return PatternRule(
      name: "ReplaceBetweenDelimiters",
      pattern: '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim',
      replace: '$startDelim$replacement$endDelim',
    );
  }
}
