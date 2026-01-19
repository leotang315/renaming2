import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'models/rename_result.dart';
import 'models/rename_status.dart';

import 'rules/rule.dart';

class Renamer {
  List<Rule> rules;
  List<String> fileList;
  bool processExtension;

  Renamer({
    List<Rule>? rules,
    List<String>? fileList,

    List<RenameResult>? mappings,
    this.processExtension = false,
  }) : rules = rules ?? [],
       fileList = fileList ?? [];

  void setProcessExtension(bool process) {
    processExtension = process;
  }

  void addFile(String file) {
    fileList.add(file);
  }

  void addFiles(List<String> files) {
    fileList.addAll(files);
  }

  bool removeFile(String file) {
    return fileList.remove(file);
  }

  bool removeFiles(List<String> files) {
    bool allRemoved = true;
    for (final file in files) {
      if (!fileList.remove(file)) {
        allRemoved = false;
      }
    }
    return allRemoved;
  }

  void clearFiles() {
    fileList.clear();
  }

  List<String> getFiles() {
    return fileList;
  }

  void addRule(Rule rule) {
    if (rule.id.isEmpty) {
      rule.id = const Uuid().v4();
    }
    rules.add(rule);
  }

  int removeRuleById(String id) {
    final count = rules.where((rule) => rule.id == id).length;
    rules.removeWhere((rule) => rule.id == id);
    return count;
  }

  int removeRuleByName(String name) {
    final count = rules.where((rule) => rule.name == name).length;
    rules.removeWhere((rule) => rule.name == name);
    return count;
  }

  int removeRuleByType(String type) {
    final count = rules.where((rule) => rule.type == type).length;
    rules.removeWhere((rule) => rule.type == type);
    return count;
  }

  void clearRules() {
    rules.clear();
  }

  Rule? getRuleById(String id) {
    try {
      return rules.firstWhere((rule) => rule.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Rule> getRules() {
    return rules;
  }

  Future<String> saveRule() async {
    return json.encode(rules.map((rule) => rule.toJson()).toList());
  }

  Future<void> loadRule(String data) async {
    try {
      final jsonList = json.decode(data) as List;
      rules =
          jsonList
              .map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList();
    } catch (e) {
      throw Exception('加载规则失败: $e');
    }
  }

  Future<RenameResult> generateOneMapping(String path, {int? index}) async {
    var result = RenameResult(
      oldPath: path,
      newPath: '',
      status: RenameStatus.pending,
    );
    try {
      final dir = p.dirname(path);
      final srcName = p.basename(path);
      String dstName;

      if (!processExtension) {
        final ext = p.extension(srcName);
        var baseName = p.basenameWithoutExtension(srcName);

        for (final rule in rules) {
          baseName = await rule.apply(baseName, index: index);
        }
        dstName = '$baseName$ext';
      } else {
        dstName = srcName;
        for (final rule in rules) {
          dstName = await rule.apply(dstName, index: index);
        }
      }
      return result.copyWith(newPath: p.join(dir, dstName));
    } catch (e) {
      return result.copyWith(newPath: "");
    }
  }

  Future<List<RenameResult>> generateAllMapping() async {
    List<RenameResult> mappings = await Future.wait(
      fileList.asMap().entries.map(
        (entry) => generateOneMapping(entry.value, index: entry.key + 1),
      ),
    );
    return mappings;
  }

  Future<RenameResult> rename(String src, String dst) async {
    var result = RenameResult(
      oldPath: src,
      newPath: dst,
      status: RenameStatus.pending,
    );

    try {
      if (src.isEmpty || dst.isEmpty) {
        return result.copyWith(status: RenameStatus.error, message: '文件路径为空');
      }

      if (!await File(src).exists()) {
        return result.copyWith(status: RenameStatus.error, message: '源文件不存在');
      }

      if (await File(dst).exists()) {
        return result.copyWith(status: RenameStatus.error, message: '目标文件已存在');
      }

      if (src == dst) {
        return result.copyWith(status: RenameStatus.success);
      }

      await File(src).rename(dst);
      result.status = RenameStatus.success;
    } catch (e) {
      result.status = RenameStatus.error;
      result.message = '重命名失败: $e';
    }
    return result;
  }

  Future<List<RenameResult>> preview() {
    return generateAllMapping();
  }

  Future<List<RenameResult>> execute(List<RenameResult> mappings) async {
    for (var item in mappings) {
      var result = await rename(item.oldPath, item.newPath);
      item.status = result.status;
      item.message = result.message;
    }
    return mappings;
  }

  Future<List<RenameResult>> retryFailed(
    List<RenameResult> previousResults,
  ) async {
    for (var item in previousResults) {
      if (item.status == RenameStatus.error) {
        var result = await rename(item.oldPath, item.newPath);
        item.status = result.status;
        item.message = result.message;
      }
    }
    return previousResults;
  }

  Future<List<RenameResult>> undo(List<RenameResult> previousResults) async {
    for (var item in previousResults) {
      if (item.status == RenameStatus.success) {
        var result = await rename(item.newPath, item.oldPath);
        if (result.status == RenameStatus.success) {
          item.status = RenameStatus.pending;
        } else {
          item.message = "Undo failed: ${result.message}";
        }
      }
    }
    return previousResults;
  }
}
