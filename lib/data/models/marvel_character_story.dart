class MarvelCharacterStory {
  int id;
  String title;
  String thumbnail;
  String description;
  String detailUri;

  MarvelCharacterStory({this.id, this.title, this.thumbnail, this.description, this.detailUri});

  factory MarvelCharacterStory.fromJson(Map<String, dynamic> json) {
    return MarvelCharacterStory(
      id: int.parse(json["id"].toString()),
      title: json["title"],
      thumbnail: json["thumbnail"],
      description: json["description"],
      detailUri: json["detailUri"],
    );
  }

  @override
  String toString() {
    return "id:$id title:$title thumbnail:$thumbnail description:$description detailUri:$detailUri";
  }
}
