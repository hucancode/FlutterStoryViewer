import 'dart:core';


class Prefecture
{
  int id;
  String? title;
  Prefecture({
    this.id = -1,
    this.title,
  });

  factory Prefecture.fromJson(Map<String, dynamic> json)
  {
    return Prefecture(
        id: json["id"],
        title: json["title"],
    );
  }
}