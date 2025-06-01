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
  bool _isDryRun = true;
  bool _selectAll = false;

  // Getters
  List<FileItem> get files => List.unmodifiable(_files);
  List<Rule> get rules => List.unmodifiable(_rules);
  bool get isDryRun => _isDryRun;
  bool get canExecute => _files.any((f) => f.isSelected) && _rules.isNotEmpty;
  bool get selectAll => _selectAll;

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
    _updatePreviews();
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

  // 规则操作
  void addRule(Rule rule) {
    _rules.add(rule);
    _updatePreviews();
    notifyListeners();
  }

  void removeRule(int index) {
    if (index >= 0 && index < _rules.length) {
      _rules.removeAt(index);
      _updatePreviews();
      notifyListeners();
    }
  }

  void clearRules() {
    _rules.clear();
    _updatePreviews();
    notifyListeners();
  }

  // 设置操作
  void setDryRun(bool value) {
    _isDryRun = value;
    notifyListeners();
  }

  void toggleSelectAll() {
    if (_selectAll) {
      deselectAllFiles();
    } else {
      selectAllFiles();
    }
  }

  // 预览功能
  void _updatePreviews() {
    for (final file in _files) {
      String result = path.basenameWithoutExtension(file.fileName);
      final extension = path.extension(file.fileName);

      try {
        for (final rule in _rules) {
          // 这里需要同步版本的规则应用，或者使用Future
          // 暂时使用简化版本
          result = _applyRuleSync(rule, result);
        }

        final newFileName = result + extension;
        file.newName = newFileName;
        file.status = newFileName != file.fileName
            ? FileStatus.changed
            : FileStatus.unchanged;
      } catch (e) {
        file.status = FileStatus.error;
        file.newName = file.fileName;
      }
    }
  }

  String _applyRuleSync(Rule rule, String input) {
    // 简化的同步规则应用
    if (rule is PatternRule) {
      return input.replaceAll(rule.pattern, rule.replace);
    }
    return input;
  }

  // 规则描述
  String getRuleDescription(Rule rule) {
    if (rule is PatternRule) {
      return '替换: "${rule.pattern}" → "${rule.replace}"';
    }
    return rule.name;
  }

  // 执行重命名
  Future<void> executeRename() async {
    final selectedFiles = _files.where((f) => f.isSelected).toList();

    for (final fileItem in selectedFiles) {
      if (fileItem.newName != null && fileItem.newName != fileItem.fileName) {
        try {
          if (!_isDryRun) {
            final oldFile = File(fileItem.filePath);
            final newPath = path.join(
              path.dirname(fileItem.filePath),
              fileItem.newName!,
            );
            await oldFile.rename(newPath);
            fileItem.filePath = newPath;
            fileItem.fileName = fileItem.newName!;
          }
        } catch (e) {
          fileItem.status = FileStatus.error;
        }
      }
    }

    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
