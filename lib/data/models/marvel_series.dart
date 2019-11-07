class MarvelSeries {
  final int id;
  final String title;
  final String thumbnail;

  MarvelSeries({this.id, this.title, this.thumbnail});

  factory MarvelSeries.fromJson(Map<String, dynamic> json) {
    return MarvelSeries(
      id: int.parse(json["id"].toString()),
      title: json["title"],
      thumbnail: json["thumbnail"],
    );
  }

  @override
  String toString() {
    return "id:$id title:$title thumbnail:$thumbnail";
  }
}