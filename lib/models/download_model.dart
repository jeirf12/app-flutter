enum DownloadStatus { pending, downloading, paused, completed, failed }

class DownloadTask {
  final String id;
  final String title;
  String filePath;
  double progress;
  int downloadedBytes;
  int totalBytes;
  DownloadStatus status;
  String streamUrl; // URL directa para reanudar descargas simples

  DownloadTask({
    required this.id,
    required this.title,
    this.filePath = '',
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = DownloadStatus.pending,
    this.streamUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'progress': progress,
        'downloadedBytes': downloadedBytes,
        'totalBytes': totalBytes,
        'status': status.index,
      };

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    final status = DownloadStatus.values[json['status'] as int];
    // Tasks that were in-progress when the app closed cannot be resumed.
    final resolvedStatus = (status == DownloadStatus.downloading ||
            status == DownloadStatus.paused ||
            status == DownloadStatus.pending)
        ? DownloadStatus.failed
        : status;
    return DownloadTask(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      progress: (json['progress'] as num).toDouble(),
      downloadedBytes: json['downloadedBytes'] as int,
      totalBytes: json['totalBytes'] as int,
      status: resolvedStatus,
    );
  }
}
