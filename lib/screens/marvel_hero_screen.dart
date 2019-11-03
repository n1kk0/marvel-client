import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/widgets/marvel_botton_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MarvelHeroScreen extends StatefulWidget {
  final String _apiBaseUrl;

  MarvelHeroScreen(this._apiBaseUrl, {Key key}) : super(key: key);

  @override
  _MarvelHeroScreenState createState() => _MarvelHeroScreenState();
}

class _MarvelHeroScreenState extends State<MarvelHeroScreen> {
  PageController _controller;
  bool _popped = false;

  @override
  Widget build(BuildContext context) {
    final MarvelCharacters characters = Provider.of<MarvelCharacters>(context);

    _controller = PageController(initialPage: characters.currentHeroId);

    if (kIsWeb) {
      _initKeyboardListener(characters);
    }

    return Scaffold(
      floatingActionButton: Consumer<MarvelCharacters>(
        builder: (BuildContext context, MarvelCharacters marvelCharacters, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                color: Colors.red,
                onPressed: () {
                  if (_controller.page > 0) {
                    _controller.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
              Text("${marvelCharacters.currentHeroId + 1} on ${marvelCharacters.marvelCharactersQuantity}"),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                color: Colors.red,
                onPressed: () {
                  if (_controller.page < characters.marvelCharactersQuantity) {
                    _controller.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: PageView.builder(
        controller: _controller,
        itemCount: characters.marvelCharactersQuantity,
        onPageChanged: (int index) async {
          final MarvelCharacters characters = Provider.of<MarvelCharacters>(context, listen: false);

          characters.currentHeroId = index;

          if (characters.currentHeroId + 2 >= characters.items.length) {
            await characters.loadPage(context);
          }
        },
        itemBuilder: (BuildContext context, int index) {
          final Size screenSize = MediaQuery.of(context).size;

          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "kirbyrulez${characters.items[index].hashCode}",
                    child: characters.items[index].loaded ? CircleAvatar(
                      radius: screenSize.width > screenSize.height - kToolbarHeight ? (screenSize.height - kToolbarHeight) / 2.5 : screenSize.width / 2.5,
                      backgroundImage: Image.network("${widget._apiBaseUrl}/images?uri=${characters.items[index].thumbnail}").image,
                      backgroundColor: Colors.transparent,
                    ) :
                    Container(
                      height: screenSize.width > screenSize.height - kToolbarHeight ? screenSize.height - kToolbarHeight : screenSize.width,
                      width: screenSize.width > screenSize.height - kToolbarHeight ? screenSize.height - kToolbarHeight : screenSize.width,
                      child: CircularProgressIndicator(strokeWidth: 16),
                    ),
                  ),
                  Text(characters.items[index].name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _marvelLinkButton("Detail", characters.items[index].detailUri),
                      Padding(padding: EdgeInsets.all(2)),
                      _marvelLinkButton("Wiki", characters.items[index].wikiUri),
                      Padding(padding: EdgeInsets.all(2)),
                      _marvelLinkButton("Comics", characters.items[index].comicsUri),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: MarvelBottomAppBar(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Null _initKeyboardListener(MarvelCharacters characters) {
    uh.document.addEventListener('keydown', (dynamic event) {
      if (event.code == 'ArrowRight') {
        if (_controller.page < characters.marvelCharactersQuantity && !characters.isLoading) {
          _controller.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );

          event.preventDefault();
        }
      } else if (event.code == 'ArrowLeft') {
        if (_controller.page > 0) {
          _controller.previousPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );

          event.preventDefault();
        }
      } else if (event.code == 'Escape' && !_popped) {
        _popped = true;
        Navigator.of(context).pop();
        event.preventDefault();
      }
    });
  }

  Widget _marvelLinkButton(String label, String url) {
    return url != null ? RaisedButton(
      color: Colors.red,
      child: Row(
        children: <Widget>[
          Text(label, style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color, fontSize: 16, fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(5)),
          Icon(Icons.open_in_new, color: Theme.of(context).primaryTextTheme.body1.color, size: 16),
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
