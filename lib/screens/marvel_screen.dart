import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/tools/app_consts.dart';
import 'package:marvel_client/providers/marvel_characters.dart';
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
        await Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
      }
    });

    if (kIsWeb) {
      uh.document.addEventListener('keydown', _keydownEventListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initPageLoading();

    return Scaffold(
      appBar: SearchSeriesAppBar(
        seriesTypeAheadController: _seriesTypeAheadController,
        searchFilterActive: _searchFilterActive,
        openSeriesSearch: () {
          _searchFilterActive = !_searchFilterActive;

          if (!_searchFilterActive) {
            _seriesTypeAheadController.text = "";
            Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = null;

            Provider.of<MarvelCharacters>(context, listen: false).loadPage(context, true).then((onValue) {
              if (MediaQuery.of(context).size.width > 1100) Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
            });
          }

          setState(() {});
        },
        onSuggestionSelected: (MarvelSeries marvelSeries) {
          _seriesTypeAheadController.text = marvelSeries.title;
          Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = marvelSeries.id;

          Provider.of<MarvelCharacters>(context, listen: false).loadPage(context, true).then((onValue) {
            if (MediaQuery.of(context).size.width > 1100) Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
          });
        },
        client: widget._client,
        apiBaseUrl: widget._apiBaseUrl,
      ),
      body: MediaQuery.of(context).size.width < 600 ?
        OneColView(_scrollController, widget._apiBaseUrl) :
        MediaQuery.of(context).size.width < 1100 ?
          MultiColsView(_scrollController, AppConsts.over600Cols, widget._apiBaseUrl) :
          MultiColsView(_scrollController, AppConsts.over1100Cols, widget._apiBaseUrl)
      ,
      bottomNavigationBar: MarvelBottomAppBar(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _seriesTypeAheadController.dispose();
    uh.document.removeEventListener('keydown', _keydownEventListener);
    super.dispose();
  }

  Null _initPageLoading() {
    if (Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded  == 0) {
      Future.delayed(Duration(milliseconds: 10), () => Provider.of<MarvelCharacters>(context, listen: false).loadPage(context).then((_) async {
        if (
          MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width / MediaQuery.of(context).size.height < AppConsts.over600Cols / (AppConsts.itemsPerPage / AppConsts.over600Cols)
        ) {
          await Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
        }

        if (
          MediaQuery.of(context).size.width >= 1100 &&
          MediaQuery.of(context).size.width / MediaQuery.of(context).size.height < AppConsts.over1100Cols / (AppConsts.itemsPerPage / AppConsts.over1100Cols)
        ) {
          await Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
        }

        _scrollController.position.isScrollingNotifier.addListener(() {
          _isScrolling = _scrollController.position.isScrollingNotifier.value;
        });
      }));
    }
  }

  void _keydownEventListener(dynamic event) {
    if (event.code == 'ArrowDown' && _isScrolling == false) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - _scrollController.position.viewportDimension) {
        Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
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
  }
}
