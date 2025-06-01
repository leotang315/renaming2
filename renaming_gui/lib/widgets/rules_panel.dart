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
              const Icon(Icons.settings, color: AppTheme.textColor, size: 16),
              const SizedBox(width: 8),
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
                      ..._buildRuleList(context, appState),

                    // 添加处理扩展名的checkbox
                    Container(
                      height: 32,
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.headerColor,
                        borderRadius: BorderRadius.circular(3),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF007ACC), width: 3),
                        ),
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
}
