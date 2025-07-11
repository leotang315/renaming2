import 'rule.dart';

class MarkerInsertRule extends Rule {
  final String marker;
  final String content;
  final bool before;

  MarkerInsertRule({
    required super.name,
    required this.content,
    required this.marker,
    this.before = true,
  }) {
    type = 'marker_insert';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final pos = input.indexOf(marker);
    if (pos == -1) {
      return input; // 如果找不到标记，返回原始输入
    }
    return before
        ? input.substring(0, pos) + content + input.substring(pos)
        : input.substring(0, pos + marker.length) +
            content +
            input.substring(pos + marker.length);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'content': content,
    'marker': marker,
    'before': before,
  };

  factory MarkerInsertRule.fromJson(Map<String, dynamic> json) {
    return MarkerInsertRule(
      name: json['name'] as String,
      content: json['content'] as String,
      marker: json['marker'] as String,
      before: json['before'] as bool,
    )..id = json['id'] as String;
  }
}
