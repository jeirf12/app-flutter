import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseurl = "www.googleapis.com";
  final String apikey = "AIzaSyDIaZoTbc5NNZ6Hsw2gImr4buDdJd7hVTE";
  final Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future getAll() async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'relatedToVideoId': 'lwelJyNBD3w',
      'type': 'video',
      'maxResults': '10',
      'key': apikey,
    };
    String api = "youtube/v3/search";
    Uri uri = Uri.https(baseurl, api, parameters);
    var response = await http.get(uri, headers: headers);
    return response;
  }

  getChannel(id) async {
    Map<String, String> parameters = {
      'part': 'snippet%2CcontentDetails%2Cstatistics',
      'maxResults': '10',
      'key': apikey,
      'id': id,
    };
    String api = "youtube/v3/channels";
    Uri uri = Uri.https(baseurl, api, parameters);
    var response = await http.get(uri, headers: headers);
    return response;
  }
}
