class MarvelCharacterComic {
  int id;
  String title;
  String thumbnail;
  String description;

  MarvelCharacterComic({this.id, this.title, this.thumbnail, this.description});

  factory MarvelCharacterComic.fromJson(Map<String, dynamic> json) {
    return MarvelCharacterComic(
      id: int.parse(json["id"].toString()),
      title: json["title"],
      thumbnail: json["thumbnail"],
      description: json["description"],
    );
  }

  @override
  String toString() {
    return "id:$id title:$title thumbnail:$thumbnail description:$description";
  }
}
