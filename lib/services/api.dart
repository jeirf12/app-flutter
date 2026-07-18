import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:example_flutter/environment/environment.dart';

class ApiService {
  final Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  // Cache: channelId → Future<thumbnailUrl?>
  final Map<String, Future<String?>> _channelCache = {};

  Future getAll(String query, {String? pageToken}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'maxResults': '10',
      'key': environment["apikey"].toString(),
      if (pageToken != null) 'pageToken': pageToken,
    };
    String api = "youtube/v3/search";
    Uri uri = Uri.https(environment["baseUrl"].toString(), api, parameters);
    var response = await http.get(uri, headers: headers);
    return response;
  }

  Future<String?> getChannelThumbnail(String channelId) =>
      _channelCache.putIfAbsent(channelId, () => _fetchChannelThumbnail(channelId));

  Future<String?> _fetchChannelThumbnail(String channelId) async {
    try {
      final response = await getChannel(channelId);
      final body = jsonDecode(response.body);
      return body['items']?[0]?['snippet']?['thumbnails']?['default']?['url']
          as String?;
    } catch (_) {
      return null;
    }
  }

  getChannel(id) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'key': environment["apikey"].toString(),
      'id': id,
    };
    String api = "youtube/v3/channels";
    Uri uri = Uri.https(environment["baseUrl"].toString(), api, parameters);
    var response = await http.get(uri, headers: headers);
    return response;
  }
}
