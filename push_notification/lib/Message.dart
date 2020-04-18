
class Message{
  String title;
  String body;
  String level;
  String datetime;

  Message(title, body, level, datetime){
    this.title = title;
    this.body = body;
    this.level = level;
    this.datetime = datetime;
  }

  Message.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        body = json['body'],
        level = json['level'],
        datetime = json['datetime'];


  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'level': level,
        'datetime': datetime,
      };
}