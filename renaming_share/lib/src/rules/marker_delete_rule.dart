import 'rule.dart';

class MarkerDeleteRule extends Rule {
  final String marker;

  MarkerDeleteRule({required super.name, required this.marker}) {
    type = 'marker_delete';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final regex = RegExp(marker);
    return input.replaceAll(regex, '');
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'marker': marker,
  };

  factory MarkerDeleteRule.fromJson(Map<String, dynamic> json) {
    return MarkerDeleteRule(
      name: json['name'] as String,
      marker: json['marker'] as String,
    )..id = json['id'] as String;
  }
}
