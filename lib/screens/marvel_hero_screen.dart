import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/tools/app_consts.dart';
import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_character.dart';
import 'package:marvel_client/widgets/marvel_botton_bar.dart';

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
        onPageChanged: (int index) async {
          final MarvelCharacters characters = Provider.of<MarvelCharacters>(context, listen: false);

          characters.currentHeroId = index;

          if (characters.currentHeroId + 2 >= characters.items.length) {
            await characters.loadPage(_loadingIndicationOn, _loadingIndicationOff, _imagePreloader);
          }
        },
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "kirbyrulez${characters.items[index].hashCode}",
                    child: characters.items[index].loaded ? CircleAvatar(
                      radius: screenWidth(context, dividedBy: 2.3) > screenHeightExcludingToolbar(context, dividedBy: 2.3) ? screenHeightExcludingToolbar(context, dividedBy: 2.3) : screenWidth(context, dividedBy: 2.3),
                      backgroundImage: Image.network("${widget._apiBaseUrl}/images?uri=${characters.items[index].thumbnail}").image,
                      backgroundColor: Colors.transparent,
                    ) :
                    Container(
                      height: screenWidth(context) > screenHeightExcludingToolbar(context) ? screenHeightExcludingToolbar(context) : screenWidth(context),
                      width: screenWidth(context) > screenHeightExcludingToolbar(context) ? screenHeightExcludingToolbar(context) : screenWidth(context),
                      child: CircularProgressIndicator(strokeWidth: 16),
                    ),
                  ),
                  Text(characters.items[index].name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
        itemCount: characters.marvelCharactersQuantity,
      ),
      bottomNavigationBar: MarvelBottomAppBar(characters.items[characters.currentHeroId].resourceUri),
    );
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context, {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).height - reducedBy) / dividedBy;
  }

  double screenWidth(BuildContext context, {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).width - reducedBy) / dividedBy;
  }

  double screenHeightExcludingToolbar(BuildContext context, {double dividedBy = 1}) {
    return screenHeight(context, dividedBy: dividedBy, reducedBy: kToolbarHeight);
  }

  Future<Null> _loadingIndicationOn() async {
    final MarvelCharacters marvelCharacters = Provider.of<MarvelCharacters>(context, listen: false);

    return await showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text("Loading", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    "Page ${marvelCharacters.lastPageLoaded + 1} of ${(marvelCharacters.marvelCharactersQuantity / AppConsts.itemsPerPage).ceil()}",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "(Characters ${marvelCharacters.lastPageLoaded * AppConsts.itemsPerPage} to ${(marvelCharacters.lastPageLoaded + 1) * AppConsts.itemsPerPage < marvelCharacters.marvelCharactersQuantity ? (marvelCharacters.lastPageLoaded + 1) * AppConsts.itemsPerPage : marvelCharacters.marvelCharactersQuantity} on ${marvelCharacters.marvelCharactersQuantity})",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            )
          ],
        );
      }
    );
  }

  Null _loadingIndicationOff() {
    Navigator.of(context).pop();
  }

  Null _imagePreloader(MarvelCharacter marvelCharacter) {
    final Image image = marvelCharacter.getImage("${widget._apiBaseUrl}/images?uri=");

    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((_, __) {
        marvelCharacter.loaded = true;
    }));
  }
}
