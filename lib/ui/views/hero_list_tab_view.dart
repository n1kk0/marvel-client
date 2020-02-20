import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:url_launcher/url_launcher.dart';

import 'package:marvel_client/data/models/marvel_character.dart';
import 'package:marvel_client/data/models/marvel_character_item.dart';
import 'package:marvel_client/data/sources/marvel_api.dart';

class HeroListTabView extends StatefulWidget {
  final String type; 
  final MarvelCharacter character;
  final Size screenSize;
  final String baseUrl;
  final Client client;
  final bool kIsWeb;

  HeroListTabView(this.type, this.character, this.screenSize, this.baseUrl, this.client, this.kIsWeb);

  @override
  _HeroListTabViewState createState() => _HeroListTabViewState();
}

class _HeroListTabViewState extends State<HeroListTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.kIsWeb) {
      uh.window.addEventListener('keydown', _keydownEventListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(5)),
        Text(widget.character.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Text("${widget.type[0].toUpperCase()}${widget.type.substring(1)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Container(
          height: MediaQuery.of(context).size.height - 185,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
            future: ApiService(widget.baseUrl, widget.client).getMarvelCharacterItems(widget.type, widget.character.id),
            builder: (BuildContext context, AsyncSnapshot<List<MarvelCharacterItem>> snapshot) {
              return snapshot.connectionState == ConnectionState.done ?
                snapshot.hasData ?
                  ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(10),
                    children: snapshot.data.map((MarvelCharacterItem item) {
                      return ListTile(
                        isThreeLine: true,
                        contentPadding: EdgeInsets.all(10),
                        leading: item.thumbnail != null ? Image.network("${widget.baseUrl}/images?uri=${item.thumbnail}") : Offstage(),
                        title: Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.description != "null" ? item.description : "", style: TextStyle(fontSize: 15)),
                        trailing: item.detailUri == null ? Offstage() : IconButton(
                          icon: Icon(Icons.open_in_new),
                          onPressed: () async {
                            if (widget.kIsWeb) {
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

  @override
  void dispose() {
    if (widget.kIsWeb) {
      uh.window.removeEventListener('keydown', _keydownEventListener);
    }

    super.dispose();
  }

  void _keydownEventListener(dynamic event) {
    if (event is uh.KeyboardEvent) {
      switch (event.code) {
        case 'ArrowDown':
          _scrollController.animateTo(
            _scrollController.offset + _scrollController.position.viewportDimension,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );

          event.preventDefault();
          break;
        case 'ArrowUp':
          _scrollController.animateTo(
            _scrollController.offset < _scrollController.position.viewportDimension ? 0 : _scrollController.offset - _scrollController.position.viewportDimension,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );

          event.preventDefault();
          break;
      }
    }
  }
}
