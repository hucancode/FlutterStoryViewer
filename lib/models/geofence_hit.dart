import 'package:intl/intl.dart';
import 'package:pop_experiment/models/geofence_hit_filter.dart';

class GeofenceHit
{
  DateTime hitDay = DateTime.now();
  DateTime leaveDay = DateTime.now();
  int geofenceID;
  GeofenceHit({required this.geofenceID});
  factory GeofenceHit.fromJson(Map<String, dynamic> json) {
    final dateFormatter = DateFormat.yMd().add_Hm();
    final ret = GeofenceHit(
      geofenceID: json["geofenceID"],
    );
    ret.hitDay = dateFormatter.parse(json["hitDay"]);
    ret.leaveDay = dateFormatter.parse(json["leaveDay"]);
    return ret;
  }
    @override
  bool operator == (dynamic o) =>
      o is GeofenceHit &&
      o.geofenceID == geofenceID;
  
  @override
  int get hashCode =>
      geofenceID.hashCode;


  int get stayTimeInMinute
  {
    return leaveDay.difference(hitDay).inMinutes;
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    final dateFormatter = DateFormat.yMd().add_Hm();
    ret["hitDay"] = dateFormatter.format(hitDay);
    ret["leaveDay"] = dateFormatter.format(leaveDay);
    ret["geofenceID"] = geofenceID;
    return ret;
  }

  bool match(GeofenceHitFilter filter)
  {
    if(geofenceID != filter.geofenceID) {
      return false;
    }
    final now = DateTime.now();
    if(now.difference(hitDay).inDays > filter.numDayToQuery) {
      return false;
    }
    final afterMin = hitDay.hour >= filter.hitTimeMin.hour && hitDay.minute <= filter.hitTimeMin.minute;
    final beforeMax = hitDay.hour <= filter.hitTimeMax.hour && hitDay.minute <= filter.hitTimeMax.minute;
    final inRange = filter.isTwoDaySpan?(afterMin || beforeMax):(afterMin && beforeMax);
    if(!inRange)
    {
      return false;
    }
    return true;
  }
}