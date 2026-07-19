import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:example_flutter/models/download_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadManager extends ValueNotifier<List<DownloadTask>> {
  DownloadManager() : super([]);

  final yt = YoutubeExplode();
  final Map<String, StreamSubscription?> _subscriptions = {};
  final Map<String, IOSink> _fileSinks = {};

  // Si no llega ningún chunk en 90 s, el stream lanza TimeoutException.
  static const _chunkTimeout = Duration(seconds: 300);

  Future<bool> startDownload({
    required String videoId,
    required bool isAudio,
  }) async {
    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) {
      print('No tiene permisos de storage');
      return false;
    }

    try {
      final video = await yt.videos.get(videoId);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);

      final StreamInfo streamInfo = isAudio
          ? manifest.audioOnly.withHighestBitrate()
          : manifest.muxed.bestQuality;

      final taskId = '${videoId}_${streamInfo.tag}';
      final isAudioOnly = streamInfo is AudioOnlyStreamInfo;
      final extension = isAudioOnly
          ? streamInfo.codec.subtype
          : 'mp4';
      final filename = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
      final totalBytes = streamInfo.size.totalBytes;

      final task = DownloadTask(
        id: taskId,
        title: video.title,
        totalBytes: totalBytes,
        status: DownloadStatus.downloading,
        streamUrl: streamInfo.url.toString(),
      );
      value = [...value, task];

      final outputPath = '/storage/emulated/0/Download/$filename.$extension';
      task.filePath = outputPath;
      notifyListeners();

      _runSimpleDownload(task, taskId, streamInfo, outputPath);
      return true;
    } catch (e) {
      print('Error obteniendo info del video: $e');
      return false;
    }
  }

  void _runSimpleDownload(DownloadTask task, String taskId,
      StreamInfo streamInfo, String outputPath) async {
    try {
      final sink = File(outputPath).openWrite();
      _fileSinks[taskId] = sink;

      final stream = yt.videos.streamsClient
          .get(streamInfo)
          .timeout(_chunkTimeout, onTimeout: (s) {
        s.addError(TimeoutException('Descarga bloqueada', _chunkTimeout));
        s.close();
      });

      _subscriptions[taskId] = stream.listen(
        (data) {
          sink.add(data);
          task.downloadedBytes += data.length;
          task.progress =
              (task.downloadedBytes / task.totalBytes).clamp(0.0, 1.0);
          notifyListeners();
        },
        onDone: () async {
          await sink.flush();
          await sink.close();
          _fileSinks.remove(taskId);
          _subscriptions.remove(taskId);
          task.progress = 1.0;
          task.status = DownloadStatus.completed;
          notifyListeners();
          await _saveTasks();
        },
        onError: (e) async {
          print('Error en stream de descarga: $e');
          await sink.close();
          _fileSinks.remove(taskId);
          _subscriptions.remove(taskId);
          task.status = DownloadStatus.failed;
          notifyListeners();
          await _saveTasks();
        },
      );
    } catch (e) {
      print('Error en descarga: $e');
      task.status = DownloadStatus.failed;
      notifyListeners();
      await _saveTasks();
    }
  }

  void pauseDownload(String id) {
    _subscriptions[id]?.pause();
    final index = value.indexWhere((t) => t.id == id);
    if (index != -1) {
      value[index].status = DownloadStatus.paused;
      notifyListeners();
    }
  }

  void resumeDownload(String id) {
    _subscriptions[id]?.resume();
    final index = value.indexWhere((t) => t.id == id);
    if (index != -1) {
      value[index].status = DownloadStatus.downloading;
      notifyListeners();
    }
  }

  Future<void> cancelDownload(String id) async {
    await _subscriptions[id]?.cancel();
    _subscriptions.remove(id);
    final sink = _fileSinks.remove(id);
    if (sink != null) await sink.close();
    final task =
        value.firstWhere((t) => t.id == id, orElse: () => throw StateError(''));
    if (task.filePath.isNotEmpty) {
      final file = File(task.filePath);
      if (await file.exists()) await file.delete();
    }
    value.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTasks();
  }

  @override
  void dispose() {
    yt.close();
    super.dispose();
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (!Platform.isAndroid) return true;

    final sdkInt = await _getAndroidVersion();

    final List<Permission> permissions = sdkInt >= 33
        ? [Permission.videos, Permission.audio]
        : [Permission.storage];

    final statuses = await permissions.request();

    final allGranted = statuses.values.every(
      (s) => s.isGranted || s.isLimited,
    );
    if (allGranted) return true;

    if (statuses.values.any((s) => s.isPermanentlyDenied)) {
      await openAppSettings();
    }

    return false;
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  Future<File> get _storageFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/downloads.json');
  }

  Future<void> _saveTasks() async {
    try {
      final file = await _storageFile;
      final json = jsonEncode(value.map((t) => t.toJson()).toList());
      await file.writeAsString(json);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  Future<void> loadTasks() async {
    try {
      final file = await _storageFile;
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
      value = jsonList
          .map((j) => DownloadTask.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }
}

final downloadManager = DownloadManager();
