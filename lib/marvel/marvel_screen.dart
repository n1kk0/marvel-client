import 'package:flutter/material.dart';
import 'package:marvel_client/marvel/marvel_hero_screen.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/tools/marvel_api.dart';

class MarvelScreen extends StatefulWidget {
  MarvelScreen({Key key}) : super(key: key);

  _MarvelScreenState createState() => _MarvelScreenState();
}

class _MarvelScreenState extends State<MarvelScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<MarvelCharacter> _marvelCharacters = List<MarvelCharacter>();
  int _lastPageLoaded = 0;

  @override
  void initState() {
    super.initState();

    _asyncInit();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _asyncInit();
      }
    });
  }

  Future<void> _asyncInit() async {
    if (_lastPageLoaded > 0) _loadingIndication(context);
    _marvelCharacters.addAll(await ApiService().getMarvelCharacters(_lastPageLoaded));
    if (_lastPageLoaded > 0) Navigator.of(context).pop();
    setState(() => _lastPageLoaded++);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marvel Characters"),
      ),
      body: ListView.builder(
        itemCount: _marvelCharacters.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            contentPadding: EdgeInsets.all(5),
            leading: Hero(
              tag: "kirbyrulez$index",
              child: CircleAvatar(
                radius: 30.0,
                backgroundImage: NetworkImage(_marvelCharacters[index].thumbnail),
                backgroundColor: Colors.transparent,
              )
            ),
            title: Text(_marvelCharacters[index].name),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MarvelHeroScreen(
                  _marvelCharacters[index].thumbnail,
                  _marvelCharacters[index].name,
                  "kirbyrulez$index",
                ),
              ));
            },
          );
        },
      ),
    );
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
              child: CircularProgressIndicator(),
            )
          ],
        );
      }
    );
  }
}
