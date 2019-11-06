class MarvelCharacterEvent {
  int id;
  String title;
  String thumbnail;
  String description;

  MarvelCharacterEvent({this.id, this.title, this.thumbnail, this.description});

  factory MarvelCharacterEvent.fromJson(Map<String, dynamic> json) {
    return MarvelCharacterEvent(
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
