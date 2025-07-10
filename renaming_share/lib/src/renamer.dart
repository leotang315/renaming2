import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'models/rename_result.dart';
import 'models/rename_status.dart';
import 'models/rename_mode.dart';
import 'rules/rule.dart';

class Renamer {
  List<Rule> rules;
  List<String> fileList;
  List<RenameResult> mappings;
  bool dryRun;
  bool processExtension;

  Renamer({
    List<Rule>? rules,
    List<String>? fileList,
    this.dryRun = false,
    List<RenameResult>? mappings,
    this.processExtension = false,
  }) : rules = rules ?? [],
       fileList = fileList ?? [],
       mappings = mappings ?? [];

  void setProcessExtension(bool process) {
    processExtension = process;
  }

  void setDryRun(bool dryRun) {
    this.dryRun = dryRun;
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

  Future<RenameResult> generateSingleMapping(String path, {int? index}) async {
    var result = RenameResult(
      oldPath: path,
      newPath: '',
      status: RenameStatus.pending,
    );

    if (path.isEmpty) {
      return result.copyWith(status: RenameStatus.error, message: '文件路径为空');
    }

    final dir = p.dirname(path);
    final srcName = p.basename(path);

    if (srcName.isEmpty) {
      return result.copyWith(status: RenameStatus.error, message: '无效的文件路径');
    }

    try {
      String processedName;
      if (!processExtension) {
        final ext = p.extension(srcName);
        var baseName = p.basenameWithoutExtension(srcName);

        for (final rule in rules) {
          baseName = await rule.apply(baseName, index: index);
        }
        processedName = '$baseName$ext';
      } else {
        processedName = srcName;
        for (final rule in rules) {
          processedName = await rule.apply(processedName, index: index);
        }
      }

      return result.copyWith(
        newPath: p.join(dir, processedName),
        status: RenameStatus.success,
      );
    } catch (e) {
      return result.copyWith(status: RenameStatus.error, message: e.toString());
    }
  }

  Future<List<RenameResult>> generateMapping() async {
    mappings = await Future.wait(
      fileList.asMap().entries.map(
            (entry) => generateSingleMapping(entry.value, index: entry.key + 1),
          ),
    );
    return mappings;
  }

  Future<List<RenameResult>> applyMapping(
    List<RenameResult> mappings, [
    RenameMode mode = RenameMode.normal,
  ]) async {
    // 执行实际重命名操作
    final results = List<RenameResult>.from(mappings);

    for (var i = 0; i < results.length; i++) {
      var mapping = results[i];

      switch (mode) {
        case RenameMode.normal:
          if (mapping.status == RenameStatus.error) {
            continue;
          }
          break;
        case RenameMode.error:
          if (mapping.status != RenameStatus.error) {
            continue;
          }
          break;
        case RenameMode.undo:
          // 执行回退操作，交换新旧路径
          final oldPath = mapping.oldPath;
          mapping = mapping.copyWith(
            oldPath: mapping.newPath,
            newPath: oldPath,
          );
          break;
      }

      // 检查路径有效性
      if (mapping.oldPath.isEmpty || mapping.newPath.isEmpty) {
        results[i] = mapping.copyWith(
          status: RenameStatus.error,
          message: '无效的文件路径',
        );
        continue;
      }

      // 如果新旧路径相同，标记为成功并跳过
      if (mapping.oldPath == mapping.newPath) {
        results[i] = mapping.copyWith(status: RenameStatus.success);
        continue;
      }

      try {
        final srcFile = File(mapping.oldPath);
        await srcFile.rename(mapping.newPath);
        results[i] = mapping.copyWith(status: RenameStatus.success);
      } catch (e) {
        results[i] = mapping.copyWith(
          status: RenameStatus.error,
          message: '重命名失败: $e',
        );
      }
    }

    return results;
  }

  Future<List<RenameResult>> applyBatch() async {
    // 生成映射
    mappings = await generateMapping();

    // 如果是预览模式，直接返回映射结果
    if (dryRun) {
      return mappings;
    }

    List<RenameResult> results = await applyMapping(
      mappings,
      RenameMode.normal,
    );

    return results;
  }
}
