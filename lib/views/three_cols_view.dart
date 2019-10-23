import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/screens/marvel_hero_screen.dart';

class ThreeColsView extends StatelessWidget {
  final ScrollController _scrollController;
  final String _apiBaseUrl;

  ThreeColsView(this._scrollController, this._apiBaseUrl, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      controller: _scrollController,
      crossAxisCount: 3,
      padding: EdgeInsets.all(36.0),
      mainAxisSpacing: 36.0,
      crossAxisSpacing: 36.0,
      children: Provider.of<MarvelCharacters>(context).characters.map((MarvelCharacter marvelCharacter) {
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
                  tag: "kirbyrulez${marvelCharacter.hashCode}",
                  child: marvelCharacter.loaded ? CircleAvatar(
                    backgroundImage: Image.network("$_apiBaseUrl/images?uri=${marvelCharacter.thumbnail}").image,
                    backgroundColor: Colors.transparent,
                    radius: MediaQuery.of(context).size.width / 10 - 2,
                  ) : Center(child: Container(
                    height: MediaQuery.of(context).size.width / 5 - 4,
                    width: MediaQuery.of(context).size.width / 5 - 4,
                    child: CircularProgressIndicator()
                  ))
                ),
                Text(marvelCharacter.name, style: TextStyle(fontSize: MediaQuery.of(context).size.width / 50, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => MarvelHeroScreen(
                _apiBaseUrl,
                Provider.of<MarvelCharacters>(context, listen: false).setHeroId(Provider.of<MarvelCharacters>(context, listen: false).items.indexOf(marvelCharacter)),
                "kirbyrulez${marvelCharacter.hashCode}",
              ),
            ));
          },
        );
      }).toList(),
    );
  }
}
