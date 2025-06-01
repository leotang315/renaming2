import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/constants.dart';
import 'add_rule_dialog.dart';

class RuleListWidget extends StatelessWidget {
  const RuleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddRuleDialog(context, appState),
                    tooltip: AppConstants.addRuleTooltip,
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: appState.clearRules,
                    tooltip: AppConstants.clearRulesTooltip,
                  ),
                ],
              ),
              const Text(
                AppConstants.rulesLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: appState.rules.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(appState.rules[index].name),
                        subtitle: Text(appState.getRuleDescription(appState.rules[index])),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () => appState.removeRule(index),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRuleDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AddRuleDialog(
        onRuleAdded: appState.addRule,
      ),
    );
  }
}