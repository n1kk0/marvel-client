import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:url_launcher/url_launcher.dart';

import 'package:marvel_client/data/models/marvel_character.dart';
import 'package:marvel_client/data/models/marvel_character_comic.dart';
import 'package:marvel_client/data/sources/marvel_api.dart';

class HeroComicsTabView extends StatelessWidget {
  final MarvelCharacter character;
  final Size screenSize;
  final String baseUrl;
  final Client client;
  final bool kIsWeb;
  const HeroComicsTabView(this.character, this.screenSize, this.baseUrl, this.client, this.kIsWeb);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(5)),
        Text(character.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Container(
          height: MediaQuery.of(context).size.height - 150,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
            future: ApiService(baseUrl, client).getMarvelCharacterComics(character.id),
            builder: (BuildContext context, AsyncSnapshot<List<MarvelCharacterComic>> snapshot) {
              return snapshot.connectionState == ConnectionState.done ?
                snapshot.hasData ?
                  ListView(
                    padding: EdgeInsets.all(10),
                    children: snapshot.data.map((MarvelCharacterComic item) {
                      return ListTile(
                        isThreeLine: true,
                        contentPadding: EdgeInsets.all(10),
                        leading: item.thumbnail != null ? Image.network("$baseUrl/images?uri=${item.thumbnail}") : Offstage(),
                        title: Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.description != "null" ? item.description : "", style: TextStyle(fontSize: 15)),
                        trailing: item.detailUri == null ? Offstage() : IconButton(
                          icon: Icon(Icons.open_in_new),
                          onPressed: () async {
                            if (kIsWeb) {
                              uh.window.open(item.detailUri, 'marvel');
                            } else {
                              await launch(item.detailUri);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ) :
                  Center(child: Text("No data", style: TextStyle(fontSize: 16))) :
                Center(child: CircularProgressIndicator())
              ;
            },
          ),
        ),
      ],
    );
  }
}
