import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:marvel_client/tools/app_config.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/models/marvel_series.dart';
import 'package:marvel_client/tools/marvel_api.dart';
import 'package:marvel_client/views/one_col_view.dart';
import 'package:marvel_client/views/three_cols_view.dart';
import 'package:marvel_client/widgets/search_series_appbar.dart';

class MarvelScreen extends StatefulWidget {
  final Client _client;
  MarvelScreen(this._client, {Key key}) : super(key: key);

  _MarvelScreenState createState() => _MarvelScreenState();
}

class _MarvelScreenState extends State<MarvelScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _seriesTypeAheadController = TextEditingController();
  final List<MarvelCharacter> _marvelCharacters = List<MarvelCharacter>();
  int _marvelCharactersQuantity;
  int _marvelSeriesFilterId;
  int _lastPageLoaded = 0;
  bool _isLoading = false;
  bool _endReached = false;
  bool _searchFilterActive = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastPageLoaded == 0) Future.delayed(Duration(milliseconds: 10), _loadPage);

    return Scaffold(
      appBar: SearchSeriesAppBar(
        marvelCharactersQuantity: _marvelCharactersQuantity,
        seriesTypeAheadController: _seriesTypeAheadController,
        searchFilterActive: _searchFilterActive,
        openSeriesSearch: () {
          _searchFilterActive = !_searchFilterActive;

          if (!_searchFilterActive) {
            _seriesTypeAheadController.text = "";
            _marvelSeriesFilterId = null;
            _loadPage(true);
          }

          setState(() {});
        },
        onSuggestionSelected: (MarvelSeries marvelSeries) {
          _seriesTypeAheadController.text = marvelSeries.title;
          _marvelSeriesFilterId = marvelSeries.id;
          _loadPage(true);
        },
        client: widget._client,
      ),
      body: MediaQuery.of(context).size.width < 600 ? OneColView(_marvelCharacters, _scrollController) : ThreeColsView(_marvelCharacters, _scrollController),
    );
  }

  Future<void> _loadPage([bool reset = false]) async {
    if(reset) {
      _endReached = false;
      _marvelCharacters.clear();
      _lastPageLoaded = 0;
    }

    if (!_isLoading && !_endReached) {
      _isLoading = true;
      _loadingIndication(context);

      final List<MarvelCharacter> loadedMarvelCharacters = await ApiService(AppConfig.of(context).apiBaseUrl, widget._client).getMarvelCharacters(_lastPageLoaded, _marvelSeriesFilterId, (int count) => _marvelCharactersQuantity = count);

      if (loadedMarvelCharacters.isEmpty) {
        _marvelCharacters.add(MarvelCharacter(
          name: "You Reached The End",
          thumbnail: "https://images-na.ssl-images-amazon.com/images/S/cmx-images-prod/StoryArc/1542/1542._SX400_QL80_TTD_.jpg",
        ));

        _endReached = true;
      } else {
        _marvelCharacters.addAll(loadedMarvelCharacters);
      }

      Navigator.of(context).pop();
      _lastPageLoaded++;
      _isLoading = false;
      setState(() {});
    }
  }

  Future<Null> _loadingIndication(BuildContext context) async {
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
                  Text("Page ${_lastPageLoaded + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  _lastPageLoaded > 0 ? 
                    Text(
                        "(Characters ${_lastPageLoaded * 15} to ${(_lastPageLoaded +1) * 15 < _marvelCharactersQuantity ? (_lastPageLoaded +1) * 15 : _marvelCharactersQuantity} on $_marvelCharactersQuantity)",
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
}
