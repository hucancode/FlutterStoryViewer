class Prefecture
{
  int id;
  String? title;
  Prefecture({required this.id, this.title})
  {
    print("prefecture $id $title");
  }

  factory Prefecture.fromJson(Map<String, dynamic> json) => Prefecture(
      id: json["id"],
      title: json["title"],
  );

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["title"] = title;
    return ret;
  }
}