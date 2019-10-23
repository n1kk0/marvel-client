import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:marvel_client/providers/marvel_characters.dart';
import 'package:marvel_client/models/marvel_character.dart';

class MarvelHeroScreen extends StatefulWidget {
  final String _apiBaseUrl;
  final int _index;
  final String _tag;

  MarvelHeroScreen(this._apiBaseUrl, this._index, this._tag, {Key key}) : super(key: key);

  @override
  _MarvelHeroScreenState createState() => _MarvelHeroScreenState();
}

class _MarvelHeroScreenState extends State<MarvelHeroScreen> {
  SwiperController _controller = SwiperController();

  @override
  Widget build(BuildContext context) {
    final MarvelCharacters characters = Provider.of<MarvelCharacters>(context, listen: false);

    return Scaffold(
      body: Swiper(
        loop: false,
        itemBuilder: (BuildContext context,int index){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: widget._tag,
                  child: Provider.of<MarvelCharacters>(context).items[index].loaded ? CircleAvatar(
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
          );
        },
        itemCount: characters.marvelCharactersQuantity,
        onTap: (_) => Navigator.of(context).pop(),
        index: widget._index,
        controller: _controller,
        control: MyControl(Provider.of<MarvelCharacters>(context, listen: false), widget._apiBaseUrl),
        pagination: MyPaginatipon(),
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

class MyPaginatipon extends SwiperPlugin {
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
  final MarvelCharacters characters;
  final String _apiBaseUrl;

  MyControl(this.characters, this._apiBaseUrl);

  Widget buildButton(SwiperPluginConfig config, Color color, IconData iconData, int quarterTurns, bool previous) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (previous) {
          config.controller.previous(animation: true);
        } else {
          final int lastItemLoaded = characters.lastPageLoaded * 15 - 2;
          final int currentIndex = config.activeIndex;

          if (currentIndex == lastItemLoaded) {
            await characters.loadPage(() {}, () {}, _imagePreloader);
          }

          config.controller.next(animation: true);
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

  Null _imagePreloader(MarvelCharacter marvelCharacter) {
    final Image image = marvelCharacter.getImage("$_apiBaseUrl/images?uri=");

    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((_, __) {
        marvelCharacter.loaded = true;
    }));
  }
}
