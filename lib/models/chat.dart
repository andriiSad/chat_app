import 'local_message.dart';

class Chat {
  Chat({
    required this.id,
    this.mostRecent,
    this.messages = const [],
  });

  factory Chat.fromJson(Map<String, dynamic> json) =>
      Chat(id: json['id'] as String);

  final String id;
  int unread = 0;
  List<LocalMessage> messages;
  LocalMessage? mostRecent;

  Map<String, dynamic> toJson() => {'id': id};
}
