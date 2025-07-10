import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:renaming_share/renaming_share.dart';
import '../models/app_state.dart';
import '../utils/theme.dart';
import 'add_rule_dialog.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class RulesPanel extends StatelessWidget {
  const RulesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 面板头部
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 48,
          decoration: const BoxDecoration(
            color: AppTheme.headerColor,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  const Icon(Icons.rule, color: AppTheme.textColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '规则',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  // 添加规则按钮
                  Tooltip(
                    message: '添加规则',
                    child: IconButton(
                      onPressed: () => _showAddRuleDialog(context),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      color: AppTheme.textColor,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.successColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 保存配置按钮
                  Tooltip(
                    message: '保存配置',
                    child: IconButton(
                      onPressed: () => _saveRulesConfig(context, appState),
                      icon: const Icon(Icons.upload, size: 18),
                      color: AppTheme.textColor,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 加载配置按钮
                  Tooltip(
                    message: '加载配置',
                    child: IconButton(
                      onPressed: () => _loadRulesConfig(context, appState),
                      icon: const Icon(Icons.download, size: 18),
                      color: AppTheme.textColor,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 规则内容
        Expanded(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // 规则列表区域 - 添加滚动功能
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // 规则组
                            if (appState.rules.isNotEmpty)
                              ..._buildRuleList(context, appState),
                          ],
                        ),
                      ),
                    ),

                    // 底部固定区域 - 只保留处理扩展名的checkbox
                    Column(
                      children: [
                        // 添加处理扩展名的checkbox
                        Container(
                          height: 32,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.headerColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              Checkbox(
                                value: appState.processExtension,
                                onChanged: (value) {
                                  appState.setProcessExtension(value ?? false);
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 8),
                              const Tooltip(
                                message: '勾选后，重命名规则将应用到文件扩展名部分',
                                child: Text(
                                  '处理文件扩展名',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(
      BuildContext context, AppState appState, Rule rule, int index) {
    return ExpansionTile(
      title: Text(
        appState.getRuleDescription(rule),
        style: const TextStyle(
          color: AppTheme.textColor,
          fontSize: 12,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _editRule(context, rule, index),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.edit, size: 14, color: AppTheme.textColor),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => appState.removeRule(index),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.delete, size: 14, color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 根据规则类型显示不同的编辑界面
              _buildRuleEditingFields(rule, index, appState),
            ],
          ),
        ),
      ],
    );
  }

  // 添加新的辅助方法来构建规则编辑字段
  Widget _buildRuleEditingFields(Rule rule, int index, AppState appState) {
    // 根据规则类型返回对应的编辑字段
    if (rule is PatternRule) {
      return _buildTextEditField(
        '前缀内容：',
        "rule.prefix",
        (value) => _updateRule(index, RuleFactory.addPrefix(value), appState),
      );
    } else if (rule is PatternRule) {
      return _buildTextEditField(
        '后缀内容：',
        "rule.suffix",
        (value) => _updateRule(index, RuleFactory.addSuffix(value), appState),
      );
    }
    // 可以继续添加其他规则类型的编辑字段
    return const Text('暂不支持直接编辑此类规则');
  }

  // 添加新的辅助方法来构建文本编辑字段
  Widget _buildTextEditField(
      String label, String initialValue, Function(String) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: initialValue),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // 添加新的辅助方法来更新规则
  void _updateRule(int index, Rule newRule, AppState appState) {
    appState.updateRule(index, newRule);
  }

  void _showAddRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddRuleDialog(onRuleAdded: (rule) {
        Provider.of<AppState>(context, listen: false).addRule(rule);
      }),
    );
  }

  void _editRule(BuildContext context, Rule rule, int index) {
    // 编辑规则功能
    showDialog(
      context: context,
      builder: (context) => AddRuleDialog(
        existingRule: rule, // 传入现有规则
        onRuleAdded: (updatedRule) {
          // 更新规则
          Provider.of<AppState>(context, listen: false)
              .updateRule(index, updatedRule);
        },
      ),
    );
  }

  List<Widget> _buildRuleList(BuildContext context, AppState appState) {
    return appState.rules.asMap().entries.map((entry) {
      final index = entry.key;
      final rule = entry.value;
      return _buildRuleItem(context, appState, rule, index);
    }).toList();
  }

  // 保存规则配置
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
        };

        final file = File(outputFile);
        await file.writeAsString(jsonEncode(config));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('规则配置保存成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 加载规则配置
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

        // 清空现有规则
        appState.clearRules();

        // 加载规则
        if (config['rules'] != null) {
          final rules = (config['rules'] as List)
              .map((ruleJson) => Rule.fromJson(ruleJson))
              .toList();
          for (final rule in rules) {
            appState.addRule(rule);
          }
        }

        // 加载处理扩展名设置
        if (config['processExtension'] != null) {
          appState.setProcessExtension(config['processExtension'] as bool);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('规则配置加载成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
