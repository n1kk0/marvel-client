import 'package:flutter/material.dart';
import 'package:marvel_client/tools/app_config.dart';

class MarvelHeroScreen extends StatelessWidget {
  final String _thumbnail;
  final String _name;
  final String _tag;

  MarvelHeroScreen(this._thumbnail, this._name, this._tag, {Key key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: _tag,
                child: CircleAvatar(
                  radius: screenWidth(context, dividedBy: 2.3) > screenHeightExcludingToolbar(context, dividedBy: 2.3) ? screenHeightExcludingToolbar(context, dividedBy: 2.3) : screenWidth(context, dividedBy: 2.3),
                  backgroundImage: Image.network("${AppConfig.of(context).apiBaseUrl}/images?uri=$_thumbnail").image,
                  backgroundColor: Colors.transparent,
                )
              ),
              Text(_name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )
    );
  }
}
