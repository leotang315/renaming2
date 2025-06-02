import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:renaming_gui/models/app_state.dart';
import 'package:renaming_gui/utils/message_utils.dart';
import 'package:renaming_gui/utils/theme.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.headerColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return Row(
            children: [
              const Spacer(),
              // 执行按钮
              ElevatedButton(
                onPressed: appState.canExecute
                    ? () => _executeRename(context, appState)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: const Text('重命名'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _executeRename(BuildContext context, AppState appState) async {
    try {
      await appState.executeRename();
      if (context.mounted) {
        MessageUtils.showMessage(
          context,
          message: '重命名完成',
        );
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showMessage(
          context,
          message: '操作失败: $e',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }
}
