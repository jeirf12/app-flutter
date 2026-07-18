# Download Video

Aplicación Android desarrollada en Flutter que permite buscar videos de YouTube y descargarlos en formato **MP3** (solo audio) o **MP4** (video con audio) directamente en la carpeta `Downloads` del dispositivo.

---

## Índice

- [Características](#características)
- [Tecnologías](#tecnologías)
- [Arquitectura y flujo](#arquitectura-y-flujo)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos previos](#requisitos-previos)
- [Configuración](#configuración)
- [Correr en local](#correr-en-local)
- [Generar APK](#generar-apk)
- [Permisos requeridos](#permisos-requeridos)
- [Gestión de descargas](#gestión-de-descargas)

---

## Características

- 🔍 **Búsqueda de videos** en YouTube mediante la YouTube Data API v3 con scroll infinito
- ⬇️ **Descarga en MP3** (audio con mayor bitrate disponible)
- 🎬 **Descarga en MP4** (mejor calidad muxed disponible)
- ⏸️ **Pausar / reanudar** descargas en curso
- ❌ **Cancelar** y eliminar archivo parcial automáticamente
- 📂 Los archivos se guardan en `/storage/emulated/0/Download/`
- 💾 Las tareas de descarga **persisten** entre sesiones (JSON local)
- 📱 Íconos adaptativos generados con `flutter_launcher_icons`

---

## Tecnologías

| Paquete | Uso |
|---|---|
| `youtube_explode_dart` | Obtener streams directos de YouTube sin necesidad de API key de descarga |
| `http` | Llamadas a YouTube Data API v3 (búsqueda) |
| `cached_network_image` | Caché de miniaturas de videos y canales |
| `permission_handler` | Solicitud de permisos de almacenamiento en runtime |
| `device_info_plus` | Detectar versión de Android para elegir el permiso correcto |
| `path_provider` | Ruta del directorio de documentos para persistir tareas |
| `open_file` | Abrir el archivo descargado desde la pantalla de descargas |

---

## Arquitectura y flujo

```
Usuario
  │
  ├─▶ Busca en YouTube (YouTube Data API v3)
  │       │
  │       └─▶ Lista de resultados con thumbnail + título + canal
  │
  ├─▶ Toca un video
  │       │
  │       └─▶ BottomSheet: elige MP3 o MP4
  │               │
  │               ├─▶ [MP3] → youtube_explode_dart → AudioOnlyStream (mayor bitrate)
  │               └─▶ [MP4] → youtube_explode_dart → MuxedStream (mejor calidad)
  │                       │
  │                       └─▶ DownloadManager
  │                               ├─▶ Verifica permisos
  │                               ├─▶ Crea DownloadTask
  │                               ├─▶ Stream de bytes → archivo en /Download/
  │                               └─▶ Notifica progreso en tiempo real (ValueNotifier)
  │
  └─▶ Pantalla de Descargas
          ├─▶ Progreso en tiempo real
          ├─▶ Pausar / Reanudar / Cancelar
          └─▶ Tap en descarga completada → abre el archivo
```

### Estados de una descarga

```
pending ──▶ downloading ──▶ completed
                │
                ├──▶ paused ──▶ downloading
                └──▶ failed
```

---

## Estructura del proyecto

```
lib/
├── main.dart                        # Punto de entrada, tema y permisos iniciales
├── environment/
│   └── environment.dart             # URL base y API key de YouTube
├── models/
│   ├── download_model.dart          # DownloadTask + DownloadStatus
│   └── options.dart                 # Modelo para opciones del menú
├── services/
│   ├── api.dart                     # YouTube Data API v3 (búsqueda y canal)
│   └── download_manager.dart        # Lógica de descarga, pausa, cancelación y persistencia
└── templates/
    ├── home.dart                    # Pantalla principal: búsqueda y lista de resultados
    ├── select_option_download.dart  # BottomSheet MP3/MP4 + inicio de descarga
    └── downloads_screen.dart        # Pantalla de descargas activas/completadas
```

---

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- Android SDK con al menos **API 21** como mínimo y **API 33+** recomendado
- Un dispositivo físico Android o emulador con **modo depuración USB** activado
- Una [YouTube Data API v3 key](https://console.cloud.google.com/) habilitada en Google Cloud

---

## Configuración

Antes de correr la app, coloca tu API key en:

```dart
// lib/environment/environment.dart
const environment = {
  "baseUrl": "www.googleapis.com",
  "apikey": "TU_API_KEY_AQUI",
};
```

> ⚠️ No subas tu API key a un repositorio público. Considera usar variables de entorno o un archivo `.env` ignorado por `.gitignore`.

---

## Correr en local

### 1. Instalar dependencias de la plataforma Android

Si es la primera vez que se corre el proyecto, se deben generar los archivos nativos de Android:

```bash
flutter create --platforms android .
```

### 2. Obtener paquetes de Dart/Flutter

```bash
flutter pub get
```

### 3. Conectar el dispositivo

Conecta tu teléfono Android por USB con **depuración USB** activada y verifica que Flutter lo detecte:

```bash
flutter devices
```

### 4. Ejecutar la app

```bash
flutter run
```

Para elegir un dispositivo específico si hay varios conectados:

```bash
flutter run -d <device-id>
```

---

## Generar APK

### APK de debug (para pruebas rápidas)

```bash
flutter build apk --debug
```

Salida: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de release (optimizado para distribución)

```bash
flutter build apk --release
```

Salida: `build/app/outputs/flutter-apk/app-release.apk`

### APK split por arquitectura (tamaño reducido)

```bash
flutter build apk --release --split-per-abi
```

Genera tres APKs separados:

| Archivo | Arquitectura |
|---|---|
| `app-armeabi-v7a-release.apk` | ARM 32-bit (dispositivos antiguos) |
| `app-arm64-v8a-release.apk` | ARM 64-bit (dispositivos modernos) |
| `app-x86_64-release.apk` | x86 64-bit (emuladores) |

Salida: `build/app/outputs/flutter-apk/`

### App Bundle (para Google Play)

```bash
flutter build appbundle --release
```

Salida: `build/app/outputs/bundle/release/app-release.aab`

---

## Permisos requeridos

| Permiso | Motivo |
|---|---|
| `INTERNET` | Búsqueda y descarga de streams |
| `READ_EXTERNAL_STORAGE` | Acceso a almacenamiento (Android < 13) |
| `WRITE_EXTERNAL_STORAGE` | Guardar archivos descargados (Android < 13) |
| `READ_MEDIA_VIDEO` | Acceso a videos (Android 13+) |
| `READ_MEDIA_AUDIO` | Acceso a audio (Android 13+) |
| `MANAGE_EXTERNAL_STORAGE` | Escritura en `/Download/` en versiones recientes |

---

## Gestión de descargas

### Cómo funciona

1. Al iniciar la descarga se crea un `DownloadTask` con estado `downloading`
2. El stream de bytes se escribe directamente al archivo de destino
3. Si no llega ningún chunk en **90 segundos**, la descarga falla automáticamente (timeout)
4. Al completarse, el progreso se guarda en un archivo JSON (`downloads.json`) en el directorio de documentos de la app
5. Al reabrir la app se cargan las tareas anteriores; las que estaban en curso se marcan como `failed` ya que el stream no puede reanudarse entre sesiones

### Ruta de descarga

Los archivos se guardan en:

```
/storage/emulated/0/Download/<título_del_video>.<mp3|mp4>
```

Los caracteres inválidos en el título (`< > : " / \ | ? *`) se eliminan automáticamente del nombre del archivo.

---

## Pantallas de la app

### Pantalla principal — Búsqueda

```
┌─────────────────────────────────┐
│ ☰  [Buscar en YouTube...]   🔍  │  ← AppBar con búsqueda inline
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ [thumbnail]  Título video   │ │
│ │             Canal · duración│ │  ← Tap abre el BottomSheet
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ [thumbnail]  Título video   │ │
│ │             Canal           │ │
│ └─────────────────────────────┘ │
│            ...                  │
│      ⟳ (cargando más)           │  ← Scroll infinito
└─────────────────────────────────┘
```

### BottomSheet — Elegir formato

```
┌─────────────────────────────────┐
│                                 │
│        Descargar como           │
│ ─────────────────────────────── │
│ 🎵  MP3 (Solo audio)            │
│ 🎬  MP4 (Video)                 │
└─────────────────────────────────┘
```

### Pantalla de Descargas

```
┌─────────────────────────────────┐
│         Mis Descargas           │
├─────────────────────────────────┤
│ Título del video                │
│ ████████████░░░░  78%           │
│ 45.20 MB / 58.10 MB    [⏸][✕]  │
├─────────────────────────────────┤
│ Otro video                      │
│ ████████████████  100%          │
│ 12.00 MB / 12.00 MB       [✓]  │  ← Tap abre el archivo
└─────────────────────────────────┘
```

### Menú — Configuración

```
┌─────────────────────────────────┐
│ ← Configuración                 │
├─────────────────────────────────┤
│ ⬇  Descargas                   │
│ 🚪 Salir                        │
└─────────────────────────────────┘
```

