import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/data/providers/marvel_characters.dart';
import 'package:marvel_client/data/models/marvel_character.dart';
import 'package:marvel_client/ui/screens/marvel_hero_screen.dart';

class MultiColsView extends StatelessWidget {
  final ScrollController _scrollController;
  final String _apiBaseUrl;
  final int _cols;
  final Client _client;
  final Function _keydownEventListener;
  final bool kIsWeb; 

  MultiColsView(this._scrollController, this._cols, this._apiBaseUrl, this._client, this._keydownEventListener, this.kIsWeb);

  @override
  Widget build(BuildContext context) {
    int index = 0;

    return GridView.count(
      controller: _scrollController,
      crossAxisCount: _cols,
      padding: EdgeInsets.all(36.0),
      mainAxisSpacing: 36.0,
      crossAxisSpacing: 36.0,
      children: Provider.of<MarvelCharacters>(context).items.map((MarvelCharacter marvelCharacter) {
        index++;

        return AutoScrollTag(
          key: ValueKey(index - 1),
          controller: _scrollController,
          index: index - 1,
          child: GestureDetector(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.width / (_cols + 2),
                maxWidth: MediaQuery.of(context).size.width / (_cols + 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "kirbyrulez${marvelCharacter.hashCode}",
                    child: marvelCharacter.loaded ? Container(
                      child: CircleAvatar(
                        backgroundImage: Image.network("$_apiBaseUrl/images?uri=${marvelCharacter.thumbnail}").image,
                        backgroundColor: Colors.transparent,
                        radius: MediaQuery.of(context).size.width / ((_cols + 2) * 2) - 2,
                      ),
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Provider.of<MarvelCharacters>(context).currentTabulationId + 1 == index ? Colors.red : Colors.transparent,
                        shape: BoxShape.circle,
                      )
                    ) : Center(child: Container(
                      height: MediaQuery.of(context).size.width / (_cols + 2) - 4,
                      width: MediaQuery.of(context).size.width / (_cols + 2) - 4,
                      child: CircularProgressIndicator()
                    ))
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        marvelCharacter.name,
                        overflow: TextOverflow.ellipsis,
                        style:TextStyle(fontSize: MediaQuery.of(context).size.width / ((_cols + 2) * 10), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
