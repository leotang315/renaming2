import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:renaming_share/renaming_share.dart';
import '../models/app_state.dart';
import '../utils/theme.dart';
import 'add_rule_dialog.dart';

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
          child: Row(
            children: [
              Text(
                '重命名规则',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
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
                    // 规则组
                    if (appState.rules.isNotEmpty)
                      ..._buildRuleGroups(context, appState),

                    // 添加规则按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showAddRuleDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('+ 添加规则'),
                      ),
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

  List<Widget> _buildRuleGroups(BuildContext context, AppState appState) {
    final groups = <String, List<Rule>>{};

    for (final rule in appState.rules) {
      final groupName = _getRuleGroupName(rule);
      groups.putIfAbsent(groupName, () => []).add(rule);
    }

    return groups.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 组标题
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF094771),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                entry.key,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 规则项
            ...entry.value.asMap().entries.map((ruleEntry) {
              final globalIndex = appState.rules.indexOf(ruleEntry.value);
              return _buildRuleItem(
                  context, appState, ruleEntry.value, globalIndex);
            }),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildRuleItem(
      BuildContext context, AppState appState, Rule rule, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.headerColor,
        borderRadius: BorderRadius.circular(3),
        border: const Border(
          left: BorderSide(color: Color(0xFF007ACC), width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              appState.getRuleDescription(rule),
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 12,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _editRule(context, rule, index),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Text('✏️', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => appState.removeRule(index),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Text('❌', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRuleGroupName(Rule rule) {
    if (rule.name.contains('前缀') || rule.name.contains('后缀')) {
      return '添加文本';
    } else if (rule.name.contains('替换')) {
      return '替换文本';
    } else if (rule.name.contains('删除') || rule.name.contains('移除')) {
      return '移除文本';
    }
    return '其他规则';
  }

  void _showAddRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddRuleDialog(onRuleAdded: (rule) {
        // 关闭对话框
        Navigator.of(context).pop();
      }),
    );
  }

  void _editRule(BuildContext context, Rule rule, int index) {
    // 编辑规则功能
    showDialog(
      context: context,
      builder: (context) => AddRuleDialog(
        onRuleAdded: (rule) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
