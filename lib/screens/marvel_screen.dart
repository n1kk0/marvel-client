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

  MarvelScreen(this._client, this._apiBaseUrl);

  _MarvelScreenState createState() => _MarvelScreenState();
}

class _MarvelScreenState extends State<MarvelScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _seriesTypeAheadController = TextEditingController();
  bool _searchFilterActive = false;
  bool _isScrolling = false;
  double _loadPageInitialMaxScrollExtent = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);

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
            _scrollController.jumpTo(0);
            _loadPageInitialMaxScrollExtent = 0;
            _initPageLoading();
          }

          setState(() {});
        },
        onSuggestionSelected: (MarvelSeries marvelSeries) {
          _seriesTypeAheadController.text = marvelSeries.title;
          Provider.of<MarvelCharacters>(context,listen: false).marvelSeriesFilterId = marvelSeries.id;
          _scrollController.jumpTo(0);
          _loadPageInitialMaxScrollExtent = 0;
          _initPageLoading();
        },
        client: widget._client,
        apiBaseUrl: widget._apiBaseUrl,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
            _isScrolling = true;
          } else if (scrollNotification is ScrollEndNotification) {
            _isScrolling = false;
          }

          return false;
        },
        child: MediaQuery.of(context).size.width < 600 ?
          OneColView(_scrollController, widget._apiBaseUrl) :
          MediaQuery.of(context).size.width < 1100 ?
            MultiColsView(_scrollController, AppConsts.over600Cols, widget._apiBaseUrl) :
            MultiColsView(_scrollController, AppConsts.over1100Cols, widget._apiBaseUrl)
        ,
      ),
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

  void _initPageLoading() {
    if (Provider.of<MarvelCharacters>(context, listen: false).lastPageLoaded  == 0) {
      Future.delayed(Duration(milliseconds: 10), () => Provider.of<MarvelCharacters>(context, listen: false).loadPage(context).then((_) {
        if (
          MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width / MediaQuery.of(context).size.height < AppConsts.over600Cols / (AppConsts.itemsPerPage / AppConsts.over600Cols)
        ) {
          Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
        }

        if (
          MediaQuery.of(context).size.width >= 1100 &&
          MediaQuery.of(context).size.width / MediaQuery.of(context).size.height < AppConsts.over1100Cols / (AppConsts.itemsPerPage / AppConsts.over1100Cols)
        ) {
          Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
        }
      }));
    }
  }

  Future<void> _scrollListener() async {
    if (
      _loadPageInitialMaxScrollExtent < _scrollController.position.maxScrollExtent &&
      _scrollController.offset >= _scrollController.position.maxScrollExtent - 50 &&
      !Provider.of<MarvelCharacters>(context, listen: false).isLoading
    ) {
      _loadPageInitialMaxScrollExtent = _scrollController.position.maxScrollExtent;
      await Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
    }
  }

  void _keydownEventListener(dynamic event) {
    if (event.code == 'ArrowDown' && !_isScrolling) {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - _scrollController.position.viewportDimension) {
        Provider.of<MarvelCharacters>(context, listen: false).loadPage(context);
      }

      _scrollController.animateTo(
        _scrollController.offset + _scrollController.position.viewportDimension,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );

      event.preventDefault();
    } else if (event.code == 'ArrowUp' && !_isScrolling) {
      _scrollController.animateTo(
        _scrollController.offset < _scrollController.position.viewportDimension ? 0 : _scrollController.offset - _scrollController.position.viewportDimension,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );

      event.preventDefault();
    }
  }
}
