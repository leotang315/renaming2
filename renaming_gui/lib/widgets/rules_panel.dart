import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:renaming_share/renaming_share.dart';
import '../models/app_state.dart';
import '../utils/theme.dart';
import 'add_rule_dialog.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class RulesPanel extends StatefulWidget {
  const RulesPanel({super.key});

  @override
  State<RulesPanel> createState() => _RulesPanelState();
}

class _RulesPanelState extends State<RulesPanel> {
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _expandedRuleIds = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 48,
          decoration: const BoxDecoration(
            color: AppTheme.headerColor,
            border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  const Icon(Icons.rule, color: AppTheme.textColor, size: 16),
                  const SizedBox(width: 8),
                  Text('规则', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  _buildHeaderIconButton(
                    icon: Icons.add,
                    tooltip: 'Add Rule',
                    onPressed: () => _showAddRuleDialog(context, appState),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    icon: Icons.upload,
                    tooltip: 'Save Config',
                    onPressed: () => _saveRulesConfig(context, appState),
                  ),
                  const SizedBox(width: 4),
                  _buildHeaderIconButton(
                    icon: Icons.download,
                    tooltip: 'Load Config',
                    onPressed: () => _loadRulesConfig(context, appState),
                  ),
                ],
              );
            },
          ),
        ),

        // Body
        Expanded(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return appState.rules.isEmpty
                  ? Center(
                      child: Text(
                        'No rules added yet',
                        style: TextStyle(color: AppTheme.textMutedColor),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: appState.rules.length,
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        appState.reorderRules(oldIndex, newIndex);
                      },
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.panelColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: child,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final rule = appState.rules[index];
                        return _buildRuleCard(context, appState, rule, index);
                      },
                    );
            },
          ),
        ),

        // Footer (Extension Checkbox)
        Consumer<AppState>(
          builder: (context, appState, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.headerColor,
                border: Border(top: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 24,
                    child: Checkbox(
                      value: appState.processExtension,
                      onChanged: (value) =>
                          appState.setProcessExtension(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Process Extension',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 32),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        color: AppTheme.textColor,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildRuleCard(
      BuildContext context, AppState appState, Rule rule, int index) {
    final isExpanded = _expandedRuleIds.contains(rule.id);
    final isEnabled = appState.isRuleEnabled(rule);

    return Container(
      key: ValueKey(rule.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.panelColor,
        border: Border.all(
          color: isExpanded ? AppTheme.primaryColor : AppTheme.borderColor,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Card Header
          ReorderableDragStartListener(
            index: index,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedRuleIds.remove(rule.id);
                  } else {
                    _expandedRuleIds.add(rule.id);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Checkbox(
                      value: isEnabled,
                      onChanged: (value) =>
                          appState.setRuleEnabled(rule.id, value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Icon(Icons.drag_indicator,
                        color: Colors.grey, size: 16),
                    const SizedBox(width: 12),
                    Opacity(
                      opacity: isEnabled ? 1 : 0.5,
                      child: _buildRuleIcon(rule),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Opacity(
                        opacity: isEnabled ? 1 : 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getRuleTitle(rule),
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getRuleSummary(rule),
                              style: TextStyle(
                                color: AppTheme.textMutedColor,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: AppTheme.errorColor),
                      onPressed: () => appState.removeRule(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded Content (Editing)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color:
                    Color(0xFF2A2A2C), // Slightly lighter/darker bg for editing
                border: Border(top: BorderSide(color: AppTheme.borderColor)),
              ),
              child: _buildRuleEditingFields(rule, index, appState),
            ),
        ],
      ),
    );
  }

  Widget _buildRuleIcon(Rule rule) {
    IconData icon;
    Color color;
    Color bg;

    if (rule.type.contains('insert')) {
      icon = Icons.add;
      color = AppTheme.successColor;
      bg = AppTheme.successColor.withOpacity(0.1);
    } else if (rule.type.contains('delete')) {
      icon = Icons.remove;
      color = AppTheme.errorColor;
      bg = AppTheme.errorColor.withOpacity(0.1);
    } else if (rule.type.contains('replace')) {
      icon = Icons.sync;
      color = AppTheme.primaryColor;
      bg = AppTheme.primaryColor.withOpacity(0.1);
    } else {
      icon = Icons.code;
      color = Colors.orange;
      bg = Colors.orange.withOpacity(0.1);
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  String _getRuleTitle(Rule rule) {
    // Convert snake_case to Title Case
    return rule.name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String _getRuleSummary(Rule rule) {
    if (rule is PositionInsertRule) {
      return 'Insert "${rule.content}" at index ${rule.position}';
    } else if (rule is MarkerInsertRule) {
      return 'Insert "${rule.content}" ${rule.before ? 'before' : 'after'} "${rule.marker}"';
    } else if (rule is RangeDeleteRule) {
      return 'Delete from ${rule.start} to ${rule.end}';
    } else if (rule is PatternRule) {
      return 'Regex: ${rule.pattern} -> ${rule.replace}';
    }
    return rule.type;
  }

  Widget _buildRuleEditingFields(Rule rule, int index, AppState appState) {
    if (rule is PositionInsertRule) {
      return Column(
        children: [
          _buildTextField(
              rule,
              '插入内容',
              rule.content,
              (v) => _updateRule(
                  index,
                  PositionInsertRule(
                      name: rule.name,
                      content: v,
                      position: rule.position,
                      fromStart: rule.fromStart)
                    ..id = rule.id,
                  appState)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    rule,
                    '插入位置',
                    rule.position.toString(),
                    (v) => _updateRule(
                        index,
                        PositionInsertRule(
                            name: rule.name,
                            content: rule.content,
                            position: int.tryParse(v) ?? 0,
                            fromStart: rule.fromStart)
                          ..id = rule.id,
                        appState),
                    isNumber: true),
              ),
              const SizedBox(width: 12),
              _buildSwitch(
                  '从开头',
                  rule.fromStart,
                  (v) => _updateRule(
                      index,
                      PositionInsertRule(
                          name: rule.name,
                          content: rule.content,
                          position: rule.position,
                          fromStart: v)
                        ..id = rule.id,
                      appState)),
            ],
          ),
        ],
      );
    } else if (rule is MarkerInsertRule) {
      return Column(
        children: [
          _buildTextField(
              rule,
              '标记',
              rule.marker,
              (v) => _updateRule(
                  index,
                  MarkerInsertRule(
                      name: rule.name,
                      content: rule.content,
                      marker: v,
                      before: rule.before)
                    ..id = rule.id,
                  appState)),
          const SizedBox(height: 8),
          _buildTextField(
              rule,
              '插入内容',
              rule.content,
              (v) => _updateRule(
                  index,
                  MarkerInsertRule(
                      name: rule.name,
                      content: v,
                      marker: rule.marker,
                      before: rule.before)
                    ..id = rule.id,
                  appState)),
          const SizedBox(height: 8),
          _buildSwitch(
              '在标记前插入',
              rule.before,
              (v) => _updateRule(
                  index,
                  MarkerInsertRule(
                      name: rule.name,
                      content: rule.content,
                      marker: rule.marker,
                      before: v)
                    ..id = rule.id,
                  appState)),
        ],
      );
    } else if (rule is MarkerDeleteRule) {
      return _buildTextField(
          rule,
          '删除标记',
          rule.marker,
          (v) => _updateRule(
              index,
              MarkerDeleteRule(name: rule.name, marker: v)..id = rule.id,
              appState));
    } else if (rule is RangeDeleteRule) {
      return Row(
        children: [
          Expanded(
            child: _buildTextField(
                rule,
                '起始位置',
                rule.start.toString(),
                (v) => _updateRule(
                    index,
                    RangeDeleteRule(
                        name: rule.name,
                        start: int.tryParse(v) ?? 0,
                        end: rule.end,
                        fromStart: rule.fromStart)
                      ..id = rule.id,
                    appState),
                isNumber: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
                rule,
                '结束位置',
                rule.end.toString(),
                (v) => _updateRule(
                    index,
                    RangeDeleteRule(
                        name: rule.name,
                        start: rule.start,
                        end: int.tryParse(v) ?? 0,
                        fromStart: rule.fromStart)
                      ..id = rule.id,
                    appState),
                isNumber: true),
          ),
        ],
      );
    } else if (rule is RangeReplaceRule) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    rule,
                    '起始位置',
                    rule.start.toString(),
                    (v) => _updateRule(
                        index,
                        RangeReplaceRule(
                            name: rule.name,
                            start: int.tryParse(v) ?? 0,
                            end: rule.end,
                            content: rule.content)
                          ..id = rule.id,
                        appState),
                    isNumber: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    rule,
                    '结束位置',
                    rule.end.toString(),
                    (v) => _updateRule(
                        index,
                        RangeReplaceRule(
                            name: rule.name,
                            start: rule.start,
                            end: int.tryParse(v) ?? 0,
                            content: rule.content)
                          ..id = rule.id,
                        appState),
                    isNumber: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
              rule,
              '替换内容',
              rule.content,
              (v) => _updateRule(
                  index,
                  RangeReplaceRule(
                      name: rule.name,
                      start: rule.start,
                      end: rule.end,
                      content: v)
                    ..id = rule.id,
                  appState)),
        ],
      );
    } else if (rule is PatternRule) {
      return Column(
        children: [
          _buildTextField(
              rule,
              '正则表达式',
              rule.pattern,
              (v) => _updateRule(
                  index,
                  PatternRule(
                      name: rule.name, pattern: v, replace: rule.replace)
                    ..id = rule.id,
                  appState)),
          const SizedBox(height: 8),
          _buildTextField(
              rule,
              '替换内容',
              rule.replace,
              (v) => _updateRule(
                  index,
                  PatternRule(
                      name: rule.name, pattern: rule.pattern, replace: v)
                    ..id = rule.id,
                  appState)),
        ],
      );
    } else if (rule is DelimiterDeleteRule) {
      return Row(
        children: [
          Expanded(
              child: _buildTextField(
                  rule,
                  '起始分隔符',
                  rule.startDelimiter,
                  (v) => _updateRule(
                      index,
                      DelimiterDeleteRule(
                          name: rule.name,
                          startDelimiter: v,
                          endDelimiter: rule.endDelimiter,
                          keepDelimiters: rule.keepDelimiters)
                        ..id = rule.id,
                      appState))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildTextField(
                  rule,
                  '结束分隔符',
                  rule.endDelimiter,
                  (v) => _updateRule(
                      index,
                      DelimiterDeleteRule(
                          name: rule.name,
                          startDelimiter: rule.startDelimiter,
                          endDelimiter: v,
                          keepDelimiters: rule.keepDelimiters)
                        ..id = rule.id,
                      appState))),
        ],
      );
    } else if (rule is DelimiterReplaceRule) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      rule,
                      '起始分隔符',
                      rule.startDelimiter,
                      (v) => _updateRule(
                          index,
                          DelimiterReplaceRule(
                              name: rule.name,
                              startDelimiter: v,
                              endDelimiter: rule.endDelimiter,
                              replacement: rule.replacement,
                              keepDelimiters: rule.keepDelimiters)
                            ..id = rule.id,
                          appState))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                      rule,
                      '结束分隔符',
                      rule.endDelimiter,
                      (v) => _updateRule(
                          index,
                          DelimiterReplaceRule(
                              name: rule.name,
                              startDelimiter: rule.startDelimiter,
                              endDelimiter: v,
                              replacement: rule.replacement,
                              keepDelimiters: rule.keepDelimiters)
                            ..id = rule.id,
                          appState))),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
              rule,
              '替换内容',
              rule.replacement,
              (v) => _updateRule(
                  index,
                  DelimiterReplaceRule(
                      name: rule.name,
                      startDelimiter: rule.startDelimiter,
                      endDelimiter: rule.endDelimiter,
                      replacement: v,
                      keepDelimiters: rule.keepDelimiters)
                    ..id = rule.id,
                  appState)),
        ],
      );
    } else if (rule is CharacterTypeDeleteRule) {
      return const Text('字符类型删除暂不支持编辑',
          style: TextStyle(color: AppTheme.textMutedColor));
    } else if (rule is CharacterTypeReplaceRule) {
      return _buildTextField(
          rule,
          '替换内容',
          rule.replacement,
          (v) => _updateRule(
              index,
              CharacterTypeReplaceRule(
                  name: rule.name,
                  characterType: rule.characterType,
                  replacement: v)
                ..id = rule.id,
              appState));
    } else if (rule is MarkerReplaceRule) {
      return Column(
        children: [
          _buildTextField(
              rule,
              '标记',
              rule.marker,
              (v) => _updateRule(
                  index,
                  MarkerReplaceRule(
                      name: rule.name, marker: v, content: rule.content)
                    ..id = rule.id,
                  appState)),
          const SizedBox(height: 8),
          _buildTextField(
              rule,
              '替换内容',
              rule.content,
              (v) => _updateRule(
                  index,
                  MarkerReplaceRule(
                      name: rule.name, marker: rule.marker, content: v)
                    ..id = rule.id,
                  appState)),
        ],
      );
    }

    return const Text('此规则暂不支持编辑',
        style: TextStyle(color: AppTheme.textMutedColor));
  }

  Widget _buildTextField(
      Rule rule, String label, String value, Function(String) onChanged,
      {bool isNumber = false}) {
    final controllerKey = '${rule.id}-$label';
    final controller = _getController(controllerKey, value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textMutedColor, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: AppTheme.textColor),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.borderColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryColor)),
            fillColor: AppTheme.backgroundColor,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _updateRule(int index, Rule newRule, AppState appState) {
    appState.updateRule(index, newRule);
  }

  void _showAddRuleDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: AddRuleDialog(
            onRuleAdded: (rule) {
              Navigator.of(dialogContext).pop();
              appState.addRule(rule);
            },
            onCancel: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  TextEditingController _getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    }
    return _controllers[key]!;
  }

  Future<void> _saveRulesConfig(BuildContext context, AppState appState) async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '保存规则配置',
        fileName: 'rules_config.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final config = {
          'rules': appState.rules.map((rule) => rule.toJson()).toList(),
          'processExtension': appState.processExtension,
          'enabledRuleIds': appState.enabledRuleIds,
        };

        final file = File(outputFile);
        await file.writeAsString(jsonEncode(config));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('规则配置保存成功'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadRulesConfig(BuildContext context, AppState appState) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: '选择规则配置文件',
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final config = jsonDecode(content) as Map<String, dynamic>;

        appState.clearRules();

        if (config['rules'] != null) {
          final rules = (config['rules'] as List)
              .map((ruleJson) => Rule.fromJson(ruleJson))
              .toList();
          for (final rule in rules) {
            appState.addRule(rule);
          }
        }

        if (config['processExtension'] != null) {
          appState.setProcessExtension(config['processExtension'] as bool);
        }

        if (config['enabledRuleIds'] != null) {
          final enabledIds =
              (config['enabledRuleIds'] as List).cast<String>().toSet();
          appState.setEnabledRuleIds(enabledIds);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('规则配置加载成功'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
