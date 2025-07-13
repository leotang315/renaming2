import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'pages/main_page.dart';
import 'utils/theme.dart';
import 'utils/logger.dart';
import 'utils/constants.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化窗口管理器
  await windowManager.ensureInitialized();

  // 配置窗口选项
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,  // 隐藏标题栏
  );

  // 应用窗口配置
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 初始化日志系统
  await AppLogger.init();
  await AppLogger.cleanOldLogs();
  AppLogger.info('应用启动，日志文件路径: ${AppLogger.logFilePath}');

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('构建主应用界面');

    return MaterialApp(
      title: AppConstants.appTitle,
      theme: AppTheme.darkTheme,
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
