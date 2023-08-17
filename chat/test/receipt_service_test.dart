import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late ReceiptService receiptService;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    receiptService = ReceiptService(r, connection);
  });

  tearDown(() async {
    receiptService.dispose();
    await cleanDb(r, connection);
    connection.close();
  });

  final user = User.fromJson({
    'id': '1234',
    'username': 'username',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent receipt successfully', () async {
    final receipt = Receipt(
      recipient: '444',
      messageId: '1234',
      status: RecipientStatus.delivered,
      timestamp: DateTime.now(),
    );
    final res = await receiptService.send(receipt);
    expect(res, true);
  });

  test('successfully subscribe and receive receipts', () async {
    receiptService.receipts(user).listen(expectAsync1((receipt) {
          expect(receipt.recipient, user.id);
        }, count: 2));
    final receipt = Receipt(
      recipient: user.id!,
      messageId: '1234',
      status: RecipientStatus.delivered,
      timestamp: DateTime.now(),
    );

    final anotherReceipt = Receipt(
      recipient: user.id!,
      messageId: '1234',
      status: RecipientStatus.delivered,
      timestamp: DateTime.now(),
    );
    await receiptService.send(receipt);
    await receiptService.send(anotherReceipt);
  });
}
