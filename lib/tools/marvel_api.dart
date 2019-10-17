import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/models/marvel_series.dart';

class ApiService {
  final String _baseUrl;
  static Map<String, dynamic> _cache = Map<String, dynamic>();

  ApiService(this._baseUrl);

  Future<List<MarvelCharacter>> getMarvelCharacters(int page, int comicSeriesFilterId, Function setTotalCount) async {
    final Response response = await _apiCall("get", "$_baseUrl/characters?p=$page&${comicSeriesFilterId == null ? "" : "csfi="}$comicSeriesFilterId");

    setTotalCount(int.parse(jsonDecode(response.body)["count"].toString()));

    return jsonDecode(response.body)["characters"].map<MarvelCharacter>((character) {
      return MarvelCharacter.fromJson(character);
    }).toList();
  }

  Future<List<MarvelSeries>> getMarvelSeries(String titleStartsWith) async {
    final Response response = await _apiCall("get", "$_baseUrl/series?tsw=$titleStartsWith");

    return jsonDecode(response.body).map<MarvelSeries>((series) {
      return MarvelSeries.fromJson(series);
    }).toList();
  }

  Future<Response> _apiCall(String verb, String url, [String body]) async {
    Response response;

    if (_cache[url] == null) {
      print("REQUEST URL:$url");
      response =  await get("$url");
      _cache[url] = response;
      print("RESPONSE STATUS_CODE:${response.statusCode} BODY:${response.body}");
    } else {
      print("RETREIVE CACHED URL:$url");
      response = _cache[url];
      print("CACHE STATUS_CODE:${response.statusCode} BODY:${response.body}");
    }

    return response;
  }
}
