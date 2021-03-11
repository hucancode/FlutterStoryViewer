class Message {
  int id;
  String icon;
  String title;
  DateTime date;
  String content;
  
  Message({
    this.id,
    this.icon,
    this.title,
    this.date,
    this.content
  })
  {
    print("new Message "+id.toString()+ " "+title);
  }

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        icon: json["icon"],
        title: json["title"],
        date: DateTime.parse(json["date"]),
        content: json["content"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon,
        "title": title,
        "date": date,
        "content": content,
    };
}