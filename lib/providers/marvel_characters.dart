import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'package:marvel_client/tools/app_consts.dart';
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
  bool get isLoading => _isLoading;

  Future<void> loadPage(BuildContext context, [bool reset = false]) async {
    if(reset) {
      _endReached = false;
      _items.clear();
      _marvelCharactersQuantity = null;
      _lastPageLoaded = 0;
      notifyListeners();
    }

    if (!_isLoading && !_endReached) {
      _isLoading = true;
      _loadingIndicationOn(context);

      final List<MarvelCharacter> loadedMarvelCharacters = await ApiService(_apiBaseUrl, _client).getMarvelCharacters(_lastPageLoaded, _marvelSeriesFilterId, (int count) => _marvelCharactersQuantity = count);

      loadedMarvelCharacters.forEach((MarvelCharacter marvelCharacter) {
        _imagePreloader(marvelCharacter);
      });

      _items.addAll(loadedMarvelCharacters);

      if (_items.length == _marvelCharactersQuantity) {
        final MarvelCharacter marvelCharacter = MarvelCharacter(
          name: "You Reached The End",
          thumbnail: "https://images-na.ssl-images-amazon.com/images/S/cmx-images-prod/StoryArc/1542/1542._SX400_QL80_TTD_.jpg",
        );

        _imagePreloader(marvelCharacter);
        _items.add(marvelCharacter);
        _endReached = true;
      }

      _lastPageLoaded++;
      _isLoading = false;
      _loadingIndicationOff(context);
      notifyListeners();
    }
  }

  Future<Null> _loadingIndicationOn(BuildContext context) async {
    return await showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text("Loading", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  _lastPageLoaded > 0 ?
                    Text(
                      "Page ${_lastPageLoaded + 1} of ${(_marvelCharactersQuantity / AppConsts.itemsPerPage).ceil()}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ) :
                    Offstage()
                  ,
                  _lastPageLoaded > 0 ? 
                    Text(
                        "(Characters ${_lastPageLoaded * AppConsts.itemsPerPage} to ${(_lastPageLoaded +1) * AppConsts.itemsPerPage < _marvelCharactersQuantity ? (_lastPageLoaded + 1) * AppConsts.itemsPerPage : _marvelCharactersQuantity} on $_marvelCharactersQuantity)",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ) :
                      Offstage()
                    ,
                ],
              ),
            )
          ],
        );
      }
    );
  }

  Null _loadingIndicationOff(BuildContext context) {
    Navigator.of(context).pop();
  }

  Null _imagePreloader(MarvelCharacter marvelCharacter) {
    final Image image = marvelCharacter.getImage("$_apiBaseUrl/images?uri=");

    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((_, __) {
      marvelCharacter.loaded = true;
      notifyListeners();
    }));
  }
}
