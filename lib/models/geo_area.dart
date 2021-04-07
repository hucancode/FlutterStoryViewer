class GeoArea {
  int id;
  double latitude;
  double longitude;
  double radius;
  
  GeoArea({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
  })
  {
    print("new GeoArea $id - $radius");
  }

  factory GeoArea.fromJson(Map<String, dynamic> json) => GeoArea(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        radius: json["radius"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "radius": radius,
    };
}