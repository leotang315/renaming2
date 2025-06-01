import 'package:flutter/material.dart';
import 'package:renaming_share/renaming_share.dart';
import '../utils/constants.dart';

class AddRuleDialog extends StatefulWidget {
  final Function(Rule) onRuleAdded;

  const AddRuleDialog({super.key, required this.onRuleAdded});

  @override
  State<AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<AddRuleDialog> {
  String _selectedRuleType = 'addPrefix';
  final _param1Controller = TextEditingController();
  final _param2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppConstants.addRuleTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedRuleType,
            items:
                AppConstants.ruleTypes.entries
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
        break;
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
