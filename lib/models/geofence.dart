class Geofence
{
  int id;
  String? title;
  DateTime? createdDate;
  DateTime? modifiedDate;
  double latitude;
  double longitude;
  double radius;
  bool isSelected;
  int authorID;

  Geofence({
    this.id = -1,
    this.title,
    this.createdDate,
    this.modifiedDate,
    this.latitude = 0,
    this.longitude = 0,
    this.radius = 0,
    this.authorID = -1,
    
    this.isSelected = false
  });
  factory Geofence.fromJson(Map<String, dynamic> json) => Geofence(
      id: json["id"],
      title: json["title"],
      createdDate: DateTime.parse(json["createdAt"]),
      modifiedDate: DateTime.parse(json["modifiedAt"]),
      latitude: json["latitude"],
      longitude: json["longitude"],
      radius: json["radius"],
      authorID: json["authorID"],
  );

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["title"] = title;
    ret["latitude"] = latitude;
    ret["longitude"] = longitude;
    ret["radius"] = radius;
    ret["authorID"] = authorID;
    return ret;
  }

  Map<String, dynamic> toShortJson()
  {
    Map<String, dynamic> ret = {};
    ret["title"] = title;
    ret["latitude"] = latitude;
    ret["longitude"] = longitude;
    ret["radius"] = radius;
    ret["authorID"] = authorID;
    return ret;
  }
}