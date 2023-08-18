enum ReceiptStatus {
  sent,
  delivered,
  read,
}

extension EnumParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }

  static ReceiptStatus fromString(String value) {
    return ReceiptStatus.values.firstWhere(
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
  final ReceiptStatus status;
  String? _id;
  String? get id => _id;

  Map<String, dynamic> toJson() => {
        'recipient': recipient,
        'messageId': messageId,
        'status': status.value(),
        'timestamp': timestamp,
      };
}
