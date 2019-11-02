import 'package:flutter/material.dart';

class MarvelCharacter {
  final String name;
  final String thumbnail;
  final String resourceUri;
  Image image;
  bool loaded = false;

  MarvelCharacter({this.name, this.thumbnail, this.resourceUri});

  factory MarvelCharacter.fromJson(Map<String, dynamic> json) {
    return MarvelCharacter(
      name: json["name"],
      thumbnail: json["thumbnail"],
      resourceUri: json["resourceUri"],
    );
  }

  Image getImage(String urlPrefix) {
    return Image.network("$urlPrefix$thumbnail");
  }

  @override
  String toString() {
    return "name:$name thumbnail:$thumbnail resourceUri:$resourceUri";
  }
}
