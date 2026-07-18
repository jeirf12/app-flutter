import 'package:example_flutter/models/options.dart';
import 'package:example_flutter/services/api.dart';
import 'package:example_flutter/templates/downloads_screen.dart';
import 'package:example_flutter/templates/select_option_download.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

ApiService apiService = ApiService();

final List<Option> _options = [
  Option(
    'Descargas',
    Icons.download,
    (context) => Navigator.push(
        context, MaterialPageRoute(builder: (context) => DownloadsScreen())),
  ),
  Option(
    'Salir',
    Icons.exit_to_app,
    (context) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Salir de la app"),
          content: const Text("¿Desea salir de la aplicación?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => exit(0),
              child: const Text("Sí"),
            ),
          ],
        );
      },
    ),
  ),
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _items = [];
  String? _nextPageToken;
  bool _isLoading = false;
  bool _isFirstLoad = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _query = query;
      _items = [];
      _nextPageToken = null;
      _isLoading = true;
      _isFirstLoad = false;
    });
    await _fetchPage(null);
  }

  Future<void> _loadMore() async {
    if (_isLoading || _nextPageToken == null) return;
    setState(() => _isLoading = true);
    await _fetchPage(_nextPageToken);
  }

  Future<void> _fetchPage(String? pageToken) async {
    try {
      final response = await apiService.getAll(_query, pageToken: pageToken);
      final body = jsonDecode(response.body);
      final newItems = (body['items'] as List<dynamic>?) ?? [];
      setState(() {
        _items = [..._items, ...newItems];
        _nextPageToken = body['nextPageToken'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _menuOptions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: const Text('Configuración')),
          body: ListView(
            children: _options
                .map((element) => InkWell(
                      onTap: () => element.action(ctx),
                      child: ListTile(
                        title: Text(element.name,
                            style: Theme.of(ctx).textTheme.headlineSmall),
                        leading: Icon(element.icon, color: Colors.blue[300]),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _menuOptions,
              icon: const Icon(Icons.menu),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Buscar en YouTube...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.teal),
              onPressed: _search,
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isFirstLoad) {
      return const Center(
        child: Text(
          'Busca una canción para comenzar.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (!_isLoading && _items.isEmpty) {
      return const Center(child: Text('No se encontraron resultados.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = _items[index]['snippet'];
        final videoId = _items[index]['id']['videoId'] as String;
        final thumbnail = data['thumbnails']['high']['url'] as String;
        final titleText = data['title'] as String;
        final channelId = data['channelId'] as String;

        return InkWell(
          onTap: () => showDownloadOptions(context, videoId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                ),
              ),
              ListTile(
                leading: FutureBuilder<String?>(
                  future: apiService.getChannelThumbnail(channelId),
                  builder: (_, snap) {
                    if (snap.hasData && snap.data != null) {
                      return CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(snap.data!),
                      );
                    }
                    return CircleAvatar(child: Text(titleText[0]));
                  },
                ),
                title: Text(
                  titleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }
}
