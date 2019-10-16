import 'package:flutter/material.dart';

import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/tools/marvel_api.dart';

import 'package:marvel_client/views/one_col_view.dart';
import 'package:marvel_client/views/three_cols_view.dart';

class MarvelScreen extends StatefulWidget {
  MarvelScreen({Key key}) : super(key: key);

  _MarvelScreenState createState() => _MarvelScreenState();
}

class _MarvelScreenState extends State<MarvelScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<MarvelCharacter> _marvelCharacters = List<MarvelCharacter>();
  int _lastPageLoaded = 0;
  bool _isLoading = false;
  bool _endReached = false;

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
      appBar: AppBar(
        title: Text("Marvel Characters"),
      ),
      body: MediaQuery.of(context).size.width < 600 ? OneColView(_marvelCharacters, _scrollController) : ThreeColsView(_marvelCharacters, _scrollController),
    );
  }

  Future<void> _loadPage() async {
    if (!_isLoading && !_endReached) {
      _isLoading = true;
      _loadingIndication(context);

      final List<MarvelCharacter> loadedMarvelCharacters = await ApiService().getMarvelCharacters(_lastPageLoaded);

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
                  Text("Chargement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Page ${_lastPageLoaded + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        );
      }
    );
  }
}
