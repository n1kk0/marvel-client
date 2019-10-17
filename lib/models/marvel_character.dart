class MarvelCharacter {
  String name;
  String thumbnail;

  MarvelCharacter({this.name, this.thumbnail});

  factory MarvelCharacter.fromJson(Map<String, dynamic> json) {
    return MarvelCharacter(
      name: json["name"],
      thumbnail: json["thumbnail"],
    );
  }

  @override
  String toString() {
    return "name:$name thumbnail:$thumbnail";
  }
}
