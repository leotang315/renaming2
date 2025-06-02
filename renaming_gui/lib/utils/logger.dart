import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AppLogger {
  static Logger? _logger;
  static File? _logFile;

  // 初始化日志器
  static Future<void> init() async {
    // 创建日志文件
    await _createLogFile();

    _logger = Logger(
      output: MultiOutput([
        ConsoleOutput(), // 控制台输出
        FileOutput(file: _logFile!), // 文件输出
      ]),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: false,
        printEmojis: false,
        printTime: true,
      ),
    );
  }

  // 创建日志文件
  static Future<void> _createLogFile() async {
    try {
      // 获取应用文档目录
      final directory = Directory.current;
      final logsDir = Directory(path.join(directory.path, 'logs'));

      // 创建logs目录（如果不存在）
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // 创建日志文件（按日期命名）
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final logFileName = 'app_$dateStr.log';
      _logFile = File(path.join(logsDir.path, logFileName));

      // 如果文件不存在则创建
      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }
    } catch (e) {
      print('创建日志文件失败: $e');
      // 如果创建文件失败，使用临时文件
      _logFile = File(path.join(Directory.current.path, 'app.log'));
    }
  }

  // 获取日志文件路径
  static String? get logFilePath => _logFile?.path;

  // 清理旧日志文件（保留最近7天）
  static Future<void> cleanOldLogs() async {
    try {
      final logsDir = Directory(path.join(Directory.current.path, 'logs'));
      if (await logsDir.exists()) {
        final files = await logsDir.list().toList();
        final now = DateTime.now();

        for (final file in files) {
          if (file is File && file.path.endsWith('.log')) {
            final stat = await file.stat();
            final daysDiff = now.difference(stat.modified).inDays;

            if (daysDiff > 7) {
              await file.delete();
              print('删除旧日志文件: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      print('清理旧日志文件失败: $e');
    }
  }

  // 调试信息
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }

  // 一般信息
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }

  // 警告信息
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }

  // 错误信息
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  // 致命错误
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.f(message, error: error, stackTrace: stackTrace);
  }

  // 跟踪信息
  static void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.t(message, error: error, stackTrace: stackTrace);
  }
}
