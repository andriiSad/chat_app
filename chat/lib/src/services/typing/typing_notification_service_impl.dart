import 'dart:async';

import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../../models/typing_event.dart';
import '../../models/user.dart';
import 'typing_notification_service_contract.dart';

class TypingNotificationService implements ITypingNotification {
  TypingNotificationService(this._r, this._connection);

  final Connection _connection;
  final RethinkDb _r;
  final _controller = StreamController<TypingEvent>.broadcast();
  StreamSubscription<Feed>? _changeFeed;
  @override
  Future<bool> send({required TypingEvent event, required User to}) async {
    if (!to.active) {
      return false;
    }
    final record = await _r.table('typing_events').insert(event.toJson(), {'conflict': 'update'}).run(_connection)
        as Map<String, dynamic>;
    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String> userIds) {
    _startReceivingTypingEvents(user, userIds);
    return _controller.stream;
  }

  @override
  void dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }

  void _cancelChangeFeed() {
    _changeFeed?.cancel();
    _changeFeed = null;
  }

  void _startReceivingTypingEvents(User user, List<String> userIds) {
    _cancelChangeFeed();
    _changeFeed = _listenToChangeFeed(user, userIds);
  }

  StreamSubscription<Feed> _listenToChangeFeed(User user, List<String> userIds) {
    return _r
        .table('typing_events')
        .filter((event) {
          return event('to').eq(user.id).and(_r.expr(userIds).contains(event('from')));
        })
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
    final TypingEvent event = _eventFromFeed(feedData);
    _controller.sink.add(event);
    _removeEvent(event);
  }

  TypingEvent _eventFromFeed(Map<String, dynamic> feedData) {
    final eventData = feedData['new_val'] as Map<String, dynamic>;
    return TypingEvent.fromJson(eventData);
  }

  void _removeEvent(TypingEvent event) {
    _r.table('typing_events').get(event.id).delete({'return_changes': false}).run(_connection);
  }
}
