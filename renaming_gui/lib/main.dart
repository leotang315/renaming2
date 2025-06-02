import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'pages/main_page.dart';
import 'utils/theme.dart';
import 'utils/logger.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志系统
  await AppLogger.init();

  // 清理旧日志文件
  await AppLogger.cleanOldLogs();

  // 记录应用启动
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
      title: 'renaming - 专业文件重命名工具',
      theme: AppTheme.darkTheme,
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
