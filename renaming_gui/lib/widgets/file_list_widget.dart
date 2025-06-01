import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/constants.dart';

class FileListWidget extends StatelessWidget {
  const FileListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () => _addFiles(appState),
                    tooltip: AppConstants.addFilesTooltip,
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: appState.clearFiles,
                    tooltip: AppConstants.clearFilesTooltip,
                  ),
                ],
              ),
              const Text(
                AppConstants.filesLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: appState.files.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(appState.files[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () => appState.removeFile(index),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addFiles(AppState appState) {
    // 模拟添加文件 - 实际应用中需要使用 file_picker 包
    appState.addFiles([
      'example1.txt',
      'example2.jpg',
      'document.pdf',
    ]);
  }
}