import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:marvel_client/data/models/marvel_character.dart';
import 'package:marvel_client/data/models/marvel_character_comic.dart';
import 'package:marvel_client/data/models/marvel_character_event.dart';
import 'package:marvel_client/data/models/marvel_character_series.dart';
import 'package:marvel_client/data/models/marvel_character_story.dart';
import 'package:marvel_client/data/models/marvel_series.dart';

class ApiService {
  final String _baseUrl;
  final Client _client;
  static Map<String, dynamic> _cache = Map<String, dynamic>();

  ApiService(this._baseUrl, this._client);

  Future<List<MarvelCharacter>> getMarvelCharacters(int page, int comicSeriesFilterId, Function setTotalCount) async {
    final Response response = await _apiCall("get", "$_baseUrl/characters?p=$page&${comicSeriesFilterId == null ? "" : "csfi="}$comicSeriesFilterId");

    setTotalCount(int.parse(jsonDecode(response.body)["count"].toString()));

    return jsonDecode(response.body)["characters"].map<MarvelCharacter>((character) {
      return MarvelCharacter.fromJson(character);
    }).toList();
  }

  Future<List<MarvelCharacterComic>> getMarvelCharacterComics(int id) async {
    final Response response = await _apiCall("get", "$_baseUrl/characters/$id/comics?");

    return jsonDecode(response.body).map<MarvelCharacterComic>((comic) {
      return MarvelCharacterComic.fromJson(comic);
    }).toList();
  }

  Future<List<MarvelCharacterEvent>> getMarvelCharacterEvents(int id) async {
    final Response response = await _apiCall("get", "$_baseUrl/characters/$id/events?");

    return jsonDecode(response.body).map<MarvelCharacterEvent>((event) {
      return MarvelCharacterEvent.fromJson(event);
    }).toList();
  }

  Future<List<MarvelCharacterSeries>> getMarvelCharacterSeries(int id) async {
    final Response response = await _apiCall("get", "$_baseUrl/characters/$id/series?");

    return jsonDecode(response.body).map<MarvelCharacterSeries>((series) {
      return MarvelCharacterSeries.fromJson(series);
    }).toList();
  }

  Future<List<MarvelCharacterStory>> getMarvelCharacterStories(int id) async {
    final Response response = await _apiCall("get", "$_baseUrl/characters/$id/stories?");

    return jsonDecode(response.body).map<MarvelCharacterStory>((story) {
      return MarvelCharacterStory.fromJson(story);
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
      response =  await _client.get("$url");
      _cache[url] = response;
      print("RESPONSE STATUS_CODE:${response.statusCode} BODY:${response.body.substring(0, 300)}");
    } else {
      print("RETREIVE CACHED URL:$url");
      response = _cache[url];
      print("CACHE STATUS_CODE:${response.statusCode} BODY:${response.body.substring(0, 300)}");
    }

    return response;
  }
}
