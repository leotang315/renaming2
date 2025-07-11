import 'rule.dart';

class RangeDeleteRule extends Rule {
  final int start;
  final int end;
  final bool fromStart;

  RangeDeleteRule({
    required super.name,
    required this.start,
    required this.end,
    this.fromStart = true,
  }) {
    type = 'range_delete';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    if (start < 0 || end > input.length || start > end) {
      throw RangeError('Invalid range');
    }
    final startPos = fromStart ? start : input.length - end;
    final endPos = fromStart ? end : input.length - start;
    return input.substring(0, startPos) + input.substring(endPos);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'start': start,
    'end': end,
    'fromStart': fromStart,
  };

  factory RangeDeleteRule.fromJson(Map<String, dynamic> json) {
    return RangeDeleteRule(
      name: json['name'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      fromStart: json['fromStart'] as bool,
    )..id = json['id'] as String;
  }
}
