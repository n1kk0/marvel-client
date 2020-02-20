import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/data/providers/marvel_characters.dart';
import 'package:marvel_client/data/models/marvel_character.dart';
import 'package:marvel_client/ui/screens/marvel_hero_screen.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class OneColView extends StatelessWidget {
  final ScrollController _scrollController;
  final String _apiBaseUrl;
  final Client _client;
  final Function _keydownEventListener;
  final bool kIsWeb; 

  OneColView(this._scrollController, this._apiBaseUrl, this._client, this._keydownEventListener, this.kIsWeb);

  @override
  Widget build(BuildContext context) {
    int index = 0;

    return ListView(
      controller: _scrollController,
      children: Provider.of<MarvelCharacters>(context).items.map((MarvelCharacter marvelCharacter) {
        index++;

        return AutoScrollTag(
          key: ValueKey(index - 1),
          controller: _scrollController,
          index: index - 1,
          child: ListTile(
            contentPadding: EdgeInsets.all(5),
            leading: Hero(
              tag: "kirbyrulez${marvelCharacter.hashCode}",
              child: marvelCharacter.loaded ? Container(
                child: CircleAvatar(
                  backgroundImage: Image.network("$_apiBaseUrl/images?uri=${marvelCharacter.thumbnail}").image,
                  backgroundColor: Colors.transparent,
                ),
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Provider.of<MarvelCharacters>(context).currentTabulationId + 1 == index ? Colors.red : Colors.transparent,
                  shape: BoxShape.circle,
                )
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

              if (kIsWeb) {
                uh.window.removeEventListener('keydown', _keydownEventListener);
              }

              await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MarvelHeroScreen(_apiBaseUrl, PageController(initialPage: characters.currentHeroId), _client, _keydownEventListener),
              ));
            },
          ),
        );
      }).toList(),
    );
  }
}
