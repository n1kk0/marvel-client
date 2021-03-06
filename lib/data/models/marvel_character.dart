import 'package:flutter/material.dart';

class MarvelCharacter {
  final int id;
  final String name;
  final String thumbnail;
  final String detailUri;
  final String wikiUri;
  final String comicsUri;
  final String description;
  Image image;
  bool loaded = false;

  MarvelCharacter({this.id, this.name, this.thumbnail, this.detailUri, this.wikiUri, this.comicsUri, this.description});

  factory MarvelCharacter.fromJson(Map<String, dynamic> json) {
    return MarvelCharacter(
      id: int.parse(json["id"].toString()),
      name: json["name"],
      thumbnail: json["thumbnail"],
      detailUri: json["detailUri"],
      wikiUri: json["wikiUri"],
      comicsUri: json["comicsUri"],
      description: json["description"],
    );
  }

  Image getImage(String urlPrefix) {
    return Image.network("$urlPrefix$thumbnail");
  }

  @override
  String toString() {
    return "id:$id name:$name thumbnail:$thumbnail detailUri:$detailUri wikiUri:$wikiUri comicsUri:$comicsUri description:$description";
  }
}
