import 'dart:async';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import 'message_service_contract.dart';

class MessageService implements IMessageService {
  MessageService(
    this._r,
    this._connection,
  );

  final Connection _connection;
  final RethinkDb _r;

  final _controller = StreamController<Message>.broadcast();
  StreamSubscription<Feed>? _changefeed;

  @override
  Future<bool> send(Message message) async {
    final record = await _r
        .table('messages')
        .insert(message.toJson())
        .run(_connection) as Map<String, dynamic>;
    return record['inserted'] == 1;
  }

  @override
  Stream<Message> messages(User activeUser) {
    _startReceivingMessages(activeUser);
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

  void _startReceivingMessages(User user) {
    _cancelChangefeed();
    _changefeed = _listenToChangefeed(user);
  }

  StreamSubscription<Feed> _listenToChangefeed(User user) {
    return _r
        .table('messages')
        .filter({'to': user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen(_handleFeedEvent);
  }

  void _handleFeedEvent(Feed event) {
    event
        .forEach(_handleSingleFeedData)
        .catchError((err) => print(err))
        .onError((error, stackTrace) => print(error));
  }

  void _handleSingleFeedData(feedData) {
    feedData as Map<String, dynamic>;
    if (feedData['new_val'] == null) {
      return;
    }
    final Message message = _messageFromFeed(feedData);
    _controller.sink.add(message);
    _removeDeliveredMessage(message);
  }

  Message _messageFromFeed(Map<String, dynamic> feedData) {
    return Message.fromJson(feedData['new_val'] as Map<String, dynamic>);
  }

  void _removeDeliveredMessage(Message message) {
    _r
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
