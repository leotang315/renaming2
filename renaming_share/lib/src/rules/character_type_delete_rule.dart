import 'rule.dart';

class CharacterTypeDeleteRule extends Rule {
  final CharacterType characterType;

  CharacterTypeDeleteRule({required super.name, required this.characterType}) {
    type = 'character_type_delete';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final pattern = _getPattern();
    return input.replaceAll(RegExp(pattern), '');
  }

  String _getPattern() {
    switch (characterType) {
      case CharacterType.number:
        return r'\d+';
      case CharacterType.space:
        return r'\s+';
      case CharacterType.letter:
        return r'[a-zA-Z]+';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'characterType': characterType.toString(),
  };

  factory CharacterTypeDeleteRule.fromJson(Map<String, dynamic> json) {
    return CharacterTypeDeleteRule(
      name: json['name'] as String,
      characterType: CharacterType.values.firstWhere(
        (e) => e.toString() == json['characterType'],
      ),
    )..id = json['id'] as String;
  }
}
