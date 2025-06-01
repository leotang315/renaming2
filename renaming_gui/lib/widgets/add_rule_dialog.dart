import 'package:flutter/material.dart';
import 'package:renaming_share/renaming_share.dart';
import '../utils/constants.dart';

class AddRuleDialog extends StatefulWidget {
  final Function(Rule) onRuleAdded;
  final Rule? existingRule; // 添加可选的现有规则参数

  const AddRuleDialog({
    super.key,
    required this.onRuleAdded,
    this.existingRule, // 支持编辑现有规则
  });

  @override
  State<AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<AddRuleDialog> {
  String _selectedRuleType = 'addPrefix';
  final _param1Controller = TextEditingController();
  final _param2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，初始化现有规则的数据
    if (widget.existingRule != null) {
      _initializeFromExistingRule(widget.existingRule!);
    }
  }

  void _initializeFromExistingRule(Rule rule) {
    // 根据规则类型设置对应的参数
    // 这里需要根据具体的规则类型来解析参数
    // 示例实现，需要根据实际的Rule结构调整
    _selectedRuleType = _getRuleTypeFromRule(rule);
    // 设置参数控制器的值
    // _param1Controller.text = rule.param1 ?? '';
    // _param2Controller.text = rule.param2 ?? '';
  }

  String _getRuleTypeFromRule(Rule rule) {
    // 根据规则名称或类型返回对应的规则类型键
    // 这里需要根据实际的Rule结构实现
    return 'addPrefix'; // 默认值
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existingRule != null ? '编辑规则' : AppConstants.addRuleTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedRuleType,
            items: AppConstants.ruleTypes.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedRuleType = value!;
                _param1Controller.clear();
                _param2Controller.clear();
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _param1Controller,
            decoration: InputDecoration(labelText: _getParam1Label()),
          ),
          if (_needsParam2()) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _param2Controller,
              decoration: InputDecoration(labelText: _getParam2Label()),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppConstants.cancelButton),
        ),
        ElevatedButton(
          onPressed: _addRule,
          child: const Text(AppConstants.addButton),
        ),
      ],
    );
  }

  String _getParam1Label() {
    return AppConstants.paramLabels[_selectedRuleType] ?? '参数1';
  }

  String _getParam2Label() {
    return AppConstants.paramLabels['${_selectedRuleType}_new'] ?? '参数2';
  }

  bool _needsParam2() {
    return _selectedRuleType == 'replacePattern';
  }

  void _addRule() {
    if (_param1Controller.text.isEmpty) return;
    if (_needsParam2() && _param2Controller.text.isEmpty) return;

    Rule rule;

    switch (_selectedRuleType) {
      case 'addPrefix':
        rule = RuleFactory.addPrefix(_param1Controller.text);
        break;
      case 'addSuffix':
        rule = RuleFactory.addSuffix(_param1Controller.text);
        break;
      case 'removePattern':
        rule = RuleFactory.removePattern(_param1Controller.text);
        break;
      case 'replacePattern':
        rule = RuleFactory.replacePattern(
          _param1Controller.text,
          _param2Controller.text,
        );
      default:
        return;
    }

    widget.onRuleAdded(rule);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _param1Controller.dispose();
    _param2Controller.dispose();
    super.dispose();
  }
}
