import 'package:flutter/material.dart';

import 'package:marvel_client/models/marvel_character.dart';

import 'package:marvel_client/screens/marvel_hero_screen.dart';
import 'package:marvel_client/tools/app_config.dart';

class ThreeColsView extends StatelessWidget {
  final List<MarvelCharacter> _marvelCharacters;
  final ScrollController _scrollController;

  ThreeColsView(this._marvelCharacters, this._scrollController, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
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
                    backgroundImage: Image.network("${AppConfig.of(context).apiBaseUrl}/images?uri=${marvelcharacter.thumbnail}").image,
                    backgroundColor: Colors.transparent,
                    radius: MediaQuery.of(context).size.width / 10 - 2,
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
    );
  }
}
