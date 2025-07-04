import 'package:flutter/foundation.dart';
import 'package:renaming_share/renaming_share.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class FileItem {
  bool isSelected;
  String srcPath;
  String srcName;
  String dstPath;
  RenameStatus status;
  String? message;
  final String fileSize;
  final String modifiedDate;

  FileItem({
    required this.srcPath,
    required this.srcName,
    required this.fileSize,
    required this.modifiedDate,
    this.dstPath = '',
    this.isSelected = false,
    this.status = RenameStatus.pending,
  });

  String get displaySize {
    final bytes = int.tryParse(fileSize) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get fileIcon {
    final ext = path.extension(srcName).toLowerCase();
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

  String get dstName {
    if (dstPath.isEmpty) {
      return "";
    }
    return path.basename(dstPath);
  }

  bool get isChanged {
    return srcPath != dstPath;
  }
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

        final fileItem = FileItem(
          srcPath: filePath,
          srcName: fileName,
          fileSize: fileSize,
          modifiedDate: modifiedDate,
          isSelected: true,
        );

        _files.add(fileItem);
      }
    }
    _updateSelectAllState();
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
    _updateSelectAllState();
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
    for (final file in _files) {
      file.isSelected = true;
    }
    _updateSelectAllState();
    notifyListeners();
  }

  void deselectAllFiles() {
    for (final file in _files) {
      file.isSelected = false;
    }
    _updateSelectAllState();
    notifyListeners();
  }

  void invertSelection() {
    for (final file in _files) {
      file.isSelected = !file.isSelected;
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
    _renamer.addFiles(_files.map((f) => f.srcPath).toList());

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
      file.dstPath = result.newPath;
      file.status = RenameStatus.pending;
      file.message = result.message;
    }
  }

  Future<void> executeRename() async {
    final selectedFiles = _files.where((f) => f.isSelected).toList();

    if (selectedFiles.isEmpty) {
      return;
    }

    Renamer renamer = Renamer();
    // 生成文件路径映射
    final mapping = selectedFiles
        .map((f) => RenameResult(
              oldPath: f.srcPath,
              newPath: f.dstPath,
            ))
        .toList();
    final results = await renamer.applyMapping(mapping, RenameMode.normal);

    // 更新文件状态和路径
    for (int i = 0; i < selectedFiles.length && i < results.length; i++) {
      final file = selectedFiles[i];
      final result = results[i];
      file.srcPath = result.newPath;
      file.srcName = path.basename(result.newPath);
      file.dstPath = result.newPath;
      file.status = result.status;
      file.message = result.message;
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

  void updateFileName(int index, String newName) {
    if (index >= 0 && index < files.length) {
      files[index].dstPath =
          path.join(path.dirname(files[index].dstPath), newName);
      notifyListeners();
    }
  }
}
