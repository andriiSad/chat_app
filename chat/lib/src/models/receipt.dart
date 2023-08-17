enum RecipientStatus {
  sent,
  delivered,
  read,
}

extension EnumParsing on RecipientStatus {
  String value() {
    return toString().split('.').last;
  }

  static RecipientStatus fromString(String value) {
    return RecipientStatus.values.firstWhere(
      (status) => status.value() == value,
    );
  }
}

class Receipt {
  Receipt({
    required this.recipient,
    required this.messageId,
    required this.timestamp,
    required this.status,
  });
  factory Receipt.fromJson(Map<String, dynamic> json) {
    final receipt = Receipt(
      recipient: json['recipient'] as String,
      messageId: json['messageId'] as String,
      status: EnumParsing.fromString(json['status'] as String),
      timestamp: json['timestamp'] as DateTime,
    );
    receipt._id = json['id'] as String;
    return receipt;
  }

  final String recipient;
  final String messageId;
  final DateTime timestamp;
  final RecipientStatus status;
  String? _id;
  String? get id => _id;

  Map<String, dynamic> toJson() => {
        'recipient': recipient,
        'messageId': messageId,
        'status': status.value(),
        'timestamp': timestamp,
      };
}
