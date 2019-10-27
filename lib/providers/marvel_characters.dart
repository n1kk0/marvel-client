import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'package:marvel_client/tools/marvel_api.dart';
import 'package:marvel_client/models/marvel_character.dart';

class MarvelCharacters with ChangeNotifier {
  final Client _client;
  final String _apiBaseUrl;
  final List<MarvelCharacter> _items = List<MarvelCharacter>();
  int _marvelSeriesFilterId;
  int _marvelCharactersQuantity;
  int _currentHeroId;
  int _lastPageLoaded = 0;
  bool _isLoading = false;
  bool _endReached = false;

  MarvelCharacters(this._client, this._apiBaseUrl);

  UnmodifiableListView<MarvelCharacter> get items => UnmodifiableListView(_items);

  set marvelSeriesFilterId(int marvelSeriesFilterId) => _marvelSeriesFilterId = marvelSeriesFilterId;
  set currentHeroId(int currentHeroId) {
    _currentHeroId = currentHeroId;
    notifyListeners();
  }

  int get marvelCharactersQuantity => _marvelCharactersQuantity;
  List<MarvelCharacter> get characters => _items;
  int get lastPageLoaded => _lastPageLoaded;
  int get currentHeroId => _currentHeroId;

  Future<void> loadPage(Function loadingIndicationOn, Function loadingIndicationOff, Function imagePreloader, [bool reset = false]) async {
    if(reset) {
      _endReached = false;
      _items.clear();
      _marvelCharactersQuantity = null;
      _lastPageLoaded = 0;
      notifyListeners();
    }

    if (!_isLoading && !_endReached) {
      _isLoading = true;
      loadingIndicationOn();

      final List<MarvelCharacter> loadedMarvelCharacters = await ApiService(_apiBaseUrl, _client).getMarvelCharacters(_lastPageLoaded, _marvelSeriesFilterId, (int count) => _marvelCharactersQuantity = count);

      loadedMarvelCharacters.forEach((MarvelCharacter marvelCharacter) {
        imagePreloader(marvelCharacter);
      });

      _items.addAll(loadedMarvelCharacters);

      if (_items.length == _marvelCharactersQuantity) {
        final MarvelCharacter marvelCharacter = MarvelCharacter(
          name: "You Reached The End",
          thumbnail: "https://images-na.ssl-images-amazon.com/images/S/cmx-images-prod/StoryArc/1542/1542._SX400_QL80_TTD_.jpg",
        );

        imagePreloader(marvelCharacter);
        _items.add(marvelCharacter);
        _endReached = true;
      }

      _lastPageLoaded++;
      _isLoading = false;
      loadingIndicationOff();
      notifyListeners();
    }
  }
}
