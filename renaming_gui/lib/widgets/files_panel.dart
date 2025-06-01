import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/app_state.dart';
import '../utils/theme.dart';

class FilesPanel extends StatelessWidget {
  const FilesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 文件面板头部
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(
                    '文件列表与预览',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _selectFolder(context, appState),
                    icon: const Text('📁'),
                    label: const Text('选择文件夹'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addFiles(context, appState),
                    icon: const Text('📄'),
                    label: const Text('添加文件'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    appState.selectionInfo,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 文件表格
        Expanded(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return _buildFileTable(context, appState);
            },
          ),
        ),
        // 底部操作栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.headerColor,
            border: Border(
              top: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  const Spacer(),
                  // 执行按钮
                  ElevatedButton(
                    onPressed: appState.canExecute
                        ? () => _executeRename(context, appState)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('开始重命名'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
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
    } else if (file.status == FileStatus.changed) {
      rowColor = const Color(0xFF1A3D1A);
    } else if (file.status == FileStatus.error) {
      rowColor = const Color(0xFF3D1A1A);
    }

    return TableRow(
      decoration: BoxDecoration(
        color: rowColor,
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
                  file.fileName,
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
          child: Text(
            file.newName ?? file.fileName,
            style: TextStyle(
              color: _getNewNameColor(file.status),
              fontSize: 12,
              fontWeight: file.status == FileStatus.changed
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildTableCell(
          child: Text(
            file.displaySize,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
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

  Widget _buildStatusIndicator(FileStatus status) {
    Color color;
    switch (status) {
      case FileStatus.unchanged:
        color = AppTheme.textMutedColor;
        break;
      case FileStatus.changed:
        color = AppTheme.warningColor;
        break;
      case FileStatus.error:
        color = AppTheme.errorColor;
        break;
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

  Color _getNewNameColor(FileStatus status) {
    switch (status) {
      case FileStatus.unchanged:
        return AppTheme.textMutedColor;
      case FileStatus.changed:
        return AppTheme.textSecondaryColor;
      case FileStatus.error:
        return AppTheme.errorColor;
    }
  }

  Future<void> _selectFolder(BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      // 获取文件夹中的所有文件
      // 这里需要实现文件夹扫描逻辑
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

  Future<void> _executeRename(BuildContext context, AppState appState) async {
    try {
      await appState.executeRename();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.isDryRun ? '预览完成' : '重命名完成'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
