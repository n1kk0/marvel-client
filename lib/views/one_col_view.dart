import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/screens/marvel_hero_screen.dart';

class OneColView extends StatelessWidget {
  final ScrollController _scrollController;
  final String _apiBaseUrl;

  OneColView(this._scrollController, this._apiBaseUrl, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: Provider.of<MarvelCharacters>(context).characters.map((MarvelCharacter marvelCharacter) {
        return ListTile(
          contentPadding: EdgeInsets.all(5),
          leading: Hero(
            tag: "kirbyrulez${marvelCharacter.hashCode}",
            child: marvelCharacter.loaded ? CircleAvatar(
              radius: 30,
              backgroundImage: Image.network("$_apiBaseUrl/images?uri=${marvelCharacter.thumbnail}").image,
              backgroundColor: Colors.transparent,
            ) : Container(
              height: 60,
              width: 60,
              child: CircularProgressIndicator()
            ),
          ),
          title: Text(marvelCharacter.name),
          onTap: () async {
            final MarvelCharacters characters = Provider.of<MarvelCharacters>(context, listen: false);
            characters.currentHeroId = characters.items.indexOf(marvelCharacter);

            await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => MarvelHeroScreen(_apiBaseUrl),
            ));
          },
        );
      }).toList(),
    );
  }
}
