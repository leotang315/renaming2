import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/Bottom_panel.dart';
import '../models/app_state.dart';
import '../widgets/rules_panel.dart';
import '../widgets/files_panel.dart';
import '../utils/theme.dart';
import 'package:window_manager/window_manager.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WindowListener {
  double _rulesPanelWidth = 200.0;
  final double _minWidth = 200.0;
  final double _maxWidth = 500.0;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return AbsorbPointer(
            absorbing: appState.isProcessing,
            child: child!,
          );
        },
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Container(
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Text(AppConstants.appTitle),
                    const Spacer(),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          windowManager.minimize();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.crop_square, size: 18),
                        onPressed: () async {
                          if (await windowManager.isMaximized()) {
                            windowManager.restore();
                          } else {
                            windowManager.maximize();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          windowManager.close();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: _rulesPanelWidth,
                    decoration: const BoxDecoration(
                      color: AppTheme.panelColor,
                    ),
                    child: const RulesPanel(),
                  ),
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
                          color: _isResizing
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: FilesPanel(),
                  ),
                ],
              ),
            ),
            const BottomPanel(),
          ],
        ),
      ),
    );
  }
}
