import 'dart:async';

import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../../models/receipt.dart';
import '../../models/user.dart';
import 'receipt_service_contract.dart';

class ReceiptService implements IReceiptService {
  ReceiptService(
    this._r,
    this._connection,
  );

  final RethinkDb _r;
  final Connection _connection;

  final _controller = StreamController<Receipt>.broadcast();
  StreamSubscription<Feed>? _changefeed;

  @override
  Future<bool> send(Receipt receipt) async {
    final receiptData = receipt.toJson();
    final record = await _r.table('receipts').insert(receiptData).run(_connection) as Map<String, dynamic>;
    return record['inserted'] == 1;
  }

  @override
  Stream<Receipt> receipts(User user) {
    _startReceivingReceipts(user);
    return _controller.stream;
  }

  @override
  void dispose() {
    _controller.close();
    _cancelChangefeed();
  }

  void _cancelChangefeed() {
    _changefeed?.cancel();
    _changefeed = null;
  }

  void _startReceivingReceipts(User user) {
    _cancelChangefeed();
    _changefeed = _listenToChangefeed(user);
  }

  StreamSubscription<Feed> _listenToChangefeed(User user) {
    return _r
        .table('receipts')
        .filter({'recipient': user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen(_handleFeedEvent);
  }

  void _handleFeedEvent(Feed event) {
    event.forEach(_handleSingleFeedData).catchError((err) => print(err)).onError((error, stackTrace) => print(error));
  }

  void _handleSingleFeedData(feedData) {
    feedData as Map<String, dynamic>;
    if (feedData['new_val'] == null) {
      return;
    }
    final Receipt receipt = _receiptFromFeed(feedData);
    _controller.sink.add(receipt);
  }

  Receipt _receiptFromFeed(Map<String, dynamic> feedData) {
    final receiptData = feedData['new_val'] as Map<String, dynamic>;
    return Receipt.fromJson(receiptData);
  }
}
