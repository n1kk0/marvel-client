class MarvelCharacterSeries {
  int id;
  String title;
  String thumbnail;
  String description;

  MarvelCharacterSeries({this.id, this.title, this.thumbnail, this.description});

  factory MarvelCharacterSeries.fromJson(Map<String, dynamic> json) {
    return MarvelCharacterSeries(
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
