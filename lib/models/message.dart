class Message {
  int id;
  String? icon;
  String? title;
  DateTime? date;
  String? content;
  bool isFavorite;
  bool isSelected;
  
  Message({
    required this.id,
    this.icon,
    this.title,
    this.date,
    this.content,
    this.isFavorite = false,
    this.isSelected = false
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
  factory Message.empty() => Message(
        id: -1,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "thumbnail": icon,
        "title": title,
        "createdAt": date,
        "content": content,
    };
}