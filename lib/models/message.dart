class Message {
  int id;
  String? icon;
  String? title;
  DateTime? date;
  String? content;
  
  Message({
    required this.id,
    this.icon,
    this.title,
    this.date,
    this.content
  })
  {
    //print("new Message $id - $title");
  }

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        icon: json["thumbnail"],
        title: json["title"],
        date: DateTime.parse(json["createdAt"]),
        content: json["content"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "thumbnail": icon,
        "title": title,
        "createdAt": date,
        "content": content,
    };
}