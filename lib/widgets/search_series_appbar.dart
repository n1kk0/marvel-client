import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';

import 'package:marvel_client/tools/marvel_api.dart';
import 'package:marvel_client/models/marvel_series.dart';

class SearchSeriesAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool searchFilterActive;
  final Function openSeriesSearch;
  final Function onSuggestionSelected;
  final TextEditingController seriesTypeAheadController;
  final int marvelCharactersQuantity;
  final Client client;
  final String apiBaseUrl;

  SearchSeriesAppBar({
    @required this.marvelCharactersQuantity,
    @required this.searchFilterActive,
    @required this.seriesTypeAheadController,
    @required this.openSeriesSearch,
    @required this.onSuggestionSelected,
    @required this.client,
    @required this.apiBaseUrl,
    Key key
  }) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

    @override
    final Size preferredSize;

    @override
    _SearchSeriesAppBarState createState() => _SearchSeriesAppBarState();
}

class _SearchSeriesAppBarState extends State<SearchSeriesAppBar>{
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(widget.searchFilterActive ? Icons.cancel : Icons.search),
        onPressed: widget.openSeriesSearch,
      ),
      title: !widget.searchFilterActive ?
        Text("Marvel Characters", style: TextStyle(fontWeight: FontWeight.bold)):
        TypeAheadField<MarvelSeries>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: widget.seriesTypeAheadController,
            style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color, fontSize: 16, fontWeight: FontWeight.bold),
            autofocus: true,
            cursorColor: Theme.of(context).primaryTextTheme.body1.color,
            decoration: InputDecoration(
              labelText: 'Search by Comic Series Title',
              counterStyle: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color, fontSize: 10),
              fillColor: Theme.of(context).primaryTextTheme.body1.color,
              labelStyle: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color),
            ),
          ),
          suggestionsCallback: (pattern) async => pattern != "" ? await ApiService(widget.apiBaseUrl, widget.client).getMarvelSeries(pattern) : [],
          itemBuilder: (BuildContext context, MarvelSeries marvelSeries) {
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.network("${widget.apiBaseUrl}/images?uri=${marvelSeries.thumbnail}", height: 48, width: 48),
              ),
              title: Text(marvelSeries.title),
            );
          },
          onSuggestionSelected: widget.onSuggestionSelected,
        )
      ,
      actions: <Widget>[
        CircleAvatar(child: Text("Total\n${widget.marvelCharactersQuantity == null ? "" : widget.marvelCharactersQuantity}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
