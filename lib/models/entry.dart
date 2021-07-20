class Entry
{
  int id;
  String? thumbnail;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? title;
  String? content;
  int? filterID;
  int authorID;
  bool isSelected;
  bool isFavorite;

  Entry({
    this.id = -1,
    this.thumbnail,
    this.title,
    this.createdDate,
    this.modifiedDate,
    this.content,
    this.filterID,
    this.authorID = -1,
    this.isSelected = false,
    this.isFavorite = false,
  });
  
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json["id"],
      thumbnail: json["thumbnail"],
      title: json["title"],
      createdDate: DateTime.parse(json["createdAt"]),
      modifiedDate: DateTime.parse(json["modifiedAt"]),
      content: json["content"],
      filterID: json["filterID"],
      authorID: 1,
    );
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["title"] = title;
    ret["thumbnail"] = thumbnail;
    ret["content"] = content;
    ret["filterID"] = filterID;
    ret["authorID"] = authorID;
    return ret;
  }

  Map<String, dynamic> toShortJson()
  {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["title"] = title;
    ret["thumbnail"] = thumbnail;
    ret["content"] = content;
    ret["filterID"] = filterID;
    return ret;
  }
}