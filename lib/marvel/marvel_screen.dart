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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastPageLoaded == 0) Future.delayed(Duration(seconds: 1), _loadPage);

    return Scaffold(
      appBar: AppBar(
        title: Text("Marvel Characters"),
      ),
      body: MediaQuery.of(context).size.width < 600 ?
        ListView.builder(
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
        ) :
        GridView.count(
          controller: _scrollController,
          crossAxisCount: 3,
          padding: EdgeInsets.all(36.0),
          mainAxisSpacing: 36.0,
          crossAxisSpacing: 36.0,
          children: _marvelCharacters.map((MarvelCharacter marvelcharacter) {
            return GestureDetector(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.width / 5,
                  maxWidth: MediaQuery.of(context).size.width / 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: "kirbyrulez${marvelcharacter.hashCode}",
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(marvelcharacter.thumbnail),
                        backgroundColor: Colors.transparent,
                        radius: MediaQuery.of(context).size.width / 10,
                      )
                    ),
                    Text(marvelcharacter.name, style: TextStyle(fontSize: MediaQuery.of(context).size.width / 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => MarvelHeroScreen(
                    marvelcharacter.thumbnail,
                    marvelcharacter.name,
                    "kirbyrulez${marvelcharacter.hashCode}",
                  ),
                ));
              },
            );
          }).toList(),
        )
      ,
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
