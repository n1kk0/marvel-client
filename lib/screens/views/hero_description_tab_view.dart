import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/data/models/marvel_character.dart';

class HeroDescriptionTabView extends StatelessWidget {
  final MarvelCharacter character;
  final Size screenSize;
  final bool kIsWeb;
  const HeroDescriptionTabView(this.character, this.screenSize, this.kIsWeb);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(5)),
        Text(character.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Text("Description", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            character.description == "" ? "No description available" : character.description,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _marvelLinkButton("Detail", character.detailUri, context),
            Padding(padding: EdgeInsets.all(2)),
            _marvelLinkButton("Wiki", character.wikiUri, context),
            Padding(padding: EdgeInsets.all(2)),
            _marvelLinkButton("Comics", character.comicsUri, context),
          ],
        ),
      ],
    );
  }

  Widget _marvelLinkButton(String label, String url, BuildContext context) {
    return url != null ? RaisedButton(
      color: Colors.red,
      child: Row(
        children: <Widget>[
          Text(label, style: TextStyle(color: Theme.of(context).primaryTextTheme.bodyText2.color, fontSize: 16, fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(5)),
          Icon(Icons.open_in_new, color: Theme.of(context).primaryTextTheme.bodyText2.color, size: 16),
        ],
      ),
      onPressed: () async {
        if (kIsWeb) {
          uh.window.open(url, 'marvel');
        } else {
          await launch(url);
        }
      },
    ) : Offstage();
  }
}