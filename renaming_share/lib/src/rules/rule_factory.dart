import 'pattern_rule.dart';
import 'rule.dart';
import 'position_insert_rule.dart';
import 'marker_insert_rule.dart';
import 'marker_delete_rule.dart';
import 'marker_replace_rule.dart';
import 'range_delete_rule.dart';
import 'range_replace_rule.dart';
import 'character_type_delete_rule.dart';
import 'character_type_replace_rule.dart';
import 'delimiter_delete_rule.dart';
import 'delimiter_replace_rule.dart';

class RuleFactory {
  RuleFactory._();

  // Add prefix
  static Rule addPrefix(String prefix) {
    return PositionInsertRule(
      name: "AddPrefix",
      content: prefix,
      position: 0,
      fromStart: true,
    );
  }

  // Add suffix
  static Rule addSuffix(String suffix) {
    return PositionInsertRule(
      name: "AddSuffix",
      content: suffix,
      position: 0,
      fromStart: false,
    );
  }

  // Add after pattern
  static Rule addAfterPattern(String pattern, String content) {
    return MarkerInsertRule(
      name: "AddAfterPattern",
      content: content,
      marker: pattern,
      before: false,
    );
  }

  // Add before pattern
  static Rule addBeforePattern(String pattern, String content) {
    return MarkerInsertRule(
      name: "AddBeforePattern",
      content: content,
      marker: pattern,
      before: true,
    );
  }

  // Add at position
  static Rule addAtPosition(int pos, String content) {
    return PositionInsertRule(
      name: "AddAtPosition",
      content: content,
      position: pos,
      fromStart: true,
    );
  }

  // Add before last N characters
  static Rule addBeforeLastN(int n, String content) {
    return PositionInsertRule(
      name: "AddBeforeLastN",
      content: content,
      position: n,
      fromStart: false,
    );
  }

  // Remove pattern
  static Rule removePattern(String pattern) {
    return MarkerDeleteRule(name: "RemovePattern", marker: pattern);
  }

  // Remove numbers
  static Rule removeNumbers() {
    return CharacterTypeDeleteRule(
      name: "RemoveNumbers",
      characterType: CharacterType.number,
    );
  }

  // Remove spaces
  static Rule removeSpaces() {
    return CharacterTypeDeleteRule(
      name: "RemoveSpaces",
      characterType: CharacterType.space,
    );
  }

  // Remove letters
  static Rule removeLetters() {
    return CharacterTypeDeleteRule(
      name: "RemoveLetters",
      characterType: CharacterType.letter,
    );
  }

  // Remove at position
  static Rule removeAtPosition(int pos) {
    return RangeDeleteRule(name: "RemoveAtPosition", start: pos, end: pos + 1);
  }

  // Remove from end
  static Rule removeFromEnd(int n) {
    return RangeDeleteRule(
      name: "RemoveFromEnd",
      start: 0,
      end: n,
      fromStart: false,
    );
  }

  // Remove range
  static Rule removeRange(int start, int end) {
    return RangeDeleteRule(name: "RemoveRange", start: start, end: end);
  }

  // Remove between delimiters (keeping delimiters)
  static Rule removeBetweenDelimiters(String startDelim, String endDelim) {
    return DelimiterDeleteRule(
      name: "RemoveBetweenDelimiters",
      startDelimiter: startDelim,
      endDelimiter: endDelim,
      keepDelimiters: true,
    );
  }

  // Remove with delimiters (including delimiters)
  static Rule removeWithDelimiters(String startDelim, String endDelim) {
    return DelimiterDeleteRule(
      name: "RemoveWithDelimiters",
      startDelimiter: startDelim,
      endDelimiter: endDelim,
      keepDelimiters: false,
    );
  }

  // Replace pattern
  static Rule replacePattern(String oldPattern, String newPattern) {
    return MarkerReplaceRule(
      name: "ReplacePattern",
      marker: oldPattern,
      content: newPattern,
    );
  }

  // Replace spaces
  static Rule replaceSpaces(String replacement) {
    return CharacterTypeReplaceRule(
      name: "ReplaceSpaces",
      characterType: CharacterType.space,
      replacement: replacement,
    );
  }

  // Replace numbers
  static Rule replaceNumbers(String replacement) {
    return CharacterTypeReplaceRule(
      name: "ReplaceNumbers",
      characterType: CharacterType.number,
      replacement: replacement,
    );
  }

  // Replace letters
  static Rule replaceLetters(String replacement) {
    return CharacterTypeReplaceRule(
      name: "ReplaceLetters",
      characterType: CharacterType.letter,
      replacement: replacement,
    );
  }

  // Replace at position
  static Rule replaceAtPosition(int pos, String replacement) {
    return RangeReplaceRule(
      name: "ReplaceAtPosition",
      start: pos,
      end: pos + 1,
      content: replacement,
    );
  }

  // Replace range
  static Rule replaceRange(int start, int end, String replacement) {
    return RangeReplaceRule(
      name: "ReplaceRange",
      start: start,
      end: end,
      content: replacement,
    );
  }

  // Replace between delimiters
  static Rule replaceBetweenDelimiters(
    String startDelim,
    String endDelim,
    String replacement,
  ) {
    return DelimiterReplaceRule(
      name: "ReplaceBetweenDelimiters",
      startDelimiter: startDelim,
      endDelimiter: endDelim,
      replacement: replacement,
      keepDelimiters: true,
    );
  }
}

// class RuleFactory2 {
//   RuleFactory2._();
//   // Add prefix
//   static Rule addPrefix(String prefix) {
//     return PatternRule(name: "AddPrefix", pattern: r'^', replace: prefix);
//   }

//   // Add suffix
//   static Rule addSuffix(String suffix) {
//     return PatternRule(name: "AddSuffix", pattern: r'$', replace: suffix);
//   }

//   // Add after pattern
//   static Rule addAfterPattern(String pattern, String content) {
//     final escapedPattern = RegExp.escape(pattern);
//     return PatternRule(
//       name: "AddAfterPattern",
//       pattern: '($escapedPattern)',
//       replace: '\${1}$content',
//     );
//   }

//   // Add before pattern
//   static Rule addBeforePattern(String pattern, String content) {
//     final escapedPattern = RegExp.escape(pattern);
//     return PatternRule(
//       name: "AddBeforePattern",
//       pattern: '($escapedPattern)',
//       replace: '$content\${1}',
//     );
//   }

//   // Add at position
//   static Rule addAtPosition(int pos, String content) {
//     return PatternRule(
//       name: "AddAtPosition",
//       pattern: '^(.{$pos})(.*)\$',
//       replace: '\${1}$content\${2}',
//     );
//   }

//   // Add before last N characters
//   static Rule addBeforeLastN(int n, String content) {
//     return PatternRule(
//       name: "AddBeforeLastN",
//       pattern: '^(.*?)(.{$n})\$',
//       replace: '\${1}$content\${2}',
//     );
//   }

//   // Remove pattern
//   static Rule removePattern(String pattern) {
//     final escapedPattern = RegExp.escape(pattern);
//     return PatternRule(
//       name: "RemovePattern",
//       pattern: escapedPattern,
//       replace: "",
//     );
//   }

//   // Remove numbers
//   static Rule removeNumbers() {
//     return PatternRule(name: "RemoveNumbers", pattern: r'\d+', replace: "");
//   }

//   // Remove spaces
//   static Rule removeSpaces() {
//     return PatternRule(name: "RemoveSpaces", pattern: r'\s+', replace: "");
//   }

//   // Remove letters
//   static Rule removeLetters() {
//     return PatternRule(
//       name: "RemoveLetters",
//       pattern: r'[a-zA-Z]+',
//       replace: "",
//     );
//   }

//   // Remove at position
//   static Rule removeAtPosition(int pos) {
//     return PatternRule(
//       name: "RemoveAtPosition",
//       pattern: '^(.{$pos}).(.*)\$',
//       replace: '\${1}\${2}',
//     );
//   }

//   // Remove from end
//   static Rule removeFromEnd(int n) {
//     return PatternRule(
//       name: "RemoveFromEnd",
//       pattern: '^(.*?)(.{$n})\$',
//       replace: '\${1}',
//     );
//   }

//   // Remove range
//   static Rule removeRange(int start, int end) {
//     return PatternRule(
//       name: "RemoveRange",
//       pattern: '^(.{$start}).{${end - start}}(.*)\$',
//       replace: '\${1}\${2}',
//     );
//   }

//   // Remove between delimiters (keeping delimiters)
//   static Rule removeBetweenDelimiters(String startDelim, String endDelim) {
//     final escapedStartDelim = RegExp.escape(startDelim);
//     final escapedEndDelim = RegExp.escape(endDelim);
//     return PatternRule(
//       name: "RemoveBetweenDelimiters",
//       pattern: '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim',
//       replace: '$startDelim$endDelim',
//     );
//   }

//   // Remove with delimiters (including delimiters)
//   static Rule removeWithDelimiters(String startDelim, String endDelim) {
//     final escapedStartDelim = RegExp.escape(startDelim);
//     final escapedEndDelim = RegExp.escape(endDelim);
//     return PatternRule(
//       name: "RemoveWithDelimiters",
//       pattern: '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim',
//       replace: "",
//     );
//   }

//   // Replace pattern
//   static Rule replacePattern(String oldPattern, String newPattern) {
//     return PatternRule(
//       name: "ReplacePattern",
//       pattern: oldPattern,
//       replace: newPattern,
//     );
//   }

//   // Replace spaces
//   static Rule replaceSpaces(String replacement) {
//     return PatternRule(
//       name: "ReplaceSpaces",
//       pattern: r'\s+',
//       replace: replacement,
//     );
//   }

//   // Replace numbers
//   static Rule replaceNumbers(String replacement) {
//     return PatternRule(
//       name: "ReplaceNumbers",
//       pattern: r'\d',
//       replace: replacement,
//     );
//   }

//   // Replace letters
//   static Rule replaceLetters(String replacement) {
//     return PatternRule(
//       name: "ReplaceLetters",
//       pattern: r'[a-zA-Z]',
//       replace: replacement,
//     );
//   }

//   // Replace at position
//   static Rule replaceAtPosition(int pos, String replacement) {
//     return PatternRule(
//       name: "ReplaceAtPosition",
//       pattern: '^(.{$pos}).(.*)\$',
//       replace: '\${1}$replacement\${2}',
//     );
//   }

//   // Replace range
//   static Rule replaceRange(int start, int end, String replacement) {
//     return PatternRule(
//       name: "ReplaceRange",
//       pattern: '^(.{$start}).{${end - start}}(.*)\$',
//       replace: '\${1}$replacement\${2}',
//     );
//   }

//   // Replace between delimiters
//   static Rule replaceBetweenDelimiters(
//     String startDelim,
//     String endDelim,
//     String replacement,
//   ) {
//     final escapedStartDelim = RegExp.escape(startDelim);
//     final escapedEndDelim = RegExp.escape(endDelim);
//     return PatternRule(
//       name: "ReplaceBetweenDelimiters",
//       pattern: '$escapedStartDelim[^$escapedEndDelim]*$escapedEndDelim',
//       replace: '$startDelim$replacement$endDelim',
//     );
//   }
// }
