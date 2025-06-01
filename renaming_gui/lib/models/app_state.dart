import 'package:flutter/foundation.dart';
import 'package:renaming_share/renaming_share.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class FileItem {
  String filePath;
  String fileName;
  final String fileSize;
  final String modifiedDate;
  final String fileType;
  bool isSelected;
  String? newName;
  FileStatus status;

  FileItem({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.modifiedDate,
    required this.fileType,
    this.isSelected = false,
    this.newName,
    this.status = FileStatus.unchanged,
  });

  String get displaySize {
    final bytes = int.tryParse(fileSize) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get fileIcon {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
        return '🖼️';
      case '.pdf':
        return '📄';
      case '.mp3':
      case '.wav':
      case '.flac':
        return '🎵';
      case '.mp4':
      case '.avi':
      case '.mkv':
        return '🎬';
      case '.txt':
      case '.md':
        return '📝';
      case '.zip':
      case '.rar':
      case '.7z':
        return '📦';
      default:
        return '📄';
    }
  }
}

enum FileStatus {
  unchanged,
  changed,
  error,
}

class AppState extends ChangeNotifier {
  final Renamer _renamer = Renamer();
  final List<FileItem> _files = [];
  final List<Rule> _rules = [];

  bool _selectAll = false;
  bool _processExtension = false; // 添加这个属性

  // Getters
  List<FileItem> get files => List.unmodifiable(_files);
  List<Rule> get rules => List.unmodifiable(_rules);

  bool get canExecute => _files.any((f) => f.isSelected) && _rules.isNotEmpty;
  bool get selectAll => _selectAll;
  bool get processExtension => _processExtension; // 添加getter

  int get selectedCount => _files.where((f) => f.isSelected).length;
  int get totalCount => _files.length;

  String get selectionInfo => '已选择 $selectedCount/$totalCount 个文件';

  // 文件操作
  void addFiles(List<String> filePaths) {
    for (final filePath in filePaths) {
      final file = File(filePath);
      if (file.existsSync()) {
        final stat = file.statSync();
        final fileName = path.basename(filePath);
        final fileSize = stat.size.toString();
        final modifiedDate = _formatDate(stat.modified);
        final fileType = path.extension(fileName);

        final fileItem = FileItem(
          filePath: filePath,
          fileName: fileName,
          fileSize: fileSize,
          modifiedDate: modifiedDate,
          fileType: fileType,
        );

        _files.add(fileItem);
      }
    }
    executePreviews();
    notifyListeners();
  }

  void removeFile(int index) {
    if (index >= 0 && index < _files.length) {
      _files.removeAt(index);
      _updateSelectAllState();
      notifyListeners();
    }
  }

  void clearFiles() {
    _files.clear();
    _selectAll = false;
    notifyListeners();
  }

  void toggleFileSelection(int index) {
    if (index >= 0 && index < _files.length) {
      _files[index].isSelected = !_files[index].isSelected;
      _updateSelectAllState();
      notifyListeners();
    }
  }

  void selectAllFiles() {
    _selectAll = true;
    for (final file in _files) {
      file.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAllFiles() {
    _selectAll = false;
    for (final file in _files) {
      file.isSelected = false;
    }
    notifyListeners();
  }

  void invertSelection() {
    for (final file in _files) {
      file.isSelected = !file.isSelected;
    }
    _updateSelectAllState();
    notifyListeners();
  }

  void selectChangedOnly() {
    for (final file in _files) {
      file.isSelected = file.status == FileStatus.changed;
    }
    _updateSelectAllState();
    notifyListeners();
  }

  void _updateSelectAllState() {
    if (_files.isEmpty) {
      _selectAll = false;
    } else {
      _selectAll = _files.every((f) => f.isSelected);
    }
  }

  void removeSelectedFiles() {
    _files.removeWhere((file) => file.isSelected);
    _updateSelectAllState();
    executePreviews();
    notifyListeners();
  }

  void toggleSelectAll() {
    if (_selectAll) {
      deselectAllFiles();
    } else {
      selectAllFiles();
    }
  }

  // 规则操作
  void addRule(Rule rule) {
    _rules.add(rule);
    executePreviews();
    notifyListeners();
  }

  void removeRule(int index) {
    if (index >= 0 && index < _rules.length) {
      _rules.removeAt(index);
      executePreviews();
      notifyListeners();
    }
  }

  void clearRules() {
    _rules.clear();
    executePreviews();
    notifyListeners();
  }

  void updateRule(int index, Rule newRule) {
    if (index >= 0 && index < _rules.length) {
      _rules[index] = newRule;
      executePreviews();
      notifyListeners();
    }
  }

  // 规则描述
  String getRuleDescription(Rule rule) {
    if (rule is PatternRule) {
      return '替换: "${rule.pattern}" → "${rule.replace}"';
    }
    return rule.name;
  }

  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 预览和执行重命名
  Future<void> executePreviews() async {
    // 清空并重新添加规则
    _renamer.clearRules();
    for (final rule in _rules) {
      _renamer.addRule(rule);
    }

    // 清空并重新添加文件
    _renamer.clearFiles();
    _renamer.addFiles(_files.map((f) => f.filePath).toList());

    // 设置不处理扩展名（保持原有逻辑）
    _renamer.setProcessExtension(_processExtension);

    // 设置是否为预览模式
    _renamer.setDryRun(true);

    // 使用 applyBatch 批量处理
    final results = await _renamer.applyBatch();

    // 更新文件状态
    for (int i = 0; i < _files.length && i < results.length; i++) {
      final file = _files[i];
      final result = results[i];

      if (result.status == RenameStatus.success) {
        final newFileName = path.basename(result.newPath);
        file.newName = newFileName;
        file.status = newFileName != file.fileName
            ? FileStatus.changed
            : FileStatus.unchanged;
      } else {
        file.status = FileStatus.error;
        file.newName = file.fileName;
      }
    }
  }

  Future<void> executeRename() async {
    final selectedFiles = _files.where((f) => f.isSelected).toList();

    if (selectedFiles.isEmpty) {
      return;
    }

    // 准备 renamer
    _renamer.clearRules();
    for (final rule in _rules) {
      _renamer.addRule(rule);
    }

    _renamer.clearFiles();
    _renamer.addFiles(selectedFiles.map((f) => f.filePath).toList());

    _renamer.setProcessExtension(_processExtension);
    _renamer.setDryRun(false);

    try {
      // 使用 applyBatch 执行重命名
      final results = await _renamer.applyBatch();

      // 更新文件状态和路径
      for (int i = 0; i < selectedFiles.length && i < results.length; i++) {
        final fileItem = selectedFiles[i];
        final result = results[i];

        if (result.status == RenameStatus.success) {
          fileItem.filePath = result.newPath;
          fileItem.fileName = path.basename(result.newPath);
          fileItem.status = FileStatus.unchanged;
          fileItem.newName = path.basename(result.newPath);
        } else {
          fileItem.status = FileStatus.error;
          // 可以添加错误信息到 FileItem 中
        }
      }
    } catch (e) {
      // 处理批量操作异常
      for (final fileItem in selectedFiles) {
        fileItem.status = FileStatus.error;
      }
    }

    notifyListeners();
  }

  // 添加设置processExtension的方法
  void setProcessExtension(bool value) {
    _processExtension = value;
    _renamer.setProcessExtension(value);
    executePreviews(); // 重新生成预览
    notifyListeners();
  }
}
