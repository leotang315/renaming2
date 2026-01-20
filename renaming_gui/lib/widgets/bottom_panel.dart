import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/message_utils.dart';
import '../utils/theme.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // 状态信息
              Icon(Icons.info_outline,
                  size: 14, color: AppTheme.textMutedColor),
              const SizedBox(width: 6),
              Text(
                '${appState.selectedCount}/${appState.files.length} 个文件',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMutedColor,
                ),
              ),
              const SizedBox(width: 16),
              if (appState.rules.isNotEmpty) ...[
                Icon(Icons.rule, size: 14, color: AppTheme.textMutedColor),
                const SizedBox(width: 6),
                Text(
                  '${appState.rules.length} 条规则',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMutedColor,
                  ),
                ),
              ],
              if (appState.isProcessing) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: appState.processingTotal > 0
                        ? appState.processingProgress
                        : null,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  appState.processingLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMutedColor,
                  ),
                ),
                if (appState.processingTotal > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${appState.processingCurrent}/${appState.processingTotal}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMutedColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: appState.processingProgress,
                      color: AppTheme.primaryColor,
                      backgroundColor: AppTheme.borderColor,
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
              const Spacer(),
              // 执行按钮
              ElevatedButton(
                onPressed: appState.canExecute && !appState.isProcessing
                    ? () => _executeRename(context, appState)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
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
