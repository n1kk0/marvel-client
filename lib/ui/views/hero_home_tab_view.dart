import 'package:flutter/material.dart';

import 'package:marvel_client/data/models/marvel_character.dart';

class HeroHomeTabView extends StatelessWidget {
  final MarvelCharacter character;
  final Size screenSize;
  final String apiBaseUrl;
  const HeroHomeTabView(this.character, this.screenSize, this.apiBaseUrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(padding: EdgeInsets.all(5)),
        Text(character.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Text("Home", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.all(5)),
        Hero(
          tag: "kirbyrulez${character.hashCode}",
          child: character.loaded ? CircleAvatar(
            radius: screenSize.width > screenSize.height - kToolbarHeight * 2 ? (screenSize.height - kToolbarHeight * 2) / 2.5 : screenSize.width / 2.5,
            backgroundImage: Image.network("$apiBaseUrl/images?uri=${character.thumbnail}").image,
            backgroundColor: Colors.transparent,
          ) :
          Container(
            height: screenSize.width > screenSize.height - kToolbarHeight * 2 ? screenSize.height - kToolbarHeight * 2 : screenSize.width,
            width: screenSize.width > screenSize.height - kToolbarHeight * 2 ? screenSize.height - kToolbarHeight * 2 : screenSize.width,
            child: CircularProgressIndicator(strokeWidth: 16),
          ),
        ),
      ],
    );
  }
}