import 'package:chat/chat.dart';

class LocalMessage {
  LocalMessage({
    required this.chatId,
    required this.message,
    required this.receipt,
  });

  factory LocalMessage.fromJson(Map<String, dynamic> json) {
    final message = Message(
      from: json['from'] as String,
      to: json['to'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as DateTime,
    );
    final localMessage = LocalMessage(
      chatId: json['chatId'] as String,
      message: message,
      receipt: EnumParsing.fromString(json['receipt'] as String),
    );
    localMessage._id = json['id'] as String;
    return localMessage;
  }

  final String chatId;
  late String? _id;
  String? get id => _id;
  final Message message;
  final ReceiptStatus receipt;

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'id': message.id,
        ...message.toJson(),
        'receipt': receipt.value(),
      };
}
