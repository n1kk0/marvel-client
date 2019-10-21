import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/screens/marvel_hero_screen.dart';

class OneColView extends StatelessWidget {
  final ScrollController _scrollController;
  final String _apiBaseUrl;

  OneColView(this._scrollController, this._apiBaseUrl, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: Provider.of<MarvelCharacters>(context).marvelCharactersQuantity,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          contentPadding: EdgeInsets.all(5),
          leading: Hero(
            tag: "kirbyrulez$index",
            child: Provider.of<MarvelCharacters>(context).characters[index].loaded ? CircleAvatar(
              radius: 30,
              backgroundImage: Image.network("$_apiBaseUrl/images?uri=${Provider.of<MarvelCharacters>(context).characters[index].thumbnail}").image,
              backgroundColor: Colors.transparent,
            ) : Container(
              height: 60,
              width: 60,
              child: CircularProgressIndicator()
            )
          ),
          title: Text(Provider.of<MarvelCharacters>(context).characters[index].name),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => MarvelHeroScreen(
                _apiBaseUrl,
                Provider.of<MarvelCharacters>(context).characters[index].thumbnail,
                Provider.of<MarvelCharacters>(context).characters[index].name,
                "kirbyrulez$index",
              ),
            ));
          },
        );
      },
    );
  }
}
