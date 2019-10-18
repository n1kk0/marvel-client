import 'package:flutter/material.dart';

import 'package:marvel_client/models/marvel_character.dart';

import 'package:marvel_client/screens/marvel_hero_screen.dart';

class OneColView extends StatelessWidget {
  final List<MarvelCharacter> _marvelCharacters;
  final ScrollController _scrollController;

  OneColView(this._marvelCharacters, this._scrollController, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _marvelCharacters.length,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          contentPadding: EdgeInsets.all(5),
          leading: Hero(
            tag: "kirbyrulez$index",
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: Image.network(_marvelCharacters[index].thumbnail).image,
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
    );
  }
}
