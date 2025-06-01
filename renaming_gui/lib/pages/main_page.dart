import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/rules_panel.dart';
import '../widgets/files_panel.dart';
import '../utils/theme.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // 左侧规则面板
          Container(
            width: 300,
            decoration: const BoxDecoration(
              color: AppTheme.panelColor,
              border: Border(
                right: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: const RulesPanel(),
          ),
          // 右侧文件面板
          const Expanded(
            child: FilesPanel(),
          ),
        ],
      ),
    );
  }
}