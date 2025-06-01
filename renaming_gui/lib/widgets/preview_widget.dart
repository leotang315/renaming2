import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/constants.dart';

class PreviewWidget extends StatelessWidget {
  const PreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.previewLabel,
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
                        leading: const Icon(Icons.file_present),
                        title: Text(appState.files[index]),
                        subtitle: FutureBuilder<String>(
                          future: appState.getPreviewName(appState.files[index]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!,
                                style: const TextStyle(color: Colors.blue),
                              );
                            }
                            return const Text('计算中...');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: appState.isDryRun,
                      onChanged: (value) => appState.setDryRun(value ?? true),
                    ),
                    const Text(AppConstants.dryRunLabel),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: appState.canExecute ? () => _executeRename(context, appState) : null,
                      child: Text(appState.isDryRun ? AppConstants.previewButton : AppConstants.renameButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _executeRename(BuildContext context, AppState appState) {
    appState.executeRename();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.isDryRun ? '预览完成' : '重命名完成'),
      ),
    );
  }
}