import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renaming_share/renaming_share.dart';

class AddRuleDialog extends StatefulWidget {
  final Function(Rule) onRuleAdded;
  final Rule? existingRule;

  const AddRuleDialog({
    super.key,
    required this.onRuleAdded,
    this.existingRule,
  });

  @override
  State<AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<AddRuleDialog> {
  String _selectedCategory = 'add';
  String _selectedRuleType = 'addPrefix';

  // 文本参数控制器
  final _param1Controller = TextEditingController();
  final _param2Controller = TextEditingController();
  final _param3Controller = TextEditingController();

  // 数字参数控制器
  final _positionController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _nController = TextEditingController();

  // 规则分类和类型定义
  final Map<String, String> _categories = {
    'add': '添加类规则',
    'remove': '删除类规则',
    'replace': '替换类规则',
  };

  final Map<String, Map<String, String>> _ruleTypes = {
    'add': {
      'addPrefix': '添加前缀',
      'addSuffix': '添加后缀',
      'addAfterPattern': '在模式后添加',
      'addBeforePattern': '在模式前添加',
      'addAtPosition': '在指定位置添加',
      'addBeforeLastN': '在倒数第N个字符前添加',
    },
    'remove': {
      'removePattern': '删除模式',
      'removeNumbers': '删除数字',
      'removeSpaces': '删除空格',
      'removeLetters': '删除字母',
      'removeAtPosition': '删除指定位置字符',
      'removeFromEnd': '从末尾删除N个字符',
      'removeRange': '删除范围内字符',
      'removeBetweenDelimiters': '删除分隔符间内容（保留分隔符）',
      'removeWithDelimiters': '删除分隔符及其间内容',
    },
    'replace': {
      'replacePattern': '替换模式',
      'replaceSpaces': '替换空格',
      'replaceNumbers': '替换数字',
      'replaceLetters': '替换字母',
      'replaceAtPosition': '替换指定位置字符',
      'replaceRange': '替换范围内字符',
      'replaceBetweenDelimiters': '替换分隔符间内容',
    },
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      _initializeFromExistingRule(widget.existingRule!);
    }
  }

  void _initializeFromExistingRule(Rule rule) {
    // 根据规则名称初始化界面
    final ruleName = rule.name;

    // 确定分类和类型
    for (final category in _ruleTypes.keys) {
      for (final type in _ruleTypes[category]!.keys) {
        if (type.toLowerCase().contains(ruleName.toLowerCase()) ||
            ruleName.toLowerCase().contains(type.toLowerCase())) {
          setState(() {
            _selectedCategory = category;
            _selectedRuleType = type;
          });
          break;
        }
      }
    }

    // 这里需要根据具体的Rule结构来解析参数
    // 由于Rule是抽象的，可能需要添加获取参数的方法
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingRule != null ? '编辑规则' : '添加规则'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 规则分类选择
              const Text('规则分类:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _categories.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _selectedRuleType =
                        _ruleTypes[_selectedCategory]!.keys.first;
                    _clearAllControllers();
                  });
                },
              ),
              const SizedBox(height: 16),

              // 具体规则类型选择
              const Text('规则类型:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRuleType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _ruleTypes[_selectedCategory]!
                    .entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRuleType = value!;
                    _clearAllControllers();
                  });
                },
              ),
              const SizedBox(height: 16),

              // 规则描述
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _getRuleDescription(),
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              // 动态参数输入区域
              ..._buildParameterInputs(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _canCreateRule() ? _createRule : null,
          child: Text(widget.existingRule != null ? '更新' : '添加'),
        ),
      ],
    );
  }

  List<Widget> _buildParameterInputs() {
    switch (_selectedRuleType) {
      // 添加类规则
      case 'addPrefix':
        return [
          _buildTextInput('前缀内容', _param1Controller, '要添加的前缀文本'),
        ];
      case 'addSuffix':
        return [
          _buildTextInput('后缀内容', _param1Controller, '要添加的后缀文本'),
        ];
      case 'addAfterPattern':
        return [
          _buildTextInput('匹配模式', _param1Controller, '要匹配的文本模式'),
          const SizedBox(height: 12),
          _buildTextInput('添加内容', _param2Controller, '在匹配模式后添加的内容'),
        ];
      case 'addBeforePattern':
        return [
          _buildTextInput('匹配模式', _param1Controller, '要匹配的文本模式'),
          const SizedBox(height: 12),
          _buildTextInput('添加内容', _param2Controller, '在匹配模式前添加的内容'),
        ];
      case 'addAtPosition':
        return [
          _buildNumberInput('位置', _positionController, '要插入内容的位置（从0开始）'),
          const SizedBox(height: 12),
          _buildTextInput('添加内容', _param1Controller, '要插入的内容'),
        ];
      case 'addBeforeLastN':
        return [
          _buildNumberInput('倒数字符数', _nController, '从末尾开始计算的字符数'),
          const SizedBox(height: 12),
          _buildTextInput('添加内容', _param1Controller, '要插入的内容'),
        ];

      // 删除类规则
      case 'removePattern':
        return [
          _buildTextInput('删除模式', _param1Controller, '要删除的文本模式'),
        ];
      case 'removeNumbers':
      case 'removeSpaces':
      case 'removeLetters':
        return [
          const Text('此规则无需参数', style: TextStyle(color: Colors.grey)),
        ];
      case 'removeAtPosition':
        return [
          _buildNumberInput('位置', _positionController, '要删除字符的位置（从0开始）'),
        ];
      case 'removeFromEnd':
        return [
          _buildNumberInput('删除字符数', _nController, '从末尾删除的字符数量'),
        ];
      case 'removeRange':
        return [
          _buildNumberInput('开始位置', _startController, '删除范围的开始位置（从0开始）'),
          const SizedBox(height: 12),
          _buildNumberInput('结束位置', _endController, '删除范围的结束位置'),
        ];
      case 'removeBetweenDelimiters':
      case 'removeWithDelimiters':
        return [
          _buildTextInput('开始分隔符', _param1Controller, '起始分隔符'),
          const SizedBox(height: 12),
          _buildTextInput('结束分隔符', _param2Controller, '结束分隔符'),
        ];

      // 替换类规则
      case 'replacePattern':
        return [
          _buildTextInput('原模式', _param1Controller, '要替换的文本模式'),
          const SizedBox(height: 12),
          _buildTextInput('新模式', _param2Controller, '替换后的文本'),
        ];
      case 'replaceSpaces':
      case 'replaceNumbers':
      case 'replaceLetters':
        return [
          _buildTextInput('替换内容', _param1Controller, '用于替换的新内容'),
        ];
      case 'replaceAtPosition':
        return [
          _buildNumberInput('位置', _positionController, '要替换字符的位置（从0开始）'),
          const SizedBox(height: 12),
          _buildTextInput('替换内容', _param1Controller, '用于替换的新内容'),
        ];
      case 'replaceRange':
        return [
          _buildNumberInput('开始位置', _startController, '替换范围的开始位置（从0开始）'),
          const SizedBox(height: 12),
          _buildNumberInput('结束位置', _endController, '替换范围的结束位置'),
          const SizedBox(height: 12),
          _buildTextInput('替换内容', _param1Controller, '用于替换的新内容'),
        ];
      case 'replaceBetweenDelimiters':
        return [
          _buildTextInput('开始分隔符', _param1Controller, '起始分隔符'),
          const SizedBox(height: 12),
          _buildTextInput('结束分隔符', _param2Controller, '结束分隔符'),
          const SizedBox(height: 12),
          _buildTextInput('替换内容', _param3Controller, '用于替换的新内容'),
        ];

      default:
        return [];
    }
  }

  Widget _buildTextInput(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: (value) {
            setState(() {}); // 触发界面更新
          },
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            setState(() {}); // 触发界面更新
          },
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  String _getRuleDescription() {
    switch (_selectedRuleType) {
      case 'addPrefix':
        return '在文件名开头添加指定的前缀文本';
      case 'addSuffix':
        return '在文件名末尾添加指定的后缀文本';
      case 'addAfterPattern':
        return '在匹配到的文本模式后面添加指定内容';
      case 'addBeforePattern':
        return '在匹配到的文本模式前面添加指定内容';
      case 'addAtPosition':
        return '在文件名的指定位置插入内容';
      case 'addBeforeLastN':
        return '在文件名倒数第N个字符前插入内容';
      case 'removePattern':
        return '删除文件名中匹配指定模式的所有文本';
      case 'removeNumbers':
        return '删除文件名中的所有数字字符';
      case 'removeSpaces':
        return '删除文件名中的所有空格字符';
      case 'removeLetters':
        return '删除文件名中的所有字母字符';
      case 'removeAtPosition':
        return '删除文件名指定位置的单个字符';
      case 'removeFromEnd':
        return '从文件名末尾删除指定数量的字符';
      case 'removeRange':
        return '删除文件名指定范围内的所有字符';
      case 'removeBetweenDelimiters':
        return '删除两个分隔符之间的内容，但保留分隔符';
      case 'removeWithDelimiters':
        return '删除两个分隔符之间的内容，包括分隔符本身';
      case 'replacePattern':
        return '将文件名中匹配的文本模式替换为新的文本';
      case 'replaceSpaces':
        return '将文件名中的所有空格替换为指定内容';
      case 'replaceNumbers':
        return '将文件名中的所有数字替换为指定内容';
      case 'replaceLetters':
        return '将文件名中的所有字母替换为指定内容';
      case 'replaceAtPosition':
        return '替换文件名指定位置的单个字符';
      case 'replaceRange':
        return '替换文件名指定范围内的所有字符';
      case 'replaceBetweenDelimiters':
        return '替换两个分隔符之间的内容，保留分隔符';
      default:
        return '请选择一个规则类型';
    }
  }

  bool _canCreateRule() {
    switch (_selectedRuleType) {
      case 'addPrefix':
      case 'addSuffix':
      case 'removePattern':
      case 'replaceSpaces':
      case 'replaceNumbers':
      case 'replaceLetters':
        return _param1Controller.text.isNotEmpty;

      case 'addAfterPattern':
      case 'addBeforePattern':
      case 'replacePattern':
      case 'removeBetweenDelimiters':
      case 'removeWithDelimiters':
        return _param1Controller.text.isNotEmpty &&
            _param2Controller.text.isNotEmpty;

      case 'addAtPosition':
      case 'replaceAtPosition':
        return _positionController.text.isNotEmpty &&
            _param1Controller.text.isNotEmpty;

      case 'addBeforeLastN':
        return _nController.text.isNotEmpty &&
            _param1Controller.text.isNotEmpty;

      case 'removeAtPosition':
      case 'removeFromEnd':
        return _positionController.text.isNotEmpty ||
            _nController.text.isNotEmpty;

      case 'removeRange':
      case 'replaceRange':
        return _startController.text.isNotEmpty &&
            _endController.text.isNotEmpty &&
            (_selectedRuleType == 'removeRange' ||
                _param1Controller.text.isNotEmpty);

      case 'replaceBetweenDelimiters':
        return _param1Controller.text.isNotEmpty &&
            _param2Controller.text.isNotEmpty &&
            _param3Controller.text.isNotEmpty;

      case 'removeNumbers':
      case 'removeSpaces':
      case 'removeLetters':
        return true;

      default:
        return false;
    }
  }

  void _createRule() {
    Rule rule;

    try {
      switch (_selectedRuleType) {
        // 添加类规则
        case 'addPrefix':
          rule = RuleFactory.addPrefix(_param1Controller.text);
          break;
        case 'addSuffix':
          rule = RuleFactory.addSuffix(_param1Controller.text);
          break;
        case 'addAfterPattern':
          rule = RuleFactory.addAfterPattern(
              _param1Controller.text, _param2Controller.text);
          break;
        case 'addBeforePattern':
          rule = RuleFactory.addBeforePattern(
              _param1Controller.text, _param2Controller.text);
          break;
        case 'addAtPosition':
          rule = RuleFactory.addAtPosition(
              int.parse(_positionController.text), _param1Controller.text);
          break;
        case 'addBeforeLastN':
          rule = RuleFactory.addBeforeLastN(
              int.parse(_nController.text), _param1Controller.text);
          break;

        // 删除类规则
        case 'removePattern':
          rule = RuleFactory.removePattern(_param1Controller.text);
          break;
        case 'removeNumbers':
          rule = RuleFactory.removeNumbers();
          break;
        case 'removeSpaces':
          rule = RuleFactory.removeSpaces();
          break;
        case 'removeLetters':
          rule = RuleFactory.removeLetters();
          break;
        case 'removeAtPosition':
          rule =
              RuleFactory.removeAtPosition(int.parse(_positionController.text));
          break;
        case 'removeFromEnd':
          rule = RuleFactory.removeFromEnd(int.parse(_nController.text));
          break;
        case 'removeRange':
          rule = RuleFactory.removeRange(
              int.parse(_startController.text), int.parse(_endController.text));
          break;
        case 'removeBetweenDelimiters':
          rule = RuleFactory.removeBetweenDelimiters(
              _param1Controller.text, _param2Controller.text);
          break;
        case 'removeWithDelimiters':
          rule = RuleFactory.removeWithDelimiters(
              _param1Controller.text, _param2Controller.text);
          break;

        // 替换类规则
        case 'replacePattern':
          rule = RuleFactory.replacePattern(
              _param1Controller.text, _param2Controller.text);
          break;
        case 'replaceSpaces':
          rule = RuleFactory.replaceSpaces(_param1Controller.text);
          break;
        case 'replaceNumbers':
          rule = RuleFactory.replaceNumbers(_param1Controller.text);
          break;
        case 'replaceLetters':
          rule = RuleFactory.replaceLetters(_param1Controller.text);
          break;
        case 'replaceAtPosition':
          rule = RuleFactory.replaceAtPosition(
              int.parse(_positionController.text), _param1Controller.text);
          break;
        case 'replaceRange':
          rule = RuleFactory.replaceRange(int.parse(_startController.text),
              int.parse(_endController.text), _param1Controller.text);
          break;
        case 'replaceBetweenDelimiters':
          rule = RuleFactory.replaceBetweenDelimiters(_param1Controller.text,
              _param2Controller.text, _param3Controller.text);
          break;

        default:
          return;
      }

      widget.onRuleAdded(rule);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建规则失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearAllControllers() {
    _param1Controller.clear();
    _param2Controller.clear();
    _param3Controller.clear();
    _positionController.clear();
    _startController.clear();
    _endController.clear();
    _nController.clear();
  }

  @override
  void dispose() {
    _param1Controller.dispose();
    _param2Controller.dispose();
    _param3Controller.dispose();
    _positionController.dispose();
    _startController.dispose();
    _endController.dispose();
    _nController.dispose();
    super.dispose();
  }
}
