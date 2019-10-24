import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:marvel_client/tools/app_consts.dart';
import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_character.dart';

class MarvelHeroScreen extends StatelessWidget {
  final String _apiBaseUrl;
  final String _tag;

  MarvelHeroScreen(this._apiBaseUrl, this._tag, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MarvelCharacters characters = Provider.of<MarvelCharacters>(context);

    return Scaffold(
      body: Swiper(
        loop: false,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: _tag,
                  child: characters.items[index].loaded ? CircleAvatar(
                    radius: screenWidth(context, dividedBy: 2.3) > screenHeightExcludingToolbar(context, dividedBy: 2.3) ? screenHeightExcludingToolbar(context, dividedBy: 2.3) : screenWidth(context, dividedBy: 2.3),
                    backgroundImage: Image.network("$_apiBaseUrl/images?uri=${characters.items[index].thumbnail}").image,
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
          );
        },
        itemCount: characters.marvelCharactersQuantity,
        onTap: (_) => Navigator.of(context).pop(),
        index: characters.currentHeroId,
        control: MyControl(context, _apiBaseUrl),
        pagination: MyPagination(),
      ),
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
}

class MyPagination extends SwiperPlugin {
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return Align(
      alignment: config.scrollDirection == Axis.horizontal ? Alignment.bottomCenter : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: FractionPaginationBuilder(color: Colors.black45).build(context, config),
      ),
    );
  }
}

class MyControl extends SwiperPlugin {
  final String _apiBaseUrl;
  final BuildContext _thisContext;

  MyControl(this._thisContext, this._apiBaseUrl);

  Widget buildButton(SwiperPluginConfig config, Color color, IconData iconData, int quarterTurns, bool previous) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final MarvelCharacters characters = Provider.of<MarvelCharacters>(_thisContext);

        if (previous) {
          characters.currentHeroId--;
          config.controller.previous(animation: true);
        } else {
          characters.currentHeroId++;

          final int lastItemLoaded = characters.items.length - 1;

          if (characters.currentHeroId == lastItemLoaded) {
            characters.loadPage(loadingIndicationOn, loadingIndicationOff, imagePreloader);
            config.controller.move(characters.currentHeroId);
          } else {
            config.controller.next(animation: true);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: Icon(
            iconData,
            semanticLabel: previous ? "Previous" : "Next",
            size: 30.0,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    ThemeData themeData = Theme.of(context);
    Color color = themeData.primaryColor;
    Color disableColor = themeData.disabledColor;
    Color prevColor;
    Color nextColor;

    if (config.loop) {
      prevColor = nextColor = color;
    } else {
      bool next = config.activeIndex < config.itemCount - 1;
      bool prev = config.activeIndex > 0;
      prevColor = prev ? color : disableColor;
      nextColor = next ? color : disableColor;
    }

    Widget child;

    if (config.scrollDirection == Axis.horizontal) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config, prevColor, Icons.arrow_back_ios, 0, true),
          buildButton(config, nextColor, Icons.arrow_forward_ios, 0, false)
        ],
      );
    } else {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config, prevColor, Icons.arrow_back_ios, -3, true),
          buildButton(config, nextColor, Icons.arrow_forward_ios, -3, false)
        ],
      );
    }

    return Container(
      height: double.infinity,
      child: child,
      width: double.infinity,
    );
  }

  Future<Null> loadingIndicationOn() async {
    final MarvelCharacters marvelCharacters = Provider.of<MarvelCharacters>(_thisContext, listen: false);

    return await showDialog<Null>(
      context: _thisContext,
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

  Null loadingIndicationOff() {
    Navigator.of(_thisContext).pop();
  }

  Null imagePreloader(MarvelCharacter marvelCharacter) {
    final Image image = marvelCharacter.getImage("$_apiBaseUrl/images?uri=");

    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((_, __) {
        marvelCharacter.loaded = true;
    }));
  }
}
