enum DiscoveryEvent
{
  beacon, 
  geofence
}

class DiscoveryEntry {
  DiscoveryEvent event;
  String id;
  DateTime date;

  DiscoveryEntry({
    required this.event,
    required this.id,
    required this.date
  });

  factory DiscoveryEntry.fromJson(Map<String, dynamic> json) => DiscoveryEntry(
        event: json["event"],
        id: json["id"],
        date: DateTime.parse(json["date"]),
    );
}