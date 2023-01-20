import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:example_flutter/environment/environment.dart';

class ApiService {
  final Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future getAll() async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'relatedToVideoId': 'lwelJyNBD3w',
      'type': 'video',
      'maxResults': '10',
      'key': environment["apikey"].toString(),
    };
    String api = "youtube/v3/search";
    Uri uri = Uri.https(environment["baseUrl"].toString(), api, parameters);
    var response = await http.get(uri, headers: headers);
    return response;
  }

  getChannel(id) async {
    Map<String, String> parameters = {
      'part': 'snippet%2CcontentDetails%2Cstatistics',
      'maxResults': '10',
      'key': environment["apikey"].toString(),
      'id': id,
    };
    String api = "youtube/v3/channels";
    Uri uri = Uri.https(environment["baseUrl"].toString(), api, parameters);
    var response = await http.get(uri, headers: headers);
    return response;
  }
}
