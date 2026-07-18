import 'package:example_flutter/services/download_manager.dart';
import 'package:example_flutter/templates/downloads_screen.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> showDownloadOptions(BuildContext context, String videoId) async {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Descargar como',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.blue),
            title: const Text('MP3 (Solo audio)'),
            onTap: () {
              Navigator.pop(sheetContext);
              _download(context, videoId, isAudio: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie, color: Colors.red),
            title: const Text('MP4 (Video)'),
            onTap: () {
              Navigator.pop(sheetContext);
              _download(context, videoId, isAudio: false);
            },
          ),
        ],
      ),
    ),
  );
}

void _download(
  BuildContext context,
  String videoId, {
  required bool isAudio,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final yt = YoutubeExplode();
  try {
    final manifest = await yt.videos.streamsClient.getManifest(videoId);
    final video = await yt.videos.get(videoId);

    final StreamInfo streamInfo;
    if (isAudio) {
      streamInfo = manifest.audioOnly.withHighestBitrate();
    } else {
      // Mejor calidad muxed disponible (audio + video en un solo stream)
      streamInfo = manifest.muxed.sortByVideoQuality().last;
    }

    if (!context.mounted) return;
    Navigator.pop(context);

    final success = await downloadManager.startDownload(
      videoId: videoId,
      title: video.title,
      streamInfo: streamInfo,
    );

    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la descarga.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DownloadsScreen()),
    );
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener info del video.')),
      );
    }
  } finally {
    yt.close();
  }
}
