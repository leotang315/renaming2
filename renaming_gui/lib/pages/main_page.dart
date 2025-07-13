import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/Bottom_panel.dart';
import '../models/app_state.dart';
import '../widgets/rules_panel.dart';
import '../widgets/files_panel.dart';
import '../utils/theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _rulesPanelWidth = 200.0;
  final double _minWidth = 200.0;
  final double _maxWidth = 500.0;
  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // 左侧规则面板
          Container(
            width: _rulesPanelWidth,
            decoration: const BoxDecoration(
              color: AppTheme.panelColor,
            ),
            child: const RulesPanel(),
          ),
          // 可拖拽的分隔条
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isResizing = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _rulesPanelWidth += details.delta.dx;
                  _rulesPanelWidth =
                      _rulesPanelWidth.clamp(_minWidth, _maxWidth);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isResizing = false;
                });
              },
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _isResizing
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : AppTheme.borderColor,
                  border: const Border(
                    right: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  color:
                      _isResizing ? AppTheme.primaryColor : Colors.transparent,
                ),
              ),
            ),
          ),
          // 右侧文件面板
          const Expanded(
            child: FilesPanel(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomPanel(),
    );
  }
}
