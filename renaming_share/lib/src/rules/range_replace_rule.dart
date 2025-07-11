import 'rule.dart';

class RangeReplaceRule extends Rule {
  final int start;
  final int end;
  final String content;
  final bool fromStart;

  RangeReplaceRule({
    required super.name,
    required this.content,
    required this.start,
    required this.end,
    this.fromStart = true,
  }) {
    type = 'range_replace';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    if (start < 0 || end > input.length || start > end) {
      throw RangeError('Invalid range');
    }
    final startPos = fromStart ? start : input.length - start;
    final endPos = fromStart ? end : input.length - end;
    return input.substring(0, startPos) + content + input.substring(endPos);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'content': content,
    'start': start,
    'end': end,
    'fromStart': fromStart,
  };

  factory RangeReplaceRule.fromJson(Map<String, dynamic> json) {
    return RangeReplaceRule(
      name: json['name'] as String,
      content: json['content'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      fromStart: json['fromStart'] as bool,
    )..id = json['id'] as String;
  }
}
