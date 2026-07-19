import 'dart:io';
import 'package:example_flutter/models/download_model.dart';
import 'package:example_flutter/services/download_manager.dart';
import 'package:flutter/material.dart';

Future<void> showExitConfirmDialog(BuildContext context) async {
  final hasActive = downloadManager.value.any(
    (t) =>
        t.status == DownloadStatus.downloading ||
        t.status == DownloadStatus.paused,
  );
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(hasActive ? 'Descargas activas' : 'Salir de la app'),
      content: Text(
        hasActive
            ? 'Tienes descargas en progreso. Al cerrar la app se cancelarán. ¿Deseas salir de todas formas?'
            : '¿Deseas salir de la aplicación?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );
  if (confirmed == true) exit(0);
}
