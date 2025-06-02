import 'package:flutter/material.dart';
import './theme.dart';

class MessageUtils {
  static void showMessage(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppTheme.successColor,
    Duration duration = const Duration(seconds: 1),
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );
    }
  }

  static void showError(BuildContext context, Object error) {
    showMessage(
      context,
      message: '操作失败: ${error.toString()}',
      backgroundColor: AppTheme.errorColor,
    );
  }
}