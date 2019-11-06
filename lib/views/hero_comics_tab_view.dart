import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:url_launcher/url_launcher.dart';

import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/models/marvel_character_comic.dart';
import 'package:marvel_client/tools/marvel_api.dart';

class HeroComicsTabView extends StatelessWidget {
  final MarvelCharacter character;
  final Size screenSize;
  final String baseUrl;
  final Client client;
  final bool kIsWeb;
  const HeroComicsTabView(this.character, this.screenSize, this.baseUrl, this.client, this.kIsWeb);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: screenSize.width > screenSize.height - kToolbarHeight * 4 ? screenSize.height - kToolbarHeight * 4 : screenSize.width,
        width: screenSize.width > screenSize.height - kToolbarHeight * 4 ? screenSize.height - kToolbarHeight * 4 : screenSize.width,
        child: FutureBuilder(
          future: ApiService(baseUrl, client).getMarvelCharacterComics(character.id),
          builder: (BuildContext context, AsyncSnapshot<List<MarvelCharacterComic>> snapshot) {
            return snapshot.connectionState == ConnectionState.done ?
              snapshot.hasData ?
                ListView(
                  children: snapshot.data.map((MarvelCharacterComic item) {
                    return ListTile(
                      leading: item.thumbnail != null ? Image.network("$baseUrl/images?uri=${item.thumbnail}") : Offstage(),
                      title: Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      subtitle: Text(item.description != "null" ? item.description : "", style: TextStyle(fontSize: 15)),
                      trailing: IconButton(
                        icon: Icon(Icons.open_in_new),
                        onPressed: item.detailUri == null ? null : () async {
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
    );
  }
}
