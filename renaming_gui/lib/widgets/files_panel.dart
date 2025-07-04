import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart'; // 添加这个导入
import 'package:renaming_share/renaming_share.dart';
import 'dart:io';
import '../models/app_state.dart';
import '../utils/theme.dart';

class FilesPanel extends StatefulWidget {
  // 改为StatefulWidget
  const FilesPanel({super.key});

  @override
  State<FilesPanel> createState() => _FilesPanelState();
}

class _FilesPanelState extends State<FilesPanel> {
  bool _isDragging = false; // 添加拖拽状态
  final FocusNode _focusNode = FocusNode(); // 添加焦点节点

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.delete) {
            final appState = Provider.of<AppState>(context, listen: false);
            if (appState.selectedCount > 0) {
              _removeSelectedFiles(context, appState);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus(); // 点击时获取焦点
          },
          child: Column(
            children: [
              // 文件面板头部
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.headerColor,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Row(
                      children: [
                        const Icon(Icons.file_present,
                            color: AppTheme.textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '文件管理器',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        // 添加文件按钮
                        Tooltip(
                          message: '添加文件',
                          child: IconButton(
                            onPressed: () => _addFiles(context, appState),
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppTheme.textColor,
                            iconSize: 20,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  AppTheme.warningColor.withOpacity(0.1),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(32, 32),
                              fixedSize: const Size(32, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 选择文件夹按钮
                        Tooltip(
                          message: '选择文件夹',
                          child: IconButton(
                            onPressed: () => _selectFolder(context, appState),
                            icon: const Icon(Icons.folder_open_outlined),
                            color: AppTheme.textColor,
                            iconSize: 20,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  AppTheme.warningColor.withOpacity(0.1),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(32, 32),
                              fixedSize: const Size(32, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 删除文件按钮
                        Tooltip(
                          message: '删除选中文件',
                          child: IconButton(
                            onPressed: appState.selectedCount > 0
                                ? () => _removeSelectedFiles(context, appState)
                                : null,
                            icon: const Icon(Icons.delete),
                            color: appState.selectedCount > 0
                                ? AppTheme.errorColor
                                : AppTheme.textSecondaryColor,
                            iconSize: 20,
                            style: IconButton.styleFrom(
                              backgroundColor: appState.selectedCount > 0
                                  ? AppTheme.warningColor.withOpacity(0.1)
                                  : Colors.transparent,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(32, 32),
                              fixedSize: const Size(32, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // 文件表格 - 添加拖拽功能
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    return DropTarget(
                      onDragDone: (detail) => _handleFileDrop(detail, appState),
                      onDragEntered: (detail) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onDragExited: (detail) {
                        setState(() {
                          _isDragging = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // border: _isDragging
                          //     ? Border.all(
                          //         color: AppTheme.primaryColor,
                          //         width: 2,
                          //         style: BorderStyle.solid,
                          //       )
                          //     : null,
                          color: _isDragging
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            _buildFileTable(context, appState),
                            if (_isDragging)
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload,
                                        size: 64,
                                        color: AppTheme.primaryColor,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        '拖放文件到这里',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '支持多个文件和文件夹',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  // 添加处理文件拖拽的方法
  void _handleFileDrop(DropDoneDetails detail, AppState appState) {
    setState(() {
      _isDragging = false;
    });

    final files = detail.files;
    if (files.isEmpty) return;

    final filePaths = <String>[];

    for (final file in files) {
      final path = file.path;
      final fileEntity = File(path);
      final dirEntity = Directory(path);

      if (fileEntity.existsSync()) {
        // 单个文件
        filePaths.add(path);
      } else if (dirEntity.existsSync()) {
        // 文件夹 - 递归获取所有文件
        final dirFiles = _getFilesFromDirectory(path);
        filePaths.addAll(dirFiles);
      }
    }

    if (filePaths.isNotEmpty) {
      appState.addFiles(filePaths);

      _showMessage(
        context,
        message: '成功添加 ${filePaths.length} 个文件',
      );
    }
  }

  // 递归获取文件夹中的所有文件
  List<String> _getFilesFromDirectory(String directoryPath) {
    final files = <String>[];
    final directory = Directory(directoryPath);
    try {
      final entities = directory.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File) {
          files.add(entity.path);
        }
      }
    } catch (e) {
      // 处理权限错误等异常
      if (mounted) {
        _showError(context, e);
      }
    }

    return files;
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.borderColor,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildFileTable(BuildContext context, AppState appState) {
    if (appState.files.isEmpty) {
      return const Center(
        child: Text(
          '请选择文件或文件夹',
          style: TextStyle(color: AppTheme.textMutedColor),
        ),
      );
    }

    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FixedColumnWidth(50),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FixedColumnWidth(80),
          5: FixedColumnWidth(120),
        },
        children: [
          // 表头
          // 在表头的TableRow中
          TableRow(
            decoration: const BoxDecoration(
              color: AppTheme.headerColor,
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            children: [
              _buildTableHeader(
                child: Checkbox(
                  value: appState.selectAll,
                  tristate: true,
                  onChanged: (_) => appState.toggleSelectAll(),
                ),
              ),
              _buildTableHeader(text: '状态'),
              _buildTableHeader(text: '原始文件名'),
              _buildTableHeader(text: '新文件名'),
              _buildTableHeader(text: '大小'),
              _buildTableHeader(text: '修改时间'),
            ],
          ),
          // 文件行
          ...appState.files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFileRow(context, appState, file, index);
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader({String? text, Widget? child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(minHeight: 32, maxHeight: 32),
      alignment: Alignment.centerLeft,
      child: child ??
          Text(
            text ?? '',
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
    );
  }

  TableRow _buildFileRow(
      BuildContext context, AppState appState, FileItem file, int index) {
    Color? rowColor;
    if (file.isSelected) {
      rowColor = const Color(0xFF094771);
    }

    return TableRow(
      decoration: BoxDecoration(
        // color: rowColor,
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      children: [
        _buildTableCell(
          child: Checkbox(
            value: file.isSelected,
            onChanged: (_) => appState.toggleFileSelection(index),
          ),
        ),
        _buildTableCell(
          child: _buildStatusIndicator(file.status),
        ),
        _buildTableCell(
          child: Row(
            children: [
              Text(file.fileIcon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.srcName,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _buildTableCell(
          child: GestureDetector(
            onDoubleTap: () {
              // 创建一个TextEditingController并设置初始值
              final controller = TextEditingController(text: file.dstName);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('修改文件名'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: '新文件名',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          appState.updateFileName(index, controller.text);
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              file.dstName,
              style: TextStyle(
                color: file.isChanged
                    ? AppTheme.textSecondaryColor
                    : AppTheme.textMutedColor,
                fontSize: 12,
                fontWeight: file.isChanged ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _buildTableCell(
          child: Text(
            file.displaySize,
            style: const TextStyle(
              color: AppTheme.textMutedColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        _buildTableCell(
          child: Text(
            file.modifiedDate,
            style: const TextStyle(
              color: AppTheme.textMutedColor,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      constraints: const BoxConstraints(minHeight: 32, maxHeight: 32),
      alignment: Alignment.centerLeft, // 水平左对齐，垂直居中
      child: child,
    );
  }

  Widget _buildStatusIndicator(RenameStatus status) {
    Color color;
    switch (status) {
      case RenameStatus.pending:
        color = AppTheme.textMutedColor;
      case RenameStatus.success:
        color = AppTheme.successColor;
      case RenameStatus.error:
        color = AppTheme.errorColor;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> _selectFolder(BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      // 获取文件夹中的所有文件
      try {
        final files = await _getFilesFromDirectory(result);
        if (files.isNotEmpty) {
          appState.addFiles(files);
          if (context.mounted) {
            _showMessage(
              context,
              message: '已添加 ${files.length} 个文件',
            );
          }
        } else {
          if (context.mounted) {
            _showMessage(
              context,
              message: '文件夹中没有找到文件',
              backgroundColor: AppTheme.warningColor,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showError(context, e);
        }
      }
    }
  }

  Future<void> _addFiles(BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      final filePaths = result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();
      appState.addFiles(filePaths);
    }
  }

  void _removeSelectedFiles(BuildContext context, AppState appState) {
    final selectedCount = appState.selectedCount;
    if (selectedCount > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除选中的 $selectedCount 个文件吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                autofocus: true, // 默认焦点在删除按钮上
                onPressed: () {
                  Navigator.of(context).pop();
                  appState.removeSelectedFiles();
                  _showMessage(
                    context,
                    message: '已删除 $selectedCount 个文件',
                  );
                },
                child: const Text('删除'),
              ),
            ],
          );
        },
      );
    }
  }

  // 显示提示消息
  void _showMessage(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppTheme.successColor,
    Duration duration = const Duration(seconds: 1),
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );
    }
  }

  // 显示错误消息
  void _showError(BuildContext context, Object error) {
    _showMessage(
      context,
      message: '读取文件夹失败: ${error.toString()}',
      backgroundColor: AppTheme.errorColor,
    );
  }
}
