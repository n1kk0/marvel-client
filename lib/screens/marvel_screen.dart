import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:provider/provider.dart';

import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_series.dart';
import 'package:marvel_client/views/one_col_view.dart';
import 'package:marvel_client/views/three_cols_view.dart';
import 'package:marvel_client/widgets/search_series_appbar.dart';

class MarvelScreen extends StatefulWidget {
  final Client _client;
  final String _apiBaseUrl;

  MarvelScreen(this._client, this._apiBaseUrl, {Key key}) : super(key: key);

  _MarvelScreenState createState() => _MarvelScreenState();
}

class _MarvelScreenState extends State<MarvelScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _seriesTypeAheadController = TextEditingController();
  bool _searchFilterActive = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
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
    if (Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded  == 0) Future.delayed(Duration(milliseconds: 10), () => Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader));

    return Scaffold(
      appBar: SearchSeriesAppBar(
        marvelCharactersQuantity: Provider.of<MarvelCharacters>(context).marvelCharactersQuantity,
        seriesTypeAheadController: _seriesTypeAheadController,
        searchFilterActive: _searchFilterActive,
        openSeriesSearch: () {
          _searchFilterActive = !_searchFilterActive;

          if (!_searchFilterActive) {
            _seriesTypeAheadController.text = "";
            Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = null;
            Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader, true);
          }

          setState(() {});
        },
        onSuggestionSelected: (MarvelSeries marvelSeries) {
          _seriesTypeAheadController.text = marvelSeries.title;
          Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = marvelSeries.id;
          Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader, true);
        },
        client: widget._client,
        apiBaseUrl: widget._apiBaseUrl,
      ),
      body: MediaQuery.of(context).size.width < 600 ? OneColView(_scrollController, widget._apiBaseUrl) : ThreeColsView(_scrollController, widget._apiBaseUrl),
    );
  }

  Future<Null> _loadingIndicationOn() async {
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
                  Text("Page ${Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded > 0 ? 
                    Text(
                        "(Characters ${Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded * 15} to ${(Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded +1) * 15 < Provider.of<MarvelCharacters>(context, listen: false).marvelCharactersQuantity ? (Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded +1) * 15 : Provider.of<MarvelCharacters>(context, listen: false).marvelCharactersQuantity} on ${Provider.of<MarvelCharacters>(context, listen: false).marvelCharactersQuantity})",
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

  Null _loadingIndicationOff() {
    Navigator.of(context).pop();
  }

  Null _imagePreloader(MarvelCharacter marvelCharacter) {
    final Image image = marvelCharacter.getImage("${widget._apiBaseUrl}/images?uri=");

    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((_, __) {
        setState(() => marvelCharacter.loaded = true);
    }));
  }
}
