import 'rule.dart';

class CharacterTypeReplaceRule extends Rule {
  final CharacterType characterType;
  final String replacement;

  CharacterTypeReplaceRule({
    required super.name,
    required this.characterType,
    required this.replacement,
  }) {
    type = 'character_type_replace';
  }

  @override
  Future<String> apply(String input, {int? index}) async {
    final pattern = _getPattern();
    return input.replaceAll(RegExp(pattern), replacement);
  }

  String _getPattern() {
    switch (characterType) {
      case CharacterType.number:
        return r'\d';
      case CharacterType.space:
        return r'\s+';
      case CharacterType.letter:
        return r'[a-zA-Z]';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'characterType': characterType.toString(),
    'replacement': replacement,
  };

  factory CharacterTypeReplaceRule.fromJson(Map<String, dynamic> json) {
    return CharacterTypeReplaceRule(
      name: json['name'] as String,
      characterType: CharacterType.values.firstWhere(
        (e) => e.toString() == json['characterType'],
      ),
      replacement: json['replacement'] as String,
    )..id = json['id'] as String;
  }
}
