import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:marvel_client/models/marvel_series.dart';
import 'package:marvel_client/tools/marvel_api.dart';

class SearchSeriesAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool searchFilterActive;
  final Function openSeriesSearch;
  final Function onSuggestionSelected;
  final TextEditingController seriesTypeAheadController;

  SearchSeriesAppBar({
    this.searchFilterActive,
    this.seriesTypeAheadController,
    this.openSeriesSearch,
    this.onSuggestionSelected,
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
        Text("Marvel Characters"):
        TypeAheadFormField<MarvelSeries>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: widget.seriesTypeAheadController,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            autofocus: true,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'Search by Comic Series',
              counterStyle: TextStyle(color: Colors.white, fontSize: 10),
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          suggestionsCallback: (pattern) async => pattern != "" ? await ApiService().getMarvelSeries(pattern) : [],
          itemBuilder: (BuildContext context, MarvelSeries marvelSeries) {
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.network(marvelSeries.thumbnail, height: 48, width: 48),
              ),
              title: Text(marvelSeries.title),
            );
          },
          onSuggestionSelected: widget.onSuggestionSelected,
        )
      ,
    );
  }
}
