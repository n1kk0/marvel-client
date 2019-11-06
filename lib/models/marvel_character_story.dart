class MarvelCharacterStory {
  int id;
  String title;
  String thumbnail;
  String description;

  MarvelCharacterStory({this.id, this.title, this.thumbnail, this.description});

  factory MarvelCharacterStory.fromJson(Map<String, dynamic> json) {
    return MarvelCharacterStory(
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
