import 'package:flutter/foundation.dart';
import 'package:renaming_share/renaming_share.dart';

class AppState extends ChangeNotifier {
  final Renamer _renamer = Renamer();
  final List<String> _files = [];
  final List<Rule> _rules = [];
  bool _isDryRun = true;

  // Getters
  List<String> get files => List.unmodifiable(_files);
  List<Rule> get rules => List.unmodifiable(_rules);
  bool get isDryRun => _isDryRun;
  bool get canExecute => _files.isNotEmpty && _rules.isNotEmpty;

  // 文件操作
  void addFiles(List<String> newFiles) {
    _files.addAll(newFiles);
    notifyListeners();
  }

  void removeFile(int index) {
    if (index >= 0 && index < _files.length) {
      _files.removeAt(index);
      notifyListeners();
    }
  }

  void clearFiles() {
    _files.clear();
    notifyListeners();
  }

  // 规则操作
  void addRule(Rule rule) {
    _rules.add(rule);
    notifyListeners();
  }

  void removeRule(int index) {
    if (index >= 0 && index < _rules.length) {
      _rules.removeAt(index);
      notifyListeners();
    }
  }

  void clearRules() {
    _rules.clear();
    notifyListeners();
  }

  // 设置操作
  void setDryRun(bool value) {
    _isDryRun = value;
    notifyListeners();
  }

  // 预览功能
  Future<String> getPreviewName(String filename) async {
    String result = filename;
    for (final rule in _rules) {
      result = await rule.apply(result);
    }
    return result;
  }

  // 规则描述
  String getRuleDescription(Rule rule) {
    if (rule is PatternRule) {
      return '模式: ${rule.pattern} -> ${rule.replace}';
    }
    return rule.name;
  }

  // 执行重命名
  Future<void> executeRename() async {
    // 实际重命名逻辑
    // 这里可以调用 _renamer 的相关方法
  }
}