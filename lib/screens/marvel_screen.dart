import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/tools/app_consts.dart';
import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/models/marvel_series.dart';
import 'package:marvel_client/views/one_col_view.dart';
import 'package:marvel_client/views/multi_cols_view.dart';
import 'package:marvel_client/widgets/search_series_appbar.dart';
import 'package:marvel_client/widgets/marvel_botton_bar.dart';

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
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        await Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
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
    if (Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded  == 0) {
      Future.delayed(Duration(milliseconds: 10), () => Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader).then((_) async {
        if (
          MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width / MediaQuery.of(context).size.height < 3 / 5
        ) {
          await Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
        }

        if (
          MediaQuery.of(context).size.width >= 1100 &&
          MediaQuery.of(context).size.width / MediaQuery.of(context).size.height < 5 / 3
        ) {
          await Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
        }

        _scrollController.position.isScrollingNotifier.addListener(() {
          _isScrolling = _scrollController.position.isScrollingNotifier.value;
        });
      }));
    }

    if (kIsWeb) {
      uh.document.addEventListener('keydown', (dynamic event) {
        if (event.code == 'ArrowDown' && _isScrolling == false) {
          if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - _scrollController.position.viewportDimension) {
            Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
          }

          _scrollController.animateTo(
            _scrollController.position.pixels + _scrollController.position.viewportDimension,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );

          event.preventDefault();
        } else if (event.code == 'ArrowUp' && _isScrolling == false) {
          _scrollController.animateTo(
            _scrollController.position.pixels < _scrollController.position.viewportDimension ? 0 : _scrollController.position.pixels - _scrollController.position.viewportDimension,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );

          event.preventDefault();
        }
      });
    }

    return Scaffold(
      appBar: SearchSeriesAppBar(
        seriesTypeAheadController: _seriesTypeAheadController,
        searchFilterActive: _searchFilterActive,
        openSeriesSearch: () {
          _searchFilterActive = !_searchFilterActive;

          if (!_searchFilterActive) {
            _seriesTypeAheadController.text = "";
            Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = null;

            Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader, true).then((onValue) {
              if (MediaQuery.of(context).size.width > 1100) Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
            });
          }

          setState(() {});
        },
        onSuggestionSelected: (MarvelSeries marvelSeries) {
          _seriesTypeAheadController.text = marvelSeries.title;
          Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = marvelSeries.id;

          Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader, true).then((onValue) {
            if (MediaQuery.of(context).size.width > 1100) Provider.of<MarvelCharacters>(context, listen: false).loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
          });
        },
        client: widget._client,
        apiBaseUrl: widget._apiBaseUrl,
      ),
      body: MediaQuery.of(context).size.width < 600 ?
        OneColView(_scrollController, widget._apiBaseUrl) :
        MediaQuery.of(context).size.width < 1100 ?
          MultiColsView(_scrollController, 3, widget._apiBaseUrl) :
          MultiColsView(_scrollController, 5, widget._apiBaseUrl)
      ,
      bottomNavigationBar: MarvelBottomAppBar(),
    );
  }

  Future<Null> _loadingIndicationOn() async {
    final MarvelCharacters marvelCharacters = Provider.of<MarvelCharacters>(context, listen: false);

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
                  marvelCharacters.lastPageLoaded > 0 ?
                    Text(
                      "Page ${marvelCharacters.lastPageLoaded + 1} of ${(marvelCharacters.marvelCharactersQuantity / AppConsts.itemsPerPage).ceil()}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ) :
                    Offstage()
                  ,
                  marvelCharacters.lastPageLoaded > 0 ? 
                    Text(
                        "(Characters ${marvelCharacters.lastPageLoaded * AppConsts.itemsPerPage} to ${(marvelCharacters.lastPageLoaded +1) * AppConsts.itemsPerPage < marvelCharacters.marvelCharactersQuantity ? (marvelCharacters.lastPageLoaded + 1) * AppConsts.itemsPerPage : marvelCharacters.marvelCharactersQuantity} on ${marvelCharacters.marvelCharactersQuantity})",
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
