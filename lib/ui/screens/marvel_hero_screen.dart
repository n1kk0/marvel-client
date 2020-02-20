import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as uh;

import 'package:marvel_client/data/providers/marvel_characters.dart';
import 'package:marvel_client/ui/views/hero_home_tab_view.dart';
import 'package:marvel_client/ui/views/hero_description_tab_view.dart';
import 'package:marvel_client/ui/views/hero_list_tab_view.dart';

class MarvelHeroScreen extends StatefulWidget {
  final String _apiBaseUrl;
  final PageController _pageController;
  final Client _client;
  final Function _keydownParentEventListener;

  MarvelHeroScreen(this._apiBaseUrl, this._pageController, this._client, this._keydownParentEventListener);

  @override
  _MarvelHeroScreenState createState() => _MarvelHeroScreenState();
}

class _MarvelHeroScreenState extends State<MarvelHeroScreen> with TickerProviderStateMixin {
  bool _popped = false;
  MarvelCharacters _characters;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 6, vsync: this); 

    if (kIsWeb) {
      uh.window.addEventListener('keydown', _keydownEventListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_characters == null) _characters = Provider.of<MarvelCharacters>(context);

    return Scaffold(
      bottomNavigationBar: Consumer<MarvelCharacters>(
        builder: (BuildContext context, MarvelCharacters marvelCharacters, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                color: Colors.red,
                onPressed: () {
                  if (widget._pageController.page > 0) {
                    widget._pageController.previousPage(
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
                  if (widget._pageController.page < _characters.marvelCharactersQuantity) {
                    widget._pageController.nextPage(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PageView.builder(
        controller: widget._pageController,
        itemCount: _characters.marvelCharactersQuantity,
        onPageChanged: (int index) async {
          final MarvelCharacters characters = Provider.of<MarvelCharacters>(context, listen: false);

          characters.currentHeroId = index;

          if (characters.currentHeroId + 2 >= characters.items.length) {
            await characters.loadPage(context);
          }
        },
        itemBuilder: (BuildContext context, int index) {
          final Size screenSize = MediaQuery.of(context).size;

          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Container(
                    child: SafeArea(
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.red,
                        labelColor: Colors.red,
                        unselectedLabelColor: Colors.redAccent,
                        tabs: [
                          Tab(child: Icon(Icons.home)),
                          Tab(child: Icon(Icons.description)),
                          Tab(child: Icon(Icons.book)),
                          Tab(child: Icon(Icons.event)),
                          Tab(child: Icon(Icons.list)),
                          Tab(child: Icon(Icons.wallpaper)),
                        ],
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    HeroHomeTabView(_characters.items[index], screenSize, widget._apiBaseUrl),
                    HeroDescriptionTabView(_characters.items[index], screenSize, kIsWeb),
                    new HeroListTabView("comics", _characters.items[index], screenSize, widget._apiBaseUrl, widget._client, kIsWeb),
                    new HeroListTabView("events", _characters.items[index], screenSize, widget._apiBaseUrl, widget._client, kIsWeb),
                    new HeroListTabView("series", _characters.items[index], screenSize, widget._apiBaseUrl, widget._client, kIsWeb),
                    new HeroListTabView("stories", _characters.items[index], screenSize, widget._apiBaseUrl, widget._client, kIsWeb),
                  ],
                ),
              ),
              Positioned(
                right: 10.0,
                top: 50.0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ]
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();

    if (kIsWeb) {
      uh.window.removeEventListener('keydown', _keydownEventListener);
      uh.window.addEventListener('keydown', widget._keydownParentEventListener);
    }
  }

  void _keydownEventListener(dynamic event) {
    if (event is uh.KeyboardEvent) {
      if (widget._pageController.hasClients && (event.code == 'ArrowRight' || (event.code == 'Tab' && event.shiftKey == false))) {
        if (widget._pageController.page < _characters.marvelCharactersQuantity && !_characters.isLoading) {
          widget._pageController.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );

          event.preventDefault();
        }
      } else if (widget._pageController.hasClients && (event.code == 'ArrowLeft' || (event.code == 'Tab' && event.shiftKey == true))) {
        if (widget._pageController.page > 0) {
          widget._pageController.previousPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );

          event.preventDefault();
        }
      } else if (event.code == 'Escape' && !_popped) {
        _popped = true;
        Navigator.of(context).pop();
        event.preventDefault();
      } else if (event.code == "Digit1") {
        _tabController.animateTo(0);
        event.preventDefault();
      } else if (event.code == "Digit2") {
        _tabController.animateTo(1);
        event.preventDefault();
      } else if (event.code == "Digit3") {
        _tabController.animateTo(2);
        event.preventDefault();
      } else if (event.code == "Digit4") {
        _tabController.animateTo(3);
        event.preventDefault();
      } else if (event.code == "Digit5") {
        _tabController.animateTo(4);
        event.preventDefault();
      } else if (event.code == "Digit6") {
        _tabController.animateTo(5);
        event.preventDefault();
      }
    }
  }
}
