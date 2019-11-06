import 'package:flutter/material.dart';

import 'package:marvel_client/models/marvel_character.dart';

class HeroHomeTabView extends StatelessWidget {
  final MarvelCharacter character;
  final Size screenSize;
  final String apiBaseUrl;
  const HeroHomeTabView(this.character, this.screenSize, this.apiBaseUrl);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
          Text(character.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}