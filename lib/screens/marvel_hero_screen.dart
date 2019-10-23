import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:marvel_client/providers/marvel_characters.dart';

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
        itemBuilder: (BuildContext context,int index){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: widget._tag,
                  child: CircleAvatar(
                    radius: screenWidth(context, dividedBy: 2.3) > screenHeightExcludingToolbar(context, dividedBy: 2.3) ? screenHeightExcludingToolbar(context, dividedBy: 2.3) : screenWidth(context, dividedBy: 2.3),
                    backgroundImage: Image.network("${widget._apiBaseUrl}/images?uri=${characters.items[index].thumbnail}").image,
                    backgroundColor: Colors.transparent,
                  )
                ),
                Text(characters.items[index].name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
        itemCount: characters.lastPageLoaded * 15 < characters.marvelCharactersQuantity ?
          characters.lastPageLoaded * 15:
          characters.marvelCharactersQuantity
        ,
        onTap: (_) => Navigator.of(context).pop(),
        index: widget._index,
        controller: _controller,
        control: SwiperControl(),
//        pagination: SwiperPagination(builder: SwiperPagination.fraction),
        pagination: YourOwnPaginatipon(),
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

class YourOwnPaginatipon extends SwiperPlugin {
  final EdgeInsetsGeometry margin = const EdgeInsets.all(10.0);
  final SwiperPlugin builder = const FractionPaginationBuilder(color: Colors.black45);

  Widget build(BuildContext context, SwiperPluginConfig config) {
    final Alignment alignment = config.scrollDirection == Axis.horizontal ? Alignment.bottomCenter : Alignment.centerRight;

    Widget child = Container(
      margin: margin,
      child: this.builder.build(context, config),
    );

    if (!config.outer) {
      child = new Align(
        alignment: alignment,
        child: child,
      );
    }

    return child;
  }
}
