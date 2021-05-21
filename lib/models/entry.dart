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
    required this.id,
    this.thumbnail,
    this.title,
    this.createdDate,
    this.modifiedDate,
    this.content,
    this.filterID,
    required this.authorID,
    this.isSelected = false,
    this.isFavorite = false,
  });
  factory Entry.empty()
  {
    return Entry(id: -1, authorID: -1);
  }
  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
      id: json["id"],
      thumbnail: json["thumbnail"],
      title: json["title"],
      createdDate: DateTime.parse(json["createdAt"]),
      modifiedDate: DateTime.parse(json["modifiedAt"]),
      content: json["content"],
      filterID: json["filterID"],
      authorID: 1,
  );

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["title"] = title;
    ret["thumbnail"] = thumbnail;
    ret["createdDate"] = createdDate;
    ret["modifiedDate"] = modifiedDate;
    ret["content"] = content;
    ret["filterID"] = filterID;
    ret["authorID"] = authorID;
    ret["isFavorite"] = isFavorite;
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