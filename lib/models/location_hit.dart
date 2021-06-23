import 'package:intl/intl.dart';

class LocationHit
{
  DateTime hitDay = DateTime.now();
  DateTime leaveDay = DateTime.now();
  double latitude;
  double longitude;
  String country = "";
  String area = "";
  String locality = "";
  String route = "";
  String street = "";
  String postalCode = "";

  LocationHit({required this.latitude, required this.longitude});
  factory LocationHit.fromJson(Map<String, dynamic> json) {
    final dateFormatter = DateFormat.yMd().add_Hm();
    final ret = LocationHit(
      latitude: json["latitude"],
      longitude: json["longitude"],
    );
    ret.hitDay = dateFormatter.parse(json["hitDay"]);
    ret.leaveDay = dateFormatter.parse(json["leaveDay"]);
    ret.country = json["country"];
    ret.area = json["area"];
    ret.locality = json["locality"];
    ret.route = json["route"];
    ret.street = json["street"];
    ret.postalCode = json["postalCode"];
    return ret;
  }

  @override
  bool operator == (dynamic o) =>
      o is LocationHit &&
      o.country == country &&
      o.area == area &&
      o.locality == locality &&
      o.postalCode == postalCode &&
      o.route == route &&
      o.street == street;
  
  @override
  int get hashCode =>
      country.hashCode ^
      area.hashCode ^
      locality.hashCode ^
      route.hashCode ^
      street.hashCode ^
      postalCode.hashCode;
      
  @override
  String toString() {
    return '$country - $area - $locality - $route - $street ($postalCode)';
  }
  
  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    final dateFormatter = DateFormat.yMd().add_Hm();
    ret["hitDay"] = dateFormatter.format(hitDay);
    ret["leaveDay"] = dateFormatter.format(leaveDay);
    ret["latitude"] = latitude;
    ret["longitude"] = longitude;
    ret["country"] = country;
    ret["area"] = area;
    ret["locality"] = locality;
    ret["route"] = route;
    ret["street"] = street;
    ret["postalCode"] = postalCode;
    return ret;
  }
}