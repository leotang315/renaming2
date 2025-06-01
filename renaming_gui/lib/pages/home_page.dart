import 'package:flutter/material.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/rule_list_widget.dart';
import '../widgets/preview_widget.dart';
import '../utils/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(AppConstants.appTitle),
      ),
      body: const Row(
        children: [
          // 左侧面板 - 文件和规则
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: FileListWidget()),
                Expanded(child: RuleListWidget()),
              ],
            ),
          ),
          // 右侧面板 - 预览和操作
          Expanded(flex: 2, child: PreviewWidget()),
        ],
      ),
    );
  }
}
