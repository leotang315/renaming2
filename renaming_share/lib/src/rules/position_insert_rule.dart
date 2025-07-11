import 'rule.dart';

class PositionInsertRule extends Rule {
  final int position;
  final String content;
  final bool fromStart;

  PositionInsertRule({
    required super.name,
    required this.content,
    required this.position,
    this.fromStart = true,
  }) {
    type = 'position_insert';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    if (position < 0 || position > input.length) {
      throw RangeError('Position out of range');
    }
    final pos = fromStart ? position : input.length - position;
    return input.substring(0, pos) + content + input.substring(pos);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'content': content,
    'position': position,
    'fromStart': fromStart,
  };

  factory PositionInsertRule.fromJson(Map<String, dynamic> json) {
    return PositionInsertRule(
      name: json['name'] as String,
      content: json['content'] as String,
      position: json['position'] as int,
      fromStart: json['fromStart'] as bool,
    )..id = json['id'] as String;
  }
}
