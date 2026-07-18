import 'package:example_flutter/models/download_model.dart';
import 'package:example_flutter/services/download_manager.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Descargas")),
      body: ValueListenableBuilder<List<DownloadTask>>(
        valueListenable: downloadManager,
        builder: (context, tasks, _) {
          if (tasks.isEmpty)
            return const Center(child: Text("No hay descargas"));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                onTap: task.status == DownloadStatus.completed
                    ? () => OpenFile.open(task.filePath)
                    : null,
                title: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: task.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          task.status == DownloadStatus.completed
                              ? Colors.green
                              : Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${(task.downloadedBytes / (1024 * 1024)).toStringAsFixed(2)} MB / "
                          "${(task.totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text("${((task.progress * 100)).toStringAsFixed(0)}%"),
                      ],
                    ),
                  ],
                ),
                trailing: _buildTrailingWidget(task),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildTrailingWidget(DownloadTask task) {
  if (task.status == DownloadStatus.completed) {
    return const Icon(Icons.check_circle, color: Colors.green);
  }

  if (task.status == DownloadStatus.failed) {
    return const Icon(Icons.error, color: Colors.red);
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(task.status == DownloadStatus.paused
            ? Icons.play_arrow
            : Icons.pause),
        onPressed: () {
          if (task.status == DownloadStatus.downloading) {
            downloadManager.pauseDownload(task.id);
          } else {
            downloadManager.resumeDownload(task.id);
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => downloadManager.cancelDownload(task.id),
      ),
    ],
  );
}
