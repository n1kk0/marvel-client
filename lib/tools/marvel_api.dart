import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:marvel_client/models/marvel_character.dart';

class ApiService {
  final String _baseUrl = "https://gateway.marvel.com";
  final String _apiPublicKey = "3d1f66d37dfce525e7bc478de3b021e8";
  final String _apiPrivateKey = "f0ef5215d848fad0762c6ba8cce055a72e7ad6bf";

  Future<List<MarvelCharacter>> getMarvelCharacters(int page) async {
    final Response response = await _apiCall("get", "$_baseUrl/v1/public/characters?orderBy=name&limit=15&offset=${page * 15}");

    return jsonDecode(response.body)["data"]["results"].map<MarvelCharacter>((beacon) {
      return MarvelCharacter.fromJson(beacon);
    }).toList();
  }

  Future<Response> _apiCall(String verb, String url, [String body]) async {
    print("REQUEST URL:$url");

    final int ts = DateTime.now().millisecondsSinceEpoch.abs();
    final String hash = md5.convert(utf8.encode("$ts$_apiPrivateKey$_apiPublicKey")).toString();
    final Response response =  await get("$url&ts=$ts&apikey=$_apiPublicKey&hash=$hash");

    print("RESPONSE STATUS_CODE:${response.statusCode} BODY:${response.body}");

    return response;
  }
}
