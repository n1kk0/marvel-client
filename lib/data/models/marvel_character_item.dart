class MarvelCharacterItem {
  int id;
  String title;
  String thumbnail;
  String description;
  String detailUri;

  MarvelCharacterItem({this.id, this.title, this.thumbnail, this.description, this.detailUri});

  factory MarvelCharacterItem.fromJson(Map<String, dynamic> json) {
    return MarvelCharacterItem(
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
