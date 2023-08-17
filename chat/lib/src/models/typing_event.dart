enum Typing {
  start,
  stop,
}

extension TypingParser on Typing {
  String value() {
    return toString().split('.').last;
  }

  static Typing fromString(String value) {
    return Typing.values.firstWhere(
      (status) => status.value() == value,
    );
  }
}

class TypingEvent {
  TypingEvent({
    required this.from,
    required this.to,
    required this.event,
  });

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final event = TypingEvent(
      from: json['from'] as String,
      to: json['to'] as String,
      event: TypingParser.fromString(json['event'] as String),
    );
    event._id = json['id'] as String;
    return event;
  }

  final String from;
  final String to;
  final Typing event;
  String? _id;
  String? get id => _id;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'event': event.value(),
      };
}
