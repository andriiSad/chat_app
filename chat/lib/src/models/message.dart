class Message {
  Message({
    required this.from,
    required this.to,
    required this.timestamp,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
      from: json['from'] as String,
      to: json['to'] as String,
      timestamp: json['timestamp'] as DateTime,
      content: json['content'] as String,
    );
    message._id = json['id'] as String;
    return message;
  }

  String? get id => _id;
  final String from;
  final String to;
  final DateTime timestamp;
  final String content;
  String? _id;

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'timestamp': timestamp,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Message{from: $from, to: $to, timestamp: $timestamp, content: $content}';
  }
}
